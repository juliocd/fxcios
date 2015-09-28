//
//  TIEProfileViewController.m
//  Cuatro X Carro
//
//  Created by Julio Cesar Diaz on 9/20/15.
//  Copyright © 2015 IT Economics SAS. All rights reserved.
//

#import "TIEProfileViewController.h"
#import "TIESingUpViewController.h"
#import "TIEMyScheduleViewController.h"

@interface TIEProfileViewController ()

@end

@implementation TIEProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)EditProfile:(id)sender {
    TIESingUpViewController *singupVC = [[TIESingUpViewController alloc] init];
    UINavigationController *trasformerNavC = [[UINavigationController alloc]initWithRootViewController:singupVC];
    [self presentViewController:trasformerNavC animated:YES completion:nil];
}

- (IBAction)updateSchedue:(id)sender {
    TIEMyScheduleViewController *myScheduleVC = [[TIEMyScheduleViewController alloc] init];
    UINavigationController *trasformerNavC = [[UINavigationController alloc]initWithRootViewController:myScheduleVC];
    [self presentViewController:trasformerNavC animated:YES completion:nil];
}
@end
