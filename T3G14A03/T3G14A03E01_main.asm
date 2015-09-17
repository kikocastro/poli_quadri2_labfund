; Main
; 
; Importa/ Exporta
;
; PACK
PACK <
PACK_INPUT_1_PTR <
PACK_INPUT_2_PTR <
PACK_OUTPUT >
; 
; UNPACK
UNPACK <
UNPACK_INPUT_PTR <
UNPACK_OUTPUT_1 >
UNPACK_OUTPUT_2 >
;
; MEMCPY
MEMCPY <
MEMCPY_ORIGIN_PTR <
MEMCPY_DESTINATION_PTR <
MEMCPY_SIZE_PTR <
;
; 
&   /0000
MAIN                JP  INI
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
MEMCPY_DESTINATION  K   /001c       ; 0012
TEST_LIST			K   /0001		; 0014
					K	/0002	 	; 0016
					K	/0003		; 0018
					K	/0004		; 001A
					K	/FFFF		; 001C
					K	/FFFF		; 001E
					K	/FFFF	 	; 0020
					K	/FFFF	 	; 0022
					K	/FFFF	 	; 0024
;
; Programa
; 
; PACK
;
INI                 LV PACK_INPUT_1 ; Carrega o endereço de PACK_INPUT_1
    	            MM PACK_INPUT_1_PTR ; Armazena esse valor em PACK_INPUT_1_PTR 
    	            LV PACK_INPUT_2 ; Carrega o endereço de PACK_INPUT_2
                    MM PACK_INPUT_2_PTR ; Armazena esse valor em PACK_INPUT_2_PTR
                    SC PACK ; Chama sub rotina PACK
                    MM PACK_OUTPUT ; Salva na saida
;
; UNPACK
;
                    LV UNPACK_INPUT ; Carrega o endereço de UNPACK_INPUT
    	            MM UNPACK_INPUT_PTR ; Armazena esse valor em UNPACK_INPUT_PTR 
    	            SC UNPACK ; Chama sub rotina UNPACK
;
; MEMCPY
;
                    LV			MEMCPY_SIZE ; Carrega endereço de MEMCPY_SIZE
					MM			MEMCPY_SIZE_PTR ; Salva no ponteiro
					LV			MEMCPY_ORIGIN ; Carrega endereço de MEMCPY_ORIGIN
					MM			MEMCPY_ORIGIN_PTR ; Salva no ponteiro
					LV			MEMCPY_DESTINATION ; Carrega endereço de MEMCPY_DESTINATION
					MM			MEMCPY_DESTINATION_PTR ; Salva no ponteiro
					SC 			MEMCPY ; Chama sub rotina MEMCPY

END                 HM END
# MAIN