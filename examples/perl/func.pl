
use strict;
use warnings;
use LWP::UserAgent;
use HTTP::Request::Common;
use JSON;
use MIME::Base64 ('encode_base64');
use Digest::SHA ('hmac_sha256_base64');
use Data::Dumper;


our $GLOBAL_NONCE_I = time * 1000;


sub	_prepare_request_public {
	my ($url) = @_;
	print "GET $url\n";
	return HTTP::Request::Common::GET($::API_HOST_PORT . $url);
};

sub	_prepare_request_private {
	my ($url, $post_obj) = @_;
	
	my $post_data = '';
	
	if ($post_obj) {
		$post_data = encode_json($post_obj);
	};
	
	
	my $nonce = time * 100;
	$nonce += ++$GLOBAL_NONCE_I;
	
	
	
	my $payload_str = 'POST' . $url . $post_data . $nonce;
	my $pay_load_b64 = encode_base64($payload_str, '');		# no \n line ending.
	
	my $signature = hmac_sha256_base64($pay_load_b64, $::API_SECRET);
	$signature .= '=' while (length($signature) % 4);	#pad to valid len
	
	my %req_data = (
		'Content' => $post_data,
		'X-APIKEY' => $::API_KEY,
		'X-PAYLOAD' => $pay_load_b64,
		'X-SIGNATURE' => $signature,
		'X-NONCE' => $nonce,
	);
	
	print "POST $url\n";
	return HTTP::Request::Common::POST($::API_HOST_PORT . $url, %req_data);
};

1;