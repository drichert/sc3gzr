my @stick_tracker = (
	# Stick 0 (direction pad)
	{ u => 0, r => 0, d => 0, l => 0 },
	# Stick 1 (left analog stick)
	{ u => 0, r => 0, d => 0, l => 0 },
	# Stick 2 (right analog stick)
	{ u => 0, r => 0, d => 0, l => 0 }
);

$stick_tracker[0]->{u} = 1;
print $stick_tracker[0]->{u} . "\n";

