#!/bin/sh
# Action to be done when playing
# Save volume level
# Turn volume up
# Play the file
play /tmp/random.mp3
# Acquire new file
./getrandommp3fromhtdir.pl http://example.com/path/to/mp3s/
# Restore saved volume level
