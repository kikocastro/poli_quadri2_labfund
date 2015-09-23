/**
 *
 * @author Diego
 */
public class Triangulo extends Poligono {
    public Triangulo(float ladoA, float ladoB, float ladoC){
        super(new float[]{ladoA, ladoB, ladoC});
    }

    /* (non-Javadoc)
     * O triangulo deve ter 3 lados e a soma de dois lados
     * deve ser menor que o terceiro lado
     * @see Poligono#validar()
     */
    @Override
    public boolean validar() {
        /* Um triangulo deve ter 3 lados e a soma
         * de dois lados deve ser MENOR que o
         * terceiro lado.
         */
		 
        super.validar();
        
        if (lados.length != 3) {
        	return false;
        }
        
        if (!ladosTemTamanhosValidos()) {
			return false;
		}
        
        return true;
        
    }
    
    
    /**
     * @return true se a condicao de existencia de um triangulo é respeitada, ie:
     * (| b - c | < a < b + c),
     * (| a - c | < b < a + c) e
     * (| a - b | < c < a + b)
     */
    private boolean ladosTemTamanhosValidos () {
    	
    	boolean ehValido = true;
    	
    	int indexA, indexB, indexC;
    	
    	
    	for (int i = 0; i < lados.length; i++) {
    		
    		indexA = i % 3;
    		indexB = (i + 1) % 3;
    		indexC = (i + 2) % 3;
    		
    		ehValido =  ehValido && 
    					(lados[indexA] < lados[indexB] + lados[indexC]) && 
    					(lados[indexA] > Math.abs(lados[indexB] - lados[indexC]));
		}
    	return ehValido;
    }	
    
   
    
}
