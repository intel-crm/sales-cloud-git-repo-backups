/*-------------------------------------------------------------------------------------------
Apex Class  : Core_Claim_Lead_Ctrl_Test
Version     : 1.0 
Created Date: 22 November 2018
Function    : Test class for Core_Claim_Lead_Ctrl
Modification Log :
* Developer                  Date                   Description
* ----------------------------------------------------------------------------                 
* Sougata Sarkar            22/11/2018              Original Version
--------------------------------------------------------------------------------------------*/

@isTest
public class Core_Claim_Lead_Ctrl_Test {

    static testMethod void verifyOwnerTest(){
        List<User> lstUser = new List<User>();
        Profile p1 = [SELECT Id FROM Profile WHERE Name = : System.label.Core_StandardUser];
        lstUser = Core_Test_Utility.Core_User(1);
        lstUser[0].Profileid = p1.id;
        insert lstUser;
        
        String leadRecType = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByName().get('Sales Lead').getRecordTypeId();
        List<Lead> lstLead = new List<Lead>();
        lstLead = Core_Test_Utility.createLead(2);
        for (Lead sobjLead: lstLead) {
            sobjLead.recordtypeId = leadRecType;
            sobjLead.Status = 'Tele Accepted Lead';
            sobjLead.Core_Lead_Status__c = 'Accepted';
            sobjLead.Core_Geo__c = '';
            sobjLead.Core_Sub_Geo__c = '';
            sobjLead.Phone = '(555) 555-5555';
            sobjLead.Title = '(555) 555-5555';
            sobjLead.Core_Current_Architecture__c = '(555) 555-5555';
            sobjLead.Core_Job_Function__c = '(555) 555-5555';
            sobjLead.Core_Product_Interest__c = '(555) 555-5555';
            sobjLead.Core_Project_Phase__c = '(555) 555-5555';
            sobjLead.Core_Project_Size__c = '555';
            sobjLead.Core_Project_Timeframe__c = '555';
            sobjLead.Core_Sales_Segment__c = '555';
            sobjLead.PostalCode = '560035';
        }
        
        System.runAs(lstUser[0]) {
            // Insert the intialized Lead
            lstLead[0].OwnerId = lstUser[0].Id;
            insert lstLead[0];
        }
        Core_Claim_Lead_Ctrl.verifyOwner(lstLead[0].Id);
        lstLead[1].OwnerId = UserInfo.getUserId();
        insert lstLead[1];
        Core_Claim_Lead_Ctrl.verifyOwner(lstLead[1].Id);
    }
}