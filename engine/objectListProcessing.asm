
; OLP
; Object List Processing

OLP             .proc
; init          init OLP system
; mainLoop      processing objects - main loop
; playerShots   process player shots
; enemies       process enemies
; enemyShots    process enemy shots
; enemyBombs    process enemy bombs
; explosions    process explosions
; parachute     process parachute
; cloudSmall    process small clouds
; cloudMedium   process medium clouds
; cloudBig      process big clouds
; boss          process boss

;======================================
; MAIN LOOP - jump here every gameLoop
;--------------------------------------
; processing order matters
;======================================
mainLoop        .proc
                jsr OLP.cloudSmall
                jsr OLP.cloudMedium
                jsr OLP.parachute
                jsr OLP.explosions
                jsr OLP.enemies
                jsr OLP.enemyBombs
                jsr OLP.enemyShots
                jsr OLP.boss
                jsr OLP.cloudBig
                jsr drawPlayer
                jmp OLP.playerShots
                .endproc


;======================================
;     PROCESS: ENEMIES
;======================================
enemies         .proc
                lda enemyCounter
                bne _1

                rts

_1              ldy #prPrepareGenericTypes.enemy
                jsr prPrepareGeneric

                lda #(olCommon+engineMaxCommon-1)
                sta OLPCounter

loop            ldx OLPCounter
                lda ol.tab.type,x
                cmp #ol.type.enemy
                bne nextObject

                ldx OLPCounter
                jsr objectVelocityMovement
                jsr objectGlobalVelocityMovement
                jsr prDrawEnemy

                pha
                ldx OLPCounter
                jsr genericFadeOut
                bne _2

                dec enemyCounter
_2              pla
                cmp #1
                bne noCollision

; colission player -> enemy | hitbox test
                jsr HIT.hitPlayerEnemy
                beq noCollision

                inc playerDestroyed
                ldx OLPCounter
                lda #ol.type.explosion
                sta ol.tab.type,x

                lda #0
                sta ol.tab.animationCounter,x
                jsr SPAWN.playerExplosion

noCollision     jsr enemyRotation

nextObject      dec OLPCounter
                lda OLPCounter
                cmp maxEnemiesOLP
                bne loop

                rts

;--------------------------------------
maxEnemiesOLP   .byte olCommon+engineMaxCommon-1-engineMaxEnemies

                .endproc


;======================================
;     PROCESS: ENEMYSHOTS
;======================================
enemyShots      .proc
                lda enemyShotCounter
                bne _1

                rts

_1              lda #olEnemyShots
                sta OLPCounter

                lda #0
                sta shotNumber+1

loop            ldx OLPCounter
                lda ol.tab.type,x
                beq nextObject

                ldx OLPCounter
                jsr objectVelocityMovement

                lda player.currentFrame
                cmp ol.tab.globalVelocitySpawnFrame,x
                beq _2

                jsr objectGlobalVelocityMovement
                jsr objectCounterGlobalVelocityMovement

_2              lda ol.tab.posXH,x
                sta enemyFire.draw.xPos
                lda ol.tab.posYH,x
                sta enemyFire.draw.yPos

shotNumber      lda #0
                jsr enemyFire.clear
                jsr enemyFire.draw
                bpl hitTest

; out of bound - destroy enemyshot
                lda shotNumber+1
                jsr enemyFire.clear

                dec enemyShotCounter

                ldx OLPCounter
                lda #0
                sta ol.tab.type,x
                beq nextObject

; hit detection
hitTest         jsr enemyFire.hitTest
                bmi nextObject

                lda playerDestroyed     ; if player is destroyed - we ignore hit detection
                bne nextObject

; hit detect
                pha
                jsr enemyFire.hitClear
                jsr enemyFire.clear
                jsr SPAWN.playerExplosion

                pla
                tax
                lda #0
                sta ol.tab.type+olEnemyShots,x ; destroy enemyShot | X = shot number

                inc playerDestroyed

nextObject      inc shotNumber+1

                inc OLPCounter
                lda OLPCounter
                cmp #(engimeMaxEnemyShots+olEnemyShots)
                bne loop

                rts
                .endproc


; -------------------------
;     PROCESS: EXPLOSIONS
; -------------------------
explosions      .proc
                ldy #prPrepareGenericTypes.explosion
                jsr prPrepareGeneric

                lda #olCommon
                sta OLPCounter

loop            ldx OLPCounter
                lda ol.tab.type,x
                cmp #ol.type.explosion
                bne nextObject

                lda ol.tab.animationCounter,x
auto0           nop                     ; lsr if rapidus
                tay
                lda explosionFrame,y
                cmp #$ff
                bne _1

                lda #0                  ; explosion animation ends => destroy the object
                sta ol.tab.type,x
                beq nextObject

_1              lda explosionFrame,y
                sta ol.tab.frame,x

                inc ol.tab.animationCounter,x

                ldx OLPCounter
                jsr objectGlobalVelocityMovement
                jsr prDrawObject

nextObject      inc OLPCounter
                lda OLPCounter
                cmp #(engineMaxCommon+olCommon)
                bne loop

                rts

;--------------------------------------

explosionFrame  .byte 0,0,1,1,2,2,3,3,3,2,2,1,1,0,0,$ff ; real animation frames

                .endproc


; -------------------------
;     PROCESS: ENEMY BOMBS
; -------------------------
enemyBombs      .proc
                lda enemyBombCounter
                bne _1

                rts

_1              ldy #prPrepareGenericTypes.bomb
                jsr prPrepareGeneric

                lda #olCommon
                sta OLPCounter

loop            ldx OLPCounter
                lda ol.tab.type,x
                cmp #ol.type.bomb
                bne nextObject

                lda gameCurrentLevel    ; lvl 5 - ufo missile animation swap (0/1)
                cmp #5
                bne _2

                lda ol.tab.frame,x
                eor #1
                sta ol.tab.frame,x

_2              ldx OLPCounter
                jsr objectGlobalVelocityMovement
                jsr enemyBomb.process   ; calculate new velocity for bomb
                jsr objectVelocityMovement
                jsr prDrawObject

                pha
                ldx OLPCounter
                jsr genericFadeOut
                bne _3

                dec enemyBombCounter

_3              pla
                cmp #1
                bne noCollision

; colission player -> bomb | hitbox test
                jsr HIT.hitPlayerBomb
                beq noCollision

                inc playerDestroyed

                ldx OLPCounter
                lda #ol.type.explosion
                sta ol.tab.type,x

                lda #0
                sta ol.tab.animationCounter,x

                lda ol.tab.posXH+olCommon,x ; center explosion on bomb (the bomb is smaller)
                sbc #8
                sta ol.tab.posXH+olCommon,x

                lda ol.tab.posYH+olCommon,x
                sbc #8
                sta ol.tab.posYH+olCommon,x

                jsr SPAWN.playerExplosion

noCollision
nextObject      inc OLPCounter
                lda OLPCounter
                cmp #(engineMaxCommon+olCommon)
                bne loop

                rts

;--------------------------------------

explosionFrame  .byte 0,0,1,1,2,2,3,3,3,2,2,1,1,0,0,$ff ; real animation frames

                .endproc


;======================================
;     PROCESS: PARACHUTE
;======================================
parachute       .proc
                lda ol.tab.type+olParachute
                beq skip

                ldy #prPrepareGenericTypes.parachute
                jsr prPrepareGeneric

                lda parachuteDestroyDelay
                beq _1

                lda #4
                sta ol.tab.frame+olParachute
                dec parachuteDestroyDelay
                bne movement

                lda #0
                sta ol.tab.type+olParachute

                lda #<soundSystem.soundChannelSFX ; parachute subsong done - move enemy shots sfx to channel0
                sta SPAWN.enemyShots.shotSoundNumber+5
                rts

_1              lda ol.tab.animationCounter+olParachute
auto0           nop                     ; lsr if rapidus
                tay
                lda parachuteFrame,y
                cmp #$ff
                bne _2

                lda #0
                sta ol.tab.animationCounter+olParachute ; loop parachute animation

                tay
_2              lda parachuteFrame,y
                sta ol.tab.frame+olParachute

                inc ol.tab.animationCounter+olParachute

movement        ldx #olParachute
                jsr objectVelocityMovement
                jsr objectGlobalVelocityMovement
                jsr prDrawObject

                pha
                ldx #olParachute
                jsr genericFadeOut
                pla

                cmp #1
                bne skip                ; no colission

; check colission with player
                lda ol.tab.frame+olParachute
                cmp #4
                bcs skip

                lda ol.tab.posXH+olParachute
                cmp #colX1
                bcc skip

                cmp #colX2
                bcs skip

                lda ol.tab.posYH+olParachute
                cmp #colY1
                bcc skip

                cmp #colY2
                bcs skip

                lda playerDestroyed     ; if player is destroyed - we ignore parachute colission
                bne skip

                beq parachuteGrabbed    ; unc

skip            rts

parachuteGrabbed
                lda SPAWN.parachute.destroyDelay
                sta parachuteDestroyDelay

                lda #<soundSystem.soundChannelSFX+1 ; move enemy shots sfx to channel1 until subsong is done
                sta SPAWN.enemyShots.shotSoundNumber+5

                lda #2
                jsr sound.soundInit.changeSong
                jsr fixBossSound

                lda #gameParachuteScore
                jmp SCORE.scoreAdd

;--------------------------------------

parachuteFrame  .byte 0,0,0,0
                .byte 1,1,1,1
                .byte 2,2,2,2
                .byte 3,3,3,3
                .byte 2,2,2,2
                .byte 1,1,1,1
                .byte $ff
soundNumber     = 4
soundNote       = 0
colX1           = prScreenXMin+prScreenWidth/2-16
colX2           = prScreenXMin+prScreenWidth/2+8
colY1           = prScreenYMin+prScreenHeight/2-16
colY2           = prScreenYMin+prScreenHeight/2+8

                .endproc


;======================================
;     PROCESS: PLAYER SHOTS
;======================================
playerShots     .proc
                lda #(olPlayerShots+engimeMaxPlayerShots-1)
                sta OLPCounter

loop            ldx OLPCounter
                lda ol.tab.type,x       ; no object on list - skip
                beq nextObject

                ldx OLPCounter
                jsr objectVelocityMovement
                jsr prDrawPlayerFire

skip            ldx OLPCounter
                jsr genericFadeOut
                ; bne nextObject

nextObject      dec OLPCounter
                bpl loop

                rts
                .endproc    ; objectsPlayerShots


;======================================
;     PROCESS: BOSS
;======================================
boss            .proc
                lda ol.tab.type+olBoss
                beq skip

                ldy #prPrepareGenericTypes.boss
                jsr prPrepareGeneric

                lda levelCurrent.enemyBossHP
                cmp levelCurrent.enemyBossHalfHP
                bcs _1

                lda random
                and #1
                sta ol.tab.frame+olBoss

_1              ldx #olBoss
                jsr objectVelocityMovement
                jsr objectGlobalVelocityMovement
                jsr prDrawObject

                ldx #0
                stx prPrepareGeneric.bossBlink
                cmp #1
                bne noCollision

; colission player -> boss | hitbox test
                jsr HIT.hitPlayerBoss
                beq noCollision

                inc playerDestroyed
                inc levelCurrent.BossKilled
                inc levelCurrent.explodeAll

                lda #0
                sta ol.tab.type+olBoss

noCollision
skip            rts
                .endproc


;======================================
;     PROCESS: SMALL CLOUD
;======================================
cloudSmall      .proc
                lda cloudCounter1
                bne _1

                rts

_1
type            = *+1
                ldy #prPrepareGenericTypes.cloud1
                jsr prPrepareGeneric

                lda #olClouds
                sta OLPCounter

loop            ldx OLPCounter
                lda ol.tab.type,x       ; no object on list - skip
                cmp #ol.type.cloud1
                bne nextObject

                dec ol.tab.movementDelay,x ; small cloud movemenet delay
                bne _2

                lda #2
                sta ol.tab.movementDelay,x
                jsr objectGlobalVelocityMovement

_2              jsr prDrawObject

                ldx OLPCounter
                jsr genericFadeOut
                bne nextObject

                dec cloudCounter1

nextObject      inc OLPCounter
                lda OLPCounter
                cmp SPAWN.maxCloudsSpawnFol
                bne loop

                rts

;--------------------------------------

delay           .byte 0

                .endproc


;======================================
;     PROCESS: MEDIUM CLOUD
;======================================
cloudMedium     .proc
                lda cloudCounter2
                bne _1

                rts

_1
type            = *+1
                ldy #prPrepareGenericTypes.cloud2
                jsr prPrepareGeneric

                lda #olClouds
                sta OLPCounter

loop            ldx OLPCounter
                lda ol.tab.type,x       ; no object on list - skip
                cmp #ol.type.cloud2
                bne nextObject

                ldx OLPCounter
                jsr objectGlobalVelocityMovement
                jsr prDrawObject

                ldx OLPCounter
                jsr genericFadeOut
                bne nextObject

                dec cloudCounter2

nextObject      inc OLPCounter
                lda OLPCounter
                cmp SPAWN.maxCloudsSpawnFol
                bne loop

                rts
                .endproc


;======================================
;     PROCESS: BIG CLOUD
;======================================
cloudBig        .proc
                lda cloudCounter3
                bne _1

                rts

_1
type            = *+1
                ldy #prPrepareGenericTypes.cloud3
                jsr prPrepareGeneric

                lda playerMaskTouched
                beq _2

                jsr resetPlayerMask

                ldx #0
                stx playerMaskTouched
                inx
                stx playerFrameDraw

_2              lda #olClouds
                sta OLPCounter

loop            ldx OLPCounter
                lda ol.tab.type,x       ; no object on list - skip
                cmp #ol.type.cloud3
                bne nextObject

                ldx OLPCounter
                jsr objectGlobalVelocityMovement
                jsr objectGlobalVelocityMovement
                jsr prDrawObject

                ldx OLPCounter
                jsr genericFadeOut
                bne nextObject

                dec cloudCounter3

nextObject      inc OLPCounter
                lda OLPCounter
                cmp SPAWN.maxCloudsSpawnFol
                bne loop

                rts
                .endproc


;======================================
;    INIT - init the OLP system
;======================================
init            .proc
; clear OL tables
                lda #0
                tax

loop            sta ol.base,x
                sta ol.base+$100,x
                sta ol.base+$200,x

                inx
                bne loop

                rts
                .endproc    ; objectListProcessingInit


; *****************************************
; ********   PRIVATE OLP ROUTINES   *******
; *****************************************

;======================================
;    OBJECT VELOCITY MOVEMENT
;--------------------------------------
;    X - object number
;    Y - mode; 0
;======================================
objectVelocityMovement .proc
                clc
                lda ol.tab.posXL,x
                adc ol.tab.velXL,x
                sta ol.tab.posXL,x
                lda ol.tab.posXH,x
                adc ol.tab.velXH,x
                sta ol.tab.posXH,x

                clc
                lda ol.tab.posYL,x
                adc ol.tab.velYL,x
                sta ol.tab.posYL,x
                lda ol.tab.posYH,x
                adc ol.tab.velYH,x
                sta ol.tab.posYH,x
                rts
                .endproc    ; objectVelocityMovement


;======================================
;  OBJECT GLOBAL VELOCITY MOVEMENT
;--------------------------------------
;  adds    player velocity
;  X - object number
;======================================
objectGlobalVelocityMovement .proc
                ldy player.currentFrame
                clc
                lda ol.tab.posXL,x
                adc globalVelocityXL,y
                sta ol.tab.posXL,x
                lda ol.tab.posXH,x
                adc globalVelocityXH,y
                sta ol.tab.posXH,x

                clc
                lda ol.tab.posYL,x
                adc globalVelocityYL,y
                sta ol.tab.posYL,x
                lda ol.tab.posYH,x
                adc globalVelocityYH,y
                sta ol.tab.posYH,x
                rts
                .endproc


;======================================
;
;======================================
objectCounterGlobalVelocityMovement .proc
                lda ol.tab.globalVelocitySpawnFrame,x
                tay

                sec
                lda ol.tab.posXL,x
                sbc globalVelocityXL,y
                sta ol.tab.posXL,x
                lda ol.tab.posXH,x
                sbc globalVelocityXH,y
                sta ol.tab.posXH,x

                sec
                lda ol.tab.posYL,x
                sbc globalVelocityYL,y
                sta ol.tab.posYL,x
                lda ol.tab.posYH,x
                sbc globalVelocityYH,y
                sta ol.tab.posYH,x
                rts
                .endproc

;--------------------------------------
;--------------------------------------

globalVelocityTab                       ; it is copied to globalVelocityXH (...) zeropage buffer
                .char >+$000,>-$40,>-$100,>-$120,>-$120,>-$100,>-$100,>-$080, >+$000,>+$90,>+$f4,>+$120,>+$120,>+$100,>+$100,>+$40
                .char >+$100,>+$100,>+$100,>+$70,>+$000,>-$c0,>-$100,>-$100,  >-$100,>-$100,>-$e4,>-$50,>+$000,>+$b0,>+$100,>+$100
                .char <+$000,<-$40,<-$100,<-$120,<-$120,<-$100,<-$100,<-$080, <+$000,<+$90,<+$f4,<+$120,<+$120,<+$100,<+$100,<+$40
                .char <+$100,<+$100,<+$100,<+$70,<+$000,<-$c0,<-$100,<-$100,  <-$100,<-$100,<-$e4,<-$50,<+$000,<+$b0,<+$100,<+$100

globalVelocityXH = zeropage+$40         ; $10 bytes
globalVelocityYH = zeropage+$50         ; $10 bytes
globalVelocityXL = zeropage+$60         ; $10 bytes
globalVelocityYL = zeropage+$70         ; $10 bytes


;======================================
; GENERIC FADEOUT - used in most cases
;--------------------------------------
; In:
;    X - object number
;    A - #$ff object outOfBounds , lets fadeOut
; Out:
;    A=0 if object destroyed
;    A=1 if not destroyed
;======================================
genericFadeOut  .proc
                cmp #$ff                ; do not use BMI here
                bne _1

                dec ol.tab.fadeOut,x    ; object outOfBounds - lets fadeOut
                bne _1

                lda #0
                sta ol.tab.type,x       ; fade out kicks in - destroy object
                rts

_1              lda #1                  ; object not destroyed
                rts
                .endproc    ; genericFadeOut


;======================================
;  ROTATE OBJECT (16 animation frames)
;--------------------------------------
;  X = object number in ol.tab
;======================================
enemyRotation   .proc
; rotation
                lda ol.tab.frame,x
                cmp ol.tab.rotationTargetFrame,x
                bne rotate

; rotation done - set new target frame for rotation
                dec ol.tab.agilityDelay,x
                bne skipRotation

                lda random
                and levelCurrent.agilityDelay
                adc levelCurrent.agilityMinimum
                sta ol.tab.agilityDelay,x

                lda random
                and #1
                beq _1
                lda #$C8                ;{iny}
                bne dir

_1              lda #$88                ;{dey}
                sta ol.tab.rotationDirection,x

dir             lda random
                and #15
                sta ol.tab.rotationTargetFrame,x
                bmi skipRotation

rotate          dec ol.tab.rotationDelay,x
                bne skipRotation

                lda random
                and levelCurrent.rotationDelay
                adc levelCurrent.rotationDelayMin
                sta ol.tab.rotationDelay,x

                lda ol.tab.rotationDirection,x
                sta direction

                ldy ol.tab.frame,x
direction       iny                     ; iny/dey depends on firection
                tya
                and #15
                sta ol.tab.frame,x

                clc
                ldy levelCurrent.difficulty
                adc SPAWN.enemy.difficultyOffset,y

                tay
                lda SPAWN.enemy.velocityXL,y
                sta ol.tab.velXL,x
                lda SPAWN.enemy.velocityXH,y
                sta ol.tab.velXH,x
                lda SPAWN.enemy.velocityYL,y
                sta ol.tab.velYL,x
                lda SPAWN.enemy.velocityYH,y
                sta ol.tab.velYH,x

skipRotation    rts
                .endproc

                .endproc    ; OLP
