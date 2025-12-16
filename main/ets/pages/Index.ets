import { webview } from '@kit.ArkWeb';
import { promptAction, router } from '@kit.ArkUI';
import { saveHomeUrl, getHomeUrl } from '../model/StorageService';
@Entry
@Component

struct Index {
  private isRefreshing: boolean = false;
  controller: webview.WebviewController = new webview.WebviewController();
  @State refreshing: boolean = false
  @State list: number[] = Array(20).fill(Date.now())
  @State is_home:boolean = false
  @State showDialog: boolean = false;
  @State home_url: string = ''
  @State saved_home_url: string = 'baidu.com';
  @State showTopRow: boolean = false
  @State showRefreshRow: boolean = true
  @State showButtonRow: boolean = true
  @State refreshTimerId: number | null = null;

  async aboutToAppear() {
    this.saved_home_url = await getHomeUrl()||this.saved_home_url;
    setTimeout(() => {
      this.backToHome();
    }, 200);
  }

  @Builder
  content(){
    Stack(){
      Column() {
        Row() {
          TextInput({
            placeholder: '请输入有效的URL地址',
            text: this.saved_home_url
          })
            .height(32)
            .width("80%")
            .onChange((value) => {
              this.home_url = value;
            })

          Button('保存')
            .height(32)
            .width("15%")
            .type(ButtonType.Capsule)
            .backgroundColor(Color.Blue)
            .onClick(() => {
              if (this.home_url) {
                saveHomeUrl(this.home_url);
                this.saved_home_url = this.home_url
                this.backToHome();
              }
              this.showTopRow = false
              this.showRefreshRow = true
              this.showButtonRow = true
              this.onRefreshing();
            })
        }
        .visibility(this.showTopRow ? Visibility.Visible : Visibility.None)
        .height(40)
        .width("100%")
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.SpaceAround)
        Row() {
          LoadingProgress()
            .height(32)
          Text('正在刷新...')
            .fontSize(16)
            .margin({ left: 20 })
        }
        .visibility(this.showRefreshRow ? Visibility.Visible : Visibility.None)
        .alignItems(VerticalAlign.Center)
        Row() {
          Button("*")
            .onClick(()=>{
              this.showTopRow = true
              this.showRefreshRow = false
              this.showButtonRow = false
              this.cancelRefresh()
            })
            .height(32)
            .width("10%")
          Button("清除缓存")
            .onClick(()=>{
              this.controller.removeCache(true)
            })
            .height(32)
            .width("25%")
          Button("返回首页")
            .onClick(()=>{
              this.is_home = true
              this.backToHome()
              setTimeout(() => {
                this.is_home = false
              }, 1000);
            })
            .height(32)
            .width("60%")

        }
        .visibility(this.showButtonRow ? Visibility.Visible : Visibility.None)
        .padding({top:5,bottom:5})
        .height(40)
        .width("100%")
        .alignItems(VerticalAlign.Center)
        .backgroundColor(Color.Pink)
        .justifyContent(FlexAlign.SpaceAround)
      }
    }

  }


  build() {

    Refresh({ refreshing: $$this.refreshing, builder: this.content() }) {
      NavDestination() {
        Column() {
          Web({ src: this.saved_home_url, controller: this.controller })
            .domStorageAccess(true)
        }
        .width("100%")
        .height("100%")
      }
    }
    .backgroundColor(Color.Pink)
    .onRefreshing(() => this.onRefreshing())

  }
  onBackPress() {
    // 当前页面是否可前进或者后退给定的step步(-1),正数代表前进，负数代表后退
    if (this.controller.accessStep(-1)) {
      this.controller.backward(); // 返回上一个web页
      return true
    } else {
      return false
    }
  }

  onRefreshing() {
    // 设置新的定时器
    this.refreshTimerId = setTimeout(() => {
      this.list = Array(20).fill(Date.now());
      this.refreshing = false;

      if (!this.is_home) {
        this.refreshWeb();
        this.is_home = false;
        promptAction.showToast({ message: '刷新成功' });
      }
    }, 1000);
  }

  // 统一清除定时器方法
  private clearRefreshTimer() {
    if (this.refreshTimerId !== null) {
      clearTimeout(this.refreshTimerId);
      this.refreshTimerId = null;
    }
  }

  private refreshWeb() {
    if (this.isRefreshing) return;
    this.isRefreshing = true;
    // 执行刷新
    this.controller.refresh();

    //刷新完成后恢复
    setTimeout(() => {
      this.isRefreshing = false;
    }, 1000);
  }

  // 中断刷新函数
  private cancelRefresh() {
    this.clearRefreshTimer(); // 统一清除
    this.isRefreshing = true;
    this.refreshing = true;
    this.controller.stop();
  }

  // 返回首页
  backToHome() {
      this.controller.loadUrl(this.saved_home_url);
  }



}
