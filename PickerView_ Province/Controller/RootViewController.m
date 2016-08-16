//
//  RootViewController.m
//  PickerView_ Province
//
//  Created by yan on 16/5/24.
//  Copyright © 2016年 yan. All rights reserved.
//

#import "RootViewController.h"

@interface RootViewController ()<UIPickerViewDataSource,UIPickerViewDelegate>

@property(nonatomic,weak)UITextField *address_TF;
/** 省 **/
@property (strong,nonatomic)NSArray *provinceList;
/** 市 **/
@property (strong,nonatomic)NSArray *cityList;
/** 区 **/
@property (strong,nonatomic)NSArray *areaList;
/** 第一级选中的下标 **/
@property (assign, nonatomic)NSInteger selectOneRow;
/** 第二级选中的下标 **/
@property (assign, nonatomic)NSInteger selectTwoRow;
/** 第三级选中的下标 **/
@property (assign, nonatomic)NSInteger selectThreeRow;

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"省市区";
    
    [self getCityListJSON];//获取数据
    [self getCitydate:0];// 默认显示数据
    [self getAreaDate:0];

    [self addTextField];
    [self addPickView];
}
- (void)addTextField{

    UITextField *address_TF = [[UITextField alloc] initWithFrame:CGRectMake(40, 80, 300, 40)];
    address_TF.borderStyle = UITextBorderStyleLine;
    [self.view addSubview:address_TF];
    self.address_TF = address_TF;
}
- (void)addPickView{
    
    UIPickerView *pickView = [[UIPickerView alloc] init];
    pickView.delegate = self;
    pickView.dataSource = self;
    pickView.backgroundColor = [UIColor colorWithRed:200 green:200 blue:200 alpha:0.5];
    self.address_TF.inputView = pickView;
}
/**
 *  读取城市文件
 */
- (void)getCityListJSON{
    
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *path = [bundle pathForResource:@"city" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSError *error;
    NSArray *provinceList = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    self.provinceList = provinceList;
    
}
- (void)getCitydate:(NSInteger)row{
    
    
    if ([self.provinceList[row][@"type"] intValue] == 0) {
        NSArray *cityArr = [[NSArray alloc] initWithObjects:self.provinceList[row], nil];
        self.cityList = cityArr;
        
    }else{
        NSMutableArray *cityList = [[NSMutableArray alloc] init];
        for (NSArray *cityArr in self.provinceList[row][@"sub"]) {
            [cityList addObject:cityArr];
        }
        self.cityList = cityList;
    }
    
    
}
- (void)getAreaDate:(NSInteger)row{
    if ([self.provinceList[self.selectOneRow][@"type"] intValue] == 0) {
        NSMutableArray *areaList = [[NSMutableArray alloc] init];
        for (NSArray *cityDict in self.provinceList[self.selectOneRow][@"sub"]) {
            [areaList addObject:cityDict];
        }
        self.areaList = areaList;
    }else{
        
        NSMutableArray *areaList = [[NSMutableArray alloc] init];
        for (NSArray *cityDict in self.cityList[row][@"sub"]) {
            [areaList addObject:cityDict];
        }
        self.areaList = areaList;
    }
    
}
#pragma mark - UIPickerViewDataSource,UIPickerViewDelegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    
    return 3;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    
    if (component == 0) {
        return self.provinceList.count;
    }else if (component == 1){
        return self.cityList.count;
    }else if (component == 2){
        return self.areaList.count;
    }
    return 0;
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
    static NSInteger oneRow = 0;
    static NSInteger tweRow = 0;
    static NSInteger threeRow = 0;
    if (component == 0) {
        
        self.selectOneRow = row;
        [self getCitydate:row];
        [pickerView reloadComponent:1];
        [pickerView selectRow:0 inComponent:1 animated:YES];
        [self getAreaDate:0];
        [pickerView reloadComponent:2];
        [pickerView selectRow:0 inComponent:2 animated:YES];
        if ([self.provinceList[self.selectOneRow][@"type"] intValue] == 0) {
            
            self.selectTwoRow = 0;
        }
        oneRow = row;
        tweRow = 0;
        threeRow = 0;
        
    }
    if (component == 1){
        
        self.selectTwoRow = row;
        [self getAreaDate:row];
        [pickerView reloadComponent:2];
        [pickerView selectRow:0 inComponent:2 animated:YES];
        
        tweRow = row;
        threeRow = 0;
    }
    if (component == 2){
        
        self.selectThreeRow = row;
        threeRow = row;
    }
    NSMutableString *regionAddress = [[NSMutableString alloc] init];
    if (oneRow > 0 &&[self.provinceList[self.selectOneRow][@"type"] intValue] != 0 ) {
        [regionAddress appendFormat:@"%@省",self.provinceList[self.selectOneRow][@"name"]];
        
    }
    if (tweRow > 0 || [self.provinceList[self.selectOneRow][@"type"] intValue] == 0){
        
        [regionAddress appendFormat:@"%@市",self.cityList[self.selectTwoRow][@"name"]];
    }
    if (threeRow > 0 ){
        [regionAddress appendFormat:@"%@",self.areaList[self.selectThreeRow][@"name"]];
    }
    self.address_TF.text = regionAddress;
}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    
    if (component == 0) {
        
        return self.provinceList[row][@"name"];
        
    }
    if (component == 1){
        if ([self.provinceList[self.selectOneRow][@"type"] intValue] == 0) {
            
            
            return self.cityList[0][@"name"];
        }else {
            
            return self.cityList[row][@"name"];
        }
        
    }
    if (component == 2){
        
        return self.areaList[row][@"name"];
    }
    return nil;
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{

    [self.view endEditing:YES];
}
@end
