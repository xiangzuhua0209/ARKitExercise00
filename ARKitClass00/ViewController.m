//
//  ViewController.m
//  ARKitClass00
//
//  Created by xiangzuhua on 2018/9/12.
//  Copyright © 2018年 xiangzuhua. All rights reserved.
//

#import "ViewController.h"
#import "ARPreviewViewController.h"
#import "SolarSystemViewController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

#pragma mark - event

- (IBAction)addPlanAction:(id)sender {
    [self pushWithType:ARaddType_plan];
}


- (IBAction)addChairAction:(UIButton *)sender {
    [self pushWithType:ARaddType_chire];
}
- (IBAction)planeCatch:(UIButton *)sender {
    [self pushWithType:ARaddType_planeCatch];

}
- (IBAction)planMove:(UIButton *)sender {
    [self pushWithType:ARaddType_planeMove];

}

- (IBAction)revolution:(UIButton *)sender {
    [self pushWithType:ARaddType_revolution];

}
- (IBAction)fuCatch:(UIButton *)sender {
    [self pushWithType:ARaddType_fuCatch];
}

- (IBAction)SolarSystem:(UIButton *)sender {
    SolarSystemViewController *solarVC = [[SolarSystemViewController alloc] init];
    [self presentViewController:solarVC animated:YES completion:^{
        
    }];
}


-(void)pushWithType:(ARaddType )type{
    ARPreviewViewController *vc = [[ARPreviewViewController alloc] init];
    vc.type = type;
    [self presentViewController:vc animated:YES completion:^{
        
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
