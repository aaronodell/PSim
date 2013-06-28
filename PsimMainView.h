//
//  PsimMainView.h
//  PSim
//
//  Created by Aaron Odell on 12/29/12.
//

#import <Cocoa/Cocoa.h>
#import "SimState.h"

@interface PsimMainView : NSView {
	SimState* displayState;
	
	IBOutlet NSTextField* fixedScaleTextField;
	IBOutlet NSButton* fixedScaleCheckBox;
	IBOutlet NSButton* centerAtParticleZeroCheckBox;
	IBOutlet NSButton* drawVelocityVectorCheckBox;
	IBOutlet NSButton* drawAccelerationVectorCheckBox;
	
	
}

@property NSRect simRect;

-(void)DisplaySimState:(SimState*)state;

-(IBAction)displaySettingsChanged:(id)sender;



@end
