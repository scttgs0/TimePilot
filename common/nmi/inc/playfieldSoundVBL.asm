
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; TIMEPILOT Sound VBL
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
playfieldSoundVBL .proc
                lda gamePaused
                beq _1

                rts

_1              lda ntsc_counter
                beq sfxStart

                dec ntsc_counter
                bne sfxStart

                lda #7
                sta ntsc_counter
                rts

sfxStart        ldx #3
sfx             lda soundSystem.soundChannelSFX,x
                beq sfxSkip

                asl
                tay                                     ;Y = 2,4,..,16    instrument number * 2 (0,2,4,..,126)
                lda soundSystem.soundChannelNote,x      ;A = 12            note (0..60)
                jsr RMT.RASTERMUSICTRACKER+15           ;RMT_SFX  | it doesnt change X register

                lda #0                                  ; sound done - we skip it next time
                sta soundSystem.soundChannelSFX,x

sfxSkip         dex
                bpl sfx

skipSFX         jmp RMT.RASTERMUSICTRACKER+3

                .endproc
