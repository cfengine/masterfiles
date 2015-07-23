#!/usr/bin/perl

use warnings;
use strict;
use JSON;

# turn this off if you want "x.enabled" not to be converted to a bool
my $convert_enabled_to_boolean = 1;

print "^meta=inventory\n";
print "^context=cfe_autorun_inventory_LLDP\n";

my %entries;
while (<>)
{
 chomp;
 if (m/^([^=]+)=(.+)$/)
 {
  add_entry(\%entries, $1, $2);
 }
}

my $encoder = JSON->new();
print "%lldp=", $encoder->encode(\%entries), "\n";

sub add_entry
{
 my $d = shift @_;
 my $k = shift @_;
 my $v = shift @_;

 if ($convert_enabled_to_boolean && $k =~ m/([^\.]+)\.enabled/)
 {
  my $kbool = $1;
  $d->{$kbool} = jconvert($v);
 }
 elsif ($k =~ m/([^\.]+)\.(.+)/)
 {
  my $k0 = $1;
  my $k1 = $2;

  $d->{$k0} ||= {};
  add_entry($d->{$k0}, $k1, $v);
 }
 else
 {
  $d->{$k} = jconvert($v);
 }
}

sub jconvert
{
 my $v = shift;

 return JSON::true if $v eq 'on';
 return JSON::false if $v eq 'off';

 return JSON::true if $v eq 'yes';
 return JSON::false if $v eq 'no';

 return 0+$v if $v =~ m/^[0-9]+$/;

 return $v;
}
