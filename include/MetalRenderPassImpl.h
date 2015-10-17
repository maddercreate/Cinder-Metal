//
//  MetalRenderPassImpl.h
//  MetalCube
//
//  Created by William Lindmeier on 10/17/15.
//
//

#import <Foundation/Foundation.h>
#import <Metal/Metal.h>
#import <simd/simd.h>

@interface MetalRenderPassImpl : NSObject
{
}

- (void)prepareForRenderToTexture:(id <MTLTexture>)texture;

@property (nonatomic, strong) MTLRenderPassDescriptor *renderPassDescriptor;
@property (nonatomic, strong) id <MTLTexture> depthTex;
@property (nonatomic, strong) id <MTLTexture> msaaTex;

@end


