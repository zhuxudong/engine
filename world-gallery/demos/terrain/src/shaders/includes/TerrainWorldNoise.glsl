int regionLayerAt(ivec2 regionLocation) {
  int halfMap = material_RegionMapSize / 2;
  ivec2 mapPosition = regionLocation + ivec2(halfMap);
  if (mapPosition.x < 0 || mapPosition.y < 0 ||
      mapPosition.x >= material_RegionMapSize || mapPosition.y >= material_RegionMapSize) {
    return -1;
  }
  return int(texelFetch(material_RegionMap, mapPosition, 0).r) - 1;
}

float worldNoiseCheckRegion(vec2 regionCoordinate) {
  return float(regionLayerAt(ivec2(floor(regionCoordinate))) >= 0);
}

float worldNoiseRegionBlend(vec2 regionCoordinate) {
  regionCoordinate -= 0.5;
  const vec2 offset = vec2(0.0, 1.0);
  float a = worldNoiseCheckRegion(regionCoordinate + offset.xy);
  float b = worldNoiseCheckRegion(regionCoordinate + offset.yy);
  float c = worldNoiseCheckRegion(regionCoordinate + offset.yx);
  float d = worldNoiseCheckRegion(regionCoordinate + offset.xx);
  vec2 weight = smoothstep(vec2(0.0), vec2(1.0), fract(regionCoordinate));
  float blend = mix(mix(d, c, weight.x), mix(a, b, weight.x), weight.y);
  return 1.0 - blend;
}

float worldNoiseHash(vec2 value) {
  return fract(
    10000.0 * sin(17.0 * value.x + value.y * 0.1) * (0.1 + abs(sin(value.y * 13.0 + value.x)))
  );
}

vec3 worldNoise2D(vec2 value) {
  vec2 fractional = fract(value);
  vec2 squared = fractional * fractional;
  vec2 cubed = squared * fractional;
  vec2 inverse = fractional - 1.0;
  vec2 inverseSquared = inverse * inverse;
  vec2 interpolation = cubed * (6.0 * squared + (-15.0 * fractional + 10.0));
  vec2 derivative = 30.0 * squared * inverseSquared;
  vec2 cell = floor(value);
  float a = worldNoiseHash(cell + vec2(0.0, 0.0));
  float b = worldNoiseHash(cell + vec2(1.0, 0.0));
  float c = worldNoiseHash(cell + vec2(0.0, 1.0));
  float d = worldNoiseHash(cell + vec2(1.0, 1.0));
  float k0 = a;
  float k1 = b - a;
  float k2 = c - a;
  float k3 = d - (b + k2);
  return vec3(
    k2 * interpolation.y + (interpolation.x * (k3 * interpolation.y + k1) + k0),
    derivative * (vec2(k3) * interpolation.yx + vec2(k1, k2))
  );
}

float worldNoise(vec2 position, float worldDistance) {
  float amplitude = 0.0;
  float weight = 1.0;
  vec2 derivative = vec2(0.0);
  float requestedOctaves = material_WorldNoiseLodDistance > 0.0
    ? float(material_WorldNoiseMaxOctaves) - floor(worldDistance / material_WorldNoiseLodDistance)
    : float(material_WorldNoiseMinOctaves);
  int octaves = int(
    clamp(requestedOctaves, float(material_WorldNoiseMinOctaves), float(material_WorldNoiseMaxOctaves))
  );
  for (int index = 0; index < octaves; index++) {
    vec3 noise = worldNoise2D(position);
    derivative += noise.yz;
    amplitude += weight * noise.x / (1.0 + dot(derivative, derivative));
    weight *= 0.5;
    position = mat2(vec2(0.8, -0.6), vec2(0.6, 0.8)) * position * 2.0;
  }
  return amplitude;
}

float getWorldNoiseHeight(vec2 regionCoordinate, float worldDistance) {
  float weight = worldNoiseRegionBlend(regionCoordinate);
  if (weight <= 1.0 - material_WorldNoiseRegionBlend) return 0.0;
  float noise = worldNoise(
    (regionCoordinate + material_WorldNoiseOffset.xz * 1024.0 / regionSize()) *
      material_WorldNoiseScale * regionSize() / 1024.0 * 0.1,
    worldDistance
  ) * material_WorldNoiseHeight * 10.0 + material_WorldNoiseOffset.y * 100.0;
  weight = smoothstep(1.0 - material_WorldNoiseRegionBlend, 1.0, weight);
  return mix(0.0, noise, weight);
}

float getWorldNoiseHeightAtWorldPosition(vec2 worldPosition, float worldDistance) {
  vec2 regionCoordinate =
    worldPosition * vertexDensity() * regionTexelSize() + vec2(0.5 * regionTexelSize());
  return getWorldNoiseHeight(regionCoordinate, worldDistance);
}
