//
//  SimState.m
//  PSim
//
//  Created by Aaron Odell on 12/29/12.
//

#import "SimState.h"


@implementation SimState

@synthesize simTime;

-(id) init {
	if(self=[super init]) {
		simTime = 0;
		psArray = [[NSMutableArray alloc] initWithCapacity:100];
	}
	return self;
}

-(id)initFromSimState:(SimState*) ss {
	
	if(self=[super init]) { 
		simTime = [ss simTime];
		psArray = [[NSMutableArray alloc] initWithArray:[ss psArray] copyItems:YES];
	}
	return self;
}

-(void)setSimStateFrom:(SimState*)sourceState {
	assert(psArray != nil);
	assert(sourceState != nil);
	assert([sourceState psArray] != nil);
	for(int i=0; i<[psArray count]; i++) {
		if(i < [[sourceState psArray] count]) {
			[[psArray objectAtIndex:i] setFromParticleState:[[sourceState psArray] objectAtIndex:i]];
		} else {
			[psArray removeObjectAtIndex:i];
		}
	}
}
	


-(NSMutableArray*)psArray{
	return psArray;
 }


-(id)particleStateAtIndex:(int) i {
	return [psArray objectAtIndex:i];
}

-(int)countParticleStates {
	return [psArray count];
}

-(void)addParticleState:(ParticleState*) ps {
	return [psArray addObject:ps];
}


-(void)applyToroid:(float) toroidSize {
	NSUInteger i;
	for(i=0; i<[psArray count]; i++) {
		[[psArray objectAtIndex:i] applyToroid:toroidSize];
	}
}






@end
