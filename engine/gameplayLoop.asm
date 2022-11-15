
; ------------------
;   GAMEPLAY LOOP
; ------------------

gameplay        .proc

minFrames               .byte engineMinFrames
animationSwitchDelay    .byte configAnimationSwitchDelay

;--------------------------------------
;
;--------------------------------------
loop            .proc
                jsr prPrepareFrame
                jsr clearBufScreen
                jsr level.mainLoop
                jsr OLP.mainLoop
                jsr HIT.mainLoop
                jsr SPAWN.mainLoop

                jsr waitFrame

; redraw score on screen every #configAnimationSwitchDelay loop iteration (saves cycles)
                lda animationSwitch
                bne _1

                jsr SCORE.scoreShow
                jsr SCORE.hiScoreRewrite
                jsr SCORE.extraLife

_1              .toggleBufScreenNr      ; MADS macro

                lda gamePaused
                beq _2

                jsr gameplay.pause
_2
                jsr gameplay.nextLoop
                jmp gameplay.loop
                .endproc


;======================================
;
;======================================
nextLoop        .proc
; animation switcher
                dec animationSwitchCounter
                bne fpsLock

                lda animationSwitch
                eor #1
                sta animationSwitch

                lda animationSwitchDelay
                sta animationSwitchCounter

fpsLock
; FPS LOCK
                lda frameCounter
                cmp minFrames
                bcc fpsLock

;!##TRACE "frames: %d" db(frameCounter)

                lda #0
                sta frameCounter

                ; jsr DEBUG.show

; extra life subsong channel swap
                lda extraLifeDuration
                beq _1

                dec extraLifeDuration
                bne _1

                lda #<soundSystem.soundChannelSFX ; extralife subsong done - move enemy shots sfx back to channel 0
                sta SPAWN.enemyShots.shotSoundNumber+5
                sta SPAWN.enemyBombs.shotSoundNumber+5
_1              rts
                .endproc


;======================================
;
;======================================
pause           .proc
                lda #<bufScreenTxt
                sta zp_CopyFrom
                sta swap                ; A=0
                lda #>bufScreenTxt
                sta zp_CopyFrom+1

                lda #<buf2FreePages
                sta zp_CopyTo
                lda #>buf2FreePages
                jsr cont

                lda #1
                sta delay

pauseLoop       lda gamePaused
                beq unpause

                jsr waitFrameNormal

                dec delay
                bne _1

                lda #60
                sta delay

                lda swap
                eor #1
                sta swap
_1              lda swap
                beq _txt2

                lda #0
                ldx #<titleScreenTexts.pause
                ldy #>titleScreenTexts.pause
                jsr copyText

                beq _2

_txt2           lda #0
                ldx #<titleScreenTexts.pause2
                ldy #>titleScreenTexts.pause2
                jsr copyText

_2              lda consol              ; option key during pause - back to title screen
                beq levelSkipper

                cmp #3
                bne pauseLoop

                jmp main

unPause         lda #<buf2FreePages
                sta zp_CopyFrom
                lda #>buf2FreePages
                sta zp_CopyFrom+1

                lda #<bufScreenTxt
                sta zp_CopyTo
                lda #>bufScreenTxt
cont            sta zp_CopyTo+1

                ldy #20-1
                jmp memCopyShort

;--------------------------------------

swap            .byte 0
delay           .byte 1

;--------------------------------------
;
;--------------------------------------
levelSkipper    .proc
                jsr unPause
                lda #0
                sta gamePaused
                lda #1
                sta levelCurrent.bossKilled
                rts
                .endproc

                .endproc

                .endproc
