#!/bin/bash

ENTRYPOINTS_USER=/usr/local/bin/entrypoint.d/user
if [ -d $ENTRYPOINTS_USER ]; then
    find $ENTRYPOINTS_USER -perm +1 -name '*.sh' | while read file; do
        source $file
    done
fi

exec ${@}
