//
//  HCWidgetForScripting.m
//  Uebersicht
//
//  Created by Felix Hageloh on 7/1/17.
//  Copyright © 2017 tracesOf. All rights reserved.
//

#import "HCWidgetForScripting.h"
#import "HCDispatcher.h"

static HCDispatcher* dispatcher;

@implementation HCWidgetForScripting

+ (void)initialize {
    if(!dispatcher) {
         dispatcher = [[HCDispatcher alloc] init];
    }
}

-(id)initWithId:(NSString*)widgetId andSettings:(NSDictionary*)settings
{
    self = [super init];
    if (self) {
        _id = widgetId;
        _hidden = [settings[@"hidden"] boolValue];
        _showOnAllScreens = [settings[@"showOnAllScreens"] boolValue];
        _showOnMainScreen = [settings[@"showOnMainScreen"] boolValue];
    }
    return self;
}

- (NSUniqueIDSpecifier *)objectSpecifier {

	return [[NSUniqueIDSpecifier alloc]
        initWithContainerClassDescription: (NSScriptClassDescription *)[NSApp
            classDescription
        ]
        containerSpecifier: nil
        key: @"widgets"
        uniqueID: self.id
    ];
}

- (void)setHidden:(BOOL)hidden
{
    if (_hidden == hidden) {
        return;
    }
    _hidden = hidden;
    [dispatcher
        dispatch: _hidden ? @"WIDGET_SET_TO_HIDE" : @"WIDGET_SET_TO_SHOW"
        withPayload: _id
    ];
}

- (void)setShowOnMainScreen:(BOOL)showOnMainScreen
{
    if (_showOnMainScreen == showOnMainScreen) {
        return;
    }
    _showOnMainScreen = showOnMainScreen;
    [dispatcher
        dispatch: @"WIDGET_SET_TO_MAIN_SCREEN"
        withPayload: _id
    ];
}

- (void)setShowOnAllScreens:(BOOL)showOnAllScreens
{
    if (_showOnAllScreens == showOnAllScreens) {
        return;
    }
    _showOnAllScreens = showOnAllScreens;
    [dispatcher
        dispatch: @"WIDGET_SET_TO_ALL_SCREENS"
        withPayload: _id
    ];
}

@end
