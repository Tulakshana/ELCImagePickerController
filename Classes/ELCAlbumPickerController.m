//
//  AlbumPickerController.m
//
//  Created by Matt Tuzzolo on 2/15/11.
//  Copyright 2011 ELC Technologies. All rights reserved.
//

#import "ELCAlbumPickerController.h"
#import "ELCImagePickerController.h"
#import "ELCAssetTablePicker.h"



@implementation ELCAlbumPickerController

@synthesize parent, assetGroups;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    albumLoaded = FALSE;
	
	[self.navigationItem setTitle:@"Loading..."];
    

    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self.parent action:@selector(cancelImagePicker)];
	[self.navigationItem setRightBarButtonItem:cancelButton];
	[cancelButton release];

    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
	self.assetGroups = tempArray;
    [tempArray release];
    
    library = [[ALAssetsLibrary alloc] init];      

    // Load Albums into assetGroups
    dispatch_async(dispatch_get_main_queue(), ^
    {
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        
        
        
        // Group enumerator Block
        void (^assetGroupEnumerator)(ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop) 
        {
            if (group == nil) 
            {

                // Reload albums

                return;
            }
            NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:2];
            [dic setObject:group forKey:@"group"];
            NSString *name = [[group valueForProperty:ALAssetsGroupPropertyName] lowercaseString];
            if ([name isEqualToString:@"saved photos"]) {
                name = @"-3";
            }else if ([name isEqualToString:@"camera roll"]){
                name = @"-2";
            }else if ([name isEqualToString:@"photo library"]){
                name = @"-1";
            }else {
                name = [NSString stringWithFormat:@"0%@",name];
            }
            [dic setObject:name forKey:@"name"];
            [self.assetGroups addObject:dic];
            [dic release];

            NSLog(@"reload albums");
            [self performSelectorOnMainThread:@selector(reloadTableView) withObject:nil waitUntilDone:YES];
        };



        
        // Group Enumerator Failure Block
        void (^assetGroupEnumeratorFailure)(NSError *) = ^(NSError *error) {
            
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Information" message:[NSString stringWithFormat:@"Please enable location services from device settings."] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            [alert release];
            
            NSLog(@"A problem occured %@", [error description]);	 
            NSLog(@"localizedDescription %@", [error localizedDescription]);
            NSLog(@"localizedRecoverySuggestion %@", [error localizedRecoverySuggestion]);
            
        };	
        

        
        [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
                               usingBlock:assetGroupEnumerator 
                             failureBlock:assetGroupEnumeratorFailure];

                
        //        // Enumerate Albums
        [library enumerateGroupsWithTypes:ALAssetsGroupAlbum
                               usingBlock:assetGroupEnumerator 
                             failureBlock:assetGroupEnumeratorFailure];
        
     

        
        [pool release];
    });  
    

//   
}

-(void)reloadTableView {
	NSLog(@"reloadTableView");
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name"
                                                  ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    [sortDescriptor release];
    self.assetGroups = [NSMutableArray arrayWithArray:[self.assetGroups sortedArrayUsingDescriptors:sortDescriptors]];
    
	[self.tableView reloadData];
	[self.navigationItem setTitle:@"Select an Album"];

    [self loadLastViewdAlbum];
}

- (void)loadLastViewdAlbum{
    if (!albumLoaded) {
        NSString *lastViewedAlbum = [[NSUserDefaults standardUserDefaults] valueForKey:@"album"];
        if ([lastViewedAlbum length] > 0) {
            int row = [lastViewedAlbum intValue];
            if (row < [self.assetGroups count]) {
                ELCAssetTablePicker *picker = [[ELCAssetTablePicker alloc] initWithNibName:@"ELCAssetTablePicker" bundle:[NSBundle mainBundle]];
                picker.parent = self;
                // Move me    
                NSMutableDictionary *dic = [self.assetGroups objectAtIndex:row];
                picker.assetGroup = [dic valueForKey:@"group"];
                [picker.assetGroup setAssetsFilter:[ALAssetsFilter allPhotos]];
                [self.navigationController pushViewController:picker animated:NO];
                albumLoaded = TRUE;
                [picker release];
            }
        }
    }

}

-(void)selectedAssets:(NSArray*)_assets {
	
	[(ELCImagePickerController*)parent selectedAssets:_assets];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [assetGroups count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Get count
    NSMutableDictionary *dic = [assetGroups objectAtIndex:indexPath.row];
    ALAssetsGroup *g = (ALAssetsGroup*)[dic valueForKey:@"group"];
    [g setAssetsFilter:[ALAssetsFilter allPhotos]];
    
//    DLog(@"%@",[g valueForProperty:ALAssetsGroupPropertyPersistentID]);
    NSInteger gCount = [g numberOfAssets];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ (%d)",[g valueForProperty:ALAssetsGroupPropertyName], gCount];
    [cell.imageView setImage:[UIImage imageWithCGImage:[g posterImage]]];
	[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
	
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	ELCAssetTablePicker *picker = [[ELCAssetTablePicker alloc] initWithNibName:@"ELCAssetTablePicker" bundle:[NSBundle mainBundle]];
	picker.parent = self;

    // Move me   
    NSMutableDictionary *dic = [assetGroups objectAtIndex:indexPath.row];
    picker.assetGroup = [dic valueForKey:@"group"];
    [picker.assetGroup setAssetsFilter:[ALAssetsFilter allPhotos]];
    
    
    [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%d",indexPath.row] forKey:@"album"];
    
	[self.navigationController pushViewController:picker animated:YES];
	[picker release];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	return 57;
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc 
{	
    [assetGroups release];
    [library release];
    [super dealloc];
}

@end

