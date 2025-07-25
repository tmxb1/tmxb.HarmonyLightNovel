import { router } from '@kit.ArkUI';
import {ToRouterData,GetReadingData,PageInformation,RouteData} from '../model/ReadingData'
import { http } from '@kit.NetworkKit';
import {appStore} from '../model/lists'
@Entry
@Component
struct ReadingPage {
  private CountList: ListScroller = new ListScroller();
  @State articleData: PageInformation={NovelVolumes:'',content:'',title:''}
  @State NovelName:string=''
  @Prop isOver:boolean=false
  // @State title:string=''
  // @State NovelVolume:string=''
  @State url:string=''
  @State rout:RouteData[]=[]
  aboutToAppear() {
    //获取传递的数据
    const params = router.getParams() as ToRouterData;
    this.NovelName=params.BookName.toString()
    // this.title=params.title.toString()
    // this.NovelVolume=params.NovelVolume.toString()
    this.url=params.Link.toString()
    this.isOver=params.isOver
    //获取数据
    this.GetBookDirectory()
    
    setTimeout(() => {
      console.log("0.9秒后执行的操作");
      //判断type，更改为在读
      appStore.ChangeType(this.NovelName,2)
      //判断type，更改为完结
      console.log(JSON.stringify(appStore))
    }, 1300);
  }



  async GetBookDirectory() {
    const httpRequest = http.createHttp();
    try {
      console.log("url:http://192.168.102.7:5000/get_Reading?url="+this.url)
      const response = await httpRequest.request("http://t2.pgrm.top:9744/get_Reading?url="+this.url, {
        method: http.RequestMethod.GET,
        expectDataType: http.HttpDataType.STRING,
        header: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        }
      });

      if (response.responseCode === 200) {
        const stream:GetReadingData = JSON.parse(response.result as string);
        console.log("stream:",JSON.stringify(stream))
        console.log("data:",JSON.stringify(stream.content))
        if (stream.status) {
          this.articleData = stream.content;
          this.rout=stream.roust;
          if (this.isOver==true && this.rout[0]?.next?.text=='返回书页') {
            appStore.ChangeType(this.NovelName,3)
          }

          // console.log("articleData:",JSON.stringify(this.articleData))
          console.log("previous:",JSON.stringify(this.rout))
          console.log("articleData:",JSON.stringify(this.articleData))
        }

      }
    } catch (err) {
      console.error("请求失败:", err);
    }
  }

  build() {
    Column(){
      Row(){
        Text(this.NovelName)
          .fontSize(12)
          .padding(5)
          .width(100)
        Text(">")
          .fontSize(12)
        Text(this.articleData.NovelVolumes)
          .fontSize(12)
          .padding(5)
          .width(150)
      }
      .padding(10)
      .width('100%')
      Column(){
        List({scroller:this.CountList}) {
          ListItem(){
            Column(){
              Text(this.articleData?.title)
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .textAlign(TextAlign.Center)

              RichText(this.articleData?.content)
            }
            .width('100%')
          }
        }
      }
      .width('100%')
      .layoutWeight(1)
      Row(){
        if (this.rout[0]?.previous?.text!='返回目录'){
          Image($r("app.media.arrow_circle_left"))
            .height(30)
            .width(30)
            .margin({left:20})
            .onClick(()=>{
              //移动到顶端
              this.CountList.scrollTo({
                xOffset: 0,
                yOffset: 0, // 滚动到顶部
                animation: {
                  duration: 500, // 动画时长（ms）
                  curve: Curve.EaseOut // 缓动曲线
                }
              });

              this.url="https://www.linovelib.com"+this.rout[0]?.previous?.link
              console.log("url:",this.url,'\n调用函数！！！')
              this.GetBookDirectory()

            })
        }else {
          Text(" ")
            .width(30)
        }
        Text('返回目录')
          .onClick(()=>{
            router.back()
          })
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        if (this.rout[0]?.next?.text!='返回书页'){
          Image($r("app.media.arrow_circle_right"))
            .height(30)
            .width(30)
            .margin({right:20})
            .onClick(()=>{
              //移动到顶端
              this.CountList.scrollTo({
                xOffset: 0,
                yOffset: 0, // 滚动到顶部
                animation: {
                  duration: 500, // 动画时长（ms）
                  curve: Curve.EaseOut // 缓动曲线
                }
              });
              this.url="https://www.linovelib.com"+this.rout[0]?.next?.link
              console.log("url:",this.url,'\n调用函数！！！')
              this.GetBookDirectory()


            })
        }else {
          Text(" ")
            .width(30)
        }

      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .padding(5)
      .zIndex(1)
      .backgroundColor("rgba(255,255,255,0.1)")
    }
    .width('100%')
    .height('100%')
  }
}



