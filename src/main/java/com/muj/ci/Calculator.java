package com.muj.ci;

/**
 * Simple Calculator class for CI/CD demonstration
 * This class provides basic arithmetic operations
 */
public class Calculator {

    /**
     * Adds two numbers
     * @param a first number
     * @param b second number
     * @return sum of a and b
     */
    public double add(double a, double b) {
        return a + b;
    }

    /**
     * Subtracts second number from first
     * @param a first number
     * @param b second number
     * @return difference of a and b
     */
    public double subtract(double a, double b) {
        return a - b;
    }

    /**
     * Multiplies two numbers
     * @param a first number
     * @param b second number
     * @return product of a and b
     */
    public double multiply(double a, double b) {
        return a * b;
    }

    /**
     * Divides first number by second
     * @param a dividend
     * @param b divisor
     * @return quotient of a divided by b
     * @throws IllegalArgumentException if divisor is zero
     */
    public double divide(double a, double b) {
        if (b == 0) {
            throw new IllegalArgumentException("Cannot divide by zero");
        }
        return a / b;
    }

    /**
     * Calculates square root of a number
     * @param a number to calculate square root of
     * @return square root of a
     * @throws IllegalArgumentException if number is negative
     */
    public double sqrt(double a) {
        if (a < 0) {
            throw new IllegalArgumentException("Cannot calculate square root of negative number");
        }
        return Math.sqrt(a);
    }

    /**
     * Calculates power of a number
     * @param base base number
     * @param exponent exponent
     * @return base raised to the power of exponent
     */
    public double power(double base, double exponent) {
        return Math.pow(base, exponent);
    }

    /**
     * Main method for demonstration
     */
    public static void main(String[] args) {
        Calculator calc = new Calculator();
        System.out.println("Calculator Demo:");
        System.out.println("10 + 5 = " + calc.add(10, 5));
        System.out.println("10 - 5 = " + calc.subtract(10, 5));
        System.out.println("10 * 5 = " + calc.multiply(10, 5));
        System.out.println("10 / 5 = " + calc.divide(10, 5));
        System.out.println("√25 = " + calc.sqrt(25));
        System.out.println("2^3 = " + calc.power(2, 3));
    }
}