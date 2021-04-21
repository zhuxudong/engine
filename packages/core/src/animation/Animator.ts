import { AnimatorState } from "./AnimatorState";
import { InterpolableValueType } from "./enums/InterpolableValueType";
import { AnimatorRecorderMode } from "./enums/AnimatorRecorderMode";
import { InterpolableValue } from "./KeyFrame";
import { AnimatorControllerLayer } from "./AnimatorControllerLayer";
import { AnimatorController, AnimatorControllerParameter } from "./AnimatorController";
import { Quaternion, Vector2, Vector3, Vector4 } from "@oasis-engine/math";
import { Component } from "../Component";
import { Entity } from "../Entity";
import { AnimationClip } from "./AnimationClip";
import { AnimatorUtils } from "./AnimatorUtils";
import { AnimateProperty } from "./enums/AnimateProperty";
import { AnimatorLayerBlendingMode } from "./enums/AnimatorLayerBlendingMode";
import { PlayType } from "./enums/PlayType";

export class Animator extends Component {
  /**
   * The mode of the Animator recorder.
   */
  recorderMode: AnimatorRecorderMode = AnimatorRecorderMode.Offline;
  /**
   * The playback speed of the Animator. 1 is normal playback speed.
   */
  speed: number = 1;
  /**
   * TODO: The AnimatorControllerParameter list used by the animator.
   */
  parameters: AnimatorControllerParameter[] = [];

  /**
   * Get the AnimatorController that controls the Animator.
   */
  get animatorController(): AnimatorController {
    return this._animatorController;
  }

  /**
   * Set the AnimatorController that controls the Animator.
   */
  set animatorController(animatorController: AnimatorController) {
    this._animatorController = animatorController;
    if (!animatorController) return;
    animatorController._setTarget(this.entity);
  }

  /**
   * Get all layers from the AnimatorController which belongs this Animator .
   */
  get layers(): Readonly<AnimatorControllerLayer[]> {
    return this._animatorController?.layers || [];
  }

  private _animatorController: AnimatorController;
  private _diffValueFromBasePos: InterpolableValue;
  private _diffFloatFromBasePos: number = 0;
  private _diffVector2FromBasePos: Vector2 = new Vector2();
  private _diffVector3FromBasePos: Vector3 = new Vector3();
  private _diffVector4FromBasePos: Vector4 = new Vector4();
  private _diffQuaternionFromBasePos: Quaternion = new Quaternion();
  private _tempVector3: Vector3 = new Vector3();
  private _tempQuaternion: Quaternion = new Quaternion();

  /**
   * @param entity - The entitiy which the animator component belongs to.
   */
  constructor(entity: Entity) {
    super(entity);
  }

  /**
   * Plays a state by name.
   * @param stateName The state name.
   * @param layerIndex The layer index(default 0).
   * @param normalizedTime The time offset between 0 and 1(default 0).
   */
  playState(stateName: string, layerIndex: number = 0, normalizedTime: number = 0): void {
    const { animatorController } = this;
    if (!animatorController) return;
    const animLayer = animatorController.layers[layerIndex];
    const theState = AnimatorState.findStateByName(stateName);
    theState.frameTime = theState.clip.length * normalizedTime;
    animLayer._playingState = theState;
    this.recorderMode = AnimatorRecorderMode.Playback;
  }

  /**
   * Set the Animator in playback mode.
   */
  play(): void {
    this.recorderMode = AnimatorRecorderMode.Playback;
  }

  /**
   * Stops the animator playback mode.
   */
  stop(): void {
    this.recorderMode = AnimatorRecorderMode.Offline;
  }

  /**
   * Evaluates the animator component based on deltaTime.
   * @param deltaTime - The deltaTime when the animation update.
   * @private
   */
  update(deltaTime: number): void {
    if (this.recorderMode !== AnimatorRecorderMode.Playback) return;
    const { animatorController } = this;
    if (!animatorController) return;
    const { layers } = animatorController;
    for (let i = 0; i < layers.length; i++) {
      const isFirstLayer = i === 0;
      const animLayer = layers[i];
      if (!animLayer._playingState) {
        animLayer._playingState = animLayer.stateMachine.states[0];
      }
      const currentState = animLayer._playingState;
      currentState.frameTime += deltaTime / 1000;
      if (currentState._playType === PlayType.IsFading) {
        const fadingState = animLayer._fadingState;
        if (fadingState) {
          fadingState.frameTime += deltaTime / 1000;
          const nextAnimClip = fadingState.clip;
          if (fadingState.frameTime > nextAnimClip.length) {
            fadingState.frameTime = nextAnimClip.length;
          }
        }
      }
      this._updatePlayingState(currentState, animLayer, isFirstLayer, deltaTime);
    }
  }

  /**
   * crossFade to the AnimationClip by name.
   */
  crossFade(
    name: string,
    layerIndex: number,
    normalizedTransitionDuration: number,
    normalizedTimeOffset: number
  ): void {
    const currentState = this.animatorController.layers[layerIndex]._playingState;
    if (currentState) {
      currentState._playType = PlayType.IsFading;
      const nextState = AnimatorState.findStateByName(name);
      const transition = currentState.addTransition(nextState);
      this.animatorController.layers[layerIndex]._fadingState = nextState;
      transition.solo = true;
      transition.duration = currentState.clip.length * normalizedTransitionDuration;
      transition.offset = nextState.clip.length * normalizedTimeOffset;
      transition.exitTime = currentState.frameTime;
    }
  }

  /**
   * Return the layer by name.
   * @param name The layer name.
   */
  getLayerByName(name: string): AnimatorControllerLayer {
    return AnimatorControllerLayer.findLayerByName(name);
  }

  /**
   * Be called when this instance be enabled.
   * @override
   * @internal
   */
  _onEnable(): void {
    this.engine._componentsManager.addOnUpdateAnimations(this);
  }

  /**
   * Be called when this instance be disabled or it's entity be inActiveInHierarchy or before this instance be destroyed.
   * @override
   * @internal
   */
  _onDisable(): void {
    this.engine._componentsManager.removeOnUpdateAnimations(this);
  }

  private _calculateDiff(
    valueType: InterpolableValueType,
    propertyName: string,
    sVal: InterpolableValue,
    dVal: InterpolableValue
  ) {
    switch (valueType) {
      case InterpolableValueType.Float:
        this._calculateFloatDiff(propertyName, sVal as number, dVal as number);
        break;
      case InterpolableValueType.Vector2:
        this._calculateVector2Diff(propertyName, sVal as Vector2, dVal as Vector2);
        break;
      case InterpolableValueType.Vector3:
        this._calculateVector3Diff(propertyName, sVal as Vector3, dVal as Vector3);
        break;
      case InterpolableValueType.Vector3:
        this._calculateVector4Diff(propertyName, sVal as Vector4, dVal as Vector4);
        break;
      case InterpolableValueType.Quaternion:
        this._calculateQuaternionDiff(dVal as Quaternion, sVal as Quaternion);
        break;
    }
  }

  private _calculateFloatDiff(propertyName: string, sVal: number, dVal: number) {
    if (AnimateProperty[propertyName] === AnimateProperty.scale) {
      this._diffFloatFromBasePos = dVal / sVal;
    } else {
      this._diffFloatFromBasePos = dVal - sVal;
    }
    this._diffValueFromBasePos = this._diffFloatFromBasePos;
  }

  private _calculateVector2Diff(propertyName: string, sVal: Vector2, dVal: Vector2) {
    if (AnimateProperty[propertyName] === AnimateProperty.scale) {
      this._diffVector2FromBasePos.x = dVal.x / sVal.x;
      this._diffVector2FromBasePos.y = dVal.y / sVal.y;
    } else {
      this._diffVector2FromBasePos.x = dVal.x - sVal.x;
      this._diffVector2FromBasePos.y = dVal.y - sVal.y;
    }
    this._diffValueFromBasePos = this._diffVector2FromBasePos;
  }

  private _calculateVector3Diff(propertyName: string, sVal: Vector3, dVal: Vector3) {
    if (AnimateProperty[propertyName] === AnimateProperty.scale) {
      this._diffVector3FromBasePos.x = dVal.x / sVal.x;
      this._diffVector3FromBasePos.y = dVal.y / sVal.y;
      this._diffVector3FromBasePos.z = dVal.z / sVal.z;
    } else {
      this._diffVector3FromBasePos.x = dVal.x - sVal.x;
      this._diffVector3FromBasePos.y = dVal.y - sVal.y;
      this._diffVector3FromBasePos.z = dVal.z - sVal.z;
    }
    this._diffValueFromBasePos = this._diffVector3FromBasePos;
  }

  private _calculateVector4Diff(propertyName: string, sVal: Vector4, dVal: Vector4) {
    if (AnimateProperty[propertyName] === AnimateProperty.scale) {
      this._diffVector4FromBasePos.x = dVal.x / sVal.x;
      this._diffVector4FromBasePos.y = dVal.y / sVal.y;
      this._diffVector4FromBasePos.z = dVal.z / sVal.z;
      this._diffVector4FromBasePos.w = dVal.w / sVal.w;
    } else {
      this._diffVector4FromBasePos.x = dVal.x - sVal.x;
      this._diffVector4FromBasePos.y = dVal.y - sVal.y;
      this._diffVector4FromBasePos.z = dVal.z - sVal.z;
      this._diffVector4FromBasePos.w = dVal.w - sVal.w;
    }
    this._diffValueFromBasePos = this._diffVector4FromBasePos;
  }

  private _calculateQuaternionDiff(dVal: Quaternion, sVal: Quaternion) {
    Quaternion.conjugate(sVal, this._diffQuaternionFromBasePos);
    Quaternion.multiply(this._diffQuaternionFromBasePos, dVal, this._diffQuaternionFromBasePos);
    this._diffValueFromBasePos = this._diffQuaternionFromBasePos;
  }

  private _getCrossFadeValue(
    target: Entity,
    propertyName: string,
    sVal: InterpolableValue,
    dVal: InterpolableValue,
    crossWeight: number
  ) {
    const transform = target.transform;
    switch (AnimateProperty[propertyName]) {
      case AnimateProperty.position:
        Vector3.lerp(sVal as Vector3, dVal as Vector3, crossWeight, this._tempVector3);
        return this._tempVector3;
      case AnimateProperty.rotation:
        Quaternion.slerp(sVal as Quaternion, dVal as Quaternion, crossWeight, this._tempQuaternion);
        return this._tempQuaternion;
      case AnimateProperty.scale: {
        const scale = transform.scale;
        Vector3.lerp(sVal as Vector3, dVal as Vector3, crossWeight, this._tempVector3);
        transform.scale = scale;
        return this._tempVector3;
      }
    }
  }

  private _updateLayerValue(
    target: Entity,
    propertyName: string,
    sVal: InterpolableValue,
    dVal: InterpolableValue,
    weight: number
  ) {
    const transform = target.transform;
    switch (AnimateProperty[propertyName]) {
      case AnimateProperty.position:
        const position = transform.position;
        Vector3.lerp(sVal as Vector3, dVal as Vector3, weight, position);
        transform.position = position as Vector3;
        break;
      case AnimateProperty.rotation:
        const rotationQuaternion = transform.rotationQuaternion;
        Quaternion.slerp(sVal as Quaternion, dVal as Quaternion, weight, rotationQuaternion);
        transform.rotationQuaternion = rotationQuaternion;
        break;
      case AnimateProperty.scale: {
        const scale = transform.scale;
        Vector3.lerp(sVal as Vector3, dVal as Vector3, weight, scale);
        transform.scale = scale;
        break;
      }
    }
  }

  private _updateAdditiveLayerValue(target: Entity, propertyName: string, diffVal: InterpolableValue, weight: number) {
    const transform = (<Entity>target).transform;
    switch (AnimateProperty[propertyName]) {
      case AnimateProperty.position:
        if (diffVal instanceof Vector3) {
          const position = transform.position;
          position.x += diffVal.x;
          position.y += diffVal.y;
          position.z += diffVal.z;
          transform.position = position;
        }
        break;
      case AnimateProperty.rotation:
        if (diffVal instanceof Quaternion) {
          const rotationQuaternion = transform.rotationQuaternion;
          AnimatorUtils.calQuaternionWeight(diffVal, weight, diffVal);
          diffVal.normalize();
          rotationQuaternion.multiply(diffVal);
          transform.rotationQuaternion = rotationQuaternion;
        }
        break;
      case AnimateProperty.scale: {
        if (diffVal instanceof Vector3) {
          const scale = transform.scale;
          AnimatorUtils.calScaleWeight(scale, weight, scale);
          scale.x = scale.x * diffVal.x;
          scale.y = scale.y * diffVal.y;
          scale.z = scale.z * diffVal.z;
          transform.scale = scale;
        }
        break;
      }
      default:
        target[propertyName] += diffVal;
    }
  }

  private _updatePlayingState(
    currentState: AnimatorState,
    animLayer: AnimatorControllerLayer,
    isFirstLayer: boolean,
    deltaTime: number
  ) {
    const { weight, blendingMode } = animLayer;
    if (currentState._playType === PlayType.IsFading) {
      const transitions = currentState.transitions;
      const transition = transitions.filter((transition) => transition.solo)[0];
      const destinationState = transition.destinationState;
      if (transition) {
        let clip = currentState.clip;
        transition._crossFadeFrameTime += deltaTime / 1000;
        let crossWeight: number;
        if (transition.duration > clip.length - transition.exitTime) {
          crossWeight = transition._crossFadeFrameTime / (clip.length - transition.exitTime);
        } else {
          crossWeight = transition._crossFadeFrameTime / transition.duration;
        }
        if (crossWeight >= 1) {
          crossWeight = 1;
          currentState._playType = PlayType.IsFinish;
        }
        let count = clip.curves.length;
        const relativePathList: string[] = [];
        const propertyNameList: string[] = [];
        const relativePathPropertyNameMap: { [key: string]: number } = {};
        const targetPropertyNameValues = [];
        const targetDefaultValues = [];
        const targetList = [];
        for (let i = count - 1; i >= 0; i--) {
          const { curve, propertyName, relativePath, _defaultValue, _target } = clip.curves[i];
          if (!relativePathPropertyNameMap[`${relativePath}_${propertyName}`]) {
            relativePathPropertyNameMap[`${relativePath}_${propertyName}`] = relativePathList.length;
            relativePathList.push(relativePath);
            propertyNameList.push(propertyName);
            const val = curve.evaluate(currentState.frameTime);
            targetPropertyNameValues.push([val]);
            targetDefaultValues.push([_defaultValue]);
            targetList.push([_target]);
          }
        }
        clip = destinationState.clip;
        count = clip.curves.length;
        for (let i = count - 1; i >= 0; i--) {
          const { curve, propertyName, relativePath, _defaultValue, _target } = clip.curves[i];
          if (relativePathPropertyNameMap[`${relativePath}_${propertyName}`] >= 0) {
            const index = relativePathPropertyNameMap[`${relativePath}_${propertyName}`];
            const val = curve.evaluate(transition.offset + transition._crossFadeFrameTime);
            targetPropertyNameValues[index][1] = val;
            targetDefaultValues[index][1] = _defaultValue;
            targetList[index][1] = _target;
          } else {
            relativePathPropertyNameMap[`${relativePath}_${propertyName}`] = relativePathList.length;
            relativePathList.push(relativePath);
            propertyNameList.push(propertyName);
            const val = curve.evaluate(transition.offset + transition._crossFadeFrameTime);
            targetPropertyNameValues.push([null, val]);
            targetDefaultValues.push([null, _defaultValue]);
            targetList.push([null, _target]);
          }
        }
        count = relativePathList.length;
        for (let i = count - 1; i >= 0; i--) {
          const relativePath = relativePathList[i];
          const propertyName = propertyNameList[i];
          const index = relativePathPropertyNameMap[`${relativePath}_${propertyName}`];
          const vals = targetPropertyNameValues[index];
          const defaultValues = targetDefaultValues[index];
          const targets = targetList[index];

          let calculatedValue: InterpolableValue;
          if (vals[0] && vals[1]) {
            calculatedValue = this._getCrossFadeValue(targets[0], propertyName, vals[0], vals[1], crossWeight);
            this._updateLayerValue(targets[0], propertyName, defaultValues[0], calculatedValue, weight);
          } else if (vals[0]) {
            calculatedValue = this._getCrossFadeValue(
              targets[0],
              propertyName,
              defaultValues[0],
              vals[0],
              1 - crossWeight
            );
            this._updateLayerValue(targets[0], propertyName, defaultValues[0], calculatedValue, weight);
          } else {
            calculatedValue = this._getCrossFadeValue(targets[1], propertyName, defaultValues[1], vals[1], crossWeight);
            this._updateLayerValue(targets[1], propertyName, defaultValues[1], calculatedValue, weight);
          }
        }
        if (currentState._playType === PlayType.IsFinish) {
          animLayer._playingState = destinationState;
        }
      }
    } else {
      currentState._playType = PlayType.IsPlaying;
      const clip = currentState.clip;
      const count = clip.curves.length;
      for (let j = count - 1; j >= 0; j--) {
        const { curve, propertyName, _target, _defaultValue } = clip.curves[j];
        const frameTime = clip._getTheRealFrameTime(currentState.frameTime);
        const val = curve.evaluate(frameTime);
        const { _valueType, _firstFrameValue } = curve;
        if (isFirstLayer) {
          this._updateLayerValue(_target, propertyName, _defaultValue, val, 1);
        } else {
          if (blendingMode === AnimatorLayerBlendingMode.Additive) {
            this._calculateDiff(_valueType, propertyName, _firstFrameValue, val);
            this._updateAdditiveLayerValue(_target, propertyName, this._diffValueFromBasePos, weight);
          } else {
            this._updateLayerValue(_target, propertyName, _defaultValue, val, weight);
          }
        }
      }
    }
  }
}