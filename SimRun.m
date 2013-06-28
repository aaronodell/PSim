//
//  SimRun.m
//  PSim
//
//  Created by Aaron Odell on 12/30/12.
//

#import "SimRun.h"
#import "SimState.h"

@implementation SimRun

@synthesize activeRect;
@synthesize logInterval;
@synthesize previousLogTime;



-(id)init { 
	if(self=[super init]) {
		ssArray = [[NSMutableArray alloc] initWithCapacity:10000];
		logInterval = 1;
		previousLogTime = 0;
	}
	return self;
}
	

-(SimState*)simStateAtIndex:(int)i {
	return [ssArray objectAtIndex:i];
}

-(int)countSimStates {
	return [ssArray count];
}



-(BOOL)loggingIsNeededAtTime:(float)simTime {
	assert(logInterval > 0);
	assert(previousLogTime >= 0);
	
	return (simTime > logInterval+previousLogTime || previousLogTime == 0);
}

-(void)logSimState:(SimState*) ss {
	assert(ss != nil);
	SimState* logItem = [[SimState alloc] initFromSimState:ss];
	[ssArray addObject:logItem];
	previousLogTime = [logItem simTime];
}
	
	

// Generate NSRect that will contain all particles during the sim run. 
// To be used by view to figure out how to scale the entire session. 
-(NSRect)sizeRect {
	int i,j;
	float maxX=-10e6;
	float minX=10e6;
	float maxY=-10e6;
	float minY=10e6;
	NSRect rect;
	
	SimState *s;
	ParticleState *p;
	
	for(i=0; i<[self countSimStates]; i++) {
		s = [self simStateAtIndex:i];
		for(j=0; j<[s countParticleStates]; j++) {
			p = [s particleStateAtIndex:j];
			
			if([p posX] > maxX) {
				maxX = [p posX];
			}
			if([p posX] < minX) {
				minX = [p posX];
			}
			if([p posY] > maxY) {
				maxY = [p posY];
			}
			if([p posY] < minY) {
				minY = [p posY];
			}
		}
	}
	
	rect.origin.x = minX;
	rect.origin.y = minY;
	rect.size.width = maxX - minX;
	rect.size.height = maxY - minY;
	
	return rect;
}


	
	
@end
