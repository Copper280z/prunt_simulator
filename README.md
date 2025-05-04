# Setup
  - Clone the Prunt repo into a directory next to this one. 
  - install alr
  - run `alr with are` to install a dependency
  - make sure npm is installed
  - `alr build`

# Running with plotted output
This is broken right now, the C callbacks don't print in the same format.

    stdbuf -oL -eL ./bin/prunt_simulator | stdbuf -oL -eL awk '/DATA OUTPUT,/ {print > "/dev/stdout"} !/DATA OUTPUT,/ {print > "/dev/stderr"}' | stdbuf -oL -eL python3 ./continuous_plot.py
