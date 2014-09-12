//
//
// The MIT License (MIT)
//
// Copyright (c) 2013 Backelite
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "BKTViewController.h"
#import "BKTPopinControllerViewController.h"
#import "UIViewController+MaryPopin.h"

@interface BKTViewController ()

@property (nonatomic, getter = isDismissable) BOOL dismissable;
@property (nonatomic, assign) NSInteger selectedAlignementOption;

- (IBAction)presentPopinPressed:(id)sender;

@end

@implementation BKTViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.selectedAlignementOption = 0;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:kMaryPopinDismissNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
}

- (IBAction)presentPopinPressed:(id)sender
{
    NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
    BKTPopinControllerViewController *popin = [[BKTPopinControllerViewController alloc] init];
    [popin setPopinTransitionStyle:[self transitionStyleForIndexPath:selectedIndexPath]];
    if ([self isDismissable]) {
        [popin setPopinOptions:BKTPopinDefault];
    } else {
        [popin setPopinOptions:BKTPopinDisableAutoDismiss];
    }
    
    //Set popin alignement according to value in segmented control
    [popin setPopinAlignment:self.selectedAlignementOption];
    
    //Create a blur parameters object to configure background blur
    BKTBlurParameters *blurParameters = [BKTBlurParameters new];
    blurParameters.alpha = 1.0f;
    blurParameters.radius = 8.0f;
    blurParameters.saturationDeltaFactor = 1.8f;
    blurParameters.tintColor = [UIColor colorWithRed:0.966 green:0.851 blue:0.038 alpha:0.2];
    [popin setBlurParameters:blurParameters];
    
    //Add option for a blurry background
    [popin setPopinOptions:[popin popinOptions]|BKTPopinBlurryDimmingView];
    
    //Define a custom transition style
    if (popin.popinTransitionStyle == BKTPopinTransitionStyleCustom)
    {
        [popin setPopinCustomInAnimation:^(UIViewController *popinController, CGRect initialFrame, CGRect finalFrame) {
                      
            popinController.view.frame = finalFrame;
            popinController.view.transform = CGAffineTransformMakeRotation(M_PI_4 / 2);
            
        }];
        
        [popin setPopinCustomOutAnimation:^(UIViewController *popinController, CGRect initialFrame, CGRect finalFrame) {
            
            popinController.view.frame = finalFrame;
            popinController.view.transform = CGAffineTransformMakeRotation(M_PI_2);
            
        }];
    }
    
    [popin setPreferedPopinContentSize:CGSizeMake(280.0, 240.0)];
    
    //Set popin transition direction
    [popin setPopinTransitionDirection:BKTPopinTransitionDirectionTop];
    [self.navigationController presentPopinController:popin animated:YES completion:^{
        NSLog(@"Popin presented !");
    }];
}

- (IBAction)isDismissableValueChanged:(id)sender
{
    [self setDismissable:((UISwitch *)sender).isOn];
}

- (BKTPopinTransitionStyle)transitionStyleForIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return indexPath.row;
    }
    return 0;
}

- (IBAction)segmentedControlChange:(UISegmentedControl *)sender
{
    self.selectedAlignementOption = sender.selectedSegmentIndex;
}

- (void)receiveNotification:(NSNotification *)notif
{
    NSLog(@"%s %@",__FUNCTION__,[notif name]);
}

@end
