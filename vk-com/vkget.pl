#!/usr/local/bin/perl
use strict;
use warnings;
use utf8;
use feature qw(say switch);
use Data::Dump qw(dump);
use WWW::Mechanize;
use Mojo::DOM;
use File::Slurp;
# binmode(STDOUT, ":utf8");
binmode(STDOUT, ":unix:utf8");
use open qw(:std :utf8);
use 5.010;
use POSIX;


use Encode qw(from_to decode encode);

my $page = read_file( "padsluchana_journbsu.htm",  binmode => ':utf8');

# from_to($body, $charset, 'utf-8');

my $dom = Mojo::DOM->new;
	$dom->parse($page);
	# my $str = substr ([$dom->find('label + span.info')->each]->[4]->text, 0, -4);
	# print $str;
	for my $e ($dom->find('div.post_table')->each) {
		# 
		# say $e->text;
		say  "-" x 50;
		say "<Post>";
		my ($post_uniq_id);
		my ($public_id, $post_id);
		
		for my $wt ($e->find('div.post_info  div.wall_post_text')->each){
			say $wt->text;
			($post_uniq_id) = $wt->parent->attrs("id") =~ /\w+\-(.*)/;
			($public_id, $post_id)  = $post_uniq_id =~ /(\d+)\_(\d+)/;
			# say "Post ID ".$wt->parent->attrs("id");
			# say "Post ID ".$wt->parent->attrs("id");
			# say "Public: $post_uniq_id\tPost $post_id";
			say "Post ID ".$post_id;
			# say "\t".$wt->type." ".$wt->attrs('class')."...!!";
		}
		
		if (my $repl_node = $e->at('div.replies')){
			my $timespan = $repl_node->at('div.reply_link_wrap small a span');
			say  "{{".$timespan->text;
			# <span class="rel_date">4 мар в 13:05</span>
			# my $time = $timespan->attrs("time");
			# say $time;
			# say localtime();
			
			my $replies_wrapper = $repl_node->at('div.replies_wrap div#replies-'.$post_uniq_id);
			
				
			if (my $wr_header = $replies_wrapper->at(' a.wr_header')){
				# <a class="wr_header" onclick="........" offs="3/18" href="/wall-59617643_4933?offset=last&amp;f=replies"></a>
				say $wr_header->attrs("offs");
			} elsif (my $wr_hidden = $replies_wrapper->at('input#start_reply-'.$post_uniq_id)){ 
				#<input type="hidden" id="start_reply-59617643_4963" value="4964" />
				# say $wr_hidden->attrs("value");
			} else {
				die;
			}
		}
		for my $rep ($e->find('div.post_info  div.replies div.replies_wrap div.reply')->each){
			my $au = $rep->at('a.author');
			# <a class="author" href="/yaraslau" data-from-id="79878104">Ярослав Климашевский</a>
			say "<<Reply [ID: ". $au->attrs("data-from-id")."\tName: ".$au->text."]>>";
			if (my $textnode = $rep->at('div.wall_reply_text')){
				if (my $greet = $textnode->at('a.wall_reply_greeting')){
					say "To: ".$greet->attrs("href");
					print $greet->text;
				}
				say $textnode->text;
			} else {
				say "NON-TEXT REPLY";
			}
			
			# say $rep->text;
			# say "\t".$wt->type." ".$wt->attrs('class')."...!!";
		}
		
		
}
	