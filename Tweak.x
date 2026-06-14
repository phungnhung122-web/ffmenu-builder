// Menu hack Free Fire cho iOS (jailbreak required)
// Chú thích kỹ thuật bằng tiếng Nga

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// Адрес смещений для версии Free Fire 1.96.2 (arm64)
#define OFFSET_ESP 0x1045C3A8
#define OFFSET_AIMBOT 0x1045C3B0
#define OFFSET_NO_RECOIL 0x1045C3B8
#define OFFSET_DAMAGE_MULT 0x1045C3C0

@interface FFMenu : UIViewController
@property (nonatomic, strong) UIWindow *overlayWindow;
@property (nonatomic, assign) BOOL espEnabled;
@property (nonatomic, assign) BOOL aimbotEnabled;
@property (nonatomic, assign) BOOL noRecoil;
@property (nonatomic, assign) float damageMultiplier;
@end

@implementation FFMenu

- (void)loadView {
    self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.7];
    self.view.userInteractionEnabled = YES;
    
    UIButton *espBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    espBtn.frame = CGRectMake(20, 100, 120, 44);
    [espBtn setTitle:@"ESP Вкл/Выкл" forState:UIControlStateNormal];
    [espBtn addTarget:self action:@selector(toggleESP) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:espBtn];
    
    UIButton *aimBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    aimBtn.frame = CGRectMake(20, 160, 120, 44);
    [aimBtn setTitle:@"Aimbot" forState:UIControlStateNormal];
    [aimBtn addTarget:self action:@selector(toggleAimbot) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:aimBtn];
    
    UIButton *recoilBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    recoilBtn.frame = CGRectMake(20, 220, 140, 44);
    [recoilBtn setTitle:@"No Recoil" forState:UIControlStateNormal];
    [recoilBtn addTarget:self action:@selector(toggleNoRecoil) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:recoilBtn];
    
    UIButton *damageBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    damageBtn.frame = CGRectMake(20, 280, 160, 44);
    [damageBtn setTitle:@"Damage x5" forState:UIControlStateNormal];
    [damageBtn addTarget:self action:@selector(setDamageMultiplier) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:damageBtn];
    
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    closeBtn.frame = CGRectMake(20, 340, 100, 44);
    [closeBtn setTitle:@"Закрыть" forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(closeMenu) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeBtn];
}

- (void)writeMemoryAtAddress:(uint64_t)address withValue:(uint32_t)value {
    // Запись через task_for_pid (требует root)
    kern_return_t kr;
    task_t targetTask;
    kr = task_for_pid(mach_task_self(), getpid(), &targetTask);
    if (kr != KERN_SUCCESS) return;
    vm_write(targetTask, address, (vm_offset_t)&value, sizeof(value));
}

- (void)toggleESP {
    self.espEnabled = !self.espEnabled;
    uint32_t val = self.espEnabled ? 0x1 : 0x0;
    [self writeMemoryAtAddress:OFFSET_ESP withValue:val];
    NSLog(@"[FFMenu] ESP установлен: %d", self.espEnabled);
}

- (void)toggleAimbot {
    self.aimbotEnabled = !self.aimbotEnabled;
    uint32_t val = self.aimbotEnabled ? 0x1 : 0x0;
    [self writeMemoryAtAddress:OFFSET_AIMBOT withValue:val];
    NSLog(@"[FFMenu] Aimbot: %d", self.aimbotEnabled);
}

- (void)toggleNoRecoil {
    self.noRecoil = !self.noRecoil;
    uint32_t val = self.noRecoil ? 0x0 : 0x1;
    [self writeMemoryAtAddress:OFFSET_NO_RECOIL withValue:val];
    NSLog(@"[FFMenu] Отдача отключена: %d", self.noRecoil);
}

- (void)setDamageMultiplier {
    self.damageMultiplier = 5.0f;
    uint32_t val = *(uint32_t*)&self.damageMultiplier;
    [self writeMemoryAtAddress:OFFSET_DAMAGE_MULT withValue:val];
    NSLog(@"[FFMenu] Урон умножен на %.1f", self.damageMultiplier);
}

- (void)closeMenu {
    [self.overlayWindow setHidden:YES];
    self.overlayWindow = nil;
}

@end

// Инжектор через Cydia Substrate
%ctor {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        window.windowLevel = UIWindowLevelAlert + 1;
        FFMenu *menuVC = [[FFMenu alloc] init];
        menuVC.overlayWindow = window;
        window.rootViewController = menuVC;
        [window makeKeyAndVisible];
        
        // Жест три пальца для вызова меню
        UISwipeGestureRecognizer *swipeUp = [[UISwipeGestureRecognizer alloc] initWithTarget:menuVC action:@selector(closeMenu)];
        swipeUp.direction = UISwipeGestureRecognizerDirectionUp;
        swipeUp.numberOfTouchesRequired = 3;
        [window addGestureRecognizer:swipeUp];
    });
}
