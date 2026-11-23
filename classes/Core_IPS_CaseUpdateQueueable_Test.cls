/***************************************************************************************************
Class Name          : Core_IPS_CaseUpdateQueueable_Test
Version             : 1.0 
Created Date        : 3 Oct 2018
Function            : This Class is for Test coverage of Core_IPS_CaseUpdateQueueable
Input Parameters    : List<Case> and String
Output Parameters   : NA
Description         : NA
Used in             : trigger Handler class Core_IPS_Response_Handler
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                    
* Aayushi Singhal             03/10/2018              Created US185674
****************************************************************************************************/ 

@isTest
public class Core_IPS_CaseUpdateQueueable_Test {
    private static User SystUserRunAs;    
    private static void getRecords(){
        Profile prof = [select id from profile where name = 'System Administrator' limit 1];
        List<User> userList = new List<user>();
        userList = TestUtilities.getListOfUser(1);
        userList[0].profileId=prof.id;
        insert userlist;
        SystUserRunAs = new User();
        SystUserRunAs = userList[0];
    }
    
    static testmethod void Core_IPS_CaseUpdateBatch_Test_Method(){
        getRecords();
        List<Case> caseList=new List<Case>();
        Id intelSupportOwner = TestUtilities.getListOfUser(1).get(0).id;
        System.runAs(SystUserRunAs){
            //Create Support Org
            List<Core_IPS_Product_Organization__c> ListOfSupportOrg  = TestUtilities.getListOfSupportOrg(2);
            insert ListOfSupportOrg;
            
            System.assert(ListOfSupportOrg != null, 'Record not created');
            
            //Create Accounts
            List<Account> ListOfAccounts = TestUtilities.getListOfAccounts(2);
            insert ListOfAccounts;
            System.assert(ListOfAccounts[0].Id != null, 'Record not created');
            
            //Create Contacts
            List<Contact> ListOfContacts = TestUtilities.getListOfContact(1);
            for(Contact ContactRec : ListOfContacts){
                ContactRec.Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
                ContactRec.core_ips_Active__c=true;
                ContactRec.Accountid = ListOfAccounts.get(0).Id; 
            }
            insert ListOfContacts;
            System.assert(ListOfContacts[0].Id != null, 'Record not created');
            
            //Create Case
            
            Case c1 = TestUtilities.getListOfCases(2).get(0);
            c1.accountId = ListOfAccounts.get(0).Id;
            c1.ContactId = ListOfContacts.get(0).id;
            c1.Core_IPS_Customer_Visible__c = false;
            caseList.add(c1);
            Case c2 = TestUtilities.getListOfCases(2).get(1);
            c2.accountId = ListOfAccounts.get(0).Id;
            c2.ContactId = ListOfContacts.get(0).id;
            c2.Core_IPS_Customer_Visible__c = false;
            caseList.add(c2);
            insert caseList; 
            
            //Get Record Type
            Id edqRecordTypeId = Schema.SObjectType.Core_IPS_Question__c.getRecordTypeInfosByName().get('Environment Detail Question').getRecordTypeId();
            
            //Create Core Question
            Core_IPS_Question__c cq = new Core_IPS_Question__c();
            cq.recordTypeId = edqRecordTypeId;
            cq.Core_IPS_Datatype__c = 'Picklist';
            cq.Core_IPS_Order_No__c = 1;
            cq.Core_IPS_Parent_Question__c = null;
            cq.Core_IPS_Product_Organization__c = ListOfSupportOrg.get(0).Id; 
            cq.Core_IPS_Question__c = 'Test';
            cq.Core_IPS_Required__c = false;
            cq.Core_IPS_Status__c = 'Active';
            cq.Core_IPS_Add_to_Reporting__c=true;
            cq.Core_IPS_Reporting_Name__c='test';
            
            insert cq;
            
            Core_IPS_Response_Handler.wrapResponse wrap = new Core_IPS_Response_Handler.wrapResponse();
            
            List<Core_IPS_Response__c> envResponses = TestUtilities.getCoreResponseRecords(2);
            for(Core_IPS_Response__c envResp : envResponses){
                envResp.Core_IPS_Case__c = c1.id;
                envResp.Core_IPS_Question_Master__c = cq.id;
            }
            insert envResponses;
        }
        ID jobID1 = System.enqueueJob(new Core_IPS_CaseUpdateQueueable(caseList,Core_IPS_CaseUpdateQueueable.Mode.EDQ));
        
        ID jobID2 = System.enqueueJob(new Core_IPS_CaseUpdateQueueable(caseList,Core_IPS_CaseUpdateQueueable.Mode.GENERAL));
        
    }
}