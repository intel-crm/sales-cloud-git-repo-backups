/*****************************************************************************************************************************************************************
* Class Name  : PMP_CreateOfferingTab4ServiceTest 
* Version     : 1.0 
* Created Date: 06-14-2019 
* Modification Log :
*
* Developer                           Date                          Description
* ----------------------------------------------------------------------------------------------------------------------------------------------------------------
* ONYX Team                          06-14-2019                    Test class of PMP_CreateOfferingTab4Service apex class
******************************************************************************************************************************************************************/
@isTest
public class PMP_CreateOfferingTab4ServiceTest {

    @isTest
    static void getResourcesInputsTest(){
        
        Account acc1=PMP_TestDataUtility.createIntelAccount('account1',PMP_TestDataUtility.intel_Account_Record_Type,true);
        PMP_Company__c cmp1=PMP_TestDataUtility.createCompanyInformation('TestCompny1',acc1.Id,true);
        PMP_Partner_Offering__c off1=PMP_TestDataUtility.createOffering('offering1','Public Content','abc is xyz',cmp1.Id,true,'Draft','');
        
        Intel_Step stepTest = PMP_CreateOfferingTab4Service.getResourcesInputs('TestClassStep',off1);
        System.assertNotEquals(null, stepTest);
        
    }
    
    @isTest
    static void getOfferingResourcesTest(){
        
        Account acc1=PMP_TestDataUtility.createIntelAccount('account1',PMP_TestDataUtility.intel_Account_Record_Type,true);
        PMP_Company__c cmp1=PMP_TestDataUtility.createCompanyInformation('TestCompny1',acc1.Id,true);
        PMP_Partner_Offering__c off1=PMP_TestDataUtility.createOffering('offering1','Public Content','abc is xyz',cmp1.Id,true,'Draft','');
        PMP_Partner_Offering_Resource__c offRes1 = PMP_TestDataUtility.createResources('res1','www.intel.com',off1.Id,'Data Sheet','');
        PMP_Partner_Offering_Resource__c offRes2 = PMP_TestDataUtility.createResources('res2','www.google.com',off1.Id,'Product Brief','');
        
        List<PMP_Partner_Offering_Resource__c> offResources = PMP_CreateOfferingTab4Service.getOfferingResources(off1.Id);
        System.assertEquals(2, offResources.size());
        
    }
}