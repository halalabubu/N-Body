#pragma once
#include "cuda_runtime.h"
#include "device_launch_parameters.h"

struct Particle
{
	float3 position;
	float3 velocity;
	
	float mass = 0;
};

__global__ void updateVertexBuffer(Particle* parts, float3* vertsPtr, int PCOUNT);
__global__ void testKernal(float3* vertsPtr);
__global__ void naiveNBody(Particle* parts, float3* vertsPtr, int PCOUNT, float delta);