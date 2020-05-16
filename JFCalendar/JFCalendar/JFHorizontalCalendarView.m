//
//  JFHorizontalCalendarView.m
//  JFCalendar
//
//  Created by 赵岩 on 2020/5/16.
//  Copyright © 2020 zhaoyan. All rights reserved.
//

#import "JFHorizontalCalendarView.h"
#import "JFCalendarMonthView.h"

@interface JFHorizontalCalendarView () <UIScrollViewDelegate, JFCalendarMonthViewDelegate>

@property (nonatomic, weak) UIScrollView *monthViewContainer;

@property (nonatomic, strong) NSMutableArray *monthViewList;
@property (nonatomic, strong) NSMutableArray *leftConstraints;
@property (nonatomic, strong) NSMutableArray *heightConstrains;

@property (nonatomic, weak) UIView *weekdaySymbolContainer;
@property (nonatomic, strong) NSArray *weekdaySymbolLabels;

@property (nonatomic, weak) NSLayoutConstraint *weekSymbolContainerHeightConstraint;

@end

@implementation JFHorizontalCalendarView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initData];
        
        [self initSubview];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self initData];
        
        [self initSubview];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self repostionMonthViews];
}

- (void)initData
{
    self.weekdaySymbolFont = [UIFont boldSystemFontOfSize:10];
    self.weekdaySymbolColor = [UIColor whiteColor];
    self.weekdaySymbolLabelHeight = 60;
    
    self.dayViewSize = CGSizeMake(40, 50);
    
    self.firstWeekday = 2;

    NSDate *today = [NSDate date];
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitEra|NSCalendarUnitYear|NSCalendarUnitMonth fromDate:today];
    
    currentEra = components.era;
    currentYear = components.year;
    currentMonth = components.month;
}

- (void)initSubview
{
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    scrollView.pagingEnabled = YES;
    scrollView.delegate = self;
    [self addSubview:scrollView];
    
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(scrollView);

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[scrollView]-0-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:viewsDictionary]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-40-[scrollView]-0-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:viewsDictionary]];
    self.monthViewContainer = scrollView;
    
    [self createWeekLabelView];
    
    [self createMonthViews];
}

- (void)createWeekLabelView
{
    UIView *view = [UIView new];
    view.clipsToBounds = YES;
    view.backgroundColor = [UIColor clearColor];
    view.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSDateFormatter* fmt = [[NSDateFormatter alloc] init];
    fmt.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    NSArray *weekdayNameList = fmt.shortWeekdaySymbols;
    
    UIView *lastLabel = nil;
    UIView *lastMarginView = nil;
    
    CGFloat width = self.dayViewSize.width;
    CGFloat height = self.dayViewSize.height;
    
    NSMutableArray *array = [NSMutableArray array];
    
    for (int i = 0; i < 7; ++i) {
        NSInteger index = (i + firstWeekday - 1) % 7;
        
        UILabel *label = [UILabel new];
        label.backgroundColor = [UIColor clearColor];
        label.translatesAutoresizingMaskIntoConstraints = NO;
        label.font = self.weekdaySymbolFont;
        label.textColor = self.weekdaySymbolColor;
        label.textAlignment = NSTextAlignmentCenter;
        [view addSubview:label];
        label.text = weekdayNameList[index];
        
        UIView *marginView = [UIView new];
        marginView.translatesAutoresizingMaskIntoConstraints = NO;
        [view addSubview:marginView];
        
        [label addConstraint:[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:width]];
        
        [label addConstraint:[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:height]];
        
        if (lastMarginView) {
            [view addConstraint:[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:lastMarginView attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
            
            [view addConstraint:[NSLayoutConstraint constraintWithItem:marginView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:label attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
            
            [view addConstraint:[NSLayoutConstraint constraintWithItem:marginView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:lastMarginView attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
        }
        else {
            [view addConstraint:[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
            
            [view addConstraint:[NSLayoutConstraint constraintWithItem:marginView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:label attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
        }
        
        [view addConstraint:[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
        
        [view addConstraint:[NSLayoutConstraint constraintWithItem:marginView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
        
        lastLabel = label;
        lastMarginView = marginView;
        
        [array addObject:label];
    }
    
    [view addConstraint:[NSLayoutConstraint constraintWithItem:lastLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
    
    [self addSubview:view];
    self.weekdaySymbolContainer = view;
    self.weekdaySymbolLabels = [NSArray arrayWithArray:array];
    
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(view);

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[view]-0-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:viewsDictionary]];
    
    NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[view(height)]"
                                                            options:0
                                                            metrics:@{@"height":@(weekdaySymbolLabelHeight)}
                                                              views:viewsDictionary];
    
    [self addConstraints:constraints];
    
    for (NSLayoutConstraint *c in constraints) {
        if (c.firstAttribute == NSLayoutAttributeHeight) {
            self.weekSymbolContainerHeightConstraint = c;
            break;
        }
    }
}

- (void)createMonthViews
{
    NSMutableArray *viewList = [NSMutableArray array];
    NSMutableArray *leftConstraints = [NSMutableArray array];
    NSMutableArray *heightConstrains = [NSMutableArray array];
    
    NSInteger era = currentEra;
    NSInteger year = currentYear;
    NSInteger month = currentMonth;
    
    [self previousMonth:&year month:&month era:&era];
    
    JFCalendarMonthView *monthView = [JFCalendarMonthView new];
    monthView.translatesAutoresizingMaskIntoConstraints = NO;
    monthView.dayViewSize = self.dayViewSize;
    monthView.dayTextViewEdgeInsets = self.dayTextViewEdgeInsets;
    [monthView setEra:era year:year month:month];
    [self.monthViewContainer addSubview:monthView];
    NSLayoutConstraint *wc = [NSLayoutConstraint constraintWithItem:monthView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.monthViewContainer attribute:NSLayoutAttributeWidth multiplier:1 constant:0];
    [wc setActive:YES];
    NSLayoutConstraint *hc = [NSLayoutConstraint constraintWithItem:monthView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.monthViewContainer attribute:NSLayoutAttributeHeight multiplier:1 constant:0];
    [hc setActive:YES];
    [heightConstrains addObject:hc];
    NSLayoutConstraint *tc = [NSLayoutConstraint constraintWithItem:monthView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.monthViewContainer attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    [tc setActive:YES];
    NSLayoutConstraint *lc = [NSLayoutConstraint constraintWithItem:monthView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.monthViewContainer attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
    [lc setActive:YES];
    [leftConstraints addObject:lc];
    [viewList addObject:monthView];
    
    monthView = [JFCalendarMonthView new];
    monthView.translatesAutoresizingMaskIntoConstraints = NO;
    monthView.dayViewSize = self.dayViewSize;
    monthView.dayTextViewEdgeInsets = self.dayTextViewEdgeInsets;
    monthView.delegate = self;
    [monthView setEra:currentEra year:currentYear month:currentMonth];
    [self.monthViewContainer addSubview:monthView];
    wc = [NSLayoutConstraint constraintWithItem:monthView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.monthViewContainer attribute:NSLayoutAttributeWidth multiplier:1 constant:0];
    [wc setActive:YES];
    hc = [NSLayoutConstraint constraintWithItem:monthView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.monthViewContainer attribute:NSLayoutAttributeHeight multiplier:1 constant:0];
    [hc setActive:YES];
    [heightConstrains addObject:hc];
    tc = [NSLayoutConstraint constraintWithItem:monthView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.monthViewContainer attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    [tc setActive:YES];
    lc = [NSLayoutConstraint constraintWithItem:monthView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.monthViewContainer attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
    [lc setActive:YES];
    [leftConstraints addObject:lc];
    
    [viewList addObject:monthView];
    
    era = currentEra;
    year = currentYear;
    month = currentMonth;
    
    [self nextMonth:&year month:&month era:&era];

    monthView = [JFCalendarMonthView new];
    monthView.translatesAutoresizingMaskIntoConstraints = NO;
    monthView.dayViewSize = self.dayViewSize;
    monthView.dayTextViewEdgeInsets = self.dayTextViewEdgeInsets;
    [monthView setEra:era year:year month:month];
    [self.monthViewContainer addSubview:monthView];
    [viewList addObject:monthView];
    wc = [NSLayoutConstraint constraintWithItem:monthView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.monthViewContainer attribute:NSLayoutAttributeWidth multiplier:1 constant:0];
    [wc setActive:YES];
    hc = [NSLayoutConstraint constraintWithItem:monthView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.monthViewContainer attribute:NSLayoutAttributeHeight multiplier:1 constant:0];
    [hc setActive:YES];
    [heightConstrains addObject:hc];
    tc = [NSLayoutConstraint constraintWithItem:monthView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.monthViewContainer attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    [tc setActive:YES];
    
    lc = [NSLayoutConstraint constraintWithItem:monthView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.monthViewContainer attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
    [lc setActive:YES];
    [leftConstraints addObject:lc];
    
    self.monthViewList = viewList;
    self.leftConstraints = leftConstraints;
    self.heightConstrains = heightConstrains;
}

- (void)setDayViewSize:(CGSize)value
{
    dayViewSize = value;
    
    for (JFCalendarMonthView *monthView in self.monthViewList) {
        monthView.dayViewSize = dayViewSize;
    }
}

- (void)setDayTextViewEdgeInsets:(UIEdgeInsets)value
{
    dayTextViewEdgeInsets = value;
    
    for (JFCalendarMonthView *monthView in self.monthViewList) {
        monthView.dayTextViewEdgeInsets = dayTextViewEdgeInsets;
    }
}

- (void)setWeekdaySymbolFont:(UIFont *)value
{
    weekdaySymbolFont = value;
    for (UILabel *lable in self.weekdaySymbolLabels) {
        lable.font = weekdaySymbolFont;
    }
}

- (void)setWeekdaySymbolColor:(UIColor *)value
{
    weekdaySymbolColor = value;
    for (UILabel *lable in self.weekdaySymbolLabels) {
        lable.textColor = weekdaySymbolColor;
    }
}

- (void)setWeekdaySymbolLabelHeight:(CGFloat)value
{
    weekdaySymbolLabelHeight = value;
    self.weekSymbolContainerHeightConstraint.constant = weekdaySymbolLabelHeight;
}

- (void)setTodayTextColor:(UIColor *)value
{
    todayTextColor = value;

    for (JFCalendarMonthView *view in self.monthViewList) {
        view.todayTextColor = value;
    }
}

- (void)setDayTextColor:(UIColor *)value
{
    dayTextColor = value;
    
    for (JFCalendarMonthView *view in self.monthViewList) {
        view.dayTextColor = value;
    }
}

- (void)setDaySelectedTextColor:(UIColor *)value
{
    daySelectedTextColor = value;
    
    for (JFCalendarMonthView *view in self.monthViewList) {
        view.daySelectedTextColor = value;
    }
}

- (void)setTodaySelectedTextColor:(UIColor *)value
{
    todaySelectedTextColor = value;
    
    for (JFCalendarMonthView *view in self.monthViewList) {
        view.todaySelectedTextColor = value;
    }
}

- (void)setTodaySelectedBackgroundColor:(UIColor *)value
{
    todaySelectedBackgroundColor = value;
    
    for (JFCalendarMonthView *view in self.monthViewList) {
        view.todaySelectedBackgroundColor = value;
    }
}

- (void)setDaySelectedBackgroundColor:(UIColor *)value
{
    daySelectedBackgroundColor = value;
    
    for (JFCalendarMonthView *view in self.monthViewList) {
        view.daySelectedBackgroundColor = value;
    }
}

- (void)previousMonth:(NSInteger *)year month:(NSInteger *)month era:(NSInteger *)era
{
    if (*month == 1) {
        *month = 12;
        if (*era == 1) {
            if (*year == 1) {
                *year = 1;
                *era = 0;
            }
            else {
                *year = *year - 1;
            }
        }
        else {
            *year = *year + 1;
        }
    }
    else {
        *month = *month - 1;
    }
}

- (void)nextMonth:(NSInteger *)year month:(NSInteger *)month era:(NSInteger *)era
{
    if (*month == 12) {
        *month = 1;
        if (*era == 1) {
            *year = *year + 1;
        }
        else {
            if (*year > 1) {
                *year = *year - 1;
            }
            else {
                *era = 1;
                *year = 1;
            }
        }
    }
    else {
        *month = *month + 1;
    }
}

- (void)leftShiftArray:(NSMutableArray *)array
{
    id obj = [array objectAtIndex:0];
    [array removeObjectAtIndex:0];
    [array addObject:obj];
}

- (void)rightShiftArray:(NSMutableArray *)array
{
    id obj = [array objectAtIndex:2];
    [array removeObjectAtIndex:2];
    [array insertObject:obj atIndex:0];
}

- (void)repostionMonthViews
{
    CGSize size = self.monthViewContainer.frame.size;

    self.monthViewContainer.contentSize = CGSizeMake(size.width * 3, size.height);
    [self.monthViewContainer setContentOffset:CGPointMake(size.width, 0)];
    
    for (NSLayoutConstraint *c in self.leftConstraints) {
        c.constant = [self.leftConstraints indexOfObject:c] * size.width;
    }
    
    JFCalendarMonthView *monthView = [self.monthViewList objectAtIndex:1];
    [self.delegate calendarView:self didDisplayMonth:monthView.month inYear:monthView.year];
}

- (void)rearrangeCalendarMonthViews
{
    NSInteger page = self.monthViewContainer.contentOffset.x / self.monthViewContainer.frame.size.width;
    
    if (page == 1) return;
    
    if (page == 0) {
        // previous
        [self rightShiftArray:self.monthViewList];
        [self rightShiftArray:self.leftConstraints];
    }
    else if (page == 2) {
        // next
        [self leftShiftArray:self.monthViewList];
        [self leftShiftArray:self.leftConstraints];
    }
    
    JFCalendarMonthView *monthView = [self.monthViewList objectAtIndex:1];
    monthView.delegate = self;
    monthView.selectedDate = self.selectedDate;
    NSInteger era = monthView.era;
    NSInteger year = monthView.year;
    NSInteger month = monthView.month;
    
    if (page == 0) {
        // previous
        monthView = [self.monthViewList objectAtIndex:0];
        monthView.delegate = nil;
        monthView.selectedDate = nil;
        [self previousMonth:&year month:&month era:&era];
        [monthView setEra:era year:year month:month];
    }
    else if (page == 2) {
        // next
        monthView = [self.monthViewList objectAtIndex:2];
        monthView.delegate = nil;
        monthView.selectedDate = nil;
        [self nextMonth:&year month:&month era:&era];
        [monthView setEra:era year:year month:month];
    }
    
    [self repostionMonthViews];
}

@synthesize currentEra;
@synthesize currentYear;
@synthesize currentMonth;

@synthesize weekdaySymbolFont;
@synthesize weekdaySymbolColor;
@synthesize weekdaySymbolLabelHeight;

@synthesize monthSymbolFont;
@synthesize monthSymbolColor;
@synthesize monthSymbolHeight;

@synthesize firstWeekday;

@synthesize dayViewSize;
@synthesize dayTextViewEdgeInsets;

@synthesize selectedDate;

@synthesize delegate;

@synthesize daySelectedBackgroundColor;

@synthesize daySelectedTextColor;

@synthesize dayTextColor;

@synthesize todaySelectedBackgroundColor;

@synthesize todaySelectedTextColor;

@synthesize todayTextColor;

- (void)reloadAccessories
{
    JFCalendarMonthView *monthView = [self.monthViewList objectAtIndex:1];
    [monthView reloadAccessories];
}

- (void)reloadAccessorieOnDate:(NSDate *)date
{
    JFCalendarMonthView *monthView = [self.monthViewList objectAtIndex:1];
    [monthView reloadAccessorieOnDate:date];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        [self rearrangeCalendarMonthViews];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self rearrangeCalendarMonthViews];
}

- (void)monthView:(JFCalendarMonthView *)monthView didSelectDate:(NSDate *)date
{
    selectedDate = date;
    [self.delegate calendarView:self didSelectDate:date];
}

- (UIView *)monthView:(JFCalendarMonthView *)monthView
   accessoryViewOnDay:(NSDate *)date
  reusedAccessoryView:(UIView *)reusedView
{
    return [self.delegate calendarView:self accessoryViewOnDay:date reusedAccessoryView:reusedView];
}

@end
