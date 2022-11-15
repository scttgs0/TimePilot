
;preparations for every rendering phase

prPrepareGenericTypes .block
    cloud1      = 0
    cloud2      = 1
    cloud3      = 2
    asteroid1   = 3
    asteroid2   = 4
    asteroid3   = 5
    enemy       = 6
    explosion   = 7
    parachute   = 8
    bomb        = 9
    boss        = 10
                .endblock


;======================================
;--------------------------------------
;   Y           object type
;======================================
prPrepareGeneric .proc
                lda twidth,y
                sta prObjWidth
                lda theight,y
                sta prObjHeight

                lda txloopjmpl,y
                sta prDrawGeneric.xloopJmp+0
                lda txloopjmph,y
                sta prDrawGeneric.xloopJmp+1

                lda txloopexit,y
                sta prDrawGeneric.StandardXLoop.exitResult

                lda txloopfhd,y
                sta prDrawGeneric.StandardXLoop.highFontDeterminant

                ldx tobj,y
                stx prObjId

                lda ebGfxMaskO,x
                sta prGfxMaskOff
                lda ebGfxNextO,x
                sta prGfxNextOff+1

                asl
                sta prGfxNextOff+2

                clc
                adc prGfxNextOff+1
                sta prGfxNextOff+3

                clc
                adc prGfxNextOff+1
                sta prGfxNextOff+4
                rts

;--------------------------------------

SXL             = prDrawGeneric.StandardXLoop
CXL             = prDrawGeneric.Cloud3XLoop
c1w             = prPrepareGfxCloud1.cWidth
c2w             = prPrepareGfxCloud2.cWidth
c3w             = prPrepareGfxCloud3.cWidth
a1w             = prPrepareGfxAsteroid1.cWidth
a2w             = prPrepareGfxAsteroid2.cWidth
a3w             = prPrepareGfxAsteroid3.cWidth
bow             = prPrepareGfxBoss.cWidth
c1h             = prPrepareGfxCloud1.cHeight
c2h             = prPrepareGfxCloud2.cHeight
c3h             = prPrepareGfxCloud3.cHeight
a1h             = prPrepareGfxAsteroid1.cHeight
a2h             = prPrepareGfxAsteroid2.cHeight
a3h             = prPrepareGfxAsteroid3.cHeight
boh             = prPrepareGfxBoss.cHeight
oc1             = prGfxObj.cloud1
oc2             = prGfxObj.cloud2
oc3             = prGfxObj.cloud3
oen             = prGfxObj.enemy
oex             = prGfxObj.explosion
opa             = prGfxObj.parachute
obm             = prGfxObj.bomb
obo             = prGfxObj.boss

bossBlink       = txloopfhd+prPrepareGenericTypes.boss

twidth          .byte  c1w,   c2w,   c3w,   a1w,   a2w,   a3w,     4,     4,     4,     2,  bow
theight         .byte  c1h,   c2h,   c3h,   a1h,   a2h,   a3h,    16,    16,    16,     8,  boh
txloopjmpl      .byte <SXL,  <SXL,  <CXL,  <SXL,  <SXL,  <CXL,  <SXL,  <SXL,  <SXL,  <SXL,  <SXL
txloopjmph      .byte >SXL,  >SXL,  >CXL,  >SXL,  >SXL,  >CXL,  >SXL,  >SXL,  >SXL,  >SXL,  >SXL
txloopexit      .byte    0,     0,   $ff,     0,     0,   $ff,     1,     0,     1,     1,     1
txloopfhd       .byte  $80,   $80,    $0,   $80,   $80,     0,     0,     0,   $80,     0,     0
tobj            .byte  oc1,   oc2,   oc3,   oc1,   oc2,   oc3,   oen,   oex,   opa,   obm,   obo

                .endproc

prepareGfxNextOff   ;--.proc
                    ;--.endproc
