# coding: utf-8
'''
Created on 2015/07/14

@author: kunihiro
'''
import initdata
import MySQLdb
 
connector = MySQLdb.connect(host="zaaa16d.qr.com", db="fintech", user="spkabumap", passwd="spkabumap", charset="utf8")
if __name__ == "__main__":
    x = connector.cursor()
    #clean DB
    patternMaster = initdata.data["patternMaster"]
    # todo 日本語文字列が上手く入らない・・・
    try:
        x.execute("DELETE FROM patternMaster")
        for pattern in patternMaster:
            x.execute("INSERT IGNORE INTO patternMaster VALUES (%s, %s, %s)", (pattern['id'], pattern['name'], pattern['description'] ))
        connector.commit()
    except ValueError:
        print("error!!", ValueError)
        connector.rollback()
    
    connector.close()