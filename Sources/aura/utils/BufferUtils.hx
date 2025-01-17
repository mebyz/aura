package aura.utils;

import haxe.ds.Vector;
import kha.FastFloat;
import kha.arrays.Float32Array;

inline function fillBuffer(buffer: Float32Array, value: FastFloat, length: Int = -1) {
	for (i in 0...(length == -1 ? buffer.length : length)) {
		buffer[i] = value;
	}
}

inline function clearBuffer(buffer: Float32Array, length: Int = -1) {
	fillBuffer(buffer, 0, length);
}

inline function initZeroesI(vector: Vector<Int>) {
	for (i in 0...vector.length) {
		vector[i] = 0;
	}
}

inline function initZeroesF64(vector: Vector<Float>) {
	for (i in 0...vector.length) {
		vector[i] = 0.0;
	}
}

inline function initZeroesF32(vector: Vector<FastFloat>) {
	for (i in 0...vector.length) {
		vector[i] = 0.0;
	}
}

/**
	Creates an empty integer vector with the given length. It is guaranteed to
	be always filled with 0, independent of the target.
**/
inline function createEmptyVecI(length: Int): Vector<Int> {
	#if target.static
		return new Vector<Int>(length);
	#else
		// On dynamic targets, vectors hold `null` after creation instead of 0
		final vec = new Vector<Int>(length);
		inline initZeroesI(vec);
		return vec;
	#end
}

/**
	Creates an empty float vector with the given length. It is guaranteed to be
	always filled with 0, independent of the target.
**/
inline function createEmptyVecF64(length: Int): Vector<Float> {
	#if target.static
		return new Vector<Float>(length);
	#else
		final vec = new Vector<Float>(length);
		inline initZeroesF64(vec);
		return vec;
	#end
}

inline function createEmptyVecF32(length: Int): Vector<FastFloat> {
	#if target.static
		return new Vector<FastFloat>(length);
	#else
		final vec = new Vector<FastFloat>(length);
		inline initZeroesF32(vec);
		return vec;
	#end
}

inline function createEmptyF32Array(length: Int): Float32Array {
	final out = new Float32Array(length);
	clearBuffer(out);
	return out;
}
