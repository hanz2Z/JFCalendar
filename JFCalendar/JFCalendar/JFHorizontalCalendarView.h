//
//  JFHorizontalCalendarView.h
//  JFCalendar
//
//  Created by 赵岩 on 2020/5/16.
//  Copyright © 2020 zhaoyan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JFCalendar/JFCalendarViewProtocol.h>

NS_ASSUME_NONNULL_BEGIN

@interface JFHorizontalCalendarView : UIView<JFCalendarViewProtocol>

@property (nonatomic, assign) BOOL showDaysOnOtherMonths;

@end

NS_ASSUME_NONNULL_END
