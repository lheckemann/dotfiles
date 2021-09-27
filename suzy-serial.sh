#!/usr/bin/env bash

tmux new-window "picocom /dev/suzy-AP" \; split-window -h "picocom /dev/suzy-Shell" \; split-window -v "picocom /dev/suzy-EC"
