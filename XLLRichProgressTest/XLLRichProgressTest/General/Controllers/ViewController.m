//
//  ViewController.m
//  XLLRichProgressTest
//
//  Created by 肖乐 on 2018/11/28.
//  Copyright © 2018 iOSCoder. All rights reserved.
//

#import "ViewController.h"
#import "XLLProgressBar.h"

@interface ViewController ()

@property (nonatomic, strong) XLLProgressBar *progressBar;

@end

@implementation ViewController

#pragma mark - lazy loading
- (XLLProgressBar *)progressBar
{
    if (_progressBar == nil)
    {
        _progressBar = [[XLLProgressBar alloc] init];
    }
    return _progressBar;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor greenColor];
    [self.view addSubview:self.progressBar];
}

#pragma mark - event

- (IBAction)onStart:(id)sender {
    
    [self.progressBar startAnimation];
}

- (IBAction)onFailed:(id)sender {
    
    [self.progressBar failedProcess];
}

- (IBAction)onResume:(id)sender {
    
    [self.progressBar resumeOrigin];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.progressBar.frame = CGRectMake(100, 150, 180, 110);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
