exp_name="qylab"

resolution=-1
gpu=-1
iterations=100000 
type=merged_400_3_0.2

# example:

if [[ "$type" == *"merged"* ]]; then
    ./train.sh -d ${exp_name}/${type}/merged -l ${exp_name} -r ${resolution} --gpu ${gpu} --iterations ${iterations}
else 
    ./train.sh -d ${exp_name}/${type} -l ${exp_name} -r ${resolution} --gpu ${gpu} --iterations ${iterations}
fi