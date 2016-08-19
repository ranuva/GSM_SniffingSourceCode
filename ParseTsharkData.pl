#use strict;
 use warnings;
 use IO::File;
 use File::Copy;

 use DBI;

  sub getMySqlConnection

  {
   my $dbh = DBI->connect("DBI:mysql:database=GSM_MS_BTS;host=localhost;port=3306",
	                   "root", "root123",
		          {'RaiseError' => 1});
      return $dbh;

  }
   sub asc_sort_subject{
	       $a <=> $b;           # Numeric sort ascending
       }

    
    sub getFileName
    {
    while ( 1 )
    {
      my ($DirName) = @_;
     opendir(DIR, $DirName);
     my @files =  (readdir(DIR));
     closedir(DIR);
     my @sorted_files = sort { -M "$DirName/$b" <=> -M "$DirName/$a" } @files;
     print join("\n",@sorted_files);

     if ( @sorted_files >= 4 )
     {

        return $sorted_files[1];
      }
     sleep 1;
     }

     
    }
 
   sub main()
   {
    my $SourceDir = $ARGV[0];
    my $ProcessedDir = $ARGV[1]; 
    my $fh;
    my $row;
    my @FieldsNames = ("GSM Frame Number:", "Channel Type:", "Antenna Number:", "Message Type:", "IMSI:", "Mobile Country Code (MCC):", "Mobile Network Code (MNC):", "Arrival Time:");
    my @DBFieldsNames = ("", "GSMFrame", "ChannelType", "AntennaNumber", "MessageType", "IMSI", "MCC", "MNC", "ArvTime");
    my %record;
    my $InsDBFields="";

    my $DBConnection = getMySqlConnection();



   while ( 1 )
    {  
         my $FileName = getFileName($SourceDir);
         print "\n File Name $FileName \n ";

         $FileName = $SourceDir . "/" . $FileName;
         print "\n File Name :$FileName:\n ";
 
         my  $read_fh = IO::File->new($FileName,'r');
         my $i = 1;
      my $recCount=1;
     $i=1;
  	while ( my $line = <$read_fh> )
   	{
	   $i=1;
       	  for my $FieldName (@FieldsNames)
       	   {
	      if ( $line =~ /$FieldName/ ) 
	        {   
	          my $tmpLine=$line;
	          $tmpLine =~ s/$FieldName//;
		  chomp $tmpLine;
	          #  print "$FieldName in $tmpLine\n";
		   $record{$i} = $tmpLine;
	  	  break;
                }
	      $i = $i + 1;
          }

         if ( $line =~ /^Frame / )
          {
              $i=1;
              $recCount = $recCount + 1;
              print "Record :: $recCount \n";

	      $InsDBFields="";
	      my $InsValues="";
	   
	        foreach $i (sort asc_sort_subject(keys(%record)))  
	      #  foreach $i (sort (keys(%record)))
	      #  foreach $i (sort { {$a} <=> {$b} } keys %record)
	       {
                 print "The field $DBFieldsNames[$i] $i is $record{$i}\n";
			my $tmp = $record{$i};
			$tmp =~ s/^\s+//;
			if ( length($tmp) > 50 )
			{
				$tmp = substr($tmp,0,50);
			}
			$tmp =~ s/^\s+//;
		 if (  length($InsDBFields) > 2 )
		     {
	                $InsDBFields =  $InsDBFields . ", " . $DBFieldsNames[$i];
			$InsValues   = $InsValues . ", \'". $tmp . "\'" ;
		      }
		     else
		   {
		 	      $InsDBFields =  $DBFieldsNames[$i];

			      $InsValues  = "\'". $tmp . "\'";
		   }
              } 

#	 for my $FieldName (@FieldsNames)
#	  {
#	    $record{$1} = " ";
#	    $i = $i + 1;
#	  } 
	      delete $record{key};
            for (keys %record ) { delete $record{$_};};  

	      my $query = "insert into GSM_MS_BTS ($InsDBFields) values ($InsValues)";
	      print "Query  $query \n";
	      my $statement = $DBConnection->prepare($query);

	       $statement->execute();
	      print "InsDBFileds  $InsDBFields \n";
          }

      }
     move ( $FileName, $ProcessedDir);
    }#End of While

    $DBConnection->disconnect();
 } #end of main

    main();
