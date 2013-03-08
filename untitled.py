import sys
import codecs
import os.path
import xml.etree.ElementTree as ET

# checking 1st argument of teh scipt: it must be 
if len(sys.argv) < 2: sys.exit('Usage: %s XML-file' % sys.argv[0])
# checking whether it does exist
if not os.path.exists(sys.argv[1]): sys.exit('ERROR: XML-file %s was not found!' % sys.argv[1])
# reading the file into variable
with open (sys.argv[1], "r") as myfile: data=myfile.read()
# decoding - XML must be UTF-8
body = data.decode("windows-1251")
# appending a XML-header
xmldoc = '<?xml version="1.0" encoding="UTF-8"?>' + body.encode("utf-8")
# parsing xml-chunk
root = ET.fromstring(xmldoc)
# getting the item(s) we need
item = root.findall("./bibliography/code")
# iterate through items, getting the content
for neighbor in item: print neighbor.text.strip()
