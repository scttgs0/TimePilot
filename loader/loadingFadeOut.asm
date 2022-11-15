
; TIMEPILOT
; simple fade out

;--------------------------------------
;--------------------------------------
                * = $5C00
;--------------------------------------

                jsr loadingFadeOut

                lda #<loadingFadeOut.fakeDlist
                sta 560
                lda #>loadingFadeOut.fakeDlist
                sta 561

                jmp loadingFadeOut.waitF


;======================================
;
;======================================
loadingFadeOut  .proc
                ldy #15
continue        ldx #4
loop            lda 708,x
                and #$f
                beq next

                dec 708,x
next            dex
                bpl loop

                jsr waitF
                jsr waitF
                jsr waitF

                dey
                bne continue

                lda #0
                sta 708
                sta 709
                sta 710
                jmp waitF

waitF           lda 20
                cmp 20
                beq *-2

                rts


;--------------------------------------
;--------------------------------------

fakeDlist       .byte $f0
                .byte $41
                    .word loadingFadeOut.fakeDlist

                .endproc
