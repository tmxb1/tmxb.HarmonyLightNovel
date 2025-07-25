<img width="485" height="1004" alt="Snipaste_2025-07-20_23-42-50" src="https://github.com/user-attachments/assets/032c03cf-5470-4984-a736-b540badc4ff9" /><img width="489" height="1006" alt="Snipaste_2025-07-20_23-42-24" src="https://github.com/user-attachments/assets/615c6eef-c16d-4e80-a941-7c80b90451fa" /><img width="482" height="1003" alt="Snipaste_2025-07-20_23-43-14" src="https://github.com/user-attachments/assets/9c6ee0d0-9c6d-4c00-a1f1-a2cbe919e4ef" />基于ArkTS语言搭建的轻小说软件

项目演示视频：https://www.bilibili.com/video/BV1ppgHzVEfH

本质上仍是套壳模式，数据来源为[哔哩轻小说](https://www.linovelib.com/)。后端通过爬虫获取网站数据后发送给前端进行布局展示。

最初认为无需数据库，但在开发搜索模块时，遇到了技术瓶颈：网站似乎设有站点检测、防爬机制或重定向策略（具体技术细节尚不明确），导致无法直接利用其搜索功能。经观察，此现象仅出现在搜索环节。因此，决定采用替代方案——将整个网站的书本信息（包括书本名称、作者、网址、封面图片网址）爬取下来，自建数据库。

此方案的**缺点**是无法实时同步网站的新书信息。为此，在后端编写了定时任务函数，于每天凌晨自动爬取网站收录的最新书籍并更新至数据库。

此外，阅读页面的图片加载采用了懒加载技术。图片的真实地址存储在 `data-src` 属性中，且直接访问该地址会被拒绝（需在请求头添加正确的 `Referer`）。**解决方案**是通过后端转发：当前端请求图片时，后端先添加正确的 `Referer` 请求头获取图片数据，再返回给前端显示。

**前端**

前端代码在NewBook文件夹中

截图：

<img width="482" height="1003" alt="Snipaste_2025-07-20_23-43-14" src="https://github.com/user-attachments/assets/27376d2d-b7d3-4041-8ca8-90687a46e301" />

分类

<img width="492" height="1001" alt="Snipaste_2025-07-20_23-43-48" src="https://github.com/user-attachments/assets/086fad91-ba4c-4973-9e99-738299ce8801" />

详细

<img width="492" height="1007" alt="Snipaste_2025-07-20_23-44-08" src="https://github.com/user-attachments/assets/04700c91-d2ec-4bc4-ac9b-53e32258d9c9" />

目录

<img width="489" height="1006" alt="Snipaste_2025-07-20_23-42-24" src="https://github.com/user-attachments/assets/5b68327a-7ba9-4016-bdf6-e371a298b75f" />

书架

<img width="485" height="1004" alt="Snipaste_2025-07-20_23-42-50" src="https://github.com/user-attachments/assets/e2756ba9-1f55-4c6c-80ee-8e3d9d241d86" />

搜索&排行榜

**后端**

后端代码在FeelGratefulBackend文件夹中

其中backend.py时运行代码，GetBookData.py是早期为填充数据库所使用的爬虫代码

启动代码:

```
python backend.py #在FeelGratefulBackend文件夹下使用
```

**数据库**

qingbook.sql是数据库备份
