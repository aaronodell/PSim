//
//  SimState.h
//  PSim
//
//  Created by Aaron Odell on 12/29/12.
//

#import <Cocoa/Cocoa.h>
#import "ParticleState.h"

@interface SimState : NSObject {
	NSMutableArray* psArray;
}


@property float simTime;

-(id)initFromSimState:(SimState*) ss;
-(ParticleState*)particleStateAtIndex:(int) i;
-(int)countParticleStates;
-(void)addParticleState:(ParticleState*) ps;

-(void)setSimStateFrom:(SimState*)sourceState;

-(NSMutableArray*)psArray;

-(void)applyToroid:(float) toroidSize;



@end
