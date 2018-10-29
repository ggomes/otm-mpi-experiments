#!/bin/bash
cd src
javac -d ../out exp/*.java
cd ../out
java exp/GenerateTaskFarmer
