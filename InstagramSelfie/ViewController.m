//
//  ViewController.m
//  InstagramSelfie
//
//  Created by Bhanu Birani on 08/07/15.
//  Copyright (c) 2015 Bhanu Birani. All rights reserved.
//

#import "ViewController.h"
#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"

@interface ViewController () {
    UIView *fullScreenImageView;
}

@end

@implementation ViewController

@synthesize collectionView;
NSDictionary *instagramJSONDic;
int columnCount = 0;

- (void)viewDidLoad {
    [super viewDidLoad];

    instagramJSONDic = [[NSDictionary alloc] init];
    fullScreenImageView = [[UIView alloc] init];
    self.view.backgroundColor = [UIColor blackColor];
    columnCount = 0;
    
    [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"imgCell"];
    [self startAFDownload];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark networking code

-(void)startAFDownload {
    NSString *urlString = @"https://api.instagram.com/v1/tags/selfie/media/recent?access_token=647785057.1677ed0.4de58c986679455d95d7a74ed8c22d53";
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"completion success");
        instagramJSONDic = (NSDictionary *)responseObject;
        [collectionView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error receiving data from Instagram "
                                                            message:[error localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
    }];
    [operation start];
}

#pragma mark infastructure

-(void)tapAction {
    [fullScreenImageView removeFromSuperview];
}

#pragma Collection view delegate/datasource

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    NSArray *tempArray =[instagramJSONDic objectForKey:@"data"];
    return [tempArray count];
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"imgCell" forIndexPath:indexPath];
    
    __weak UICollectionViewCell *weakCell = cell;
    
    NSString *imageURL = [[[[[instagramJSONDic objectForKey: @"data" ] objectAtIndex:indexPath.row] objectForKey:@"images"] objectForKey:@"standard_resolution"] objectForKey:@"url"];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height)];
    imageView.tag = 100+indexPath.row;
    
    [cell addSubview:imageView];
    
    NSURL *url = [NSURL URLWithString:imageURL];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    UIImage *placeholderImage = [UIImage imageNamed:@""];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    __weak UIImageView *weakImageView = imageView;
    [imageView setImageWithURLRequest:request
                     placeholderImage:placeholderImage
                              success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                  [weakImageView setImage:image];
                                  [weakCell setNeedsLayout];
                              } failure:nil];
    
    cell.backgroundColor = [UIColor whiteColor];
    cell.layer.borderColor = [UIColor whiteColor].CGColor;
    cell.layer.borderWidth = 2;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    fullScreenImageView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    fullScreenImageView.backgroundColor = [UIColor blackColor];
    
    UIImageView *fullImageView = (UIImageView *)[self.view viewWithTag:100+indexPath.row];
    UIImageView *pictureView = [[UIImageView alloc] initWithFrame:CGRectMake(40, 200, 300, 300)];
    if ([fullImageView.image isKindOfClass:[UIImage class]]) {
        [pictureView setImage:fullImageView.image];
    }
    
    [fullScreenImageView addSubview:pictureView];
    [self.view addSubview:fullScreenImageView];
    
    UITapGestureRecognizer* tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(tapAction)];
    [fullScreenImageView addGestureRecognizer:tgr];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize frameSize;
    switch(columnCount){
        case 0  :
            frameSize = CGSizeMake(125, 125);
            columnCount =  columnCount + 1;
            break;
        case 1  :
            frameSize = CGSizeMake(100, 100);
            columnCount = columnCount + 1;
            break;
        case 2 :
            frameSize = CGSizeMake(75, 75);
            columnCount = 0;
        default :
            frameSize = CGSizeMake(75, 75);
    }
    [self.collectionView reloadData];
    return frameSize;
}

@end
