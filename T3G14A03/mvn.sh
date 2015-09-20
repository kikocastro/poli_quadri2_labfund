#!/bin/bash

# EX1
# Montador
java -cp MLR.jar montador.MvnAsm T3G14A03E01_main.asm
java -cp MLR.jar montador.MvnAsm T3G14A03E01_const.asm
java -cp MLR.jar montador.MvnAsm T3G14A03E01_rotinas.asm

# Linker
java -cp MLR.jar linker.MvnLinker T3G14A03E01_main.mvn T3G14A03E01_const.mvn T3G14A03E01_rotinas.mvn -s T3G14A03E01_final.mvn

# Relocador
java -cp MLR.jar relocator.MvnRelocator T3G14A03E01_final.mvn T3G14A03E01_final_relocated.mvn 0000 0000

# EX2
# Montador
java -cp MLR.jar montador.MvnAsm T3G14A03E02_main.asm
java -cp MLR.jar montador.MvnAsm T3G14A03E02_const.asm
java -cp MLR.jar montador.MvnAsm T3G14A03E02_rotinas.asm

# Linker
java -cp MLR.jar linker.MvnLinker T3G14A03E02_main.mvn T3G14A03E02_const.mvn T3G14A03E02_rotinas.mvn -s T3G14A03E02_final.mvn

# Relocador
java -cp MLR.jar relocator.MvnRelocator T3G14A03E02_final.mvn T3G14A03E02_final_relocated.mvn 0000 0000

# EX3
# Montador
java -cp MLR.jar montador.MvnAsm T3G14A03E03_main.asm
java -cp MLR.jar montador.MvnAsm T3G14A03E03_const.asm
java -cp MLR.jar montador.MvnAsm T3G14A03E03_rotinas.asm

# Linker
java -cp MLR.jar linker.MvnLinker T3G14A03E03_main.mvn T3G14A03E03_const.mvn T3G14A03E03_rotinas.mvn -s T3G14A03E03_final.mvn

# Relocador
java -cp MLR.jar relocator.MvnRelocator T3G14A03E03_final.mvn T3G14A03E03_final_relocated.mvn 0000 0000