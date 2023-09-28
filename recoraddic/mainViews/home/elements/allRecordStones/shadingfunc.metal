//
//  shadingfunc.metal
//  recoraddiction
//
//  Created by 김지호 on 2023/07/12.
//


#include <simd/simd.h>
#include <metal_stdlib>
using namespace metal;


typedef enum VertexInputIndex
{
    VertexInputIndexVertices     = 0,
    VertexInputIndexViewportSize = 1,
    VertexInputIndexTranslation = 2,
} VertexInputIndex;


struct VerIn {
    float4 coordinate [[attribute(0)]];
    float4 color [[attribute(1)]];
};

struct VerOutRastInOut {
    float4 coordinate [[position]];
    float4 color;
};


vertex VerOutRastInOut vertexShader(uint vertexID [[vertex_id]],
                              constant VerIn *vertices [[buffer(VertexInputIndexVertices)]], // buffer(0)
                              constant vector_uint2 *viewportSizePointer [[buffer(VertexInputIndexViewportSize)]] // buffer(1)
                                    ) {
    
    VerOutRastInOut out;
    
    float4 pixelSpacePosition = vertices[vertexID].coordinate;

    
    vector_float2 viewportSize = vector_float2(*viewportSizePointer);

    out.coordinate = vector_float4(0.0, 0.0, 0.0, 1.0);
    
    out.coordinate.xy = pixelSpacePosition.xy / (viewportSize.xy / 4.0);

    out.coordinate.z = pixelSpacePosition.z;
    
    out.color = vertices[vertexID].color;
    
    return out;
}



fragment float4 fragmentShader(VerOutRastInOut in [[stage_in]]) {
    return in.color;
//    return float4(1, 0, 0, 1); // red color
}
