//
//  MapViewController.m
//  FavoritePhotos
//
//  Created by Andrew Liu on 11/10/14.
//  Copyright (c) 2014 Andrew Liu. All rights reserved.
//

#import "MapViewController.h"
#import "Favorites.h"
#define kUserPhotos @"kUserPhotos"
@interface MapViewController ()
@property NSMutableArray *favoritesArray;

@end

@implementation MapViewController

//MARK: Project life cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self load];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self load];
}

//MARK: Persistence
- (void)save
{
    NSURL *plistURL = [[self documentsDirectory]URLByAppendingPathComponent:@"favoritesPhoto.plist"];
    [self.favoritesArray writeToURL:plistURL atomically:YES];
}

- (void)load
{
    NSURL *plistURL = [[self documentsDirectory]URLByAppendingPathComponent:@"favoritesPhoto.plist"];
    self.favoritesArray = [NSMutableArray arrayWithContentsOfURL:plistURL];
    if (self.favoritesArray == nil)
    {
        self.favoritesArray = [NSMutableArray array];
    }
}

- (NSURL *)documentsDirectory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *url = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].firstObject;
    return url;
}

@end
