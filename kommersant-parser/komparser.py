#!/usr/bin/env python
# -*- coding: utf-8 -*-
import os
import sys
import requests # Загрузка новостей с сайта.
from bs4 import BeautifulSoup # Превращалка html в текст.
import re # Регулярные выражения.
import time # Время
from pymystem3 import Mystem
import json
import csv
from datetime import date, timedelta
m = Mystem()


def get_one_komm_article(url, daydate, site, writer):
    print(url)
    a_title = ''
    a_body = ''
    author = ''
    a_id = re.compile('/([^/]*)$').search(url).group(1) #получаем id статьи - можно использовать как имя файла
    
    r = requests.get(url) #получаем текст страницы
    r.raise_for_status()
    if r.status_code != 200: #если совсем всё плохо...
        print("site error!", r.status_code)
        return False
        
    # bspage = BeautifulSoup(r.text, "lxml") #загружаем текст в объект типа BeautifulSoup
    bspage = BeautifulSoup(r.text, "html5lib") #загружаем текст в объект типа BeautifulSoup
    
    # os.makedirs(os.path.join(os.getcwd(), 'raw', str(daydate.year), str(daydate.month)), exist_ok=True)
    # a_path_raw = os.path.join(os.getcwd(), 'raw', str(daydate.year), str(daydate.month), a_id+'.html')
    # print(str(bspage), file=open(a_path_raw, 'w', encoding='utf-8'))
    
    ph1 = bspage.h1 #получаем заголовок статьи
    if ph1:
        a_title  = bspage.h1.text
    else:
        print("no title")
    
    pauthor = bspage.find('p', class_='b-article__text document_authors') #получаем автора статьи
    if pauthor:
        author = pauthor.text
        print("author found")
    else:
        print("no author")

    div = bspage.find("div", class_="article_text_wrapper") #получаем статью
    if div:
        for tag in div.find_all("p"):
            if not tag.has_attr('class') or 'document_authors' not in tag.attrs['class']:
                a_body += tag.text.strip() #получаем текст без тегов
    # print(a_body)
    
    #пути к файлу
    a_path_plain = os.path.join(os.getcwd(), 'plain', str(daydate.year), str(daydate.month), a_id+'.txt')
    a_path_mystem = os.path.join(os.getcwd(), 'mystem', str(daydate.year), str(daydate.month), a_id+'.tsv')
    
    #временно, потом убрать
    # os.makedirs(os.path.join(os.getcwd(), 'plain', str(daydate.year), str(daydate.month)), exist_ok=True)
    # os.makedirs(os.path.join(os.getcwd(), 'mystem', str(daydate.year), str(daydate.month)), exist_ok=True)
    
    plaintext  = a_title + "\n" + a_body
    print(plaintext, file=open(a_path_plain, 'w', encoding='utf-8'))
    # print(">>", a_path_plain)
    
    
    # lemmas = m.lemmatize(text)
    
    a_body_parsed = []

    words  = a_body.split(' ')
    wordcount = len(words) #количество слов
    
    for w in words:
        try:
            # mstm = w, "lemma:"+ json.dumps(m.analyze(w)[0]["analysis"][0]["lex"], ensure_ascii=False)+'_'+json.dumps(m.analyze(w)[0]["analysis"][0]["gr"], ensure_ascii=False)
            mstm = "ololo"
            a_body_parsed.append(mstm)
        except:
            mstm = w
            a_body_parsed.append(mstm)
    
    print(a_body_parsed,  file=open(a_path_mystem, 'w', encoding='utf-8'))
    # print(">>", a_path_mystem)
    
    writer.writerow([a_path_plain, author, str(daydate), site, a_title, url, wordcount])
    return True
    
def get_komm_day(archive_url, daydate, site, csvwriter):
    '''обрабатывает страницу архива одного дня'''
    print ("DAY->", daydate)
    url = archive_url+str(daydate)
    result = []
    more = []
    r = requests.get(url) #страница со списком всех статей за этот день
    r.raise_for_status()
    if r.status_code != 200: #если совсем всё плохо...
        print("site error!")
        return False
    bspage = BeautifulSoup(r.text, "html5lib")
    
    try:
        lis = bspage.find_all("li", class_="archive_date_result__item")
        #фрагменты с адресами статей
        if lis:
            day_links = ["https://www.kommersant.ru"+l("a")[0]["href"] for l in lis] #адреса статей, вышедших в этот день 
            button_more = bspage.find("button", class_="ui_button ui_button--load_content lazyload-button")["data-lazyload-url"] #фрагмент со ссылкой на другие статьи за этот день
            if button_more:
                more = ["https://www.kommersant.ru"+button_more]
        
        for l in day_links:
            result.append(l)
            #time.sleep(0.3)
    except:
        pass
    
    try:
        r2 = requests.get(more[0]) #страница с дополнительным списом статей за этот день
        bspage2 = BeautifulSoup(r2.text, "html5lib")
        lis_more = bspage2.find_all("li", class_="archive_date_result__item")
        day_links_more = ["https://www.kommersant.ru"+l("a")[0]["href"] for l in lis_more]
        for l in day_links_more:
            result.append(l)
            #time.sleep(0.3)
    except:
        if more == None:
            day_links_more = None
        pass
    
    fin = []
    # print(result)
    print("len",len(result))
    for i in result:
        get_one_komm_article(i, daydate, site, csvwriter)
    return True
    
def gen_dir(name, date):
    print("create folder")
    dd = [str(i) for i in date]
    path = os.path.join(os.getcwd(), name, dd[0], dd[1])
    os.makedirs(path, exist_ok=True)
    
    pass
    
def get_links_w_dates(start, end, url):
    """на вход ожидаются списки вида [2018,12,31] и url в формате str"""
    
    a = date(start[0], start[1], start[2])
    b = date(end[0], end[1], end[2])
    
    lst_dates = []
    
    for d in range((a-b).days + 1):
        dt = a - timedelta(days=d)
        lst_dates.append(dt)
        
        gen_dir('plain', [dt.year, dt.month])
        gen_dir('mystem',[dt.year, dt.month])
        
    return lst_dates


def start_work(startList, endList, site, title, tabname):   
    isnewfile  = os.path.exists(tabname)
    outcsv =  open(tabname, 'a', encoding='utf-8', newline='')
    bigcsv = csv.writer(outcsv, delimiter = '\t')
    if not isnewfile: #если мы создали файл, то записываем заголовок. Если нет, то он уже есть.
        bigcsv.writerow(['path', 'author', 'date', 'source', 'title', 'url', 'wordcount'])
    
    for day in get_links_w_dates(startList, endList, site):
        if not get_komm_day(site, day, title, bigcsv):
            sys.exit('Error!')

##############################################################################33
#запускаем все это...
siteUrl = 'https://www.kommersant.ru/archive/news/day/'
siteName = 'Коммерсант'
siteFrom = [2018,1,15]
siteTo = [2018,1,15]
siteTab  = 'metadata_kommersant.csv'
today = date.today()
start_work(siteFrom, siteTo, siteUrl, siteName, siteTab)
# get_one_komm_article ('https://www.kommersant.ru/doc/3521142', today, siteUrl)
 # https://www.kommersant.ru/archive/news/day/2018-01-15