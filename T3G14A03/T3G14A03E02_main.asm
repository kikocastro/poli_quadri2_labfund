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
UITOCH      <
HALF_PACK   <
;
&   /0000
MAIN                JP  INI
; Entradas / Saidas
;
;
; CHTOI
;
CHTOI_INPUT_1       K   /4552
CHTOI_INPUT_2       K   /524F
CHTOI_OUTPUT        K   /0000
;
; UITOCH
;
UITOCH_INPUT		    K	  /8000
UITOCH_OUTPUT_1 		K 	/0000
UITOCH_OUTPUT_2 		K 	/0000
; Programa
;
; PACK
;
INI                 LV UITOCH_INPUT ; Carrega o endereço de UITOCH_INPUT
    	              MM INPUT_1_PTR ; Armazena esse valor em INPUT_1_PTR

                    SC UITOCH ; Chama sub rotina UITOCH

                    LD OUTPUT_1 ; Carrega primeira palavra
                    MM UITOCH_OUTPUT_1 ; Salva na saida

                    LD OUTPUT_2 ; Carrega primeira palavra
                    MM UITOCH_OUTPUT_2 ; Salva na saida

                    LV CHTOI_INPUT_1 ; Carrega o endereço de CHTOI_INPUT_1
                    MM INPUT_1_PTR ; Armazena esse valor em INPUT_1_PTR

                    LV CHTOI_INPUT_2 ; Carrega o endereço de CHTOI_INPUT_2
                    MM INPUT_2_PTR ; Armazena esse valor em INPUT_2_PTR

                    SC CHTOI ; Chama sub rotina CHTOI

                    MM CHTOI_OUTPUT ; Salva na saida
END                 HM END
;
; Saidas
;
OUTPUT_1    K /0000 ; Endereco da entrada 1
OUTPUT_2    K /0000 ; Endereco da entrada 2
OUTPUT_3    K /0000 ; Endereco da entrada 3
;
# MAIN