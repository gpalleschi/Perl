#!/usr/bin/perl -w

#
# stat.pl ver 1.0
#
#
# This script execute a stat of a file in UNIX/LINUX environment
#

# Check parameters
if ($#ARGV < 0 ) {
   printf("\n Use stat.pl with one parameter, file name.\n\n");
   exit;
}

# Check if file exists
if ( !(-e $ARGV[0]) ) {
   printf("\n File <$ARGV[0]> don't exists.\n\n");
   exit;
}

($dev, $ino, $mode, $nlink, $uid, $gid, $rdev, $size,

    $atime, $mtime, $ctime, $blksize, $blocks) = stat($ARGV[0]);

print("dev     = $dev\n");

print("ino     = $ino\n");

print("mode    = $mode\n");

print("nlink   = $nlink\n");

print("uid     = $uid\n");

print("gid     = $gid\n");

print("rdev    = $rdev\n");

print("size    = $size\n");

print("atime   = $atime\n");

print("mtime   = $mtime\n");

print("ctime   = $ctime\n");

print("blksize = $blksize\n");

print("blocks  = $blocks\n");

 

($sec, $min, $hr, $day, $month, $year, $day_Of_Week, $julianDate, $dst) = localtime($ctime);

$year = $year + 1900;

$month = $month + 1;

printf(" ctime $year/$month/$day $hr:$min:$sec\n");

($sec, $min, $hr, $day, $month, $year, $day_Of_Week, $julianDate, $dst) = localtime($mtime);

$year = $year + 1900;

$month = $month + 1;

printf(" mtime $year/$month/$day $hr:$min:$sec\n");

($sec, $min, $hr, $day, $month, $year, $day_Of_Week, $julianDate, $dst) = localtime($atime);

$year = $year + 1900;

$month = $month + 1;

printf(" atime $year/$month/$day $hr:$min:$sec\n");

 
