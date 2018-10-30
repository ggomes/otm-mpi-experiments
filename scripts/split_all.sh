#!/bin/bash
cd $OTMMPIHOME/src/main/java
javac -d $OTMMPIHOME/out_javac -cp $OTMSIMJAR:$OTMMPIHOME/lib/* metis/*.java metagraph/*.java translator/*.java xmlsplitter/*.java
cd $OTMMPIHOME/out_javac
mkdir -p /home/gomes/code/otm-mpi-experiments/split_files/100/1
java -cp $OTMSIMJAR:$OTMMPIHOME/lib/*:. xmlsplitter.XMLSplitter $HOME/code/otm-mpi-experiments/split_files/100/1/100_1 $HOME/code/otm-mpi-experiments/cfg/100.xml 1
mkdir -p /home/gomes/code/otm-mpi-experiments/split_files/100/2
java -cp $OTMSIMJAR:$OTMMPIHOME/lib/*:. xmlsplitter.XMLSplitter $HOME/code/otm-mpi-experiments/split_files/100/2/100_2 $HOME/code/otm-mpi-experiments/cfg/100.xml 2
mkdir -p /home/gomes/code/otm-mpi-experiments/split_files/100/4
java -cp $OTMSIMJAR:$OTMMPIHOME/lib/*:. xmlsplitter.XMLSplitter $HOME/code/otm-mpi-experiments/split_files/100/4/100_4 $HOME/code/otm-mpi-experiments/cfg/100.xml 4
mkdir -p /home/gomes/code/otm-mpi-experiments/split_files/100/8
java -cp $OTMSIMJAR:$OTMMPIHOME/lib/*:. xmlsplitter.XMLSplitter $HOME/code/otm-mpi-experiments/split_files/100/8/100_8 $HOME/code/otm-mpi-experiments/cfg/100.xml 8
mkdir -p /home/gomes/code/otm-mpi-experiments/split_files/100/16
java -cp $OTMSIMJAR:$OTMMPIHOME/lib/*:. xmlsplitter.XMLSplitter $HOME/code/otm-mpi-experiments/split_files/100/16/100_16 $HOME/code/otm-mpi-experiments/cfg/100.xml 16
mkdir -p /home/gomes/code/otm-mpi-experiments/split_files/100/32
java -cp $OTMSIMJAR:$OTMMPIHOME/lib/*:. xmlsplitter.XMLSplitter $HOME/code/otm-mpi-experiments/split_files/100/32/100_32 $HOME/code/otm-mpi-experiments/cfg/100.xml 32
mkdir -p /home/gomes/code/otm-mpi-experiments/split_files/62500/16
java -cp $OTMSIMJAR:$OTMMPIHOME/lib/*:. xmlsplitter.XMLSplitter $HOME/code/otm-mpi-experiments/split_files/62500/16/62500_16 $HOME/code/otm-mpi-experiments/cfg/62500.xml 16
mkdir -p /home/gomes/code/otm-mpi-experiments/split_files/62500/32
java -cp $OTMSIMJAR:$OTMMPIHOME/lib/*:. xmlsplitter.XMLSplitter $HOME/code/otm-mpi-experiments/split_files/62500/32/62500_32 $HOME/code/otm-mpi-experiments/cfg/62500.xml 32
mkdir -p /home/gomes/code/otm-mpi-experiments/split_files/62500/64
java -cp $OTMSIMJAR:$OTMMPIHOME/lib/*:. xmlsplitter.XMLSplitter $HOME/code/otm-mpi-experiments/split_files/62500/64/62500_64 $HOME/code/otm-mpi-experiments/cfg/62500.xml 64
mkdir -p /home/gomes/code/otm-mpi-experiments/split_files/62500/128
java -cp $OTMSIMJAR:$OTMMPIHOME/lib/*:. xmlsplitter.XMLSplitter $HOME/code/otm-mpi-experiments/split_files/62500/128/62500_128 $HOME/code/otm-mpi-experiments/cfg/62500.xml 128
mkdir -p /home/gomes/code/otm-mpi-experiments/split_files/10000/4
java -cp $OTMSIMJAR:$OTMMPIHOME/lib/*:. xmlsplitter.XMLSplitter $HOME/code/otm-mpi-experiments/split_files/10000/4/10000_4 $HOME/code/otm-mpi-experiments/cfg/10000.xml 4
mkdir -p /home/gomes/code/otm-mpi-experiments/split_files/10000/8
java -cp $OTMSIMJAR:$OTMMPIHOME/lib/*:. xmlsplitter.XMLSplitter $HOME/code/otm-mpi-experiments/split_files/10000/8/10000_8 $HOME/code/otm-mpi-experiments/cfg/10000.xml 8
mkdir -p /home/gomes/code/otm-mpi-experiments/split_files/10000/16
java -cp $OTMSIMJAR:$OTMMPIHOME/lib/*:. xmlsplitter.XMLSplitter $HOME/code/otm-mpi-experiments/split_files/10000/16/10000_16 $HOME/code/otm-mpi-experiments/cfg/10000.xml 16
mkdir -p /home/gomes/code/otm-mpi-experiments/split_files/10000/32
java -cp $OTMSIMJAR:$OTMMPIHOME/lib/*:. xmlsplitter.XMLSplitter $HOME/code/otm-mpi-experiments/split_files/10000/32/10000_32 $HOME/code/otm-mpi-experiments/cfg/10000.xml 32
mkdir -p /home/gomes/code/otm-mpi-experiments/split_files/10000/64
java -cp $OTMSIMJAR:$OTMMPIHOME/lib/*:. xmlsplitter.XMLSplitter $HOME/code/otm-mpi-experiments/split_files/10000/64/10000_64 $HOME/code/otm-mpi-experiments/cfg/10000.xml 64
mkdir -p /home/gomes/code/otm-mpi-experiments/split_files/10000/128
java -cp $OTMSIMJAR:$OTMMPIHOME/lib/*:. xmlsplitter.XMLSplitter $HOME/code/otm-mpi-experiments/split_files/10000/128/10000_128 $HOME/code/otm-mpi-experiments/cfg/10000.xml 128
mkdir -p /home/gomes/code/otm-mpi-experiments/split_files/2500/1
java -cp $OTMSIMJAR:$OTMMPIHOME/lib/*:. xmlsplitter.XMLSplitter $HOME/code/otm-mpi-experiments/split_files/2500/1/2500_1 $HOME/code/otm-mpi-experiments/cfg/2500.xml 1
mkdir -p /home/gomes/code/otm-mpi-experiments/split_files/2500/2
java -cp $OTMSIMJAR:$OTMMPIHOME/lib/*:. xmlsplitter.XMLSplitter $HOME/code/otm-mpi-experiments/split_files/2500/2/2500_2 $HOME/code/otm-mpi-experiments/cfg/2500.xml 2
mkdir -p /home/gomes/code/otm-mpi-experiments/split_files/2500/4
java -cp $OTMSIMJAR:$OTMMPIHOME/lib/*:. xmlsplitter.XMLSplitter $HOME/code/otm-mpi-experiments/split_files/2500/4/2500_4 $HOME/code/otm-mpi-experiments/cfg/2500.xml 4
mkdir -p /home/gomes/code/otm-mpi-experiments/split_files/2500/8
java -cp $OTMSIMJAR:$OTMMPIHOME/lib/*:. xmlsplitter.XMLSplitter $HOME/code/otm-mpi-experiments/split_files/2500/8/2500_8 $HOME/code/otm-mpi-experiments/cfg/2500.xml 8
mkdir -p /home/gomes/code/otm-mpi-experiments/split_files/2500/16
java -cp $OTMSIMJAR:$OTMMPIHOME/lib/*:. xmlsplitter.XMLSplitter $HOME/code/otm-mpi-experiments/split_files/2500/16/2500_16 $HOME/code/otm-mpi-experiments/cfg/2500.xml 16
mkdir -p /home/gomes/code/otm-mpi-experiments/split_files/2500/32
java -cp $OTMSIMJAR:$OTMMPIHOME/lib/*:. xmlsplitter.XMLSplitter $HOME/code/otm-mpi-experiments/split_files/2500/32/2500_32 $HOME/code/otm-mpi-experiments/cfg/2500.xml 32
mkdir -p /home/gomes/code/otm-mpi-experiments/split_files/2500/64
java -cp $OTMSIMJAR:$OTMMPIHOME/lib/*:. xmlsplitter.XMLSplitter $HOME/code/otm-mpi-experiments/split_files/2500/64/2500_64 $HOME/code/otm-mpi-experiments/cfg/2500.xml 64
mkdir -p /home/gomes/code/otm-mpi-experiments/split_files/2500/128
java -cp $OTMSIMJAR:$OTMMPIHOME/lib/*:. xmlsplitter.XMLSplitter $HOME/code/otm-mpi-experiments/split_files/2500/128/2500_128 $HOME/code/otm-mpi-experiments/cfg/2500.xml 128
