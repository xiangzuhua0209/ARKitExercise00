//
//  SolarSystemViewController.m
//  ARKitClass00
//
//  Created by xiangzuhua on 2018/9/23.
//  Copyright © 2018年 xiangzuhua. All rights reserved.
//

#import "SolarSystemViewController.h"
#import <ARKit/ARKit.h>

typedef NS_ENUM(NSUInteger, SolarType){
    SolarType_sun = 0,
    SolarType_moon,//月亮
    SolarType_sunHalo,//太阳光晕
    SolarType_earth,
    SolarType_earth_orbit = 4,//地球轨道
    SolarType_saturn,//土星
    SolarType_saturn_orbit,
    SolarType_mars,//火星
    SolarType_mars_orbit = 8,
    SolarType_venus,//金星
    SolarType_venus_orbit,
    SolarType_mercury,//水星
    SolarType_mercury_orbit = 12,
    SolarType_jupiter,//木星
    SolarType_jupiter_orbit,
    SolarType_uranus,//天王星
    SolarType_uranus_orbit = 16,
    SolarType_neptune,//海王星
    SolarType_neptune_orbit,
    SolarType_plute,//冥王星
    SolarType_plute_orbit = 20,
    
    
    
};

@interface SolarSystemViewController ()<ARSessionDelegate,ARSCNViewDelegate>

@property(nonatomic, strong)ARSCNView *rootScnView;
@property(nonatomic, strong)ARWorldTrackingConfiguration *configuration;
@property(nonatomic, strong)ARSession *session;

/// node
@property (nonatomic, strong)SCNNode *sunNode;
@property (nonatomic, strong)SCNNode *sunHaloNode;// 太阳光光晕节点
/// 地球
@property (nonatomic, strong)SCNNode *earthNode;
@property (nonatomic, strong)SCNNode *earthOrbitNode;//地球轨道
@property (nonatomic, strong)SCNNode *moonNode;

/// 土星
@property (nonatomic, strong)SCNNode *saturnNode;
@property (nonatomic, strong)SCNNode *saturnOrbitNode;

/// 火星
@property (nonatomic, strong)SCNNode *marsNode;
@property (nonatomic, strong)SCNNode *marsOrbitNode;

/// 金星
@property (nonatomic, strong)SCNNode *venusNode;
@property (nonatomic, strong)SCNNode *venusOrbitNode;

/// 水星
@property (nonatomic, strong)SCNNode *mercuryNode;
@property (nonatomic, strong)SCNNode *mercuryOrbitNode;

/// 木星
@property (nonatomic, strong)SCNNode *jupiterNode;
@property (nonatomic, strong)SCNNode *jupiterOrbitNode;

///天王星
@property (nonatomic, strong)SCNNode *uranusNode;
@property (nonatomic, strong)SCNNode *uranusOrbitNode;

/// 海王星
@property (nonatomic, strong)SCNNode *neptuneNode;
@property (nonatomic, strong)SCNNode *neptuneOrbitNode;

/// 冥王星
@property (nonatomic, strong)SCNNode *pluteNode;
@property (nonatomic, strong)SCNNode *pluteOrbitNode;

@end

@implementation SolarSystemViewController
#pragma mark -- 懒加载
-(ARWorldTrackingConfiguration *)configuration{
    if (!_configuration) {
        _configuration = [[ARWorldTrackingConfiguration alloc] init];
        _configuration.lightEstimationEnabled = YES;
        _configuration.planeDetection = ARPlaneDetectionHorizontal;
    }
    return _configuration;
}
-(ARSession *)session{
    if (!_session) {
        _session = [ARSession new];
        _session.delegate = self;
    }
    return _session;
}

-(ARSCNView *)rootScnView{
    if (!_rootScnView) {
        _rootScnView = [[ARSCNView alloc] initWithFrame:CGRectMake(0, 0, kWidth, kHeight)];
        _rootScnView.session = self.session;
        _rootScnView.delegate = self;
        _rootScnView.automaticallyUpdatesLighting = YES;
    }
    return _rootScnView;
}
-(void)viewDidAppear:(BOOL)animated{
    [self.view addSubview:self.rootScnView];
    [self initNode];
    [self.session runWithConfiguration:self.configuration options:(ARSessionRunOptionResetTracking | ARSessionRunOptionRemoveExistingAnchors)];
    [self addBackButton];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
}
#pragma mark -- private
-(void)initNode{
    [self sunGroup];
    [self earthGroup];
    [self saturnGroup];
    [self marsGroup];
    [self venusGroup];
    [self mercuryGroup];
    [self jupiterGroup];
    [self uranusGroup];
    [self neptuneGroup];
    [self pluteGroup];
}

-(void)sunGroup{
    // 创建太阳、太阳光晕节点
    self.sunNode = [self getNodeWithtype:SolarType_sun];//太阳节点
    self.sunHaloNode = [self getNodeWithtype:SolarType_sunHalo];//太阳光晕节点
    [self.rootScnView.scene.rootNode addChildNode:self.sunNode];//将太阳节添加到根节点
    [self.sunNode addChildNode:self.sunHaloNode];// 太阳节点添加光晕节点
    
    // 太阳表面材料的动画
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"contentsTransform"];
    animation.duration = 10.0;
    animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DConcat(CATransform3DMakeTranslation(0, 0, 0), CATransform3DMakeScale(3, 3, 3))];
    animation.toValue = [NSValue valueWithCATransform3D:CATransform3DConcat(CATransform3DMakeTranslation(1, 0, 0), CATransform3DMakeScale(3, 3, 3))];
    animation.repeatCount = FLT_MAX;
    [_sunNode.geometry.firstMaterial.diffuse addAnimation:animation forKey:@"sun-texture"];
    
    // 给太阳添加光
    SCNNode *lightNode = [SCNNode node];
    lightNode.light = [SCNLight light];
    lightNode.light.type = SCNLightTypeOmni;
    [_sunNode addChildNode:lightNode];
    lightNode.light.attenuationEndDistance = 19;
    lightNode.light.attenuationStartDistance = 21;
}

-(void)earthGroup{
    // 创建地球、月球、地球公转轨道节点
    self.earthNode = [self getNodeWithtype:SolarType_earth];
    self.moonNode = [self getNodeWithtype:SolarType_moon];
    self.earthOrbitNode = [self getNodeWithtype:SolarType_earth_orbit];
    [self.sunNode addChildNode:self.earthOrbitNode];

    // 月亮公转
    SCNNode *moonRotationNode = [SCNNode node];
    [moonRotationNode addChildNode:_moonNode];
    CABasicAnimation *moonRotationAnimation = [CABasicAnimation animationWithKeyPath:@"rotation"];
    moonRotationAnimation.duration = 3;
    moonRotationAnimation.toValue = [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI * 2)];
    moonRotationAnimation.repeatCount = FLT_MAX;
    [moonRotationNode addAnimation:moonRotationAnimation forKey:@"moon rotation around earth"];
    // 因为，地球自转，所以月球公转的节点不能直接添加到地球节点，否则公转速度是“地球自转+月球公转”的速度，这里用一个与地球同位置但不自转的节点来实现
    SCNNode *earthGroup = [SCNNode node];
    earthGroup.position = SCNVector3Make(0.8, 0, 0);
    [earthGroup addChildNode:self.earthNode];
    [earthGroup addChildNode:moonRotationNode];
    
    // 地球公转
    SCNNode *earthRotationNode = [SCNNode node];
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"rotation"];
    animation.duration = 36.0;
    animation.toValue = [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI * 2)];
    animation.repeatCount = FLT_MAX;
    [earthRotationNode addAnimation:animation forKey:@"earth rotation around sun"];
    [_sunNode addChildNode:earthRotationNode];
    [earthRotationNode addChildNode:earthGroup];
    
    /// 给地球地表添加一层半透明的云层
    SCNNode *cloudsNode = [SCNNode node];
    cloudsNode.geometry = [SCNSphere sphereWithRadius:0.06];
    [_earthNode addChildNode:cloudsNode];
    cloudsNode.opacity = 0.5;
    cloudsNode.geometry.firstMaterial.transparent.contents = @"art.scnassets/earth/cloudsTransparency.png";
    cloudsNode.geometry.firstMaterial.transparencyMode = SCNTransparencyModeRGBZero;
}
-(void)saturnGroup{
    self.saturnNode = [self getNodeWithtype:SolarType_saturn];
    // 添加土星环
    SCNNode *saturnLoopNode = [SCNNode node];
    saturnLoopNode.opacity = 0.4;
    saturnLoopNode.geometry = [SCNBox boxWithWidth:0.6 height:0 length:0.6 chamferRadius:0];
    saturnLoopNode.geometry.firstMaterial.diffuse.contents = @"art.scnassets/earth/saturn_loop.png";
    saturnLoopNode.geometry.firstMaterial.diffuse.mipFilter = SCNFilterModeLinear;
    saturnLoopNode.rotation = SCNVector4Make(-0.5, -1, 0, M_PI_2);
    saturnLoopNode.geometry.firstMaterial.lightingModelName = SCNLightingModelConstant; // no lighting
    [self.saturnNode addChildNode:saturnLoopNode];
    
    // 添加轨道
    self.saturnOrbitNode = [self getNodeWithtype:SolarType_saturn_orbit];
    [_sunNode addChildNode:self.saturnOrbitNode];
    
    // 将土星和土星环节点添加到一个空节点，作为一个整体节点,设置其位置
    SCNNode *saturnGroupNode = [SCNNode node];
    saturnGroupNode.position = SCNVector3Make(1.68, 0, 0);
    [saturnGroupNode addChildNode:self.saturnNode];
    [saturnGroupNode addChildNode:saturnLoopNode];
    
    // 土星公转
    SCNNode *saturnRotationNode = [SCNNode node];// 在太阳节点添加一空节点
    [self.sunNode addChildNode:saturnRotationNode];
    [saturnRotationNode addChildNode:saturnGroupNode];// 再将上面土星的整体节点添加到此空节点，使空节点旋转时实现土星的公转
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"rotation"];
    animation.toValue = [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI * 2)];
    animation.repeatCount = FLT_MAX;
    animation.duration = 80.0;
    [saturnRotationNode addAnimation:animation forKey:@"saturn rotation around sun"];
}

-(void)marsGroup{
    self.marsNode = [self getNodeWithtype:SolarType_mars];
    self.marsOrbitNode = [self getNodeWithtype:SolarType_mars_orbit];
    [self.sunNode addChildNode: self.marsOrbitNode];
    
    //公转
    SCNNode *marsRotationNode = [SCNNode node];
    [marsRotationNode addChildNode:self.marsNode];
    [self.sunNode addChildNode:marsRotationNode];
    CABasicAnimation *animationg = [CABasicAnimation animationWithKeyPath:@"rotation"];
    animationg.repeatCount = FLT_MAX;
    animationg.duration = 35.0;
    animationg.toValue = [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI * 2)];
    [marsRotationNode addAnimation:animationg forKey:@"mars rotation around sun"];
}
-(void)venusGroup{
    self.venusNode = [self getNodeWithtype:SolarType_venus];
    self.venusOrbitNode = [self getNodeWithtype:SolarType_venus_orbit];
    [self.sunNode addChildNode:self.venusOrbitNode];
    
    //公转
    SCNNode *venusRotationNode = [SCNNode node];
    [venusRotationNode addChildNode:self.venusNode];
    [self.sunNode addChildNode:venusRotationNode];
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"rotation"];
    animation.repeatCount = FLT_MAX;
    animation.duration = 40;
    animation.toValue = [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI * 2)];
    [venusRotationNode addAnimation:animation forKey:@"venus rotation around sun"];
}
-(void)mercuryGroup{
    self.mercuryNode = [self getNodeWithtype:SolarType_mercury];
    self.mercuryOrbitNode = [self getNodeWithtype:SolarType_mercury_orbit];
    [self.sunNode addChildNode:self.mercuryOrbitNode];
    
    //公转
    SCNNode *mercuryRotationNode = [SCNNode node];
    [mercuryRotationNode addChildNode:self.mercuryNode];
    [self.sunNode addChildNode:mercuryRotationNode];
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"rotation"];
    animation.repeatCount = FLT_MAX;
    animation.duration = 25.0;
    animation.toValue = [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI * 2)];
    [mercuryRotationNode addAnimation:animation forKey:@"mercury rotation around sun"];
}
-(void)jupiterGroup{
    self.jupiterNode = [self getNodeWithtype:SolarType_jupiter];
    self.jupiterOrbitNode = [self getNodeWithtype:SolarType_jupiter_orbit];
    [self.sunNode addChildNode:self.jupiterOrbitNode];
    
    //公转
    SCNNode *jupiterRotationNode = [SCNNode node];
    [jupiterRotationNode addChildNode:self.jupiterNode];
    [self.sunNode addChildNode:jupiterRotationNode];
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"rotation"];
    animation.repeatCount = FLT_MAX;
    animation.duration = 90;
    animation.toValue = [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI * 2)];
    [jupiterRotationNode addAnimation:animation forKey:@"venus rotation around sun"];
}
-(void)uranusGroup{
    self.uranusNode = [self getNodeWithtype:SolarType_uranus];
    self.uranusOrbitNode = [self getNodeWithtype:SolarType_uranus_orbit];
    [self.sunNode addChildNode:self.uranusOrbitNode];
    
    //公转
    SCNNode * uranusRotationNode = [SCNNode node];
    [uranusRotationNode addChildNode:self.uranusNode];
    [self.sunNode addChildNode:uranusRotationNode];
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"rotation"];
    animation.repeatCount = FLT_MAX;
    animation.duration = 55;
    animation.toValue = [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI * 2)];
    [uranusRotationNode addAnimation:animation forKey:@"uranus rotation around sun"];
    
    
}

-(void)neptuneGroup{
    self.neptuneNode = [self getNodeWithtype:SolarType_neptune];
    self.neptuneOrbitNode = [self getNodeWithtype:SolarType_neptune_orbit];
    [self.sunNode addChildNode:self.neptuneOrbitNode];
    
    //公转
    SCNNode *neptuneRotationNode = [SCNNode node];
    [neptuneRotationNode addChildNode:self.neptuneNode];
    [self.sunNode addChildNode:neptuneRotationNode];
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"rotation"];
    animation.repeatCount = FLT_MAX;
    animation.duration = 50;
    animation.toValue = [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI * 2)];
    [neptuneRotationNode addAnimation:animation forKey:@"neptune rotation around sun"];
}
-(void)pluteGroup{
    self.pluteNode = [self getNodeWithtype:SolarType_plute];
    self.pluteOrbitNode = [self getNodeWithtype:SolarType_plute_orbit];
    [self.sunNode  addChildNode:self.pluteOrbitNode];
    
    SCNNode *pluteRotationNode = [SCNNode node];
    [pluteRotationNode addChildNode:self.pluteNode];
    [self.sunNode addChildNode:pluteRotationNode];
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"rotation"];
    animation.repeatCount = FLT_MAX;
    animation.duration = 100;
    animation.toValue = [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI * 2)];
    [pluteRotationNode addAnimation:animation forKey:@"plute rotation around sun"];
}

-(SCNNode *)getNodeWithtype:(SolarType)type{
    SCNNode *node = [SCNNode new];
    if (type % 2 == 1) {
        node.geometry.firstMaterial.locksAmbientWithDiffuse   = YES;
        node.geometry.firstMaterial.shininess = 0.1;
        node.geometry.firstMaterial.specular.intensity = 0.5;
        //自转 ---  各星球自转速度是不同，这里统一成一个速度了
        [node runAction:[SCNAction repeatActionForever:[SCNAction rotateByX:0 y:2 z:0 duration:1]]];
    }else if(type % 2 == 0 && type > 2){
        node.opacity = 0.4;
        node.geometry.firstMaterial.diffuse.mipFilter = SCNFilterModeLinear;
        node.rotation = SCNVector4Make(0, 1, 0, M_PI_2);
        node.geometry.firstMaterial.lightingModelName = SCNLightingModelConstant; // no lighting
    }

    switch (type) {
        case SolarType_sun:{
            node.geometry = [SCNSphere sphereWithRadius:0.25];
            [node setPosition:SCNVector3Make(0, -0.1, 3)];//设置位置
            node.geometry.firstMaterial.multiply.contents = @"art.scnassets/earth/sun.jpg";
            node.geometry.firstMaterial.diffuse.contents = @"art.scnassets/earth/sun.jpg";
            node.geometry.firstMaterial.multiply.intensity = 0.5;
            node.geometry.firstMaterial.lightingModelName = SCNLightingModelConstant;
            
            node.geometry.firstMaterial.multiply.wrapS =
            node.geometry.firstMaterial.diffuse.wrapS  =
            node.geometry.firstMaterial.multiply.wrapT =
            node.geometry.firstMaterial.diffuse.wrapT  = SCNWrapModeRepeat;
        }
            break;
        case SolarType_sunHalo:{
            node.opacity = 0.5;
            node.geometry = [SCNPlane planeWithWidth:2.5 height:2.5];
            node.geometry.firstMaterial.diffuse.contents = @"art.scnassets/earth/sun-halo.png";
            node.geometry.firstMaterial.lightingModelName = SCNLightingModelConstant; // no lighting
            node.geometry.firstMaterial.writesToDepthBuffer = NO; // do not write to depth
        }
            break;
        case SolarType_earth:{
            node.geometry = [SCNSphere sphereWithRadius:0.05];
            // 地球贴图
            node.geometry.firstMaterial.diffuse.contents = @"art.scnassets/earth/earth-diffuse-mini.jpg";
            node.geometry.firstMaterial.emission.contents = @"art.scnassets/earth/earth-emissive-mini.jpg";
            node.geometry.firstMaterial.specular.contents = @"art.scnassets/earth/earth-specular-mini.jpg";
        }
            break;
        case SolarType_moon:{
            node.geometry = [SCNSphere sphereWithRadius:0.01];
            node.position = SCNVector3Make(0.1, 0, 0);
            //月球贴图
            node.geometry.firstMaterial.diffuse.contents = @"art.scnassets/earth/moon.jpg";
            node.geometry.firstMaterial.specular.contents = [UIColor grayColor];
        }
            break;
        case SolarType_earth_orbit:{
            node.geometry = [SCNBox boxWithWidth:1.72 height:0 length:1.72 chamferRadius:0];
            node.geometry.firstMaterial.diffuse.contents = @"art.scnassets/earth/orbit.png";
        }
            break;
        case SolarType_saturn:{
            node.geometry = [SCNSphere sphereWithRadius:0.12];
            //土星贴图
            _saturnNode.geometry.firstMaterial.diffuse.contents = @"art.scnassets/earth/saturn.jpg";
        }
            break;
        case SolarType_saturn_orbit:{
            node.geometry = [SCNBox boxWithWidth:3.57 height:0 length:3.57 chamferRadius:0];
            node.geometry.firstMaterial.diffuse.contents = @"art.scnassets/earth/orbit.png";
        }
            break;
        case SolarType_mars:{
            node.geometry = [SCNSphere sphereWithRadius:0.03];
            node.position = SCNVector3Make(1.0, 0, 0);
            node.geometry.firstMaterial.diffuse.contents = @"art.scnassets/earth/mars.jpg";
        }
            break;
        case SolarType_mars_orbit:{
            node.geometry = [SCNBox boxWithWidth:2.14 height:0 length:2.14 chamferRadius:0];
            node.geometry.firstMaterial.diffuse.contents = @"art.scnassets/earth/orbit.png";
        }
            break;
        case SolarType_venus:{
            node.geometry = [SCNSphere sphereWithRadius:0.04];
            node.position = SCNVector3Make(0.6, 0, 0);
            node.geometry.firstMaterial.diffuse.contents = @"art.scnassets/earth/venus.jpg";
        }
            break;
        case SolarType_venus_orbit:{
            node.geometry = [SCNBox boxWithWidth:1.29 height:0 length:1.29 chamferRadius:0];
            node.geometry.firstMaterial.diffuse.contents = @"art.scnassets/earth/orbit.png";
        }
            break;
        case SolarType_mercury:{
            node.geometry = [SCNSphere sphereWithRadius:0.02];
            node.position = SCNVector3Make(0.4, 0, 0);
            node.geometry.firstMaterial.diffuse.contents = @"art.scnassets/earth/mercury.jpg";
        }
            break;
        case SolarType_mercury_orbit:{
            node.geometry = [SCNBox boxWithWidth:0.86 height:0 length:0.86 chamferRadius:0];
            node.geometry.firstMaterial.diffuse.contents = @"art.scnassets/earth/orbit.png";
        }
            break;
        case SolarType_jupiter:{
            node.geometry = [SCNSphere sphereWithRadius:0.15];
            node.position = SCNVector3Make(1.4, 0, 0);
            node.geometry.firstMaterial.diffuse.contents = @"art.scnassets/earth/jupiter.jpg";
        }
            break;
        case SolarType_jupiter_orbit:{
            node.geometry = [SCNBox boxWithWidth:2.95 height:0 length:2.95 chamferRadius:0];
            node.geometry.firstMaterial.diffuse.contents = @"art.scnassets/earth/orbit.png";
        }
            break;
        case SolarType_uranus:{
            node.geometry = [SCNSphere sphereWithRadius:0.09];
            node.position = SCNVector3Make(1.95, 0, 0);
            node.geometry.firstMaterial.diffuse.contents = @"art.scnassets/earth/uranus.jpg";
        }
            break;
        case SolarType_uranus_orbit:{
            node.geometry = [SCNBox boxWithWidth:4.19 height:0 length:4.19 chamferRadius:0];
            node.geometry.firstMaterial.diffuse.contents = @"art.scnassets/earth/orbit.png";
        }
            break;
        case SolarType_neptune:{
            node.geometry = [SCNSphere sphereWithRadius:0.08];
            node.position = SCNVector3Make(2.14, 0, 0);
            node.geometry.firstMaterial.diffuse.contents = @"art.scnassets/earth/neptune.jpg";
        }
            break;
        case SolarType_neptune_orbit:{
            node.geometry = [SCNBox boxWithWidth:4.54 height:0 length:4.54 chamferRadius:0];
            node.geometry.firstMaterial.diffuse.contents = @"art.scnassets/earth/orbit.png";
        }
            break;
        case SolarType_plute:{
            node.geometry = [SCNSphere sphereWithRadius:0.04];
            node.position = SCNVector3Make(2.319, 0, 0);
            node.geometry.firstMaterial.diffuse.contents = @"art.scnassets/earth/plute.jpg";
        }
            break;
        case SolarType_plute_orbit:{
            node.geometry = [SCNBox boxWithWidth:4.98 height:0 length:4.98 chamferRadius:0];
            node.geometry.firstMaterial.diffuse.contents = @"art.scnassets/earth/orbit.png";
        }
            break;
        default:
            break;
    }
    return node;
}

-(void)addBackButton{
    UIButton *backButton = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [backButton setTitle:@"返回" forState:(UIControlStateNormal)];
    [backButton setTitleColor:[UIColor redColor] forState:(UIControlStateNormal)];
    backButton.frame = CGRectMake(0, 20, 64, 44);
    [backButton addTarget:self action:@selector(backAction) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:backButton];
}

#pragma mark -- ARSessionDelegate
-(void)session:(ARSession *)session didAddAnchors:(NSArray<ARAnchor *> *)anchors{
    
}
-(void)session:(ARSession *)session didUpdateFrame:(ARFrame *)frame{
    //监听手机的移动，实现近距离查看太阳系细节，为了凸显效果变化值*3
    [self.sunNode setPosition:SCNVector3Make(-3 * frame.camera.transform.columns[3].x, -0.1 - 3 * frame.camera.transform.columns[3].y, -2 - 3 * frame.camera.transform.columns[3].z)];
}

#pragma mark -- ARSCNViewDelegate
-(void)renderer:(id<SCNSceneRenderer>)renderer didAddNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor{
    
}
#pragma mark -- event
-(void)backAction{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
