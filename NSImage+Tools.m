//
//  NSImage+ColorTools.m
//  Brainpeek
//
//  Created by Eugene Braginets on 8/2/16.
//  Copyright © 2016 Eugene Braginets. All rights reserved.
//

#import "NSImage+Tools.h"
#import <CoreImage/CoreImage.h>

const float THRESHOLD = 0.1; //PLAY WITH THRESHOLD VALUE

@implementation NSImage (ColorTools)


-(NSImage*) replaceColor:(NSColor*)inputColor withColor:(NSColor*)resultColor  {
    return [self replaceColor:inputColor withColor:resultColor withThreshold:THRESHOLD];
}

-(NSImage*) replaceColor:(NSColor*)inputColor withColor:(NSColor*)resultColor withThreshold:(float)threshold {
    
    NSColor *inColor = [inputColor colorUsingColorSpace:[NSColorSpace sRGBColorSpace]];
    NSColor *outColor = [resultColor colorUsingColorSpace:[NSColorSpace sRGBColorSpace]];
    
    CIImage *inputImage = [[CIImage alloc] initWithData:[self TIFFRepresentation]];
    
    const unsigned int size = 64; //PLAY WITH CUBE SIZE and THRESOL VALUE
    
    size_t cubeDataSize = size * size * size * sizeof ( float ) * 4;
    float *cubeData = (float *) malloc ( cubeDataSize );
    float rgb[3];
    
    size_t offset = 0;
    for (int z = 0; z < size; z++)
    {
        rgb[2] = ((double) z) / size; // blue value
        for (int y = 0; y < size; y++)
        {
            rgb[1] = ((double) y) / size; // green value
            for (int x = 0; x < size; x++)
            {
                rgb[0] = ((double) x) / size; // red value
                
                if ([self testColor:rgb withColor:inColor threshold:threshold]) {
                    cubeData[offset]   = outColor.redComponent;
                    cubeData[offset+1] = outColor.greenComponent;
                    cubeData[offset+2] = outColor.blueComponent;
                    cubeData[offset+3] = 1.0;
//                    NSLog (@"replaced: %f %f %f BY %f %f %f", rgb[0], rgb[1], rgb[2], outColor.redComponent, outColor.greenComponent, outColor.blueComponent);
                } else {
                    cubeData[offset]   = rgb[0];
                    cubeData[offset+1] = rgb[1];
                    cubeData[offset+2] = rgb[2];
                    cubeData[offset+3] = 1.0;
                }
                
                offset += 4;
            }
        }
    }
    
    NSData *data = [NSData dataWithBytesNoCopy:cubeData length:cubeDataSize freeWhenDone:YES];
    CIFilter *colorCube = [CIFilter filterWithName:@"CIColorCube"];
    [colorCube setValue:[NSNumber numberWithInt:size] forKey:@"inputCubeDimension"];
    [colorCube setValue:data forKey:@"inputCubeData"];
    [colorCube setValue:inputImage forKey:kCIInputImageKey];
    CIImage *outputImage = [colorCube outputImage];
    
    NSImage *resultImage = [[NSImage alloc] initWithSize:[outputImage extent].size];
    NSCIImageRep *rep = [NSCIImageRep imageRepWithCIImage:outputImage];
    [resultImage addRepresentation:rep];
    
    return resultImage;
}



- (BOOL) testColor:(float[3])color1 withColor:(NSColor *)color2 threshold:(float)threshold {
    return ((fabs(color1[0] - color2.redComponent) < threshold) && (fabs(color1[1] - color2.greenComponent) < threshold) && (fabs(color1[2] - color2.blueComponent) < threshold));
}


@end
