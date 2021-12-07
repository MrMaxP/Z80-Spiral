
;***********************************************************
;* Size Coding 01-12-21
;*
;* Adrian Brown - adrian@apbcomputerservices.co.uk
;*
;***********************************************************

                DEVICE  ZXSPECTRUM48

				ORG	$8000

;***********************************************************

Start:
				; Setup the screen for the compo
				call Setup

				; Call the routine
				call Routine

Loop:			jr	Loop

;***********************************************************

Setup:
				; Clear the screen
				ld		hl, $4000
				ld		de, $4001
				ld		(hl), 0
				ld		bc, 6144
				ldir
				ld		bc, 767
				ld		(hl), %00111000
				ldir

				; Clear border
				ld		a, 7
				out		(254), a

				; Make sure interrupts are enabled
				ei
				ret

;***********************************************************
// 2658

Routine:
				ld		de,0			// de = xy pixel position
				ld		hl,$C0FF		// hl = vh loop counts

rep:			ld		b,l				// b with h count
hlp1:			call	pixel			// plot
				inc		e				// inc x pos
				djnz	hlp1			// loop

				dec		h				// dec horizontal loop count
				dec		l				// dec vertical loop count

				ld		b,h				// from here on do the same as above for down, left and up loops of the spiral
vlp1:			call	pixel
				inc		d
				djnz	vlp1

				dec		h
				dec		l
				ld		b,l
hlp2:			call	pixel
				dec		e
				djnz	hlp2

				dec		h
				dec		l
				ld		b,h
vlp2:			call	pixel
				dec		d
				djnz	vlp2

				dec		h
				ret		z				// zero vert count means we're done
				dec		l

				jr		rep				// loop

										// standard(ish) get pixel address in screen mem
pixel:			push	bc				// store registers that we're using in the main section
				push	hl
				ld		a,d
				ld		l,a
				and		7
				or		$40
				ld		h,a

				ld		a,l
				rra
				rra
				rra
				and		$18
				or		h
				ld		h,a

				ld		a,l
				rla
				rla
				and		$E0
				ld		l,a
				ld		a,e
				srl		a
				srl		a
				srl		a
				add		l
				ld		l,a

										// hl is now the screen address of the byte containing the pixel

				ld		a,e
				and		7				// and off bottom 7 bits (pixel across byte
				inc		a				// +1 as our pixel starts in the carry flag
				ld		b,a				// set loop count
				xor		a				// zero a
				scf						// set carry flag
bit:			rra						// rotate carry flag into byte and along byte by count b
				djnz	bit

				or		(hl)			// or our pixel with screen memory
				ld		(hl),a			// put it back on the screen

				pop		hl				// get our registers back
				pop		bc

//				halt					// wait for screen interrupt to make it slow

				ret

Routine_End:

;***********************************************************

				DISPLAY "Routine Size: ", /D, Routine_End - Routine

;***********************************************************

                SAVESNA "main.sna", Start