#!/usr/bin/env perl
#!/usr/bin/env perl
use strict;
use warnings;
use utf8;
# binmode(STDOUT, ":utf8");
# binmode(STDOUT, ":unix:utf8");
use open qw(:std :utf8);
use 5.010;
# binmode STDOUT, ':encoding(UTF-8)';
use Mojolicious::Lite;
use DBI;
use Data::Dumper;
use Encode qw /from_to decode_utf8 encode/;
use HTML::Entities;
use List::MoreUtils qw(firstidx);
my @months	= qw |zero января февраля марта апреля мая июня июля августа сентября октября ноября декабря|;

my $cound_added = 0;
my $for_log = '';
my $db = DBI->connect("dbi:SQLite:dbname=vak.db", "", "", {RaiseError => 1, AutoCommit => 0, PrintError => 1, sqlite_unicode => 1});
open (LOG,">>","vaklog.txt") || die ("Error : can't open log file");

# my $url = 'http://www.vak.org.by/index.php?go=Notice';
# my $url = 'http://www.vak.org.by/index.php?go=Notice&page=5';
# $url = 'http://box/ansi.html';

my $big = <<'END';
<a href=/index.php?go=Notice&file=print&id=21806><img src='template/Classic/images/page_print.gif' alt='Распечатать' border='0' height='19' width='19'></a> <span class=comment>[10.12.2013] </span><br><b>Ровдо Ольга Ивановна</b>, соискатель ученой степени кандидата наук, будет защищать диссертацию «<b>Методика взаимосвязанного обучения студентов-филологов лексикологии русского языка и учебно-профессиональным видам лингворечевой деятельности</b>» по специальности «13.00.02 - теория и методика обучения и воспитания (русский язык)» (<i>педагогические науки</i>) 10 января 2014 г. в 14:00 в совете  по адресу: Белорусский государственный университет, 220050, г.Минск, К.Маркса,31, т.209-55-58, phyl@bsu.by.<br><img src='template/Classic/images/page.gif' border='0' height='9' width='8'>&nbsp;<a href=http://referat.vak.org.by/index.php?go=Files&in=view&id=21806 target=_blank>автореферат</a><br>
<br><a href=/index.php?go=Notice&file=print&id=21802><img src='template/Classic/images/page_print.gif' alt='Распечатать' border='0' height='19' width='19'></a> <span class=comment>[10.12.2013] </span><br><b>Антоновская Лариса Ивановна</b>, соискатель ученой степени кандидата наук, будет защищать диссертацию «<b>Бактерии и их метаболиты – основа новых методов оценки антибактериальных свойств биозащищенных материалов</b>» по специальности «03.02.03 – микробиология; 03.01.06 – биотехнология (в том числе бионанотехнологии)» (<i>биологические науки</i>) 10 января 2014 г. в 10:00 в совете Д 01.34.01 по адресу: Государственное научное учреждение «Институт микробиологии Национальной академии наук Беларуси», 220141, Минск, ул. академика В.Ф. Купревича, 2.
E-mail: microbio@mbio.bas-net.by, 
тел. +375-17-267-62-09.<br><img src='template/Classic/images/page.gif' border='0' height='9' width='8'>&nbsp;<a href=http://referat.vak.org.by/index.php?go=Files&in=view&id=21802 target=_blank>автореферат</a><br>
<br><a href=/index.php?go=Notice&file=print&id=21801><img src='template/Classic/images/page_print.gif' alt='Распечатать' border='0' height='19' width='19'></a> <span class=comment>[9.12.2013] </span><br><b>Сакович Андрей Ренардович</b>, соискатель ученой степени доктора наук, будет защищать диссертацию «<b>Острый гнойный синусит: адаптационные реакции, влияние на клиническое течение и прогноз, реабилитация пациентов (клинико-лабораторное исследование)</b>» по специальности «14.01.03 – болезни уха, горла и носа» (<i>медицинские науки</i>) 16 января 2014 г. в 13:00 в совете Д 03.15.06 по адресу: Государственное учреждение образования «Белорусская медицинская академия последипломного образования», 220013, г. Минск, ул. П. Бровки, 3/3; тел. (017) 2004427; e-mail: lorkafedra@tut.by..<br><img src='template/Classic/images/page.gif' border='0' height='9' width='8'>&nbsp;<a href=http://referat.vak.org.by/index.php?go=Files&in=view&id=21801 target=_blank>автореферат</a><br>
<br><a href=/index.php?go=Notice&file=print&id=21800><img src='template/Classic/images/page_print.gif' alt='Распечатать' border='0' height='19' width='19'></a> <span class=comment>[9.12.2013] </span><br><b>Козорез Александр Иванович</b>, соискатель ученой степени кандидата наук, будет защищать диссертацию «<b>Взаимосвязи качества лесных охотничьих угодий и численности оленьих (Cervidae) в условиях Беларуси</b>» по специальности «06.03.02 – лесоведение, лесоводство, лесоустройство и лесная таксация» (<i>сельскохозяйственные науки</i>) 09 января 2014 г. в 10:00 в совете Д 02.08.05 по адресу: Учреждение образования «Белорусский государственный технологический университет», 220006, г. Минск, ул. Свердлова, 13а,
тел. +375 17 226 08 43,  факс +375 17 327 62 17..<br><img src='template/Classic/images/page.gif' border='0' height='9' width='8'>&nbsp;<a href=http://referat.vak.org.by/index.php?go=Files&in=view&id=21800 target=_blank>автореферат</a><br>
<br><a href=/index.php?go=Notice&file=print&id=21799><img src='template/Classic/images/page_print.gif' alt='Распечатать' border='0' height='19' width='19'></a> <span class=comment>[8.12.2013] </span><br><b>Кухарчик Юлия Викторовна</b>, соискатель ученой степени кандидата наук, будет защищать диссертацию «<b>Невынашивание беременности ранних сроков: патогенетические аспекты, коррекция и профилактика</b>» по специальности «14.01.01 - акушерство и гинекология» (<i>медицинские науки</i>) 08 января 2014 г. в 10:00 в совете Д 03.18.01  по адресу: УО «Белорусский государственный медицинский университет», 220116, г. Минск, пр-т Дзержинского, 83; телефон ученого секретаря 272-55-98.<br><img src='template/Classic/images/page.gif' border='0' height='9' width='8'>&nbsp;<a href=http://referat.vak.org.by/index.php?go=Files&in=view&id=21799 target=_blank>автореферат</a><br>
<br><a href=/index.php?go=Notice&file=print&id=21798><img src='template/Classic/images/page_print.gif' alt='Распечатать' border='0' height='19' width='19'></a> <span class=comment>[5.12.2013] </span><br><b>Чигилейчик Андрей Викторович</b>, соискатель ученой степени кандидата наук, будет защищать диссертацию «<b>Гражданско-правовая ответственность за причинение вреда в результате дорожно-транспортных происшествий</b>» по специальности «12.00.03 - гражданское право; предпринимательское право; семейное право; международное частное право» (<i>юридические науки</i>) 14 января 2014 г. в 16:00 в совете Д 02.01.04 по адресу: Белорусский государственный университет, 220030, г. Минск, ул.Ленинградская, 8, ауд. 407, 
тел. 226 55 41..<br><img src='template/Classic/images/page.gif' border='0' height='9' width='8'>&nbsp;<a href=http://referat.vak.org.by/index.php?go=Files&in=view&id=21798 target=_blank>автореферат</a><br>
<br><a href=/index.php?go=Notice&file=print&id=21797><img src='template/Classic/images/page_print.gif' alt='Распечатать' border='0' height='19' width='19'></a> <span class=comment>[4.12.2013] </span><br><b>Автушко Татьяна Сергеевна</b>, соискатель ученой степени кандидата наук, будет защищать диссертацию «<b>Задача Коши для линейных дифференциальных уравнений второго порядка с обобщенными коэффициентами в алгебре мнемофункций</b>» по специальности «01.01.02 – дифференциальные уравнения, динамические системы и оптимальное управление» (<i>физико-математические науки</i>) 17 января 2014 г. в 12:00 в совете Д 02.01.07 по адресу: Белорусский государственный университет, 220030, г. Минск, ул. Ленинградская, 8 (корпус
юридического факультета), ауд. 407, 
тел. (017) 209-57-09.<br><img src='template/Classic/images/page.gif' border='0' height='9' width='8'>&nbsp;<a href=http://referat.vak.org.by/index.php?go=Files&in=view&id=21797 target=_blank>автореферат</a><br>
<br><a href=/index.php?go=Notice&file=print&id=21796><img src='template/Classic/images/page_print.gif' alt='Распечатать' border='0' height='19' width='19'></a> <span class=comment>[4.12.2013] </span><br><b>Богданов Сергей Викторович</b>, соискатель ученой степени кандидата наук, будет защищать диссертацию «<b>Обеспечение работоспособности монтажных стыков сварных конструкций из композитных элементов с несущей металлической оболочечной арматурой</b>» по специальности «05.02.10 - сварка, родственные процессы и технологии» (<i>технические науки</i>) 10 января 2014 г. в 14:00 в совете  по адресу: Государственное учреждение высшего профессионального образования "Белорусско-Российский университет", 212000, г.Могилев, пр-т Мира,43. тел. (0222)266100.
e-mail: bru@bru.mogilev.by.<br><img src='template/Classic/images/page.gif' border='0' height='9' width='8'>&nbsp;<a href=http://referat.vak.org.by/index.php?go=Files&in=view&id=21796 target=_blank>автореферат</a><br>
<br><a href=/index.php?go=Notice&file=print&id=21795><img src='template/Classic/images/page_print.gif' alt='Распечатать' border='0' height='19' width='19'></a> <span class=comment>[4.12.2013] </span><br><b>Зеневич Андрей Олегович</b>, соискатель ученой степени доктора наук, будет защищать диссертацию «<b>Одноквантовые системы для приема и обработки оптической информации </b>» по специальности «05.11.07 – оптические и оптико-электронные приборы и комплексы» (<i>технические науки</i>) 10 января 2014 г. в 14:15 в совете Д02.05.17 по адресу: Белорусский национальный технический университет, 220013, г. Минск, пр. Независимости, 65, кор. 1
(8-017) 293-95-17; e-mail: aantoshyn@mail.ru..<br><img src='template/Classic/images/page.gif' border='0' height='9' width='8'>&nbsp;<a href=http://referat.vak.org.by/index.php?go=Files&in=view&id=21795 target=_blank>автореферат</a><br>
<br><a href=/index.php?go=Notice&file=print&id=21794><img src='template/Classic/images/page_print.gif' alt='Распечатать' border='0' height='19' width='19'></a> <span class=comment>[3.12.2013] </span><br><b>Марковник Николай Романович</b>, соискатель ученой степени кандидата наук, будет защищать диссертацию «<b>Имущественное право как предмет залога</b>» по специальности «12.00.03 - гражданское право; предпринимательское право; семейное право; международное частное право» (<i>юридические науки</i>) 14 января 2014 г. в 14:00 в совете Д 02.01.04 по адресу: Белорусский государственный университет, 220030, г.Минск, ул.Ленинградская,8, ауд. 407,
тел. 226-55-41.<br><img src='template/Classic/images/page.gif' border='0' height='9' width='8'>&nbsp;<a href=http://referat.vak.org.by/index.php?go=Files&in=view&id=21794 target=_blank>автореферат</a><br>
<br><a href=/index.php?go=Notice&file=print&id=21793><img src='template/Classic/images/page_print.gif' alt='Распечатать' border='0' height='19' width='19'></a> <span class=comment>[3.12.2013] </span><br><b>Бекряева Евгения Борисовна</b>, соискатель ученой степени кандидата наук, будет защищать диссертацию «<b>Асимптотические свойства решений систем, близких к экспоненциально дихотомическим</b>» по специальности «01.01.02 - дифференциальные уравнения, динамические системы и оптимальное управление» (<i>физико-математические науки</i>) 10 января 2014 г. в 13:30 в совете Д 01.02.02 по адресу: Институт математики Национальной академии наук Беларуси, МИнск, ул.Сурганова,11. Тел.(+375 17)284-19-58.
e-mail: svl@im.bas-net.by.<br><img src='template/Classic/images/page.gif' border='0' height='9' width='8'>&nbsp;<a href=http://referat.vak.org.by/index.php?go=Files&in=view&id=21793 target=_blank>автореферат</a><br>
<br><a href=/index.php?go=Notice&file=print&id=21792><img src='template/Classic/images/page_print.gif' alt='Распечатать' border='0' height='19' width='19'></a> <span class=comment>[2.12.2013] </span><br><b>Жук Анастасия Игоревна</b>, соискатель ученой степени кандидата наук, будет защищать диссертацию «<b>Системы дифференциальных уравнений с обобщенными коэффициентами в алгебре обобщенных функций</b>» по специальности «01.01.02 - дифференциальные уравнения, динамические системы и оптимальное управление» (<i>физико-математические науки</i>) 17 января 2014 г. в 10:00 в совете Д 02.01.17 по адресу: Белорусский государственный университет, 220030, г. Минск, ул.Ленинградская, 8 (корпус юридического факультета), ауд.407, тел.уч.секретаря (017)209-57-09.<br><img src='template/Classic/images/page.gif' border='0' height='9' width='8'>&nbsp;<a href=http://referat.vak.org.by/index.php?go=Files&in=view&id=21792 target=_blank>автореферат</a><br>
<br><a href=/index.php?go=Notice&file=print&id=21791><img src='template/Classic/images/page_print.gif' alt='Распечатать' border='0' height='19' width='19'></a> <span class=comment>[2.12.2013] </span><br><b>Сушкевич Анна Валерьевна</b>, соискатель ученой степени кандидата наук, будет защищать диссертацию «<b>Стоматологический цемент гидравлического  твердения</b>» по специальности «05.17.11 – технология силикатных и тугоплавких неметаллических материалов» (<i>технические науки</i>) 27 декабря 2013 г. в 12:00 в совете Д 02.08.02 по адресу: учреждение образования «Белорусский государственный технологический университет», 220006, г. Минск, ул. Свердлова, 13а. Тел./факс: (8-017) 327&#8722;62&#8722;35. E-mail: unibel.chtvm@tut.by.<br><img src='template/Classic/images/page.gif' border='0' height='9' width='8'>&nbsp;<a href=http://referat.vak.org.by/index.php?go=Files&in=view&id=21791 target=_blank>автореферат</a><br>
<br><a href=/index.php?go=Notice&file=print&id=21790><img src='template/Classic/images/page_print.gif' alt='Распечатать' border='0' height='19' width='19'></a> <span class=comment>[27.11.2013] </span><br><b>Мартыненко Игнат Михайлович</b>, соискатель ученой степени кандидата наук, будет защищать диссертацию «<b>Применение аналитических методов к исследованию процессов деформирования кубически анизотропных кристаллических тел</b>» по специальности «01.02.04 – механика деформируемого твердого тела» (<i>физико-математические науки</i>) 27 декабря 2013 г. в 14:00 в совете Д 02.05.07 по адресу: Белорусский национальный технический университет, г. Минск, пр. Независимости, 65.<br><img src='template/Classic/images/page.gif' border='0' height='9' width='8'>&nbsp;<a href=http://referat.vak.org.by/index.php?go=Files&in=view&id=21790 target=_blank>автореферат</a><br>
<br><a href=/index.php?go=Notice&file=print&id=21788><img src='template/Classic/images/page_print.gif' alt='Распечатать' border='0' height='19' width='19'></a> <span class=comment>[27.11.2013] </span><br><b>Пронкевич Сергей Александрович</b>, соискатель ученой степени кандидата наук, будет защищать диссертацию «<b>Моделирование и читсленно-аналитическое решение двумерных задач устойчивости, колебаний и контактного колебаний и контактного взаимодействия деформируемых тел</b>» по специальности «01.02.04 – механика деформируемого твердого тела» (<i>физико-математические науки</i>) 27 декабря 2013 г. в 16:00 в совете Д 02.05.07 по адресу: Белорусский национальный технический университет, 220013, г. Минск, пр. Независимости, 65.<br><img src='template/Classic/images/page.gif' border='0' height='9' width='8'>&nbsp;<a href=http://referat.vak.org.by/index.php?go=Files&in=view&id=21788 target=_blank>автореферат</a><br>
<br><a href=/index.php?go=Notice&file=print&id=21787><img src='template/Classic/images/page_print.gif' alt='Распечатать' border='0' height='19' width='19'></a> <span class=comment>[27.11.2013] </span><br><b>Позняк Анна Ивановна</b>, соискатель ученой степени кандидата наук, будет защищать диссертацию «<b>Ресурсосберегающая технология получения керамических плиток для внутренней облицовки стен</b>» по специальности «05.17.11 - технология силикатных и тугоплавких неметаллических материалов» (<i>технические науки</i>) 27 декабря 2013 г. в 10:00 в совете Д 02.08.02 по адресу: Учреждение образования "Белорусский государственный технологический университет", 220006, г. Минск, ул. Свердлова, 13а тел. (8-017) 327-51-71. E-mail: root@bstu.unibel.by; keramika@belstu.by.<br><img src='template/Classic/images/page.gif' border='0' height='9' width='8'>&nbsp;<a href=http://referat.vak.org.by/index.php?go=Files&in=view&id=21787 target=_blank>автореферат</a><br>
<br><a href=/index.php?go=Notice&file=print&id=21786><img src='template/Classic/images/page_print.gif' alt='Распечатать' border='0' height='19' width='19'></a> <span class=comment>[26.11.2013] </span><br><b>Парманчук Ольга Николаевна</b>, соискатель ученой степени кандидата наук, будет защищать диссертацию «<b>Аналитические свойства решений перекрестной системы и одного дифференциального уравнения второго порядка второй степени</b>» по специальности «01.01.02 – дифференциальные уравнения,динамические системы и оптимальное управление» (<i>физико-математические науки</i>) 27 декабря 2013 г. в 12:00 в совете К 02.14.02 по адресу: Учреждение образования «Гродненский государственный университет имени Янки Купалы», 230023,г.Гродно, ул.Ожешко, 22, ауд.209, Тел.уч. секретаря: (+375 152) 74 43 76; (+375 152) 73 19 26,
Email: v.a.pronko@gmail.com ; n.nech@grsu.by.<br><img src='template/Classic/images/page.gif' border='0' height='9' width='8'>&nbsp;<a href=http://referat.vak.org.by/index.php?go=Files&in=view&id=21786 target=_blank>автореферат</a><br>
<br><a href=/index.php?go=Notice&file=print&id=21785><img src='template/Classic/images/page_print.gif' alt='Распечатать' border='0' height='19' width='19'></a> <span class=comment>[26.11.2013] </span><br><b>Аль-Далеми Юсра Мохаммед Квиджа</b>, соискатель ученой степени кандидата наук, будет защищать диссертацию «<b>Методология оценки профессионального риска в производстве мономеров и полимеров на нефтехимическом предприятии</b>» по специальности «05.26.01 – охрана труда (топливное и нефтехимическое производство)» (<i>технические науки</i>) 27 декабря 2013 г. в 11:00 в совете К 02.19.01 по адресу: Учреждении образования «Полоцкий государственный университет», 211440, г.Полоцк, ул. Стрелецкая, 4, ауд. 255. Тел. уч. секретаря +375 (214) 53-50-79, 53-17-32. 
E-mail: pltrans@psu.by или v.lipsky@psu.by.<br><img src='template/Classic/images/page.gif' border='0' height='9' width='8'>&nbsp;<a href=http://referat.vak.org.by/index.php?go=Files&in=view&id=21785 target=_blank>автореферат</a><br>
<br><a href=/index.php?go=Notice&file=print&id=21784><img src='template/Classic/images/page_print.gif' alt='Распечатать' border='0' height='19' width='19'></a> <span class=comment>[26.11.2013] </span><br><b>Третьякова Анна Васильевна</b>, соискатель ученой степени кандидата наук, будет защищать диссертацию «<b>Пресные подземные воды территории Гомельской области: динамика, экология, особенности использования</b>» по специальности «25.01.07 – гидрогеология» (<i>науки о земле</i>) 27 декабря 2013 г. в 11:00 в совете Д 12.01.01 по адресу: Республиканское унитарное предприятие «Научно-производственный центр по геологии», 220141, г. Минск, ул. Купревича,  7); E-mail ученого секретаря onoshko@geology.org.by; телефон ученого секретаря (8-017)-263-90-59.<br><img src='template/Classic/images/page.gif' border='0' height='9' width='8'>&nbsp;<a href=http://referat.vak.org.by/index.php?go=Files&in=view&id=21784 target=_blank>автореферат</a><br>
<br><a href=/index.php?go=Notice&file=print&id=21778><img src='template/Classic/images/page_print.gif' alt='Распечатать' border='0' height='19' width='19'></a> <span class=comment>[25.11.2013] </span><br><b>Федорцова Наталия Михайловна</b>, соискатель ученой степени кандидата наук, будет защищать диссертацию «<b>Свойства решений линейно-квадратичных задач оптимального управления с параметрами и неопределенностями</b>» по специальности «01.01.09 – дискретная математика и математическая кибернетика» (<i>физико-математические науки</i>) 10 января 2014 г. в 15:30 в совете Д 01.02.02 по адресу: Институт математики НАН Беларуси, 220072, Минск, ул. Сурганова, 11. Тел. 284-19-58. E-mail: svl@im.bas-net.by.<br><img src='template/Classic/images/page.gif' border='0' height='9' width='8'>&nbsp;<a href=http://referat.vak.org.by/index.php?go=Files&in=view&id=21778 target=_blank>автореферат</a><br>
<br><a href=/index.php?go=Notice&file=print&id=21776><img src='template/Classic/images/page_print.gif' alt='Распечатать' border='0' height='19' width='19'></a> <span class=comment>[21.11.2013] </span><br><b>Лохницкая Марина Анатольевна</b>, соискатель ученой степени кандидата наук, будет защищать диссертацию «<b>Закономерности номинации хранилищ в русском и английском языках донациональной эпохи</b>» по специальности «10.02.19 - теория языка» (<i>филологические науки</i>) 09 января 2014 г. в 16:00 в совете Д 02.01.24 по адресу: Белорусский государственный университет, г. Минск, ул. К. Маркса, 31, тел. 209-55-58, 
e-mail: batnf@bsu.by.<br><img src='template/Classic/images/page.gif' border='0' height='9' width='8'>&nbsp;<a href=http://referat.vak.org.by/index.php?go=Files&in=view&id=21776 target=_blank>автореферат</a><br>
<br><a href=/index.php?go=Notice&file=print&id=21775><img src='template/Classic/images/page_print.gif' alt='Распечатать' border='0' height='19' width='19'></a> <span class=comment>[21.11.2013] </span><br><b>Василенко Екатерина Николаевна</b>, соискатель ученой степени кандидата наук, будет защищать диссертацию «<b>Реализация коммуникативной стратегии убеждения средствами грамматических категорий (на материале политического дискурса)</b>» по специальности «10.02.19 – теория языка» (<i>филологические науки</i>) 09 января 2014 г. в 14:00 в совете Д 02.01.24 по адресу: Белорусский государственный университет, 220030, г. Минск, ул. К. Маркса, 31. Телефон ученого секретаря: 222-36-02. 
e-mail: slavling@bsu.by.<br><img src='template/Classic/images/page.gif' border='0' height='9' width='8'>&nbsp;<a href=http://referat.vak.org.by/index.php?go=Files&in=view&id=21775 target=_blank>автореферат</a><br>

END
  
sub dload {
	my ($page_num) = @_;
	my $url = 'http://www.vak.org.by/index.php?go=Notice&page='.$page_num;
	my $ua = Mojo::UserAgent->new(max_redirects => 10);
	$ua->name('Mozilla/5.0 (Windows; U; Windows NT 5.1; rv:1.7.3) Gecko/20041001 Firefox/0.10.1');
	say STDERR "Get:\t".$url; 
	my $tx = $ua->get($url);

	if (my $res = $tx->success) {
		# say $res->body;
		my $page = $res->body;
		from_to($page, "cp-1251", "utf-8");
		# say $page;
		my $ff  = decode_utf8( $page );
		($page_num) = narrow ($page_num, $ff);
		dload($page_num) if $page_num;
	 }
	  else {
		my ($err, $code) = $tx->error;
		die $code ? "$code response: $err" : "Connection error: $err";
	  }

}

sub narrow {
  my ($page_num, $ff) = @_;
  my $new_num = ++$page_num;
  my $begin = q|<br><br><b>Объявления о защите диссертации</b><br><br>|;
	my $end =  q|<br><br><center>|;
	# $ff =~ /page_title\.tpl(.*?)page_right\.tpl/gs;
	$ff =~ /$begin(.*?)$end/gs;
	# $ff =~ /209\-55\-58(.*?)автореферат/gs;
	my $content = $1;
	# say $1;
	my $pagetag	=  quotemeta(q|<a href="/index.php?go=Notice&page=|).$new_num.quotemeta(q|">|).$new_num.quotemeta(q|</a>|);
	$content ? separate($1) : die ("Error extracting content from the page!");
	if ($ff =~ /$pagetag/){
		say STDERR "Next:\t".$new_num;
	} else {
		$new_num = 0;
	}
	return ($new_num);
}
  
 sub separate {
	my ($info) = @_;
	my $splitter = q|автореферат</a><br>|;
	my @arr = split (/$splitter/, $info);
	
	foreach my $item (@arr) {
		$item =~ s/\n/ /g;
		$item =~ s/\s{2}/ /g;
		
		# «06.01.05 – селекция и семеноводство<br /> сельскохозяйственных растений»
		$item =~ s/\<br \/\>(?=\s)//g;
		# $item =~ s/\</\n\</g;
		unless ($item =~ /^\s*$/) {
			proc ($item);
		} else {
			# say "String contains 0 or more white-space character and nothing else.";
		}
		
	}
 }
 sub proc {
		my ($text) = @_;
		$for_log .= "-" x 50;
		$for_log .=  $text."\n";
		my (@specs_codes,  @specs_titles, $spec_gen_title, $timeplace, $name1, $name2, $name3, $degree, $datetime,
		$place, $day, $month, $year, $time, $council_type, $council_code, $is_foreign, $db_date_posted,  $db_date_event);
		my $person_name;
		my $href_print	=  quotemeta(q|href=/index.php?go=Notice&file=print&id=|);
		my $href_file	=  quotemeta(q|href=http://referat.vak.org.by/index.php?go=Files&in=view&id=|);
		my $span		=  quotemeta(q|<span class=comment>[|);
		my ($io, $ic, $bo, $bc, $br) =  (quotemeta(q|<i>|), quotemeta(q|</i>|), quotemeta(q|<b>|), quotemeta(q|</b>|), quotemeta(q|<br>|));
		my $big		= q|А-ЯЁІЎ|;
		my $lil		= q|а-яёіў\'|;
		my $name	= qq|[$big][$lil]+|;
		my $d3		= qr|\d{1,2}\.\d{2}\.\d{2}|;
		my $lang 	= $text =~ m/[іўІЎ]/ ? 'be' : 'ru';
		my $id_print	= $1 if $text =~ /$href_print(\d+)/;
		my $id_file		= $1 if $text =~ /$href_file(\d+)/;
		my $date_posted = $1 if $text =~ /$span([\d\.]+)\]/;
		$date_posted =~ s/(?<=^)(\d)(?=\.)/0$1/;
		my $topic		= $1 if $text =~ /«$bo(.*?)$bc»/;
		
		
		##
		###
		# ($newdate = $date) =~ s/(..)\/(..)\/(....)/$3,$2,$1/;
		##
		
		 # «03.02.03 – микробиология; 03.01.06 – биотехнология (в том числе бионанотехнологии)»
		# «8.00.05 – экономика и управление народным хозяйством»
		# «06.01.01 защита растений»
		# «14.01.05 - кардиология; 14.01.06 - психиатрия.»
		#«10.02.20 – параўнальна-гiстарычнае, тыпалагiчнае i супастаўляльнае мовазнаўства»
		
		if ($text =~ /«(?<sc>$d3)\.?\s+[\–\-]?\s?(?<st>[$big$lil\,\-\s\(\)\;]+)»\s\($io(?<sg>.*?)$ic\)(?<tp>.*?)\<img/){
			$specs_codes[0]		= $+{sc};
			$specs_titles[0]	= $+{st};
			$spec_gen_title		= $+{sg};
			$timeplace	= $+{tp};
		} elsif ($text =~ /«(?<sc>$d3)\.?\s+[\–\-]\s+(?<st>[$lil\,\-\s\(\)]+)\;\s+(?<sc2>$d3)\.?\s+[\–\-]\s+(?<st2>[$lil\,\-\s\(\)]+)\.?»\s\($io(?<sg>.*?)$ic\)(?<tp>.*?)\<img/){
			# warn "2 specs";
			$specs_codes[0]		= $+{sc};
			$specs_titles[0]	= $+{st};
			$specs_codes[1]		= $+{sc2};
			$specs_titles[1]	= $+{st2};
			$spec_gen_title		= $+{sg};
			$timeplace			= $+{tp};
		}
		else {
			die "problem parsing code-descr".$text;
		}
		
		# my @matches = ($text =~ m/$bo($name)\s+($name)\s?(.*?)$bc(.*?)«/);
		# die "problem parsing names".$text unless @matches;
		# $is_foreign = $matches[2] ? 0 : 1;
		# $name3 = $matches[0];
		# $name1 = $matches[1];
		# $name2 = $matches[2];
		
		# Хамед Мохамед С. Абдельмажид
		 if ($text =~ /$br$bo([$big$lil\s\.\-]+)$bc\,([$lil\s]+)\,/){
			$person_name  = $1;
			my $degree_txt = $2;
			# say $person_name;
			if ($degree_txt =~ /канд/){
				$degree	= 1;
			} elsif ($degree_txt =~ /докт/) {
				$degree	= 2;
			} else {
				die "problem parsing degree";
			}
		 }
		 
		 die "problem extracting name\n".$text unless $person_name;
		 die "problem extracting degree\n".$text unless $degree;
		# if ($matches[3] =~ /канд/){
			# $degree	= 1;
		# } elsif ($matches[3] =~ /докт/) {
			# $degree	= 2;
		# } else {
			# die "problem parsing degree";
		# }
		
		die "problem parsing ID" unless $id_print == $id_file;
		die "problem parsing date" unless $date_posted;
		$db_date_posted = join ('-', reverse (split ('\.', $date_posted)))." 00:00:00.000000 "; 
		die "problem parsing topic" unless $topic;
		$timeplace =~ s/\.\./\./;
		$timeplace =~ s/.\<br\>$//;
		($datetime, $place) = split 'по адресу:', $timeplace;
		
		
		if ($datetime =~ /(\d{1,2})\s+([$lil]+)\s+(\d{4}).*?(\d{1,2}\:\d{1,2})/){
			$day  = $1;
			$month = firstidx { $_ eq $2 } @months;
			$month = '0'.$month if length($month) < 2;
			$year =  $3;
			$time = $4;
			$db_date_event = "$year-$month-$day $time:00.000000";
		} else {
			die "problem parsing event date";
		}
		if ($datetime =~ /([$big])\s*($d3)\.?\s*$/){
			$council_type = $1;
			$council_code = $2;
		} else {
			# say "<no council>";
		}
		
		# say $matches[2] ? "Fath\t".$matches[2] : "<foreigner>";
		 # say "----\n".$place."\n---";
		 # yyyy-mm-dd hh:mm:ss.xxxxxx
		# say "Code\t".$spec_code; 
		# say "Descr\t".$spec_descr;
		# say "Gener\t".$spec_gen;
		# say "Lname\t".$matches[0]; 
		# say "Fname\t".$matches[1];
		
		
		# say "Topic $topic\nlang $lang\nDefense Day - Posted\n$db_date_event \n$db_date_posted";
		# say "name1 $name1 $name2 C type: $council_type\nC code: $council_code";
		# $id_print == $id_file ? say "File\t".$id_file : die "problem parsing ID";
		# $date_posted ? say "Post\t".$date_posted : die "problem parsing date";
		# $topic ? say "Topic\t".$topic : die "problem parsing topic";
		##
		
		# we should check whether this file id exists
		if($db->selectrow_array("SELECT * FROM defenses WHERE file_id = ?", undef, $id_file)){ # 21762
			$for_log = '';
			return; # quitting...
		} else {
			# say "adding to db...";
			# $db->do('BEGIN');
			# say $topic;
			# $db->begin_work or die $db->errstr;
			my ($council_id)	= defined $council_code ? get_council_id($council_code, $council_type) : 0;
			# $db->commit;
			my @specs_id		= get_specs_id (\@specs_codes,  \@specs_titles, $spec_gen_title, $lang);
			
			# my ($person_id) 	= add_person ($name1, $name2, $name3, $is_foreign, $lang); # deprecated
			
			my ($event_id)	= add_event($person_name, $council_id, $db_date_event, $place, $db_date_posted, $degree, $lang, $topic, $id_file);
			die ("Can't add to DB!") unless $event_id;
			$for_log .=  "EventID:\t$event_id";
			foreach my $specs_item (@specs_id){
				my $sth = eval { $db->prepare('INSERT INTO specs2def ( work_id, specs_id) VALUES (?, ?)') } || undef;
				$sth->execute($event_id, $specs_item);
				$for_log .=  "ThesisID:\t$event_id Specs:\t$specs_item";
			}
			$cound_added++;
		}
 }

sub get_specs_id {
	my ($ref_codes, $ref_titles, $gen_title, $lang) =  @_;
	my @code_ids;
	foreach my $num (0..$#$ref_codes) {
		my $code = @$ref_codes[$num];
		
		# «8.00.05 – экономика и управление народным хозяйством»
		if ($code =~ s/^(\d)\./0$1\./){
			say STDERR "not good code. fixed. ".$code;
		}
		my $title = @$ref_titles[$num];
		my ($specs_id) = $db->selectrow_array("SELECT id FROM specs WHERE code = ?", undef, $code);
		# say @$ref_titles[$num];
		# say $gen_title;
		# exit;
		# say $num.' of '.$#$ref_codes."__";
		unless ($specs_id) {
			my $sth = eval { $db->prepare('INSERT INTO specs ( code, title_'.$lang.', gen_title_'.$lang.') VALUES (?, ?, ?)') } || return undef;
			$sth->execute($code, $title, $gen_title);
			$specs_id = $db->last_insert_id("", "", "specs", "");
		}
		push @code_ids, $specs_id;
	}
	
	return (@code_ids);
} 
 
sub tie_specs {
	my ($event_id, @specs) = @_;
	my $sth = eval { $db->prepare("INSERT INTO def_specs_rel (event_id, specs_id) VALUES (?, ?)") } || return undef;
	foreach my $spec (@specs){
		$sth->execute($event_id, $spec);
	}
} 
sub add_event {
	my ($person_name,  $council_id, $event_date, $event_desc, $date_posted, $degree, $lang, $topic, $file_id) = @_;
	my $new_id;
	my ($file_indb) = $db->selectrow_array("SELECT 1 FROM defenses WHERE file_id = ?", undef, $file_id);
	unless ($file_indb){
		$for_log .=  "Person:\t$person_name\nCouncil:\t$council_id\nEventDate:\t$event_date\nEventDesc:\t$event_desc\nPostDate:\t$date_posted\nDegree:\t$degree\nLang:\t$lang\nTopic:\t$topic\nFileID:\t$file_id";
		my $sth = eval { $db->prepare("INSERT INTO defenses (date_added, person_name, council_id, event_date, event_desc, date_posted, degree, lang, topic, file_id ) VALUES (DATETIME('now'), ?, ?, ?, ?, ?, ?, ?, ?, ?)") } || return undef;
		$sth->execute($person_name,  $council_id, $event_date, $event_desc, $date_posted, $degree, $lang, $topic, $file_id);
		$new_id = $db->last_insert_id("", "", "defenses", "");
	} else {
	say STDERR "already in db!";
	}
	return ($new_id);
	
	
	
}
sub add_person {
	my ($name1, $name2, $name3, $is_foreign, $lang) = @_;
	my $sql = 'INSERT INTO persons (name1_'.$lang.', name2_'.$lang.', name3_'.$lang.', is_foreign) VALUES (?, ?, ?, ?)';
	# say $sql;
	my $sth = eval { $db->prepare($sql) } || return undef;
	#############
	##DBD::SQLite::db prepare failed: near "foreign": syntax error at gvak.pl line 248.
	################
	$sth->execute($name1, $name2, $name3, $is_foreign);
	return ($db->last_insert_id("", "", "persons", ""));
}

sub get_council_id {
	my ($code, $letter) = @_;
	my ($council_id) = $db->selectrow_array("SELECT id FROM councils WHERE code = ? AND letter = ?", undef, $code, $letter);
	unless ($council_id){
		my $sth = eval { $db->prepare('INSERT INTO councils ( code, letter) VALUES (?, ?)') } || return undef;
		$sth->execute($code, $letter);
		$council_id = $db->last_insert_id("", "", "councils", "");
	}
	return ($council_id);
}
 

	dload(1);

 
	# separate ($big);
	say "Press ENTER to add item, or any char key followed by ENTER to ignore";
	my $input = <STDIN>;
	chomp($input);
	unless (length($input)){
		say LOG $for_log if $for_log;
		$db->commit();
		say STDERR "commited: ".$cound_added;
	} else {
		say  "ignored";
	}
	
	# my $key = getc(STDIN);
	# say $key;
	# print "You entered: $input";
	# exit;
  
  
  
		
# my $ref = $db->selectall_arrayref("SELECT * FROM defenses");


# my $sth = eval { $db->prepare() } || return undef;
# $sth->execute;
# my $ref = $sth->fetchall_arrayref({});
# say Dumper ($ref);
