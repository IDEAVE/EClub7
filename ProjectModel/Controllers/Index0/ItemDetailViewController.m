//
//  ItemDetailViewController.m
//  Club
//
//  Created by dongway on 14-8-11.
//  Copyright (c) 2014年 martin. All rights reserved.
//

//
//  ItemDetailViewController.m
//  Club
//
//  Created by dongway on 14-8-11.
//  Copyright (c) 2014年 martin. All rights reserved.
//

#import "ItemDetailViewController.h"
#import "ItemDetailService.h"
#import <UIImageView+WebCache.h>
#import "PurchaseCarItemsViewController.h"
#import "WebViewController.h"
#import "MLFloatButton.h"
#import "SharedData.h"
#import "Member_Login.h"
#import "SVProgressHUD.h"
#import "Status.h"
@interface ItemDetailViewController ()<MLFloatButtonDelegate,UIWebViewDelegate,UIScrollViewDelegate>
{
    ItemDetailService *itemDetailService;
    WebViewController *target;
    NSString *gid;
}
@end

@implementation ItemDetailViewController

-(id)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]) {
        itemDetailService = [[ItemDetailService alloc] init];
    }
    return self;
}
-(void)loadView{
    [super loadView];
    self.automaticallyAdjustsScrollViewInsets = NO;
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [SVProgressHUD dismiss];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.scrollview setContentOffset:CGPointMake(15, 0)];
    self.title = self.goodModel.name;
    gid = self.goodModel.gid;
    [self.imgView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IP,self.goodModel.bigpicture]] placeholderImage:[UIImage imageNamed:@"e"]];
    self.currentPrice.text = [NSString stringWithFormat:@"%@元/%@",self.goodModel.discount,self.goodModel.unit];
    self.pastPrice.text = [NSString stringWithFormat:@"%@元/%@",self.goodModel.price,self.goodModel.unit];
    self.count.text = self.goodModel.unit_num;
    self.Ems.text = self.goodModel.logistics;
    self.floatButton = [MLFloatButton loadFromNibAddTarget :self InSuperView:self.view];
    self.webview.scrollView.scrollEnabled = NO;
    [self loadWebPageWithString:self.goodModel.url inWebView:self.webview];
}
- (void)loadWebPageWithString:(NSString*)urlString inWebView:(UIWebView *)webView{
    NSURL *url =[NSURL URLWithString:urlString];
    NSURLRequest *request =[NSURLRequest requestWithURL:url];
    [webView loadRequest:request];
}

#pragma UIWebViewDelegate
- (void)webViewDidStartLoad:(UIWebView *)webView{
    [SVProgressHUD show];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [SVProgressHUD dismiss];
    CGRect frame = webView.frame;
    CGSize mWebViewTextSize = [webView sizeThatFits:CGSizeMake(1.0f, 1.0f)];
    frame.size = mWebViewTextSize;
    self.webview.frame = frame;
    [self.scrollview setContentSize:CGSizeMake(DeviceFrame.size.width, mWebViewTextSize.height+240+100)];
    NSLog(@"%f",self.webviewHeight.constant);
     self.webviewHeight.constant = mWebViewTextSize.height+240;
}

//#pragma UIScrollViewDelegate
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
//    NSLog(@"%@",NSStringFromCGSize(scrollView.contentSize));
//}

-(void)buttonTouchAction
{
    PurchaseCarItemsViewController *purchaseCar = [self.storyboard instantiateViewControllerWithIdentifier:@"PurchaseCarItemsViewController"];
    [self.navigationController pushViewController:purchaseCar animated:YES];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)reduceAction:(id)sender {
    self.count.text = [itemDetailService reduceNumber:self.count];
}

- (IBAction)addAction:(id)sender {
    self.count.text = [itemDetailService addNumber:self.count];
}

- (IBAction)buyAction:(id)sender {
   }

- (IBAction)addToPurchaseCar:(id)sender {
    NSString *num = self.count.text;
    [itemDetailService addToPurchaseCarWithGid:gid andNum:num inTabBarController:self.tabBarController withDone:^(Status *model){
    
    }];
}

- (IBAction)buynow:(id)sender {
    //立即购买
    NSString *count = self.count.text;
    [itemDetailService presentPurchaseCarViewControllerOnViewController:self andItemCount:count];
    
}
- (IBAction)share:(id)sender {
    [SharedAction shareWithTitle:self.title andDesinationUrl:self.goodModel.url Text:self.goodModel.name andImageUrl:[NSString stringWithFormat:@"%@%@",IP,self.goodModel.bigpicture] InViewController:self];
}
//- (IBAction)segMent:(UISegmentedControl *)sender {
//       if (sender.selectedSegmentIndex==0) {
//        [target.view removeFromSuperview];
//        [target removeFromParentViewController];
//    }else{
//        if (!target) {
//            target = [[WebViewController alloc] initWithNibName:@"WebViewController" bundle:nil];
////            target.urlString = self.goodModel.url;
//            [target.view layoutSubviews];
//            NSLog(@"%@",target.urlString);
////            target.view.frame = CGRectMake(0, NavigationBarFrame.size.height+StatusBarFrame.size.height, DeviceFrame.size.width, DeviceFrame.size.height-NavigationBarFrame.size.height+StatusBarFrame.size.height);
//        }
//        [self addChildViewController:target];
//        [self.view addSubview:target.view];
//    }
//}


@end
