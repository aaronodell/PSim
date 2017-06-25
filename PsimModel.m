//
//  PsimModel.m
//  PSim
//
//  Created by Aaron Odell on 12/29/12.
//

#import "PsimModel.h"
#import "PSimController.h"

@implementation PsimModel

@synthesize previousTimeReturnedIndex;
@synthesize userDidAbort;
@synthesize prevSimParam;
@synthesize controller;

-(id)init {
	if(self=[super init]) {
		userDidAbort = NO;
	}
	return self;
}

-(BOOL)simHasRun {
	if(simLog != nil) {
		return YES;
	} else {
		return NO;
	}
}

-(void)SimThreadWithParamaters:(SimParamaters*)simParam {
	
	NSLog(@"In thread...\n");
	
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc]init];
	
	
	[self RunSimFromParamaters:simParam];

	[pool release];
	
}


// Main simulation function. Takes paramaters in simParam, plus a few hardcoded constants
// TODO: Move hardcoded constants to paramaters, settings object, or #define
	
-(void)RunSimFromParamaters:(SimParamaters*)simParam {
	
	
	// Declare variables
	int i, j;
	float force_x, force_y;
	float delta_x, delta_y, distance, magnitude;
	float currentTime, endTime = [simParam simLength];
	float relativeVelocitySquared;
	float relativeVelocitySquaredPerDistance, maxRelativeVelocitySquaredPerDistance, relativeMovementPerTimestep;
	float timeStep = [simParam timeStep];
	float targetMovementPerTimeStep = 0.01;
	float iParCollisionDistance,jParCollisionDistance;
	BOOL collisionOccured;
	float maxTimestep = 30;
	float minTimestep = 0.00001;
	int mergeParticle1Index, mergeParticle2Index;
	const float grav_const = 30;
	NSDate* executionStartTime = [[NSDate alloc] init];
	SimState *currentSimState, *nextSimState;
	ParticleState *iPar,*iParNext,*jPar,*jParNext;
	
	
	// Setup logging of sim state
	if(simLog == nil) {
		simLog = [[SimRun alloc] init];
		currentSimState = [[SimState alloc] initFromSimState:[simParam initialSimState]];
	} else {
		// Shouldn't be here
		assert(0); 
		currentSimState = [[SimState alloc] initFromSimState:[simLog simStateAtIndex:[simLog countSimStates]-1]];
	}
	nextSimState = [[SimState alloc] initFromSimState:currentSimState];	
	currentTime = [currentSimState simTime];
	userDidAbort = NO;
	
	[simLog setLogInterval:1];
	


	// Main processing loop, runs once for each timestep
	while(currentTime < endTime && !userDidAbort) {
				
		collisionOccured = NO;
		mergeParticle1Index = -1;
		mergeParticle2Index = -1;
		maxRelativeVelocitySquaredPerDistance = 0;
		[currentSimState setSimTime:currentTime];

		
		
		// Set net force on all particles to zero
		for(i=0;i<[currentSimState countParticleStates]; i++) {
			iPar = [currentSimState particleStateAtIndex:i];
			[iPar setForceX:0];
			[iPar setForceY:0];
		}
		
		
		// Outer particle interaction calculation loop. 
		// Combined with inner loop, this process results in runtime complexity
		// of O(N^2), where N = number of particles. 
		for(i=0; i<[currentSimState countParticleStates]; i++) { 
			
			iPar = [currentSimState particleStateAtIndex:i];
			iParNext = [nextSimState particleStateAtIndex:i];
			
			iParCollisionDistance = 4*sqrt([iPar mass]);
			
			
			// Inner particle interaction calculation loop
			for(j=0; j<i; j++) {   
				
				jPar = [currentSimState particleStateAtIndex:j];
				jParNext = [nextSimState particleStateAtIndex:j];
				jParCollisionDistance = 4*sqrt([jPar mass]);

				// Calculate total distance between particles using pathagorean theorem
				delta_x = [jPar posX] - [iPar posX];
				delta_y = [jPar posY] - [iPar posY];				
				distance = sqrt(delta_x*delta_x + delta_y*delta_y);
				
				// Calculate force of each particle on the other using Newton's Law of Universal Gravitation (adding softening factor if non-zero)
				magnitude = grav_const*[iPar mass]*[jPar mass]/(distance*distance + [simParam gravitySofteningFactor]);				

				// Decompose into x and y vector
				force_x = magnitude*(delta_x/distance); // mag * cos(theta)
				force_y = magnitude*(delta_y/distance); // mag * sin(theta)
				

				/*
					Dynamic timestep calculations (optional)
				
					Will detect how much relative motion exists between particles. If particles are moving quickly
					relative to one another, and close together, sim will decrease time step to better model close 
					interaction. If particles are moving slowly relative to one another, and are far apart, sim can 
					safely increase timestep
			    */
				
				if([simParam dynamicTimeStepOn]) {
					// Find the square of the velocity of one particle relative to the other
					// Using square of velocity avoids having to do expensive square root calculation
					// TODO: Characterize performance with velocity^2 vs velocity
					relativeVelocitySquared = pow([iPar velX]-[jPar velX], 2) + pow([iPar velY]-[jPar velY],2);
					// Divide by distance to find "importance" of motion
					relativeVelocitySquaredPerDistance = relativeVelocitySquared/distance;
					
					// Update max for this sim iteration if needed (final timestep adjustment will be at end of this timestep)
					if(relativeVelocitySquaredPerDistance > maxRelativeVelocitySquaredPerDistance) {
						maxRelativeVelocitySquaredPerDistance = relativeVelocitySquaredPerDistance;
					}
				}
				
				
				// Check for collisions (based on proximity of particles) 
				if([simParam collisionsOn]) {
					if(distance < iParCollisionDistance || distance < jParCollisionDistance){
						//assert(!collisionOccured); // if this is failing, add support for multiple collisions per timestep
						mergeParticle1Index = MIN(i,j);
						mergeParticle2Index = MAX(i,j);
						collisionOccured = YES;
						force_x = 0;
						force_y = 0;
					}
				}
				
				
				// Add equal and opposite force to each particles total		
				[iPar addToForceX:force_x];
				[iPar addToForceY:force_y];
				[jPar addToForceX:-force_x];
				[jPar addToForceY:-force_y];
				
				
			} // end for j
		}// end for i
		
		// Merge particles if collided
		if(collisionOccured) {
			assert(mergeParticle1Index < mergeParticle2Index);			
			iPar = [currentSimState particleStateAtIndex:mergeParticle1Index];
			jPar = [currentSimState particleStateAtIndex:mergeParticle2Index];
			[iPar mergeWithParticle:jPar];
			[[nextSimState psArray] removeObjectAtIndex:mergeParticle2Index];
			NSLog(@"Merged particles %d and %d at time %f\n", mergeParticle1Index, mergeParticle2Index, currentTime);
		}
		
		// Calculate acceleration (based on total force / mass) of each 
		// particle and update velocity
		for(i=0; i<[nextSimState countParticleStates]; i++) {
			iPar = [currentSimState particleStateAtIndex:i];
			iParNext = [nextSimState particleStateAtIndex:i];
		
			// 	
			[iPar setAccelX:[iPar forceX]/[iPar mass]];
			[iPar setAccelY:[iPar forceY]/[iPar mass]];
			
			[iParNext addToVelX:[iPar accelX]*timeStep];
			[iParNext addToVelY:[iPar accelY]*timeStep];
		}
			
		
		// Update positions based on velocities		
		for(i=0; i<[nextSimState countParticleStates]; i++) {
			iParNext = [nextSimState particleStateAtIndex:i];			
			[iParNext addToPosX:[iParNext velX]*timeStep];
			[iParNext addToPosY:[iParNext velY]*timeStep];
		}
		
		
		// Optionally apply "torroid" modeling. Makes right side of sim region feed
		// into left, and vis versa; same for top feeding bottom and vis versa. 
		// Can be useful for modeling smaller region of large system,
		// ie region of ideal gas
		if([simParam toroidOn]) {
			[nextSimState applyToroid:[simParam toroidSize]];
		}
		
		
		
		if(	[simLog loggingIsNeededAtTime:currentTime] ) {
			[simLog logSimState:currentSimState];
			[controller modelRunIsAtTime:currentTime];
		}
		
		// Update timestep based on optional dynamic timestep calculations (described above). 
		if( [simParam dynamicTimeStepOn] ) {
			relativeMovementPerTimestep = sqrt(maxRelativeVelocitySquaredPerDistance) * timeStep;

			BOOL didDecrease = NO;
			BOOL didIncrease = NO;
			
			while(relativeMovementPerTimestep > 2*targetMovementPerTimeStep ) { 
				timeStep /= 2;
				relativeMovementPerTimestep /= 2;
				
				if(didDecrease) {
					NSLog(@"%f: MULTIPLE TIMESTEP DECREASE\n", currentTime);
				}
				didDecrease = YES;
				
				NSLog(@"%f: decrease timestep to %f\n", currentTime, timeStep);
				
				if(timeStep < minTimestep) {
					timeStep = minTimestep;
					NSLog(@"%f:    decrease timestep limited to %f\n", currentTime, timeStep);
				} 

			}
			
			while( relativeMovementPerTimestep <= .5*targetMovementPerTimeStep ) {
				assert(!didDecrease);
				timeStep *= 2;
				relativeMovementPerTimestep *=2;
		
				if(didIncrease) {
					NSLog(@"%f: MULTIPLE TIMESTEP INCREASE\n", currentTime);
				}
				didIncrease = YES;
	
				NSLog(@"%f: increased timestep to %f\n", currentTime, timeStep);
			
				
				if(timeStep > maxTimestep) {
					timeStep = maxTimestep;
					NSLog(@"%f:    increase timestep limited to %f\n", currentTime, timeStep);
				}
				
			}
		}
		
		// Increment timestep
		currentTime += timeStep;
		
		// Update current state
		[currentSimState setSimStateFrom:nextSimState];
			
	} // end main while loop

	if(!userDidAbort) {
		NSLog(@"Sim Complete\n");
		NSLog(@"Runtime: %f s, %d particles\n", -1*[executionStartTime timeIntervalSinceNow], [[simLog simStateAtIndex:[simLog countSimStates]-1] countParticleStates]);
	} else {
		NSLog(@"Sim Aborted\n");
	}
	
	
	prevSimParam = simParam;
		
	[controller simComplete];
	
}


// SimStateAtTime: returns state of simulator at time closest to t
// If the time being requested is greater than the time previously returned,
// function will begin searching from that last returned point. This is efficient
// in practice since the vast majority of requests for a sim state will be requesting
// a state not far after the one previously requested. If this request is for an earlier
// time than previously requested, begins search at t=0

// TODO: Implement binary search, compare performance with this implementation

-(SimState*)SimStateAtTime:(float)t { 
	
	int searchIndex = previousTimeReturnedIndex;
	
	assert(t>=0);
	
	
	if(searchIndex > [simLog countSimStates]) {
		searchIndex = 0;
	}
	
	assert(searchIndex>=0);	
	if([[simLog simStateAtIndex:searchIndex] simTime] > t) {
		searchIndex = 0;
	}

	//assert(searchIndexTime <= t);
		
	while([[simLog simStateAtIndex:searchIndex] simTime] < t) {
		if( searchIndex+1 < [simLog countSimStates]) {
			searchIndex++;
		} else {
			break;
		}
	}
			

	previousTimeReturnedIndex = searchIndex;	   
	
	return [simLog simStateAtIndex:searchIndex];
	
	
}
 
 

-(float)maxTime {
	return [[simLog simStateAtIndex:([simLog countSimStates]-1)] simTime];
}


-(NSRect)sizeRect { 
	if(simLog) {
		return [simLog sizeRect];
	}
	else {
		return NSMakeRect(0, 0, 0, 0);
	}
}

-(void)deleteSimLog {
	simLog = nil;
}





@end
