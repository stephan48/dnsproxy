 #!/usr/bin/perl 
 
use Net::DNS::Nameserver;
use strict;
use warnings;
 
use Net::DNS;
use Data::Dumper;
use Getopt::Long qw(GetOptions);

my $nameserver = ('178.63.26.172');
my $port       = 5353;
my $debug      = 0;

GetOptions( 'debug'              => \$debug,
		    'nameserver|ns|n=s@' => \$nameserver,
		  );

my $res = Net::DNS::Resolver->new(debug => $debug);
$res->port($port);
$res->nameservers($nameserver);
 
sub reply_handler {
    my ($qname, $qclass, $qtype, $peerhost,$query,$conn) = @_;
	my ($rcode, @ans, @auth, @add);

	print "----------------------------------------------------\n";
    print "Received query from $peerhost to ". $conn->{"sockhost"}. "\n";
	print "Query:\n";
    $query->print;
	print "---------------------------------\n";
	print "Resolver Answer:\n";
	my $answer = $res->send($query);
	$answer->print;
		
	push @ans, $answer->answer;
	push @auth, $answer->authority;
	push @add, $answer->additional;
	$rcode = $answer->header->rcode;		
	print "----------------------------------------------------\n";
		
    #print Dumper $answer;
    return ($rcode, \@ans, \@auth, \@add, { aa => $answer->header->aa, ra => $answer->header->ra, ad => $answer->header->ad,});
}
 
my $ns = Net::DNS::Nameserver->new(
    LocalPort    => 53,
    ReplyHandler => \&reply_handler,
    Verbose      => $debug,
	debug        => $debug,
) || die "couldn't create nameserver object\n";

$ns->main_loop;