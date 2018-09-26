//
//  ARPreviewViewController.m
//  ARKitClass00
//
//  Created by xiangzuhua on 2018/9/12.
//  Copyright © 2018年 xiangzuhua. All rights reserved.
//

#import "ARPreviewViewController.h"
#import <SceneKit/SceneKit.h>
#import <ARKit/ARKit.h>

@interface ARPreviewViewController()<ARSCNViewDelegate,ARSessionDelegate>

@property(nonatomic,strong)ARConfiguration *configuration;

@property(nonatomic,strong)ARSCNView *scnView;

@property(nonatomic,strong)ARSession *session;

@property(nonatomic, strong)SCNNode *tempNode;


@end

@implementation ARPreviewViewController

#pragma mark - 懒加载
- (ARSCNView *)scnView{
    if (!_scnView) {
        _scnView = [[ARSCNView alloc] initWithFrame:self.view.bounds];
        _scnView.delegate = self;
        _scnView.session = self.session;
    }
    return _scnView;
}

-(ARSession *)session{
    if (!_session) {
        _session = [[ARSession alloc] init];
        _session.delegate = self;

    }
    return _session;
}

-(ARConfiguration *)configuration{
    if (!_configuration) {
        ARWorldTrackingConfiguration *configuration = [[ARWorldTrackingConfiguration alloc] init];
        // 平面捕捉设置为水平平面捕捉
        if (self.type == ARaddType_fuCatch) {
            configuration.detectionImages = [ARReferenceImage referenceImagesInGroupNamed:@"AR Resources" bundle:nil];
        } else {
            configuration.planeDetection = ARPlaneDetectionHorizontal;
        }
        _configuration = configuration;
        _configuration.lightEstimationEnabled = YES;
    }
    return _configuration;
}

#pragma mark - circle

-(void)viewDidLoad{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [self.view addSubview:self.scnView];
    [self.session runWithConfiguration:self.configuration];
    [self addBackButton];

}

-(void)viewDidDisappear:(BOOL)animated{
    
}

#pragma mark - private

-(void)addBackButton{
    UIButton *backButton = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [backButton setTitle:@"返回" forState:(UIControlStateNormal)];
    [backButton setTitleColor:[UIColor redColor] forState:(UIControlStateNormal)];
    backButton.frame = CGRectMake(0, 20, 64, 44);
    [backButton addTarget:self action:@selector(backAction) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:backButton];
}

//获取模型 0--飞机   1--椅子
-(SCNScene *)getSceneWithType:(NSInteger)type{
    
    NSString *sceneModelPath = type == 0?@"Models.scnassets/ship.scn":type == 1?@"Models.scnassets/chair/chair.scn":@"Models.scnassets/vase/vase.scn";
    SCNScene *scene = [SCNScene sceneNamed:sceneModelPath];
    return scene;
}
#pragma mark - event
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (self.type == ARaddType_plan || self.type == ARaddType_chire) {
        SCNScene *scene = [self getSceneWithType:self.type];
        SCNNode *node = scene.rootNode.childNodes[0];
        // 节点，相对于世界原点的位置（也就是相机位置）
        node.position = SCNVector3Make(0, 0, -1);
        [self.scnView.scene.rootNode addChildNode:node];
    }else if(self.type == ARaddType_planeCatch){
        return;
    }else if(self.type == ARaddType_planeMove){
        
        SCNScene *scene = [self getSceneWithType:0];
        SCNNode *shipNode = scene.rootNode.childNodes[0];
        self.tempNode = shipNode;
        shipNode.scale = SCNVector3Make(0.3, 0.3, 0.3);//缩放比例
        shipNode.position = SCNVector3Make(0, 0, -10);
        for (SCNNode *node in shipNode.childNodes) {
            node.scale = SCNVector3Make(0.3, 0.3, 0.3);
            node.position = SCNVector3Make(0, 0, -10);
        }
        [self.scnView.scene.rootNode addChildNode:shipNode];
        
    }else if(self.type == ARaddType_revolution){
        // 添加花瓶节点
        SCNScene *scene = [self getSceneWithType:2];
        SCNNode *vaseNode = scene.rootNode.childNodes[0];
        vaseNode.scale = SCNVector3Make(1, 1, 1);
        vaseNode.position = SCNVector3Make(0, 0, -2);
        for (SCNNode *node in vaseNode.childNodes) {
            node.scale = SCNVector3Make(1, 1, 1);
            node.position = SCNVector3Make(0, 0, -2);
        }
        /*设置花瓶围绕相机公转*/
        
        //添加空节点到相机的位置，并将花瓶节点设置为空节点的子节点
        SCNNode *node1 = [[SCNNode alloc] init];
        node1.position = self.scnView.scene.rootNode.position;
        [self.scnView.scene.rootNode addChildNode:node1];
        [node1 addChildNode:vaseNode];
        
        //给空节点添加旋转动画
        CABasicAnimation *revolutionAnimation = [CABasicAnimation animationWithKeyPath:@"rotation"];
        revolutionAnimation.duration = 10;
        revolutionAnimation.toValue = [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI *2)];
        revolutionAnimation.repeatCount = FLT_MAX;
        [node1 addAnimation:revolutionAnimation forKey:@"revolution"];
        
        
        
    }else{
        return;
    }
}


-(void)backAction{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

#pragma mark - ARSessionDelegate
- (void)session:(ARSession *)session didUpdateFrame:(ARFrame *)frame{
    //飞机跟随相机转
    if (self.type == ARaddType_planeMove && self.tempNode) {
        self.tempNode.position = SCNVector3Make(frame.camera.transform.columns[3].x, frame.camera.transform.columns[3].y, frame.camera.transform.columns[3].z);
    }
}

/**
 This is called when new anchors are added to the session.
 
 @param session The session being run.
 @param anchors An array of added anchors.
 */
- (void)session:(ARSession *)session didAddAnchors:(NSArray<ARAnchor*>*)anchors{
    NSLog(@"添加新的锚点");
}

/**
 This is called when anchors are updated.
 
 @param session The session being run.
 @param anchors An array of updated anchors.
 */
- (void)session:(ARSession *)session didUpdateAnchors:(NSArray<ARAnchor*>*)anchors{
    NSLog(@"锚点发生改变");
}

/**
 This is called when anchors are removed from the session.
 
 @param session The session being run.
 @param anchors An array of removed anchors.
 */
- (void)session:(ARSession *)session didRemoveAnchors:(NSArray<ARAnchor*>*)anchors{
    NSLog(@"锚点移除");
}

#pragma mark - ARSCNViewDelegate
//- (nullable SCNNode *)renderer:(id <SCNSceneRenderer>)renderer nodeForAnchor:(ARAnchor *)anchor{
//    return nil;
//}
// 如果开启平地捕捉，当捕捉到平地，就会走这个代理，并且返回捕捉到锚点及自动添加的节点
-(void)renderer:(id<SCNSceneRenderer>)renderer didAddNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor{
    if (self.type == ARaddType_planeCatch) {//平地捕捉
    
        if ([anchor isMemberOfClass:[ARPlaneAnchor class]]) {//是否为平地锚点
            
            ARPlaneAnchor *planeAnchor = (ARPlaneAnchor *)anchor;
            
            // 添加一个几个结构，这里是一个红色的正方形平面
            SCNBox *plane = [SCNBox boxWithWidth:planeAnchor.extent.x * 0.3 height:0 length:planeAnchor.extent.x * 0.3 chamferRadius:0.0];
            plane.firstMaterial.diffuse.contents = [UIColor redColor];
            
            // 把几何结构作为子节点添加节点
            SCNNode *planeNode = [SCNNode nodeWithGeometry:plane];
            planeNode.position = SCNVector3Make(planeAnchor.center.x, 0, planeAnchor.center.z);
            [node addChildNode:planeNode];
            
            // 在节点上添加一个花瓶子节点
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                SCNScene *scene = [SCNScene sceneNamed:@"Models.scnassets/vase/vase.scn"];
                SCNNode *vaseNode = scene.rootNode.childNodes[0];
                vaseNode.position = SCNVector3Make(planeAnchor.center.x, 0, planeAnchor.center.z);
                [node addChildNode:vaseNode];
            });
        }
    }else if(self.type == ARaddType_fuCatch){
        ARImageAnchor *imageAnchor = (ARImageAnchor *)anchor;
        ARReferenceImage *referenceImage = imageAnchor.referenceImage;
        SCNNode *tempNode = [SCNNode new];
        
        tempNode.opacity = 0.5;
        tempNode.eulerAngles = SCNVector3Make(M_PI/3, 0, 0);
        SCNBox *box = [SCNBox boxWithWidth:referenceImage.physicalSize.width height:referenceImage.physicalSize.height length:0.01 chamferRadius:1];
        tempNode.geometry = box;
        [node addChildNode:tempNode];
        
        if ([referenceImage.name isEqualToString:@"fu01"]) {
            tempNode.geometry.firstMaterial.diffuse.contents = @"fu01.jpeg";
        }else if([referenceImage.name isEqualToString:@"fu02"]){
            tempNode.geometry.firstMaterial.diffuse.contents = @"fu02";
        }
        
    }
    
}

@end
