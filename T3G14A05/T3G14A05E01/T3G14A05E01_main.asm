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
GETLINEF    <
;
&   /0000
MAIN                JP  INI
; Entradas / Saidas
;
;
; GETLINEF
;
; Unidade logica
GL_UL                    K   /0002
; tamanho do buffer
GL_BUF                   K   /0004
; endereco do buffer
GL_END                   K   /0006
; Reserva enderecos do buffer
                         $   /0010
;
;
; Programa
;
;
INI                 LV GL_UL ; Carrega o endereço de GL_UL
    	              MM INPUT_1_PTR ; Armazena esse valor em INPUT_1_PTR
                    LV GL_BUF ; Carrega o endereço de GL_BUF
                    MM INPUT_2_PTR ; Armazena esse valor em INPUT_2_PTR
                    LV GL_END ; Carrega o endereço de GL_END
                    MM INPUT_3_PTR ; Armazena esse valor em INPUT_3_PTR

                    SC GETLINEF ; Chama sub rotina GETLINEF

END                 HM END
;
; Saidas
;
OUTPUT_1    K /0000 ; Endereco da entrada 1
OUTPUT_2    K /0000 ; Endereco da entrada 2
OUTPUT_3    K /0000 ; Endereco da entrada 3
;
# MAIN