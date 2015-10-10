#!/bin/bash

# EX1
# Montador
java -cp MLR.jar montador.MvnAsm T3G14A05E01_main.asm
java -cp MLR.jar montador.MvnAsm T3G14A05E01_const.asm
java -cp MLR.jar montador.MvnAsm T3G14A05E01_rotinas.asm

# Linker
java -cp MLR.jar linker.MvnLinker T3G14A05E01_main.mvn T3G14A05E01_const.mvn T3G14A05E01_rotinas.mvn -s T3G14A05E01_final.mvn

# Relocador
java -cp MLR.jar relocator.MvnRelocator T3G14A05E01_final.mvn T3G14A05E01_final_relocated.mvn 0000 0000

