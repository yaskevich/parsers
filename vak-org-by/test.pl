use utf8;
use strict;
use warnings;
binmode(STDOUT, ":unix:utf8");
		my ($io, $ic, $bo, $bc, $br) =  (quotemeta(q|<i>|), quotemeta(q|</i>|), quotemeta(q|<b>|), quotemeta(q|</b>|), quotemeta(q|<br>|));
		my $big		= q|А-ЯЁІЎ|;
		my $lil		= q|а-яёіў\'|;
		my $name	= qq|[$big][$lil]+|;
		my $d3		= qr|\d{1,2}\.\d{2}\.\d{2}|;

		#параўнальна-гiстарычнае, » 
		
my $str = "«05.12.04 – супастаўляльнае мовазнаўства» (<i>технические науки</i>) 27 февраля 2014 г. в 14:00 в совете Д 02.15.02 по адресу: УО «Белорусский государственный университет информатики и радиоэлектроники», 220013, г. Минск, ул. П. Бровки, 6, корп. 1, ауд. 232, тел. 293-89-89, -mail: dissovetbsuir.by..<br><img src='template/Classic/images/page.gif' border='0' height='9' width='8'>&nbsp;<a href=http://referat.vak.org.by/index.php?go=Files&in=view&id=21892 target=_blank>автореферат</a><br><br><a href=/index.php?go=Notice&file=print&id=21891><img src=
";
if ($str =~ /«(?<sc>$d3)\.?\s+[\–\-]?\s?(?<st>[$big$lil\,\-\s\(\)\;]+)»\s\($io(?<sg>.*?)$ic\)(?<tp>.*?)\<img/){
	print "$+{st}\n";
}