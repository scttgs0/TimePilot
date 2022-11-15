
; ----------------------------------
;             DATA LOADER
;    copy gfx data to RAM under ROM
;-----------------------------------

;--------------------------------------
;--------------------------------------
                * = $2000
;--------------------------------------

copyFm          = $3000               ; $1000
copyFm2         = $4000               ; $1000
copyFm3         = $5000               ; $400
copyFm4         = $5400               ; $200

                jsr loader.disableOS


;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
; gameGraphic
;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
copyDataObjects .macro
                lda copyFm+$000+(\1<<8),x
                sta dataGameGraphic+$000+(\1<<8),x
                .endmacro


                ldx #0
_next1      .for item in range(16)
                .copyDataObjects item
            .endfor

                inx
                bne _next1


;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
; gameGraphic2
;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
copyDataObjects2 .macro
                lda copyFm2+$000+(\1<<8),x
                sta dataGameGraphic2+$000+(\1<<8),x
                .endmacro


                ldx #0
_next2      .for item in range(16)
                .copyDataObjects2 item
            .endfor

                inx
                bne _next2

;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
; gameGraphic3
;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
copyDataObjects3 .macro
                lda copyFm3+$000+(\1<<8),x
                sta dataLogoFonts+$000+(\1<<8),x
                .endmacro


                ldx #0
_next3      .for item in range(4)
                .copyDataObjects3 item
            .endfor

                inx
                bne _next3

;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
; gameGraphic4    (clouds, progress bars)
;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
copyDataObjects4 .macro
                lda copyFm4+$000+(\1<<8),x
                sta dataCloudSmall+$000+(\1<<8),x
                .endmacro


                ldx #0
_next4      .for item in range(2)
                .copyDataObjects4 item
            .endfor

                inx
                bne _next4

; determines PAL or NTSC
                ldx $d014
                dex
                beq _5

                ldx #7
_5              stx $f600               ; game reads it and store information on zero page

; finish
                jmp loader.enableOS


;--------------------------------------
                .include 'loaderProcedures.asm'
;--------------------------------------

;--------------------------------------
;--------------------------------------
                * = copyFm
;--------------------------------------
                .binary '../data/graphic/enemies/enemyLevel1.dat'
                .binary '../data/graphic/enemies/enemyLevel2.dat'
                .binary '../data/graphic/enemies/enemyLevel4.dat'
                .binary '../data/graphic/enemies/bossLevel1.dat'
                .binary '../data/graphic/enemies/bossLevel2.dat'
                .binary '../data/graphic/enemies/bossLevel3.dat'
                .binary '../data/graphic/enemies/bossLevel4.dat'

;--------------------------------------
;--------------------------------------
                * = copyFm2
;--------------------------------------
                .binary '../data/graphic/enemies/enemyLevel3.dat'
                .binary '../data/graphic/enemies/enemyLevel5.dat'
                .binary '../data/graphic/enemies/enemyExplosion.dat'
                .binary '../data/graphic/bonuses/parachute.dat'

                .binary '../data/graphic/enemies/bossLevel5.dat'
                .binary '../data/graphic/player.raw'
                .binary '../data/graphic/asteroids/asteroidSmall.dat'
                .binary '../data/graphic/asteroids/asteroidMedium.dat'
                .binary '../data/graphic/asteroids/asteroidBig.dat'
                .binary '../data/graphic/enemies/bomb.dat'

;--------------------------------------
;--------------------------------------
                * = copyFm2+(dataTextFonts-dataGameGraphic2)
;--------------------------------------
                .binary '../data/graphic/timePilotFonts.fnt'
                .binary '../data/graphic/enemies/bomb_lvl5.dat'
                .binary '../data/graphic/bonuses/cosmonaut.dat'

;--------------------------------------
;--------------------------------------
                * = copyFm3
;--------------------------------------
                .binary '../data/graphic/titleScreenLogo.fnt'

;--------------------------------------
;--------------------------------------
                * = copyFm4
;--------------------------------------
                .binary '../data/graphic/clouds/cloudSmall.dat'
                .binary '../data/graphic/clouds/cloudMedium.dat'

                .binary '../data/graphic/progressBar/levelBar1.dat'
                .binary '../data/graphic/progressBar/levelBar2.dat'
                .binary '../data/graphic/progressBar/levelBar3.dat'
                .binary '../data/graphic/progressBar/levelBar4.dat'
                .binary '../data/graphic/progressBar/levelBar5.dat'
                .binary '../data/graphic/clouds/cloudBig.dat'
