#!/usr/bin/perl

##############################################################################
# Sen Peng
# Usage: Randomly Extract Matched Read Sequence from Read1 and Read2 files
# based on seqID file provided
##############################################################################

use strict;
use warnings;
use Getopt::Std;
use File::Basename;

## CONSTANTS ##
my $TRUE              = 1;
my $FALSE             = 0;
my $DEBUG             = $FALSE;
my $EXITSTATUS        = 0;

# Get the options passed at the command prompt
GetOptions();

##############################
#   M A I N   P R O G R A M  #
##############################

# Check to see we received two files in the arguments
if(scalar(@ARGV) != 3)
{
	print STDERR "Incorrect number of arguments\n";
	Usage();
	exit(1);
}

my $fail = $FALSE;

# Check to see if the files exist
foreach my $file (@ARGV)
{
	if(!-e $file)
	{
		print STDERR "File $file didn't exist\n";
		$fail = $TRUE;
	}
}

# If any of the files didn't exist,kill the script
if($fail)
{
	exit(1);
}

# Read the file names in from the command line
my $random = shift(@ARGV);
my $read1 = shift(@ARGV);
my $read2 = shift(@ARGV);

my $date = `date`;
chomp($date);
print STDERR "BEGIN RandomlyExtractReadsFromRead2 on $read1 $read2 at $date\n";

# Index the first file.
my $ids = IndexFastq($random);

# Compare the two files
ExtractFastq($read1, $read2, $ids);

$date = `date`;
chomp($date);
print STDERR "END RandomlyExtractReadsFromRead2 on $read1 $read2 at $date\n";

exit($EXITSTATUS);

# Subroutines
sub Usage
{
    my $base = basename($0);
    print "Usage: $base [dh] random Read1 Read2\n";
    print "\td:\tDebug mode on (default off)\n";
    print "\th:\tPrint this usage\n";
}

sub GetOptions
{
    # Get the options passed at the command prompt
    my %options=();
    getopts("dh", \%options);
    
    if(defined($options{'d'}))
    {
	$DEBUG = $TRUE;
    }
    
    if(defined($options{'h'}))
    {
	Usage();
	exit($EXITSTATUS);
    }
}

sub IndexFastq
{
    my $file = shift;
    my $ids;
    
    open(IN, $file) or die("Could not open $file\n");
    my $seqCounter = 0;
    my $lineCounter = 1;
    while(my $line = <IN>)
    {
	chomp($line);
	
	# Each block is going to be of 4 lines
	# Assuming both reads come from same machine and flowcell lane
		
	if($line =~ m/^@(.*?):(\d+):(.*?):(\d+):(\d+):(\d+):(\d+)\.*/) # CASAVA 1.8+
	{
	    #@HWI-ST1025:64:D09CVACXX:8:1101:1133:1921 2:N:0:TGACCA
	    #HWI-ST1025   Instrument
	    #64           Run
	    #D09CVACXX    Flowcell
	    #8            Lane
	    #1101         Tile
	    #1133         X coord
	    #1921         Y coord
	    #2            Pair number [1/2]
	    #N            Fails QC [Y/N]
	    #0            No control bits [even numbers]
	    #TGACCA       Index tag

	    $seqCounter++;
		$line =~ s/\/\d+$//;
		$line =~ s/\s+.*//;
	    $ids->{$line} = 1;
	}
	elsif($line =~ m/^\#/)
	{
	    print STDERR "File: $file\[$lineCounter]: Skipping comment line: $line\n" if($DEBUG);
	}
	elsif($line =~ m/^$/)
	{
	    print STDERR "File: $file\[$lineCounter]: Skipping empty line: $line\n" if($DEBUG);
	}
	else
	{
	    print STDERR "File: $file\[$lineCounter]: Could not match the sequence ID from the name: $line\n" if($DEBUG);
	}
	$lineCounter++;
    }
	print STDOUT "$seqCounter sequence has been indexed\n";
    close(IN);
    
    return $ids;
}
print STDOUT "\n";
sub ExtractFastq
{
    my $read1       = shift;
    my $read2       = shift;
    my ($ids)       = shift;        
    my $seqCounter1 = 0;
	my $seqCounter2 = 0;
    # We don't want to have to open/close file handles each time, so let's open them here
	open(F1EOUT, ">${read1}_Extracted.fastq") or die("Could not write to file: ${read1}_Extracted.fastq\n");
    open(F2EOUT, ">${read2}_Extracted.fastq") or die("Could not write to file: ${read2}_Extracted.fastq\n");
    
    open(F1IN,'-|', "gunzip -c $read1") or die("Could not open $read1\n");
	while(my $line = <F1IN>)
    {
	chomp($line);
	
	# Skip empty lines or comments
	if($line =~ m/^$/g or $line =~ m/^\s*\#/)
	{
	    next;
	}
	
	# Each read consists of four lines
		
	if($line =~ m/^@(.*?):(\d+):(.*?):(\d+):(\d+):(\d+):(\d+)\.*/) # CASAVA 1.8+      
	{
	    $line =~ s/\/\d+$//;
		$line =~ s/\s+.*//;
		if(exists $ids->{$line})
	    {
		$seqCounter1++;
		# Print out from read1
		print F1EOUT $line . "\n";
		for(my $i=0; $i<3; $i++)
		{
		    my $tmpLine = <F1IN>;
		    print F1EOUT $tmpLine;
		}
	    }

	}
	else
	{
#	    print STDERR "Could not match the sequence ID from the name: $line\n";;
	    next;
	}
    }
	close(F1IN);
	close(F1EOUT);
	print STDOUT "$seqCounter1 sequence extracted from Read1\n";
	open(F2IN,'-|', "gunzip -c $read2") or die("Could not open $read2\n");
    while(my $line = <F2IN>)
    {
	chomp($line);
	
	# Skip empty lines or comments
	if($line =~ m/^$/g or $line =~ m/^\s*\#/)
	{
	    next;
	}
	
	# Each block is going to be of 4 lines
	# Let's get the seq ID from the sequence name
		
	if($line =~ m/^@(.*?):(\d+):(.*?):(\d+):(\d+):(\d+):(\d+)\.*/) # CASAVA 1.8+      
	{

	    $line =~ s/\/\d+$//;
		$line =~ s/\s+.*//;
		if(exists $ids->{$line})
	    {
		$seqCounter2++;
		# Print out from file 2
		print F2EOUT $line . "\n";
		for(my $i=0; $i<3; $i++)
		{
		    my $tmpLine = <F2IN>;
		    print F2EOUT $tmpLine;
		}
	    }

	}
	else
	{
#	    print STDERR "Could not match the sequence ID from the name: $line\n";;
	    next;
	}
    }
    close(F2EOUT);
    close(F2IN);
	print STDOUT "$seqCounter2 sequence extracted from Read2\n";
    print STDOUT "\n";
}