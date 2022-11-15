
; Enemy fire procedures

enemyFire       .proc

;======================================
;
;======================================
velocity        .proc
xMax    = prScreenWidth / 2 / 8
yMax    = prScreenHeight / 2 / 8

;in
;position in virtual dimensions 0-255
xPos    = zeroPageLocal+0     ;modified after return
yPos    = zeroPageLocal+1

;out
;Z=1 if no value returned
;computed velocities 0-255 with high bytes equal 0 or 255 depending on sign
xVel    = zeroPageLocal+2
yVel    = zeroPageLocal+4

                lda xPos
                sec
                sbc #128
                bmi leftSide

                lsr
                lsr
                lsr
                cmp #xMax

                bcc +                   ;jcs exit0

                jmp exit0
+               sta xPos

                lda yPos
                sec
                sbc #128
                bmi rightUpperSide

rightLowerSide  lsr
                lsr
                lsr
                cmp #yMax
                bcc +                   ;jcs exit0

                jmp exit0

+               tax
                lda mul10,x
;c i clear
                adc xPos
                tax
                lda #$ff
                sta xVel+1
                sta yVel+1

                lda #0
                sec
                sbc xVelTab,x
                sta xVel
                lda #0
                sec
                sbc yVelTab,x
                sta yVel
                rts

rightUpperSide  lda #128
                sec
                sbc yPos
                lsr
                lsr
                lsr
                cmp #yMax
                bcs exit0

                tax
                lda mul10,x
;c i clear
                adc xPos
                tax
                lda #$ff
                sta xVel+1
                lda #0
                sta yVel+1

                sec
                sbc xVelTab,x
                sta xVel
                lda yVelTab,x
                sta yVel
                rts

leftSide        lda #128
                sec
                sbc xPos
                lsr
                lsr
                lsr
                cmp #xMax
                bcs exit0

                sta xPos

                lda yPos
                sec
                sbc #128
                bmi leftUpperSide

leftLowerSide   lsr
                lsr
                lsr
                cmp #yMax
                bcs exit0

                tax
                lda mul10,x
;c i clear
                adc xPos
                tax
                lda xVelTab,x
                sta xVel
                lda #$ff
                sta yVel+1
                lda #0
                sta xVel+1
                sec
                sbc yVelTab,x
                sta yVel
                rts

leftUpperSide   lda #128
                sec
                sbc yPos
                lsr
                lsr
                lsr
                cmp #yMax
                bcc cont

exit0           lda #0
                rts

cont            tax
                lda mul10,x
;c i clear
                adc xPos
                tax
                lda #0
                sta xVel+1
                sta yVel+1
                lda xVelTab,x
                sta xVel
                lda yVelTab,x
                sta yVel
                rts

;--------------------------------------

m       = 800                           ; velocity multiplier m/1000 (example 800/1000 = 0.8) | max is 1000 (multiplier=1.0)

xVelTab         .byte 0,0,0,0,0,0,253*m/1000,254*m/1000,254*m/1000,255*m/1000
                .byte 0,0,0,0,0,0,246*m/1000,248*m/1000,250*m/1000,251*m/1000
                .byte 0,0,0,0,0,229*m/1000,235*m/1000,240*m/1000,243*m/1000,245*m/1000
                .byte 0,0,0,181*m/1000,200*m/1000,213*m/1000,222*m/1000,229*m/1000,234*m/1000,238*m/1000
                .byte 0,0,132*m/1000,160*m/1000,181*m/1000,197*m/1000,208*m/1000,217*m/1000,224*m/1000,229*m/1000
                .byte 0,81*m/1000,114*m/1000,142*m/1000,164*m/1000,181*m/1000,194*m/1000,205*m/1000,213*m/1000,220*m/1000

yVelTab         .byte 0,0,0,0,0,0,36*m/1000,32*m/1000,28*m/1000,25*m/1000
                .byte 0,0,0,0,0,0,70*m/1000,62*m/1000,56*m/1000,50*m/1000
                .byte 0,0,0,0,0,114*m/1000,101*m/1000,90*m/1000,81*m/1000,74*m/1000
                .byte 0,0,0,181*m/1000,160*m/1000,142*m/1000,127*m/1000,114*m/1000,104*m/1000,95*m/1000
                .byte 0,0,220*m/1000,200*m/1000,181*m/1000,164*m/1000,149*m/1000,136*m/1000,124*m/1000,114*m/1000
                .byte 0,243*m/1000,229*m/1000,213*m/1000,197*m/1000,181*m/1000,167*m/1000,154*m/1000,142*m/1000,132*m/1000

mul10           .byte 0,10,20,30,40,50

                .endproc


;======================================
;
;======================================
hitClear        .proc
                sta hitclr
                rts
                .endproc


;======================================
; returns which missile hit the player
; return -1 for none
;======================================
hitTest         .proc
                lda kolm0p
                beq _1

_m0             lda #0
                rts

_1              lda kolm1p
                bne _m0

                lda kolm2p
                beq _2

_m1             lda #1
                rts

_2              lda kolm3p
                bne _m1

                lda #$ff
                rts
                .endproc


;======================================
;in
;A - 0 or 1 for missle number
;
;out
;A - 0 or 2 for missle number
;======================================
clear           .proc
                asl
                tax
;x is 0 or 2

;clear old position
                ldy ycache,x
                lda bufM+0,y
                and clearmask,x
                sta bufM+0,y
                lda bufM+1,y
                and clearmask,x
                sta bufM+1,y
                rts
                .endproc


;======================================
;in
;position in virtual dimensions 0-255
;A - 0 or 2 for missle number
;out
;A=-1 if out of bounds
;======================================
draw            .proc
xPos    = zeroPageLocal+0
yPos    = zeroPageLocal+1
temp    = zeroPageLocal+0

                lda xPos
                cmp #prScreenXMin
                bcc _exit

                cmp #prScreenXMax
                bcs _exit

                lda yPos
                cmp #prScreenYMin
                bcc _exit

                cmp #prScreenYMax-2
                bcc _1

_exit           lda #$ff
                rts

_1              sec
                sbc #64
                sta ycache,x
                tay

                lda xPos
                sta hposm0,x
                sta hposm1,x

                lda clearmask,x
                sta temp
                eor #$ff
                sta temp+1

                lda state,x
                eor #1
                sta state,x
                tax

                lda bufM+0,y
                and temp
                sta temp+2

                lda bufM+1,y
                and temp
                sta temp+3

                lda mask,x
                and temp+1
                ora temp+2
                sta bufM+0,y
                lda mask+1,x
                and temp+1
                ora temp+3
                sta bufM+1,y

                lda #0
                rts
                .endproc

;--------------------------------------
;--------------------------------------

mask            .byte $ff,$ff,$ff                           ; lvl 1-4
                ; .byte %1011010,%10100101,%01011010        ; lvl 5

;clearmask/clearmask1, ycache/ycache1, clearmask1/clearmask2, state/state1 are ingexed by index 0 or 2
clearmask       .byte %11110000
ycache          .byte 0
clearmask1      .byte %00001111
ycache1         .byte 0
clearmask2      .byte %11110000
state           .byte 0
ignored         .byte 0
state1          .byte 0
                .endproc
