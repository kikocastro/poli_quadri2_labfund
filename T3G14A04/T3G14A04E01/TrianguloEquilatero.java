/**
 *
 * @author Diego
 */
public class TrianguloEquilatero extends TrianguloIsosceles {
    
    public TrianguloEquilatero(float lado){
        super(lado, lado);
    }

    /* (non-Javadoc)
     * Verifica se os 3 lados sao iguais entre si
     * @see TrianguloIsosceles#validar()
     */
    @Override
    public boolean validar() {
    	
    	super.validar();
    	
    	if (lados[0] != lados[1] || lados[0] != lados[2] || lados[1] != lados[2]) {
			return false;
		} else {
	    	return true;	
		}
    }
    
}
