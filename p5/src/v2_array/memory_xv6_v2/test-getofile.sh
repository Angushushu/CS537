#! /bin/bash

if ! [[ -d v2 ]]; then
    echo "The v2 dir does not exist."
    echo "Your xv6 code should be in the v2 directory"
    echo "to enable the automatic tester to work."
    exit 1
fi

../tester/run-tests.sh $*
