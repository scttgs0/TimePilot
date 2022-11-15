
;Render List Interpretter

;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
;bufRLIDs* - beginning of font
;bufRLIDof - offset in font
;X - value to write
;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
rliCmdDrawPixel .macro
rliDest     = bufRLIDsL

                ldy #0
                tya
                sta (rliDest),y
                iny
                sta (rliDest),y
                iny
                sta (rliDest),y
                iny
                sta (rliDest),y
                iny
                sta (rliDest),y
                iny
                sta (rliDest),y
                iny
                sta (rliDest),y
                iny
                sta (rliDest),y
                ldy bufRLIDof

                ; lda bufRLIVal

                txa
                sta (rliDest),y
                .endmacro


;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
;bufRLIDs* - beginning of font
;Y - offset in font
;bufRLIVal - value to write
; no mask
;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
rliCmdMergePixel .macro

rliDest     = bufRLIDsL

                ; lda bufRLIVal
                ora (rliDest),y
                sta (rliDest),y
                .endmacro


;======================================
;bufRLIDs* - beginning of font
;bufRLIDof - offset in font
;bufRLIVal - value to write
;bufRLIMsk - mask value
;======================================
;rliCmdMergePixelMasked .proc
                ; lda bufRLIDsL
                ; sta rliDest
                ; lda bufRLIDsH
                ; sta rliDest+1
                ; ldy bufRLIDof
                ; lda (rliDest),y
                ; and bufRLIMsk
                ; ora bufRLIVal
                ; sta (rliDest),y
                ; rts
                ; .endproc


;======================================
;bufRLIDs* - beginning of font
;bufRLISr* - source buffer
;======================================
rliCmdDrawFull  .proc
rliDest     = bufRLIDsL
rliSrc      = bufRLISrL

                ldy #0
                lda (rliSrc),y
                sta (rliDest),y
                iny
                lda (rliSrc),y
                sta (rliDest),y
                iny
                lda (rliSrc),y
                sta (rliDest),y
                iny
                lda (rliSrc),y
                sta (rliDest),y
                iny
                lda (rliSrc),y
                sta (rliDest),y
                iny
                lda (rliSrc),y
                sta (rliDest),y
                iny
                lda (rliSrc),y
                sta (rliDest),y
                iny
                lda (rliSrc),y
                sta (rliDest),y
                rts
                .endproc


;======================================
;bufRLIDs* - beginning of destination font
;bufRLISr* - source buffer
;bufRLIMsk - offset from source buffer to mask buffer
;======================================
rliCmdMergeFull .proc
rliOp   = bufRLIDsL
rliDest = bufRLIDsL
rliSrc  = bufRLISrL

                lda rliSrc
                clc
                adc bufRLIMsk
                sta rliMask

                lda #0
                tay
                adc rliSrc+1
                sta rliMask+1
                lda (rliOp),y
                and (rliMask),y
                ora (rliSrc),y
                sta (rliDest),y

                iny
                lda (rliOp),y
                and (rliMask),y
                ora (rliSrc),y
                sta (rliDest),y

                iny
                lda (rliOp),y
                and (rliMask),y
                ora (rliSrc),y
                sta (rliDest),y

                iny
                lda (rliOp),y
                and (rliMask),y
                ora (rliSrc),y
                sta (rliDest),y

                iny
                lda (rliOp),y
                and (rliMask),y
                ora (rliSrc),y
                sta (rliDest),y

                iny
                lda (rliOp),y
                and (rliMask),y
                ora (rliSrc),y
                sta (rliDest),y

                iny
                lda (rliOp),y
                and (rliMask),y
                ora (rliSrc),y
                sta (rliDest),y

                iny
                lda (rliOp),y
                and (rliMask),y
                ora (rliSrc),y
                sta (rliDest),y
                rts
                .endproc


;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
;prDrawGeneric.prPlayer - beginning of player mask
;prDrawGeneric.prHalf - which half of mask to update
;rliMask - mask buffer
;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
rliCmdMaskFull .macro
                ldy #0
                lda (rliMask),y
                sta (prDrawGeneric.prPlayer),y

                iny
                lda (rliMask),y
                sta (prDrawGeneric.prPlayer),y

                iny
                lda (rliMask),y
                sta (prDrawGeneric.prPlayer),y

                iny
                lda (rliMask),y
                sta (prDrawGeneric.prPlayer),y

                iny
                lda (rliMask),y
                sta (prDrawGeneric.prPlayer),y

                iny
                lda (rliMask),y
                sta (prDrawGeneric.prPlayer),y

                iny
                lda (rliMask),y
                sta (prDrawGeneric.prPlayer),y

                iny
                lda (rliMask),y
                sta (prDrawGeneric.prPlayer),y
                .endmacro


;======================================
;bufRLIDs* - beginning of font
;bufRLISr* - source buffer
;bufRLILen - length of source data 1-8
;======================================
rliCmdDrawTop     .proc
rliDest     = bufRLIDsL
rliSrc      = bufRLISrL

                ldy bufRLILen
                lda rliCmdDrawTopbraTab1-1,y
                sta bra1+1
                lda rliCmdDrawTopbraTab2-1,y
                sta bra2+1
                ldy #0
bra1            beq *

bra1Beg8        lda (rliSrc),y
                sta (rliDest),y
                iny
bra1Beg7        lda (rliSrc),y
                sta (rliDest),y
                iny
bra1Beg6        lda (rliSrc),y
                sta (rliDest),y
                iny
bra1Beg5        lda (rliSrc),y
                sta (rliDest),y
                iny
bra1Beg4        lda (rliSrc),y
                sta (rliDest),y
                iny
bra1Beg3        lda (rliSrc),y
                sta (rliDest),y
                iny
bra1Beg2        lda (rliSrc),y
                sta (rliDest),y
                iny
bra1Beg1        lda (rliSrc),y
                sta (rliDest),y
                iny
                lda #0
bra2            beq *

bra2Beg1        sta (rliDest),y
                iny
bra2Beg2        sta (rliDest),y
                iny
bra2Beg3        sta (rliDest),y
                iny
bra2Beg4        sta (rliDest),y
                iny
bra2Beg5        sta (rliDest),y
                iny
bra2Beg6        sta (rliDest),y
                iny
bra2Beg7        sta (rliDest),y
bra2Beg8        rts
                .endproc


;======================================
;bufRLIDs* - beginning of destination font
;bufRLISr* - source buffer
;bufRLIMsk - offset from source buffer to mask buffer
;bufRLILen - length of source data 1-8
;======================================
rliCmdMergeTop  .proc
rliOp   = bufRLIDsL
rliDest = bufRLIDsL
rliSrc  = bufRLISrL

                lda rliSrc
                clc
                adc bufRLIMsk
                sta rliMask

                lda rliSrc+1
                adc #0
                sta rliMask+1

                ldy bufRLILen
                lda rliCmdMergeTopbraTab1-1,y
                sta bra1+1
                ldy #0
bra1            beq *

bra1Beg8        lda (rliOp),y
                and (rliMask),y
                ora (rliSrc),y
                sta (rliDest),y
                iny
bra1Beg7        lda (rliOp),y
                and (rliMask),y
                ora (rliSrc),y
                sta (rliDest),y
                iny
bra1Beg6        lda (rliOp),y
                and (rliMask),y
                ora (rliSrc),y
                sta (rliDest),y
                iny
bra1Beg5        lda (rliOp),y
                and (rliMask),y
                ora (rliSrc),y
                sta (rliDest),y
                iny
bra1Beg4        lda (rliOp),y
                and (rliMask),y
                ora (rliSrc),y
                sta (rliDest),y
                iny
bra1Beg3        lda (rliOp),y
                and (rliMask),y
                ora (rliSrc),y
                sta (rliDest),y
                iny
bra1Beg2        lda (rliOp),y
                and (rliMask),y
                ora (rliSrc),y
                sta (rliDest),y
                iny
bra1Beg1        lda (rliOp),y
                and (rliMask),y
                ora (rliSrc),y
                sta (rliDest),y
                rts
                .endproc


;======================================
;bufRLILen - length of source data 1-8
;prDrawGeneric.prPlayer - beginning of player mask
;prDrawGeneric.prHalf - which half of mask to update
;rliMask - mask buffer
;======================================
rliCmdMaskTop   .proc
rliOp   = bufRLIDsL
rliDest = bufRLIDsL
rliSrc  = bufRLISrL

                ldy bufRLILen
                lda rliCmdMaskTopbraTab1-1,y
                sta bra1+1

                ldy #0
bra1            beq *

bra1Beg8        lda (rliMask),y
                sta (prDrawGeneric.prPlayer),y
                iny
bra1Beg7        lda (rliMask),y
                sta (prDrawGeneric.prPlayer),y
                iny
bra1Beg6        lda (rliMask),y
                sta (prDrawGeneric.prPlayer),y
                iny
bra1Beg5        lda (rliMask),y
                sta (prDrawGeneric.prPlayer),y
                iny
bra1Beg4        lda (rliMask),y
                sta (prDrawGeneric.prPlayer),y
                iny
bra1Beg3        lda (rliMask),y
                sta (prDrawGeneric.prPlayer),y
                iny
bra1Beg2        lda (rliMask),y
                sta (prDrawGeneric.prPlayer),y
                iny
bra1Beg1        lda (rliMask),y
                sta (prDrawGeneric.prPlayer),y
                rts
                .endproc


;======================================
;bufRLIDs* - beginning of font
;bufRLISr* - source buffer minus offset
;Y - offset to beginning of data 0-7
;======================================
rliCmdDrawBot   .proc
rliDest     = bufRLIDsL
rliSrc      = bufRLISrL

                ; ldy bufRLIDof

                lda rliCmdDrawBotbraTab1,y
                sta bra1+1
                lda rliCmdDrawBotbraTab2,y
                sta bra2+1
                ldy #0
                tya
bra1            beq *

bra1Beg7        sta (rliDest),y
                iny
bra1Beg6        sta (rliDest),y
                iny
bra1Beg5        sta (rliDest),y
                iny
bra1Beg4        sta (rliDest),y
                iny
bra1Beg3        sta (rliDest),y
                iny
bra1Beg2        sta (rliDest),y
                iny
bra1Beg1        sta (rliDest),y
                iny
bra2            bne *

bra1Beg0
bra2Beg0        lda (rliSrc),y
                sta (rliDest),y
                iny
bra2Beg1        lda (rliSrc),y
                sta (rliDest),y
                iny
bra2Beg2        lda (rliSrc),y
                sta (rliDest),y
                iny
bra2Beg3        lda (rliSrc),y
                sta (rliDest),y
                iny
bra2Beg4        lda (rliSrc),y
                sta (rliDest),y
                iny
bra2Beg5        lda (rliSrc),y
                sta (rliDest),y
                iny
bra2Beg6        lda (rliSrc),y
                sta (rliDest),y
                iny
bra2Beg7        lda (rliSrc),y
                sta (rliDest),y
                rts
                .endproc


;======================================
;bufRLIDs* - beginning of destination font
;bufRLISr* - source buffer
;bufRLIMsk - offset from source buffer to mask buffer
;Y - offset to beginning of data 0-7
;======================================
rliCmdMergeBot  .proc
rliOp   = bufRLIDsL
rliDest = bufRLIDsL
rliSrc  = bufRLISrL

                lda rliSrc
                clc
                adc bufRLIMsk
                sta rliMask
                lda rliSrc+1
                adc #0
                sta rliMask+1

                ; ldy bufRLIDof

                lda rliCmdMergeBotbraTab1,y
                sta bra1+1
bra1            bcc *                   ;!

bra1Beg0        lda (rliOp),y
                and (rliMask),y
                ora (rliSrc),y
                sta (rliDest),y
                iny
bra1Beg1        lda (rliOp),y
                and (rliMask),y
                ora (rliSrc),y
                sta (rliDest),y
                iny
bra1Beg2        lda (rliOp),y
                and (rliMask),y
                ora (rliSrc),y
                sta (rliDest),y
                iny
bra1Beg3        lda (rliOp),y
                and (rliMask),y
                ora (rliSrc),y
                sta (rliDest),y
                iny
bra1Beg4        lda (rliOp),y
                and (rliMask),y
                ora (rliSrc),y
                sta (rliDest),y
                iny
bra1Beg5        lda (rliOp),y
                and (rliMask),y
                ora (rliSrc),y
                sta (rliDest),y
                iny
bra1Beg6        lda (rliOp),y
                and (rliMask),y
                ora (rliSrc),y
                sta (rliDest),y
                iny
bra1Beg7        lda (rliOp),y
                and (rliMask),y
                ora (rliSrc),y
                sta (rliDest),y
                rts
                .endproc


;======================================
;Y - offset to beginning of data 0-7
;prDrawGeneric.prPlayer - beginning of player mask
;prDrawGeneric.prHalf - which half of mask to update
;rliMask - mask buffer
;======================================
rliCmdMaskBot   .proc
rliOp   = bufRLIDsL
rliDest = bufRLIDsL
rliSrc  = bufRLISrL

                ; ldy bufRLIDof

                lda rliCmdMaskBotbraTab1,y
                sta bra1+1
bra1            bcc *                   ;!

bra1Beg0        lda (rliMask),y
                sta (prDrawGeneric.prPlayer),y
                iny
bra1Beg1        lda (rliMask),y
                sta (prDrawGeneric.prPlayer),y
                iny
bra1Beg2        lda (rliMask),y
                sta (prDrawGeneric.prPlayer),y
                iny
bra1Beg3        lda (rliMask),y
                sta (prDrawGeneric.prPlayer),y
                iny
bra1Beg4        lda (rliMask),y
                sta (prDrawGeneric.prPlayer),y
                iny
bra1Beg5        lda (rliMask),y
                sta (prDrawGeneric.prPlayer),y
                iny
bra1Beg6        lda (rliMask),y
                sta (prDrawGeneric.prPlayer),y
                iny
bra1Beg7        lda (rliMask),y
                sta (prDrawGeneric.prPlayer),y
                rts
                .endproc

;--------------------------------------
;--------------------------------------

rliCmdDrawTopbraTab1
                .byte rliCmdDrawTop.bra1Beg1-rliCmdDrawTop.bra1Beg8
                .byte rliCmdDrawTop.bra1Beg2-rliCmdDrawTop.bra1Beg8
                .byte rliCmdDrawTop.bra1Beg3-rliCmdDrawTop.bra1Beg8
                .byte rliCmdDrawTop.bra1Beg4-rliCmdDrawTop.bra1Beg8
                .byte rliCmdDrawTop.bra1Beg5-rliCmdDrawTop.bra1Beg8
                .byte rliCmdDrawTop.bra1Beg6-rliCmdDrawTop.bra1Beg8
                .byte rliCmdDrawTop.bra1Beg7-rliCmdDrawTop.bra1Beg8
                .byte rliCmdDrawTop.bra1Beg8-rliCmdDrawTop.bra1Beg8
rliCmdDrawTopbraTab2
                .byte rliCmdDrawTop.bra2Beg1-rliCmdDrawTop.bra2Beg1
                .byte rliCmdDrawTop.bra2Beg2-rliCmdDrawTop.bra2Beg1
                .byte rliCmdDrawTop.bra2Beg3-rliCmdDrawTop.bra2Beg1
                .byte rliCmdDrawTop.bra2Beg4-rliCmdDrawTop.bra2Beg1
                .byte rliCmdDrawTop.bra2Beg5-rliCmdDrawTop.bra2Beg1
                .byte rliCmdDrawTop.bra2Beg6-rliCmdDrawTop.bra2Beg1
                .byte rliCmdDrawTop.bra2Beg7-rliCmdDrawTop.bra2Beg1
                .byte rliCmdDrawTop.bra2Beg8-rliCmdDrawTop.bra2Beg1
rliCmdMergeTopbraTab1
                .byte rliCmdMergeTop.bra1Beg1-rliCmdMergeTop.bra1Beg8
                .byte rliCmdMergeTop.bra1Beg2-rliCmdMergeTop.bra1Beg8
                .byte rliCmdMergeTop.bra1Beg3-rliCmdMergeTop.bra1Beg8
                .byte rliCmdMergeTop.bra1Beg4-rliCmdMergeTop.bra1Beg8
                .byte rliCmdMergeTop.bra1Beg5-rliCmdMergeTop.bra1Beg8
                .byte rliCmdMergeTop.bra1Beg6-rliCmdMergeTop.bra1Beg8
                .byte rliCmdMergeTop.bra1Beg7-rliCmdMergeTop.bra1Beg8
                .byte rliCmdMergeTop.bra1Beg8-rliCmdMergeTop.bra1Beg8
rliCmdMaskTopbraTab1
                .byte rliCmdMaskTop.bra1Beg1-rliCmdMaskTop.bra1Beg8
                .byte rliCmdMaskTop.bra1Beg2-rliCmdMaskTop.bra1Beg8
                .byte rliCmdMaskTop.bra1Beg3-rliCmdMaskTop.bra1Beg8
                .byte rliCmdMaskTop.bra1Beg4-rliCmdMaskTop.bra1Beg8
                .byte rliCmdMaskTop.bra1Beg5-rliCmdMaskTop.bra1Beg8
                .byte rliCmdMaskTop.bra1Beg6-rliCmdMaskTop.bra1Beg8
                .byte rliCmdMaskTop.bra1Beg7-rliCmdMaskTop.bra1Beg8
                .byte rliCmdMaskTop.bra1Beg8-rliCmdMaskTop.bra1Beg8
rliCmdDrawBotbraTab1
                .byte rliCmdDrawBot.bra1Beg0-rliCmdDrawBot.bra1Beg7
                .byte rliCmdDrawBot.bra1Beg1-rliCmdDrawBot.bra1Beg7
                .byte rliCmdDrawBot.bra1Beg2-rliCmdDrawBot.bra1Beg7
                .byte rliCmdDrawBot.bra1Beg3-rliCmdDrawBot.bra1Beg7
                .byte rliCmdDrawBot.bra1Beg4-rliCmdDrawBot.bra1Beg7
                .byte rliCmdDrawBot.bra1Beg5-rliCmdDrawBot.bra1Beg7
                .byte rliCmdDrawBot.bra1Beg6-rliCmdDrawBot.bra1Beg7
                .byte rliCmdDrawBot.bra1Beg7-rliCmdDrawBot.bra1Beg7
rliCmdDrawBotbraTab2
                .byte rliCmdDrawBot.bra2Beg0-rliCmdDrawBot.bra2Beg0
                .byte rliCmdDrawBot.bra2Beg1-rliCmdDrawBot.bra2Beg0
                .byte rliCmdDrawBot.bra2Beg2-rliCmdDrawBot.bra2Beg0
                .byte rliCmdDrawBot.bra2Beg3-rliCmdDrawBot.bra2Beg0
                .byte rliCmdDrawBot.bra2Beg4-rliCmdDrawBot.bra2Beg0
                .byte rliCmdDrawBot.bra2Beg5-rliCmdDrawBot.bra2Beg0
                .byte rliCmdDrawBot.bra2Beg6-rliCmdDrawBot.bra2Beg0
                .byte rliCmdDrawBot.bra2Beg7-rliCmdDrawBot.bra2Beg0
rliCmdMergeBotbraTab1
                .byte rliCmdMergeBot.bra1Beg0-rliCmdMergeBot.bra1Beg0
                .byte rliCmdMergeBot.bra1Beg1-rliCmdMergeBot.bra1Beg0
                .byte rliCmdMergeBot.bra1Beg2-rliCmdMergeBot.bra1Beg0
                .byte rliCmdMergeBot.bra1Beg3-rliCmdMergeBot.bra1Beg0
                .byte rliCmdMergeBot.bra1Beg4-rliCmdMergeBot.bra1Beg0
                .byte rliCmdMergeBot.bra1Beg5-rliCmdMergeBot.bra1Beg0
                .byte rliCmdMergeBot.bra1Beg6-rliCmdMergeBot.bra1Beg0
                .byte rliCmdMergeBot.bra1Beg7-rliCmdMergeBot.bra1Beg0
rliCmdMaskBotbraTab1
                .byte rliCmdMaskBot.bra1Beg0-rliCmdMaskBot.bra1Beg0
                .byte rliCmdMaskBot.bra1Beg1-rliCmdMaskBot.bra1Beg0
                .byte rliCmdMaskBot.bra1Beg2-rliCmdMaskBot.bra1Beg0
                .byte rliCmdMaskBot.bra1Beg3-rliCmdMaskBot.bra1Beg0
                .byte rliCmdMaskBot.bra1Beg4-rliCmdMaskBot.bra1Beg0
                .byte rliCmdMaskBot.bra1Beg5-rliCmdMaskBot.bra1Beg0
                .byte rliCmdMaskBot.bra1Beg6-rliCmdMaskBot.bra1Beg0
                .byte rliCmdMaskBot.bra1Beg7-rliCmdMaskBot.bra1Beg0
