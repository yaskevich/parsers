from scrapy.selector import Selector
from transliterate import translit
import io
from lxml import etree
from w3lib.html import remove_tags, remove_tags_with_content
# import pymorphy2
# ma = pymorphy2.MorphAnalyzer()
import collections

namespaces = {
    # 'xml': "http://www.w3.org/1999/xhtml",
    'tei':     'http://www.tei-c.org/ns/1.0'
}
for prefix, uri in namespaces.items():
    etree.register_namespace(prefix, uri)

speakerDict = collections.OrderedDict()
def getSpeaker(txt):
    people = []
    idstring = ""
    if " и " in txt:
        people = txt.split(" и ")
    else:
        people.append(txt)
    for i, guy in enumerate(people):
        id  = "#" + translit(guy, 'ru', reversed=True)\
            .replace("'", "").replace(",", "").replace(" ", "_").lower()
        speakerDict[id] = guy[0].upper() + guy[1:]
        # print(i)
        idstring += " " + id if i > 0 else id
    return idstring

def ss(sel, path):
    a = sel.css(path)
    return(a[0].extract().strip() if a else "")

with io.open("novg.htm",'r',encoding='cp1251') as fo, open('kheraskov-novg.xml', 'w', encoding='utf-8') as f:
# with io.open("kher.htm",'r',encoding='cp1251') as fo, open('kheraskov-moskva.xml', 'w', encoding='utf-8') as f:
    text = fo.read()
    # text = text.encode().decode('UTF-8')
    # meta[attr = "name"]
    text = remove_tags(text, which_ones=('i','a','br'))
    # text  = remove_tags_with_content(text, which_ones=('h1',))
    sr = Selector(text=text)
    sel = sr.css('h1::text').extract()
    sel2 = sr.css('h2::text').extract()
    author = ss(sr, 'meta[name="author"]::attr(content)')
    title = ss(sr, 'meta[name="title"]::attr(content)')
    genre = ss(sr, 'meta[name="genre"]::attr(content)')
    created = ss(sr, 'meta[name="created"]::attr(content)')
    dscr = ss(sr, 'meta[name="description"]::attr(content)')



    # print(author)
    # print(title)
    # print(genre)
    # print(created)
    # exit()



    # print(sel2.pop(), s3.pop())
    # css (*)

    # create XML
    root = etree.Element('TEI', xmlns="http://www.tei-c.org/ns/1.0", xmllang="ru")
    teiHeader = etree.SubElement(root, 'teiHeader')

    fdesc = etree.SubElement(teiHeader, 'fileDesc')

    prodesc = etree.SubElement(teiHeader, 'profileDesc')
    partdesc = etree.SubElement(prodesc, 'particDesc')
    listPerson = etree.SubElement(partdesc, 'listPerson')




    ts  = etree.SubElement(fdesc, 'titleStmt')

    pubstat  = etree.SubElement(fdesc, 'publicationStmt')
    etree.SubElement(pubstat, 'publisher', xmlid='RusDraCor').text = "RusDraCor"
    etree.SubElement(pubstat, 'idno', type='URL').text = "https://dracor.org/rus/kheraskov-moskva"
    etree.SubElement(pubstat, 'idno', type='RusDraCor').text = "100"


    lic = etree.SubElement(etree.SubElement(pubstat, 'availability'), 'licence')
    etree.SubElement(lic, 'ab').text = "CC BY 4.0"
    etree.SubElement(lic, 'ref', target="https://creativecommons.org/licenses/by/4.0/legalcode").text = "Licence"

    srcdesc = etree.SubElement(fdesc, 'sourceDesc')
    digisrc = etree.SubElement(srcdesc, 'bibl', type="digitalSource")
    etree.SubElement(digisrc, 'name').text = "Русская виртуальная библиотека (rvb.ru)"

    etree.SubElement(digisrc , 'idno', type='URL').text = "https://rvb.ru/18vek/heraskov/01text/03tragedies/64.htm"

    lic = etree.SubElement(etree.SubElement(digisrc, 'availability'), 'licence')
    etree.SubElement(lic, 'ab').text = "CC BY 4.0"
    etree.SubElement(lic, 'ref', target="https://creativecommons.org/licenses/by/4.0/legalcode").text = "Licence"

    origsrc = etree.SubElement(srcdesc, 'bibl', type="originalSource")
    etree.SubElement(origsrc, 'title').text = dscr
    etree.SubElement(origsrc, 'date', type="written", when=created).text = created

    ### РВБ: XVIII век: М.М. Херасков.	Версия 1.1, 28 марта 2016 г.

    ###
    ### <bibl type="">
    ###
          # <name>Библиотека Максима Мошкова (lib.ru)</name>
          # <idno type="URL">http://az.lib.ru/o/ostrowskij_a_n/text_0130.shtml</idno>
          # <availability>
          #   <licence>
          #     <ab>CC BY-SA 3.0</ab>
          #     <ref target="https://creativecommons.org/licenses/by-sa/3.0/deed.ru">Licence</ref>
          #   </licence>
          # </availability>
          # <bibl type="originalSource">


    # <title type="main" xml:lang="ru">Лес</title>
    mainRu = etree.SubElement(ts, 'title', type='main')
    mainRu.text = title

    genreRu = etree.SubElement(ts, 'title', type='sub')
    genreRu.text = genre


    authorRu = etree.SubElement(ts, 'author', key='Wikidata:Q1930316')
    authorRu.text = author

    textnode = etree.Element('text')
    root.append(textnode)

    front = etree.Element('front')
    textnode.append(front)

    body = etree.Element('body')
    textnode.append(body)



    doctitle = etree.Element('docTitle')
    front.append(doctitle)

    castlist = etree.Element('castList')
    front.append(castlist)

    etree.SubElement(doctitle, 'titlePart', type='main').text = genre

    # temp = s.xpath('//div[@class="example"]/h1').extract()
    # castNode = sr.xpath("//*[contains(text(),'ABC')]")
    # castNode = sr.xpath('//div.chapter[h1]')
    castNodeNest = sr.xpath('//div[@class="chapter"][h1]/child::*')
    i = 0
    for castNode in castNodeNest:
        inners  = castNode.xpath("child::*")
        nn = castNode.xpath("name()").extract()[0]
        # if len(inners) > 1:
            # print(nn, len(inners))


        shortname  = ""
        if nn == "h2":
            etree.SubElement(castlist, 'head').text = castNode.xpath("text()").extract()[0]
        elif nn == "p":
            castText = castNode.xpath("string()").extract()[0]
            etree.SubElement(castlist, 'castItem').text = castText
            # print(castText)
            # noDescNode = castNode.xpath('span[@class="speaker"]/text()')
            # shortname  = noDescNode[0].extract() if noDescNode else castText
            # shList  = shortname.split()
            # for w in shList:
            #     print(w)
        #     < person
        #     xml: id = "aksjusha"
        #     sex = "FEMALE" >
        #     < persName > Аксюша < / persName >
        # < / person >





    curHead = body
    curAct = body
    curSp = body
    # for it in sr.css('div.chapter:has(h1)'):
    for it in sr.xpath('//div[@class="chapter"][not(h1)]'):
        for ser0 in it.xpath("child::node()"):
            curTypeObj = ser0.xpath("name()")
            if not len(curTypeObj): continue
            el = curTypeObj[0].extract()

            cl = ss(ser0, "*::attr(class)")
            cId = ss(ser0, "*::attr(id)")
            cTxt = ss(ser0, "*::text")

            children = ser0.xpath("child::node()")
            if len(children) > 1 and cl != "versusia6":
                print(len(children))
                print(f'{el} | {cl} | {cId}| {cTxt}')
                # print(children)
                # pass

            if el == 'h2':
                act = etree.Element('div')
                # act.text = 'some text'
                act.set('type', 'act')
                body.append(act)
                curHead = act
                curAct = act
                h = etree.SubElement(curHead, 'head')
                h.text = cTxt
            elif el == 'h3':
                scn = etree.Element('div')
                # act.text = 'some text'
                scn.set('type', 'scene')
                curAct.append(scn)
                curHead = scn
                h3 = etree.SubElement(scn, 'head')
                h3.text = cTxt
            elif cl == "stage":
                stg = etree.SubElement(curHead, 'stage')
                stg.text = cTxt
            elif cl == "remark":
                stg = etree.SubElement(sp, 'stage')
                stg.text = cTxt
            elif cl == "speaker" and el == "p":
                sp = etree.Element('sp')
                # act.text = 'some text'
                sp.set('who', getSpeaker(cTxt))
                curHead.append(sp)
                curSp = sp
                spName = etree.SubElement(sp, 'speaker')
                spName.text = cTxt
            elif el == "div" and cl == "versusia6":
                for ch in children:
                    subelNode = ch.xpath("name()")
                    if subelNode:
                        subcl = ss(ch, "*::attr(class)")
                        ## line TYPE is here!!!
                        # print(subcl)

                        subcId = ss(ch, "*::attr(id)")
                        subcTxt = ss(ch, "*::text")
                        etree.SubElement(sp, 'l').text = subcTxt
                        # print(f'{subcl} | {subcId}')
                        # print(ch.extract())
                        # elif cl in ["line", "line1r", "line2r", "line3r", "line4r","line5r",]:
                        #     spLine = etree.SubElement(sp, 'l')
                        #     spLine.text = ss(ch, "*::attr(class)") + cTxt

            elif cl == "page":
                etree.SubElement(sp, 'pb', n=cTxt)
            elif cl == "date":
                break
                # pass
            elif el == "br":
                pass
            elif cl in ["br", "versusia6", "chapter"]:
                pass
            else:
                print(f'{el} | {cl} | {cId}| {cTxt}')

    # print(speakerDict)
    for k,v in speakerDict.items():
        sex = "FEMALE" if v[-1:] in ["а", "я"] else "MALE"
        prsn = etree.SubElement(listPerson, 'person', xmlid=k, sex=sex)
        prsn.text = v
        # etree.SubElement(prsn, 'persName')
        # prsn.set(QName(namespaces.xml, 'mustUnderstand'), "bebe")

        # qname2 = etree.QName('xml', "id")  # Attribute QName
        #
        # root = etree.Element("bbbbbbbbbbbb", {qname2: "test"})
        # print (etree.tounicode(root))

        # print(k, v)


    s  = etree.tostring(root,  encoding='UTF-8', pretty_print=True, xml_declaration=True).decode('UTF-8')
    # print(s)
    s = s.replace("xmllang", "xml:lang").replace("xmlid", "xml:id")
    print(s, file=f)
