//
//  FavoritesViewController.m
//  FavoritePhotos
//
//  Created by Andrew Liu on 11/9/14.
//  Copyright (c) 2014 Andrew Liu. All rights reserved.
//

#import "CustomCollectionViewCell.h"
#import "FavoritesViewController.h"
#import "Favorites.h"
@import Social;
@import Foundation;
@import Twitter;
@import MessageUI;
#define kUserPhotos @"kUserPhotos"

@interface FavoritesViewController () <UICollectionViewDataSource, UICollectionViewDelegate, MFMailComposeViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property NSMutableArray *favoritesArray;

@end

@implementation FavoritesViewController

//MARK: Project life cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self load];
    [self.collectionView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self load];
    [self.collectionView reloadData];
}

//MARK: Delete && Tweet && Email
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Confirmation"
                                                                   message:@"Are you sure you would like to delete this item?"
                                                            preferredStyle:UIAlertControllerStyleActionSheet];

    UIAlertAction *delete = [UIAlertAction actionWithTitle:@"Delete"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction *action){
                                                       [self.favoritesArray removeObject:self.favoritesArray[indexPath.item]];
                                                       [self save];
                                                       [self.collectionView reloadData];
                                                   }];
    [alert addAction:delete];

    UIAlertAction *tweetFriends = [UIAlertAction actionWithTitle:@"Tweet"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction *action){
                                                           SLComposeViewController *tweetSheet = [SLComposeViewController
                                                                                               composeViewControllerForServiceType:SLServiceTypeTwitter];
                                                           NSData *imageData = self.favoritesArray[indexPath.item];
                                                           UIImage *image = [UIImage imageWithData:imageData];
                                                           [tweetSheet addImage:image];
                                                           [tweetSheet setInitialText:@"Enjoy!"];
                                                           [self presentViewController:tweetSheet animated:YES completion:nil];
                                                  }];
    [alert addAction:tweetFriends];

    UIAlertAction *emailFriends = [UIAlertAction actionWithTitle:@"Email"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction *action){
                                                       MFMailComposeViewController *emailSheet = [[MFMailComposeViewController alloc] init];
                                                       emailSheet.mailComposeDelegate = self;
                                                       [emailSheet setToRecipients:[NSArray arrayWithObject:@"mobilemakers@gmail.com"]];
                                                       [emailSheet setSubject:@"A Message from Mobile Makers"];
                                                       [emailSheet setMessageBody:@"Enjoy" isHTML:NO];
                                                       [emailSheet setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
                                                       NSData *imageData = self.favoritesArray[indexPath.item];
                                                       UIImage *image = [UIImage imageWithData:imageData];
                                                       NSData *myData = UIImageJPEGRepresentation(image, 1.0);
                                                       [emailSheet addAttachmentData:myData mimeType:@"image/jpeg" fileName:@"mobilemakers.jpg"];
                                                       [self presentViewController:emailSheet animated:YES completion:nil];
                                                  }];
    [alert addAction:emailFriends];

    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                     style:UIAlertActionStyleCancel
                                                   handler:nil];
    [alert addAction:cancel];

    [self presentViewController:alert animated:YES completion:nil];
}

//MARK: UICollectionViewDataSource required protocol
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.favoritesArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CustomCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    NSData *imageData = self.favoritesArray[indexPath.item];
    UIImage *image = [UIImage imageWithData:imageData];
    cell.imageView.image = image;
    return cell;
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
