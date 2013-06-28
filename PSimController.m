//
//  PSimController.m
//  PSim
//
//  Created by Aaron Odell on 12/29/12.
//


#import "PSimController.h"


@implementation PSimController

@synthesize myModel;
@synthesize simIsPlaying;
@synthesize animationTimer;
@synthesize displayTime;
@synthesize playSpeed;

-(id)init {
	if(self=[super init]) {
		simIsPlaying = FALSE;
		displayTime = 0;

	}
	return self;
}

-(void)awakeFromNib { 
	[speedSliderLabel setIntValue:(int)pow(2,[speedSlider floatValue])];
	playSpeed = pow(2,[speedSlider floatValue]);

	[timeSliderLabel setFloatValue:[timeSlider floatValue]];
}

-(IBAction)RunSimButton:(id)sender {

	[self pauseAnimation];
	[myModel deleteSimLog];
	[self readParamatersRunSim];
	
}

-(IBAction)PlayPauseButton:(id)sender {
	if(![self simIsPlaying]) { 
		[self playAnimation];
	} else {
		[self pauseAnimation];
	} 
}

-(IBAction)StopButton:(id)sender {
	[self stopAnimation];
}


// When animation timer fires, do sanity checking then update display
-(void)timerFired:(NSTimer*)theTimer {
	if([self simIsPlaying]) {
		assert(playSpeed != 0);
		[self setDisplayTime:displayTime+(playSpeed*[animationTimer timeInterval])];
		if(displayTime >= [myModel maxTime]) {
			[self pauseAnimation];
		}
		[timeSlider setFloatValue:[self displayTime]];
		[self updateDisplay];
	} else {
		assert(0);
	}
}


-(void)playAnimation {
	if([myModel simHasRun]) {
		if([self displayTime] > [myModel maxTime]) {
			[self stopAnimation];
		}

		[self setSimIsPlaying:TRUE];
		[self setAnimationTimer:[NSTimer scheduledTimerWithTimeInterval:.01 target:self selector:@selector(timerFired:) userInfo:nil repeats:YES]];
		[playPauseButton setTitle:@"Pause"];
	}
}

-(void)pauseAnimation { 
	[self setSimIsPlaying:FALSE];
	[playPauseButton setTitle:@"Play"];
	[animationTimer invalidate];	
	animationTimer = nil;
	
}

-(void)stopAnimation {
	[self pauseAnimation];
	
	[self setDisplayTime:0];
	[timeSlider setFloatValue:0];
	[self updateDisplay];	
}

-(void)updateDisplay { 
	[psimView DisplaySimState:[myModel SimStateAtTime:displayTime]];
	[timeSliderLabel setFloatValue:displayTime];
}

-(IBAction)timeSliderAction:(id)sender {
	[self pauseAnimation];
	[self setDisplayTime:[timeSlider floatValue]];
	[self updateDisplay];
}

-(IBAction)speedSliderAction:(id)sender {
	playSpeed = pow(2,[sender floatValue]);
	[speedSliderLabel setFloatValue:playSpeed];
}

-(IBAction)AbortSimButtonAction:(id)sender { 
	[myModel setUserDidAbort:YES];
}

-(IBAction)ContinueButtonAction:(id)sender {
//  Removed for now, may re-add later
/*	if([simLength floatValue] > [[myModel prevSimParam] simLength]) {
		SimParamaters* simParam = [myModel prevSimParam];
		[simParam setSimLength:[simLength floatValue]];
		[progressBar setMaxValue:[simLength doubleValue]];
		[timeSlider setMaxValue:[simLength doubleValue]];
		[NSThread detachNewThreadSelector:@selector(SimThreadWithParamaters:) toTarget:myModel withObject:simParam];
	}
*/
}


// PsimModel calls this to update progress bar during simulation
-(void)modelRunIsAtTime:(float) simTime {
	[progressBar setDoubleValue:simTime];
	[progressLabel setIntValue:simTime];

	if([psimView simRect].size.width == 0) {
		[psimView setSimRect:[myModel sizeRect]];
	}
}


// read sim paramaters from GUI, calculate initial conditions, and launch
// simulation thread
-(int)readParamatersRunSim { 
	float mass, radius, angle, vel;
	SimState* initialSimState = [[SimState alloc]init];
	ParticleState *sunParticle;
	ParticleState *ps;
	PSMathHelper* math = [[PSMathHelper alloc] init];
	
	sunParticle = [ParticleState ParticleWithMass:1000 PosX:0 PosY:0 VelX:0 VelY:0];
	[initialSimState addParticleState:sunParticle];
	
	// Calculate mass, distance from "sun", angle, velocity based on gaussian distributed rand and offset. 
	for(int i=0; i<[numParticlesField intValue]; i++) {
		
		do {
			mass = [math gaussianRand] * [massStdDevField floatValue] + [massMeanField floatValue];
		} while(mass <= 1);
		
		do {
			radius = [math gaussianRand] * [radiusStdDevField floatValue] + [radiusMeanField floatValue];
		} while (radius <= 1);
		
		
		vel = [math gaussianRand] * [velStdDevField floatValue] + [velMeanField floatValue];
		vel += 2*pi*[orbitConstantField floatValue]/radius;
		
		angle = [math normalizedRand] * 360;
				
		ps = [ParticleState ParticleRelativeToParticle:sunParticle withMass:mass posR:radius posAngle:angle velMag:vel velAngle:0];
		[initialSimState addParticleState:ps];
	}
	
	// Create SimParamaters object from random conditions generated above,
	// read paramaters from GUI
	SimParamaters* simParam = [[SimParamaters alloc] init];
	[simParam setInitialSimState:initialSimState];
	[simParam setTimeStep:[timeStepField floatValue]];
	[simParam setSimLength:[simLengthField floatValue]];
	[simParam setInitialSimState:initialSimState];
	[simParam setGravitySofteningFactor:1];
	
	if([toroidCheckBox state] == NSOnState) {
		[simParam setToroidOn:YES];
		[simParam setToroidSize:[toroidSizeField floatValue]];
	} else {
		[simParam setToroidOn:NO];
		[simParam setToroidSize:0];
	}
	
	if([timeStepDynamicButton state] == NSOnState) {
		[simParam setDynamicTimeStepOn:YES];
	} else {
		[simParam setDynamicTimeStepOn:NO];
	}
	
	if([collisionCheckBox state] == NSOnState) {
		[simParam setCollisionsOn:YES];
	} else {
		[simParam setCollisionsOn:NO];
	}
	
	[progressBar setMaxValue:[simLengthField doubleValue]];
	[timeSlider setMaxValue:[simLengthField doubleValue]];
	

	myModel = [[PsimModel alloc] init];
	[myModel setController:self];
	

	[NSThread detachNewThreadSelector:@selector(SimThreadWithParamaters:) toTarget:myModel withObject:simParam];	
	
	return 0;
}



-(void)simComplete {
	
	[self stopAnimation];
	
	[timeSlider setMinValue:0];
	[timeSlider setMaxValue:[myModel maxTime]];
	[timeSlider setFloatValue:0];	
	
	[psimView setSimRect:[myModel sizeRect]];
	
	[self updateDisplay];
	
}



@end
