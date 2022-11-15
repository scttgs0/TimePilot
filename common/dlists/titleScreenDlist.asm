
;--------------------------------------
;--------------------------------------
                * = dataTitleScreenDlist
;--------------------------------------

                .byte $50,$C7
                    .word bufScreenTxt
                .byte $70,$70
                .byte $45
                    .word bufScreen0+80
                .byte $85,$70,$70
                .byte $70,$70,$70
                .byte $47
                    .word bufScreenTxt+20
                .byte $70,$70,$87
                .byte $70,$70,$70
                .byte $70,$70
                .byte $47
                    .word bufScreenTxt+7*20
                .byte $30,$07
                .byte $41
                    .word dataTitleScreenDlist


;--------------------------------------
;--------------------------------------
                * = dataTitleScreenDlist2
;--------------------------------------

                .byte $50,$C7
                    .word bufScreenTxt
                .byte $70,$70
                .byte $45
                    .word bufScreen0+80
                .byte $85,$70,$70
                .byte $C7
                    .word bufScreenTxt+20
                .byte $70,$20,$87
                .byte $70,$20,$87
                .byte $70,$20,$87
                .byte $70,$20,$87
                .byte $70,$20,$07
                .byte $41
                    .word dataTitleScreenDlist2

fakeDlist       .byte $f0
                .byte $41
                    .word fakeDlist
