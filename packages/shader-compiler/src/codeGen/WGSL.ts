import type {
  IShaderInfo,
  IShaderReflection,
  IShaderResourceReflection,
  IShaderStorageBufferReflection,
  IShaderStructReflection,
  IShaderUniformReflection,
  IShaderVertexInputReflection
} from "@galacean/engine-design";
import { BaseToken, type BranchSignature } from "../common/BaseToken";
import { EShaderStage } from "../common/enums/ShaderStage";
import { Keyword } from "../common/enums/Keyword";
import { TypeAny } from "../common/types";
import { ASTNode, TreeNode } from "../parser/AST";
import { ESymbolType, FnSymbol, StructSymbol, VarSymbol } from "../parser/symbolTable";
import { NodeChild, StructProp, SymbolType } from "../parser/types";
import { ParserUtils } from "../ParserUtils";
import { GLESVisitor } from "./GLESVisitor";
import { VisitorContext } from "./VisitorContext";

type Stage = "vertex" | "fragment" | "compute";

type IOField = {
  name: string;
  type: string;
  location: number;
  branch: BranchSignature;
};

type Resource = IShaderResourceReflection & {
  sourceIndex: number;
  samplerType: string;
  branch: BranchSignature;
};

type Uniform = IShaderUniformReflection & {
  sourceIndex: number;
  branch: BranchSignature;
};

type StorageBuffer = IShaderStorageBufferReflection & {
  sourceIndex: number;
  branch: BranchSignature;
  atomic: boolean;
};

type WorkgroupVariable = {
  name: string;
  type: string;
  arrayLength?: string;
  sourceIndex: number;
  branch: BranchSignature;
  atomic: boolean;
};

type StorageElementReference = {
  kind: "storage";
  storageBuffer: StorageBuffer;
  expression: ASTNode.PostfixExpression;
};

type WorkgroupAtomicReference = {
  kind: "workgroup";
  workgroupVariable: WorkgroupVariable;
  expression: ASTNode.PostfixExpression | ASTNode.VariableIdentifier;
};

type AtomicReference = StorageElementReference | WorkgroupAtomicReference;

/**
 * Direct ShaderLab AST to WGSL code generator.
 * @internal
 */
export class WGSLVisitor extends GLESVisitor {
  private static _singleton: WGSLVisitor;

  private readonly _uniforms = new Map<string, Uniform>();
  private readonly _resources = new Map<string, Resource>();
  private readonly _storageBuffers = new Map<string, StorageBuffer>();
  private readonly _workgroupVariables = new Map<string, WorkgroupVariable>();
  private readonly _structs = new Map<string, StructSymbol>();
  private readonly _vertexInputs = new Map<string, IOField>();
  private readonly _vertexOutputs = new Map<string, IOField>();
  private readonly _fragmentInputs = new Map<string, IOField>();
  private readonly _fragmentOutputs = new Map<string, IOField>();
  private readonly _functionSymbols = new Map<string, FnSymbol[]>();
  private readonly _builtins: Record<Stage, Set<string>> = {
    vertex: new Set(),
    fragment: new Set(),
    compute: new Set()
  };
  private readonly _pointerParameterStack: Set<string>[] = [];
  private readonly _samplerParameterStack: Map<string, string>[] = [];
  private _vertexEntry = "";
  private _fragmentEntry = "";
  private _swizzleTempIndex = 0;
  private _requiresNanHelper = false;
  private _includeGuardMacros = new Set<string>();

  static getVisitor(): WGSLVisitor {
    return (this._singleton ??= new WGSLVisitor());
  }

  /**
   * Set macros that guard complete include chunks rather than shader features.
   * @param macros - Canonical include guard macro names.
   * @returns This visitor.
   * @internal
   */
  setIncludeGuardMacros(macros: ReadonlySet<string>): this {
    this._includeGuardMacros = new Set(macros);
    return this;
  }

  override visitShaderProgram(node: ASTNode.GLShaderProgram, vertexEntry: string, fragmentEntry: string): IShaderInfo {
    this._resetProgram();
    VisitorContext.reset();
    this._vertexEntry = vertexEntry;
    this._fragmentEntry = fragmentEntry;
    this._collectGlobalResources(node, vertexEntry, fragmentEntry);
    this._prepareAtomics(node, false);

    const generated = super.visitShaderProgram(node, vertexEntry, fragmentEntry);
    this._collectFragmentOutputs(node, fragmentEntry);
    const reflection = this._createReflection();
    const declarations = this._createResourceDeclarations();

    return {
      vertex: `${declarations}\n${generated.vertex}\n${this._createVertexWrapper()}`,
      fragment: `${declarations}\n${generated.fragment}\n${this._createFragmentWrapper()}`,
      reflection
    };
  }

  /**
   * Generate a WebGPU compute shader from the same ShaderLab AST used by render passes.
   * @param node - Parsed ShaderLab program.
   * @param computeEntry - Compute entry-point name.
   * @param workgroupSize - Compile-time workgroup dimensions.
   * @returns Generated compute source and structured reflection.
   * @internal
   */
  visitComputeProgram(
    node: ASTNode.GLShaderProgram,
    computeEntry: string,
    workgroupSize: readonly [string, string, string]
  ): IShaderInfo {
    this._resetProgram();
    VisitorContext.reset();
    this._collectGlobalResources(node, "", "", computeEntry);
    this._prepareAtomics(node, true);

    const generated = this._visitComputeProgramBody(node, computeEntry);
    const reflection = this._createReflection();
    const declarations = this._createResourceDeclarations();

    return {
      vertex: "",
      fragment: "",
      compute: `${declarations}\n${generated}\n${this._createComputeWrapper(workgroupSize)}`,
      computeWorkgroupSize: workgroupSize,
      reflection
    };
  }

  override defaultCodeGen(children: NodeChild[]): string {
    return children
      .map((child) => {
        if (child instanceof BaseToken) {
          return this._translateOpaqueLexeme(child.lexeme);
        }
        return child.codeGen(this);
      })
      .join(" ");
  }

  override getOtherGlobal(): void {}

  override getAttributeProp(prop: StructProp): string {
    const name = prop.ident.lexeme;
    if (!this._vertexInputs.has(name)) {
      this._vertexInputs.set(name, {
        name,
        type: this._type(prop.typeInfo),
        location: this._vertexInputs.size,
        branch: prop.ident.branch
      });
    }
    return `var<private> ${name}: ${this._type(prop.typeInfo)};`;
  }

  override getVaryingProp(prop: StructProp): string {
    const name = prop.ident.lexeme;
    const type = this._type(prop.typeInfo);
    const stage = this._stage();
    if (!name || !type) {
      throw new Error(
        `WGSL ${stage} varying is missing semantic metadata (name=${String(name)}, type=${String(type)}, sourceType=${String(prop.typeInfo?.typeLexeme)}).`
      );
    }
    const fields = stage === "vertex" ? this._vertexOutputs : this._fragmentInputs;
    if (!fields.has(name)) {
      fields.set(name, { name, type, location: fields.size, branch: prop.ident.branch });
    }
    return `var<private> ${name}: ${type};`;
  }

  override getMRTProp(prop: StructProp): string {
    const name = prop.ident.lexeme;
    const location = prop.mrtIndex ?? this._fragmentOutputs.size;
    this._fragmentOutputs.set(name, {
      name,
      type: this._type(prop.typeInfo),
      location,
      branch: prop.ident.branch
    });
    return "";
  }

  override visitVariableIdentifier(node: ASTNode.VariableIdentifier): string {
    const original = super.visitVariableIdentifier(node);
    const stage = this._stage();
    const builtin = this._builtinName(original, stage);
    if (builtin) {
      this._builtins[stage].add(original);
      return builtin;
    }
    if (this._uniforms.has(original)) {
      const uniform = this._uniforms.get(original);
      const access = `gsUniforms.${original}`;
      return uniform.type === "bool" ? `(${access} != 0u)` : access;
    }
    if (this._isPointerParameter(original)) {
      return `(*${original})`;
    }
    return original;
  }

  override visitPostfixExpression(node: ASTNode.PostfixExpression): string {
    const result = super.visitPostfixExpression(node);
    if (node.children.length === 4) {
      const root = ParserUtils.extractDirectIdentLexeme(node.children[0] as ASTNode.PostfixExpression);
      const uniform = root ? this._uniforms.get(root) : undefined;
      if (uniform?.arrayLength && this._requiresUniformArrayWrapper(uniform.type)) {
        return `${result}.value`;
      }
    }
    return result;
  }

  override visitFunctionCall(node: ASTNode.FunctionCall): string {
    const call = node.children[0] as ASTNode.FunctionCallGeneric;
    const identifier = call.children[0] as ASTNode.FunctionIdentifier;
    const paramsNode = call.children[2];
    const params = paramsNode instanceof ASTNode.FunctionCallParameterList ? paramsNode.paramNodes : [];

    if (call.fnSymbol instanceof FnSymbol) {
      const functionSymbol = this._resolveFunctionSymbol(identifier.lexeme, params, call.fnSymbol);
      VisitorContext.context.referenceGlobal(functionSymbol.ident, ESymbolType.FN);
      const parameterInfo = functionSymbol.astNode.protoType.parameterList ?? [];
      const args: string[] = [];
      for (let i = 0; i < params.length; i++) {
        const info = parameterInfo[i];
        if (info?.typeInfo && VisitorContext.context.getStructRole(info.typeInfo.typeLexeme)) {
          continue;
        }
        const expression = params[i].codeGen(this);
        const samplerType =
          (info?.typeInfo && this._samplerType(info.typeInfo.typeLexeme)) ??
          (info?.astNode instanceof TreeNode ? this._opaqueSamplerParameter(info.astNode)?.samplerType : undefined);
        if (samplerType) {
          args.push(expression, this._samplerName(expression));
        } else if (info?.astNode instanceof ASTNode.ParameterDeclaration && this._isOutParameter(info.astNode)) {
          const bareExpression = this._stripPointer(expression);
          args.push(this._isPointerParameter(bareExpression) ? bareExpression : `&${bareExpression}`);
        } else {
          args.push(expression);
        }
      }
      return `${this._functionName(functionSymbol.astNode)}(${args.join(", ")})`;
    }

    const name = identifier.lexeme;
    if (name === "barrier" && this._stage() !== "compute") {
      throw new Error("ShaderLab barrier is only supported in compute passes.");
    }
    if (name === "atomicAdd" || name === "atomicLoad" || name === "atomicStore") {
      const expectedParameterCount = name === "atomicLoad" ? 1 : 2;
      const target = params[0] ? this._atomicReference(params[0]) : undefined;
      if (!target || params.length !== expectedParameterCount) {
        throw new Error(
          `ShaderLab ${name} requires a shared int/uint variable or direct shared/storage int/uint array element.`
        );
      }
      const targetCode = params[0].codeGen(this);
      if (name === "atomicLoad") {
        return `atomicLoad(&${targetCode})`;
      }
      const valueCode = params[1].codeGen(this);
      return `${name}(&${targetCode}, ${valueCode})`;
    }

    const args = params.map((param) => param.codeGen(this));
    const textureCall = this._textureCall(name, params, args);
    if (textureCall) {
      return textureCall;
    }

    if (identifier.isBuiltin && typeof identifier.ident !== "string") {
      const matrix = this._matrixScalarConstructor(identifier.ident, params, args);
      if (matrix) {
        return matrix;
      }
    }

    const mapped = this._builtinFunction(name);
    if (mapped === "sqrt" && this._isNegativeConstant(args[0])) {
      this._requiresNanHelper = true;
      return "gs_nan()";
    }
    if (mapped === "gs_mod") {
      return `((${args[0]}) - (${args[1]}) * floor((${args[0]}) / (${args[1]})))`;
    }
    if (mapped === "gs_relational") {
      return `(${args[0]} ${this._relationalOperator(name)} ${args[1]})`;
    }
    if (mapped === "bitcast") {
      const argumentType = this._topLevelExpressionType(params[0], args[0]);
      return `bitcast<${this._bitcastTargetType(name, argumentType)}>(${args[0]})`;
    }
    if ((mapped === "min" || mapped === "max" || mapped === "clamp") && args.length >= 2) {
      const returnType = this._topLevelExpressionType(params[0], args[0]);
      if (returnType.startsWith("vec")) {
        for (let i = 1; i < args.length; i++) {
          const argumentType = this._topLevelExpressionType(params[i], args[i]);
          if (argumentType !== returnType) {
            args[i] = `${returnType}(${args[i]})`;
          }
        }
      }
    }
    if (identifier.isBuiltin && typeof identifier.ident !== "string") {
      const targetType = this._typeFromDataType(identifier.ident);
      const targetComponentType = /<([^>]+)>/.exec(targetType)?.[1] ?? targetType;
      if (targetComponentType !== "bool") {
        for (let i = 0; i < args.length; i++) {
          const argumentType = this._expressionType(params[i]);
          if (argumentType === "bool") {
            args[i] = this._numericFromBool(targetComponentType, args[i]);
          } else if (argumentType.startsWith("vec") && argumentType.endsWith("<bool>")) {
            const numericVectorType = argumentType.replace("<bool>", `<${targetComponentType}>`);
            args[i] = this._numericVectorFromBool(numericVectorType, args[i]);
          }
        }
      }
      return `${targetType}(${args.join(", ")})`;
    }
    return `${mapped}(${args.join(", ")})`;
  }

  override visitFunctionIdentifier(node: ASTNode.FunctionIdentifier): string {
    if (node.isBuiltin && typeof node.ident !== "string") {
      return this._typeFromDataType(node.ident);
    }
    return this._builtinFunction(node.lexeme);
  }

  override visitMacroDefine(node: ASTNode.MacroDefine): string {
    const paramsToken = node.isFunction ? node.children[2] : undefined;
    const params = paramsToken instanceof BaseToken ? paramsToken.lexeme : "";
    const value = node.valueExpression?.codeGen(this) ?? "";
    return `\n#define ${node.macroName}${params}${value ? ` ${value}` : ""}\n`;
  }

  override visitMacroCallFunction(node: ASTNode.MacroCallFunction): string {
    if (!node.aliasesNonBuiltinIdent) {
      return super.visitMacroCallFunction(node);
    }

    for (const reference of node.referenceSymbolNames) {
      const functions = this._functionSymbols.get(reference);
      if (functions?.length !== 1) {
        continue;
      }

      const paramsNode = node.children[2];
      if (!(paramsNode instanceof ASTNode.FunctionCallParameterList)) {
        continue;
      }
      const symbol = functions[0];
      const parameterInfo = symbol.astNode.protoType.parameterList ?? [];
      const params = paramsNode.paramNodes;
      const args: string[] = [];
      for (let i = 0; i < params.length; i++) {
        const info = parameterInfo[i];
        if (info?.typeInfo && VisitorContext.context.getStructRole(info.typeInfo.typeLexeme)) {
          continue;
        }
        const expression = params[i].codeGen(this);
        const samplerType = info?.typeInfo && this._samplerType(info.typeInfo.typeLexeme);
        if (samplerType) {
          args.push(expression, this._samplerName(expression));
        } else if (info?.astNode instanceof ASTNode.ParameterDeclaration && this._isOutParameter(info.astNode)) {
          const bareExpression = this._stripPointer(expression);
          args.push(this._isPointerParameter(bareExpression) ? bareExpression : `&${bareExpression}`);
        } else {
          args.push(expression);
        }
      }
      VisitorContext.context.referenceGlobal(symbol.ident, ESymbolType.FN);
      return `${this._functionName(symbol.astNode)}(${args.join(", ")})`;
    }
    return super.visitMacroCallFunction(node);
  }

  override visitSingleDeclaration(node: ASTNode.SingleDeclaration): string {
    const children = node.children;
    const type = this._typeFromSpecifier(node.typeSpecifier, node.arraySpecifier);
    const name = (children[1] as BaseToken).lexeme;
    const initializer = children[children.length - 1];
    const hasInitializer = children.length === 4 || children.length === 5;
    const declaration = this._isConstType(children[0] as ASTNode.FullySpecifiedType) ? "let" : "var";
    return `${declaration} ${name}: ${type}${hasInitializer ? ` = ${this._code(initializer)}` : ""}`;
  }

  override visitDeclaration(node: ASTNode.Declaration): string {
    const child = node.children[0];
    if (child instanceof ASTNode.InitDeclaratorList) {
      const typeLexeme = child.typeInfo.typeLexeme;
      if (
        VisitorContext.context.isVaryingStruct(typeLexeme) ||
        VisitorContext.context.isMRTStruct(typeLexeme) ||
        VisitorContext.context.isAttributeStruct(typeLexeme)
      ) {
        return "";
      }
      return `${this._emitInitDeclaratorList(child).join(";\n")};`;
    }
    return this.defaultCodeGen(node.children);
  }

  override visitVariableDeclaration(node: ASTNode.VariableDeclaration): string {
    if (!node.isStatic) {
      return "";
    }
    const name = (node.children[1] as BaseToken).lexeme;
    const type = this._typeFromSpecifier(node.type.typeSpecifier);
    const initializer = node.children[node.children.length - 1];
    const value = node.children.length === 4 ? this._code(initializer) : undefined;
    return `const ${name}: ${type}${value ? ` = ${value}` : ""}`;
  }

  override visitGlobalVariableDeclaration(): string {
    return "";
  }

  override visitParameterDeclaration(node: ASTNode.ParameterDeclaration): string {
    if (!node.ident || !node.typeInfo) {
      const opaqueSampler = this._opaqueSamplerParameter(node);
      if (opaqueSampler) {
        const { name, samplerType } = opaqueSampler;
        return `${name}: ${samplerType.texture}, ${name}_sampler: ${samplerType.sampler}`;
      }
      return super.visitParameterDeclaration(node);
    }
    const name = node.ident.lexeme;
    const samplerType = this._samplerType(node.typeInfo.typeLexeme);
    if (samplerType) {
      return `${name}: ${samplerType.texture}, ${name}_sampler: ${samplerType.sampler}`;
    }
    const type = this._type(node.typeInfo);
    return this._isOutParameter(node) ? `${name}: ptr<function, ${type}>` : `_in_${name}: ${type}`;
  }

  override visitFunctionParameterList(node: ASTNode.FunctionParameterList): string {
    const context = VisitorContext.context;
    const output: string[] = [];
    for (const item of node.parameterInfoList) {
      if (item.typeInfo && context.getStructRole(item.typeInfo.typeLexeme)) {
        continue;
      }
      output.push(item.astNode.codeGen(this));
    }
    return output.join(", ");
  }

  override visitFunctionHeader(node: ASTNode.FunctionHeader): string {
    const returnType = node.returnType.typeSpecifier.lexeme;
    const mappedReturn = VisitorContext.context.isVaryingStruct(returnType)
      ? "void"
      : this._typeFromSpecifier(node.returnType.typeSpecifier);
    return `fn ${node.ident.lexeme}(` + (mappedReturn === "void" ? "" : "");
  }

  override visitFunctionDefinition(node: ASTNode.FunctionDefinition): string {
    const name = node.protoType.ident.lexeme;
    const stage = this._stage();
    if (name === VisitorContext.context.stageEntry) {
      const statements = node.statements.codeGen(this);
      return `fn gs_${stage}Entry() ${statements}`;
    }

    const pointerParams = new Set<string>();
    const samplerParams = new Map<string, string>();
    for (const info of node.protoType.parameterList ?? []) {
      if (!(info.astNode instanceof TreeNode)) {
        continue;
      }
      if (
        info.ident &&
        info.typeInfo &&
        info.astNode instanceof ASTNode.ParameterDeclaration &&
        this._isOutParameter(info.astNode)
      ) {
        pointerParams.add(info.ident.lexeme);
      }
      if (info.ident && info.typeInfo && this._samplerType(info.typeInfo.typeLexeme)) {
        samplerParams.set(info.ident.lexeme, info.typeInfo.typeLexeme);
      } else {
        const opaqueSampler = this._opaqueSamplerParameter(info.astNode);
        if (opaqueSampler) {
          samplerParams.set(opaqueSampler.name, opaqueSampler.typeLexeme);
        }
      }
    }
    this._pointerParameterStack.push(pointerParams);
    this._samplerParameterStack.push(samplerParams);
    const parameters = node.protoType.parameterList
      ?.filter((item) => !item.typeInfo || !VisitorContext.context.getStructRole(item.typeInfo.typeLexeme))
      .map((item) => {
        const opaqueSampler = item.astNode instanceof TreeNode ? this._opaqueSamplerParameter(item.astNode) : undefined;
        if (opaqueSampler) {
          const { name, samplerType } = opaqueSampler;
          return `${name}: ${samplerType.texture}, ${name}_sampler: ${samplerType.sampler}`;
        }
        return item.astNode.codeGen(this);
      })
      .join(", ");
    const returnType = this._typeFromSpecifier(node.protoType.returnType.typeSpecifier);
    const body = node.statements.codeGen(this);
    const inputCopies = (node.protoType.parameterList ?? [])
      .filter(
        (item) =>
          item.ident &&
          item.typeInfo &&
          !VisitorContext.context.getStructRole(item.typeInfo.typeLexeme) &&
          item.astNode instanceof ASTNode.ParameterDeclaration &&
          !this._isOutParameter(item.astNode) &&
          !this._samplerType(item.typeInfo.typeLexeme) &&
          !this._opaqueSamplerParameter(item.astNode)
      )
      .map((item) => `var ${item.ident!.lexeme}: ${this._type(item.typeInfo!)} = _in_${item.ident!.lexeme};`)
      .join("\n");
    const mutableBody = inputCopies ? body.replace("{", `{\n${inputCopies}`) : body;
    this._samplerParameterStack.pop();
    this._pointerParameterStack.pop();
    return `fn ${this._functionName(node)}(${parameters ?? ""})${returnType === "void" ? "" : ` -> ${returnType}`} ${mutableBody}`;
  }

  override visitJumpStatement(node: ASTNode.JumpStatement): string {
    if (node.isFragReturnStatement) {
      if (VisitorContext.context.mrtStructs.length) {
        return "return;";
      }
      const expression = node.children[1] as ASTNode.Expression;
      this._fragmentOutputs.set("_gsFragColor", {
        name: "_gsFragColor",
        type: "vec4<f32>",
        location: 0,
        branch: []
      });
      return `_gsFragColor = ${expression.codeGen(this)}; return;`;
    }
    return super.visitJumpStatement(node);
  }

  override visitConditionalExpression(node: ASTNode.ConditionalExpression): string {
    if (node.children.length === 1) {
      return this._code(node.children[0]);
    }
    const condition = (node.children[0] as TreeNode).codeGen(this);
    const whenTrue = (node.children[2] as TreeNode).codeGen(this);
    const whenFalse = (node.children[4] as TreeNode).codeGen(this);
    return `select(${whenFalse}, ${whenTrue}, ${condition})`;
  }

  override visitExpressionStatement(node: ASTNode.ExpressionStatement): string {
    const expression = node.children[0];
    if (expression instanceof ASTNode.Expression && expression.children.length === 1) {
      const assignment = expression.children[0];
      if (assignment instanceof ASTNode.AssignmentExpression && assignment.children.length === 3) {
        const left = this._code(assignment.children[0]);
        const match = /^(.*)\.([xyzwrgba]{2,4})$/.exec(left.trim());
        if (match) {
          const operator = this._code(assignment.children[1]).trim();
          const rightNode = assignment.children[2] as TreeNode & { type?: unknown };
          const right = this._code(rightNode);
          const rightType = this._expressionType(rightNode);
          const isVectorRight = rightType.startsWith("vec");
          const temp = `_gsSwizzle${this._swizzleTempIndex++}`;
          const statements = Array.from(match[2]).map(
            (component, index) =>
              `${match[1]}.${this._canonicalComponent(component)} ${operator} ${temp}${
                isVectorRight ? `[${index}]` : ""
              };`
          );
          return `{ let ${temp} = ${right}; ${statements.join(" ")} }`;
        }
      }
    }
    return this.defaultCodeGen(node.children);
  }

  override visitIterationStatement(node: ASTNode.IterationStatement): string {
    const children = node.children;
    const statementIndex = children.length - 1;
    const prefix = children
      .slice(0, statementIndex)
      .map((child) => this._code(child))
      .join(" ");
    return `${prefix} ${this._ensureBlock(this._code(children[statementIndex]))}`;
  }

  override visitMultiplicativeExpression(node: ASTNode.MultiplicativeExpression): string {
    const children = node.children;
    if (
      children.length === 3 &&
      children[1] instanceof BaseToken &&
      children[1].lexeme === "/" &&
      this._isMatrixExpression(children[0])
    ) {
      return `${this._code(children[0])} * (1.0 / (${this._code(children[2])}))`;
    }
    return this.defaultCodeGen(children);
  }

  override visitSelectionStatement(node: ASTNode.SelectionStatement): string {
    const children = node.children;
    const condition = this._code(children[2]);
    const whenTrue = this._ensureBlock(this._code(children[4]));
    if (children.length === 5) {
      return `if (${condition}) ${whenTrue}`;
    }
    return `if (${condition}) ${whenTrue} else ${this._ensureBlock(this._code(children[6]))}`;
  }

  override visitStructSpecifier(node: ASTNode.StructSpecifier): string {
    const context = VisitorContext.context;
    const role =
      context.attributeStructs.includes(node) ||
      context.varyingStructs.includes(node) ||
      context.mrtStructs.includes(node);
    if (role) {
      return super.visitStructSpecifier(node);
    }

    const name = node.ident?.lexeme;
    if (!name) {
      return "";
    }
    return "";
  }

  private _resetProgram(): void {
    this._uniforms.clear();
    this._resources.clear();
    this._storageBuffers.clear();
    this._workgroupVariables.clear();
    this._structs.clear();
    this._vertexInputs.clear();
    this._vertexOutputs.clear();
    this._fragmentInputs.clear();
    this._fragmentOutputs.clear();
    this._functionSymbols.clear();
    this._builtins.vertex.clear();
    this._builtins.fragment.clear();
    this._builtins.compute.clear();
    this._pointerParameterStack.length = 0;
    this._samplerParameterStack.length = 0;
    this._swizzleTempIndex = 0;
    this._requiresNanHelper = false;
  }

  private _collectGlobalResources(
    node: ASTNode.GLShaderProgram,
    vertexEntry: string,
    fragmentEntry: string,
    computeEntry = ""
  ): void {
    const ioTypes = new Set<string>();
    node.shaderData.symbolTable.forEach((symbol) => {
      if (symbol instanceof FnSymbol) {
        const symbols = this._functionSymbols.get(symbol.ident) ?? [];
        const generatedName = this._functionName(symbol.astNode);
        if (!symbols.some((candidate) => this._functionName(candidate.astNode) === generatedName)) {
          symbols.push(symbol);
        }
        this._functionSymbols.set(symbol.ident, symbols);
      }
      if (
        symbol instanceof FnSymbol &&
        (symbol.ident === vertexEntry || symbol.ident === fragmentEntry || symbol.ident === computeEntry)
      ) {
        for (const param of symbol.astNode.protoType.parameterList ?? []) {
          if (param.typeInfo && typeof param.typeInfo.type === "string") {
            ioTypes.add(param.typeInfo.typeLexeme);
          }
        }
        const returnType = symbol.astNode.protoType.returnType.typeSpecifier;
        if (typeof returnType.type === "string") {
          ioTypes.add(returnType.lexeme);
        }
      }
    });
    node.shaderData.symbolTable.forEach((symbol) => {
      if (symbol instanceof StructSymbol && !ioTypes.has(symbol.ident) && !this._structs.has(symbol.ident)) {
        this._structs.set(symbol.ident, symbol);
      }
    });

    const globals: VarSymbol[] = [];
    node.shaderData.symbolTable.forEach((symbol) => {
      if (
        symbol instanceof VarSymbol &&
        symbol.isGlobalVariable &&
        symbol.astNode instanceof ASTNode.VariableDeclaration &&
        !symbol.astNode.isStatic &&
        !ioTypes.has(symbol.dataType.typeLexeme)
      ) {
        globals.push(symbol);
      }
    });
    globals.sort((left, right) => left.astNode.location.start.index - right.astNode.location.start.index);

    for (const symbol of globals) {
      const name = symbol.ident;
      const branch = (symbol.astNode.children[1] as BaseToken).branch;
      const isWorkgroupVariable = this._containsQualifier(symbol.astNode.children, Keyword.SHARED);
      if (isWorkgroupVariable) {
        if (!computeEntry) {
          throw new Error(`ShaderLab shared variable "${name}" is only supported in compute passes.`);
        }
        if (!this._workgroupVariables.has(name)) {
          this._workgroupVariables.set(name, {
            name,
            type: this._typeFromDataType(symbol.dataType.type, symbol.dataType.typeLexeme),
            arrayLength: this._arrayLength(symbol.dataType.arraySpecifier),
            sourceIndex: symbol.astNode.location.start.index,
            branch,
            atomic: false
          });
        }
        continue;
      }
      const isStorageBuffer = this._containsQualifier(symbol.astNode.children, Keyword.BUFFER);
      if (isStorageBuffer) {
        if (!symbol.dataType.arraySpecifier) {
          throw new Error(`ShaderLab storage buffer "${name}" must be declared as an array.`);
        }
        if (!this._storageBuffers.has(name)) {
          this._storageBuffers.set(name, {
            name,
            binding: 0,
            access: this._containsQualifier(symbol.astNode.children, Keyword.READONLY) ? "read" : "read_write",
            elementType: this._typeFromDataType(symbol.dataType.type, symbol.dataType.typeLexeme),
            arrayLength: this._arrayLength(symbol.dataType.arraySpecifier),
            sourceIndex: symbol.astNode.location.start.index,
            branch,
            atomic: false
          });
        }
        continue;
      }
      const sampler = this._samplerType(symbol.dataType.typeLexeme);
      if (sampler) {
        if (!this._resources.has(name)) {
          this._resources.set(name, {
            name,
            textureBinding: 0,
            samplerBinding: 0,
            textureType: sampler.texture,
            samplerType: sampler.sampler,
            comparison: sampler.sampler === "sampler_comparison",
            sourceIndex: symbol.astNode.location.start.index,
            branch
          });
        }
      } else if (!this._uniforms.has(name)) {
        const arraySpecifier =
          symbol.dataType.arraySpecifier ??
          symbol.astNode.children.find((child) => child instanceof ASTNode.ArraySpecifier);
        this._uniforms.set(name, {
          name,
          type: this._typeFromDataType(symbol.dataType.type, symbol.dataType.typeLexeme),
          arrayLength: this._arrayLength(arraySpecifier as ASTNode.ArraySpecifier | undefined),
          sourceIndex: symbol.astNode.location.start.index,
          branch
        });
      }
    }

    let binding = computeEntry && this._uniforms.size === 0 ? 0 : 1;
    for (const resource of Array.from(this._resources.values()).sort(
      (left, right) => left.sourceIndex - right.sourceIndex
    )) {
      resource.textureBinding = binding++;
      resource.samplerBinding = binding++;
    }
    for (const storageBuffer of Array.from(this._storageBuffers.values()).sort(
      (left, right) => left.sourceIndex - right.sourceIndex
    )) {
      storageBuffer.binding = binding++;
    }
  }

  private _collectFragmentOutputs(node: ASTNode.GLShaderProgram, fragmentEntry: string): void {
    node.shaderData.symbolTable.forEach((symbol) => {
      if (!(symbol instanceof FnSymbol) || symbol.ident !== fragmentEntry) {
        return;
      }
      if (symbol.astNode.protoType.returnType.type === Keyword.VEC4) {
        this._fragmentOutputs.set("_gsFragColor", {
          name: "_gsFragColor",
          type: "vec4<f32>",
          location: 0,
          branch: []
        });
      }
    });
    if (this._builtins.fragment.has("gl_FragColor")) {
      this._fragmentOutputs.set("_gsFragColor", {
        name: "_gsFragColor",
        type: "vec4<f32>",
        location: 0,
        branch: []
      });
    }
  }

  private _createReflection(): IShaderReflection {
    const uniforms = Array.from(this._uniforms.values())
      .sort((left, right) => left.sourceIndex - right.sourceIndex)
      .map(({ sourceIndex: _sourceIndex, branch, ...uniform }) => ({
        ...uniform,
        conditions: this._reflectionConditions(branch)
      }));
    const structs: IShaderStructReflection[] = Array.from(this._structs.values())
      .sort((left, right) => left.astNode.location.start.index - right.astNode.location.start.index)
      .map((symbol) => ({
        name: symbol.ident,
        members: symbol.astNode.propList.map((prop) => ({
          name: prop.ident.lexeme,
          type: this._typeFromDataType(prop.typeInfo.type, prop.typeInfo.typeLexeme),
          arrayLength: this._arrayLength(prop.typeInfo.arraySpecifier),
          conditions: this._reflectionConditions(prop.ident.branch)
        }))
      }));
    const resources = Array.from(this._resources.values())
      .sort((left, right) => left.sourceIndex - right.sourceIndex)
      .map(({ sourceIndex: _sourceIndex, samplerType: _samplerType, branch, ...resource }) => ({
        ...resource,
        conditions: this._reflectionConditions(branch)
      }));
    const vertexInputs: IShaderVertexInputReflection[] = Array.from(this._vertexInputs.values()).map(
      ({ name, type, location }) => ({ name, type, location })
    );
    const fragmentOutputs = Array.from(this._fragmentOutputs.values()).map(({ location }) => location);
    const storageBuffers = Array.from(this._storageBuffers.values())
      .sort((left, right) => left.sourceIndex - right.sourceIndex)
      .map(({ sourceIndex: _sourceIndex, branch, atomic: _atomic, ...storageBuffer }) => ({
        ...storageBuffer,
        conditions: this._reflectionConditions(branch)
      }));
    const reflection: IShaderReflection = { uniforms, structs, resources, vertexInputs, fragmentOutputs };
    if (storageBuffers.length > 0) {
      reflection.storageBuffers = storageBuffers;
    }
    return reflection;
  }

  private _createResourceDeclarations(): string {
    const structs = Array.from(this._structs.values())
      .sort((left, right) => left.astNode.location.start.index - right.astNode.location.start.index)
      .map((symbol) => {
        const members = symbol.astNode.propList.map((prop) =>
          this._guardBranch(prop.ident.branch, `  ${prop.ident.lexeme}: ${this._type(prop.typeInfo)},`)
        );
        return `struct ${symbol.ident} {\n${members.join("\n")}\n}`;
      })
      .join("\n");
    const uniformValues = Array.from(this._uniforms.values()).sort(
      (left, right) => left.sourceIndex - right.sourceIndex
    );
    const wrapperTypes = Array.from(
      new Set(
        uniformValues
          .filter((field) => field.arrayLength && this._requiresUniformArrayWrapper(field.type))
          .map((field) => field.type)
      )
    )
      .map((type) => {
        const storageType = type === "bool" ? "u32" : type;
        return `struct ${this._uniformArrayWrapperName(type)} {\n  @size(16) value: ${storageType},\n}`;
      })
      .join("\n");
    const fields = uniformValues.map((field) => {
      const storageType = field.type === "bool" ? "u32" : field.type;
      const type = field.arrayLength
        ? `array<${
            this._requiresUniformArrayWrapper(field.type) ? this._uniformArrayWrapperName(field.type) : storageType
          }, ${field.arrayLength}>`
        : storageType;
      return this._guardBranch(field.branch, `  ${field.name}: ${type},`);
    });
    const uniformBlock =
      fields.length > 0
        ? `struct GSUniforms {\n${fields.join("\n")}\n}\n@group(0) @binding(0) var<uniform> gsUniforms: GSUniforms;`
        : "";
    const workgroupVariables = Array.from(this._workgroupVariables.values())
      .sort((left, right) => left.sourceIndex - right.sourceIndex)
      .map((variable) => {
        const elementType = variable.atomic ? `atomic<${variable.type}>` : variable.type;
        const type = variable.arrayLength ? `array<${elementType}, ${variable.arrayLength}>` : elementType;
        return this._guardBranch(variable.branch, `var<workgroup> ${variable.name}: ${type};`);
      })
      .join("\n");
    const resources = Array.from(this._resources.values())
      .sort((left, right) => left.sourceIndex - right.sourceIndex)
      .map((resource) =>
        this._guardBranch(
          resource.branch,
          `@group(0) @binding(${resource.textureBinding}) var ${resource.name}: ${resource.textureType};\n` +
            `@group(0) @binding(${resource.samplerBinding}) var ${resource.name}_sampler: ${resource.samplerType};`
        )
      )
      .join("\n");
    const storageBuffers = Array.from(this._storageBuffers.values())
      .sort((left, right) => left.sourceIndex - right.sourceIndex)
      .map((storageBuffer) => {
        const elementType = storageBuffer.atomic ? `atomic<${storageBuffer.elementType}>` : storageBuffer.elementType;
        const arrayType = storageBuffer.arrayLength
          ? `array<${elementType}, ${storageBuffer.arrayLength}>`
          : `array<${elementType}>`;
        return this._guardBranch(
          storageBuffer.branch,
          `@group(0) @binding(${storageBuffer.binding}) var<storage, ${storageBuffer.access}> ${storageBuffer.name}: ${arrayType};`
        );
      })
      .join("\n");
    const nanHelper = this._requiresNanHelper
      ? "fn gs_nan() -> f32 { var bits: u32 = 0x7fc00000u; return bitcast<f32>(bits); }"
      : "";
    return `${structs}\n${wrapperTypes}\n${uniformBlock}\n${workgroupVariables}\n${resources}\n${storageBuffers}\n${nanHelper}`;
  }

  private _prepareAtomics(node: TreeNode, isComputeProgram: boolean): void {
    const atomicTargets = new Set<TreeNode>();
    const visitAtomicCalls = (current: TreeNode): void => {
      if (current instanceof ASTNode.FunctionCall) {
        const call = current.children[0] as ASTNode.FunctionCallGeneric;
        const identifier = call.children[0] as ASTNode.FunctionIdentifier;
        const paramsNode = call.children[2];
        if (
          !(call.fnSymbol instanceof FnSymbol) &&
          (identifier.lexeme === "atomicAdd" ||
            identifier.lexeme === "atomicLoad" ||
            identifier.lexeme === "atomicStore") &&
          paramsNode instanceof ASTNode.FunctionCallParameterList
        ) {
          const name = identifier.lexeme;
          if (!isComputeProgram) {
            throw new Error(`ShaderLab ${name} is only supported in compute passes.`);
          }
          const params = paramsNode.paramNodes;
          const expectedParameterCount = name === "atomicLoad" ? 1 : 2;
          const target = params[0] ? this._atomicReference(params[0]) : undefined;
          if (!target || params.length !== expectedParameterCount) {
            throw new Error(
              `ShaderLab ${name} requires a shared int/uint variable or direct shared/storage int/uint array element.`
            );
          }
          if (target.kind === "storage" && target.storageBuffer.access !== "read_write") {
            throw new Error(`ShaderLab ${name} target "${target.storageBuffer.name}" must be writable.`);
          }
          const targetType =
            target.kind === "storage" ? target.storageBuffer.elementType : target.workgroupVariable.type;
          if (targetType !== "i32" && targetType !== "u32") {
            const targetName = target.kind === "storage" ? target.storageBuffer.name : target.workgroupVariable.name;
            throw new Error(`ShaderLab ${name} target "${targetName}" must contain scalar int or uint values.`);
          }
          if (target.kind === "storage") {
            target.storageBuffer.atomic = true;
          } else {
            target.workgroupVariable.atomic = true;
          }
          atomicTargets.add(target.expression);
        }
      }
      for (const child of current.children) {
        if (child instanceof TreeNode) {
          visitAtomicCalls(child);
        }
      }
    };
    visitAtomicCalls(node);

    if (atomicTargets.size === 0) {
      return;
    }
    const rejectNonAtomicAccess = (current: TreeNode): void => {
      if (current instanceof ASTNode.PostfixExpression && current.children.length === 4) {
        const root = ParserUtils.extractDirectIdentLexeme(current.children[0] as ASTNode.PostfixExpression);
        const storageBuffer = root ? this._storageBuffers.get(root) : undefined;
        if (storageBuffer?.atomic && !atomicTargets.has(current)) {
          throw new Error(
            `ShaderLab storage buffer "${storageBuffer.name}" uses atomic elements; only atomic operations are supported.`
          );
        }
        const workgroupVariable = root ? this._workgroupVariables.get(root) : undefined;
        if (workgroupVariable?.atomic && !atomicTargets.has(current)) {
          throw new Error(
            `ShaderLab shared variable "${workgroupVariable.name}" uses atomic elements; only atomic operations are supported.`
          );
        }
      } else if (current instanceof ASTNode.VariableIdentifier) {
        const name = ParserUtils.extractDirectIdentLexeme(current);
        const workgroupVariable = name ? this._workgroupVariables.get(name) : undefined;
        if (workgroupVariable?.atomic && !workgroupVariable.arrayLength && !atomicTargets.has(current)) {
          throw new Error(
            `ShaderLab shared variable "${workgroupVariable.name}" is atomic; only atomic operations are supported.`
          );
        }
      }
      for (const child of current.children) {
        if (child instanceof TreeNode) {
          rejectNonAtomicAccess(child);
        }
      }
    };
    rejectNonAtomicAccess(node);
  }

  private _storageElementReference(node: TreeNode): StorageElementReference | undefined {
    let current = node;
    while (current.children.length === 1 && current.children[0] instanceof TreeNode) {
      current = current.children[0];
    }
    if (!(current instanceof ASTNode.PostfixExpression) || current.children.length !== 4) {
      return undefined;
    }
    const root = ParserUtils.extractDirectIdentLexeme(current.children[0] as ASTNode.PostfixExpression);
    const storageBuffer = root ? this._storageBuffers.get(root) : undefined;
    return storageBuffer ? { kind: "storage", storageBuffer, expression: current } : undefined;
  }

  private _atomicReference(node: TreeNode): AtomicReference | undefined {
    const storageReference = this._storageElementReference(node);
    if (storageReference) {
      return storageReference;
    }

    let current = node;
    while (current.children.length === 1 && current.children[0] instanceof TreeNode) {
      current = current.children[0];
    }
    if (current instanceof ASTNode.VariableIdentifier) {
      const name = ParserUtils.extractDirectIdentLexeme(current);
      const workgroupVariable = name ? this._workgroupVariables.get(name) : undefined;
      if (workgroupVariable && !workgroupVariable.arrayLength) {
        return { kind: "workgroup", workgroupVariable, expression: current };
      }
      return undefined;
    }
    if (!(current instanceof ASTNode.PostfixExpression) || current.children.length !== 4) {
      return undefined;
    }
    const root = ParserUtils.extractDirectIdentLexeme(current.children[0] as ASTNode.PostfixExpression);
    const workgroupVariable = root ? this._workgroupVariables.get(root) : undefined;
    return workgroupVariable?.arrayLength ? { kind: "workgroup", workgroupVariable, expression: current } : undefined;
  }

  private _createVertexWrapper(): string {
    const builtins = this._builtins.vertex;
    const inputFields = Array.from(this._vertexInputs.values()).map((field) =>
      this._guardField(field, `  @location(${field.location}) ${field.name}: ${field.type},`)
    );
    if (builtins.has("gl_VertexID")) {
      inputFields.push("  @builtin(vertex_index) vertexIndex: u32,");
    }
    if (builtins.has("gl_InstanceID")) {
      inputFields.push("  @builtin(instance_index) instanceIndex: u32,");
    }

    const outputFields = ["  @builtin(position) position: vec4<f32>,"];
    for (const field of this._vertexOutputs.values()) {
      outputFields.push(
        this._guardField(
          field,
          `  @location(${field.location})${this._interpolation(field.type)} ${field.name}: ${field.type},`
        )
      );
    }

    const privateBuiltins = ["var<private> _gsPosition: vec4<f32>;"];
    if (builtins.has("gl_VertexID")) {
      privateBuiltins.push("var<private> _gsVertexIndex: i32;");
    }
    if (builtins.has("gl_InstanceID")) {
      privateBuiltins.push("var<private> _gsInstanceIndex: i32;");
    }
    const assignments = Array.from(this._vertexInputs.values()).map((field) =>
      this._guardField(field, `  ${field.name} = input.${field.name};`)
    );
    if (builtins.has("gl_VertexID")) {
      assignments.push("  _gsVertexIndex = i32(input.vertexIndex);");
    }
    if (builtins.has("gl_InstanceID")) {
      assignments.push("  _gsInstanceIndex = i32(input.instanceIndex);");
    }

    const outputs = [
      "  output.position = vec4<f32>(_gsPosition.xy, (_gsPosition.z + _gsPosition.w) * 0.5, _gsPosition.w);"
    ];
    for (const field of this._vertexOutputs.values()) {
      outputs.push(this._guardField(field, `  output.${field.name} = ${field.name};`));
    }

    const inputDeclaration = inputFields.length > 0 ? `struct GSVertexInput {\n${inputFields.join("\n")}\n}` : "";
    return `${privateBuiltins.join("\n")}
${inputDeclaration}
struct GSVertexOutput {
${outputFields.join("\n")}
}
@vertex fn main(${inputFields.length > 0 ? "input: GSVertexInput" : ""}) -> GSVertexOutput {
${assignments.join("\n")}
  gs_vertexEntry();
  var output: GSVertexOutput;
${outputs.join("\n")}
  return output;
}`;
  }

  private _createFragmentWrapper(): string {
    const builtins = this._builtins.fragment;
    const inputFields = Array.from(this._fragmentInputs.values()).map((field) => {
      if (!field.type) {
        throw new Error(`WGSL fragment input "${field.name}" has no resolved type.`);
      }
      return this._guardField(
        field,
        `  @location(${field.location})${this._interpolation(field.type)} ${field.name}: ${field.type},`
      );
    });
    if (builtins.has("gl_FragCoord")) {
      inputFields.push("  @builtin(position) fragCoord: vec4<f32>,");
    }
    if (builtins.has("gl_FrontFacing")) {
      inputFields.push("  @builtin(front_facing) frontFacing: bool,");
    }

    const outputFields = Array.from(this._fragmentOutputs.values()).map((field) =>
      this._guardField(field, `  @location(${field.location}) ${field.name}: ${field.type},`)
    );
    if (builtins.has("gl_FragDepth")) {
      outputFields.push("  @builtin(frag_depth) fragDepth: f32,");
    }

    const privateFields = Array.from(this._fragmentOutputs.values()).map((field) =>
      this._guardField(field, `var<private> ${field.name}: ${field.type};`)
    );
    if (builtins.has("gl_FragCoord")) {
      privateFields.push("var<private> _gsFragCoord: vec4<f32>;");
    }
    if (builtins.has("gl_FrontFacing")) {
      privateFields.push("var<private> _gsFrontFacing: bool;");
    }
    if (builtins.has("gl_FragDepth")) {
      privateFields.push("var<private> _gsFragDepth: f32;");
    }

    const inputs = Array.from(this._fragmentInputs.values()).map((field) =>
      this._guardField(field, `  ${field.name} = input.${field.name};`)
    );
    if (builtins.has("gl_FragCoord")) {
      inputs.push("  _gsFragCoord = input.fragCoord;");
    }
    if (builtins.has("gl_FrontFacing")) {
      inputs.push("  _gsFrontFacing = input.frontFacing;");
    }

    const outputs = Array.from(this._fragmentOutputs.values()).map((field) =>
      this._guardField(field, `  output.${field.name} = ${field.name};`)
    );
    if (builtins.has("gl_FragDepth")) {
      outputs.push("  output.fragDepth = _gsFragDepth;");
    }

    const hasOutputs = outputFields.length > 0;
    const inputDeclaration = inputFields.length > 0 ? `struct GSFragmentInput {\n${inputFields.join("\n")}\n}` : "";
    if (!hasOutputs) {
      return `${privateFields.join("\n")}
${inputDeclaration}
@fragment fn main(${inputFields.length > 0 ? "input: GSFragmentInput" : ""}) {
${inputs.join("\n")}
  gs_fragmentEntry();
}`;
    }

    return `${privateFields.join("\n")}
${inputDeclaration}
struct GSFragmentOutput {
${outputFields.join("\n")}
}
@fragment fn main(${inputFields.length > 0 ? "input: GSFragmentInput" : ""}) -> GSFragmentOutput {
${inputs.join("\n")}
  gs_fragmentEntry();
  var output: GSFragmentOutput;
${outputs.join("\n")}
  return output;
}`;
  }

  private _createComputeWrapper(workgroupSize: readonly [string, string, string]): string {
    const builtins = this._builtins.compute;
    const inputs: string[] = [];
    const privateFields: string[] = [];
    const assignments: string[] = [];
    const addBuiltin = (sourceName: string, wgslName: string, type: string, privateName: string): void => {
      if (!builtins.has(sourceName)) {
        return;
      }
      inputs.push(`@builtin(${wgslName}) ${privateName.substring(3)}: ${type}`);
      privateFields.push(`var<private> ${privateName}: ${type};`);
      assignments.push(`  ${privateName} = ${privateName.substring(3)};`);
    };

    addBuiltin("gl_GlobalInvocationID", "global_invocation_id", "vec3<u32>", "_gsGlobalInvocationID");
    addBuiltin("gl_LocalInvocationID", "local_invocation_id", "vec3<u32>", "_gsLocalInvocationID");
    addBuiltin("gl_WorkGroupID", "workgroup_id", "vec3<u32>", "_gsWorkGroupID");
    addBuiltin("gl_LocalInvocationIndex", "local_invocation_index", "u32", "_gsLocalInvocationIndex");
    addBuiltin("gl_NumWorkGroups", "num_workgroups", "vec3<u32>", "_gsNumWorkGroups");

    return `${privateFields.join("\n")}
@compute @workgroup_size(${workgroupSize.join(", ")})
fn main(${inputs.join(", ")}) {
${assignments.join("\n")}
  gs_computeEntry();
}`;
  }

  private _emitInitDeclaratorList(node: ASTNode.InitDeclaratorList): string[] {
    const children = node.children;
    if (children.length === 1) {
      return [(children[0] as ASTNode.SingleDeclaration).codeGen(this)];
    }
    const output = this._emitInitDeclaratorList(children[0] as ASTNode.InitDeclaratorList);
    const name = (children[2] as BaseToken).lexeme;
    const array = children[3] instanceof ASTNode.ArraySpecifier ? children[3] : node.typeInfo.arraySpecifier;
    const initializer = children[children.length - 1];
    const value = children.length === 5 || children.length === 6 ? ` = ${this._code(initializer)}` : "";
    output.push(`var ${name}: ${this._type(node.typeInfo, array)}${value}`);
    return output;
  }

  private _textureCall(
    name: string,
    paramNodes: Array<ASTNode.AssignmentExpression | ASTNode.MacroCallArgBlock>,
    args: string[]
  ): string | undefined {
    const samplingNames = new Set([
      "texture",
      "texture2D",
      "textureCube",
      "texture2DProj",
      "texture2DLodEXT",
      "textureCubeLodEXT",
      "textureLod",
      "texture2DGradEXT",
      "textureCubeGradEXT",
      "textureGrad",
      "texelFetch",
      "textureSize"
    ]);
    if (!samplingNames.has(name) || args.length === 0) {
      return undefined;
    }
    const texture = args[0];
    const sampler = this._samplerName(texture);
    const resourceType = this._resourceType(paramNodes[0], texture);
    const comparison = resourceType?.includes("depth");

    if (name === "textureSize") {
      if (resourceType?.includes("2d_array")) {
        return `vec3<i32>(vec2<i32>(textureDimensions(${texture}, ${args[1]})), i32(textureNumLayers(${texture})))`;
      }
      return `vec2<i32>(textureDimensions(${texture}, ${args[1]}))`;
    }
    if (name === "texelFetch") {
      if (resourceType?.includes("2d_array")) {
        return `textureLoad(${texture}, (${args[1]}).xy, (${args[1]}).z, ${args[2]})`;
      }
      return `textureLoad(${texture}, ${args[1]}, ${args[2]})`;
    }
    if (comparison) {
      return `textureSampleCompare(${texture}, ${sampler}, (${args[1]}).xy, (${args[1]}).z)`;
    }
    const is2DArray = resourceType?.includes("2d_array");
    if (name.includes("Grad")) {
      if (is2DArray) {
        return `textureSampleGrad(${texture}, ${sampler}, (${args[1]}).xy, i32((${args[1]}).z), ${args[2]}, ${args[3]})`;
      }
      return `textureSampleGrad(${texture}, ${sampler}, ${args[1]}, ${args[2]}, ${args[3]})`;
    }
    if (name.includes("Lod") || name === "textureLod") {
      if (is2DArray) {
        return `textureSampleLevel(${texture}, ${sampler}, (${args[1]}).xy, i32((${args[1]}).z), ${args[2]})`;
      }
      return `textureSampleLevel(${texture}, ${sampler}, ${args[1]}, ${args[2]})`;
    }
    if (args.length >= 3) {
      if (is2DArray) {
        return `textureSampleBias(${texture}, ${sampler}, (${args[1]}).xy, i32((${args[1]}).z), ${args[2]})`;
      }
      return `textureSampleBias(${texture}, ${sampler}, ${args[1]}, ${args[2]})`;
    }
    if (is2DArray) {
      return `textureSample(${texture}, ${sampler}, (${args[1]}).xy, i32((${args[1]}).z))`;
    }
    return `textureSample(${texture}, ${sampler}, ${args[1]})`;
  }

  private _builtinFunction(name: string): string {
    switch (name) {
      case "atan":
        return "atan2";
      case "inversesqrt":
        return "inverseSqrt";
      case "barrier":
        return "workgroupBarrier";
      case "dFdx":
        return "dpdx";
      case "dFdy":
        return "dpdy";
      case "mod":
        return "gs_mod";
      case "floatBitsToInt":
      case "floatBitsToUint":
      case "intBitsToFloat":
      case "uintBitsToFloat":
        return "bitcast";
      case "packHalf2x16":
        return "pack2x16float";
      case "unpackHalf2x16":
        return "unpack2x16float";
      case "lessThan":
      case "lessThanEqual":
      case "greaterThan":
      case "greaterThanEqual":
      case "equal":
      case "notEqual":
        return "gs_relational";
      case "not":
        return "not";
      default:
        return name;
    }
  }

  private _bitcastTargetType(name: string, argumentType: string): string {
    const componentType = name === "floatBitsToInt" ? "i32" : name === "floatBitsToUint" ? "u32" : "f32";
    const vectorSize = /^vec([234])</.exec(argumentType)?.[1];
    return vectorSize ? `vec${vectorSize}<${componentType}>` : componentType;
  }

  private _relationalOperator(name: string): string {
    return (
      {
        lessThan: "<",
        lessThanEqual: "<=",
        greaterThan: ">",
        greaterThanEqual: ">=",
        equal: "==",
        notEqual: "!="
      } as Record<string, string>
    )[name];
  }

  private _type(typeInfo: SymbolType, array = typeInfo.arraySpecifier): string {
    const base = this._typeFromDataType(typeInfo.type, typeInfo.typeLexeme);
    const length = this._arrayLength(array);
    return length ? `array<${base}, ${length}>` : base;
  }

  private _typeFromSpecifier(specifier: ASTNode.TypeSpecifier, array = specifier.arraySpecifier): string {
    const base = this._typeFromDataType(specifier.type, specifier.lexeme);
    const length = this._arrayLength(array);
    return length ? `array<${base}, ${length}>` : base;
  }

  private _typeFromDataType(type: unknown, fallback?: string): string {
    if (typeof type === "string") {
      return this._mapTypeLexeme(type);
    }
    if (type && typeof type === "object" && "type" in type) {
      const typeInfo = type as { type: unknown; typeLexeme?: string };
      return this._typeFromDataType(typeInfo.type, typeInfo.typeLexeme ?? fallback);
    }
    switch (type) {
      case Keyword.VOID:
        return "void";
      case Keyword.BOOL:
        return "bool";
      case Keyword.INT:
        return "i32";
      case Keyword.UINT:
        return "u32";
      case Keyword.FLOAT:
      case Keyword.DOUBLE:
        return "f32";
      case Keyword.BVEC2:
        return "vec2<bool>";
      case Keyword.BVEC3:
        return "vec3<bool>";
      case Keyword.BVEC4:
        return "vec4<bool>";
      case Keyword.IVEC2:
        return "vec2<i32>";
      case Keyword.IVEC3:
        return "vec3<i32>";
      case Keyword.IVEC4:
        return "vec4<i32>";
      case Keyword.UVEC2:
        return "vec2<u32>";
      case Keyword.UVEC3:
        return "vec3<u32>";
      case Keyword.UVEC4:
        return "vec4<u32>";
      case Keyword.VEC2:
        return "vec2<f32>";
      case Keyword.VEC3:
        return "vec3<f32>";
      case Keyword.VEC4:
        return "vec4<f32>";
      case Keyword.MAT2:
        return "mat2x2<f32>";
      case Keyword.MAT3:
        return "mat3x3<f32>";
      case Keyword.MAT4:
        return "mat4x4<f32>";
      case Keyword.MAT2X3:
        return "mat2x3<f32>";
      case Keyword.MAT2X4:
        return "mat2x4<f32>";
      case Keyword.MAT3X2:
        return "mat3x2<f32>";
      case Keyword.MAT3X4:
        return "mat3x4<f32>";
      case Keyword.MAT4X2:
        return "mat4x2<f32>";
      case Keyword.MAT4X3:
        return "mat4x3<f32>";
      default:
        return this._mapTypeLexeme(fallback ?? String(type));
    }
  }

  private _expressionType(node: NodeChild | undefined): string {
    if (!node || node instanceof BaseToken) {
      return "";
    }
    if (
      node instanceof ASTNode.PostfixExpression &&
      node.children.length === 3 &&
      node.children[2] instanceof BaseToken
    ) {
      const memberName = node.children[2].lexeme;
      if (/^[xyzwrgba]{1,4}$/.test(memberName)) {
        const baseType = this._expressionType(node.children[0]);
        const componentType = /<([^>]+)>/.exec(baseType)?.[1] ?? "f32";
        return memberName.length === 1 ? componentType : `vec${memberName.length}<${componentType}>`;
      }
      const baseType = this._expressionType(node.children[0]);
      const member = this._structs
        .get(baseType)
        ?.astNode.propList.find((property) => property.ident.lexeme === memberName);
      if (member) {
        return this._type(member.typeInfo);
      }
    }
    if (node instanceof ASTNode.FunctionCall) {
      const call = node.children[0] as ASTNode.FunctionCallGeneric;
      const identifier = call.children[0] as ASTNode.FunctionIdentifier;
      const paramsNode = call.children[2];
      if (call.fnSymbol instanceof FnSymbol && paramsNode instanceof ASTNode.FunctionCallParameterList) {
        const functionSymbol = this._resolveFunctionSymbol(identifier.lexeme, paramsNode.paramNodes, call.fnSymbol);
        return this._typeFromSpecifier(functionSymbol.astNode.protoType.returnType.typeSpecifier);
      }
    }
    const directType = (node as TreeNode & { type?: unknown }).type;
    if (directType !== undefined && directType !== TypeAny && !this._containsOverloadedFunctionCall(node)) {
      const resolved = this._typeFromDataType(directType);
      if (resolved !== String(TypeAny)) {
        return resolved;
      }
    }
    if (node instanceof ASTNode.FunctionCall) {
      const call = node.children[0] as ASTNode.FunctionCallGeneric;
      const identifier = call.children[0] as ASTNode.FunctionIdentifier;
      if (
        identifier.lexeme === "dot" ||
        identifier.lexeme === "length" ||
        identifier.lexeme === "distance" ||
        identifier.lexeme === "determinant"
      ) {
        return "f32";
      }
    }
    for (const child of node.children) {
      if (
        child instanceof BaseToken &&
        (child.lexeme === "<" ||
          child.lexeme === ">" ||
          child.lexeme === "<=" ||
          child.lexeme === ">=" ||
          child.lexeme === "==" ||
          child.lexeme === "!=" ||
          child.lexeme === "&&" ||
          child.lexeme === "||" ||
          child.lexeme === "!")
      ) {
        return "bool";
      }
    }
    const constructorName = node.constructor?.name;
    if (
      node.children.length > 1 &&
      (constructorName === "RelationalExpression" ||
        constructorName === "EqualityExpression" ||
        constructorName === "LogicalAndExpression" ||
        constructorName === "LogicalXorExpression" ||
        constructorName === "LogicalOrExpression")
    ) {
      return "bool";
    }

    let scalarType = "";
    let matrixType = "";
    for (const child of node.children) {
      const resolved = this._expressionType(child);
      if (resolved.startsWith("vec")) {
        return resolved;
      }
      if (!matrixType && resolved.startsWith("mat")) {
        matrixType = resolved;
      }
      if (!scalarType && resolved) {
        scalarType = resolved;
      }
    }
    return matrixType || scalarType;
  }

  private _topLevelExpressionType(node: NodeChild | undefined, expression: string): string {
    const swizzle = /\.([xyzwrgba]{1,4})\s*\)?$/.exec(expression.trim());
    if (swizzle) {
      const size = swizzle[1].length;
      const inferredType = this._expressionType(node);
      const componentType = /<([^>]+)>/.exec(inferredType)?.[1] ?? "f32";
      return size === 1 ? componentType : `vec${size}<${componentType}>`;
    }
    if (/^(?:dot|length|distance|determinant)\s*\(/.test(expression.trim())) {
      return "f32";
    }
    return this._expressionType(node);
  }

  private _mapTypeLexeme(type: string): string {
    return (
      (
        {
          void: "void",
          bool: "bool",
          int: "i32",
          uint: "u32",
          float: "f32",
          double: "f32",
          bvec2: "vec2<bool>",
          bvec3: "vec3<bool>",
          bvec4: "vec4<bool>",
          ivec2: "vec2<i32>",
          ivec3: "vec3<i32>",
          ivec4: "vec4<i32>",
          uvec2: "vec2<u32>",
          uvec3: "vec3<u32>",
          uvec4: "vec4<u32>",
          vec2: "vec2<f32>",
          vec3: "vec3<f32>",
          vec4: "vec4<f32>",
          mat2: "mat2x2<f32>",
          mat3: "mat3x3<f32>",
          mat4: "mat4x4<f32>",
          mat2x3: "mat2x3<f32>",
          mat2x4: "mat2x4<f32>",
          mat3x2: "mat3x2<f32>",
          mat3x4: "mat3x4<f32>",
          mat4x2: "mat4x2<f32>",
          mat4x3: "mat4x3<f32>"
        } as Record<string, string>
      )[type] ?? type
    );
  }

  private _numericFromBool(type: string, expression: string): string {
    const values = type === "f32" ? ["0.0", "1.0"] : type === "u32" ? ["0u", "1u"] : ["0i", "1i"];
    return `select(${values[0]}, ${values[1]}, ${expression})`;
  }

  private _numericVectorFromBool(type: string, expression: string): string {
    const componentType = /<([^>]+)>/.exec(type)?.[1] ?? "f32";
    const zero = componentType === "f32" ? "0.0" : componentType === "u32" ? "0u" : "0i";
    const one = componentType === "f32" ? "1.0" : componentType === "u32" ? "1u" : "1i";
    return `select(${type}(${zero}), ${type}(${one}), ${expression})`;
  }

  private _samplerType(type: string): { texture: string; sampler: "sampler" | "sampler_comparison" } | undefined {
    switch (type) {
      case "sampler2D":
        return { texture: "texture_2d<f32>", sampler: "sampler" };
      case "isampler2D":
        return { texture: "texture_2d<i32>", sampler: "sampler" };
      case "usampler2D":
        return { texture: "texture_2d<u32>", sampler: "sampler" };
      case "sampler2DArray":
        return { texture: "texture_2d_array<f32>", sampler: "sampler" };
      case "isampler2DArray":
        return { texture: "texture_2d_array<i32>", sampler: "sampler" };
      case "usampler2DArray":
        return { texture: "texture_2d_array<u32>", sampler: "sampler" };
      case "samplerCube":
        return { texture: "texture_cube<f32>", sampler: "sampler" };
      case "sampler2DShadow":
        return { texture: "texture_depth_2d", sampler: "sampler_comparison" };
      default:
        return undefined;
    }
  }

  private _arrayLength(array?: ASTNode.ArraySpecifier): string | undefined {
    if (!array || array.children.length < 3) {
      return undefined;
    }
    return this._code(array.children[1]);
  }

  private _stage(): Stage {
    switch (VisitorContext.context.stage) {
      case EShaderStage.VERTEX:
        return "vertex";
      case EShaderStage.FRAGMENT:
        return "fragment";
      default:
        return "compute";
    }
  }

  private _builtinName(name: string, stage: Stage): string | undefined {
    if (stage === "vertex") {
      return (
        {
          gl_Position: "_gsPosition",
          gl_VertexID: "_gsVertexIndex",
          gl_InstanceID: "_gsInstanceIndex"
        } as Record<string, string>
      )[name];
    }
    if (stage === "compute") {
      return (
        {
          gl_GlobalInvocationID: "_gsGlobalInvocationID",
          gl_LocalInvocationID: "_gsLocalInvocationID",
          gl_WorkGroupID: "_gsWorkGroupID",
          gl_LocalInvocationIndex: "_gsLocalInvocationIndex",
          gl_NumWorkGroups: "_gsNumWorkGroups"
        } as Record<string, string>
      )[name];
    }
    return (
      {
        gl_FragCoord: "_gsFragCoord",
        gl_FrontFacing: "_gsFrontFacing",
        gl_FragDepth: "_gsFragDepth",
        gl_FragColor: "_gsFragColor"
      } as Record<string, string>
    )[name];
  }

  private _isOutParameter(node: ASTNode.ParameterDeclaration): boolean {
    return this._containsQualifier(node.children, Keyword.OUT) || this._containsQualifier(node.children, Keyword.INOUT);
  }

  private _containsQualifier(children: NodeChild[], qualifier: Keyword): boolean {
    for (const child of children) {
      if (child instanceof BaseToken && child.type === qualifier) {
        return true;
      }
      if (child instanceof TreeNode && this._containsQualifier(child.children, qualifier)) {
        return true;
      }
    }
    return false;
  }

  private _isConstType(type: ASTNode.FullySpecifiedType): boolean {
    return this._containsQualifier(type.children, Keyword.CONST);
  }

  private _isPointerParameter(name: string): boolean {
    for (let i = this._pointerParameterStack.length - 1; i >= 0; i--) {
      if (this._pointerParameterStack[i].has(name)) {
        return true;
      }
    }
    return false;
  }

  private _stripPointer(expression: string): string {
    return expression.startsWith("(*") && expression.endsWith(")") ? expression.slice(2, -1) : expression;
  }

  private _samplerName(textureExpression: string): string {
    const name = this._stripPointer(textureExpression);
    return `${name}_sampler`;
  }

  private _resourceType(
    node: ASTNode.AssignmentExpression | ASTNode.MacroCallArgBlock,
    expression: string
  ): string | undefined {
    const bare = ParserUtils.unwrapBareIdentifier(node as ASTNode.AssignmentExpression, {
      allowParens: true
    });
    const name = bare?.getLexeme(this) ?? expression;
    return this._resources.get(name)?.textureType ?? this._samplerTypeFromParameters(name);
  }

  private _samplerTypeFromParameters(name: string): string | undefined {
    for (let i = this._samplerParameterStack.length - 1; i >= 0; i--) {
      const type = this._samplerParameterStack[i].get(name);
      if (type) {
        return this._samplerType(type)?.texture;
      }
    }
    return undefined;
  }

  private _interpolation(type: string): string {
    return type.includes("<i32>") || type.includes("<u32>") ? " @interpolate(flat)" : "";
  }

  private _functionName(node: ASTNode.FunctionDefinition): string {
    const name = node.protoType.ident.lexeme;
    const signature = (node.protoType.parameterList ?? [])
      .map((parameter) => parameter.typeInfo?.typeLexeme ?? "macro")
      .join("_");
    return `gs_${name}_${signature || "void"}`.replace(/[^A-Za-z0-9_]/g, "_");
  }

  private _ensureBlock(statement: string): string {
    const trimmed = statement.trim();
    return trimmed.startsWith("{") ? trimmed : `{ ${trimmed} }`;
  }

  private _canonicalComponent(component: string): string {
    return (
      (
        {
          r: "x",
          g: "y",
          b: "z",
          a: "w"
        } as Record<string, string>
      )[component] ?? component
    );
  }

  private _guardField(field: IOField, code: string): string {
    return this._guardBranch(field.branch, code);
  }

  private _guardBranch(branch: BranchSignature, code: string): string {
    const semanticBranch = this._semanticBranch(branch);
    if (semanticBranch.length === 0) {
      return code;
    }
    const prefix = semanticBranch
      .map((condition) =>
        condition.expression
          ? condition.defined
            ? `#if ${condition.expression}`
            : `#if !(${condition.expression})`
          : `${condition.defined ? "#ifdef" : "#ifndef"} ${condition.name}`
      )
      .join("\n");
    return `${prefix}\n${code}\n${"#endif\n".repeat(semanticBranch.length).trimEnd()}`;
  }

  private _reflectionConditions(branch: BranchSignature): BranchSignature | undefined {
    const semanticBranch = this._semanticBranch(branch).filter((condition) => !condition.expression);
    return semanticBranch.length > 0 ? semanticBranch : undefined;
  }

  private _semanticBranch(branch: BranchSignature): BranchSignature {
    return branch.filter((condition) => condition.defined || !this._includeGuardMacros.has(condition.name));
  }

  private _resolveFunctionSymbol(
    name: string,
    params: readonly (ASTNode.AssignmentExpression | ASTNode.MacroCallArgBlock)[],
    fallback: FnSymbol
  ): FnSymbol {
    const candidates = this._functionSymbols.get(name);
    if (!candidates || candidates.length < 2) {
      return fallback;
    }
    const argumentTypes = params.map((param) => this._expressionType(param));
    const matches = candidates.filter((candidate) => {
      const parameterList = candidate.astNode.protoType.parameterList ?? [];
      if (parameterList.length !== argumentTypes.length) {
        return false;
      }
      return parameterList.every((parameter, index) => {
        if (!parameter.typeInfo || !argumentTypes[index]) {
          return true;
        }
        return this._type(parameter.typeInfo) === argumentTypes[index];
      });
    });
    return matches.length === 1 ? matches[0] : fallback;
  }

  private _containsOverloadedFunctionCall(node: TreeNode): boolean {
    if (node instanceof ASTNode.FunctionCall) {
      const call = node.children[0] as ASTNode.FunctionCallGeneric;
      const identifier = call.children[0] as ASTNode.FunctionIdentifier;
      if (call.fnSymbol instanceof FnSymbol && (this._functionSymbols.get(identifier.lexeme)?.length ?? 0) > 1) {
        return true;
      }
    }
    return node.children.some((child) => child instanceof TreeNode && this._containsOverloadedFunctionCall(child));
  }

  private _opaqueSamplerParameter(node: TreeNode):
    | {
        name: string;
        typeLexeme: string;
        samplerType: { texture: string; sampler: "sampler" | "sampler_comparison" };
      }
    | undefined {
    if (node instanceof ASTNode.ParameterDeclaration) {
      const macroSampler = this._opaqueSamplerMacroParameter(node);
      if (macroSampler) {
        return macroSampler;
      }
    }
    const source =
      node instanceof ASTNode.ParameterDeclaration ? super.visitParameterDeclaration(node) : node.codeGen(this);
    const match =
      /(?:^|\s)(?:(?:lowp|mediump|highp)\s+)?(sampler2DShadow|[iu]?sampler2D(?:Array)?|samplerCube)\s+([A-Za-z_]\w*)\b/m.exec(
        source
      );
    if (!match) {
      return undefined;
    }
    const samplerType = this._samplerType(match[1]);
    return samplerType ? { name: match[2], typeLexeme: match[1], samplerType } : undefined;
  }

  private _opaqueSamplerMacroParameter(node: ASTNode.ParameterDeclaration):
    | {
        name: string;
        typeLexeme: string;
        samplerType: { texture: string; sampler: "sampler" | "sampler_comparison" };
      }
    | undefined {
    const macroCall = node.children.find(
      (child): child is ASTNode.MacroCallFunction => child instanceof ASTNode.MacroCallFunction
    );
    const paramsNode = macroCall?.children[2];
    if (!macroCall || !(paramsNode instanceof ASTNode.FunctionCallParameterList)) {
      return undefined;
    }

    const candidates: {
      name: string;
      typeLexeme: string;
      samplerType: { texture: string; sampler: "sampler" | "sampler_comparison" };
    }[] = [];
    for (const definition of macroCall.visibleMacroDefinitions) {
      if (!definition.valueText) {
        continue;
      }
      const match =
        /(?:^|\s)(?:(?:lowp|mediump|highp)\s+)?(sampler2DShadow|[iu]?sampler2D(?:Array)?|samplerCube)\s+([A-Za-z_]\w*)\b/.exec(
          definition.valueText
        );
      if (!match) {
        continue;
      }
      const samplerType = this._samplerType(match[1]);
      const parameterIndex = definition.params.indexOf(match[2]);
      const actualParameter = paramsNode.paramNodes[parameterIndex];
      if (samplerType && actualParameter) {
        candidates.push({
          name: actualParameter.codeGen(this).trim(),
          typeLexeme: match[1],
          samplerType
        });
      }
    }
    return candidates.find((candidate) => candidate.typeLexeme === "sampler2DShadow") ?? candidates[0];
  }

  private _requiresUniformArrayWrapper(type: string): boolean {
    return type === "bool" || type === "f32" || type === "i32" || type === "u32" || type.startsWith("vec2<");
  }

  private _uniformArrayWrapperName(type: string): string {
    return `GSUniformArray_${type}`.replace(/[^A-Za-z0-9_]/g, "_");
  }

  private _isMatrixExpression(child: NodeChild): boolean {
    if (child instanceof BaseToken) {
      return false;
    }
    const type = (child as TreeNode & { type?: unknown }).type;
    if (
      type === Keyword.MAT2 ||
      type === Keyword.MAT3 ||
      type === Keyword.MAT4 ||
      type === Keyword.MAT2X3 ||
      type === Keyword.MAT2X4 ||
      type === Keyword.MAT3X2 ||
      type === Keyword.MAT3X4 ||
      type === Keyword.MAT4X2 ||
      type === Keyword.MAT4X3
    ) {
      return true;
    }
    return child.children.length === 1 && this._isMatrixExpression(child.children[0]);
  }

  private _isNegativeConstant(expression: string | undefined): boolean {
    if (!expression) {
      return false;
    }
    const compact = expression.replace(/[()\s]/g, "");
    return /^-\d+(?:\.\d*)?(?:e[+-]?\d+)?$/i.test(compact);
  }

  private _matrixScalarConstructor(
    type: unknown,
    params: Array<ASTNode.AssignmentExpression | ASTNode.MacroCallArgBlock>,
    args: string[]
  ): string | undefined {
    if (args.length !== 1) {
      return undefined;
    }
    const dimensions = (
      {
        [Keyword.MAT2]: [2, 2],
        [Keyword.MAT3]: [3, 3],
        [Keyword.MAT4]: [4, 4],
        [Keyword.MAT2X3]: [2, 3],
        [Keyword.MAT2X4]: [2, 4],
        [Keyword.MAT3X2]: [3, 2],
        [Keyword.MAT3X4]: [3, 4],
        [Keyword.MAT4X2]: [4, 2],
        [Keyword.MAT4X3]: [4, 3]
      } as Record<number, [columns: number, rows: number]>
    )[type as number];
    if (!dimensions) {
      return undefined;
    }
    const [columns, rows] = dimensions;
    if (params[0] instanceof TreeNode && this._isMatrixExpression(params[0])) {
      const sourceType = this._expressionType(params[0]);
      const sourceDimensions = /^mat(\d)x(\d)<f32>$/.exec(sourceType);
      if (!sourceDimensions) {
        return undefined;
      }
      const sourceColumns = Number(sourceDimensions[1]);
      const sourceRows = Number(sourceDimensions[2]);
      const columnValues = Array.from({ length: columns }, (_, column) => {
        const values = Array.from({ length: rows }, (_, row) =>
          column < sourceColumns && row < sourceRows ? `${args[0]}[${column}][${row}]` : row === column ? "1.0" : "0.0"
        );
        return `vec${rows}<f32>(${values.join(", ")})`;
      });
      return `mat${columns}x${rows}<f32>(${columnValues.join(", ")})`;
    }
    const columnValues = Array.from({ length: columns }, (_, column) => {
      const values = Array.from({ length: rows }, (_, row) => (row === column ? args[0] : "0.0"));
      return `vec${rows}<f32>(${values.join(", ")})`;
    });
    return `mat${columns}x${rows}<f32>(${columnValues.join(", ")})`;
  }

  private _translateOpaqueLexeme(lexeme: string): string {
    if (lexeme.startsWith("#extension") || lexeme.startsWith("precision ")) {
      return "";
    }
    if (!lexeme.startsWith("#")) {
      return lexeme;
    }
    return lexeme
      .replace(/\bfloat\b/g, "f32")
      .replace(/\bvec2\b/g, "vec2<f32>")
      .replace(/\bvec3\b/g, "vec3<f32>")
      .replace(/\bvec4\b/g, "vec4<f32>")
      .replace(/\bmat2\b/g, "mat2x2<f32>")
      .replace(/\bmat3\b/g, "mat3x3<f32>")
      .replace(/\bmat4\b/g, "mat4x4<f32>")
      .replace(/\btexture2D\b/g, "texture")
      .replace(/\btextureCube\b/g, "texture");
  }

  private _code(child: NodeChild): string {
    return child instanceof BaseToken ? this._translateOpaqueLexeme(child.lexeme) : child.codeGen(this);
  }
}
