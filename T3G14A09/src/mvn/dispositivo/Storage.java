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
public class Storage implements Dispositivo {
		
	private int[] list;
	private int posRead;
	private int posWrite;
	
	private static int LISTSIZE = 5;
    
    public Storage() {
    	this.list = new int[LISTSIZE];
    	this.posRead = 0;
    	this.posWrite = 0;
	}

	@Override
	public void escrever(Bits8 in) throws MVNException {
		if(this.podeEscrever()){
			this.list[this.posWrite] = in.toInt();
			incrementPosWrite();
		} 
	}

	@Override
	public Bits8 ler() throws MVNException {
		int currentByte = this.list[this.posRead];
		incrementPosRead();
		return new Bits8(currentByte);
	}
	
	private void incrementPosWrite () {
		if (this.posWrite < this.LISTSIZE - 1) {
			this.posWrite += 1;
		} 
	}

	private void incrementPosRead () {
		this.posRead += 1;
		this.posRead = this.posRead % (this.LISTSIZE);
	}

	@Override
	public boolean podeLer() {
		return true;
	}

	@Override
	public boolean podeEscrever() {
		if (this.posWrite < (this.LISTSIZE)) {
			return true;
		} else {
			return false;
		}
	}
	

	@Override
	public void reset() throws MVNException {
    	for (int i = 0; i < list.length; i++) {
			this.list[i] = 0;
		}
    	this.posRead = 0;
    	this.posWrite = 0;
	}

	@Override
	public Bits8 skip(Bits8 val) throws MVNException {
		return null;
	}

	@Override
	public Bits8 position() throws MVNException {
		return new Bits8(this.posRead);
	}

	@Override
	public Bits8 size() throws MVNException {
		return new Bits8(this.LISTSIZE - this.posWrite);
	}	
    

   
   
}
