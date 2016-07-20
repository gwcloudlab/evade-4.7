#!/bin/bash

phoronix_ubuntu='~/.phoronix-test-suite/test-results'
phoronix_opensuse='/var/lib/phoronix-test-suite/test-results'

fn=$1

cp sudokut.opts sudokut-$fn.opts
echo "sudokut-$fn" >> sudokut-$fn.opts
echo "sudokut-$fn" >> sudokut-$fn.opts
echo "sudokut benchmark on $(hostname) with remus filename $fn" >> sudokut-$fn.opts
echo "n" >> sudokut-$fn.opts
phoronix-test-suite run sudokut < sudokut-$fn.opts
cd $phoronix_ubuntu
tar cfz sudokut-$fn-results.tar.gz sudokut-$fn-$i-out
scp sudokut-$fn-results.tar.gz sundarcs@nimbnode31:~/phoronix_out/
