#! /bin/bash

set -x
set -e

start=26
end=33

j=0


for i in $(seq $start $end); do
	(( j = i + 4))
	cp -f ~cs537-1/handin/dyf/p6/map___reduce/tests-out/$i.out tests/$i.out
	#cp -f tests/$j.out tests/$i.out
	#cp -f tests/$j.err tests/$i.err
	#cp -f tests/$j.desc tests/$i.desc
	#cp -f tests/$j.run tests/$i.run
done
