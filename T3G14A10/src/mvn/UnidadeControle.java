/**
 * Escola Politécnica da Universidade de São Paulo Departamento de Engenharia de
 * Computação e Sistemas Digitais Copyright© 2001..2011, todos os direitos
 * reservados.
 *
 * Este programa é de uso exclusivo das disciplinas de Laboratório de
 * Fundamentos de Engenharia de Computação (PCS2024 e PCS2302) e Linguagens e
 * Compiladores (PCS2056 e PCS2508). É vetada a utilização e/ou distribuição
 * deste código sem a autorização dos docentes responsáveis pela disciplina ou
 * do departamento responsável.
 */
package mvn;

import mvn.controle.MVNException;
import mvn.controle.PainelControle;

/**
 * Representa a unidade de controle para a MVN. Eh essa a abstracao responsavel
 * por processar as instrucoes da MVN.
 *
 * @author PSMuniz
 * @author Diego Queiroz
 * @version 1.0 - PCS/EPUSP
 * @version 2.0 - PCS/EPUSP (MVN 4.0)
 */
public class UnidadeControle {

    // //////////////////////////////////////////////////////////////////////////////
    // Constantes do repertorio de instrucoes
    // //////////////////////////////////////////////////////////////////////////////
    /**
     * * Desvio incondicional.
     */
    public static final int JP = 0x0000;

    /**
     * * Desvio se acumulador e zero.
     */
    public static final int JZ = 0x0001;

    /**
     * * Desvio se acumulador for negativo.
     */
    public static final int JN = 0x0002;

    /**
     * * Move um valor para o acumulador.
     */
    public static final int LV = 0x0003;

    /**
     * * Soma.
     */
    public static final int ADD = 0x0004;

    /**
     * * Subtracao.
     */
    public static final int SUB = 0x0005;

    /**
     * * Multiplicacao.
     */
    public static final int MUL = 0x0006;

    /**
     * * Divisao.
     */
    public static final int DIV = 0x0007;

    /**
     * * Memoria para acumulador.
     */
    public static final int LD = 0x0008;

    /**
     * * Acumulador para memoria.
     */
    public static final int MD = 0x0009;

    /**
     * * Desvio para subprograma.
     */
    public static final int SC = 0x000A;

    /**
     * * Retorno de subprograma.
     */
    public static final int RS = 0x000B;

    /**
     * * Parada.
     */
    public static final int HM = 0x000C;

    /**
     * * Entrada.
     */
    public static final int GD = 0x000D;

    /**
     * * Saida.
     */
    public static final int PD = 0x000E;

    /**
     * *
     * Chamada de supervisor
     */
    public static final int OS = 0x000F;

    // Constantes para referenciar registradores (alguns mnemonicos classicos)
    /**
     * * Indice: Registrador de endereco de memoria
     */
    public static final int MAR = 0;

    /**
     * * Indice: Registrador de Dados da memoria
     */
    public static final int MDR = 1;

    /**
     * * Indice: Registrador de endereco da instrucao
     */
    public static final int IC = 2;

    /**
     * * Indice: Registrador de instrucao
     */
    public static final int IR = 3;

    /**
     * * Indice: Registrador de codigo de operacao
     */
    public static final int OP = 4;

    /**
     * * Indice: Registrador de operando de instrucao
     */
    public static final int OI = 5;

    /**
     * * Indice: Registrador de dados (acumulador)
     */
    public static final int AC = 6;

    /**
     * * Descricao: Registrador de endereco de memoria
     */
    private static final String MAR_DESC = "MAR";

    /**
     * * Descricao: Registrador de Dados da memoria
     */
    private static final String MDR_DESC = "MDR";

    /**
     * * Descricao: Registrador de endereco da instrucao
     */
    private static final String IC_DESC = "IC";

    /**
     * * Descricao: Registrador de instrucao
     */
    private static final String IR_DESC = "IR";

    /**
     * * Descricao: Registrador de codigo de operacao
     */
    private static final String OP_DESC = "OP";

    /**
     * * Descricao: Registrador de operando de instrucao
     */
    private static final String OI_DESC = "OI";

    /**
     * * Descricao: Registrador de dados (acumulador)
     */
    private static final String AC_DESC = "AC";

    /**
     * * Descricao dos registradores
     */
    public static final String[] REGISTERS = new String[]{
        MAR_DESC, MDR_DESC, IC_DESC, IR_DESC, OP_DESC, OI_DESC, AC_DESC};

    /**
     * * Tamanho de uma instrucao, em Bytes
     */
    private static final int INSTRUCTION_SIZE = Word.WORD_SIZE
            / Bits8.BYTE_SIZE;

    /**
     * * Mensagem de erro: Instrucao invalida
     */
    private static final String ERR_INVALID_INSTRUCTION = "Instrucao [%h] invalida, verificar o programa.";

    /**
     * * Registradores da MVN
     */
    private Registradores regs;

    /**
     * * Memoria da MVN
     */
    private Memoria mem;

    /**
     * * Gerenciador de dispositivos da MVN
     */
    private GerenciadorDispositivos io;

    public PainelControle getPainel() {
        return painel;
    }

    public void setPainel(PainelControle painel) {
        this.painel = painel;
    }

    /**
     * Painel de controle
     */
    private PainelControle painel;

    /**
     * Instancia a unidade de controle com o Gerenciador de Dispositivos e
     * Memoria especificados.<br/>
     * <br/>
     * <b>Pre-condicao</b>: Nenhuma.<br/>
     * <b>Pos-condicao</b>: A Unidade de Controle e instanciada.
     *
     * @param io Gerenciador de Dispositivos a ser utilizado.
     * @param mem Memoria a ser utilizada.
     */
    public UnidadeControle(GerenciadorDispositivos io, Memoria mem) {
        this.regs = new Registradores(REGISTERS.length);
        this.io = io;
        this.mem = mem;
    }

    /**
     * Altera o valor dos registradores para ZERO.<br/>
     * <br/>
     * <b>Pre-condicao</b>: os registradores estao com qualquer valor.<br/>
     * <b>Pos-condicao</b>: os registradores estao zerados.
     */
    public void clearRegs() {
        regs.clear();
    }

    /**
     * Retorna uma referencia para os registradores da Unidade de Controle.<br/>
     * <br/>
     * <b>Pre-condicao</b>: Nenhuma.<br/>
     * <b>Pos-condicao</b>: Uma referencia para os registradores e retornada.
     *
     * @return Os registradores
     */
    public Registradores obterRegs() {
        return regs;
    }

    /**
     * Inicia a MVN definindo o valor do Registrador de Endereco de Instrucao -
     * IC. <b>Pre-condicao</b>: Nenhuma. <b>Pos-condicao</b>: a MVN esta
     * iniciada com o Registrador apontando para a instrucao especificada em
     * <i>initIC</i>.
     *
     * @param initIC O endereco de memoria a ser passado ao registrador IC.
     */
    public void start(int initIC) {
        // Acertar o IC para initIC
        regs.getRegister(IC).setValue(initIC);
    }

    /**
     * Executa um passo do ciclo de busca e execucao (FDX).<br/>
     * Para executar um programa e necessario executar este metodos sucessivas
     * vezes.<br/>
     * <br/>
     * <b>Pre-condicao</b>: A Unidade de Controle esta inicializada.<br/>
     * <b>Pos-condicao</b>: A instrucao indicada pelo registrador IC e
     * executada.
     *
     * @return True se a instrucao atual nao for ums instrucao de parada da MVN,
     * False caso contrario.
     * @throws MVNException Caso ocorra algum erro durante a execucao da
     * instrucao.
     */
    public boolean resume() throws MVNException {
        fetch();
        decode();
        execute();

        return (regs.getRegister(OP).toInt() != HM);
    }

    /**
     * Acerta o IR para o valor armazenado no endereco indicado pelo IC. Note
     * que o endereco fornecido e o endereco menos significativo. O valor
     * abrange 2 bytes.<br/>
     * <br/>
     * <b>Pre-condicao</b>: Os registradores MAR, MDR e IR contem qualquer
     * valor.<br/>
     * <b>Pos-condicao</b>: A seguinte operacao foi executada:<br/>
     * MAR <- IC<br/> MDR <- mem[MAR]<br/> IR <- MDR
     *
     * @throws MVNException Caso ocorra algum erro durante a leitura da memoria.
     */
    private void fetch() throws MVNException {
        // Carrega o valor do IC no MAR.
        regs.setValue(MAR, IC);

        // Coloca no MDR o conteÃºdo da posicao de memoria indicada pelo MAR.
        // O MAR esta referenciando o endereco menos significativo e
        // precisamos
        // da palavra completa, i.e. a armazenada nos enderecos IC e IC+1.
        Bits8 HiWord = mem.read(regs.getRegister(MAR).toInt());
        Bits8 LoWord = mem.read(regs.getRegister(MAR).toInt() + 1);
        regs.getRegister(MDR).setValue(LoWord, HiWord);

        // Coloca o valor de MDR no IR para decodificacao.
        regs.setValue(IR, MDR);
    }

    /**
     * Decodifica a instrucao no IR, colocando o codigo de operacao no
     * registrador OP e o operando no registrador OI.<br/>
     * <br/>
     * <b>Pre-condicao</b>: Os registradores OP e OI contem qualquer valor.<br/>
     * <b>Pos-condicao</b>: O registrador OP contem a instrucao a ser executada,
     * e OI contem o operando da instrucao. Ambora retirados do registrador IR.
     */
    private void decode() {
        // Coloca o codigo de operacao no registrador OP.
        // O codigo de operacao e o nibble mais significativo de IR.
        int instrucao = regs.getRegister(IR).getNibbleInt(3);
        regs.getRegister(OP).setValue(instrucao);

        // Coloca o operando no registrador OI.
        // O codigo de operacao abrange os tres nibbles menos significativos
        // do IR.
        int operando = regs.getRegister(IR).toInt() & 0xFFF;
        regs.getRegister(OI).setValue(operando);
    }

    /**
     * Executa a instrucao contida no registrador OP e o valor do operando no
     * registrador OI.<br/>
     * <br/>
     * <b>Pre-condicao</b>: OP contem a instrucao a ser executada.<br/>
     * <b>Pos-condicao</b>: A instrucao e executada.
     *
     * @throws MVNException Caso a instrucao nao exista.
     */
    private void execute() throws MVNException {
        int instrucao = regs.getRegister(OP).toInt();

        switch (instrucao) {
            case JP:
                instrucaoJP();
                break;
            case JZ:
                instrucaoJZ();
                break;
            case JN:
                instrucaoJN();
                break;
            case LV:
                instrucaoLV();
                break;
            case ADD:
                instrucaoADD();
                break;
            case SUB:
                instrucaoSUB();
                break;
            case MUL:
                instrucaoMUL();
                break;
            case DIV:
                instrucaoDIV();
                break;
            case LD:
                instrucaoLD();
                break;
            case MD:
                instrucaoMD();
                break;
            case SC:
                instrucaoSC();
                break;
            case RS:
                instrucaoRS();
                break;
            case HM:
                instrucaoHM();
                break;
            case GD:
                instrucaoGD();
                break;
            case PD:
                instrucaoPD();
                break;
            case OS:
                instrucaoOS();
                break;
            default:
                throw new MVNException(ERR_INVALID_INSTRUCTION, instrucao);
        }
    }// execute

    /**
     * Desvio incondicional: OP = 0x0000. <br>
     * Modifica o conteÃºdo do contador de instrucoes (IC) armazenando nele o
     * conteÃºdo do registrador de operando (OI).<br/>
     * <br/>
     * <b>Pre-condicao</b>: IC contem qualquer valor.<br/>
     * <b>Pos-condicao</b>: IC <- OI
     */
    private void instrucaoJP() {
        regs.setValue(IC, OI);
    }

    /**
     * Desvio se acumulador e zero: OP = 0x0001. <br>
     * Se o conteÃºdo do acumulador for zero, entao modificar o conteÃºdo do
     * contador de instrucoes (IC) armazenando nele o conteÃºdo do registrador
     * de operando (OI).<br/>
     * <br/>
     * <b>Pre-condicao</b>: IC contem qualquer valor.<br/>
     * <b>Pos-condicao</b>: IC <- OI , se AC = 0<br/> IC <- IC + 1 , caso
     * contrario
     */
    private void instrucaoJZ() {
        //Verifica se acumulador = 0: salta para OI em caso positivo, 
        //ou incrementa IC em caso negativo
        if (regs.getRegister(AC).toInt() == 0) {
            regs.setValue(IC, OI);
        } else {
            IncrementaIC();
        }
    }

    /**
     * Desvio se acumulador for negativo: OP = 0x0002. <br>
     * Se o conteÃºdo do acumulador for negativo, entao modificar o conteÃºdo do
     * contador de instrucoes (IC) armazenando nele o conteÃºdo do registrador
     * de operando (OI).<br/>
     * <br/>
     * <b>Pre-condicao</b>: IC contem qualquer valor.<br/>
     * <b>Pos-condicao</b>: IC <- OI , se AC < 0<br/> IC <- IC + 1 , caso
     * contrario
     */
    private void instrucaoJN() {
        //Verifica se acumulador negativo: salta para OI em caso positivo, 
        //ou incrementa IC em caso negativo
        if (regs.getRegister(AC).toShort() < 0) {
            regs.setValue(IC, OI);
        } else {
            
            IncrementaIC();
        }
    }

    /**
     * Move valor para acumulador: OP = 0x0003. <br>
     * Modificar o conteÃºdo do acumulador (AC) com o conteÃºdo do registrador
     * operando (OI).<br/>
     * Por limitacao dessa implementacao, nao e possivel mover valores fora do
     * intervalo 0x000 e 0xFFF.<br/>
     * <br/>
     * <b>Pre-condicao</b>: AC contem qualquer valor.<br/>
     * <b>Pos-condicao</b>: AC <- OI<br/> IC <- IC + 1
     */
    private void instrucaoLV() {
        regs.setValue(AC, OI);
        IncrementaIC();
    }

    /**
     * Soma: OP = 0x0004.<br/>
     * Somar ao conteÃºdo do acumulador (AC) ao conteÃºdo da posicao de memoria
     * indicada pelo registrador de operando (OI). Armazenar o resultado no
     * registrador acumulador.<br/>
     * <br/>
     * <b>Pre-condicao</b>: AC contem qualquer valor<br/>
     * <b>Pos-condicao</b>: AC <- AC + MEM[OI]<br/> IC <- IC + 1
     */
    private void instrucaoADD() throws MVNException {
        Bits8 HiWord = mem.read(regs.getRegister(OI).toInt());
        Bits8 LoWord = mem.read(regs.getRegister(OI).toInt() + 1);

        int conteudoMemoria = (new Word(LoWord, HiWord)).toInt();
        int conteudoAcumulador = regs.getRegister(AC).toInt();

        regs.getRegister(AC).setValue(conteudoAcumulador + conteudoMemoria);
        IncrementaIC();
    }

    /**
     * Subtracao: OP = 0x0005. <br>
     * Subtrair do conteÃºdo do acumulador (AC) o conteÃºdo da posicao de
     * memoria indicada pelo registrador de operando (OI). Armazenar o resultado
     * no registrador acumulador.<br/>
     * <br/>
     * <b>Pre-condicao</b>: AC contem qualquer valor<br/>
     * <b>Pos-condicao</b>: AC <- AC - MEM[OI]<br/> IC <- IC + 1
     */
    private void instrucaoSUB() throws MVNException {
        Bits8 HiWord = mem.read(regs.getRegister(OI).toInt());
        Bits8 LoWord = mem.read(regs.getRegister(OI).toInt() + 1);

        int conteudoMemoria = (new Word(LoWord, HiWord)).toInt();
        int conteudoAcumulador = regs.getRegister(AC).toInt();

        regs.getRegister(AC).setValue(conteudoAcumulador - conteudoMemoria);
        IncrementaIC();
    }

    /**
     * Multiplicacao: OP = 0x0006. <br>
     * Multiplicar o conteÃºdo do acumulador (AC) peloo conteÃºdo da posicao de
     * memoria indicada pelo registrador de operando (OI). Armazenar o resultado
     * no registrador acumulador.<br/>
     * <br/>
     * <b>Pre-condicao</b>: AC contem qualquer valor<br/>
     * <b>Pos-condicao</b>: AC <- AC * MEM[OI]<br/> IC <- IC + 1
     */
    private void instrucaoMUL() throws MVNException {
        Bits8 HiWord = mem.read(regs.getRegister(OI).toInt());
        Bits8 LoWord = mem.read(regs.getRegister(OI).toInt() + 1);

        int conteudoMemoria = (new Word(LoWord, HiWord)).toInt();
        int conteudoAcumulador = regs.getRegister(AC).toInt();

        regs.getRegister(AC).setValue(conteudoAcumulador * conteudoMemoria);
        IncrementaIC();
    }

    /**
     * Divisao inteira: OP = 0x0007. <br>
     * Dividir o conteÃºdo do acumulador (AC) pelo conteÃºdo da posicao de
     * memoria indicada pelo registrador de operando (OI). Armazenar o resultado
     * no registrador acumulador.<br/>
     * <br/>
     * <b>Pre-condicao</b>: AC contem qualquer valor<br/>
     * <b>Pos-condicao</b>: AC <- (int) AC / MEM[OI]<br/> IC <- IC + 1
     */
    private void instrucaoDIV() throws MVNException {
        Bits8 HiWord = mem.read(regs.getRegister(OI).toInt());
        Bits8 LoWord = mem.read(regs.getRegister(OI).toInt() + 1);

        short conteudoMemoria = (new Word(LoWord, HiWord)).toShort();
        short conteudoAcumulador = regs.getRegister(AC).toShort();

        regs.getRegister(AC).setValue(conteudoAcumulador / conteudoMemoria);
        IncrementaIC();
    }

    /**
     * LDA: OP = 0x0008. <br>
     * Armazenar no acumulador (AC) o conteÃºdo da posicao de memoria cujo
     * endereco e o conteÃºdo do OI.<br/>
     * <br/>
     * <b>Pre-condicao</b>: AC contem qualquer valor<br/>
     * <b>Pos-condicao</b>: AC <- MEM[OI]<br/> IC <- IC + 1
     */
    private void instrucaoLD() throws MVNException {
        Bits8 HiWord = mem.read(regs.getRegister(OI).toInt());
        Bits8 LoWord = mem.read(regs.getRegister(OI).toInt() + 1);

        regs.getRegister(AC).setValue(LoWord, HiWord);
        IncrementaIC();
    }

    /**
     * MD: OP = 0x0009. <br>
     * Guardar o conteÃºdo do acumulador (AC) na posicao de memoria indicada
     * pelo OI.<br/>
     * <br/>
     * <b>Pre-condicao</b>: MEM[OI] contem qualquer valor<br/>
     * <b>Pos-condicao</b>: MEM[OI] <- AC<br/> IC <- IC + 1
     */
    private void instrucaoMD() throws MVNException {
        Bits8 HiWord = regs.getRegister(AC).getHiWord();
        Bits8 LoWord = regs.getRegister(AC).getLoWord();

        mem.write(HiWord, regs.getRegister(OI).toInt());
        mem.write(LoWord, regs.getRegister(OI).toInt() + 1);
        IncrementaIC();
    }

    /**
     * Chamada de subrotina: OP = 0x000A. <br>
     * Implementacao para encadeamento de subrotinas(nao ha mecanismo de
     * recursao!).<br/>
     * <br/>
     * <b>Pre-condicao</b>: IC e MEM[OI] contem qualquer valor<br/>
     * <b>Pos-condicao</b>: MEM[OI] <- IC + 1<br/> IC <- OI + 1
     */
    private void instrucaoSC() throws MVNException {
        // coloca em IC o endereco da proxima instrucao
        IncrementaIC();

        // coloca o endereco da proxima instrucao no endereco especificado
        // por OI
        Bits8 HiWord = regs.getRegister(IC).getHiWord();
        Bits8 LoWord = regs.getRegister(IC).getLoWord();

        mem.write(HiWord, regs.getRegister(OI).toInt());
        mem.write(LoWord, regs.getRegister(OI).toInt() + 1);

        // salta para o endereco especificado em OI
        regs.setValue(IC, OI);

        IncrementaIC();
    }

    /**
     * Retorno de subprograma: OP = 0x000B. <br>
     * Implementacao para encadeamento de subrotinas (nao ha mecanismo de
     * recursao!).<br/>
     * <br/>
     * <b>Pre-condicao</b>: IC contem qualquer valor<br/>
     * <b>Pos-condicao</b>: IC <- MEM[OI]
     */
    private void instrucaoRS() throws MVNException {
        // o endereco de retorno e o valor contido no endereco do OI
        Bits8 HiWord = mem.read(regs.getRegister(OI).toInt());
        Bits8 LoWord = mem.read(regs.getRegister(OI).toInt() + 1);

        regs.getRegister(IC).setValue(LoWord, HiWord);
    }

    /**
     * STOP: OP = 0x000c. <br/>
     * O operando contem o endereco a partir do qual o programa continua.<br/>
     * <br/>
     * <b>Pre-condicao</b>: IC contem qualquer valor<br/>
     * <b>Pos-condicao</b>: IC <- OI e envia um sinal de parada para a MVN.
     */
    private void instrucaoHM() {
        // Armazenar no registrador IC o conteudo do registrador OI.
        regs.setValue(IC, OI);
    }

    /**
     * GD: OP = 0x000d. <br>
     * O operando contem a identificacao do dispositivo de entrada.<br/>
     * <br/>
     * <b>Pre-condicao</b>: OI indica um dispositivo registrado no gerenciador e
     * AC contem qualquer valor<br/>
     * <b>Pos-condicao</b>: AC <- DISP[OI]<br/> IC <- IC + 1
     */
    private void instrucaoGD() throws MVNException {
        // obtendo o tipo e a unidade logica
        int tipoDispositivo = regs.getRegister(OI).getHiWord().toInt();
        int unidadeControle = regs.getRegister(OI).getLoWord().toInt();

        // Le uma palavra (2 x Bits8) da unidade logica de disco selecionada
        // e armazena-a no acumulador.
        // Monta uma palavra com os bytes lidos pelo dispositivo, de modo que o
        // primeiro byte lido seja a parte mais significativa da palavra e o
        // segundo
        // byte lido seja a parte menos significativa.
        Bits8 HiWord = io.lerDispositivo(tipoDispositivo, unidadeControle);
        Bits8 LoWord = io.lerDispositivo(tipoDispositivo, unidadeControle);

        // System.out.println("---- LowWord: " + LoWord);
        // System.out.println("---- HiWord: " + HiWord);
        regs.getRegister(AC).setValue(LoWord, HiWord);

        IncrementaIC();
    }

    /**
     * OUT: OP = 0x000e. <br>
     * Transferir o conteÃºdo do acumulador (AC) para o dispositivo de saida
     * cuja identificacao esta no registrador OI. Acionar o dispositivo de saida
     * e aguardar que este termine de executar a operacao de saida. <br>
     * O formato padrao da saida e em hexadecimal.<br/>
     * <br/>
     * <b>Pre-condicao</b>: OI indica um dispositivo registrado no gerenciador e
     * AC contem qualquer valor<br/>
     * <b>Pos-condicao</b>: DISP[OI] <- AC<br/> IC <- IC + 1
     */
    private void instrucaoPD() throws MVNException {
        // obtendo o tipo e a unidade logica
        int tipoDispositivo = regs.getRegister(OI).getHiWord().toInt();
        int unidadeControle = regs.getRegister(OI).getLoWord().toInt();

        // Escreve a palavra do acumulador no disco. A palavra deve ser
        // decomposta em dois Bits8, pois a escrita e a cada Bits8 (byte).
        Bits8 HiWord = new Bits8(regs.getRegister(AC).getHiWord());
        Bits8 LoWord = new Bits8(regs.getRegister(AC).getLoWord());

        // escreve no dispositivo
        // A parte alta da palavra e escrita primeiro, seguida da parte baixa
        io.escreverDispositivo(tipoDispositivo, unidadeControle, HiWord);
        io.escreverDispositivo(tipoDispositivo, unidadeControle, LoWord);

        IncrementaIC();
    }

    /**
     * SVC: OP = 0x000F.<br/>
     * Chamada de supervisor.<br/>
     * Recebe um número variável de parâmetros (Posicoes de memória acima da chamada) <br/>
     * e o código da operação a ser efetuada. 
     * <br/>
     * <b>Pre-condicao</b>: Dois parametros no endereÃ§os anteriores Ã¥ chamada da instruÃ§Ã£o: TYPE e UL (Unidade LÃ³gica).<br/>
     * <b>Pos-condicao</b>: Device adicionado a lista de dispositivo. SaÃ­da no Acumulador: 0 se sucesso, -1 se erro. 
     */
    private void instrucaoOS() throws MVNException {
        
      // Obtem o numero de parametros
        int numeroDeParametros = regs.getRegister(OI).getNibbleInt(2);
        
      // Obtem ID da operacao
        int opId = regs.getRegister(OI).getLoWord().toInt();
        
      // Obtem parametros
        int[] OSParams = getOSParametros(numeroDeParametros); 

      int retorno = -1;
      int lu;

      /**
       * Operacao 0xA
       * Parametros:  
       * type – o tipo de dispositivo (0, 1 ou 4, apenas)
       * lu – o número da unidade lógica do dispositivo (0 a 255)
       */
      switch (opId) {
      /**
      * Se o numero de parametros é 2 e
      * a unidade logica (OSParams[0]) é valida e
      * o tipo de dispositivo (OSParams[1]) é valido
      * Adiciona o dispositivo e retorna 0 para sucesso ou -1 para erro
      **/
      case 0xAD:
	      if (numeroDeParametros == 2 && luInValidRange(OSParams[0]) && validType(OSParams[1])) {
	          io.addDispSimples(OSParams[1], OSParams[0]);
	          retorno = 0;
	      } else {
	          retorno = -1;
	      }
	      break;
      /**
       *  Chama o metodo skip()
       *  @param lu: numero da unidade logica
       *  @param num: numero de words a avançar
       *  @return numero de words avançadas, -1 em caso de erro (numero
       *           da ul invalido, inexistente ou somente escrita, ou numero
       *           negativo de bytes no parametro num)
       */
      case 0xFE:
          int num = OSParams[0];
          lu = OSParams[1];
          retorno = skip(num, lu, numeroDeParametros);
          break;
      /**
       *  Chama o metodo reset()
       *  @param lu: numero da unidade logica
       *  @return 0 em caso de sucesso, -1 em caso de erro (numero
       *           da ul invalido, inexistente ou somente escrita)
       */
      case 0xFF:
          lu = OSParams[0];
          retorno = reset(lu, numeroDeParametros);
          break;
      /**
       * Tratamento de excecoes do MBS
       */
      case 0xEE:
          lu = 0xFF;
          retorno = regs.getRegister(AC).toInt();
          logError(lu, retorno);
          break;
      /**
       * Execucao de programa na memoria do MBS
       */
      case 0xEF:
    	  retorno = regs.getRegister(AC).toInt();
          mbsExecutaPrograma();
          break;
	  default:
		  break;
	}
      
      // Armazena o valor de retorno no acumulador
      Bits8 hiWord = new Bits8(0);
      if (retorno == -1 ) {
          hiWord = new Bits8(retorno);
      }
      Word saida = new Word(new Bits8(retorno), hiWord);
      regs.getRegister(AC).setValue(saida);

      IncrementaIC();
    }

    private void mbsExecutaPrograma() throws MVNException {
        String acValue = regs.getRegister(AC).toHexString();
        int opValue = regs.getRegister(OP).toInt();
        int icValue = regs.getRegister(IC).toInt();

        boolean executaPassByPass = this.painel.getExecutaPassByPass();
        boolean executaShowRegs = this.painel.getExecutaShowRegs();

        String executaParams = prepareExecutaParams(acValue, executaPassByPass, executaShowRegs);

        this.painel.executaComando('r', executaParams);

        regs.getRegister(OP).setValue(opValue);
        regs.getRegister(IC).setValue(icValue);
    }

    private String prepareExecutaParams(String acValue, boolean passByPassParam, boolean showRegsParam) {
        String n = "n";
        String s = "s";

        String passByPass = passByPassParam ? s : n;
        String showRegs = showRegsParam ? s : n;

        String params = acValue + " " + showRegs + " " + passByPass;

        return params;
    }

    private void logError(int lu, int errorCode) {
        int[] errorMessage = getMBSErrorMessage(errorCode);

        for (int i = 0; i < errorMessage.length ; i++) {

            try {
                io.escreverDispositivo(3, lu, new Bits8(errorMessage[i]));
            } catch (MVNException e) {
            }
        }

        writeNewLine(lu);
    }

    private void writeNewLine(int lu) {
        int[] newLine = {0xd, 0xa};

        for (int i = 0; i < newLine.length ; i++) {
            try {
                io.escreverDispositivo(3, lu, new Bits8(newLine[i]));
            } catch (MVNException e) {
            }
        }
    }

    private int[] getMBSErrorMessage(int errorCode) {
        int[] errorMessage = new int[100];

        switch (errorCode) {
            case 0:
                errorMessage = new int[] {0x4f, 0x4b}; //"OK"
                break;
            case 1:
                errorMessage = new int[] {0x45, 0x52, 0x3a, 0x4a, 0x4f, 0x42}; //"ER:JOB"
                break;
            case 2:
                errorMessage = new int[] {0x45, 0x52, 0x3a, 0x43, 0x4d, 0x44}; //"ER:CMD"
                break;
            case 3:
                errorMessage = new int[] {0x45, 0x52, 0x3a, 0x41, 0x52, 0x47}; //"ER:ARG"
                break;
            case 4:
                errorMessage = new int[] {0x45, 0x52, 0x3a, 0x45, 0x4e, 0x44}; //"ER:END"
                break;
            case 5:
                errorMessage = new int[] {0x45, 0x52, 0x3a, 0x45, 0x58, 0x45}; //"ER:EXE"
                break;
            default:
                break;
        }
        return errorMessage;
    }

    /**
     * Avança o cursor de leitura da ul de disco em quantidade especifica
     * de bytes
     * @param num
     *          numero de words a acavçar
     * @param lu
     *          unidade logica
     * @param numeroDeParametros
     *          numero de parametros
     * @return 0 em caso de sucesso, -1 em caso de erro (numero
     *           da ul invalido, inexistente ou somente escrita)
     */
    private int skip(int num, int lu, int numeroDeParametros) {

        int retorno;

        if ((numeroDeParametros == 2) && validLu(3, lu) && num >= 0) {
            retorno = 0;

            try {
                Dispositivo disco = io.getDevice(3, lu);

                if (!disco.podeLer()) {
                    retorno = -1;
                } else {
                    retorno = disco.skip(new Bits8(num)).toInt();
                }
            } catch (MVNException e) {
                retorno = -1;
            }

        } else {
            retorno = -1;
        }

        return retorno;
    }

    /**
     * Posiciona cursor de leitura da unidade logica no inicio do arquivo
     * @param lu
     *          numero da unidade logica
     * @param numeroDeParametros
     *          numero de parametros recebidos
     *  @return 0 em caso de sucesso, -1 em caso de erro (numero
     *           da ul invalido, inexistente ou somente escrita)
     */
    private int reset(int lu, int numeroDeParametros) {

        int retorno;

        if ((numeroDeParametros == 1) && validLu(3, lu)) {
            retorno = 0;

            try {
                Dispositivo disco = io.getDevice(3, lu);

                if (!disco.podeLer()) {
                    retorno = -1;
                } else {
                    disco.reset();
                }
            } catch (MVNException e) {
                e.printStackTrace();
                retorno = -1;
            }

        } else {
            retorno = -1;
        }

        return retorno;
    }
    
    /**
     * Armazena os valores dos parametros passados em um array para a operação OS
     * @param numeroDeParametros
     * @return array de inteiros com os valores dos parametros
     * @throws MVNException
     */
    private int[] getOSParametros(int numeroDeParametros) throws MVNException {

        Bits8 HiWord;
        Bits8 LoWord;
        
        int[] OSParams = new int[numeroDeParametros + 1];
        
        int j = 0;
        
        for (int i = numeroDeParametros; i > 0; i--) {
            
            int paramAddress = regs.getRegister(MAR).toInt() - (2 * i);
            
            HiWord = mem.read(paramAddress);
            LoWord = mem.read(paramAddress + 1);
            
            OSParams[j] = (new Word(LoWord, HiWord)).toInt();
            j ++;
        }
        
        return OSParams;
    }
    
    /**
     * 
     * @param type
     * 			Tipo do dispositivo na entrada de instrucaoOS
     * @return true se type Ã© 0, 1 ou 4, false caso contrario
     */
    private boolean validType(int type) {
    	
		return type == 0 || type == 1 || type == 4;
	}
    
    /**
     * 
     * @param lu (unidade logica)
     * 			Unidade Logica na entrada de instrucaoOS
     * @return true se lu esta no intervalo [0, 255], false caso contrario
     */
    private boolean luInValidRange(int lu) {
    	
		return lu >= 0 && lu <= 255;
	}

    /**
     *
     * @param lu (unidade logica)
     * 			Unidade Logica na entrada de instrucaoOS
     * @return true se lu esta no intervalo [0, 255], se dispositivo existe e se pode ler, false caso contrario
     */
    private boolean validLu(int type, int lu) {

        // verifica se lu esta entre [0,255] e retorna falso caso nao esteja
        if (!luInValidRange(lu))
            return false;

        boolean validLu = true;

        try {
            Dispositivo disco = io.getDevice(type, lu);

            if (!disco.podeLer()) {
                validLu = false;
            }

        } catch (MVNException e) {
            e.printStackTrace();
            validLu = false;
        }

        return validLu;

    }
    
    /**
     * Retorna uma String contendo um cabecalho para os registradores da MVN,
     * para ser utilizado com o metodo toString da classe Registradores.<br/>
     * <br/>
     * <b>Pre-condicao</b>: Nenhuma.<br/>
     * <b>Pos-condicao</b>: O cabecalho dos registradores e retornado.
     *
     * @return Uma String com o cabecalho dos registradores.
     */
    public static String regsHeader() {
        StringBuilder result = new StringBuilder(2 * REGISTERS.length
                * (Word.HEXWORD_SIZE + 1) + 4);
        StringBuilder line = new StringBuilder(REGISTERS.length * 5);
        for (int i = 0; i < REGISTERS.length; i++) {
            result.append(String.format(String.format(" %%-%ds", Word.HEXWORD_SIZE),
                    REGISTERS[i]));
            line.append("---- ");
        }
        result.append(System.getProperty("line.separator"));
        result.append(line);
        result.append(System.getProperty("line.separator"));

        return result.toString();
    }

    /**
     * Incrementa o registrador IC para que este referencie o endereco da
     * proxima instrucao.<br/>
     * <br/>
     * <b>Pre-condicao</b>: IC contem qualquer valor.<br/>
     * <b>Pos-condicao</b>: IC <- IC + 1
     */
    private void IncrementaIC() {
        int nextInstr = regs.getRegister(IC).toInt() + 1 * INSTRUCTION_SIZE;
        regs.getRegister(IC).setValue(nextInstr);
    }
}
