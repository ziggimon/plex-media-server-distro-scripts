#!/usr/bin/perl
#-----------------------------------------------------------
# plex_functions.pl
# (c) 2012 Stefan Rubner <stefan@whocares.de>
#-----------------------------------------------------------
# 20120329 - initial revision
#-----------------------------------------------------------
use CGI;
use CGI::Carp qw(fatalsToBrowser);
use JSON;

our $mydlna = "/c/.plex/Library/Application Support/Plex Media Server/dlnaclientprofiles.xml";

do "/frontview/lib/addon.pl";
print "Content-type: text/html\n\n";
my $query = CGI->new;
my $param = $query->Vars;

my $action = $param->{'action'};

if ( $action eq "dlnaread" ) {
    my $jsontxt = {};
    if ( -e $mydlna ) {
	open(CF, '<', $mydlna) or die "Open dlnaclientprofiles.xml: $!";
	my @lines = <CF>;
	close(CF);

	$jsonarr = join('', @lines);
	$jsontxt->{'content'} = $jsonarr;
    } else {
	$jsontxt->{'content'} = '';
    }
    print to_json($jsontxt);
} elsif ( $action eq "dlnasave" ) {
    my $data = $query->param('data');
    my @jsondata = split(/\n/, $data);

    # sysopen(CF,"/tmp/dlna_test", O_WRONLY | O_TRUNC | O_CREATE)  or die "Open dlnaclientprofiles.xml: $!";
    open CF, '>', $mydlna	or die "Open dlnaclientprofiles.xml: $!";;
    foreach (@jsondata) {
      print CF "$_\n";
    }
    close(CF);

    my $SPOOL = "\n\n";
    $SPOOL .= "/etc/init.d/plexserver restart";
    $SPOOL .= "\n";
    spool_file('93_PLEX', $SPOOL);
    empty_spool();
    print to_json(["New dlnaclientprofiles.xml saved successfully. Plex Media Server will be restarted."]);
} elsif ( $action eq "dlnarestore" ) {
    my $SPOOL = "\n\n";
    $SPOOL .= 'rm -f "/c/.plex/Library/Application Support/Plex Media Server/dlnaclientprofiles.xml"';
    $SPOOL .= 'touch "/c/.plex/Library/Application Support/Plex Media Server/dlnaclientprofiles.xml"';
    $SPOOL .= 'chown admin:admin "/c/.plex/Library/Application Support/Plex Media Server/dlnaclientprofiles.xml"';
    $SPOOL .= "\n\n";
    spool_file('94_PLEX', $SPOOL);
    empty_spool();
    print to_json(["Default dlnaclientprofiles.xml has been restored. Plex Media Server will be restarted."]);
}

1;