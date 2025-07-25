import { router } from '@kit.ArkUI';
import { http } from '@kit.NetworkKit';
import { ToDirectory,Data,title,GetBookDirectoryData } from '../model/GetBookDirectoryData'

@Entry
@Component
struct DirectoryPage {
  @State url:string=''
  @State data:Data[]=[]
  @State name:string=''
  @Prop isOver:boolean=false
  //测试数据
  // @State DirectoryData:Data[]=[{
  //   NovelVolumeTitle:'Silent Witch 沉默魔女的秘密 第一卷',
  //   Title:[{
  //     TitleName:"插图",
  //     TitleLink:"/novel/2979/148077"
  //   },{
  //     TitleName:"序章 沃岗的黑龙",
  //     TitleLink:"/novel/2979/148078"
  //   },{
  //     TitleName:"插图",
  //     TitleLink:"/novel/2979/148079"
  //   },{
  //     TitleName:"插图",
  //     TitleLink:"/novel/2979/148080"
  //   }]
  // },{
  //   NovelVolumeTitle:'Silent Witch 沉默魔女的秘密 第一卷',
  //   Title:[{
  //     TitleName:"插图",
  //     TitleLink:"/novel/2979/148077"
  //   },{
  //     TitleName:"序章 沃岗的黑龙",
  //     TitleLink:"/novel/2979/148078"
  //   },{
  //     TitleName:"插图",
  //     TitleLink:"/novel/2979/148079.html"
  //   },{
  //     TitleName:"插图",
  //     TitleLink:"/novel/2979/148080.html"
  //   }]
  // }]
  //获取页面传递信息，调用后端函数
  aboutToAppear() {
    //获取传递的数据
    const params = router.getParams() as ToDirectory;
    this.url=params.url
    this.name=params.name
    this.isOver=params.isOver

    //true 加入书架（想看，在看，已看）
    //false 未加入

    // 传递给后端获取数据 fet
    this.GetBookDirectory()
  }

  async GetBookDirectory() {
    // console.log("GetBookDirectory url:",this.url)
    const httpRequest = http.createHttp();
    try {
      const response = await httpRequest.request(`http://t2.pgrm.top:9744/Directory?url=${this.url}`, {
        method: http.RequestMethod.GET,
        expectDataType: http.HttpDataType.STRING, // 关键设置
        header: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        }
      });

      if (response.responseCode === 200) {
        const stream:GetBookDirectoryData = JSON.parse(response.result as string);
        if (stream.status==true) {
          console.log("stream.data:",JSON.stringify(stream.data))
          this.data=stream.data
        }
      }
    } catch (err) {
      console.error("请求失败:", JSON.stringify(err));
    }
  }

  build() {
    Column(){
      Column(){
        Text(this.name)
          .padding(20)
          .fontWeight(FontWeight.Bold)
          .fontSize(22)
          .textAlign(TextAlign.Center)
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      List({space:40}){
        ForEach(this.data, (item: Data, index: number) => {
          ListItem() {
            Column({space:10}){
              //卷名
              Row({space:5}){
                Row()
                  .width(10)
                  .backgroundColor("#66ccff")
                  .height(20)
                Text(item.NovelVolumeTitle)
                  .fontWeight(FontWeight.Bold)
                  .fontSize(18)
              }
              .width('100%')
              .padding(4)

              //标题名
              Column({space:6}){
                ForEach(item.Title, (items: title, indexs: number) => {
                  Text(items.TitleName)
                    .textAlign(TextAlign.Start)
                    .fontSize(18)
                    // .width('100%')
                    .padding(6)
                    .maxLines(2) // 最大显示行数为1
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .onClick(()=>{
                      router.pushUrl({
                        url: 'pages/ReadingPage',
                        params: {
                          BookName:this.name,
                          Link:'https://www.linovelib.com'+items.TitleLink,
                          isOver:this.isOver
                        }
                      })
                    })



                })
              }
              .alignItems(HorizontalAlign.Start)
              .width('100%')
            }
          }
          .backgroundColor("#f8f8f8")
          .borderRadius(5)
        })
      }
      .divider({strokeWidth:2,color:"#66ccff"})
      .scrollBar(BarState.Auto)
      .padding(8)
      .layoutWeight(1)
      .width('100%')


    }
    .width('100%')
    .height('100%')
  }
}