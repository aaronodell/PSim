//
//  ParticleState.h
//  PSim
//
//  Created by Aaron Odell on 12/29/12.
//

#import <Cocoa/Cocoa.h>


@interface ParticleState : NSObject {

}


+(id)ParticleWithMass:(float)m PosX:(float)px PosY:(float)py VelX:(float)vx VelY:(float)vy;
+(id)ParticleRelativeToParticle:(ParticleState*)pbase withMass:(float)m dX:(float)dx dY:(float)dy dVX:(float)dvx dVY:(float)dVY;
+(id)ParticleRelativeToParticle:(ParticleState*)pbase withMass:(float)m posR:(float)posR posAngle:(float)posA  velMag:(float)velM velAngle:(float) velA;
//+(id)ParticleFromCollisionOfParticle:(ParticleState*)p1 with:(ParticleState*) p2;

-(void)mergeWithParticle:(ParticleState*) p;

-(id)initFromParticleState:(ParticleState*)ps;

-(void)setFromParticleState:(ParticleState*)sourceState;

-(void)addToPosX:(float)dx;
-(void)addToPosY:(float)dy;
-(void)addToVelX:(float)dvx;
-(void)addToVelY:(float)dvy;
-(void)addToForceX:(float)dfx;
-(void)addToForceY:(float)dfy;


-(void)applyToroid:(float) toroidSize;




@property float mass;
@property float posX;
@property float posY;
@property float velX;
@property float velY;
@property float accelX;
@property float accelY;
@property float forceX;
@property float forceY;


@end
