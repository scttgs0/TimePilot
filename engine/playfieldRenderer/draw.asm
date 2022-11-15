
;======================================
; drawing small bullet. 1 pixel
;--------------------------------------
; x - index in object list table
;======================================
prDrawPlayerFire .proc
prXOff          = prTemp+5
prRowRem        = bufRLIDof
prColRem        = prTemp+7
prFontNr        = prTemp+8              ;font number
prScreenOff     = prTemp+9              ;w    offset in screen buffer
prFntOff        = bufRLIDsL             ;offset in font

                lda ol.tab.posXH,x
                lsr
                lsr
                tay
                lda prTabs.xoff,y
                bpl cont

outOfBounds     lda #$ff
                rts

cont            sta prXOff
                lda ol.tab.posYH,x
                lsr
                lsr
                lsr
                tay
                lda prTabs.fontNr,y
                bmi outOfBounds

                sta prFontNr
                lda ol.tab.posYH,x
                and #$7
                sta prRowRem
                lda ol.tab.posXH,x
                and #3
                sta prColRem

                lda prTabs.scrLo,y
                clc
                adc prXOff
                sta prScreenOff
                lda prTabs.scrHi,y
                adc #0
                sta prScreenOff+1

                ldx prFontNr
                ldy #0
                lda (prScreenOff),y
                bne mergeFire

;allocating font
                lda fntAlloc,x
                sta prFntOff
                ora #$80
                sta (prScreenOff),y
                inc fntAlloc,x
                lda #0
                asl prFntOff
                asl prFntOff
                rol
                asl prFntOff
                rol
                adc prTabs.fontsH,x
                sta bufRLIDsH

                ; lda prFntOff
                ; sta bufRLIDsL

                ldy prColRem
                ldx bitmap,y

                ; stx bufRLIVal
                ; lda prRowRem
                ; sta bufRLIDof

                .rliCmdDrawPixel
                lda #0
                rts

;font already present
mergeFire       sta prFntOff
                lda #0
                asl prFntOff
                asl prFntOff
                rol
                asl prFntOff
                rol
                adc prTabs.fontsH,x
                sta bufRLIDsH

                ; lda prFntOff
                ; sta bufRLIDsL

                ldy prColRem
                lda bitmap,x

                ; sta bufRLIVal

                ldy prRowRem
                .rliCmdMergePixel
                lda #0
                rts

;--------------------------------------

bitmap          .byte %11000000
                .byte %00110000
                .byte %00001100
                .byte %00000011

                .endproc


;======================================
; X - object number in ol.tab
;======================================
prDrawEnemy     .proc
tmpFrame        = zeroPageLocal

                lda ol.tab.frame,x
                sta tmpFrame

; custom animations for level 3 and 5
                lda gameCurrentLevel
                cmp #5
                beq lvl5
                cmp #3
                bne draw
                ldy tmpFrame
                lda level3,y
                sta tmpFrame
                bpl draw
lvl5
                lda animationSwitch     ; 0-1 frames for lvl5 enemies in loop
                sta tmpFrame
draw
                clc
                lda prObjId
                adc tmpFrame

                tay
                lda ebGfxScrsL,y
                sta prGfxScr
                lda ebGfxScrsH,y
                sta prGfxScr+1

                bne prDrawGeneric       ;!

; level 3 has different animation frames per movement frame
level3          .byte 4,3,2,1,0,1,2,3,4,5,6,7,8,7,6,5
                .endproc


;======================================
; X - object number in ol.tab
;======================================
prDrawObject    .proc
                clc
                lda ol.tab.frame,x
                adc prObjId
                tay
                lda ebGfxScrsL,y
                sta prGfxScr
                lda ebGfxScrsH,y
                sta prGfxScr+1

                ; fall through
                ; jmp prDrawGeneric     ; it will execute prDrawGeneric
                .endproc


;--------------------------------------
; x - index in object list table
; returns 0 on successful draw
; returns $ff if object is out of bounds
; returns 1 if object with colission with player
;--------------------------------------
prDrawGeneric   .proc
prRow           = prTemp+4
prColRem        = prTemp+5
prRowRem        = prTemp+6
prWidth1        = prTemp+7              ;iterations left in one x loop
prXOff          = prTemp+8              ;x screen offset (bytes)
prWidth         = prTemp+9
prYIter         = prTemp+10             ;y iteration in pixels i.e. offset in source graphics
prYOff          = prTemp+11             ;y screen offset (font rows)
prScreenOff     = prTemp+12             ;w offset in screen buffer
prFntOff        = prTemp+14             ;offset in font
prSrcGfx        = prTemp+15             ;w
prBottomN       = prTemp+17             ;N if set if ther are more than 8 Y iterations left
prBottomCnt     = prTemp+18             ;number of iterations to bottom
prNewFont       = prTemp+19             ;zero if new fot has been allocated
prSrcGfx1       = bufRLISrL             ;w
prCurHeight     = prTemp+22             ;current height
prExit          = prTemp+23             ;exit status
prPlayer        = prTemp+24             ;w player mask

                lda ol.tab.posXH,x
                lsr
                lsr
                tay
                lda prTabs.xoff,y
                bpl xpos
                asl
                bpl xneg

outOfBounds     lda #$ff
                rts

xneg            lsr
                sta prWidth1            ;on 4 bits of prTabs.xoff is encoded how many iterations are out of screen
                cmp prObjWidth
                bcc _1

                clc
                bne outOfBounds

                lda ol.tab.posXH,x
                and #3
                beq outOfBounds
                bne xneg2

_1              lda ol.tab.posXH,x
                and #3
xneg2           sta prColRem
                lda prGfxScr+1
                sta prSrcGfx+1
                lda prGfxScr
                ldy prWidth1
                beq xneg1

xneg0           adc prGfxNextOff+4
                bcc _2

                inc prSrcGfx+1
                clc
_2              dey
                bne xneg0

xneg1           ldy prColRem
                adc prGfxNextOff,y
                sta prSrcGfx
                lda #0
                sta prXOff
                adc prSrcGfx+1
                sta prSrcGfx+1
                bne xcont

xpos            sta prXOff
                lda ol.tab.posXH,x
                and #3
                sta prColRem
                tay
                lda #0
                sta prWidth1
                lda prGfxScr
                clc
                adc prGfxNextOff,y
                sta prSrcGfx
                lda prGfxScr+1
                adc #0
                sta prSrcGfx+1

xcont

_temp           = prNewFont

                lda #40
                sec
                sbc prXOff
                sta _temp

                lda prObjWidth
                sec
                sbc prWidth1
                sta prWidth
                lda prColRem
                beq _3

                inc prWidth             ;with is one itration greater if we don't start from beginning of font
_3              lda prWidth
                cmp _temp
                bcc _4

                lda _temp
                sta prWidth
_4              lda ol.tab.posYH,x
                and #$7
                sta prRowRem
                lda #prScreenYMax
                sec
                sbc ol.tab.posYH,x
                sec
                sbc prObjHeight
                bcs _fullHeight

                adc prObjHeight
                sta prCurHeight
                jmp _5

_fullHeight     lda prObjHeight
                sta prCurHeight

_5              lda ol.tab.posYH,x
                lsr
                lsr
                lsr
                tay
                lda prTabs.fontNr,y
                bpl ypos

                asl
                bpl +                   ;jmi outOfBounds
                jmp outOfBounds         ;if 6th bit is set - we're below the screen

+               sbc prRowRem            ;on lower bits there are encoded number of iteration out of screen
                sta prYIter
                clc
                adc prSrcGfx
                sta prSrcGfx
                bne _6

                inc prSrcGfx+1
_6              lda #10
                sta prYOff
                lda #0
                sta prRowRem
                beq yloopStart          ;!

exit
                lda prExit
                rts

ypos            sty prYOff
                lda #0
                sta prYIter

yloopStart      lda #0
                sta prExit
yloop           lda prCurHeight
                sec
                sbc prYIter
                beq exit
                bcc exit

                sta prBottomCnt
                cmp #8
                ror prBottomN           ;setting N bit if there are more than 8 iterations left

                lda prSrcGfx
                sec
                sbc prRowRem
                sta prSrcGfx1
                lda prSrcGfx+1
                sbc #0
                sta prSrcGfx1+1

                ldy prYOff
                lda prTabs.scrLo,y
                clc
                adc prXOff
                sta prScreenOff
                lda prTabs.scrHi,y
                adc #0
                sta prScreenOff+1
                lda prWidth
                sta prWidth1

xloopJmp        = *+1
                jmp *                   ; auto-modification in prepare phase

nextyLoop

_temp           = prNewFont

                inc prYOff
                lda #8
                ldy prRowRem
                beq nextyLoop1

                sec
                sbc prRowRem
                sta _temp
                clc
                adc prYIter
                sta prYIter
                lda #0
                sta prRowRem
                lda prSrcGfx
                clc
                adc _temp
                sta prSrcGfx
                bne yloop

                inc prSrcGfx+1
                bne yloop               ;!
nextyLoop1      clc
                adc prYIter
                sta prYIter
                lda prSrcGfx
                clc
                adc #8
                sta prSrcGfx
                bne yloop

                inc prSrcGfx+1
                bne yloop               ;!


;--------------------------------------
;
;--------------------------------------
StandardXLoop   .proc
                lda prTabs.fontNr,y
                adc #<fntAlloc
                sta fntAllocA0
                sta fntAllocA1
;c is clear
                sbc #<fntAlloc-1
;c is set
                tay
                lda prTabs.fontsH,y
                sta fontsHA

xloop           ldy #0
                lda (prScreenOff),y
                sta prNewFont
                beq clearFont

                sta bufRLIDsL           ;font low
                cmp #fontsReservedForPlayerLocation
                bcc dirtyFont

                lda prExit
exitResult      = *+1
                ora #0
                sta prExit
                jmp dirtyFont

clearFont
;allocating font
fntAllocA0      = *+1
                lda fntAlloc
                sta bufRLIDsL           ;font low
highFontDeterminant = *+1
                ora #$80
                sta (prScreenOff),y
fntAllocA1      = *+1
                inc fntAlloc

dirtyFont       tya
                asl bufRLIDsL
                asl bufRLIDsL
                rol
                asl bufRLIDsL
                rol
fontsHA         = *+1
                adc #0
                sta bufRLIDsH           ;destination font high

                ; lda prSrcGfx1
                ; sta bufRLISrL         ;source low
                ; lda prSrcGfx1+1
                ; sta bufRLISrH         ;source high

;now we decide which command to use
                lda prNewFont
                bne csMerge
csDraw                                  ;new font is drawn
                ldy prRowRem
                beq csDrawFullOrTop
csDrawBot                               ;drawing bottom part of the font

                ; sta bufRLIDof

                jsr rliCmdDrawBot
                jmp nextxLoop


csDrawFullOrTop
                bit prBottomN
                bmi csDrawFull

csDrawTop       lda prBottomCnt         ;drawing top part of the font
                sta bufRLILen
                jsr rliCmdDrawTop
                jmp nextxLoop

csDrawFull      jsr rliCmdDrawFull      ;drawing full font

nextxLoop       dec prWidth1
                bne +                   ;jeq nextyLoop

                jmp nextyLoop

+               inc prScreenOff
                bne _1

                inc prScreenOff+1
_1              lda prSrcGfx1
                clc
                adc prGfxNextOff+4
                sta prSrcGfx1
                bcc xloop

                inc prSrcGfx1+1
                bne xloop               ;!

csMerge         lda prGfxMaskOff        ;merging to existing font
                sta bufRLIMsk           ;mask offset

                ldy prRowRem
                beq csMergeFullOrTop

csMergeBot                              ;merging bottom part of the font
                ; sta bufRLIDof

                jsr rliCmdMergeBot
                jmp nextxLoop

csMergeFullOrTop
                bit prBottomN
                bmi csMergeFull

csMergeTop      lda prBottomCnt         ;drawing top part of the font
                sta bufRLILen
                jsr rliCmdMergeTop
                jmp nextxLoop

csMergeFull     jsr rliCmdMergeFull     ;drawing full font
                jmp nextxLoop

                .endproc


;--------------------------------------
;
;--------------------------------------
Cloud3XLoop     .proc
                lda prTabs.fontNr,y
                adc #<fntAlloc
                sta fntAllocA0
                sta fntAllocA1
;c is clear
                sbc #<fntAlloc-1
;c is set
                tay
                lda prTabs.fontsH,y
                sta prFntOff

xloop           ldy #0
                lda (prScreenOff),y
                bne dirtyFont

;allocating font
fntAllocA0      = *+1
                lda fntAlloc
                sta bufRLIDsL           ;destination low
                ora #$80
                sta (prScreenOff),y
fntAllocA1      = *+1
                inc fntAlloc

                tya
                asl bufRLIDsL
                asl bufRLIDsL
                rol
                asl bufRLIDsL
                rol
                adc prFntOff
                sta bufRLIDsH           ;destination high

                ; lda prSrcGfx1
                ; sta bufRLISrL         ;source low
                ; lda prSrcGfx1+1
                ; sta bufRLISrH         ;source high

csDraw          ldy prRowRem            ;new font is drawn
                beq csDrawFullOrTop

csDrawBot                               ;drawing bottom part of the font

                ; sta bufRLIDof

                jsr rliCmdDrawBot
                jmp nextxLoop

csDrawFullOrTop bit prBottomN
                bmi csDrawFull

csDrawTop       lda prBottomCnt         ;drawing top part of the font
                sta bufRLILen
                jsr rliCmdDrawTop
                jmp nextxLoop

csDrawFull      jsr rliCmdDrawFull      ;drawing full font

nextxLoop       dec prWidth1
                bne +                   ;jeq nextyLoop

                jmp nextyLoop

+               inc prScreenOff
                bne _1

                inc prScreenOff+1
_1              lda prSrcGfx1
                clc
                adc prGfxNextOff+4
                sta prSrcGfx1
                bcc xloop

                inc prSrcGfx1+1
                bne xloop               ;!

dirtyFont       cmp #fontsReservedForPlayerLocation
                bcc notOnPlayer

                sta bufRLIDsL           ;source font low
                sta playerMaskTouched

                tax
                lda prTabs.playerMaskByFontL-fontsReservedForPlayerLocation,x
                sta prPlayer
                lda prTabs.playerMaskByFontH-fontsReservedForPlayerLocation,x
                sta prPlayer+1
                tya
                asl bufRLIDsL
                asl bufRLIDsL
                rol
                asl bufRLIDsL
                rol
                adc prFntOff
                sta bufRLIDsH           ;destination high

                ; lda prSrcGfx1
                ; sta bufRLISrL         ;source low
                ; lda prSrcGfx1+1
                ; sta bufRLISrH         ;source high

csMerge2        lda prGfxMaskOff        ;merging to existing font
                sta bufRLIMsk           ;mask offset

                ldy prRowRem
                beq csMergeFullOrTop2

csMergeBot2     jsr rliCmdMergeBot      ;merging bottom part of the font
                ldy prRowRem
                jsr rliCmdMaskBot
                jmp nextxLoop

csMergeFullOrTop2
                bit prBottomN
                bmi csMergeFull2

csMergeTop2     lda prBottomCnt         ;drawing top part of the font
                sta bufRLILen

                jsr rliCmdMergeTop
                jsr rliCmdMaskTop
                jmp nextxLoop

csMergeFull2    jsr rliCmdMergeFull     ;drawing full font

                .rliCmdMaskFull
                jmp nextxLoop

notOnPlayer     bmi highFont

                ora #$80
                sta (prScreenOff),y

highFont        sta bufRLIDsL           ;source font low

                tya
                asl bufRLIDsL
                asl bufRLIDsL
                rol
                asl bufRLIDsL
                rol
                adc prFntOff
                sta bufRLIDsH           ;destination high

                ; lda prSrcGfx1
                ; sta bufRLISrL         ;source low
                ; lda prSrcGfx1+1
                ; sta bufRLISrH         ;source high

csMerge         lda prGfxMaskOff        ;merging to existing font
                sta bufRLIMsk           ;mask offset

                ldy prRowRem
                beq csMergeFullOrTop

csMergeBot                              ;merging bottom part of the font
                ; sta bufRLIDof
                ; tay

                jsr rliCmdMergeBot
                jmp nextxLoop

csMergeFullOrTop
                bit prBottomN
                bmi csMergeFull

csMergeTop      lda prBottomCnt         ;drawing top part of the font
                sta bufRLILen
                jsr rliCmdMergeTop
                jmp nextxLoop

csMergeFull     jsr rliCmdMergeFull     ;drawing full font
                jmp nextxLoop
                .endproc

                .endproc

prTabs          .block
fontNr              .byte $a8,$a4,$a0,$9c,$98,$94,$90,$8c,$88,$84,$00,$00,$00,$01,$01,$01
                    .byte $02,$02,$02,$03,$03,$03,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
scrLo               .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$00,$28,$50,$78,$a0,$c8
                    .byte $f0,$18,$40,$68,$90,$b8,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
scrHi               .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$00,$00,$00,$00,$00,$00
                    .byte $00,$01,$01,$01,$01,$01,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
xoff                .byte $8c,$8b,$8a,$89,$88,$87,$86,$85,$84,$83,$82,$81,$00,$01,$02,$03
                    .byte $04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$10,$11,$12,$13
                    .byte $14,$15,$16,$17,$18,$19,$1a,$1b,$1c,$1d,$1e,$1f,$20,$21,$22,$23
                    .byte $24,$25,$26,$27,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
fontsH              .byte >bufFonts0a,>bufFonts1a,>bufFonts2a,>bufFonts3a
visibleFontsH       .byte >bufFonts0b,>bufFonts1b,>bufFonts2b,>bufFonts3b
playerMaskByFontL   .byte <playerMask,<playerMask,<playerMask+16,<playerMask+16
                    .byte <playerMask+8,<playerMask+8,<playerMask+24,<playerMask+24
playerMaskByFontH   .byte >playerMask,>playerMask,>playerMask+16,>playerMask+16
                    .byte >playerMask+8,>playerMask+8,>playerMask+24,>playerMask+24
playerMaskTable     .byte $0f,$f0
                .endblock
