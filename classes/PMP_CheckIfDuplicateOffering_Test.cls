@isTest
public class PMP_CheckIfDuplicateOffering_Test {
     @isTest
    static void testIsWorking() {
        Boolean result = PMP_CheckIfDuplicateOffering.isWorking();
        System.assertEquals(true, result);
    }

    // //Added by Manasa - for duplicate Name check
    //  static testMethod void testSameCompanyDuplicateOffering(){
    //     Test.startTest();       
             
    //     Account acc1 = PMP_TestDataUtility.createIntelAccount('TestAccount1', PMP_TestDataUtility.intel_Account_Record_Type, true);
        
    //     PMP_Company__c cmp1 = PMP_TestDataUtility.createCompanyInformation('TestCompany1', acc1.Id, true);
                        
    //     PMP_Partner_Offering__c offering1 = PMP_TestDataUtility.createOffering('TestDuplicateOffering','Public Content', 
    //                                                                              'TestDuplicate',cmp1.Id, true,'Published','');
                    
    //     PMP_Partner_Offering__c offering2 = PMP_TestDataUtility.createOffering('TestDuplicateOffering','Public Content', 
    //                                                                              'TestDuplicate',cmp1.Id, false,'Published','');
         
    //     Integer duplicateValue = PMP_CheckIfDuplicateOffering.isDuplicateOffering(offering2.Name, offering2.Id, cmp1.Id);
    //     System.assertEquals(-1, duplicateValue);
    //     Test.stopTest();
    // }
    //  //Added by Krishna Ch - for duplicate Name check
    //  static testMethod void testSameCompanyDuplicateOffering1(){
    //     Test.startTest();       
             
    //     Account acc1 = PMP_TestDataUtility.createIntelAccount('TestAccount1', PMP_TestDataUtility.intel_Account_Record_Type, true);
        
    //     PMP_Company__c cmp1 = PMP_TestDataUtility.createCompanyInformation('TestCompany1', acc1.Id, true);
                        
    //     /*PMP_Partner_Offering__c offering1 = PMP_TestDataUtility.createOffering('TestDuplicateOffering','Public Content', 
    //                                                                              'TestDuplicate',cmp1.Id, true,'Published','');*/
                    
    //     PMP_Partner_Offering__c offering2 = PMP_TestDataUtility.createOffering('TestDuplicateOffering','Public Content', 
    //                                                                              'TestDuplicate',cmp1.Id, false,'Published','');
     
    //     Integer duplicateValue = PMP_CheckIfDuplicateOffering.isDuplicateOffering('TestDuplicateOffering5', offering2.Id, cmp1.Id);
    //     System.assertEquals(1, duplicateValue);
    //     Test.stopTest();
    // }

}