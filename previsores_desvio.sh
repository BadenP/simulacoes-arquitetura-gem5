#!/bin/bash


echo "Insira o nome/id do seu container para que possamos invocar o gem5 no docker: "
read container_id
sudo docker run -it $container_id /bin/bash -c '

programs=("trisolv" "mvt")
inputs=("MEDIUM_DATASET" "LARGE_DATASET")
configs_cpu=("4" "12")
previsores=("LocalBP" "BiModeBP")

cd gem5

if [ ! -d "PolyBenchC-4.2.1" ]; 
then git clone https://github.com/MatthiasJReisinger/PolyBenchC-4.2.1.git
fi

cd PolyBenchC-4.2.1

gcc -I utilities -I linear-algebra/kernels/mvt utilities/polybench.c -DMEDIUM_DATASET linear-algebra/kernels/mvt/mvt.c -o mvt_MEDIUM_DATASET -lm

gcc -I utilities -I linear-algebra/kernels/mvt utilities/polybench.c -DLARGE_DATASET linear-algebra/kernels/mvt/mvt.c -o mvt_LARGE_DATASET -lm

gcc -I utilities -I linear-algebra/solvers/trisolv utilities/polybench.c -DMEDIUM_DATASET linear-algebra/solvers/trisolv/trisolv.c -o trisolv_MEDIUM_DATASET -lm

gcc -I utilities -I linear-algebra/solvers/trisolv utilities/polybench.c -DLARGE_DATASET linear-algebra/solvers/trisolv/trisolv.c -o trisolv_LARGE_DATASET -lm

cd ..

#Simulação de Previsores de Desvio
for program in "${programs[@]}"; do
    for input in "${inputs[@]}"; do
    	for previsor in "${previsores[@]}"; do
		cmd="build/X86/gem5.fast configs/example/se.py --cmd=PolyBenchC-4.2.1/${program}_${input} --cpu-type=O3CPU --bp-type=$previsor --caches --l2cache --l1d_size=32kB --l1i_size=32kB --l2_size=128kB --l2_assoc=4 --output=${program}_${input}_${previsor}"
		eval $cmd
		echo "Simulação completa de $program com entrada $input e previsor $previsor."
	done
    done
done

echo "Todas as simulações foram finalizadas"

#Falta pegar os arquivos de saída e salvar na máquina

#sudo docker cp relaxed_keller:/home/simulator/gem5/m5out/mvtb_MINI_DATASET ~/Desktop/saidaaa.txt
'

