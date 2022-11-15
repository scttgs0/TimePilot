
;    TIMEPILOT
;    GAME INIT

gameInit        .proc
; gameInit.settings                     - default starting values for the game
; gameInit.system                       - disableOS, enable custom NMI
; gameInit.PM                           - turnoff P/M graphic on title screen


;======================================
;
;======================================
settings        .proc
; clear zero page (not globalVelocityBuffer) | clears 00-$3f and $80-$ff
                lda #0
                ldx #$80
_next1          sta $00,x
                inx
                cpx #$3e
                bne _next1

                ;A=0
                sta playfieldTransitionVBL.backgroundColor+1
                sta titleScreen.screenMode

                jsr detectCPU
                jsr drawTo.draw_init

                lda #1
                sta player.animationDelay
                sta playerShotDelay
                sta playerFrameDraw
                sta extraLifeValue      ; first extra life after 10.000 (value 1 = 10.000 points)
                sta firstRun
                sta gameCurrentLevel

                lda #configPauseDelay
                sta gamePauseDelay

                lda #configStartingPlayerLives
                sta playerLives

                lda #configRankingColorsDelay
                sta titleScreenHiScoreDLI.rankingColorsDelay

                lda levelInformation.levelBackgroundColor ; first transition color
                sta playfieldTransition.color+1

                lda ntsc
                sta ntsc_counter
                rts
                .endproc


;======================================
;
;======================================
system          .proc
                jsr waitFrame
                jsr disableOS
                jsr prepareGlobalVelocity
                jsr detectCPU
                beq _1

                jsr prepareForRapidus
_1              jsr setFakeDlist

                lda $f600               ; determined in loadGameGraphic
                sta ntsc
                jmp enableNMI

                .endproc


;======================================
;
;======================================
setFakeDlist    .proc
                lda #<fakeDlist
                sta dlptr
                lda #>fakeDlist
                sta dlptr+1
                rts
                .endproc


;======================================
;
;======================================
disablePM       .proc
                lda #0
                sta pmactive
                lda #%100010
                sta dmactl
                jsr hideMissiles
                jmp hidePlayer
                .endproc


;======================================
;
;======================================
prepareForRapidus .proc
                lda #1
                sta gameplay.minFrames

;dividing globalVelocity
                ldx #0
                clc

globalVelocityLoop
                lda OLP.globalVelocityXH,x
                bpl _1

                sec
_1              ror OLP.globalVelocityXH,x
                ror OLP.globalVelocityXL,x
                inx
                cpx #32
                bcc globalVelocityLoop

;dividing SPAWN.enemy.velocity
                ldx #0

SPAWNEnemyvelocityLoop
                clc
                lda SPAWN.enemy.velocityXH,x
                bpl _2

                sec
_2              ror SPAWN.enemy.velocityXH,x
                ror SPAWN.enemy.velocityXL,x
                inx
                bpl SPAWNEnemyvelocityLoop

;dividing SPAWN.playerShot.velocity
                ldx #0
                clc
SPAWNplayerShotvelocityLoop
                lda SPAWN.playerShot.velocityXH,x
                bpl _3

                sec
_3              ror SPAWN.playerShot.velocityXH,x
                ror SPAWN.playerShot.velocityXL,x
                inx
                cpx #32
                bcc SPAWNplayerShotvelocityLoop

;dividing enemyFire.velocity.xVelTab and yVelTab
                ldx #0
enemyFirevelocityVelTabLoop
                lsr enemyFire.velocity.xVelTab,x
                inx
                cpx #12*10
                bcc enemyFirevelocityVelTabLoop

;modifying playfield DLI
                lda #$8D                ;{sta}
                sta DLIDispatch
                lda #<wsync
                sta DLIDispatch+1

                lda #>wsync
                sta DLIDispatch+2

;modifying enemy bombs speed
                lda #15
                sta enemyBomb.process.auto0
                lda #7
                sta enemyBomb.process.auto1
                lda #10
                sta enemyBomb.process.auto2

; modifying parachute animation, speed and spawn ratio
                lda #$4A                ;{lsr}
                sta OLP.parachute.auto0

                ldx #127
                stx SPAWN.parachute.auto0
                inx
                stx SPAWN.parachute.spawnDelay

                lda #96
                sta SPAWN.parachute.destroyDelay

                lda #32
                sta SPAWN.parachute.velocityYL
                sta SPAWN.enemy.fadeOut

; modyfying boss speed
                lda #$80
                sta SPAWN.boss.velocityXL

; modyfying explosion animation speed
                lda #$4A                ;{lsr}
                sta OLP.explosions.auto0

; modyfying various delays
                lda #180
                sta SPAWN.globalSpawnDelay

                lda #6
                sta gameplay.animationSwitchDelay

                lda #88
                sta SCORE.extraLife.extraLifeDurationValue

                lda #140
                sta SPAWN.enemy.squadronPosition.squadronRotationDelay

; rapidus level values
                jsr rapidusLevelValues

; clouds values
                lda #9
                sta SPAWN.maxCloudsSpawnF

                lda #(9+olClouds)
                sta SPAWN.maxCloudsSpawnFol

                lda #8
                sta SPAWN.maxCloudsSpawn

                ldx #4
                stx SPAWN.maxCloud1
                dex
                stx SPAWN.maxCloud2
                dex
                stx SPAWN.maxCloud3
                rts
                .endproc

                .endproc                ; gameInit
