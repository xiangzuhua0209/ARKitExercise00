//
//  ARPreviewViewController.h
//  ARKitClass00
//
//  Created by xiangzuhua on 2018/9/12.
//  Copyright © 2018年 xiangzuhua. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM (NSInteger, ARaddType) {
    ARaddType_plan = 0,
    ARaddType_chire,
    ARaddType_planeCatch,
    ARaddType_planeMove,
    ARaddType_revolution,
    ARaddType_fuCatch,
    ARaddType_other
};

@interface ARPreviewViewController : UIViewController

@property(nonatomic ,assign)ARaddType type;


@end
