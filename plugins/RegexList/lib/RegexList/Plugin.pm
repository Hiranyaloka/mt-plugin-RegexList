# Copyright 2011 Rick Bychowski: Hiranyaloka
# This program is free software; you can redistribute it and/or modify it
# under the terms of either: the GNU General Public License as published
# by the Free Software Foundation; or the Artistic License.
# See http://dev.perl.org/licenses/ for more information.

package RegexList::Plugin;
use strict;
use MT 4;

sub regex_list {
  my ( $str, $val, $ctx ) = @_;
  my $app = MT->app;
  my @matches;
  my @subs;
  
  # Requires an array
  die "regex_list requires multiple arguments." unless ref($val) eq 'ARRAY';
  my $subst_patt  = $val->[0];
  my $replace     = $val->[1];
  my $match_patt  = $val->[2];
  my $capture     = $val->[3];
  
  # Restrict $capture to single non-zero digit or default is &
  $capture = $capture =~ /^\s*([1-9])\s*/;
  $capture = ($capture || '&');
  
  #store match from first regex into an array
  if ( $match_patt =~ m!^(/)(.+)\1([A-Za-z]+)?$! ) {
    $match_patt = $2;
    if ( my $opt = $3 ) {
      $opt =~ s/[ge]+//g;
      # Mode modifier is moved into the regex using ($modifier) syntax
      $match_patt = "(?$opt)" . $match_patt;
    }
    my $re = eval {qr/$match_patt/};
    
    if ( defined $re ) {
      eval {
        while ($str =~ /$re/go) {
          no strict 'refs';
          push (@matches, $$capture);
          use strict 'refs';
      $app->log({
        message => "Pushed  '"
          . $& . "' to matches."
      });
        }
      };
      if ($@) {
        return $ctx->error("Invalid regular expression: $@");
      }
    }
  }
  
  if ( $subst_patt =~ m!^(/)(.+)\1([A-Za-z]+)?$! ) {
    $subst_patt = $2;
    my $global;
    if ( my $opt = $3 ) {
      $global = 1 if $opt =~ m/g/;
      $opt =~ s/[ge]+//g;
      # Mode modifier is moved into the regex using ($modifier) syntax
      $subst_patt = "(?$opt)" . $subst_patt;
    }
    my $re = eval {qr/$subst_patt/};
    if ( defined $re ) {
      $replace =~ s!\\\\(\d+)!\$1!g;  # for php, \\1 is how you write $1
      $replace =~ s!/!\\/!g;
      for my $m (@matches) {
        eval '$m =~ s/$re/' . $replace . '/o' . ( $global ? 'g' : '' );
        push (@subs, $m);
      $app->log({
        message => "Pushed  '"
          . $m . "' to subs."
      });
        if ($@) {
          return $ctx->error("Invalid regular expression: $@");
        }
      }
    }
  }
  
  return \@subs;
}

sub mt_log {
   my ($app, $msg) = @_;
   $app->log({
    message => $msg
  });
}

1;
