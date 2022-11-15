
prScreenWidth           = 160
prScreenHeight          = 96

prScreenWidthFonts      = prScreenWidth/4
prScreenHeightFonts     = prScreenHeight/8

;virtual screen coordinates
prScreenXMin            = 128-(prScreenWidth/2)
prScreenXMax            = 128+(prScreenWidth/2)
prScreenYMin            = 128-(prScreenHeight/2)
prScreenYMax            = 128+(prScreenHeight/2)

; object box size for fadeOut
fadeOutWidth            = 16            ; after this amount of pixels object will start to fade out off screen
fadeOutHeight           = 16            ; after this amount of pixels object will start to fade out off screen

rliTemp                 = zeroPageLocal

rliMask                 = rliTemp+0

bufRLIDsL               = rliTemp+2     ;render list destination low
bufRLIDsH               = rliTemp+3     ;render list destination high
bufRLISrL               = rliTemp+4     ;render list source low
bufRLISrH               = rliTemp+5     ;render list source high
bufRLIDof               = rliTemp+6     ;render list destination offset
bufRLILen               = rliTemp+7     ;render list length (same as offset)
bufRLIMsk               = rliTemp+8     ;render list mask offset from dest
bufRLIVal               = rliTemp+9     ;render list destination value

prTemp                  = zeroPageLocal+7    ;this is madness!


;graphics objects ids | max 64 objects (0-63)
prGfxObj        .block
    enemy       = 0         ;16 entries
    explosion   = 16        ;4 entries
    parachute   = 20        ;5 entries
    boss        = 25        ;2 entries
    cloud1      = 27        ;1 entry
    cloud2      = 28        ;1 entry
    cloud3      = 29        ;1 entry
    bomb        = 30        ;2 entries
    rocket      = 32        ;16 entries
                .endblock

fontsReservedForPlayerLocation = 256-8

;--------------------------------------
;--------------------------------------

    .include 'preinit.asm'
    .include 'preparePhase.asm'
    .include 'draw.asm'
    .include 'render.asm'
