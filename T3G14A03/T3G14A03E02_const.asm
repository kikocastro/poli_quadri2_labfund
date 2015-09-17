; Exporta constantes
;
LOAD        >   
WRITE       >

CONST_0     >                
CONST_1     >               
CONST_2     >  
CONST_80    >
CONST_100   >              
CONST_1000  >
CONST_8000  >
CONST_FFFF  >

RANGE_START >
RANGE_END   >
;
;
& /0000 ; Origem relocavel
;
;
; CONSTANTES
;
; ###################################
; Operacoes
; ###################################
;
LOAD                    LD  /0000
WRITE		        	MM  /0000
;
; ###################################
; Numeros
; ###################################
;
CONST_0                 K   /0000
CONST_1                 K   /0001
CONST_2                 K   /0002
CONST_80                K   /0080
CONST_100               K   /0100
CONST_1000              K   /1000
CONST_8000              K   /8000
CONST_FFFF  			K   /FFFF
;
;
; ###################################
; Sub rotinas
; ###################################
;
; Limite de memoria para aa sequencia de UNPACK
RANGE_START             K       /0014 ; Inicio do intervalo determinado
RANGE_END               K       /0024 ; Fim do intervalo determinado

# LOAD