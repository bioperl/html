#!/usr/local/bin/perl -w

#---------------------------------------------------------------------------
# PROGRAM  : blast_seq.pl
# PURPOSE  : To submit a set of sequence for Blast analysis and parse the results.
# AUTHOR   : Steve A. Chervitz
# CREATED  : 15 May 1998
# REVISION : $Id$
# WEBSITE  : http://bio.perl.org/Projects/Blast/
# USAGE    : blast_seq.pl -h
# EXAMPLES : blast_seq.pl -eg
#
# INSTALLATION: 
#    Set the require ".../blast_config.pl" and require ".../seqtools.pl" 
#    to point to the proper location of these files on your system.
#    See blast_config.pl and seqtools.pl for additional steps.
#
# MODIFIED:
#  sac, 16 Jun 1998: Added installation comment, require statement comments.
#---------------------------------------------------------------------------

# Using files in the examples/blast distribution directory:
require "../seq/seqtools.pl";
require "blast_config.pl";
# Proper paths after you install them in your system:
#require "/share/www-data/html/perlOOP/bioperl/bin/seq/seqtools.pl";
#require "/share/www-data/html/perlOOP/bioperl/bin/blast/blast_config.pl";

use vars qw($ID $VERSION $DESC %runParam %blastParam 
	    $opt_parse $opt_table $opt_compress );

# Command-line options to be imported into seqtools.pl.
# This allows us to set all params we need with one GetOptions() call.
@blast_opts = qw(prog=s vers=s db=s html! v=s b=s expect=s gap!
		 filt=s mat=s gap_c=s gap_e=s email=s word=s
		 parse! signif=s strict! stats! best!    
		 table=s compress! rem! loc! check_all!
		 );
$ID      = 'blast_seq.pl';
$VERSION = 0.1;
$DESC    = "Run and parse a set of Blast reports given a set of Fasta formatted sequences";

#### Main #####

&init_seq(\&blast_seq_usage, @blast_opts);

&set_blast_params();

&load_ids();

&get_seq_objs(\&blast_seq);

&wrap_up_seq();

################


#---------------------
sub blast_seq_usage {
#---------------------

    &seq_usage;

    print STDERR <<"QQ_NOTE_QQ";

blast_seq.pl can take potentially many parameters since
it incorporates functionalities for both manipulating Fasta
sequence (seqtools.pl) and running/parsing Blast reports
(blast_config.pl). These parameters will be shown in three sets:

  (1) parameters for manipulating the sequence file.
  (2) parameters for running the Blast reports.
  (3) parameters for parsing the Blast reports.

To take full advantage of all the options, it would be a good idea
to try using the seq and blast scripts individually.

QQ_NOTE_QQ

    print STDERR "Hit <RETURN> to view parameters."; <STDIN>;

    &seq_params;

    print STDERR "Hit <RETURN> to view Blast run parameters."; <STDIN>;

    &blast_params;  # print both run and parse params.
    &blast_general_params;

}


#------------
sub examples {
#------------
<<"QQ_EG_QQ";
(Run this in the examples/blast/ directory of the distribution.)

  ./$ID seq/seqs.fasta -eid -prog blastp -db yeast -signif 1e-5 -table 2 > runseqs.out

QQ_EG_QQ
}

#----------------
sub blast_seq {
#----------------
# This method will be called for each sequence in the indicated file.
# Each sequence is sent off for blast analysis and then the 
# resulting blast object is processed further.

    my $seq = shift;

    print STDERR "\nBLASTing sequence ${\$seq->id}\n";

    $runParam{-seqs} = [ $seq ];
    $blastParam{-run} = \%runParam;

    # Verifying the data structure:
 #   print STDERR "Sequence to be blasted:\n";
#    print STDERR $blastParam{-run}->{-seqs}->[0]->layout(); 
       
    my ($blast_obj);
    eval { 
	$blast_obj = &create_blast;
    };
    next if($@);

    $opt_compress && $blast_obj->compress_file; 
    
    if($opt_parse) {
	if ($opt_table) {
	    &print_table($blast_obj);
	} else {
	    $blast_obj->display();
	}
    }
    $blast_obj->destroy;
}    




