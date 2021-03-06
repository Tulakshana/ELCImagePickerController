//
//  Asset.m
//
//  Created by Matt Tuzzolo on 2/15/11.
//  Copyright 2011 ELC Technologies. All rights reserved.
//

#import "ELCAsset.h"
#import "ELCAssetTablePicker.h"



@implementation ELCAsset

@synthesize asset = _asset;
@synthesize parent;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
    }
    return self;
}

-(id)initWithAsset:(ALAsset*)value {
	
	if (self = [super initWithFrame:CGRectMake(0, 0, 0, 0)]) {
		
		self.asset = value;
		
		CGRect viewFrames = CGRectMake(0, 0, 75, 75);
		
		UIImageView *assetImageView = [[UIImageView alloc] initWithFrame:viewFrames];
		[assetImageView setContentMode:UIViewContentModeScaleToFill];
		[assetImageView setImage:[UIImage imageWithCGImage:[_asset thumbnail]]];
		[self addSubview:assetImageView];
		[assetImageView release];
		
		overlayView = [[UIImageView alloc] initWithFrame:viewFrames];
		[overlayView setImage:[UIImage imageNamed:@"Overlay.png"]];
		[overlayView setHidden:YES];
		[self addSubview:overlayView];
    }
    
	return self;	
}

-(void)toggleSelection {
    
	overlayView.hidden = !overlayView.hidden;
//    
//    if([(ELCAssetTablePicker*)self.parent totalSelectedAssets] >= 10) {
//        
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Maximum Reached" message:@"" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
//		[alert show];
//		[alert release];	
//
//        [(ELCAssetTablePicker*)self.parent doneAction:nil];
//    }
    int totalAssets = [(ELCAssetTablePicker*)self.parent totalSelectedAssets];
    NSLog(@"totalSelectedAssets %d",totalAssets);
    if(totalAssets <= 15) {
        
//        overlayView.hidden = !overlayView.hidden;
        [(ELCAssetTablePicker*)self.parent setTitle:[NSString stringWithFormat:@"%d more",(15 - totalAssets)]];
        [[NSUserDefaults standardUserDefaults]setValue:[NSString stringWithFormat:@"%d",row] forKey:@"ELCrow"];
        [[NSUserDefaults standardUserDefaults]synchronize];

    }else {
        overlayView.hidden = TRUE;
    }
    
}

-(BOOL)selected {
	
	return !overlayView.hidden;
}

-(void)setSelected:(BOOL)_selected {
    
	[overlayView setHidden:!_selected];
}

- (void)dealloc 
{    
    [_asset release];
	[overlayView release];
    [super dealloc];
}

- (void)setRow:(int)value{
    row = value;
}

@end

