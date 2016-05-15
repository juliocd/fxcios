//
//  TIEApplicationsViewController.h
//  Cuatro X Carro
//
//  Created by Julio Cesar Diaz on 9/27/15.
//  Copyright © 2015 IT Economics SAS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TIEApplicationsViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

- (id)initWithTripId:(NSString *) aTripId withSecond:(NSString *) aMaxSeats withThird:(NSMutableArray *) aPassengers;

@property (weak, nonatomic) IBOutlet UITableView *applicationsTableView;

@property (weak, nonatomic) IBOutlet UILabel *applicantName;
@property (weak, nonatomic) IBOutlet UILabel *applicantEmail;
@property (weak, nonatomic) IBOutlet UILabel *applicantPhone;
@property (weak, nonatomic) IBOutlet UITextView *applicantAddress;
@property (weak, nonatomic) IBOutlet UIImageView *passengerPrictureProfile;
@property (weak, nonatomic) IBOutlet UITableView *applicationsTable;
@property (weak, nonatomic) IBOutlet UILabel *informationTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *aceptRequestButton;
@property (weak, nonatomic) IBOutlet UIButton *rejectRequestButton;


- (IBAction)AnswerApplication:(id)sender;
@end
