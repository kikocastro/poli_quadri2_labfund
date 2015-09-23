
public class Retangulo extends Poligono {
    public Retangulo(float ladoA, float ladoB){
        super(new float[]{ladoA, ladoB, ladoA, ladoB});
    }

    /* (non-Javadoc)
     * Verifica se ha 4 lados e se as arestas nao adjacentes tem a mesma medida
     * @see Poligono#validar()
     */
    @Override
    public boolean validar() {
		 
        super.validar();
        
        if (lados.length != 4) {
        	return false;
        }
        
        if (!ladoOpostosIguais()) {
			return false;
		}
        
        return true;       
    }
    
    private boolean ladoOpostosIguais() {
    	if (lados[0] != lados[2]) {
        	return false;
        }
        if (lados[1] != lados[3]) {
        	return false;
        }
        return true;
    }
}