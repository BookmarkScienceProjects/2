#include "exchange6.h"

#include "multigpu.h"
#include <cuda.h>
#include "gpu_conf.h"
#include "gpu_safe.h"
#include "common_func.h"
#ifdef __cplusplus
extern "C" {
#endif
// full 3D blocks
__global__ void exchange6Kern(float* __restrict__ hx, float* __restrict__  hy, float* __restrict__  hz,
                              float* __restrict__  mx, float* __restrict__  my, float* __restrict__  mz,
                              float* __restrict__  mSat_map, float* __restrict__  Aex_map,
                              const float pre,
                              const int N0, const int N1, const int N2,
                              const int wrap0, const int wrap1, const int wrap2,
                              const float cellx_2, const float celly_2, const float cellz_2)
{

    int i = blockIdx.x * blockDim.x + threadIdx.x;
    int j = blockIdx.y * blockDim.y + threadIdx.y;
    int k = blockIdx.z * blockDim.z + threadIdx.z;

    if (i < N0 && j < N1 && k < N2)
    {

        int I = i * N1 * N2 + j * N2 + k;

        float mSat0 = getMaskUnity(mSat_map, I);
        float Aex0 = getMaskUnity(Aex_map, I);
        float lex0Mul = fdivZero(Aex0, mSat0);
        float lexMul, lex1Mul, lex2Mul;

        float mx0 = mx[I]; // mag component of central cell
        float mx1, mx2;

        float my0 = my[I]; // mag component of central cell
        float my1, my2;

        float mz0 = mz[I]; // mag component of central cell
        float mz1, mz2;

        float Hx, Hy, Hz;

        int linAddr;

        // neighbors in X direction
        int idx = i - 1;
        idx = (idx < 0 && wrap0) ? N0 + idx : idx;
        idx = max(idx, 0);
        linAddr = idx * N1 * N2 + j * N2 + k;

        lexMul = fdivZero(getMaskUnity(Aex_map, linAddr), getMaskUnity(mSat_map, linAddr));
        lex1Mul = avgGeomZero(lex0Mul, lexMul);

        mx1 = mx[linAddr];
        my1 = my[linAddr];
        mz1 = mz[linAddr];

        idx = i + 1;
        idx = (idx == N0 && wrap0) ? idx - N0 : idx;
        idx = min(idx, N0 - 1);
        linAddr = idx * N1 * N2 + j * N2 + k;

        lexMul = fdivZero(getMaskUnity(Aex_map, linAddr), getMaskUnity(mSat_map, linAddr));
        lex2Mul = avgGeomZero(lex0Mul, lexMul);

        mx2 = mx[linAddr];
        my2 = my[linAddr];
        mz2 = mz[linAddr];

        Hx = pre * cellx_2 * (lex1Mul * (mx1 - mx0) + lex2Mul * (mx2 -  mx0));
        Hy = pre * cellx_2 * (lex1Mul * (my1 - my0) + lex2Mul * (my2 -  my0));
        Hz = pre * cellx_2 * (lex1Mul * (mz1 - mz0) + lex2Mul * (mz2 -  mz0));

        // neighbors in Z direction
        idx = k - 1;
        idx = (idx < 0 && wrap2) ? N2 + idx : idx;
        idx = max(idx, 0);
        linAddr = i * N1 * N2 + j * N2 + idx;

        lexMul = fdivZero(getMaskUnity(Aex_map, linAddr), getMaskUnity(mSat_map, linAddr));
        lex1Mul = avgGeomZero(lex0Mul, lexMul);

        mx1 = mx[linAddr];
        my1 = my[linAddr];
        mz1 = mz[linAddr];

        idx = k + 1;
        idx = (idx == N2 && wrap2) ? idx - N2 : idx;
        idx = min(idx, N2 - 1);
        linAddr = i * N1 * N2 + j * N2 + idx;

        lexMul = fdivZero(getMaskUnity(Aex_map, linAddr), getMaskUnity(mSat_map, linAddr));
        lex2Mul = avgGeomZero(lex0Mul, lexMul);

        mx2 = mx[linAddr];
        my2 = my[linAddr];
        mz2 = mz[linAddr];

        Hx += pre * cellz_2 * (lex1Mul * (mx1 - mx0) + lex2Mul * (mx2 -  mx0));
        Hy += pre * cellz_2 * (lex1Mul * (my1 - my0) + lex2Mul * (my2 -  my0));
        Hz += pre * cellz_2 * (lex1Mul * (mz1 - mz0) + lex2Mul * (mz2 -  mz0));

        // neighbors in Y direction
        idx = j - 1;
        idx = (idx < 0 && wrap1) ? N1 + idx : idx;
        idx = max(idx, 0);
        linAddr = i * N1 * N2 + idx * N2 + k;

        lexMul = fdivZero(getMaskUnity(Aex_map, linAddr), getMaskUnity(mSat_map, linAddr));
        lex1Mul = avgGeomZero(lex0Mul, lexMul);

        mx1 = mx[linAddr];
        my1 = my[linAddr];
        mz1 = mz[linAddr];

        idx = j + 1;
        idx = (idx == N1 && wrap1) ? idx - N1 : idx;
        idx = min(idx, N1 - 1);
        linAddr = i * N1 * N2 + idx * N2 + k;

        lexMul = fdivZero(getMaskUnity(Aex_map, linAddr), getMaskUnity(mSat_map, linAddr));
        lex2Mul = avgGeomZero(lex0Mul, lexMul);

        mx2 = mx[linAddr];
        my2 = my[linAddr];
        mz2 = mz[linAddr];

        Hx += pre * celly_2 * (lex1Mul * (mx1 - mx0) + lex2Mul * (mx2 -  mx0));
        Hy += pre * celly_2 * (lex1Mul * (my1 - my0) + lex2Mul * (my2 -  my0));
        Hz += pre * celly_2 * (lex1Mul * (mz1 - mz0) + lex2Mul * (mz2 -  mz0));

        // Write back to global memory
        hx[I] = Hx;
        hy[I] = Hy;
        hz[I] = Hz;

    }

}


__export__ void exchange6Async(float** hx, float** hy, float** hz, float** mx, float** my, float** mz, float** msat, float** aex, float Aex2_mu0MsatMul, int N0, int N1Part, int N2, int periodic0, int periodic1, int periodic2, float cellSizeX, float cellSizeY, float cellSizeZ, CUstream* streams)
{

    dim3 gridsize, blocksize;

    make3dconf(N0, N1Part, N2, &gridsize, &blocksize);

    float cellx_2 = (float)(1.0 / ((double)cellSizeX * (double)cellSizeX));
    float celly_2 = (float)(1.0 / ((double)cellSizeY * (double)cellSizeY));
    float cellz_2 = (float)(1.0 / ((double)cellSizeZ * (double)cellSizeZ));

    int nDev = nDevice();

    for (int dev = 0; dev < nDev; dev++)
    {
        gpu_safe(cudaSetDevice(deviceId(dev)));
        exchange6Kern <<< gridsize, blocksize, 0, cudaStream_t(streams[dev])>>>(hx[dev], hy[dev], hz[dev], mx[dev], my[dev], mz[dev], msat[dev], aex[dev], Aex2_mu0MsatMul, N0, N1Part, N2, periodic0, periodic1, periodic2, cellx_2, celly_2, cellz_2);
    }
}


#ifdef __cplusplus
}
#endif

