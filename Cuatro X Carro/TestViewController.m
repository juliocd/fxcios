//
//  TestViewController.m
//  Cuatro X Carro
//
//  Created by Julio Cesar Diaz M on 3/29/16.
//  Copyright © 2016 IT Economics SAS. All rights reserved.
//

#import "TestViewController.h"

@interface TestViewController ()

@end

@implementation TestViewController
@synthesize test;
- (void)viewDidLoad {
    
    test.adjustsFontSizeToFitWidth=YES;
    test.minimumScaleFactor=0.5;
    
    [super viewDidLoad];
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

@end
