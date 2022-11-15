
; ENGINE SETTINGS | co-op with ENGINE OL OFFSETS
engineMaxEnemies        = 8                         ; max amount of enemies | max: engineMaxCommon - engimeMaxEnemyBombs
engimeMaxPlayerShots    = 8                         ; max amount of player shots | max: 8
engimeMaxEnemyShots     = 2                         ; max amount of enemy shots  | max: 2 (limited by P/M missiles; 2 per shot)
engimeMaxEnemyBombs     = 2                         ; max amount of enemy bombs/rockets | max: engineMaxCommon - engineMaxEnemies
engineMaxCommon         = (ol.capacity-olCommon)    ; max amount of common objects (enemies, bombs, explosions)
engineMaxClouds         = (olCommon-olClouds)       ; max amount of clouds (engine capacity)
engineMaxCloudsSpawn    = 4                         ; max amount of clouds to spawn    | default: 4
engineMaxCloudsSpawnF   = 5                         ; max amount of clouds to spawn when game starts (first spawn) | default: 5
engineMaxCloud1         = 2                         ; max amount of small clouds | default: 2
engineMaxCloud2         = 2                         ; max amount of medium clouds | default: 2
engineMaxCloud3         = 1                         ; max amount of big clouds| default: 1
engineMinFrames         = 2                         ; min. frames per gameloop aka FPS lock 25fps/30fps | 50/60fps for rapidus (autodetect) | | default: 2
engineWaitFrameVcount   = 90                        ; screen line number for VWaitFrame | default: 90

; GAME CONFIG
configPlayerAnimationDelay      = 3     ; default: 3 | 1 = fastest
configPlayerShotDelay           = 6     ; default: 6 | delay between shots
configPlayerShotMaxChain        = 3     ; default: 3 | max. chained shots per pressed fire | or default: 6
configRankingColorsDelay        = 4     ; default: 4 | fade in/out delay
configTeleportAnimationDelay    = 3     ; default: 3 | 1 = fastest
configAnimationSwitchDelay      = 3     ; default: 3 | delay for animation switch (ufo animnation, airscrews, ufo missiles etc)
configGameMaxDifficulty         = 3     ; default: 3 | 0-3 | if max is changed -> need to do changes in SPAWN.spawnEnemy velocity tables
configSquadronRotationDelay     = 70    ; default: 70 | delay before spawned squadron will start to rotate
configSquadronSpawnDelay        = 8     ; default: 8 | general delay (in units) before a squadron can be spawned; example: 8 normal enemies before we take squadrons in consideration
configGlobalSpawnDelay          = 80    ; default: 80 | delay (in gameloops) before first spawns can occur
configStartingPlayerLives       = 5     ; default: 5 | values: 1-255
configGameOverDelay             = 100   ; default: 100 | delay until game go to title screen after game over | * 2 for turbo
configPauseDelay                = 25    ; default: 25  | delay before we can unpause/pause again
configSwarmModeAddEnemies       = 16    ; default: 16 | adds this amount of enemies (swarm mode) | max value: 16 (8+16 = engineMaxCommon)

; SCORE SETTINGS (values per object; BCD)
gameEnemyScore                  = 1     ; 100
gameBombScore                   = 1     ; 100
gameParachuteScore              = $20   ; 2000
gameBossHitScore                = 1     ; 100
gameBossScore                   = $30   ; 3000

; GENERAL CONFIG
configGameMaxLevel              = 5     ; max game level (then it resets to level 1)
configLevelStartNameBlink       = 8     ; delay on level name color blink in frames

; SOUND CONFIG
configSoundAllow                = 1     ; sound on/off
configMusicStartGame            = 4     ; subsong line for starting music | 4 = starting music | 5 = off
configMusicHighScore            = 7     ; subsong line for highscore music
configMusicPlayerDestroyed      = $c    ; subsong line for player destroyed sfx
configMusicTeleport             = 9     ; subsong line for teleport music (technically subsong with SFX)
configMusicHiScore              = 7     ; subsong line for HiScore music
configSFXChannels               = 4     ; [NOT IMPLEMENTED] how many channels system use for SFX (1-x)


; TEMP TRACES - stash
; RMT rmt_play
;!##TRACE "trackn_idx: %d" db(RMT.trackn_idx)
;!##TRACE "ns: %d" db(RMT.ns)
;!##TRACE "nr: %d" db(RMT.nr)
;!##TRACE "nt: %d" db(RMT.nt)
;!##TRACE "y: %d" y

; SAMPLE ENGINE SETTINGS for TURBO CPU
; engineMaxEnemies        = 24    ; max amount of enemies | 8
; engimeMaxPlayerShots    = 8    ; max amount of player shots
; engimeMaxEnemyShots        = 2    ; max amount of enemy shots
; engimeMaxEnemyBombs        = 2    ; max amount of enemy bombs/rockets
; engineMaxCommon            = (ol.capacity-olCommon)    ; max amount of common objects (enemies, bombs, explosions)
; engineMaxClouds            = (olCommon-olClouds)        ; max amount of clouds
; engineMaxCloudsSpawn    = 8    ; max amount of clouds to spawn | 4
; engineMaxCloudsSpawnF    = 8    ; max amount of clouds to spawn when game starts | 5
; engineMaxCloud1            = 3    ; max amount of small clouds | 2
; engineMaxCloud2            = 3    ; max amount of medium clouds | 2
; engineMaxCloud3            = 2    ; max amount of big clouds | 1
; engineMinFrames            = 1    ; min. frames | wait for engineMinFrames is scene was rendered faster | FPS lock 25fps/30fps
; engineWaitFrameVcount    = 90
