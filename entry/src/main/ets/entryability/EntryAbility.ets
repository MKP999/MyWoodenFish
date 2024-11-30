import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import Window from '@ohos.window';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
  }

  onDestroy(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: Window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    // 设置状态栏和导航栏颜色
    windowStage.getMainWindow(async (err, window) => {
      if (err.code) {
        console.error('Failed to get the main window. Cause: ' + JSON.stringify(err));
        return;
      }
      
      try {
        // 先设置窗口为全屏模式
        await window.setFullScreen(true);
        
        // 设置状态栏和导航栏属性
        await window.setWindowSystemBarProperties({
          statusBarColor: '#222222',
          navigationBarColor: '#222222',
          statusBarContentColor: '#FFFFFF',
          navigationBarContentColor: '#FFFFFF',
          isStatusBarLightIcon: true,
          isNavigationBarLightIcon: true
        });

        console.info('System bar properties set successfully');
      } catch (error) {
        console.error('Failed to set system bar properties:', error);
      }
    });

    // 加载主页面
    windowStage.loadContent('pages/Index');
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onBackground');
  }
}
