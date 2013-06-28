//
//  PSMathHelper.m
//  PSim
//
//  Created by Aaron Odell on 1/22/13.
//

#import "PSMathHelper.h"


@implementation PSMathHelper

-(id)init {
	if(self=[super init]) {
		unsigned randSeed =  clock();
		srand(randSeed);
	}
	return self;
}

-(float)normalizedRand { 
	float result = ((rand()%10000)/10000.0);
	assert(result >= 0);
	assert(result < 1);
	
	return result;
}

-(BOOL)randBool {
	if( (rand()/10000) % 2 ) {
		return YES;
	} else {
		return NO;
	}
}

-(float)normalizedPosNegRand {
	float result = [self normalizedRand];
	
	if([self randBool]) {
		result *= -1;
	}
	
	assert(result > -1);
	assert(result < 1);
	
	return result;
}

-(float)gaussianRand {
	static double V1, V2, S;
	static int phase = 0;
	float X;
	
	if(phase == 0) {
		do {
			double U1 = (double)rand() / RAND_MAX;
			double U2 = (double)rand() / RAND_MAX;
			
			V1 = 2 * U1 - 1;
			V2 = 2 * U2 - 1;
			S = V1 * V1 + V2 * V2;
		} while(S >= 1 || S == 0);
		
		X = V1 * sqrt(-2 * log(S) / S);
	} else
		X = V2 * sqrt(-2 * log(S) / S);
	
	phase = 1 - phase;
	
	return X;	
}

@end
