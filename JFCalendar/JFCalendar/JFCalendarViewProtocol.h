//
//  JFCalendarViewProtocol.h
//  JFCalendar
//
//  Created by 赵岩 on 2020/5/16.
//  Copyright © 2020 zhaoyan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JFCalendar/JFCalendarViewDelegate.h>

NS_ASSUME_NONNULL_BEGIN

@protocol JFCalendarViewProtocol <NSObject>

@required

@property (nonatomic, assign, readonly) NSInteger currentEra;
@property (nonatomic, assign, readonly) NSInteger currentYear;
@property (nonatomic, assign, readonly) NSInteger currentMonth;

@property (nonatomic, strong) UIFont *weekdaySymbolFont;
@property (nonatomic, strong) UIColor *weekdaySymbolColor;
@property (nonatomic, assign) CGFloat weekdaySymbolLabelHeight;

@property (nonatomic, strong) UIFont *monthSymbolFont;
@property (nonatomic, strong) UIColor *monthSymbolColor;
@property (nonatomic, assign) CGFloat monthSymbolHeight;

@property (nonatomic, strong) UIColor *todayTextColor;
@property (nonatomic, strong) UIColor *dayTextColor;

@property (nonatomic, strong) UIColor *todaySelectedTextColor;
@property (nonatomic, strong) UIColor *daySelectedTextColor;

@property (nonatomic, strong) UIColor *todaySelectedBackgroundColor;
@property (nonatomic, strong) UIColor *daySelectedBackgroundColor;

@property (nonatomic, assign) NSUInteger firstWeekday;

@property (nonatomic, assign) CGSize dayViewSize;
@property (nonatomic, assign) UIEdgeInsets dayTextViewEdgeInsets;

@property (nonatomic, strong) NSDate *selectedDate;

@property (nonatomic, weak) id<JFCalendarViewDelegate> delegate;

- (void)reloadAccessories;

- (void)reloadAccessorieOnDate:(NSDate *)date;

@end

NS_ASSUME_NONNULL_END
