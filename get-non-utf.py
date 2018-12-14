import requests
import codecs
id  = 2856
r = requests.get('http://mftd.org/index.php?action=story&id='+str(id))
if r.status_code == 200:
    body = r.text    
    body  = bytes(body,'iso-8859-1').decode('utf-8')
    file = codecs.open(str(id)+".html", "w", encoding="utf-8")
    file.write(body)
    file.close()