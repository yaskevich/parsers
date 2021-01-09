#!/usr/bin/env perl
use strict;
use utf8;

use 5.014;
binmode STDOUT, ':encoding(UTF-8)';
use Mojolicious::Lite;
use DBI;
use Data::Dumper;
use Encode qw /from_to decode_utf8 encode/;
binmode(STDOUT, ":unix:utf8");
# binmode STDOUT, ':encoding(UTF-8)';

use HTML::Entities;

my $ua = Mojo::UserAgent->new(max_redirects => 10);
$ua->transactor->name('Mozilla/5.0 (Windows; U; Windows NT 5.1; rv:1.7.3) Gecko/20041001 Firefox/0.10.1');

sub get_page {
	my ($url) = @_;
	my $tx = $ua->get($url);
	# say $tx->req->url->to_abs;
	my $res = $tx->res;
	# say scalar (@{$tx->redirects});
	# say $tx->req->url;
	say 'Error '.$res->error if $res->error;
	my $raw = $tx->res->body;
	# say "Got page OK: ".length($raw);
	my $dom2 = $res->dom;
	# say $dom;
	
	from_to($raw, 'windows-1251', 'utf-8');
	my $body = decode_utf8($raw); # from internal encoding to real utf-8 which is ready for DB
	$dom2 = Mojo::DOM->new($body); # reload DOM into utf-8
	return $dom2;
}

sub get_listed {
	my $dom = get_page("http://6.pogoda.by/");
 
	# say $dom->at('table[forecast]')->to_string();
	say $dom->at('#forecast')->to_string();
	exit;
	my $i = 1;
	my $river_name = "";
	for my $e ($dom->find('table > tr')->each) {
		
		if (my $a = $e->at('td:nth-child(2) > b > a')){
			if (my $d = $e->at('td:nth-child(1) > b ')){
				$river_name = $d->text();
			}
		
			my $place_name = $a->text();
			
			my $coords = get_coords($place_name);
			
			my $river = $a->attr("href");
			$i++;
			# print '"'.$a->text().'", ';
			
			my $dom_river  = get_page ($river);
			
			for my $e ($dom_river->find('table > tr')->each) {
				if (my $b = $e->at('td.meteo')){
					print '"'.$river_name.'"', ",\"", $place_name, "\",",$coords, "," , $b->text();
				}
				if (my $c = $e->at('td:nth-child(2)')){
					my $class = $c->attr("class")|| '';
					if (defined ($c->text)){
						print "," , $c->text if $class  eq "meteo";
					}
				}
				if (my $c = $e->at('td:nth-child(4)')){
					my $class = $c->attr("class") || '';
					print "," , $c->text if $class eq "meteo";
				}
				print "\n";
			}
			# exit;
		}
	}
}



&get_listed;
# &get_to_check;
# &proc_all_jp;
