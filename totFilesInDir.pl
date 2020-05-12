#!/usr/bin/perl

  $totfile = 0;
  opendir(my $dh, $ARGV[0]) || die;
  while(readdir $dh) {
     print "$some_dir/$_\n";
     $totfile++;
  }
  closedir $dh;

  printf(" Tot Files : $totfile \n");
