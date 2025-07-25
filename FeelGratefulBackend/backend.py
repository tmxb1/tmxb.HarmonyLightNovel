#-*- coding: UTF-8 -*- 。
from io import BytesIO
from urllib.parse import urljoin
from flask import app,jsonify,Flask,request,Response
import ast
import json
import sys,html
import re
import requests,time
import hashlib
from bs4 import BeautifulSoup
from lxml  import etree
from apscheduler.schedulers.background import BackgroundScheduler
from flask_sqlalchemy import SQLAlchemy
from sqlalchemy import or_

app=Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'mysql+mysqlconnector://root:123456@localhost/qingbook'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
db = SQLAlchemy(app)


class Book(db.Model):
    __tablename__ = 'book'

    Bookid = db.Column(db.Integer, primary_key=True)
    BookName = db.Column(db.String(255), nullable=False)
    BookLink = db.Column(db.String(255))
    BookImg = db.Column(db.String(255))
    BookAuther = db.Column(db.String(100))

    def to_dict(self):
        """将对象转换为字典格式"""
        return {
            'BookName': self.BookName,
            'BookLink': self.BookLink,
            'BookImg': self.BookImg,
            'BookAuther': self.BookAuther
        }

HttpAddress = [0] * 10

def handle_wenku(option):
    mapping = {
        "不限":0,
        "日本轻小说": 1,
        "华文轻小说": 2,
        "Web轻小说": 3,
    }
    # 返回映射值，如果没有匹配则返回None
    return mapping.get(option[0], None)

def handle_tag(options):
    mapping = {
        "不限":0,"恋爱":64,"后宫":48,"校园":63,"百合":27,"转生":26,"异世界":47,"奇幻":15,"冒险":61,
        "欢乐向":222,"女性视角":231,"龙傲天":219,"魔法":96,"青春":67,"性转":31,"病娇":198,"妹妹":217,
        "青梅竹马":225,"战斗":18,"NTR":256,"人外":223,"大小姐":227,"黑暗":189,"悬疑":68,"科幻":56,
        "伪娘":201,"战争":55,"萝莉":185,"复仇":229,"斗智":199,"异能":131,"猎奇":241,"轻文学":191,
        "职场":60,"经营":226,"JK":246,"女儿":261,"机战":135,"末日":221,"旅行":239,"犯罪":220,"治愈":98,
        "推理":97,"惊悚":124,"日本文学":205,"美食":211,"游戏":248,"大逃杀":249,"格斗":132,"耽美":228,
        "音乐":233,"群像":245,"脑洞":224,"恶役":328,"热血":28,"JC":304,"间谍":254,"温馨":180,"宅文化":263,
        "同人":333,"竞技":146
    }
    # 映射所有选项
    return [mapping.get(opt, opt) for opt in options]

def handle_progress(option):
    # print(f"[进度] 选项: {', '.join(option)}")
    mapping = {
        "不限": 0,
        "新书上传":1,
        "情节展开":2,
        "精彩纷呈":3,
        "接近尾声":4,
        "已经完本":5
    }
    # 返回映射值，如果没有匹配则返回None
    return mapping.get(option[0], None)


def handle_animation(options):
    print(f"[动画] 选项: {', '.join(options)}")
    mapping = {
        "不限": 0,
        "已动画化":1,
        "未动画化":2
    }
    # 返回映射值，如果没有匹配则返回None
    return mapping.get(options[0], None)

def handle_word_count(options):
    print(f"[字数] 选项: {', '.join(options)}")
    mapping = {
        "不限": 0,
        "30万以下":1,
        "30-50万":2,
        "50-100万":3,
        "100-200万":4,
        "200万以上":5
    }
    # 返回映射值，如果没有匹配则返回None
    return mapping.get(options[0], None)

def handle_update(options):
    print(f"[更新] 选项: {', '.join(options)}")
    mapping = {
        "不限": 0,
        "三日内":1,
        "七日内":2,
        "半月内":3,
        "一月内":4
    }
    # 返回映射值，如果没有匹配则返回None
    return mapping.get(options[0], None)
def handle_sort(options):
    mapping = {
        "周点击":'weekvisit',"月点击":'monthvisit',"周推荐":'weekvote',"月推荐":'monthvote',
        "周鲜花":'weekflower',"月鲜花":'monthflower',"收藏数":'goodnum',"更新时间":'lastupdate',
        "入库时间":'postdate'

    }
    # 返回映射值，如果没有匹配则返回None
    return mapping.get(options[0], None)

def getH5Address(raw_data):
    print("raw_data:",raw_data)
    data=raw_data['TagSelection']
    nowpage=raw_data["nowpage"]
    print("data:",data)
    n = {}
    handlers = {
        "文库": handle_wenku,  # 0
        "标签": handle_tag,  # 1
        "进度": handle_progress,  # 2
        "动画": handle_animation,  # 3
        "字数": handle_word_count,  # 4
        "更新": handle_update,  # 5
        "排序": handle_sort  # 6
    }
    for index, item in enumerate(data):
        item_type = item["type"]
        options = item["options"]
        # 获取处理函数，如果没有则使用默认处理
        handler = handlers.get(item_type)
        # 调用处理函数
        result = handler(options)
        n[index] = result
        # 打印结果
        print(f"类型: {item_type, index}")
        print(f"原始选项: {options}")
        print(f"处理结果: {result}")
        print("-" * 50)
    # 1是页面数
    url = ('https://www.linovelib.com/wenku/' + n[6] + '_' + '-'.join(map(str, n[1])) + '_' + str(n[2]) + "_" + str(n[3]) + "_" + str(n[0]) + "_0_0_" + str(n[4]) + "_"+str(nowpage)+"_" + str(n[5]) + ".html")
    return url
def getWenku_text(url):
    sys.stdout.reconfigure(encoding='UTF-8')
    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0',
        'accept-language': 'zh-CN,zh;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6',
        'Referer': 'https://www.linovelib.com/',
    }
    response = requests.get(url=url, headers=headers)
    # response.encoding=response.apparent_encoding #自动识别编码
    response.encoding = 'UTF-8'
    html = etree.HTML(response.text)
    # print(response.apparent_encoding)
    if not html:
        return jsonify({'status': False, 'data': 0})
    print('response.text:', etree.tostring(html, pretty_print=True).decode())
    divs = html.xpath('//div[@class="store_collist"]/div')
    nowpage = html.xpath('substring-before(//em[@id="pagestats"], "/")')
    maxpage = html.xpath('substring-after(//em[@id="pagestats"], "/")')
    print('nowpage:', nowpage)
    print('maxpage:', maxpage)
    page = {'nowpage': nowpage, 'maxpage': maxpage}
    print('divs:', len(divs))
    data = []
    for index, div in enumerate(divs):
        Booklink = div.xpath("./div[1]/a/@href")  # 书本链接
        ImgSrc = div.xpath("./div[1]/a/img/@data-original")  # 书本封面
        Bookname = div.xpath('.//div[@class="bookname"]/a/text()')  # 书本名称
        BookAuthor = div.xpath('.//div[@class="bookilnk"]/span[1]/text()')  # 书本作者
        BookLibrary = div.xpath('.//div[@class="bookilnk"]/span[2]/text()')  # 书本文库
        BookStatus = div.xpath('.//div[@class="bookilnk"]/span[3]/text()')  # 书本状态
        LatestBookTime = div.xpath('.//div[@class="bookilnk"]/span[4]/text()')  # 书本最新时间
        BookIntroduction = div.xpath('.//div[@class="bookintro"]/text()')  # 书本简介
        BookTags = div.xpath('.//div[@class="bookupdate"]/b/text()')  # 书本标签
        data.append({
            "Booklink": Booklink,
            "ImgSrc": ImgSrc,
            "Bookname": Bookname,
            "BookAuthor": BookAuthor,
            "BookLibrary": BookLibrary,
            "BookStatus": BookStatus,
            "LatestBookTime": LatestBookTime,
            "BookIntroduction": BookIntroduction,
            "BookTags": BookTags
        })
    # decoded_data = decode_unicode_escape(data)
    print('data:', data)
    return data,page

def getDetailed_text(url):
    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0',
        'accept-language': 'zh-CN,zh;q=0.9',
        'Sec-Ch-Ua-Platform': "Windows",
        'Upgrade-Insecure-Requests': '1'
    }
    data = {}
    try:
        response = requests.get(url=url, headers=headers)
        response.encoding = 'UTF-8'
        # 使用 BeautifulSoup 解析，它会自动处理 HTML 实体
        soup = BeautifulSoup(response.text, 'html.parser')
        print("开始:", soup)
        BookImg = soup.find("div", class_='book-img fl').find("img")["src"]
        print("BookImg:", BookImg)
        BookName= soup.find("h1", class_='book-name').text
        print("BookName:", BookName)
        BookAuthor=soup.find("div", class_='au-name').find("a").get_text()
        print("BookAuthor:", BookAuthor)
        span = soup.find("div", class_='nums').find_all("span")
        print("span:",span)
        BookLastTime=span[0].get_text()
        print("BookLastTime:", BookLastTime)
        BookWordage=span[1].get_text()
        print("BookWordage:", BookWordage)
        SumRecommend = span[2].get_text()
        print("SumRecommend:", SumRecommend)
        WeekRecommend = span[3].get_text()
        print("WeekRecommend:", WeekRecommend)
        BookOver=soup.find("a", class_='state').get_text()
        print("BookOver:", BookOver)
        AnimationBased=soup.find("a", class_='label rg2')
        if AnimationBased :
            AnimationBased="已动画化"
        else:
            AnimationBased = "未动画化"
        print("AnimationBased:", AnimationBased)
        BookTags=[a.get_text(strip=True) for a in soup.find("div", class_='book-label').find("span").find_all("a")]
        print("BookTags:", BookTags)
        BookSynopsisDiv=soup.find("div", class_='book-dec Jbook-dec')
        BookSynopsis = [p.get_text(strip=True) for p in BookSynopsisDiv.select('p:not([class]):not([id])')]
        print("BookSynopsis:", BookSynopsis)
        return {
            'BookImg': BookImg,#图片
            'BookName': BookName,#名称
            'BookAuthor': BookAuthor,#作者
            'BookLastTime': BookLastTime,#最后更新
            'BookOver':BookOver,
            'BookWordage': BookWordage,#字数
            'SumRecommend': SumRecommend,#总推荐
            'WeekRecommend': WeekRecommend,#周推荐
            'AnimationBased': AnimationBased,#动画化
            'BookTags': BookTags,#标签
            'BookSynopsis': BookSynopsis#简介
        }
    except Exception as e:
        return None

#获取最新小说名称
def GetDatabase():
    # 获取id最大的书籍
    max_id_book = Book.query.order_by(Book.Bookid.desc()).first()

    # 简化的打印语句
    if max_id_book:
        print(f"Max book ID: {max_id_book.Bookid}, Name: {max_id_book.BookName}")
        return max_id_book.BookName
    else:
        print("No books found")
        return "0"


# 更新数据库
def daily_task():
    with app.app_context():
        #获取已知最新
        lastName=GetDatabase()
        print('数据库最新书名是',lastName)
        #爬网站
        headers = {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0',
            'accept-language': 'zh-CN,zh;q=0.9',
            'Referer': 'https://www.linovelib.com/topfull/allvisit/1.html',
            'Sec-Ch-Ua-Platform': "Windows",
            'Upgrade-Insecure-Requests': '1'
        }
        n=0
        i=0
        while True:
            data = []
            url = f'https://www.linovelib.com/wenku/postdate_0_0_0_0_0_0_0_{i - 0 + 1}_0.html'
            print("url:", url)
            response = requests.get(url=url, headers=headers)
            response.encoding = 'UTF-8'
            soup = BeautifulSoup(response.text, 'html.parser')
            if not soup:
                print("BeautifulSoup 解析失败")
                return
            list_divs = soup.find_all("div", class_='bookbox')
            print("list_div:",list_divs)
            for list_div in list_divs:
                title = list_div.find('div', class_='bookname').get_text()  # 书名
                print("title:",title)
                if title==lastName:
                    n=1
                    break
                else:
                    link = list_div.find('div', class_='bookname').find('a')['href']  # 书连接
                    spans = list_div.find_all('span')[0].get_text()  # 作者
                    img = list_div.find('img')["data-original"]  # 书名
                    print(title, link, spans)
                    data.insert(0, {
                        "title": title,
                        "link": link,
                        "auther": spans,
                        'img': img
                    })
            #报错数据
            save(data)
            if n==1:
                break
        return
def save(datas):
    try:
        # 将字典列表转换为 Book 对象列表
        books = [
            Book(
                BookName=data['title'],
                BookLink=data['link'],
                BookAuther=data['auther'],
                BookImg=data['img']
            )
            for data in datas
        ]

        # 批量添加对象到 session
        db.session.add_all(books)

        # 提交事务
        db.session.commit()
        print(f"成功保存 {len(datas)} 条记录")

    except Exception as e:
        db.session.rollback()  # 回滚事务
        print("保存错误:", e)
#实现每天晚上4点干活
def start_scheduler():
    """启动定时任务"""
    scheduler = BackgroundScheduler(timezone="Asia/Shanghai")  # 设置时区

    # 每天凌晨4点执行
    scheduler.add_job(
        func=daily_task,
        trigger="cron",
        hour=4,
        minute=0
    )

    scheduler.start()
    print("定时任务已启动，将在每天凌晨4点执行")

# class Book(db.Model):
#     id = db.Column(db.Integer, primary_key=True)
#     BookName = db.Column(db.String(100))
@app.route("/Detailed",methods=["POST"])
def Detailed():
    # 获取数据，进行处理
    raw_data =json.loads(request.get_data(as_text=True))
    print('raw_data',raw_data)
    if raw_data:
        url=raw_data['Booklink']
        print(url)
        # 爬虫
        data=getDetailed_text(url)
        if data:
            return jsonify({'status': True, 'data': data})
        else:
            return jsonify({'status': False, 'data': {}})
    else:
        return jsonify({'status': False, 'data': {}})
# 分类数据
@app.route("/all",methods=["POST"])
def all():
    # 获取数据，进行处理
    raw_data =json.loads(request.get_data(as_text=True))
    # print('raw_data',raw_data)
    if raw_data:
        url=getH5Address(raw_data)
        print(url)

        # 爬虫
        data,page=getWenku_text(url)
        if data:
            return jsonify({'status': True,'page':page, 'data': data})
        else:
            return jsonify({'status': False, 'data': {}})
    else:
        return jsonify({'status': False, 'data': {}})

# 排行榜数据
@app.route("/top",methods=["GET"])
def top():
    url = "https://www.linovelib.com/top.html"
    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0',
        'accept-language':'zh-CN,zh;q=0.9',
        'Referer':'https://www.linovelib.com/topfull/allvisit/1.html',
        'Sec-Ch-Ua-Platform':"Windows",
        'Upgrade-Insecure-Requests':'1'
        }
    try:
        response = requests.get(url=url, headers=headers)
        response.encoding = 'UTF-8'
        # 使用 BeautifulSoup 解析，它会自动处理 HTML 实体
        soup = BeautifulSoup(response.text, 'html.parser')
        alist = soup.find_all("div",class_='rank_i_p_list')
        data=[]
        for list in alist:
            # print("解析后的HTML:", list)
            list_title=list.find('div',class_='rank_i_p_tit').text
            # print('标题：',list_title)
            lists_data=list.find_all('div',class_='rank_i_bname')
            data_list = []
            for index,lists_text in enumerate(lists_data):
                if index==0:
                    Booklink=lists_text.find('a',class_='rank_i_l_a_book')['href']
                    Bookname=lists_text.find('a',class_='rank_i_l_a_book').text
                else:
                    Booklink = lists_text.find('a', target='_blank')['href']
                    Bookname = lists_text.find('a', target='_blank').text
                BookId=re.findall(r'\d+', Booklink)[0]
                ImgSrc_mini=str(BookId[0])if len(BookId)==4 else '0'
                ImgSrc='https://www.linovelib.com/files/article/image/'+ImgSrc_mini+'/'+str(BookId)+'/'+str(BookId)+'s'+'.jpg'
                data_list.append({
                    'ImgSrc':ImgSrc,
                    'Bookname':Bookname,
                    'Booklink':Booklink
                })
            data.append({
                'title':list_title,
                'list':data_list
            })
        print('data:',data)
        return jsonify({'status': True, 'data': data})

    except Exception as e:
        return jsonify({'status': False, 'data': f'发生错误: {str(e)}'})

#目录数据
@app.route("/Directory",methods=["GET"])
def Directory():
    url=request.args.get('url')
    print("url:",url)
    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0',
        'accept-language':'zh-CN,zh;q=0.9',
        'Referer':'https://www.linovelib.com/topfull/allvisit/1.html',
        'Sec-Ch-Ua-Platform':"Windows",
        'Upgrade-Insecure-Requests':'1'
        }
    # return jsonify({'status': False, 'data': {}})
    try:
        response = requests.get(url=url, headers=headers)
        response.encoding = 'UTF-8'
        # 使用 BeautifulSoup 解析，它会自动处理 HTML 实体
        soup = BeautifulSoup(response.text, 'html.parser')
        print("网页：",soup)
        data=[]
        divs = soup.find_all("div", class_='volume clearfix')
        print("网页：", divs)
        for div in divs:
            Title=[]
            NovelVolumeTitle=div.find("h2",class_="v-line").get_text()
            # print("NovelVolumeTitle：", NovelVolumeTitle)
            lis=div.find_all("li",class_="col-4")
            # print("lis：", lis)
            for li in lis:
                TitleName=li.find("a").get_text()
                # print("TitleName：", TitleName)
                TitleLink=li.find("a")["href"][:-5]
                # print("TitleLink：", TitleLink)
                Title.append({
                    "TitleName":TitleName,
                    "TitleLink":TitleLink})
                # print("Title：", Title)
            data.append({
                "NovelVolumeTitle":NovelVolumeTitle,
                "Title":Title})
            # print("data：", data)
        print("data:",data)
        if data:
            return jsonify({'status': True, 'data': data})
        else:
            return jsonify({'status': False, 'data': {}})

    except Exception as e:
        return jsonify({'status': False, 'data': f'发生错误: {str(e)}'})

#文章数据
@app.route("/get_Reading", methods=["GET"])
def get_Reading():
    url = request.args.get('url')+'.html'
    print("url:",url)
    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36',
        'Accept-Language':'zh-CN,zh;q=0.9',
        # 'Accept-Encoding': 'gzip,deflate,br',
        'Accept':'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7',

    }
    try:
        data=[]
        response = requests.get(url, headers=headers, timeout=10)
        response.encoding ='UTF-8'
        soup = BeautifulSoup(response.text, 'html.parser')
        print("soup:",soup)

        #获取标题和卷名   出现问题
        NovelVolume_div = soup.find("div", class_='chepnav').find_all('a')
        if NovelVolume_div:
            NovelVolumes = NovelVolume_div[-1].get_text()
            print("NovelVolumes:", NovelVolumes)
        title=soup.find("h1").get_text()
        print( "title:", title)


        # 核心处理逻辑
        article_body = soup.find("div", id="TextContent")
        print('article_body:',article_body)
        if not article_body:
            return jsonify({"status": False, 'content': {},'roust':''})

        #将图片从div中移出
        target_div = soup.find('div', id='hidden-images')
        if target_div:
            target_div.replace_with(*target_div.contents)

        print('移除div前')
        hidden_div = article_body.find('div',class_="dag")
        if hidden_div:
            hidden_div.decompose()
        print('移除div后,article_body:',article_body)

        if article_body:
            current_style = article_body.get('style', '')
            new_style = 'font-size:16px; width:380px;'

            # 确保不重复添加样式
            if new_style not in current_style:
                # 清理多余的分号
                current_style = current_style.strip('; ')
                article_body['style'] = f"{current_style}; {new_style}".strip('; ')

            print(f"添加样式后: {article_body.get('style')}")

        print('处理图片前')
        # 2. 处理图片
        for img in article_body.find_all('img'):
            # 获取真实图片地址 (从data-src)
            img_src = img.get('data-src') or img.get('src')
            print('img_src：',img_src)
            if not img_src:
                continue
            # 转换为绝对路径
            full_url = urljoin(url, img_src)
            # 替换为代理地址
            img['src'] = f"http://172.30.160.1:5000/image_proxy?url={full_url}"
            #添加图片大小
            img['style'] = "max-width:380px; height:auto;"
            # 删除无关属性
            img.attrs = {key: val for key, val in img.attrs.items() if key in ['src', 'alt','style']}

        #找下一页和下一页
        roust = []
        route = soup.find("div", class_="mlfy_page")
        print('route:',route)
        if route:
            a_tags = route.find_all('a')
            first_a = a_tags[0]
            first_text = first_a.get_text(strip=True)
            first_href = first_a.get('href', '')[:-5]

            # 获取最后一个a标签
            last_a = a_tags[-1]
            last_text = last_a.get_text(strip=True)
            last_href = last_a.get('href', '')[:-5]
        print('first_text:',first_text)
        print('first_href:', first_href)
        print('last_text:', last_text)
        print('last_href:', last_href)
        roust.append({
             'previous':{
                "text": first_text,
                "link": first_href
            },
            "next":{
                "text": last_text,
                "link": last_href
            }
        })
        data={
            'content':str(article_body),
            'NovelVolumes':NovelVolumes,
            'title':title
        }
        print("data:",data)
        # 3. 返回纯净的HTML内容
        if data:
            print('12')
            return jsonify({"status":True,'content': data,'roust':roust})
        else:
            print('34')
            return jsonify({"status": False, 'content': "",'roust':''})

    except Exception as e:
        return jsonify({"status":False,'content': str(e),'roust':''})

# 优化的图片代理服务
@app.route('/image_proxy',methods=["GET"])
def image_proxy():
    print('进入函数')
    image_url = request.args.get('url')
    print('image_url:',image_url)
    headers = {
        'Referer': 'https://www.linovelib.com/',
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36',
        'sec-ch-ua':'"Not)A;Brand";v="8", "Chromium";v="138", "Google Chrome";v="138"',
        'sec-ch-ua-mobile':'?0',
        'sec-ch-ua-platform':"Windows"
    }

    try:
        img_response = requests.get(image_url, headers=headers, timeout=10, stream=True)
        return Response(
            img_response.content,
            content_type=img_response.headers.get('Content-Type', 'image/jpeg')
        )
    except:
        # 返回空白图片占位
        return Response(b'', content_type='image/png')

#搜索书本或作者
@app.route("/Search",methods=["GET"])
def Search():
    search_input = request.args.get('input').encode('latin1').decode('utf-8')
    print('search_input:',search_input)
    if not search_input:
        return jsonify({'status': False,'data': '缺少查询参数: input'})
    try:
        # 创建搜索模式
        search_pattern = f"%{search_input}%"
        # 使用 SQLAlchemy 进行查询
        results = Book.query.filter(
            or_(
                Book.BookName.ilike(search_pattern),
                Book.BookAuther.ilike(search_pattern)
            )
        ).all()
        print("results:",results)
        # 转换结果
        converted_data = [book.to_dict() for book in results]
        return jsonify({'status': True,'data': converted_data})
    except Exception as e:
        app.logger.error(f"搜索失败: {str(e)}")
        return jsonify({'status': False,'data': f'搜索失败: {str(e)}'})
    # input=request.args.get('input')
    # print("input:",input)
    # try:
    #     conn = mysql.connector.connect(**DB_CONFIG)
    #     cursor = conn.cursor()
    #     search_pattern = f"%{input}%"
    #     print('3')
    #     query = """SELECT BookName,BookLink,BookImg,BookAuther FROM book WHERE BookName LIKE %s OR BookAuther LIKE %s"""
    #     cursor.execute(query, (search_pattern, search_pattern))
    #     print('4')
    #     data = cursor.fetchall()
    #     print("data:",data)
    #     cursor.close()
    #     conn.close()
    #     converted_data = [
    #         {
    #             'BookName': item[0],
    #             'BookLink': item[1],
    #             'BookImg': item[2],
    #             'BookAuther': item[3]
    #         }
    #         for item in data
    #     ]
    #     return jsonify({'status': True, 'data': converted_data})
    # except Exception as e:
    #     return jsonify({'status': False, 'data': f'发生错误: {str(e)}'})

@app.route('/agreement',methods=["GET"])
def agreement():
    print('进入函数')
    text = request.args.get('url')
    count=''
    print('111', text)
    try:
        if text=='2':
            count="""<div style="
    font-size:16px;
    width:380px;
    height:auto;          /* 占满整个可视高度 */
    display:flex;
    flex-direction:column;
    align-items:center;    /* 水平居中 */
    justify-content:center;/* 垂直居中 */
"><b style="text-align: center;">《轻墨》隐私政策</b><br /><span>欢迎使用《鸿蒙小说》！我们深知隐私保护的重要性，本应用严格遵循最小必要原则设计。请您在使用前仔细阅读以下隐私条款：</span>
			<div><h4>一、权限使用说明</h4><span>网络访问权限 (INTERNET)</span><br><span>✅ 唯一申请的权限</span><br><span>⚠️ 用途说明：仅用于获取小说资源，不涉及任何用户账户系统。</span><br>
			<span>❌ 不用于：用户行为跟踪、广告推送或数据上传。</span></div><div><h4>二、数据存储与安全</h4><span>网络访问权限 (INTERNET)</span><br>
		    <span>✅ 唯一申请的权限</span><br><span>⚠️ 用途说明：仅用于获取小说资源，不涉及任何用户账户系统。</span><br><span>❌ 不用于：用户行为跟踪、广告推送或数据上传。</span><br>
		    <span>所有用户数据仅存于本地</span><br><span>数据清理</span><br><span>卸载应用时，所有数据将自动永久删除。</span>
			 </div><div><h4>三、第三方服务说明</h4>
				 <span>无用户数据分析SDK</span><br>
				 <span>❌ 不集成任何广告或统计SDK（如友盟、Firebase等）</span><br>
				 <span>开源组件声明</span><br>
				 <span>使用部分Apache 2.0许可的开源库（详见Github仓库），不涉及用户数据处理</span>
			 </div>
			 <div>
			 	<h4>四、年龄限制与隐私保护</h4>
			 	<span>
			 		<strong>▲ 本应用为16+软件</strong>，<u>禁止16周岁以下未成年人使用</u>。<br>
			 		• 系统<strong>不设年龄验证功能</strong>，请监护人确保未成年人不得使用<br>
			 		• 我们<strong>不主动收集任何未成年人信息</strong>，如发现未成年人使用，建议监护人立即卸载应用
			 	</span>
			 </div>
			 <div>
			 	<h4>五、免责条款</h4>
			 	<span>因以下情况导致数据丢失，我们不承担责任：</span><br>
			 	<span>⚠️ 设备损坏/刷机</span><span> ⚠️ 误删应用 </span><span>⚠️ 系统权限限制</span>
			 </div>
			 <div>
			 	<h4>联系方式</h4>
			 	<span>隐私相关问题请联系：</span><br>
			 	<span>📧 tmxb@foxmail.com</span>
			 </div>
			 <br>
			 <span>更新日期：2025年7月23日</span>
			 
		 </div>"""
        elif text=='1':
            count="""<div style="
    font-size:16px;
    width:380px;
    height:auto;          /* 占满整个可视高度 */
    display:flex;
    flex-direction:column;
    align-items:center;    /* 水平居中 */
    justify-content:center;/* 垂直居中 */
">
    <span style="text-align:center;font-weight:bold;">《轻墨》免责声明</span><br>
    <span>1、本软件所有内容均收集自其他网站，本软件不参与组织扫图、翻译、录入等工作。</span><br>
    <span>2、网站仅为写作爱好者及日语翻译学习交流提供试阅，如果你喜欢该作品，请联系相关出版机构购买正版。</span><br>
    <span>3、由于我们无法对用户上传到本网站的所有作品内容进行充分的监测……</span><br>
    <span>（email：tmxb@foxmail.com）</span>
</div>"""
        print('222',count)
        return jsonify({'status': True,'data': count})
    except :
        # 返回空白图片占位
        return jsonify({'status': False,'data': '访问错误，请退出'})

if __name__ == '__main__':
    # GetDatabase()
    start_scheduler()
    app.run(host='172.24.224.1', port=5000, debug=True)
