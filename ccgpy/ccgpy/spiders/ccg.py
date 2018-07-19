#!/usr/bin/env python
#coding=utf-8

import re
import scrapy

class ccgSpider(scrapy.Spider):
    name = 'ccgpy'
    URL_BASE = 'http://www.ccgkdd.com.cn/Disease/detail?DisCode=CKD'

    def start_requests(self):
        for num in range(21, 41):
            page_url = self.URL_BASE + str(num)
            print (page_url)
            yield scrapy.Request(url=page_url, callback = self.parse)

    def parse(self, response):
        ccg_db = {}
        ccg_db['url'] = response.url
        ccg_db['id'] = response.url.split('=')[1]

        main_div = response.xpath('/html/body/div[2]/div/div/div/table/tbody')
        cname = main_div.xpath('tr[1]/td[2]/text()')
        ename = main_div.xpath('tr[2]/td[2]/text()')
        inherited = main_div.xpath('tr[3]/td[2]/text()')
        diseaseId = main_div.xpath('tr[3]/td[4]/text()')
        ratio = main_div.xpath('tr[3]/td[6]/text()')
        omimId = main_div.xpath('tr[4]/td[2]/a/@href')
        description = main_div.xpath('tr[5]/td[2]/text()')

        if cname:
            ccg_db['cname'] = cname.extract()[0].strip()

        if ename:
            ccg_db['ename'] = ename.extract()[0].strip()

        if inherited:
            ccg_db['inherited'] = inherited.extract()[0].strip()

        if diseaseId:
            ccg_db['diseaseId'] = diseaseId.extract()[0].strip()

        if ratio:
            ccg_db['ratio'] = ratio.extract()[0].strip()

        if omimId:
            ccg_db['omimId'] = omimId.extract()[0].strip()

        if description:
            ccg_db['description'] = description.extract()[0].strip()

        print (ccg_db)

        return ccg_db

