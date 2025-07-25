import { router } from '@kit.ArkUI';
import TextReader from '@hms.ai.textReader';
import { http } from '@kit.NetworkKit';

interface ToWebData{
  url:string
}
interface GetWebData{
  status:boolean,
  data:string
}
@Entry
@Component
struct WebPage {
  @State count:string=''
  aboutToAppear() {
    //获取传递的数据
    const params = router.getParams() as ToWebData;
    console.log(params.url)
    this.GetCount(params.url)
  }
  async GetCount(url:string) {
    const httpRequest = http.createHttp();
    console.log("stream.dataq前:1"+url)
    try {
      const response = await httpRequest.request(`http://t2.pgrm.top:9744/agreement?url=${url}`, {
        method: http.RequestMethod.GET,
        expectDataType: http.HttpDataType.STRING, // 关键设置
        header: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        }
      });

      if (response.responseCode === 200) {
        const stream:GetWebData = JSON.parse(response.result as string);
        if (stream.status==true) {
          console.log("stream.data:",JSON.stringify(stream.data))
          this.count = stream.data;
          }
      }
    } catch (err) {
      console.error("请求失败:", JSON.stringify(err));
    }
  }


  build() {
    Column(){
      Column(){
        RichText(this.count)
          .layoutWeight(1)
          .height('100%')
          .width('100%')

          .padding(10)
      }
      .width('100%')
      .height('90%')

      Button("返回")
        .onClick(()=>{
          router.back();
        })

    }
    .width('100%')
    .height('100%')
  }
}