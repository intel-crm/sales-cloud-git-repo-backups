@isTest
public class Core_Ips_DynamicDataTable_Lwc_Ctrl_Test {
    
    
    @isTest
    static void GetWrapperOfSObjectFieldColumnActionValues_Test(){
        
        Core_Ips_CaseListView_Lwc__mdt tableComponentMetadata =  [SELECT Id,FieldValue__c,HeaderValue__c,DeveloperName,Query__c FROM Core_Ips_CaseListView_Lwc__mdt WHERE DeveloperName='AllCases'];
        Core_Ips_DynamicDataTable_Lwc_Ctrl.GetWrapperOfSObjectFieldColumnActionValues(tableComponentMetadata.DeveloperName);
        
        Core_Ips_CaseListView_Lwc__mdt tableComponentMetadata1 =  [SELECT Id,FieldValue__c,HeaderValue__c,DeveloperName,Query__c FROM Core_Ips_CaseListView_Lwc__mdt WHERE DeveloperName='All_Cases_Detail_View'];
        Core_Ips_DynamicDataTable_Lwc_Ctrl.GetWrapperOfSObjectFieldColumnActionValues(tableComponentMetadata1.DeveloperName);
        
        Core_Ips_CaseListView_Lwc__mdt tableComponentMetadata2 =  [SELECT Id,FieldValue__c,HeaderValue__c,DeveloperName,Query__c FROM Core_Ips_CaseListView_Lwc__mdt WHERE DeveloperName='All_Open_Cases_Detail_View'];
        Core_Ips_DynamicDataTable_Lwc_Ctrl.GetWrapperOfSObjectFieldColumnActionValues(tableComponentMetadata2.DeveloperName);
        
        Core_Ips_CaseListView_Lwc__mdt tableComponentMetadata3 =  [SELECT Id,FieldValue__c,HeaderValue__c,DeveloperName,Query__c FROM Core_Ips_CaseListView_Lwc__mdt WHERE DeveloperName='My_Recently_Updates_Cases'];
        Core_Ips_DynamicDataTable_Lwc_Ctrl.GetWrapperOfSObjectFieldColumnActionValues(tableComponentMetadata3.DeveloperName);
        
        Core_Ips_CaseListView_Lwc__mdt tableComponentMetadata4 =  [SELECT Id,FieldValue__c,HeaderValue__c,DeveloperName,Query__c FROM Core_Ips_CaseListView_Lwc__mdt WHERE DeveloperName='Recently_Viewed_Cases'];
        Core_Ips_DynamicDataTable_Lwc_Ctrl.GetWrapperOfSObjectFieldColumnActionValues(tableComponentMetadata4.DeveloperName);
        
        //Core_Ips_CaseListView_Lwc__mdt TableComponentMetadata5 =  [SELECT Id,FieldValue__c,HeaderValue__c,DeveloperName,Query__c FROM Core_Ips_CaseListView_Lwc__mdt WHERE DeveloperName='My_Account_Cases'];
        //Core_Ips_DynamicDataTable_Lwc_Ctrl.GetWrapperOfSObjectFieldColumnActionValues(TableComponentMetadata5.DeveloperName);
        
        Core_Ips_CaseListView_Lwc__mdt tableComponentMetadata6 =  [SELECT Id,FieldValue__c,HeaderValue__c,DeveloperName,Query__c FROM Core_Ips_CaseListView_Lwc__mdt WHERE DeveloperName='My_Open_Cases'];
        Core_Ips_DynamicDataTable_Lwc_Ctrl.GetWrapperOfSObjectFieldColumnActionValues(tableComponentMetadata6.DeveloperName);
        
        Core_Ips_CaseListView_Lwc__mdt tableComponentMetadata7 =  [SELECT Id,FieldValue__c,HeaderValue__c,DeveloperName,Query__c FROM Core_Ips_CaseListView_Lwc__mdt WHERE DeveloperName='My_Closed_Cases'];
        Core_Ips_DynamicDataTable_Lwc_Ctrl.GetWrapperOfSObjectFieldColumnActionValues(tableComponentMetadata7.DeveloperName);
        


        
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
    private static void insertUsersWithValidationBypass(List<User> users) {
        User validationBypassUser = [SELECT Id FROM User WHERE Profile.Name = :System.Label.Core_System_Admin_Profile_Name AND IsActive = true LIMIT 1];
        System.runAs(validationBypassUser) {
            insert users;
        }
    }

    @isTest
    static void GetWrapperOfSObjectFieldColumnActionValues_Test1 (){
        
        UserRole role = [SELECT Id FROM UserRole WHERE PortalType = 'None' LIMIT 1];
        Map<String,ID> profiles = new Map<String,ID>();
        List<String> strProf = new List<String>();
        strProf.add('System Administrator');
        strProf.add('Partner');
        List<Profile> profileList = [select id, name from Profile where name IN : strProf];
        for(Profile prf : profileList){
            profiles.put(prf.name, prf.id);
        }
        
        List<User> listOfUser = new List<User> ();
        listOfUser = TestUtilities.getListOfUser(1);
        listOfUser.get(0).ProfileID =  profiles.get('System Administrator');
        listOfUser.get(0).userRoleId = role.Id;
        insertUsersWithValidationBypass(listOfUser);
        
        Account accRec = TestUtilities.getAccount();
        accRec.Name ='Test Account 1';
        accRec.Core_CNDA_Number__c ='1234';
        accRec.Core_IPS_Active__c = true;
        accRec.OwnerId = listOfUser.get(0).Id;
        System.runAs(listOfUser.get(0)){
        	insert accRec;
        }
        Id intelSupportOwner = listOfUser.get(0).id;
        List<Contact> listOfContacts = TestUtilities.getListOfContact(1);
        for(Contact contactRec : listOfContacts){
            contactRec.Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
            contactRec.Accountid = accRec.Id;
            contactRec.Core_IPS_Active__c = true;
        }
        
        System.runAs(listOfUser.get(0)){
            insert listOfContacts;
        }
        
        List<User> listOfUser1 = new List<User> ();
        listOfUser1 = TestUtilities.getListOfUser(1);
        listOfUser1.get(0).ProfileID =  profiles.get('Partner');
        listOfUser1.get(0).ContactId = listOfContacts.get(0).id;
        insertUsersWithValidationBypass(listOfUser1);
        
        system.runAs(listOfUser.get(0)){
        Case caseRecord = new Case();
        caseRecord.ContactId = listOfContacts.get(0).id;
        caseRecord.AccountId = accRec.Id;
        caseRecord.Core_IPS_Customer_Visible__c = true;
        caseRecord.Subject = 'TestSubject';
        caseRecord.Description = 'TestDescription';
        caseRecord.Type = 'Question';
        caseRecord.Core_Severity__c = 'Low';
        
        insert caseRecord;
        }
        
        Test.startTest();
          system.runAs(listOfUser1.get(0)){
              Core_Ips_CaseListView_Lwc__mdt tableComponentMetadata1 =  [SELECT Id,FieldValue__c,HeaderValue__c,DeveloperName,Query__c FROM Core_Ips_CaseListView_Lwc__mdt WHERE DeveloperName='All_Cases_Detail_View'];
              Core_Ips_DynamicDataTable_Lwc_Ctrl.GetWrapperOfSObjectFieldColumnActionValues(tableComponentMetadata1.DeveloperName);  
           
        }    
    }
}