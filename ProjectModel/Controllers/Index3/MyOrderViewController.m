//
//  MyOrderViewController.m
//  Club
//
//  Created by dongway on 14-8-31.
//  Copyright (c) 2014年 martin. All rights reserved.
//

#import "MyOrderViewController.h"
#import "OrderCell.h"
#import "TradeOrderCell.h"
#import "RobOrderData.h"
#import <UIImageView+WebCache.h>
#import "NSString+MT.h"
#import "MyOrderService.h"
#import "OrderDetailData.h"
#import "MyGroupCell.h"
#import "MyGroups.h"
#import "KillOrderCell.h"
#import "MySecond.h"
#import "MJRefresh.h"

@interface MyOrderViewController ()
{
    MyOrderService *myOrderService;
    NSInteger page;
    UserInfo *user;
    NSInteger selectedSegmentIndex1;
    NSInteger rereshinType;
    
   
}
@end

@implementation MyOrderViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    SharedData *sharedData = [SharedData sharedInstance];
    user = sharedData.user;
    selectedSegmentIndex1=0;
    myOrderService = [[MyOrderService alloc] init];
    self.items=[[NSMutableArray alloc] init];
    [SharedAction setupRefreshWithTableView:self.tableview toTarget:self];

}


#pragma UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.orderType==TradeOrderType) {
        TradeOrderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TradeOrderCell"];
        NSInteger row = indexPath.row;
         TradeOrder *order1 = [self.items objectAtIndex:row];
        cell.demo.text = order1.demo;
        cell.time.text = [order1.regtime substringToIndex:10];
//        cell.total.hidden = YES;
        cell.total.text = order1.status;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    }else if(self.orderType==RobOrderType){
        OrderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OrderCell"];
        NSInteger row = indexPath.row;
        RobOrder *order = [self.items objectAtIndex:row];
        [cell.imgView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IP,order.picture]] placeholderImage:[UIImage imageNamed:@"e"]];
        cell.name.text = order.name;
        NSString *stamp = order.regtime;
        cell.time.text = [stamp timeType3FromStamp:stamp];
        cell.status.text = order.status;
        return cell;
    }else if(self.orderType==GroupOrderType){
        MyGroupCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyGroupCell" forIndexPath:indexPath];
        NSInteger row = indexPath.row;
        MyGroupOrder *order = [self.items objectAtIndex:row];
        [cell.imgView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IP,order.picture]]];
        cell.name.text = order.name;
        cell.discount.text = [NSString stringWithFormat:@"%@元/%@",order.discount,order.unit];
//        cell.price.text = [NSString stringWithFormat:@"%@元/%@",order.price,order.unit];
        cell.time.text = order.regtime;
        cell.number.text = order.nums;
        cell.status.text = order.status;
        return cell;
    }else if(self.orderType==KillOrderType){
        KillOrderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"KillOrderCell" forIndexPath:indexPath];
        NSInteger row = indexPath.row;
        MySecondOrder *order = [self.items objectAtIndex:row];
        [cell.imgView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",PrexImgPath,order.picture]]];
        cell.name.text = order.name;
        cell.price.text = [NSString stringWithFormat:@"%@/%@",order.discount,order.unit];
        cell.time.text = order.regtime;
        cell.status.text = order.status;
        return cell;
    }else{
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{    if (self.orderType==RobOrderType) {
        return 90.0f;
    }else if(self.orderType==TradeOrderType){
        return 57.0f;
    }else if(self.orderType==GroupOrderType){
        return 119.0f;
    }else if(self.orderType == KillOrderType){
        return 100;
    }else{
        return 0;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath  {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (IBAction)swicthAction:(id)sender {
    UISegmentedControl *seg = (UISegmentedControl *)sender;
    selectedSegmentIndex1=seg.selectedSegmentIndex;
    [SharedAction setupRefreshWithTableView:self.tableview toTarget:self];
}

-(void)headerRereshing
{
    page=1;
    rereshinType=0;
    [SVProgressHUD show];
     NSString *pageString =[NSString stringWithFormat:@"%ld",(long)(long)page];
    [self rereShingWithPageString:pageString andRereShingType:rereshinType];
}

- (void)footerRereshing
{
    page++;
    rereshinType=1;
     [SVProgressHUD show];
    NSString *pageString =[NSString stringWithFormat:@"%ld",(long)(long)page];
    [self rereShingWithPageString:pageString andRereShingType:rereshinType];
}

-(void)rereShingWithPageString:(NSString *)pageString andRereShingType:(NSInteger )rereshinType1{
       if (selectedSegmentIndex1==0) {
        [myOrderService loadOrderWithPage:pageString andToken:user.token andUser_type:user.user_type andSelectedSegmentIndex:selectedSegmentIndex1 inTabBarController:self.tabBarController withDone:^(TradeOrderInfo *model){
            if (rereshinType1==0) {
                 self.items = (NSMutableArray *)model.order;
                 [_tableview headerEndRefreshing];
            }else{
                 [self.items addObjectsFromArray:model.order];
                 [_tableview footerEndRefreshing];
            }
            self.orderType=TradeOrderType;
            [self.tableview reloadData];
        }];
    }else if (selectedSegmentIndex1==1){
        [myOrderService loadOrderWithPage:pageString andToken:user.token andUser_type:user.user_type andSelectedSegmentIndex:selectedSegmentIndex1 inTabBarController:self.tabBarController withDone:^(RobOrderInfo *model){
            if (rereshinType1==0) {
                self.items = (NSMutableArray *)model.order;
                [_tableview headerEndRefreshing];
            }else{
                [self.items addObjectsFromArray:model.order];
                  [_tableview footerEndRefreshing];
            }
            self.orderType=RobOrderType;
            [self.tableview reloadData];
        }];
    }else if(selectedSegmentIndex1==2){
        [myOrderService loadOrderWithPage:pageString andToken:user.token andUser_type:user.user_type andSelectedSegmentIndex:selectedSegmentIndex1 inTabBarController:self.tabBarController withDone:^(MyGroupOrderInfo *model){
            if (rereshinType1==0) {
                self.items = (NSMutableArray *)model.order;
                [_tableview headerEndRefreshing];
            }else{
                [self.items addObjectsFromArray:model.order];
                  [_tableview footerEndRefreshing];
            }
            self.orderType=GroupOrderType;
            [self.tableview reloadData];
        }];
    }else{
        [myOrderService loadOrderWithPage:pageString andToken:user.token andUser_type:user.user_type andSelectedSegmentIndex:selectedSegmentIndex1 inTabBarController:self.tabBarController withDone:^(MySecondInfo *model){
            if (rereshinType1==0) {
                self.items = (NSMutableArray *)model.order;
                [_tableview headerEndRefreshing];
            }else{
                [self.items addObjectsFromArray:model.order];
                  [_tableview footerEndRefreshing];
            }
            self.orderType=KillOrderType;
            [self.tableview reloadData];
        }];
    }
}

#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"goodToDetail"]) {
        if (self.orderType==TradeOrderType){
        NSIndexPath *indexPath = [self.tableview indexPathForSelectedRow];
        NSInteger row = indexPath.row;
        TradeOrder *order1 = [self.items objectAtIndex:row];
        TradeOrderDetailViewController *viewController = segue.destinationViewController;
        viewController.orderid = order1.orderid;
        }
    }
}



@end
