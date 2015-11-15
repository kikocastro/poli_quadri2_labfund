java -cp MLR.jar montador.MvnAsm T3G14A10E01_main.asm
java -cp MLR.jar montador.MvnAsm T3G14A10E01_const.asm
java -cp MLR.jar montador.MvnAsm T3G14A10E01_rotinas.asm
java -cp MLR.jar montador.MvnAsm prog10.asm


java -cp MLR.jar linker.MvnLinker T3G14A10E01_main.mvn T3G14A10E01_const.mvn T3G14A10E01_rotinas.mvn prog10.mvn -s T3G14A10E01_final.mvn

java -cp MLR.jar relocator.MvnRelocator T3G14A10E01_final.mvn o.mvn 0000 0000
pause

