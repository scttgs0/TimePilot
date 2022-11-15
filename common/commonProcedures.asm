
;======================================
;
;======================================
copyText        .proc
                sta color+1
                stx zp_CopyFrom
                sty zp_CopyFrom+1

                lda #<bufScreenTxt
                sta copyTo+1
                lda #>bufScreenTxt
                sta copyTo+2

                ldy #0
                lda (zp_CopyFrom),y
                tax
                iny
                lda (zp_CopyFrom),y
                tay
                beq start

posy            .adw copyTo+1,#20
                dey
                bne posy

start           ldy #2
copy            lda (zp_CopyFrom),y
                cmp #3                  ; ' # '
                beq done

color           ora #%01000000
copyTo          sta bufScreenTxt,x
                inx
                iny
                bne copy                ;!

done            rts
                .endproc


;======================================
;
;======================================
clearBufPM      .proc
                lda #0
                tax
loop            sta bufPM0,x
                sta bufPM2,x

                inx
                bne loop

                rts
                .endproc


;======================================
;
;======================================
clearBufScreenTxt ;--.proc
                lda #0
                tax
lo              sta bufScreenTxt,x
                sta bufScreenTxt+$100,x

                inx
                bne lo
                rts
                ;--.endproc


;--------------------------------------
;
;--------------------------------------
loaderFadeOut   ;--.proc
                ldy #15
continue        ldx #2
loop            lda 708,x
                and #$f
                beq next

                dec 708,x
next            dex
                bpl loop

                jsr waitFrameNormal
                jsr waitFrameNormal
                jsr waitFrameNormal

                dey
                bne continue

                lda #0
                sta 708
                sta 709
                sta 710
                jmp waitFrameNormal

                ;--.endproc


;======================================
;returns $80 for 65c816 and $00 for 6502
;======================================
detectCPU       .proc
                lda #$99
                clc
                sed
                adc #$01
                cld
                beq CPU_CMOS

CPU_02          lda #0
                sta rapidusDetected
                rts

CPU_CMOS        lda #0
                rep #%00000010          ; reset the bit with
                beq CPU_02

CPU_C816        lda #$80
                sta rapidusDetected
                rts
                .endproc


;======================================
; temporary solution for BOSS sound -
; if boss on screen we replay boss sound
; (because 'changeSong' resets it and we
; use changeSong for parachute
; pickup/additional life)
;======================================
fixBossSound    .proc
                lda levelCurrent.toKill
                bne _XIT

                lda levelCurrent.enemyBossHP
                beq _XIT

                ldy gameCurrentLevel
                dey
                ldx SPAWN.boss.soundNumber,y
                ldy #SPAWN.boss.soundNote
                stx soundSystem.soundChannelSFX+2
                sty soundSystem.soundChannelNote+2
_XIT            rts
                .endproc


;--------------------------------------
; new level values for rapidus (agility,
; periodicity, rotation delays etc)
;--------------------------------------
rapidusLevelValues .proc
                lda #<levelInformation.rapidusLevelRotationDelayMin
                sta zp_CopyFrom
                lda #>levelInformation.rapidusLevelRotationDelayMin
                sta zp_CopyFrom+1

                lda #<levelInformation.levelRotationDelayMin
                sta zp_CopyTo
                lda #>levelInformation.levelRotationDelayMin
                sta zp_CopyTo+1

                ldy #45-1
;   fall through (instead of jmp memCopyShort)
                .endproc


;======================================
; SIMPLE MEMCOPY
;--------------------------------------
; Y             block lenght (max 128 bytes)
; zp_CopyFrom   source
; zp_CopyTo     destination
;======================================
memCopyShort    .proc
loop            lda (zp_CopyFrom),y
                sta (zp_CopyTo),y

                dey
                bpl loop

                rts
                .endproc


;--------------------------------------
; new level values for rapidus (agility,
; periodicity, rotation delays etc)
;--------------------------------------
prepareGlobalVelocity .proc
                lda #<OLP.globalVelocityTab
                sta zp_CopyFrom
                lda #>OLP.globalVelocityTab
                sta zp_CopyFrom+1

                lda #<globalVelocityBuffer
                sta zp_CopyTo
                lda #>globalVelocityBuffer
                sta zp_CopyTo+1

                ldy #64-1
                bne memCopyShort

                .endproc


;======================================
;
;======================================
disableOS       .proc
                lda #0
                sta nmien               ; NMI off
                sei                     ; IRQ off
                lda #$fe                ; RAM under ROM on | OS off
                sta portb
                rts
                .endproc


;--------------------------------------
; Add to WORD
;--------------------------------------
adw             .macro addr,val
                clc
                lda \addr
                adc \val
                sta \addr
                bcc _1

                inc \addr+1
_1
                .endmacro


;--------------------------------------
; Subtract from WORD
;--------------------------------------
sbw             .macro addr,val
                sec
                lda \addr
                sbc \val
                sta \addr

                lda \addr+1
                sbc \val+1
                sta \addr+1
                .endmacro

;--------------------------------------
; Subtract from WORD immediate value
;--------------------------------------
sbwv            .macro addr,val
                sec
                lda \addr
                sbc \val
                sta \addr

                bcs +
                dec \addr+1
+
                .endmacro
