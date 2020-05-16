//
//  JFVerticalCalendarView.m
//  JFCalendar
//
//  Created by 赵岩 on 2020/5/16.
//  Copyright © 2020 zhaoyan. All rights reserved.
//

#import "JFVerticalCalendarView.h"
#import "JFCalendarMonthView.h"

#define kHalfYearCount (50)

@interface JFVerticalCalendarView () <UICollectionViewDataSource, UICollectionViewDelegate, JFCalendarMonthViewDelegate>

@property (nonatomic, weak) UICollectionView *collectionView;

@property (nonatomic, weak) UIView *weekdaySymbolContainer;
@property (nonatomic, strong) NSArray *weekdaySymbolLabels;

@property (nonatomic, weak) NSLayoutConstraint *weekSymbolContainerHeightConstraint;

@property (nonatomic, assign) BOOL needLocationToCurrentMonth;

@end

@implementation JFVerticalCalendarView

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
    
    if (self.needLocationToCurrentMonth) {
        UICollectionView *collectionView = self.collectionView;
        
        [collectionView layoutIfNeeded];
        
        CGFloat height = 0;
        for (NSInteger i = self.currentYear - kHalfYearCount; i < self.currentYear; ++i) {
            for (NSInteger j = 1; j <= 12; ++j) {
                height += [self heightForYear:i month:j];
            }
        }
        
        for (NSInteger j = 1; j < self.currentMonth; ++j) {
            height += [self heightForYear:self.currentYear month:j];
        }
                
        [collectionView scrollRectToVisible:CGRectMake(0, height, collectionView.frame.size.width, collectionView.frame.size.height) animated:NO];
        
        self.needLocationToCurrentMonth = NO;
    }
    
    __weak typeof(self) ws = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [ws.collectionView.collectionViewLayout invalidateLayout];
    });
}

- (void)initData
{
    self.weekdaySymbolFont = [UIFont boldSystemFontOfSize:10];
    self.weekdaySymbolColor = [UIColor lightGrayColor];
    self.weekdaySymbolLabelHeight = 60;
    
    self.monthSymbolFont = [UIFont systemFontOfSize:17];
    self.monthSymbolColor = [UIColor colorWithRed:.235 green:.275 blue:.31 alpha:1];
    self.monthSymbolHeight = 50;
    
    self.dayViewSize = CGSizeMake(40, 50);
    
    self.dayTextColor = [UIColor colorWithRed:.2 green:.2 blue:.2 alpha:1];
    self.daySelectedTextColor = [UIColor whiteColor];
    
    self.todayTextColor = [UIColor colorWithRed:.235 green:.486 blue:.988 alpha:1];
    self.todaySelectedTextColor = [UIColor whiteColor];
    
    self.daySelectedBackgroundColor = [UIColor colorWithRed:.235 green:.486 blue:.988 alpha:1];
    self.todaySelectedBackgroundColor = [UIColor colorWithRed:.235 green:.486 blue:.988 alpha:1];
    
    self.firstWeekday = 2;

    NSDate *today = [NSDate date];
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitEra|NSCalendarUnitYear|NSCalendarUnitMonth fromDate:today];
    
    currentEra = components.era;
    currentYear = components.year;
    currentMonth = components.month;
}

- (void)initSubview
{
    self.clipsToBounds = YES;
    
    [self createWeekLabelView];
    UIView *weekSymbolContainer = self.weekdaySymbolContainer;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    // 根据itemSize和间隔去更新collectionView的frame
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.showsVerticalScrollIndicator = NO;
    collectionView.allowsMultipleSelection = NO;
    collectionView.scrollEnabled = YES;
    collectionView.pagingEnabled = NO;
    collectionView.backgroundColor = [UIColor clearColor];
    [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"MonthContainerCell"];
    [self addSubview:collectionView];
    
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(collectionView, weekSymbolContainer);

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[collectionView]-0-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:viewsDictionary]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[weekSymbolContainer]-0-[collectionView]-0-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:viewsDictionary]];
    self.collectionView = collectionView;
    
    self.needLocationToCurrentMonth = YES;
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
        NSInteger index = (i + self.firstWeekday - 1) % 7;
        
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
                                                                   metrics:@{@"height":@(self.weekdaySymbolLabelHeight)}
                                                              views:viewsDictionary];
    
    [self addConstraints:constraints];
    
    for (NSLayoutConstraint *c in constraints) {
        if (c.firstAttribute == NSLayoutAttributeHeight) {
            self.weekSymbolContainerHeightConstraint = c;
            break;
        }
    }
}

- (CGFloat)heightForYear:(NSInteger)year month:(NSInteger)month
{
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setDay:1];
    [components setMonth:month];
    [components setYear:year];
    [components setEra:1];
    
    NSDate *date = [[NSCalendar currentCalendar] dateFromComponents:components];
    NSUInteger count = [[NSCalendar currentCalendar] rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date].length;
            
    NSDateComponents *weekComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitWeekday fromDate:date];
    NSInteger numInWeekOfFirstDayInMonth = weekComponents.weekday;
    
    if (numInWeekOfFirstDayInMonth == 1) {
        count += 6;
    }
    else {
        count += (numInWeekOfFirstDayInMonth - 2);
    }
    
    return (count + 6) / 7 * self.dayViewSize.height + self.monthSymbolHeight;
}

- (BOOL)era:(NSInteger)era year:(NSInteger)year month:(NSInteger)month inSameMonthWithDate:(NSDate *)date
{
    NSInteger e;
    NSInteger y;
    NSInteger m;
    [[NSCalendar currentCalendar] getEra:&e year:&y month:&m day:NULL fromDate:date];
    if (e == era && y == year && m == month) {
        return YES;
    }
    else {
        return NO;
    }
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
    NSArray *array = [self.collectionView visibleCells];
    for (UICollectionViewCell *cell in array) {
        JFCalendarMonthView *monthView = [cell.contentView viewWithTag:64];
        [monthView reloadAccessories];
    }
}

- (void)reloadAccessorieOnDate:(NSDate *)date
{
    NSArray *array = [self.collectionView visibleCells];
    for (UICollectionViewCell *cell in array) {
         JFCalendarMonthView *monthView = [cell.contentView viewWithTag:64];
         if ([self era:monthView.era year:monthView.year month:monthView.month inSameMonthWithDate:date]) {
             [monthView reloadAccessorieOnDate:date];
         }
     }
}

- (void)setDayViewSize:(CGSize)value
{
    dayViewSize = value;
}

- (void)setDayTextViewEdgeInsets:(UIEdgeInsets)value
{
    dayTextViewEdgeInsets = value;
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

    NSArray *array = [self.collectionView visibleCells];
    for (UICollectionViewCell *cell in array) {
        JFCalendarMonthView *monthView = [cell.contentView viewWithTag:64];
        monthView.todayTextColor = value;
    }
}

- (void)setDayTextColor:(UIColor *)value
{
    dayTextColor = value;
    
    NSArray *array = [self.collectionView visibleCells];
    for (UICollectionViewCell *cell in array) {
        JFCalendarMonthView *monthView = [cell.contentView viewWithTag:64];
        monthView.dayTextColor = value;
    }
}

- (void)setDaySelectedTextColor:(UIColor *)value
{
    daySelectedTextColor = value;
    
    NSArray *array = [self.collectionView visibleCells];
    for (UICollectionViewCell *cell in array) {
        JFCalendarMonthView *monthView = [cell.contentView viewWithTag:64];
        monthView.daySelectedTextColor = value;
    }
}

- (void)setTodaySelectedTextColor:(UIColor *)value
{
    todaySelectedTextColor = value;
    
    NSArray *array = [self.collectionView visibleCells];
    for (UICollectionViewCell *cell in array) {
        JFCalendarMonthView *monthView = [cell.contentView viewWithTag:64];
        monthView.todaySelectedTextColor = value;
    }
}

- (void)setTodaySelectedBackgroundColor:(UIColor *)value
{
    todaySelectedBackgroundColor = value;
    
    NSArray *array = [self.collectionView visibleCells];
    for (UICollectionViewCell *cell in array) {
        JFCalendarMonthView *monthView = [cell.contentView viewWithTag:64];
        monthView.todaySelectedBackgroundColor = value;
    }
}

- (void)setDaySelectedBackgroundColor:(UIColor *)value
{
    daySelectedBackgroundColor = value;
    
    NSArray *array = [self.collectionView visibleCells];
    for (UICollectionViewCell *cell in array) {
        JFCalendarMonthView *monthView = [cell.contentView viewWithTag:64];
        monthView.daySelectedBackgroundColor = value;
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return kHalfYearCount * 2 * 12;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MonthContainerCell" forIndexPath:indexPath];
    JFCalendarMonthView *monthView = [cell.contentView viewWithTag:64];
    if (!monthView) {
        monthView = [JFCalendarMonthView new];
        monthView.tag = 64;
        monthView.delegate = self;
        monthView.dayViewSize = self.dayViewSize;
        
        monthView.monthSymbolFont = self.monthSymbolFont;
        monthView.monthSymbolColor = self.monthSymbolColor;
        monthView.monthSymbolHeight = self.monthSymbolHeight;
        
        monthView.todayTextColor = self.todayTextColor;
        monthView.dayTextColor = self.dayTextColor;

        monthView.todaySelectedTextColor = self.todaySelectedTextColor;
        monthView.daySelectedTextColor = self.daySelectedTextColor;

        monthView.todaySelectedBackgroundColor = self.todaySelectedBackgroundColor;
        monthView.daySelectedBackgroundColor = self.daySelectedBackgroundColor;
        
        monthView.translatesAutoresizingMaskIntoConstraints = NO;
        [cell.contentView addSubview:monthView];
        
        NSLayoutConstraint *wc = [NSLayoutConstraint constraintWithItem:monthView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeWidth multiplier:1 constant:0];
        [wc setActive:YES];
        NSLayoutConstraint *hc = [NSLayoutConstraint constraintWithItem:monthView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeHeight multiplier:1 constant:0];
        [hc setActive:YES];
        NSLayoutConstraint *tc = [NSLayoutConstraint constraintWithItem:monthView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeTop multiplier:1 constant:0];
        [tc setActive:YES];
        NSLayoutConstraint *lc = [NSLayoutConstraint constraintWithItem:monthView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
        [lc setActive:YES];
    }
    
    NSInteger row = indexPath.row;
    NSInteger year = row / 12 - kHalfYearCount + self.currentYear;
    NSInteger month = (row + 1) % 12;
    if (month == 0) {
        month = 12;
    }
    
    [monthView setYear:year month:month];
    monthView.dayViewSize = self.dayViewSize;
    monthView.dayTextViewEdgeInsets = self.dayTextViewEdgeInsets;
    if (self.selectedDate && [self era:monthView.era year:monthView.year month:monthView.month inSameMonthWithDate:self.selectedDate]) {
        monthView.selectedDate = self.selectedDate;
    }
    else {
        monthView.selectedDate = nil;
    }
        
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setDay:1];
    [components setMonth:month];
    [components setYear:year];
    [components setEra:1];
    
    NSDate *date = [[NSCalendar currentCalendar] dateFromComponents:components];
    NSUInteger count = [[NSCalendar currentCalendar] rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date].length;
            
    NSDateComponents *weekComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitWeekday fromDate:date];
    NSInteger numInWeekOfFirstDayInMonth = weekComponents.weekday;
    
    if (numInWeekOfFirstDayInMonth == 1) {
        count += 6;
    }
    else {
        count += (numInWeekOfFirstDayInMonth - 2);
    }
        
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(nonnull UICollectionViewCell *)cell forItemAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    if (!self.needLocationToCurrentMonth) {
        JFCalendarMonthView *monthView = [cell.contentView viewWithTag:64];
        [self.delegate calendarView:self didDisplayMonth:monthView.month inYear:monthView.year];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    NSInteger year = row / 12 - kHalfYearCount + self.currentYear;
    NSInteger month = (row + 1) % 12;
    if (month == 0) {
        month = 12;
    }
    
    return CGSizeMake(self.collectionView.bounds.size.width, [self heightForYear:year month:month]);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(nonnull UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(nonnull UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
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
