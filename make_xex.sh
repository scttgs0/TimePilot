
64tass  --m65816 \
        --atari-xex \
        -b \
        -o bootstrap.bin \
        bootstrap.asm

# 65816 intentional -- processor auto-detection

64tass  --m65816 \
        --atari-xex \
        -o timepilot.bin \
        --list=timepilot.lst \
        --labels=timepilot.lbl \
        timepilot.asm

cat     timepilot.bin \
        data/music/timepilot.rmt \
        bootstrap.bin \
        >timepilot.xex
