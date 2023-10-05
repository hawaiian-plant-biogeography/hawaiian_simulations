NSIMS=1
for i in $(seq 1 $NSIMS);
do
    echo "Performing Simulation $i"
    PJFILE="../experiment1/pj_scripts/sim$i.pj"
    NAME="sample$i"
    gtimeout 10m pjcli $PJFILE -d -o pj_output/ -f 'trs' -p $NAME
done