//
//  AssetTablePicker.m
//
//  Created by Matt Tuzzolo on 2/15/11.
//  Copyright 2011 ELC Technologies. All rights reserved.
//

#import "ELCAssetTablePicker.h"
#import "ELCAssetCell.h"
#import "ELCAsset.h"
#import "ELCAlbumPickerController.h"


@implementation ELCAssetTablePicker

@synthesize parent;
@synthesize assetGroup, elcAssets = _elcAssets;

-(void)viewDidLoad {
        
	[self.tableView setSeparatorColor:[UIColor clearColor]];
	[self.tableView setAllowsSelection:NO];

    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    self.elcAssets = tempArray;
    [tempArray release];
	
	UIBarButtonItem *doneButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneAction:)] autorelease];
    
	[self.navigationItem setRightBarButtonItem:doneButtonItem];
	[self.navigationItem setTitle:@"Loading..."];

//	[self performSelectorInBackground:@selector(preparePhotos) withObject:nil];
//    
//    // Show partial while full list loads
//	[self.tableView performSelector:@selector(reloadData) withObject:nil afterDelay:.5];
    [self preparePhotos];
    
    activityView = nil;
    activityHolderView = nil;


    
}


-(void)preparePhotos {
    

    [self.navigationItem setTitle:@"Loading..."];
    void (^enumerateAsset)(ALAsset *, NSUInteger , BOOL *) = ^(ALAsset *result, NSUInteger index, BOOL *stop){
        if(result == nil) 
        {
            [self.navigationItem setTitle:@"Pick Photos"];
            
            [self.tableView reloadData];
            int row = [[[NSUserDefaults standardUserDefaults]valueForKey:@"ELCrow"]intValue];
            if (row < [self.tableView numberOfRowsInSection:0]) {
                            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:FALSE];
            }

            return;
        }
        
        ELCAsset *elcAsset = [[[ELCAsset alloc] initWithAsset:result] autorelease];
        [elcAsset setParent:self];
        [_elcAssets addObject:elcAsset];
        
    };
    [self.assetGroup enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:enumerateAsset];

}

- (void) doneAction:(id)sender {
    NSThread *progressThread = [[NSThread alloc]initWithTarget:self selector:@selector(showProgress) object:nil];
    [progressThread start];
    
	NSMutableArray *selectedAssetsImages = [[[NSMutableArray alloc] init] autorelease];
	    
	for(ELCAsset *elcAsset in _elcAssets)
    {		
		if([elcAsset selected]) {
			
			[selectedAssetsImages addObject:[elcAsset asset]];
		}
	}
        
    [(ELCAlbumPickerController*)self.parent selectedAssets:selectedAssetsImages];
    
    [progressThread release];
    [activityView stopAnimating];
    [activityHolderView removeFromSuperview];
    
}

- (void)showProgress{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    
    if (activityHolderView == nil) {
        activityHolderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 480)];
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(103, 190, 115, 101)];
        [imageView setImage:[UIImage imageNamed:@"loadingBack.png"]];
        [activityHolderView addSubview:imageView];
        [imageView release];
    }
    if (activityView == nil) {
        activityView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [activityView setFrame:CGRectMake(136, 203, 50, 50)];
    }
    [activityView startAnimating];
    [activityHolderView addSubview:activityView];
    [self.navigationController.navigationBar addSubview:activityHolderView];
    
    [pool drain];
}

#pragma mark UITableViewDataSource Delegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return ceil([self.assetGroup numberOfAssets] / 4.0);
}

- (NSArray*)assetsForIndexPath:(NSIndexPath*)_indexPath {
    
	int index = (_indexPath.row*4);
	int maxIndex = (_indexPath.row*4+3);
    
	// NSLog(@"Getting assets for %d to %d with array count %d", index, maxIndex, [assets count]);
    
	if(maxIndex < [_elcAssets count]) {
        
		return [NSArray arrayWithObjects:[_elcAssets objectAtIndex:index],
				[_elcAssets objectAtIndex:index+1],
				[_elcAssets objectAtIndex:index+2],
				[_elcAssets objectAtIndex:index+3],
				nil];
	}
    
	else if(maxIndex-1 < [_elcAssets count]) {
        
		return [NSArray arrayWithObjects:[_elcAssets objectAtIndex:index],
				[_elcAssets objectAtIndex:index+1],
				[_elcAssets objectAtIndex:index+2],
				nil];
	}
    
	else if(maxIndex-2 < [_elcAssets count]) {
        
		return [NSArray arrayWithObjects:[_elcAssets objectAtIndex:index],
				[_elcAssets objectAtIndex:index+1],
				nil];
	}
    
	else if(maxIndex-3 < [_elcAssets count]) {
        
		return [NSArray arrayWithObject:[_elcAssets objectAtIndex:index]];
	}
    
	return nil;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
        
    ELCAssetCell *cell = (ELCAssetCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) 
    {		        
        cell = [[[ELCAssetCell alloc] initWithAssets:[self assetsForIndexPath:indexPath] reuseIdentifier:CellIdentifier] autorelease];
    }	
	else 
    {		
		[cell setAssets:[self assetsForIndexPath:indexPath]];
	}
    
    [cell setRow:indexPath.row];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	return 79;
}

- (int)totalSelectedAssets {
    
    int count = 0;
    
    for(ELCAsset *asset in _elcAssets)
    {
		if([asset selected]) 
        {            
            count++;	
		}
	}
    
    return count;
}

- (void)dealloc 
{
    [_elcAssets release];
    [selectedAssetsLabel release];
    activityView = nil;
    activityHolderView = nil;
    [super dealloc];    
}

@end
