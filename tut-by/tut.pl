#!/usr/bin/env perl
use strict;
use utf8;

use 5.010;
binmode STDOUT, ':encoding(UTF-8)';
use Mojolicious::Lite;
use DBI;
use Data::Dumper;
use Encode qw /from_to decode_utf8 encode/;
use HTML::Entities;
use Time::Piece;
	
	# my $url = "http://news.tut.by/world/421105.html";
	my $url = "http://news.tut.by/archive/24.05.2012.html?sort=reads";

	my $ua = Mojo::UserAgent->new(max_redirects => 10);
	$ua->transactor->name('Mozilla/5.0 (Windows; U; Windows NT 5.1; rv:1.7.3) Gecko/20041001 Firefox/0.10.1');

&get_listed;

sub get_listed {
	my $tx = $ua->get($url);
	my $res = $tx->res;
	$url = $tx->req->url;
	say 'Error '.$res->error if $res->error;
	my $raw = $tx->res->body;
	say "Got page OK: ".length($raw);
	my $dom = $res->dom;
	
	my $body = decode_utf8($raw); # from internal encoding to real utf-8 which is ready for DB
	$dom = Mojo::DOM->new($body); # reload DOM into utf-8

	my $i = 1;
	for my $e ($dom->find('ul.b-lists > li.lists__li')->each) {
		say "---";
		say "Number:\t".$i;
		say "ID\t".$e->attr('data-id');
		my $date_tm =  $e->attr('data-tm');
		my $date_update_tm =  $e->attr('data-update-tm');
		my $date = localtime($date_tm)->strftime('%F %T'); # adjust format to taste
		say "Date:\t".$date;
		say "→\t".localtime($date_update_tm)->strftime('%F %T') if $date_tm != $date_update_tm;
		my $link_node = $e->at(':not(li) > a:first-child');
		
		for my $l ($e->find('a')->each) {
			my $parent = $l->parent->type;
			next if  $parent eq 'div';
			my $title  = $l->text;
			say "Link:\t".$l->attr("href");
			say "Title:\t".$title;
			last if $title;
		}
		say "Views:\t".$e->at('ul.li-meta > li.li_views')->text;
		say "Cmnt:\t".$e->at('ul.li-meta > li.li_comment')->text if $e->at('ul.li-meta > li.li_comment');
		say "Cat:\t".$e->at('ul.li-meta > li.li_category > a')->text;
		$i++;
	}
	
}

sub get_listed_up {
	my $tx = $ua->get($url);
	my $res = $tx->res;
	$url = $tx->req->url;
	say 'Error '.$res->error if $res->error;
	my $raw = $tx->res->body;
	say "Got page OK: ".length($raw);
	my $dom = $res->dom;
	
	my $body = decode_utf8($raw); # from internal encoding to real utf-8 which is ready for DB
	$dom = Mojo::DOM->new($body); # reload DOM into utf-8

	for my $e ($dom->find('li.mainnews-tabbed__li')->each) {
		my $link_node = $e->at('a');
		
		say $link_node->attr('href');
		
		my $desc_node = $link_node->at('span.desc');
		# say $e->text;
		say $desc_node->text;
		# say $collection->first->text;
	}
	
}
	
sub get_product {	
	my $tx = $ua->get($url);
	my $res = $tx->res;
	$url = $tx->req->url;
	say 'Error '.$res->error if $res->error;
	my $raw = $tx->res->body;
	say "Got page OK: ".length($raw);
	my $dom = $res->dom;
	
	my $body = decode_utf8($raw); # from internal encoding to real utf-8 which is ready for DB
	$dom = Mojo::DOM->new($body); # reload DOM into utf-8
	
	
	if (my $node = $dom->at('title')){
		my $title = $node->text;
		say "title ".$title;
	}
	
	# my $css = Mojo::DOM::CSS->new(tree => $dom);
	# my $result = $css->select_one('meta[name]');
	
	if (my $node = $dom->at('meta[name="news_keywords"]')){
		my $a = $node->attr('content');
		say "keywords: ".$a;
	}
	
	if (my $node = $dom->at('meta[name="description"]')){
		my $a = $node->attr('content');
		say "description: ".$a;
	}
	
	if (my $node = $dom->at('meta[property="article:section"]')){
		my $a = $node->attr('content');
		say "section: ".$a;
	}
	
	if (my $node = $dom->at('meta[property="article:published_time"]')){
		my $a = $node->attr('content');
		say "published_time: ".$a;
	}
	
	if (my $node = $dom->at('meta[property="og:locale"]')){
		my $a = $node->attr('content');
		say "locale: ".$a;
	}

	if (my $node = $dom->at('meta[property="og:type"]')){
		my $a = $node->attr('content');
		say "type: ".$a;
	}
}