@isTest
public class Core_Ips_DynamicDataTable_Lwc_Ctrl_Test {
    
    
    @isTest
    static void GetWrapperOfSObjectFieldColumnActionValues_Test(){
        
        Core_Ips_CaseListView_Lwc__mdt TableComponentMetadata =  [SELECT Id,FieldValue__c,HeaderValue__c,DeveloperName,Query__c FROM Core_Ips_CaseListView_Lwc__mdt WHERE DeveloperName='AllCases'];
        Core_Ips_DynamicDataTable_Lwc_Ctrl.GetWrapperOfSObjectFieldColumnActionValues(TableComponentMetadata.DeveloperName);
        
        Core_Ips_CaseListView_Lwc__mdt TableComponentMetadata1 =  [SELECT Id,FieldValue__c,HeaderValue__c,DeveloperName,Query__c FROM Core_Ips_CaseListView_Lwc__mdt WHERE DeveloperName='All_Cases_Detail_View'];
        Core_Ips_DynamicDataTable_Lwc_Ctrl.GetWrapperOfSObjectFieldColumnActionValues(TableComponentMetadata1.DeveloperName);
        
        Core_Ips_CaseListView_Lwc__mdt TableComponentMetadata2 =  [SELECT Id,FieldValue__c,HeaderValue__c,DeveloperName,Query__c FROM Core_Ips_CaseListView_Lwc__mdt WHERE DeveloperName='All_Open_Cases_Detail_View'];
        Core_Ips_DynamicDataTable_Lwc_Ctrl.GetWrapperOfSObjectFieldColumnActionValues(TableComponentMetadata2.DeveloperName);
        
        Core_Ips_CaseListView_Lwc__mdt TableComponentMetadata3 =  [SELECT Id,FieldValue__c,HeaderValue__c,DeveloperName,Query__c FROM Core_Ips_CaseListView_Lwc__mdt WHERE DeveloperName='My_Recently_Updates_Cases'];
        Core_Ips_DynamicDataTable_Lwc_Ctrl.GetWrapperOfSObjectFieldColumnActionValues(TableComponentMetadata3.DeveloperName);
        
        Core_Ips_CaseListView_Lwc__mdt TableComponentMetadata4 =  [SELECT Id,FieldValue__c,HeaderValue__c,DeveloperName,Query__c FROM Core_Ips_CaseListView_Lwc__mdt WHERE DeveloperName='Recently_Viewed_Cases'];
        Core_Ips_DynamicDataTable_Lwc_Ctrl.GetWrapperOfSObjectFieldColumnActionValues(TableComponentMetadata4.DeveloperName);
        
        //Core_Ips_CaseListView_Lwc__mdt TableComponentMetadata5 =  [SELECT Id,FieldValue__c,HeaderValue__c,DeveloperName,Query__c FROM Core_Ips_CaseListView_Lwc__mdt WHERE DeveloperName='My_Account_Cases'];
        //Core_Ips_DynamicDataTable_Lwc_Ctrl.GetWrapperOfSObjectFieldColumnActionValues(TableComponentMetadata5.DeveloperName);
        
        Core_Ips_CaseListView_Lwc__mdt TableComponentMetadata6 =  [SELECT Id,FieldValue__c,HeaderValue__c,DeveloperName,Query__c FROM Core_Ips_CaseListView_Lwc__mdt WHERE DeveloperName='My_Open_Cases'];
        Core_Ips_DynamicDataTable_Lwc_Ctrl.GetWrapperOfSObjectFieldColumnActionValues(TableComponentMetadata6.DeveloperName);
        
        Core_Ips_CaseListView_Lwc__mdt TableComponentMetadata7 =  [SELECT Id,FieldValue__c,HeaderValue__c,DeveloperName,Query__c FROM Core_Ips_CaseListView_Lwc__mdt WHERE DeveloperName='My_Closed_Cases'];
        Core_Ips_DynamicDataTable_Lwc_Ctrl.GetWrapperOfSObjectFieldColumnActionValues(TableComponentMetadata7.DeveloperName);
        


        
    }
    
    @isTest     
    static void ProductFieldAndDataValues_Test(){
        Core_Ips_ProductListView_LWC__mdt prodData =  [SELECT Id,FieldValue__c,HeaderValue__c,DeveloperName FROM Core_Ips_ProductListView_LWC__mdt WHERE DeveloperName='AllProducts'];
        Core_Ips_ProductDataTable_LWC_Ctrl.ProductFieldAndDataValues(prodData.DeveloperName);
        Core_Ips_ProductListView_LWC__mdt prodData2 =  [SELECT Id,FieldValue__c,HeaderValue__c,DeveloperName FROM Core_Ips_ProductListView_LWC__mdt WHERE DeveloperName='ActiveProducts'];
        Core_Ips_ProductDataTable_LWC_Ctrl.ProductFieldAndDataValues(prodData2.DeveloperName);
        
        
    }
   @isTest 
        static void projectFieldColumnValues_Test(){
        Core_Ips_ProjectListView_Lwc__mdt prodData1 =  [SELECT Id,FieldValue__c,HeaderValue__c,DeveloperName FROM Core_Ips_ProjectListView_Lwc__mdt WHERE DeveloperName='AllProjects'];
        Core_Ips_ProjectDataTable_Lwc_Ctrl.projectFieldColumnValues(prodData1.DeveloperName);
       }
    @isTest 
        static void ContactFieldAndDataValues_Test(){
        Core_Ips_ContactListView_LWC__mdt prodData3 =  [SELECT Id,FieldValue__c,HeaderValue__c,DeveloperName FROM Core_Ips_ContactListView_LWC__mdt WHERE DeveloperName='MyContacts'];
        Core_Ips_ContactDataTable_LWC_Ctrl.ContactFieldAndDataValues(prodData3.DeveloperName);
       }
    @isTest
    static void GetWrapperOfSObjectFieldColumnActionValues_Test1 (){
        
        UserRole role = [SELECT Id FROM UserRole WHERE PortalType = 'None' LIMIT 1];
        Map<String,ID> profiles = new Map<String,ID>();
        List<String> strProf = new List<String>();
        strProf.add('System Administrator');
        strProf.add('Partner');
        List<Profile> ProfileList = [select id, name from Profile where name IN : strProf];
        for(Profile prf : ProfileList){
            profiles.put(prf.name, prf.id);
        }
        
        List<User> ListOfUser = new List<User> ();
        ListOfUser = TestUtilities.getListOfUser(1);
        ListOfUser.get(0).ProfileID =  profiles.get('System Administrator');
        ListOfUser.get(0).userRoleId = role.Id;
        insert ListOfUser;
        
        Account accRec = TestUtilities.getAccount();
        accRec.Name ='Test Account 1';
        accRec.Core_CNDA_Number__c ='1234';
        accRec.Core_IPS_Active__c = true;
        accRec.OwnerId = ListOfUser.get(0).Id;
        System.runAs(ListOfUser.get(0)){
        	insert accRec;
        }
        Id intelSupportOwner = ListOfUser.get(0).id;
        List<Contact> ListOfContacts = TestUtilities.getListOfContact(1);
        for(Contact ContactRec : ListOfContacts){
            ContactRec.Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
            ContactRec.Accountid = accRec.Id;
            ContactRec.Core_IPS_Active__c = true;
        }
        
        System.runAs(ListOfUser.get(0)){
            insert ListOfContacts;
        }
        
        List<User> ListOfUser1 = new List<User> ();
        ListOfUser1 = TestUtilities.getListOfUser(1);
        ListOfUser1.get(0).ProfileID =  profiles.get('Partner');
        ListOfUser1.get(0).ContactId = ListOfContacts.get(0).id;
        insert ListOfUser1;
        
        system.runAs(ListOfUser.get(0)){
        Case CaseRecord = new Case();
        CaseRecord.ContactId = ListOfContacts.get(0).id;
        CaseRecord.AccountId = accRec.Id;
        CaseRecord.Core_IPS_Customer_Visible__c = true;
        CaseRecord.Subject = 'TestSubject';
        CaseRecord.Description = 'TestDescription';
        CaseRecord.Type = 'Question';
        CaseRecord.Core_Severity__c = 'Low';
        
        insert CaseRecord;
        }
        
        Test.startTest();
        system.runAs(ListOfUser1.get(0)){
           Core_Ips_CaseListView_Lwc__mdt TableComponentMetadata1 =  [SELECT Id,FieldValue__c,HeaderValue__c,DeveloperName,Query__c FROM Core_Ips_CaseListView_Lwc__mdt WHERE DeveloperName='All_Cases_Detail_View'];
           Core_Ips_DynamicDataTable_Lwc_Ctrl.GetWrapperOfSObjectFieldColumnActionValues(TableComponentMetadata1.DeveloperName);  
           
        }    
    }
}