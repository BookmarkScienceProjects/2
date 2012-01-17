
#include "add.h"

#include "multigpu.h"
#include <cuda.h>
#include "gpu_conf.h"
#include "gpu_safe.h"

#ifdef __cplusplus
extern "C" {
#endif

///@internal
__global__ void addKern(float* dst, float* a, float* b, int Npart) {
	int i = threadindex;
	if (i < Npart) {
		dst[i] = a[i] + b[i];
	}
}


void addAsync(float** dst, float** a, float** b, CUstream* stream, int Npart) {
	dim3 gridSize, blockSize;
	make1dconf(Npart, &gridSize, &blockSize);
	for (int dev = 0; dev < nDevice(); dev++) {
		gpu_safe(cudaSetDevice(deviceId(dev)));
		addKern <<<gridSize, blockSize, 0, cudaStream_t(stream[dev])>>> (dst[dev], a[dev], b[dev], Npart);
	}
}



///@internal
__global__ void maddKern(float* dst, float* a, float* b, float mulB, int Npart) {
	int i = threadindex;
	float bMask;
	if (b == NULL){
		bMask = 1.0f;
	}else{
		bMask = b[i];
	}
	if (i < Npart) {
		dst[i] = a[i] + mulB * bMask;
	}
}


void maddAsync(float** dst, float** a, float** b, float mulB, CUstream* stream, int Npart) {
	dim3 gridSize, blockSize;
	make1dconf(Npart, &gridSize, &blockSize);
	for (int dev = 0; dev < nDevice(); dev++) {
		gpu_safe(cudaSetDevice(deviceId(dev)));
		maddKern <<<gridSize, blockSize, 0, cudaStream_t(stream[dev])>>> (dst[dev], a[dev], b[dev], mulB, Npart);
	}
}

///@internal
__global__ void madd1Kern(float* a, float* b, float mulB, int Npart) {
	int i = threadindex;
	float bMask;
	if (b == NULL){
		bMask = 1.0f;
	}else{
		bMask = b[i];
	}
	if (i < Npart) {
		a[i] += mulB * bMask;
	}
}


void madd1Async(float** a, float** b, float mulB, CUstream* stream, int Npart) {
	dim3 gridSize, blockSize;
	make1dconf(Npart, &gridSize, &blockSize);
	for (int dev = 0; dev < nDevice(); dev++) {
		gpu_safe(cudaSetDevice(deviceId(dev)));
		madd1Kern <<<gridSize, blockSize, 0, cudaStream_t(stream[dev])>>> (a[dev], b[dev], mulB, Npart);
	}
}

///@internal
__global__ void madd2Kern(float* a, float* b, float mulB, float* c, float mulC, int Npart) {
	int i = threadindex;

	float bMask;
	if (b == NULL){
		bMask = 1.0f;
	}else{
		bMask = b[i];
	}

	float cMask;
	if (c == NULL){
		cMask = 1.0f;
	}else{
		cMask = c[i];
	}

	if (i < Npart) {
		a[i] += mulB * bMask + mulC * cMask;
	}
}


void madd2Async(float** a, float** b, float mulB, float** c, float mulC, CUstream* stream, int Npart) {
	dim3 gridSize, blockSize;
	make1dconf(Npart, &gridSize, &blockSize);
	for (int dev = 0; dev < nDevice(); dev++) {
		gpu_safe(cudaSetDevice(deviceId(dev)));
		madd2Kern <<<gridSize, blockSize, 0, cudaStream_t(stream[dev])>>> (a[dev], b[dev], mulB, c[dev], mulC, Npart);
	}
}


__global__ void cmaddKern(float* dst, float* src, float a, float b, int NComplexPart){

  int i = threadindex; // complex index
  int e = 2 * i; // real index

  if(i < NComplexPart){

    float s = src[i];

	dst[e  ] += s * a;
	dst[e+1] += s * b;
  }
  
  return;
}

void cmaddAsync(float** dst, float** src, float a, float b, CUstream* stream, int NComplexPart){
	dim3 gridSize, blockSize;
	make1dconf(NComplexPart, &gridSize, &blockSize);
	for (int dev = 0; dev < nDevice(); dev++) {
		gpu_safe(cudaSetDevice(deviceId(dev)));
		cmaddKern <<<gridSize, blockSize, 0, cudaStream_t(stream[dev])>>> (dst[dev], src[dev], a, b, NComplexPart);
	}
}



#ifdef __cplusplus
}
#endif
