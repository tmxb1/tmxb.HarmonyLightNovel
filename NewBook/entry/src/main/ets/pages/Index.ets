import {appStore} from '../model/lists'
import BookShelfPage from './BookShelfPage'
import SearchPage from './SearchPage'
import ClassificationPage from './ClassificationPage'
import font from '@ohos.font';
import { common, Want } from '@kit.AbilityKit';
import featureAbility from '@ohos.ability.featureAbility';
import wantConstant from '@ohos.ability.wantConstant';
import { router } from '@kit.ArkUI';

interface GeneratedObjectLiteralInterface_1 {
  action: string;
  uri: string;
  type: string;
}

@Entry
@Component
struct Index {
  @State onClickindex:number=0
  // @State showAgreementDialog: boolean = true // 控制弹窗显示状态
  private context = getContext(this) as common.UIAbilityContext;

  @Builder
  mybuilder(text:string,img:string,showimg:string,index:number){
    Column(){
      Image(this.onClickindex==index?$r(showimg):$r(img))
        .width(25)
      Text(text)
        .fontColor(this.onClickindex==index?'#66ccff':Color.Black)
    }
    .width('100%')
    .height(56)
    .margin({top:6})
  }
  aboutToAppear(): void {//在组件加载时，自动调用==生命周期函数
    appStore.forceUpdate();
    //注册字体
    font.registerFont({
      familyName:'novel',
      familySrc:'/fonts/iconfont.ttf'
    })

  }
  ToWeb(url:string){
    // console.log("https://www.linovelib.com"+MiniLink)
    router.pushUrl({
      url: 'pages/webPage',
      params: {
        url:url
      }
    })
  }

  // 构建协议弹窗
  @Builder
  AgreementDialog() {
    Column(){
      Column() {
        Text('用户协议')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .margin({ top: 20, bottom: 10 })

        Text() {
          Span('欢迎使用本应用！请仔细阅读')
            .fontSize(16)
          Span('《免责声明》')
            .fontSize(16)
            .fontColor(Color.Blue) // 设置为蓝色
            .onClick(()=>{
              this.ToWeb('1')
            })
          Span('和')
            .fontSize(16)
          Span('《隐私政策》')
            .fontSize(16)
            .fontColor(Color.Blue)
            .onClick(()=>{
              this.ToWeb('2')
            })
          Span('，我们将严格遵守相关法律法规，保护您的个人信息安全。')
            .fontSize(16)
        }
          .fontSize(16)
          .padding(10)
          .textAlign(TextAlign.Center)

        Row() {
          Button('取消', { type: ButtonType.Normal })
            .width(120)
            .height(40)
            .fontColor(Color.Black)
            .backgroundColor(Color.White)
            .borderColor('#66ccff')
            .borderWidth(1)
            .onClick(() => {
              // 退出应用
              let context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
              context.terminateSelf();
            })

          Button('启动', { type: ButtonType.Normal })
            .width(120)
            .height(40)
            .margin({ left: 20 })
            .backgroundColor('#66ccff')
            .onClick(() => {
              // 同意协议
              appStore.showAgreementDialog=true
            })
        }
        .margin({ top: 20, bottom: 20 })
      }
      .width('80%')
      .backgroundColor(Color.White)
      .borderRadius(16)
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .width('100%')
    .height('100%')
    .backgroundColor('rgba(255,255,255,0.5)')

  }

  build() {
    Stack(){
      Column(){
        Tabs({barPosition:BarPosition.End}){
          TabContent(){
            Column(){

              BookShelfPage({
                listdata:appStore.data
              })
            }

          }
          .tabBar(this.mybuilder('书架','app.media.bookshelf','app.media.bookshelf_click',0))

          TabContent(){
            SearchPage()
          }
          .tabBar(this.mybuilder('搜索','app.media.search','app.media.search_chilk',1))

          TabContent(){
            ClassificationPage()
          }
          .tabBar(this.mybuilder('分类','app.media.classification','app.media.classification_chilk',2))
        }

        .onChange((Index:number)=>{
          this.onClickindex=Index
        })
      }
      .width('100%')
      .height('100%')
      if (appStore.showAgreementDialog==false) {
        this.AgreementDialog()
      }
    }
  }
}