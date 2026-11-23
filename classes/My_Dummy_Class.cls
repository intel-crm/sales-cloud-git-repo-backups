/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-29-2026
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
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
        //Workflow Issue check
        Decimal multiplier = 1.10; // 10% markup
        Decimal finalResult = inputValue * multiplier;
        
        return finalResult.setScale(2);
    }
}