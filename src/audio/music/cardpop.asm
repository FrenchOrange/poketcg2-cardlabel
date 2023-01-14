Music_CardPop_Ch2:
	speed 4
	stereo_panning TRUE, TRUE
	cutoff 8
	duty 2
	volume_envelope 9, 0
	MainLoop
	Loop 7
	rest 16
	EndLoop
	rest 14
	Loop 2
	octave 5
	cutoff 8
	F# 1
	G_ 1
	cutoff 6
	F# 1
	volume_envelope 3, 7
	F# 1
	volume_envelope 9, 0
	D_ 1
	volume_envelope 3, 7
	F# 1
	dec_octave
	volume_envelope 9, 0
	A_ 1
	inc_octave
	volume_envelope 3, 7
	D_ 1
	dec_octave
	volume_envelope 9, 0
	G_ 1
	volume_envelope 3, 7
	A_ 1
	volume_envelope 9, 0
	F# 1
	volume_envelope 3, 7
	G_ 1
	volume_envelope 9, 0
	D_ 1
	volume_envelope 3, 7
	G_ 1
	dec_octave
	volume_envelope 9, 0
	A_ 1
	volume_envelope 3, 7
	inc_octave
	D_ 1
	dec_octave
	volume_envelope 9, 0
	G_ 1
	volume_envelope 3, 7
	A_ 1
	volume_envelope 9, 0
	F# 1
	volume_envelope 3, 7
	G_ 1
	rest 1
	F# 1
	rest 12
	rest 16
	rest 14
	octave 5
	volume_envelope 9, 0
	cutoff 8
	E_ 1
	F_ 1
	cutoff 6
	E_ 1
	volume_envelope 3, 7
	E_ 1
	volume_envelope 9, 0
	C_ 1
	volume_envelope 3, 7
	E_ 1
	dec_octave
	volume_envelope 9, 0
	G_ 1
	inc_octave
	volume_envelope 3, 7
	C_ 1
	dec_octave
	volume_envelope 9, 0
	F_ 1
	volume_envelope 3, 7
	G_ 1
	volume_envelope 9, 0
	E_ 1
	volume_envelope 3, 7
	F_ 1
	volume_envelope 9, 0
	C_ 1
	volume_envelope 3, 7
	E_ 1
	dec_octave
	volume_envelope 9, 0
	G_ 1
	volume_envelope 3, 7
	inc_octave
	C_ 1
	dec_octave
	volume_envelope 9, 0
	F_ 1
	volume_envelope 3, 7
	G_ 1
	volume_envelope 9, 0
	E_ 1
	volume_envelope 3, 7
	F_ 1
	rest 1
	E_ 1
	rest 12
	rest 16
	volume_envelope 9, 0
	rest 14
	EndLoop
	rest 2
	EndMainLoop


Music_CardPop_Ch1:
	speed 4
	stereo_panning TRUE, TRUE
	cutoff 8
	duty 2
	volume_envelope 6, 0
	cutoff 3
	Loop 2
	octave 2
	A_ 2
	inc_octave
	A_ 2
	inc_octave
	A_ 2
	dec_octave
	A_ 2
	inc_octave
	inc_octave
	A_ 2
	dec_octave
	A_ 2
	dec_octave
	A_ 2
	inc_octave
	inc_octave
	A_ 2
	dec_octave
	dec_octave
	A_ 2
	dec_octave
	A_ 2
	inc_octave
	A_ 2
	inc_octave
	A_ 2
	inc_octave
	A_ 2
	dec_octave
	A_ 2
	dec_octave
	A_ 2
	inc_octave
	inc_octave
	A_ 2
	EndLoop
	Loop 2
	octave 2
	G_ 2
	inc_octave
	G_ 2
	inc_octave
	G_ 2
	dec_octave
	G_ 2
	inc_octave
	inc_octave
	G_ 2
	dec_octave
	G_ 2
	dec_octave
	G_ 2
	inc_octave
	inc_octave
	G_ 2
	dec_octave
	dec_octave
	G_ 2
	dec_octave
	G_ 2
	inc_octave
	G_ 2
	inc_octave
	G_ 2
	inc_octave
	G_ 2
	dec_octave
	G_ 2
	dec_octave
	G_ 2
	inc_octave
	inc_octave
	G_ 2
	EndLoop
	EndMainLoop


Music_CardPop_Ch3:
	speed 4
	wave 1
	stereo_panning TRUE, TRUE
	volume_envelope 2, 0
	echo 0
	cutoff 8
	music_call Branch_1e36f0
	C_ 2
	C# 2
	music_call Branch_1e36f0
	D_ 2
	C# 2
	music_call Branch_1e3701
	D_ 2
	C# 2
	music_call Branch_1e3701
	C_ 2
	C# 2
	EndMainLoop

Branch_1e36f0:
	octave 1
	D_ 2
	rest 2
	D_ 4
	inc_octave
	D_ 2
	dec_octave
	D_ 2
	rest 2
	F# 2
	rest 2
	G_ 2
	rest 2
	G# 2
	rest 2
	A_ 2
	music_ret

Branch_1e3701:
	octave 1
	C_ 2
	rest 2
	C_ 4
	inc_octave
	C_ 2
	dec_octave
	C_ 2
	rest 2
	E_ 2
	rest 2
	F_ 2
	rest 2
	F# 2
	rest 2
	G_ 2
	music_ret


Music_CardPop_Ch4:
	speed 4
	octave 1
	Loop 11
	music_call Branch_1e372b
	snare4 4
	snare1 2
	snare3 2
	snare4 2
	snare1 2
	EndLoop
	music_call Branch_1e372b
	snare4 2
	snare2 1
	snare2 1
	Loop 4
	snare1 2
	EndLoop
	EndMainLoop

Branch_1e372b:
	bass 2
	snare3 2
	snare4 4
	snare1 2
	snare3 2
	snare4 2
	snare1 2
	bass 2
	snare1 2
	music_ret
