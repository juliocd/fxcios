//
//  TIEApplicationsViewController.h
//  Cuatro X Carro
//
//  Created by Julio Cesar Diaz on 9/27/15.
//  Copyright © 2015 IT Economics SAS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TIEApplicationsViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSArray *applications;

@property (weak, nonatomic) IBOutlet UITableView *applicationsTableView;

@end
