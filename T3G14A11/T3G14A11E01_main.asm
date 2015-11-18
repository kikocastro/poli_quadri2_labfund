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
CONST_FF 	<
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
WORD_EX			<

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
			- 	WORD_JB
			JZ 	GET_CMD
			JP	ERRO_JB
			; Leitura de DU, LO ou /* (final)
GET_CMD		SC 	READ_CMD
			JZ 	ERRO_CMD
			-	WORD_DU
			JZ 	GET_ARGS_DU
			+ 	WORD_DU
			-	WORD_LO
			JZ	GET_ARGS_LO
			+ 	WORD_LO
			- 	WORD_EX
			JZ 	GET_ARGS_EX ;linha 0020
			+ 	WORD_EX
			- 	WORD_BARS_END
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
GET_ARGS_EX SC 	READ_ARGS_EX ; le e salva UL da imagem do programa a ser executado em LOADER_UL
			- 	CONST_FFFF
			JZ 	ERRO_EX
			+ 	CONST_FFFF
			; chama loader para carregar imagem do programa na memoria
			SC	LOADER ; linha 004e
			OS 	/00EF ; chama instrucao EX
			JP 	GET_CMD
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
ERRO_EX 	LV 	/0005
			OS 	/00EE
			JP 	FIM
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
; Le uma linha do batch.
; Retorna WORD_JB se leu //JB <EOL>
; Retorna WORD_DU se leu //DU <EOL>
; Retorna WORD_LO se leu //LO <EOL>
; Retorna WORD_EX se leu //EX <EOL>
; Retorna WORD_BARS_END se leu /* <EOF>
; Retorna 0 se houve erro de job ou comando
; Retorna 1 se houve erro de fim
;
ANS			K 		/0000 ; Valor de retorno da sub-rotina
;
READ_CMD	K       /0000
			SC		GETWORD
			-		WORD_BARS
			JZ		RC_BARS ; Escaneou o "//"
			+ 		WORD_BARS
			- 		WORD_BARS_END
			JZ		RC_BARS_END ; Escaneou o "/*"
			JP		RC_ERRO_FIM
RC_BARS		SC 		GETWORD
			-		WORD_JB
			JZ 		RC_JB ;	Escaneou o "//JB"
			+ 		WORD_JB
			- 		WORD_DU
			JZ		RC_DU ; Escaneou o "//DU"
			+ 		WORD_DU
			- 		WORD_LO
			JZ 		RC_LO ; Escaneou o "//LO"
			+		WORD_LO
			-		WORD_EX
			JZ 		RC_EX ; Escaneou o "//EX"
			JP		RC_ERRO_CMD
RC_BARS_END	SC 		GETWORD
			- 		WORD_EOF
			JZ 		RC_OK_FIM ; Escaneou o "/* <EOF>"
			+ 		WORD_EOF
			- 		WORD_EOL
			SC 		GETWORD
			-		WORD_EOF
			JZ 		RC_OK_FIM ; Escaneou o "/* <EOL> <EOF>"
			JP 		RC_ERRO_FIM
;
RC_JB		LD 		WORD_JB
			MM		ANS
			JP 		RC_GET_EOL
RC_DU		LD 		WORD_DU
			MM		ANS
			JP		RC_GET_EOL
RC_LO		LD		WORD_LO
			MM		ANS
			JP		RC_GET_EOL
RC_EX		LD 		WORD_EX
			MM		ANS
			JP		RC_GET_EOL
;
RC_GET_EOL	SC 		GETWORD
			- 		WORD_EOL
			JZ		RC_OK_CMD
			JP		RC_ERRO_CMD
;
RC_OK_CMD	LD 		ANS
			JP 		RC_END
RC_OK_FIM	LD 		WORD_BARS_END
			JP		RC_END
RC_ERRO_CMD	LV 		/0000
			JP 		RC_END
RC_ERRO_FIM	LV 		/0001
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
;
; ###################################
; READ_ARGS_EX
; ###################################
;
; Le a linha de argumentos para um comando EX
; Retorna o valor do (único) parametro de EX FFFF ou FFFF em caso de erro
;
EX_ADDRESS		K 		/0000
;
READ_ARGS_EX	K       /0000
			SC		GETPARAM
			MM 		EX_ADDRESS
			; para EX_ADDRESS ser valido precisa estar entre 0000 e 00FF, senão raise erro FFFF
			LD 		CONST_FF
			- 		EX_ADDRESS
			JN 		RAE_ERRO
			LD 		EX_ADDRESS
			MM 		LOADER_UL
			SC		GETWORD
			- 		WORD_EOL
			JZ		RAE_DONE_OK
			JP 		RAE_ERRO
;
RAE_ERRO	LD 		CONST_FFFF
			JP 		RAE_END
RAE_DONE_OK	LD 		EX_ADDRESS
RAE_END		RS 		READ_ARGS_EX
;
# MAIN
