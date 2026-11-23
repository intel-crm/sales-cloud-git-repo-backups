public with sharing class My_Dummy_Class {
    
    /**
     * Performs a dummy calculation on the input value.
     * @param inputValue The decimal value to process.
     * @return The calculated decimal result.
     */
    public Decimal performDummyCalculation(Decimal inputValue) {
        if (inputValue == null) {
            throw new IllegalArgumentException('Input value cannot be null.');
        }
        
        Decimal multiplier = 1.10; // 10% markup
        Decimal finalResult = inputValue * multiplier;
        
        return finalResult.setScale(2);
    }
}