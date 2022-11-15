
; ----------------
;     TimePilot
;  memory LAYOUT
; ----------------

; ***** ZERO PAGE *****

;global page zero variables goes here
zeroPage                = $00
counterDLI              = zeroPage

gameCurrentLevel        = zeroPage+2    ; 1 byte
playerShotChain         = zeroPage+3    ; 1 byte
frameCounter            = zeroPage+4    ; frame counter (how many frames per rendered scene)
playerShotDelay         = zeroPage+5    ; 1 byte delay beetwen shots
playerShotChannel       = zeropage+6    ; [NOT USED ANYMORE] was for: 1 byte pokey channel for fire (2 or 3)
playerFrameDraw         = zeroPage+7    ; 1 byte flag if we have to draw new player frame
player          .block
    animationDelay      = zeroPage+8    ; delay counter before we go to next player animation frame
    currentFrame        = zeroPage+10   ; current player frame
    lastFrame           = zeroPage+11   ; playe frame before
                .endblock
gamePaused              = zeropage+12   ; 1 byte    0 - game is running | 1 - game is paused
gamePauseDelay          = zeropage+13   ; 1 byte    delay before we can unpause/pause the game
gameSFXAllow            = zeroPage+14   ; 1 byte    [NOT USED ANYMORE]
playerMovementAllow     = zeroPage+15   ; 1 byte
bufScreenNr             = zeroPage+16   ; 1 byte | high byte of screen address
OLPCounter              = zeroPage+17   ; 1 byte | temporal counter for object list (OLP) used in various logic
playerShotCounter       = zeroPage+18   ; 1 byte | active player shots - used in OLP (so we dont have to check the list)
enemyCounter            = zeroPage+19   ; 1 byte | active enemies - used in OLP (so we dont have to check the list)
enemyShotCounter        = zeroPage+20   ; 1 byte | active enemy shots - used in OLP (so we dont have to check the list)
animationSwitch         = zeroPage+21   ; 1 byte | switches global animation per gameLoop (0-1)
animationSwitchCounter  = zeroPage+22   ; 1 byte | delay for animationSwitch; can be setup in config
cloudCounter1           = zeroPage+23   ; 1 byte
cloudCounter2           = zeroPage+24   ; 1 byte
cloudCounter3           = zeroPage+25   ; 1 byte
parachuteSpawnDelay     = zeroPage+26   ; 1 byte
parachuteDestroyDelay   = zeroPage+27   ; 1 byte
playerMaskTouched       = zeroPage+28   ; 1 byte 1 if player mask has been touched
playerDestroyed         = zeroPage+29   ; 1 byte 1 if player is destroyed
playerDestroyedDelay    = zeroPage+30   ; 1 byte - delay1 before we reset level after death
playerDestroyedInit     = zeroPage+31   ; 1 byte - is destroy delay inited?
playerLives             = zeroPage+32   ; 1 byte
playerScore             = zeroPage+33   ; 2 bytes
hiScore                 = zeroPage+35   ; 2 bytes
hiScoreNew              = zeroPage+37   ; 1 byte 0/1 flag if player got new higscore (so we rewrite it on screen)
levelFullyInited        = zeroPage+38   ; 1 byte
playerGameOver          = zeroPage+39   ; 1 byte 0/1 flag
extraLifeScore          = zeroPage+40   ; 2 bytes
extraLifeValue          = zeroPage+42   ; 1 byte    amount of score we add an extralife | 1 = 10.000, 5 = 50.000
extraLifeDuration       = zeroPage+43   ; 1 byte    during extra life subsong we swap SFX channels for enemy shots for a duration
firstRun                = zeroPage+44   ; 1 byte    0/1 flag (first game run; resets at title screen)
spawnCounter            = zeroPage+45   ; 1 byte    how many units to spawn in enemy spawn routine
spawnType               = zeroPage+46   ; 1 byte    single unit or squadron
squadronDelay           = zeropage+47   ; 1 byte    min. delay (in 'spawned units') before next squadron can be randomly spawned
squadronSide            = zeropage+48   ; 1 byte    screen side for squadron (top,right,bottom,left) | values 0-3
squadronShake           = zeropage+49   ; 1 byte    randomize position (global random value for whole squadron)
squadronAlt             = zeropage+50   ; 1 byte    cache; 0 for alernative direction, >0 - normal direction
squadronAddr            = zeropage+51   ; 2 bytes   adress to selected squadron data
enemyBombCounter        = zeropage+53   ; 1 byte    enemy bombs counter
rapidusDetected         = zeropage+54   ; 1 byte    0 - running on 6502, $80 - running on 65c816.
fntAlloc                = zeroPage+55   ; 4 bytes   fonts for enemies

ntsc                    = zeropage+$3e  ; 0 = PAL; other value = NTSC counter for VBL skip
ntsc_counter            = zeropage+$3f  ; skip VBL sound by this frames; 0 to disable NTSC (during gameplay, FX)
globalVelocityBuffer    = zeropage+$40  ; -$7f ($3f bytes) fast global velocity buffer

levelCurrent    .block                      ; information about current level
    tokill                  = zeroPage+$80  ; 1 byte
    agilityDelay            = zeroPage+$81  ; 1 byte
    rotationDelay           = zeroPage+$82  ; 1 byte
    bossKilled              = zeroPage+$83  ; 1 byte
    allowSpawnsDelay        = zeroPage+$84  ; 1 byte | delay before we can spawn anything in level
    allowSpawns             = zeroPage+$85  ; 1 byte | 0 = spawns allowed (shots, enemies etc)
    enemyPeriodicity        = zeroPage+$86  ; 1 byte
    difficulty              = zeroPage+$87  ; 1 byte
    clearedLevels           = zeroPage+$88  ; 1 byte
    explodeAll              = zeroPage+$89  ; 1 byte
    agilityMinimum          = zeroPage+$8a  ; 1 byte ; enemy minimum agility (less = better agility)
    rotationDelayMin        = zeroPage+$8b  ; 1 byte
    enemyBossHP             = zeroPage+$8c  ; 1 byte
    enemyBossHalfHP         = zeroPage+$8d  ; 1 byte
    enemyFirePeriodicity    = zeropage+$8e  ; 1 byte
    squadronPeriodicity     = zeropage+$8f  ; 1 byte
    enemyBombPeriodicity    = zeropage+$90  ; 1 byte
    swarmMode               = zeropage+$91  ; 1 byte
                .endblock

; draw engine
prObjWidth              = zeroPage+$92      ; 1 byte    | current object width in bytes (4 pixels)
prObjHeight             = zeroPage+$93      ; 1 byte    | current object height
prGfxScr                = zeroPage+$94      ; 2 bytes   | sourca graphics address
prGfxMaskOff            = zeroPage+$96      ; 1 byte    | offset to corresponding mask data
prGfxNextOff            = zeroPage+$97      ; 4 bytes   | offset to next horizontal graphics
prObjId                 = zeroPage+$9c      ; 1 byte    | index of  object in ebGfx* table


soundSystem     .block                      ; what sound FX to play on what channel during VBL
    channelCounter      = zeroPage+$a2      ; 1 byte | channel counter - cycle sounds through channels [DEPRECATED]
    soundChannelSFX     = zeroPage+$a3      ; -$a6 4 bytes (4 channels)
    soundChannelNote    = zeroPage+$a7      ; -$aa 4 bytes (4 channels)
    subsongQueue        = zeroPage+$ab      ; 1 byte ; queued subsong to play (change on VBL)
                .endblock


musicPlayerPage         = zeroPage+$ac      ; 19 bytes

;local temp variablesvariables for current running segment
zeroPageLocal           = $c0
zp_CopyFrom             = zeroPageLocal
zp_CopyTo               = zeroPageLocal+2
zp_CopyLength           = zeroPageLocal+4   ; 2 bytes


; ***** ENGINE BUFFERS *****
prMaskTempTable         = objectListTable   ; $100 bytes | temporary table for mask generations; shared buffer
ebGfxScrsL              = $200              ;  - $23f
ebGfxScrsH              = $240              ;  - $27f
ebGfxMaskO              = $280              ;  - $2bf
ebGfxNextO              = $2c0              ;  - $2ff
playerMask              = $340              ;  - $37f

; RENDERER BUFFER
egGfxData               = $5900             ; max: $ad59

; NMI
nmiHandler              = $ad60             ; - $add0)

; ***** GAME DATA *****
dataMusicPlayerTables   = $addf             ; - dummy - just for information (~$400 bytes frequency tables before RMT player)
dataMusicPlayer         = $b100             ; - $b4ff (can vary | check in final version)
dataMusicFile           = $b500             ; - $beff RMT file | ($be4c for now)

; DLISTs
dataTitleScreenDlist    = $bf00             ; - $40 bytes
dataTitleScreenDlist2   = $bf40             ; - $40 bytes
dataPlayfieldDlist      = $bf80             ; - $40 bytes
dataPlayfieldDlist2     = $bfc0             ; - $40 bytes

dataCloudSmall          = $f000             ; $20 bytes
dataCloudMedium         = $f020             ; $80 bytes
dataProgressBar1        = $f0a0             ; $20 bytes
dataProgressBar2        = $f0c0             ; $20 bytes
dataProgressBar3        = $f0e0             ; $20 bytes
dataProgressBar4        = $f100             ; $20 bytes
dataProgressBar5        = $f120             ; $20 bytes
dataCloudBig            = $f140             ; $c0 bytes

; MAIN GFX DATA
; enemies, bosses, explosions, parachute, bombs, rockets, player
dataGameGraphic         = $c000 ; - $cfff
dataEnemyLevel1         = dataGameGraphic         ; $400 bytes
dataEnemyLevel2         = dataGameGraphic+$400    ; $400 bytes
dataEnemyLevel4         = dataGameGraphic+$800    ; $400 bytes
dataEnemyBoss1          = dataGameGraphic+$c00    ; $100 bytes
dataEnemyBoss2          = dataGameGraphic+$d00    ; $100 bytes
dataEnemyBoss3          = dataGameGraphic+$e00    ; $100 bytes
dataEnemyBoss4          = dataGameGraphic+$f00    ; $100 bytes


dataGameGraphic2        = $e000 ; - $efff
dataEnemyLevel3         = dataGameGraphic2        ; $240 bytes
dataEnemyLevel5         = dataGameGraphic2+$240   ; $80 bytes
dataEnemyExplosion      = dataGameGraphic2+$2c0   ; $100 bytes
dataParachute           = dataGameGraphic2+$3c0   ; $140 bytes
dataEnemyBoss5          = dataGameGraphic2+$500   ; $100 bytes
dataSpritePlayer        = dataGameGraphic2+$600   ; $400 bytes
dataAsteroidSmall       = dataGameGraphic2+$a00   ; $40 bytes
dataAsteroidMedium      = dataGameGraphic2+$a40   ; $80 bytes
dataAsteroidBig         = dataGameGraphic2+$ac0   ; $120 bytes
dataEnemyBomb           = dataGameGraphic2+$be0   ; $20 bytes
dataTextFonts           = dataGameGraphic2+$c00   ; $2a0 bytes    | last $150 fnt bytes used for gfx data
dataEnemyBombLvl5       = dataGameGraphic2+$ea0   ; $20 bytes
dataCosmonaut           = dataGameGraphic2+$ec0   ; $140 bytes

; ***** GAME BUFFERS ******
objectListTable         = $d800     ; - $dbff ; $400 bytes

bufFonts0a              = $400      ; - $400 bytes        ; iteration of 4 pages
bufFonts1a              = $800      ; - $400 bytes        ; iteration of 4 pages
bufFonts2a              = $c00      ; - $400 bytes        ; iteration of 4 pages
bufFonts3a              = $1000     ; - $400 bytes        ; iteration of 4 pages

bufFonts0b              = $1400     ; - $400 bytes        ; iteration of 4 pages
bufFonts1b              = $1800     ; - $400 bytes        ; iteration of 4 pages
bufFonts2b              = $1c00     ; - $400 bytes        ; iteration of 4 pages
bufFonts3b              = $dc00     ; - $400 bytes        ; iteration of 4 pages

bufScreen0              = $f200     ; - $f3ff
bufScreen1              = $f400     ; - $f5ff
buf2FreePages           = $f600     ; - $f7ff

bufPMBase               = $f800     ; - $fbff      ; iteration of 4 pages; only pages 2 and 3 used for sprites | first $200 used in various buffers
bufM                    = bufPMBase+$180
bufPM0                  = bufPMBase+$200
bufPM1                  = bufPMBase+$280
bufPM2                  = bufPMBase+$300
bufPM3                  = bufPMBase+$380

bufScreenTxt            = bufPMBase                ; unused PMBase segment - used for score information
bufProgressBar          = bufScreenTxt+40          ; unused PMBase segment - used for level progress bar gfx

dataLogoFonts           = $fc00     ; - $ffff

; ***** FREE RAM *****
; free: $ede0-edff  dataGameGraphic2+$de0 - $dff | $20 bytes
; $380    - $3ff    ($80 bytes)

; ***** FREE RAM - BUFFERS ONLY *****
; $f600 - $f7ff ($200 bytes) can be only used for buffers;  used in: titlescreen drawTo buffer
