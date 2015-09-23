
public class Quadrado extends Retangulo {
    public Quadrado(float lado){
        super(lado, lado);
    }

    /* (non-Javadoc)
     * Verifica se ha algum lado diferente. Como na classe super ja ha a 
     * verificacao que lados opostos sao iguais, basta verificar se dois lados adjacentes
     * sao iguais.
     * @see Retangulo#validar()
     */
    @Override
    public boolean validar() {
		 
        super.validar();
        
        if (lados[0] != lados[1]) {
        	return false;
        }
        
        return true;       
    }
    
    
}