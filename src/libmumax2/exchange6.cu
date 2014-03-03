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
                              float* __restrict__  lexMsk,
                              const float lex2Mul,
                              const float msat0T0Mul,
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

        float lex02 = getMaskUnity(lexMsk, I) * getMaskUnity(lexMsk, I);
        float lex2, pre1, pre2;

        float3 m0 = make_float3(mx[I], my[I], mz[I]);
        float ms0 = len(m0);
        float3 s0 = normalizef(m0);

        float Hx, Hy, Hz;
        float ms2, ms1;
        float3 s1, s2;
        float3 m1, m2;

        int linAddr;

        // neighbors in X direction
        int idx = i - 1;
        idx = (idx < 0 && wrap0) ? N0 + idx : idx;
        idx = max(idx, 0);
        linAddr = idx * N1 * N2 + j * N2 + k;
    
        m1 = make_float3(mx[linAddr], my[linAddr], mz[linAddr]);
        ms1 = len(m1);
        s1 = normalizef(m1);

        lex2 = getMaskUnity(lexMsk, linAddr) * getMaskUnity(lexMsk, linAddr);
        pre1 = avgGeomZero(lex02 * ms0, lex2 * ms1);

        idx = i + 1;
        idx = (idx == N0 && wrap0) ? idx - N0 : idx;
        idx = min(idx, N0 - 1);
        linAddr = idx * N1 * N2 + j * N2 + k;

        m2 = make_float3(mx[linAddr], my[linAddr], mz[linAddr]);
        ms2 = len(m2);
        s2 = normalizef(m2);

        lex2 = getMaskUnity(lexMsk, linAddr) * getMaskUnity(lexMsk, linAddr);
        pre2 = avgGeomZero(lex02 * ms0, lex2 * ms2);

        Hx = lex2Mul * msat0T0Mul * cellx_2 * (pre1 * (s1.x - s0.x) + pre2 * (s2.x - s0.x));
        Hy = lex2Mul * msat0T0Mul * cellx_2 * (pre1 * (s1.y - s0.y) + pre2 * (s2.y - s0.y));
        Hz = lex2Mul * msat0T0Mul * cellx_2 * (pre1 * (s1.z - s0.z) + pre2 * (s2.z - s0.z));

        // neighbors in Z direction
        idx = k - 1;
        idx = (idx < 0 && wrap2) ? N2 + idx : idx;
        idx = max(idx, 0);
        linAddr = i * N1 * N2 + j * N2 + idx;
    
        m1 = make_float3(mx[linAddr], my[linAddr], mz[linAddr]);
        ms1 = len(m1);
        s1 = normalizef(m1);

        lex2 = getMaskUnity(lexMsk, linAddr) * getMaskUnity(lexMsk, linAddr);
        pre1 = avgGeomZero(lex02 * ms0, lex2 * ms1);

        idx = k + 1;
        idx = (idx == N2 && wrap2) ? idx - N2 : idx;
        idx = min(idx, N2 - 1);
        linAddr = i * N1 * N2 + j * N2 + idx;

        m2 = make_float3(mx[linAddr], my[linAddr], mz[linAddr]);
        ms2 = len(m2);
        s2 = normalizef(m2);

        lex2 = getMaskUnity(lexMsk, linAddr) * getMaskUnity(lexMsk, linAddr);
        pre2 = avgGeomZero(lex02 * ms0, lex2 * ms2);

        Hx += lex2Mul * msat0T0Mul * cellz_2 * (pre1 * (s1.x - s0.x) + pre2 * (s2.x - s0.x));
        Hy += lex2Mul * msat0T0Mul * cellz_2 * (pre1 * (s1.y - s0.y) + pre2 * (s2.y - s0.y));
        Hz += lex2Mul * msat0T0Mul * cellz_2 * (pre1 * (s1.z - s0.z) + pre2 * (s2.z - s0.z));

        // neighbors in Y direction
        idx = j - 1;
        idx = (idx < 0 && wrap1) ? N1 + idx : idx;
        idx = max(idx, 0);
        linAddr = i * N1 * N2 + idx * N2 + k;

        m1 = make_float3(mx[linAddr], my[linAddr], mz[linAddr]);
        ms1 = len(m1);
        s1 = normalizef(m1);

        lex2 = getMaskUnity(lexMsk, linAddr) * getMaskUnity(lexMsk, linAddr);
        pre1 = avgGeomZero(lex02 * ms0, lex2 * ms1);

        idx = j + 1;
        idx = (idx == N1 && wrap1) ? idx - N1 : idx;
        idx = min(idx, N1 - 1);
        linAddr = i * N1 * N2 + idx * N2 + k;

        m2 = make_float3(mx[linAddr], my[linAddr], mz[linAddr]);
        ms2 = len(m2);
        s2 = normalizef(m2);

        lex2 = getMaskUnity(lexMsk, linAddr) * getMaskUnity(lexMsk, linAddr);
        pre2 = avgGeomZero(lex02 * ms0, lex2 * ms2);
        
        Hx += lex2Mul * msat0T0Mul * celly_2 * (pre1 * (s1.x - s0.x) + pre2 * (s2.x - s0.x));
        Hy += lex2Mul * msat0T0Mul * celly_2 * (pre1 * (s1.y - s0.y) + pre2 * (s2.y - s0.y));
        Hz += lex2Mul * msat0T0Mul * celly_2 * (pre1 * (s1.z - s0.z) + pre2 * (s2.z - s0.z));

        // Write back to global memory
        hx[I] = Hx;
        hy[I] = Hy;
        hz[I] = Hz;

    }

}


__export__ void exchange6Async(float** hx, float** hy, float** hz, 
                              float** mx, float** my, float** mz, 
                              float** lex, 
                              float lex2Mul, 
                              float msat0T0Mul,
                              int N0, int N1Part, int N2, 
                              int periodic0, int periodic1, int periodic2, 
                              float cellSizeX, float cellSizeY, float cellSizeZ, 
                              CUstream* streams)
{
    dim3 gridsize, blocksize;

    make3dconf(N0, N1Part, N2, &gridsize, &blocksize);

    float cellx_2 = (float)(1.0 / ((double)cellSizeX * (double)cellSizeX));
    float celly_2 = (float)(1.0 / ((double)cellSizeY * (double)cellSizeY));
    float cellz_2 = (float)(1.0 / ((double)cellSizeZ * (double)cellSizeZ));

    int dev = 0;

    gpu_safe(cudaSetDevice(deviceId(dev)));
    exchange6Kern <<< gridsize, blocksize, 0, cudaStream_t(streams[dev])>>>(hx[dev], hy[dev], hz[dev],
                                                                            mx[dev], my[dev], mz[dev], 
                                                                            lex[dev], 
                                                                            lex2Mul,
                                                                            msat0T0Mul, 
                                                                            N0, N1Part, N2, 
                                                                            periodic0, periodic1, periodic2, 
                                                                            cellx_2, celly_2, cellz_2);
}


#ifdef __cplusplus
}
#endif

