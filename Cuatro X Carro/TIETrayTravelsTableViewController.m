//
//  TIETrayTravelsTableViewController.m
//  Cuatro X Carro
//
//  Created by Julio Cesar Diaz on 9/20/15.
//  Copyright © 2015 IT Economics SAS. All rights reserved.
//

#import "TIETrayTravelsTableViewController.h"
#import "TIETravelCustomCellTableViewCell.h"
#import "TIETravelDetailsViewController.h"

@interface TIETrayTravelsTableViewController ()

@end

@implementation TIETrayTravelsTableViewController

@synthesize items;

- (NSArray *)items
{
    if (!items)
    {
        NSMutableArray * arr = [NSMutableArray arrayWithCapacity:20];
        for (NSInteger i=0; i<20; i++)
            [arr addObject:[NSString stringWithFormat:@"Nombre %ld", (long)i]];
        items = arr;
    }
    return items;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
}

//Se determina numero de filas de la tabla
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.items count];
}
//Se configura celda a cargar en la tabla
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //Se crea instancia de celda
    TIETravelCustomCellTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"tableCell"];
    //Se valida que la celda esta vacia para llenarla
    if (!cell)
    {
        //Se registra celda creda a archivo xib
        [tableView registerNib:[UINib nibWithNibName:@"TIETravelCustomCellTableViewCell" bundle:nil] forCellReuseIdentifier:@"tableCell"];
        //Se agrega vista cargada con celda a tabla
        cell = [tableView dequeueReusableCellWithIdentifier:@"tableCell"];
    }
    
    return cell;
}
//Se configuran datos de la celda
- (void)tableView:(UITableView *)tableView willDisplayCell:(TIETravelCustomCellTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.userNameLabel.text = [self.items objectAtIndex:indexPath.row];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here, for example:
    // Create the next view controller.
    
    TIETravelDetailsViewController *detailViewController = [[TIETravelDetailsViewController alloc] init];
    
    // Pass the selected object to the new view controller.
    
    // Push the view controller.
    UINavigationController *trasformerNavC = [[UINavigationController alloc]initWithRootViewController:detailViewController];
    [self presentViewController:trasformerNavC animated:YES completion:nil];
    //[self.navigationController pushViewController:trasformerNavC animated:YES];
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
