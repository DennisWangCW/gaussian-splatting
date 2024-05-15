function rand(){
    min=$1
    max=$(($2-$min+1))
    num=$(date +%s%N)
    echo $(($num%$max+$min))  
}

port=$(rand 10000 30000)
unset all_proxy ALL_PROXY
alg_name=vallina_gs
iterations=40_000
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -l|--logdir) logdir="$2"; shift ;;
        -d|--data) data="$2"; shift ;;
        -r|--resolution) resolution="$2"; shift ;;
        --gpu) gpu="$2"; shift ;;
        --iterations) iterations="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

time=$(date "+%Y%m%d%H%M%S")

python train.py --eval --use_wandb -s ../data/inputs/${data} --iterations ${iterations} --port $port -m ../data/outputs/${data}/${alg_name}/$time --gpu ${gpu}
