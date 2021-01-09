#!/usr/local/bin/perl
use strict;
use warnings;
use utf8;
use feature qw(say);
use Data::Dump qw(dump);
use WWW::Mechanize;
use DBI;
use Mojo::DOM;
use File::Slurp;

my $page_num = 1;
my $html = read_file( "page194.htm");
open(my $fh, '>', "result.txt") or die $!;


page_process ($html);



sub page_load {
	my $user_agent_string = "Mozilla/5.0 (Windows; U; Windows NT 5.1; rv:1.7.3) Gecko/20041001 Firefox/0.10.1";
	my $ua = WWW::Mechanize->new( 'autocheck' => 1, 'onerror' => undef, 'agent'=> $user_agent_string, 'timeout' => 30, 'max_redirect' => 30);

	my $resp = $ua->get('http://habrahabr.ru/posts/collective/page'.$page_num.'/');
		if ($resp->is_success) {
			my $page = $resp->content;
			page_process ($page);
		}
		 else  {
			die "Error with page retrieval!"
		}
}

sub page_process {
	my $dom = Mojo::DOM->new;
	$dom->parse(shift);
	$dom->find('html:root > body > div > div > div > div > div.post')->each(sub { 
		# my $cur = 
		# print $fh $_->attrs->{href}, "\n\t", $_->parent->parent->find('div > a.hub')->[0]->text,"\n\t", $_->text."\n" 
		my $post = $_->to_xml; 
		print $fh $post."\n---------------\n";
		

		# title, url, date, score + - result, hub, tags, added to favs, author, beforecut , type: podkast or post or translation, listened times, class="post translation", original link, hub could be numerous
		# tables: url list, hub list, author list
		# comments count
		# get rss - check what items are dead after time (access denied message)

		});

}