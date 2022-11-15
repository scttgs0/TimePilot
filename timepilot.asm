
; -----------------------------------
;             TIMEPILOT
;    arcade port for Atari XL/XE 64K
;            code: solo, laoo
;          New Generation 2018
;------------------------------------

            .enc "atari-screen"
                .cdef " Z",$00
                .cdef "az",$61
            .enc "none"


                .include 'loader/loadingFadeOut.asm'


;--------------------------------------
;--------------------------------------
                * = $02E2
;--------------------------------------

                .addr $5C00


    ;opt c+        65816 instructions

                .include 'loader/loadGameGraphic.asm'


;--------------------------------------
;--------------------------------------
                * = $02E2
;--------------------------------------

                .addr $2000


;--------------------------------------
;--------------------------------------
                * = $2000
;--------------------------------------

start           ; preinitializations
                jsr gameInit.system

main            .proc
                jsr gameInit.disablePM
                jsr prPreinitLvl1
                jsr gameInit.settings
                jsr titleScreen
                jsr initPlayfield
                jmp gameplay.loop
                .endproc

                ; nmi
                .include 'common/nmi/titleScreenNMI.asm'
                .include 'common/nmi/playfieldNMI.asm'

                ; commons
                .include 'common/hardwareRegisters.asm'
                .include 'common/config.asm'
                .include 'common/memoryLayout.asm'

                ; engine
                .include 'engine/drawPlayer.asm'
                .include 'engine/gameplayLoop.asm'
                .include 'engine/playfieldRenderer/main.asm'
                .include 'engine/levelProcedures.asm'
                .include 'engine/gameSpawns.asm'
                .include 'engine/objectListProcessing.asm'
                .include 'engine/objectListTable.asm'
                .include 'engine/hitDetect.asm'
                .include 'engine/enemyFire.asm'
                .include 'engine/enemyBomb.asm'
                .include 'engine/scoreRoutines.asm'
                .include 'engine/gameModes.asm'

                ; various
                .include 'common/commonProcedures.asm'
                .include 'common/gameInit.asm'
                .include 'common/playfieldInit.asm'
                .include 'common/playfieldProcessing.asm'
                .include 'common/titleScreen.asm'
                .include 'common/drawTo.asm'
                .include 'common/soundSystem.asm'

                ; ORG ins starts here
                .include 'common/dlists/titleScreenDlist.asm'
                .include 'common/dlists/playfieldDlist.asm'
                .include 'common/rmt/rmtplayr.asm'
                .include 'common/nmi/nmi.asm'

                ; music/sfx
                ;.binary "data/music/timepilot.rmt"


; ;--------------------------------------
; ;--------------------------------------
;                 * = $02E0
; ;--------------------------------------

;                 .addr $2000
