; rst vectors
SECTION "rst00", ROM0
	ret
	ds 7
SECTION "rst08", ROM0
	ret
	ds 7
SECTION "rst10", ROM0
	ret
	ds 7
SECTION "rst18", ROM0
	jp Bank1Call
	ds 5
SECTION "rst20", ROM0
	jp $3c3c ; RST20
	ds 5
SECTION "rst28", ROM0
	jp FarCall
	ds 5
SECTION "rst30", ROM0
	jp GetTurnDuelistVariable
	ds 5
SECTION "rst38", ROM0
	jp $0f16 ; RST38
	ds 5

; interrupts
SECTION "vblank", ROM0
	jp VBlankHandler
	ds 5
SECTION "lcdc", ROM0
	call wLCDCFunctionTrampoline
	reti
	ds 4
SECTION "timer", ROM0
	jp TimerHandler
	ds 5
SECTION "serial", ROM0
	jp $0c47 ; SerialHandler
	ds 5
SECTION "joypad", ROM0
	reti
	ds $9f

SECTION "romheader", ROM0
	nop
	jp Start

	ds $4c

SECTION "start", ROM0
Start: ; 0150 (0:0150)
	di
	ld sp, $fffe
	push af
	xor a
	ldh [rIF], a
	ldh [rIE], a
	call $03e6 ; ZeroRAM
	ld a, $1
	call BankswitchROM
	xor a
	call BankswitchSRAM
	call BankswitchVRAM0
	call $028e ; DisableLCD
	pop af
	ld [wInitialA], a
	call $0342 ; DetectConsole
	ld a, $20
	ld [wTileMapFill], a
	call $0399 ; SetupVRAM
	call $0305 ; SetupRegisters
	call $0363 ; SetupPalettes
	call $305c ; SetupSound
	call SetupTimer
	call $0dc7 ; ResetSerial
	call $0566 ; CopyDMAFunction
	call ValidateSRAM
	ld a, BANK(GameLoop)
	call BankswitchROM
	ld sp, $d000
	jp GameLoop

; vblank interrupt handler
VBlankHandler: ; 019b (0:019b)
	push af
	push bc
	push de
	push hl
	ldh a, [hBankROM]
	push af
	ldh a, [rSVBK]
	push af
	ld a, $1
	ldh [rSVBK], a
	ld hl, wReentrancyFlag
	bit IN_VBLANK, [hl]
	jr nz, .done
	set IN_VBLANK, [hl]
	ld a, [wVBlankOAMCopyToggle]
	or a
	jr z, .no_oam_copy
	call hDMAFunction ; DMA-copy $ca00-$ca9f to OAM memory
	xor a
	ld [wVBlankOAMCopyToggle], a
.no_oam_copy
	; flush scaling/windowing parameters
	ldh a, [hSCX]
	ldh [rSCX], a
	ldh a, [hSCY]
	ldh [rSCY], a
	ldh a, [hWX]
	ldh [rWX], a
	ldh a, [hWY]
	ldh [rWY], a
	; flush LCDC
	ldh a, [hLCDC]
	ldh [rLCDC], a
	ei
	call wVBlankFunctionTrampoline
	call $0425 ; FlushPalettesIfRequested
	ld hl, wVBlankCounter
	inc [hl]
	ld hl, wReentrancyFlag
	res IN_VBLANK, [hl]
.done
	pop af
	ldh [rSVBK], a
	pop af
	call BankswitchROM
	pop hl
	pop de
	pop bc
	pop af
	reti

; timer interrupt handler
TimerHandler: ; 01ef (0:01ef)
	push af
	push hl
	push de
	push bc
	ei
	call $0bb2 ; SerialTimerHandler
	ldh a, [rSVBK]
	push af
	ld a, $1
	ldh [rSVBK], a
	; only trigger every fourth interrupt ≈ 60.24 Hz
	ld hl, wTimerCounter
	ld a, [hl]
	inc [hl]
	and $3
	jr nz, .done
	; increment the 60-60-60-255-255 counter
	call IncrementPlayTimeCounter
	; check in-timer flag
	ld hl, wReentrancyFlag
	bit IN_TIMER, [hl]
	jr nz, .done
	set IN_TIMER, [hl]
	ldh a, [hBankROM]
	push af
	ld a, $77 ; BANK(SoundTimerHandler)
	call BankswitchROM
	call $4003 ; SoundTimerHandler
	pop af
	call BankswitchROM
	; clear in-timer flag
	ld hl, wReentrancyFlag
	res IN_TIMER, [hl]
.done
	pop af
	ldh [rSVBK], a
	pop bc
	pop de
	pop hl
	pop af
	reti

; increment play time counter by a tick
IncrementPlayTimeCounter: ; 022f (0:022f)
	ld a, [wPlayTimeCounterEnable]
	or a
	ret z
	ld hl, wPlayTimeCounter
	inc [hl]
	ld a, [hl]
	cp 60
	ret c
	ld [hl], $0
	inc hl
	inc [hl]
	ld a, [hl]
	cp 60
	ret c
	ld [hl], $0
	inc hl
	inc [hl]
	ld a, [hl]
	cp 60
	ret c
	ld [hl], $0
	inc hl
	inc [hl]
	ret nz
	inc hl
	inc [hl]
	ret

; setup timer to 16384/68 ≈ 240.94 Hz
SetupTimer: ; 0254 (0:0254)
	push bc
	ld b, -68 ; Value for Normal Speed
	ldh a, [rKEY1]
	and $80
	jr z, .set_timer
	ld b, $100 - 2 * 68 ; Value for CGB Double Speed
.set_timer
	ld a, b
	ldh [rTMA], a
	ld a, TAC_16384_HZ
	ldh [rTAC], a
	ld a, TAC_START | TAC_16384_HZ
	ldh [rTAC], a
	pop bc
	ret
; 0x026c

SECTION "bank0@0773", ROM0[$0773]

; switch ROM bank to a
BankswitchROM: ; 0773 (0:0773)
	ldh [hBankROM], a
	ld [MBC3RomBank], a
	ret

; switch SRAM bank to a
BankswitchSRAM: ; 0779 (0:0779)
	push af
	ldh [hBankSRAM], a
	ld [MBC3SRamBank], a
	ld a, SRAM_ENABLE
	ld [MBC3SRamEnable], a
	pop af
	ret

; enable external RAM (SRAM)
EnableSRAM: ; 0786 (0:0786)
	push af
	ld a, SRAM_ENABLE
	ld [MBC3SRamEnable], a
	pop af
	ret

; disable external RAM (SRAM)
DisableSRAM: ; 078e (0:078e)
	push af
	xor a ; SRAM_DISABLE
	ld [MBC3SRamEnable], a
	pop af
	ret

; set current dest VRAM bank to 0
BankswitchVRAM0: ; 0795 (0:0795)
	push af
	xor a
	ldh [hBankVRAM], a
	ldh [rVBK], a
	pop af
	ret

; set current dest VRAM bank to 1
BankswitchVRAM1: ; 079d (0:079d)
	push af
	ld a, $1
	ldh [hBankVRAM], a
	ldh [rVBK], a
	pop af
	ret

; set current dest VRAM bank to a
BankswitchVRAM: ; 07a6 (0:07a6)
	ldh [hBankVRAM], a
	ldh [rVBK], a
	ret

; set current dest WRAM bank to a
BankswitchWRAM: ; 07ab (0:07ab)
	ldh [rSVBK], a
	ret

; switch to CGB Normal Speed Mode
SwitchToCGBNormalSpeed: ; 07ae (0:07ae)
	ld hl, rKEY1
	bit 7, [hl]
	ret z
	jr CGBSpeedSwitch

; switch to CGB Double Speed Mode
SwitchToCGBDoubleSpeed: ; 07b6 (0:07b6)
	ld hl, rKEY1
	bit 7, [hl]
	ret nz
;	fallthrough

; switch between CGB Double Speed Mode and Normal Speed Mode
CGBSpeedSwitch: ; 07bc (0:07bc)
	ldh a, [rIE]
	push af
	xor a
	ldh [rIE], a
	set 0, [hl]
	xor a
	ldh [rIF], a
	ldh [rIE], a
	ld a, $30
	ldh [rJOYP], a
	stop
	call SetupTimer
	pop af
	ldh [rIE], a
	ret

; validate the saved data in SRAM
; it must contain with the sequence $04, $21, $13 at s0a000
ValidateSRAM: ; 07d6 (0:07d6)
	xor a
	call BankswitchSRAM
	ld hl, $a000
	ld bc, $2000 / 2
.check_pattern_loop
	ld a, [hli]
	cp $41
	jr nz, .check_sequence
	ld a, [hli]
	cp $93
	jr nz, .check_sequence
	dec bc
	ld a, c
	or b
	jr nz, .check_pattern_loop
	call RestartSRAM
	scf
	call $405b ; InitSaveDataAndSetUppercase
	call DisableSRAM
	ret
.check_sequence
	ld hl, $a000 ; s0a000
	ld a, [hli]
	cp $04
	jr nz, .restart_sram
	ld a, [hli]
	cp $21
	jr nz, .restart_sram
	ld a, [hl]
	cp $13
	jr nz, .restart_sram
	ret
.restart_sram
	call RestartSRAM
	or a
	call $405b ; InitSaveDataAndSetUppercase
	call DisableSRAM
	ret

; zero all SRAM banks and set s0a000 to $04, $21, $13
RestartSRAM: ; 0818 (0:0818)
	ld a, 3
.clear_loop
	call $082e ; ClearSRAMBank
	dec a
	cp -1
	jr nz, .clear_loop
	ld hl, $a000 ; s0a000
	ld [hl], $04
	inc hl
	ld [hl], $21
	inc hl
	ld [hl], $13
	ret

; zero the loaded SRAM bank
ClearSRAMBank: ; 082e (0:082e)
	push af
	call BankswitchSRAM
	call EnableSRAM
	ld hl, $a000
	ld bc, $2000
.loop
	xor a
	ld [hli], a
	dec bc
	ld a, c
	or b
	jr nz, .loop
	pop af
	ret

; returns h * l in hl
HtimesL: ; 0844 (0:0844)
	push de
	ld a, h
	ld e, l
	ld d, $0
	ld l, d
	ld h, d
	jr .asm_852
.asm_84d
	add hl, de
.asm_84e
	sla e
	rl d
.asm_852
	srl a
	jr c, .asm_84d
	jr nz, .asm_84e
	pop de
	ret

; return a random number between 0 and a (exclusive) in a
Random: ; 085a (0:085a)
	push hl
	ld h, a
	call UpdateRNGSources
	ld l, a
	call HtimesL
	ld a, h
	pop hl
	ret

; get the next random numbers of the wRNG1 and wRNG2 sequences
UpdateRNGSources: ; 0866 (0:0866)
	push hl
	push de
	ld hl, wRNG1
	ld a, [hli]
	ld d, [hl] ; wRNG2
	inc hl
	ld e, a
	ld a, d
	rlca
	rlca
	xor e
	rra
	push af
	ld a, d
	xor e
	ld d, a
	ld a, [hl] ; wRNGCounter
	xor e
	ld e, a
	pop af
	rl e
	rl d
	ld a, d
	xor e
	inc [hl] ; wRNGCounter
	dec hl
	ld [hl], d ; wRNG2
	dec hl
	ld [hl], e ; wRNG1
	pop de
	pop hl
	ret
; 0x088a

SECTION "bank0@091b", ROM0[$091b]

; set attributes for [hl] sprites starting from wOAM + [wOAMOffset] / 4
; return carry if reached end of wOAM before finishing
SetManyObjectsAttributes: ; 091b (0:091b)
	push hl
	ld a, [wOAMOffset]
	ld c, a
	ld b, HIGH(wOAM)
	cp 40 * 4
	jr nc, .beyond_oam
	pop hl
	ld a, [hli] ; [hl] = how many obj?
.copy_obj_loop
	push af
	ld a, [hli]
	add e
	ld [bc], a ; Y Position <- [hl + 1 + 4*i] + e
	inc bc
	ld a, [hli]
	add d
	ld [bc], a ; X Position <- [hl + 2 + 4*i] + d
	inc bc
	ld a, [hli]
	ld [bc], a ; Tile/Pattern Number <- [hl + 3 + 4*i]
	inc bc
	ld a, [hli]
	ld [bc], a ; Attributes/Flags <- [hl + 4 + 4*i]
	inc bc
	ld a, c
	cp 40 * 4
	jr nc, .beyond_oam
	pop af
	dec a
	jr nz, .copy_obj_loop
	or a
.done
	ld hl, wOAMOffset
	ld [hl], c
	ret
.beyond_oam
	pop hl
	scf
	jr .done

; for the sprite at wOAM + [wOAMOffset] / 4, set its attributes from registers e, d, c, b
; return carry if [wOAMOffset] > 40 * 4 (beyond the end of wOAM)
SetOneObjectAttributes: ; 094a (0:094a)
	push hl
	ld a, [wOAMOffset]
	ld l, a
	ld h, HIGH(wOAM)
	cp 40 * 4
	jr nc, .beyond_oam
	ld [hl], e ; Y Position
	inc hl
	ld [hl], d ; X Position
	inc hl
	ld [hl], c ; Tile/Pattern Number
	inc hl
	ld [hl], b ; Attributes/Flags
	inc hl
	ld a, l
	ld [wOAMOffset], a
	pop hl
	or a
	ret
.beyond_oam
	pop hl
	scf
	ret

; set the Y Position and X Position of all sprites in wOAM to $00
ZeroObjectPositions: ; 0967 (0:0967)
	xor a
	ld [wOAMOffset], a
	ld hl, wOAM
	ld c, 40
	xor a
.loop
	ld [hli], a
	ld [hli], a
	inc hl
	inc hl
	dec c
	jr nz, .loop
	ret

; RST18
; this function affects the stack so that it returns to the pointer following
; the rst call. similar to rst 28, except this always loads bank 1
Bank1Call: ; 0979 (0:0979)
	push hl
	push hl
	push hl
	push hl
	push de
	push af
	ld hl, sp+$d
	ld d, [hl]
	dec hl
	ld e, [hl]
	dec hl
	ld [hl], $0
	dec hl
	ldh a, [hBankROM]
	ld [hld], a
	ld [hl], HIGH(SwitchToBankAtSP)
	dec hl
	ld [hl], LOW(SwitchToBankAtSP)
	dec hl
	inc de
	ld a, [de]
	ld [hld], a
	dec de
	ld a, [de]
	ld [hl], a
	ld a, $1
;	fallthrough

Bank1Call_FarCall_Common: ; 0999 (0:0999)
	call BankswitchROM
	ld hl, sp+$d
	inc de
	inc de
	ld [hl], d
	dec hl
	ld [hl], e
	pop af
	pop de
	pop hl
	ret

; switch to the ROM bank at sp+4
SwitchToBankAtSP: ; 09a7 (0:09a7)
	push af
	push hl
	ld hl, sp+$04
	ld a, [hl]
	call BankswitchROM
	pop hl
	pop af
	inc sp
	inc sp
	ret

; RST28
; this function affects the stack so that it returns
; to the three byte pointer following the rst call
FarCall: ; 09b4 (0:09b4)
	push hl
	push hl
	push hl
	push hl
	push de
	push af
	ld hl, sp+$d
	ld d, [hl]
	dec hl
	ld e, [hl]
	dec hl
	ld [hl], $0
	dec hl
	ldh a, [hBankROM]
	ld [hld], a
	ld [hl], HIGH(SwitchToBankAtSP)
	dec hl
	ld [hl], LOW(SwitchToBankAtSP)
	dec hl
	inc de
	inc de
	ld a, [de]
	ld [hld], a
	dec de
	ld a, [de]
	ld [hl], a
	dec de
	ld a, [de]
	inc de
	jr Bank1Call_FarCall_Common
; 0x09d8

SECTION "bank0@1486", ROM0[$1486]

; returns [[hWhoseTurn] << 8 + a] in a and in [hl]
; i.e. duelvar a of the player whose turn it is
GetTurnDuelistVariable: ; 1486 (0:1486)
	ld l, a
	ldh a, [hWhoseTurn]
	ld h, a
	ld a, [hl]
	ret
; 0x148c
