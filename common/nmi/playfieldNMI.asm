
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; PLAYFIELD NMI
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
DLIDispatch     .proc
                nop
                nop
                nop

                pha
                lda counterDLI
                lda counterDLI          ; its intentional ;) it must be here - purpose of 3-cycles "nop"
                clc

mode            adc #<bufDLIJumps       ; or adc #5 for DLI level start (uses bufDLIJumpsLevelStart table) | code modification changes the #value
                sta j+1
                inc counterDLI          ; 2 -> 5 3
                inc counterDLI
j               jmp (bufDLIJumps)

                .endproc


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
DLI0            .proc
                lda prTabs.visibleFontsH+0
                sta chbase

; code modifications changes the #values of c0-c4

c0              lda #0
                sta colpf0
c1              lda #0
                sta colpf1
c2              lda #0
                sta colpf2
c3              lda #0
                sta colpf3
c4              lda #$84
                sta colbak

                lda #%101110
                sta dmactl

                lda #3
                sta pmactive

                pla
                rti
                .endproc


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
DLI1            .proc
                lda prTabs.visibleFontsH+1
                sta chbase
                pla
                rti
                .endproc


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
DLI2            .proc
                lda prTabs.visibleFontsH+2
                sta chbase
                pla
                rti
                .endproc


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
DLI3            .proc
                lda prTabs.visibleFontsH+3
                sta chbase
                pla
                rti
                .endproc


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
DLI4            .proc
; code modifications changes the #values of c0-c2
                lda #0
                sta colbak
                lda #>dataLogoFonts
                sta chbase

c0              lda #0
                sta colpf0
c1              lda #0
                sta colpf1
c2              lda #0
                sta colpf2

                lda #0
                sta pmactive

                lda #%100010
                sta dmactl

                inc frameCounter

                pla
                rti
                .endproc


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; DLI for level start
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
DLI1b           .proc
                lda prTabs.visibleFontsH+1
                sta chbase

                jsr initPlayfieldPMColors
                jsr showPlayer

                sta wsync

                pla
                rti
                .endproc


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
DLI3b           .proc
                lda prTabs.visibleFontsH+3
                sta chbase

                lda #textPosX
                sta hposp0
                lda #textPosX+12
                sta hposp1
                lda #textPosX+12*2
                sta hposp2
                lda #textPosX+12*3
                sta hposp3

; level name color change
                txa
                pha
                ldx levelNameColorCounter
                lda levelNameColor,x
                sta colpm0
                sta colpm1
                sta colpm2
                sta colpm3

                sta wsync

                pla
                tax
                pla
                rti

textPosX    = 106
                .endproc


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
DLI4b           .proc
                lda #0
                sta colbak

                lda #>dataLogoFonts
                sta chbase

; code modifications changes the #values of c0-c2

c0              lda #0
                sta colpf0
c1              lda #0
                sta colpf1
c2              lda #0
                sta colpf2

                lda #0
                sta pmactive

                lda #%100010
                sta dmactl

                inc frameCounter

; level name
                lda playerGameOver
                bne gameOver

                lda #textPosX
                sta hposp0
                lda #textPosX+8
                sta hposp1
                lda #textPosX+8*2
                sta hposp2
                lda #textPosX+8*3
                sta hposp3

                bne colorBlink

gameOver        lda #textPosX2
                sta hposp0
                lda #textPosX2+12
                sta hposp1
                lda #textPosX2+12*2
                sta hposp2
                lda #textPosX2+12*3
                sta hposp3

; level name color change + delay
colorBlink      txa
                pha

                dec levelNameColorDelay
                bne _1

                lda #configLevelStartNameBlink
                sta levelNameColorDelay
                dec levelNameColorCounter

                lda levelNameColorCounter
                bpl _1

                lda #3
                sta levelNameColorCounter
                ldx levelNameColorCounter

                lda levelNameColor,x
                sta colpm0
                sta colpm1

_1              pla
                tax
                pla
                rti

textPosX    = 116
textPosX2   = 106
                .endproc


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; DLI for Game Over
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
DLI1c           .proc
                lda prTabs.visibleFontsH+1
                sta chbase

                jsr initPlayfieldPMColors
                jsr hidePlayer

                sta wsync

                pla
                rti
                .endproc

;--------------------------------------
;--------------------------------------

levelNameColorDelay     .byte configLevelStartNameBlink
levelNameColorCounter   .byte 3
levelNameColor          .byte $72,$f,$36,$f

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; playfield VBL
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
playfieldVBL    .proc
                pha
                txa
                pha
                tya
                pha

                lda #>dataTextFonts
                sta chbase

                lda #0
                sta counterDLI

c0              lda #$f
                sta colpf0
                lda #$34
                sta colpf2

                jsr playfieldJoystickVBL
                jsr playfieldSoundVBL

                pla
                tay
                pla
                tax
                pla
                rti
                .endproc


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
playfieldTransitionVBL .proc
                pha
                txa
                pha
                tya
                pha

                lda #>dataLogoFonts
                sta chbase

backgroundColor
                lda #0
                sta colbak

                lda #$14                ; shadow
                sta colpf2
                lda #$ee                ; main
                sta colpf1
                lda #$34                ; shadow2
                sta colpf0

                jsr playfieldSoundVBL

                pla
                tay
                pla
                tax
                pla
                rti
                .endproc

;--------------------------------------
;--------------------------------------

                .include 'inc/playfieldJoystickVBL.asm'
                .include 'inc/playfieldSoundVBL.asm'
