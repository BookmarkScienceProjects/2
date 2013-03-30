#include "uniaxialanisotropy.h"

#include "multigpu.h"
#include <cuda.h>
#include "gpu_conf.h"
#include "gpu_safe.h"

#ifdef __cplusplus
extern "C" {
#endif

__global__ void cubic4AnisotropyKern (float *hx, float *hy, float *hz, 
                                     float *mx, float *my, float *mz,
                                     float *K1_map, float *mSat_map, float K1_Mu0Msat_mul, 
                                     float *anisC1_mapx, float anisC1_mulx,
                                     float *anisC1_mapy, float anisC1_muly,
                                     float *anisC1_mapz, float anisC1_mulz,
                                     float *anisC2_mapx, float anisC2_mulx,
                                     float *anisC2_mapy, float anisC2_muly,
                                     float *anisC2_mapz, float anisC2_mulz,
                                     int Npart){

  int i = threadindex;

  if (i < Npart){

	float mSat_mask;
	if (mSat_map ==NULL){
		mSat_mask = 1.0f;
	}else{
		mSat_mask = mSat_map[i];
		if (mSat_mask == 0.0f){
			mSat_mask = 1.0f; // do not divide by zero
		}
	}

    float K1_Mu0Msat; // 2 * K1 / Mu0 * Msat
    if (K1_map==NULL){
      K1_Mu0Msat = K1_Mu0Msat_mul / mSat_mask;
	}else{
      K1_Mu0Msat = (K1_Mu0Msat_mul / mSat_mask) * K1_map[i];
	}

    float u1x;
    if (anisC1_mapx==NULL){
      u1x = anisC1_mulx;
    }else{
      u1x = anisC1_mulx*anisC1_mapx[i];
    }

    float u1y;
    if (anisC1_mapy==NULL){
      u1y = anisC1_muly;
    }else{
      u1y = anisC1_muly*anisC1_mapy[i];
    }

    float u1z;
    if (anisC1_mapz==NULL){
      u1z = anisC1_mulz;
    }else{
      u1z = anisC1_mulz*anisC1_mapz[i];
    }

    float u2x;
    if (anisC2_mapx==NULL){
      u2x = anisC2_mulx;
    }else{
      u2x = anisC2_mulx*anisC2_mapx[i];
    }

    float u2y;
    if (anisC2_mapy==NULL){
      u2y = anisC2_muly;
    }else{
      u2y = anisC2_muly*anisC2_mapy[i];
    }

    float u2z;
    if (anisC2_mapz==NULL){
      u2z = anisC2_mulz;
    }else{
      u2z = anisC2_mulz*anisC2_mapz[i];
    }

    float u3x = u1y*u2z-u1z*u2y;
    float u3y = u1z*u2x-u1x*u2z;
    float u3z = u1x*u2y-u1y*u2x;

    float a1 = u1x*mx[i] + u1y*my[i] + u1z*mz[i];
    float a1sq = a1*a1;
    float a2 = u2x*mx[i] + u2y*my[i] + u2z*mz[i];
    float a2sq = a2*a2;
    float a3 = u3x*mx[i] + u3y*my[i] + u3z*mz[i];
    float a3sq = a3*a3;

    hx[i] = (a1*(a2sq+a3sq))*u1x + (a2*(a1sq+a3sq))*u2x + (a3*(a1sq+a2sq))*u3x;
    hy[i] = (a1*(a2sq+a3sq))*u1y + (a2*(a1sq+a3sq))*u2y + (a3*(a1sq+a2sq))*u3y;
    hz[i] = (a1*(a2sq+a3sq))*u1z + (a2*(a1sq+a3sq))*u2z + (a3*(a1sq+a2sq))*u3z;

    hx[i] *= K1_Mu0Msat;
    hy[i] *= K1_Mu0Msat;
    hz[i] *= K1_Mu0Msat;

  }

}

__global__ void cubic6AnisotropyKern (float *hx, float *hy, float *hz, 
                                     float *mx, float *my, float *mz,
                                     float *K1_map, float *K2_map, float *mSat_map, float K1_Mu0Msat_mul, float K2_Mu0Msat_mul, 
                                     float *anisC1_mapx, float anisC1_mulx,
                                     float *anisC1_mapy, float anisC1_muly,
                                     float *anisC1_mapz, float anisC1_mulz,
                                     float *anisC2_mapx, float anisC2_mulx,
                                     float *anisC2_mapy, float anisC2_muly,
                                     float *anisC2_mapz, float anisC2_mulz,
                                     int Npart){

  int i = threadindex;

  if (i < Npart){

	float mSat_mask;
	if (mSat_map ==NULL){
		mSat_mask = 1.0f;
	}else{
		mSat_mask = mSat_map[i];
		if (mSat_mask == 0.0f){
			mSat_mask = 1.0f; // do not divide by zero
		}
	}

    float K1_Mu0Msat; // 2 * K1 / Mu0 * Msat
    if (K1_map==NULL){
      K1_Mu0Msat = K1_Mu0Msat_mul / mSat_mask;
	}else{
      K1_Mu0Msat = (K1_Mu0Msat_mul / mSat_mask) * K1_map[i];
	}

    float K2_Mu0Msat; // 2 * K2 / Mu0 * Msat
    if (K2_map==NULL){
      K2_Mu0Msat = K2_Mu0Msat_mul / mSat_mask;
	}else{
      K2_Mu0Msat = (K2_Mu0Msat_mul / mSat_mask) * K2_map[i];
	}

    float u1x;
    if (anisC1_mapx==NULL){
      u1x = anisC1_mulx;
    }else{
      u1x = anisC1_mulx*anisC1_mapx[i];
    }

    float u1y;
    if (anisC1_mapy==NULL){
      u1y = anisC1_muly;
    }else{
      u1y = anisC1_muly*anisC1_mapy[i];
    }

    float u1z;
    if (anisC1_mapz==NULL){
      u1z = anisC1_mulz;
    }else{
      u1z = anisC1_mulz*anisC1_mapz[i];
    }

    float u2x;
    if (anisC2_mapx==NULL){
      u2x = anisC2_mulx;
    }else{
      u2x = anisC2_mulx*anisC2_mapx[i];
    }

    float u2y;
    if (anisC2_mapy==NULL){
      u2y = anisC2_muly;
    }else{
      u2y = anisC2_muly*anisC2_mapy[i];
    }

    float u2z;
    if (anisC2_mapz==NULL){
      u2z = anisC2_mulz;
    }else{
      u2z = anisC2_mulz*anisC2_mapz[i];
    }

    float u3x = u1y*u2z-u1z*u2y;
    float u3y = u1z*u2x-u1x*u2z;
    float u3z = u1x*u2y-u1y*u2x;

    float a1 = u1x*mx[i] + u1y*my[i] + u1z*mz[i];
    float a1sq = a1*a1;
    float a2 = u2x*mx[i] + u2y*my[i] + u2z*mz[i];
    float a2sq = a2*a2;
    float a3 = u3x*mx[i] + u3y*my[i] + u3z*mz[i];
    float a3sq = a3*a3;

    hx[i] = ((a1*(a2sq+a3sq))*u1x + (a2*(a1sq+a3sq))*u2x + (a3*(a1sq+a2sq))*u3x) * K1_Mu0Msat;
    hy[i] = ((a1*(a2sq+a3sq))*u1y + (a2*(a1sq+a3sq))*u2y + (a3*(a1sq+a2sq))*u3y) * K1_Mu0Msat;
    hz[i] = ((a1*(a2sq+a3sq))*u1z + (a2*(a1sq+a3sq))*u2z + (a3*(a1sq+a2sq))*u3z) * K1_Mu0Msat;

    hx[i] += (a1*a2sq*a3sq*u1x + a2*a1sq*a3sq*u2x + a3*a1sq*a2sq*u3x) * K2_Mu0Msat;
    hy[i] += (a1*a2sq*a3sq*u1y + a2*a1sq*a3sq*u2y + a3*a1sq*a2sq*u3y) * K2_Mu0Msat;
    hz[i] += (a1*a2sq*a3sq*u1z + a2*a1sq*a3sq*u2z + a3*a1sq*a2sq*u3z) * K2_Mu0Msat;

  }

}

__global__ void cubic8AnisotropyKern (float *hx, float *hy, float *hz, 
                                     float *mx, float *my, float *mz,
                                     float *K1_map, float *K2_map, float *K3_map, float *mSat_map, float K1_Mu0Msat_mul, float K2_Mu0Msat_mul, float K3_Mu0Msat_mul, 
                                     float *anisC1_mapx, float anisC1_mulx,
                                     float *anisC1_mapy, float anisC1_muly,
                                     float *anisC1_mapz, float anisC1_mulz,
                                     float *anisC2_mapx, float anisC2_mulx,
                                     float *anisC2_mapy, float anisC2_muly,
                                     float *anisC2_mapz, float anisC2_mulz,
                                     int Npart){

  int i = threadindex;

  if (i < Npart){

	float mSat_mask;
	if (mSat_map ==NULL){
		mSat_mask = 1.0f;
	}else{
		mSat_mask = mSat_map[i];
		if (mSat_mask == 0.0f){
			mSat_mask = 1.0f; // do not divide by zero
		}
	}

    float K1_Mu0Msat; // 2 * K1 / Mu0 * Msat
    if (K1_map==NULL){
      K1_Mu0Msat = K1_Mu0Msat_mul / mSat_mask;
	}else{
      K1_Mu0Msat = (K1_Mu0Msat_mul / mSat_mask) * K1_map[i];
	}

    float K2_Mu0Msat; // 2 * K2 / Mu0 * Msat
    if (K2_map==NULL){
      K2_Mu0Msat = K2_Mu0Msat_mul / mSat_mask;
	}else{
      K2_Mu0Msat = (K2_Mu0Msat_mul / mSat_mask) * K2_map[i];
	}

    float K3_Mu0Msat; // 4 * K3 / Mu0 * Msat
    if (K3_map==NULL){
      K3_Mu0Msat = K3_Mu0Msat_mul / mSat_mask;
	}else{
      K3_Mu0Msat = (K3_Mu0Msat_mul / mSat_mask) * K3_map[i];
	}

    float u1x;
    if (anisC1_mapx==NULL){
      u1x = anisC1_mulx;
    }else{
      u1x = anisC1_mulx*anisC1_mapx[i];
    }

    float u1y;
    if (anisC1_mapy==NULL){
      u1y = anisC1_muly;
    }else{
      u1y = anisC1_muly*anisC1_mapy[i];
    }

    float u1z;
    if (anisC1_mapz==NULL){
      u1z = anisC1_mulz;
    }else{
      u1z = anisC1_mulz*anisC1_mapz[i];
    }

    float u2x;
    if (anisC2_mapx==NULL){
      u2x = anisC2_mulx;
    }else{
      u2x = anisC2_mulx*anisC2_mapx[i];
    }

    float u2y;
    if (anisC2_mapy==NULL){
      u2y = anisC2_muly;
    }else{
      u2y = anisC2_muly*anisC2_mapy[i];
    }

    float u2z;
    if (anisC2_mapz==NULL){
      u2z = anisC2_mulz;
    }else{
      u2z = anisC2_mulz*anisC2_mapz[i];
    }

    float u3x = u1y*u2z-u1z*u2y;
    float u3y = u1z*u2x-u1x*u2z;
    float u3z = u1x*u2y-u1y*u2x;

    float a1 = u1x*mx[i] + u1y*my[i] + u1z*mz[i];
    float a1sq = a1*a1;
    float a14t = a1sq*a1sq;
    float a2 = u2x*mx[i] + u2y*my[i] + u2z*mz[i];
    float a2sq = a2*a2;
    float a24t = a2sq*a2sq;
    float a3 = u3x*mx[i] + u3y*my[i] + u3z*mz[i];
    float a3sq = a3*a3;
    float a34t = a3sq*a3sq;

    hx[i] = ((a1*(a2sq+a3sq))*u1x + (a2*(a1sq+a3sq))*u2x + (a3*(a1sq+a2sq))*u3x) * K1_Mu0Msat;
    hy[i] = ((a1*(a2sq+a3sq))*u1y + (a2*(a1sq+a3sq))*u2y + (a3*(a1sq+a2sq))*u3y) * K1_Mu0Msat;
    hz[i] = ((a1*(a2sq+a3sq))*u1z + (a2*(a1sq+a3sq))*u2z + (a3*(a1sq+a2sq))*u3z) * K1_Mu0Msat;

    hx[i] += (a1*a2sq*a3sq*u1x + a2*a1sq*a3sq*u2x + a3*a1sq*a2sq*u3x) * K2_Mu0Msat;
    hy[i] += (a1*a2sq*a3sq*u1y + a2*a1sq*a3sq*u2y + a3*a1sq*a2sq*u3y) * K2_Mu0Msat;
    hz[i] += (a1*a2sq*a3sq*u1z + a2*a1sq*a3sq*u2z + a3*a1sq*a2sq*u3z) * K2_Mu0Msat;

    hx[i] += (a1*(a24t+a34t)*a1sq*u1x + a2*(a14t+a34t)*a2sq*u2x + a3*(a14t+a24t)*a3sq*u3x) * K3_Mu0Msat;
    hy[i] += (a1*(a24t+a34t)*a1sq*u1y + a2*(a14t+a34t)*a2sq*u2y + a3*(a14t+a24t)*a3sq*u3y) * K3_Mu0Msat;
    hz[i] += (a1*(a24t+a34t)*a1sq*u1z + a2*(a14t+a34t)*a2sq*u2z + a3*(a14t+a24t)*a3sq*u3z) * K3_Mu0Msat;

  }

}



__export__ void cubic4AnisotropyAsync(float **hx, float **hy, float **hz, 
                          float **mx, float **my, float **mz,
                          float **K1_map, float **MSat_map, float K1_Mu0Msat_mul, 
                          float **anisC1_mapx, float anisC1_mulx,
                          float **anisC1_mapy, float anisC1_muly,
                          float **anisC1_mapz, float anisC1_mulz,
                          float **anisC2_mapx, float anisC2_mulx,
                          float **anisC2_mapy, float anisC2_muly,
                          float **anisC2_mapz, float anisC2_mulz,
                          CUstream* stream, int Npart){

  dim3 gridSize, blockSize;
  make1dconf(Npart, &gridSize, &blockSize);

  for (int dev=0; dev<nDevice(); dev++){
    assert(hx[dev] != NULL);
    assert(hy[dev] != NULL);
    assert(hz[dev] != NULL);
    assert(mx[dev] != NULL);
    assert(my[dev] != NULL);
    assert(mz[dev] != NULL);
    gpu_safe(cudaSetDevice(deviceId(dev)));

    cubic4AnisotropyKern<<<gridSize, blockSize, 0, cudaStream_t(stream[dev])>>> (
					hx[dev],hy[dev],hz[dev],  
                    mx[dev],my[dev],mz[dev], 
                    K1_map[dev], MSat_map[dev], K1_Mu0Msat_mul,
                    anisC1_mapx[dev], anisC1_mulx,
                    anisC1_mapy[dev], anisC1_muly,
                    anisC1_mapz[dev], anisC1_mulz,
                    anisC2_mapx[dev], anisC2_mulx,
                    anisC2_mapy[dev], anisC2_muly,
                    anisC2_mapz[dev], anisC2_mulz,
                    Npart);
  }
}

__export__ void cubic6AnisotropyAsync(float **hx, float **hy, float **hz, 
                          float **mx, float **my, float **mz,
                          float **K1_map, float **K2_map, float **MSat_map, float K1_Mu0Msat_mul, float K2_Mu0Msat_mul, 
                          float **anisC1_mapx, float anisC1_mulx,
                          float **anisC1_mapy, float anisC1_muly,
                          float **anisC1_mapz, float anisC1_mulz,
                          float **anisC2_mapx, float anisC2_mulx,
                          float **anisC2_mapy, float anisC2_muly,
                          float **anisC2_mapz, float anisC2_mulz,
                          CUstream* stream, int Npart){

  dim3 gridSize, blockSize;
  make1dconf(Npart, &gridSize, &blockSize);

  for (int dev=0; dev<nDevice(); dev++){
    assert(hx[dev] != NULL);
    assert(hy[dev] != NULL);
    assert(hz[dev] != NULL);
    assert(mx[dev] != NULL);
    assert(my[dev] != NULL);
    assert(mz[dev] != NULL);
    gpu_safe(cudaSetDevice(deviceId(dev)));

    cubic6AnisotropyKern<<<gridSize, blockSize, 0, cudaStream_t(stream[dev])>>> (
					hx[dev],hy[dev],hz[dev],  
                    mx[dev],my[dev],mz[dev], 
                    K1_map[dev], K2_map[dev], MSat_map[dev], K1_Mu0Msat_mul, K2_Mu0Msat_mul,
                    anisC1_mapx[dev], anisC1_mulx,
                    anisC1_mapy[dev], anisC1_muly,
                    anisC1_mapz[dev], anisC1_mulz,
                    anisC2_mapx[dev], anisC2_mulx,
                    anisC2_mapy[dev], anisC2_muly,
                    anisC2_mapz[dev], anisC2_mulz,
                    Npart);
  }
}

__export__ void cubic8AnisotropyAsync(float **hx, float **hy, float **hz, 
                          float **mx, float **my, float **mz,
                          float **K1_map, float **K2_map, float **K3_map, float **MSat_map, float K1_Mu0Msat_mul, float K2_Mu0Msat_mul, float K3_Mu0Msat_mul, 
                          float **anisC1_mapx, float anisC1_mulx,
                          float **anisC1_mapy, float anisC1_muly,
                          float **anisC1_mapz, float anisC1_mulz,
                          float **anisC2_mapx, float anisC2_mulx,
                          float **anisC2_mapy, float anisC2_muly,
                          float **anisC2_mapz, float anisC2_mulz,
                          CUstream* stream, int Npart){

  dim3 gridSize, blockSize;
  make1dconf(Npart, &gridSize, &blockSize);

  for (int dev=0; dev<nDevice(); dev++){
    assert(hx[dev] != NULL);
    assert(hy[dev] != NULL);
    assert(hz[dev] != NULL);
    assert(mx[dev] != NULL);
    assert(my[dev] != NULL);
    assert(mz[dev] != NULL);
    gpu_safe(cudaSetDevice(deviceId(dev)));

    cubic8AnisotropyKern<<<gridSize, blockSize, 0, cudaStream_t(stream[dev])>>> (
					hx[dev],hy[dev],hz[dev],  
                    mx[dev],my[dev],mz[dev], 
                    K1_map[dev], K2_map[dev], K3_map[dev], MSat_map[dev], K1_Mu0Msat_mul, K2_Mu0Msat_mul, K3_Mu0Msat_mul,
                    anisC1_mapx[dev], anisC1_mulx,
                    anisC1_mapy[dev], anisC1_muly,
                    anisC1_mapz[dev], anisC1_mulz,
                    anisC2_mapx[dev], anisC2_mulx,
                    anisC2_mapy[dev], anisC2_muly,
                    anisC2_mapz[dev], anisC2_mulz,
                    Npart);
  }
}

#ifdef __cplusplus
}
#endif