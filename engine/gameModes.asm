
gameModes       .proc

;--------------------------------------
; normal mode
;--------------------------------------
normal          .proc
                lda #8
                sta SPAWN.enemy.maxEnemies

                lda #6
                sta SPAWN.enemy.maxEnemiesSquadron

                lda #$27-4
                sta OLP.enemies.maxEnemiesOLP

                lda #$EA                ;{nop}
                sta SPAWN.enemyShots
                sta SPAWN.enemyBombs

                lda rapidusDetected
                beq swarm.finish        ; shared finishing code

                jsr rapidusLevelValues  ; rewrite default level values for rapidus (because swarm mode changes it)
                bmi swarm.finish        ; N is set by rapidusLevelValues->memCopyShort

                .endproc


;--------------------------------------
; swarm mode    | press select on titlescreen (rapidus only)
;--------------------------------------
swarm           .proc
                lda #8+configSwarmModeAddEnemies
                sta SPAWN.enemy.maxEnemies

                lda #8-2+configSwarmModeAddEnemies
                sta SPAWN.enemy.maxEnemiesSquadron

                lda #$27-configSwarmModeAddEnemies
                sta OLP.enemies.maxEnemiesOLP

                lda #$60                ;{rts}
                sta SPAWN.enemyShots
                sta SPAWN.enemyBombs

                lda #0
                sta levelInformation.levelEnemyPeriodicity
                sta levelInformation.levelEnemyPeriodicity+1
                sta levelInformation.levelEnemyPeriodicity+2
                sta levelInformation.levelEnemyPeriodicity+3
                sta levelInformation.levelEnemyPeriodicity+4

                lda #63
                sta levelInformation.levelAgilityMinimum
                sta levelInformation.levelAgilityMinimum+1
                sta levelInformation.levelAgilityMinimum+2
                sta levelInformation.levelAgilityMinimum+3
                sta levelInformation.levelAgilityMinimum+4

                lda #127
                sta levelInformation.levelSquadronPeriodicity
                sta levelInformation.levelSquadronPeriodicity+1
                sta levelInformation.levelSquadronPeriodicity+2
                sta levelInformation.levelSquadronPeriodicity+3
                sta levelInformation.levelSquadronPeriodicity+4

                lda #1
                sta levelCurrent.swarmMode
                sta levelCurrent.difficulty

                lda #10
                sta playerLives

finish          lda SPAWN.globalSpawnDelay ; first time spawn delay when game starts
                sta levelInformation.levelAllowSpawnsDelay
                rts
                .endproc

                .endproc
