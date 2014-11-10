//
//  ViewController.m
//  FavoritePhotos
//
//  Created by Andrew Liu on 11/8/14.
//  Copyright (c) 2014 Andrew Liu. All rights reserved.
//

#import "CustomCollectionViewCell.h"
#import "SearchViewController.h"
#import "FavoritesViewController.h"
#define kUserDefaults @"kUserDefaults"

@interface SearchViewController () <UITextFieldDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UITabBarControllerDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UITextField *textfield;
@property NSMutableArray *currentArray;
@property NSMutableArray *favoritesArray;
@property NSArray *dataArray;

@end

@implementation SearchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.currentArray = [NSMutableArray array];
    self.favoritesArray = [NSMutableArray array];
    self.dataArray = [NSArray array];
    self.tabBarController.delegate = self;
    [self.collectionView reloadData];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.collectionView reloadData];
}
//MARK: UICollectionViewDataSource required protocol
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.currentArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CustomCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.imageView.image = self.currentArray[indexPath.item];

    if ([self.favoritesArray containsObject:self.currentArray[indexPath.item]])
    {
        cell.imageView.layer.borderColor = [[UIColor redColor] CGColor];
        cell.imageView.layer.borderWidth = 4.0;
    }
    else
    {
        cell.imageView.layer.borderColor = nil;
        cell.imageView.layer.borderWidth = 0.0;
    }
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.favoritesArray containsObject:self.currentArray[indexPath.item]])
    {
        [self.favoritesArray removeObject:self.currentArray[indexPath.item]];
//        [self save];
    }
    else
    {
        [self.favoritesArray addObject:self.currentArray[indexPath.item]];
//        [self save];
    }
    [self.collectionView reloadData];

}

//MARK: Switch view controller
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    FavoritesViewController *fvc = [self.tabBarController.viewControllers objectAtIndex:0];
    fvc.favoritesArray = self.favoritesArray;
}

//MARK: Loading image from API
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.currentArray removeAllObjects];
    NSString *searchString = [NSString stringWithFormat:@"https://api.instagram.com/v1/tags/%@/media/recent?access_token=252242883.1fb234f.1e6836762f8a4c4e9f86b5a53e892d9f&count=10",self.textfield.text];
    [self loadJson:searchString];
    self.textfield.text = @"";
    [self.textfield resignFirstResponder];
    [self.collectionView reloadData];
    return YES;
}

- (void)Error:(NSError *)error
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                   message:error.localizedDescription
                                                            preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK"
                                                     style:UIAlertActionStyleDefault
                                                   handler:nil];
    [alert addAction:action];

    [self presentViewController:alert animated:YES completion:nil];
}

- (void)loadJson:(NSString *)json
{
    NSURL *url = [NSURL URLWithString:json];
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
     {
         if (connectionError)
         {
             [self Error:connectionError];
         }
         else
         {
             NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
             NSArray *jsonArray = jsonDictionary[@"data"];
             self.dataArray = jsonArray;
             for (NSDictionary *dataDict in self.dataArray)
             {
                 NSDictionary *imagesDict = dataDict[@"images"];
                 NSDictionary *resolutionDict = imagesDict[@"low_resolution"];
                 NSURL *imageURL = [NSURL URLWithString:resolutionDict[@"url"]];
                 NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
                 UIImage *image = [UIImage imageWithData:imageData];
                 [self.currentArray addObject:image];
                 [self.collectionView reloadData];
             }
         }
     }];
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
//- (NSURL *)documentsDirectory
//{
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    NSURL *url = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].firstObject;
//    return url;
//}

@end
