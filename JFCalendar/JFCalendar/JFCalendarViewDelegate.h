//
//  JFCalendarViewDelegate.h
//  JFCalendar
//
//  Created by 赵岩 on 2020/5/16.
//  Copyright © 2020 zhaoyan. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol JFCalendarViewProtocol;

@protocol JFCalendarViewDelegate <NSObject>

@optional

- (void)calendarView:(id<JFCalendarViewProtocol>)calendarView didDisplayMonth:(NSInteger)month inYear:(NSInteger)year;

- (void)calendarView:(id<JFCalendarViewProtocol>)calendarView didSelectDate:(NSDate *_Nonnull)date;

- (UIView *_Nullable)calendarView:(id<JFCalendarViewProtocol>)calendarView
      accessoryViewOnDay:(NSDate *)date
     reusedAccessoryView:(UIView *_Nonnull)reusedView;

@end

NS_ASSUME_NONNULL_END
