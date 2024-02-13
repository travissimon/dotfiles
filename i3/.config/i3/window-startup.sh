#!/bin/bash

i3-msg 'workspace "1: emacs"'
/usr/bin/alacritty -e emacs -nw &

sleep 5s

i3-msg 'workspace "2: chrome"'
google-chrome --profile-directory=Default &

sleep 1.5s

i3-msg 'workspace "3: firefox"'
firefox &

sleep 1.5s

i3-msg 'workspace "4: Regsoft"'
google-chrome --profile-directory="Profile 2"

sleep 1.5s

i3-msg 'workspace "5: terminals"';
/usr/bin/alacritty &
/usr/bin/alacritty &

sleep 1s

i3-msg 'workspace "6: term"';
/usr/bin/alacritty &

sleep 1s

i3-msg 'workspace "1: emacs"'

