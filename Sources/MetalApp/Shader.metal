#include <metal_stdlib>
#include <simd/simd.h>

using namespace metal;

struct Vertex
{
    float4 position [[position]];
    float4 color;
};

struct RasterizerData {
    // The [[position]] attribute of this member indicates that this value
    // is the clip space position of the vertex when this structure is
    // returned from the vertex function.
    float4 position [[position]];
    float4 color;
};

// MARK: - Vertex
vertex RasterizerData basic_vertex(unsigned int vid [[ vertex_id ]],
                                   constant Vertex *vertices [[ buffer(0) ]]) {
    
    float4 pos = vertices[vid].position;
    
    RasterizerData out;
    out.position = pos;
    out.color = vertices[vid].color;
    return out;
}

// MARK: - Fragment
fragment float4 basic_fragment(RasterizerData in [[stage_in]]) {
    
    return float4(in.color);
}
