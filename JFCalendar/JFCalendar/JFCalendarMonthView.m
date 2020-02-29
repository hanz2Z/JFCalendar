//
//  JFCalendarMonthView.m
//  JFCalendar
//
//  Created by zhaoyan on 2019/8/14.
//  Copyright © 2019年 zhaoyan. All rights reserved.
//

#import "JFCalendarMonthView.h"

@interface JFCalendarMonthView () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) NSArray *dayList;
@property (nonatomic, weak) UICollectionView *daysView;

@property (nonatomic, assign) NSInteger selectedIndex;

@end

@implementation JFCalendarMonthView

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
    self.dayTextColor = [UIColor whiteColor];
    self.todayTextColor = [UIColor redColor];
    
    self.daySelectedTextColor = [UIColor blackColor];
    self.todaySelectedTextColor = [UIColor whiteColor];
    
    self.daySelectedBackgroundColor = [UIColor whiteColor];
    self.todaySelectedBackgroundColor = [UIColor redColor];
    
    self.dayViewSize = CGSizeMake(40, 40);
    
    _daysInOtherMonthHidden = YES;
    _firstWeekday = 2;
    NSDate *date = [NSDate date];
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitEra|NSCalendarUnitYear|NSCalendarUnitMonth fromDate:date];
    
    [self setEra:components.era year:components.year month:components.month];
}

- (void)initSubview
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    
    // 根据itemSize和间隔去更新collectionView的frame
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.showsVerticalScrollIndicator = NO;
    collectionView.allowsMultipleSelection = NO;
    collectionView.scrollEnabled = NO;
    [self addSubview:collectionView];
    self.daysView = collectionView;
    
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(collectionView);
    
    [self addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[collectionView]-0-|"
                                             options:0
                                             metrics:nil
                                               views:viewsDictionary]];
    [self addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[collectionView]-0-|"
                                             options:0
                                             metrics:nil
                                               views:viewsDictionary]];
    
    [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"DayCellID"];
}

- (void)setEra:(NSUInteger)era year:(NSUInteger)year month:(NSUInteger)month
{
    _era = era;
    _year = year;
    _month = month;
    _selectedIndex = -1;
    
    [self updateDays];
}

- (void)setYear:(NSUInteger)year month:(NSUInteger)month
{
    _era = 1;
    _year = year;
    _month = month;
    _selectedIndex = -1;
    
    [self updateDays];
}

- (void)reloadAccessories
{
    [self.daysView reloadData];
}

- (void)reloadAccessorieOnDate:(NSDate *)date
{
    NSInteger index = -1;
    for (NSDate *d in self.dayList) {
        if ([self sameDay:date andDate:d]) {
            index = [self.dayList indexOfObject:d];
        }
    }
    
    if (index != -1) {
        [self.daysView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]]];
    }
}

- (void)setDayViewSize:(CGSize)dayViewSize
{
    _dayViewSize = dayViewSize;
    
    [self.daysView reloadData];
}

- (void)setDayViewEdgeInsets:(UIEdgeInsets)dayViewEdgeInsets
{
    _dayViewEdgeInsets = dayViewEdgeInsets;
    
    [self.daysView reloadData];
}

- (void)updateDays
{
    [[NSCalendar currentCalendar] setFirstWeekday:_firstWeekday];

    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setDay:1];
    [components setMonth:_month];
    [components setYear:_year];
    [components setEra:_era];
    
    NSDate *date = [[NSCalendar currentCalendar] dateFromComponents:components];
    NSUInteger count = [[NSCalendar currentCalendar] rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date].length;
    _daysCount = count;
    
    NSInteger numInWeekOfFirstDayInMonth = [[NSCalendar currentCalendar] ordinalityOfUnit:NSCalendarUnitWeekday inUnit:NSCalendarUnitWeekOfMonth forDate:date];
    
    NSUInteger dayDiff = _firstWeekday - 1;

    if (numInWeekOfFirstDayInMonth < _firstWeekday) {
        numInWeekOfFirstDayInMonth += 7;
    }
    numInWeekOfFirstDayInMonth -= dayDiff;
    
    NSMutableArray *dayList = [NSMutableArray array];
    
    NSDate *d = [date dateByAddingTimeInterval:-86400];
    for (int i = 0; i < numInWeekOfFirstDayInMonth-1; ++i) {
        [dayList insertObject:d atIndex:0];
        d = [d dateByAddingTimeInterval:-86400];
    }
    
    d = date;
    for (int i = 0; i < count; ++i) {
        [dayList addObject:d];
        d = [d dateByAddingTimeInterval:86400];
    }

    NSUInteger year = _year;
    NSUInteger month = _month;
    NSUInteger era = _era;
    
    [self nextMonth:&year month:&month era:&era];
    [components setDay:1];
    [components setMonth:month];
    [components setYear:year];
    [components setEra:era];
    
    date = [[NSCalendar currentCalendar] dateFromComponents:components];
    numInWeekOfFirstDayInMonth = [[NSCalendar currentCalendar] ordinalityOfUnit:NSCalendarUnitWeekday inUnit:NSCalendarUnitWeekOfMonth forDate:date];
    
    if (numInWeekOfFirstDayInMonth != _firstWeekday) {
        if (numInWeekOfFirstDayInMonth < _firstWeekday) {
            numInWeekOfFirstDayInMonth += 7;
        }
        numInWeekOfFirstDayInMonth -= dayDiff;
        
        d = date;
        for (NSInteger i = numInWeekOfFirstDayInMonth; i <=7; ++i) {
            [dayList addObject:d];
            d = [d dateByAddingTimeInterval:86400];
        }
    }
    
    self.dayList = dayList;
    
    [self.daysView reloadData];
}

- (void)nextMonth:(NSUInteger *)year month:(NSUInteger *)month era:(NSUInteger *)era
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
                *month = 1;
            }
        }
    }
    else {
        *month = *month + 1;
    }
}

- (BOOL)sameDay:(NSDate *)date1 andDate:(NSDate *)date2
{
    return [[NSCalendar currentCalendar] isDate:date1 inSameDayAsDate:date2];
}

- (BOOL)sameMonth:(NSDate *)date
{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitEra|NSCalendarUnitYear|NSCalendarUnitMonth fromDate:date];
    if (components.era == _era && components.year == _year && components.month == _month) {
        return YES;
    }
    else {
        return NO;
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dayList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DayCellID" forIndexPath:indexPath];
    NSDate *date = [self.dayList objectAtIndex:indexPath.row];
    NSDate *today = [NSDate date];
    
    BOOL isToday = [self sameDay:today andDate:date];
    BOOL sameMonth = [self sameMonth:date];
    
    CGFloat width = self.dayViewSize.width;
    CGFloat height = self.dayViewSize.height;
    
    CGFloat top = self.dayViewEdgeInsets.top;
    CGFloat left = self.dayViewEdgeInsets.left;
    CGFloat bottom = self.dayViewEdgeInsets.bottom;
    CGFloat right = self.dayViewEdgeInsets.right;
    
    CGFloat length = MIN(width-left-right, height-top-bottom);
    
    UIView *dayContainer = [cell.contentView viewWithTag:1024];
    if (!dayContainer) {
        dayContainer = [UIView new];
        dayContainer.tag = 1024;
        dayContainer.translatesAutoresizingMaskIntoConstraints = NO;
        [cell.contentView addSubview:dayContainer];
        
        NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(dayContainer);
        
        [cell.contentView addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-left-[dayContainer]-right-|"
                                                 options:0
                                                 metrics:@{@"width":@(width),@"left":@(left),@"right":@(right)}
                                                   views:viewsDictionary]];
        [cell.contentView addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-top-[dayContainer]-bottom-|"
                                                 options:0
                                                 metrics:@{@"height":@(height),@"top":@(top), @"bottom":@(bottom)}
                                                   views:viewsDictionary]];
        
        UIView *selectedBGView = [UIView new];
        selectedBGView.translatesAutoresizingMaskIntoConstraints = NO;
        selectedBGView.backgroundColor = isToday ? self.todaySelectedBackgroundColor : self.daySelectedBackgroundColor;
        selectedBGView.layer.cornerRadius = length/2;
        selectedBGView.tag = 1025;
        [dayContainer addSubview:selectedBGView];
        if (indexPath.row == self.selectedIndex) {
            selectedBGView.hidden = NO;
        }
        else {
            selectedBGView.hidden = YES;
        }
        
        viewsDictionary = NSDictionaryOfVariableBindings(selectedBGView);
        
        [dayContainer addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[selectedBGView]-0-|"
                                                 options:0
                                                 metrics:nil
                                                   views:viewsDictionary]];
        [dayContainer addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[selectedBGView]-0-|"
                                                 options:0
                                                 metrics:nil
                                                   views:viewsDictionary]];
        
        UILabel *label = [UILabel new];
        label.translatesAutoresizingMaskIntoConstraints = NO;
        label.textAlignment = NSTextAlignmentCenter;
        label.tag = 1026;
        [dayContainer addSubview:label];
        
        NSLayoutConstraint *hConstraint = [NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:dayContainer attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
        
        NSLayoutConstraint *vConstraint = [NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:dayContainer attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
        
        [dayContainer addConstraint:hConstraint];
        [dayContainer addConstraint:vConstraint];
    }

    UILabel *label = (UILabel *)[dayContainer viewWithTag:1026];
    
    if (indexPath.row == self.selectedIndex) {
        if (isToday) {
            label.textColor = self.todaySelectedTextColor;
        }
        else {
            label.textColor = self.daySelectedTextColor;
        }
    }
    else {
        if (isToday) {
            label.textColor = self.todayTextColor;
        }
        else {
            label.textColor = self.dayTextColor;
        }
    }
    
    if (self.daysInOtherMonthHidden && !sameMonth) {
        label.text = nil;
    }
    else {
        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay fromDate:date];
        label.text = [@(components.day) stringValue];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(monthView:accessoryViewOnDay:reusedAccessoryView:)]) {
            UIView *reusedAccessory = [cell.contentView viewWithTag:1027];

            UIView *view = [self.delegate monthView:self accessoryViewOnDay:date reusedAccessoryView:reusedAccessory];
            view.tag = 1027;
            if (view) {
                [cell.contentView addSubview:view];
            }
        }
    }
    
    return cell;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDate *date = [self.dayList objectAtIndex:indexPath.row];
    BOOL sameMonth = [self sameMonth:date];
    
    if (self.daysInOtherMonthHidden && !sameMonth) {
        return NO;
    }
    else {
        return YES;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.dayViewSize;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(nonnull UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(nonnull UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    CGFloat totalWidth = collectionView.frame.size.width;
    CGFloat size = self.dayViewSize.width;
    CGFloat spacing = (totalWidth - size * 7)/6;
    return spacing;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.selectedIndex != -1) {
        UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:self.selectedIndex inSection:0]];
        UILabel *label = (UILabel *)[cell viewWithTag:1026];
        
        NSDate *date = [self.dayList objectAtIndex:indexPath.row];
        NSDate *today = [NSDate date];
        BOOL sameday = [self sameDay:date andDate:today];
        
        if (sameday) {
            label.textColor = self.todayTextColor;
        }
        else {
            label.textColor = self.dayTextColor;
        }
        
        UIView *bgView = [cell viewWithTag:1025];
        bgView.hidden = YES;
    }
    
    self.selectedIndex = [indexPath row];

    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    UILabel *label = (UILabel *)[cell viewWithTag:1026];
    
    NSDate *date = [self.dayList objectAtIndex:indexPath.row];
    NSDate *today = [NSDate date];
    BOOL sameday = [self sameDay:date andDate:today];
    if (sameday) {
        label.textColor = self.todaySelectedTextColor;
    }
    else {
        label.textColor = self.daySelectedTextColor;
    }
    
    UIView *bgView = [cell viewWithTag:1025];
    bgView.hidden = NO;
    
    _selectedDate = date;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(monthView:didSelectDate:)]) {
        [self.delegate monthView:self didSelectDate:date];
    }
}

@end
