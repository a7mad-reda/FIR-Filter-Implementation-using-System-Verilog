# load saved signals to nwave window and maximize it
wvCreateWindow
wvRestoreSignal -win $_nWave2 \
           "./signal.rc" \
           -overWriteAutoAlias on -appendSignals on
verdiWindowBeWindow -win $_nWave2
wvResizeWindow -win $_nWave2 -1 27 1914 831

