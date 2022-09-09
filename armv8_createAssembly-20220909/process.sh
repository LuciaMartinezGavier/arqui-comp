make 

LONG=$(cat main.list | grep -oP '\t[0-9a-f]{8}' | wc -l)

#cat main.list | grep -oP '\t[0-9a-f]{8}' | awk -v awkvar="$LONG" '{print awkvar}'

cat main.list | grep -oP '\t[0-9a-f]{8}' | awk -v awkvar="$LONG" '{if (NR==1) {print "ROM [0:" awkvar-1 "] =\x27{32\x27h" $1 ","} else { if (NR==awkvar){print "32\x27h" $1 "};"} else {print "32\x27h" $1 ","}}}'


