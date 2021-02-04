import scrapy
import logging
import re
import sqlite3 as sqlite
from scrapy import signals
from scrapy.settings import Settings
# pip install pypiwin32
# pip install attrs
# scrapy runspider spider.py -o deals.csv
# a python-scrapy
# python-cryptography
# apt-get install python-dev python-pip libxml2-dev libxslt1-dev zlib1g-dev libffi-dev libssl-dev
# pip install Twisted==16.4.1
# pip install attrs
# pip install  characteristic
# pip install cryptography
# scrapy runspider spider.py -t csv -o -> deals-new.csv

logging.getLogger('scrapy').setLevel(logging.WARNING)
settings = Settings()

class BlogSpider(scrapy.Spider):
    name = 'ZviazdaSpider'
    sql = "insert into zviazda (title, guid, url, more, pubdate) values (?, ?, ?, ?, ?)"
    # start_urls = ['http://zviazda.by/be/news']
    start_urls = ['http://zviazda.by/be/news?page=622']

    @classmethod
    def from_crawler(cls, crawler, *args, **kwargs):
        spider = super(BlogSpider, cls).from_crawler(crawler, *args, **kwargs)
        crawler.signals.connect(spider.spider_closed, signal=signals.spider_closed)
        return spider

    def __init__(self, user_agent='Scrapy'):
        print ('init')
        self.user_agent = "Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/47.0.2526.73 Safari/537.36"
        self.connection = sqlite.connect('./zviazda.db')
        self.cursor = self.connection.cursor()
    	# self.cur.execute("DROP TABLE IF EXISTS zviazda")
    	# self.cur.execute("delete * DROP TABLE IF EXISTS zviazda")
        self.cursor.execute('CREATE TABLE IF NOT EXISTS zviazda ' \
                    '(id INTEGER PRIMARY KEY, guid INTEGER, title VARCHAR(80), url VARCHAR(80), more TEXT, pubdate DATE)')

    def handle_error(self, e):
        log.err(e)

    def spider_closed(self, spider):
    	self.connection.commit()
    	self.connection.close()
        print('closed')

    def parse(self, response):
        print ('parse')
        print(self.name)
        for entry in response.css('div.media'):
            this_url = entry.css('a ::attr(href)').extract_first()
            match = re.search('\/(\d+)\-', this_url)
            this_guid = match.group(1) if match else 0
            self.cursor.execute("select * from zviazda where guid=?", (this_guid,))
            result = self.cursor.fetchone()
            # result = 0
            if not result:
                title = entry.css('h4.media-heading > a ::text').extract_first()
                if title: title.rstrip()
                more = entry.css('p ::text').extract_first()
                if more: more.rstrip()
                pubday  = entry.css('div.b-rubric_header > time::text').extract_first()
                if pubday: pubday = re.sub(r"(\d+)\.(\d+)\.(\d+)", "\\3-\\2-\\1", pubday)
                self.cursor.execute(self.sql, (title, this_guid, this_url, more, pubday))

        next_page = response.css('li.pager-next000000 > a ::attr(href)').extract_first()
        if next_page:
            yield scrapy.Request(response.urljoin(next_page), callback=self.parse)
