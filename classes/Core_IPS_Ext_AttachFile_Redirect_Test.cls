/***************************************************************************************************
Apex Class Name:  Core_IPS_Ext_AttachFile_Redirect_Test.
US no          :  Iteration 13,US108333.
Version        :  1.0 
Created Date   :  19/06/2018
Function       :  Controller for VF page to Add Attachments on the Case Detail Page Button.
Modification Log :
*Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------              
* Raj Kommera            19/06/2018                Created
****************************************************************************************************/
@isTest
public class Core_IPS_Ext_AttachFile_Redirect_Test {    
    
    static testMethod Void iPSExternalUserTest(){
        list<Core_IPS_Labels__c> listcstSettings = new list<Core_IPS_Labels__c >();
        
        Core_IPS_Labels__c  label = new Core_IPS_Labels__c();
        label.name = 'PUBLIC_TO_CUSTOMERS';
        label.value__C = 'Public to Customers';
        listcstSettings.add(label);
        
        Core_IPS_Labels__c  label1 = new Core_IPS_Labels__c();
        label1.name = 'PRIVATE_TO_PARTNERS';
        label1.value__c = 'Private to Intel';
        listcstSettings.add(label1);
        insert listcstSettings;
        
        User CommunityUser = TestUtilities.getCustomerUser('IPS External Customer');
        // creating Customer community  user
        System.runAs(CommunityUser){
            
            Test.startTest();            
            System.debug('CommunityUser.Id: ' + CommunityUser.Id);
            Case Ca =  TestUtilities.getCase(); 
            insert Ca;
            System.assert(Ca.Id != null, 'Case Record not created');
            PageReference pageRef = Page.Core_IPS_External_AttachFile_Redirect;
            Test.setCurrentPage(pageRef);
            ApexPages.CurrentPage().getparameters().put('id',Ca.id);
            ApexPages.StandardController StndContr = new ApexPages.standardController(Ca);
            Core_IPS_Ext_AttachFile_Redirect_Ctrl caseClose = new Core_IPS_Ext_AttachFile_Redirect_Ctrl(StndContr);
            Pagereference Pg = caseClose.redirectPage();
            Test.stopTest();
        }
        
    }
    
    //User with Partner Profile
    static testMethod Void iPSPartnerUserTest(){
        
        list<Core_IPS_Labels__c> listcstSettings = new list<Core_IPS_Labels__c >();
        Core_IPS_Labels__c  label = new Core_IPS_Labels__c();
        label.name = 'PUBLIC_TO_CUSTOMERS';
        label.value__C = 'Public to Customers';
        listcstSettings.add(label);
        
        Core_IPS_Labels__c  label1 = new Core_IPS_Labels__c();
        label1.name = 'PRIVATE_TO_PARTNERS';
        label1.value__c = 'Private to Intel';
        listcstSettings.add(label1);
        insert listcstSettings;
        
        
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Partner' LIMIT 1];            
        Account acc = TestUtilities.getAccount();
        acc.Core_IPS_Active__c=True;
        insert acc;
        
        Contact con = TestUtilities.getContact();
        con.AccountId=acc.id;
        con.Core_IPS_Active__c=True;
        insert con;
        
        User usr = new User(LastName = 'LIVESTONERS',
                            FirstName='JASONTYU',
                            ContactId = con.id,
                            Alias = 'jliv',
                            Email = 'jason.liveston@asdf.com',
                            Username = 'jason.livestonjhgu@asdf.com',
                            ProfileId = profileId.id,
                            TimeZoneSidKey = 'GMT',
                            LanguageLocaleKey = 'en_US',
                            EmailEncodingKey = 'UTF-8',
                            LocaleSidKey = 'en_US'
                           );
        
        System.runAs(usr) {
            Test.startTest();            
            Case Ca =  TestUtilities.getCase(); 
            insert Ca;
            System.assert(Ca.Id != null, 'Case Record not created');
            PageReference pageRef = Page.Core_IPS_External_AttachFile_Redirect;
            Test.setCurrentPage(pageRef);
            ApexPages.CurrentPage().getparameters().put('id',Ca.id);
            ApexPages.StandardController StndContr = new ApexPages.standardController(Ca);
            Core_IPS_Ext_AttachFile_Redirect_Ctrl caseClose = new Core_IPS_Ext_AttachFile_Redirect_Ctrl(StndContr);
            Pagereference Pg = caseClose.redirectPage();
            caseClose.privateToPartnerURL = '';
            Test.stopTest();
        }
    }
    
    //User With FAE Permission Set
    static testMethod Void fAEPartnerUserTest(){
        Profile sysAdminProfile = [select id, name from Profile where name = 'System Administrator' Limit 1];
        User sysAdminUser= new User(Alias = 'std455',
                                    Email = 'test.user@intel.com',
                                    EmailEncodingKey = 'UTF-8',
                                    LastName = 'Testing', 
                                    LanguageLocaleKey = 'en_US',
                                    Core_Login_Id__c = '1234', 
                                    LocaleSidKey = 'en_US',
                                    ProfileId = sysAdminProfile .Id,Phone='8764657467',
                                    TimeZoneSidKey = 'America/Los_Angeles',
                                    UserName = 'standard123@systestorg.com');
        insert sysAdminUser;
        
        
        UserRole testuserRole = new UserRole(Name = 'UnitTest-Customer-User');
        insert testuserRole;
        
        sysAdminUser.UserRoleId = testuserRole.Id;
        update sysAdminUser;
        
        PermissionSet  pSet = [select id,label from PermissionSet where Label = 'IPS Partner FAE Permission Set'];
        
        //assign permission set to user
        PermissionSetAssignment psa = new PermissionSetAssignment(AssigneeId = sysAdminUser.id, PermissionSetId = pSet.Id);
        insert psa;
        
        System.runAs(sysAdminUser) {
            Test.startTest();            
            Case Ca =  TestUtilities.getCase(); 
            insert Ca;
            System.assert(Ca.Id != null, 'Case Record not created');
            PageReference pageRef = Page.Core_IPS_External_AttachFile_Redirect;
            Test.setCurrentPage(pageRef);
            ApexPages.CurrentPage().getparameters().put('id',Ca.id);
            ApexPages.StandardController StndContr = new ApexPages.standardController(Ca);
            Core_IPS_Ext_AttachFile_Redirect_Ctrl caseClose = new Core_IPS_Ext_AttachFile_Redirect_Ctrl(StndContr);
            Pagereference Pg = caseClose.redirectPage();
            Test.stopTest();
        }
    }
    
    
    //User With FAE Permission Set
    static testMethod Void returnToCase(){
        Profile sysAdminProfile = [select id, name from Profile where name = 'System Administrator' Limit 1];
        User sysAdminUser= new User(Alias = 'std455',
                                    Email = 'test.user@intel.com',
                                    EmailEncodingKey = 'UTF-8',
                                    LastName = 'Testing', 
                                    LanguageLocaleKey = 'en_US',
                                    Core_Login_Id__c = '1234', 
                                    LocaleSidKey = 'en_US',
                                    ProfileId = sysAdminProfile .Id,Phone='8764657467',
                                    TimeZoneSidKey = 'America/Los_Angeles',
                                    UserName = 'standard123@systestorg.com');
        insert sysAdminUser;
        
        
        UserRole testuserRole = new UserRole(Name = 'UnitTest-Customer-User');
        insert testuserRole;
        
        sysAdminUser.UserRoleId = testuserRole.Id;
        update sysAdminUser;
        
        PermissionSet  pSet = [select id,label from PermissionSet where Label = 'IPS Partner FAE Permission Set'];
        
        //assign permission set to user
        PermissionSetAssignment psa = new PermissionSetAssignment(AssigneeId = sysAdminUser.id, PermissionSetId = pSet.Id);
        insert psa;
        System.runAs(sysAdminUser){
            Test.startTest();            
            Case Ca =  TestUtilities.getCase(); 
            insert Ca;
            System.assert(Ca.Id != null, 'Case Record not created');
            PageReference pageRef = Page.Core_IPS_External_AttachFile_Redirect;
            Test.setCurrentPage(pageRef);
            ApexPages.CurrentPage().getparameters().put('id',Ca.id);
            ApexPages.StandardController StndContr = new ApexPages.standardController(Ca);
            Core_IPS_Ext_AttachFile_Redirect_Ctrl caseClose = new Core_IPS_Ext_AttachFile_Redirect_Ctrl(StndContr);
            Pagereference Pg = caseClose.returnToCasePage();
            Test.stopTest();
        }
    }
}