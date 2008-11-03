#!/usr/bin/perl

# sc3gzr
# Dan Richert
# 09/15/2008
# 
# Gamepad controlled text filter
# 
# Linux::Joystick :
# http://search.cpan.org/~bwatson/Linux-Joystick-0.0.1/Joystick.pm
#
# WordNet::QueryData :
# http://search.cpan.org/~jrennie/WordNet-QueryData-1.47/QueryData.pm


use strict; use warnings;
use WordNet::QueryData; 
use Linux::Joystick;
use Net::OpenSoundControl::Client;

my $js = Linux::Joystick->new(
	threshold => 32000,
	nonblocking => 1
);

print STDERR 'Loading WordNet::QueryData... ';
my $wn = WordNet::QueryData->new;
print "Ready.\n";

my $osc_client = Net::OpenSoundControl::Client->new(
	Host => '192.168.2.5',
	Port => 57120 # Default sclang port (linux) (talking to OSCResponderNodes)
) or die "Could not start client: $@\n";

#### Pattern data for stick directions ####

my @pattern_data = (
	# Mode 0 (letters)
	{
		0 => {
			u => 'a',
			ur => 'b',
			r => 'c',
			dr => 'd',
			d => 'e',
			dl => 'f',
			l => 'g',
			ul => 'h'
		},
		1 => {
			u => 'i',
			ur => 'j',
			r => 'k',
			dr => 'l',
			d => 'm',
			dl => 'n',
			l => 'o',
			ul => 'p'
		},
		2 => { 
			u => 'r',
			ur => 's',
			r => 't',
			dr => 'u',
			d => 'v',
			dl => 'w',
			l => 'x',
			ul => 'y'
		}
	},

	# Mode 1 (a + letter)
	{
		0 => {
			u => 'ab',
			ur => 'ac',
			r => 'ad',
			dr => 'ae',
			d => 'af',
			dl => 'ag',
			l => 'ah',
			ul => 'ai'
		},
		1 => {
			u => 'aj',
			ur => 'ak',
			r => 'al',
			dr => 'am',
			d => 'an',
			dl => 'ao',
			l => 'ap',
			ul => 'ar'
		},
		2 => {
			u => 'as',
			ur => 'at',
			r => 'au',
			dr => 'av',	
			d => 'aw',
			dl => 'ax',
			l => 'ay',
			ul => 'az'
		}
	},

	# Mode 2 (e + letter)
	{
		0 => {
			u => 'ea',
			ur => 'eb',
			r => 'ec',
			dr => 'ed',
			d => 'ee',
			dl => 'ef',
			l => 'eg',
			ul => 'eh'
		},
		1 => {
			u => 'ei',
			ur => 'ek',
			r => 'el',
			dr => 'em',
			d => 'en',
			dl => 'eo',
			l => 'ep',
			ul => 'er'
		},
		2 => {
			u => 'es',
			ur => 'et',
			r => 'eu',
			dr => 'ev',
			d => 'ew',	
			dl => 'ex',
			l => 'ey',
			ul => 'ez'
		}
	},

	# Mode 3 (i + letter)
	{
		0 => {
			u => 'ia',
			ur => 'ib',
			r => 'ic',
			dr => 'id',
			d => 'ie',
			dl => 'if',
			l => 'ig',
			ul => 'ih'
		},
		1 => {
			u => 'ij',
			ur => 'ik',
			r => 'il',
			dr => 'im',
			d => 'in',
			dl => 'io',
			l => 'ip',
			ul => 'ir'
		},
		2 => {
			u => 'is',
			ur => 'it',
			r => 'iu',
			dr => 'iv',	
			d => 'iw',
			dl => 'ix',
			l => 'iy',
			ul => 'iz'
		}
	},

	# Mode 4 (o + letter)
	{
		0 => {
			u => 'oa',
			ur => 'ob',
			r => 'oc',
			dr => 'od',
			d => 'oe',
			dl => 'of',
			l => 'og',
			ul => 'oh'
		},
		1 => {
			u => 'oi',
			ur => 'oj',
			r => 'ol',
			dr => 'om',
			d => 'on',
			dl => 'oo',
			l => 'op',
			ul => 'or'
		},
		2 => {
			u => 'os',
			ur => 'ot',
			r => 'ou',
			dr => 'ov',
			d => 'ow',
			dl => 'ox',
			l => 'oy',
			ul => 'oz'
		}
	},

	# Mode 5 (u + letter)
	{
                0 => {
                        u => 'ua',
                        ur => 'ub',
                        r => 'uc',
                        dr => 'ud',
                        d => 'ue',
                        dl => 'uf',
                        l => 'ug',
                        ul => 'uh'
                },
                1 => {
                        u => 'ui',
                        ur => 'uj',
                        r => 'uk',
                        dr => 'ul',
                        d => 'um',
                        dl => 'un',
                        l => 'uo',
                        ul => 'up'
                },
                2 => {
                        u => 'ur',
                        ur => 'us',
                        r => 'ut',
                        dr => 'uv',
                        d => 'uw',
                        dl => 'ux',
                        l => 'uy',
                        ul => 'uz'
                }
	}	
);

#### End: Pattern data ####

#### Array of hashes for tracking stick positions ####

my @stick_tracker = (
        # 0: Stick 0 (direction pad)
        { u => 0, r => 0, d => 0, l => 0 },
        # 1: Stick 0 (left analog stick)
        { u => 0, r => 0, d => 0, l => 0 },
        # 2: Stick 1 (right analog stick)
        { u => 0, r => 0, d => 0, l => 0 }
);

#### End: stick tracker ####

#### Mode selector and anchoring ####
# This changes when x,y,z,a,b,c buttons are pressed to choose pattern modes for the sticks

my $mode = 0; # initialize to a-z mode (0)
my $anchor = 'n'; # Three possiblities for $anchor -- 'b' = beginning, 'n' = none, 'e' = end
my $wn_mode = '';

#### End: Mode selector ####


#### SUBROUTINES ####

# Open file $filename, read it to $text, 
# split $text on white space, then 
# reassemble the text into an array of 
# lines @lines where then length of each 
# line is less than or equal to $maxlen
sub file2lines {
	my ($filename, $maxlen) = @_;
	
	open F, $filename;	
	my $text = '';
	while(<F>){ $text .= $_ }
	close F;

	my @text = split /\s+/, $text;
	my @lines = ();
	my $buf = '';
	foreach(@text){
		if( length($buf) + length($_) > $maxlen){
			push @lines, $buf;
			$buf = $_;
		}else{
			$buf .= " $_";
		}
	}
	push @lines, $buf;

	return @lines;
}

sub get_stick_direction {
	# 0 = dpad, 1 = left analog, 2 = right analog
	my $stick_num = shift;
	
	# Check diaganols first
	if($stick_tracker[$stick_num]->{u} && $stick_tracker[$stick_num]->{r}){ return 'ur' }
	elsif($stick_tracker[$stick_num]->{d} && $stick_tracker[$stick_num]->{r}){ return 'dr' }
	elsif($stick_tracker[$stick_num]->{d} && $stick_tracker[$stick_num]->{l}){ return 'dl' }
	elsif($stick_tracker[$stick_num]->{u} && $stick_tracker[$stick_num]->{l}){ return 'ul' }
	elsif($stick_tracker[$stick_num]->{u}){ return 'u' }
	elsif($stick_tracker[$stick_num]->{r}){ return 'r' }
	elsif($stick_tracker[$stick_num]->{d}){ return 'd' }
	elsif($stick_tracker[$stick_num]->{l}){ return 'l' }
}

sub get_rand_word_from_wn_results {
	# Takes a comma separated list of querySense results.
	# The wordnet querySense method normally returns 
	# an array, but I'm too lazy/newbish to deal with referencing,
	# so use join(',',$wn_result) then pass that to this sub.
	
	# split the results on comma
	my @wn_results = split(/,/, shift(@_));
	# pick a random result
	my $word = $wn_results[int(rand($#wn_results + 1))];
	# chop off the pos and sense codes
	$word =~ m/^([^#]+)#/;
	# replace underscores with spaces
	$word =~ s/_/ /;
	return $1; 
}


# OSC Subroutines

sub trigger_chmod_synth {
	# This synth is triggered when pushing buttons to change character modes
	# \chmod synth kills itself when done (doneAction:2 on amplitude envelope)
	my $note = shift;
	$osc_client->send(["/chmod", "i", $note]);
}

sub anmod_right {
	$osc_client->send(["/anmod_right"]);
}

sub anmod_left {
	$osc_client->send(["/anmod_left"]);
}

sub anmod_mute {
	$osc_client->send(["/anmod_mute"]);
}

sub get_stmod_formfreq {
        my $formfreq;
        if(!$wn_mode){ $formfreq = 100 }
        elsif($wn_mode eq 'also'){ $formfreq = 200 }
        elsif($wn_mode eq 'syns'){ $formfreq = 300 }
        elsif($wn_mode eq 'hype'){ $formfreq = 400 }
        elsif($wn_mode eq 'mero'){ $formfreq = 500 }
        elsif($wn_mode eq 'holo'){ $formfreq = 600 }
	else{ return 100 };
        return $formfreq;
}

sub get_stmod_bwfreq {
        my $bwfreq;
        if(!$wn_mode){ $bwfreq = 100 }
        elsif($wn_mode eq 'also'){ $bwfreq = 250 }
        elsif($wn_mode eq 'syns'){ $bwfreq = 400 }
        elsif($wn_mode eq 'hype'){ $bwfreq = 550 }
        elsif($wn_mode eq 'mero'){ $bwfreq = 700 }
        elsif($wn_mode eq 'holo'){ $bwfreq = 850 }
	else{ return 100; }
        return $bwfreq;
}

sub stmod_on {
	my $note = shift;
	$osc_client->send(["/stmod_on", "i", $note, "i", get_stmod_formfreq, "i", get_stmod_bwfreq]);
}

# Convert character chunk to note
sub char_chunk2note {
	my $char_chunk = shift;
	my $char;
	if(length($char_chunk) == 2){
		$char = substr($char_chunk, 1, 1);
	}else{
		$char = $char_chunk;
	}

	my $note_num;
	if($char eq 'a'){ $note_num = 41 } # F
	elsif($char eq 'b'){ $note_num = 42 } # F#
	elsif($char eq 'c'){ $note_num = 44 } # G#
	elsif($char eq 'd'){ $note_num = 46 } # A#
	elsif($char eq 'e'){ $note_num = 48 } # C
	elsif($char eq 'f'){ $note_num = 49 } # C#
	elsif($char eq 'g'){ $note_num = 51 } # D#
        elsif($char eq 'h'){ $note_num = 53 } # F
        elsif($char eq 'i'){ $note_num = 54 } # F#
        elsif($char eq 'j'){ $note_num = 56 } # G#
        elsif($char eq 'k'){ $note_num = 58 } # A#
        elsif($char eq 'l'){ $note_num = 60 } # C
        elsif($char eq 'm'){ $note_num = 61 } # C#
        elsif($char eq 'n'){ $note_num = 63 } # D#
        elsif($char eq 'o'){ $note_num = 65 } # F
        elsif($char eq 'p'){ $note_num = 66 } # F#
        elsif($char eq 'q'){ $note_num = 68 } # G#
        elsif($char eq 'r'){ $note_num = 70 } # A#
        elsif($char eq 's'){ $note_num = 72 } # C
        elsif($char eq 't'){ $note_num = 73 } # C#
        elsif($char eq 'u'){ $note_num = 75 } # D#
        elsif($char eq 'v'){ $note_num = 77 } # F
        elsif($char eq 'w'){ $note_num = 78 } # F#
        elsif($char eq 'x'){ $note_num = 80 } # G#
        elsif($char eq 'y'){ $note_num = 82 } # A#
        elsif($char eq 'z'){ $note_num = 84 } # C

	return $note_num;
}
 	
#### END: SUBROUTINES ####


################################################################
################################
################
########
####
##
#

#my ($filename, $maxlen) = @ARGV;
#my @lines = file2lines($filename, $maxlen);
#foreach(@lines){
#        print "$_\n";
#}

# Non-blocking loop
my @lines = file2lines('text/On_the_Study_of_Words-Richard_C_Trench.txt', 80);
my $line_ndx = 0;
my $char_chunk = '';
while(1){
#while(my $e = $js->nextEvent){
	my $e = $js->nextEvent;
	if($e){
		# Set $mode based on button press 
		# Butons: A = 0, B = 1, C = 2, X = 3, Y = 4, Z = 5
		# 6 and 7 are the L and R buttons  
		if($e->isButton){
			
			# handle mode switching
			if($e->buttonDown && $e->button != 6 && $e->button != 7){
				$mode = $e->button;
				#print "Mode: $mode\n";

				# Trigger \chmod SC synth with notes based on mode number
				if($mode == 0){ trigger_chmod_synth(54) }
				elsif($mode == 1){ trigger_chmod_synth(56) }
				elsif($mode == 2){ trigger_chmod_synth(60) }
				elsif($mode == 3){ trigger_chmod_synth(63) }
				elsif($mode == 4){ trigger_chmod_synth(66) }
				elsif($mode == 5){ trigger_chmod_synth(70) } 
			}
	
			# handle anchoring
			if($e->buttonDown && ($e->button == 6 || $e->button == 7)){
				if($e->buttonDown(6)){ # anchor pattern to beginning
					$anchor = 'b';
					anmod_left;
					#print "Anchoring to beginning\n";
				}
				if($e->buttonDown(7)){ # anchor pattern to end
					$anchor = 'e';
					anmod_right;
					#print "Anchoring to end\n";
				}
			}
			if($e->buttonUp && ($e->button == 6 || $e->button == 7)){
				if($e->buttonUp(6) || $e->buttonUp(7)){
					# Turn off anchoring if L or R was released
					$anchor = 'n';
					anmod_mute;
					#print "Anchoring off\n";
				}
			}

		}
		
		# Stick handling
		if($e->isAxis){
			#print $e->stick . ' : ' . $e->axis . ' : ' . $e->axisValue . "\n";
			
			# DPAD
			if($e->axis == 6 || $e->axis == 5){
				if($e->axis == 6){ # dpad vertical
					if($e->axisValue < 0){
						#print "DPAD UP\n";
						$stick_tracker[0]->{u} = 1;
						$stick_tracker[0]->{d} = 0;
					}elsif($e->axisValue > 0){
						#print "DPAD DOWN\n";
						$stick_tracker[0]->{d} = 1;
						$stick_tracker[0]->{u} = 0;
					}else{
						$stick_tracker[0]->{u} = 0;
						$stick_tracker[0]->{d} = 0;
					}
				}

				if($e->axis == 5){ # dpad horizontal
					if($e->axisValue < 0){
						#print "DPAD LEFT\n";
						$stick_tracker[0]->{l} = 1;
						$stick_tracker[0]->{r} = 0;
					}elsif($e->axisValue > 0){
						#print "DPAD RIGHT\n";
						$stick_tracker[0]->{l} = 0;
						$stick_tracker[0]->{r} = 1;
					}else{
						$stick_tracker[0]->{l} = 0;
						$stick_tracker[0]->{r} = 0;
					}
				}

               			my $stick0_direction = get_stick_direction(0);
                		if($stick0_direction){
                        		$char_chunk = $pattern_data[$mode]->{0}->{$stick0_direction};
                			stmod_on(char_chunk2note($char_chunk));
				}
			}

			# ANALOG STICK 0 (LEFT)
			if($e->axis == 1 || $e->axis == 0){
				if($e->axis == 1){ # analog stick 0 (left stick) vertical
					if($e->axisValue == -32767){
						#print "STICK0 UP\n";
 						$stick_tracker[1]->{u} = 1;
                                               	$stick_tracker[1]->{d} = 0;
					}elsif($e->axisValue == 32767){
						#print "STICK0 DOWN\n";
 						$stick_tracker[1]->{u} = 0;
                                                $stick_tracker[1]->{d} = 1;
					}else{
						$stick_tracker[1]->{u} = 0;
						$stick_tracker[1]->{d} = 0;
					}
				}
				if($e->axis == 0){ # analog stick 0 (left stick) horizontal
					if($e->axisValue == -32767){
						#print "STICK0 LEFT\n";
						$stick_tracker[1]->{l} = 1;
                                                $stick_tracker[1]->{r} = 0;
					}elsif($e->axisValue == 32767){
						#print "STICK0 RIGHT\n";
						$stick_tracker[1]->{l} = 0;
                                                $stick_tracker[1]->{r} = 1;
					}else{
						$stick_tracker[1]->{l} = 0;
                                                $stick_tracker[1]->{r} = 0;
					}
				}

				my $stick1_direction = get_stick_direction(1);
				if($stick1_direction){
					$char_chunk = $pattern_data[$mode]->{1}->{$stick1_direction};
                                        stmod_on(char_chunk2note($char_chunk));
				}
			}

		
			# ANALOG STICK 1 (RIGHT)
			if($e->axis == 4 || $e->axis == 3){
				if($e->axis == 4){ # analog stick 1 (right stick) vertical
					if($e->axisValue == -32767){
						#print "STICK1 UP\n";
						$stick_tracker[2]->{u} = 1;	
						$stick_tracker[2]->{d} = 0;
					}elsif($e->axisValue == 32767){
						#print "STICK1 DOWN\n";
						$stick_tracker[2]->{u} = 0;
						$stick_tracker[2]->{d} = 1;
					}else{
						$stick_tracker[2]->{u} = 0;
						$stick_tracker[2]->{d} = 0;
					}
				}
			
				if($e->axis == 3){ # analog stick 1 (right stick) horizontal
					if($e->axisValue == 32767){
						#print "STICK1 RIGHT\n";
						$stick_tracker[2]->{r} = 1;
						$stick_tracker[2]->{l} = 0;
					}elsif($e->axisValue == -32767){
						#print "STICK1 LEFT\n";
						$stick_tracker[2]->{r} = 0;	
						$stick_tracker[2]->{l} = 1;
					}else{
						$stick_tracker[2]->{r} = 0;
						$stick_tracker[2]->{l} = 0;
					}
				}

				my $stick2_direction = get_stick_direction(2);
				if($stick2_direction){
					$char_chunk = $pattern_data[$mode]->{2}->{$stick2_direction};
                                        stmod_on(char_chunk2note($char_chunk));
				}
			}


			# Use the slider to set wordnet transform mode
			if($e->axis == 2){ # slider
				# print "SLIDER VAL " . $e->axisValue . "\n";
				if($e->axisValue >= 23405 ){ $wn_mode = ''; }
				elsif($e->axisValue >= 14044 ){ $wn_mode = 'also'; }
				elsif($e->axisValue >= 4682 ){ $wn_mode = 'syns'; }
				elsif($e->axisValue >= -4680 ){ $wn_mode = 'hype'; }
				elsif($e->axisValue >= -14042 ){ $wn_mode = 'hypo'; }
				elsif($e->axisValue >= -23404 ){ $wn_mode = 'mero'; }
				else{ $wn_mode = 'holo' }	
			}

			#print $e->axisValue . "\n";
			#print $e->axis . "\n";
		}

		

		#my $stick1_direction = get_stick_direction(1);
		#if($stick1_direction){
		#	$char_chunk = $pattern_data[$mode]->{1}->{$stick1_direction}
		#}
		
		#my $stick2_direction = get_stick_direction(2);
		#if($stick2_direction){
		#	$char_chunk = $pattern_data[$mode]->{2}->{$stick2_direction}
		#}

		my $pattern = '';
		if($anchor eq 'b'){
			$pattern = "^$char_chunk";
		}elsif($anchor eq 'e'){
			$pattern = "$char_chunk".'$';
		}else{
			$pattern = $char_chunk;
		}
		
		my @line = split /\s+/, $lines[$line_ndx];
		
		foreach(@line){
			if($pattern){  # this conditional wrapper is a bug work-around -- sometimes $pattern doesn't get assigned
				if($_ =~ /$pattern/){ 
					if(!$wn_mode){
						print "$_ ";
					}else{
						my @wn_results = $wn->querySense("$_", "$wn_mode");
						#my @wn_results = $wn->querySense("run", "syns");
						if(@wn_results){
							my $wn_results = join(',',@wn_results);
							print get_rand_word_from_wn_results($wn_results);
						}else{
							print "$_ ";
						}
					} 
				}else{ 
					print ' ' x (length $_)
				}
			}else{
				print ' ' x (length $_)
			}
		}
		print "\n";
	
		# Set the line index back to 0 if it's at the end, increment if not
		if($line_ndx == $#lines){
			$line_ndx = 0;
		}else{
			$line_ndx++;
		}
					
	} # end: event detector

	#sleep(1);	
}	
