#!/usr/bin/perl

$indRec = 0;

# Open File Input
$filename = $ARGV[0] || die("\n\n Program acepts these parameters : File Name\n\n\n");

open(FILE, "< $filename") || die "Error in opening file $filename : $!";
while ($riga = <FILE>) {
   chomp $riga;
   if ( $indRec == 0 ) {
     @title = split(/	/,$riga);
   } else {

     printf("\n\n RECORD $indRec\n");

     @value = split(/	/,$riga);
     for ($i = 0; $i < $#title+1; $i++) { 
       printf("\n {$title[$i]} <$value[$i]>");
     }

   }
   $indRec = $indRec + 1;
}
$indRec = $indRec -1;
printf("\n\n TOTAL RECORDS : $indRec\n\n");
close (FILE);
