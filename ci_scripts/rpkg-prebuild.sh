#!/bin/bash
#
# This needs to live side by side with edk2 in order to simulate
# a typical repo sync of the fw tree.  The edk2 Makefile assumes ../edk2-platforms
git clone --depth 1 --branch rivos/main $GITLAB_SWINT_URL/fw/cpu/edk2-platforms.git $REPO_ROOT/rv/sw/int/fw/cpu/edk2-platforms
