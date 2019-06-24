//
//  TestViewController.m
//  CALayer-learning
//
//  Created by 周腾飞 on 2019/6/3.
//  Copyright © 2019年 周腾飞. All rights reserved.
//

#import "TestViewController.h"
#import <Masonry.h>
#import <CoreBluetooth/CoreBluetooth.h>


/**
 *  1、建立中心角色
 
 2、扫描外设(Discover Peripheral)
 
 3、连接外设(Connect Peripheral)
 
 4、扫描外设中的服务和特征(Discover Services And Characteristics)
 
 4.1 获取外设的services
 
 4.2 获取外设的Characteristics，获取characteristics的值
 
 4.3 获取Characteristics的Descriptor和Descriptor的值
 
 5、利用特征与外设做数据交互
 
 6、订阅Characteristic的通知
 
 7、断开连接(Disconnect)
 */
@interface TestViewController () <CBCentralManagerDelegate, CBPeripheralDelegate>

// 手机设备
@property (nonatomic, strong) CBCentralManager *mCentral;
// 外设设备
@property (nonatomic, strong) CBPeripheral *mPeripheral;
// 特征值
@property (nonatomic, strong) CBCharacteristic *mCharacteristic;
// 服务
@property (nonatomic, strong) CBService *mService;
// 描述
@property (nonatomic, strong) CBDescriptor *mDescriptor;


@property (nonatomic, strong) UIButton *sendButton;
@property (nonatomic, strong) UIButton *secondButton;
@property (nonatomic, strong) UIButton *timeButton;

@property (nonatomic, strong) UIButton *stepButton;
@property (nonatomic, strong) UIButton *resetTimeButton;

@end

@implementation TestViewController

- (UIButton *)resetTimeButton
{
    if (!_resetTimeButton) {
        _resetTimeButton = [[UIButton alloc] init];
        [_resetTimeButton setTitle:@"resetTime--C2" forState:UIControlStateNormal];
        [_resetTimeButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [_resetTimeButton addTarget:self action:@selector(resetTimeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _resetTimeButton;
}

- (UIButton *)sendButton
{
    if (!_sendButton) {
        _sendButton = [[UIButton alloc] init];
        [_sendButton setTitle:@"sendData" forState:UIControlStateNormal];
        [_sendButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [_sendButton addTarget:self action:@selector(sendButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sendButton;
}

- (UIButton *)secondButton
{
    if (!_secondButton) {
        _secondButton = [[UIButton alloc] init];
        [_secondButton setTitle:@"0xc4步数--Button" forState:UIControlStateNormal];
        [_secondButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [_secondButton addTarget:self action:@selector(secondButtonClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _secondButton;
}
- (UIButton *)timeButton
{
    if (!_timeButton) {
        _timeButton = [[UIButton alloc] init];
        [_timeButton setTitle:@"时间--0x89" forState:UIControlStateNormal];
        [_timeButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [_timeButton addTarget:self action:@selector(timeButtonClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _timeButton;
}

- (UIButton *)stepButton
{
    if (!_stepButton) {
        _stepButton = [[UIButton alloc] init];
        [_stepButton setTitle:@"0xc6-device信息/0xFA蓝牙地址" forState:UIControlStateNormal];
        [_stepButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [_stepButton addTarget:self action:@selector(stepButtonClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _stepButton;
}

// 1.程序开始初始化设备
- (CBCentralManager *)mCentral
{
    if (!_mCentral) {
        _mCentral = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
    }
    return _mCentral;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    // 中心管理者初始化
    [self mCentral];
    [self.view addSubview:self.sendButton];
    [self.view addSubview:self.secondButton];
    [self.view addSubview:self.timeButton];
    [self.view addSubview:self.stepButton];
    [self.view addSubview:self.resetTimeButton];
    [self.sendButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.height.mas_equalTo(100);
        make.top.equalTo(self.view.mas_top).offset(100);
    }];
    
    [self.secondButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.top.equalTo(self.sendButton.mas_bottom).offset(20);
        make.height.mas_equalTo(100);
    }];
    
    [self.timeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.top.equalTo(self.secondButton.mas_bottom).offset(20);
        make.height.mas_equalTo(100);
    }];
    
    [self.stepButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.top.equalTo(self.timeButton.mas_bottom).offset(20);
        make.height.mas_equalTo(100);
    }];
    
    [self.resetTimeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.top.equalTo(self.stepButton.mas_bottom).offset(20);
        make.height.mas_equalTo(100);
    }];
    
    
    
}

// 当程序退出时，断开连接
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    // 停止扫描
    if (@available(iOS 9.0, *)) {
        if ([self.mCentral isScanning]) {
            [self.mCentral stopScan];
        }
    } else {
        // Fallback on earlier versions
    }
    // 停止连接
    if (nil != self.mPeripheral && self.mPeripheral.state == CBPeripheralStateConnecting) {
        [self.mCentral cancelPeripheralConnection:self.mPeripheral];
    }
    
}

// 重新设置时间
- (void)resetTimeButtonClick:(UIButton *)btn
{
    Byte byteArray[] = {0xc2 ,0x05 ,0x13, 0x06, 0x16, 0x05, 0x1b, 0x16, 0x04};
    NSData *sendData = [NSData dataWithBytes:byteArray length:sizeof(byteArray)];
    [self.mPeripheral writeValue:sendData forCharacteristic:self.mCharacteristic type:CBCharacteristicWriteWithResponse];
   
}


- (void)stepButtonClick
{
    // 0xc6--设备信息，
    // 0xfa
    Byte time = 0xFA;
    NSData *data2 = [NSData dataWithBytes:&time length:sizeof(time)];
    NSLog(@"%@", data2);
    [self.mPeripheral writeValue:data2 forCharacteristic:self.mCharacteristic type:CBCharacteristicWriteWithResponse];
}

// 时间
- (void)timeButtonClick
{
    Byte time = 0x89;
    NSData *data2 = [NSData dataWithBytes:&time length:sizeof(time)];
    [self.mPeripheral writeValue:data2 forCharacteristic:self.mCharacteristic type:CBCharacteristicWriteWithResponse];
    NSLog(@"---->%@", data2);

    
}
// 步数
- (void)secondButtonClick
{
    
    Byte b[] = {0xC4, 0x03, 0x01, 0x00, 0x01};
    NSData *data = [NSData dataWithBytes:&b length:sizeof(b)];
    NSLog(@"%@", data);
    [self.mPeripheral writeValue:data forCharacteristic:self.mCharacteristic type:CBCharacteristicWriteWithResponse];
    
}

- (NSString*)hexStringFromData:(NSData*)myD{
    Byte *bytes = (Byte *)[myD bytes];
    
    NSString *hexStr = @"";
    for (int i = 0; i < [myD length]; i++) {
        NSString *newHexStr = [NSString stringWithFormat:@"%x", bytes[i]&0xff];
        
        if ([newHexStr length] == 1) {
            hexStr = [NSString stringWithFormat:@"%@0%@", hexStr, newHexStr];
            
        } else {
            hexStr = [NSString stringWithFormat:@"%@%@", hexStr, newHexStr];
        }
        
    }
    return hexStr;
}



/**
 带子节的string转为NSData
 
 @return NSData类型
 */
-(NSData*)convertBytesStringToData:(NSString *)string {
    NSMutableData* data = [NSMutableData data];
    int idx;
    for (idx = 0; idx+2 <= string.length; idx+=2) {
        NSRange range = NSMakeRange(idx, 2);
        NSString* hexStr = [string substringWithRange:range];
        NSScanner* scanner = [NSScanner scannerWithString:hexStr];
        unsigned int intValue;
        [scanner scanHexInt:&intValue];
        [data appendBytes:&intValue length:1];
    }
    return data;
}

- (void)sendButtonClick:(UIButton *)btn
{
    [self sendDataToBLE:@"0x89"];
}

//发送数据
-(void)sendDataToBLE:(NSString *)data{
    NSData* myData = [data dataUsingEncoding:NSUTF8StringEncoding];
    [self.mPeripheral writeValue:myData // 写入的数据
               forCharacteristic:self.mCharacteristic // 写给哪个特征
                            type:CBCharacteristicWriteWithResponse];// 通过此响应记录是否成功写入
}

#pragma mark - CBCentralManagerDelegate
// 2.只要中心管理者初始化，就会触发此代理方法
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    switch (central.state) {
        case CBManagerStateUnknown:
            NSLog(@"CBManagerStateUnknown");
            break;
        case CBManagerStateResetting:
            NSLog(@"CBManagerStateResetting");
            break;
        case CBManagerStateUnsupported:
            NSLog(@"CBManagerStateUnsupported");
            break;
        case CBManagerStateUnauthorized:
            NSLog(@"CBManagerStateUnauthorized");
            break;
        case CBManagerStatePoweredOff:
            NSLog(@"CBManagerStatePoweredOff");
            break;
        case CBManagerStatePoweredOn:
        {
            NSLog(@"CBManagerStatePoweredOn");
            //搜索外设
            [self.mCentral scanForPeripheralsWithServices:nil // 通过某些服务筛选外设
                                                  options:nil]; // dict,条件
        }
            break;
        default:
            break;
    }
}

// 3.发现外设后回调的方法
// 获取广播包数据
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSLog(@"搜索到设备名：%@，设备ID：%@", peripheral.name, peripheral.identifier);
    
    // 发现之后就是进行链接 QN-Scale FT905HR
    if ([peripheral.name isEqualToString:@"FT905HR"]) {
        [self.mCentral stopScan];
        self.mPeripheral = peripheral;
        // CBPeripheralDelegate
        self.mPeripheral.delegate = self;
        [self.mCentral connectPeripheral:peripheral options:nil];
        NSLog(@"advertisementData--->%@", advertisementData);
    }
    
}

// 4.中心管理者链接外设成功
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"设备连接成功，设备名：%@", peripheral.name);
    // 外设发现服务，传nil代表不过滤
    [self.mPeripheral discoverServices:nil];
}
// 外设连接失败
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"设备连接失败，设备名：%@", peripheral.name);
}
// 丢失链接
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"设备c丢失链接，设备名：%@", peripheral.name);
}

#pragma mark - CBPeripheralDelegate
// 7.发现外设的服务后调用的方法
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    // 是否获取失败
    if (error) {
//        NSLog(@"设备获取服务失败，设备名：%@", peripheral.name);
        return;
    }
    for (CBService *service in peripheral.services) {
        self.mService = service;
//        NSLog(@"设备获取服务成功，服务名：%@，服务UUID：%@，服务数量：%lu",service,service.UUID,peripheral.services.count);
        // 外设发现特征
        [peripheral discoverCharacteristics:nil forService:service];
    }
}

// 8.获取特征中的值和描述
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if (error) {
        NSLog(@"设备获取特征失败，设备名：%@", peripheral.name);
        return;
    }
    /**
     CBCharacteristicPropertyRead                                                    = 0x02,
     CBCharacteristicPropertyWriteWithoutResponse                                    = 0x04,
     CBCharacteristicPropertyWrite                                                   = 0x08,
     CBCharacteristicPropertyNotify                                                  = 0x10,
     */
    for (CBCharacteristic *cha in service.characteristics) {
        if ([cha.UUID.UUIDString isEqualToString:@"FFF2"]) {
            // 找到可写的特征值 UUID
            self.mCharacteristic = cha;
            
        } else if ([cha.UUID.UUIDString isEqualToString:@"FFF1"]) {
            //             _writeCharacteristic = character;
            // 设置通知
            
            //            [_peripheral discoverDescriptorsForCharacteristic:character];
//            [self.mPeripheral readValueForCharacteristic:cha];
            [self.mPeripheral setNotifyValue:YES forCharacteristic:cha];
        }
        
    }
    
}

// 9.读取特征中的值和描述：更新特征值的时候调用，可以理解为获取蓝牙返回的数据
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if ([characteristic.UUID.UUIDString isEqualToString:@"FFF1"]) {
        
        NSLog(@">>>>>>>>>>>>>>>>>特征值：%@",characteristic.value);
        
    }
   
    
}



// 10.状态改变和发现描述
// 通知状态改变的时候调用
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if(error){
        NSLog(@"特征名：%@，改变通知状态失败",error);
    }
    NSLog(@"----》特征名：%@，改变了通知状态",characteristic);
}

//发现外设的特征的描述数组
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(nonnull CBCharacteristic *)characteristic error:(nullable NSError *)error
{
    if(error){
        NSLog(@"设备获取描述失败，设备名：%@", peripheral.name);
        return;
    }
    for (CBDescriptor *descriptor in characteristic.descriptors) {
        self.mDescriptor = descriptor;
        [peripheral readValueForDescriptor:descriptor];
        NSLog(@"设备获取描述成功，描述名：%@",descriptor);
    }
}

// 写数据回调
-(void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if (!error) {
        NSLog(@"数据发送成功");
    } else {
        NSLog(@"数据发送失败：%@", error);
    }
}








@end
