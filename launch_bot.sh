#!/bin/bash
#
#
echo "Launching ricer and check to reboot it anytime"

# Change to this script dir
cd $(cd -P -- "$(dirname -- "$0")" && pwd -P)


launch=true

while true
  
  if $launch
    $launch=false
    reboot=bundle_exec rake ricer:start
  fi
  
  if reboot
    launch=true
  else
    # check wget or something else
    sleep 10
    # wget... 
  fi
  
end
