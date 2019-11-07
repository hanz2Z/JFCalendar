//
//  JFCalendarView.m
//  JFCalendar
//
//  Created by zhaoyan on 2019/8/14.
//  Copyright © 2019年 zhaoyan. All rights reserved.
//

#import "JFCalendarView.h"
#import "JFCalendarMonthView.h"

#define VARIABLE_NAME(name, suffix) name##suffix

@interface JFCalendarView () <UIScrollViewDelegate, JFCalendarMonthViewDelegate>

@property (nonatomic, weak) UIScrollView *monthViewContainer;
@property (nonatomic, strong) NSMutableArray *monthViewList;

@end

@implementation JFCalendarView

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

- (void)initData
{
    _scrollDirection = JSCalendarViewScrollHorizontalDirection;
    _weekdaySymbolLabelHeight = 40;

    NSDate *today = [NSDate date];
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitEra|NSCalendarUnitYear|NSCalendarUnitMonth fromDate:today];
    
    self.dayViewSize = CGSizeMake(40, 40);
    
    _firstWeekday = 2;

    _currentEra = components.era;
    _currentYear = components.year;
    _currentMonth = components.month;
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
    view.backgroundColor = [UIColor clearColor];
    view.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSDateFormatter* fmt = [[NSDateFormatter alloc] init];
    fmt.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    NSArray *weekdayNameList = fmt.shortWeekdaySymbols;
    
    UIView *lastLabel = nil;
    UIView *lastMarginView = nil;
    
    CGFloat width = self.dayViewSize.width;
    CGFloat height = self.dayViewSize.height;
    
    for (int i = 0; i < 7; ++i) {
        NSInteger index = (i + _firstWeekday - 1) % 7;
        
        UILabel *label = [UILabel new];
        label.backgroundColor = [UIColor clearColor];
        label.translatesAutoresizingMaskIntoConstraints = NO;
        label.font = [UIFont boldSystemFontOfSize:10];
        label.textColor = [UIColor whiteColor];
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
    }
    
    [view addConstraint:[NSLayoutConstraint constraintWithItem:lastLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
    
    [self addSubview:view];
    
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(view);

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[view]-0-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:viewsDictionary]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[view(height)]"
                                                                 options:0
                                                                 metrics:@{@"height":@(_weekdaySymbolLabelHeight)}
                                                                   views:viewsDictionary]];
}

- (void)createMonthViews
{
    NSMutableArray *viewList = [NSMutableArray array];
    
    NSInteger era = _currentEra;
    NSInteger year = _currentYear;
    NSInteger month = _currentMonth;
    
    [self previousMonth:&year month:&month era:&era];
    
    JFCalendarMonthView *monthView = [JFCalendarMonthView new];
    [monthView setEra:era year:year month:month];
    [self.monthViewContainer addSubview:monthView];
    [viewList addObject:monthView];
    
    monthView = [JFCalendarMonthView new];
    monthView.delegate = self;
    [monthView setEra:_currentEra year:_currentYear month:_currentMonth];
    [self.monthViewContainer addSubview:monthView];
    [viewList addObject:monthView];
    
    era = _currentEra;
    year = _currentYear;
    month = _currentMonth;
    
    [self nextMonth:&year month:&month era:&era];

    monthView = [JFCalendarMonthView new];
    [monthView setEra:era year:year month:month];
    [self.monthViewContainer addSubview:monthView];
    [viewList addObject:monthView];
    
    self.monthViewList = viewList;
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

    if (_scrollDirection == JSCalendarViewScrollHorizontalDirection) {
        self.monthViewContainer.contentSize = CGSizeMake(size.width * 3, size.height);
        [self.monthViewContainer setContentOffset:CGPointMake(size.width, 0)];
    }
    else {
        self.monthViewContainer.contentSize = CGSizeMake(size.width, size.height * 3);
        [self.monthViewContainer setContentOffset:CGPointMake(0, size.height)];
    }
    
    int i = 0;
    for (UIView *monthView in self.monthViewList) {
        if (_scrollDirection == JSCalendarViewScrollHorizontalDirection) {
            monthView.frame = CGRectMake(i * size.width, 0, size.width, size.height);
        }
        else {
            monthView.frame = CGRectMake(0, i * size.height, size.width, size.height);
        }
        
        ++i;
    }
}

- (void)rearrangeCalendarMonthViews
{
    NSInteger page = self.monthViewContainer.contentOffset.x / self.monthViewContainer.frame.size.width;
    if (_scrollDirection == JSCalendarViewScrollVerticalDirection) {
        page = self.monthViewContainer.contentOffset.y / self.monthViewContainer.frame.size.height;
    }
    
    if (page == 1) return;
    
    if (page == 0) {
        // previous
        [self rightShiftArray:self.monthViewList];
    }
    else if (page == 2) {
        // next
        [self leftShiftArray:self.monthViewList];
    }
    
    JFCalendarMonthView *monthView = [self.monthViewList objectAtIndex:1];
    monthView.delegate = self;
    NSInteger era = monthView.era;
    NSInteger year = monthView.year;
    NSInteger month = monthView.month;
    
    if (page == 0) {
        // previous
        monthView = [self.monthViewList objectAtIndex:0];
        monthView.selectedDate = nil;
        monthView.delegate = self;
        [self previousMonth:&year month:&month era:&era];
        [monthView setEra:era year:year month:month];
    }
    else if (page == 2) {
        // next
        monthView = [self.monthViewList objectAtIndex:2];
        monthView.selectedDate = nil;
        monthView.delegate = self;
        [self nextMonth:&year month:&month era:&era];
        [monthView setEra:era year:year month:month];
    }
    
    [self repostionMonthViews];
}

- (void)setScrollDirection:(JSCalendarViewScrollDirection)scrollDirection
{
    _scrollDirection = scrollDirection;
    
    [self repostionMonthViews];
}

- (void)setDayViewSize:(CGSize)dayViewSize
{
    _dayViewSize = dayViewSize;
    
    for (JFCalendarMonthView *monthView in self.monthViewList) {
        monthView.dayViewSize = dayViewSize;
    }
}

- (void)setDayViewEdgeInsets:(UIEdgeInsets)dayViewEdgeInsets
{
    _dayViewEdgeInsets = dayViewEdgeInsets;
    
    for (JFCalendarMonthView *monthView in self.monthViewList) {
        monthView.dayViewEdgeInsets = dayViewEdgeInsets;
    }
}

- (NSDate *)selectedDate
{
    JFCalendarMonthView *monthView = [self.monthViewList objectAtIndex:1];
    return monthView.selectedDate;
}

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

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self repostionMonthViews];
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
    if (self.delegate && [self.delegate respondsToSelector:@selector(calendarView:didSelectDate:)]) {
        [self.delegate calendarView:self didSelectDate:date];
    }
}

- (UIView *)monthView:(JFCalendarMonthView *)monthView
   accessoryViewOnDay:(NSDate *)date
  reusedAccessoryView:(UIView *)reusedView
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(calendarView:accessoryViewOnDay:reusedAccessoryView:)]) {
        return [self.delegate calendarView:self accessoryViewOnDay:date reusedAccessoryView:reusedView];
    }
    else {
        return nil;
    }
}

@end
