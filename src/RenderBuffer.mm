//
//  RenderBuffer.cpp
//  ParticleSorting
//
//  Created by William Lindmeier on 11/15/15.
//
//

#include "RenderBuffer.h"
#include "RendererMetalImpl.h"
#include "ImageHelpers.h"

using namespace std;
using namespace ci;
using namespace ci::mtl;

#define IMPL ((__bridge id <MTLCommandBuffer>)mImpl)
#define DRAWABLE ((__bridge id <CAMetalDrawable>)mDrawable)

RenderBufferRef RenderBuffer::create( const std::string & bufferName )
{
    RendererMetalImpl *renderer = [RendererMetalImpl sharedRenderer];
    // instantiate a command buffer
    id <MTLCommandBuffer> commandBuffer = [renderer.commandQueue commandBuffer];
    commandBuffer.label = [NSString stringWithUTF8String:bufferName.c_str()];
    id <CAMetalDrawable> drawable = [renderer.metalLayer nextDrawable];
    return RenderBufferRef( new RenderBuffer( (__bridge void *)commandBuffer,
                                              (__bridge void *)drawable ) );
}

RenderBuffer::RenderBuffer( void * mtlCommandBuffer, void * mtlDrawable )
:
CommandBuffer(mtlCommandBuffer)
,mDrawable(mtlDrawable)
{
    assert( mImpl != NULL );
    assert( mtlDrawable != NULL );
    assert( [(__bridge id)mtlDrawable conformsToProtocol:@protocol(CAMetalDrawable)] );
}

RenderEncoderRef RenderBuffer::createRenderEncoder( const RenderPassDescriptorRef & descriptor,
                                                    const std::string & encoderName )
{
    return CommandBuffer::createRenderEncoder(descriptor, (__bridge void *)DRAWABLE.texture);
}

void RenderBuffer::commitAndPresent( std::function< void( void * mtlCommandBuffer) > completionHandler )
{
    RendererMetalImpl *renderer = [RendererMetalImpl sharedRenderer];
    renderer.currentDrawable = DRAWABLE;

    // clean up the command buffer
    __block dispatch_semaphore_t block_sema = [renderer inflightSemaphore];
    if ( block_sema != nil )
    {
        [IMPL addCompletedHandler:^(id<MTLCommandBuffer> buffer)
         {
             if ( completionHandler != NULL )
             {
                 completionHandler( (__bridge void *) buffer );
             }
             dispatch_semaphore_signal(block_sema);
         }];
    }
    [IMPL presentDrawable:DRAWABLE];
    // Finalize rendering here & push the command buffer to the GPU
    [IMPL commit];
}