import 'dart:typed_data';

void multiplyAdd({
  required double factorA,
  required Float32List factorB,
  required Float32List dest,
}) {
  final length = factorB.length;
  // Use SIMD for 4x faster mixing if length is multiple of 4
  if (length % 4 == 0) {
    final factorX4 = Float32x4.splat(factorA);
    final factorBView = factorB.buffer.asFloat32x4List();
    final destView = dest.buffer.asFloat32x4List();
    for (var i = 0; i < factorBView.length; i++) {
      destView[i] = destView[i] + (factorX4 * factorBView[i]);
    }
  } else {
    for (int i = 0; i < length; i++) {
      dest[i] += factorA * factorB[i];
    }
  }
}

void multiplyAddStep({
  required double factorA,
  required double step,
  required Float32List factorB,
  required Float32List dest,
}) {
  var a = factorA;
  for (int i = 0; i < factorB.length; i++) {
    dest[i] += a * factorB[i];
    a += step;
  }
}
