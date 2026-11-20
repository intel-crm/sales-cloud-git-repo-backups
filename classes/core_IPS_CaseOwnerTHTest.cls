@isTest 
private class core_IPS_CaseOwnerTHTest {
    static testMethod void assignUserValues() {
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
       
        User u = new User(Alias = 'standt', Email='standarduser@intel.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles', UserName='newOnlyUserForCaseowner@testorg.com');
        
        insert u;
        Core_IPS_Product_Organization__c suppOrg = Core_IPS_Backend_TestClass_Utility.getSupportOrg();
        insert suppOrg;
        
        Core_IPS_Case_Owner_Group__c cc = new Core_IPS_Case_Owner_Group__c();
        cc.Core_IPS_Case_Owner__c = u.id;
        cc.Core_IPS_Owner_Group_3__c = 'test';
        cc.Core_IPS_Support_Org__c = suppOrg.id;
        cc.Core_IPS_Owner_Team_1__c='ABCUser';
        cc.Core_IPS_Owner_Team_2__c='UserQWE';
        cc.Core_IPS_Owner_Team_3__c='TeamTest';
        cc.Core_IPS_Owner_Group_1__c='GroupOne';
        cc.Core_IPS_Owner_Group_2__c='GroupTwo';
        insert cc;
        
        
        
    }
    
    static testMethod void updateCOGRecords_Test(){
        
        Core_Trigger_Executions__c TriggerExecution = new Core_Trigger_Executions__c();
        TriggerExecution.Name = 'updateCOGRecords';
        TriggerExecution.Core_Active__c = true;
        TriggerExecution.Core_Class_Name__c ='Core_IPS_CaseOwnerGroup_TriggerHandler';
        TriggerExecution.Core_Description__c = 'This method will execute whenever a COG record is to be updated apart from the default values assigned during insertion';
        TriggerExecution.Core_Object__c = 'Case Owner Group';
        TriggerExecution.Core_Trigger_Events__c = 'before update';
        
        insert TriggerExecution;
               
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        user us = [select id,managerId from User where managerId!=null limit 1];
        User u = new User(Alias = 'standt', Email='standarduser@intel.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, managerId=us.ManagerId,
                          TimeZoneSidKey='America/Los_Angeles', UserName='newOnlyUserForCaseowner@testorg.com');
        
        insert u;
        Core_IPS_Product_Organization__c suppOrg = Core_IPS_Backend_TestClass_Utility.getSupportOrg();
        insert suppOrg;
        
        Core_IPS_Case_Owner_Group__c cc = new Core_IPS_Case_Owner_Group__c();
        cc.Core_IPS_Case_Owner__c = u.id;
        cc.Core_IPS_Owner_Group_3__c = 'test';
        cc.Core_IPS_Support_Org__c = suppOrg.id;
        cc.Core_IPS_Owner_Team_1__c='ABCUser';
        cc.Core_IPS_Owner_Team_2__c='UserQWE';
        cc.Core_IPS_Owner_Team_3__c='TeamTest';
        cc.Core_IPS_Owner_Group_1__c='GroupOne';
        cc.Core_IPS_Owner_Group_2__c='GroupTwo';
        insert cc;
        
        Core_IPS_Case_Owner_Group__c cc1 = new Core_IPS_Case_Owner_Group__c();
        cc1 = [select id from Core_IPS_Case_Owner_Group__c where Core_IPS_Owner_Group_1__c='GroupOne'];
        cc1.Core_IPS_Owner_Group_1__c = 'Updated';
        cc1.Core_IPS_Owner_Group_2__c='GroupTwoUodated';
        cc1.Core_IPS_Owner_Group_3__c = 'testUpdated';
        cc1.Core_IPS_Owner_Team_1__c='ABCUserUpdated';
        cc1.Core_IPS_Owner_Team_2__c='UserQWEUpdated';
        cc1.Core_IPS_Owner_Team_3__c='TeamTestUpdated';
        cc1.Core_IPS_Case_Owner_Email__c = 'testUser123@xyz.com';
        update cc1;
        
              
    }
    
    
    
}