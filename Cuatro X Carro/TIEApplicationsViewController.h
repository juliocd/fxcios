//
//  TIEApplicationsViewController.h
//  Cuatro X Carro
//
//  Created by Julio Cesar Diaz on 9/27/15.
//  Copyright © 2015 IT Economics SAS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TIEApplicationsViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

- (id)initWithTripId:(NSString *) aTripId withSecond:(NSString *) aMaxSeats;

@property (weak, nonatomic) IBOutlet UITableView *applicationsTableView;

@property (weak, nonatomic) IBOutlet UILabel *applicantName;
@property (weak, nonatomic) IBOutlet UILabel *applicantEmail;
@property (weak, nonatomic) IBOutlet UILabel *applicantPhone;
@property (weak, nonatomic) IBOutlet UITextView *applicantAddress;
- (IBAction)AcceptingApplication:(id)sender;
- (IBAction)CancelApplication:(id)sender;
@end
