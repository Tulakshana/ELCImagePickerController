//
//  AssetCell.h
//
//  Created by Matt Tuzzolo on 2/15/11.
//  Copyright 2011 ELC Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ELCAssetCell : UITableViewCell
{
	NSArray *_rowAssets;
    int row;
}

-(id)initWithAssets:(NSArray*)_assets reuseIdentifier:(NSString*)_identifier;
-(void)setAssets:(NSArray*)_assets;
- (void)setRow:(int)value;

@property (nonatomic,retain) NSArray *rowAssets;

@end
