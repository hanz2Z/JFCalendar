//
//  JFCalendarMonthView.h
//  JFCalendar
//
//  Created by zhaoyan on 2019/8/14.
//  Copyright © 2019年 zhaoyan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JFCalendarMonthView;

@protocol JFCalendarMonthViewDelegate <NSObject>

@optional

- (void)monthView:(JFCalendarMonthView *_Nonnull)monthView didSelectDate:(NSDate *_Nonnull)date;

- (UIView *_Nonnull)monthView:(JFCalendarMonthView *_Nullable)monthView
   accessoryViewOnDay:(NSDate *_Nonnull)date
  reusedAccessoryView:(UIView *_Nonnull)reusedView;

@end

NS_ASSUME_NONNULL_BEGIN

@interface JFCalendarMonthView : UIView

@property (nonatomic, assign, readonly) NSUInteger era;
@property (nonatomic, assign, readonly) NSUInteger year;
@property (nonatomic, assign, readonly) NSUInteger month;
@property (nonatomic, assign, readonly) NSUInteger daysCount;

@property (nonatomic, assign) NSUInteger firstWeekday;
@property (nonatomic, assign) BOOL showDaysInOtherMonth;

@property (nonatomic, strong) UIColor *todayTextColor;
@property (nonatomic, strong) UIColor *dayTextColor;

@property (nonatomic, strong) UIColor *todaySelectedTextColor;
@property (nonatomic, strong) UIColor *daySelectedTextColor;

@property (nonatomic, strong) UIColor *todaySelectedBackgroundColor;
@property (nonatomic, strong) UIColor *daySelectedBackgroundColor;

@property (nonatomic, assign) CGSize dayViewSize;
@property (nonatomic, assign) UIEdgeInsets dayViewEdgeInsets;

@property (nonatomic, assign) BOOL daysInOtherMonthHidden;

@property (nonatomic, strong, nullable) NSDate *selectedDate;

@property (nonatomic, weak) id<JFCalendarMonthViewDelegate> delegate;

- (void)setEra:(NSUInteger)era year:(NSUInteger)year month:(NSUInteger)month;
- (void)setYear:(NSUInteger)year month:(NSUInteger)month;

- (void)reloadAccessories;

- (void)reloadAccessorieOnDate:(NSDate *)date;

@end

NS_ASSUME_NONNULL_END
