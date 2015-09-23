/**
 *
 * @author Diego
 */
public class TrianguloIsosceles extends Triangulo {
    
    public TrianguloIsosceles(float ladoA, float ladoB){
        super(ladoA, ladoA, ladoB);
    }

    /* (non-Javadoc)
     * Verifica se ha dois lados iguais
     * @see Triangulo#validar()
     */
    @Override
    public boolean validar() {
    	
    	super.validar();
    	
    	if (lados[0] == lados[1] || lados[0] == lados[2] || lados[1] == lados[2]) {
			return true;
		} else {
	    	return false;	
		}
    }
    
}
