@isTest
public class PMP_Batch_PublishToPIM_Test {

    static testMethod void PMP_Batch_PublishToPIM(){
        
         String offferingNameDesc=String.valueOf(DateTime.now());
        Account acc1 = PMP_TestDataUtility.createIntelAccount('TestAccount1', PMP_TestDataUtility.intel_Account_Record_Type, true);
        
        Contact con1 = PMP_TestDataUtility.createContact(acc1.id,true);
       
        PMP_Company__c cmp1 = PMP_TestDataUtility.createCompanyInformation('TestCompany1', acc1.Id, true);
        
        
         PMP_Partner_Offering__c testOfferingApproved = PMP_TestDataUtility.createOffering('TestDuplicateOffering2','Public Content', 
                                                                                 'TestDuplicate',cmp1.Id, true,'Approved','');
        
        PMP_Partner_Offering__c testOffering = PMP_TestDataUtility.createOffering('TestDuplicateOffering2','Public Content', 
                                                                                 'TestDuplicate',cmp1.Id, true,'Published','');
        testOffering.PMP_Working_Copy_Id__c=testOfferingApproved.Id;
        testOffering.PMP_Partner_Offering_Source_Id__c='121212';
        update testOffering;
        
        
        PMP_Batch_PublishToPIM bc = new PMP_Batch_PublishToPIM(false);
        ID batchprocessid=database.executebatch(bc,30);
        
        
        PMP_PublishToPIM_Scheduler lsc = new PMP_PublishToPIM_Scheduler();
        
        String sch = '0  00 1 3 * ?';
        
        system.schedule('Market Place Locale Test', sch, lsc);
    }
}