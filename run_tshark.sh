
    echo "Tshaks started"

    while [ 1 ]
    do
	    Fname=`date +%m%d%Y%H%M%S`
	    Fname="Source/Tshark_$Fname.out"
	    sudo -S <<< "Druti@143" ~/WireShark/wireshark-2.0.4/tshark -f "udp port 4729" -i any -g -V > $Fname &


	    echo "Out File Name $Fname"
	    sleep 5
	    sudo -S <<< "Druti@143" kill -9 `ps -fu root | grep "tshark" | awk -F " " '{print $2}'`^C

    done
