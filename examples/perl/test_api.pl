
use strict;
use warnings;
use Data::Dumper;

$::path = '.';
require "$::path/config.pl";
require "$::path/func.pl";


############ EDIT CONFIG BEFORE RUNNING THIS ###########


&main();

sub main {
	
	my $actions = {
		'1' => '/v1/public/markets',
		'2' => '/v1/public/market/BTCUSD',
		'3' => '/v1/public/tickers',
		'4' => '/v1/public/ticker/BTCUSD',
		'5' => '/v1/public/orders/BTCUSD?limit=2',
		'6' => '/v1/public/orders_history/BTCUSD?limit=2',
		
		'7' => '/v1/private/balances',
		'8' => '/v1/private/balance/USD',
		'9' => '/v1/private/list_open_orders',
		'10' => '/v1/private/list_open_orders/BTCUSD/',
		'11' => '/v1/private/list_closed_orders/BTCUSD/',
		'12' => '/v1/private/list_margin_positions/BTCUSD/',
		
		
		'101' => 'make EXCHANGE orders',
		'102' => 'make MARGIN orders',
		'103' => 'cancel all my orders',
		'104' => 'close all margin positions (BTCUSD)',
	};
	
	while (1) {
		print "Select action:\n";
		
		foreach my $i (sort {$a <=> $b} keys %{$actions}) {
			print "$i : $actions->{$i}\n";
		};
		
		my $selection = <>;
		chomp($selection);
		
		if (! defined $actions->{$selection}) {
			print "Invalid selection\n";
			next;
		};
		
		if ($selection < 100) {
			&make_request($actions->{$selection});
		} else {
			
			&generate_exchange_orders() if $selection eq '101';
			&generate_margin_orders() if $selection eq '102';
			&cancel_my_orders() if $selection eq '103';
			&close_all_ma() if $selection eq '104';
			
			
		};
		
	};
};


sub	make_request {
	my ($url, $dump_output) = @_;
	
	$dump_output //= 1;
	
	my $ua = LWP::UserAgent->new;
	my $request;
	
	if ($url =~ /public/o) {
		$request = &_prepare_request_public($url);
	} else {
		$request = &_prepare_request_private($url);
	};	
	
	my $response = $ua->request($request);
		
	if ($response->is_success) {
		my $obj = decode_json($response->decoded_content);
		
		if ($obj->{'RESULT'}) {
			if ($dump_output) {
				print "OK: " . Dumper($obj->{'DATA'}) . "\n";
			};
			
			return $obj->{'DATA'};
		} else {
			print "FAIL: " . $obj->{'MESSAGE'} . "\n";
			return;
		};
		
	} else {
		print "FAIL: " . $response->status_line;
		return;
	};
};


sub	generate_exchange_orders {
	my $curr_ticker_data = &make_request('/v1/public/ticker/BTCUSD', 0);
	print "Curr BTCUSD price " . $curr_ticker_data->{'LAST'} . "\n";
	
	unless ($curr_ticker_data->{'LAST'}) {
		print "Can not continue w/o valid price ...";
		return;
	};
	
	
	my $price = $curr_ticker_data->{'LAST'} - ($curr_ticker_data->{'LAST'}*0.05);
	my $qty = 0.1;
	
	
	############################### LIMIT ###############################
	
	print "Making limit: BUY $qty \@ $price ... ";
	&make_order({
		'MARKET' => 'BTCUSD',
		'TYPE' => 'BUY',
		'ORDER_TYPE' => 'limit',
		'PRICE' => $price,
		'QTY' => $qty,
	});
	
	$price = $curr_ticker_data->{'LAST'} + ($curr_ticker_data->{'LAST'}*0.05);
	print "Making limit: SELL $qty \@ $price ... ";
	&make_order({
		'MARKET' => 'BTCUSD',
		'TYPE' => 'SELL',
		'ORDER_TYPE' => 'limit',
		'PRICE' => $price,
		'QTY' => $qty,
	});
	
	############################### MARKET ###############################
	
	print "Making market: BUY $qty ... ";
	&make_order({
		'MARKET' => 'BTCUSD',
		'TYPE' => 'BUY',
		'PRICE' => 0,
		'ORDER_TYPE' => 'market',
		'QTY' => $qty,
	});
	
	
	print "Making market: SELL $qty ...";
	&make_order({
		'MARKET' => 'BTCUSD',
		'TYPE' => 'SELL',
		'PRICE' => 0,
		'ORDER_TYPE' => 'market',
		'QTY' => $qty,
	});
	
	
	############################### STOP ###############################
	
	$price = $curr_ticker_data->{'LAST'} + ($curr_ticker_data->{'LAST'}*0.05);
	print "Making stop market: BUY $qty \@ $price ...";
	&make_order({
		'MARKET' => 'BTCUSD',
		'TYPE' => 'BUY',
		'ORDER_TYPE' => 'stop',
		'STOP_TYPE' => 'market',
		'PRICE' => $price,
		'QTY' => $qty,
	});
	
	$price = $curr_ticker_data->{'LAST'} + ($curr_ticker_data->{'LAST'}*0.05);
	print "Making stop limit: BUY $qty \@ $price ...";
	&make_order({
		'MARKET' => 'BTCUSD',
		'TYPE' => 'BUY',
		'ORDER_TYPE' => 'stop',
		'STOP_TYPE' => 'limit',
		'STOP_LIMIT_PRICE' => $price,
		'PRICE' => $price,
		'QTY' => $qty,
	});
	
	$price = $curr_ticker_data->{'LAST'} + ($curr_ticker_data->{'LAST'}*0.05);
	print "Making stop trailing: BUY $qty \@ $price ...";
	&make_order({
		'MARKET' => 'BTCUSD',
		'TYPE' => 'BUY',
		'ORDER_TYPE' => 'stop',
		'STOP_TYPE' => 'trailing',
		'STOP_TRAILING_DISTANCE' => ($curr_ticker_data->{'LAST'}*0.01),
		'PRICE' => $price,
		'QTY' => $qty,
	});
	
	
	
	
	
	$price = $curr_ticker_data->{'LAST'} - ($curr_ticker_data->{'LAST'}*0.05);
	print "Making stop market: SELL $qty \@ $price ...";
	&make_order({
		'MARKET' => 'BTCUSD',
		'TYPE' => 'SELL',
		'ORDER_TYPE' => 'stop',
		'STOP_TYPE' => 'market',
		'PRICE' => $price,
		'QTY' => $qty,
	});
	
	
	$price = $curr_ticker_data->{'LAST'} - ($curr_ticker_data->{'LAST'}*0.05);
	print "Making stop market: BUY $qty \@ $price POST_ONLY. should be executed. (price lower than curr)... ";
	&make_order({
		'MARKET' => 'BTCUSD',
		'TYPE' => 'BUY',
		'ORDER_TYPE' => 'stop',
		'STOP_TYPE' => 'market',
		'PRICE' => $price,
		'QTY' => $qty,
	});
	
	
	$price = $curr_ticker_data->{'LAST'} - ($curr_ticker_data->{'LAST'}*0.05);
	print "Making stop limit: BUY $qty \@ $price ...";
	&make_order({
		'MARKET' => 'BTCUSD',
		'TYPE' => 'SELL',
		'ORDER_TYPE' => 'stop',
		'STOP_TYPE' => 'limit',
		'STOP_LIMIT_PRICE' => $price,
		'PRICE' => $price,
		'QTY' => $qty,
	});
	
	$price = $curr_ticker_data->{'LAST'} - ($curr_ticker_data->{'LAST'}*0.05);
	print "Making stop trailing: BUY $qty \@ $price ...";
	&make_order({
		'MARKET' => 'BTCUSD',
		'TYPE' => 'SELL',
		'ORDER_TYPE' => 'stop',
		'STOP_TYPE' => 'trailing',
		'STOP_TRAILING_DISTANCE' => ($curr_ticker_data->{'LAST'}*0.01),
		'PRICE' => $price,
		'QTY' => $qty,
	});
	
	
	
	
	
	
	############################### CONDITIONAL ###############################
	
	$price = $curr_ticker_data->{'LAST'} + ($curr_ticker_data->{'LAST'}*0.05);
	print "Making CONDITIONAL market (buy higher): BUY $qty \@ $price ... ";
	&make_order({
		'MARKET' => 'BTCUSD',
		'TYPE' => 'BUY',
		'ORDER_TYPE' => 'conditional',
		'CONDITIONAL_TYPE' => 'market',
		'PRICE' => $price,
		'QTY' => $qty,
	});
	
	$price = $curr_ticker_data->{'LAST'} - ($curr_ticker_data->{'LAST'}*0.05);
	print "Making CONDITIONAL market (buy lower): BUY $qty \@ $price ... ";
	&make_order({
		'MARKET' => 'BTCUSD',
		'TYPE' => 'BUY',
		'ORDER_TYPE' => 'conditional',
		'CONDITIONAL_TYPE' => 'market',
		'PRICE' => $price,
		'QTY' => $qty,
	});
};




sub	generate_margin_orders {
	my $curr_ticker_data = &make_request('/v1/public/ticker/BTCUSD', 0);
	print "Curr BTCUSD price " . $curr_ticker_data->{'LAST'} . "\n";
	
	unless ($curr_ticker_data->{'LAST'}) {
		print "Can not continue w/o valid price ...";
		return;
	};
	
	
	my $price = $curr_ticker_data->{'LAST'};
	my $qty = 0.1;
	
	
	############################### LIMIT ###############################
	
	$price = $curr_ticker_data->{'LAST'} - ($curr_ticker_data->{'LAST'}*0.05);
	print "Making limit (margin): BUY $qty \@ $price ... ";
	&make_order({
		'MARKET' => 'BTCUSD',
		'TYPE' => 'BUY',
		'ORDER_TYPE' => 'limit',
		'PRICE' => $price,
		'QTY' => $qty,
		
		'EXCHANGE_TYPE' => 'margin',
		'MARGIN_LEVERAGE' => 3,
		'MARGIN_GROUP' => 0,
		
		'HIDDEN' => 1,
		'REDUCE_ONLY' => 1,
		'NOTE' => 'test order x',
	});
	
	############################### MARKET ###############################
	
	$price = $curr_ticker_data->{'LAST'} - ($curr_ticker_data->{'LAST'}*0.05);
	print "Making MARGIN (margin): (this will make NEW margin position in most cases) BUY $qty \@ $price ... ";
	&make_order({
		'MARKET' => 'BTCUSD',
		'TYPE' => 'BUY',
		'ORDER_TYPE' => 'market',
		'PRICE' => $price,
		'QTY' => $qty,
		
		'EXCHANGE_TYPE' => 'margin',
		'MARGIN_LEVERAGE' => 3,
		'MARGIN_GROUP' => 0,
		
		'NOTE' => 'test order x',
	});
};



sub	cancel_my_orders {
	my $ua = LWP::UserAgent->new;
	
	my $request = &_prepare_request_private('/v1/private/list_open_orders', {});
	my $response = $ua->request($request);
	my $obj;
	
	if ($response->is_success) {
		$obj = decode_json($response->decoded_content);
		
		if (! $obj->{'RESULT'}) {
			die "fail: " . $obj->{'MESSAGE'} . "\n";
		};
		
	} else {
		die $response->status_line;
	};
	
		
	#print Dumper($obj->{'DATA'});
	
	foreach my $order (@{$obj->{'DATA'}}) {
		print "Cancelling order $order->{'ID'} : ";
		
		my $request = &_prepare_request_private('/v1/private/cancel_order', {
			'MARKET' => $order->{'MARKET'},
			'ID' => $order->{'ID'},
		});
		
		my $response = $ua->request($request);
		
		
		if ($response->is_success) {
			print $response->decoded_content . "\n";
			my $obj2 = decode_json($response->decoded_content);
			
			if ($obj2->{'RESULT'}) {
				print "ok\n";
			} else {
				print "fail: " . $obj2->{'MESSAGE'} . "\n";
			};
			
		} else {
			print "fail (http): " . $response->status_line . "\n";
		};
		
	};
};




sub	close_all_ma {
	my $ua = LWP::UserAgent->new;
	
	my $request = &_prepare_request_private('/v1/private/list_margin_positions/', {'MARKET' => 'BTCUSD'});
	my $response = $ua->request($request);
	my $obj;
	
	if ($response->is_success) {
		$obj = decode_json($response->decoded_content);
		
		if (! $obj->{'RESULT'}) {
			die "fail: " . $obj->{'MESSAGE'} . "\n";
		};
		
	} else {
		die $response->status_line;
	};
	
		
	#print Dumper($obj->{'DATA'});
	
	foreach my $ma (@{$obj->{'DATA'}}) {
		print "Closing MA $ma->{'ID'} : ";
		
		my $request = &_prepare_request_private('/v1/private/close_margin_position', {
			'MARKET' => $ma->{'MARKET'},
			'ID' => $ma->{'ID'},
		});
		
		my $response = $ua->request($request);
		
		if ($response->is_success) {
			print $response->decoded_content . "\n";
			my $obj2 = decode_json($response->decoded_content);
			
			if ($obj2->{'RESULT'}) {
				print "ok\n";
			} else {
				print "fail: " . $obj2->{'MESSAGE'} . "\n";
			};
			
		} else {
			print "fail (http): " . $response->status_line . "\n";
		};
		
	};
};


sub make_order {
	my ($config) = @_;
	
	print "(y/n)?";
	my $answ = <>;
	chomp($answ);
	return unless $answ eq 'y';
	
	my $ua = LWP::UserAgent->new;
	my $request = &_prepare_request_private('/v1/private/new_order', $config);
	my $response = $ua->request($request);
	
	if ($response->is_success) {
		my $obj = decode_json($response->decoded_content);
		
		if ($obj->{'RESULT'}) {
			print "OK: " . $obj->{'DATA'}->{'ID'} . "\n";
		} else {
			print "FAIL: " . $obj->{'MESSAGE'} . "\n";
		};
	} else {
		print "FAIL: " . $response->status_line;
	};
	
};

1;