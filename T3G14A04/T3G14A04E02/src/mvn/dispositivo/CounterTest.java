package mvn.dispositivo;

import static org.junit.Assert.*;
import mvn.Bits8;
import mvn.controle.MVNException;

import org.junit.Test;

public class CounterTest {
	
	Counter counter = new Counter();

	@Test
	public void testCounter() throws MVNException {
		Bits8 counterValue = counter.ler();
		assertEquals("Counter must be 0 when created", 0, counterValue.toInt());
	}

	@Test
	public void testEscrever() throws MVNException {
		counter.escrever(new Bits8(5));
		Bits8 value = counter.ler();
		assertEquals(5, value.toInt());
	}

	@Test
	public void testPodeLerWhenLessThanFF() {
		counter.escrever(new Bits8(254));
		assertTrue("Allowed to write when value less than FF", counter.podeLer());
	}

	@Test 
	public void testPodeLerWhenEqualsToFF() {		
		counter.escrever(new Bits8(255));
		assertFalse("Not allowed to write when value is equal to FF", counter.podeLer());	
	}

	@Test
	public void testPodeEscrever() {
		assertTrue(counter.podeEscrever());
	}

	@Test
	public void testPosition() throws MVNException {
		counter.escrever(new Bits8(1));
		counter.position();
		counter.position();
		Bits8 newValue = counter.ler();
		assertEquals(3, newValue.toInt());
	}

	@Test
	public void testSize() throws MVNException {
		counter.escrever(new Bits8(1));
		Bits8 size = counter.size();
		assertEquals(254, size.toInt());
	}

	@Test
	public void testSkip() throws MVNException {
		counter.escrever(new Bits8(1));
		try {
			counter.skip(new Bits8(2));
		} catch (MVNException e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		}
		Bits8 newValue = counter.ler();
		assertEquals(3, newValue.toInt());
	}

}
