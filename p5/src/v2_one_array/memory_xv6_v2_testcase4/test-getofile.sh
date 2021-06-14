#! /bin/bash

if ! [[ -d v2_testcase4 ]]; then
    echo "The v2_testcase4 dir does not exist."
    echo "Your xv6 code should be in the v2_testcase4 directory"
    echo "to enable the automatic tester to work."
    exit 1
fi

../tester/run-tests.sh $*
