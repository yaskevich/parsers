import requests
import json

# https://www.mos.ru/socialnaya-karta-skidki/
link = 'https://www.mos.ru/api/socialnaya-karta/v1/sales/company?fields=geoData,cardTypes,name,categoryId,minDiscount,maxDiscount&cardType=3'

# Request data from link as 'str'
data = requests.get(link).text

# convert 'str' to Json
data2 = json.loads(data)
with open('data.json', 'w') as outfile:
    json.dump(data2, outfile, ensure_ascii=False)