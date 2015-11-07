//
//  RenderEncoder.hpp
//  MetalCube
//
//  Created by William Lindmeier on 10/16/15.
//
//

#pragma once

#include "cinder/Cinder.h"
#include "MetalGeom.h"
#include "PipelineState.h"
#include "DataBuffer.h"
#include "TextureBuffer.h"
#include "DepthState.h"
#include "SamplerState.h"

namespace cinder { namespace mtl {
    
    typedef std::shared_ptr<class RenderEncoder> RenderEncoderRef;
    
    class RenderEncoder
    {

        friend class CommandBuffer;
        
    public:
        
        virtual ~RenderEncoder();
        
        void pushDebugGroup( const std::string & groupName);
        void popDebugGroup();

        void setPipelineState( PipelineStateRef pipeline );
        void setFragSamplerState( SamplerStateRef samplerState, int samplerIndex = 0 );
        void setDepthStencilState( DepthStateRef depthState );

        void setTextureAtIndex( TextureBufferRef texture, size_t index = 0 );
        void setBufferAtIndex( DataBufferRef buffer, size_t bufferIndex , size_t bytesOffset = 0 );

        void draw( ci::mtl::geom::Primitive primitive, size_t vertexStart, size_t vertexCount,
                   size_t instanceCount );
        
        void endEncoding();
        
        void * getNative(){ return mImpl; }
        
    protected:

        static RenderEncoderRef create( void * mtlRenderCommandEncoder ); // <MTLRenderCommandEncoder>
        
        RenderEncoder( void * mtlRenderCommandEncoder );
        
        void * mImpl = NULL; // <MTLRenderCommandEncoder>
    };
    
} }