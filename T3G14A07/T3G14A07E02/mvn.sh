#!/bin/bash

# EX1
# Montador
java -cp MLR.jar montador.MvnAsm T3G14A07E02_main.asm
java -cp MLR.jar montador.MvnAsm T3G14A07E02_const.asm
java -cp MLR.jar montador.MvnAsm T3G14A07E02_rotinas.asm

# Linker
java -cp MLR.jar linker.MvnLinker T3G14A07E02_main.mvn T3G14A07E02_const.mvn T3G14A07E02_rotinas.mvn -s T3G14A07E02_final.mvn

# Relocador
java -cp MLR.jar relocator.MvnRelocator T3G14A07E02_final.mvn out.mvn 0000 0000

