/**
 *
 * @author Diego
 */
public class Poligono {
    float[] lados;
    
    /**
     * Construtor
     * @param lados
     */
    public Poligono(float[] lados){
        this.lados = lados;
    }
    
    
    /**
     * @return true se o poligono tem pelo menos 3 lados
     */
    public boolean validar(){
        /* Não sei que forma é, então o melhor
         * que eu posso fazer é verificar se possui
         * pelo menos 3 lados.
         */
		 
	    if (lados.length > 2) {
			return true;
		} else {
			return false;
		}
    	
    }
    
    /**
     * @return perimetro do poligono
     */
    public float perimetro(){
        float soma = 0;
        for ( float i : lados ){
            soma += i;
        }
        return soma;
    }
    
    /**
     * Imprime informacoes sobre o poligono: tipo, medidas dos lados, perimetro e se a forma é válida ou nao
     */
    public void imprime(){
        System.out.println(getClass().getName());
        
        System.out.print("Lados: ");
        
        StringBuilder txt = new StringBuilder();
        String sep = "";
        for ( float i : lados ){
            txt.append(sep).append(i);
            sep = ", ";
        }
        System.out.println(txt);
        
        System.out.print("Perimetro: ");
        System.out.println(perimetro());
        
        if (validar()){
            System.out.println("Forma valida!");
        } else {
            System.out.println("Forma invalida!");
        }
        System.out.println();
    }
    
}
