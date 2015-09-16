#!/bin/bash

# Montador
java -cp MLR.jar montador.MvnAsm T3G14A03E01_main.asm
java -cp MLR.jar montador.MvnAsm T3G14A03E01_const.asm
java -cp MLR.jar montador.MvnAsm T3G14A03E01_rotinas.asm

# Linker
java -cp MLR.jar linker.MvnLinker T3G14A03E01_main.mvn
java -cp MLR.jar linker.MvnLinker T3G14A03E01_const.mvn
java -cp MLR.jar linker.MvnLinker T3G14A03E01_rotinas.mvn

