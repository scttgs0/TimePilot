
; HIT
; Hit detection

HIT             .proc

;======================================
; HIT DETECT MAIN LOOP
;--------------------------------------
; jump here every gameLoop
;======================================
mainLoop        .proc
                ldx #(engimeMaxPlayerShots-1)
loopShot        lda ol.tab.type+olPlayerShots,x
                beq nextShot

                lda ol.tab.type+olBoss  ; boss
                beq _1

                jsr hitBoss

_1              ldy #(engineMaxCommon-1) ; common objects
loopObj         lda ol.tab.type+olCommon,y
                cmp #ol.type.enemy
                bne _2

                jsr hitEnemy
                jmp nextObj

_2              cmp #ol.type.bomb
                bne nextObj

                jsr hitBomb

nextObj         dey
                bpl loopObj

nextShot        dex
                bpl loopShot

                rts
                .endproc


;======================================
; In: Y = enemy, X = player shot
;======================================
hitEnemy        .proc
hitboxWidth     = 16
hitboxHeight    = 16

; HITBOX - X
                lda ol.tab.posXH+olCommon,y
                cmp ol.tab.posXH+olPlayerShots,x
                bcs skip

                adc #hitboxWidth        ; C is clear
                cmp ol.tab.posXH+olPlayerShots,x
                bcc skip

; HITBOX - Y
                lda ol.tab.posYH+olCommon,y
                cmp ol.tab.posYH+olPlayerShots,x
                bcs skip

                adc #hitboxHeight       ; C is clear
                cmp ol.tab.posYH+olPlayerShots,x
                bcc skip

; HIT DETECTED
                lda #ol.type.explosion
                sta ol.tab.type+olCommon,y
                dec enemyCounter

                lda #0
                sta ol.tab.animationCounter+olCommon,y
                sta ol.tab.type+olPlayerShots,x
                jsr level.killEnemy
                ; jsr level.killEnemy

                ldx #soundNumber
                ldy #soundNote
                stx soundSystem.soundChannelSFX+3
                sty soundSystem.soundChannelNote+3
                lda #gameEnemyScore
                jmp SCORE.scoreAdd

skip            rts

soundNumber     = 3
soundNote       = 0

                .endproc


;======================================
; In: Y = bomb, X = player shot
;======================================
hitBomb         .proc
hitboxWidth     = 11
hitboxHeight    = 9

; HITBOX - X
                lda ol.tab.posXH+olCommon,y
                sbc #3
                cmp ol.tab.posXH+olPlayerShots,x
                bcs skip

                adc #hitboxWidth        ; C is clear
                cmp ol.tab.posXH+olPlayerShots,x
                bcc skip

; HITBOX - Y
                lda ol.tab.posYH+olCommon,y
                sbc #3
                cmp ol.tab.posYH+olPlayerShots,x
                bcs skip

                adc #hitboxHeight       ; C is clear
                cmp ol.tab.posYH+olPlayerShots,x
                bcc skip

; HIT DETECTED
                lda #ol.type.explosion
                sta ol.tab.type+olCommon,y
                lda ol.tab.posXH+olCommon,y
                sbc #8
                sta ol.tab.posXH+olCommon,y
                lda ol.tab.posYH+olCommon,y
                sbc #8
                sta ol.tab.posYH+olCommon,y

                dec enemyBombCounter
                lda #0
                sta ol.tab.animationCounter+olCommon,y
                sta ol.tab.type+olPlayerShots,x

                ldx #soundNumber
                ldy #soundNote
                stx soundSystem.soundChannelSFX+3
                sty soundSystem.soundChannelNote+3

                lda #gameBombScore
                jmp SCORE.scoreAdd

skip            rts

soundNumber     = 3
soundNote       = 0
                .endproc


;======================================
; In: X = player shot
;======================================
hitBoss         .proc
hitboxWidth     = 32
hitboxHeight    = 16

; HITBOX - X
                lda ol.tab.posXH+olBoss
                cmp ol.tab.posXH+olPlayerShots,x
                bcs skip

                adc #hitboxWidth        ; C is clear
                cmp ol.tab.posXH+olPlayerShots,x
                bcc skip

; HITBOX - Y
                lda ol.tab.posYH+olBoss
                cmp ol.tab.posYH+olPlayerShots,x
                bcs skip

                adc #hitboxHeight       ; C is clear
                cmp ol.tab.posYH+olPlayerShots,x
                bcc skip

; HIT DETECTED
                lda #$80
                sta prPrepareGeneric.bossBlink

                lda #0
                sta ol.tab.type+olPlayerShots,x
                lda #gameBossHitScore
                jsr SCORE.scoreAdd

                dec levelCurrent.enemyBossHP
                bne _1

                lda #1
                sta levelCurrent.bossKilled

                lda #0
                sta ol.tab.type+olBoss
                lda #gameBossScore
                jsr SCORE.scoreAdd

_1              ldx #soundNumber
                ldy #soundNote
                stx soundSystem.soundChannelSFX+3
                sty soundSystem.soundChannelNote+3

skip            rts

soundNumber     = 3     ; or 11
soundNote       = 0
                .endproc


;======================================
; In: X = object number (enemy) in ol.tab list
; Out: A = 0 no collision | A = 1 - collision
; algorithm: Axis-Aligned Bounding Box
;======================================
hitPlayerEnemy  .proc
playerWidth         = 8                 ; hitboxwidth
playerHeight        = 8                 ; hitboxheight
enemyWidth          = 16
enemyHeight         = 16
enemyHitboxWidth    = 12
enemyHitboxHeight   = 12

enemyChangeX        = (enemyWidth-enemyHitboxWidth)/2
enemyChangeY        = (enemyHeight-enemyHitboxHeight)/2

playerX             = prScreenXMin+(prScreenWidth/2)-playerWidth+4
playerY             = prScreenYMin+(prScreenHeight/2)-playerHeight+4
playerX_W           = playerWidth+playerX
playerY_H           = playerHeight+playerY

                clc
                lda ol.tab.posXH,x
                adc #enemyChangeX
                cmp #playerX_W
                bcs noColission

; C is clear
                lda ol.tab.posXH,x
                adc #enemyHitboxWidth
                cmp #playerX
                bcc noColission

                lda ol.tab.posYH,x
                adc #enemyChangeY-1     ;C is set
                cmp #playerY_H
                bcs noColission

; C is clear
                lda ol.tab.posYH,x
                adc #enemyHitboxHeight
                cmp #playerY
                bcc noColission

; colission
                lda #gameEnemyScore
                jsr SCORE.scoreAdd
                lda #1
                rts

noColission     lda #0
                rts
                .endproc


;======================================
; In: X = object number (bomb) in ol.tab list
; Out: A = 0 no collision | A = 1 - collision
; algorithm: Axis-Aligned Bounding Box
;======================================
hitPlayerBomb   .proc
playerWidth         = 8                 ; hitboxwidth
playerHeight        = 8                 ; hitboxheight
bombWidth           = 5
bombHeight          = 3
bombHitboxWidth     = 3
bombHitboxHeight    = 2
bombChangeX         = (bombWidth-bombHitboxWidth)/2
bombChangeY         = (bombHeight-bombHitboxHeight)/2

playerX             = prScreenXMin+(prScreenWidth/2)-playerWidth+4
playerY             = prScreenYMin+(prScreenHeight/2)-playerHeight+4
playerX_W           = playerWidth+playerX
playerY_H           = playerHeight+playerY

                clc
                lda ol.tab.posXH,x
                adc #bombChangeX
                cmp #playerX_W
                bcs noColission

; C is clear
                lda ol.tab.posXH,x
                adc #bombHitboxWidth
                cmp #playerX
                bcc noColission

                lda ol.tab.posYH,x
                adc #+bombChangeY-1     ;C is set
                cmp #playerY_H
                bcs noColission

; C is clear
                lda ol.tab.posYH,x
                adc #bombHitboxHeight
                cmp #playerY
                bcc noColission

; colission
                lda #gameBombScore
                jsr SCORE.scoreAdd

                lda #1
                rts

noColission     lda #0
                rts
                .endproc


;======================================
; Out: A = 0 no collision | A = 1 - collision
; algorithm: Axis-Aligned Bounding Box
;======================================
hitPlayerBoss   .proc
playerWidth         = 8                 ; hitboxwidth
playerHeight        = 8                 ; hitboxheight
enemyWidth          = 32
enemyHeight         = 16
enemyHitboxWidth    = 32
enemyHitboxHeight   = 10
enemyChangeX        = (enemyWidth-enemyHitboxWidth)/2
enemyChangeY        = (enemyHeight-enemyHitboxHeight)/2

playerX             = prScreenXMin+(prScreenWidth/2)-playerWidth+4
playerY             = prScreenYMin+(prScreenHeight/2)-playerHeight+4
playerX_W           = playerWidth+playerX
playerY_H           = playerHeight+playerY

                clc
                lda ol.tab.posXH+olBoss
                adc #enemyChangeX
                cmp #playerX_W
                bcs noColission

; C is clear
                lda ol.tab.posXH+olBoss
                adc #enemyHitboxWidth
                cmp #playerX
                bcc noColission

                clc
                lda ol.tab.posYH+olBoss
                adc #enemyChangeY
                cmp #playerY_H
                bcs noColission

; C is clear
                lda ol.tab.posYH+olBoss
                adc #enemyHitboxHeight
                cmp #playerY
                bcc noColission

; colission
                lda #gameBossScore
                jsr SCORE.scoreAdd

                lda #1
                rts

noColission     lda #0
                rts
                .endproc

                .endproc ; HIT
