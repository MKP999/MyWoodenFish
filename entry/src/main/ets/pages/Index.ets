import { audio } from '@kit.AudioKit'
import { media } from '@kit.MediaKit'
import { BusinessError } from '@kit.BasicServicesKit'
import testNapi from 'libentry.so'  // 导入so
import data_preferences from '@ohos.data.preferences';

interface woodfishItem {
  id: number
  image: Resource
}

@Entry
@Component
struct Index {
  @State scaleValue: number = 1
  @State showText: boolean = false
  @State textOpacity: number = 1
  @State textOffsetY: number = 0
  @State showPanel: boolean = false
  @State customText: string = '功德 +1'
  @State currentWoodfish: Resource = $r('app.media.woodfish')  // 当前选中的木鱼
  @State selectedIndex: number = 0  // 添加索引状态：0表示第一个木鱼，1表示第二个木鱼
  @State currentTabIndex: number = 0  // 改名避免冲突 0手动 1自动
  @State autoPlayInterval: number = 1  // 自动播放间隔（秒），默认1秒
  @State currentAVIndex: number = 0
  private isClickable: boolean = true
  private autoPlayTimer: number = -1    // 添加定时器ID
  private soundPool: media.SoundPool | null = null
  private soundId: number = 0
  private streamId: number = 0
  private avList: string[] = [
    'https://img02.tuke88.com/newpreview_music/09/03/88/5c8aec3410f095551.mp3',
    'https://img02.tuke88.com/newpreview_music/09/00/71/5c89465032f0c47285.mp3',
    'https://img02.tuke88.com/newpreview_music/09/03/86/5c8ae9df2794690095.mp3',
    'https://img02.tuke88.com/newpreview_music/09/03/86/5c8ae9d99b14456943.mp3',
    'https://img02.tuke88.com/newpreview_music/09/03/88/5c8aec307bdd858225.mp3',
    'https://dst-app-pubread.oss-cn-shenzhen.aliyuncs.com/mtc/app/images/lowcode/ji.mp3'
  ]

  // 在 Index struct 内添加木鱼数据数组
  private woodfishList: woodfishItem[]  = [
    { id: 0, image: $r('app.media.woodfish') },
    { id: 1, image: $r('app.media.woodfish1') },
    { id: 2, image: $r('app.media.dog') },
    { id: 3, image: $r('app.media.pig') },
    { id: 4, image: $r('app.media.ji') }
  ]

  avPlayer: media.AVPlayer = null!

  // 在 Index struct 中添加点击计数状态
  @State clickCount: number = 0

  async  aboutToAppear() {

    // 初始化音频播放器
    this.avPlayer = await media.createAVPlayer()

    this.avPlayer.on("stateChange", (state) => {
      switch (state) {
        case 'initialized':
          this.avPlayer.prepare()
          break;

        case 'prepared':
          this.avPlayer.play()
          break;
      }
    })
  }


  // 播放音效
  private async playSound() {
    this.avPlayer.url = this.avList[this.currentAVIndex]
    setTimeout(() => {
      this.avPlayer.reset()
    }, 500)
  }

  // 清理音频资源
  private async cleanupSound() {
    if (!this.soundPool) return
    
    try {
      if (this.streamId) {
        await this.soundPool.stop(this.streamId)
      }
      if (this.soundId) {
        await this.soundPool.unload(this.soundId)
      }
      
      this.soundPool.off('loadComplete')
      this.soundPool.off('playFinished')
      this.soundPool.off('error')
      
      await this.soundPool.release()
      this.soundPool = null
    } catch (error) {
      const err = error as BusinessError
      console.error('Failed to cleanup sound:', err.message)
    }
  }


  aboutToDisappear() {
    this.cleanupSound()   // 清理音频
    this.stopAutoPlay()   // 保持原有的自动播放清理
  }

  @Builder tabBuilder(index: number, title: string) {
      Text(`${title}模式`)
        .fontColor(this.currentTabIndex === index ? '#FFFFFF' : '#666666')
        .lineHeight(20)
        .border({
          width: 2,
          color: this.currentTabIndex === index ? '#FFFFFF' : '#222222',
          radius: 10
        })
        .padding(10)
        .margin({
          right: 10
        })
        .onClick(() => {
            this.currentTabIndex = index
            if (index === 1) {
              this.startAutoPlay()
            } else {
              this.stopAutoPlay()
            }
            console.info('Switched to tab:', index)
        })
  }
  
  // 处理木鱼点击
  handleWoodFishClick() {
    if (!this.isClickable) return
    this.isClickable = false
    
    // 增加点击计数
    this.clickCount++
    // 保持原有的音频播放和动画效果
    this.playSound()

    // 保持原有的动画效果
    this.scaleValue = 0.9
    animateTo({ duration: 200 }, () => {
      this.scaleValue = 1
    })
    
    this.showText = true
    this.textOpacity = 1
    this.textOffsetY = 0
    animateTo({ duration: 1000 }, () => {
      this.textOpacity = 0
      this.textOffsetY = -100
    })
    
    setTimeout(() => {
      this.showText = false
      this.isClickable = true
    }, 500)
  }

  // 开始自动播放
  startAutoPlay() {
    this.stopAutoPlay()
    this.autoPlayTimer = setInterval(() => {
      this.handleWoodFishClick()
    }, this.autoPlayInterval * 1000)  // 转换为毫秒
    console.info(`Auto play started with interval: ${this.autoPlayInterval}s`)
  }

  // 停止自动播放
  stopAutoPlay() {
    if (this.autoPlayTimer !== -1) {
      clearInterval(this.autoPlayTimer)
      this.autoPlayTimer = -1
      console.info('Auto play stopped')
    }
  }

  @Builder
  settingsBuilder() {
    Column() {
      // 标题栏
      // Row() {
      //   Text('设置')
      //     .fontSize(20)
      //     .fontColor('#FFFFFF')
      //   Blank()
      //   Image($r('app.media.close'))
      //     .width(24)
      //     .height(24)
      //     .onClick(() => {
      //       this.showPanel = false
      //     })
      // }
      // .width('100%')
      // .padding({ left: 16, right: 16, top: 8, bottom: 8 })

      // 设置内容
      Scroll() {
        Column() {
          // 输入框
          TextInput({ 
            placeholder: '请输入显示文案',
            text: this.customText
          })
            .width('90%')
            .height(40)
            .margin({ top: 24, bottom: 24 })
            .backgroundColor('#333333')
            .placeholderColor('#999999')
            .fontColor('#FFFFFF')
            .maxLength(20)
            .onChange((value: string) => {
              // 直接更新文本
              this.customText = value || ''
            })
          
          // 木鱼样式选择器
          Text('皮肤')
            .fontSize(16)
            .fontColor('#FFFFFF')
            .margin({ bottom: 12 })
            .textAlign(TextAlign.Start)
            .width('90%')


          // 木鱼选择部分
          Row() {
            ForEach(this.woodfishList, (item: woodfishItem) => {
              Stack() {
                // 背景和边框容器
                Column()
                  .width(50)
                  .height(40)
                  .backgroundColor('#222222')
                  .border({
                    width: this.selectedIndex === item.id ? 1 : 0,
                    color: '#FFFFFF',
                    style: BorderStyle.Solid
                  })
                  .borderRadius(8)
                
                // 木鱼图片
                Image(item.image)
                  .width(42)
                  .height(32)
                  .padding(4)
                  .objectFit(ImageFit.Cover)
                  .onClick(() => {
                    this.selectedIndex = item.id
                    this.currentWoodfish = item.image
                    console.info(`Selected woodfish ${item.id + 1}`)
                  })
              }
              .margin({ right: item.id !== this.woodfishList.length - 1 ? 12 : 0 })
            }, (item: woodfishItem) => JSON.stringify(item))
          }
          .width('90%')
          .margin({ bottom: 24 })
          .justifyContent(FlexAlign.Start)

          Text('模式')
            .fontSize(16)
            .fontColor('#FFFFFF')
            .margin({ bottom: 12 })
            .textAlign(TextAlign.Start)
            .width('90%')

          Row() {
            this.tabBuilder(0, '手动')
            this.tabBuilder(1, '自动')
          }
          .margin({ bottom: 16 })
          .justifyContent(FlexAlign.Start)
          .width('90%')

          // 音色
          // 自动模式的内容
          Column() {
            Text('音色')
              .fontSize(16)
              .fontColor('#FFFFFF')
              .margin({ bottom: 12, top: 12 })
              .textAlign(TextAlign.Start)
              .width('90%')

            Row() {
              // 1-5秒的选项
              ForEach(this.avList, (av: string, index: number) => {
                Column() {
                  // Text(index.toString())
                  //   .fontSize(16)
                  //   .fontColor(this.currentAVIndex === index ? '#FFFFFF' : '#666666')
                    Image($r("app.media.listening_fill"))
                      .width(32)
                      .height(32)
                }
                .width(42)
                .height(42)
                .justifyContent(FlexAlign.Center)
                .backgroundColor(this.currentAVIndex === index ? '#333333' : 'transparent')
                .border({
                  width: this.currentAVIndex === index ? 2 : 0,
                  color: '#FFFFFF',
                  style: BorderStyle.Solid
                })
                .borderRadius(8)
                .margin({ right: index !== 5 ? 12 : 0 })
                .onClick(() => {
                  if (this.currentAVIndex !== index) {
                    this.currentAVIndex = index
                    // 立即播放一次新音色的音效
                    this.playSound()
                    if (this.currentTabIndex === 1) {
                      this.startAutoPlay()
                    }
                  }
                })
              }, (item: string) => item)
            }
            .width('100%')
            .justifyContent(FlexAlign.Start)
            .margin({ top: 8, bottom: 8 })
          }
          .alignItems(HorizontalAlign.Start)
          .width('90%')
          .backgroundColor('#222222')

          // 自动模式的间隔选择（根据currentTabIndex显示/隐藏）
            if (this.currentTabIndex === 1) {
              // 自动模式的内容
              Column() {
                Text('自动敲击间隔（秒）')
                  .fontSize(16)
                  .fontColor('#FFFFFF')
                  .margin({ bottom: 12, top: 12 })
                  .textAlign(TextAlign.Start)
                  .width('90%')

                Row() {
                  // 1-5秒的选项
                  ForEach([1, 2, 3, 4, 5], (seconds: number) => {
                    Column() {
                      Text(seconds.toString())
                        .fontSize(16)
                        .fontColor(this.autoPlayInterval === seconds ? '#FFFFFF' : '#666666')
                    }
                    .width(48)
                    .height(48)
                    .justifyContent(FlexAlign.Center)
                    .backgroundColor(this.autoPlayInterval === seconds ? '#333333' : 'transparent')
                    .border({
                      width: this.autoPlayInterval === seconds ? 2 : 0,
                      color: '#FFFFFF',
                      style: BorderStyle.Solid
                    })
                    .borderRadius(8)
                    .margin({ right: seconds !== 5 ? 12 : 0 })
                    .onClick(() => {
                      if (this.autoPlayInterval !== seconds) {
                        this.autoPlayInterval = seconds
                        if (this.currentTabIndex === 1) {
                          this.startAutoPlay()
                        }
                      }
                    })
                  }, (item: number) => item.toString())
                }
                .width('100%')
                .justifyContent(FlexAlign.Start)
                .margin({ top: 8, bottom: 8 })
              }
              .alignItems(HorizontalAlign.Start)
              .width('90%')
              .backgroundColor('#222222')
            }
        }
        .width('100%')
        .padding(16)
      }
    }
    .width('100%')
    .backgroundColor('#222222')
  }

  build() {
    Stack() {
      // 添加计数显示
      Column() {
        Text(`${this.clickCount}`)
          .fontSize(30)
          .fontColor('#FFFFFF')
          .margin({ top: 50 })  // 调整位置
          .fontWeight(FontWeight.Bold)
      }
      .width('100%')
      .position({ x: 0, y: 0 })
      .margin({ top: 50 })
      .zIndex(1)  // 确保显示在最上层

      Stack() {
        Stack() {
          // 使用当前选中的木鱼图片
          Image(this.currentWoodfish)
            .width(250)
            .height(200)
            .scale({ x: this.scaleValue, y: this.scaleValue })
            .onClick(() => {
              this.handleWoodFishClick()
            })

          if (this.showText) {
            Text(this.customText)
              .fontSize(24)
              .fontColor('#FFFFFF')
              .opacity(this.textOpacity)
              .translate({ y: this.textOffsetY })
              .animation({ duration: 1000 })
              .maxLines(1)
              .position({
                // 根据文字长度动态计算x位置
                x: `${Math.max(0, 70 - this.customText.length * 4)}%`,  // 每个字减少5%，最小为0%              
                y: '-5%'    // 调整到木鱼上方
              })
              .constraintSize({
                maxWidth: '100%'
              })
              .padding({ left: 8, right: 8 })
          }
        }

        // 设置图标
        Image($r('app.media.setting'))
          .width(32)
          .height(32)
          .position({ x: 16, y: 16 })
          .onClick(() => {
            this.showPanel = true
          })
          .bindSheet($$this.showPanel, this.settingsBuilder(), {
            height: '90%',
            dragBar: true,
            backgroundColor: '#222222',
            onWillAppear: () => {
              console.info('Settings panel will appear')
            },
            onAppear: () => {
              console.info('Settings panel appeared')
            },
            onWillDisappear: () => {
              console.info('Settings panel will disappear')
            },
            onDisappear: () => {
              console.info('Settings panel disappeared')
            }
          })

      }
      .width('100%')
      .height('100%')
      .backgroundColor('#000000')
    }
    
  }
}
