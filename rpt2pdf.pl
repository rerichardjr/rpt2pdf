#################################
# rpt2pdf.pl                    #
# v 1.3                         #
# 12/03/04 11:07 PM             #
# Converts reports to PDFs      #
#################################

use Net::FTP;

my $prog_name="RPT2PDF";
my $prog_ver="v1.3";
my $email="rerichardjr";
my $rpt_cfg="default.cfg";
my $ftp_cfg="ftp.cfg";
my $download="no";
my $rpt_file;
my %rpt_opt;
my %ftp_opt;
my $obj_number;
my $outlines_obj;
my $page_parent_obj;
my $info_obj;
my $font_obj;
my $procset_obj;
my $root_obj;
my $count_obj;
my $kids_obj;
my $xref_offset;
my $page_count;
my $stream_length;
my $start_stream;
my $end_stream;
my $time_stamp=time();
my @page_obj_kids;
my @xref_offsets;

# Check parameters
$param=@ARGV;

# If no arguments use default.cfg with no download
if ($param ne 0) {
	# Arguments passed, expecting 3 or less
	if ($param le 3) {
		# Print help message
		if ($param eq 1 and ($ARGV[0] eq "-h" or $ARGV[0] eq "--help")) {
			goto HELP;
		}
		# Only passed config file
		if ($param eq 2 and $ARGV[0] eq "-c" and $ARGV[1] ne "") {
			$rpt_cfg=$ARGV[1];
		# Passed config file and download option
		} elsif ($param eq 3 and $ARGV[0] eq "-c" and $ARGV[1] ne "" and $ARGV[2] eq "--download") {
			$rpt_cfg=$ARGV[1];
			$download="yes";
		# Only passed download option, will use default.cfg
		} elsif ($param eq 1 and $ARGV[0] eq "--download") {
			$download="yes";
		} else {
			goto HELP;
		}
	} else {
		HELP:print $prog_name . " " . $prog_ver . "\n";
		print "usage:  rpt2pdf.pl [-h] [-c conf-file] [--download]\n";
		print "\n";
		print "optional arguments:\n";
		print "  -h, --help		show this help message and exit\n";
		print "  -c config.cfg		process config file\n";
		print "  --download		download report from mainframe using FTP\n";
		exit;
	}
}

# Get config info
open(CFG, "<$rpt_cfg") or die "Error opening " . $rpt_cfg . "\n";
	print "Getting parameters from " . $rpt_cfg . "\n";
	foreach $option (<CFG>) {
		chomp $option;
		if ($option eq /^#/) {
			next;
		}
	@configs=split(/=/, $option);
	$rpt_opt{$configs[0]}=$configs[1];
}
close(CFG);

# Setup username and desktop options
if ($rpt_opt{report} eq "username") {
	$rpt_opt{report}=$ENV{username};
}

if ($rpt_opt{pdf_save} eq "desktop") {
	$rpt_opt{pdf_save}=$ENV{userprofile} . "\\desktop";
}

# Download?
if ($download eq "yes") {
	&DOWN;
}

# Setup for BBox check
my $y_cord_total=$rpt_opt{y_cord};

# Inform user
print $prog_name . " " . $prog_ver . "\n";
print "Generating PDF Report $rpt_opt{pdf_output}_$time_stamp.pdf \n";

# Open filehandle PDF
open(PDF, ">$rpt_opt{pdf_save}\\$rpt_opt{pdf_output}_$time_stamp.pdf") or die "Error creating " . $rpt_opt{pdf_output} . ".pdf\n";
	&pdf_header;
	&kids_obj;
	&pdf_xref_table;
	&pdf_footer;

	# Start dumping pdf contents to PDF
	sub pdf_header {

		# PDF header obj
		&get_offset(print PDF "%PDF-1.3 %����\n");

		# Outlines obj
		$outlines_obj=$obj_number;
		print PDF $outlines_obj . " 0 obj\n";
		print PDF "<< /Type /Outlines\n";
		print PDF "/Count 0\n";
		print PDF ">>\n";
		&get_offset(print PDF "endobj\n");

		# Info obj
		$info_obj=$obj_number;
		print PDF $info_obj . " 0 obj\n";
		print PDF "<<\n";
		print PDF "/Creator (rerichardjr \:\\))\n";
		print PDF "/Title (" . $rpt_opt{location} . " " . $rpt_opt{pdf_title} . ")\n";
		print PDF "/Producer (" . $prog_name . " " . $prog_ver . " - " . $email . ")\n";
		print PDF "/Author (" . $ENV{username} . ")\n";
		($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(time);
		$yy=$year+1900;
		$mm=$mon+1;
		print PDF "/CreationDate (D:";
		print PDF $yy;
		# Following variables are 2 digits, so pad them
		printf PDF "%.2ld",$mm;
		printf PDF "%.2ld",$mday;
		printf PDF "%.2ld",$hour;
		printf PDF "%.2ld",$min;
		printf PDF "%.2ld",$sec;
		print PDF ")\n"; 
		print PDF ">>\n";
		&get_offset(print PDF "endobj\n");

		# Pages obj
		$page_parent_obj=$obj_number;
		print PDF $page_parent_obj . " 0 obj\n";
		# Increment obj_number for kids_obj
		$kids_obj=++$obj_number;
		print PDF "<< /Type /Pages\n";
		print PDF "/Kids " . $kids_obj . " 0 R\n";
		# Increment obj_number for count_obj
		$count_obj=++$obj_number;
		print PDF "/Count " . $count_obj . " 0 R\n";
		print PDF ">>\n";
		&get_offset(print PDF "endobj\n");

		# Root obj
		$root_obj=$obj_number;
		print PDF $root_obj . " 0 obj\n";
		print PDF "<< /Type /Catalog\n";
		print PDF "/Outlines " . $outlines_obj . " 0 R\n";
		print PDF "/Pages " . $page_parent_obj . " 0 R\n";
		print PDF ">>\n";
		&get_offset(print PDF "endobj\n");

		# Procset obj
		$procset_obj=$obj_number;
		print PDF $procset_obj . " 0 obj\n";
		print PDF "[/PDF /Text]\n";
		&get_offset(print PDF "endobj\n");

		# Font obj
		$font_obj=$obj_number;
		print PDF $font_obj . " 0 obj\n";
		print PDF "<< /Type /Font\n";
		print PDF "/Subtype /Type1\n";
		print PDF "/Name /F1\n";
		print PDF "/BaseFont /". $rpt_opt{font_type} . "\n";
		print PDF "/Encoding /WinAnsiEncoding\n";
		print PDF ">>\n";
		&get_offset(print PDF "endobj\n");
		&report_data;
	}

	# Read in reports data from filehandle RPT
	sub report_data {
		open(RPT, "<$rpt_opt{report}.txt") or die "Error getting report data from " . $rpt_opt{report} ."\n";
		binmode(RPT);
		foreach $line (<RPT>) {
			chomp $line;
			print ".";
			if ($line =~ /^\s/ and $page_count<1) {
				$line =~ s/^\s/1/;
			}
			# If first digit is 1 or BBox y cord is less than or equal to 30, start a new page
			if ($line =~ /^[1]/ or $y_cord_total<=30) {
					$page_count++;
				# If first page is done, start printing object footer
				if ($page_count>=2) {
					&page_obj_footer;
				}
				&page_obj_header;
			}
			# If first digit is 0, single space
			if ($line =~ /^[0]/) {
				print PDF "T* () Tj\n";
				$y_cord_total-=$rpt_opt{font_pnt};
			}
			# If first digit is -, double space
			if ($line =~ /^[-]/) {
				print PDF "T* () Tj\n";
				print PDF "T* () Tj\n";
				$y_cord_total-=$rpt_opt{font_pnt};
			}
			# Clean up reports
			# Delete first space, digit or - from report
			$line =~ s/^(\s|\d|-)//;
			# Replace \ with / 
			$line =~ s/\\/\//g;
			# Replace ( and ) with \( and \)
			$line =~ s/\(/\\(/g;
			$line =~ s/\)/\\)/g;
			# Replace EOF
			$line =~ s/(\cz|\x1a|\032)//g;
			# Get length of line and add it to stream_length
			$stream_length+=length("T* (" . $line . ") Tj\n");
			print PDF "T* (" . $line . ") Tj\n";
			$y_cord_total-=$rpt_opt{font_pnt};
		}
		&page_obj_footer;
		close(RPT);
	}


	# Print page object header
	sub page_obj_header {

		# Page obj
		$page_obj_kids[$page_count]=$obj_number;
		print PDF $obj_number . " 0 obj\n";
		print PDF "<< /Type /Page\n";
		print PDF "/Parent " . $page_parent_obj . " 0 R\n";
		if ($rpt_opt{orientation} eq "portrait") {
			$size_x=612;
			$size_y=792;
		} else {
			$size_x=792;
			$size_y=612;
		}
		print PDF "/MediaBox [0 0 " . $size_x . " " . $size_y . "]\n";
		print PDF "/Contents " . ($obj_number+1) . " 0 R\n";
		print PDF "/Resources << /ProcSet " . $procset_obj . " 0 R\n";
		print PDF "/Font << /F1 " . $font_obj . " 0 R >>\n";
		print PDF ">>\n";
		print PDF ">>\n";
		&get_offset(print PDF "endobj\n");

		# Content obj
		print PDF $obj_number . " 0 obj\n";
		print PDF "<< /Length " . ($obj_number+1) . " 0 R >>\n";
		print PDF "stream\n";
		# Need offset for start of stream
		$start_stream=tell(PDF);
		print PDF "BT\n";
		print PDF "/F1 " . $rpt_opt{font_pnt} . " Tf\n";
		print PDF "20 700 Td\n";
		print PDF "1 0 0 1 " . $rpt_opt{x_cord} . " " .  $rpt_opt{y_cord} . " Tm\n";
		print PDF $rpt_opt{font_pnt} . " TL\n";
	}

	sub page_obj_footer {
		print PDF "ET\n";
		# Need offset for end of stream
		$end_stream=tell(PDF);
		print PDF "endstream\n";
		&get_offset(print PDF "endobj\n");
		$y_cord_total=$rpt_opt{y_cord};
		&stream_obj;
	}

	# Create stream length object
	sub stream_obj {
		print PDF $obj_number . " 0 obj\n";
		# Calculate stream length
		print PDF ($end_stream-$start_stream)-2 . "\n";
		# Zero out stream_length
		$stream_length=0;
		# If this is last page, no need to add more to xref table
		if ($stream_count<$page_count) {
			&get_offset(print PDF "endobj\n");
		} else {
			print PDF "endobj\n";
		}
	}

	# Create pages object
	sub kids_obj {
		my $i;
		$xref_offsets[$kids_obj]=(tell(PDF)-2);
		print PDF $kids_obj . " 0 obj\n";
		print PDF "[\n";
		# Get the kids out of array
		for ($i=1; $i<=$page_count; $i++) {
			print PDF $page_obj_kids[$i] . " 0 R\n";
		}
		print PDF "]\n";
		print PDF "endobj\n";
		$xref_offsets[$count_obj]=(tell(PDF)-2);
		print PDF $count_obj . " 0 obj\n";
		print PDF $page_count . "\n";
		print PDF "endobj\n";
	}

	# Build the xref table
	sub pdf_xref_table {
		my $x;
		$xref_offset=(tell(PDF)-2);
		print PDF "xref\n";
		print PDF "0 " . $obj_number . "\n";
		print PDF "0000000000 65535 f\n";
		for ($x=1; $x<$obj_number; $x++) {
			# The offset is 10 digits, so we need a pad
			printf PDF "%.10ld 00000 n\n",$xref_offsets[$x];
		}
	}

	# Print pdf footer
	sub pdf_footer {
		print PDF "trailer\n";
		print PDF "<< /Size " . $obj_number . "\n";
		print PDF "/Root " . $root_obj . " 0 R\n";
		print PDF "/Info " . $info_obj . " 0 R\n";
		print PDF ">>\n";
		print PDF "startxref\n";
		print PDF $xref_offset . "\n";
		print PDF "%%EOF\n";
	}

	# Get current offset
	sub get_offset {
		++$obj_number;
		$xref_offsets[$obj_number]=(tell(PDF)-2);
	}

close(PDF);

sub SET_FTP {
	print "Processing FTP config\n";
	open(FTP, "<$ftp_cfg") or die "Error opening " . $ftp_cfg . "\n";
	foreach $option (<FTP>) {
		chomp $option;
		if ($option eq /^#/) {
			next;
		}
		@configs=split(/=/, $option);
		$ftp_opt{$configs[0]}=$configs[1];
	}
close(FTP);
}

sub DOWN {
	&SET_FTP;
	&CONNECT;
	$localname = "$rpt_opt{report}.txt";
	#unlink $localname;
	$remotename = $rpt_opt{report};
	if ($remotename) {
		print "Downloading " . $rpt_opt{report} . "\n";
		$ftp->get($remotename, $localname) or die "Invalid Filename $remotename\n";
	}
	$ftp->quit;
}

sub CONNECT {
	print "Connecting to " . $ftp_opt{host} . "\n";
	$ftp = Net::FTP->new($ftp_opt{host}) or die "Couldn't Connect";
	$ftp->login($ftp_opt{uid}, $ftp_opt{pw}) or die "Invalid Username or Password";
	$ftp->cwd($ftp_opt{dir1}) or die "Invalid Directory 1";
	$ftp->cwd($ftp_opt{dir2}) or die "Invalid Directory 2";
}