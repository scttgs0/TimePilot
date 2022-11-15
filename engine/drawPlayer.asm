
; TIMEPILOT
; drawing Player

;======================================
;
;======================================
drawPlayer      .proc
                lda playerFrameDraw        ; 0 = we dont need to redraw player
                bne _1

                rts

_1              ldx player.currentFrame
                dec playerFrameDraw ; 1-> 0

                ;X - frame animation number 0..15

                ;layout offset bits meaning
                ;9876543210
                ;bbbbssffff
                ; b - byte number
                ; s - sprite number
                ; f - frame number


;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
;
;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
node            .macro solo
                lda dataSpritePlayer+$000+(\1<<6),x
                and playerMask+\1
                sta bufPM0+63-8+\1
                lda dataSpritePlayer+$010+(\1<<6),x
                and playerMask+\1
                sta bufPM1+63-8+\1
                lda dataSpritePlayer+$020+(\1<<6),x
                and playerMask+16+\1
                sta bufPM2+63-8+\1
                lda dataSpritePlayer+$030+(\1<<6),x
                and playerMask+16+\1
                sta bufPM3+63-8+\1
                .endmacro

            .for item in range(16)
                .node item
            .endfor

                rts
                .endproc


;======================================
;
;======================================
hidePlayer      .proc
                lda #0
                sta hposp0
                sta hposp1
                sta hposp2
                sta hposp3
                rts
                .endproc


;======================================
;
;======================================
hideMissiles    .proc
                lda #0
                sta hposm0
                sta hposm1
                sta hposm2
                sta hposm3
                rts
                .endproc


;======================================
;
;======================================
showPlayer      .proc
                lda #120
                sta hposp0
                lda #120
                sta hposp1
                lda #128
                sta hposp2
                lda #128
                sta hposp3

                lda #1
                sta playerFrameDraw
                rts
                .endproc
