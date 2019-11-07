//
//  JFCalendarView.h
//  JFCalendar
//
//  Created by zhaoyan on 2019/8/14.
//  Copyright © 2019年 zhaoyan. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    JSCalendarViewScrollHorizontalDirection,
    JSCalendarViewScrollVerticalDirection,
} JSCalendarViewScrollDirection;

@class JFCalendarView;

@protocol JFCalendarViewDelegate <NSObject>

@optional

- (void)calendarViewDidChange:(JFCalendarView *_Nonnull)calendarView;

- (void)calendarView:(JFCalendarView *_Nonnull)calendarView didSelectDate:(NSDate *_Nonnull)date;

- (UIView *_Nullable)calendarView:(JFCalendarView *_Nonnull)calendarView
      accessoryViewOnDay:(NSDate *_Nonnull)date
     reusedAccessoryView:(UIView *_Nonnull)reusedView;

@end

NS_ASSUME_NONNULL_BEGIN

@interface JFCalendarView : UIView

@property (nonatomic, assign, readonly) NSInteger currentEra;
@property (nonatomic, assign, readonly) NSInteger currentYear;
@property (nonatomic, assign, readonly) NSInteger currentMonth;

@property (nonatomic, assign) CGFloat weekdaySymbolLabelHeight;

@property (nonatomic, assign) NSUInteger firstWeekday;

@property (nonatomic, assign) JSCalendarViewScrollDirection scrollDirection;

@property (nonatomic, assign) CGSize dayViewSize;
@property (nonatomic, assign) UIEdgeInsets dayViewEdgeInsets;

@property (nonatomic, weak) id<JFCalendarViewDelegate> delegate;

@property (nonatomic, strong) NSDate *selectedDate;

- (void)reloadAccessories;

- (void)reloadAccessorieOnDate:(NSDate *)date;

@end

NS_ASSUME_NONNULL_END
