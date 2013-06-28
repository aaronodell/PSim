//
//  PSimController.h
//  PSim
//
//  Created by Aaron Odell on 12/29/12.
//

#import <Cocoa/Cocoa.h>
#import "PsimMainView.h"
#import "PSimModel.h"
#import "SimState.h"
#import "SimParamaters.h"
#import "ParticleState.h"
#import "PSMathHelper.h"



@interface PSimController : NSObject {
	IBOutlet PsimMainView* psimView;
	IBOutlet NSSlider* timeSlider;
	IBOutlet NSTextField* timeSliderLabel;
	
	IBOutlet NSTextField* timeStepField;
	IBOutlet NSButton* timeStepDynamicButton;
	
	IBOutlet NSTextField* simLengthField;
	
	IBOutlet NSButton* playPauseButton;

	IBOutlet NSSlider* speedSlider;
	IBOutlet NSTextField* speedSliderLabel;
	
	IBOutlet NSButton* collisionCheckBox;

	IBOutlet NSTextField* gravitySofteningField;
	IBOutlet NSButton* toroidCheckBox;
	IBOutlet NSTextField* toroidSizeField;
	
	IBOutlet NSProgressIndicator* progressBar;
	IBOutlet NSTextField* progressLabel;

	
	IBOutlet NSTextField* numParticlesField;	
	IBOutlet NSTextField* massMeanField;
	IBOutlet NSTextField* massStdDevField;
	IBOutlet NSTextField* radiusMeanField;
	IBOutlet NSTextField* radiusStdDevField;
	IBOutlet NSTextField* velMeanField;
	IBOutlet NSTextField* velStdDevField;
	IBOutlet NSTextField* orbitConstantField;
	
}

//@property bool simHasRun;

@property BOOL simIsPlaying;
@property (retain) NSTimer* animationTimer;
@property float displayTime;
@property float playSpeed;
@property (retain) PsimModel* myModel;

-(IBAction)RunSimButton:(id)sender;
-(IBAction)AbortSimButtonAction:(id)sender;
-(IBAction)PlayPauseButton:(id)sender;
-(IBAction)ContinueButtonAction:(id)sender;
-(IBAction)StopButton:(id)sender;
-(IBAction)timeSliderAction:(id)sender;
-(IBAction)speedSliderAction:(id)sender;



-(void)timerFired:(NSTimer*)theTimer;

-(void)updateDisplay;

-(void)awakeFromNib;

-(void)playAnimation;
-(void)pauseAnimation;
-(void)stopAnimation;

-(void)modelRunIsAtTime:(float) simTime;

-(int)readParamatersRunSim;


-(void)simComplete;


@end
