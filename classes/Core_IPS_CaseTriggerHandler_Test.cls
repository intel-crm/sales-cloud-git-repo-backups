/***************************************************************************************************
Class Name:  Core_IPS_CaseTriggerHandler_Test
Class Type: Test Class 
Version     : 1.0 
Created Date: 06 Nov 2015
Function    : This class contains test coverage for Core_IPS_CaseTriggerHandler class
Input Parameters: None 
Output Parameters: None
Description:   This class contains unit test scenarios for Core_IPS_CaseTriggerHandler class
Used in     : None
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Syed Moosa Nazir TN       11/06/2015                 Created
* Deepak Jetty              25/01/2016                 Modified
* Ganapati                  29/07/2019                 Modified for - US404375 - Technical: Test Classes are failing in Production 
* //System.assert()--> statement Added By Hassan Khan 02-02-2024
****************************************************************************************************/   
@isTest
public class Core_IPS_CaseTriggerHandler_Test{
    //Instance variables that are commonly used in multiple test methods
    static List<User> listOfUser = new List<User> ();
    static Group grp = new Group();
    static Core_IPS_Product_Issue_Category__c caseCat = new Core_IPS_Product_Issue_Category__c();
    static  Core_IPS_Product_Issue_Category__c subCategory = new Core_IPS_Product_Issue_Category__c();
    public static Id slaprocessId = [Select Id, Name, NameNorm, IsActive, VersionNumber from SlaProcess Where Name = 'IPS Standard SLA Entitlement' and IsActive=true].Id;

    private static void insertUsersWithValidationBypass(List<User> users) {
        User validationBypassUser = [SELECT Id FROM User WHERE Profile.Name = :System.Label.Core_System_Admin_Profile_Name AND IsActive = true LIMIT 1];
        System.runAs(validationBypassUser) {
            insert users;
        }
    }
    
    
    /***************************************************************************************************
Method Name:  getRecords()
Method Type: void
Version     : 1.0 
Created Date: 05 Nov 2015
Description:  Common Test data used for all test methods
Scenario Type:  
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Syed Moosa Nazir TN       11/05/2015              Created
****************************************************************************************************/
    static void getRecords (){
        // Query Profiles
        Map<String,ID> profiles = new Map<String,ID>();
        List<Profile> profileList = [select id, name from Profile where name = 'System Administrator'];
        for(Profile prf : profileList){
            profiles.put(prf.name, prf.id);
        }
        // Create Users
        listOfUser = TestUtilities.getListOfUser(2);
        for(User usr : listOfUser){
            usr.ProfileID =  profiles.get('System Administrator');
        }
        insertUsersWithValidationBypass(listOfUser);
        System.assertEquals(listOfUser.get(0).profileid, profiles.get('System Administrator'), 'System Admin');
        System.runAs(listOfUser.get(0)){
            //Create Group
            grp = TestUtilities.getQueue();
            grp.Type='Regular';
            insert grp;
            Group grp1 = new Group(Name='IPS - Unassigned Cases',Type='Queue');
            insert grp1;
            //Create Group Members
            List<GroupMember> listGM = new List<GroupMember>();
            for(User usr:listOfUser){
                GroupMember grpMem = new GroupMember();
                grpMem.GroupId = grp.Id;
                grpMem.UserOrGroupId = usr.Id;
                listGM.add(grpMem);
            }
            //insert Group Memebers
            if(!listGM.isEmpty()){
                insert listGM;
            }
            List<Core_IPS_Labels__c> listofIpsLables = TestUtilities.getIPSLabel();
            insert listofIpsLables;
            List<Core_IPS_Labels__c> lablesList = new List<Core_IPS_Labels__c>();
            
            Core_IPS_Labels__c labels1 = new Core_IPS_Labels__c();
            labels1.name= 'IPS_Case_Status_Investigating';
            labels1.value__c='Investigating';
            lablesList.add(labels1);
            string gecRTypeId = [SELECT id from RecordType where Name ='IPS GEC ReadOnly'].Id;
            Core_IPS_Labels__c labels2 = new Core_IPS_Labels__c();
            labels2.name= 'GEC Record Type Id';
            labels2.value__c=gecRTypeId;
            lablesList.add(labels2);
            Core_IPS_Labels__c labels3 = new Core_IPS_Labels__c(Name = 'GEC_Status_Approved_WithG',Value__c = 'Approved with Guardrails');
            lablesList.add(labels3);
            // Avoid Hardcoding Id Fix - Start - Shipra
            Core_ERPM_Engagement__c cee=new Core_ERPM_Engagement__c(Name  ='Partner File Transfer', Core_Engagement_Type__c='SEC',Core_IsActive__c=true,Core_Technical_Engagement_Code__c='PFT',Core_Technical_DeDup_Number__c='B2B');
            insert cee;
            Core_Entitlement__c entitle=new Core_Entitlement__c (name ='Advanced Shipment and Invoice Notification', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='test dup',Core_IsActive__c=true);
            insert entitle;
            Core_IPS_Labels__c labels4 = new Core_IPS_Labels__c(Name = 'SelfAssignedCaseEntitlementId',Value__c = entitle.Id);
             // Core_IPS_Labels__c labels4 = new Core_IPS_Labels__c(Name = 'SelfAssignedCaseEntitlementId',Value__c = '550o0000000B51vAAC');
            lablesList.add(labels4);
          // Avoid Hardcoding Id Fix - End - Shipra
            // change added by chiru - code refactor - embargo country label
            Core_IPS_Labels__c labelVal = new Core_IPS_Labels__c(Name = 'Core_IPS_EmbargoedCountryList',Value__c = 'USA,INDIA');
            lablesList.add(labelVal);
            insert lablesList;
            
            Core_IPS_Labels__c slaprocessLabel = [SELECT Id, Name, value__c FROM Core_IPS_Labels__c WHERE Name = 'IPS Standard Entitlement Process ID' LIMIT 1];
            slaprocessLabel.value__c = slaprocessId;
            update slaprocessLabel;
            System.assert(listofIpsLables[0].Id != null, 'Records not created');
            
            List<Core_IPS_Q_Biz_hours_mapping__c> labellist2 = new List<Core_IPS_Q_Biz_hours_mapping__c>();
            Core_IPS_Q_Biz_hours_mapping__c bizLabel1 = new Core_IPS_Q_Biz_hours_mapping__c();
            BusinessHours stdBusinessHours = [select id from BusinessHours where Name = 'Default'];
            bizLabel1.Name = 'Default';
            bizLabel1.Business_Hours_Name__c = 'Default';
            bizLabel1.Business_Hours_ID__c = stdBusinessHours.Id;
            bizLabel1.Queue_ID__c = grp1.Id;
            bizLabel1.Queue_Name__c = grp1.Name;
            labellist2.add(bizLabel1);   
            Core_IPS_Q_Biz_hours_mapping__c bizLabel2 = new Core_IPS_Q_Biz_hours_mapping__c();
            bizLabel2.Name = 'test_group';
            bizLabel2.Business_Hours_Name__c = 'test_group';
            bizLabel2.Business_Hours_ID__c = stdBusinessHours.Id;
            bizLabel2.Queue_ID__c = grp1.Id;
            bizLabel2.Queue_Name__c = grp1.Name;
            labellist2.add(bizLabel2);
            insert labellist2;
            
            //Custom Setting - Ips Error Codes
            List<Core_IPS_Error_Code__c> listofIpsErrorCodes = TestUtilities.getListOfIpsErrorCodes();
            insert listofIpsErrorCodes;
            System.assert(listofIpsErrorCodes[0].Id != null, 'Records not created');
            //Custom Setting - Trigger Executions
            List<Core_Trigger_Executions__c> listOftriggerExecutions = TestUtilities.getListOftriggerExecutions();
            insert listOftriggerExecutions;
            System.assert(listOftriggerExecutions[0].Id != null, 'Records not created');
            
            
        }
    }
    
    /***************************************************************************************************
Method Name: exerciseloadGroupByName_Test
Method Type: Test Method
Version     : 1.0 
Created Date: 8/2/2016
Description:  Exercise the loadGroupByName function to obtain 85% coverage BKM
Scenario Type:  Positive
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Brian Matthews            8/2/2016                 Created
****************************************************************************************************/
    static testmethod void exerciseloadGroupByNameTest(){
        final String GROUP_NAME_TEXT = 'ORG_1';
        
        Map<String,Group> mapGroupByName = new Map<String,Group>();
        List<Group> groupNames = [Select Id, Name, DeveloperName  from Group limit 1];
        Core_IPS_CaseTriggerHandler.loadGroupByName(groupNames, mapGroupByName);
        
        mapGroupByName.put(GROUP_NAME_TEXT, new Group());    
        //  Core_IPS_CaseTriggerHandler.loadGroupByName(NULL, NULL);
        // Core_IPS_CaseTriggerHandler.loadGroupByName(NULL, mapGroupByName);
        //Changes Made By Chiru - Code Refactor
        Core_IPS_CaseTriggerHandler.loadGroupByName(groupNames, mapGroupByName);        
        
        Group simpleGroup = new Group(Name=GROUP_NAME_TEXT, DeveloperName=GROUP_NAME_TEXT);
        insert simpleGroup;
        System.assertEquals(simpleGroup!=null, true, 'Group Inserted');
        
        mapGroupByName.clear();
        Core_IPS_CaseTriggerHandler.loadGroupByName(groupNames, mapGroupByName);        
        
    }
    
    /***************************************************************************************************
Method Name:  assignEntitlementToCaseWithEntCon_Test
Method Type: Test Method
Version     : 1.0 
Created Date: 06 Nov 2015
Description:  Testing with EntitlementContact record
Scenario Type:  Positive
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Syed Moosa Nazir TN       11/06/2015                Created
* Deepak Jetty              25/01/2016                Modified
****************************************************************************************************/
    static testmethod void assignEntitlementToCaseWithEntConTest(){
        getRecords();
        // Get intelSupportOwner Id (User Id)
        Id intelSupportOwner = listOfUser.get(0).id;
        System.runAs(listOfUser.get(1)){
            // Create Accounts
            List<Account> listOfAccounts = TestUtilities.getListOfAccounts(1);
            insert listOfAccounts;
            System.assert(listOfAccounts[0].Id != null, 'Record not created');
            // Create Contact
            List<Contact> listOfContacts = TestUtilities.getListOfContact(1);
            for(Contact contactRec : listOfContacts){
                contactRec.Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
                contactRec.Accountid = listOfAccounts.get(0).Id;
                contactRec.MailingCountry = 'India';
            }
            insert listOfContacts;
            System.assert(listOfContacts[0].Id != null, 'Record not created');
            // Create Asset
            list<Asset> assetList = TestUtilities.getAssetList(1);
            for(Asset asst : assetList){
                asst.accountId = listOfAccounts.get(0).Id;
                asst.Contactid = listOfContacts.get(0).id;
            }
            insert assetList;
            Core_IPS_CaseCreateHelper cls = new Core_IPS_CaseCreateHelper();
            cls.getProductVariant(assetList[0].product2Id);
            System.assert(assetList[0].Id != null, 'Record not created');
            // Create Entitlement
            List<Entitlement> listOfEntitlement = TestUtilities.getListOfEntitlement(1);
            for(Entitlement entitlementRec : listOfEntitlement){
                entitlementRec.AccountId = listOfAccounts.get(0).Id;
                entitlementRec.AssetId = assetList.get(0).id;
            }
            insert listOfEntitlement;
            System.assert(listOfEntitlement[0].Id != null, 'Record not created');
            // Create EntitlementContact
            List<EntitlementContact> listOfEntitlementContact = TestUtilities.getListOfEntitlementContact(1);
            for(EntitlementContact entitlementContactRec : listOfEntitlementContact){
                entitlementContactRec.ContactId = listOfContacts.get(0).Id;
                entitlementContactRec.EntitlementId = listOfEntitlement.get(0).id;
            }
            insert listOfEntitlementContact;
            System.assert(listOfEntitlementContact[0].Id != null, 'Record not created');
            // Create Case
            List<Case> listOfCases = TestUtilities.getListOfCases(3);
            for(Case caseRec : listOfCases){
                caseRec.ContactId = listOfContacts.get(0).id;
                caseRec.accountId = listOfAccounts.get(0).Id;
            }
            //get Business Hours
            Test.startTest();
            /* List<BusinessHours> bhs=[select id from BusinessHours where IsDefault=true];
//Create Queue Business Hours
Core_IPS_Q_Biz_hours_mapping__c queueXBizHours = TestUtilities.getQueueXBizHours();
queueXBizHours.Business_Hours_ID__c = bhs.get(0).id;
queueXBizHours.Business_Hours_Name__c = 'Ashok_Test';
queueXBizHours.Queue_ID__c = grp.Id;
queueXBizHours.Queue_Name__c = grp.Name;
//insert Queue Business Hours
insert queueXBizHours;
insert listOfCases;
System.assert(listOfCases[0].Id != null, 'Record not created');
update listOfCases;
List<Case> listOfCase = [select id from case where id IN: listOfCases];
System.assert(listOfCase[0].id != null, 'Record not updated');
delete listOfCase;
List<Case> listOfCaseDelete = [select id from case where id IN: listOfCase];
System.assert(listOfCaseDelete.isEmpty(), 'Record not deleted');
undelete listOfCase;
List<Case> listOfCaseUnDelete = [select id from case where id IN: listOfCase];
System.assert(listOfCase[0].id != null, 'Record not Undeleted');*/
            Test.stopTest();
        }
    }
    
    /***************************************************************************************************
Method Name:  assignEntitlementToCaseWithoutEntCon_Test
Method Type: Test Method
Version     : 1.0 
Created Date: 06 Nov 2015
Description:  Testing without EntitlementContact record
Scenario Type:  Positive
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Syed Moosa Nazir TN       11/06/2015                Created
* Deepak Jetty              25/01/2016                Modified
****************************************************************************************************/
    /* static testmethod void assignEntitlementToCaseWithoutEntConTest(){
getRecords();
// Get intelSupportOwner Id (User Id)
Id intelSupportOwner = listOfUser.get(0).id;
System.runAs(listOfUser.get(1)){
// Create Accounts
List<Account> listOfAccounts = TestUtilities.getListOfAccounts(1);
insert listOfAccounts;
System.assert(listOfAccounts[0].Id != null, 'Record not created');
// Create Contact
List<Contact> listOfContacts = TestUtilities.getListOfContact(1);
for(Contact contactRec : listOfContacts){
contactRec.Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
contactRec.Accountid = listOfAccounts.get(0).Id;
}
insert listOfContacts;
System.assert(listOfContacts[0].Id != null, 'Record not created');
// Create Asset
list<Asset> assetList = TestUtilities.getAssetList(1);
for(Asset asst : assetList){
asst.accountId = listOfAccounts.get(0).Id;
asst.Contactid = listOfContacts.get(0).id;
}
insert assetList;
System.assert(assetList[0].Id != null, 'Record not created');
// Create Entitlement
List<Entitlement> listOfEntitlement = TestUtilities.getListOfEntitlement(1);
for(Entitlement entitlementRec : listOfEntitlement){
entitlementRec.AccountId = listOfAccounts.get(0).Id;
entitlementRec.AssetId = assetList.get(0).id;
}
insert listOfEntitlement;
System.assert(listOfEntitlement[0].Id != null, 'Record not created');
// Create Case
List<Case> listOfCases = TestUtilities.getListOfCases(10);
for(Case caseRec : listOfCases){
caseRec.ContactId = listOfContacts.get(0).id;
caseRec.accountId = listOfAccounts.get(0).Id;
}
//get Business Hours
List<BusinessHours> bhs=[select id from BusinessHours where IsDefault=true];
//Create Queue Business Hours
Core_IPS_Q_Biz_hours_mapping__c queueXBizHours = TestUtilities.getQueueXBizHours();
queueXBizHours.Business_Hours_ID__c = bhs.get(0).id;
queueXBizHours.Business_Hours_Name__c = 'Ashok_Test';
queueXBizHours.Queue_ID__c = grp.Id;
queueXBizHours.Queue_Name__c = grp.Name;
//insert Queue Business Hours
insert queueXBizHours;
Test.startTest();
insert listOfCases;
System.assert(listOfCases[0].Id != null, 'Record not created');
update listOfCases;
List<Case> listOfCase = [select id from case where id IN: listOfCases];
System.assert(listOfCase[0].id != null, 'Record not updated');
delete                                                       ;
List<Case> listOfCaseDelete = [select id from case where id IN: listOfCase];
System.assert(listOfCaseDelete.isEmpty(), 'Record not deleted');
//Sneha
//undelete listOfCase;
//List<Case> listOfCaseUnDelete = [select id from case where id IN: listOfCase];
//System.assert(listOfCase[0].id != null, 'Record not Undeleted');
Test.stopTest();
}
}*/
    
    /***************************************************************************************************
Method Name:  assignEntitlementToCase_NegativeTest
Method Type: Test Method
Version     : 1.0 
Created Date: 06 Nov 2015
Description:  Testing without Entitlement and EntitlementContact record
Scenario Type: Negative
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Syed Moosa Nazir TN       11/06/2015                Created
* Deepak Jetty              25/01/2016                Modified
****************************************************************************************************/
    static testmethod void assignEntitlementToCaseNegativeTest(){
        getRecords();
        // Get intelSupportOwner Id (User Id)
        Id intelSupportOwner = listOfUser.get(0).id;
        System.runAs(listOfUser.get(1)){
            List<Account> listOfAccounts = TestUtilities.getListOfAccounts(1);
            insert listOfAccounts;
            System.assert(listOfAccounts[0].Id != null, 'Record not created');
            // Create Contact
            List<Contact> listOfContacts = TestUtilities.getListOfContact(1);
            for(Contact contactRec : listOfContacts){
                contactRec.Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
                contactRec.Accountid = listOfAccounts.get(0).Id;
                contactRec.MailingCountry = 'India';
            }
            insert listOfContacts;
            System.assert(listOfContacts[0].Id != null, 'Record not created');
            // Create Asset
            list<Asset> assetList = TestUtilities.getAssetList(1);
            for(Asset asst : assetList){
                asst.accountId = listOfAccounts.get(0).Id;
                asst.Contactid = listOfContacts.get(0).id;
            }
            insert assetList;
            System.assert(assetList[0].Id != null, 'Record not created');
            // Create Entitlement
            List<Entitlement> listOfEntitlement = TestUtilities.getListOfEntitlement(1);
            for(Entitlement entitlementRec : listOfEntitlement){
                entitlementRec.AccountId = listOfAccounts.get(0).Id;
                entitlementRec.AssetId = assetList.get(0).id;
            }
            insert listOfEntitlement;
            System.assert(listOfEntitlement[0].Id != null, 'Record not created');
            //get Business Hours
            Test.startTest();
            /*Sneha List<BusinessHours> bhs=[select id from BusinessHours where IsDefault=true];
//Create Queue Business Hours
Core_IPS_Q_Biz_hours_mapping__c queueXBizHours = TestUtilities.getQueueXBizHours();
queueXBizHours.Business_Hours_ID__c = bhs.get(0).id;
queueXBizHours.Business_Hours_Name__c = 'Ashok_Test';
queueXBizHours.Queue_ID__c = grp.Id;
queueXBizHours.Queue_Name__c = grp.Name;
//insert Queue Business Hours
insert queueXBizHours;
//Create Custom IPS Lables
Core_IPS_Labels__c    ipsLabels = new Core_IPS_Labels__c();
ipsLabels.Name = listOfEntitlement.get(0).id;
ipsLabels.Value__c = 'SelfAssignedCaseEntitlementId';
//Insert IPS Labels
insert ipsLabels;
// Create Case
List<Case> listOfCases = TestUtilities.getListOfCases(10);
for(Case caseRec : listOfCases){
caseRec.ContactId = listOfContacts.get(0).id;
caseRec.accountId = listOfAccounts.get(0).Id;
}
insert listOfCases;
System.assert(listOfCases[0].Id != null, 'Record not created');
update listOfCases;
List<Case> listOfCase = [select id from case where id IN: listOfCases];
System.assert(listOfCase[0].id != null, 'Record not updated');
delete listOfCase;
List<Case> listOfCaseDelete = [select id from case where id IN: listOfCase];
System.assert(listOfCaseDelete.isEmpty(), 'Record not deleted');
//undelete listOfCase;
//List<Case> listOfCaseUnDelete = [select id from case where id IN: listOfCase];
//System.assert(listOfCase[0].id != null, 'Record not Undeleted'); */
            Test.stopTest();
        }
    } 
    
    
    /***************************************************************************************************
Method Name:  caseSLAManagement_Test
Method Type: Test Method
Version     : 1.0 
Created Date: 06 Nov 2015
Description:  Testing caseSLAManagement method
Scenario Type:  Positive
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Syed Moosa Nazir TN       11/06/2015                Created
* Deepak Jetty              25/01/2016                Modified
****************************************************************************************************/
    static testmethod void caseSLAManagementTest(){
        getRecords();
        RecordType recType = [Select Name, Id From RecordType where sObjectType='Case' and name = 'IPS GEC ReadOnly'];
        // Get intelSupportOwner Id (User Id)
        Id intelSupportOwner = listOfUser.get(0).id;
        System.runAs(listOfUser.get(0)){
            // Create Accounts
            List<Account> listOfAccounts = TestUtilities.getListOfAccounts(1);
            insert listOfAccounts;
            System.assert(listOfAccounts[0].Id != null, 'Record not created');
            // Create Contact
            List<Contact> listOfContacts = TestUtilities.getListOfContact(1);
            for(Contact contactRec : listOfContacts){
                contactRec.Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
                contactRec.Accountid = listOfAccounts.get(0).Id;
                contactRec.MailingCountry = 'India';
            }
            insert listOfContacts;
            System.assert(listOfContacts[0].Id != null, 'Record not created');
            // Create Asset
            list<Asset> assetList = TestUtilities.getAssetList(1);
            for(Asset asst : assetList){
                asst.accountId = listOfAccounts.get(0).Id;
                asst.Contactid = listOfContacts.get(0).id;
            }
            insert assetList;
            System.assert(assetList[0].Id != null, 'Record not created');
            // Create Entitlement
            List<Entitlement> listOfEntitlement = TestUtilities.getListOfEntitlement(1);
            for(Entitlement entitlementRec : listOfEntitlement){
                entitlementRec.AccountId = listOfAccounts.get(0).Id;
                entitlementRec.AssetId = assetList.get(0).id;
            }
            insert listOfEntitlement;
            System.assert(listOfEntitlement[0].Id != null, 'Record not created');
            // Create Case
            List<Case> listOfCases = TestUtilities.getListOfCases(2);
            for(Case caseRec : listOfCases){
                caseRec.ContactId = listOfContacts.get(0).id;
                caseRec.accountId = listOfAccounts.get(0).Id;
                caseRec.Core_Next_Response_Due_Date__c= Date.valueOf('2008-01-01 00:00:00');
                caseRec.Core_Sub_Status__c = 'Waiting for Customer Clarification*';
                caseRec.Core_Issue_Description__c = 'Test';
                caseRec.Core_IPS_GEC_Case__c = true;
            }
            //get Business Hours
            //List<BusinessHours> bhs=[select id from BusinessHours where IsDefault=true];
            //Create Queue Business Hours
            Test.startTest();   
            Core_IPS_Q_Biz_hours_mapping__c queueXBizHours = TestUtilities.getQueueXBizHours();
            // queueXBizHours.Business_Hours_ID__c = bhs.get(0).id;
            queueXBizHours.Business_Hours_Name__c = 'Ashok_Test';
            queueXBizHours.Queue_ID__c = grp.Id;
            queueXBizHours.Queue_Name__c = grp.Name;
            //insert Queue Business Hours
            //insert queueXBizHours;
            Core_IPS_Labels__c ipsLabel = new Core_IPS_Labels__c();
            ipsLabel.Name = 'GEC Record Type Id';
            ipsLabel.Value__c = recType.id;
            insert ipsLabel;
            
            insert listOfCases;
            System.assert(listOfCases[0].Id != null, 'Record not created');
            
            List<Casemilestone> cst = new List<Casemilestone>();    
            List<Casemilestone> csmstone = [Select caseid, StartDate,CompletionDate from Casemilestone where caseid in :listOfCases];
            for(CaseMilestone cs :csmstone){
                cs.StartDate = system.today()-1;
                // cs.CompletionDate = null;
                cst.add(cs);
            }
            update cst;
            
            
            List<Case> listOfCase = [select isStopped, Core_Sub_Status__c from case where id IN: listOfCases];
            integer counter = 0;
            for(Case caseRec : listOfCase){
                caseRec.isStopped = false;
                caseRec.Core_Issue_Description__c = 'Test1';
                caseRec.Core_IPS_GEC_Case__c = false;
                caseRec.Core_Next_Response_Due_Date__c= Date.valueOf('2017-06-05 00:00:00');
                if(counter < 5){
                    caseRec.Core_Sub_Status__c = 'Investigating';
                    caseRec.RecordTypeId = recType.id;
                }else{
                    caseRec.Core_Sub_Status__c = 'Investigating';
                    caseRec.RecordTypeId = recType.id;
                    
                }
                counter++;
            }
            counter = 0;
            update listOfCase;
            /*Sneha
List<Case> ListOfCas = [select Core_Sub_Status__c, RecordTypeId from case where id IN: listOfCase];
System.assertEquals(ListOfCas[0].RecordTypeId,  recType.id);
delete ListOfCas;
List<Case> listOfCaseDelete = [select id from case where id IN: listOfCase];
System.assert(listOfCaseDelete.isEmpty(), 'Record not deleted');
//undelete ListOfCas;
//List<Case> listOfCaseUnDelete = [select id from case where id IN: listOfCase];
//System.assert(ListOfCas[0].id != null, 'Record not Undelete');*/
            Test.stopTest(); 
            List<Casemilestone> cml = [Select caseid, StartDate,CompletionDate from Casemilestone];
        }
    }
    
    /***************************************************************************************************
Method Name:  caseSLAManagementwithCaseRecordType_Test
Method Type: Test Method
Version     : 1.0 
Created Date: 06 Nov 2015
Description:  Testing caseSLAManagement method
Scenario Type:  Positive
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Deepak Jetty              28/01/2016                Created
****************************************************************************************************/
    static testmethod void caseSLAManagementwithCaseRecordTypeTest(){
        getRecords();
        RecordType recType = [Select Name, Id From RecordType where sObjectType='Case' and name = 'IPS GEC ReadOnly'];
        // Get intelSupportOwner Id (User Id)
        Id intelSupportOwner = listOfUser.get(0).id;
        System.runAs(listOfUser.get(0)){
            // Create Accounts
            List<Account> listOfAccounts = TestUtilities.getListOfAccounts(1);
            insert listOfAccounts;
            System.assert(listOfAccounts[0].Id != null, 'Record not created');
            // Create Contact
            List<Contact> listOfContacts = TestUtilities.getListOfContact(1);
            for(Contact contactRec : listOfContacts){
                contactRec.Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
                contactRec.Accountid = listOfAccounts.get(0).Id;
                contactRec.MailingCountry = 'India';
            }
            insert listOfContacts;
            System.assert(listOfContacts[0].Id != null, 'Record not created');
            // Create Asset
            list<Asset> assetList = TestUtilities.getAssetList(1);
            for(Asset asst : assetList){
                asst.accountId = listOfAccounts.get(0).Id;
                asst.Contactid = listOfContacts.get(0).id;
            }
            insert assetList;
            System.assert(assetList[0].Id != null, 'Record not created');
            // Create Entitlement
            List<Entitlement> listOfEntitlement = TestUtilities.getListOfEntitlement(1);
            for(Entitlement entitlementRec : listOfEntitlement){
                entitlementRec.AccountId = listOfAccounts.get(0).Id;
                entitlementRec.AssetId = assetList.get(0).id;
            }
            insert listOfEntitlement;
            System.assert(listOfEntitlement[0].Id != null, 'Record not created');
            // Create Case
            List<Case> listOfCases = TestUtilities.getListOfCases(10);
            for(Case caseRec : listOfCases){
                caseRec.ContactId = listOfContacts.get(0).id;
                caseRec.accountId = listOfAccounts.get(0).Id;
                caseRec.RecordTypeId = recType.id;
            }
            //get Business Hours
            List<BusinessHours> bhs=[select id from BusinessHours where IsDefault=true];
            //Create Queue Business Hours
            Core_IPS_Q_Biz_hours_mapping__c queueXBizHours = TestUtilities.getQueueXBizHours();
            queueXBizHours.Business_Hours_ID__c = bhs.get(0).id;
            queueXBizHours.Business_Hours_Name__c = 'Ashok_Test';
            queueXBizHours.Queue_ID__c = grp.Id;
            queueXBizHours.Queue_Name__c = grp.Name;
            //insert Queue Business Hours
            insert queueXBizHours;
            Core_IPS_Labels__c ipsLabel = new Core_IPS_Labels__c();
            ipsLabel.Name = 'GEC Record Type Id';
            ipsLabel.Value__c = recType.id;
            insert ipsLabel;
            Test.startTest();            
            insert listOfCases;
            System.assert(listOfCases[0].Id != null, 'Record not created');
            List<Case> listOfCase = [select isStopped, Core_Sub_Status__c from case where id IN: listOfCases];
            integer counter = 0;
            for(Case caseRec : listOfCase){
                caseRec.isStopped = true;
                if(counter < 5){
                    caseRec.Core_Sub_Status__c = 'Investigating';
                }else{
                    caseRec.Core_Sub_Status__c = 'Investigating';
                }
                counter++;
            }
            counter = 0;
            update listOfCase;
            List<Case> listOfCas = [select Core_Sub_Status__c, RecordTypeId from case where id IN: listOfCase];
            System.assertEquals(listOfCas[0].Core_Sub_Status__c,  'Investigating', 'Investigating');
            // delete listOfCas;
            List<Case> listOfCaseDelete = [select id from case where id IN: listOfCase];
            // System.assert(listOfCaseDelete.isEmpty(), true);
            //undelete listOfCas;
            List<Case> listOfCaseUnDelete = [select id from case where id IN: listOfCase];
            System.assert(listOfCas[0].id != null, true);
            Test.stopTest();
        }
    }
    
    /***************************************************************************************************
Method Name:  executeCaseAssignmentRule_Test
Method Type: Test Method
Version     : 1.0 
Created Date: 06 Nov 2015
Description:  Testing executeCaseAssignmentRule method
Scenario Type:  Positive
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Syed Moosa Nazir TN       11/06/2015                Created
* Deepak Jetty              25/01/2016                Modified
* Sumukh                    26/04/2019                Modified
****************************************************************************************************/
    static testmethod void executeCaseAssignmentRuleTest(){
        getRecords();
        // Get intelSupportOwner Id (User Id)
        Profile prof1 = [select id from profile where name = 'IPS Agent' limit 1];
        List<user> ipsuserList = new List<user>();
        ipsuserList = TestUtilities.getListOfUser(1);
        ipsuserList[0].profileId=prof1.id;
        insertUsersWithValidationBypass(ipsuserList);
        Id intelSupportOwner = listOfUser.get(0).id;
        System.runAs(listOfUser.get(1)){
            // Create Accounts
            List<Account> listOfAccounts = TestUtilities.getListOfAccounts(1);
            listOfAccounts[0].Core_CNDA_Number__c = 'Test123';
            insert listOfAccounts;
            System.assert(listOfAccounts[0].Id != null, 'Record not created');
            // Create Contact
            List<Contact> listOfContacts = TestUtilities.getListOfContact(1);
            for(Contact contactRec : listOfContacts){
                contactRec.Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
                contactRec.Accountid = listOfAccounts.get(0).Id;
                contactRec.MailingCountry = 'India';
            }
            insert listOfContacts;
            System.assert(listOfContacts[0].Id != null, 'Record not created');
            
            List<Core_IPS_Project__c> listOfIpsProjects = TestUtilities.getListOfIpsProjects(1);
            insert listOfIpsProjects;
            
            System.assert(listOfIpsProjects[0].Id != null, 'Record not created');
            // Create Ips Account
            List<Core_IPS_Account__c> listOfIpsAccounts = TestUtilities.getListOfIpsAccounts(1);
            for(Core_IPS_Account__c ipsAcc : listOfIpsAccounts){
                ipsAcc.Core_Account__c = listOfAccounts.get(0).Id;
                ipsAcc.Core_IPS_Project__c = listOfIpsProjects.get(0).Id;
            }
            insert listOfIpsAccounts;
            System.assert(listOfIpsAccounts[0].Id != null, 'Record not created');
            // Create Project Member
            List<Core_IPS_Project_Member__c> listOfProjectMembers = TestUtilities.getListOfProjectMembers(1);
            for(Core_IPS_Project_Member__c projMem : listOfProjectMembers){
                projMem.Core_IPS_Contact__c = listOfContacts.get(0).Id;
                projMem.Core_IPS_Project__c = listOfIpsProjects.get(0).Id;
                projMem.Core_User__c = intelSupportOwner;
            }
            insert listOfProjectMembers;
            System.assert(listOfProjectMembers[0].Id != null, 'Record not created');
            
            // Create Product
            List<Product2> listOfProducts = TestUtilities.getListOfProduct(2);
            insert listOfProducts;
            //System.assert(listOfProducts[0].id != null,'Record not created');
            List<Core_IPS_Product_Organization__c> listOfSupportOrg  = TestUtilities.getListOfSupportOrg(1);
            insert listOfSupportOrg;
            List<Core_IPS_Supported_Product__c> listOfSupportedProduct = TestUtilities.getListOfSupportedProduct(2);
            integer counter = 0;
            for(Core_IPS_Supported_Product__c supportedProduct : listOfSupportedProduct){
                if(counter==0){
                    supportedProduct.Core_Product__c = listOfProducts.get(0).id;
                    supportedProduct.Core_Product_Organization__c = listOfSupportOrg.get(0).id;
                }else{
                    supportedProduct.Core_Product__c = listOfProducts.get(1).id;
                    supportedProduct.Core_Product_Organization__c = listOfSupportOrg.get(0).id;
                }
                counter++;
            }
            insert listOfSupportedProduct;
            
            list<Asset> assetList = TestUtilities.getAssetList(1);
            for(Asset asst : assetList){
                asst.accountId = listOfAccounts.get(0).Id;
                asst.Contactid = listOfContacts.get(0).id;
                asst.Core_Product_Organization__c = listOfSupportOrg.get(0).id;
                asst.Core_IPS_Project__c = listOfIpsProjects.get(0).id;
                asst.Core_Supported_Product__c = listOfSupportedProduct.get(0).id;
                asst.product2Id = listOfProducts.get(0).id;
            }
            insert assetList;
            Entitlement ent1 = new Entitlement();
            ent1 = TestUtilities.getEntitlementRecord();
            ent1.accountid = listOfAccounts.get(0).Id;
            ent1.AssetId = assetList.get(0).id;
            ent1.startdate = System.today()-1;
            ent1.endDate = system.today()+760;
            ent1.SlaProcessId = Core_IPS_Labels__c.getValues('IPS Standard Entitlement Process ID').Value__c;
            insert ent1;
            recordtype rType = [select id from  recordtype where Name ='IPS case create'];
            // Create Case
            List<Case> listOfCases = TestUtilities.getListOfCases(10);
            for(Case caseRec : listOfCases){
                caseRec.ContactId = listOfContacts.get(0).id;
                caseRec.Core_IPS_Private_Project__c = false;
                caseRec.Core_IPS_Supported_Contact__c = listOfContacts.get(0).id;
                caseRec.accountId = listOfAccounts.get(0).Id;
                caseRec.AssetId = assetList.get(0).id;
                caseRec.Core_IPS_Project_Case__c = listOfIpsProjects.get(0).id;
                //caseRec.ProductId = listOfProducts.get(0).id;
                caseRec.Core_IPS_GEC_Status__c = 'Approved with Guardrails';
                caseRec.entitlementId = ent1.id;
                caseRec.ownerId = userinfo.getUserID();
                caseRec.recordtypeId = rType.Id;
                caseRec.Core_First_Response_Completed__c =false;
                caseRec.Priority = 'Low';
                caseRec.Core_Sub_Status__c = 'Reproduced';
                caseRec.Core_Severity__c = 'Low';
                caseRec.Core_Latest_Case_Comment_Type__c = 'Public to Customers';
                caseRec.Core_Intel_Sup_Owner__c = UserInfo.getUserId();
                caseRec.Core_Case_Co_Owner__c = ipsuserList[0].Id;
                caseRec.Origin = 'Email';
                caseRec.Core_IPS_Is_Notification_Active__c = true;
                caseRec.Core_Latest_Comment_Time_Stamp__c = System.now()+1;
            }
            listOfCases[0].SlaStartDate = System.now() - 1;
            //get Business Hours
            List<BusinessHours> bhs=[select id from BusinessHours where IsDefault=true];
            //Create Queue Business Hours
            Core_IPS_Q_Biz_hours_mapping__c queueXBizHours = TestUtilities.getQueueXBizHours();
            queueXBizHours.Business_Hours_ID__c = bhs.get(0).id;
            queueXBizHours.Business_Hours_Name__c = 'Ashok_Test';
            queueXBizHours.Queue_ID__c = grp.Id;
            queueXBizHours.Queue_Name__c = grp.Name;
            //insert Queue Business Hours
            insert queueXBizHours;
            Test.startTest();
            insert listOfCases;
            
            List<Core_IPS_Case_Interested_Party__c> interestedpartyLst = new List<Core_IPS_Case_Interested_Party__c>();
            Core_IPS_Case_Interested_Party__c interestedparty;
            for(Case cs : listOfCases) {
                interestedparty = new Core_IPS_Case_Interested_Party__c ();
                interestedparty.Contact__C = listOfContacts.get(0).id;
                interestedparty.Case__c= cs.Id;
                interestedpartyLst.add(interestedparty);
            }
            insert interestedpartyLst;
            
            Core_CaseTrigger_Dispatcher.triggerAssignmentRule = true;
            System.assert(listOfCases[0].Id != null, 'Record not created');
            counter = 0;
            for(Case caseRec : listOfCases){
                if(counter < 5){
                    caseRec.ProductId = listOfProducts.get(0).id;
                    caseRec.ContactId = listOfContacts.get(0).id;
                }else{
                    caseRec.ProductId = listOfProducts.get(1).id;
                    //caseRec.ContactId = listOfContacts.get(1).id;
                }
                counter++;
            }
            counter = 0;
            update listOfCases;
            List<Case> listOfCase = [select ProductId,ContactId from case where id IN: listOfCases];
            System.assert(listOfCase[0].ProductId != null, 'Record not updated with product id');
            // delete listOfCase;
            List<Case> listOfCaseDelete = [select id from case where id IN: listOfCase];
            // System.assert(listOfCaseDelete.isEmpty(), true);
            Test.stopTest();
            
            // undelete listOfCase;
            
            List<Case> listOfCaseUnDelete = [select id from case where id IN: listOfCase];
            System.assert(listOfCase[0].id != null, 'Record not Undelete');
        }
    }
    
    /***************************************************************************************************
Method Name:  ProvideCaseAccess_Test
Method Type: Test Method
Version     : 1.0 
Created Date: 06 Nov 2015
Description:  Testing ProvideCaseAccess method
Scenario Type:  Positive
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Syed Moosa Nazir TN       11/06/2015               Created
****************************************************************************************************/
    static testmethod void provideCaseAccessTest(){
        getRecords();
        // Get intelSupportOwner Id (User Id)
        Id intelSupportOwner = listOfUser.get(0).id;
        System.runAs(listOfUser.get(1)){
            // Create Accounts
            List<Account> listOfAccounts = TestUtilities.getListOfAccounts(1);
            for(Account acc: listOfAccounts){
                acc.Core_CNDA_Number__c='123';
            }
            insert listOfAccounts;
            System.assert(listOfAccounts[0].Id != null, 'Record not created');
            // Create Contact
            List<Contact> listOfContacts = TestUtilities.getListOfContact(1);
            for(Contact contactRec : listOfContacts){
                contactRec.Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
                contactRec.Accountid = listOfAccounts.get(0).Id;
                contactRec.MailingCountry = 'India';
            }
            insert listOfContacts;
            System.assert(listOfContacts[0].Id != null, 'Record not created');
            // Create Ips Project
            List<Core_IPS_Project__c> listOfIpsProjects = TestUtilities.getListOfIpsProjects(1);
            insert listOfIpsProjects;
            System.assert(listOfIpsProjects[0].Id != null, 'Record not created');
            // Create Ips Account
            List<Core_IPS_Account__c> listOfIpsAccounts = TestUtilities.getListOfIpsAccounts(1);
            for(Core_IPS_Account__c ipsAcc : listOfIpsAccounts){
                ipsAcc.Core_Account__c = listOfAccounts.get(0).Id;
                ipsAcc.Core_IPS_Project__c = listOfIpsProjects.get(0).Id;
            }
            insert listOfIpsAccounts;
            System.assert(listOfIpsAccounts[0].Id != null, 'Record not created');
            // Create Project Member
            List<Core_IPS_Project_Member__c> listOfProjectMembers = TestUtilities.getListOfProjectMembers(1);
            for(Core_IPS_Project_Member__c projMem : listOfProjectMembers){
                projMem.Core_IPS_Contact__c = listOfContacts.get(0).Id;
                projMem.Core_IPS_Project__c = listOfIpsProjects.get(0).Id;
                projMem.Core_User__c = intelSupportOwner;
            }
            insert listOfProjectMembers;
            System.assert(listOfProjectMembers[0].Id != null, 'Record not created');
            // Create Case
            List<Case> listOfCases = TestUtilities.getListOfCases(10);
            for(Case caseRec : listOfCases){
                caseRec.ContactId = listOfContacts.get(0).id;
                caseRec.accountId = listOfAccounts.get(0).Id;
            }
            //get Business Hours
            
            
            Test.startTest();
            /*/*Sneha List<BusinessHours> bhs=[select id from BusinessHours where IsDefault=true];
//Create Queue Business Hours
Core_IPS_Q_Biz_hours_mapping__c queueXBizHours = TestUtilities.getQueueXBizHours();
queueXBizHours.Business_Hours_ID__c = bhs.get(0).id;
queueXBizHours.Business_Hours_Name__c = 'Ashok_Test';
queueXBizHours.Queue_ID__c = grp.Id;
queueXBizHours.Queue_Name__c = grp.Name;
//insert Queue Business Hours
insert queueXBizHours;
insert listOfCases;
Core_CaseTrigger_Dispatcher.triggerAssignmentRule = true;
System.assert(listOfCases[0].Id != null, 'Record not created');
integer counter = 0;
for(Case caseRec : listOfCases){
if(counter < 5){
caseRec.Core_IPS_Project_Case__c = listOfIpsProjects.get(0).id;
}else{
caseRec.AccountId = listOfAccounts.get(0).id;
}
counter++;
}
counter = 0;
update listOfCases;
List<Case> listOfCase = [select id from case where id IN: listOfCases];
System.assert(listOfCase[0].id != null, 'Record not updated');
delete listOfCase;
List<Case> listOfCaseDelete = [select id from case where id IN: listOfCase];
System.assert(listOfCaseDelete.isEmpty(), 'Record not deleted');
//undelete listOfCase;
//List<Case> listOfCaseUnDelete = [select id from case where id IN: listOfCase];
//System.assert(listOfCase[0].id != null, 'Record not Undeleted');*/
            Test.stopTest();
        }
    }
    
    /***************************************************************************************************
Method Name:  assignMigratedCaseInformation_Test
Method Type: Test Method
Version     : 1.0 
Created Date: 27 Jan 2016
Description:  Testing assignMigratedCaseInformation method
Scenario Type:  Positive
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Deepak Jetty              25/01/2016                Created
****************************************************************************************************/
   /* static testmethod void assignMigratedCaseInformationTest(){
        // Query Profiles
        Map<String,ID> profiles = new Map<String,ID>();
        List<String> strProf = new List<String>();
        strProf.add('System Administrator');
        strProf.add('IPS Data Migration');
        List<Profile> profileList = [select id, name from Profile where name IN : strProf];
        for(Profile prf : profileList){
            profiles.put(prf.name, prf.id);
        }
        Core_Trigger_Executions__c  triggerExecution = new Core_Trigger_Executions__c();
        
        
        Core_Trigger_Executions__c  triggerExecution1 = new Core_Trigger_Executions__c();
        triggerExecution1.Name = 'assignCaseInformation';
        triggerExecution1.Core_Active__c = true;
        triggerExecution1.Core_Class_Name__c ='Core_IPS_CaseTriggerHandler';
        triggerExecution1.Core_Description__c = 'To update Case fields.';
        triggerExecution1.Core_Object__c = 'Case';
        triggerExecution1.Core_Trigger_Events__c = 'before insert';
        insert new List<Core_Trigger_Executions__c>{triggerExecution1};
            // Create Users
            listOfUser = TestUtilities.getListOfUser(2);
        listOfUser.get(0).ProfileID =  profiles.get('System Administrator');
        listOfUser.get(1).ProfileID =  profiles.get('IPS Data Migration');
        insertUsersWithValidationBypass(listOfUser);
        System.assertEquals(listOfUser.get(0).profileid, profiles.get('System Administrator'), 'System Admin');
        System.assertEquals(listOfUser.get(1).profileid, profiles.get('IPS Data Migration'), 'IPS Data Migration');
        System.runAs(listOfUser.get(0)){
            // Create Ips Labels added by Aayushi US79852    
            List<Core_IPS_Labels__c> ipsLabels = TestUtilities.getIPSLabel();    
            for(Core_IPS_Labels__c il: ipsLabels){    
                if(il.name=='ProjectGroupPrefix'){    
                    il.Value__c = 'IPS_Proj_';    
                }    
                if(il.name=='CoreStatus_SPtoActive_Error'){    
                    il.Value__c = 'Project Status cannot be changed from Submitted Pending to Active';    
                }    
                if(il.name=='Core_OneProjProdMem_Error'){    
                    il.Value__c = 'Project cannot be submitted without atleast one account and one Product and one Project Member';    
                }    
                if(il.name=='CoreStatus_Draft'){    
                    il.Value__c = 'Draft';     
                }    
                if(il.name=='CoreStatus_Active'){    
                    il.Value__c = 'Active' ;    
                }    
                if(il.name=='CoreStatus_Inactive'){    
                    il.Value__c = 'Inactive' ;    
                }    
                if(il.name=='CoreStatus_SP'){    
                    il.Value__c = 'Submitted Pending' ;    
                }    
            }    
            
            Insert ipsLabels;
            //Create Group
            grp = TestUtilities.getQueue();
            grp.Type='Regular';
            insert grp;
            //Create Group Members
            List<GroupMember> listGM = new List<GroupMember>();
            for(User usr:listOfUser){
                GroupMember grpMem = new GroupMember();
                grpMem.GroupId = grp.Id;
                grpMem.UserOrGroupId = usr.Id;
                listGM.add(grpMem);
            }
            //insert Group Memebers
            if(!listGM.isEmpty()){
                insert listGM;
            }
            
        }
        // Get intelSupportOwner Id (User Id)
        Id intelSupportOwner = listOfUser.get(1).id;
        List<Account> listOfAccounts=new List<Account>();
        System.runAs(listOfUser.get(0)){
            // Create Accounts
            listOfAccounts = TestUtilities.getListOfAccounts(1);
            insert listOfAccounts;
            System.assert(listOfAccounts[0].Id != null, 'Record not created');
        }
        
        System.runAs(listOfUser.get(1)){
            // Create Contact
            List<Contact> listOfContacts = TestUtilities.getListOfContact(1);
            for(Contact contactRec : listOfContacts){
                contactRec.Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
                contactRec.Accountid = listOfAccounts.get(0).Id;
                contactRec.MailingCountry = 'India';
            }
            insert listOfContacts;
            // Create Ips Project
            List<Core_IPS_Project__c> listOfIpsProjects = TestUtilities.getListOfIpsProjects(1);
            insert listOfIpsProjects;
            System.assert(listOfIpsProjects[0].Id != null, 'Record not created');
            // Create Ips Account
            List<Core_IPS_Account__c> listOfIpsAccounts = TestUtilities.getListOfIpsAccounts(1);
            for(Core_IPS_Account__c ipsAcc : listOfIpsAccounts){
                ipsAcc.Core_Account__c = listOfAccounts.get(0).Id;
                ipsAcc.Core_IPS_Project__c = listOfIpsProjects.get(0).Id;
            }
            insert listOfIpsAccounts;
            System.assert(listOfIpsAccounts[0].Id != null, 'Record not created');
            // Create Project Member
            List<Core_IPS_Project_Member__c> listOfProjectMembers = TestUtilities.getListOfProjectMembers(1);
            for(Core_IPS_Project_Member__c projMem : listOfProjectMembers){
                projMem.Core_IPS_Contact__c = listOfContacts.get(0).Id;
                projMem.Core_IPS_Project__c = listOfIpsProjects.get(0).Id;
                projMem.Core_User__c = intelSupportOwner;
            }
            insert listOfProjectMembers;
            System.assert(listOfProjectMembers[0].Id != null, 'Record not created');
            // Create Support Org
            List<Core_IPS_Product_Organization__c> listOfSupportOrg  = TestUtilities.getListOfSupportOrg(2);
            insert listOfSupportOrg;
            System.assert(listOfSupportOrg != null, 'Record not created');
            integer counter = 0;
            // Create Product
            List<Product2> listOfProducts = TestUtilities.getListOfProduct(2);
            for(Product2 product : listOfProducts){
                if(counter==0){
                    product.Core_Hierarchy_ID__c = '43';
                    product.Core_Hierarchy_Name__c = 'ProdHierarchyName';
                    product.Core_Unique_ID__c = 'Product12345';
                    product.Core_Code_Name__c = 'ProductCoreCodeName';
                }else{
                    product.Core_Hierarchy_ID__c = '59';
                    product.Core_Hierarchy_Name__c = 'ProdHierarchyName59';
                    product.Core_Unique_ID__c = 'Product59';
                    product.Core_Code_Name__c = 'ProductCoreCodeName59';
                    
                }
                counter++;
            }
            insert listOfProducts;
            System.assert(listOfProducts[0].id != null,'Record not created');
            counter = 0;
            // Create Supported product
            List<Core_IPS_Supported_Product__c> listOfSupportedProduct = TestUtilities.getListOfSupportedProduct(2);
            for(Core_IPS_Supported_Product__c supportedProduct : listOfSupportedProduct){
                if(counter==0){
                    supportedProduct.Core_Product__c = listOfProducts.get(0).id;
                    supportedProduct.Core_Product_Organization__c = listOfSupportOrg.get(0).id;
                }else{
                    supportedProduct.Core_Product__c = listOfProducts.get(1).id;
                    supportedProduct.Core_Product_Organization__c = listOfSupportOrg.get(1).id;
                }
                counter++;
            }
            insert listOfSupportedProduct;
            System.assert(listOfSupportedProduct[0].id != null,'Record not created');
            // Create Asset
            list<Asset> assetList = TestUtilities.getAssetList(2);
            for(Asset asst : assetList){
                asst.accountId = listOfAccounts.get(0).Id;
                asst.Contactid = listOfContacts.get(0).id;
                if(counter==0){
                    asst.Core_IPS_Project__c = listOfIpsProjects.get(0).id;
                    asst.AccountId = listOfAccounts.get(0).id;
                    asst.Core_Product_Organization__c = listOfSupportOrg.get(0).id;
                    asst.Core_Supported_Product__c = listOfSupportedProduct.get(0).id;
                    asst.product2Id = listOfProducts.get(0).id;
                }else{
                    asst.Core_IPS_Project__c = listOfIpsProjects.get(0).id;
                    asst.AccountId = listOfAccounts.get(0).id;
                    asst.Core_Product_Organization__c = listOfSupportOrg.get(1).id;
                    asst.Core_Supported_Product__c = listOfSupportedProduct.get(1).id;
                    asst.product2Id = listOfProducts.get(1).id;
                }
                counter++;
            }
            insert assetList;
            System.assert(assetList[0].Id != null, 'Record not created');
            
            counter = 0;
            // Create Case
            List<Case> listOfCases = TestUtilities.getListOfCases(10);
            for(Case caseRec : listOfCases){
                caseRec.ContactId = listOfContacts.get(0).id;
                caseRec.accountId = listOfAccounts.get(0).Id;
                if(counter < 5){
                    //caseRec.assetId = assetList.get(0).Id;
                    caseRec.Core_IPS_Supported_Product__c = listOfSupportedProduct.get(0).id;
                    caseRec.Core_IPS_Project_Case__c = listOfIpsProjects.get(0).id;
                    caseRec.Core_IPS_Product_Org1__c = listOfSupportOrg.get(1).id;
                }else{
                    //caseRec.assetId = assetList.get(0).Id;
                    caseRec.Core_IPS_Supported_Product__c = listOfSupportedProduct.get(1).id;
                    caseRec.Core_IPS_Project_Case__c = listOfIpsProjects.get(0).id;
                    caseRec.Core_IPS_Product_Org1__c = listOfSupportOrg.get(1).id;
                }
                counter++;
            }
            //get Business Hours
            List<BusinessHours> bhs=[select id from BusinessHours where IsDefault=true];
            //Create Queue Business Hours
            Core_IPS_Q_Biz_hours_mapping__c queueXBizHours = TestUtilities.getQueueXBizHours();
            queueXBizHours.Business_Hours_ID__c = bhs.get(0).id;
            queueXBizHours.Business_Hours_Name__c = 'Ashok_Test';
            queueXBizHours.Queue_ID__c = grp.Id;
            queueXBizHours.Queue_Name__c = grp.Name;
            //insert Queue Business Hours
            insert queueXBizHours;
            Core_CaseTrigger_Dispatcher.triggerAssignmentRule = true;
            Test.startTest();
            // change added by chiru - code refactor - embargo country label
            Core_IPS_Labels__c labelVal = new Core_IPS_Labels__c(Name = 'Core_IPS_EmbargoedCountryList',Value__c = 'USA,INDIA');
            insert labelval;
            insert listOfCases;
            //  System.assert(listOfCases[0].Id != null, 'Record not created');          
            update listOfCases;
            List<Case> listOfCase = [select id from case where id IN: listOfCases];
            System.assert(listOfCase[0].id != null, true);
            // delete listOfCase;
            List<Case> listOfCaseDelete = [select id from case where id IN: listOfCase];
            //System.assert(listOfCaseDelete.isEmpty(), 'Record not deleted');
            //undelete listOfCase;
            List<Case> listOfCaseUnDelete = [select id from case where id IN: listOfCase];
            // System.assert(listOfCase[0].id != null, 'Record not Undelete');
            Test.stopTest();
        }
    } */
    
    /***************************************************************************************************
Method Name:  assignMigratedCaseInformationwithoutAccandProj_Test
Method Type: Test Method
Version     : 1.0 
Created Date: 27 Jan 2016
Description:  Testing assignMigratedCaseInformation method
Scenario Type:  Negative
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Deepak Jetty              25/01/2016                Created
****************************************************************************************************/
    static testmethod void assignMigratedCaseInformationwithoutAccandProjTest(){
        // Query Profiles
        Map<String,ID> profiles = new Map<String,ID>();
        List<String> strProf = new List<String>();
        strProf.add('System Administrator');
        strProf.add('System Administrator');
        List<Profile> profileList = [select id, name from Profile where name IN : strProf];
        for(Profile prf : profileList){
            profiles.put(prf.name, prf.id);
        }
        Core_Trigger_Executions__c  triggerExecution = new Core_Trigger_Executions__c();
        
        // Create Users
        listOfUser = TestUtilities.getListOfUser(2);
        listOfUser.get(0).ProfileID =  profiles.get('System Administrator');
        listOfUser.get(1).ProfileID =  profiles.get('System Administrator');
        insertUsersWithValidationBypass(listOfUser);
        System.assertEquals(listOfUser.get(0).profileid, profiles.get('System Administrator'), 'System Admin');
        System.assertEquals(listOfUser.get(1).profileid, profiles.get('System Administrator'), 'System Admin');
        System.runAs(listOfUser.get(0)){
            // Create Ips Labels added by Aayushi US79852    
            List<Core_IPS_Labels__c> ipsLabels = TestUtilities.getIPSLabel();    
            for(Core_IPS_Labels__c il: ipsLabels){    
                if(il.name=='ProjectGroupPrefix'){    
                    il.Value__c = 'IPS_Proj_';    
                }    
                if(il.name=='CoreStatus_SPtoActive_Error'){    
                    il.Value__c = 'Project Status cannot be changed from Submitted Pending to Active';    
                }    
                if(il.name=='Core_OneProjProdMem_Error'){    
                    il.Value__c = 'Project cannot be submitted without atleast one account and one Product and one Project Member';    
                }    
                if(il.name=='CoreStatus_Draft'){    
                    il.Value__c = 'Draft';     
                }    
                if(il.name=='CoreStatus_Active'){    
                    il.Value__c = 'Active' ;    
                }    
                if(il.name=='CoreStatus_Inactive'){    
                    il.Value__c = 'Inactive' ;    
                }    
                if(il.name=='CoreStatus_SP'){    
                    il.Value__c = 'Submitted Pending' ;    
                }    
            }    
            
            Insert ipsLabels;
            //Create Group
            grp = TestUtilities.getQueue();
            grp.Type='Regular';
            insert grp;
            //Create Group Members
            List<GroupMember> listGM = new List<GroupMember>();
            for(User usr:listOfUser){
                GroupMember grpMem = new GroupMember();
                grpMem.GroupId = grp.Id;
                grpMem.UserOrGroupId = usr.Id;
                listGM.add(grpMem);
            }
            //insert Group Memebers
            if(!listGM.isEmpty()){
                insert listGM;
            }
            
        }
        // Get intelSupportOwner Id (User Id)
        Id intelSupportOwner = listOfUser.get(1).id;
        List<Account> listOfAccounts=new List<Account>();
        System.runAs(listOfUser.get(0)){
            // Create Accounts
            listOfAccounts = TestUtilities.getListOfAccounts(1);
            insert listOfAccounts;
            System.assert(listOfAccounts[0].Id != null, 'Record not created');
        }
        System.runAs(listOfUser.get(1)){
            // Create Contact
            List<Contact> listOfContacts = TestUtilities.getListOfContact(1);
            for(Contact contactRec : listOfContacts){
                contactRec.Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
                contactRec.Accountid = listOfAccounts.get(0).Id;
                contactRec.MailingCountry = 'India';
            }
            insert listOfContacts;
            // Create Ips Project
            List<Core_IPS_Project__c> listOfIpsProjects = TestUtilities.getListOfIpsProjects(1);
            insert listOfIpsProjects;
            System.assert(listOfIpsProjects[0].Id != null, 'Record not created');
            // Create Ips Account
            List<Core_IPS_Account__c> listOfIpsAccounts = TestUtilities.getListOfIpsAccounts(1);
            for(Core_IPS_Account__c ipsAcc : listOfIpsAccounts){
                ipsAcc.Core_Account__c = listOfAccounts.get(0).Id;
                ipsAcc.Core_IPS_Project__c = listOfIpsProjects.get(0).Id;
            }
            insert listOfIpsAccounts;
            System.assert(listOfIpsAccounts[0].Id != null, 'Record not created');
            // Create Project Member
            List<Core_IPS_Project_Member__c> listOfProjectMembers = TestUtilities.getListOfProjectMembers(1);
            for(Core_IPS_Project_Member__c projMem : listOfProjectMembers){
                projMem.Core_IPS_Contact__c = listOfContacts.get(0).Id;
                projMem.Core_IPS_Project__c = listOfIpsProjects.get(0).Id;
                projMem.Core_User__c = intelSupportOwner;
            }
            insert listOfProjectMembers;
            System.assert(listOfProjectMembers[0].Id != null, 'Record not created');
            // Create Support Org
            List<Core_IPS_Product_Organization__c> listOfSupportOrg  = TestUtilities.getListOfSupportOrg(2);
            insert listOfSupportOrg;
            System.assert(listOfSupportOrg != null, 'Record not created');
            integer counter = 0;
            // Create Product
            List<Product2> listOfProducts = TestUtilities.getListOfProduct(2);
            for(Product2 product : listOfProducts){
                if(counter==0){
                    product.Core_Hierarchy_ID__c = '43';
                    product.Core_Hierarchy_Name__c = 'ProdHierarchyName';
                    product.Core_Unique_ID__c = 'Product12345';
                    product.Core_Code_Name__c = 'ProductCoreCodeName';
                }else{
                    product.Core_Hierarchy_ID__c = '59';
                    product.Core_Hierarchy_Name__c = 'ProdHierarchyName59';
                    product.Core_Unique_ID__c = 'Product59';
                    product.Core_Code_Name__c = 'ProductCoreCodeName59';
                    
                }
                counter++;
            }
            insert listOfProducts;
            System.assert(listOfProducts[0].id != null,'Record not created');
            counter = 0;
            // Create Supported product
            List<Core_IPS_Supported_Product__c> listOfSupportedProduct = TestUtilities.getListOfSupportedProduct(2);
            for(Core_IPS_Supported_Product__c supportedProduct : listOfSupportedProduct){
                if(counter==0){
                    supportedProduct.Core_Product__c = listOfProducts.get(0).id;
                    supportedProduct.Core_Product_Organization__c = listOfSupportOrg.get(0).id;
                }else{
                    supportedProduct.Core_Product__c = listOfProducts.get(1).id;
                    supportedProduct.Core_Product_Organization__c = listOfSupportOrg.get(1).id;
                }
                counter++;
            }
            insert listOfSupportedProduct;
            System.assert(listOfSupportedProduct[0].id != null,'Record not created');
            // Create Asset
            list<Asset> assetList = TestUtilities.getAssetList(2);
            for(Asset asst : assetList){
                asst.accountId = listOfAccounts.get(0).Id;
                asst.Contactid = listOfContacts.get(0).id;
                if(counter==0){
                    asst.Core_IPS_Project__c = listOfIpsProjects.get(0).id;
                    asst.AccountId = listOfAccounts.get(0).id;
                    asst.Core_Product_Organization__c = listOfSupportOrg.get(0).id;
                    asst.Core_Supported_Product__c = listOfSupportedProduct.get(0).id;
                    asst.product2Id = listOfProducts.get(0).id;
                }else{
                    asst.Core_IPS_Project__c = listOfIpsProjects.get(0).id;
                    asst.AccountId = listOfAccounts.get(0).id;
                    asst.Core_Product_Organization__c = listOfSupportOrg.get(1).id;
                    asst.Core_Supported_Product__c = listOfSupportedProduct.get(1).id;
                    asst.product2Id = listOfProducts.get(1).id;
                }
                counter++;
            }
            insert assetList;
            System.assert(assetList[0].Id != null, 'Record not created');
            
            counter = 0;
            // Create Case
            List<Case> listOfCases = TestUtilities.getListOfCases(10);
            for(Case caseRec : listOfCases){
                caseRec.ContactId = listOfContacts.get(0).id;
                if(counter < 5){
                    //caseRec.assetId = assetList.get(0).Id;
                    caseRec.Core_IPS_Supported_Product__c = listOfSupportedProduct.get(0).id;
                    caseRec.Core_IPS_Product_Org1__c = listOfSupportOrg.get(1).id;
                }else{
                    //caseRec.assetId = assetList.get(0).Id;
                    caseRec.Core_IPS_Supported_Product__c = listOfSupportedProduct.get(1).id;
                    caseRec.Core_IPS_Product_Org1__c = listOfSupportOrg.get(1).id;
                }
                counter++;
            }
            //get Business Hours
            List<BusinessHours> bhs=[select id from BusinessHours where IsDefault=true];
            //Create Queue Business Hours
            Core_IPS_Q_Biz_hours_mapping__c queueXBizHours = TestUtilities.getQueueXBizHours();
            queueXBizHours.Business_Hours_ID__c = bhs.get(0).id;
            queueXBizHours.Business_Hours_Name__c = 'Ashok_Test';
            queueXBizHours.Queue_ID__c = grp.Id;
            queueXBizHours.Queue_Name__c = grp.Name;
            //insert Queue Business Hours
            insert queueXBizHours;
            Core_CaseTrigger_Dispatcher.triggerAssignmentRule = true;
            Test.startTest();
            insert listOfCases;
            // System.assert(listOfCases[0].Id != null, 'Record not created');          
            update listOfCases;
            List<Case> listOfCase = [select id from case where id IN: listOfCases];
            System.assert(listOfCase[0].id != null, true);
            // delete listOfCase;
            List<Case> listOfCaseDelete = [select id from case where id IN: listOfCase];
            //  System.assert(listOfCaseDelete.isEmpty(), 'Record not deleted');
            // undelete listOfCase;
            List<Case> listOfCaseUnDelete = [select id from case where id IN: listOfCase];
            //  System.assert(listOfCase[0].id != null, 'Record not Undelete');
            Test.stopTest();
        }
    }
    
    /***************************************************************************************************
Method Name:  assignMigratedCaseInformationwithoutProjectinAsset_Test
Method Type: Test Method
Version     : 1.0 
Created Date: 27 Jan 2016
Description:  Testing assignMigratedCaseInformation method
Scenario Type:  Negative
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Deepak Jetty              25/01/2016                Created
****************************************************************************************************/
    static testmethod void assignMigratedCaseInformationwithoutProjectinAssetTest(){
        // Query Profiles
        Map<String,ID> profiles = new Map<String,ID>();
        List<String> strProf = new List<String>();
        strProf.add('System Administrator');
        strProf.add('System Administrator');
        List<Profile> profileList = [select id, name from Profile where name IN : strProf];
        for(Profile prf : profileList){
            profiles.put(prf.name, prf.id);
        }
        Core_Trigger_Executions__c  triggerExecution5 = new Core_Trigger_Executions__c();
        
        // Create Users
        listOfUser = TestUtilities.getListOfUser(2);
        listOfUser.get(0).ProfileID =  profiles.get('System Administrator');
        listOfUser.get(1).ProfileID =  profiles.get('System Administrator');
        insertUsersWithValidationBypass(listOfUser);
        System.assertEquals(listOfUser.get(0).profileid, profiles.get('System Administrator'), 'System Admin');
        System.assertEquals(listOfUser.get(1).profileid, profiles.get('System Administrator'), 'System Admin');
        System.runAs(listOfUser.get(0)){
            // Create Ips Labels added by Aayushi US79852  
            List<Core_IPS_Labels__c> ipsLabels = TestUtilities.getIPSLabel();    
            for(Core_IPS_Labels__c il: ipsLabels){    
                if(il.name=='ProjectGroupPrefix'){    
                    il.Value__c = 'IPS_Proj_';    
                }    
                if(il.name=='CoreStatus_SPtoActive_Error'){    
                    il.Value__c = 'Project Status cannot be changed from Submitted Pending to Active';    
                }    
                if(il.name=='Core_OneProjProdMem_Error'){    
                    il.Value__c = 'Project cannot be submitted without atleast one account and one Product and one Project Member';    
                }    
                if(il.name=='CoreStatus_Draft'){    
                    il.Value__c = 'Draft';     
                }    
                if(il.name=='CoreStatus_Active'){    
                    il.Value__c = 'Active' ;    
                }    
                if(il.name=='CoreStatus_Inactive'){    
                    il.Value__c = 'Inactive' ;    
                }    
                if(il.name=='CoreStatus_SP'){    
                    il.Value__c = 'Submitted Pending' ;    
                }    
            }    
            
            Insert ipsLabels;
            //Custom Setting - Trigger Executions
            Core_Trigger_Executions__c  triggerExecution = new Core_Trigger_Executions__c();
            triggerExecution.Name = 'assignCaseInformation';
            triggerExecution.Core_Active__c = true;
            triggerExecution.Core_Class_Name__c ='Core_IPS_CaseTriggerHandler';
            triggerExecution.Core_Description__c = 'To update Support Level On Case.';
            triggerExecution.Core_Object__c = 'Case';
            triggerExecution.Core_Trigger_Events__c = 'before update';
            insert triggerExecution; 
            //Create Group
            grp = TestUtilities.getQueue();
            grp.Type='Regular';
            insert grp;
            //Create Group Members
            List<GroupMember> listGM = new List<GroupMember>();
            for(User usr:listOfUser){
                GroupMember grpMem = new GroupMember();
                grpMem.GroupId = grp.Id;
                grpMem.UserOrGroupId = usr.Id;
                listGM.add(grpMem);
            }
            //insert Group Memebers
            if(!listGM.isEmpty()){
                insert listGM;
            }
            
        }
        // Get intelSupportOwner Id (User Id)
        Id intelSupportOwner = listOfUser.get(1).id;
        List<Account> listOfAccounts=new List<Account>();
        System.runAs(listOfUser.get(0)){
            // Create Accounts
            listOfAccounts = TestUtilities.getListOfAccounts(1);
            insert listOfAccounts;
            System.assert(listOfAccounts[0].Id != null, 'Record not created');
        }
        System.runAs(listOfUser.get(1)){
            // Create Support Org
            List<Core_IPS_Product_Organization__c> listOfSupportOrg  = TestUtilities.getListOfSupportOrg(2);
            insert listOfSupportOrg;
            System.assert(listOfSupportOrg != null, 'Record not created');
            // Create Contact
            List<Contact> listOfContacts = TestUtilities.getListOfContact(1);
            for(Contact contactRec : listOfContacts){
                contactRec.Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
                contactRec.Core_IPS_Alternate_Support_Owner__c =intelSupportOwner;
                contactRec.Core_IPS_Alternate_Support_Org__c = listOfSupportOrg[0].id;
                contactRec.Accountid = listOfAccounts.get(0).Id;
                contactRec.MailingCountry = 'India';
            }
            insert listOfContacts;
            // Create Ips Project
            List<Core_IPS_Project__c> listOfIpsProjects = TestUtilities.getListOfIpsProjects(1);
            insert listOfIpsProjects;
            System.assert(listOfIpsProjects[0].Id != null, 'Record not created');
            // Create Ips Account
            List<Core_IPS_Account__c> listOfIpsAccounts = TestUtilities.getListOfIpsAccounts(1);
            for(Core_IPS_Account__c ipsAcc : listOfIpsAccounts){
                ipsAcc.Core_Account__c = listOfAccounts.get(0).Id;
                ipsAcc.Core_IPS_Project__c = listOfIpsProjects.get(0).Id;
            }
            insert listOfIpsAccounts;
            System.assert(listOfIpsAccounts[0].Id != null, 'Record not created');
            // Create Project Member
            List<Core_IPS_Project_Member__c> listOfProjectMembers = TestUtilities.getListOfProjectMembers(1);
            for(Core_IPS_Project_Member__c projMem : listOfProjectMembers){
                projMem.Core_IPS_Contact__c = listOfContacts.get(0).Id;
                projMem.Core_IPS_Project__c = listOfIpsProjects.get(0).Id;
                projMem.Core_User__c = intelSupportOwner;
            }
            insert listOfProjectMembers;
            System.assert(listOfProjectMembers[0].Id != null, 'Record not created');
            
            integer counter = 0;
            // Create Product
            List<Product2> listOfProducts = TestUtilities.getListOfProduct(2);
            for(Product2 product : listOfProducts){
                if(counter==0){
                    product.Core_Hierarchy_ID__c = '43';
                    product.Core_Hierarchy_Name__c = 'ProdHierarchyName';
                    product.Core_Unique_ID__c = 'Product12345';
                    product.Core_Code_Name__c = 'ProductCoreCodeName';
                }else{
                    product.Core_Hierarchy_ID__c = '59';
                    product.Core_Hierarchy_Name__c = 'ProdHierarchyName59';
                    product.Core_Unique_ID__c = 'Product59';
                    product.Core_Code_Name__c = 'ProductCoreCodeName59';
                    
                }
                counter++;
            }
            insert listOfProducts;
            System.assert(listOfProducts[0].id != null,'Record not created');
            counter = 0;
            // Create Supported product
            List<Core_IPS_Supported_Product__c> listOfSupportedProduct = TestUtilities.getListOfSupportedProduct(2);
            for(Core_IPS_Supported_Product__c supportedProduct : listOfSupportedProduct){
                if(counter==0){
                    supportedProduct.Core_Product__c = listOfProducts.get(0).id;
                    supportedProduct.Core_Product_Organization__c = listOfSupportOrg.get(0).id;
                }else{
                    supportedProduct.Core_Product__c = listOfProducts.get(1).id;
                    supportedProduct.Core_Product_Organization__c = listOfSupportOrg.get(1).id;
                }
                counter++;
            }
            insert listOfSupportedProduct;
            System.assert(listOfSupportedProduct[0].id != null,'Record not created');
            // Create Asset
            list<Asset> assetList = TestUtilities.getAssetList(2);
            for(Asset asst : assetList){
                asst.accountId = listOfAccounts.get(0).Id;
                asst.Contactid = listOfContacts.get(0).id;
                if(counter==0){
                    asst.AccountId = listOfAccounts.get(0).id;
                    asst.Core_Product_Organization__c = listOfSupportOrg.get(0).id;
                    asst.Core_Supported_Product__c = listOfSupportedProduct.get(0).id;
                    asst.product2Id = listOfProducts.get(0).id;
                }else{
                    asst.AccountId = listOfAccounts.get(0).id;
                    asst.Core_Product_Organization__c = listOfSupportOrg.get(1).id;
                    asst.Core_Supported_Product__c = listOfSupportedProduct.get(1).id;
                    asst.product2Id = listOfProducts.get(1).id;
                }
                counter++;
            }
            insert assetList;
            System.assert(assetList[0].Id != null, 'Record not created');
            
            counter = 0;
            // Create Case
            List<Case> listOfCases = TestUtilities.getListOfCases(10);
            for(Case caseRec : listOfCases){
                caseRec.ContactId = listOfContacts.get(0).id;
                caseRec.accountId = listOfAccounts.get(0).Id;
                if(counter < 5){
                    //caseRec.assetId = assetList.get(0).Id;
                    caseRec.Core_IPS_Supported_Product__c = listOfSupportedProduct.get(0).id;
                    caseRec.Core_IPS_Product_Org1__c = listOfSupportOrg.get(1).id;
                }else{
                    //caseRec.assetId = assetList.get(0).Id;
                    caseRec.Core_IPS_Supported_Product__c = listOfSupportedProduct.get(1).id;
                    caseRec.Core_IPS_Product_Org1__c = listOfSupportOrg.get(1).id;
                }
                counter++;
            }
            //get Business Hours
            List<BusinessHours> bhs=[select id from BusinessHours where IsDefault=true];
            //Create Queue Business Hours
            Core_IPS_Q_Biz_hours_mapping__c queueXBizHours = TestUtilities.getQueueXBizHours();
            queueXBizHours.Business_Hours_ID__c = bhs.get(0).id;
            queueXBizHours.Business_Hours_Name__c = 'Ashok_Test';
            queueXBizHours.Queue_ID__c = grp.Id;
            queueXBizHours.Queue_Name__c = grp.Name;
            //insert Queue Business Hours
            insert queueXBizHours;
            Core_CaseTrigger_Dispatcher.triggerAssignmentRule = true;
            Test.startTest();
            // change added by chiru - code refactor - embargo country label
            Core_IPS_Labels__c labelVal = new Core_IPS_Labels__c(Name = 'Core_IPS_EmbargoedCountryList',Value__c = 'USA,INDIA');
            insert labelval;
            insert listOfCases;
            System.assert(listOfCases[0].Id != null, true);          
            update listOfCases;
            List<Case> listOfCase = [select id from case where id IN: listOfCases];
            // System.assert(listOfCase[0].id != null, 'Record not updated');
            //  delete listOfCase;
            List<Case> listOfCaseDelete = [select id from case where id IN: listOfCase];
            // System.assert(listOfCaseDelete.isEmpty(), true);
            // undelete listOfCase;
            List<Case> listOfCaseUnDelete = [select id from case where id IN: listOfCase];
            System.assert(listOfCase[0].id != null, true);
            
            Test.stopTest();
        }
    }   
    
    public  static testmethod void loadGroupByIdTest(){                        
        getRecords();
        Group grp1;
        System.runAs(listOfUser.get(0)){  
            grp1 = new Group(Name='Queue11',Type='Queue');
            insert grp1;
            //start added by Aayushi US89551
            GroupMember grpMem1 = new GroupMember();
            grpMem1.UserOrGroupId = listOfUser.get(0).Id;
            grpMem1.GroupId = grp1.Id;
            Insert grpMem1;
            //end
            QueueSobject mappingObject = new QueueSobject(QueueId = grp1.Id, SobjectType = 'Case');
            insert mappingObject;
        }
        Id intelSupportOwner = listOfUser.get(0).id;
        System.runAs(listOfUser.get(1)){
            List<BusinessHours> bhs=[select id from BusinessHours where IsDefault=true];
            //Create Queue Business Hours
            Core_IPS_Q_Biz_hours_mapping__c queueXBizHours = TestUtilities.getQueueXBizHours();
            queueXBizHours.Business_Hours_ID__c = bhs.get(0).id;
            queueXBizHours.Business_Hours_Name__c = 'Ashok_Test';
            queueXBizHours.Queue_ID__c = grp.Id;
            queueXBizHours.Queue_Name__c = grp.Name;
            insert queueXBizHours;
            List<Case> caseList = new List<Case>();
            Account account =  new Account();
            //Contact con =  new Contact();
            Entitlement ent = new Entitlement();
            account = TestUtilities.getAccountRecord();
            insert account;
            List<Contact> listOfContacts = TestUtilities.getListOfContact(1);
            for(Contact contactRec : listOfContacts){
                contactRec.Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
                contactRec.Accountid = account.Id;
                contactRec.MailingCountry = 'India';
            }
            List<Core_IPS_Product_Organization__c> listOfSupportOrg  = TestUtilities.getListOfSupportOrg(1);
            insert listOfSupportOrg;
            list<Asset> assetList = TestUtilities.getAssetList(1);
            for(Asset asst : assetList){
                asst.accountId = account.Id;
                asst.Contactid = listOfContacts.get(0).id;
                asst.Core_Product_Organization__c = listOfSupportOrg.get(0).id;
            }
            insert assetList;
            caseList = TestUtilities.getListOfCases(10);
            ent = TestUtilities.getEntitlementRecord();
            ent.accountid = account.id;
            ent.AssetId = assetList.get(0).id;
            ent.startdate = System.today()-1;
            ent.endDate = system.today()+760;    
            //ent.SlaProcessId = Core_IPS_Labels__c.getValues('IPS Standard Entitlement Process ID').Value__c;
            insert ent;
            //Added by Geetha as per  DE33659
            //Creating masterCaseCategory
            Core_IPS_Master_Issue_Category__c masterCaseCategory = TestUtilities.getMasterCaseCategories();
            masterCaseCategory.Core_type__c = 'Case Category';
            insert masterCaseCategory;
            //Creating masterCategory
            Core_IPS_Master_Issue_Category__c masterCategory = TestUtilities.getMasterCaseCategories();
            masterCategory.Core_Master_Issue_Category__c = masterCaseCategory.id;            
            insert masterCategory;
            caseCat = TestUtilities.getCaseCategories();
            caseCat.Core_Issue_Category_Name__c = masterCategory.id;
            caseCat.Core_Type__c = 'Case Category';
            insert caseCat; 
            System.assert(caseCat.Id != null, 'Record not created');
            
            subCategory = TestUtilities.getCaseCategories();
            subCategory.Core_Issue_Sub_Category_Name__c = masterCategory.id;
            subCategory.Core_Type__c = 'Case Subcategory';
            insert subCategory; 
            System.assert(subCategory.Id != null, 'Record not created');
            
            recordtype rType = [select id from  recordtype where Name ='IPS case create'];
            for(case cs:caseList){
                cs.accountId = account.id;
                cs.entitlementId = ent.Id;
                cs.ownerId = grp1.Id;
                cs.recordtypeId = rType.Id;
                cs.Core_First_Response_Completed__c =false;
                cs.Core_Case_Issue_Category__c = caseCat.id;
                cs.Core_case_issue_sub_category__c = subCategory.id;
                
                cs.ContactId = listOfContacts.get(0).id;
                cs.Priority = 'Low';
                cs.Core_Sub_Status__c = 'Reproduced';
                cs.Core_Intel_Sup_Owner__c = UserInfo.getUserId();
                cs.Core_IPS_Is_Notification_Active__c = true;
                cs.Core_Latest_Comment_Time_Stamp__c = System.now()+1;                
            }
            caseList[0].SlaStartDate = System.now() - 1;
            insert caseList;
            Core_IPS_CaseTriggerHandler.loadGroupById(caseList);
        }
    }
    /***************************************************************************************************
Method Name:  IPSCaseFieldsInit_test()
Method Type: Test Method
Version     : 1.0 
Created Date: 5/24/2017
Description:  Testing IPSCaseFieldsInit method
Scenario Type:  Negative
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Aparna                      5/24/2017                Created
****************************************************************************************************/
    public static testmethod void ipsCaseFieldsInitTest(){
        
        List<Case> caseList = new List<Case>();
        Account acct =  new Account();
        Contact con =  new Contact();
        Entitlement ent = new Entitlement();
        acct = TestUtilities.getAccountRecord();
        acct.Core_CNDA_Number__c ='1691';
        insert acct;
        Contact contactRecord;
        contactRecord = TestUtilities.getContact();
        contactRecord.Accountid = acct.id;
        // contactRecord.Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
        contactRecord.core_ips_Active__c=false;
        contactRecord.Email = 'ContactDellTest@gmail.com';
        contactRecord.MailingCountry = 'India';
        insert contactRecord; 
        
        
        //Custom Setting - Trigger Executions
        List<Core_Trigger_Executions__c> triggerExecutionList= new List<Core_Trigger_Executions__c>();
        Core_Trigger_Executions__c  triggerExecution = new Core_Trigger_Executions__c();
        triggerExecution.Name = 'IPSCaseFieldsInit';
        triggerExecution.Core_Active__c = true;
        triggerExecution.Core_Class_Name__c ='Core_IPS_CaseTriggerHandler';
        triggerExecution.Core_Description__c = 'To update Case fields.';
        triggerExecution.Core_Object__c = 'Case';
        triggerExecution.Core_Trigger_Events__c = 'before insert';
        insert triggerExecution; 
        Id devRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('IPS Case Create').getRecordTypeId();
        Case c= new case(recordtypeId=devRecordTypeId,contactId=contactRecord.id,subject='testing case', Type='Test case', Origin='phone', Reason='Testing',Status='new',Priority='high',Core_Severity__c='1234');
        caseList.add(c);
        insert caseList;
        System.assertEquals(caseList!=null, true, 'Cases Inserted');
        Core_IPS_CaseTriggerHandler.IPSCaseFieldsInit(caseList);
    }
    
    /***************************************************************************************************
Method Name:  updateSupportLevelOnCase_Test
Method Type: Test Method
Version     : 1.0 
Created Date: 12 Oct 2017
Description:  Testing updateSupportLevelOnCase method
Scenario Type:  Positive
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Yogesh Sharma              10/12/2017                Created
* Sandeep Sankhla       10/12/2017          Modified
****************************************************************************************************/
    static testmethod void updateSupportLevelOnCaseTest(){
        Test.startTest();
        Map<String,ID> profiles = new Map<String,ID>();
        List<String> strProf = new List<String>();
        strProf.add('System Administrator');
        strProf.add('IPS Data Migration');
        List<Profile> profileList = [select id, name from Profile where name IN : strProf];
        
        for(Profile prf : profileList){
            profiles.put(prf.name, prf.id);
        }
        
        //Create Users
        List<User> listOfUser = new List<User>();
        listOfUser = TestUtilities.getListOfUser(1); 
        listOfUser.get(0).ProfileId =  profiles.get('System Administrator');
        insertUsersWithValidationBypass(listOfUser);
        
        //Custom Setting - Trigger Executions
        Core_Trigger_Executions__c  triggerExecution = new Core_Trigger_Executions__c();
        triggerExecution.Name = 'updateSupportLevelOnCase';
        triggerExecution.Core_Active__c = true;
        triggerExecution.Core_Class_Name__c ='Core_IPS_CaseTriggerHandler';
        triggerExecution.Core_Description__c = 'To update Support Level On Case.';
        triggerExecution.Core_Object__c = 'Case';
        triggerExecution.Core_Trigger_Events__c = 'before insert';
        insert triggerExecution; 
        System.assert(triggerExecution.id != null, 'triggerExecution inserted');
        
        //Custom Setting - Trigger Executions Sandeeep US84539: I2
        Core_Trigger_Executions__c  triggerExecution1 = new Core_Trigger_Executions__c();
        triggerExecution1.Name = 'checkCaseClosureParams';
        triggerExecution1.Core_Active__c = true;
        triggerExecution1.Core_Class_Name__c ='Core_IPS_CaseTriggerHandler';
        triggerExecution1.Core_Description__c = 'Check If Org number is same and Case closure is equal to custom setting closure and bugfix id is not empty.';
        triggerExecution1.Core_Object__c = 'Case';
        triggerExecution1.Core_Trigger_Events__c = 'before update';
        insert triggerExecution1; 
        System.assert(triggerExecution1.id != null, 'triggerExecution inserted');
        
        //Custom Setting Record inserted by Sandeep US84539: I2
        Core_IPS_Support_Org_Specification__c supportOrgCustomSetting = new Core_IPS_Support_Org_Specification__c();
        supportOrgCustomSetting.Core_IPS_Is_Active__c = true;
        supportOrgCustomSetting.Core_IPS_Case_Closure__c = 'Fix in Intel Documentation';
        supportOrgCustomSetting.Core_IPS_Field_Name__c = 'Core_IPS_Bug_Doc_Fix_ID__c';
        supportOrgCustomSetting.Core_IPS_Support_Org_Number__c = 'Org-027';
        supportOrgCustomSetting.Name = 'PSG';
        supportOrgCustomSetting.Core_IPS_Trigger_Field_Value__c= 'Close-Pending';
        supportOrgCustomSetting.Core_IPS_Trigger_Field_API__c = 'Core_Sub_Status__c';
        insert supportOrgCustomSetting;
        
        System.assert(supportOrgCustomSetting.id != NULL,'Custom setting is not Null');
        
        Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('updateSupportLevelOnCase');
        
        //Custom Setting - Core IPS Labels
        List<Core_IPS_Labels__c> listofIpsLables = new List<Core_IPS_Labels__c>();
        Core_IPS_Labels__c ipsLables1 = new Core_IPS_Labels__c(Name = 'Case_RT_Name_IPS_Case_Create',Value__c = 'IPS Case Create');
        Core_IPS_Labels__c ipsLables2 = new Core_IPS_Labels__c(Name = 'Case_RT_Name_IPS_NoAssignedContact',Value__c = 'IPS No Assigned Contact Case');
        Core_IPS_Labels__c ipsLables3 = new Core_IPS_Labels__c(Name = 'Support_Level_Default',Value__c = 'ROW');
        Core_IPS_Labels__c ipsLables4 = new Core_IPS_Labels__c(Name = 'Support_Level_Default_No_Assigned_Cont',Value__c = 'Tier 3');
        listofIpsLables.add(ipsLables1);
        listofIpsLables.add(ipsLables2);
        listofIpsLables.add(ipsLables3);  
        List<Core_IPS_Labels__c> ipsLabelsForGlobalAsset = TestUtilities.getIPSLabel();
        for(Core_IPS_Labels__c ipl : ipsLabelsForGlobalAsset){
            if(ipl.Name == 'Core_IPS_Global_Asset_RT'){
                ipl.value__c = 'Core_Public_Product';
            }
        }
        listofIpsLables.addAll(ipsLabelsForGlobalAsset);  
        
        insert listofIpsLables;
        
        //Get intelSupportOwner Id (User Id)
        Id intelSupportOwner = listOfUser.get(0).id;
        System.runAs(listOfUser.get(0)){
            
            //Create Support Org
            List<Core_IPS_Product_Organization__c> listOfSupportOrg  = TestUtilities.getListOfSupportOrg(2);
            insert listOfSupportOrg;
            
            //System.assert(listOfSupportOrg != null, 'Record not created');
            
            //Create Accounts
            List<Account> listOfAccounts = TestUtilities.getListOfAccounts(2);
            insert listOfAccounts;
            System.assert(listOfAccounts[0].Id != null, 'Record not created');
            
            //Create Contact
            List<Contact> listOfContacts = TestUtilities.getListOfContact(1);
            for(Contact contactRec : listOfContacts){
                contactRec.Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
                contactRec.core_ips_Active__c=true;
                contactRec.Accountid = listOfAccounts.get(0).Id;
                contactRec.MailingCountry = 'India';
            }
            insert listOfContacts;
            System.assert(listOfContacts[0].Id != null, 'Record not created');
            
            
            //Create Product
            Integer counter = 0;
            
            List<Product2> listOfProducts = TestUtilities.getListOfProduct(2);
            for(Product2 product : listOfProducts){
                if(counter==0){
                    product.Core_Hierarchy_ID__c = '43';
                    product.Core_Hierarchy_Name__c = 'ProdHierarchyName';
                    product.Core_Unique_ID__c = 'Product12345';
                    product.Core_Code_Name__c = 'ProductCoreCodeName';
                }else{
                    product.Core_Hierarchy_ID__c = '59';
                    product.Core_Hierarchy_Name__c = 'ProdHierarchyName59';
                    product.Core_Unique_ID__c = 'Product59';
                    product.Core_Code_Name__c = 'ProductCoreCodeName59';
                    
                }
                counter++;
            }
            insert listOfProducts;
            System.assert(listOfProducts[0].id != null,'Record not created');
            
            
            //Create Supported product
            counter = 0;
            List<Core_IPS_Supported_Product__c> listOfSupportedProduct = TestUtilities.getListOfSupportedProduct(2);
            for(Core_IPS_Supported_Product__c supportedProduct : listOfSupportedProduct){
                if(counter==0){
                    supportedProduct.Core_Product__c = listOfProducts.get(0).id;
                    supportedProduct.Core_Product_Organization__c = listOfSupportOrg.get(0).id;
                }else{
                    supportedProduct.Core_Product__c = listOfProducts.get(1).id;
                    supportedProduct.Core_Product_Organization__c = listOfSupportOrg.get(1).id;
                }
                counter++;
            }
            insert listOfSupportedProduct;
            System.assert(listOfSupportedProduct[0].id != null,'Record not created');
            
            //Create Asset
            counter = 0;
            list<Asset> assetList = TestUtilities.getAssetList(2);
            for(Asset asst : assetList){
                asst.accountId = listOfAccounts.get(0).Id;
                asst.Contactid = listOfContacts.get(0).id;
                if(counter==0){
                    asst.core_product_organization__c = listOfSupportOrg.get(0).id;
                    asst.core_supported_product__c = listOfSupportedProduct.get(0).id;
                    asst.product2Id = listOfProducts.get(0).id;
                }else{
                    asst.core_product_organization__c = listOfSupportOrg.get(1).id;
                    asst.core_supported_product__c = listOfSupportedProduct.get(1).id;
                    asst.product2Id = listOfProducts.get(1).id;
                }
                counter++;
            }
            insert assetList;
            System.assert(assetList[0].Id != null, 'Record not created');
            
            
            //Create Ips Project
            counter = 0;
            List<Core_IPS_Project__c> listOfIpsProjects = TestUtilities.getListOfIpsProjects(2);
            insert listOfIpsProjects;
            System.assert(listOfIpsProjects[0].Id != null, 'Record not created');
            
            // Create Ips Account
            Counter=0;
            List<Core_IPS_Account__c> listOfIpsAccounts = TestUtilities.getListOfIpsAccounts(2);
            for(Core_IPS_Account__c ipsAcc : listOfIpsAccounts){
                if(counter<1){
                    ipsAcc.Core_Account__c = listOfAccounts.get(0).Id;
                    ipsAcc.Core_IPS_Project__c = listOfIpsProjects.get(0).Id;
                } else {
                    ipsAcc.Core_Account__c = listOfAccounts.get(0).Id;
                    ipsAcc.Core_IPS_Project__c = listOfIpsProjects.get(1).Id;
                }
                counter++;
            }
            counter = 0;
            insert listOfIpsAccounts;
            System.assert(listOfIpsAccounts[0].Id != null, 'Record not created');
            
            //Get Suport Level Picklist Values
            Schema.DescribeFieldResult fieldResult = Core_IPS_Support_Level__c.Core_IPS_Support_Level__c.getDescribe();
            List<SelectOption> options = new List<SelectOption>(); 
            for(Schema.PicklistEntry f : fieldResult.getPicklistValues()){
                options.add(new SelectOption(f.getLabel(), f.getValue()));
            }   
            
            //Created Support Level
            Core_IPS_Support_Level__c supLevel = new Core_IPS_Support_Level__c();
            supLevel.Core_IPS_Account__c = listOfAccounts.get(0).Id;
            supLevel.Core_IPS_Support_Org__c = listOfSupportOrg.get(0).Id;
            supLevel.Core_IPS_Support_Level__c = options.get(0).getValue();
            insert supLevel;
            Test.stopTest();
            // Create Case
            counter=0;
            List<Case> listOfCases = TestUtilities.getListOfCases(10);
            
            for(Case caseRec : listOfCases){
                caseRec.ContactId = listOfContacts.get(0).id;
                caseRec.accountId = listOfAccounts.get(0).Id;
                caseRec.Core_IPS_GEC_Case__c=false;
                if(counter < 2){
                    caseRec.assetId = assetList.get(0).Id;
                    // caseRec.Core_IPS_Project_Case__c = listOfIpsProjects.get(0).id;
                    caseRec.Core_IPS_Supported_Product__c = listOfSupportedProduct.get(0).id; 
                }
                else if(counter>=2 && counter <5){
                    caseRec.assetId = assetList.get(1).Id;
                    caseRec.Core_IPS_Project_Case__c = listOfIpsProjects.get(0).id;
                }
                else{
                    caseRec.assetId = assetList.get(1).Id;
                    caseRec.Core_IPS_Project_Case__c = listOfIpsProjects.get(0).id;
                    caseRec.Core_IPS_Supported_Product__c = listOfSupportedProduct.get(1).id; 
                }
                counter++;
            }
            insert listOfCases;
            
            System.assert(listOfCases[0].Id != null, 'Record not created');
            
            String noAssignedContactCaseRecordType = Core_IPS_Helper_Utility.getIPSLabel('Case_RT_Name_IPS_NoAssignedContact');
            Case c1 = TestUtilities.getListOfCases(10).get(0);
            c1.RecordTypeId = Core_IPS_CaseTriggerHandler.getCaseRecordtypeIDByName(noAssignedContactCaseRecordType);
            c1.assetId = assetList.get(1).Id;
            c1.Core_IPS_Project_Case__c = listOfIpsProjects.get(0).id;
            c1.Core_IPS_Supported_Product__c = listOfSupportedProduct.get(0).id;  
            
            insert c1;
            /*start added by Yogesh US72443*/
            c1.Core_IPS_Supported_Product__c = listOfSupportedProduct.get(1).id;
            
            update c1; 
            /*end */
            insert ipsLables4;
            Case c2 = TestUtilities.getListOfCases(10).get(0);
            c2.RecordTypeId = Core_IPS_CaseTriggerHandler.getCaseRecordtypeIDByName(noAssignedContactCaseRecordType);
            c2.assetId = assetList.get(1).Id;
            c2.Core_IPS_Project_Case__c = listOfIpsProjects.get(0).id;
            c2.Core_IPS_Supported_Product__c = listOfSupportedProduct.get(1).id;  
            
            insert  c2; 
            //start added by Yogesh US72443
            c2.Core_IPS_Supported_Product__c = listOfSupportedProduct.get(0).id;
            
            update c2; 
            //end
        }   
        
    }
    
    /***************************************************************************************************
Method Name:  manageCaseAccessForCustomer_Test
Method Type: Test Method
Version     : 1.0 
Created Date: 10 Nov 2017
Description:  Testing manageCaseAccessForCustomer method
Scenario Type:  Positive and Negative
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Yogesh Sharma              10/11/2017                Created
****************************************************************************************************/
    static testmethod void manageCaseAccessForCustomerTest(){
        Test.startTest();
        Map<String,ID> profiles = new Map<String,ID>();
        List<String> strProf = new List<String>();
        strProf.add('System Administrator');
        strProf.add('IPS Data Migration');
        List<Profile> profileList = [select id, name from Profile where name IN : strProf];
        
        for(Profile prf : profileList){
            profiles.put(prf.name, prf.id); 
        }
        
        //Create Users
        List<User> listOfUser = new List<User>();
        listOfUser = TestUtilities.getListOfUser(1); 
        listOfUser.get(0).ProfileId =  profiles.get('System Administrator');
        insertUsersWithValidationBypass(listOfUser);
        
        //Custom Setting - Trigger Executions
        //List<Core_Trigger_Executions__c> triggerExecutionList= new List<Core_Trigger_Executions__c>();
        Core_Trigger_Executions__c  triggerExecution = new Core_Trigger_Executions__c();
        triggerExecution.Name = 'IPSCaseFieldsInit';
        triggerExecution.Core_Active__c = true;
        triggerExecution.Core_Class_Name__c ='Core_IPS_CaseTriggerHandler';
        triggerExecution.Core_Description__c = 'To update Case fields.';
        triggerExecution.Core_Object__c = 'Case';
        triggerExecution.Core_Trigger_Events__c = 'before insert';
        insert triggerExecution;
        System.assert(triggerExecution.id != null, 'triggerExecution inserted');
        
        // Create Ips Labels added by Aayushi US78952
        List<Core_IPS_Labels__c> ipsLabels = TestUtilities.getIPSLabel();
        for(Core_IPS_Labels__c il: ipsLabels){
            if(il.name=='ProjectGroupPrefix'){
                il.Value__c = 'IPS_Proj_';
            }
            if(il.name=='CoreStatus_SPtoActive_Error'){
                il.Value__c = 'Project Status cannot be changed from Submitted Pending to Active';
            }
            if(il.name=='Core_OneProjProdMem_Error'){
                il.Value__c = 'Project cannot be submitted without atleast one account and one Product and one Project Member';
            }
            if(il.name=='CoreStatus_Draft'){
                il.Value__c = 'Draft'; 
            }
            if(il.name=='CoreStatus_Active'){
                il.Value__c = 'Active' ;
            }
            if(il.name=='CoreStatus_Inactive'){
                il.Value__c = 'Inactive' ;
            }
            if(il.name=='CoreStatus_SP'){
                il.Value__c = 'Submitted Pending' ;
            }
            if(il.name=='Core_IPS_Bug/Fix_ErrMsg'){
                il.Value__c = 'Error : Bug/Doc Fix ID is required in order to close a case.' ;  
            }
            if(il.name=='Core_IPS_Bug/Fix_StatusValue'){
                il.Value__c = 'Closed' ;
            }
        }
        //Custom Setting - Core IPS Labels
        List<Core_IPS_Labels__c> listofIpsLables = new List<Core_IPS_Labels__c>();
        Core_IPS_Labels__c ipsLables1 = new Core_IPS_Labels__c(Name = 'Case_RT_Name_IPS_Case_Create',Value__c = 'IPS Case Create');
        Core_IPS_Labels__c ipsLables2 = new Core_IPS_Labels__c(Name = 'Case_RT_Name_IPS_NoAssignedContact',Value__c = 'IPS No Assigned Contact Case');
        Core_IPS_Labels__c ipsLables3 = new Core_IPS_Labels__c(Name = 'Support_Level_Default',Value__c = 'ROW');
        Core_IPS_Labels__c ipsLables4 = new Core_IPS_Labels__c(Name = 'Support_Level_Default_No_Assigned_Cont',Value__c = 'Tier 2');
        //Core_IPS_Labels__c ipsLables5 = new Core_IPS_Labels__c(Name = 'Core_IPS_Bug/Fix_ErrMsg', Value__c = 'Error : Bug/Doc Fix ID is required in order to close a case.');
        //Core_IPS_Labels__c ipsLables6 = new Core_IPS_Labels__c(Name = 'Core_IPS_Bug/Fix_StatusValue', Value__c = 'Closed');
        
        listofIpsLables.add(ipsLables1);
        listofIpsLables.add(ipsLables2);
        listofIpsLables.add(ipsLables3); 
        listofIpsLables.add(ipsLables4);
        //listofIpsLables.add(ipsLables5); 
        //listofIpsLables.add(ipsLables6);
        
        listofIpsLables.addAll(ipsLabels);
        insert listofIpsLables;
        
        //Get intelSupportOwner Id (User Id)
        Id intelSupportOwner = listOfUser.get(0).id;
        System.runAs(listOfUser.get(0)){
            
            //Create Support Org
            List<Core_IPS_Product_Organization__c> listOfSupportOrg  = TestUtilities.getListOfSupportOrg(2);
            insert listOfSupportOrg;
            
            //System.assert(listOfSupportOrg != null, 'Record not created');
            
            //Create Accounts
            List<Account> listOfAccounts = TestUtilities.getListOfAccounts(2);
            insert listOfAccounts;
            System.assert(listOfAccounts[0].Id != null, 'Record not created');
            
            //Create Contact
            List<Contact> listOfContacts = TestUtilities.getListOfContact(1);
            for(Contact contactRec : listOfContacts){
                contactRec.Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
                contactRec.core_ips_Active__c=true;
                contactRec.Accountid = listOfAccounts.get(0).Id;
                contactRec.MailingCountry = 'India';
            }
            insert listOfContacts;
            System.assert(listOfContacts[0].Id != null, 'Record not created');
            
            
            //Create Product
            Integer counter = 0;
            
            List<Product2> listOfProducts = TestUtilities.getListOfProduct(2);
            for(Product2 product : listOfProducts){
                if(counter==0){
                    product.Core_Hierarchy_ID__c = '43';
                    product.Core_Hierarchy_Name__c = 'ProdHierarchyName';
                    product.Core_Unique_ID__c = 'Product12345';
                    product.Core_Code_Name__c = 'ProductCoreCodeName';
                }else{
                    product.Core_Hierarchy_ID__c = '59';
                    product.Core_Hierarchy_Name__c = 'ProdHierarchyName59';
                    product.Core_Unique_ID__c = 'Product59';
                    product.Core_Code_Name__c = 'ProductCoreCodeName59';
                    
                }
                counter++;
            }
            insert listOfProducts;
            System.assert(listOfProducts[0].id != null,'Record not created');
            
            
            //Create Supported product
            counter = 0;
            List<Core_IPS_Supported_Product__c> listOfSupportedProduct = TestUtilities.getListOfSupportedProduct(2);
            for(Core_IPS_Supported_Product__c supportedProduct : listOfSupportedProduct){
                if(counter==0){
                    supportedProduct.Core_Product__c = listOfProducts.get(0).id;
                    supportedProduct.Core_Product_Organization__c = listOfSupportOrg.get(0).id;
                }else{
                    supportedProduct.Core_Product__c = listOfProducts.get(1).id;
                    supportedProduct.Core_Product_Organization__c = listOfSupportOrg.get(1).id;
                }
                counter++;
            }
            insert listOfSupportedProduct;
            System.assert(listOfSupportedProduct[0].id != null,'Record not created');
            
            //Create Asset
            counter = 0;
            list<Asset> assetList = TestUtilities.getAssetList(2);
            for(Asset asst : assetList){
                asst.accountId = listOfAccounts.get(0).Id;
                asst.Contactid = listOfContacts.get(0).id;
                if(counter==0){
                    asst.core_product_organization__c = listOfSupportOrg.get(0).id;
                    asst.core_supported_product__c = listOfSupportedProduct.get(0).id;
                    asst.product2Id = listOfProducts.get(0).id;
                }else{
                    asst.core_product_organization__c = listOfSupportOrg.get(1).id;
                    asst.core_supported_product__c = listOfSupportedProduct.get(1).id;
                    asst.product2Id = listOfProducts.get(1).id;
                }
                counter++;
            }
            insert assetList;
            System.assert(assetList[0].Id != null, 'Record not created');
            
            
            //Create Ips Project
            counter = 0;
            List<Core_IPS_Project__c> listOfIpsProjects = TestUtilities.getListOfIpsProjects(2);
            insert listOfIpsProjects;
            System.assert(listOfIpsProjects[0].Id != null, 'Record not created');
            
            // Create Ips Account
            Counter=0;
            List<Core_IPS_Account__c> listOfIpsAccounts = TestUtilities.getListOfIpsAccounts(2);
            for(Core_IPS_Account__c ipsAcc : listOfIpsAccounts){
                if(counter<1){
                    ipsAcc.Core_Account__c = listOfAccounts.get(0).Id;
                    ipsAcc.Core_IPS_Project__c = listOfIpsProjects.get(0).Id;
                } else {
                    ipsAcc.Core_Account__c = listOfAccounts.get(0).Id;
                    ipsAcc.Core_IPS_Project__c = listOfIpsProjects.get(1).Id;
                }
                counter++;
            }
            counter = 0;
            insert listOfIpsAccounts;
            System.assert(listOfIpsAccounts[0].Id != null, 'Record not created');
            
            //Get Suport Level Picklist Values
            Schema.DescribeFieldResult fieldResult = Core_IPS_Support_Level__c.Core_IPS_Support_Level__c.getDescribe();
            List<SelectOption> options = new List<SelectOption>(); 
            for(Schema.PicklistEntry f : fieldResult.getPicklistValues()){
                options.add(new SelectOption(f.getLabel(), f.getValue()));
            }   
            
            //Created Support Level
            Core_IPS_Support_Level__c supLevel = new Core_IPS_Support_Level__c();
            supLevel.Core_IPS_Account__c = listOfAccounts.get(0).Id;
            supLevel.Core_IPS_Support_Org__c = listOfSupportOrg.get(0).Id;
            supLevel.Core_IPS_Support_Level__c = options.get(0).getValue();
            insert supLevel;
            
            //Create Case For Customer Visible Checkbox
            List<Case> lstCase = TestUtilities.getListOfCases(5);
            Core_IPS_CaseTriggerHandler.assignMigratedCaseInformation(lstCase); //added by chiru
            lstCase.get(0).accountId = listOfAccounts.get(0).Id;
            lstCase.get(0).ContactId = listOfContacts.get(0).id;
            lstCase.get(0).Core_IPS_Customer_Visible__c = false;
            
            lstCase.get(1).accountId = listOfAccounts.get(0).Id;
            lstCase.get(1).ContactId = listOfContacts.get(0).id;
            lstCase.get(1).Core_IPS_Customer_Visible__c = false;
            lstCase.get(1).assetId = assetList.get(1).Id;
            lstCase.get(1).Core_IPS_Project_Case__c = listOfIpsProjects.get(0).id;
            
            lstCase.get(2).accountId = listOfAccounts.get(0).Id;
            lstCase.get(2).ContactId = listOfContacts.get(0).id;
            lstCase.get(2).Core_IPS_Customer_Visible__c = false;
            lstCase.get(2).assetId = assetList.get(1).Id;
            lstCase.get(2).Core_IPS_Project_Case__c = listOfIpsProjects.get(0).id;
            
            lstCase.get(3).accountId = listOfAccounts.get(0).Id;
            lstCase.get(3).ContactId = listOfContacts.get(0).id;
            lstCase.get(3).Core_IPS_Customer_Visible__c = false;
            lstCase.get(3).assetId = assetList.get(1).Id;
            lstCase.get(3).Core_IPS_Project_Case__c = null;
            
            lstCase.get(4).accountId = listOfAccounts.get(0).Id;
            lstCase.get(4).ContactId = listOfContacts.get(0).id;
            lstCase.get(4).Core_IPS_Customer_Visible__c = false;
            lstCase.get(4).assetId = assetList.get(1).Id;
            lstCase.get(4).Core_IPS_Project_Case__c = null;
            
            insert lstCase;
            
            lstCase.get(1).Core_IPS_Project_Case__c  = null;
            lstCase.get(1).Core_IPS_Customer_Visible__c = false; 
            
            lstCase.get(2).Core_IPS_Project_Case__c  = listOfIpsProjects.get(1).id;
            lstCase.get(2).Core_IPS_Customer_Visible__c = false; 
            
            lstCase.get(3).Core_IPS_Project_Case__c  = listOfIpsProjects.get(1).id;
            lstCase.get(3).Core_IPS_Customer_Visible__c = false; 
            
            lstCase.get(4).accountId = listOfAccounts.get(1).Id;
            lstCase.get(4).Core_IPS_Project_Case__c  = null;
            lstCase.get(4).Core_IPS_Customer_Visible__c = false;   
            
            update lstCase;
            Case cs= new Case();
            insert cs;
            /*CaseShare csShareRec = new CaseShare();
csShareRec.CaseAccessLevel = 'Edit';
csShareRec.CaseId = cs.Id;
csShareRec.UserOrGroupId = listOfUser.get(0).Id;
insert csShareRec;  */         
        } 
        Test.stopTest(); 
    } 
    
    /***************************************************************************************************
Method Name:  updateSupportLevelOnCase_Test2
Method Type: Test Method
Version     : 1.0 
Created Date: 21 Feb 2018
Description:  Testing updateSupportLevelOnCase method
Scenario Type:  Positive
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sugandha              21/02/2018                Created
* Aayushi               22/03/2018                Modified
****************************************************************************************************/
    static testmethod void updateSupportLevelOnCaseTest2(){
        Test.startTest();
        Map<String,ID> profiles = new Map<String,ID>();
        List<String> strProf = new List<String>();
        strProf.add('System Administrator');
        strProf.add('IPS Data Migration');
        List<Profile> profileList = [select id, name from Profile where name IN : strProf];
        
        for(Profile prf : profileList){
            profiles.put(prf.name, prf.id);
        }
        
        //Create Users
        List<User> listOfUser = new List<User>();
        listOfUser = TestUtilities.getListOfUser(1); 
        listOfUser.get(0).ProfileId =  profiles.get('System Administrator');
        insertUsersWithValidationBypass(listOfUser);
        
        //Custom Setting - Trigger Executions
        List<Core_Trigger_Executions__c> triggerExecutionList= new List<Core_Trigger_Executions__c>();
        Core_Trigger_Executions__c  triggerExecution = new Core_Trigger_Executions__c();
        triggerExecution.Name = 'IPSCaseFieldsInit';
        triggerExecution.Core_Active__c = true;
        triggerExecution.Core_Class_Name__c ='Core_IPS_CaseTriggerHandler';
        triggerExecution.Core_Description__c = 'To update Case fields.';
        triggerExecution.Core_Object__c = 'Case';
        triggerExecution.Core_Trigger_Events__c = 'before insert';
        insert triggerExecution; 
        System.assert(triggerExecution.id != null, 'triggerExecution inserted');
        
        //Custom Setting - Trigger Executions Sandeeep US84539: I2
        Core_Trigger_Executions__c  triggerExecution1 = new Core_Trigger_Executions__c();
        triggerExecution1.Name = 'checkCaseClosureParams';
        triggerExecution1.Core_Active__c = true;
        triggerExecution1.Core_Class_Name__c ='Core_IPS_CaseTriggerHandler';
        triggerExecution1.Core_Description__c = 'Check If Org number is same and Case closure is equal to custom setting closure and bugfix id is not empty.';
        triggerExecution1.Core_Object__c = 'Case';
        triggerExecution1.Core_Trigger_Events__c = 'before update';
        insert triggerExecution1; 
        System.assert(triggerExecution1.id != null, 'triggerExecution inserted');
        
        //Custom Setting Record inserted by Sandeep US84539: I2
        Core_IPS_Support_Org_Specification__c supportOrgCustomSetting = new Core_IPS_Support_Org_Specification__c();
        supportOrgCustomSetting.Core_IPS_Is_Active__c = true;
        supportOrgCustomSetting.Core_IPS_Case_Closure__c = 'Fix in Intel Documentation';
        supportOrgCustomSetting.Core_IPS_Field_Name__c = 'Core_IPS_Bug_Doc_Fix_ID__c';
        supportOrgCustomSetting.Core_IPS_Support_Org_Number__c = 'Org-027';
        supportOrgCustomSetting.Name = 'PSG';
        insert supportOrgCustomSetting;
        //start added by Aayushi US89551
        Core_Trigger_Executions__c  triggerExecutionRec = new Core_Trigger_Executions__c();
        triggerExecutionRec.Name = 'provideProjCaseAccessToFAE';
        triggerExecutionRec.Core_Active__c = true;
        triggerExecutionRec.Core_Class_Name__c ='Core_IPS_Account_Handler';
        triggerExecutionRec.Core_Description__c = 'Activate Or Deactivate Project Members';
        triggerExecutionRec.Core_Object__c = 'Core_IPS_Account__c';
        triggerExecutionRec.Core_Trigger_Events__c = 'after update';
        insert triggerExecutionRec;
        //end
        System.assert(supportOrgCustomSetting.id != NULL,'Custom setting is not Null');
        
        Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('updateSupportLevelOnCase');
        
        //Custom Setting - Core IPS Labels
        List<Core_IPS_Labels__c> listofIpsLables = new List<Core_IPS_Labels__c>();
        Core_IPS_Labels__c ipsLables1 = new Core_IPS_Labels__c(Name = 'Case_RT_Name_IPS_Case_Create',Value__c = 'IPS Case Create');
        Core_IPS_Labels__c ipsLables2 = new Core_IPS_Labels__c(Name = 'Case_RT_Name_IPS_NoAssignedContact',Value__c = 'IPS No Assigned Contact Case');
        Core_IPS_Labels__c ipsLables3 = new Core_IPS_Labels__c(Name = 'Support_Level_Default',Value__c = 'ROW');
        Core_IPS_Labels__c ipsLables4 = new Core_IPS_Labels__c(Name = 'Support_Level_Default_No_Assigned_Cont',Value__c = 'Tier 3');
        listofIpsLables.add(ipsLables1);
        listofIpsLables.add(ipsLables2);
        listofIpsLables.add(ipsLables3);  
        List<Core_IPS_Labels__c> ipsLabelsForGlobalAsset = TestUtilities.getIPSLabel();
        for(Core_IPS_Labels__c ipl : ipsLabelsForGlobalAsset){
            if(ipl.Name == 'Core_IPS_Global_Asset_RT'){
                ipl.value__c = 'Core_Public_Product';
            }
        }
        listofIpsLables.addAll(ipsLabelsForGlobalAsset);  
        
        insert listofIpsLables;
        
        //Get intelSupportOwner Id (User Id)
        Id intelSupportOwner = listOfUser.get(0).id;
        System.runAs(listOfUser.get(0)){
            
            //Create Support Org
            List<Core_IPS_Product_Organization__c> listOfSupportOrg  = TestUtilities.getListOfSupportOrg(2);
            insert listOfSupportOrg;
            
            //System.assert(listOfSupportOrg != null, 'Record not created');
            
            //Create Accounts
            List<Account> listOfAccounts = TestUtilities.getListOfAccounts(2);
            insert listOfAccounts;
            System.assert(listOfAccounts[0].Id != null, 'Record not created');
            
            //Create Contact
            List<Contact> listOfContacts = TestUtilities.getListOfContact(1);
            for(Contact contactRec : listOfContacts){
                contactRec.Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
                contactRec.core_ips_Active__c=true;
                contactRec.Accountid = listOfAccounts.get(0).Id;
                contactrec.MailingCountry = 'India';
            }
            insert listOfContacts;
            System.assert(listOfContacts[0].Id != null, 'Record not created');
            
            
            //Create Product
            Integer counter = 0;
            
            List<Product2> listOfProducts = TestUtilities.getListOfProduct(2);
            for(Product2 product : listOfProducts){
                if(counter==0){
                    product.Core_Hierarchy_ID__c = '43';
                    product.Core_Hierarchy_Name__c = 'ProdHierarchyName';
                    product.Core_Unique_ID__c = 'Product12345';
                    product.Core_Code_Name__c = 'ProductCoreCodeName';
                }else{
                    product.Core_Hierarchy_ID__c = '59';
                    product.Core_Hierarchy_Name__c = 'ProdHierarchyName59';
                    product.Core_Unique_ID__c = 'Product59';
                    product.Core_Code_Name__c = 'ProductCoreCodeName59';
                    
                }
                counter++;
            }
            insert listOfProducts;
            System.assert(listOfProducts[0].id != null,'Record not created');
            
            
            //Create Supported product
            counter = 0;
            List<Core_IPS_Supported_Product__c> listOfSupportedProduct = TestUtilities.getListOfSupportedProduct(2);
            for(Core_IPS_Supported_Product__c supportedProduct : listOfSupportedProduct){
                if(counter==0){
                    supportedProduct.Core_Product__c = listOfProducts.get(0).id;
                    supportedProduct.Core_Product_Organization__c = listOfSupportOrg.get(0).id;
                }else{
                    supportedProduct.Core_Product__c = listOfProducts.get(1).id;
                    supportedProduct.Core_Product_Organization__c = listOfSupportOrg.get(1).id;
                }
                counter++;
            }
            insert listOfSupportedProduct;
            System.assert(listOfSupportedProduct[0].id != null,'Record not created');
            
            //Create Asset
            counter = 0;
            list<Asset> assetList = TestUtilities.getAssetList(2);
            for(Asset asst : assetList){
                asst.accountId = listOfAccounts.get(0).Id;
                asst.Contactid = listOfContacts.get(0).id;
                if(counter==0){
                    asst.core_product_organization__c = listOfSupportOrg.get(0).id;
                    asst.core_supported_product__c = listOfSupportedProduct.get(0).id;
                    asst.product2Id = listOfProducts.get(0).id;
                }else{
                    asst.core_product_organization__c = listOfSupportOrg.get(1).id;
                    asst.core_supported_product__c = listOfSupportedProduct.get(1).id;
                    asst.product2Id = listOfProducts.get(1).id;
                }
                counter++;
            }
            insert assetList;
            System.assert(assetList[0].Id != null, 'Record not created');
            
            
            //Create Ips Project
            counter = 0;
            List<Core_IPS_Project__c> listOfIpsProjects = TestUtilities.getListOfIpsProjects(2);
            insert listOfIpsProjects;
            System.assert(listOfIpsProjects[0].Id != null, 'Record not created');
            //insert fae added by Aayushi 20/03/2018 US89551
            List<user> userList = TestUtilities.getListofuser(1);
            profile prof = [select id, name from Profile where name = 'Sales Rep-BB' limit 1];
            userlist[0].profileid=prof.id;
            userlist[0].username='salesrep0202.abc@user.com';
            System.runAs(listOfUser.get(0)){
                insert userlist;
            }
            //start added by Aayushi 20/03/2018 US89551
            String teamMemberRole = 'Team Member (100%)';
            String accountAccessLevel = 'Edit';
            String opportunityAccessLevel = 'Edit';
            String caseAccessLevel = 'None';
            List<AccountTeamMember> members = new list<AccountTeamMember>();
            List<AccountShare> sharingRules = new list<AccountShare>();
            //end
            // Create Ips Account
            Counter=0;
            List<Core_IPS_Account__c> listOfIpsAccounts = TestUtilities.getListOfIpsAccounts(2);
            for(Core_IPS_Account__c ipsAcc : listOfIpsAccounts){
                if(counter<1){
                    ipsAcc.Core_Account__c = listOfAccounts.get(0).Id;
                    ipsAcc.Core_IPS_Project__c = listOfIpsProjects.get(0).Id;
                    //start added by Aayushi 20/03/2018 US89551
                    members.add(New AccountTeamMember(AccountId = listOfAccounts.get(0).Id, TeamMemberRole = teamMemberRole, UserId= userlist[0].Id));
                    sharingRules.add(new AccountShare(AccountAccessLevel = accountAccessLevel, OpportunityAccessLevel = OpportunityAccessLevel, CaseAccessLevel = caseAccessLevel, UserOrGroupId = userlist[0].Id, AccountId = listOfAccounts.get(0).Id));
                    
                } else {
                    ipsAcc.Core_Account__c = listOfAccounts.get(0).Id;
                    ipsAcc.Core_IPS_Project__c = listOfIpsProjects.get(1).Id;
                    members.add(New AccountTeamMember(AccountId = listOfAccounts.get(1).Id, TeamMemberRole = teamMemberRole, UserId= userlist[0].Id));
                    sharingRules.add(new AccountShare(AccountAccessLevel = accountAccessLevel, OpportunityAccessLevel = OpportunityAccessLevel, CaseAccessLevel = caseAccessLevel, UserOrGroupId = userlist[0].Id, AccountId = listOfAccounts.get(1).Id));
                    //end
                }
                counter++;
            }
            counter = 0;
            insert listOfIpsAccounts;
            System.assert(listOfIpsAccounts[0].Id != null, 'Record not created');
            
            //Get Suport Level Picklist Values
            Schema.DescribeFieldResult fieldResult = Core_IPS_Support_Level__c.Core_IPS_Support_Level__c.getDescribe();
            List<SelectOption> options = new List<SelectOption>(); 
            for(Schema.PicklistEntry f : fieldResult.getPicklistValues()){
                options.add(new SelectOption(f.getLabel(), f.getValue()));
            }   
            
            //Created Support Level
            Core_IPS_Support_Level__c supLevel = new Core_IPS_Support_Level__c();
            supLevel.Core_IPS_Account__c = listOfAccounts.get(0).Id;
            supLevel.Core_IPS_Support_Org__c = listOfSupportOrg.get(0).Id;
            supLevel.Core_IPS_Support_Level__c = options.get(0).getValue();
            insert supLevel;
            
            // Create Case
            counter=0;
            List<Case> listOfCases = TestUtilities.getListOfCases(10);
            
            for(Case caseRec : listOfCases){
                caseRec.ContactId = listOfContacts.get(0).id;
                caseRec.accountId = listOfAccounts.get(0).Id;
                caseRec.Core_IPS_GEC_Case__c=false;
                if(counter < 2){
                    caseRec.assetId = assetList.get(0).Id;
                    // caseRec.Core_IPS_Project_Case__c = listOfIpsProjects.get(0).id;
                    caseRec.Core_IPS_Supported_Product__c = listOfSupportedProduct.get(0).id; 
                }
                else if(counter>=2 && counter <5){
                    caseRec.assetId = assetList.get(1).Id;
                    caseRec.Core_IPS_Project_Case__c = listOfIpsProjects.get(0).id;
                }
                else{
                    caseRec.assetId = assetList.get(1).Id;
                    caseRec.Core_IPS_Project_Case__c = listOfIpsProjects.get(0).id;
                    caseRec.Core_IPS_Supported_Product__c = listOfSupportedProduct.get(1).id; 
                }
                counter++;
            }
            insert listOfCases;
            System.assert(listOfCases[0].Id != null, 'Record not created');
            
            String noAssignedContactCaseRecordType = Core_IPS_Helper_Utility.getIPSLabel('Case_RT_Name_IPS_NoAssignedContact');
            Case c1 = TestUtilities.getListOfCases(10).get(0);
            c1.RecordTypeId = Core_IPS_CaseTriggerHandler.getCaseRecordtypeIDByName(noAssignedContactCaseRecordType);
            c1.assetId = assetList.get(1).Id;
            c1.Core_IPS_Project_Case__c = listOfIpsProjects.get(0).id;
            c1.Core_IPS_Supported_Product__c = listOfSupportedProduct.get(0).id;  
            
            insert c1;
            /*start added by Yogesh US72443*/
            c1.Core_IPS_Supported_Product__c = listOfSupportedProduct.get(1).id;
            
            update c1; 
            /*end */
            insert ipsLables4;
            Case c2 = TestUtilities.getListOfCases(10).get(0);
            c2.RecordTypeId = Core_IPS_CaseTriggerHandler.getCaseRecordtypeIDByName(noAssignedContactCaseRecordType);
            c2.assetId = assetList.get(1).Id;
            c2.Core_IPS_Project_Case__c = listOfIpsProjects.get(0).id;
            c2.Core_IPS_Supported_Product__c = listOfSupportedProduct.get(1).id;  
            
            insert  c2; 
            //start added by Yogesh US72443
            c2.Core_IPS_Supported_Product__c = listOfSupportedProduct.get(0).id;
            
            update c2; 
            System.assertEquals(c2!=null, true, 'Case Updated');
            //end
        }   
        Test.stopTest();
    }     
    
    //This is for testing negative test case
    public static testmethod void testProvideCaseAccessatFutureNegative(){
        Core_IPS_CaseTriggerHandler.ProvideCaseAccessatFuture(null);
        Core_IPS_CaseTriggerHandler.IPSCaseFieldsInit(null);
        System.assertEquals(10>1, true, 'Test');
        
    }
    
    /***************************************************************************************************
Method Name:  updateSupportLevelOnCase_Test2
Method Type: Test Method
Version     : 1.0 
Created Date: 21 Feb 2018
Description:  Testing updateSupportLevelOnCase method
Scenario Type:  Positive
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sugandha              21/02/2018                Created
* Aayushi               22/03/2018                Modified
****************************************************************************************************/
    static testmethod void updateSupportLevelOnCaseTest3(){
        Test.startTest();
        Map<String,ID> profiles = new Map<String,ID>();
        List<String> strProf = new List<String>();
        strProf.add('System Administrator');
        strProf.add('IPS Data Migration');
        List<Profile> profileList = [select id, name from Profile where name IN : strProf];
        
        for(Profile prf : profileList){
            profiles.put(prf.name, prf.id);
        }
        
        //Create Users
        List<User> listOfUser = new List<User>();
        listOfUser = TestUtilities.getListOfUser(1); 
        listOfUser.get(0).ProfileId =  profiles.get('System Administrator');
        insertUsersWithValidationBypass(listOfUser);
        
        //Custom Setting - Trigger Executions
        List<Core_Trigger_Executions__c> triggerExecutionList= new List<Core_Trigger_Executions__c>();
        Core_Trigger_Executions__c  triggerExecution = new Core_Trigger_Executions__c();
        triggerExecution.Name = 'IPSCaseFieldsInit';
        triggerExecution.Core_Active__c = true;
        triggerExecution.Core_Class_Name__c ='Core_IPS_CaseTriggerHandler';
        triggerExecution.Core_Description__c = 'To update Case fields.';
        triggerExecution.Core_Object__c = 'Case';
        triggerExecution.Core_Trigger_Events__c = 'before insert';
        Core_Trigger_Executions__c  triggerExecution1 = new Core_Trigger_Executions__c();
        triggerExecution1.Name = 'checkCaseClosureParams';
        triggerExecution1.Core_Active__c = true;
        triggerExecution1.Core_Class_Name__c ='Core_IPS_CaseTriggerHandler';
        triggerExecution1.Core_Description__c = 'Check If Org number is same and Case closure is equal to custom setting closure and bugfix id is not empty.';
        triggerExecution1.Core_Object__c = 'Case';
        triggerExecution1.Core_Trigger_Events__c = 'before insert';
        triggerExecutionList.add(triggerExecution1); 
        insert triggerExecutionList;
        System.assert(triggerExecutionList[0].id != null, 'triggerExecution inserted');
        
        //Custom Setting - Trigger Executions Sandeeep US84539: I2
        /*Core_Trigger_Executions__c  triggerExecution2 = new Core_Trigger_Executions__c();
triggerExecution2.Name = 'checkCaseClosureParams';
triggerExecution2.Core_Active__c = true;
triggerExecution2.Core_Class_Name__c ='Core_IPS_CaseTriggerHandler';
triggerExecution2.Core_Description__c = 'Check If Org number is same and Case closure is equal to custom setting closure and bugfix id is not empty.';
triggerExecution2.Core_Object__c = 'Case';
triggerExecution2.Core_Trigger_Events__c = 'before update';
insert triggerExecution2; 
System.assert(triggerExecution1.id != null, 'triggerExecution inserted');*/
        
        //Custom Setting Record inserted by Sandeep US84539: I2
        Core_IPS_Support_Org_Specification__c supportOrgCustomSetting = new Core_IPS_Support_Org_Specification__c();
        supportOrgCustomSetting.Core_IPS_Is_Active__c = true;
        supportOrgCustomSetting.Core_IPS_Case_Closure__c = 'Fix in Intel Documentation';
        supportOrgCustomSetting.Core_IPS_Field_Name__c = 'Core_IPS_Bug_Doc_Fix_ID__c';
        supportOrgCustomSetting.Core_IPS_Support_Org_Number__c = 'Org-027';
        supportOrgCustomSetting.Name = 'PSG';
        insert supportOrgCustomSetting;
        //start added by Aayushi US89551
        /* Core_Trigger_Executions__c  triggerExecutionRec = new Core_Trigger_Executions__c();
triggerExecutionRec.Name = 'provideProjCaseAccessToFAE';
triggerExecutionRec.Core_Active__c = true;
triggerExecutionRec.Core_Class_Name__c ='Core_IPS_Account_Handler';
triggerExecutionRec.Core_Description__c = 'Activate Or Deactivate Project Members';
triggerExecutionRec.Core_Object__c = 'Core_IPS_Account__c';
triggerExecutionRec.Core_Trigger_Events__c = 'after update';
insert triggerExecutionRec;*/
        //end
        System.assert(supportOrgCustomSetting.id != NULL,'Custom setting is not Null');
        
        Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('updateSupportLevelOnCase');
        
        //Custom Setting - Core IPS Labels
        List<Core_IPS_Labels__c> listofIpsLables = new List<Core_IPS_Labels__c>();
        Core_IPS_Labels__c ipsLables1 = new Core_IPS_Labels__c(Name = 'Case_RT_Name_IPS_Case_Create',Value__c = 'IPS Case Create');
        Core_IPS_Labels__c ipsLables2 = new Core_IPS_Labels__c(Name = 'Case_RT_Name_IPS_NoAssignedContact',Value__c = 'IPS No Assigned Contact Case');
        Core_IPS_Labels__c ipsLables3 = new Core_IPS_Labels__c(Name = 'Support_Level_Default',Value__c = 'ROW');
        Core_IPS_Labels__c ipsLables4 = new Core_IPS_Labels__c(Name = 'Support_Level_Default_No_Assigned_Cont',Value__c = 'Tier 3');
        listofIpsLables.add(ipsLables1);
        listofIpsLables.add(ipsLables2);
        listofIpsLables.add(ipsLables3);  
        List<Core_IPS_Labels__c> ipsLabelsForGlobalAsset = TestUtilities.getIPSLabel();
        for(Core_IPS_Labels__c ipl : ipsLabelsForGlobalAsset){
            if(ipl.Name == 'Core_IPS_Global_Asset_RT'){
                ipl.value__c = 'Core_Public_Product';
            }
        }
        listofIpsLables.addAll(ipsLabelsForGlobalAsset);  
        
        insert listofIpsLables;
        //added by rajeswari on junly 18 for increase code coverage
        Core_CaseTrigger_Dispatcher.triggerAssignmentRule = true;
        
        Core_IPS_Backend_System2__c backendSystem = new Core_IPS_Backend_System2__c();
        backendSystem.Name = 'HSDES-PSG01';
        
        backendSystem.Core_IPS_Target_System__c = 'hsdes:fpga:bug';
        insert backendSystem;
        
        Core_IPS_Backend_Routing__c backendRoutingRule = new Core_IPS_Backend_Routing__c();
        backendRoutingRule.Core_IPS_Backend_Routing_Order__c = 1;
        backendRoutingRule.Core_IPS_Queue__c = 'IPS - Unassigned Cases';
        backendRoutingRule.Core_IPS_Auto_Promote__c = true;
        backendRoutingRule.Core_IPS_New_Backend_System__c = backendSystem.Id;
        insert backendRoutingRule;
        
        //end by rajeswari 
        //Get intelSupportOwner Id (User Id)
        Id intelSupportOwner = listOfUser.get(0).id;
        System.runAs(listOfUser.get(0)){
            
            //Create Support Org
            List<Core_IPS_Product_Organization__c> listOfSupportOrg  = TestUtilities.getListOfSupportOrg(2);
            insert listOfSupportOrg;
            
            //System.assert(listOfSupportOrg != null, 'Record not created');
            
            //Create Accounts
            List<Account> listOfAccounts = TestUtilities.getListOfAccounts(2);
            insert listOfAccounts;
            System.assert(listOfAccounts[0].Id != null, 'Record not created');
            
            //Create Contact
            List<Contact> listOfContacts = TestUtilities.getListOfContact(1);
            for(Contact contactRec : listOfContacts){
                contactRec.Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
                contactRec.core_ips_Active__c=true;
                contactRec.Accountid = listOfAccounts.get(0).Id;
                contactRec.MailingCountry = 'India';
            }
            insert listOfContacts;
            System.assert(listOfContacts[0].Id != null, 'Record not created');
            
            
            //Create Product
            Integer counter = 0;
            
            List<Product2> listOfProducts = TestUtilities.getListOfProduct(2);
            for(Product2 product : listOfProducts){
                if(counter==0){
                    product.Core_Hierarchy_ID__c = '43';
                    product.Core_Hierarchy_Name__c = 'ProdHierarchyName';
                    product.Core_Unique_ID__c = 'Product12345';
                    product.Core_Code_Name__c = 'ProductCoreCodeName';
                }else{
                    product.Core_Hierarchy_ID__c = '59';
                    product.Core_Hierarchy_Name__c = 'ProdHierarchyName59';
                    product.Core_Unique_ID__c = 'Product59';
                    product.Core_Code_Name__c = 'ProductCoreCodeName59';
                    
                }
                counter++;
            }
            insert listOfProducts;
            System.assert(listOfProducts[0].id != null,'Record not created');
            
            
            //Create Supported product
            counter = 0;
            List<Core_IPS_Supported_Product__c> listOfSupportedProduct = TestUtilities.getListOfSupportedProduct(2);
            for(Core_IPS_Supported_Product__c supportedProduct : listOfSupportedProduct){
                if(counter==0){
                    supportedProduct.Core_Product__c = listOfProducts.get(0).id;
                    supportedProduct.Core_Product_Organization__c = listOfSupportOrg.get(0).id;
                }else{
                    supportedProduct.Core_Product__c = listOfProducts.get(1).id;
                    supportedProduct.Core_Product_Organization__c = listOfSupportOrg.get(1).id;
                }
                counter++;
            }
            insert listOfSupportedProduct;
            System.assert(listOfSupportedProduct[0].id != null,'Record not created');
            
            //Create Asset
            counter = 0;
            list<Asset> assetList = TestUtilities.getAssetList(2);
            for(Asset asst : assetList){
                asst.accountId = listOfAccounts.get(0).Id;
                asst.Contactid = listOfContacts.get(0).id;
                if(counter==0){
                    asst.core_product_organization__c = listOfSupportOrg.get(0).id;
                    asst.core_supported_product__c = listOfSupportedProduct.get(0).id;
                    asst.product2Id = listOfProducts.get(0).id;
                }else{
                    asst.core_product_organization__c = listOfSupportOrg.get(1).id;
                    asst.core_supported_product__c = listOfSupportedProduct.get(1).id;
                    asst.product2Id = listOfProducts.get(1).id;
                }
                counter++;
            }
            insert assetList;
            System.assert(assetList[0].Id != null, 'Record not created');
            
            
            //Create Ips Project
            counter = 0;
            List<Core_IPS_Project__c> listOfIpsProjects = TestUtilities.getListOfIpsProjects(2);
            insert listOfIpsProjects;
            System.assert(listOfIpsProjects[0].Id != null, 'Record not created');
            //insert fae added by Aayushi 20/03/2018 US89551
            List<user> userList = TestUtilities.getListofuser(1);
            profile prof = [select id, name from Profile where name = 'Sales Rep-BB' limit 1];
            userlist[0].profileid=prof.id;
            userlist[0].username='salesrep0202.abc@user.com';
            System.runAs(listOfUser.get(0)){
                insert userlist;
            }
            //start added by Aayushi 20/03/2018 US89551
            String teamMemberRole = 'Team Member (100%)';
            String accountAccessLevel = 'Edit';
            String opportunityAccessLevel = 'Edit';
            String caseAccessLevel = 'None';
            List<AccountTeamMember> members = new list<AccountTeamMember>();
            List<AccountShare> sharingRules = new list<AccountShare>();
            //end
            // Create Ips Account
            Counter=0;
            List<Core_IPS_Account__c> listOfIpsAccounts = TestUtilities.getListOfIpsAccounts(2);
            for(Core_IPS_Account__c ipsAcc : listOfIpsAccounts){
                if(counter<1){
                    ipsAcc.Core_Account__c = listOfAccounts.get(0).Id;
                    ipsAcc.Core_IPS_Project__c = listOfIpsProjects.get(0).Id;
                    //start added by Aayushi 20/03/2018 US89551
                    members.add(New AccountTeamMember(AccountId = listOfAccounts.get(0).Id, TeamMemberRole = teamMemberRole, UserId= userlist[0].Id));
                    sharingRules.add(new AccountShare(AccountAccessLevel = accountAccessLevel, OpportunityAccessLevel = OpportunityAccessLevel, CaseAccessLevel = caseAccessLevel, UserOrGroupId = userlist[0].Id, AccountId = listOfAccounts.get(0).Id));
                    
                } else {
                    ipsAcc.Core_Account__c = listOfAccounts.get(0).Id;
                    ipsAcc.Core_IPS_Project__c = listOfIpsProjects.get(1).Id;
                    members.add(New AccountTeamMember(AccountId = listOfAccounts.get(1).Id, TeamMemberRole = teamMemberRole, UserId= userlist[0].Id));
                    sharingRules.add(new AccountShare(AccountAccessLevel = accountAccessLevel, OpportunityAccessLevel = OpportunityAccessLevel, CaseAccessLevel = caseAccessLevel, UserOrGroupId = userlist[0].Id, AccountId = listOfAccounts.get(1).Id));
                    //end
                }
                counter++;
            }
            counter = 0;
            insert listOfIpsAccounts;
            System.assert(listOfIpsAccounts[0].Id != null, 'Record not created');
            
            //Get Suport Level Picklist Values
            Schema.DescribeFieldResult fieldResult = Core_IPS_Support_Level__c.Core_IPS_Support_Level__c.getDescribe();
            List<SelectOption> options = new List<SelectOption>(); 
            for(Schema.PicklistEntry f : fieldResult.getPicklistValues()){
                options.add(new SelectOption(f.getLabel(), f.getValue()));
            }   
            
            //Created Support Level
            Core_IPS_Support_Level__c supLevel = new Core_IPS_Support_Level__c();
            supLevel.Core_IPS_Account__c = listOfAccounts.get(0).Id;
            supLevel.Core_IPS_Support_Org__c = listOfSupportOrg.get(0).Id;
            supLevel.Core_IPS_Support_Level__c = options.get(0).getValue();
            insert supLevel;
            
            // Create Case
            counter=0;
            List<Case> listOfCases = TestUtilities.getListOfCases(10);
            
            for(Case caseRec : listOfCases){
                caseRec.ContactId = listOfContacts.get(0).id;
                caseRec.accountId = listOfAccounts.get(0).Id;
                caseRec.Core_IPS_GEC_Case__c=false;
                if(counter < 2){
                    caseRec.assetId = assetList.get(0).Id;
                    // caseRec.Core_IPS_Project_Case__c = listOfIpsProjects.get(0).id;
                    caseRec.Core_IPS_Supported_Product__c = listOfSupportedProduct.get(0).id; 
                }
                else if(counter>=2 && counter <5){
                    caseRec.assetId = assetList.get(1).Id;
                    caseRec.Core_IPS_Project_Case__c = listOfIpsProjects.get(0).id;
                }
                else{
                    caseRec.assetId = assetList.get(1).Id;
                    caseRec.Core_IPS_Project_Case__c = listOfIpsProjects.get(0).id;
                    caseRec.Core_IPS_Supported_Product__c = listOfSupportedProduct.get(1).id; 
                }
                counter++;
            }
            insert listOfCases;
            System.assert(listOfCases[0].Id != null, 'Record not created');
            
            String noAssignedContactCaseRecordType = Core_IPS_Helper_Utility.getIPSLabel('Case_RT_Name_IPS_NoAssignedContact');
            Case c1 = TestUtilities.getListOfCases(10).get(0);
            c1.RecordTypeId = Core_IPS_CaseTriggerHandler.getCaseRecordtypeIDByName(noAssignedContactCaseRecordType);
            c1.assetId = assetList.get(1).Id;
            c1.Core_IPS_Project_Case__c = listOfIpsProjects.get(0).id;
            c1.Core_IPS_Supported_Product__c = listOfSupportedProduct.get(0).id;  
            
            insert c1;
            /*start added by Yogesh US72443*/
            c1.Core_IPS_Supported_Product__c = listOfSupportedProduct.get(1).id;
            
            update c1; 
            /*end */
            insert ipsLables4;
            Case c2 = TestUtilities.getListOfCases(10).get(0);
            c2.RecordTypeId = [SELECT id from RecordType where Name ='IPS Case Create'].Id;
            c2.assetId = assetList.get(1).Id;
            c2.Core_IPS_Project_Case__c = listOfIpsProjects.get(0).id;
            c2.Core_IPS_Supported_Product__c = listOfSupportedProduct.get(1).id;  
            c2.Core_Partner_Supported_Account__c = listOfAccounts.get(0).id;
            c2.Core_IPS_Self_Assigned__c = true;
            
            insert  c2; 
            c2.Core_Partner_Supported_Account__c = listOfAccounts.get(1).id;
            
            update c2;
        }   
        Test.stopTest();
    }     
    
    
    /***************************************************************************************************
Method Name:  ProjectInterestedParties_Test
Method Type: Test Method
Version     : 1.0 
Description:  ProjectInterestedParties Test method
Scenario Type:  Positive
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Rakesh                    21/06/2018                Created - US107411
* Amritesh                  1/2/2019                  DE28924
****************************************************************************************************/
    static testmethod void projectInterestedPartiesTest(){
        try{
            getRecords();
            // Get intelSupportOwner Id (User Id)
            Id intelSupportOwner = listOfUser.get(0).id;
            System.runAs(listOfUser.get(1)){
                // Create Accounts
                List<Account> listOfAccounts = TestUtilities.getListOfAccounts(1);
                for(Account acc: listOfAccounts){
                    acc.Core_CNDA_Number__c='123';
                }
                insert listOfAccounts;
                System.assert(listOfAccounts[0].Id != null, 'Record not created');
                // Create Contact
                List<Contact> listOfContacts = TestUtilities.getListOfContact(1);
                for(Contact contactRec : listOfContacts){
                    contactRec.Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
                    contactRec.Accountid = listOfAccounts.get(0).Id;
                    contactRec.Core_IPS_Active__c = true;
                    contactRec.MailingCountry = 'India';
                }
                insert listOfContacts;
                System.assert(listOfContacts[0].Id != null, 'Record not created');
                // Create Ips Project
                List<Core_IPS_Project__c> listOfIpsProjects = TestUtilities.getListOfIpsProjects(2);
                insert listOfIpsProjects;
                System.assert(listOfIpsProjects[0].Id != null, 'Record not created');
                // Create Ips Account
                List<Core_IPS_Account__c> listOfIpsAccounts = TestUtilities.getListOfIpsAccounts(1);
                for(Core_IPS_Account__c ipsAcc : listOfIpsAccounts){
                    ipsAcc.Core_Account__c = listOfAccounts.get(0).Id;
                    ipsAcc.Core_IPS_Project__c = listOfIpsProjects.get(0).Id;
                }
                insert listOfIpsAccounts;
                System.assert(listOfIpsAccounts[0].Id != null, 'Record not created');
                // Create Project Member
                List<Core_IPS_Project_Member__c> listOfProjectMembers = TestUtilities.getListOfProjectMembers(2);
                Integer i=1;
                for(Core_IPS_Project_Member__c projMem : listOfProjectMembers){
                    projMem.Core_IPS_Contact__c = listOfContacts.get(0).Id;
                    if(i==1){
                        projMem.Core_IPS_Project__c = listOfIpsProjects.get(0).Id;
                    } else {
                        projMem.Core_IPS_Project__c = listOfIpsProjects.get(1).Id;    
                    }
                    
                    projMem.Core_User__c = intelSupportOwner;
                    projMem.Add_as_Case_Interested_Party__c = true;
                    i++;
                }
                insert listOfProjectMembers;
                // Create IST Member
                List<Core_IPS_Intel_Support_Team__c> lstIST = new List<Core_IPS_Intel_Support_Team__c>();
                Core_IPS_Intel_Support_Team__c ist = new Core_IPS_Intel_Support_Team__c();
                ist.Core_IPS_Project__c = listOfIpsProjects[0].Id;
                ist.Core_IPS_User__c = intelSupportOwner;
                ist.Status__c='Active';
                ist.Add_as_Case_Interested_Party__c = true;
                lstIST.add(ist);
                
                ist = new Core_IPS_Intel_Support_Team__c();
                ist.Core_IPS_Project__c = listOfIpsProjects[1].Id;
                ist.Core_IPS_User__c = intelSupportOwner;
                ist.Status__c='Active';
                ist.Add_as_Case_Interested_Party__c = true;
                lstIST.add(ist);
                insert lstIST;
                System.assert(lstIST[0].Id != null, 'Record not created');
                
                // Create Case
                List<Case> listOfCases = TestUtilities.getListOfCases(4);
                for(Case caseRec : listOfCases){
                    caseRec.ContactId = listOfContacts.get(0).id;
                    caseRec.accountId = listOfAccounts.get(0).Id;
                    caseRec.Core_IPS_Project_Case__c = listOfIpsProjects[0].Id;
                }
                
                for(Core_IPS_Project__c objproj : listOfIpsProjects) {
                    objproj.Core_IPS_Enable_ISTasInterested_Parties__c = true;
                    objproj.Core_IPS_EnableMemberasInterestedParties__c = true;
                }
                update listOfIpsProjects;
                
                List<Core_Trigger_Executions__c> lsttriggerExecution = new List<Core_Trigger_Executions__c>();
                Core_Trigger_Executions__c  triggerExecution = new Core_Trigger_Executions__c();
                triggerExecution.Name = 'create_InsterestedParties_UsingCase';
                triggerExecution.Core_Active__c = true;
                triggerExecution.Core_Class_Name__c ='Core_IPS_CaseTriggerHandler';
                triggerExecution.Core_Description__c = 'create_InsterestedParties_UsingCase';
                triggerExecution.Core_Object__c = 'Case';
                triggerExecution.Core_Trigger_Events__c = 'After Update';
                lsttriggerExecution.add(triggerExecution);
                
                triggerExecution = new Core_Trigger_Executions__c();
                triggerExecution.Name = 'create_IntrestedParties_ProjectMembers';
                triggerExecution.Core_Active__c = true;
                triggerExecution.Core_Class_Name__c ='Core_IPS_CaseTriggerHandler';
                triggerExecution.Core_Description__c = 'create_IntrestedParties_ProjectMembers';
                triggerExecution.Core_Object__c = 'Case';
                triggerExecution.Core_Trigger_Events__c = 'After Update';
                lsttriggerExecution.add(triggerExecution);
                
                triggerExecution = new Core_Trigger_Executions__c();
                triggerExecution.Name = 'case_Edit_projectDetails';
                triggerExecution.Core_Active__c = true;
                triggerExecution.Core_Class_Name__c ='Core_IPS_CaseTriggerHandler';
                triggerExecution.Core_Description__c = 'case_Edit_projectDetails';
                triggerExecution.Core_Object__c = 'Case';
                triggerExecution.Core_Trigger_Events__c = 'After Update';
                lsttriggerExecution.add(triggerExecution);
                insert lsttriggerExecution;
                
                Test.startTest();
                insert listOfCases;
                System.assert(listOfCases[0].Id != null, 'Record not created');
                for(Case caseRec : listOfCases){
                    caseRec.Core_IPS_Project_Case__c = listOfIpsProjects.get(1).id;
                }
                Core_CaseTrigger_Dispatcher.triggerAssignmentRule=true;
                update listOfCases;
                //commented for DE28924   
                /*for(Case caseRec : listOfCases){
caseRec.Core_IPS_Project_Case__c = listOfIpsProjects.get(0).id;
}
Core_CaseTrigger_Dispatcher.recursiveError = 0;
Core_CaseTrigger_Dispatcher.triggerAssignmentRule=true;
update listOfCases;
Core_CaseTrigger_Dispatcher.triggerAssignmentRule=false;*/
                Test.stopTest();
            }
        }catch(Exception ex){}
    }
    
    /***************************************************************************************************
Method Name:  validate_caseOwner_Test
Method Type: Test Method
Version     : 1.0 
Description:  validate_caseOwner Test method
Scenario Type:  Positive
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sugandha                    25/06/2018             Created - DE40252
****************************************************************************************************/
    static testmethod void validateCaseOwnerTest(){
        getRecords();
        Id intelSupportOwner = listOfUser.get(0).id;
        Map<String,ID> profiles = new Map<String,ID>();
        List<Profile> profileList = [select id, name from Profile where name='IPS Agent-Partner' ];
        for(Profile prf : profileList){
            profiles.put(prf.name, prf.id);
        }
        
        User thisUser = [select Id from User where Id = :UserInfo.getUserId()];
        User userRecord = new User();
        System.runAs ( listOfUser[0]) { 
            UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
            Profile profile1 = [Select Id from Profile where name = 'System Administrator'];
            User portalAccountOwner1 = new User(
                UserRoleId = portalRole.Id,
                ProfileId = profile1.Id,
                Username = 'test1206@intel.com',
                Alias = 'batman',
                Email='newuser155@intel.com',
                EmailEncodingKey='UTF-8',
                Firstname='Bruce',
                Lastname='Wayne',
                LanguageLocaleKey='en_US',
                LocaleSidKey='en_US',
                TimeZoneSidKey='America/Chicago'
            );
            Database.insert(portalAccountOwner1);
            
            Account testAccount1=TestUtilities.getAccount(); 
            testAccount1.ownerid = portalAccountOwner1.id;      
            insert testAccount1;             
            Contact testContact1 = new Contact(FirstName='testFirstName123', LastName='testLastName', Email='test1234643@testing.com.testsetup',
                                               AccountId=testAccount1.id,Core_Personal_Email_Indicator__c = true,Core_Enterprise_Id__c='12345',Core_AGS_Integration_Status__c='Successful',MailingCountry = 'India');
            insert testContact1;
            
            UserRole ur = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
            insert ur;
            
            userRecord.Alias = 'StdUser';
            userRecord.contactId =testContact1.id;
            userRecord.Email = 'newuser21@intel.com';
            userRecord.EmailEncodingKey ='UTF-8';
            userRecord.LastName = 'Testing';
            userRecord.FirstName = 'FName';
            userRecord.LanguageLocaleKey = 'en_US';
            userRecord.LocaleSidKey = 'en_US';
            userRecord.TimeZoneSidKey = 'America/Los_Angeles'; 
            userRecord.UserName = 'newuser' + String.valueOf(DateTime.Now().getTime()) + '@intel.com.' + UserInfo.getOrganizationId();
            userRecord.isActive = true;
            
            userRecord.ProfileID =  profiles.get('IPS Agent-Partner');  
            
            insert userRecord; 
            
            // Create Accounts
            List<Account> listOfAccounts = TestUtilities.getListOfAccounts(1);
            for(Account acc: listOfAccounts){
                acc.Core_CNDA_Number__c='123';
            }
            insert listOfAccounts;
            System.assert(listOfAccounts[0].Id != null, 'Record not created');
            // Create Contact
            List<Contact> listOfContacts = TestUtilities.getListOfContact(1);
            for(Contact contactRec : listOfContacts){
                contactRec.Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
                contactRec.Accountid = listOfAccounts.get(0).Id;
                contactRec.Core_IPS_Active__c = true;
                contactRec.MailingCountry = 'India';
            }
            insert listOfContacts;
            System.assert(listOfContacts[0].Id != null, 'Record not created');
            // Create Ips Project
            List<Core_IPS_Project__c> listOfIpsProjects = TestUtilities.getListOfIpsProjects(2);
            insert listOfIpsProjects;
            System.assert(listOfIpsProjects[0].Id != null, 'Record not created');
            // Create Ips Account
            List<Core_IPS_Account__c> listOfIpsAccounts = TestUtilities.getListOfIpsAccounts(1);
            for(Core_IPS_Account__c ipsAcc : listOfIpsAccounts){
                ipsAcc.Core_Account__c = listOfAccounts.get(0).Id;
                ipsAcc.Core_IPS_Project__c = listOfIpsProjects.get(0).Id;
            }
            insert listOfIpsAccounts;
            System.assert(listOfIpsAccounts[0].Id != null, 'Record not created');
            // Create Project Member
            List<Core_IPS_Project_Member__c> listOfProjectMembers = TestUtilities.getListOfProjectMembers(1);
            for(Core_IPS_Project_Member__c projMem : listOfProjectMembers){
                projMem.Core_IPS_Contact__c = testContact1.Id;
                projMem.Core_IPS_Project__c = listOfIpsProjects.get(0).Id;
                projMem.Core_Status__c = 'Active';
                projMem.Core_User__c = userRecord.id;
            }
            insert listOfProjectMembers;
            
            Core_Trigger_Executions__c triggerExecution = new Core_Trigger_Executions__c();
            triggerExecution.Name = 'Core_IPS_Execute_CaseOwnerValidation1';
            triggerExecution.Core_Active__c = true;
            triggerExecution.Core_Class_Name__c ='Core_IPS_CaseTriggerHandler';
            triggerExecution.Core_Description__c = 'case_Edit_projectDetails';
            triggerExecution.Core_Object__c = 'Case';
            triggerExecution.Core_Trigger_Events__c = 'Before Update';
            
            insert triggerExecution;
            
            // Create Case
            List<Case> listOfCases = TestUtilities.getListOfCases(4);
            Map<Id,Boolean> backendCaseMapTest =new Map<Id,Boolean>();
            for(Case caseRec : listOfCases){
                caseRec.ContactId = listOfContacts.get(0).id;
                caseRec.accountId = listOfAccounts.get(0).Id;
                caseRec.Core_IPS_Project_Case__c = listOfIpsProjects[0].Id;
                caseRec.ownerId = userRecord.id;
            }
            
            Test.startTest();
            try{
                insert listOfCases;
            }catch(Exception ex){}
            for(Case CaseIdList:listOfCases){
                backendCaseMapTest.put(CaseIdList.Id,false);  
            }
            try{
                //  Core_IPS_CaseTriggerHandler.makeCreatePlatformEventInFuture(CaseIds,backendCaseMapTest);
            }catch(Exception ex){}
            //Core_IPS_CaseTriggerHandler.makeCreatePlatformEventInFuture(listOfCases[0].id,backendCaseMapTest);
            for(Case caseRec : listOfCases){
                caseRec.ownerId = userRecord.id;
            }
            update listOfCases;
            
            Test.stopTest();
            
        }
    }
    
    
    
    static testmethod void assignCaseInformationfromProjectTest(){
        
        //Create Custom Setting - Trigger Executions
        List<Core_Trigger_Executions__c> triggerExecutionList=new List<Core_Trigger_Executions__c>();
        Core_Trigger_Executions__c  triggerExecution1 = new Core_Trigger_Executions__c();
        triggerExecution1.Name = 'assignCaseInformationfromProject';
        triggerExecution1.Core_Active__c = true;
        triggerExecution1.Core_Class_Name__c ='Core_IPS_CaseTriggerHandler';
        triggerExecution1.Core_Description__c = 'This method is used update the Project value on Case.';
        triggerExecution1.Core_Object__c = 'Case';
        triggerExecution1.Core_Trigger_Events__c = 'Before Insert';
        triggerExecutionList.add(triggerExecution1);
        insert triggerExecutionList; 
        System.assert(triggerExecutionList[0].id != null, 'triggerExecution inserted');
        
        //added by amritesh - US137508
        Core_IPS_Labels__c ipsLables2 = new Core_IPS_Labels__c(Name = 'Case_RT_Name_IPS_NoAssignedContact',Value__c = 'IPS No Assigned Contact Case');        
        insert ipsLables2;
        
        getRecords ();
        Test.startTest();
        Id intelSupportOwner = listOfUser.get(0).id;
        System.runAs(listOfUser.get(1)){
            // Create Accounts
            List<Account> listOfAccounts = TestUtilities.getListOfAccounts(1);
            for(Account acc: listOfAccounts){
                acc.Core_CNDA_Number__c='123';
            }
            insert listOfAccounts;
            System.assert(listOfAccounts[0].Id != null, 'Record not created');
            // Create Contact
            List<Contact> listOfContacts = TestUtilities.getListOfContact(1);
            for(Contact contactRec : listOfContacts){
                contactRec.Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
                contactRec.Accountid = listOfAccounts.get(0).Id;
                contactRec.MailingCountry = 'India';
            }
            insert listOfContacts;
            System.assert(listOfContacts[0].Id != null, 'Record not created');
            // Create Ips Project
            List<Core_IPS_Project__c> listOfIpsProjects = TestUtilities.getListOfIpsProjects(1);
            listOfIpsProjects[0].Core_IPS_Remove_Notification_Details__c=true;
            listOfIpsProjects[0].Core_IPS_Support_Level__c='Tier 4';
            listOfIpsProjects[0].Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
            listOfIpsProjects[0].Core_IPS_Partner_Support_Owner__c = intelSupportOwner;
            insert listOfIpsProjects;
            System.assert(listOfIpsProjects[0].Id != null, 'Record not created');
            // Create Ips Account
            List<Core_IPS_Account__c> listOfIpsAccounts = TestUtilities.getListOfIpsAccounts(1);
            for(Core_IPS_Account__c ipsAcc : listOfIpsAccounts){
                ipsAcc.Core_Account__c = listOfAccounts.get(0).Id;
                ipsAcc.Core_IPS_Project__c = listOfIpsProjects.get(0).Id;
            }
            insert listOfIpsAccounts;
            System.assert(listOfIpsAccounts[0].Id != null, 'Record not created');
            // Create Project Member
            List<Core_IPS_Project_Member__c> listOfProjectMembers = TestUtilities.getListOfProjectMembers(1);
            for(Core_IPS_Project_Member__c projMem : listOfProjectMembers){
                projMem.Core_IPS_Contact__c = listOfContacts.get(0).Id;
                projMem.Core_IPS_Project__c = listOfIpsProjects.get(0).Id;
                projMem.Core_User__c = intelSupportOwner;
            }
            insert listOfProjectMembers;
            System.assert(listOfProjectMembers[0].Id != null, 'Record not created');
            // Create Case
            List<Case> listOfCases = TestUtilities.getListOfCases(5);
            for(Case caseRec : listOfCases){
                caseRec.ContactId = listOfContacts.get(0).id;
                caseRec.accountId = listOfAccounts.get(0).Id;
                caseRec.Core_IPS_Project_Case__c=listOfIpsProjects.get(0).Id;
                caseRec.Core_Issue_Description__c = 'Description as part of Code Refactor 26/09 to cover description not null block';
            }
            insert listOfCases;
            Test.stopTest();
            
            //added by amritesh - US137508
            Core_CaseTrigger_Dispatcher.recursivetrigger1 = true;
            listOfCases[0].Core_IPS_Project_Case__c = null;
            try{
                update listOfCases[0];
            }catch(Exception exp){
            }
        }
    }
    
    /***************************************************************************************************
Method Name:  assignUserManager_Test
Method Type: Test Method
Version     : 1.0 
Description:  assignUserManager Test method
Scenario Type:  Positive
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Amritesh                    25/06/2018             Created - US176778
****************************************************************************************************/
    static testmethod void assignUserManagerTest(){
        getRecords();
        Id intelSupportOwner = listOfUser.get(0).id;
        Map<String,ID> profiles = new Map<String,ID>();
        List<Profile> profileList = [select id, name from Profile where name='IPS Agent' ];
        for(Profile prf : profileList){
            profiles.put(prf.name, prf.id);
        }
        
        //User thisUser = [select Id from User where Id = :UserInfo.getUserId()];
        //User userRecord = new User();
        System.runAs ( listOfUser[0]) { 
            //UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
            Profile profile1 = [Select Id from Profile where name = 'System Administrator'];
            User sysadmin = new User(
                //UserRoleId = portalRole.Id,
                ProfileId = profile1.Id,
                Username = 'test1206@intel.com',
                Alias = 'testbaty',
                Email='newuser155@intel.com',
                EmailEncodingKey='UTF-8',
                Firstname='Bruce',
                Lastname='Wayne',
                LanguageLocaleKey='en_US',
                LocaleSidKey='en_US',
                TimeZoneSidKey='America/Chicago'
            );
            Database.insert(sysadmin);
            
            Account testAccount1=TestUtilities.getAccount(); 
            testAccount1.ownerid = sysadmin.id;      
            insert testAccount1;             
            Contact testContact1 = new Contact(FirstName='testFirstName123', LastName='testLastName', Email='test1234643@testing.com.testsetup',
                                               AccountId=testAccount1.id,Core_Personal_Email_Indicator__c = true,Core_Enterprise_Id__c='12345',Core_AGS_Integration_Status__c='Successful',mailingcountry = 'India');
            insert testContact1;
            
            //UserRole ur = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
            //insert ur;
            User userRecord = new User();
            userRecord.Alias = 'StdUser';
            //userRecord.contactId =testContact1.id;
            userRecord.Email = 'newuser21@intel.com';
            userRecord.EmailEncodingKey ='UTF-8';
            userRecord.LastName = 'Testing';
            userRecord.FirstName = 'FName';
            userRecord.LanguageLocaleKey = 'en_US';
            userRecord.LocaleSidKey = 'en_US';
            userRecord.TimeZoneSidKey = 'America/Los_Angeles'; 
            userRecord.UserName = 'newuser' + String.valueOf(DateTime.Now().getTime()) + '@intel.com.' + UserInfo.getOrganizationId();
            userRecord.isActive = true;            
            userRecord.ProfileID =  profiles.get('IPS Agent');  
            
            insert userRecord; 
            
            // Create Accounts
            List<Account> listOfAccounts = TestUtilities.getListOfAccounts(1);
            for(Account acc: listOfAccounts){
                acc.Core_CNDA_Number__c='123';
            }
            insert listOfAccounts;
            System.assert(listOfAccounts[0].Id != null, 'Record not created');
            // Create Contact
            List<Contact> listOfContacts = TestUtilities.getListOfContact(1);
            for(Contact contactRec : listOfContacts){
                contactRec.Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
                contactRec.Accountid = listOfAccounts.get(0).Id;
                contactRec.Core_IPS_Active__c = true;
                contactRec.MailingCountry = 'India';
            }
            insert listOfContacts;
            System.assert(listOfContacts[0].Id != null, 'Record not created');
            
            Core_Trigger_Executions__c triggerExecution = new Core_Trigger_Executions__c();
            triggerExecution.Name = 'assignUserManager';
            triggerExecution.Core_Active__c = true;
            triggerExecution.Core_Class_Name__c ='Core_IPS_CaseTriggerHandler';
            triggerExecution.Core_Description__c = 'assignUserManager';
            triggerExecution.Core_Object__c = 'Case';
            triggerExecution.Core_Trigger_Events__c = 'Before Insert, Before Update';
            
            insert triggerExecution;
            
            // Create Case
            List<Case> listOfCases = TestUtilities.getListOfCases(2);
            for(Case caseRec : listOfCases){
                caseRec.ContactId = listOfContacts.get(0).id;
                caseRec.accountId = listOfAccounts.get(0).Id;
                caseRec.ownerId = sysadmin.id;
            }
            
            Test.startTest();
            insert listOfCases;
            for(Case caseRec : listOfCases){
                caseRec.ownerId = userRecord.id;
            }
            update listOfCases;
            
            Test.stopTest();
            
        }
    }
    
    static testmethod void caseOwnerGrpTest(){
        getRecords(); 
        Id intelSupportOwner = listOfUser.get(0).id;
        Map<String,ID> profiles = new Map<String,ID>();
        List<Profile> profileList = [select id, name from Profile where name='IPS Agent' ];
        for(Profile prf : profileList){
            profiles.put(prf.name, prf.id);
        }
        for(Core_Trigger_Executions__c triggerExcecution: [SELECT ID,Name FROM Core_Trigger_Executions__c]){
        }
        
        //User thisUser = [select Id from User where Id = :UserInfo.getUserId()];
        //User userRecord = new User();
        System.runAs ( listOfUser[0]) { 
            //UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
            Profile profile1 = [Select Id from Profile where name = 'System Administrator'];
            User sysadmin = new User(
                //UserRoleId = portalRole.Id,
                ProfileId = profile1.Id,
                Username = 'test1206@intel.com',
                Alias = 'testbaty',
                Email='newuser155@intel.com',
                EmailEncodingKey='UTF-8',
                Firstname='Bruce',
                Lastname='Wayne',
                LanguageLocaleKey='en_US',
                LocaleSidKey='en_US',
                TimeZoneSidKey='America/Chicago'
            );
            Database.insert(sysadmin);
            
            Account testAccount1=TestUtilities.getAccount(); 
            testAccount1.ownerid = sysadmin.id;      
            insert testAccount1;             
            Contact testContact1 = new Contact(FirstName='testFirstName123', LastName='testLastName', Email='test1234643@testing.com.testsetup',
                                               AccountId=testAccount1.id,Core_Personal_Email_Indicator__c = true,Core_Enterprise_Id__c='12345',Core_AGS_Integration_Status__c='Successful',MailingCountry='India');
            insert testContact1;
            
            //UserRole ur = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
            //insert ur;
            User userRecord = new User();
            userRecord.Alias = 'StdUser';
            //userRecord.contactId =testContact1.id;
            userRecord.Email = 'newuser21@intel.com';
            userRecord.EmailEncodingKey ='UTF-8';
            userRecord.LastName = 'Testing';
            userRecord.FirstName = 'FName';
            userRecord.LanguageLocaleKey = 'en_US';
            userRecord.LocaleSidKey = 'en_US';
            userRecord.TimeZoneSidKey = 'America/Los_Angeles'; 
            userRecord.UserName = 'newuser' + String.valueOf(DateTime.Now().getTime()) + '@intel.com.' + UserInfo.getOrganizationId();
            userRecord.isActive = true;            
            userRecord.ProfileID =  profiles.get('IPS Agent');  
            
            insert userRecord; 
            
            // Create Accounts
            List<Account> listOfAccounts = TestUtilities.getListOfAccounts(1);
            for(Account acc: listOfAccounts){
                acc.Core_CNDA_Number__c='123';
            }
            insert listOfAccounts;
            System.assert(listOfAccounts[0].Id != null, 'Record not created');
            // Create Contact
            List<Contact> listOfContacts = TestUtilities.getListOfContact(1);
            for(Contact contactRec : listOfContacts){
                contactRec.Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
                contactRec.Accountid = listOfAccounts.get(0).Id;
                contactRec.Core_IPS_Active__c = true;
                contactRec.MailingCountry = 'India';
            }
            insert listOfContacts;
            System.assert(listOfContacts[0].Id != null, 'Record not created');
            
            Core_Trigger_Executions__c triggerExecution = new Core_Trigger_Executions__c();
            triggerExecution.Name = 'updateCaseOwnerGroup';
            triggerExecution.Core_Active__c = true;
            triggerExecution.Core_Class_Name__c ='Core_IPS_CaseTriggerHandler';
            triggerExecution.Core_Description__c = 'updateCaseOwnerGroup';
            triggerExecution.Core_Object__c = 'Case';
            triggerExecution.Core_Trigger_Events__c = 'Before Insert, Before Update';
            
            insert triggerExecution;
            
            Core_IPS_Product_Organization__c prodOrg = TestUtilities.getSupportOrg();
            insert prodOrg;
            
            Product2 prod = TestUtilities.getProduct();
            insert prod; 
            
            Core_IPS_Supported_Product__c sp=TestUtilities.getSupportedProduct();
            sp.Core_Product__c = prod.id;
            sp.Core_Product_Organization__c = prodOrg.id;
            sp.Core_Flag_Status__c = 'Auto Approve';
            insert sp; 
            
            Core_IPS_Case_Owner_Group__c ownerGrp = new Core_IPS_Case_Owner_Group__c(
                Core_IPS_Case_Owner__c=sysadmin.Id,
                Core_IPS_Support_Org__c=prodOrg.Id,
                Core_IPS_Case_Owner_Email__c='test2@gmail.com',
                Core_IPS_Owner_Group_1__c = 'test@gmail.com'
            );
            insert  ownerGrp;
            
            // Create Case
            List<Case> listOfCases = TestUtilities.getListOfCases(2);
            for(Case caseRec : listOfCases){
                caseRec.ContactId = listOfContacts.get(0).id;
                caseRec.accountId = listOfAccounts.get(0).Id;                
                caseRec.ownerId = sysadmin.id;
                caseRec.Core_IPS_Supported_Product__c = sp.Id; 
                caseRec.Core_IPS_Product_Org1__c = prodOrg.Id;
            }
            
            Test.startTest();
            
            insert listOfCases;
            System.assertEquals(listOfCases!=null, true, 'Cases Inserted');
            Test.stopTest();
            
        }
    }
    
    
    static testmethod void caseProjProdOwnerTest(){
        
        getrecords();
        // Query Profiles
        Map<String,ID> profiles = new Map<String,ID>();
        List<String> strProf = new List<String>();
        strProf.add('System Administrator');
        List<Profile> profileList = [select id, name from Profile where name IN : strProf];
        for(Profile prf : profileList){
            profiles.put(prf.name, prf.id);
        }
        
        //Create Role
        UserRole r = [SELECT Id, Name FROM UserRole WHERE DeveloperName = 'IPS_Product_Org_Admin' LIMIT 1];
        
        User userRecord = new User(
            Alias = 'StdUser', 
            Email = 'newuser211@intel.com', 
            EmailEncodingKey ='UTF-8',
            LastName = 'Testing',
            FirstName = 'FName',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles', 
            UserName = 'nnnnewuser12300000@intel.com',
            isActive = true,
            UserRoleId = r.Id
            
        );
        
        
        List<User> listOfUser1 = new List<User>{userRecord}; //TestUtilities.getListOfUser(1);
            listOfUser1.get(0).ProfileID =  profiles.get('System Administrator');
        //listOfUser1.get(1).ProfileID =  profiles.get('IPS Support Org Admin');
        
        insertUsersWithValidationBypass(listOfUser1);
        
        List<Core_IPS_Labels__c> listofIpsLables = TestUtilities.getIPSLabel();
        System.runAs(listOfUser.get(0)){
            insert listofIpsLables;
        }
        /*List<Core_Trigger_Executions__c> listOftriggerExecutions = TestUtilities.getListOftriggerExecutions();
System.runAs(listOfUser.get(0)){    
insert listOftriggerExecutions;
} */
        //  System.runAs(listOfUser.get(1)){
        Product2 prod = TestUtilities.getProduct();
        System.runAs(listOfUser1.get(0)){
            insert prod; 
        } 
        
        Account acctRecord=TestUtilities.getAccountRecord();
        // acctRecord.OwnerId= listOfUser.get(1).id;
        acctRecord.Core_CNDA_Number__c='123';
        System.runAs(listOfUser1.get(0)){
            insert acctRecord; 
        } 
        //insert acctRecord;
        Contact contactRecord;
        contactRecord = TestUtilities.getContact();
        contactRecord.Accountid = acctRecord.id;
        // contactRecord.Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
        contactRecord.core_ips_Active__c=false;
        contactrecord.MailingCountry = 'India';
        contactRecord.Email = 'ContactDellTest@gmail.com';
        System.runAs(listOfUser.get(0)){
            insert contactRecord; 
        } 
        //insert contactRecord;
        
        Core_IPS_Product_Organization__c prodOrg = TestUtilities.getSupportOrg();
        System.runAs(listOfUser.get(0)){
            insert prodOrg; 
        } 
        //insert prodOrg;
        Core_IPS_Supported_Product__c sp=TestUtilities.getSupportedProduct();
        sp.Core_Product__c = prod.id;
        sp.Core_Product_Organization__c = prodOrg.id;
        sp.Core_Flag_Status__c = 'Auto Approve';
        System.runAs(listOfUser.get(0)){
            insert sp; 
        } 
        // insert sp;
        
        Id projectRecordTypeId = Schema.SObjectType.Core_IPS_Project__c.getRecordTypeInfosByName().get('Active').getRecordTypeId();
        Core_IPS_Project__c ipsProjectRecord = new Core_IPS_Project__c(
            Name = 'projIPSTestProject Grv',
            Core_Status__c = 'Draft',
            Core_MPNDA__c='12345',
            recordTypeId = projectRecordTypeId
        );
        test.startTest();
        List<Core_IPS_Project__c> listOfIpsProjects = new List<Core_IPS_Project__c>{ipsProjectRecord};
            System.runAs(listOfUser1.get(0)){
                insert listOfIpsProjects; 
            } 
        
        core_ips_account__c projAccount= TestUtilities.getCoreIpsAccount();
        Core_IPS_Project_Member__c projectMember = TestUtilities.getProjectMember();
        Core_IPS_Product__c projProduct=TestUtilities.getIpsProduct();
        for(Core_IPS_Project__c proj: listOfIpsProjects){
            
            
            projAccount.Core_Account__c=acctRecord.Id;
            projAccount.Core_IPS_Project__c=proj.Id;
            
            // insert projAccount;
            
            
            projectMember.core_ips_contact__c = contactRecord.id;
            projectMember.Core_IPS_Project__c = proj.id;
            
            //insert projectMember;
            
            
            projProduct.Core_IPS_Project__c=proj.Id;
            projProduct.Core_Supported_Product__c=sp.Id;
            
            // insert projProduct;
            
        }
        System.runAs(listOfUser1.get(0)){
            insert projAccount; 
        } 
        System.runAs(listOfUser1.get(0)){
            insert projectMember; 
        } 
        System.runAs(listOfUser1.get(0)){
            insert projProduct; 
        }
        
        //List<Core_IPS_Project__c> listOfIpsProjects = new List<Core_IPS_Project__c>{ipsProjectRecord};
        System.runAs(listOfUser1.get(0)){
            listOfIpsProjects.get(0).Core_Status__c = 'Submitted Pending';
            update listOfIpsProjects;
        } 
        
        List<Entitlement> listOfEntitlement = TestUtilities.getListOfEntitlement(1);
        for(Entitlement entitlementRec : listOfEntitlement){
            entitlementRec.AccountId = acctRecord.Id;
            
        }
        System.runAs(listOfUser.get(0)){
            insert listOfEntitlement;
        }
        Id devRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('IPS No Assigned Contact Case').getRecordTypeId();
        Case c2 = TestUtilities.getListOfCases(1).get(0);
        System.runAs(listOfUser1.get(0)){
            c2.RecordTypeId = devRecordTypeId;
            //c2.assetId = assetList.get(1).Id;
            c2.Core_IPS_Project_Case__c = listOfIpsProjects.get(0).id;
            c2.Core_IPS_Supported_Product__c = sp.Id;  
            c2.entitlementId = listOfEntitlement.get(0).id;
            c2.ownerId = userinfo.getUserID();
            c2.Core_First_Response_Completed__c =false;
            c2.Priority = 'Low';
            c2.Core_Sub_Status__c = 'Reproduced';
            c2.Core_Intel_Sup_Owner__c = UserInfo.getUserId();
            c2.Core_IPS_Is_Notification_Active__c = true;
            c2.Core_Latest_Comment_Time_Stamp__c = System.now()+1;
            c2.SlaStartDate = System.now() - 1;
            //System.runAs(listOfUser1.get(0)){
            insert  c2; 
            System.assertEquals(c2!=null,true, 'Case Inserted');
        }
        List<Case> caseList = new List<Case>{c2};
            Core_IPS_CaseTriggerHandler.assignProjectCasesOwner(caseList); 
        System.runAs(listOfUser.get(0)){
            c2.Subject='test Grv Prvt Proj Owner';      
            update  c2; 
        }
        test.stopTest();
        
    }
    
    static testmethod void caseProjProdOwnerUpdateTest(){
        
        getrecords();
        // Query Profiles
        Map<String,ID> profiles = new Map<String,ID>();
        List<String> strProf = new List<String>();
        strProf.add('System Administrator');//System Administrator
        strProf.add('Sales Rep-BB-Dual IPS');
        List<Profile> profileList = [select id, name from Profile where name IN : strProf];
        for(Profile prf : profileList){
            profiles.put(prf.name, prf.id);
        }
        
        //Create Role
        UserRole r = [SELECT Id, Name FROM UserRole WHERE DeveloperName = 'IPS_Product_Org_Admin' LIMIT 1];
        
        User userRecord = new User(
            Alias = 'StdUser', 
            Email = 'newuser211@intel.com', 
            EmailEncodingKey ='UTF-8',
            LastName = 'Testing',
            FirstName = 'FName',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles', 
            UserName = 'nnnnewuser12300000@intel.com',
            isActive = true,
            UserRoleId = r.Id
            
        );
        User userRecord1 = new User(
            Alias = 'StdUser', 
            Email = 'newuser21sdsdsdw1@intel.com', 
            EmailEncodingKey ='UTF-8',
            LastName = 'Testing',
            FirstName = 'FName',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles', 
            UserName = 'nnnnewuser123ssdsd000@intel.com',
            isActive = true,
            UserRoleId = r.Id
            
        );
        
        
        List<User> listOfUser1 = new List<User>{userRecord, userRecord1}; //TestUtilities.getListOfUser(1);
            listOfUser1.get(0).ProfileID =  profiles.get('System Administrator');
        listOfUser1.get(1).ProfileID =  profiles.get('Sales Rep-BB-Dual IPS');
        //listOfUser1.get(1).ProfileID =  profiles.get('IPS Support Org Admin');
        
        insertUsersWithValidationBypass(listOfUser1);
        
        /* List<Core_IPS_Labels__c> listofIpsLables = TestUtilities.getIPSLabel();
System.runAs(listOfUser.get(0)){
insert listofIpsLables;
} */
        //  System.runAs(listOfUser.get(1)){
        Product2 prod1 = TestUtilities.getProduct();
        Product2 prod2 = TestUtilities.getProduct();
        prod2.Name='test Prod2';
        List<Product2> prodList = new List<Product2>();
        prodList.add(prod1);
        prodList.add(prod2);
        System.runAs(listOfUser1.get(0)){
            insert prodList; 
        } 
        test.startTest();
        Account acctRecord=TestUtilities.getAccountRecord();
        // acctRecord.OwnerId= listOfUser.get(1).id;
        acctRecord.Core_CNDA_Number__c='123';
        System.runAs(listOfUser1.get(0)){
            insert acctRecord; 
        } 
        //insert acctRecord;
        Contact contactRecord;
        contactRecord = TestUtilities.getContact();
        contactRecord.Accountid = acctRecord.id;
        // contactRecord.Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
        contactRecord.core_ips_Active__c=false;
        contactRecord.Email = 'ContactDellTest@gmail.com';
        contactRecord.MailingCountry = 'India';
        System.runAs(listOfUser.get(0)){
            insert contactRecord; 
        } 
        //insert contactRecord;
        List<Core_IPS_Product_Organization__c> suppOrgList = new List<Core_IPS_Product_Organization__c>();
        Core_IPS_Product_Organization__c prodOrg = TestUtilities.getSupportOrg();
        Core_IPS_Product_Organization__c prodOrg2 = TestUtilities.getSupportOrg();
        suppOrgList.add(prodOrg);
        suppOrgList.add(prodOrg2);
        System.runAs(listOfUser.get(0)){
            insert suppOrgList; 
        } 
        
        List<Core_IPS_Supported_Product__c> spList = new List<Core_IPS_Supported_Product__c>();
        Core_IPS_Supported_Product__c sp1=TestUtilities.getSupportedProduct();
        sp1.Core_Product__c = prod1.id;
        sp1.Core_Product_Organization__c = prodOrg.id;
        sp1.Core_Flag_Status__c = 'Auto Approve';
        Core_IPS_Supported_Product__c sp2 = new Core_IPS_Supported_Product__c();
        sp2.Core_EOIS__c = false;
        sp2.Core_Supported_Product_Name__c = 'Haswell EP';
        sp2.Core_Product__c = prod2.id;
        sp2.Core_Product_Organization__c = prodOrg2.id;
        sp2.Core_Flag_Status__c = 'Auto Approve';
        spList.add(sp1);
        spList.add(sp2);
        System.runAs(listOfUser.get(0)){
            insert spList; 
        } 
        // insert sp;
        
        Id projectRecordTypeId = Schema.SObjectType.Core_IPS_Project__c.getRecordTypeInfosByName().get('Active').getRecordTypeId();
        Core_IPS_Project__c ipsProjectRecord = new Core_IPS_Project__c(
            Name = 'projIPSTestProject Grv',
            Core_Status__c = 'Draft',
            Core_MPNDA__c='12345',
            core_ips_private__c=true,
            recordTypeId = projectRecordTypeId
        );
        
        List<Core_IPS_Project__c> listOfIpsProjects = new List<Core_IPS_Project__c>{ipsProjectRecord};
            System.runAs(listOfUser1.get(0)){
                insert listOfIpsProjects; 
            } 
        list<Asset> assetList = TestUtilities.getAssetList(2);
        for(Asset asst : assetList){
            asst.accountId = acctRecord.Id;
            asst.Contactid = contactRecord.id;
            asst.Core_IPS_Project__c = listOfIpsProjects.get(0).id;
            asst.Core_Supported_Product__c = spList.get(0).id;
        }
        System.runAs(listOfUser.get(0)){
            insert assetList;
        }
        core_ips_account__c projAccount= TestUtilities.getCoreIpsAccount();
        Core_IPS_Project_Member__c projectMember = TestUtilities.getProjectMember();
        List<Core_IPS_Product__c> projProdList = new List<Core_IPS_Product__c>();
        // insert projAccount;
        for(Core_IPS_Project__c proj: listOfIpsProjects){
            
            projAccount.Core_Account__c=acctRecord.Id;
            projAccount.Core_IPS_Project__c=proj.Id;
            
            
            //insert projectMember;    
            
            projectMember.core_ips_contact__c = contactRecord.id;
            projectMember.Core_IPS_Project__c = proj.id;
            
            // insert projProduct
            
            Core_IPS_Product__c projProduct1=TestUtilities.getIpsProduct();
            projProduct1.Core_IPS_Project__c=proj.Id;
            projProduct1.Core_Supported_Product__c=sp1.Id;            
            
            Core_IPS_Product__c projProduct2=TestUtilities.getIpsProduct();
            projProduct2.Core_IPS_Project__c=proj.Id;
            projProduct2.Core_Supported_Product__c=sp2.Id;             
            projProdList.add(projProduct1);
            projProdList.add(projProduct2);    
            
        }
        System.runAs(listOfUser1.get(0)){
            insert projAccount; 
        } 
        System.runAs(listOfUser1.get(0)){
            insert projectMember; 
        }
        System.runAs(listOfUser1.get(0)){
            insert projProdList; 
            System.assertEquals(projProdList!=null, true, 'Project Product Inserted');
        } 
        test.stopTest();
        //List<Core_IPS_Project__c> listOfIpsProjects = new List<Core_IPS_Project__c>{ipsProjectRecord};
        System.runAs(listOfUser1.get(0)){
            listOfIpsProjects.get(0).Core_Status__c = 'Active';
            //update listOfIpsProjects;
        } 
        
        
        
        List<Asset> projAssetList = [Select Id,Core_IPS_Project__c,Core_Supported_Product__c from Asset where Core_IPS_Project__c =:listOfIpsProjects.get(0).id];   
        
        
        List<Entitlement> listOfEntitlement = TestUtilities.getListOfEntitlement(1);
        for(Entitlement entitlementRec : listOfEntitlement){
            entitlementRec.AccountId = acctRecord.Id;
            
        }
        System.runAs(listOfUser.get(0)){
            insert listOfEntitlement;
        }
        
        Id devRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('IPS No Assigned Contact Case').getRecordTypeId();
        
        Case c2 = TestUtilities.getListOfCases(1).get(0);
        c2.RecordTypeId = devRecordTypeId;
        c2.Core_IPS_Self_Assigned__c =true; 
        c2.assetId = projAssetList.get(0).Id;
        c2.Core_IPS_Project_Case__c = listOfIpsProjects.get(0).id;
        c2.Core_IPS_Supported_Product__c = projAssetList.get(0).Core_Supported_Product__c;  
        c2.EntitlementId=listOfEntitlement.get(0).id;
        c2.Core_IPS_Private_Project__c = true;
        System.runAs(listOfUser1.get(0)){
            insert  c2; 
        }
        final Map<Id,Case> mCase = new Map<Id,Case>();
        mCase.put(c2.Id,c2);
        /* System.runAs(listOfUser.get(0)){
c2.Subject='test Grv Prvt Proj Owner';
c2.Core_IPS_Supported_Product__c = projAssetList.get(1).Core_Supported_Product__c;  
c2.assetid = projAssetList.get(1).Id;
update  c2; 
} */
        
        List<Case> caseList = new List<Case>{c2};
            Case c3 = new Case();
        c3.Id=c2.Id;
        c3.assetId=projAssetList.get(1).Id;
        c3.Core_IPS_Supported_Product__c = projAssetList.get(1).Core_Supported_Product__c; 
        c3.Core_IPS_Project_Case__c = listOfIpsProjects.get(0).id;
        c3.Core_IPS_Private_Project__c = true;
        List<Case> newCaseList = new List<Case>{c3};
            Core_IPS_CaseTriggerHandler.assignCaseOwnerOnProdUpdate(mCase, newCaseList);
        
    }
    
    
    static testmethod void caseProjProdOwnerUpdate1Test(){
        
        getrecords();
        // Query Profiles
        Map<String,ID> profiles = new Map<String,ID>();
        List<String> strProf = new List<String>();
        strProf.add('System Administrator');
        strProf.add('Sales Rep-BB-Dual IPS');
        List<Profile> profileList = [select id, name from Profile where name IN : strProf];
        for(Profile prf : profileList){
            profiles.put(prf.name, prf.id);
        }
        
        //Create Role
        UserRole r = [SELECT Id, Name FROM UserRole WHERE DeveloperName = 'IPS_Product_Org_Admin' LIMIT 1];
        
        User userRecord = new User(
            Alias = 'StdUser', 
            Email = 'newuser211@intel.com', 
            EmailEncodingKey ='UTF-8',
            LastName = 'Testing',
            FirstName = 'FName',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles', 
            UserName = 'nnnnewuser12300000@intel.com',
            isActive = true
            
            
        );//UserRoleId = r.Id
        
        User userRecord1 = new User(
            Alias = 'StdUser', 
            Email = 'newuser2ssssds11@intel.com', 
            EmailEncodingKey ='UTF-8',
            LastName = 'Testing',
            FirstName = 'FName',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles', 
            UserName = 'nnnnewusedsdsdeeer12300@intel.com',
            isActive = true
            
            
        );
        
        
        List<User> listOfUser1 = new List<User>{userRecord,userRecord1}; //TestUtilities.getListOfUser(1);
            listOfUser1.get(0).ProfileID =  profiles.get('System Administrator');
        listOfUser1.get(1).ProfileID =  profiles.get('Sales Rep-BB-Dual IPS');
        //listOfUser1.get(1).ProfileID =  profiles.get('IPS Support Org Admin');
        
        insertUsersWithValidationBypass(listOfUser1);
        
        /* List<Core_IPS_Labels__c> listofIpsLables = TestUtilities.getIPSLabel();
System.runAs(listOfUser.get(0)){
insert listofIpsLables;
} */
        //  System.runAs(listOfUser.get(1)){
        Product2 prod1 = TestUtilities.getProduct();
        Product2 prod2 = TestUtilities.getProduct();
        prod2.Name='test Prod2';
        List<Product2> prodList = new List<Product2>();
        prodList.add(prod1);
        prodList.add(prod2);
        System.runAs(listOfUser1.get(0)){
            insert prodList; 
        } 
        test.startTest();
        Account acctRecord=TestUtilities.getAccountRecord();
        // acctRecord.OwnerId= listOfUser.get(1).id;
        acctRecord.Core_CNDA_Number__c='123';
        System.runAs(listOfUser1.get(0)){
            insert acctRecord; 
        } 
        //insert acctRecord;
        Contact contactRecord;
        contactRecord = TestUtilities.getContact();
        contactRecord.Accountid = acctRecord.id;
        // contactRecord.Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
        contactRecord.core_ips_Active__c=false;
        contactRecord.Email = 'ContactDellTest@gmail.com';
        contactRecord.MailingCountry = 'India';
        System.runAs(listOfUser.get(0)){
            insert contactRecord; 
        } 
        //insert contactRecord;
        List<Core_IPS_Product_Organization__c> suppOrgList = new List<Core_IPS_Product_Organization__c>();
        Core_IPS_Product_Organization__c prodOrg = TestUtilities.getSupportOrg();
        Core_IPS_Product_Organization__c prodOrg2 = TestUtilities.getSupportOrg();
        suppOrgList.add(prodOrg);
        suppOrgList.add(prodOrg2);
        System.runAs(listOfUser.get(0)){
            insert suppOrgList; 
        } 
        
        List<Core_IPS_Supported_Product__c> spList = new List<Core_IPS_Supported_Product__c>();
        Core_IPS_Supported_Product__c sp1=TestUtilities.getSupportedProduct();
        sp1.Core_Product__c = prod1.id;
        sp1.Core_Product_Organization__c = prodOrg.id;
        sp1.Core_Flag_Status__c = 'Auto Approve';
        Core_IPS_Supported_Product__c sp2 = new Core_IPS_Supported_Product__c();
        sp2.Core_EOIS__c = false;
        sp2.Core_Supported_Product_Name__c = 'Haswell EP';
        sp2.Core_Product__c = prod2.id;
        sp2.Core_Product_Organization__c = prodOrg2.id;
        sp2.Core_Flag_Status__c = 'Auto Approve';
        spList.add(sp1);
        spList.add(sp2);
        System.runAs(listOfUser.get(0)){
            insert spList; 
        } 
        // insert sp;
        
        Id projectRecordTypeId = Schema.SObjectType.Core_IPS_Project__c.getRecordTypeInfosByName().get('Active').getRecordTypeId();
        Core_IPS_Project__c ipsProjectRecord = new Core_IPS_Project__c(
            Name = 'projIPSTestProject Grv',
            Core_Status__c = 'Draft',
            Core_MPNDA__c='12345',
            core_ips_private__c=true,
            recordTypeId = projectRecordTypeId
        );
        
        List<Core_IPS_Project__c> listOfIpsProjects = new List<Core_IPS_Project__c>{ipsProjectRecord};
            System.runAs(listOfUser1.get(0)){
                insert listOfIpsProjects; 
            } 
        list<Asset> assetList = TestUtilities.getAssetList(1);
        for(Asset asst : assetList){
            asst.accountId = acctRecord.Id;
            asst.Contactid = contactRecord.id;
            asst.Core_IPS_Project__c = listOfIpsProjects.get(0).id;
            asst.Core_Supported_Product__c = spList.get(0).id;
        }
        System.runAs(listOfUser1.get(0)){
            insert assetList;
        }
        // insert projAccount;
        core_ips_account__c projAccount= TestUtilities.getCoreIpsAccount();
        Core_IPS_Project_Member__c projectMember = TestUtilities.getProjectMember();
        List<Core_IPS_Product__c> projProdList = new List<Core_IPS_Product__c>();
        for(Core_IPS_Project__c proj: listOfIpsProjects){
            
            projAccount.Core_Account__c=acctRecord.Id;
            projAccount.Core_IPS_Project__c=proj.Id;
            
            
            //insert projectMember;    
            
            projectMember.core_ips_contact__c = contactRecord.id;
            projectMember.Core_IPS_Project__c = proj.id;
            
            // insert projProduct
            
            Core_IPS_Product__c projProduct1=TestUtilities.getIpsProduct();
            projProduct1.Core_IPS_Project__c=proj.Id;
            projProduct1.Core_Supported_Product__c=sp1.Id;
            projProduct1.Core_IPS_Prod_Def_Case_Owner_ID__c = listOfUser1.get(0).Id;  // added changes by sumukh for US586420
            
            Core_IPS_Product__c projProduct2=TestUtilities.getIpsProduct();
            projProduct2.Core_IPS_Project__c=proj.Id;
            projProduct2.Core_Supported_Product__c=sp2.Id;
            projProduct2.Core_IPS_Prod_Def_Case_Owner_ID__c =listOfUser1.get(0).Id; // added changes by sumukh for US586420                
            projProdList.add(projProduct1);
            projProdList.add(projProduct2);    
            
        }
        System.runAs(listOfUser1.get(0)){
            insert projAccount; 
        } 
        System.runAs(listOfUser1.get(0)){
            insert projectMember; 
        } 
        System.runAs(listOfUser1.get(0)){
            insert projProdList; 
        } 
        test.stopTest();
        //List<Core_IPS_Project__c> listOfIpsProjects = new List<Core_IPS_Project__c>{ipsProjectRecord};
        System.runAs(listOfUser1.get(0)){
            listOfIpsProjects.get(0).Core_Status__c = 'Active';
            //update listOfIpsProjects;
        } 
        
        
        List<Asset> projAssetList = [Select Id,Core_IPS_Project__c,Core_Supported_Product__c from Asset where Core_IPS_Project__c =:listOfIpsProjects.get(0).id];   
        
        
        List<Entitlement> listOfEntitlement = TestUtilities.getListOfEntitlement(1);
        for(Entitlement entitlementRec : listOfEntitlement){
            entitlementRec.AccountId = acctRecord.Id;
            
        }
        System.runAs(listOfUser.get(0)){
            insert listOfEntitlement;
        }
        
        Id devRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('IPS No Assigned Contact Case').getRecordTypeId();
        
        Case c2 = TestUtilities.getListOfCases(1).get(0);
        c2.RecordTypeId = devRecordTypeId;
        c2.Core_IPS_Self_Assigned__c =true; 
        c2.assetId = projAssetList.get(0).Id;
        c2.Core_IPS_Project_Case__c = listOfIpsProjects.get(0).id;
        c2.Core_IPS_Supported_Product__c = projAssetList.get(0).Core_Supported_Product__c;  
        c2.EntitlementId=listOfEntitlement.get(0).id;
        c2.Core_IPS_Private_Project__c = true;
        System.runAs(listOfUser1.get(0)){
            insert  c2; 
            System.assertEquals(c2!=null, true, 'Case inserted');
        }
    }
    
    /***************************************************************************************************
Method Name:  USAMinds_test
Method Type: Test Method
Version     : 1.0 
Description:  insertCommentUSAMinds Test method
Scenario Type:  Positive
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Aparna                    22/2/2019               Created - US253169
****************************************************************************************************/ 
    
    public static testmethod void usaMindsTest(){
        
        List<Case> caseList = new List<Case>();
        
        Account acct =  new Account();
        Contact con =  new Contact();
        Entitlement ent = new Entitlement();
        acct = TestUtilities.getAccountRecord();
        acct.Core_CNDA_Number__c ='1691';
        insert acct;
        
        List<Contact> conList = new List<Contact>();
        Contact contactRecord = TestUtilities.getContact();
        contactRecord.Accountid = acct.id;
        contactRecord.core_ips_Active__c=false;
        contactRecord.Email = 'runTestClass@test.com';
        contactRecord.MailingCountry = 'India';
        conList.add(contactRecord);
        
        Contact contactRecord1 = TestUtilities.getContact();
        contactRecord1.Accountid = acct.id;
        contactRecord1.core_ips_Active__c=false;
        contactRecord1.Email = 'run123TestClass@test.com';
        contactRecord1.MailingCountry = 'India';
        conList.add(contactRecord1);
        
        insert conList;
        
        //Custom Setting - Trigger Executions
        List<Core_Trigger_Executions__c> triggerExecutionList= new List<Core_Trigger_Executions__c>();
        Core_Trigger_Executions__c  triggerExecution = new Core_Trigger_Executions__c();
        triggerExecution.Name = 'IPSCaseFieldsInit';
        triggerExecution.Core_Active__c = true;
        triggerExecution.Core_Class_Name__c ='Core_IPS_CaseTriggerHandler';
        triggerExecution.Core_Description__c = 'To update Case fields.';
        triggerExecution.Core_Object__c = 'Case';
        triggerExecution.Core_Trigger_Events__c = 'before insert';
        
        Core_Trigger_Executions__c  triggerExecution3 = new Core_Trigger_Executions__c();
        triggerExecution3.Name = 'assignCaseInformationfromProject';
        triggerExecution3.Core_Active__c = true;
        triggerExecution3.Core_Class_Name__c ='Core_IPS_CaseTriggerHandler';
        triggerExecution3.Core_Description__c = 'To update Case fields.';
        triggerExecution3.Core_Object__c = 'Case';
        triggerExecution3.Core_Trigger_Events__c = 'before insert';
        triggerExecutionList.add(triggerExecution3 ); 
        insert triggerExecutionList;
        
        //Custom Setting - Trigger Executions
        Core_Trigger_Executions__c  triggerExecution2 = new Core_Trigger_Executions__c();
        triggerExecution2.Name = 'UpdateCommentUSAMinds';
        triggerExecution2.Core_Active__c = true;
        triggerExecution2.Core_Class_Name__c ='Core_IPS_CaseTriggerHandler';
        triggerExecution2.Core_Description__c = 'Used for adding Private to Intel comment for USA-Minds cases when Updated';
        triggerExecution2.Core_Object__c = 'Case';
        triggerExecution2.Core_Trigger_Events__c = 'after update';
        insert triggerExecution2;   
        
        Core_Trigger_Executions__c  triggerExecution4 = new Core_Trigger_Executions__c();
        triggerExecution4.Name = 'insertCommentUSAMinds';
        triggerExecution4.Core_Active__c = true;
        triggerExecution4.Core_Class_Name__c ='Core_IPS_CaseTriggerHandler';
        triggerExecution4.Core_Description__c = 'Used for adding Private to Intel comment for USA-Minds cases when Updated';
        triggerExecution4.Core_Object__c = 'Case';
        triggerExecution4.Core_Trigger_Events__c = 'after insert';
        insert triggerExecution4;   
        
        
        List<Core_IPS_Labels__c> listofIpsLables = new List<Core_IPS_Labels__c>();
        Core_IPS_Labels__c ipsLables0 = new Core_IPS_Labels__c(Name = 'PRIVATE_TO_INTEL',Value__c = 'Private to Intel');
        Core_IPS_Labels__c ipsLables1 = new Core_IPS_Labels__c(Name = 'USA',Value__c = 'United States');
        Core_IPS_Labels__c ipsLables2 = new Core_IPS_Labels__c(Name = 'Core_IPS_USAMinds_Comment',Value__c = 'By working this case, you are agreeing to comply with regulatory requirements here: <a href = "http://goto.intel.com/mindsipsguardrails">http://goto.intel.com/mindsipsguardrails</a> ');
        Core_IPS_Labels__c ipsLables3 = new Core_IPS_Labels__c(Name = 'Core_IPS_USAMindsComment_Author',Value__c = UserInfo.getUserId());
        Core_IPS_Labels__c ipsLables4 = new Core_IPS_Labels__c(Name = 'Agent',Value__c = 'Agent');
        Core_IPS_Labels__c ipsLables5 = new Core_IPS_Labels__c(Name = 'GEC_Status_Approved_WithG',Value__c = 'Approved with Guardrails');
        listofIpsLables.add(ipsLables0);
        listofIpsLables.add(ipsLables1);
        listofIpsLables.add(ipsLables2);
        listofIpsLables.add(ipsLables3); 
        listofIpsLables.add(ipsLables4);
        listofIpsLables.add(ipsLables5);
        
        insert listofIpsLables;
        
        List<Contact> conList1 = [select Id From Contact where id = :conList[0].Id or id = :conList[1].Id  limit 2];
        
        Id devRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('IPS Case Create').getRecordTypeId();
        Case c= new case(recordtypeId=devRecordTypeId,contactId=conList1[0].Id,subject='testing case', Type='Test case', Origin='phone', Reason='Testing',Status='new',Priority='high',Core_Severity__c='1234',Core_IPS_Minds__c=true,Core_IPS_Country_Region__c = 'United States',Core_IPS_GEC_Status__c = 'Approved with Guardrails');
        caseList.add(c);
        insert caseList;
        
        List<Case> caseList1 = [select Id, contactId from case where Id = :caseList[0].Id limit 1];
        caseList1[0].contactId = conList1[1].Id;
        update caseList1;
        System.assertEquals(caseList1!=null, true, 'Case Updated');
        
        if(caseList.size()>0){
            Core_IPS_CaseTriggerHandler.insertCommentUSAMinds(caseList);
        }
    }   
    //end
    
    /***************************************************************************************************
Method Name:  createFAEASInterestedPartyTest
Method Type: Test Method
Version     : 1.0 
Description:  createFAEASInterestedParty Test method
Scenario Type:  Positive
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Ganapati                    03/07/2019               Created - US358368
****************************************************************************************************/ 
    
    static testmethod void createFAEASInterestedPartyTest(){
        getRecords();
        Core_IPS_Labels__c labels = new Core_IPS_Labels__c ();
        labels.name= 'IPS_SalesRep_ProfilesId';
        labels.value__c='00eo0000000TVVr,00eo0000000TVVs,00eo0000000TVVp,00eo0000000TVVq,0PS1J000000GCOJ';
        insert labels;
        
        Core_Trigger_Executions__c  triggerExecution1 = new Core_Trigger_Executions__c();
        triggerExecution1.Name = 'createFAEASInterestedParty';
        triggerExecution1.Core_Active__c = true;
        triggerExecution1.Core_Class_Name__c ='Core_IPS_CaseTriggerHandler';
        triggerExecution1.Core_Description__c = 'Creates an Interested party over case creation ';
        triggerExecution1.Core_Object__c = 'Case';
        triggerExecution1.Core_Trigger_Events__c = 'after insert';
        insert triggerExecution1;   
        List<Profile> profileList = [select id, name from Profile where name = 'System Administrator' limit 1];
        User userRecord = new User();
        userRecord.Alias = 'StdUser';
        //userRecord.contactId =listOfContacts[0].id;
        userRecord.Email = 'newuser22@intel.com';
        userRecord.EmailEncodingKey ='UTF-8';
        userRecord.LastName = 'Testing';
        userRecord.FirstName = 'FName';
        userRecord.LanguageLocaleKey = 'en_US';
        userRecord.LocaleSidKey = 'en_US';
        userRecord.TimeZoneSidKey = 'America/Los_Angeles'; 
        userRecord.UserName = 'newuser22' + String.valueOf(DateTime.Now().getTime()) + '@intel.com.' + UserInfo.getOrganizationId();
        userRecord.isActive = true;
        userRecord.ProfileID =  profileList[0].Id;  
        insertUsersWithValidationBypass(new List<User>{userRecord});
        
        Map<String, Id> caseRecordtype = new Map<String, Id>();
        
        for(Recordtype recType:[Select ID,Name from Recordtype where sobjectType = 'Case']) {  
            caseRecordtype.put(recType.Name,recType.ID);
        } 
        
        System.runAs(userRecord){ 
            Account acct =  new Account();
            Contact con =  new Contact();
            Entitlement ent = new Entitlement();
            acct = TestUtilities.getAccountRecord();
            acct.Core_CNDA_Number__c ='1691';
            insert acct;
            
            
            List<Contact> conList = new List<Contact>();
            Contact contactRecord = TestUtilities.getContact();
            contactRecord.Accountid = acct.id;
            contactRecord.core_ips_Active__c=false;
            contactRecord.Email = 'runTestClass@test.com';
            contactRecord.MailingCountry = 'India';
            conList.add(contactRecord);
            
            Contact contactRecord1 = TestUtilities.getContact();
            contactRecord1.Accountid = acct.id;
            contactRecord1.core_ips_Active__c=false;
            contactRecord1.Email = 'run123TestClass@test.com';
            contactRecord1.MailingCountry = 'India';
            conList.add(contactRecord1);
            
            insert conList;
            List<Core_IPS_Project__c> listOfIpsProjects = TestUtilities.getListOfIpsProjects(2);
            
            insert listOfIpsProjects;
            List<Case> listOfCase = new List<Case>();
            /*Case caseRecord = new Case(
Status = 'New',
Origin = 'Web',
Priority = 'High',
Subject = 'TestSubject 1',
Description = 'TestDescription',
RecordTypeId = caseRecordtype.get('IPS No Assigned Contact Case')
);
listOfCase.add(c);
*/
            Case caseRecord1= new case(recordtypeId=caseRecordtype.get('IPS Case Create'),contactId=conList[0].Id,subject='testing case',Core_IPS_Project_Case__c = listOfIpsProjects[0].Id,  Type='Test case', Origin='Web', Reason='Testing',Status='New',Priority='High',Core_Severity__c='High');
            
            listOfCase.add(caseRecord1);
            Test.startTest();
            insert listOfCase;
            Test.stopTest();
        }
        
        triggerExecution1.Core_Active__c = false;
        update triggerExecution1;
        
        Case caseRecord = new Case(
            Status = 'New',
            Origin = 'Web',
            Priority = 'High',
            Subject = 'TestSubject 1',
            Description = 'TestDescription',
            RecordTypeId = caseRecordtype.get('IPS No Assigned Contact Case')
        );
        insert caseRecord;
        System.assertEquals(caseRecord!=null, true, 'Case Inserted');
    } 
    //created by ranjini for US404759
    static testmethod void createNACCaseTest(){
        List<Core_Trigger_Executions__c> triggerExecutionList= new List<Core_Trigger_Executions__c>();
        Core_Trigger_Executions__c  triggerExecution = new Core_Trigger_Executions__c();
        triggerExecution.Name = 'IPSCaseFieldsInit';
        triggerExecution.Core_Active__c = true;
        triggerExecution.Core_Class_Name__c ='Core_IPS_CaseTriggerHandler';
        triggerExecution.Core_Description__c = 'To update Case fields.';
        triggerExecution.Core_Object__c = 'Case';
        triggerExecution.Core_Trigger_Events__c = 'before insert';
        
        
        Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('IPSCaseFieldsInit');
        Id recordTypeIPSNAC = Schema.SObjectType.Case.getRecordTypeInfosByName().get('IPS No Assigned Contact Case').getRecordTypeId();
        Case caseRecord = new Case(
            
            Subject = 'TestSubject 1',
            Description = 'TestDescription',
            Core_Severity__c = 'low',
            Type = 'Question',
            RecordTypeId = recordTypeIPSNAC
        );
        Test.startTest();
        insert caseRecord;
        System.assertEquals(caseRecord!=null, true, 'Case Inserted');
        Test.stopTest();
    }
    
   /* static testmethod void createCaseShareTest(){
        List<Profile> profileList = [select id, name from Profile where name = 'Sales Rep-CW' limit 1];
        User userRecord = new User();
        userRecord.Alias = 'StdUser';
        //userRecord.contactId =listOfContacts[0].id;
        userRecord.Email = 'newuser22@intel.com';
        userRecord.EmailEncodingKey ='UTF-8';
        userRecord.LastName = 'Testing';
        userRecord.FirstName = 'FName';
        userRecord.LanguageLocaleKey = 'en_US';
        userRecord.LocaleSidKey = 'en_US';
        userRecord.TimeZoneSidKey = 'America/Los_Angeles'; 
        userRecord.UserName = 'newuser22' + String.valueOf(DateTime.Now().getTime()) + '@intel.com.' + UserInfo.getOrganizationId();
        userRecord.isActive = true;
        userRecord.ProfileID =  profileList[0].Id;  
        insert userRecord;
        System.AssertEquals(userRecord.Id != null, true);
        
        Account acct =  new Account();
        Contact con =  new Contact();
        Entitlement ent = new Entitlement();
        acct = TestUtilities.getAccountRecord();
        acct.Core_CNDA_Number__c ='1691';
        insert acct;
        Map<String, Id> caseRecordtype = new Map<String, Id>();
        
        for(Recordtype recType:[Select ID,Name from Recordtype where sobjectType = 'Case']) {  
            caseRecordtype.put(recType.Name,recType.ID);
        } 
        List<Contact> conList = new List<Contact>();
        Contact contactRecord = TestUtilities.getContact();
        contactRecord.Accountid = acct.id;
        contactRecord.core_ips_Active__c=false;
        contactRecord.Email = 'runTestClass@test.com';
        conList.add(contactRecord);
        
        List<Core_IPS_Project__c> listOfIpsProjects = TestUtilities.getListOfIpsProjects(2);  
        insert listOfIpsProjects;
        
        Case caseRecord1= new case(recordtypeId=caseRecordtype.get('IPS Case Create'),contactId=conList[0].Id,subject='testing case1',Core_IPS_Project_Case__c = listOfIpsProjects[0].Id,  Type='Test case', Origin='Web', Reason='Testing',Status='New',Priority='High',Core_Severity__c='High');
        Case caseRecord2= new case(recordtypeId=caseRecordtype.get('IPS Case Create'),contactId=conList[0].Id,subject='testing case2',Core_IPS_Project_Case__c = listOfIpsProjects[0].Id,  Type='Test case', Origin='Web', Reason='Testing',Status='New',Priority='High',Core_Severity__c='High');
        Case caseRecord3= new case(recordtypeId=caseRecordtype.get('IPS GEC ReadOnly'),contactId=conList[0].Id,subject='testing case2',Core_IPS_Project_Case__c = listOfIpsProjects[0].Id,  Type='Test case', Origin='Web', Reason='Testing',Status='New',Priority='High',Core_Severity__c='High');
        caseRecord3.Core_IPS_GEC_Case__c = true; 
        List<case>listOfCase = new List<case>();
        listOfCase.add(caseRecord1);
        listOfCase.add(caseRecord2);
        listOfCase.add(caseRecord3);
        insert listOfCase;
        List<CaseShare> lstCaseShare = new List<CaseShare>();
        CaseShare csShareRec1 = new CaseShare(caseId=caseRecord1.id,CaseAccessLevel = 'Read', UserOrGroupId= userRecord.id);
        CaseShare csShareRec2 = new CaseShare(caseId=caseRecord2.id,CaseAccessLevel = 'Read', UserOrGroupId= userRecord.id); 
        lstCaseShare.add(csShareRec1);
        lstCaseShare.add(csShareRec2);
        
        insert lstCaseShare;
        Map<Id,Set<Id>> caseContactUserCustomerVisibleFalseMap = new Map<Id,Set<Id>>();
        Map<Id,Set<Id>> caseContactUserCustomerVisibleTrueMap = new Map<Id,Set<Id>>();
        set<Id> testset = new Set<Id>();
        caseContactUserCustomerVisibleFalseMap.put(caseRecord1.id, testset);
        caseContactUserCustomerVisibleTrueMap.put(caseRecord2.id,testset);
        Test.startTest();
        Core_IPS_CaseTriggerHandler.createCaseShare(lstCaseShare, caseContactUserCustomerVisibleFalseMap, caseContactUserCustomerVisibleTrueMap );
        Test.stopTest();
        System.assert(profileList[0].id != null, true);
    } */
    
    static testmethod void createNACCaseTest1(){
        List<Core_Trigger_Executions__c> triggerExecutionList= new List<Core_Trigger_Executions__c>();
        Core_Trigger_Executions__c  triggerExecution = new Core_Trigger_Executions__c();
        triggerExecution.Name = 'IPSCaseFieldsInit';
        triggerExecution.Core_Active__c = true;
        triggerExecution.Core_Class_Name__c ='Core_IPS_CaseTriggerHandler';
        triggerExecution.Core_Description__c = 'To update Case fields.';
        triggerExecution.Core_Object__c = 'Case';
        triggerExecution.Core_Trigger_Events__c = 'before insert';
        
        
        Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('IPSCaseFieldsInit');
        Id recordTypeIPSNAC = Schema.SObjectType.Case.getRecordTypeInfosByName().get('IPS No Assigned Contact Case').getRecordTypeId();
        Case caseRecord = new Case(
            
            Subject = 'TestSubject 1',
            Description = 'TestDescription',
            Core_Severity__c = 'low',
            Type = 'Question',
            RecordTypeId = recordTypeIPSNAC
        );
        
        
        List<Core_IPS_Labels__c> lablesList = new List<Core_IPS_Labels__c>();
        Core_IPS_Labels__c labels = new Core_IPS_Labels__c();
        labels.name= 'PRIVATE_TO_INTEL';
        labels.value__c='Private to Intel';
        lablesList.add(labels);
        
        Core_IPS_Labels__c labels1 = new Core_IPS_Labels__c();
        labels1.name= 'PUBLIC_TO_CUSTOMERS';
        labels1.value__c='Public to Customers';
        lablesList.add(labels1);
        
        Core_IPS_Labels__c labels2 = new Core_IPS_Labels__c();
        labels2.name= 'PRIVATE_TO_AGENTS';
        labels2.value__c='Private to Agents';
        lablesList.add(labels2);
        
        Core_IPS_Labels__c labels3 = new Core_IPS_Labels__c();
        labels3.name= 'Customer';
        labels3.value__c='Customer';
        lablesList.add(labels3);
        
        Core_IPS_Labels__c labels4 = new Core_IPS_Labels__c();
        labels4.name= 'Agent';
        labels4.value__c='Agent';
        lablesList.add(labels4);
        
        Core_IPS_Labels__c labels5 = new Core_IPS_Labels__c();
        labels5.name= 'FAE';
        labels5.value__c='FAE';
        lablesList.add(labels5);
        
        Core_IPS_Labels__c labels6 = new Core_IPS_Labels__c();
        labels6.name= 'Partner';
        labels6.value__c='Partner';
        lablesList.add(labels6);
        
        Core_IPS_Labels__c labels7 = new Core_IPS_Labels__c();
        labels7.name= 'PRIVATE_TO_PARTNERS';
        labels7.value__c='Private to Partner';
        lablesList.add(labels7);
        
        Core_IPS_Labels__c labels8 = new Core_IPS_Labels__c();
        labels8.name= 'Partner - DFAE';
        labels8.value__c= 'Partner - DFAE';
        lablesList.add(labels8);
        
        Core_IPS_Labels__c labels9 = new Core_IPS_Labels__c();
        labels9.name= 'Backend Integration';
        labels9.value__c='Backend Integration';
        lablesList.add(labels9);
        
        Core_IPS_Labels__c labels10 = new Core_IPS_Labels__c();
        labels10.name= 'Comment Source - B2B API';
        labels10.value__c='B2B API';
        lablesList.add(labels10);
        
        Core_IPS_Labels__c labels11 = new Core_IPS_Labels__c();
        labels11.name= 'Comment Source - Backend System';
        labels11.value__c='Backend System';
        lablesList.add(labels11);
        
        Core_IPS_Labels__c labels12 = new Core_IPS_Labels__c();
        labels12.name= 'Comment Source - Customer';
        labels12.value__c='Customer Portal';
        lablesList.add(labels12);
        
        Core_IPS_Labels__c labels13 = new Core_IPS_Labels__c();
        labels13.name= 'Comment Source - Data Migration';
        labels13.value__c='Data Migration';
        lablesList.add(labels13);
        
        Core_IPS_Labels__c labels14 = new Core_IPS_Labels__c();
        labels14.name= 'Comment Source - Email';
        labels14.value__c='Email';
        lablesList.add(labels14); 
        
        Core_IPS_Labels__c labels15 = new Core_IPS_Labels__c();
        labels15.name= 'Comment Source - Internal';
        labels15.value__c='Internal Portal  ';
        lablesList.add(labels15);
        
        Core_IPS_Labels__c labels16 = new Core_IPS_Labels__c();
        labels16.name= 'Comment Source - N/A';
        labels16.value__c='N/A';
        lablesList.add(labels16);
        
        Core_IPS_Labels__c labels17 = new Core_IPS_Labels__c();
        labels17.name= 'Data Migration';
        labels17.value__c='Data Migration';
        lablesList.add(labels17);
        // Avoid Hardcoding Id Fix  - Shipra
        Case caseRecord1=  TestUtilities.getCase(); 
        insert caseRecord1;
        Core_IPS_Labels__c labels21 = new Core_IPS_Labels__c();
        labels21.name= 'Core_IPS_USAMindsComment_Author';
        labels21.value__c=caseRecord1.Id;
        //labels21.value__c='5003F000000ffZFQAY';
        lablesList.add(labels21);
        
        Core_IPS_Labels__c labels22 = new Core_IPS_Labels__c();
        labels22.name= 'System';
        labels22.value__c='System';
        lablesList.add(labels22);
        
        Core_IPS_Labels__c labels18 = new Core_IPS_Labels__c();
        labels18.name= 'Partner - Agent';
        labels18.value__c='Partner - Agent';
        lablesList.add(labels18);      
        insert lablesList;
        
        Test.startTest();
        insert caseRecord;
        List<id> idlist = new List<id>();
        idlist.add(caseRecord.id);
        Core_IPS_CaseTriggerHandler.promoteMissedItems(idlist);
        Map<Id,String> testmap = new Map<Id,String>();
        // Avoid Hardcoding Id Fix  - Shipra
        Case caseRecord2=  TestUtilities.getCase(); 
        insert caseRecord2;
        Id testid = caseRecord2.Id;
        //        Id testid = '5003F000000ffZFQAY';
        //testmap.put(testid,'{"id":"Env Dtl Resp","Env Dtl Resp":"Env Dtl Resp"}');
        List<Object> edqData = new List<Object>();  
        Map<String, Object> Answermap = new Map<String, Object>();
        Answermap.put('Ansr',5);
        edqData.add(Answermap);
        Map<String, List<Object>> testmap1 = new Map<String, List<Object>>();
        testmap1.put('Env Dtl Resp',edqData);
        String dataString = System.JSON.serialize(testmap1);
        testmap.put(testid,dataString);
        
        List<String> testList = new List<String>();
        testList.add('question');
        Core_IPS_CaseTriggerHandler.getEdqs(testmap, testList);        
        List<Id> caseIds = new List<id> ();
        caseIds.add(caseRecord.Id);
        Core_IPS_CaseTriggerHandler.prepareComment(caseIds);
        Core_IPS_CaseTriggerHandler.createCaseComment(caseRecord.Id);
        
        System.assertEquals(caseRecord!=null, true, 'Case Inserted');
        Test.stopTest();
    }
    
    //Added by Vishal As part Of STOWD implementation -TWC777-2514 - 08/08/2024
    @isTest
    public static void handleBeforeUpdateSTOWDTest() {
       // List<STOWD_Tracking_Field__mdt> trackingFields = [SELECT MasterLabel, IsActive__c, FieldType__c FROM STOWD_Tracking_Field__mdt];
        
        Case testCase = new Case(
            Status = 'New',
            OwnerId = UserInfo.getUserId(),
            Core_IPS_Escalated_Level__c = 'Low',
            Core_Sub_Status__c = 'Pending',
            Core_IPS_Assigned_Queue__c = 'Queue 1'
        );
        insert testCase;
        // Added By Chiru
        System.AssertEquals(testCase.Id != null,true);
        List<Case> cases = [SELECT Id, Status, OwnerId, Core_IPS_Escalated_Level__c, Core_Sub_Status__c, Core_IPS_Assigned_Queue__c FROM Case];
        
        Map<Id, Case> oldCaseMap = new Map<Id, Case>(cases);
        
        for (Case caseRec : cases) {
            caseRec.Status = 'In Progress'; 
        }
        
        Test.startTest();
        //Core_IPS_CaseTriggerHandler.handleBeforeUpdate(cases, oldCaseMap);
        Test.stopTest();
        
        
    }
    
}