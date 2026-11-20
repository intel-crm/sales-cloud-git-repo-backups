@isTest(SeeAllData=false)
public class Core_MDF_Reusable_Code_Test {
    @isTest
    static void testValidateRule() {
        boolean result;
        Core_MDF_Reusable_Code.ValidateRuleParams inputRecord = new Core_MDF_Reusable_Code.ValidateRuleParams();
        inputRecord.recValue = 'Test';
        inputRecord.crtValue = 'Actual';
        inputRecord.operator = 'Not Equal';
        inputRecord.fieldType = 'STRING';
        result = Core_MDF_Reusable_Code.validateRule(inputRecord);
        System.assertEquals(true, result); /*Test != Actual*/
        
        inputRecord.operator = 'Equal';     
        result = Core_MDF_Reusable_Code.validateRule(inputRecord);
        System.assertEquals(false, result); /*Test == Actual*/
        
        inputRecord.operator = 'Not In';  
        result = Core_MDF_Reusable_Code.validateRule(inputRecord);
        System.assertEquals(true, result); /*Test NOT IN Actual*/
        
        inputRecord.crtValue = 'Actual; Test';
        inputRecord.operator = 'In';  
        result = Core_MDF_Reusable_Code.validateRule(inputRecord);
        System.assertEquals(true, result); /*Test IN Actual; Test*/
        
        
        inputRecord.recValue = '10';
        inputRecord.crtValue = '100';
        inputRecord.operator = 'Not Equal';
        inputRecord.fieldType = 'CURRENCY';
        
        result = Core_MDF_Reusable_Code.validateRule(inputRecord);
        System.assertEquals(true, result); /*10 != 100*/
        
        inputRecord.operator = 'Equal';
        result = Core_MDF_Reusable_Code.validateRule(inputRecord);
        System.assertEquals(false, result); /*10 == 100*/
        
        inputRecord.operator = 'Greater Than';
        result = Core_MDF_Reusable_Code.validateRule(inputRecord);
        System.assertEquals(false, result); /*10 > 100*/
        
        inputRecord.operator = 'Greater Than or Equal';
        result = Core_MDF_Reusable_Code.validateRule(inputRecord);
        System.assertEquals(false, result); /*10 >= 100*/
        
        inputRecord.operator = 'Less Than';
        result = Core_MDF_Reusable_Code.validateRule(inputRecord);
        System.assertEquals(true, result); /*10 < 100*/
        
        inputRecord.recValue = '100';
        inputRecord.operator = 'Less Than or Equal';
        result = Core_MDF_Reusable_Code.validateRule(inputRecord);
        System.assertEquals(true, result); /*100 <= 100*/
        
        inputRecord.recValue = '20201-06-15';
        inputRecord.crtValue = '20201-07-15';
        inputRecord.operator = 'Not Equal';
        inputRecord.fieldType = 'DATE';
        
        result = Core_MDF_Reusable_Code.validateRule(inputRecord);
        System.assertEquals(true, result); /*15 June 2021 != 15 July 2021*/
        
        inputRecord.operator = 'Equal';
        result = Core_MDF_Reusable_Code.validateRule(inputRecord);
        System.assertEquals(false, result); /*15 June 2021 == 15 July 2021*/
        
        inputRecord.operator = 'Greater Than';
        result = Core_MDF_Reusable_Code.validateRule(inputRecord);
        System.assertEquals(false, result); /*15 June 2021 > 15 July 2021*/
        
        inputRecord.operator = 'Greater Than or Equal';
        result = Core_MDF_Reusable_Code.validateRule(inputRecord);
        System.assertEquals(false, result); /*15 June 2021 >= 15 July 2021*/
        
        inputRecord.operator = 'Less Than';
        result = Core_MDF_Reusable_Code.validateRule(inputRecord);
        System.assertEquals(true, result); /*15 June 2021 < 15 July 2021*/
        
        inputRecord.operator = 'Less Than or Equal';
        result = Core_MDF_Reusable_Code.validateRule(inputRecord);
        System.assertEquals(true, result); /*15 June 2021 <= 15 July 2021*/
        
        inputRecord.recValue = 'MON; TUES; WED;';
        inputRecord.crtValue = 'MON';
        inputRecord.operator = 'Not Equal';
        inputRecord.fieldType = 'MULTIPICKLIST';
        
        result = Core_MDF_Reusable_Code.validateRule(inputRecord);
        System.assertEquals(true, result); /*MON; TUES; WED; != MON*/
        
        inputRecord.operator = 'Equal';
        result = Core_MDF_Reusable_Code.validateRule(inputRecord);
        System.assertEquals(false, result); /*MON; TUES; WED; == MON*/
        
        inputRecord.operator = 'In';
        result = Core_MDF_Reusable_Code.validateRule(inputRecord);
        System.assertEquals(false, result); /*MON; TUES; WED; In MON*/
        
        inputRecord.recValue = 'MON;';
        inputRecord.crtValue = 'MON; TUES; WED;';
        inputRecord.operator = 'Not In';
        
        result = Core_MDF_Reusable_Code.validateRule(inputRecord);
        System.assertEquals(false, result); /*MON; Not In MON; TUES; WED;*/
        
        inputRecord.recValue = '';
        inputRecord.operator = 'Equal';
        inputRecord.crtValue = '';
        result = Core_MDF_Reusable_Code.validateRule(inputRecord);
        System.assertEquals(true, result);
        
        inputRecord.crtValue = '';
        inputRecord.operator = 'Not Equal';
        inputRecord.recValue = 'MON';
        result = Core_MDF_Reusable_Code.validateRule(inputRecord);
        System.assertEquals(true, result);
        
        inputRecord.crtValue = 'MON';
        inputRecord.operator = 'Not Equal';
        inputRecord.recValue = '';
        result = Core_MDF_Reusable_Code.validateRule(inputRecord);
        System.assertEquals(true, result);
        
        inputRecord.crtValue = '';
        inputRecord.operator = 'In';
        inputRecord.recValue = '';
        result = Core_MDF_Reusable_Code.validateRule(inputRecord);
        System.assertEquals(false, result);
        
        string fieldType = Core_MDF_Reusable_Code.getDataTypeOfField('Campaign','Name');
        System.assertEquals('STRING', fieldType);
        
    }
}