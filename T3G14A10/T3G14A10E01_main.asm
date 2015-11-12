DUMPER 		<
DUMP_INI 	<
DUMP_TAM 	<
DUMP_UL 	<
DUMP_BL 	<
DUMP_EXE 	<
;
LOADER	  	<
LOADER_UL 	<
;
CHTOI		<
INPUT_1_PTR	<
INPUT_2_PTR	<
;
GETDATA 	<
;
CONST_1 	<
CONST_2 	<
CONST_300	<
CONST_FFFC	<
CONST_FFFE	<
CONST_FFFF	<
;
WORD_BARS 		<
WORD_BARS_END	<
WORD_JB			<
WORD_DU			<
WORD_LO			<
WORD_SPACES		<
WORD_EOL		<
WORD_EOF 		<
;
		& 	/0000
MAIN	JP 	INI		; salta para o início do programa
UL		K 	/0000 	; parâmetro: UL onde está o arquivo de batch
;
INI 		SC 	MAIN_RESET
			; Leitura de JB
			SC 	READ_CMD
			- 	CONST_1
			JZ 	GET_CMD
			JP	ERRO_JB
			; Leitura de DU, LO ou /* (final)
GET_CMD		SC 	READ_CMD
			JZ 	ERRO_CMD
			-	CONST_2
			JZ 	GET_ARGS_DU
			-	CONST_1
			JZ	GET_ARGS_LO
			-	CONST_1
			JZ	DONE_OK
			JP	ERRO_FIM
;
			; Leitura dos parametros de DU
GET_ARGS_DU	SC 	READ_ARGS_DU
			JZ	ERRO_ARG
			SC	DUMPER
			JP	GET_CMD
			; Leitura dos parametros de LO
GET_ARGS_LO	SC 	READ_ARGS_LO
			JZ	ERRO_ARG
			LD 	LOADER_UL
			SC	LOADER
			; O codigo abaixo deveria tratar os erros de LOAD (memoria insuficiente ou erro de checksum)
			; Todavia nao tratamos erros aqui, pois nos foi permitido assumir que as entradas estarao corretas
			-	CONST_FFFE
			JZ	ERRO_LO_FFFE
CONTINUE1	+	CONST_FFFE
			-	CONST_FFFC
			JZ	ERRO_LO_FFFC
CONTINUE2	JP	GET_CMD
;
ERRO_LO_FFFE	JP	CONTINUE1 ; Houve erro do tipo FFFE (falta de memória disponível pra load)
ERRO_LO_FFFC	JP	CONTINUE2 ; Houve erro do tipo FFFC (checksum error) no Loader
;
ERRO_JB		LV	/0001
			OS	/00EE
			JP	FIM
ERRO_CMD	LV	/0002
			OS 	/00EE
			JP	FIM
ERRO_ARG	LV	/0003
			OS 	/00EE
			JP	FIM
ERRO_FIM	LV	/0004
			OS 	/00EE
			JP	FIM
DONE_OK		LV	/0000
			OS	/00EE
			JP	FIM
FIM 	 	HM	FIM		; fim do programa
;
; ###################################
; MAIN_RESET
; ###################################
;
; Reseta variaveis da main
;
MAIN_READ_WORD 	K 	/0000
;
MAIN_RESET 	K       /0000
			LD      UL
			+       CONST_300
			+       GETDATA
			MM      MAIN_READ_WORD
			RS 		MAIN_RESET
;
; ###################################
; GETWORD
; ###################################
;
; Escanea um par de caracteres ASCII, salvando-os no acumulador
;
GETWORD 	K       /0000
			LD      MAIN_READ_WORD
			MM		GW_NEXT
GW_NEXT		K 		/0000
			RS 		GETWORD
;
; ###################################
; GETPARAM
; ###################################
;
; Escanea dois pares de caracteres ASCII e os converte ao hexadecimal correspondente, salvando-o no acumulador
;
GP_IN_1 	K		/0000
GP_IN_2 	K		/0000
;
GETPARAM 	K       /0000
			SC 		GETWORD
			- 		WORD_EOL
			JZ 		GP_ERRO
			+ 		WORD_EOL
			-		WORD_EOF
			JZ		GP_ERRO
			+ 		WORD_EOF
			MM 		GP_IN_1
			SC 		GETWORD
			MM 		GP_IN_2
;			
			LV		GP_IN_1
			MM 		INPUT_1_PTR
			LV		GP_IN_2
			MM 		INPUT_2_PTR
			SC 		CHTOI
			JP		GP_END
; GP_ERRO 	LD 		CONST_FFFF ; FFFF pode ser retorno do parametro EXE (instr. executavel) do DUMPER
GP_ERRO 	RS 		GETPARAM
GP_END		RS 		GETPARAM
;
; ###################################
; READ_CMD
; ###################################
;
; Le uma linha do batch. Retorna 1, 2, 3 se leu JB, DU ou LO, respectivamente
; Retorna 4 se leu /* (final)
; Retorna 0 em caso de erro (ausência de quebra de linha também produzirá erro)
;
ANS			K 		/0000 ; Valor de retorno da sub-rotina
;
READ_CMD	K       /0000
			SC		GETWORD
			-		WORD_BARS
			JZ		RC_BARS ; Escaneou o "//"
			+ 		WORD_BARS
			- 		WORD_BARS_END
			JZ		RC_FINAL ; Escaneou o "/*"
			JP		RC_ERRO
RC_BARS		SC 		GETWORD
			-		WORD_JB
			JZ 		RC_JB ;	Escaneou o "JB"
			+ 		WORD_JB
			- 		WORD_DU
			JZ		RC_DU ; Escaneou o "DU"
			+ 		WORD_DU
			- 		WORD_LO
			JZ 		RC_LO ; Escaneou o "LO"
			JP		RC_ERRO
RC_CMD		SC		GETWORD ; Essa linha e executada apos obter um comando ("//JB", "//DU" ou "//LO")
			-		WORD_EOL
			JZ		RC_DONE_OK
			JP 		RC_ERRO
;
RC_JB		LV 		/0001
			MM		ANS
			JP 		RC_CMD
RC_DU		LV 		/0002
			MM		ANS
			JP		RC_CMD
RC_LO		LV		/0003
			MM		ANS
			JP		RC_CMD
RC_FINAL	LV		/0004
			MM		ANS
			JP		RC_DONE_OK
;
RC_DONE_OK	LD 		ANS
			JP 		RC_END
RC_ERRO		LV 		/0000
			JP		RC_END
RC_END 		RS 		READ_CMD
;
;
; ###################################
; READ_ARGS_DU
; ###################################
;
; Le a linha de argumentos para um comando DUMP
; e os armazena nas posicoes de memoria correspondentes (DUMP_BL, DUMP_INI, DUMP_TAM, DUMP_EXE, DUMP_UL)
; Retorna 0 em caso de erro, 1 caso contrario
;
READ_ARGS_DU	K       /0000
RAD_BL		SC		GETPARAM
			; - 		CONST_FFFF
			; JZ		RAD_ERRO
			; + 		CONST_FFFF
			MM 		DUMP_BL
			SC		GETWORD
			- 		WORD_SPACES
			JZ		RAD_INI
			JP 		RAD_ERRO
;			
RAD_INI		SC		GETPARAM
			; - 		CONST_FFFF
			; JZ		RAD_ERRO
			; + 		CONST_FFFF
			MM 		DUMP_INI
			SC		GETWORD
			- 		WORD_SPACES
			JZ		RAD_TAM
			JP 		RAD_ERRO
;
RAD_TAM		SC		GETPARAM
			; - 		CONST_FFFF
			; JZ		RAD_ERRO
			; + 		CONST_FFFF
			MM 		DUMP_TAM
			SC		GETWORD
			- 		WORD_SPACES
			JZ		RAD_EXE
			JP 		RAD_ERRO
RAD_EXE		SC		GETPARAM
			; - 		CONST_FFFF
			; JZ		RAD_ERRO
			; + 		CONST_FFFF
			MM 		DUMP_EXE
			SC		GETWORD
			- 		WORD_SPACES
			JZ		RAD_UL
			JP 		RAD_ERRO
RAD_UL		SC		GETPARAM
			; - 		CONST_FFFF
			; JZ		RAD_ERRO
			; + 		CONST_FFFF
			MM 		DUMP_UL
			SC 		GETWORD ; BUG AQUI ?
			-		WORD_EOL
			JZ		RAD_DONE_OK
			JP		RAD_ERRO
;
RAD_ERRO	LV		/0000
			JP 		RAD_END
RAD_DONE_OK	LV 		/0001
RAD_END		RS 		READ_ARGS_DU
;
; ###################################
; READ_ARGS_LO
; ###################################
;
; Le a linha de argumentos para um comando LOAD
; Retorna 0 em caso de erro, 1 caso contrario
;
READ_ARGS_LO	K       /0000
			SC		GETPARAM
			- 		CONST_FFFF
			JZ		RAL_ERRO
			+ 		CONST_FFFF
			MM 		LOADER_UL
			SC		GETWORD
			- 		WORD_EOL
			JZ		RAL_DONE_OK
			JP 		RAL_ERRO
;			
RAL_ERRO	LV		/0000
			JP 		RAL_END
RAL_DONE_OK	LV 		/0001
RAL_END		RS 		READ_ARGS_LO
;
# MAIN
