#!/bin/sh

TRANSPARENT='#00000000'
INSIDE='#60606040'
VERIFYING='#207bb8ff'
WRONG='#800000ff'
IDLE='#282828ff'
CLICK='#404040ff'
BACKSPACE='#181818ff'
TEXT='#101010ff'
LINE='#10101080'

i3lock \
--blur 5 \
\
--insidever-color=$INSIDE \
--ringver-color=$VERIFYING \
\
--insidewrong-color=$INSIDE \
--ringwrong-color=$WRONG \
\
--inside-color=$INSIDE \
--ring-color=$IDLE \
--keyhl-color=$CLICK \
--bshl-color=$BACKSPACE \
--line-color=$LINE \
--separator-color='#101010ff' \
\
--verif-text="Unlocking" \
--wrong-text="Wrong Password" \
--lock-text="Locking" \
--noinput-text="No Input" \
--lockfailed-text="Failed to lock" \
\
--verif-color=$TEXT \
--wrong-color=$TEXT \
--modif-color=$TEXT \
--layout-color=$TEXT \
--time-color=$TEXT \
--date-color=$TEXT \
--greeter-color=$TEXT \
\
--time-str="%H:%M" \
--date-str="%d.%m.%Y %A" \
--time-size=40 \
--date-size=16 \
\
--ring-width 12 \
--radius 120 \
\
--indicator --clock
