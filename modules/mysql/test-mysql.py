#!/usr/bin/env python
# -*- coding: UTF-8 -*-

import os
import sys
parentDir = os.path.abspath(os.path.join(os.getcwd(), ".."))
sys.path.append(parentDir)

from modules.mysql.MySqlConn import Mysql
from _sqlite3 import Row

mysql = Mysql()

gene="'ABCC2'"

sqlAll = "SELECT * FROM gene2exons WHERE gene=" + gene
result = list(mysql.getAll(sqlAll))
if result:
    print (result[0]['exon'])
# sqlAll = "SELECT tb.uid as uid, group_concat(tb.goodsname) as goodsname FROM ( SELECT goods.uid AS uid, IF ( ISNULL(goodsrelation.goodsname), goods.goodsID, goodsrelation.goodsname ) AS goodsname FROM goods LEFT JOIN goodsrelation ON goods.goodsID = goodsrelation.goodsId ) tb GROUP BY tb.uid"
# result = mysql.getMany(sqlAll,2)
# if result :
#     print ("get many")
#     for row in result :
#         print ("%s\t%s"%(row["uid"],row["goodsname"]))


# result = mysql.getOne(sqlAll)
# print ("get one")
# print ("%s\t%s"%(result["uid"],result["goodsname"]))

#释放资源
mysql.dispose()