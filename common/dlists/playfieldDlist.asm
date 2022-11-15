
;--------------------------------------
;--------------------------------------
                * = dataPlayfieldDlist
;--------------------------------------

                .byte $50,$C7
                    .word bufScreenTxt
                .byte $45

adrBufScreen0   = *+1
                    .word bufScreen0
                .byte $05
                .byte $85,$05,$05
                .byte $85,$05,$05
                .byte $85,$05,$05
                .byte $85,$10
                .byte $4D
                    .word bufProgressBar
                .byte $0D,$0D,$0D
                .byte $0D,$0D,$0D
                .byte $0D
                .byte $41
                    .word dataPlayfieldDlist


;--------------------------------------
;--------------------------------------
                * = dataPlayfieldDlist2        ; titleScreen transition
;--------------------------------------

                .byte $50,$45
                    .word bufScreen0
                .byte $05,$05,$05
                .byte $05,$05,$05
                .byte $05,$05,$05
                .byte $05,$05,$05
                .byte $05,$10
                .byte $41
                    .word dataPlayfieldDlist2
