//
//  FavoritesViewController.m
//  FavoritePhotos
//
//  Created by Andrew Liu on 11/9/14.
//  Copyright (c) 2014 Andrew Liu. All rights reserved.
//

#import "CustomCollectionViewCell.h"
#import "FavoritesViewController.h"
#define kUserDefaults @"kUserDefaults"

@interface FavoritesViewController () <UICollectionViewDataSource, UICollectionViewDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation FavoritesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
//    [self load];
    [self.collectionView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//    [self load];
    [self.collectionView reloadData];
}

//MARK: UICollectionViewDataSource required protocol
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.favoritesArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CustomCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.imageView.image = self.favoritesArray[indexPath.item];
    return cell;
}

//MARK: Persistence
//- (void)save
//{
//    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//    NSURL *plistURL = [[self documentsDirectory]URLByAppendingPathComponent:@"favoritesPhoto.plist"];
//    [self.favoritesArray writeToURL:plistURL atomically:YES];
//    [userDefaults setObject:[NSDate date] forKey:kUserDefaults];
//    [userDefaults synchronize];
//}
//
//- (void)load
//{
//    NSURL *plistURL = [[self documentsDirectory]URLByAppendingPathComponent:@"favoritesPhoto.plist"];
//    self.favoritesArray = [NSMutableArray arrayWithContentsOfURL:plistURL];
//    if (self.favoritesArray == nil)
//    {
//        self.favoritesArray = [NSMutableArray array];
//    }
//}
//
//
//- (NSURL *)documentsDirectory
//{
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    NSURL *url = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].firstObject;
//    return url;
//}

@end
