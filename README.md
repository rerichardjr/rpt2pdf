# History of RPT2PDF

This was a quick Perl script I wrote in 2004 to download mainframe reports and convert them to PDF. Operators were wasting roughly five to six sheets of continuous paper to print a one page report.  With ```RPT2PDF```, operators could now print this report on a laser printer or send to recepient using email.  Managers began opting for their daily green bar reports to be sent through email, rather than receiving physical green bar copies.  This greatly reduced the usage of both paper and the specialty printers.

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
