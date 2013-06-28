//
//  SimRun.h
//  PSim
//
//  Created by Aaron Odell on 12/30/12.
//

#import <Cocoa/Cocoa.h>
#import "SimState.h"


@interface SimRun : NSObject {
	NSMutableArray* ssArray;
}

@property NSRect activeRect;
@property float logInterval;
@property float previousLogTime;

//-(NSMutableArray*)ssArray;

-(SimState*)simStateAtIndex:(int)i;
-(int)countSimStates;
//-(void)addSimState:(SimState*) ss;
-(NSRect)sizeRect;

-(BOOL)loggingIsNeededAtTime:(float)simTime;
-(void)logSimState:(SimState*) ss;



@end
