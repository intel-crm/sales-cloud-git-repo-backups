@isTest
private class Core_IPS_Update_Sub_Status_Test {
     
    static testmethod void test() {
      
    
    Case newCase = new Case(ContactId = '0033F000004sXVd',Core_IPS_Country_Region__c = 'Aland Islands',Core_IPS_Issue_source__c = 'Internal Portal',Core_CaseType__c = 'Design Review',Core_Severity__c = 'Low',Subject = 'Test case',Description = 'Test Case');
    
    newCase.Status='Closed';
    newCase.Core_Sub_Status__c='Investigating';
    newCase.RecordTypeId='012o0000000TPVi';
    insert newCase;
     
    Test.startTest();
    Core_IPS_Update_Sub_Status updateSubStatus = new Core_IPS_Update_Sub_Status();
    Database.executeBatch(updateSubStatus);   
    Test.stopTest();
     
    
    //Case[] caseUpdatedList = [SELECT Id,Contact FROM Case];
    //System.assert(caseUpdatedList[0].Contact.Contains('Updated'));
    }
    }