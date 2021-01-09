#!/usr/bin/perl

use XML::LibXML;

$parser = new XML::LibXML;

$struct = $parser -> parse_file("page194.htm");
$rootel = $struct -> getDocumentElement();

$elname = $rootel -> getName();
print "Root element is a $elname and it contains ...\n";

@kids = $rootel -> childNodes();
foreach $child(@kids) {
        $elname = $child -> getName();
        @atts = $child -> getAttributes();
        print "$elname (";
        foreach $at (@atts) {
                $na = $at -> getName();
                $va = $at -> getValue();
                print " ${na}[$va] ";
                }
        print ")\n";
        }
