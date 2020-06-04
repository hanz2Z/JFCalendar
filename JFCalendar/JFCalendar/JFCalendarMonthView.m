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

@property (nonatomic, weak) UILabel *monthSymbolLabel;

@property (nonatomic, assign) BOOL needReload;

@property (nonatomic, strong) NSLayoutConstraint *monthSymbolHConstraint;

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

- (CGSize)intrinsicContentSize
{
    NSInteger rowCount = (self.dayList.count + 6) / 7;
    return CGSizeMake(UIViewNoIntrinsicMetric, rowCount * self.dayViewSize.height + self.monthSymbolHeight);
}

- (void)initData
{
    self.monthSymbolFont = [UIFont boldSystemFontOfSize:17];
    self.monthSymbolColor = [UIColor colorWithRed:0.235 green:0.275 blue:0.31 alpha:1];
    self.monthSymbolHeight = 40;
    
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
    UIView *monthView = [UIView new];
    monthView.translatesAutoresizingMaskIntoConstraints = NO;
    monthView.clipsToBounds = YES;

    UILabel *monthLabel = [UILabel new];
    monthLabel.translatesAutoresizingMaskIntoConstraints = NO;
    monthLabel.font = self.monthSymbolFont;
    monthLabel.textColor = self.monthSymbolColor;
    [monthView addSubview:monthLabel];

    self.monthSymbolLabel = monthLabel;

    [self addSubview:monthView];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    
    // 根据itemSize和间隔去更新collectionView的frame
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.showsVerticalScrollIndicator = NO;
    collectionView.allowsMultipleSelection = NO;
    collectionView.scrollEnabled = NO;
    collectionView.backgroundColor = [UIColor clearColor];
    [self addSubview:collectionView];
    self.daysView = collectionView;
    
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(monthView, monthLabel, collectionView);
    
    [monthView addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-12-[monthLabel]"
                                             options:0
                                             metrics:nil
                                               views:viewsDictionary]];

    [monthView addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[monthLabel]"
                                             options:0
                                             metrics:nil
                                               views:viewsDictionary]];
    
    NSLayoutConstraint *c = [NSLayoutConstraint constraintWithItem:monthLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:monthView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
    c.active = YES;

    [self addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[monthView(40)]"
                                             options:0
                                             metrics:nil
                                               views:viewsDictionary]];
    
    c = [NSLayoutConstraint constraintWithItem:monthView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:_monthSymbolHeight];
    c.active = YES;
    self.monthSymbolHConstraint = c;
    
    [self addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[monthView]-0-|"
                                             options:0
                                             metrics:nil
                                               views:viewsDictionary]];
    
    [self addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[collectionView]-0-|"
                                             options:0
                                             metrics:nil
                                               views:viewsDictionary]];
    [self addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:[monthView]-0-[collectionView]-0-|"
                                             options:0
                                             metrics:nil
                                               views:viewsDictionary]];
    
    c = [NSLayoutConstraint constraintWithItem:collectionView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:monthView attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    c.active = YES;
    
    [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"DayCellID"];
}

- (void)setEra:(NSUInteger)era year:(NSUInteger)year month:(NSUInteger)month
{
    _era = era;
    _year = year;
    _month = month;
    _selectedDate = nil;
    
    NSDateFormatter* fmt = [[NSDateFormatter alloc] init];
    fmt.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    NSArray *monthNameList = fmt.shortMonthSymbols;
    
    NSString *monthName = [monthNameList objectAtIndex:(month-1)];
    if (month == 1) {
        monthName = [NSString stringWithFormat:@"%lu年%@", (unsigned long)year, monthName];
    }
    
    self.monthSymbolLabel.text = monthName;
    
    [self updateDays];
    
    [self invalidateIntrinsicContentSize];
}

- (void)setYear:(NSUInteger)year month:(NSUInteger)month
{
    [self setEra:1 year:year month:month];
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

- (void)scheduleReloading
{
    _needReload = YES;
    //__weak typeof(self) ws = self;
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(reloadIfNeeded) withObject:nil afterDelay:0];
}

- (void)reloadIfNeeded
{
    if (_needReload) {
        [self.daysView reloadData];
        _needReload = NO;
    }
}

- (void)setDayViewSize:(CGSize)dayViewSize
{
    _dayViewSize = dayViewSize;
    
    [self invalidateIntrinsicContentSize];
    
    [self scheduleReloading];
}

- (void)setDayTextViewEdgeInsets:(UIEdgeInsets)dayViewEdgeInsets
{
    _dayTextViewEdgeInsets = dayViewEdgeInsets;
    
    [self scheduleReloading];
}

- (void)setSelectedDate:(NSDate *)selectedDate
{
    NSDate *date = _selectedDate;
    _selectedDate = selectedDate;
    if (date) {
        [self reloadCellOnDay:date];
    }
    
    if (selectedDate) {
        [self reloadCellOnDay:_selectedDate];
    }
}

- (void)setDayTextColor:(UIColor *)value
{
    _dayTextColor = value;
    
    [self scheduleReloading];
}

- (void)setTodayTextColor:(UIColor *)value
{
    _todayTextColor = value;
    
    [self scheduleReloading];
}

- (void)setDaySelectedTextColor:(UIColor *)value
{
    _daySelectedTextColor = value;
    
    [self scheduleReloading];
}

- (void)setTodaySelectedTextColor:(UIColor *)value
{
    _todaySelectedTextColor = value;
    
    [self scheduleReloading];
}

- (void)setDaySelectedBackgroundColor:(UIColor *)value
{
    _daySelectedBackgroundColor = value;
    
    [self scheduleReloading];
}

- (void)setTodaySelectedBackgroundColor:(UIColor *)value
{
    _todaySelectedBackgroundColor = value;
    
    [self scheduleReloading];
}

- (void)setMonthSymbolHeight:(CGFloat)value
{
    _monthSymbolHeight = value;
    self.monthSymbolHConstraint.constant = value;
    [self invalidateIntrinsicContentSize];
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
    
    NSDateComponents *weekComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitWeekday fromDate:date];
    NSInteger numInWeekOfFirstDayInMonth = weekComponents.weekday;
    
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
    weekComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitWeekday fromDate:date];
    numInWeekOfFirstDayInMonth = weekComponents.weekday;
    
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

- (void)reloadCellOnDay:(NSDate *)date
{
    NSInteger row = 0;
    for (NSDate *d in self.dayList) {
        if ([self sameDay:date andDate:d]) {
            break;
        }
        
        ++row;
    }
    
    if (row < self.dayList.count) {
        [self.daysView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:0]]];
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
    BOOL sameDayWithSelected = NO;
    if (self.selectedDate) {
        sameDayWithSelected = [self sameDay:date andDate:self.selectedDate];
    }
    
    CGFloat width = self.dayViewSize.width;
    CGFloat height = self.dayViewSize.height;
    
    CGFloat top = self.dayTextViewEdgeInsets.top;
    CGFloat left = self.dayTextViewEdgeInsets.left;
    CGFloat bottom = self.dayTextViewEdgeInsets.bottom;
    CGFloat right = self.dayTextViewEdgeInsets.right;
    
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
        selectedBGView.layer.cornerRadius = length/2;
        selectedBGView.tag = 1025;
        [dayContainer addSubview:selectedBGView];
        
        if (sameDayWithSelected) {
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
    
    UIView *selectedBGView = [cell viewWithTag:1025];
    selectedBGView.backgroundColor = isToday ? self.todaySelectedBackgroundColor : self.daySelectedBackgroundColor;

    if (sameDayWithSelected) {
        selectedBGView.hidden = NO;
        
        if (isToday) {
            label.textColor = self.todaySelectedTextColor;
        }
        else {
            label.textColor = self.daySelectedTextColor;
        }
    }
    else {
        selectedBGView.hidden = YES;
        
        if (isToday) {
            label.textColor = self.todayTextColor;
        }
        else {
            label.textColor = self.dayTextColor;
        }
    }
    
    UIView *reusedAccessory = [cell.contentView viewWithTag:1027];
    [reusedAccessory removeFromSuperview];

    if (self.daysInOtherMonthHidden && !sameMonth) {
        label.text = nil;
    }
    else {
        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay fromDate:date];
        label.text = [@(components.day) stringValue];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(monthView:accessoryViewOnDay:reusedAccessoryView:)]) {
            if (sameMonth || !_daysInOtherMonthHidden) {
                UIView *view = [self.delegate monthView:self accessoryViewOnDay:date reusedAccessoryView:reusedAccessory];
                view.tag = 1027;
                if (view) {
                    [cell.contentView addSubview:view];
                }
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
    CGFloat totalWidth = collectionView.frame.size.width-1;
    CGFloat size = self.dayViewSize.width;
    CGFloat spacing = (totalWidth - size * 7)/6;
    return spacing;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDate *newSelectedDate = [self.dayList objectAtIndex:indexPath.row];

    if (self.selectedDate) {
        if (![self sameDay:newSelectedDate andDate:self.selectedDate]) {
            self.selectedDate = newSelectedDate;
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(monthView:didSelectDate:)]) {
                [self.delegate monthView:self didSelectDate:newSelectedDate];
            }
        }
    }
    else {
        self.selectedDate = newSelectedDate;
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(monthView:didSelectDate:)]) {
            [self.delegate monthView:self didSelectDate:newSelectedDate];
        }
    }
}

@end
