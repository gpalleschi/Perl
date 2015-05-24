#!/usr/bin/perl -w

#
# GPSoft - Giovanni Palleschi - 2010 - PrgAsn1.pl Utility read file ASN.1 - Ver. 2.0 
#
# perl PrgAsn1.pl <File Asn1> [<File Name Conversion>]
#
# [...] opcional
#
# This script perl produce a BER Codification in STDOUT of an ASN1 File.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

#Start Declarative 


# Start Function to convert hex value 

sub dataConvert {
  my ($hexvalue, $type) = @_;
  $valueConv = $hexvalue;

# Hex to Ascii
  if ( $type eq 'A' ) {
     $valueConv = pack("H*", $hexvalue);
  }
# Hex to Binary
  if ( $type eq 'B' ) {
     $valueConv = unpack("B*", pack("H*", $hexvalue));
  }
# Hex to Number
  if ( $type eq 'N' ) {
     $valueConv = hex $hexvalue;
  }

  return $valueConv;
}

# End Function to convert hex value 


sub getConv() {

  open FILEC, $ARGV[1] or die "Couldn't open file: $ARGV[1] $!\n";

  foreach $line (<FILEC>) {
    if ( length($line) > 4 ) {
       $convs{ substr($line,1,length($line)-2) } =  substr($line,0,1);
    }
  }

  close FILEC;
}

sub CtrlInfinitiveEnd() {
    my $retCode = "00";
    my $curpos  = tell FILE;
   
    for($i=0;$i<2;$i++) {
       last if ( readAsn1() ne "00" );
    }

    if ( $i == 2 ) {
       return 1;
    }

    seek(FILE, $curpos, 0);
    return 0;
}

sub GetPrimitiveValue {

  my ($lenValue) = @_;
  my $sretvalue = "";
  $ind = 0;

  while ( ($lenValue > 0 && $ind < $lenValue) or
          ($lenValue < 0 && CtrlInfinitiveEnd() == 0) 
	) {
   
     $sretvalue = sprintf("%s%s",$sretvalue,readAsn1());
     $ind = $ind + 1;

  }

  return $sretvalue
}

sub readAsn1 { 
    my $retCode = sprintf("%02x",ord(getc( FILE )));
    if ( eof(FILE) ) {
       printf("\n");
       close(FILE);
       exit 0;
    }
    return $retCode;
}

sub getTag {

    my $length;
    my $startByte = tell FILE;
    my $taghex = readAsn1();
    my $next = hex $taghex;

    if ( $next == 0 ) { return; }

    $next = $next & 0xff;
    
    $id = ($next & 192) >> 6;

    if ( (($next & 32) >> 5) == 1 ) {
       $flag = "false";
    }
    else {
       $flag = "true";
    }

    $tag = ($next & 31);

    if ( $tag == 31 )
    {
      $taghex = sprintf("%s%s",$taghex,readAsn1());
      $nextbis = hex $taghex;

      $nextbis = $nextbis & 0xff;

      $tag = $nextbis & 127;
      while( 128 == ( $nextbis & 128 ) )
      {
        $taghex = sprintf("%s%s",$taghex,readAsn1());
        $nextbis = hex $taghex;

        $nextbis = $nextbis & 0xff;
        $tag = $tag << 7 | ( $nextbis & 127 );
      }
    }

    $ATag[$iLevel] =  sprintf ("$id-$tag"); 
    $HTag[$iLevel] =  sprintf ("$taghex"); 

    $TagApp = $ATag[0];
    $TagAppH = $HTag[0];
    for($iInd=1;$iInd<$iLevel+1;$iInd++) {
      $TagApp2 = $TagApp . "." . $ATag[$iInd];
      $TagApp = $TagApp2;
      $TagApp2H = $TagAppH . "." . $HTag[$iInd];
      $TagAppH = $TagApp2H;
    }
    
    $CodeTag = sprintf ("$TagApp [$TagAppH] offset [$startByte]");

    $next = hex readAsn1();

    $nbyte = $next & 127;

    if ( ($next & 128) == 0 )
    {
      $length = $nbyte;
    }
    else
    {
      if ( $nbyte > 0 )
      {
        if ( $nbyte > 4 ) {
          $CodeTag = "ERROR TAG";
          return;
        }
        else {
          $next = hex readAsn1();

          $length = $next;
          for($contabyte=1;$contabyte<$nbyte;$contabyte++)
          {
            $next = hex readAsn1();

            $length = $length << 8 | ( $next );
          }
        }
      }
      else
      {

# Length Infinity

        $length = -1;
      }
    }
    printf("\n");

    for($i=0;$i<$iLevel;$i++) {
       printf("	");
    }

    if ( $length < 0 ) {
       printf("$CodeTag length : indefinite ");
    } else {
       printf("$CodeTag length : $length ");
    }

# Primitive Tag read value

    if ( $flag eq "true" ) {
       $value = GetPrimitiveValue($length);
       printf(" Hex Value <$value> ");

       if ( keys( %convs ) > 0 ) {
          if (exists($convs{$TagApp})) {
             $typeConv = $convs{$TagApp};
             $datoConv = dataConvert($value,$typeConv);
             printf(" Conv <%s> Value <%s>",$typeConv,$datoConv);
          }
       }

    } else {

# Structured Tag read next tag

      $iLevel  = $iLevel + 1;
      while ( (($length > 0) && ((tell FILE) - $startByte + 1) < $length) or
              (($length < 0) && CtrlInfinitiveEnd() == 0) ) {
            getTag();
      }
      $iLevel  = $iLevel - 1;
   }
   return;
}

# Start Prg

# Variable Convertions
my %hash = ();

#End Declarative 

if ($#ARGV < 0 ) {
   print "usage: perl PrgAsn1.pl <File Asn1> [-s<File Name Conversion>]\n";
   exit;
}

# Check Parameters

if ($#ARGV == 1 ) {

# File Conversion Management

      getConv();

}

$flag_cont=1;

open FILE, $ARGV[0] or die "Couldn't open file: $ARGV[0] $!\n";

printf("\nASN1 FILE $ARGV[0] \n");

$iLevel  = 0;

while ( $flag_cont == 1 ) {

   getTag();

}

__END__
