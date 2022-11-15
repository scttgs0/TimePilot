
;hardware

KEY_ESC         = $1c

trig0           = $d010 ; joy0 fire
colpm0          = $d012 ; 704
colpm1          = $d013
colpm2          = $d014
colpm3          = $d015
colpf0          = $d016 ; 708
colpf1          = $d017
colpf2          = $d018
colpf3          = $d019
colbak          = $d01a
gtiactl         = $d01b
consol          = $d01f

audc1           = $d201
audc2           = $d203
audc3           = $d205
audc4           = $d207
kbcode          = $d209
random          = $d20a
irqen           = $d20e
irqst           = $d20e
skstat          = $d20f

porta           = $d300
portb           = $d301

dmactl          = $d400
dlptr           = $d402
vcount          = $d40b
nmien           = $d40e
nmist           = $d40f
wsync           = $d40a

;solo
; SCROLLS
hscrol          = $d404
; FONTS
chbase          = $d409
; P/M
pmbase          = 54279
pmactive        = 53277
sizep0          = 53256
sizep1          = 53257
sizep2          = 53258
sizep3          = 53259
sizem           = 53260
hposp0          = 53248
hposp1          = 53249
hposp2          = 53250
hposp3          = 53251
hposm0          = 53252
hposm1          = 53253
hposm2          = 53254
hposm3          = 53255
kolm0p          = $d008
kolm1p          = $d009
kolm2p          = $d00a
kolm3p          = $d00b
hitclr          = $d01e
