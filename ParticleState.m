//
//  ParticleState.m
//  PSim
//
//  Created by Aaron Odell on 12/29/12.
//

#import "ParticleState.h"

#define PI 3.14159


@implementation ParticleState


@synthesize mass;
@synthesize posX;
@synthesize	posY;
@synthesize velX;
@synthesize velY;
@synthesize accelX;
@synthesize accelY;
@synthesize forceX;
@synthesize forceY;


+(id)ParticleWithMass:(float)m PosX:(float)px PosY:(float)py VelX:(float)vx VelY:(float)vy {
	ParticleState* p = [[ParticleState alloc] init];
	[p setPosX:px];
	[p setPosY:py];
	[p setVelX:vx];
	[p setVelY:vy];
	[p setMass:m];
	return p;
}



+(id)ParticleRelativeToParticle:(ParticleState*)pbase withMass:(float)m dX:(float)dx dY:(float)dy dVX:(float)dvx dVY:(float)dvy {
	ParticleState* pnew = [[ParticleState alloc]initFromParticleState:pbase];
	
	[pnew setMass:m];
	[pnew addToPosX:dx];
	[pnew addToPosY:dy];
	[pnew addToVelX:dvx];
	[pnew addToVelY:dvy];
	
	return pnew;
}


+(id)ParticleRelativeToParticle:(ParticleState*)pbase withMass:(float)m posR:(float)posR posAngle:(float)posA  velMag:(float)velM velAngle:(float) velA {

	float dX, dY, dVX, dVY;
	
	if(posR < 0) {
		posR *= -1;
		posA += 180;
		
	}
	
	if(velM < 0) {
		velM *= -1;
		velA += 180;
	}

	assert(posR > 0);
	assert(velM >= 0); 
	
	dX = posR*cos(posA*PI/180);
	dY = posR*sin(posA*PI/180);
	dVX = velM*cos((velA+posA-90)*PI/180);
	dVY = velM*sin((velA+posA-90)*PI/180);
	
	return [ParticleState ParticleRelativeToParticle:pbase withMass:m dX:dX dY:dY dVX:dVX dVY:dVY];
}

+(id)ParticleFromCollisionOfParticle:(ParticleState*)p1 with:(ParticleState*) p2 { 
	ParticleState* pnew = [[ParticleState alloc] init];
	[pnew setMass:[p1 mass]+[p2 mass]];
	[pnew setVelX:([p1 velX]*[p1 mass]+[p2 velX]*[p2 mass]) /  ([p1 mass]+[p2 mass])]; // weighted average velocity merge
	[pnew setVelY:([p1 velY]*[p1 mass]+[p2 velY]*[p2 mass]) /  ([p1 mass]+[p2 mass])];

	 
	[pnew setPosX: ([p1 posX]*[p1 mass]+[p2 posX]*[p2 mass]) / ([p1 mass]+[p2 mass])]; //weighted average position merge
	[pnew setPosY: ([p1 posY]*[p1 mass]+[p2 posY]*[p2 mass]) / ([p1 mass]+[p2 mass])]; 
	
	return pnew;
}


-(id) init {
	if(self=[super init]) {
		posX = 0;
		posY = 0;
		velX = 0;
		velY = 0;
		mass = 0;
		forceX = 0;
		forceY = 0;
	}
	return self;
}

-(id)copyWithZone:(NSZone*)zone {
	return [[ParticleState alloc] initFromParticleState:self];
}

-(id)initFromParticleState:(ParticleState*)ps {
	if(self=[super init]) {
		posX = [ps posX];
		posY = [ps posY];
		velX = [ps velX];
		velY = [ps velY];
		accelX = [ps accelX];
		accelY = [ps accelY];
		forceX = [ps forceX];
		forceY = [ps forceY];
		mass = [ps mass];
	}
	return self;
}


-(void)setPosX:(float)x Y:(float)y { 
	posX = x;
	posY = y;
}

-(void)setVelX:(float)x Y:(float)y {
	velX = x;
	velY = y;
}

-(void)addToPosX:(float)dx {
	posX += dx;
}

-(void)addToPosY:(float)dy {
	posY += dy;
}

-(void)addToVelX:(float)dvx {
	velX += dvx;
}
-(void)addToVelY:(float)dvy {
	velY += dvy;
}

-(void)addToForceX:(float)dfx {
	forceX += dfx;
}

-(void)addToForceY:(float)dfy {
	forceY += dfy;
}


-(void)applyToroid:(float) toroidSize {
	if(toroidSize) {
		while(posX > toroidSize) {
			posX -= toroidSize;
		}
		while(posX < 0) {
			posX += toroidSize;
		}
	
		while(posY > toroidSize) {
			posY -= toroidSize;
		}
		while(posY < 0) {
			posY += toroidSize;
		}
	}
	
}

-(void)mergeWithParticle:(ParticleState*) p {
	
	float selfOriginalMass = [self mass];
	float pOriginalMass = [p mass];
	float newMass = selfOriginalMass+pOriginalMass;
	
	[self setMass:newMass];
	[self setVelX:( [self velX]*selfOriginalMass + [p velX]*pOriginalMass ) / newMass ]; // weighted average velocity merge
	[self setVelY:( [self velY]*selfOriginalMass + [p velY]*pOriginalMass ) / newMass ];
	
	
	[self setPosX:( [self posX]*selfOriginalMass + [p posX]*pOriginalMass) / newMass ]; //weighted average position merge
	[self setPosY:( [self posY]*selfOriginalMass + [p posY]*pOriginalMass) / newMass ]; //weighted average position merge
	
	[self setForceX:forceX+[p forceX]];
	[self setForceY:forceY+[p forceY]];
}
	
-(void)setFromParticleState:(ParticleState*)sourceState {
	mass = [sourceState mass];
	posX = [sourceState posX];
	posY = [sourceState posY];
	velX = [sourceState velX];
	velY = [sourceState velY];
	forceX = [sourceState forceX];
	forceY = [sourceState forceY];
}

-(NSString*)description {
	NSMutableString* description = [[NSMutableString alloc] init];
	
	[description appendString:[super description]];
	
	[description appendFormat:@"Mass: %f\n", mass];
	[description appendFormat:@"PosX: %f\n", posX];
	[description appendFormat:@"PosY: %f\n", posY];
	[description appendFormat:@"VelX: %f\n", velX];
	[description appendFormat:@"VelY: %f\n", velY];
	[description appendFormat:@"AccelX: %f\n", accelX];
	[description appendFormat:@"AccelY: %f\n", accelY];
	[description appendFormat:@"ForceX: %f\n", forceX];
	[description appendFormat:@"ForceY: %f\n", forceY];
	
	
	return description;

}



@end
