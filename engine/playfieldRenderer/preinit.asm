
cPixelsPerByte  =   4
cPlanesPerObj   =   2                   ;graphics and mask

egGfxDataPtr    .fill 2
egGfxEnemyPtr   .fill 2                 ;pointer to beginning of enemy data

ebTmpGfxObj     =   zeroPageLocal+0     ;object number
ebTmpHeight     =   zeroPageLocal+1
ebTmpWidth      =   zeroPageLocal+2
ebTmpSize       =   zeroPageLocal+3     ;w
ebTmpGfxSrc     =   zeroPageLocal+5     ;w
ebTmpGfxStride  =   zeroPageLocal+7     ;w

ebTmpFree       =   zeroPageLocal+9


;======================================
;
;======================================
prPreinitLvl1   .proc
; OLP will use clouds
                lda #prPrepareGenericTypes.cloud1
                sta OLP.cloudSmall.type
                lda #prPrepareGenericTypes.cloud2
                sta OLP.cloudMedium.type
                lda #prPrepareGenericTypes.cloud3
                sta OLP.cloudBig.type

                jsr prPreinitShared
                jsr prPrepareGfxCloud1
                jsr prPrepareGfxCloud2
                jsr prPrepareGfxCloud3

                ldx #6
                jsr prPrepareGfxCommon  ; explosion

                ldx #7
                jsr prPrepareGfxCommon  ; parachute

                ldx #9
                jsr prPrepareGfxCommon  ; bomb
                jsr resetPlayerMask
                jmp clearBufFontsHidden
                .endproc


;======================================
;
;======================================
prPreinitLvl5   .proc
; OLP will use asteroids
                lda #prPrepareGenericTypes.asteroid1
                sta OLP.cloudSmall.type
                lda #prPrepareGenericTypes.asteroid2
                sta OLP.cloudMedium.type
                lda #prPrepareGenericTypes.asteroid3
                sta OLP.cloudBig.type

                jsr prPreinitShared
                jsr prPrepareGfxAsteroid1
                jsr prPrepareGfxAsteroid2
                jsr prPrepareGfxAsteroid3

                ldx #6
                jsr prPrepareGfxCommon  ; explosion

                ldx #8
                jsr prPrepareGfxCommon  ; cosmomaut

                ldx #10
                jsr prPrepareGfxCommon  ; bomb lvl 5 (missile)
                jsr resetPlayerMask
                jmp clearBufFontsHidden
                .endproc


;======================================
;
;======================================
prPreinitShared .proc
                lda #<egGfxData
                sta egGfxDataPtr
                lda #>egGfxData
                sta egGfxDataPtr+1

                lda #0
                sta egGfxEnemyPtr
                sta egGfxEnemyPtr+1
                sta prGfxNextOff        ;always 0

                ; fall through12
                ; jmp prInitializePreparationTables
                .endproc


;======================================
; preparation of table for mapping
; graphics bits to mask for each two
; bits mask is 11 if graphics is 0
;======================================
prInitializePreparationTables .proc
cnt             = zeroPageLocal
tmp             = zeroPageLocal+1

                ldx #0
loop            lda #4
                sta cnt
                txa
l0              sta tmp
                and #3
                tay
                lda prMaskTempTable,x
                lsr
                lsr
                ora tab,y
                sta prMaskTempTable,x
                lda tmp
                lsr
                lsr
                dec cnt
                bne l0

                inx
                bne loop
                rts

;--------------------------------------

tab             .byte $c0,$00,$00,$00
                .endproc


;======================================
;
;======================================
prPrepareGfxPreamble .proc
                ldx ebTmpGfxObj
                lda egGfxDataPtr
                sta ebGfxScrsL,x
                lda egGfxDataPtr+1
                sta ebGfxScrsH,x
                lda ebTmpHeight
                sta ebGfxMaskO,x
                asl
                sta ebGfxNextO,x
                lda egGfxDataPtr
                clc
                adc ebTmpSize
                sta egGfxDataPtr
                lda egGfxDataPtr+1
                adc ebTmpSize+1
                sta egGfxDataPtr+1
                rts
                .endproc


;======================================
;
;======================================
prPrepareGfxCloud1 .proc
cWidth  = 4
cHeight = 8

                lda #prGfxObj.cloud1
                sta ebTmpGfxObj

                lda #cHeight
                sta ebTmpHeight

                lda #<((cWidth+1)*cHeight*cPixelsPerByte*cPlanesPerObj)
                sta ebTmpSize
                lda #>((cWidth+1)*cHeight*cPixelsPerByte*cPlanesPerObj)
                sta ebTmpSize+1
                jsr prPrepareGfxPreamble

                lda #cWidth
                sta ebTmpWidth
                sta ebTmpGfxStride

                lda #0
                sta ebTmpGfxStride+1

                lda #<dataCloudSmall
                sta ebTmpGfxSrc
                lda #>dataCloudSmall
                sta ebTmpGfxSrc+1
                jmp prPrepareGfxConvert

                .endproc


;======================================
;
;======================================
prPrepareGfxCloud2 .proc
cWidth  = 8
cHeight = 14

                lda #prGfxObj.cloud2
                sta ebTmpGfxObj
                lda #cHeight
                sta ebTmpHeight

                lda #<((cWidth+1)*cHeight*cPixelsPerByte*cPlanesPerObj)
                sta ebTmpSize
                lda #>((cWidth+1)*cHeight*cPixelsPerByte*cPlanesPerObj)
                sta ebTmpSize+1
                jsr prPrepareGfxPreamble

                lda #cWidth
                sta ebTmpWidth
                sta ebTmpGfxStride

                lda #0
                sta ebTmpGfxStride+1

                lda #<(dataCloudMedium+cWidth) ;skipping one empty line
                sta ebTmpGfxSrc
                lda #>(dataCloudMedium+cWidth)
                sta ebTmpGfxSrc+1
                jmp prPrepareGfxConvert

                .endproc


;======================================
;
;======================================
prPrepareGfxCloud3 .proc
cWidth  = 12
cHeight = 15

                lda #prGfxObj.cloud3
                sta ebTmpGfxObj

                lda #cHeight
                sta ebTmpHeight

                lda #<((cWidth+1)*cHeight*cPixelsPerByte*cPlanesPerObj)
                sta ebTmpSize
                lda #>((cWidth+1)*cHeight*cPixelsPerByte*cPlanesPerObj)
                sta ebTmpSize+1
                jsr prPrepareGfxPreamble

                lda #cWidth
                sta ebTmpWidth
                sta ebTmpGfxStride

                lda #0
                sta ebTmpGfxStride+1

                lda #<(dataCloudBig+cWidth) ;skipping one empty line
                sta ebTmpGfxSrc
                lda #>(dataCloudBig+cWidth)
                sta ebTmpGfxSrc+1
                jmp prPrepareGfxConvert

                .endproc


;======================================
; ASTEROIDS
;======================================
prPrepareGfxAsteroid1 .proc
cWidth  = 4
cHeight = 15

;cloud1 is 16x8 pixels
;4 bytes horizontally and 8 bytes vertically

                lda #prGfxObj.cloud1
                sta ebTmpGfxObj

                lda #cHeight
                sta ebTmpHeight

                lda #<((cWidth+1)*cHeight*cPixelsPerByte*cPlanesPerObj)
                sta ebTmpSize
                lda #>((cWidth+1)*cHeight*cPixelsPerByte*cPlanesPerObj)
                sta ebTmpSize+1
                jsr prPrepareGfxPreamble

                lda #cWidth
                sta ebTmpWidth
                sta ebTmpGfxStride

                lda #0
                sta ebTmpGfxStride+1

                lda #<dataAsteroidSmall
                sta ebTmpGfxSrc
                lda #>dataAsteroidSmall
                sta ebTmpGfxSrc+1

                jmp prPrepareGfxConvert

                .endproc


;======================================
;
;======================================
prPrepareGfxAsteroid2 .proc
cWidth  = 8
cHeight = 14

                lda #prGfxObj.cloud2
                sta ebTmpGfxObj

                lda #cHeight
                sta ebTmpHeight

                lda #<((cWidth+1)*cHeight*cPixelsPerByte*cPlanesPerObj)
                sta ebTmpSize
                lda #>((cWidth+1)*cHeight*cPixelsPerByte*cPlanesPerObj)
                sta ebTmpSize+1
                jsr prPrepareGfxPreamble

                lda #cWidth
                sta ebTmpWidth
                sta ebTmpGfxStride

                lda #0
                sta ebTmpGfxStride+1

                lda #<(dataAsteroidMedium+cWidth) ;skipping one empty line
                sta ebTmpGfxSrc
                lda #>(dataAsteroidMedium+cWidth)
                sta ebTmpGfxSrc+1
                jmp prPrepareGfxConvert

                .endproc


;======================================
;
;======================================
prPrepareGfxAsteroid3 .proc
cWidth  = 12
cHeight = 21

                lda #prGfxObj.cloud3
                sta ebTmpGfxObj

                lda #cHeight
                sta ebTmpHeight

                lda #<((cWidth+1)*cHeight*cPixelsPerByte*cPlanesPerObj)
                sta ebTmpSize
                lda #>((cWidth+1)*cHeight*cPixelsPerByte*cPlanesPerObj)
                sta ebTmpSize+1
                jsr prPrepareGfxPreamble

                lda #cWidth
                sta ebTmpWidth
                sta ebTmpGfxStride

                lda #0
                sta ebTmpGfxStride+1

                lda #<dataAsteroidBig
                sta ebTmpGfxSrc
                lda #>dataAsteroidBig
                sta ebTmpGfxSrc+1

;               //fall through
;               jmp prPrepareGfxConvert

                .endproc


;======================================
;
;======================================
prPrepareGfxConvert .proc

dstPtrBase  = ebTmpFree
dstPtr      = ebTmpFree+2
cntY        = ebTmpFree+4
cntX        = ebTmpFree+5
tmpl        = ebTmpFree+6
tmp         = ebTmpFree+7
tmpr        = ebTmpFree+8
cnt         = ebTmpFree+9
dstStride   = ebTmpFree+10
srcPtr      = ebTmpFree+11

                ldx ebTmpGfxObj
                lda ebGfxScrsL,x
                sta dstPtrBase
                lda ebGfxScrsH,x
                sta dstPtrBase+1
                lda ebGfxNextO,x
                sta dstStride
                lda ebTmpHeight
                sta cntY

loopy           lda ebTmpWidth
                sta cntX

                lda ebTmpGfxSrc
                sta srcPtr
                lda ebTmpGfxSrc+1
                sta srcPtr+1

                lda dstPtrBase
                sta dstPtr
                lda dstPtrBase+1
                sta dstPtr+1

                lda #0
                sta tmpr

loopxOuter      lda tmpr
                sta tmpl

                ldy #0
                lda (srcPtr),y
                sta tmp

                lda #4
                sta cnt
loopxInner      lda tmp
                ldy #0
                sta (dstPtr),y
                tax
                lda prMaskTempTable,x
                ldy ebTmpHeight
                sta (dstPtr),y          ;mask is by 'height' further than gfx
                lda tmpl
                lsr
                ror tmp
                ror tmpr
                lsr
                ror tmp
                ror tmpr
                sta tmpl
                lda dstPtr
                clc
                adc dstStride
                sta dstPtr
                bcc _1

                inc dstPtr+1
_1              dec cnt
                bne loopxInner

                inc srcPtr
                bne _2

                inc srcPtr+1
_2              dec cntX
                bmi _3
                bne loopxOuter

                lda tmpr
                sta tmpl
                lda #0
                sta tmp
                lda #4
                sta cnt
                bne loopxInner

_3              inc dstPtrBase
                bne _4

                inc dstPtrBase+1
_4              lda ebTmpGfxSrc
                clc
                adc ebTmpGfxStride
                sta ebTmpGfxSrc
                lda ebTmpGfxSrc+1
                adc ebTmpGfxStride+1
                sta ebTmpGfxSrc+1
                dec cntY
                beq +                   ;jne loopy

                jmp loopy

+               rts
                .endproc


;======================================
;
;======================================
prPrepareGfxCommonInit .proc
                lda egGfxEnemyPtr+1
                beq _firstTime
                lda egGfxEnemyPtr
                sta egGfxDataPtr
                lda egGfxEnemyPtr+1
                sta egGfxDataPtr+1
                bne _1
_firstTime      lda egGfxDataPtr
                sta egGfxEnemyPtr
                lda egGfxDataPtr+1
                sta egGfxEnemyPtr+1
_1              rts
                .endproc


;======================================
; prepares animations graphics | common objects (sizes: 8, 16)
; X = object animation number
; 1-5 enemies | 6 explosion | 7 parachute | 8 astronaut | 9 bomb
;======================================
prPrepareGfxCommon .proc
                dex
                txa
                pha

                jsr prInitializePreparationTables

                pla
                tax

                sta animationNumber
                lda animationFrames,x   ; how many animation frames for this object
                sta aniFrames+1
                lda animationL,x
                sta autoL+2
                lda animationH,x
                sta autoH+1
                lda #0
                sta frame

loop            ldy animationNumber
                lda animationObj,y
                clc
                adc frame
                sta ebTmpGfxObj
                lda height,y
                sta ebTmpHeight
                lda sizeL,y
                sta ebTmpSize
                lda sizeH,y
                sta ebTmpSize+1
                jsr prPrepareGfxPreamble ; y is not used there

                lda width,y
                sta ebTmpWidth
                ldy animationNumber
                lda cStrideL,y
                sta ebTmpGfxStride
                lda cStrideH,y
                sta ebTmpGfxStride+1
                lda frame               ; frame * width (width: 16)
                asl                     ; *2    (width:8)
                cpy #8                  ; bomb
                beq autoL

                cpy #9                  ; ufo missile
                beq autoL

                asl                     ; *4    (width: 16)
autoL           clc
                adc #<dataEnemyLevel1   ; code-modified value
                sta ebTmpGfxSrc
autoH           lda #>dataEnemyLevel1   ; code-modified value
                sta ebTmpGfxSrc+1
                jsr prPrepareGfxConvert

                inc frame
                lda frame
aniFrames       cmp #16                 ; code-modified value (different per object)
                bcc loop
                rts

;-------------------------------------

; 1-5 enemies | 6 explosion | 7 parachute |  8 cosmonaut | 9 bomb | 10 ufo missile
animationL      .byte <dataEnemyLevel1,<dataEnemyLevel2,<dataEnemyLevel3,<dataEnemyLevel4,<dataEnemyLevel5
                .byte <dataEnemyExplosion,<dataParachute,<dataCosmonaut,<dataEnemyBomb,<dataEnemyBombLvl5
animationH      .byte >dataEnemyLevel1,>dataEnemyLevel2,>dataEnemyLevel3,>dataEnemyLevel4,>dataEnemyLevel5
                .byte >dataEnemyExplosion,>dataParachute,>dataCosmonaut,>dataEnemyBomb,>dataEnemyBombLvl5
animationObj    .byte prGfxObj.enemy,prGfxObj.enemy,prGfxObj.enemy,prGfxObj.enemy,prGfxObj.enemy
                .byte prGfxObj.explosion,prGfxObj.parachute,prGfxObj.parachute,prGfxObj.bomb,prGfxObj.bomb
animationFrames .byte 16, 16, 9, 16, 2, 4, 5, 5, 2, 2                        ; animation frames
cStrideL        .byte <4*16, <4*16, <4*9, <4*16, <4*2, <4*4, <4*5, <4*5, <2*2, <2*2         ; chars x animationFrames
cStrideH        .byte >4*16, >4*16, >4*9, >4*16, >4*2, >4*4, >4*5, >4*5, >2*2, >2*2         ; chars x animationFrames
width           .byte 4, 4, 4, 4, 4, 4, 4, 4, 2, 2                           ; animation width in chars (*cPixelsPerByte = in pixels)
height          .byte 16, 16, 16, 16, 16, 16, 16, 16, 8, 8                   ; animation height in pixels
animationNumber .byte 0                 ; local temp
frame           .byte 0                 ; local temp

                ; <((cWidth+1)*cHeight*cPixelsPerByte*cPlanesPerObj)
                ; >((cWidth+1)*cHeight*cPixelsPerByte*cPlanesPerObj)
sizeL           .byte <5*16*cPixelsPerByte*cPlanesPerObj,<5*16*cPixelsPerByte*cPlanesPerObj
                .byte <5*16*cPixelsPerByte*cPlanesPerObj,<5*16*cPixelsPerByte*cPlanesPerObj
                .byte <5*16*cPixelsPerByte*cPlanesPerObj,<5*16*cPixelsPerByte*cPlanesPerObj
                .byte <5*16*cPixelsPerByte*cPlanesPerObj,<5*16*cPixelsPerByte*cPlanesPerObj
                .byte <3*8*cPixelsPerByte*cPlanesPerObj,<3*8*cPixelsPerByte*cPlanesPerObj
sizeH           .byte >5*16*cPixelsPerByte*cPlanesPerObj,>5*16*cPixelsPerByte*cPlanesPerObj
                .byte >5*16*cPixelsPerByte*cPlanesPerObj,>5*16*cPixelsPerByte*cPlanesPerObj
                .byte >5*16*cPixelsPerByte*cPlanesPerObj,>5*16*cPixelsPerByte*cPlanesPerObj
                .byte >5*16*cPixelsPerByte*cPlanesPerObj,>5*16*cPixelsPerByte*cPlanesPerObj
                .byte >3*8*cPixelsPerByte*cPlanesPerObj,>3*8*cPixelsPerByte*cPlanesPerObj

                .endproc


;======================================
; OBJECTS 32x16
;--------------------------------------
; X = boss number (1-5)
;======================================
prPrepareGfxBoss .proc
cWidth  = 8
cHeight = 16

                dex
                txa
                pha

                jsr prInitializePreparationTables

                pla
                tax
                sta animationNumber
                lda animationFrames,x   ; how many animation frames for this level
                sta aniFrames+1
                lda animationL,x
                sta autoL+1
                lda animationH,x
                sta autoH+1
                lda #0
                sta frame

loop            ldy animationNumber
                lda animationObj,y
                clc
                adc frame
                sta ebTmpGfxObj
                lda #cHeight
                sta ebTmpHeight
                lda #<((cWidth+1)*cHeight*cPixelsPerByte*cPlanesPerObj)
                sta ebTmpSize
                lda #>((cWidth+1)*cHeight*cPixelsPerByte*cPlanesPerObj)
                sta ebTmpSize+1
                jsr prPrepareGfxPreamble

                lda #cWidth
                sta ebTmpWidth
                ldy animationNumber
                lda cStrideL,y
                sta ebTmpGfxStride
                lda cStrideH,y
                sta ebTmpGfxStride+1
                lda frame
                asl                     ; determines animation stride
                asl
                asl

autoL           adc #<dataEnemyBoss1
                sta ebTmpGfxSrc
autoH           lda #>dataEnemyBoss1
                sta ebTmpGfxSrc+1
                jsr prPrepareGfxConvert

                ldx frame
                inx
                stx frame
aniFrames       cpx #16
                bcc loop
                rts

;--------------------------------------

frame           .byte 0
animationL      .byte <dataEnemyBoss1, <dataEnemyBoss2, <dataEnemyBoss3, <dataEnemyBoss4, <dataEnemyBoss5
animationH      .byte >dataEnemyBoss1, >dataEnemyBoss2, >dataEnemyBoss3, >dataEnemyBoss4, >dataEnemyBoss5
animationObj    .byte prGfxObj.boss,   prGfxObj.boss,   prGfxObj.boss,   prGfxObj.boss,   prGfxObj.boss
animationFrames .byte 2, 2, 2, 2, 2                     ; animation frames (boss 1-5)
cStrideL        .byte <8*2, <8*2, <8*2, <8*2, <8*2      ; 4 chars x animationFrames
cStrideH        .byte >8*2, >8*2, >8*2, >8*2, >8*2      ; 4 chars x animationFrames
animationNumber .byte 0                ; local temp

                .endproc
