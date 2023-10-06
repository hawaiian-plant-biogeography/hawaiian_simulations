NSIMS=100
for i in $(seq 1 $NSIMS);
do
    echo "Performing Simulation $i"
    PJFILE="../experiment1/pj_scripts/sim$i.pj"
    NAME="sample$i"
    gtimeout 3m pjcli $PJFILE -d -o ../experiment1/pj_output/ -f 'trs' -p $NAME
done