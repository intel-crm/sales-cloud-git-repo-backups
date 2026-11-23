@isTest
public class Core_MDF_CCP_GetFieldsListTest {
    @isTest 
    public static void getObjectFieldstest(){
       String objName='Case';
        String fieldName='Core_MDF_Activity_Type__c';
        Test.startTest();
        Core_MDF_CCP_GetFieldsList.getObjectFields(objName);
        Core_MDF_CCP_GetFieldsList.getFieldsType(objName);
        Core_MDF_CCP_GetFieldsList.getPickListValues(objName,fieldName);
        
       Test.stopTest();
    }
    
    
}