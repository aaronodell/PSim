//
//  PsimMainView.m
//  PSim
//
//  Created by Aaron Odell on 12/29/12.


#import "PsimMainView.h"


@implementation PsimMainView

@synthesize simRect;

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		displayState = nil;
    }
    return self;
}

- (void)drawRect:(NSRect)displayRect {
	
	int i;
	ParticleState* ps;
	float scale, translateX, translateY;
	NSPoint particleCenter;
	NSAffineTransform *simToDisplayTransform, *drawTransform;  
	NSBezierPath *drawPath; 	
	
	
	// Draw background
	[[NSColor whiteColor] set];
	NSRectFill(displayRect);
	
	
	if(displayState != nil) {
		
		
		/* Setup simToDisplayTransform 
		   Change sim coordinates to display coordinates */
		
		assert(simRect.size.width != 0);
		
		// Set display scale
		if([fixedScaleCheckBox state] == NSOnState) { 
			scale = [fixedScaleTextField floatValue];
		} else { 
			scale = MIN(displayRect.size.width/simRect.size.width,displayRect.size.height/simRect.size.height);
		}
		assert(scale != 0);
		assert(!isnan(scale));
		
		translateX = displayRect.size.width/2;
		translateY = displayRect.size.height/2;
		
		if([centerAtParticleZeroCheckBox state] == NSOnState) {
			ParticleState* particleZero = [displayState particleStateAtIndex:0];
			translateX -= [particleZero posX]*scale;
			translateY -= [particleZero posY]*scale;
		}
		
		simToDisplayTransform = [NSAffineTransform transform];		
		[simToDisplayTransform translateXBy:translateX yBy:translateY];
		[simToDisplayTransform scaleBy:scale];
		
		
		// Draw each particle
		
		for(i=0; i<[displayState countParticleStates]; i++) {
			
			ps = [displayState particleStateAtIndex:i];

			particleCenter = [simToDisplayTransform transformPoint:NSMakePoint([ps posX], [ps posY])];

			drawTransform = [NSAffineTransform transform];
			[drawTransform translateXBy:particleCenter.x yBy:particleCenter.y];
			[drawTransform scaleBy:sqrt([ps mass])+1];	 // Particle size, arbitrary		

			drawPath = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(-1, -1, 2, 2)];
			[drawPath transformUsingAffineTransform:drawTransform];			
			
			[[NSColor blueColor] set];
			[drawPath fill];
			
			
			// Draw velocity and acceleration vectors if enabled
			if([drawVelocityVectorCheckBox state] == NSOnState) {
			
				drawTransform = [NSAffineTransform transform];
				[drawTransform translateXBy:particleCenter.x yBy:particleCenter.y];
				[drawTransform rotateByRadians:atan2([ps velY], [ps velX])];
				[drawTransform scaleBy:4*sqrt(pow([ps velX], 2)+pow([ps velY],2))];
				
				drawPath = [NSBezierPath bezierPath];
				[drawPath moveToPoint:NSMakePoint(0,0)];
				[drawPath lineToPoint:NSMakePoint(1,0)];
				[drawPath transformUsingAffineTransform:drawTransform];
				
				[[NSColor redColor] set];
				[drawPath stroke];
				
			}
			
			
			if([drawAccelerationVectorCheckBox state] == NSOnState) {
			
				drawTransform = [NSAffineTransform transform];
				[drawTransform translateXBy:particleCenter.x yBy:particleCenter.y];
				[drawTransform rotateByRadians:atan2([ps accelY], [ps accelX])];
				[drawTransform scaleBy:100*sqrt(pow([ps accelX], 2)+pow([ps accelY],2))];
				
				drawPath = [NSBezierPath bezierPath];
				[drawPath moveToPoint:NSMakePoint(0,0)];
				[drawPath lineToPoint:NSMakePoint(1,0)];
				[drawPath transformUsingAffineTransform:drawTransform];

				[[NSColor greenColor] set];
				[drawPath stroke];
				
			}
			
			 
		}
	}
}


			

-(void)DisplaySimState:(SimState*)state {
	displayState = state;
	[self setNeedsDisplay:YES];
}


-(IBAction)displaySettingsChanged:(id)sender {
	[self setNeedsDisplay:YES];
}

							

@end
