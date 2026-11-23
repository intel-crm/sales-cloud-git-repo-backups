/***************************************************************************************************
* Apex Class Name : Core_IPS_Case_Interested_Parties
* Test Class Name : Core_IPS_Case_Interested_PartiesTest
* Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Ganapati                   21/04/2020             Created for US639296 - LEX: Create: Create External Interested Party
****************************************************************************************************/

@isTest(seeAllData=false)
private class Core_IPS_Case_Interested_PartiesTest {
    
    @isTest
    private static void testMethod1() {
        
        List<string> listOfProfileNames = new List<string> {'System Administrator','IPS External Customer'};
        Map<String,ID> mapOfProfiles = new Map<String,ID>();
        for(Profile prof : [select id, name from Profile where name IN: listOfProfileNames]){
            mapOfProfiles.put(prof.name, prof.id);
        }
        
        // Create UserRole Record
        UserRole role = new UserRole();
        role.name='CEO';
        insert role;
        List<User> sysAdminUsr = TestUtilities.getListOfUser(1);
        sysAdminUsr.get(0).UserName = 'SysAdminUsr'+sysAdminUsr.get(0).UserName;
        sysAdminUsr.get(0).ProfileID =  mapOfProfiles.get('System Administrator');
        sysAdminUsr.get(0).userroleid =  role.ID;
        insert sysAdminUsr;
        // Creating SETUP OBJECT (USERROLE) RECORD
        System.RunAs(sysAdminUsr[0]){
            Id nacId = Core_IPS_Case_Interested_Parties.getCaseRecordtypeIDByName('IPS No Assigned Contact Case');
            System.assertEquals(true, nacId!=null);
            
            Account accountRec1 = TestUtilities.getAccount();
            accountRec1.Core_IPS_Active__c = true;
            insert accountRec1;
            
            List<Contact> listOfContacts = TestUtilities.getListOfContact(1);
            listOfContacts[0].Accountid = accountRec1.Id;
            insert listOfContacts;
            
            List<User> listOfExternalUsers = TestUtilities.getListOfUser(1);
            listOfExternalUsers.get(0).ProfileID = [select id, name from Profile where name = 'IPS External Customer'].Id;
            listOfExternalUsers.get(0).contactId = listOfContacts.get(0).Id;
            listOfExternalUsers.get(0).UserName = 'CustomerUser'+listOfExternalUsers.get(0).UserName;
            insert listOfExternalUsers;
            
            Integer cnt = Core_IPS_Case_Interested_Parties.findTotalRecords('SELECT count() FROM Account');
            System.assertEquals(true, cnt!=null);
            
            List<Contact> conList1 = Core_IPS_Case_Interested_Parties.getQueryResult('SELECT Id, Name FROM Contact', false);
            System.assertEquals(true, conList1!=null);
            
            List<Contact> conList2 = Core_IPS_Case_Interested_Parties.getQueryResult('SELECT Id, Name FROM Contact', true);
            System.assertEquals(true, conList2!=null);
            
            Map<String, String> conUsrMap =  Core_IPS_Case_Interested_Parties.getContactUserMap('SELECT Id, Name FROM Contact', false);
            System.assertEquals(true, conUsrMap!=null);
            
            List<Case> listOfCases = TestUtilities.getListOfCases(1);
            listOfCases.get(0).AccountId = accountRec1.Id;
            listOfCases.get(0).Core_IPS_Customer_Visible__c = true;
            insert listOfCases;
            Boolean editAccess = Core_IPS_Case_Interested_Parties.isCaseEditable(listOfCases.get(0).Id);
            System.assertEquals(true, editAccess!=null);
            
            List<Core_IPS_Case_Interested_Party__c> lstInterestedPartiesInternal = new List<Core_IPS_Case_Interested_Party__c>();
            Core_IPS_Case_Interested_Party__c newRecordInternal = new Core_IPS_Case_Interested_Party__c();
            newRecordInternal.User__c = UserInfo.getUserId(); 
            newRecordInternal.Case__c = listOfCases.get(0).Id;
            newRecordInternal.Type__c = 'Internal';
            newRecordInternal.Active__c = true;
            lstInterestedPartiesInternal.add(newRecordInternal);
            
            List<Core_IPS_Case_Interested_Party__c> lstInterestedPartiesInternal1 = Core_IPS_Case_Interested_Parties.insertInterestedParties(lstInterestedPartiesInternal, false);
            System.assertEquals(true, lstInterestedPartiesInternal1!=null);
            
            List<Core_IPS_Case_Interested_Party__c> lstInterestedPartiesExternal = new List<Core_IPS_Case_Interested_Party__c>();
            Core_IPS_Case_Interested_Party__c newRecordExternal = new Core_IPS_Case_Interested_Party__c();
            newRecordExternal.Contact__c = listOfContacts.get(0).Id; 
            newRecordExternal.Case__c = listOfCases.get(0).Id;
            newRecordExternal.Type__c = 'External';
            newRecordExternal.Active__c = true;
            lstInterestedPartiesExternal.add(newRecordExternal);
            
            List<Core_IPS_Case_Interested_Party__c> lstInterestedPartiesExternal1 = Core_IPS_Case_Interested_Parties.insertInterestedParties(lstInterestedPartiesExternal, true);
            System.assertEquals(true, lstInterestedPartiesExternal1!=null);
            
            List<Core_IPS_Case_Interested_Party__c> lstInterestedPartiesInternal2 = Core_IPS_Case_Interested_Parties.getLinkedInterestedParties(listOfCases.get(0).Id, 'Internal');
            System.assertEquals(true, lstInterestedPartiesInternal2!=null);
            List<Core_IPS_Case_Interested_Party__c> lstInterestedPartiesExternal2 = Core_IPS_Case_Interested_Parties.getLinkedInterestedParties(listOfCases.get(0).Id, 'External');
            System.assertEquals(true, lstInterestedPartiesExternal2!=null);        
            
            List<Core_IPS_Project__c> listOfIpsProjects = TestUtilities.getListOfIpsProjects(1);
            insert listOfIpsProjects;
            Core_Trigger_Executions__c  triggerExecution = new Core_Trigger_Executions__c();
            triggerExecution.Name = 'myIntelIntegration';
            triggerExecution.Core_Active__c = true;
            triggerExecution.Core_Class_Name__c ='Core_IPS_CaseTriggerHandler';
            triggerExecution.Core_Description__c = 'To update Case fields.';
            triggerExecution.Core_Object__c = 'Case';
            triggerExecution.Core_Trigger_Events__c = 'before insert';
            insert triggerExecution;
            
            List<Core_IPS_Project_Member__c> listOfProjectMembers = TestUtilities.getListOfProjectMembers(1);
            listOfProjectMembers.get(0).Core_IPS_Contact__c = listOfContacts.get(0).Id;
            listOfProjectMembers.get(0).Core_IPS_Project__c = listOfIpsProjects.get(0).Id;
            listOfProjectMembers.get(0).Core_User__c = listOfExternalUsers.get(0).Id;
            insert listOfProjectMembers;
            
            List<Id> conIdLst1 = Core_IPS_Case_Interested_Parties.getActiveContactIds(accountRec1.Id, null);
            System.assertEquals(true, conIdLst1!=null);
            
            List<Id> conIdLst2 = Core_IPS_Case_Interested_Parties.getActiveContactIds(null, listOfIpsProjects.get(0).Id);
            System.assertEquals(true, conIdLst2!=null);
            
            Core_IPS_Labels__c ipsLables2 = new Core_IPS_Labels__c(Name = 'Case_RT_Name_IPS_NoAssignedContact',Value__c = 'IPS No Assigned Contact Case');
            insert ipsLables2;
            
            List<String> profilesIdsList = Core_IPS_Case_Interested_Parties.getInternalPartiesProfileIds(listOfCases.get(0).Id);
            System.assertEquals(true, profilesIdsList!=null);
            Boolean customerVisibility = Core_IPS_Case_Interested_Parties.checkCustomerVisibility(listOfCases.get(0).Id);
            System.assertEquals(true, customerVisibility);
            
        }
    }    
}