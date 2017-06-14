#!/bin/bash

if [ -f /usr/local/bin/entrypoint.d/user/*.sh ]; then
    source /usr/local/bin/entrypoint.d/user/*.sh
fi

exec ${@}
