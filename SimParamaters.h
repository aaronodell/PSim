//
//  SimParamaters.h
//  PSim
//
//  Created by Aaron Odell on 12/31/12.
//

#import <Cocoa/Cocoa.h>
#import "SimState.h"

@interface SimParamaters : NSObject {
}

@property (retain) SimState* initialSimState;

@property float simLength;
@property float gravitySofteningFactor;

@property BOOL toroidOn;
@property float toroidSize;

@property float timeStep;
@property BOOL dynamicTimeStepOn;

@property BOOL collisionsOn;


@end
