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
			ul => 'er',
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
			ul => 'ih',
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

# $patter_data[mode]->{stick}->{direction}
print $pattern_data[5]->{2}->{dr} . "\n";
