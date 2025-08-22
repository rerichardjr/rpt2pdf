# History of RPT2PDF

This was a quick Perl script I wrote in 2004 to download mainframe reports and convert them to PDF. Operators were wasting roughly five to six sheets of continuous paper to print a one page report.  With ```RPT2PDF```, operators could now print this report on a laser printer or send to recepient using email.  Managers began opting for their daily green bar reports to be sent through email, rather than receiving physical green bar copies.  This greatly reduced the usage of both paper and the specialty printers.

I identified a bottleneck in print workflows at a 1.2M sq. ft. distribution center supporting 100+ retail stores and architected a Perl-based automation system that eliminated reliance on Océ VarioStream 7000 series printers for mainframe reporting. Unload/load cycles were wasting greenbar paper and operator time just to print a single 8.5x11 page report, so I replaced the physical print path for report workflows while preserving processes for Océ shipping label printing.

No one asked me to replace the greenbar printer process. I just saw paper waste and thought, 'I don't like that, I'm going to fix it."

Constraint Analysis:
• Operators manually unloaded and reloaded continuous feed greenbar and white paper, wasting material for single-page jobs
• Environment restricted to base Perl tools and Net::FTP module, no access to external PDF libraries or PDF format documentation
• Internet access completely locked down
• High-friction, multi-step process to retrieve and distribute mainframe reports, leading to inefficiency and waste

Solution:
I architected an Enterprise Report Transformation Engine to convert mainframe reports to PDF and shifted output from greenbar to laser-printed or digital PDF reports

Implementation:
• Reverse engineered PDF format using notepad
• Wrote Perl code to build PDF from scratch using only native Perl (~10-15 hours)
• Parsed raw mainframe reports and constructed fully compliant PDF files
• Built configs for report orientations and in-serviced operators on use

Strategic Value Demonstrated:
Impact: 
• $100K annual supply savings
• 50%+ reduction in paper waste
• Enterprise-wide process modernization
Technical:
• Enhanced scalability by enabling delivery of any mainframe report via email in both portrait and landscape formats
• Zero-dependency PDF engine
• Mainframe data parsing
• Perl-based automation under access constraints

# RPT2PDF

Converts mainframe reports to PDF.  These reports contained special formatting characters.

```t
1  start new page
0  single space
-  double space
```

Example of a [report](https://github.com/rerichardjr/RPT2PDF/blob/main/somereport.txt)

# Usage

```t
usage:  rpt2pdf.pl [-h] [-c conf-file] [--download]

optional arguments:
  -h, --help            show this help message and exit
  -c config.cfg         process config file
  --download            download report from mainframe using FTP
```

## Example config files used to convert a txt report into a PDF

somereport-landscape.cfg
```t
orientation=landscape
font_type=Arial
font_pnt=10
report=somereport
pdf_save=c:\RPT2PDF
pdf_output=somereport-landscape
pdf_title=This is somereport.txt converted to a landscape PDF
x_cord=18
y_cord=600
```

somereport-portrait.cfg
```t
orientation=portrait
font_type=Arial
font_pnt=10
report=somereport
pdf_save=desktop
pdf_output=somereport-portrait
pdf_title=This is somereport.txt converted to a portrait PDF
x_cord=18
y_cord=732
```

## Generating a landscape PDF report

```perl rpt2pdf.pl -c somereport-landscape.cfg```

Output

```t
Getting parameters from somereport-landscape.cfg
RPT2PDF v1.3
Generating PDF Report somereport-landscape_1671411288.pdf
....................................................................
```

Created [somereport-landscape_1671411288](https://github.com/rerichardjr/RPT2PDF/blob/main/somereport-landscape_1671411288.pdf)

