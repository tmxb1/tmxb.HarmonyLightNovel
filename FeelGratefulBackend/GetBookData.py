# -*- coding: utf-8 -*-
import json
import random
import sys
import io
import requests
from bs4 import BeautifulSoup
import mysql.connector
import time
import re

from lxml import etree

# 爬取图书数据
# def scrape_books():
#     base_url = "http://books.toscrape.com/catalogue/page-{}.html"
#     books = []
#
#     for page in range(1, 3):  # 只爬取前2页作为示例
#         url = base_url.format(page)
#         try:
#             response = requests.get(url, timeout=10)
#             response.raise_for_status()  # 检查HTTP错误
#
#             soup = BeautifulSoup(response.text, 'html.parser')
#             book_list = soup.select('article.product_pod')
#
#             for book in book_list:
#                 title = book.h3.a['title']
#                 price_str = book.select_one('p.price_color').text
#                 price = float(re.sub(r'[^\d.]', '', price_str))  # 提取数字
#                 rating = book.p['class'][1]  # 如 'Three'
#                 stock = book.select_one('p.instock').text.strip()
#
#                 books.append({
#                     'title': title,
#                     'price': price,
#                     'rating': rating,
#                     'stock': stock
#                 })
#
#             print(f"已爬取第 {page} 页数据")
#             time.sleep(1)  # 礼貌性延迟
#
#         except Exception as e:
#             print(f"爬取第 {page} 页时出错: {str(e)}")
#
#     return books

# 配置数据库连接
DB_CONFIG = {
    'host': 'localhost',
    'user': 'root',
    'password': '123456',
    'database': 'qingbook'
}



# 主函数
def main(i):
    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0',
        'accept-language': 'zh-CN,zh;q=0.9',
        'Referer': 'https://www.linovelib.com/topfull/allvisit/1.html',
        'Sec-Ch-Ua-Platform': "Windows",
        'Upgrade-Insecure-Requests': '1'
    }
    try:
        data=[]
        url=f'https://www.linovelib.com/wenku/postdate_0_0_0_0_0_0_0_{i-0+1}_0.html'
        print("url:",url)
        response = requests.get(url=url, headers=headers)
        response.encoding = 'UTF-8'
        soup = BeautifulSoup(response.text, 'html.parser')
        if not soup:
            print("BeautifulSoup 解析失败")
            return
        list_divs=soup.find_all("div",class_='bookbox')
        for list_div in list_divs:
            title=list_div.find('div',class_='bookname').get_text() #书名
            link=list_div.find('div',class_='bookname').find('a')['href'] #书连接
            spans=list_div.find_all('span')[0].get_text() #作者
            img = list_div.find('img')["data-original"]  # 书名
            print(title,link,spans)
            data.append({
                "title":title,
                "link": link,
                "auther": spans,
                'img':img
            })
        save(data)
    except Exception as e:
        print("错误1：",e)

def save(datas):
    try:
        conn = mysql.connector.connect(**DB_CONFIG)
        cursor = conn.cursor()
        insert_query = """
            INSERT INTO book (BookName ,BookLink ,BookAuther,BookImg)
            VALUES ( %(title)s, %(link)s, %(auther)s, %(img)s)
            """
        cursor.executemany(insert_query, datas)
        conn.commit()
        print(f"成功保存 {len(datas)} 条记录")
    except Exception as e:
        print("错误2：",e)


if __name__ == "__main__":
    try:
        sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')
        sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding='utf-8', errors='replace')
        for i in range(158):
            main(i)
            print('第', i + 1, '页抓取完成')
            # time.sleep(5)
            time.sleep(random.uniform(40, 90))
        print('爬虫完成')
    except Exception as e:
        print("错误3：",e)
