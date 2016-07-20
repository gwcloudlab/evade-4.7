#!/bin/bash

echo -e "\n*** Running iperf script ***\n"
./remus_iperf_script.sh
sleep 15
echo -e "\n*** Running httperf script ***\n"
./remus_httperf_script.sh
echo -e "\n*** Running phoronix script ***\n"
./remus_phoronix_script.sh
echo -e "\n*** Running sysbench script ***\n"
./remus_sysbench_script.sh
echo -e "\n*** Running mbw script ***\n"
./remus_mbw_script.sh
echo -e "\n*** DONE! ***\n"
