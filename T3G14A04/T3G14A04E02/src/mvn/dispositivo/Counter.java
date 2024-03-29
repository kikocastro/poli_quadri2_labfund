/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

package mvn.dispositivo;

import java.io.IOException;

import mvn.Bits8;
import mvn.Dispositivo;
import mvn.controle.MVNException;

/**
 *
 * @author mjunior
 */
public class Counter implements Dispositivo {
		
	/*** Erro de dispositivo: Counter não pode ser lido por estar cheio */
	private static final String	ERR_FULL		= "Counter não pode ser lido pois está cheio";
    
	private Bits8 count = new Bits8(0);
    
	/*** Valor maximo de count 0xFF */
	private static Bits8 maxCount = new Bits8(255);
	
	private static Bits8 zero = new Bits8(0);
    
	 /**
     * inicializa em 0 o atributo count
     */
    public Counter() {
    	reset();
	}	
    
    public void escrever(Bits8 newCount) {	
    	count = newCount;
	}
   
    /**
	 * Le um Bits8 do counter.<br/>
	 * <b>Pre-condicao</b>: Deve ser possivel ler do counter.<br/>
	 * <b>Pos-condicao</b>: A informacao e lida do counter.
	 * 
	 */
	@Override
	public Bits8 ler() {
		
		return count;
		
	}
    
    /**
     * 
     * @return true caso count seja menor do que o valor máximo 
     * do contador (FF), * false caso contrário
     */
    public boolean podeLer() {
    	
    	int compareResult = count.compareTo(maxCount);
    	
		if (compareResult < 0) {
			return true;
		} else {
			return false;
		}
	}
    
    public boolean podeEscrever() {
		return true;
	}
    
    public void reset() {
    	count = zero;	
	}
    
    
    /**
     * soma n ao valor de count, atualizando este último;
     * casocountatinja seu valor máximo (FF), ele permanece
     * nesse valor. 
     * @return o valor de count como resultado
     */
    @Override
    public Bits8 position() throws MVNException {
    	this.skip(new Bits8(1));
    	return null;
    }
   
    /**
     * @return o número de vezes que o método position ainda pode ser
     * chamado antes que a variável count atinja o valor máximo (FF)
     */
    @Override
    public Bits8 size() throws MVNException {
    	int chamadasDisponiveis;
    	chamadasDisponiveis = maxCount.toInt() - count.toInt();
    	
    	return new Bits8(chamadasDisponiveis);
    }
    
    
    /**
     * soma 1 ao valor decount, atualizando-o; caso count já esteja em
     * seu valor máximo (FF), ele permanece nesse valor. 
     * @return o valor de count como resultado
     */
    @Override
    public Bits8 skip(Bits8 val) throws MVNException {
    	count.add(val);
    	if (count.toInt() > 255) {
    		count = maxCount;
    	}
    	return count;
    }
}
