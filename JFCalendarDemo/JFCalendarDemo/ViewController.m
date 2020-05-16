//
//  ViewController.m
//  JFCalendarDemo
//
//  Created by zhaoyan on 2019/11/7.
//  Copyright © 2019 zhaoyan. All rights reserved.
//

#import "ViewController.h"
#import <JFCalendar/JFCalendar.h>

@interface ViewController () <JFCalendarViewDelegate>

@property (nonatomic, weak) id<JFCalendarViewProtocol> calendarView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIView<JFCalendarViewProtocol> *view = [JFVerticalCalendarView new];
    view.weekdaySymbolLabelHeight = 40;
    view.translatesAutoresizingMaskIntoConstraints = NO;
    view.backgroundColor = [UIColor whiteColor];
    view.delegate = self;
    view.dayViewSize = CGSizeMake(40, 50);
    view.dayTextViewEdgeInsets = UIEdgeInsetsMake(0, 0, 10, 0);
    //view.scrollDirection = JFCalendarViewScrollVerticalDirection;
    [self.view addSubview:view];
    self.calendarView = view;
    
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(view);
    
    [self.view addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[view]-0-|"
                                             options:0
                                             metrics:nil
                                               views:viewsDictionary]];
    [self.view addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-64-[view(400)]"
                                             options:0
                                             metrics:nil
                                               views:viewsDictionary]];
}

- (void)calendarView:(id<JFCalendarViewProtocol>)calendarView didDisplayMonth:(NSInteger)month inYear:(NSInteger)year
{
    //NSLog(@"year %ld, month %ld showed", (long)year, (long)month);
}

- (void)calendarView:(id<JFCalendarViewProtocol>)calendarView didSelectDate:(NSDate *)date
{
    NSLog(@"did select date : %@", date);
    
    UIAlertController *alert = [[UIAlertController alloc] init];
    alert.title = [date description];
    UIAlertAction *a = [UIAlertAction actionWithTitle:@"cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alert addAction:a];
    
    [self presentViewController:alert animated:YES completion:nil];
    
    [calendarView reloadAccessorieOnDate:date];
}

- (UIView *)calendarView:(id<JFCalendarViewProtocol>)calendarView
      accessoryViewOnDay:(NSDate *)date
     reusedAccessoryView:(UIView *)reusedView
{
    //NSDateComponents *c = [[NSCalendar currentCalendar] components:NSCalendarUnitDay fromDate:date];
    
    if (reusedView) {
        if ([calendarView.selectedDate isEqualToDate:date]) {
            reusedView.backgroundColor = [UIColor whiteColor];
        }
        else {
            reusedView.backgroundColor = [UIColor blueColor];
        }
        
        return reusedView;
    }
    else {
        UIView *dot = [UIView new];
        dot.layer.cornerRadius = 2;
        dot.frame = CGRectMake(18, 40, 4, 4);
        dot.backgroundColor = [UIColor redColor];
        
        if ([calendarView.selectedDate isEqualToDate:date]) {
            dot.backgroundColor = [UIColor whiteColor];

        }
        else {
            dot.backgroundColor = [UIColor blueColor];
        }
        
        return dot;
    }
}

@end
