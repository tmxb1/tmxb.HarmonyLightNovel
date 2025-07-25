import router from '@ohos.router'
import {lists,appStore} from '../model/lists'
import http from '@ohos.net.http'
@Extend(Text) function model(index:number,Selected:number,click:(setindex:number)=>void){
  .fontSize(16)
  .width(54)
  .textAlign(TextAlign.Center)
  .borderRadius(20)
  .border({width:index==Selected?1:0,color:'#66ccff'})
  .onClick(()=>{
    //回调函数
    click(index)
  })
  // .backgroundColor(Color.Yellow)
}



@Component
struct constlist{
  @Prop listdata:lists[]=[]
  @Prop ModelIndex:number
  @State backgroundBlur:number=0
  @Prop switch:boolean=false
  @Prop isreading:boolean=false
  @State popup: lists = {title:'',Booklink:'',type:0,img:''}
  @State BookShelfType_title:string[]=['想读',"在读","已读"]
  private getFilteredData(): lists[] {
    if (this.ModelIndex === 0) {
      return this.listdata // 显示所有数据
    } else if (this.ModelIndex === 1) {
      return this.listdata.filter(item => item.type === 1) // 只显示type=1的数据
    }else if (this.ModelIndex === 2) {
      return this.listdata.filter(item => item.type === 2) // 只显示type=1的数据
    }else if (this.ModelIndex === 3) {
      return this.listdata.filter(item => item.type === 3) // 只显示type=1的数据
    }
    return this.listdata
  }

  ToDetailed(MiniLink:string){
    // console.log("https://www.linovelib.com"+MiniLink)
    router.pushUrl({
      url: 'pages/DetailedPage',
      params: {
        Booklink:MiniLink
      }
    })
  }


  build() {
    Column(){
      Column(){
        if (this.listdata.length>0){
          List({space:3}) {
            ForEach(this.getFilteredData(), (item: lists, index: number) => {
              ListItem() {
                Column(){

                  Image(item.img)
                    .width(100)
                    .height(140)
                    .backgroundColor(Color.Gray)

                  Row(){
                    Text(item.title)

                      .fontSize(13)
                      .textAlign(TextAlign.Start)
                      // .fontWeight(1)
                      .width('85%')
                      .maxLines(2) // 最大显示行数为1
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                    // .backgroundColor(Color.Pink)

                    Text(item.type==1?'想看':(item.type==2?'在看':'已看'))
                      .fontSize(11)
                      .textAlign(TextAlign.End)
                      .width('15%')
                      .fontWeight(FontWeight.Bold)
                      .onClick(()=>{
                        this.backgroundBlur = 200 // 设置模糊度
                        this.popup =item
                        this.switch = true
                      })
                    // .backgroundColor(Color.Blue)
                    // 0 想看
                    // 1 在看
                    // 2 已看
                  }
                  .height(35)
                  .width('90%')
                  // .backgroundColor(Color.Orange)
                  .justifyContent(FlexAlign.Center)
                  .alignItems(VerticalAlign.Center)
                }
                .width('100%')
                .padding(3)
                .justifyContent(FlexAlign.Center)
                .alignItems(HorizontalAlign.Center)
                .onClick(() => {
                  this.ToDetailed(item.Booklink)
                })
                // .gesture(
                //   LongPressGesture({ repeat: true })
                //     .onAction(() => {
                //       // 长按时显示悬浮框
                //
                //
                //       console.log("长按中,backgroundBlur=",this.backgroundBlur)
                //     })
                //     // .onActionEnd(() => {
                //     //   // 长按结束时关闭悬浮框
                //     //   this.backgroundBlur = 0 // 设置模糊度
                //     //   console.log("长按接受")
                //     //   this.switch = false
                //     //
                //     // })
                // )

              }
            })
          }
          .lanes(3,5)
          .scrollBar(BarState.Auto)
          .margin({bottom:100})
        }else {
          Column(){
            Text('书架中暂无数据')
              .fontWeight(FontWeight.Bold)
              .margin({top:-150})
          }
          .width('100%')
          .height('100%')
          // .backgroundColor(Color.Pink)
          .justifyContent(FlexAlign.Center)
        }
      }
      .width('100%')
      .height('100%')
       // 应用模糊效果

      if (this.switch) {
        Column(){
          Column({space:15}){
            Image(this.popup.img)
              .width(220)
              .height(300)
              .backdropBlur(this.backgroundBlur)
              // .margin({top:-110})
              .onClick(()=>{
                this.ToDetailed(this.popup.Booklink)
              })
            Text(this.popup.title)
              .width(240)
              .fontWeight(FontWeight.Bold)
              .textAlign(TextAlign.Center)
              .onClick(()=>{
                this.ToDetailed(this.popup.Booklink)
              })
            Row(){
              ForEach(this.BookShelfType_title, (item: string, index: number) => {
                BookShelfType({
                  type: this.popup.type,
                  truenumber: index+1,
                  title: item,
                  name: this.popup.title,
                  switch: this.switch
                })
                  .layoutWeight(1)
              })
              Row(){
                Image($r("app.media.delete_key"))
                  .width(20)
                  .height(20)
                Text('移除')
              }
              // .backgroundColor(Color.Pink)
              .layoutWeight(1)
              .onClick(()=>{
                this.switch = false
                appStore.deleteItem(this.popup.title)
              })

            }
            .width(260)
          }
          .margin({top:-110})

        }

        .onClick(()=>{
          this.switch = false
        })
        .alignItems(HorizontalAlign.Center)
        .justifyContent(FlexAlign.Center)
        .backgroundColor("rgba(255,255,255,0.5)")
        .width('100%')
        .height('100%')
        .position({ x:0, y: 0 })
        .zIndex(1)
      }

    }
    .width('100%')
    .height('100%')
  }
}
//点击想读后，进入阅读页面，自动切换成在读  ==》未完成
//书本是完结的情况下，进入最后一页，自动切换到已读 ==》未完成


@Component
struct BookShelfType{
  @Prop type:number
  @Prop truenumber:number
  @Prop title:string
  @Prop name:string
  @Link switch:boolean
  build() {
    Row(){
      Text('')
        .width(20)
        .height(20)
        .borderRadius(10)
        .backgroundColor(this.type==this.truenumber?'#66ccff':Color.Gray)
      Text(this.title)
        .textAlign(TextAlign.Start)
    }
    .onClick(()=>{
      console.log("this.truenumber:",this.truenumber)
      appStore.data = appStore.data.map(item => (item.title === this.name ? { img:item.img,title:item.title,Booklink:item.Booklink, type: this.truenumber } : item))
      this.switch=false
      console.log('更改后：',JSON.stringify(appStore))
    })
  }
}

@Entry
@Component
struct BookShelfPage {
  @State ModelIndex:number=0
  @Prop listdata:lists[]=[]
  SetModelIndex(index:number){
    this.ModelIndex=index
  }

  build() {
    Column(){
      //顶部
      Row(){
        Text("书架")
          .fontSize(28)
          .padding(5)
          .backgroundColor('#66ccff')
          .fontColor(Color.White)
          .fontWeight(FontWeight.Bold)
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .width('100%')
      .height(40)
      .padding({left:20,right:20})
      //标签
      Row({space:30}){
        Text('全部')
          .model(0,this.ModelIndex, (setindex: number): void => this.SetModelIndex(setindex))
        Text('想看')
          .model(1,this.ModelIndex,(setindex: number): void => this.SetModelIndex(setindex))
        Text('在看')
          .model(2,this.ModelIndex,(setindex: number): void => this.SetModelIndex(setindex))
        Text('已看')
          .model(3,this.ModelIndex,(setindex: number): void => this.SetModelIndex(setindex))
      }
      .justifyContent(FlexAlign.Start)
      .width('100%')
      .padding(20)

      //内容
      Column(){
        constlist({
          listdata:this.listdata,
          ModelIndex:this.ModelIndex
        })
      }
      .width('100%')
    }
    .width('100%')
    .height('100%')
  }


}

export default BookShelfPage