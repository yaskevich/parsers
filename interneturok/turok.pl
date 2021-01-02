#!/usr/bin/env perl
use strict;
use utf8;
use 5.012;
use feature 'unicode_strings';
use DBI;
use Data::Dumper;
use Encode qw /from_to decode_utf8 encode encode_utf8/;
use Mojolicious::Lite;
# use Mojo::JSON qw(decode_json encode_json j);
use JSON qw(encode_json  decode_json );

# binmode STDOUT, ':utf8';
binmode STDOUT, ':encoding(UTF-8)';
binmode STDERR, ':encoding(UTF-8)';
my $ua = Mojo::UserAgent->new(max_redirects => 10);
$ua->transactor->name('Mozilla/5.0 (Windows; U; Windows NT 5.1; rv:1.7.3) Gecko/20041001 Firefox/0.10.1');
#
# open FH, '>:utf8', 'urok.json' or die  "Error opening file: $!";
open FH, '>', 'urok.json' or die  "Error opening file: $!";
open REP, '>:utf8', 'report.csv' or die  "Error opening file: $!";
my @arr;
my @links;
my ($in, $out) = qw /Ø ∑/;
# my ($in, $out) = qw /:-( :-)/;
my ($x, $y) = (0, 0);
my $subj_id;
my $grade_id;
my %cats = ();
# push @links, {source=> 1, target=>2};
my $graph_id = 1;
my $pre;

&get_listed('http://interneturok.ru/ru/school/english/2-klass');
# &get_listed('http://interneturok.ru/ru/school/english/5-6-klassy');

sub at_node {
	my ($node, $path) = @_;
	my $inner = '•';
	if (defined $node){
		my $something = $node->at($path);
		
		if (defined $something){
			if (defined $something->text){
				$inner = $something->text;
			}
		}
	}
	return $inner;
}
sub gettext {
	my ($node) = @_;
	return defined $node ? $node->text : '';
}

sub create_node {
	
	my ($curl,$customid, $title, $level, $spec_flag) = @_;
	my %sm = (
		data_id => $customid,
		data_url => $curl,
		full_ru => $title, 
		title_ru => $title,
		color => $spec_flag ? 'purple': "red",
		x => $x,
		y => $y,
		index=> 0,
		weight => 4,
		fixed => 0,
		level => $level,
		id => $graph_id
	);
	push @arr, \%sm;
	++$graph_id;
	$x +=10;
	$y +=10;
	return $sm{id};
}

sub process_listitem {
	my ($segment, $parent_id, $join_flag) = @_;
	my $data_id	= $segment->attr("data-id"); 
	if ($data_id) {
		my $data_name	= $segment->attr("data-name"); 
		my $data_url	= $segment->attr("data-url");
		my $stripped	= Mojo::URL->new($data_url)->path->to_abs_string;
		$data_url	= Mojo::URL->new($stripped)->base(Mojo::URL->new('http://interneturok.ru'))->to_abs->to_string;
		$data_name =~ s/\&nbsp\;/ /g;
		$data_name =~ s/\s+/ /g;
		say REP $data_id.',"'.$data_name.'"';
		# say "\t".$data_name;
		
		my $real_id = create_node ($data_url, $data_id, $data_name, 5);
		# push @links, {source=> $parent_id, target=>$real_id, relation=>'section'};
		chain2section($real_id, $parent_id);
		
		
		if ($join_flag) {
			chain2section($real_id, $grade_id);	
			chain2order ($real_id);
		} 
	} else {
		die $segment->to_string();
	}
	
}
sub chain2section {
	my ($this, $up) = @_;
	push @links, {source=> $up, target=>$this, relation=>'section'};
}

sub chain2order {
	my ($id) = @_;
	$pre = create_node('', '', $in, 3, 1) unless ($pre);
	push @links, {source=> $pre, target=>$id,  relation=>'order'};
	$pre = $id;
}

sub get_listed {
	my ($url) = @_;
	my $tx = $ua->get($url);
	my $res = $tx->res;
	$url = $tx->req->url;
	say STDERR $url;
	die 'Error '.$res->error if $res->error;
	my $raw = $tx->res->body;
	say STDERR "Got page OK: ".length($raw);
	my $dom = Mojo::DOM->new(decode_utf8($raw));
	#--------------------------------------------------#
	my $subj = $dom->at('.b-grade__title')->text(); 
	if (exists $cats{$subj}) {
		$subj_id = $cats{$subj};
	} else {
		$subj_id = create_node('', '', $subj, 2);
		$cats{$subj} = $subj_id;
	}
	#--------------------------------------------------#
	my $grade = $dom->at('.b-grade-switcher__current')->text();
	if (exists $cats{$grade}) {
		$grade_id = $cats{$grade};
	} else {
		$grade_id = create_node('', '', $grade, 2);
		$cats{$grade} = $grade_id;
	}
	#--------------------------------------------------#
	for my $area ($dom->find('ul.list > li.list__item')->each) {
		my $section_id;
		my $section = $area->at('h4')->text(); # lvl3
		# say $section;
		
		if (exists $cats{$section}) {
			$section_id = $cats{$section};
		} else {
			$section_id = create_node('', '', $section, 3);
			push @links, {source=> $subj_id, target=>$section_id};			
			$cats{$section} = $section_id;
		}
		
		for my $part ($area->find('ul.list__item__children > li.list__item.m-heading')->each) {
			if ($part->matches('.m-group')) {
				my $data_chapter_id = $part->attr("data-chapter_id");
				my $chapter_name = $part->at('a > span')->text();
				# say STDERR "\t●".
				# add chapter to list
				my $chapter_id = create_node('', $data_chapter_id, $chapter_name, 4);
				# push @links, {source=> $section_id, target=>$chapter_id};
				chain2section($chapter_id, $section_id);
				chain2order ($chapter_id);
				for my $item ($part->find('ul.list__item__children > li.list__item')->each) {
					process_listitem ($item, $chapter_id);
				}
				
			} else {
				process_listitem ($part, $section_id, 1);
			}
		}
	}
	
	my $whatsnext = $dom->at('.b-grade-switcher__link_style_next');
	# $whatsnext = 0;
	if ($whatsnext){
		my $classlabel = $whatsnext->at('span')->text();
		say "→".$classlabel;
		my $next_url = Mojo::URL->new($whatsnext->attr('href'))->base(Mojo::URL->new('http://interneturok.ru'))->to_abs->to_string;
		say $next_url;
		$classlabel =~ /(\d)/;
		my $nextclass = $1;
		if ($1 < 5) {
			say $1;
			&get_listed($next_url);
		}
		
	} else {
		say "finish";
	}
}
chain2order(create_node('', '', $out, 3, 1));
my %json_hash = (nodes => \@arr, links => \@links, last_index=> ++$graph_id);
say  FH encode_json (\%json_hash);