import http from '@ohos.net.http'
import {getChartsData,getChartsListData,getCharts} from '../model/getChartsData'
import { router } from '@kit.ArkUI';

@Entry
@Component
struct ChartsPage {
  @State data:getChartsData[]=[]

  async getChartsGet() {
    const httpRequest = http.createHttp();
    try {
      const response = await httpRequest.request('http://t2.pgrm.top:9744/top', {
        method: http.RequestMethod.GET,
        expectDataType: http.HttpDataType.STRING, // 关键设置
        header: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        }
      });

      if (response.responseCode === 200) {
        const stream:getCharts = JSON.parse(response.result as string);
        if (stream.status==true) {
          this.data=stream.data
        }
      }
    } catch (err) {
      console.error("请求失败:", JSON.stringify(err));
    }
  }

  aboutToAppear(): void {
    this.getChartsGet()
  }

  build() {
    Column(){
      List({space:10}) {
        ForEach(this.data, (item: getChartsData, index: number) => {
          ListItem() {
            Column() {
              Text(item.title)
                .textAlign(TextAlign.Start)
                .width('100%')
                .padding(10)
              List({space:10}) {
                ForEach(item.list, (items: getChartsListData, indexs: number) => {
                  ListItem(){
                    Column(){
                      Image(items.ImgSrc)
                        .width(100)
                        .height(140)
                      Text(items.Bookname)
                        .fontSize(13)
                        .textAlign(TextAlign.Center)
                        .width(100)
                        .maxLines(1) // 最大显示行数为1
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                    }
                    .onClick(()=>{
                      console.log(items.Booklink)
                      router.pushUrl({
                        url: 'pages/DetailedPage',
                        params: {
                          Booklink:"https://www.linovelib.com"+items.Booklink
                        }
                      })
                    })
                  }
                })
              }
              .listDirection(Axis.Horizontal)
              .scrollBar(BarState.Auto)
              .padding(10)
            }
            .width('100%')

          }
          .width('100%')
        })
      }
      .margin({bottom:140})
      .scrollBar(BarState.Auto)
    }
    .width('100%')
    .height('100%')
  }
}
export default ChartsPage