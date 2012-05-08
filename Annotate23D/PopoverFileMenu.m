//
//  PopoverFileMenu.m
//  Annotate23D
//
//  Created by William Brown on 2012/02/08.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PopoverFileMenu.h"
#import "WorkspaceViewController.h"
#import "SceneArchiver.h"


@implementation PopoverFileMenu
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (void)loadBackgroundImage:(id)sender {
  [self.delegate loadNewBackgroundImage];
}

- (IBAction)newSketch:(id)sender {
  [self.delegate newSketch];
}

- (IBAction)saveSketch:(id)sender {
  UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Save Scene" message:@"Please enter a name to save the scene under" delegate:self cancelButtonTitle:@"Save" otherButtonTitles:nil];
  alert.alertViewStyle = UIAlertViewStylePlainTextInput;
  UITextField * alertTextField = [alert textFieldAtIndex:0];
  alertTextField.placeholder = @"Name for saved scene";
  [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{ 
  NSLog(@"Entered: %@",[[alertView textFieldAtIndex:0] text]);
  [self.delegate saveSketch:[[alertView textFieldAtIndex:0] text]];
}

- (IBAction)loadSketch:(id)sender {
  [self.delegate loadSketch];
}
@end
