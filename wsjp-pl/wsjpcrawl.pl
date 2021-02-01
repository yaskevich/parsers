#!/usr/local/bin/perl
use strict;
use warnings;
use utf8;
use 5.010;
use Data::Dump qw(dump);
use WWW::Mechanize;
use DBI;
use Mojo::DOM;
use File::Slurp;
use Encode;


#my $html = read_file( "page.html");

my $dbh = DBI->connect("dbi:SQLite:dbname=wsjp.sqlite", "", "", {RaiseError => 1, AutoCommit => 0, PrintError => 1});

$dbh->{sqlite_unicode} = 1;
sub counter { state $count = 0; defined(shift) ? $count : $count++; }
$dbh->do('BEGIN'); 
#page_process ($html);
#process_letter (1);
    #CREATE TABLE "wsjp_letters" ("id" INTEGER PRIMARY KEY  NOT NULL , "letter" CHAR UNIQUE, "checked" DATETIME)
    #CREATE TABLE "wsjp_words" ("id" INTEGER PRIMARY KEY  NOT NULL,"word" TEXT,"url" TEXT,"checked" DATETIME, "letter" CHAR, "pos" TEXT, "gram" CHAR, "senses" INTEGER, "content" TEXT, "populated" DATETIME default "2012-01-01 00:00:00")
#map { process_letter($_)} (1..30); #  we process all page by letters, excerpting wordlists
populate_dictionary(); # get every page by word id from wordlist
# parse html pages of word articles into countable data


sub process_letter {
	my $iterator = shift;
	my $address = 'http://wsjp.pl/index.php?pokaz=powitalna&l='.$iterator.'&ind=0';	
	#$address = 'http://localhost/page.html';
	
	my $content = get_html ($address);
	my $cur_letter = process_wordlist ($content);
	#write_file($iterator.'.html', $content);
	my $sql2 = "INSERT OR REPLACE INTO wsjp_letters (id, letter, checked) VALUES (?, ?, DATETIME('now'))";
	db_send ($sql2, $iterator, $cur_letter);
	$dbh->commit();
	
	say 'Got (words): '.counter(1);
	say 'Done: '.$address;
	
	#exit;
}

sub process_wordlist {
	my $dom = Mojo::DOM->new;
	$dom->parse(shift);
	my $letter;
	my $letter_leaf = $dom->at('html:root > body > form > div#mainDiv > div#lista_hasel_z_lit_kontener > div#lista_hasel_z_lit > div#lista_hasel_literki > a > b');
	
	if ($letter_leaf) {
		$letter = $letter_leaf->text;
		for my $item ($dom->find('html:root > body > form > div#mainDiv > div#lista_hasel_z_lit_kontener > div#lista_hasel_z_lit > div#lista_hasel > div > a')->each) {
			my ($id, $word, $url);
			$word	= $item->all_text;
			$word	=~ s/\s+$//;
			$url	= $item->attrs('href');
			($id)	= $url =~ m/id_hasla\=(\d+)/;

			my $sql = "INSERT OR REPLACE INTO wsjp_words (id, word, url, letter, checked) VALUES (?, ?, ?, ?, DATETIME('now'))";	
			db_send ($sql, $id, $word, $url, $letter);
			counter();		
		}
	} else {
		$letter = $dom->at('html:root > body > form > div#mainDiv > div#lista_hasel_z_lit_kontener > div#lista_hasel_z_lit > div#lista_hasel_literki > b.brak_hasel')->text;
	}		
	return $letter;
}

sub process_page_word {
	my $dom = Mojo::DOM->new;
	$dom->parse(shift);
	my $letter = $dom->at('html:root > body > form > div#mainDiv > div#lista_hasel_z_lit_kontener > div#lista_hasel_z_lit > div#lista_hasel_literki > a > b')->text;
	# /html/body/table/tbody/tr/td/div/div/div[2]/table/tbody/tr[16]/td
	# get page
	# count senses
	# get gram 
	# get pos verbosed type
	# parse
	# store
}



sub populate_dictionary {
	# get range what checked not so long ago	
	#CREATE TABLE "wsjp_words" ("id" INTEGER,"word" TEXT,"url" TEXT,"checked" DATETIME, "letter_id" CHAR, "pos" TEXT, "gram" CHAR, "senses" INTEGER, "content" TEXT, "populated" DATETIME default "2012-01-01 00:00:00")
	# CREATE TABLE "wsjp_words" ("id" INTEGER,"word" TEXT,"url" TEXT,"checked" DATETIME, "pos" TEXT, "gram" CHAR, "senses" INTEGER, "content" TEXT, "populated" DATETIME default "2012-01-01 00:00:00")	
	foreach my $id_ref (@{$dbh->selectall_arrayref("SELECT id FROM wsjp_words WHERE populated <  date('now','-1 day')")}) {
		my $id = @{$id_ref}[0];
		#dump $id;
		#my ($content) = get_html ('http://localhost/druk.html');
		my ($content) = get_html ('http://wsjp.pl/do_druku.php?id_hasla='.$id.'&id_znaczenia=0');
		my $sql = "UPDATE wsjp_words SET content = ?, populated = DATETIME('now') WHERE id = ?";	
		sleep(1);
		db_send ($sql, $content, $id);
		say counter()."\t::\t".$id;		
		#$dbh->commit();
		#exit;
		# get word page
		# no preprocess, paste into db
		
	}
	$dbh->commit();
	# commit
	#dump ($all);
}

sub get_html {
	my $address = shift;
	my $content;
	my $user_agent_string = "Mozilla/5.0 (Windows; U; Windows NT 5.1; rv:1.7.3) Gecko/20041001 Firefox/0.10.1";
	my $ua = WWW::Mechanize->new( 'autocheck' => 1, 'onerror' => undef, 'agent'=> $user_agent_string, 'timeout' => 30, 'max_redirect' => 30);
	my $resp = $ua->get($address);
		if ($resp->is_success) {
			$content = $resp->decoded_content();
			#print $content;
			}
		 else  {
			die "Error with page retrieval: ".$address;
		}
	return ($content);
}


sub db_send {
	my $sql =  shift;
	my @params = @_;
	my $sth = $dbh->prepare($sql) 	or die "Cannot prepare: " . $dbh->errstr();
	$sth->execute(@params) or die "Cannot execute: " . $sth->errstr();
	
}
#$dbh->disconnect();
	#http://wsjp.pl/index.php?pokaz=powitalna&l=3&ind=0

	# <a href="index.php?id_hasla=22790&amp;l=1&amp;ind=0">A</a>
	# <a href="index.php?id_hasla=22790&amp;l=30&amp;ind=0">Ż</a>
	# $dom->find('html:root > body > form > div#mainDiv > div#lista_hasel_z_lit_kontener > div#lista_hasel_z_lit > div#lista_hasel_literki > a') # list liter
