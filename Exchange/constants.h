//
//  constants.h
//  Exchange
//
//  Created by Max Ostapchuk on 2/22/17.
//  Copyright © 2017 Max Ostapchuk. All rights reserved.
//

#ifndef constants_h
#define constants_h

// COLOR DATA
#define UIColorFromRGB(rgbValue) \
[   UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
    green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
    blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
    alpha:1.0]

#define BACKGROUND_COLOR UIColorFromRGB(0x2E3642)
#define GREEN_COLOR UIColorFromRGB(0x94DD3B)
#define WHITE_COLOR UIColorFromRGB(0xFFFFFF)

#define RATING_UP UIColorFromRGB(0xC3EE8E)
#define RATING_DOWN UIColorFromRGB(0xF36341)

#define CURRENCY_CHANGE_VIEW UIColorFromRGB(0x7C8BA1)

#endif /* constants_h */
