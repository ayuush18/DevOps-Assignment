package com.muj.ci;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

/**
 * Unit tests for Calculator class
 * Tests all basic arithmetic operations and edge cases
 */
public class CalculatorTest {

    private Calculator calculator;

    @BeforeEach
    public void setUp() {
        calculator = new Calculator();
    }

    @Test
    public void testAdd() {
        assertEquals(15.0, calculator.add(10, 5), 0.001);
        assertEquals(0.0, calculator.add(-5, 5), 0.001);
        assertEquals(-10.0, calculator.add(-5, -5), 0.001);
        assertEquals(7.5, calculator.add(2.5, 5.0), 0.001);
    }

    @Test
    public void testSubtract() {
        assertEquals(5.0, calculator.subtract(10, 5), 0.001);
        assertEquals(-10.0, calculator.subtract(-5, 5), 0.001);
        assertEquals(0.0, calculator.subtract(5, 5), 0.001);
        assertEquals(-2.5, calculator.subtract(2.5, 5.0), 0.001);
    }

    @Test
    public void testMultiply() {
        assertEquals(50.0, calculator.multiply(10, 5), 0.001);
        assertEquals(-25.0, calculator.multiply(-5, 5), 0.001);
        assertEquals(25.0, calculator.multiply(-5, -5), 0.001);
        assertEquals(0.0, calculator.multiply(0, 5), 0.001);
        assertEquals(12.5, calculator.multiply(2.5, 5.0), 0.001);
    }

    @Test
    public void testDivide() {
        assertEquals(2.0, calculator.divide(10, 5), 0.001);
        assertEquals(-1.0, calculator.divide(-5, 5), 0.001);
        assertEquals(1.0, calculator.divide(-5, -5), 0.001);
        assertEquals(0.5, calculator.divide(2.5, 5.0), 0.001);
    }

    @Test
    public void testDivideByZero() {
        IllegalArgumentException exception = assertThrows(
            IllegalArgumentException.class, 
            () -> calculator.divide(10, 0)
        );
        assertEquals("Cannot divide by zero", exception.getMessage());
    }

    @Test
    public void testSqrt() {
        assertEquals(5.0, calculator.sqrt(25), 0.001);
        assertEquals(0.0, calculator.sqrt(0), 0.001);
        assertEquals(3.0, calculator.sqrt(9), 0.001);
        assertEquals(2.236, calculator.sqrt(5), 0.001);
    }

    @Test
    public void testSqrtNegative() {
        IllegalArgumentException exception = assertThrows(
            IllegalArgumentException.class, 
            () -> calculator.sqrt(-5)
        );
        assertEquals("Cannot calculate square root of negative number", exception.getMessage());
    }

    @Test
    public void testPower() {
        assertEquals(8.0, calculator.power(2, 3), 0.001);
        assertEquals(1.0, calculator.power(5, 0), 0.001);
        assertEquals(25.0, calculator.power(5, 2), 0.001);
        assertEquals(0.25, calculator.power(2, -2), 0.001);
        assertEquals(1.0, calculator.power(1, 100), 0.001);
    }

    @Test
    public void testEdgeCases() {
        // Test with very large numbers
        assertEquals(2000000000.0, calculator.add(1000000000, 1000000000), 0.001);
        
        // Test with very small numbers
        assertEquals(0.0000002, calculator.add(0.0000001, 0.0000001), 0.0000001);
        
        // The following lines are commented out because Calculator.divide throws an exception for divide by zero
        // assertEquals(Double.POSITIVE_INFINITY, calculator.divide(1, 0.0));
        // assertEquals(Double.NEGATIVE_INFINITY, calculator.divide(-1, 0.0));
    }
}