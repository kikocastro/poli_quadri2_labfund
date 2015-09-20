; Main
; 
; Importa/ Exporta
;
INPUT_1_PTR <
INPUT_2_PTR <
INPUT_3_PTR <

OUTPUT_1    >
OUTPUT_2    >
OUTPUT_3    >
;
; Rotinas
; 
PACK        <
UNPACK      <
MEMCPY      <
CHTOI       <
HALF_PACK   <
;
&   /0000
MAIN                JP  INI 
; ##############################################
; Entradas / Saidas
;
; PACK
;
PACK_INPUT_1        K   /00FA       ; 0002
PACK_INPUT_2        K   /00FF       ; 0004
PACK_OUTPUT         K   /0000       ; 0006
;
; UNPACK
;
UNPACK_INPUT        K   /8001       ; 0008
UNPACK_OUTPUT_1     K   /0000       ; 000A
UNPACK_OUTPUT_2     K   /0000       ; 000C
;
; MEMCPY
;
MEMCPY_SIZE         K   /0003       ; 000E
MEMCPY_ORIGIN       K   /0014       ; 0010
MEMCPY_DESTINATION  K   /001C       ; 0012
TEST_LIST			K   /0001		; 0014
					K	/0002	 	; 0016
					K	/0003		; 0018
					K	/0004		; 001A
					K	/FFFF		; 001C
					K	/FFFF		; 001E
					K	/FFFF	 	; 0020
					K	/FFFF	 	; 0022
					K	/FFFF	 	; 0024
; ##############################################
;
; Saidas
;
OUTPUT_1    K /0000 ; Endereco da entrada 1
OUTPUT_2    K /0000 ; Endereco da entrada 2
OUTPUT_3    K /0000 ; Endereco da entrada 3
;					
;
; Programa
; 
; PACK
;
INI                 LV PACK_INPUT_1 ; Carrega o endereço de PACK_INPUT_1
    	            MM INPUT_1_PTR ; Armazena esse valor em INPUT_1_PTR 
    	            LV PACK_INPUT_2 ; Carrega o endereço de PACK_INPUT_2
                    MM INPUT_2_PTR ; Armazena esse valor em INPUT_2_PTR
                    SC PACK ; Chama sub rotina PACK
                    MM PACK_OUTPUT ; Salva na saida
;
; UNPACK
;
                    LV UNPACK_INPUT ; Carrega o endereço de UNPACK_INPUT
    	            MM INPUT_1_PTR ; Armazena esse valor em INPUT_1_PTR 
    	            SC UNPACK ; Chama sub rotina UNPACK
    	            LD OUTPUT_1
                    MM UNPACK_OUTPUT_1 ; Salva na saida
                    LD OUTPUT_2
                    MM UNPACK_OUTPUT_2 ; Salva na saida
;
; MEMCPY
;
                    LV			MEMCPY_SIZE ; Carrega endereço de MEMCPY_SIZE
					MM			INPUT_1_PTR ; Salva no ponteiro
					LV			MEMCPY_ORIGIN ; Carrega endereço de MEMCPY_ORIGIN
					MM			INPUT_2_PTR ; Salva no ponteiro
					LV			MEMCPY_DESTINATION ; Carrega endereço de MEMCPY_DESTINATION
					MM			INPUT_3_PTR ; Salva no ponteiro
					SC 			MEMCPY ; Chama sub rotina MEMCPY

END                 HM INI
# MAIN