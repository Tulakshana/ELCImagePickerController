//
//  Asset.h
//
//  Created by Matt Tuzzolo on 2/15/11.
//  Copyright 2011 ELC Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>


@interface ELCAsset : UIView {
	ALAsset *_asset;
	UIImageView *overlayView;
	BOOL selected;
	id parent;
    int row;
}

@property (nonatomic, retain) ALAsset *asset;
@property (nonatomic, assign) id parent;

-(id)initWithAsset:(ALAsset*)value;
-(BOOL)selected;
- (void)setRow:(int)value;

@end