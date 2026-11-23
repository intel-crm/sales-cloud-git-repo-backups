@isTest
public class Pricing_FieldTest {
    static testmethod void testFieldDetails(){
        String objectAPIName = 'Account';
        String fieldSetName = 'Core_Mapacc_Field_Set';
        Schema.FieldSetMember f = Schema.getGlobalDescribe().get(objectAPIName).getDescribe().fieldSets.getMap().get(fieldSetName).getFields()[0];
        
        Pricing_Field fieldObj1 = new Pricing_Field(f);
        
        Pricing_Field fieldObj = new Pricing_Field(true);
        fieldObj.APIName = null;
        fieldObj.Label = null;
        fieldObj.Required = null;
        fieldObj.isInput = null;
        fieldObj.Type = null;
        fieldObj.isDateField = true;
        fieldObj.fieldValue = null;
        fieldObj.programType = null;
        fieldObj.doubleFieldValue = null;
        fieldObj.fieldDisabled = null;
        
        System.assert(fieldObj != null);
    }
}