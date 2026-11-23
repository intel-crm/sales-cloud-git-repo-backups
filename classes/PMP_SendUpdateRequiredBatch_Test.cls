@isTest
public with sharing class PMP_SendUpdateRequiredBatch_Test {
  /*  
        static testMethod void testMethod1() {
        Account acc1 = PMP_TestDataUtility.createIntelAccount('account1',PMP_TestDataUtility.intel_Account_Record_Type,true);
        PMP_Company__c cmp1 = PMP_TestDataUtility.createCompanyInformation('TestCompny1',acc1.Id,true);
        List<PMP_Partner_Offering__c> offlist = new List<PMP_Partner_Offering__c>();
        User adminUser = PMP_TestDataUtility.createUser(true);
        PMP_Partner_Offering__c workoffering1 = PMP_TestDataUtility.createOffering('workingoffering1','Public Content','abc is xyz',cmp1.Id,true,'Admin Review','');
        DateTime dT = System.now().date();  
        Date myDate = date.newinstance(dT.year(), dT.month(), dT.day());
        String formattedDate=dT.format('yyyy-MM-dd'); 
        workoffering1.PMP_Offering_Status_Update_Dt__c = System.today();
        workoffering1.PMP_Intel_Admin_Id__c = adminUser.Id;
        workoffering1.PMP_Partner_Offering_Lifecycle_Status_Nm__c ='Update Required';
         
        update workoffering1;

        List<PRM_EmailLog__c> emailList = new List<PRM_EmailLog__c>();
         
         PRM_EmailLog__c emLog = new PRM_EmailLog__c();
         emLog.PMP_Partner_Offering__c = workoffering1.id;
         emLog.Email_Template_Name__c ='PMP PMP_OfferingUpdateRequiredFirstNotify';
         emailList.add(emLog);
         insert emailList;
        
         test.startTest();
         PMP_SendUpdateRequiredOffEmailsBatch batch = new PMP_SendUpdateRequiredOffEmailsBatch();
         Database.executeBatch(batch,1);
         test.stopTest();
        }
    */
}