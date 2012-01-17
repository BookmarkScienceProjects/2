/**
  * @file
  * This file implements simple linear algebra functions.
  *
  * @author Arne Vansteenkiste
  */

#ifndef _ADD_H_
#define _ADD_H_

#include <cuda.h>

#ifdef __cplusplus
extern "C" {
#endif

/// dst[i] = a[i] + b[i]
/// @param Npart number of floats per GPU, so total number of floats / nDevice()
void addAsync(float** dst, float** a, float** b, CUstream* stream, int Npart);

/// Multiply-add: a[i] += mulB * b[i]
/// @param Npart number of floats per GPU, so total number of floats / nDevice()
void madd1Async(float** a, float** b, float mulB, CUstream* stream, int Npart);

/// Multiply-add: a[i] += mulB * b[i] + mulC * c[i]
/// @param Npart number of floats per GPU, so total number of floats / nDevice()
void madd2Async(float** a, float** b, float mulB, float** c, float mulC, CUstream* stream, int Npart);


/// Multiply-add: dst[i] = a[i] + mulB * b[i]
/// @param Npart number of floats per GPU, so total number of floats / nDevice()
void maddAsync(float** dst, float** a, float** b, float mulB, CUstream* stream, int Npart);


/// Complex multiply add. 
/// @param dst contains complex numbers (interleaved format)
/// @param src contains real numbers
/// @param NComplexPart: number of complex numbers in dst per GPU (== number of real numbers in src per GPU)
///	dst[i] += c * src[i]
void cmaddAsync(float** dst, float** src, float a, float b, CUstream* stream, int NComplexPart);


#ifdef __cplusplus
}
#endif
#endif
