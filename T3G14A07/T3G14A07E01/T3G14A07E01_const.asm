; Exporta constantes
;
LOAD        >
WRITE       >
SUBTRACT    >
GETDATA     >
PUTDATA     >

CONST_0                 >
CONST_1                 >
CONST_2                 >
CONST_7                 >
CONST_9                 >
CONST_A                 >
CONST_10                >
CONST_F                 >
CONST_30                >
CONST_3A                >
CONST_40                >
CONST_47                >
CONST_80                >
CONST_FF                >
CONST_100               >
CONST_300               >
CONST_FFE               >
CONST_1000              >
CONST_8000              >
CONST_FFFF              >

MEM_START   >
MEM_END     >
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
WRITE		            MM  /0000
SUBTRACT	        	-   /0000
GETDATA                 GD  /0000
PUTDATA                 PD  /0000
;
; ###################################
; Numeros
; ###################################
;
CONST_0                 K   /0000
CONST_1                 K   /0001
CONST_2                 K   /0002
CONST_7                 K   /0007
CONST_9                 K   /0009
CONST_A                 K   /000A
CONST_10                K   /0010
CONST_F                 K   /000F
CONST_30                K   /0030
CONST_3A                K   /003A
CONST_40                K   /0040
CONST_47                K   /0047
CONST_80                K   /0080
CONST_FF                K   /00FF
CONST_100               K   /0100
CONST_300               K   /0300
CONST_FFE               K   /0FFE
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
MEM_START               K       /0014 ; Inicio do intervalo determinado
MEM_END                 K       /0024 ; Fim do intervalo determinado

# LOAD