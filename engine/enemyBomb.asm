; Enemy fire procedures


enemyBomb       .proc

;======================================
; Y - bomb index (object at OL.tab list)
; A - positive bomb flies rightwards
; A - negative bomb flies leftwards
;======================================
init            .proc
                pha

                lda #$ff
                sta ol.tab.velYH+olCommon,y
                lda #0
                sta ol.tab.velYL+olCommon,y
                sta ol.tab.velXL+olCommon,y

                lda rapidusDetected
                bne rapidus

                pla
                bmi negative

positive        lda #$ff
                sta ol.tab.velXH+olCommon,y
                rts

negative        lda #1
                sta ol.tab.velXH+olCommon,y
                rts

rapidus         lda #$80
                sta ol.tab.velXL+olCommon,y

                pla
                bpl positive

                lda #$0
                sta ol.tab.velXH+olCommon,y
                rts
                .endproc


;======================================
; X - bomb index (object at OL.tab list)
;     included offset to olCommon objects
;======================================
process         .proc
tmp     = zeroPageLocal

                lda gameCurrentLevel
                cmp #5
                bcc lvl1_4

                lda ol.tab.enemyBombDirection,x ; ufo missile acc lvl 5
                bne _1

                clc                     ; ufo missile down
                lda ol.tab.velYL,x
                lda random
auto0           = *+1
                and #31
                adc ol.tab.velYL,x
                sta ol.tab.velYL,x
                lda ol.tab.velYH,x
                adc #0
                sta ol.tab.velYH,x
                rts

_1              sec                     ; ufo missile up
                lda random
auto1           = *+1
                and #15
                sta tmp
                lda ol.tab.velYL,x
                sbc tmp
                sta ol.tab.velYL,x
                lda ol.tab.velYH,x
                sbc #0
                sta ol.tab.velYH,x
                rts

lvl1_4                                  ; bomb acc lvl 1-4
                ; clc !
                lda ol.tab.velYL,x
auto2           = *+1
                adc #32
                sta ol.tab.velYL,x
                bcc _2

                inc ol.tab.velYH,x
_2              rts
                .endproc

                .endproc
