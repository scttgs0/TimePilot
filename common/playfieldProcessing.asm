
; playfield list procedures

;======================================
;
;======================================
clearBufScreenSimple .proc
                lda #0
                tax
_next1          sta bufScreen0,x
                sta bufScreen0+$080,x
                sta bufScreen0+$100,x
                sta bufScreen0+$180,x
                sta bufScreen1,x
                sta bufScreen1+$080,x
                sta bufScreen1+$100,x
                sta bufScreen1+$180,x
                inx
                bpl _next1
                rts
                .endproc


;======================================
;
;======================================
clearBufScreen  .proc
                lda bufScreenNr
                beq s0

s1              lda #0
                tax
_next1          sta bufScreen1,x
                sta bufScreen1+$080,x
                sta bufScreen1+$100,x
                sta bufScreen1+$180,x
                inx
                bpl _next1

                lda playerDestroyed
                bne skipPLayerFonts0
playerFontOffset =   prScreenWidthFonts*(prScreenHeightFonts/2-1)+prScreenWidthFonts/2-2

                ldx #fontsReservedForPlayerLocation
                stx bufScreen1+playerFontOffset+0
                inx
                stx bufScreen1+playerFontOffset+1
                inx
                stx bufScreen1+playerFontOffset+2
                inx
                stx bufScreen1+playerFontOffset+3
                inx
                stx bufScreen1+playerFontOffset+prScreenWidthFonts+0
                inx
                stx bufScreen1+playerFontOffset+prScreenWidthFonts+1
                inx
                stx bufScreen1+playerFontOffset+prScreenWidthFonts+2
                inx
                stx bufScreen1+playerFontOffset+prScreenWidthFonts+3

                lda #0
                ldx #7
_next2
                sta bufFonts1b+$3c0,x
                sta bufFonts1b+$3c8,x
                sta bufFonts1b+$3d0,x
                sta bufFonts1b+$3d8,x
                sta bufFonts2b+$3e0,x
                sta bufFonts2b+$3e8,x
                sta bufFonts2b+$3f0,x
                sta bufFonts2b+$3f8,x
                dex
                bpl _next2
skipPLayerFonts0
                rts

s0
                lda #0
                tax
_next3          sta bufScreen0,x
                sta bufScreen0+$080,x
                sta bufScreen0+$100,x
                sta bufScreen0+$180,x
                inx
                bpl _next3

                lda playerDestroyed
                bne skipPLayerFonts1

                ldx #fontsReservedForPlayerLocation
                stx bufScreen0+playerFontOffset+0
                inx
                stx bufScreen0+playerFontOffset+1
                inx
                stx bufScreen0+playerFontOffset+2
                inx
                stx bufScreen0+playerFontOffset+3
                inx
                stx bufScreen0+playerFontOffset+prScreenWidthFonts+0
                inx
                stx bufScreen0+playerFontOffset+prScreenWidthFonts+1
                inx
                stx bufScreen0+playerFontOffset+prScreenWidthFonts+2
                inx
                stx bufScreen0+playerFontOffset+prScreenWidthFonts+3

                lda #0
                ldx #7
_next4
                sta bufFonts1a+$3c0,x
                sta bufFonts1a+$3c8,x
                sta bufFonts1a+$3d0,x
                sta bufFonts1a+$3d8,x
                sta bufFonts2a+$3e0,x
                sta bufFonts2a+$3e8,x
                sta bufFonts2a+$3f0,x
                sta bufFonts2a+$3f8,x
                dex
                bpl _next4

skipPLayerFonts1
                rts
                .endproc


;======================================
; at beginning of new frame
;======================================
prPrepareFrame  .proc
                lda #1
                sta fntAlloc+0
                sta fntAlloc+1
                sta fntAlloc+2
                sta fntAlloc+3
                ;fall through
                .endproc


;======================================
;
;======================================
commitBufScreen .proc
                ldx bufScreenNr
                ldy tabBufScreen,x
                sty prTabs.scrHi+10
                sty prTabs.scrHi+11
                sty prTabs.scrHi+12
                sty prTabs.scrHi+13
                sty prTabs.scrHi+14
                sty prTabs.scrHi+15
                sty prTabs.scrHi+16
                iny
                sty prTabs.scrHi+17
                sty prTabs.scrHi+18
                sty prTabs.scrHi+19
                sty prTabs.scrHi+20
                sty prTabs.scrHi+21
                ldy tabFont0,x
                sty prTabs.fontsH+0
                ldy tabFont1,x
                sty prTabs.fontsH+1
                ldy tabFont2,x
                sty prTabs.fontsH+2
                ldy tabFont3,x
                sty prTabs.fontsH+3
                txa
                eor #1
                tax
                ldy tabBufScreen,x
                sty adrBufScreen0
                ldy tabFont0,x
                sty prTabs.visibleFontsH+0
                ldy tabFont1,x
                sty prTabs.visibleFontsH+1
                ldy tabFont2,x
                sty prTabs.visibleFontsH+2
                ldy tabFont3,x
                sty prTabs.visibleFontsH+3
                rts
                .endproc

;--------------------------------------
;--------------------------------------

tabBufScreen    .byte >bufScreen0,>bufScreen1
tabFont0        .byte >bufFonts0a,>bufFonts0b
tabFont1        .byte >bufFonts1a,>bufFonts1b
tabFont2        .byte >bufFonts2a,>bufFonts2b
tabFont3        .byte >bufFonts3a,>bufFonts3b


;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
;
;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
toggleBufScreenNr .macro
                lda bufScreenNr
                eor #1
                sta bufScreenNr
                .endmacro


;======================================
;
;======================================
clearBufFontsHidden .proc
                lda bufScreenNr
                bne clearBufFontsB

                ;fall through
                ;beq clearBufFontsA

                .endproc


;--------------------------------------
;
;--------------------------------------
clearBufFontsA  ;--.proc
                lda #0
                tax
_next1          sta bufFonts0a+$000,x
                sta bufFonts0a+$100,x
                sta bufFonts0a+$200,x
                sta bufFonts0a+$300,x
                sta bufFonts1a+$000,x
                sta bufFonts1a+$100,x
                sta bufFonts1a+$200,x
                sta bufFonts1a+$300,x
                sta bufFonts2a+$000,x
                sta bufFonts2a+$100,x
                sta bufFonts2a+$200,x
                sta bufFonts2a+$300,x
                sta bufFonts3a+$000,x
                sta bufFonts3a+$100,x
                sta bufFonts3a+$200,x
                sta bufFonts3a+$300,x

                inx
                bne _next1

                rts
                ;--.endproc


;======================================
;
;======================================
clearBufFontsB  .proc
                lda #0
                tax
_next1          sta bufFonts0b+$000,x
                sta bufFonts0b+$100,x
                sta bufFonts0b+$200,x
                sta bufFonts0b+$300,x
                sta bufFonts1b+$000,x
                sta bufFonts1b+$100,x
                sta bufFonts1b+$200,x
                sta bufFonts1b+$300,x
                sta bufFonts2b+$000,x
                sta bufFonts2b+$100,x
                sta bufFonts2b+$200,x
                sta bufFonts2b+$300,x
                sta bufFonts3b+$000,x
                sta bufFonts3b+$100,x
                sta bufFonts3b+$200,x
                sta bufFonts3b+$300,x

                inx
                bne _next1

                rts
                .endproc


;======================================
;
;======================================
resetPlayerMask .proc
                ldx #$3f
                lda #$ff
_next1          sta playerMask,x

                dex
                bpl _next1

                rts
                .endproc
