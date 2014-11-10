//
//  ViewController.m
//  FavoritePhotos
//
//  Created by Andrew Liu on 11/8/14.
//  Copyright (c) 2014 Andrew Liu. All rights reserved.
//

#import "CustomCollectionViewCell.h"
#import "SearchViewController.h"
#import "Favorites.h"
#define kUserPhotos @"kUserPhotos"
#define kSearchTags @"https://api.instagram.com/v1/tags/%@/media/recent?access_token=252242883.1fb234f.1e6836762f8a4c4e9f86b5a53e892d9f&count=10"
#define kSearchUsers @"https://api.instagram.com/v1/users/search?access_token=252242883.1fb234f.1e6836762f8a4c4e9f86b5a53e892d9f&q=%@&count=10"

@interface SearchViewController () <UITextFieldDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UITabBarControllerDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UITextField *textfield;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property NSMutableArray *searchArray;
@property NSMutableArray *favoritesArray;
@property NSString *searchJson;

@end

@implementation SearchViewController

//MARK: Project life cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.searchArray = [NSMutableArray array];
    self.searchJson = [NSString string];
    self.tabBarController.delegate = self;
    [self load];
    [self.collectionView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self load];
    [self.collectionView reloadData];
}

//MARK: UICollectionViewDataSource required protocol
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.searchArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CustomCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    NSData *imageData = self.searchArray[indexPath.item];
    UIImage *image = [UIImage imageWithData:imageData];
    cell.imageView.image = image;
    
    if ([self.favoritesArray containsObject:self.searchArray[indexPath.item]])
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

//MARK: USing collection view delegate to add favorites
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.favoritesArray containsObject:self.searchArray[indexPath.item]])
    {
        [self.favoritesArray removeObject:self.searchArray[indexPath.item]];

        [self save];

    }
    else
    {

        [self.favoritesArray addObject:self.searchArray[indexPath.item]];

        [self save];

    }
    [self.collectionView reloadData];

}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.searchArray removeAllObjects];
    if (self.segmentedControl.selectedSegmentIndex == 1)
    {
        self.searchJson = kSearchUsers;
        NSString *searchString = [NSString stringWithFormat:self.searchJson,self.textfield.text];
        [self loadUsers:searchString];

    }
    else
    {
        self.searchJson = kSearchTags;
        NSString *searchString = [NSString stringWithFormat:self.searchJson,self.textfield.text];
        [self loadTags:searchString];

    }
    self.textfield.text = @"";
    [self.textfield resignFirstResponder];
    [self.collectionView reloadData];
    return YES;
}



- (void)loadTags:(NSString *)json
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
             NSArray *dataArray = jsonArray;
             for (NSDictionary *dataDict in dataArray)
             {
                 NSDictionary *imagesDict = dataDict[@"images"];
                 NSDictionary *resolutionDict = imagesDict[@"low_resolution"];
                 NSURL *imageURL = [NSURL URLWithString:resolutionDict[@"url"]];
                 NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
                 [self.searchArray addObject:imageData];
                 [self.collectionView reloadData];
             }
         }
     }];
}

- (void)loadUsers:(NSString *)json
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
             NSArray *dataArray = jsonArray;
             for (NSDictionary *dataDict in dataArray)
             {
                 NSURL *imageURL = [NSURL URLWithString:dataDict[@"profile_picture"]];
                 NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
                 [self.searchArray addObject:imageData];
                 [self.collectionView reloadData];
             }
         }
     }];
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

//MARK: Error alert
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

@end
