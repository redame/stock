#!/bin/sh

python train.py --data_dir data/dazai \
    --checkpoint_dir cv/dazai \
    --rnn_size 1024 --gpu -1 --enable_checkpoint False
#    --checkpoint_dir /media/tajima/New\ Volume/cv/dazai \
#    --init_from "$1"

