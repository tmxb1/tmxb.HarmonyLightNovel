import http from '@ohos.net.http'
import { FilterOptionsClass, FilterOptions, SelectAndSaveTags } from '../model/FilterOptions'
import { router } from '@kit.ArkUI';

interface BookData {
  BookAuthor: string[];
  BookIntroduction: string[];
  BookLibrary: string[];
  BookStatus: string[];
  BookTags: string[];
  Booklink: string[];
  Bookname: string[];
  ImgSrc: string[];
  LatestBookTime: string[];
}

interface PageData {
  nowpage:number;
  maxpage:number;
}
interface StreamResponse {
  status: boolean;
  data: BookData[];
  page:PageData;
}

interface SendingBackendDataClass{
  TagSelection:FilterOptionsClass[],
  nowpage:number
}


@Component
struct IficationColumn {
  @Prop url: string = ''
  @Link data: BookData[]
  @State responseData: string = "等待请求...";
  @Prop TagSelection: FilterOptionsClass[] =[];
  @Link Page:PageData;
  private CountList: ListScroller = new ListScroller();
  PageonChange?:(page:number)=>void;

  decodeUnicode(str: string): string {
    return str.replace(/\\u([\d\w]{4})/gi, (match: string, grp: string): string => {
      return String.fromCharCode(parseInt(grp, 16));
    });
  }
  build() {
    Column(){
      List({space:5,scroller:this.CountList}) {
        ForEach(this.data, (item: BookData, index: number) => {
          ListItem() {
            Column(){
              Image(item.ImgSrc.toString())
                .width(100)
                .height(140)
              Text(item.Bookname.toString())
                .fontSize(13)
                .textAlign(TextAlign.Center)
                .width('100%')
                .maxLines(1) // 最大显示行数为1
                .textOverflow({ overflow: TextOverflow.Ellipsis })
              Text(item.BookAuthor.toString())
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
              console.log(item.Booklink.toString())
              router.pushUrl({
                url: 'pages/DetailedPage',
                params: {
                  Booklink:"https://www.linovelib.com"+item.Booklink
                }
              })
            })
          }
        })
      }
      .lanes(3,5)
      .scrollBar(BarState.Auto)

      Column(){
        Row(){
          //跳转
          Image(Number(this.Page?.nowpage?.toString() ?? 1)>1?$r("app.media.arrow_circle_left"):'')
            .height(30)
            .width(30)
            .margin({left:20})
            .onClick(()=>{
              if (this.Page.nowpage>1) {
                if (this.PageonChange) {
                  this.PageonChange(this.Page.nowpage-1);
                }
                this.CountList.scrollTo({
                  xOffset: 0,
                  yOffset: 0, // 滚动到顶部
                  animation: {
                    duration: 1000, // 动画时长（ms）
                    curve: Curve.EaseOut // 缓动曲线
                  }
                });
              }
            })
          Text(' ').layoutWeight(1)
          Text(this.Page?.nowpage?.toString() ?? 'N/A')
          Text('/')
          Text(this.Page?.maxpage?.toString() ?? 'N/A')
          Text(' ').layoutWeight(1)
          Image(
            Number(this.Page?.nowpage?.toString() ?? 1)==Number(this.Page?.maxpage?.toString() ?? 1)?'':$r("app.media.arrow_circle_right")
          )
            .height(30)
            .width(30)
            .margin({left:20})
            .onClick(()=>{
              if (this.Page.nowpage<this.Page.maxpage) {
                console.log('IficationColumn:',this.Page.nowpage.toString())
                if (this.PageonChange) {
                  this.PageonChange(this.Page.nowpage-0+1);
                }
                this.CountList.scrollTo({
                  xOffset: 0,
                  yOffset: 0, // 滚动到顶部
                  animation: {
                    duration: 1000, // 动画时长（ms）
                    curve: Curve.EaseOut // 缓动曲线
                  }
                });
              }

            })
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)
      }
      .width('100%')
    }
    .margin({bottom:120})
  }
}

@Entry
@Component
struct ClassificationPage {
  @State url:string='http://t2.pgrm.top:9744/all'
  @State isCollapsed: boolean = true;
  @State Tabsroom: FilterOptionsClass[] = FilterOptions();
  @State TagSelection: FilterOptionsClass[] = SelectAndSaveTags();
  @State Page:PageData={nowpage:1,maxpage:1}
  @State data: BookData[] = []
  @State SendingBackendData:SendingBackendDataClass={TagSelection:this.TagSelection,nowpage:this.Page.nowpage}

  //记录点击标签，返回给后端
  ErrorLabelLocation(index: number, indexs: number) {
    if (this.Tabsroom[index].isMultipleChoice) {
      // 多选逻辑
      const selectedOption = this.Tabsroom[index].options[indexs];
      const currentSelected = this.TagSelection[index].options;
      const newOptions = [...currentSelected]; // 创建新数组（不可变更新）
      if (selectedOption === "不限") {
        // 点击 "不限" 时，清空所有选项
        this.TagSelection[index].options = [];
      } else {
        // 点击其他选项时，检查是否已存在
        const existsIndex = newOptions.indexOf(selectedOption);
        if (existsIndex === -1) {
          // 如果不存在，添加新选项
          newOptions.push(selectedOption);
          // 如果当前有 "不限"，移除它（因为 "不限" 和其他选项互斥）
          const unlimitedIndex = newOptions.indexOf("不限");
          if (unlimitedIndex !== -1) {
            newOptions.splice(unlimitedIndex, 1);
          }
          this.TagSelection[index].options = newOptions;
        } else {
          // 如果已存在，移除它
          newOptions.splice(existsIndex, 1);
          this.TagSelection[index].options = newOptions;
        }
      }
      // 如果数组为空，自动添加 "不限"（默认状态）
      if (this.TagSelection[index].options.length === 0) {
        this.TagSelection[index].options = ["不限"];
      }
      // 触发更新（确保父级数组也更新）
      this.TagSelection = [...this.TagSelection];
    } else {
      // 单选逻辑（保持不变）
      const selectedOption = this.Tabsroom[index].options[indexs];
      if (this.TagSelection[index].options[0] === selectedOption) {
        this.TagSelection[index].options = [index === 6 ? "更新时间" : "不限"];
      } else {
        this.TagSelection[index].options = [selectedOption];
      }
      this.TagSelection = [...this.TagSelection]; // 触发更新
    }
    console.log(JSON.stringify(this.TagSelection))
  }

  // 新增：检查标签是否被选中
  isTagSelected(index: number, tag: string): boolean {
    return this.TagSelection[index].options.includes(tag);
  }
  //页面启获取参数
  aboutToAppear(): void {
    this.clickPostRequest()
  }

  private PageonChange = async (page:number) => {
    this.SendingBackendData.nowpage=page
    console.log('PageonChange_nowpage:',this.SendingBackendData.nowpage)
    await this.clickPostRequest();

  }
  //从后端获取数据
  async clickPostRequest() {
    // console.log('SendingBackendData:',JSON.stringify(this.SendingBackendData))
    console.log('clickPostRequest_nowpage:',this.SendingBackendData.nowpage)
    const httpRequest = http.createHttp();
    try {
      const response = await httpRequest.request(this.url, {
        method: http.RequestMethod.POST,
        expectDataType: http.HttpDataType.STRING, // 关键设置
        extraData: JSON.stringify(this.SendingBackendData),
        header: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        }
      });

      if (response.responseCode === 200) {
        const stream: StreamResponse = JSON.parse(response.result as string);
        if (stream.status==true) {
          this.Page = stream.page;
          this.data=stream.data
        }
      }
    } catch (err) {
      console.error("请求失败:", JSON.stringify(err));
    }
  }

  build() {
    Column() {
      // 顶部标题
      Row() {
        Text("分类")
          .fontSize(28)
          .padding(5)
          .backgroundColor('#66ccff')
          .fontColor(Color.White)
          .fontWeight(FontWeight.Bold)
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .width('100%')
      .height(50)
      .padding({ left: 20, right: 20 })

      // 标签区域
      Column({ space: 5 }) {
        // 可折叠内容
        Column() {
          ForEach(this.Tabsroom, (item: FilterOptionsClass, index: number) => {
            ListItem() {
              Row() {
                Text(item.type.toString() + ':')
                  .fontSize(14)
                  .width(54)
                  .textAlign(TextAlign.Center)
                  .borderRadius(20)
                  .fontColor(Color.Gray)

                Flex({ wrap: FlexWrap.Wrap, alignItems: ItemAlign.Center }) {
                  ForEach(item.options, (items: string, indexs: number) => {
                    Text(items.toString())
                      .fontSize(14)
                      .textAlign(TextAlign.Center)
                      .borderRadius(15)
                      .padding(4)
                      .onClick(() => {
                        this.ErrorLabelLocation(index, indexs);
                        this.clickPostRequest()
                      })
                      .border({
                        width: this.TagSelection[index].options.includes(items) ? 1 : 0,
                        color: "#66ccff"
                      })
                  })
                }
                .layoutWeight(1)
                .margin({ left: 5 })
              }
              .width('100%')
              .margin({ bottom: 5 })
            }
          })
        }
        .height(this.isCollapsed ? "0vp" : "auto")
        .opacity(this.isCollapsed ? 0 : 1)
        .clip(true)
        .margin({ top: 5 })

        // 折叠/展开按钮
        Button(this.isCollapsed ? "展开" : "折叠")
          .height(30)
          .onClick(() => {
            animateTo({
              duration: 600,
              curve: Curve.EaseOut
            }, () => {
              this.isCollapsed = !this.isCollapsed;
            });
          })
      }

      // 内容区域
      Column() {
        IficationColumn({
          url:this.url,
          TagSelection:this.TagSelection,
          Page:this.Page,
          data:this.data,
          PageonChange:this.PageonChange
        })
      }
      .width('100%')
    }
    .width('100%')
    .height('100%')
  }
}

export default ClassificationPage

