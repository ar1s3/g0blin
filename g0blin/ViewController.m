//
//  ViewController.m
//  g0blin
//
//  Created by Sticktron on 2017-12-26.
//  Copyright © 2017 Sticktron. All rights reserved.
//

#import "ViewController.h"
#import "SettingsController.h"
#include "v0rtex.h"
#include "common.h"
#include "offsets.h"
#include "kernel.h"
#include "kpp.h"
#include "remount.h"
#include "bootstrap.h"
#include <sys/utsname.h>


#define GRAPE [UIColor colorWithRed:0.5 green:0 blue:1 alpha:1]


@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIButton *goButton;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UITextView *consoleView;
@property (weak, nonatomic) IBOutlet UILabel *cydiaJailbreeakdLabel;
@property (weak, nonatomic) IBOutlet UIButton *settingsButton;
@property (weak, nonatomic) IBOutlet UILabel *reinstallBootstrapLabel;
@end


task_t tfp0;
kptr_t kslide;
kptr_t kcred;
uint64_t kbase;



@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.progressView.progress = 0;
    self.progressView.hidden = YES;

    self.consoleView.layer.cornerRadius = 6;
    self.consoleView.text = nil;
    
    self.goButton.layer.cornerRadius = 16;
    
    self.reinstallBootstrapLabel.hidden = YES;
    self.cydiaJailbreeakdLabel.hidden = YES;
    
    // print kernel version
    struct utsname u;
    uname(&u);
    [self log:[NSString stringWithFormat:@"%s \n", u.version]];
    
    // abort if already jailbroken
    if (strstr(u.version, "MarijuanARM")) {
        self.goButton.enabled = NO;
        self.goButton.backgroundColor = UIColor.darkGrayColor;
        [self.goButton setTitle:@"Already jailbroken!" forState:UIControlStateDisabled];
    }
    
    
    if (init_offsets() != YES) {
        self.goButton.enabled = NO;
        self.goButton.backgroundColor = UIColor.darkGrayColor;
        [self.goButton setTitle:@"Not supported yet!" forState:UIControlStateDisabled];
        return;
    }
    
    [self log:@"Ready. \n"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)log:(NSString *)text {
    self.consoleView.text = [NSString stringWithFormat:@"%@%@ \n", self.consoleView.text, text];
}

- (IBAction)prepareForUnwind:(UIStoryboardSegue *)segue {
    //segue exit marker
    
    SettingsController *settingsController = segue.sourceViewController;
    self.reinstallBootstrapLabel.hidden = !settingsController.reinstallBootstrapSwitch.on;
    self.cydiaJailbreeakdLabel.hidden = !settingsController.enableJailbreakdSwitch.on;
}

- (IBAction)go:(UIButton *)sender {
    self.goButton.enabled = NO;
    self.goButton.backgroundColor = UIColor.darkGrayColor;
    [self.goButton setTitle:@"Jailbreaking..." forState:UIControlStateDisabled];
    
    self.progressView.hidden = NO;
    [self.progressView setProgress:0.1 animated:YES];
    
    [self log:@"Running exploit..."];
    
    kern_return_t ret = v0rtex(NULL, NULL, &tfp0, &kslide, &kcred);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (ret != KERN_SUCCESS) {
            self.goButton.enabled = YES;
            self.goButton.backgroundColor = GRAPE;
            [self.goButton setTitle:@"Failed, try again" forState:UIControlStateNormal];
            
            [self log:@"ERROR: exploit failed \n"];
            return;
        }
        LOG("v0rtex was successful");
        LOG("tfp0 -> %u", tfp0);
        LOG("slide -> %u", kslide);
        
        kbase = kslide + 0xFFFFFFF007004000;
        LOG("kern base -> %llu", kbase);
        LOG("kern cred -> %u", kcred);

        [self bypassKPP];
    });
}

- (void)bypassKPP {
    
    [self.progressView setProgress:0.3 animated:YES];
    [self log:@"Bypassing KPP..."];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        
        if (do_kpp(1, 0, kbase, kslide, tfp0, kcred) != KERN_SUCCESS) {
            [self log:@"ERROR: KPP bypass failed \n"];
            return;
        }
        LOG("fuck kpp, yolo kjc!");
        
        [self remount];
    });
}

- (void)remount {

    [self.progressView setProgress:0.5 animated:YES];
    [self log:@"Remounting..."];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{

        if (do_remount(kslide) != KERN_SUCCESS) {
            [self log:@"ERROR: failed to remount system partition \n"];
            return;
        }

        [self bootstrap];
  });
}

- (void)bootstrap {
    
    [self.progressView setProgress:0.6 animated:YES];
    [self log:@"Installing Cydia..."];
    
    BOOL force = NO;
    if (self.reinstallBootstrapLabel.hidden == NO) {
        force = YES;
        [self log:@"(forcing reinstall)"];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        if (do_bootstrap(force) != KERN_SUCCESS) {
            [self log:@"ERROR: failed to install Cydia \n"];
            return;
        }
        
        [self finish];
    });
}

- (void)finish {
    [self.progressView setProgress:1 animated:YES];
    [self log:@"SUCCESS: jailbreak done!"];

    [self.goButton setTitle:@"Already jailbroken" forState:UIControlStateDisabled];
    
    sleep(2);
    
    if (self.cydiaJailbreeakdLabel.hidden == NO) {
        // start launchdaemons ...
        LOG("reloading...");
        pid_t pid;
        posix_spawn(&pid, "/bin/launchctl", 0, 0, (char**)&(const char*[]){"/bin/launchctl", "load", "/Library/LaunchDaemons/0.reload.plist", NULL}, NULL);
        //waitpid(pid, 0, 0);
    }
    else {
        LOG("starting jailbreakd...");
        [self log:@"Waiting for Cydia, please open Cydia..."];
        extern void startJBD(void);
        startJBD();
    }
    
}

@end
