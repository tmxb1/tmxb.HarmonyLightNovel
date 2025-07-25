import {SearchData,GetSearchData} from '../model/SearchData'
import ChartsPage from './ChartsPage'
import { router } from '@kit.ArkUI'
import { http } from '@kit.NetworkKit'

@Component
struct SearchRoom{
  @Prop listdata:SearchData[]=[]
  @Prop input_switch:boolean=false//是否显示书本
  build() {
    Column(){
      if (this.listdata.length>0){
        //搜索到数据
        List({space:5}) {
          ForEach(this.listdata, (item: SearchData, index: number) => {
            ListItem() {
              Column(){
                Image(item.BookImg)
                  .width(100)
                  .height(140)
                Text(item.BookName)
                  .fontSize(13)
                  .textAlign(TextAlign.Center)
                  .width('100%')
                  .maxLines(1) // 最大显示行数为1
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                Text(item.BookAuther)
                  .fontSize(11)
                  .textAlign(TextAlign.Center)
                  .width('100%')
                  .maxLines(1) // 最大显示行数为1
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
              }
              .padding(3)
              .width('100%')
              .justifyContent(FlexAlign.Center)
              .alignItems(HorizontalAlign.Center)
              .onClick(()=>{
                console.log(item.BookLink)
                router.pushUrl({
                  url: 'pages/DetailedPage',
                  params: {
                    Booklink:"https://www.linovelib.com"+item.BookLink
                  }
                })
              })

            }
          })
        }
        .lanes(3,5)
        .scrollBar(BarState.Auto)
        .margin({bottom:100})
      }else if (this.input_switch==true){
        //没有找到书籍
        Column(){
          Text('未找到书籍')
            .fontWeight(FontWeight.Bold)
            .margin({top:-150})
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      }else {
        //排行榜
        ChartsPage()
          .width('100%')
          .height('100%')

      }

    }
  }
}


@Entry
@Component
struct SearchPage {
  @Prop listdata:SearchData[]=[]
  @State input_text:string=''//输入框数据
  @State input_switch:boolean=false//是否显示书本

  async GetSearchBook(input_text:string): Promise<number> {
    const httpRequest = http.createHttp();
    console.log("stream.dataq前:1"+input_text)
    try {
      const response = await httpRequest.request(`http://t2.pgrm.top:9744/Search?input=${input_text}`, {
        method: http.RequestMethod.GET,
        expectDataType: http.HttpDataType.STRING, // 关键设置
        header: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        }
      });

      if (response.responseCode === 200) {
        const stream:GetSearchData = JSON.parse(response.result as string);
        if (stream.status==true) {
          console.log("stream.data:",JSON.stringify(stream.data))
          this.listdata = stream.data;
          console.log("listdata:",this.listdata.length)
          if (this.listdata.length>0){
            this.input_switch=false
          }else {
            this.input_switch=true
          }
        }
      }
    } catch (err) {
      console.error("请求失败:", JSON.stringify(err));
    }
    return 0
  }

  //搜索函数
  SearchBook(input_text:string) {
    console.log("input_text:",input_text.length)
    if (input_text.length==0){
      this.listdata=[]
      this.input_switch=false
    }else {
      const len= this.GetSearchBook(input_text)
      console.log("长度：",JSON.stringify(len))
    }
	}

  build() {
    Column(){
      //顶部
      Row(){
        Text("搜索")
          .fontSize(28)
          .padding(5)
          .backgroundColor('#66ccff')
          .fontColor(Color.White)
          .fontWeight(FontWeight.Bold)
        // .backgroundColor(Color.Pink)
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .width('100%')
      .height(50)
      .padding({left:20,right:20})

      //搜搜栏
      Column(){
        Row({space:10}){
         TextInput({
           placeholder:'请输入书名或作者',
           text:$$this.input_text
         })
           .width('90%')
           .border({width:1,color:'#66ccff'})
           .onSubmit(()=>{
             this.SearchBook(this.input_text)

           })
          Text('\ue600')
            .fontFamily('novel')
            .fontSize(26)
            .fontColor('#66ccff')
            .onClick(()=>{
              this.SearchBook(this.input_text)
            })
        }


      }
      .justifyContent(FlexAlign.Start)
      .width('100%')
      .padding(20)

      //内容
      Column(){
        SearchRoom({
          listdata:this.listdata,
          input_switch:this.input_switch
        })
      }
      .width('100%')
    }
    .width('100%')
    .height('100%')
  }
}

export default SearchPage