#!/usr/bin/env bash
cd src
javac -d ../out -cp exp/*.java
cd ../out
java -cp . exp.MakeScripts
