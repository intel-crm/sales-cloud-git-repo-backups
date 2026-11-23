@isTest
public class PMP_SendExpiryOfferingEmailsBatch_Test {
    
    @isTest
    static void testIsWorking() {
        Boolean result = PMP_SendExpiryOfferingEmailsBatch.isWorking();
        System.assertEquals(true, result);
    }
//IPA2.0 - As part of TWC729-7977 commented the entire class 
/*
     static testMethod void testMethod1() {
      
        Account acc1 = PMP_TestDataUtility.createIntelAccount('account1',PMP_TestDataUtility.intel_Account_Record_Type,true);
        PMP_Company__c cmp1 = PMP_TestDataUtility.createCompanyInformation('TestCompny1',acc1.Id,true);
        List<PMP_Partner_Offering__c> offlist = new List<PMP_Partner_Offering__c>();
         
       PMP_Partner_Offering__c workoffering1 = PMP_TestDataUtility.createOffering('workingoffering1','Public Content','abc is xyz',cmp1.Id,true,'Draft','');
        workoffering1.PMP_Partner_Offering_End_Dt__c = system.today();
        workoffering1.PMP_Partner_Offering_Lifecycle_Status_Nm__c = 'Admin Review';
        offlist.add(workoffering1);
         
       PMP_Partner_Offering__c offering1 = PMP_TestDataUtility.createOffering('offering1','Public Content','abc is xyz',cmp1.Id,true,'Draft','');
        offering1.PMP_Partner_Offering_End_Dt__c = system.today();
        offering1.PMP_Partner_Offering_Lifecycle_Status_Nm__c = 'Published';
        offering1.PMP_Working_Copy_Id__c =workoffering1.id;
        offlist.add(offering1);
        //update offlist; 
         PMP_Partner_Offering__c offering2 = PMP_TestDataUtility.createOffering('offering1','Public Content','abc is xyz',cmp1.Id,true,'Update Required','');
        //offering1.PMP_Partner_Offering_End_Dt__c = system.today();
        //offering1.PMP_Partner_Offering_Lifecycle_Status_Nm__c = 'Published';
        offering2.PMP_Working_Copy_Id__c =workoffering1.id;
        offlist.add(offering2);
        update offlist; 
         
         List<PRM_EmailLog__c> emailList = new List<PRM_EmailLog__c>();
         
         PRM_EmailLog__c emLog = new PRM_EmailLog__c();
         emLog.PMP_Partner_Offering__c = offering1.id;
         emLog.Email_Template_Name__c ='PMP OfferingExpiryFirstReminder';
         emailList.add(emLog);
         
         PRM_EmailLog__c emLog1 = new PRM_EmailLog__c();
         emLog1.PMP_Partner_Offering__c = offering1.id;
         emLog1.Email_Template_Name__c ='PMP OfferingExpirySecondReminder';
         emailList.add(emLog1);
         
         PRM_EmailLog__c emLog2 = new PRM_EmailLog__c();
         emLog2.PMP_Partner_Offering__c = offering1.id;
         emLog2.Email_Template_Name__c ='PMP OfferingExpiryFinalReminder';
         emailList.add(emLog2);
         
         PRM_EmailLog__c emLog3 = new PRM_EmailLog__c();
         emLog3.PMP_Partner_Offering__c = offering1.id;
         emLog3.Email_Template_Name__c ='PMP PMP_OfferingUpdateRequiredFirstNotify';
         emailList.add(emLog3);
         PRM_EmailLog__c emLog4 = new PRM_EmailLog__c();
         emLog4.PMP_Partner_Offering__c = offering1.id;
         emLog4.Email_Template_Name__c ='PMP PMP_OfferingUpdateRequiredSecondNotify';
         emailList.add(emLog4);
         insert emailList;
         system.assertEquals('PMP OfferingExpiryFinalReminder', emLog2.Email_Template_Name__c);
         
         test.startTest();
         PMP_SendExpiryOfferingEmailsBatch batch = new PMP_SendExpiryOfferingEmailsBatch();
         Database.executeBatch(batch,1);
         test.stopTest();
        
    }
    static testMethod void testMethod12() {
      
        Account acc1 = PMP_TestDataUtility.createIntelAccount('account1',PMP_TestDataUtility.intel_Account_Record_Type,true);
        PMP_Company__c cmp1 = PMP_TestDataUtility.createCompanyInformation('TestCompny1',acc1.Id,true);
        List<PMP_Partner_Offering__c> offlist = new List<PMP_Partner_Offering__c>();
        
       PMP_Partner_Offering__c workoffering1 = PMP_TestDataUtility.createOffering('workingoffering1','Public Content','abc is xyz',cmp1.Id,true,'Draft','');
        workoffering1.PMP_Partner_Offering_End_Dt__c = system.today();
        workoffering1.PMP_Partner_Offering_Lifecycle_Status_Nm__c = 'Admin Review';
        offlist.add(workoffering1);
         
        PMP_Partner_Offering__c offering2 = PMP_TestDataUtility.createOffering('offering2','Public Content','abc is xyz',cmp1.Id,true,'Draft','');
        offering2.PMP_Partner_Offering_End_Dt__c = system.today().adddays(7);
        offering2.PMP_Partner_Offering_Lifecycle_Status_Nm__c = 'Published';
        offering2.PMP_Working_Copy_Id__c =workoffering1.id;
        offlist.add(offering2);
  
        update offlist;
        
        system.assertEquals('Published', offering2.PMP_Partner_Offering_Lifecycle_Status_Nm__c);
         
         test.startTest();
         PMP_SendExpiryOfferingEmailsBatch batch = new PMP_SendExpiryOfferingEmailsBatch();
         Database.executeBatch(batch,1);
         test.stopTest();
        
    }
    
    static testMethod void testMethod2() {
      
        Account acc1 = PMP_TestDataUtility.createIntelAccount('account1',PMP_TestDataUtility.intel_Account_Record_Type,true);
        PMP_Company__c cmp1 = PMP_TestDataUtility.createCompanyInformation('TestCompny1',acc1.Id,true);
        List<PMP_Partner_Offering__c> offlist = new List<PMP_Partner_Offering__c>();
        
      PMP_Partner_Offering__c workoffering1 = PMP_TestDataUtility.createOffering('workingoffering1','Public Content','abc is xyz',cmp1.Id,true,'Draft','');
        workoffering1.PMP_Partner_Offering_End_Dt__c = system.today();
        workoffering1.PMP_Partner_Offering_Lifecycle_Status_Nm__c = 'Admin Review';
        offlist.add(workoffering1);
         
        PMP_Partner_Offering__c offering2 = PMP_TestDataUtility.createOffering('offering2','Public Content','abc is xyz',cmp1.Id,true,'Draft','');
        offering2.PMP_Partner_Offering_End_Dt__c = system.today().adddays(14);
        offering2.PMP_Partner_Offering_Lifecycle_Status_Nm__c = 'Published';
        offering2.PMP_Working_Copy_Id__c =workoffering1.id;
        system.assertEquals('Published', offering2.PMP_Partner_Offering_Lifecycle_Status_Nm__c);
        offlist.add(offering2);
  
        update offlist;
         
         test.startTest();
         PMP_SendExpiryOfferingEmailsBatch batch = new PMP_SendExpiryOfferingEmailsBatch();
         Database.executeBatch(batch,1);
         test.stopTest();
        
    }
    
    static testMethod void testMethod21() {
      
        Account acc1 = PMP_TestDataUtility.createIntelAccount('account1',PMP_TestDataUtility.intel_Account_Record_Type,true);
        PMP_Company__c cmp1 = PMP_TestDataUtility.createCompanyInformation('TestCompny1',acc1.Id,true);
        List<PMP_Partner_Offering__c> offlist = new List<PMP_Partner_Offering__c>();
        
      PMP_Partner_Offering__c workoffering1 = PMP_TestDataUtility.createOffering('workingoffering1','Public Content','abc is xyz',cmp1.Id,true,'Draft','');
        workoffering1.PMP_Partner_Offering_End_Dt__c = system.today();
        workoffering1.PMP_Partner_Offering_Lifecycle_Status_Nm__c = 'Admin Review';
        offlist.add(workoffering1);
        
         
        PMP_Partner_Offering__c offering2 = PMP_TestDataUtility.createOffering('offering2','Public Content','abc is xyz',cmp1.Id,true,'Draft','');
        offering2.PMP_Partner_Offering_End_Dt__c = system.today().adddays(0);
        offering2.PMP_Partner_Offering_Lifecycle_Status_Nm__c = 'Published';
        offering2.PMP_Working_Copy_Id__c =workoffering1.id;
        system.assertEquals('Published', offering2.PMP_Partner_Offering_Lifecycle_Status_Nm__c);
        offlist.add(offering2);
  
        update offlist;
         
         test.startTest();
         PMP_SendExpiryOfferingEmailsBatch batch = new PMP_SendExpiryOfferingEmailsBatch();
         Database.executeBatch(batch,1);
         test.stopTest();
        
    }
*/
}