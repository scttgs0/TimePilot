
;======================================
;
;======================================
titleScreen     .proc
                jsr waitFrameNormal

                lda #0
                sta dmactl

                jsr clearbufScreenSimple
                jsr clearbufScreenTxt
                jsr copyTitleLogo
                jsr copyTitleTexts
                jsr waitFrameNormal

                lda #<dataTitleScreenDlist
                sta dlptr
                lda #>dataTitleScreenDlist
                sta dlptr+1

                jsr setTitleScreenNMI
                jsr gameInit.disablePM
                jsr RMT.rmt_silence

                lda SCORE.doHighScoreFlag
                beq titleLoop

                lda ntsc
                sta ntsc_counter
                jmp SCORE.doHighScore

titleLoop       jsr waitFrameNormal

                dec screenDelay
                bne skip

                inc screenMode
                lda screenMode
                cmp #1
                beq mode1

                cmp #2
                beq mode2

                cmp #3
                beq mode3

mode0           jsr titleScreenMode0
                jmp skip

mode1           jsr titleScreenMode1
                bne skip

mode2           jsr titleScreenMode2
                jmp skip

mode3           jsr titleScreenMode3

skip            lda trig0
                beq normalMode

                lda consol
                cmp #6
                beq normalMode

                cmp #5
                bne titleLoop

                lda rapidusDetected
                beq titleLoop

                jmp gameModes.swarm

normalMode      jmp gameModes.normal

;--------------------------------------

screenDelay     .byte 200
screenMode      .byte 0
                .endproc


;======================================
;
;======================================
titleScreenMode0 .proc
                lda #200
                sta titleScreen.screenDelay

                lda #0
                sta titleScreen.screenMode
                sta titleScreenDLI.color+1

                lda #$80
                sta titleScreenDLI.color

                jsr waitFrameNormal
                jsr setTitleScreenNMI
                jsr waitFrameNormal

                lda #<dataTitleScreenDlist
                sta dlptr
                lda #>dataTitleScreenDlist
                sta dlptr+1

                jmp copyTitleTexts

                .endproc


;======================================
;
;======================================
titleScreenMode1 .proc
                lda #10
                sta titleScreen.screenDelay
                rts
                .endproc


;======================================
;
;======================================
titleScreenMode2 .proc
                lda #200
                sta titleScreen.screenDelay
                jsr waitFrameNormal

                lda #<dataTitleScreenDlist2
                sta dlptr
                lda #>dataTitleScreenDlist2
                sta dlptr+1

                jsr setTitleScreenHiScoreNMI

                jmp copyTitleTextsHiScore
                .endproc


;======================================
;
;======================================
titleScreenMode3 .proc
                lda #25
                sta titleScreen.screenDelay
                jmp waitFrameNormal

                .endproc


;======================================
;
;======================================
copyTitleLogo   .proc
                lda #0
                tax
                ldy #91
_next1          txa
                sta bufScreen0+83,x
                tya
                sta bufScreen0+123,x

                iny
                inx
                cpx #34
                bne _next1

                rts
                .endproc


;======================================
;
;======================================
setTitleScreenNMI .proc
                lda #0
                sta nmien

                lda #<titleScreenDLI
                sta NMI.DLI+1
                lda #>titleScreenDLI
                sta NMI.DLI+2
                lda #<titleScreenVBL
                sta NMI.VBL+1
                lda #>titleScreenVBL
                sta NMI.VBL+2

                lda #$c0
                sta nmien
                rts
                .endproc


;======================================
;
;======================================
setTitleScreenHiScoreNMI .proc
                lda #0
                sta nmien

                lda #<titleScreenHiScoreDLI
                sta NMI.DLI+1
                lda #>titleScreenHiScoreDLI
                sta NMI.DLI+2

                lda #$c0
                sta nmien
                rts
                .endproc


;======================================
;
;======================================
copyTitleTexts  .proc
                lda rapidusDetected
                beq txtPlay

; or rapidus enabled
                lda #0
                ldx #<titleScreenTexts.rapidus
                ldy #>titleScreenTexts.rapidus
                jsr copyText

                jmp nextText

; play
txtPlay         lda #0
                ldx #<titleScreenTexts.play
                ldy #>titleScreenTexts.play
                jsr copyText

nextText
; 1-up bonus
                lda #0
                ldx #<titleScreenTexts.bonus1
                ldy #>titleScreenTexts.bonus1
                jsr copyText

                lda #0
                ldx #<titleScreenTexts.bonus2
                ldy #>titleScreenTexts.bonus2
                jsr copyText

; konami
                lda #0
                ldx #<titleScreenTexts.konami
                ldy #>titleScreenTexts.konami
                jsr copyText

; NG
                lda #0
                ldx #<titleScreenTexts.newgen
                ldy #>titleScreenTexts.newgen
                jmp copyText

                .endproc


;--------------------------------------
;
;--------------------------------------
copyTitleTextsHiScore .proc
; score table
                lda #0
                ldx #<titleScreenTexts.hiscore
                ldy #>titleScreenTexts.hiscore
                jmp copyText
                .endproc

;--------------------------------------
;--------------------------------------

titleScreenTexts .proc
            .enc "atari-screen"
play            .text 8,0,'PLAY#'
rapidus         .text 2,0,'RAPIDUS ENABLED!#'
pause           .text 0,0,'       PAUSED       #'
pause2          .text 3,0,'OPTION TO QUIT#'
bonus1          .text 0,1,'1ST BONUS 10000 PTS.#'
bonus2          .text 0,2,'AND EVERY 50000 PTS.#'
konami          .text 4,7,'@1982 KONAMI#'
newgen          .text 0,8,'@2018 NEW GENERATION#'
hiscore         .text 0,1,'SCORE RANKING TABLE '
                .text '1ST    10000   SOLO '
                .text '2ND     8800   LAOO '
                .text '3RD     8460   MIKER'
hiscoreMove     .text '4TH     6502   TIGER'
                .text '5TH     4300   VOY   #'
            .enc "none"
                .endproc
