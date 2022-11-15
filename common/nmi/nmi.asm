
; NMI + few procedures
; this block of code MAY not be longer than $ad60-$adde

;--------------------------------------
;--------------------------------------
                * = nmiHandler
;--------------------------------------

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Non-Maskable Interrupt Handler
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
NMI             .proc
                bit nmist               ; what interruption VBL or DLI ?
                bpl no

DLI             jmp dull

no              sta nmist
VBL             jmp dull

dull            rti
                .endproc


; .align $100
; warning: it MAY NOT cross page boundary (example $31f8 ->$3208)
; it is included at ~$ad60
bufDLIJumps
                .word DLI0
                .word DLI1
                .word DLI2
                .word DLI3
                .word DLI4

bufDLIJumpsLevelStart
                .word DLI0
                .word DLI1b
                .word DLI2
                .word DLI3b
                .word DLI4b

bufDLIJumpsGameOver
                .word DLI0
                .word DLI1c
                .word DLI2
                .word DLI3b
                .word DLI4b


;======================================
;
;======================================
enableNMI       .proc
                lda #<NMI
                sta $fffa
                lda #>NMI
                sta $fffb

                lda #$c0
                sta nmien
                rts
                .endproc


; Various waitFrame procedures


;======================================
;
;======================================
waitJoyXFrames  .proc
                jsr waitFrameNormal

                dex
                beq _XIT

                lda porta
                eor #$ff
                and #$f
                cmp #1
                beq _XIT

                cmp #2
                beq _XIT

                cmp #4
                beq _XIT

                lda trig0
                beq _XIT
                bne waitJoyXFrames

_XIT            rts
                .endproc


;======================================
;--------------------------------------
; X = how many frames to wait
;======================================
waitXFrames     .proc
                jsr waitFrameNormal

                dex
                bne waitXFrames

                rts
                .endproc


;======================================
;
;======================================
waitFrame       .proc
l1              lda vcount
                cmp #engineWaitFrameVcount
                bcc l1

                rts
                .endproc


;======================================
;
;======================================
waitFrameNormal .proc
l1              lda vcount
                bne l1

l2              lda vcount
                beq l2

                rts
                .endproc

; this block of code MAY not be longer than $ad60-$adde
