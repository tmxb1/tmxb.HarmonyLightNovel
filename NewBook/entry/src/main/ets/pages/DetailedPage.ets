import router from '@ohos.router'
import http from '@ohos.net.http'
import { GetDetailed,BookData } from '../model/GetDetailedData'
import {appStore} from '../model/lists'

interface ToDetailed{
  Booklink:string
}


@Entry
@Component
struct DetailedPage {
  @State BookSynopsis:string=''
  @State Booklink: string = '';
  @State data:BookData= {
    BookImg: '',
    BookName: '',
    BookAuthor: '',
    BookLastTime: '',
    BookWordage: '',
    BookTags: [],
    BookOver: '',
    AnimationBased: '',
    SumRecommend: '',
    WeekRecommend: '',
    BookSynopsis:''
  }
  @State isOver:boolean=false

  //获取页面传递信息，调用后端函数
  aboutToAppear() {
    //获取传递的数据
    const params = router.getParams() as ToDetailed;
    this.Booklink=params.Booklink
    console.log(this.Booklink)
    //传递给后端获取数据 post
    this.clickPostRequest()
  }

  //调用后端获取书籍详细信息 POST
  async clickPostRequest() {
    console.log('clickPostRequest:', this.Booklink)
    const httpRequest = http.createHttp();
    try {
      const response = await httpRequest.request("http://t2.pgrm.top:9744/Detailed", {
        method: http.RequestMethod.POST,
        expectDataType: http.HttpDataType.STRING, // 关键设置
        extraData: JSON.stringify({Booklink:this.Booklink}),
        header: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        }
      });

      if (response.responseCode === 200) {
        // console.log(response.result.toString())
        const stream: GetDetailed = JSON.parse(response.result as string);
        if (stream.status==true) {
          this.data=stream.data
          this.BookSynopsis=stream.data.BookSynopsis
          this.data.BookOver=='完结'?this.isOver=true:this.isOver=false
          console.log("data:",this.data.BookOver)
        }
      }
    } catch (err) {
      console.error("请求失败:", JSON.stringify(err));
    }
  }

  iflook(){
    return appStore.data.some(item => item.title === this.data.BookName.toString());

  }
  build() {
    Column(){
      //图片
      Column({space:10}){
        Image(this.data.BookImg)
          .width(190)
          .height(250)
        Column(){
          Text(this.data.BookName)
            .fontWeight(FontWeight.Bold)
            .fontSize(20)
            .textAlign(TextAlign.Center)
            .padding(10)
          Text(this.data.BookAuthor)
            .fontSize(18)
        }

      }
      .width('100%')
      .margin({top:10})

      //信息
      Column(){
        //信息栏
        Row(){
          Column({space:5}){
            Text(this.data.BookWordage)
              .fontWeight(FontWeight.Bold)
            Text(this.data.BookOver=='完结'?'完结':this.data.BookLastTime.slice(-11))
              .fontSize(13)
              .fontColor(Color.Grey)
          }
          .layoutWeight(1)
          Column({space:5}){
            Text(this.data.BookWordage)
              .fontWeight(FontWeight.Bold)
            Text(this.data.AnimationBased)
              .fontSize(13)
              .fontColor(Color.Grey)
          }
          .layoutWeight(1)
          Column({space:5}){
            Text(this.data.SumRecommend)
              .fontWeight(FontWeight.Bold)
            Text(this.data.WeekRecommend)
              .fontSize(13)
              .fontColor(Color.Grey)
          }
          .layoutWeight(1)
        }
        .width('100%')
        .padding(15)

        //简介
        Column({space:10}){
          Row(){
            Text('简介')
              .fontSize(17)
              .padding(5)
              .fontWeight(FontWeight.Bold)
              .backgroundColor("#66ccff")
              .margin(5)
            Flex({
              direction: FlexDirection.Row,   // 横向排列
              wrap: FlexWrap.Wrap,             // 允许换行
              justifyContent: FlexAlign.Start, // 左对齐
              alignItems: ItemAlign.End,    // 垂直居中
            }){
              ForEach(this.data.BookTags, (item: string, index: number) => {
                Text(item)
                  .fontColor("#808080")
                  .borderRadius(8)
                  .padding(5)
                  .backgroundColor("#D3D3D3")
                  .margin({left:3,right:3})
              })
            }
          }
          .alignItems(VerticalAlign.Center)

          Text(this.data.BookSynopsis[0])
            .fontSize(14)
            .height(150)
            .width('100%')
            .maxLines(10) // 最大显示行数为1
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .width('100%')
        .padding(15)
        .alignItems(HorizontalAlign.Start)

      }
      .width('100%')
      .layoutWeight(1)

      //按钮
      Column(){
        Row({space:5}){
          Button('开始阅读')
            .width('70%')
            .height(50)
            .fontSize(24)
            .borderRadius(10)
            .onClick(()=>{
              const url=this.Booklink.substring(0, this.Booklink.length-5)+'/catalog'
              console.log("url:",url)
              router.pushUrl({
                url: 'pages/DirectoryPage',
                params: {
                  url:url,
                  name:this.data.BookName,
                  isOver:this.isOver
                  //输送是否完结
                }
              })
            })

          if (!this.iflook()){
            Button('想看')
              .height(50)
              .layoutWeight(1)
              .borderRadius(10)
              .onClick(()=>{
                appStore.addItem({
                  title: this.data.BookName,
                  img:this.data.BookImg,
                  Booklink:this.Booklink,
                  type: 1
                })
                console.log('加入完成',JSON.stringify(appStore.data))
              })
          }else {
            Button('取消')
              .height(50)
              .backgroundColor(Color.Red)
              .layoutWeight(1)
              .borderRadius(10)
              .onClick(()=>{
                appStore.deleteItem(this.data.BookName)
                console.log('加入完成',JSON.stringify(appStore.data))
              })
          }

        }
        .alignItems(VerticalAlign.Bottom)
        .padding(10)
      }
      .width('100%')
    }
    .height('100%')
    .width('100%')
    .backgroundImage($r('app.media.back'))
    .backgroundImageSize(ImageSize.Cover)
  }
}