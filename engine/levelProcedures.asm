
; TIMEPILOT
; Level Procedures

level           .proc
; init                  - inits level ; X = level number
; mainLoop              - main level loop
; killEnemy             - progress bar
; nextLevelPrepare      - preparation for next level
; nextLevelTeleport     - teleport
; nextLevel             - sets all needed stuff for next level

;======================================
; LEVEL MAIN LOOP
;--------------------------------------
; jump here every gameLoop
;======================================
mainLoop        .proc

                lda playerGameOver
                beq playLevel

; gameover delay -> title screen
                dec playerGameOver
                bne _1

                jmp main

_1              rts

playLevel
; allow spawns counter

                lda levelCurrent.allowSpawnsDelay
                beq _2

                dec levelCurrent.allowSpawnsDelay
                bne _2

                inc levelCurrent.allowSpawns ;  0 -> 1

                lda #0
                sta ntsc_counter

; dli mode for level gameplay | setup once after spawns are allowed
                jsr waitFrameNormal
                jsr clearLevelName

                lda #<bufDLIJumps
                sta DLIDispatch.mode+1
                jsr initPlayfieldPMColors
                jsr showPlayer

_2
; is player alive?
                lda playerDestroyed
                beq playerNotDestroyed

                lda playerDestroyedInit
                bne _3

                inc playerDestroyedInit
                jsr hidePlayer

                lda #configMusicPlayerDestroyed
                jsr sound.soundInit.changeSong

_3              dec playerDestroyedDelay
                bne playerNotDestroyed

                dec levelCurrent.allowSpawns
                lda #255
                sta levelCurrent.allowSpawnsDelay

                dec playerLives
                bne _4

                lda #1
                sta levelCurrent.allowSpawnsDelay

                lda #configGameOverDelay
                sta playerGameOver

; INIT GAME OVER / HIGH SCORE
                jsr waitFrameNormal
                jsr SCORE.findHighScore ; returns line position in X
                beq _noHiScore

                jsr SCORE.highScoreInit ; and we use line poistion here

_noHiScore      lda #0
                sta counterDLI
                sta titleScreen.screenMode

                lda #<bufDLIJumpsGameOver
                sta DLIDispatch.mode+1
                jmp level.showGameOver

_4              jmp level.init.levelReset

playerNotDestroyed
; next level?
                lda levelCurrent.bossKilled
                bne nextLevelLoop

                rts

nextLevelLoop   lda playerDestroyed
                beq _5

                rts                     ; if player is destroyed we do not initiate next level

_5              lda level.nextLevelInited
                bne _6

                jmp level.nextLevelPrepare
_6              jmp level.nextLevelTeleport

                .endproc

; --- END OF level.mainloop


;--------------------------------------
; NEXT LEVEL PREPARE
;--------------------------------------
nextLevelPrepare
                inc nextLevelInited

                lda #0
                sta levelCurrent.allowSpawnsDelay
                sta levelCurrent.allowSpawns
                inc levelCurrent.clearedLevels
                inc levelCurrent.explodeAll

                lda #0
                sta firstRun
                jsr waitFrameNormal

                lda #configMusicTeleport
                jmp sound.soundInit.changeSong

;--------------------------------------

nextLevelInited .byte 0


;--------------------------------------
;    NEXT LEVEL TELEPORT
; X = level number
;--------------------------------------
nextLevelTeleport .proc
                lda RMT.trackn_idx      ; synchronize teleport main animation with RMT subsong
                cmp #101
                bcs _1

                rts

                lda #0
                sta ol.tab.type+olClouds
                sta ol.tab.type+olClouds+1
                sta ol.tab.type+olClouds+2
                sta ol.tab.type+olClouds+3
                sta ol.tab.type+olClouds+4

; clear enemyMissiles
                jsr enemyFire.clear     ; A = 0

                lda #1
                jsr enemyFire.clear

_1              jsr waitFrameNormal     ; teleports starts here
                jsr clearBufScreenSimple

                lda #1
                sta bufScreenNr
                jsr clearBufFontsHidden
                jsr commitBufScreen

                jsr resetPlayerMask

                lda #1
                sta playerframeDraw
                jsr drawPlayer

                lda #0
                sta playerMovementAllow

                lda #$f
                sta DLI0.c3+1

                ldx 3

; fonts for teleport animation
                ldx #0
_2              lda fnt,x
                sta bufFonts0a+$380,x
                sta bufFonts1a+$380,x
                sta bufFonts2a+$380,x
                sta bufFonts3a+$380,x

                inx
                cpx #16*8
                bne _2

; resets draw position
                ldx #0
_3              lda #19
                sta x1,x
                lda #20
                sta x2,x

                inx
                cpx #charCount
                bne _3

                lda #20
                sta x1+7
                lda #19
                sta x2+7

; resets delays
                lda #2
                sta delay
                lda #13
                sta delay+1
                lda #19
                sta delay+2
                lda #22
                sta delay+3
                lda #23
                sta delay+4
                lda #24
                sta delay+5
                lda #25
                sta delay+6
                lda #26
                sta delay+7

teleportLoop    ldx #0
teleportIteration
                lda delay,x
                beq drawIt

                dec delay,x
                jmp next

drawIt          lda x1,x
                tay
                lda ch1,x
                sta bufScreen0+5*40,y
                lda ch2,x
                sta bufScreen0+6*40,y

                lda x2,x
                tay
                lda ch1,x
                sta bufScreen0+5*40,y
                lda ch2,x
                sta bufScreen0+6*40,y

                lda x1,x
                cmp m1,x
                beq _4

                dec x1,x
_4              lda x2,x
                cmp m2,x
                beq next

                inc x2,x

next            inx
                cpx #charCount
                bne teleportIteration

doDelay         dec frameDelay
                beq nextLoop

                jsr waitFrameNormal
                jsr teleportBlink
                jsr drawPlayer

                lda frameDelay
                and #1
                bne _5

                jsr initPlayfieldPMColors
                jmp doDelay

_5              lda #$f
                jsr initPlayfieldPMColorsWhite
                jmp doDelay

nextLoop        lda #configTeleportAnimationDelay
                sta frameDelay

                lda x1+7
                cmp #19                 ; finished last char? do fadeout
                beq teleportFadeOut
                jmp teleportLoop

teleportFadeOut
                lda #0
                sta teleportLineOutX1
                lda #39
                sta teleportLineOutX2
teleportFadeOutLoop1
                lda #0
                sta teleportOutX1
                lda #39
                sta teleportOutX2
teleportFadeOutLoop2
                ldx teleportOutX1
                lda bufScreen0+5*40,x
                beq _6

                cmp #$f0
                beq _6

                dec bufScreen0+5*40,x
_6              lda bufScreen0+6*40,x
                beq _7

                cmp #$f8
                beq _7

                dec bufScreen0+6*40,x
_7              ldx teleportOutX2
                lda bufScreen0+5*40,x
                beq _8

                cmp #$f0
                beq _8

                dec bufScreen0+5*40,x
_8              lda bufScreen0+6*40,x
                beq _9

                cmp #$f8
                beq _9

                dec bufScreen0+6*40,x
_9              lda teleportOutX1
                cmp #19
                beq _10

                inc teleportOutX1
                dec teleportOutX2
                jmp teleportFadeOutLoop2

_10             jsr waitFrameNormal
                jsr teleportBlink
                jsr teleportLineOut
                jsr waitFrameNormal
                jsr teleportLineOut
                jsr teleportBlink

                lda RMT.nt              ; for now | find where is song line number | ;!##TRACE "ns: %d nt: %d" db(RMT.ns) db(RMT.nt)
                cmp #62
                beq _11

                jmp teleportFadeOutLoop1
_11             jmp level.nextLevel

teleportLineOut lda #0
                ldx teleportLineOutX1
                sta bufScreen0+5*40,x
                sta bufScreen0+6*40,x
                ldx teleportLineOutX2
                sta bufScreen0+5*40,x
                sta bufScreen0+6*40,x

                lda teleportLineOutX1
                cmp #19
                beq _12

                inc teleportLineOutX1
                dec teleportLineOutX2
_12             rts

;--------------------------------------

teleportOutX1       .byte 0
teleportOutX2       .byte 0
teleportLineOutX1   .byte 0
teleportLineOutX2   .byte 0

;--------------------------------------

teleportBlink   lda teleportBlinkMode
                eor #1
                sta teleportBlinkMode
                bne _13

                lda #$c
                sta DLI0.c3+1
                jmp blinkEnds

_13             lda #$f
                sta DLI0.c3+1
blinkEnds       rts

;--------------------------------------

charCount       = 8                     ; chars used in animation (per line; 2 lines)
x1                  .byte 19,19,19,19,19,19,19,20
m1                  .byte 0,5,10,14,16,17,18,19
x2                  .byte 20,20,20,20,20,20,20,20
m2                  .byte 39,34,29,25,23,22,21,20
ch1                 .byte $f0,$f1,$f2,$f3,$f4,$f5,$f6,$f7
ch2                 .byte $f8,$f9,$fa,$fb,$fc,$fd,$fe,$ff
delay               .byte 5,20,25,25,26,27,28,29
frameDelay          .byte configTeleportAnimationDelay
teleportDelay       .byte $ff
teleportBlinkMode   .byte 0

fnt             .byte $00,$00,$00,$00,$00,$00,$00,$ff
                .byte $00,$00,$00,$00,$00,$00,$ff,$ff
                .byte $00,$00,$00,$00,$00,$ff,$ff,$ff
                .byte $00,$00,$00,$00,$ff,$ff,$ff,$ff
                .byte $00,$00,$00,$ff,$ff,$ff,$ff,$ff
                .byte $00,$00,$ff,$ff,$ff,$ff,$ff,$ff
                .byte $00,$ff,$ff,$ff,$ff,$ff,$ff,$ff
                .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
                .byte $ff,$00,$00,$00,$00,$00,$00,$00
                .byte $ff,$ff,$00,$00,$00,$00,$00,$00
                .byte $ff,$ff,$ff,$00,$00,$00,$00,$00
                .byte $ff,$ff,$ff,$ff,$00,$00,$00,$00
                .byte $ff,$ff,$ff,$ff,$ff,$00,$00,$00
                .byte $ff,$ff,$ff,$ff,$ff,$ff,$00,$00
                .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$00
                .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
                .endproc


;--------------------------------------
; NEXT LEVEL
;--------------------------------------
; X = level number
;--------------------------------------
nextLevel       .proc
                jsr hidePlayer
                jsr initPlayfieldPMColors

                lda #0
                sta level.nextLevelInited

                lda #configGameMaxDifficulty ; set max difficulty - stage 15+
                sta levelCurrent.difficulty

                ldy levelCurrent.clearedLevels
                cpy #15
                bcs mode

                lda levelInformation.levelDifficulty,y ; or lower difficulty for stages 1-14 | it will reset after 255 stages (a gift;)
                sta levelCurrent.difficulty

mode            lda levelCurrent.swarmMode ; swarm mode higher difficulty
                beq finish

                lda gameCurrentLevel
                cmp #3
                bne _1

                lda #2                  ; swarm mode lvl 4 different (bit slower; only UFO difficulty is fully maxed)
                sta levelCurrent.difficulty
                bne finish

_1              lda levelInformation.levelDifficulty,y
                tax
                inx
                cpx #configGameMaxDifficulty+1
                bcc _2

                ldx #configGameMaxDifficulty
_2              stx levelCurrent.difficulty

finish          inc gameCurrentLevel    ; levels 1-5 then new loop
                lda gameCurrentLevel
                cmp #configGameMaxLevel+1
                bne _3

                lda #1
                sta gameCurrentLevel
_3              jsr waitFrameNormal

                ldx gameCurrentLevel
                jsr level.init
                jmp initPlayfieldPM

                .endproc


;======================================
; INIT LEVEL
;--------------------------------------
; X = level number
;======================================
init            .proc
                dex
                stx levelNumber
                txa
                asl
                asl
                tax

                jsr waitFrameNormal

; progress bar colors
                lda levelInformation.levelBarColor,x
                sta DLI4.c0+1
                sta DLI4b.c0+1
                lda levelInformation.levelBarColor+1,x
                sta DLI4.c1+1
                sta DLI4b.c1+1
                lda levelInformation.levelBarColor+2,x
                sta DLI4.c2+1
                sta DLI4b.c2+1

; playfield colors
                lda levelInformation.levelPlayfieldColor,x
                sta DLI0.c0+1
                lda levelInformation.levelPlayfieldColor+1,x
                sta DLI0.c1+1
                lda levelInformation.levelPlayfieldColor+2,x
                sta DLI0.c2+1
                lda levelInformation.levelPlayfieldColor+3,x
                sta DLI0.c3+1

                ldx levelNumber
                lda levelInformation.levelBackgroundColor,x
                sta DLI0.c4+1

;    progress bar seeder
                ldx levelNumber
                txa
                asl
                tax
                lda levelInformation.levelBarTile,x
                sta barFrom+1
                lda levelInformation.levelBarTile+1,x
                sta barFrom+2

                lda #<bufProgressBar
                sta barTo+1
                lda #>bufProgressBar
                sta barTo+2

                lda #8
                sta counter
startY          ldy #0
startX          ldx #0
barFrom         lda $ffff,x
barTo           sta $ffff,y
                iny
                inx
                cpx #4
                bne barFrom

                ldx #0
                cpy #4*7                ; 7 tiles
                bne startX

                .adw barFrom+1,#4
                .adw barTo+1,#40

_1              dec counter
                bne startY

                ldx levelNumber
                lda levelInformation.levelToKill,x
                sta levelCurrent.tokill

                lda levelInformation.levelEnemyBossHP,x
                sta levelCurrent.enemyBossHP
                lsr
                sta levelCurrent.enemyBossHalfHP

skipPreInit     lda #0
                sta levelCurrent.bossKilled
                sta levelFullyInited

; LVL1-4 and LVL5 differences | enemyShot sound lvl1-4 and lvl5 |  clouds lvl1-4, asteroids lvl5 | X=4 for lvl5
                cpx #4
                bne _2

                jsr prPreinitLvl5       ; asteroids

                lda #SPAWN.enemyShots.soundNumberLvl5
                sta SPAWN.enemyShots.shotSoundNumber+1
                lda #SPAWN.enemyBombs.soundNumberLvl5
                sta SPAWN.enemyBombs.shotSoundNumber+1
                bne shotSoundSetDone

_2              lda firstRun
                bne _3

                cpx #0
                bne _3

                jsr prPreinitLvl1       ; clouds

_3              lda #SPAWN.enemyShots.soundNumber
                sta SPAWN.enemyShots.shotSoundNumber+1
                lda #SPAWN.enemyBombs.soundNumber
                sta SPAWN.enemyBombs.shotSoundNumber+1

shotSoundSetDone
levelReset

; enemy shots on channel0 (during subsongs we move it temporaly to channel1)
                lda #<soundSystem.soundChannelSFX
                sta SPAWN.enemyShots.shotSoundNumber+5
                sta SPAWN.enemyBombs.shotSoundNumber+5

                lda #4                  ; player's starting position (ship flying right = 4)
                sta player.currentFrame

                ldx levelNumber
                lda levelInformation.levelRotationDelayMin,x
                sta levelCurrent.rotationDelayMin
                lda levelInformation.levelAgilityDelay,x
                sta levelCurrent.agilityDelay
                lda levelInformation.levelAgilityMinimum,x
                sta levelCurrent.agilityMinimum
                lda levelInformation.levelAllowSpawnsDelay,x
                sta levelCurrent.allowSpawnsDelay
                lda levelInformation.levelEnemyPeriodicity,x
                sta levelCurrent.enemyPeriodicity
                lda levelInformation.levelEnemyFirePeriodicity,x
                sta levelCurrent.enemyFirePeriodicity
                lda levelInformation.levelSquadronPeriodicity,x
                sta levelCurrent.squadronPeriodicity
                lda levelInformation.levelEnemyBombPeriodicity,x
                sta levelCurrent.enemyBombPeriodicity

                lda #configSquadronSpawnDelay
                sta squadronDelay

; during level reset (but not on first run) we decrease global allowSpawnsDelay
                lda levelFullyInited
                beq _4

                lda #15
                sta levelCurrent.allowSpawnsDelay
_4              cpx #4                  ; (level 5 has different enemyShot shape)
                beq _lvl5

                lda #$ff
                sta enemyFire.mask
                sta enemyFire.mask+1
                sta enemyFire.mask+2
                bne _5

_lvl5           lda #%1011010
                sta enemyFire.mask
                lda #%10100101
                sta enemyFire.mask+1
                lda #%01011010
                sta enemyFire.mask+2

_5              lda #1
                sta playerMovementAllow

                lda #configPlayerShotMaxChain
                sta playerShotChain

                jsr waitFrameNormal
                jsr clearBufFontsHidden

                jsr prPrepareGfxCommonInit

                ldx levelNumber
                inx
                jsr prPrepareGfxCommon  ; enemies 1-5 (X = level number)

                ldx levelNumber
                inx
                jsr prPrepareGfxBoss

                lda #0
                sta frameCounter
                sta OLPCounter
                sta playerShotCounter
                sta enemyCounter
                sta enemyShotCounter
                sta enemyBombCounter
                sta levelCurrent.explodeAll
                sta parachuteDestroyDelay
                sta cloudCounter1
                sta cloudCounter2
                sta cloudCounter3
                sta levelCurrent.allowSpawns
                sta playerDestroyed
                sta playerDestroyedInit
                sta level.nextLevelInited
                jsr enemyFire.hitClear  ; A = 0

                lda #80
                sta playerDestroyedDelay

                lda #configAnimationSwitchDelay
                sta animationSwitchCounter

                lda SPAWN.parachute.spawnDelay
                sta parachuteSpawnDelay

                jsr OLP.init

; clear enemyMissiles
                lda #0
                jsr enemyFire.clear

                lda #1
                jsr enemyFire.clear

                jsr spawn.startingClouds

; DLI for level start
                lda levelFullyInited
                bne skipLevelName

                jsr waitFrameNormal

                lda #0
                sta counterDLI
                lda #<bufDLIJumpsLevelStart
                sta DLIDispatch.mode+1
                jsr level.showLevelName

skipLevelName

; was boss spawned? if so - re-respawn it
                lda levelCurrent.toKill
                bne _6

                lda levelCurrent.bossKilled
                bne _6
                jsr SPAWN.boss

_6              jsr level.showPlayerLives

                lda #1
                sta levelFullyInited

                lda ntsc
                sta ntsc_counter

                jmp showPlayer

; local data for routines
counter         .byte 0
levelNumber     .byte 0

                .endproc

; ---- end of INIT LEVEL ----


;--------------------------------------
; SHOW LEVEL NAME
;--------------------------------------
showlevelName   ;--.proc
                ldx #7
_next1
; A.D.
                lda dataTextFonts+$21*8,x
                sta bufPM0+31,x
                lda dataTextFonts+$e*8,x
                sta bufPM1+31,x
                lda dataTextFonts+$24*8,x
                sta bufPM2+31,x
                lda dataTextFonts+$e*8,x
                sta bufPM3+31,x

                dex
                bpl _next1

; Y E A R
                ldx gameCurrentLevel
                dex
                txa
                asl
                asl
                tax
                lda levelYearL,x
                sta a1+1
                lda levelYearH,x
                sta a1+2
                lda levelYearL+1,x
                sta a2+1
                lda levelYearH+1,x
                sta a2+2
                lda levelYearL+2,x
                sta a3+1
                lda levelYearH+2,x
                sta a3+2
                lda levelYearL+3,x
                sta a4+1
                lda levelYearH+3,x
                sta a4+2

                ldx #7
a1              lda $ffff,x
                sta bufPM0+88,x
a2              lda $ffff,x
                sta bufPM1+88,x
a3              lda $ffff,x
                sta bufPM2+88,x
a4              lda $ffff,x
                sta bufPM3+88,x

                dex
                bpl a1
                rts

;--------------------------------------

levelYearL      .byte <dataTextFonts+$11*8, <dataTextFonts+$19*8, <dataTextFonts+$11*8, <dataTextFonts+$10*8
                .byte <dataTextFonts+$11*8, <dataTextFonts+$19*8, <dataTextFonts+$14*8, <dataTextFonts+$10*8
                .byte <dataTextFonts+$11*8, <dataTextFonts+$19*8, <dataTextFonts+$17*8, <dataTextFonts+$10*8
                .byte <dataTextFonts+$11*8, <dataTextFonts+$19*8, <dataTextFonts+$18*8, <dataTextFonts+$12*8
                .byte <dataTextFonts+$12*8, <dataTextFonts+$10*8, <dataTextFonts+$17*8, <dataTextFonts+$17*8
levelYearH      .byte >dataTextFonts+$11*8, >dataTextFonts+$19*8, >dataTextFonts+$11*8, >dataTextFonts+$10*8
                .byte >dataTextFonts+$11*8, >dataTextFonts+$19*8, >dataTextFonts+$14*8, >dataTextFonts+$10*8
                .byte >dataTextFonts+$11*8, >dataTextFonts+$19*8, >dataTextFonts+$17*8, >dataTextFonts+$10*8
                .byte >dataTextFonts+$11*8, >dataTextFonts+$19*8, >dataTextFonts+$18*8, >dataTextFonts+$12*8
                .byte >dataTextFonts+$12*8, >dataTextFonts+$10*8, >dataTextFonts+$17*8, >dataTextFonts+$17*8
                ;--.endproc

; ---- end of SHOW LEVEL NAME ---- ;


;--------------------------------------
; show GAME OVER
;--------------------------------------
showGameOver    .proc
                ldx #7
_next1          lda dataTextFonts+$27*8,x   ; GAME
                sta bufPM0+31,x
                lda dataTextFonts+$21*8,x
                sta bufPM1+31,x
                lda dataTextFonts+$2d*8,x
                sta bufPM2+31,x
                lda dataTextFonts+$25*8,x
                sta bufPM3+31,x

                lda dataTextFonts+$2f*8,x   ;  OVER
                sta bufPM0+88,x
                lda dataTextFonts+$36*8,x
                sta bufPM1+88,x
                lda dataTextFonts+$25*8,x
                sta bufPM2+88,x
                lda dataTextFonts+$32*8,x
                sta bufPM3+88,x

                dex
                bpl _next1

                rts
                .endproc


;======================================
; CLEAR LEVEL NAME
;======================================
clearLevelName  .proc
                ldx #7
                lda #0
_next1          sta bufPM0+31,x
                sta bufPM1+31,x
                sta bufPM2+31,x
                sta bufPM3+31,x
                sta bufPM0+88,x
                sta bufPM1+88,x
                sta bufPM2+88,x
                sta bufPM3+88,x

                dex
                bpl _next1

                rts
                .endproc


;======================================
; SHOW PLAYER LIVES
; on level reset
;======================================
showPlayerLives .proc
                lda #<bufProgressBar
                sta clear1+1
                lda #>bufProgressBar
                sta clear1+2

                .adw clear1+1,#30

                ldy #7
clrs            ldx #9
clr0            lda #0
clear1          sta $ffff,x
                dex
                bpl clr0

                .adw clear1+1,#40
                dey
                bpl clrs

                ldx playerLives
                cpx #2
                bcs _1

                rts

_1              dex
                dex
                txa
                cmp #4
                bcs max4
                sta lives
                jmp start

max4            lda #4
                sta lives

start           lda #<livesGFX
                sta barFrom+1
                lda #>livesGFX
                sta barFrom+2
                lda #<bufProgressBar
                sta barTo+1
                lda #>bufProgressBar
                sta barTo+2

                .adw barTo+1,#38

                lda lives
                asl
                sta tmp

                .sbw barTo+1,tmp

                lda #8
                sta counter

startY          ldy #0
startX          ldx #0
barFrom         lda $ffff,x
barTo           sta $ffff,y

                iny
                inx
                cpx #2
                bne barFrom

                ldx #0
                cpy #2*1                ; 1 tile
                bne startX

                .adw barFrom+1,#2
                .adw barTo+1,#40

_2              dec counter
                bne startY

                dec lives
                bpl start

                rts

;--------------------------------------

livesGFX        .byte $00,$80,$00,$80,$02,$60,$12,$61,$1a,$69,$2a,$aa,$22,$a2,$10,$81
lives           .byte 0
tmp             .byte 0
counter         .byte 0

                .endproc


;======================================
; KILL ENEMY
;--------------------------------------
; X = enemy number
;======================================
killEnemy       .proc
                lda levelCurrent.tokill
                beq _1

                dec levelCurrent.tokill
                dec levelCurrent.tokill
                bne decreaseProgressBar

                jsr SPAWN.boss          ; all enemy for this level killed - spawn boss
                jmp decreaseProgressBar

_1              rts

decreaseProgressBar
                lda levelCurrent.tokill
                pha
                lsr
                tax
                pla
                and #1
                bne _2
            .for item in range(8)
                .progressBarRight item
            .endfor
_2
            .for item in range(8)
                .progressBarLeft item
            .endfor

progressDone    rts


;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
;
;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
progressBarRight .macro
                lda bufProgressBar+$000+(\1*40),x
                and #%00001111
                sta bufProgressBar+$000+(\1*40),x
                .endmacro


;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
;
;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
progressBarLeft .macro
                lda bufProgressBar+$000+(\1*40),x
                and #%11110000
                sta bufProgressBar+$000+(\1*40),x
                .endmacro

                .endproc

; ---- end of KILL ENEMY ---- ;

                .endproc

levelInformation .block
levelBarTile    .word dataProgressBar1,dataProgressBar2,dataProgressBar3,dataProgressBar4,dataProgressBar5 ; 16x8 graphic tile
levelBarColor   .byte $84,$9a,$fa,0     ; level 1
                .byte $84,$9a,$fa,0     ; level 2
                .byte $84,$9a,$fa,0     ; level 3
                .byte $84,$9a,$fa,0     ; level 4
                .byte $9a,$84,$fa,0     ; level 5

levelPlayfieldColor
                .byte $ea,$24,$d6,$f    ; level 1
                .byte $c8,$c6,$36,$f    ; level 2
                .byte $ea,$34,$8a,$f    ; level 3
                .byte $ff,$84,$8a,$f    ; level 4
                .byte $84,$9c,$ff,$f    ; level 5

levelBackgroundColor
                .byte $80,$84,$94,$42,$0
levelToKill     .byte 56,56,56,56,56    ; 112 progress bar pixels / 2 | 56 default
levelEnemyBossHP
                .byte 14,16,18,20,24

; stock CPU
levelRotationDelayMin
                .byte 7,7,5,5,4         ; minimum delay for rotation (used if rotation is in progress)
levelRotationDelay
                .byte 15,7,7,7,7        ; 'and' mask for rotation delay randomization (we add rnd to levelRotationDelayMin)
levelAllowSpawnsDelay
                .byte 60,60,60,60,60    ; delay before we can spawn anything in level (during that time we see level name)
levelAgilityDelay
                .byte 15,15,7,7,3       ; 'and' mask for agility randomization (delay before init new enemy rotation)
levelAgilityMinimum
                .byte 15,9,7,4,3        ; minimum agility per level
levelEnemyPeriodicity
                .byte 15,7,3,3,1        ; 'and' mask for random (lover mask - better periodicity)
levelSquadronPeriodicity
                .byte 1,1,1,1,1         ; 'and' mask for random (lover mask - better periodicity)
levelEnemyFirePeriodicity
                .byte 31,15,15,7,3      ; 'and' mask for random (lover mask - better periodicity)
levelEnemyBombPeriodicity
                .byte 31,31,15,7,1      ; 'and' mask for random (lover mask - better periodicity)

; rapidus CPU
rapidusLevelRotationDelayMin
                .byte 14,14,10,10,8
rapidusLevelRotationDelay
                .byte 31,15,15,15,15
rapidusLevelAllowSpawnsDelay
                .byte 120,120,120,120,120
rapidusLevelAgilityDelay
                .byte 31,31,15,15,7
rapidusLevelAgilityMinimum
                .byte 30,18,14,8,6
rapidusLevelEnemyPeriodicity
                .byte 31,15,7,7,3
rapidusLevelSquadronPeriodicity
                .byte 3,3,3,3,3
rapidusLevelEnemyFirePeriodicity
                .byte 63,31,31,15,7
rapidusLevelEnemyBombPeriodicity
                .byte 63,63,31,15,3

; secondary (independent) difficulty for lvls 1-5 (stages 1-14); from stage 15 - difficulty is always set to #configGameMaxDifficulty
levelDifficulty .byte 0,0,1,2,3
                .byte 1,2,2,3,3
                .byte 2,2,3,3,3
                .endblock
