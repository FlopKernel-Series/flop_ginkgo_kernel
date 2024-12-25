#!/bin/bash

# Delete temp files to prevent build system from complaining
rm -r include/config
# Wrap to ckbuild.sh
export WP=${WP:-$(realpath $PWD/../)}

bash ckbuild.sh "$@"
