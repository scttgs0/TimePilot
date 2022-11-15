
;    TIMEPILOT
;    SPAWN SYSTEM
;     spawns: shots, enemies, squadrons, missiles, bombs, clouds, parachute, boss

SPAWN           .proc
; mainLoop          spawn system - main loop
; playerShot        spawns player shots
; enemy             spawns enemies/squadrons
; enemyShots        spawns enemy shots
; enemyBombs        spawns enemy bombs
; cloudSmall        spawns small clouds/asteroids
; cloudMedium       spawns medium clouds/asteroids
; cloudBig          spawns big clouds/asteroids
; parachute         spawns parachute
; startingClouds    spawns starting clouds
; boss              spawns Boss
; explodeAll        sets all objects on screen to be exploded


;======================================
;
;======================================
mainLoop        .proc
                jsr SPAWN.cloudBig
                jsr SPAWN.cloudSmall
                jsr SPAWN.cloudMedium

; are we allowed to spawn common objects?
                lda levelCurrent.allowSpawns
                beq _1

                jsr SPAWN.parachute
                jsr SPAWN.enemy

                jsr SPAWN.enemyShots
                jsr SPAWN.enemyBombs

_1              lda levelCurrent.explodeAll
                bne SPAWN.explodeAll
                rts
                .endproc


;--------------------------------------
; EXPLODE ALL
; next lvl/player died
;--------------------------------------
explodeAll      .proc
                ldx #(engineMaxCommon-1)

explode         lda ol.tab.type+olCommon,x ; set explosion only to active objects
                beq _1

                lda #ol.type.explosion
                sta ol.tab.type+olCommon,x

                lda #0
                sta ol.tab.animationCounter+olCommon,x
_1              dex
                bpl explode

                lda #ol.type.explosion  ; a boss explodes on 2 objects in olCommons sublist
                sta ol.tab.type+olCommon+1
                sta ol.tab.type+olCommon+2
                lda ol.tab.posXH+olBoss
                sta ol.tab.posXH+olCommon+1
                lda ol.tab.posYH+olBoss
                sta ol.tab.posYH+olCommon+1
                sta ol.tab.posYH+olCommon+2

                clc
                lda ol.tab.posXH+olBoss
                adc #16
                sta ol.tab.posXH+olCommon+2


                lda #0                  ; destroy parachute, enemy shots
                sta ol.tab.type+olParachute
                sta ol.tab.type+olEnemyShots
                sta ol.tab.type+olEnemyShots+1

                jsr enemyFire.clear     ; A = 0

                lda #1
                jsr enemyFire.clear

                dec levelCurrent.explodeAll
                rts
                .endproc


;======================================
;    PLAYER EXPLOSION
;======================================
playerExplosion .proc
; spawn as first element of object lists
                ldx #olCommon
                lda #ol.type.explosion
                sta ol.tab.type,x

                lda #0
                sta ol.tab.animationCounter,x

                lda #120
                sta ol.tab.posXH,x
                lda #120
                sta ol.tab.posYH,x
                rts
                .endproc


;======================================
;    SPAWN: CLOUD SMALL
;======================================
cloudSmall      .proc
                lda cloudCounter1
                cmp maxCloud1
                bcs skip

                lda random
                and #7
                bne skip

                ldx maxCloudsSpawn      ; search for free space in ol.table.clouds
_search         lda ol.tab.type+olClouds,x
                beq _1

                dex
                bpl _search

                rts                     ; cannot spawn

_1
                ; clc !
                inc cloudCounter1
                lda random
                and #3
                adc player.currentFrame

                tay
                lda #ol.type.cloud1
                sta ol.tab.type+olClouds,x

fill            lda spawnPositionCloudBig.X,y ; starting position
                sta ol.tab.posXH+olClouds,x
                lda spawnPositionCloudBig.Y,y
                sta ol.tab.posYH+olClouds,x

                lda #fadeOut
                sta ol.tab.fadeOut+olClouds,x
skip            rts

fadeOut     = 16
                .endproc


;======================================
;    SPAWN: CLOUD MEDIUM
;======================================
cloudMedium     .proc
                lda cloudCounter2
                cmp maxCloud2
                bcs _skip

                lda random
                and #7
                bne _skip

                ldx maxCloudsSpawn      ; search for free space in ol.table.clouds
_search         lda ol.tab.type+olClouds,x
                beq _1

                dex
                bpl _search

_skip           rts                     ; cannot spawn

_1
; C is clear
                ; clc
                inc cloudCounter2
                lda random
                and #3
                adc player.currentFrame

                tay
                lda #ol.type.cloud2
                sta ol.tab.type+olClouds,x
                bne cloudSmall.fill     ;!

fadeOut     = 16
                .endproc


;======================================
;    SPAWN: CLOUD BIG
;======================================
cloudBig        .proc
                lda cloudCounter3
                cmp maxCloud3
                bcs _skip

                lda random
                and #7
                bne _skip

                ldx maxCloudsSpawn      ; search for free space in ol.table.clouds
_search         lda ol.tab.type+olClouds,x
                beq _1

                dex
                bpl _search

_skip           rts                     ; cannot spawn

_1
                ;clc !
                inc cloudCounter3
                lda random
                and #3
                adc player.currentFrame

                tay
                lda #ol.type.cloud3
                sta ol.tab.type+olClouds,x
                bne cloudSmall.fill     ;!

fadeOut     = 16
                .endproc


;======================================
;    SPAWN: ENEMY
;======================================
enemy           .proc
                lda enemyCounter
                cmp maxEnemies          ; max enemies spawned?
                bcs lrts

spawn           lda random              ; enemy periodicity for current level/difficulty
                and levelCurrent.enemyPeriodicity
                beq doSpawn

lrts            rts

doSpawn         lda gameCurrentLevel    ; lvl 5 - no squadrons for UFO
                cmp #5
                beq singleEnemy

                lda squadronDelay       ; checks for squadron: delay and periodicity
                beq _1

                dec squadronDelay
                bne singleEnemy

_1              lda random
                and levelCurrent.squadronPeriodicity
                bne singleEnemy

                lda enemyCounter
                cmp maxEnemiesSquadron  ; we need min. 3 free slots in enemy list to spawn squadron | maxEnemies-2
                bcs singleEnemy

                lda #configSquadronSpawnDelay ; squadron initialization
                sta squadronDelay

                lda player.currentFrame ; lets find squadron starting direction
                adc #2                  ; c is clear
                and #$f
                lsr
                lsr
                sta squadronSide

                tax
                lda squadronPosition.squadronDataL,x
                sta squadronAddr
                lda squadronPosition.squadronDataH,x
                sta squadronAddr+1

                lda #$EA                ;{nop}                  ; default direction
                sta squadronPosition.direction

                lda random
                sta squadronShake       ; global position shake for squadron

                and #1
                sta squadronAlt         ; 0 = alternative direction | >0 = normal direction
                bne _2

                lda #$C8                ;{iny}                  ; alternative direction
                sta squadronPosition.direction

_2              lda #$e
                jsr sound.soundInit.changeSong
                jsr fixBossSound

                lda #2
                sta spawnCounter
                sta spawnType
                bne spawnUnit

singleEnemy     lda #0                  ; single enemy
                sta spawnType
                sta spawnCounter

spawnUnit       ldx #(engineMaxCommon-1)
_search         lda ol.tab.type+olCommon,x
                beq _3

                dex
                bpl _search

                rts                     ; cannot spawn (no room in ol.tab)

_3              inc enemyCounter

                lda spawnType
                bne _4
                beq singleUnit          ; single unit

_4              jsr squadronPosition    ; squadron unit | returns (in A) unit starting frame
                jsr skipUnitPosition

                dec spawnCounter
                bpl spawnUnit
skip            rts

; X - free object in ol.tab list
singleUnit      clc
                lda random
                and #7
                adc player.currentFrame

                tay
                lda spawnPositionEnemy.X,y
                sta ol.tab.posXH+olCommon,x
                lda spawnPositionEnemy.Y,y
                sta ol.tab.posYH+olCommon,x

                lda random
                and levelCurrent.rotationDelay
                adc levelCurrent.rotationDelayMin
                asl                     ; starting rotation delay higher
                asl
                sta ol.tab.rotationDelay+olCommon,x

                lda random              ; enemy starting frame
                and #3
                adc player.currentFrame
                adc #6
                and #$f

skipUnitPosition                        ; A = unit starting frame
                sta ol.tab.frame+olCommon,x
                ldy levelCurrent.difficulty
                adc difficultyOffset,y

                tay
                lda velocityXL,y
                sta ol.tab.velXL+olCommon,x
                lda velocityXH,y
                sta ol.tab.velXH+olCommon,x
                lda velocityYL,y
                sta ol.tab.velYL+olCommon,x
                lda velocityYH,y
                sta ol.tab.velYH+olCommon,x

                lda random
                and levelCurrent.agilityDelay
                adc levelCurrent.agilityMinimum
                sta ol.tab.agilityDelay+olCommon,x

                lda #ol.type.enemy
                sta ol.tab.type+olCommon,x
                lda fadeOut
                sta ol.tab.fadeOut+olCommon,x

                lda random
                and #1
                beq _5
                lda #$C8                ;{iny}
                bne direction

_5              lda #$88                ;{dey}
direction       sta ol.tab.rotationDirection+olCommon,x
                sta ol.tab.enemyShotIsAllowed+olCommon,x
                sta ol.tab.enemyBombIsAllowed+olCommon,x

                lda random
                and #15
                sta ol.tab.rotationTargetFrame+olCommon,x
                rts

;--------------------------------------

maxEnemies          .byte engineMaxEnemies
maxEnemiesSquadron  .byte engineMaxEnemies-2


;======================================
; set position of squadron unit
; IN: X = object number in ol.tab
; OUT: A = unit starting frame (important!)
;======================================
squadronPosition .proc
                lda squadronRotationDelay
                sta ol.tab.rotationDelay+olCommon,x

                lda spawnCounter
                asl
                asl
                tay

                lda (squadronAddr),y
                sta ol.tab.posXH+olCommon,x ; X pos
                iny
                lda (squadronAddr),y
                sta ol.tab.posYH+olCommon,x ; Y pos

                lda squadronAlt         ; no position shake if alternative direction (4 corners)
                beq direction

                lda squadronSide
                and #1
                bne _1

                lda squadronShake       ; shakeX
                and #127
                adc ol.tab.posXH+olCommon,x
                sta ol.tab.posXH+olCommon,x

_1              lda squadronSide
                and #1
                beq _2
                lda squadronShake       ; shakeY
                and #63
                adc ol.tab.posYH+olCommon,x
                sta ol.tab.posYH+olCommon,x

_2
direction       nop                     ; automodified byte:  nop or iny (nop = default direction; iny = alternative direction)
                iny
                lda (squadronAddr),y    ; unit starting frame
                rts

;--------------------------------------

squadronRotationDelay   .byte configSquadronRotationDelay
squadronDataL           .byte <squadronTop, <squadronRight, <squadronBottom, <squadronLeft
squadronDataH           .byte >squadronTop, >squadronRight, >squadronBottom, >squadronLeft

; squadron spawn data for each screen quarter before randomization | x, y, starting frame, alternative direction starting frame
squadronXOffset     = 8
squadronYOffset     = 8
unitWidth           = 16
unitHeight          = 16
squadronXDistance   = 15
squadronYDistance   = 15

squadronTop     .byte prScreenXMin+squadronXOffset-squadronXDistance, prScreenYMin-squadronYDistance-unitWidth, 8, 6
                .byte prScreenXMin+squadronXOffset, prScreenYMin-unitWidth, 8, 6
                .byte prScreenXMin+squadronXOffset+squadronXDistance, prScreenYMin-squadronYDistance-unitWidth, 8, 6

squadronRight   .byte prScreenXMax+squadronXDistance, prScreenYMin+squadronYOffset-squadronYDistance, 12, 10
                .byte prScreenXMax, prScreenYMin+squadronYOffset, 12, 10
                .byte prScreenXMax+squadronXDistance, prScreenYMin+squadronYOffset+squadronYDistance, 12, 10

squadronBottom  .byte prScreenXMin+squadronXOffset-squadronXDistance, prScreenYMax+squadronYDistance, 0, 2
                .byte prScreenXMin+squadronXOffset, prScreenYMax, 0, 2
                .byte prScreenXMin+squadronXOffset+squadronXDistance, prScreenYMax+squadronYDistance, 0, 2

squadronLeft    .byte prScreenXMin-squadronXDistance-unitWidth, prScreenYMin+squadronYOffset-squadronYDistance, 4, 5
                .byte prScreenXMin-unitWidth, prScreenYMin+squadronYOffset, 4, 5
                .byte prScreenXMin-squadronXDistance-unitWidth, prScreenYMin+squadronYOffset+squadronYDistance, 4, 5

                .endproc


difficulty1     = 700
difficulty2     = 1100
difficulty3     = 1400
difficulty4     = 1800

difficultyOffset .byte 0,16,32,48

velocityXH      .char >+$000*difficulty1/1000,>+$90*difficulty1/1000,>+$f4*difficulty1/1000,>+$120*difficulty1/1000,>+$120*difficulty1/1000,>+$100*difficulty1/1000,>+$100*difficulty1/1000,>+$40*difficulty1/1000,>+$000*difficulty1/1000,>-$40*difficulty1/1000,>-$100*difficulty1/1000,>-$120*difficulty1/1000,>-$120*difficulty1/1000,>-$100*difficulty1/1000,>-$100*difficulty1/1000,>-$080*difficulty1/1000
                .char >+$000*difficulty2/1000,>+$90*difficulty2/1000,>+$f4*difficulty2/1000,>+$120*difficulty2/1000,>+$120*difficulty2/1000,>+$100*difficulty2/1000,>+$100*difficulty2/1000,>+$40*difficulty2/1000,>+$000*difficulty2/1000,>-$40*difficulty2/1000,>-$100*difficulty2/1000,>-$120*difficulty2/1000,>-$120*difficulty2/1000,>-$100*difficulty2/1000,>-$100*difficulty2/1000,>-$080*difficulty2/1000
                .char >+$000*difficulty3/1000,>+$90*difficulty3/1000,>+$f4*difficulty3/1000,>+$120*difficulty3/1000,>+$120*difficulty3/1000,>+$100*difficulty3/1000,>+$100*difficulty3/1000,>+$40*difficulty3/1000,>+$000*difficulty3/1000,>-$40*difficulty3/1000,>-$100*difficulty3/1000,>-$120*difficulty3/1000,>-$120*difficulty3/1000,>-$100*difficulty3/1000,>-$100*difficulty3/1000,>-$080*difficulty3/1000
                .char >+$000*difficulty4/1000,>+$90*difficulty4/1000,>+$f4*difficulty4/1000,>+$120*difficulty4/1000,>+$120*difficulty4/1000,>+$100*difficulty4/1000,>+$100*difficulty4/1000,>+$40*difficulty4/1000,>+$000*difficulty4/1000,>-$40*difficulty4/1000,>-$100*difficulty4/1000,>-$120*difficulty4/1000,>-$120*difficulty4/1000,>-$100*difficulty4/1000,>-$100*difficulty4/1000,>-$080*difficulty4/1000
velocityYH      .char >-$100*difficulty1/1000,>-$100*difficulty1/1000,>-$e4*difficulty1/1000,>-$50*difficulty1/1000,>+$000*difficulty1/1000,>+$b0*difficulty1/1000,>+$100*difficulty1/1000,>+$100*difficulty1/1000,>+$100*difficulty1/1000,>+$100*difficulty1/1000,>+$100*difficulty1/1000,>+$70*difficulty1/1000,>+$000*difficulty1/1000,>-$c0*difficulty1/1000,>-$100*difficulty1/1000,>-$100*difficulty1/1000
                .char >-$100*difficulty2/1000,>-$100*difficulty2/1000,>-$e4*difficulty2/1000,>-$50*difficulty2/1000,>+$000*difficulty2/1000,>+$b0*difficulty2/1000,>+$100*difficulty2/1000,>+$100*difficulty2/1000,>+$100*difficulty2/1000,>+$100*difficulty2/1000,>+$100*difficulty2/1000,>+$70*difficulty2/1000,>+$000*difficulty2/1000,>-$c0*difficulty2/1000,>-$100*difficulty2/1000,>-$100*difficulty2/1000
                .char >-$100*difficulty3/1000,>-$100*difficulty3/1000,>-$e4*difficulty3/1000,>-$50*difficulty3/1000,>+$000*difficulty3/1000,>+$b0*difficulty3/1000,>+$100*difficulty3/1000,>+$100*difficulty3/1000,>+$100*difficulty3/1000,>+$100*difficulty3/1000,>+$100*difficulty3/1000,>+$70*difficulty3/1000,>+$000*difficulty3/1000,>-$c0*difficulty3/1000,>-$100*difficulty3/1000,>-$100*difficulty3/1000
                .char >-$100*difficulty4/1000,>-$100*difficulty4/1000,>-$e4*difficulty4/1000,>-$50*difficulty4/1000,>+$000*difficulty4/1000,>+$b0*difficulty4/1000,>+$100*difficulty4/1000,>+$100*difficulty4/1000,>+$100*difficulty4/1000,>+$100*difficulty4/1000,>+$100*difficulty4/1000,>+$70*difficulty4/1000,>+$000*difficulty4/1000,>-$c0*difficulty4/1000,>-$100*difficulty4/1000,>-$100*difficulty4/1000

velocityXL      .char <+$000*difficulty1/1000,<+$90*difficulty1/1000,<+$f4*difficulty1/1000,<+$120*difficulty1/1000,<+$120*difficulty1/1000,<+$100*difficulty1/1000,<+$100*difficulty1/1000,<+$40*difficulty1/1000,<+$000*difficulty1/1000,<-($40*difficulty1/1000),<-($100*difficulty1/1000),<-($120*difficulty1/1000),<-($120*difficulty1/1000),<-($100*difficulty1/1000),<-($100*difficulty1/1000),<-($080*difficulty1/1000)
                .char <+$000*difficulty2/1000,<+$90*difficulty2/1000,<+$f4*difficulty2/1000,<+$120*difficulty2/1000,<+$120*difficulty2/1000,<+$100*difficulty2/1000,<+$100*difficulty2/1000,<+$40*difficulty2/1000,<+$000*difficulty2/1000,<-($40*difficulty2/1000),<-($100*difficulty2/1000),<-($120*difficulty2/1000),<-($120*difficulty2/1000),<-($100*difficulty2/1000),<-($100*difficulty2/1000),<-($080*difficulty2/1000)
                .char <+$000*difficulty3/1000,<+$90*difficulty3/1000,<+$f4*difficulty3/1000,<+$120*difficulty3/1000,<+$120*difficulty3/1000,<+$100*difficulty3/1000,<+$100*difficulty3/1000,<+$40*difficulty3/1000,<+$000*difficulty3/1000,<-($40*difficulty3/1000),<-($100*difficulty3/1000),<-($120*difficulty3/1000),<-($120*difficulty3/1000),<-($100*difficulty3/1000),<-($100*difficulty3/1000),<-($080*difficulty3/1000)
                .char <+$000*difficulty4/1000,<+$90*difficulty4/1000,<+$f4*difficulty4/1000,<+$120*difficulty4/1000,<+$120*difficulty4/1000,<+$100*difficulty4/1000,<+$100*difficulty4/1000,<+$40*difficulty4/1000,<+$000*difficulty4/1000,<-($40*difficulty4/1000),<-($100*difficulty4/1000),<-($120*difficulty4/1000),<-($120*difficulty4/1000),<-($100*difficulty4/1000),<-($100*difficulty4/1000),<-($080*difficulty4/1000)
velocityYL      .char <-($100*difficulty1/1000),<-($100*difficulty1/1000),<-($e4*difficulty1/1000),<-($50*difficulty1/1000),<+$000*difficulty1/1000,<+$b0*difficulty1/1000,<+$100*difficulty1/1000,<+$100*difficulty1/1000,<+$100*difficulty1/1000,<+$100*difficulty1/1000,<+$100*difficulty1/1000,<+$70*difficulty1/1000,<+$000*difficulty1/1000,<-($c0*difficulty1/1000),<-($100*difficulty1/1000),<-($100*difficulty1/1000)
                .char <-($100*difficulty2/1000),<-($100*difficulty2/1000),<-($e4*difficulty2/1000),<-($50*difficulty2/1000),<+$000*difficulty2/1000,<+$b0*difficulty2/1000,<+$100*difficulty2/1000,<+$100*difficulty2/1000,<+$100*difficulty2/1000,<+$100*difficulty2/1000,<+$100*difficulty2/1000,<+$70*difficulty2/1000,<+$000*difficulty2/1000,<-($c0*difficulty2/1000),<-($100*difficulty2/1000),<-($100*difficulty2/1000)
                .char <-($100*difficulty3/1000),<-($100*difficulty3/1000),<-($e4*difficulty3/1000),<-($50*difficulty3/1000),<+$000*difficulty3/1000,<+$b0*difficulty3/1000,<+$100*difficulty3/1000,<+$100*difficulty3/1000,<+$100*difficulty3/1000,<+$100*difficulty3/1000,<+$100*difficulty3/1000,<+$70*difficulty3/1000,<+$000*difficulty3/1000,<-($c0*difficulty3/1000),<-($100*difficulty3/1000),<-($100*difficulty3/1000)
                .char <-($100*difficulty4/1000),<-($100*difficulty4/1000),<-($e4*difficulty4/1000),<-($50*difficulty4/1000),<+$000*difficulty4/1000,<+$b0*difficulty4/1000,<+$100*difficulty4/1000,<+$100*difficulty4/1000,<+$100*difficulty4/1000,<+$100*difficulty4/1000,<+$100*difficulty4/1000,<+$70*difficulty4/1000,<+$000*difficulty4/1000,<-($c0*difficulty4/1000),<-($100*difficulty4/1000),<-($100*difficulty4/1000)

fadeOut         .byte 16

                .endproc ; enemy


;======================================
;    SPAWN: ENEMYSHOTS
;======================================
enemyShots      .proc
                nop                     ; nop - normal mode | rts - swarm mode
                lda enemyShotCounter
                cmp #engimeMaxEnemyShots ; max shots spawned?
                bcs lrts

spawn           lda random
                and levelCurrent.enemyFirePeriodicity
                bne lrts

                lda #(engineMaxCommon-1)
                sta OLPCounter

searchEnemy     ldx OLPCounter
                lda ol.tab.type+olCommon,x ; search for enemy plane on ol list
                cmp #ol.type.enemy
                bne _1

                lda ol.tab.enemyShotIsAllowed+olCommon,x ; can enemy shot?
                beq _1

                lda ol.tab.posXH+olCommon,x
                sta enemyFire.velocity.xPos
                lda ol.tab.posYH+olCommon,x
                sta enemyFire.velocity.yPos
                jsr enemyFire.velocity
                beq _1                  ; cant spawn enemyshot (enemy is too close to the player)
                bne doSpawn

_1              dec OLPCounter
                bpl searchEnemy

lrts            rts

doSpawn         ldx OLPCounter
                ldy #(engimeMaxEnemyShots-1)
searchShot      lda ol.tab.type+olEnemyShots,y
                beq _2

                dey
                bpl searchShot

_2
; enemy just shot - out of ammo;) [enemy can shot once per spawn]
; A = 0
                sta ol.tab.enemyShotIsAllowed+olCommon,x

                lda #ol.type.fire_e
                sta ol.tab.type+olEnemyShots,y

; enemy fire starts from center of the enemy
                clc
                lda ol.tab.posXH+olCommon,x
                adc #7
                sta ol.tab.posXH+olEnemyShots,y
                lda ol.tab.posYH+olCommon,x
                adc #7
                sta ol.tab.posYH+olEnemyShots,y

                lda enemyFire.velocity.xVel
                sta ol.tab.velXL+olEnemyShots,y
                lda enemyFire.velocity.xVel+1
                sta ol.tab.velXH+olEnemyShots,y

                lda enemyFire.velocity.yVel
                sta ol.tab.velYL+olEnemyShots,y
                lda enemyFire.velocity.yVel+1
                sta ol.tab.velYH+olEnemyShots,y

; enemyshot velocity *2
                clc
                lda ol.tab.velXL+olEnemyShots,y
                adc ol.tab.velXL+olEnemyShots,y
                sta ol.tab.velXL+olEnemyShots,y
                lda ol.tab.velXH+olEnemyShots,y
                adc ol.tab.velXH+olEnemyShots,y
                sta ol.tab.velXH+olEnemyShots,y

                clc
                lda ol.tab.velYL+olEnemyShots,y
                adc ol.tab.velYL+olEnemyShots,y
                sta ol.tab.velYL+olEnemyShots,y
                lda ol.tab.velYH+olEnemyShots,y
                adc ol.tab.velYH+olEnemyShots,y
                sta ol.tab.velYH+olEnemyShots,y

                lda player.currentFrame
                sta ol.tab.globalVelocitySpawnFrame+olEnemyShots,y

                inc enemyShotCounter

shotSoundNumber ldx #soundNumber        ; autocode modifications here | do not change instructions order | engine changes soundNumber and channel0/1
                ldy #soundNote
                stx soundSystem.soundChannelSFX+1
                sty soundSystem.soundChannelNote+1
                rts

;--------------------------------------

soundNumber     = $c
soundNumberLvl5 = $1                  ; or $17
soundNote       = 0

                .endproc


;======================================
;    SPAWN: ENEMY BOMBS
;======================================
enemyBombs      .proc
                nop                     ; nop - normal mode | rts - swarm mode
                lda enemyBombCounter    ; max bombs spawned?
                cmp #engimeMaxEnemyBombs
                bcs lrts

spawn           lda random
                and levelCurrent.enemyBombPeriodicity
                bne lrts

                lda #(engineMaxCommon-1) ; search spawned enemy list
                sta OLPCounter
searchEnemy     ldx OLPCounter
                lda ol.tab.type+olCommon,x ; search for enemy plane
                cmp #ol.type.enemy
                bne nextSearch

                lda ol.tab.enemyBombIsAllowed+olCommon,x ; can enemy use bombs?
                beq nextSearch

                lda ol.tab.posXH+olCommon,x
                sta enemyFire.velocity.xPos
                lda ol.tab.posYH+olCommon,x
                sta enemyFire.velocity.yPos
                jsr enemyFire.velocity
                beq nextSearch          ; cant spawn enemy bomb (enemy is too close to the player)
                bne doSpawn

nextSearch      dec OLPCounter
                bpl searchEnemy

lrts            rts

doSpawn         ldy #(engineMaxCommon-1) ; search for free spot in object list
_search         lda ol.tab.type+olCommon,y
                beq spawnBomb

                dey
                bpl _search

                rts                     ; cannot spawn (no room in ol.tab)

spawnBomb       ldx OLPCounter
                sta ol.tab.enemyBombIsAllowed+olCommon,x ; A=0

                lda #ol.type.bomb
                sta ol.tab.type+olCommon,y

                clc
                lda ol.tab.posXH+olCommon,x

                pha
                adc #7
                sta ol.tab.posXH+olCommon,y
                lda ol.tab.posYH+olCommon,x
                adc #7
                sta ol.tab.posYH+olCommon,y
                pla

                cmp #prScreenXMin+(prScreenWidth/2) ; bomb direction: left or right
                bcc _2

                lda #1
                bne side

_2              lda #0
side            sta ol.tab.frame+olCommon,y ; frame 0 or 1 (left/right)
                sbc #1                  ; positive = left | negative = right | #frame-1 = 0 or $ff
                jsr enemyBomb.init      ; init bomb velicity and acceleration

                lda #fadeOut
                sta ol.tab.fadeOut+olCommon,y
                inc enemyBombCounter

                lda #0                  ; bomb direction lvl1-4: down | lvl5: up or down | default: up
                sta ol.tab.enemyBombDirection+olCommon,y

                lda gameCurrentLevel
                cmp #5
                bne shotSoundNumber

                lda ol.tab.posYH+olCommon,x
                cmp #prScreenYMin+(prScreenHeight/2)
                bcc shotSoundNumber

                lda #1
                sta ol.tab.enemyBombDirection+olCommon,y ; ufo missile direction up

shotSoundNumber ldx #soundNumber        ; autocode modifications here | do not change instructions order | engine changes soundNumber and channel0/1
                ldy #soundNote
                stx soundSystem.soundChannelSFX+1
                sty soundSystem.soundChannelNote+1
                rts

;--------------------------------------

soundNumber     = $a
soundNumberLvl5 = $4
soundNote       = 0

fadeOut         = 3
tmp             .byte 0

                .endproc


;======================================
;    SPAWN: PARACHUTE
;======================================
parachute       .proc
                lda ol.tab.type+olParachute
                bne skip2

                lda parachuteSpawnDelay
                bne skip

                lda random
auto0           = *+1
                and #63
                bne skip2

; lets spawn parachute
                lda spawnDelay
                sta parachuteSpawnDelay

                lda #ol.type.parachute
                sta ol.tab.type+olParachute
                lda random
                and #127
                adc #startX
                sta ol.tab.posXH+olParachute
                lda #startY
                sta ol.tab.posYH+olParachute
                lda #fadeOut
                sta ol.tab.fadeOut+olParachute

                lda #0
                sta ol.tab.velYH+olParachute
                lda velocityYL
                sta ol.tab.velYL+olParachute
                rts

skip            dec parachuteSpawnDelay
skip2           rts

;--------------------------------------

startX          = prScreenXMin
startY          = prScreenYMin-16
fadeOut         = 24
velocityYL      .byte 64
destroyDelay    .byte 48
spawnDelay      .byte 64

                .endproc


;======================================
;    SPAWN: BOSS
; one time per level; called in levelMainLoop
;======================================
boss            .proc
                lda #ol.type.boss
                sta ol.tab.type+olBoss
                lda #0
                sta ol.tab.frame+olBoss

                lda random
                and #63
                adc #startY
                sta ol.tab.posYH+olBoss
                lda #startY
                sta ol.tab.posYH+olBoss

                lda velocityXH
                sta ol.tab.velXH+olBoss
                lda velocityXL
                sta ol.tab.velXL+olBoss

                ldy gameCurrentLevel
                dey
                ldx soundNumber,y
                ldy #soundNote
                stx soundSystem.soundChannelSFX+2
                sty soundSystem.soundChannelNote+2
                rts

skip            dec parachuteSpawnDelay
skip2           rts

;--------------------------------------

soundNumber     .byte $d,$d,$13,$d,$14  ; lvl1,2,4 $d | lvl3: $13 | lvl5: $14
soundNote       = 0
startX          = prScreenXMax
startY          = prScreenYMin+16     ; not used - boss starting X position is "0" on virutal screen and will start to decrease
velocityXH      .char >-$100/2
velocityXL      .char <-$100/2

                .endproc


; ----------------------
;    SPAWN: PLAYER SHOT
; ----------------------
playerShot      .proc
                inc playerShotCounter
                lda playerShotCounter
                and #$7
                sta playerShotCounter
                tax

                ldy player.currentFrame

                lda #ol.type.fire_p     ; type
                sta ol.tab.type,x

                lda #0
                sta ol.tab.posXL,x
                sta ol.tab.posYL,x

                lda shotStartingX,y     ; starting position
                sta ol.tab.posXH,x
                lda shotStartingY,y
                sta ol.tab.posYH,x

                lda velocityXL,y        ; velocity
                sta ol.tab.velXL,x
                lda velocityXH,y
                sta ol.tab.velXH,x
                lda velocityYL,y
                sta ol.tab.velYL,x
                lda velocityYH,y
                sta ol.tab.velYH,x

                lda #fadeOut
                sta ol.tab.fadeOut,x

                ldx #soundNumber
                ldy #soundNote
                stx soundSystem.soundChannelSFX+1
                sty soundSystem.soundChannelNote+1
                rts

;--------------------------------------

shotCounter     .byte 0
                   ;       0       1         2        3        4        5        6         7        8        9        10       11       12       13       14       15
shotStartingX      .byte 127,     132,     135,     136,     135,     135,     132,     129,     128,     124,     122,     121,     120,     121,     122,     127 ; starting X/Y position of player shot (for each player rotation frame 0-15)
shotStartingY      .byte 120,     121,     124,     126,     128,     132,     134,     134,     135,     134,     132,     129,     128,     126,     123,     120 ; starting X/Y position of player shot (for each player rotation frame 0-15)
velocityXH      .char >+$000,  >+$1a0,  >+$380,  >+$3b4,  >+$380,  >+$340,  >+$200,  >+$100,  >+$000,  >-$280,  >-$340,  >-$340,  >-$300,  >-$340,  >-$340,  >-$080 ; velocity | base max speedX: 3-3.5
velocityYH      .char >-$300,  >-$300,  >-$200,  >-$100,  >+$000,  >+$204,  >+$340,  >+$300,  >+$300,  >+$320,  >+$240,  >+$03c,  >+$000,  >-$1b8,  >-$220,  >-$300 ; velocity | base max speedY: 3-3.5
velocityXL      .char <+$000,  <+$1a0,  <+$380,  <+$3b4,  <+$380,  <+$340,  <+$200,  <+$100,  <+$000,  <-$280,  <-$340,  <-$340,  <-$300,  <-$340,  <-$340,  <-$080
velocityYL      .char <-$300,  <-$300,  <-$200,  <-$100,  <+$000,  <+$204,  <+$340,  <+$300,  <+$300,  <+$320,  <+$240,  <+$03c,  <+$000,  <-$1b8,  <-$220,  <-$300
fadeOut         = 1
soundNumber     = 2
soundNote       = 0
                .endproc  ; spawnPlayerShot


; -------------------------
;    SPAWNS INITIAL CLOUDS
; -------------------------
startingClouds  .proc
                ldx #0
loop            lda random
                and #127
                adc #prScreenXMin
                adc #16
                sta ol.tab.posXH+olClouds,x
                txa
                asl
                asl
                asl
                asl
                sta tmp
                lda random
                and #15
                adc #prScreenYMin
                adc tmp
                sta ol.tab.posYH+olClouds,x

                lda delay,x
                sta ol.tab.movementDelay+olClouds,x
                lda clouds,x
                sta ol.tab.type+olClouds,x

; increase cloud counters
                tay
                txa
                pha
                dey
                tya
                tax
                inc cloudCounter1,x
                pla
                tax

                lda #fadeOut
                sta ol.tab.fadeOut+olClouds,x

                inx
                cpx maxCloudsSpawnF
                bne loop
                rts

;--------------------------------------

tmp             .byte 0
clouds          .byte ol.type.cloud1,ol.type.cloud3,ol.type.cloud2,ol.type.cloud1,ol.type.cloud2,ol.type.cloud3,ol.type.cloud2,ol.type.cloud1,ol.type.cloud1
delay           .byte 2,0,0,2,0,0,0,2,2
fadeOut         = 16

                .endproc


; SPAWN POSITION TABLES | depends on player ship direction
sX              = prScreenXMin
sY              = prScreenYMin
eX              = prScreenXMax
eY              = prScreenYMax
dX              = prScreenWidth/4
dY              = prScreenHeight/4

spawnPositionEnemy .block
    cWidth      = 16
    cHeight     = 16
    hWidth      = cWidth/2
    hHeight     = cHeight/2
    X       .byte sX-cWidth,sX-hWidth, sX+dX*1-cWidth ; 13,14,15
    ;                        0               1                2            3             4          5              6               7                  8                   9               10               11                   12                 13          14           15
            .byte sX+dX*2-cWidth,     sX+dX*3-cWidth,     eX-cWidth,   eX+cWidth,eX,eX, eX-cWidth,  sX+dX*3-cWidth, sX+dX*2-cWidth, sX+dX*1-cWidth,sX-cWidth,       sX-cWidth,        sX-cWidth,       sX-cWidth,           sX-hWidth,      sX+dX*1-cWidth
            .byte sX+dX*2-cWidth,     sX+dX*3-cWidth,     eX-cWidth,   eX+cWidth ; 0,1,2,3

    Y       .byte sY+dY*1-cHeight,sY-cHeight, sY-cHeight ; 13,14,15
    ;                        0               1                2            3                 4                 5                   6               7         8             9        10               11                   12                  13                 14           15
            .byte sY-cHeight,sY-cHeight,     sY-cHeight,      sY+dY*1-cHeight,               sY+dY*2-cHeight,  sY+dY*3-cHeight,    eY+cHeight,     eY,       eY,           eY,      eY-cHeight,      sY+dY*3-cHeight,     sY+dY*2-cHeight,    sY+dY*1-cHeight,   sY-cHeight,  sY-cHeight
            .byte sY-cHeight,sY-cHeight,     sY-cHeight,      sY+dY*1-cHeight ; 0,1,2,3
                .endblock

spawnPositionCloudBig .block
    cWidth  = 48
    cHeight = 16
    hWidth  = cWidth/2
    hHeight = cHeight/2
    X       .byte sX-hWidth, sX+dX*1-hWidth   ; 14,15
    ;                       0               1          2      3      4     5       6          7          8            9               10          11                    12                13                 14           15
            .byte sX+dX*2-hWidth,    sX+dX*3-hWidth,  eX,    eX,    eX,   eX,     eX,     sX+dX*3,    sX+dX*2,     sX+dX*1,      sX-cWidth,    sX-cWidth,           sX-cWidth,         sX-cWidth,        sX-hWidth,  sX+dX*1-hWidth
            .byte sX+dX*2-hWidth,    sX+dX*3-hWidth ; 0,1
    Y       .byte sY-cHeight,      sY-cHeight ; 14,15
    ;                       0               1                2            3                 4                 5                   6               7          8         9           10               11                   12                  13                 14           15
            .byte sY-cHeight,      sY-cHeight,         sY-hHeight,  sY+dY*1-cHeight,  sY+dY*2-cHeight, sY+dY*3-cHeight,      eY-hHeight,         eY,        eY,       eY,       eY-cHeight,  sY+dY*3-cHeight,    sY+dY*2-cHeight,    sY+dY*1-cHeight,      sY-cHeight,   sY-cHeight
            .byte sY-cHeight,      sY-cHeight      ; 0,1
                .endblock

spawnPositionCloudSmall .block
    cWidth      = 16
    cHeight     = 8
                .endblock

spawnPositionCloudMedium .block
    cWidth      = 32
    cHeight     = 16
                .endblock

maxCloudsSpawnF     .byte engineMaxCloudsSpawnF
maxCloudsSpawnFol   .byte engineMaxCloudsSpawnF+olClouds
maxCloudsSpawn      .byte engineMaxCloudsSpawn-1
maxCloud1           .byte engineMaxCloud1
maxCloud2           .byte engineMaxCloud2
maxCloud3           .byte engineMaxCloud3
globalSpawnDelay    .byte configGlobalSpawnDelay
                .endproc    ; SPAWN
