//
//  PsimModel.h
//  PSim
//
//  Created by Aaron Odell on 12/29/12.

#import <Cocoa/Cocoa.h>
#import "SimRun.h"
#import "SimState.h"
#import "ParticleState.h"
#import "SimParamaters.h"

@class PSimController;

@interface PsimModel : NSObject {

	SimRun* simLog;
}

@property (retain) PSimController* controller;
@property float previousTimeReturnedIndex;
@property BOOL userDidAbort;
@property (retain) SimParamaters* prevSimParam;

-(void)RunSimFromParamaters:(SimParamaters*)simParam;
-(SimState*)SimStateAtTime:(float)t;
-(float)maxTime;
-(BOOL)simHasRun;
-(NSRect)sizeRect;
-(void)deleteSimLog;
-(void)SimThreadWithParamaters:(SimParamaters*)simParam;


@end
