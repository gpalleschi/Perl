# GPSoft 2009 
#
# Utility for print file containing a specified string
#
# Program acepts these parameters : path, pattern
#
# The results is the same of "grep -l pattern path"
#
#

$pattern = $ARGV[0] || die("\n Error insert pattern to search.");
$directory = $ARGV[1] || die("\n Error insert file to search.");

@dir=<$directory/*.*>;

foreach $file(@dir)
{
  open (FL,"$file");
  while(<FL> )
  {
    if ($_ =~ /$pattern/)
    {
      push (@file_ok,$file);
      last;
    }
  }
  close (FL);
}

print "Files containing $pattern in dir $directory.\n";
$i=0;
foreach $file(@file_ok)
{
 $i=$i+1;
 print "$i - $file\n"
}
