/****************************************************************************************************************************************
* Class Name  : Core_MDF_SearchAccountController_Test 
* Version     : 1.0 
* Created Date: 07-06-2019
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - Vaishali D        10-06-2019                   Created to test search account
*****************************************************************************************************************************************/
@isTest(SeeAllData=false)
private class Core_MDF_SearchAccountController_Test {
/****************************************************************************************************************************************
Method Name:    setupMethod                                   
Description:    Method created to create setup data.                               
Added By:       Accenture – VD  -  07-06-2019
Modified By:           Date:                    Changes: 
Accenture – VD        07-06-2019                Created.
*****************************************************************************************************************************************/       
    @TestSetup static void setupMethod(){
        //Role
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1];
        // Creating User with utility class 
        User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr1.profileId = sysAdminProfile.Id;
        usr1.UserRoleId = usRole.Id;
        Database.insert(usr1);
        
        //Running as System Admin
        System.runAs(usr1){
            // Creating channel program with utility class
            ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.CCF_PROGRAM,'Client CoMarketing Fund', true);
            
            // Creating IntelAccount with utility class
            Account intAcc = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Test Intel Account',Core_MDF_CCP_TestDataUtility.intel_Account_Record_Type, false);
            intAcc.Core_Account_Type__c = 'Reseller';
            intAcc.Industry = 'Food & Beverage';
            Database.insert(intAcc);
            
            //Creating Contact on above account
            Contact cont = Core_MDF_CCP_TestDataUtility.createContact(intAcc.Id,false);
            cont.RecordTypeId = Core_MDF_CCP_TestDataUtility.Intel_Contact_Record_Type;
            cont.Email = 'test123@dell.com';
            Database.insert(cont);
            
            //Creating Partner Profile
            Profile partnerProfile = [SELECT Id FROM Profile WHERE Name='Partner' LIMIT 1];
            
            //Creating user for above contact
            User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr.LastName = 'User Test1';
            usr.ProfileId = partnerProfile.Id;
            usr.Email = 'test123@dell.com';
            usr.ContactId = cont.Id;
            Database.insert(usr);
            
            //Creating Group
            Group ccfgrp = new Group();
            ccfgrp.Name = 'Core CCP CCF External';
            ccfgrp.DeveloperName = 'Core_CCP_CCF_External';
            Database.insert(ccfgrp);
            
            // Creating Group Member
            GroupMember ccfGrpMem = new GroupMember();
            ccfGrpMem.UserOrGroupId = usr.Id;
            ccfGrpMem.GroupId = ccfgrp.Id;
            Database.insert(ccfGrpMem);
            
            // Creating Partner Group Mapping
            Core_MDF_Partner_Group_Mapping__c pgm = new Core_MDF_Partner_Group_Mapping__c();
            pgm.Core_MDF_Account__c = intAcc.Id;
            pgm.Core_MDF_Group_Name__c = 'Core_CCP_CCF_External';
            pgm.Core_MDF_Type_of_Access__c = 'External';
            pgm.Core_MDF_Group_Id__c = ccfgrp.Id;                
            pgm.Core_MDF_Channel_Program__c = cp.Id;
            Database.insert(pgm);
            
            // Creating Partner Group Domain Mapping
            Core_MDF_Partner_Group_Domain_Mapping__c pgdm = new Core_MDF_Partner_Group_Domain_Mapping__c();
            pgdm.Name = 'dell.com';
            pgdm.Core_MDF_Active_Ind__c = true;
            pgdm.Core_MDF_Partner_Group_Mapping_Id__c = pgm.id;
            Database.insert(pgdm);
        }
    }
/****************************************************************************************************************************************
Method Name:    fectchAccountAndSaveContact                                   
Description:    Method created to check search account functionality                            
Added By:       Accenture – VD  -  07-06-2019
Modified By:           Date:                    Changes: 
Accenture – VD        07-06-2019                Created.
*****************************************************************************************************************************************/       
    @isTest static void fectchAccountAndSaveContact(){
        
         Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1];
        // Creating User with utility class 
        User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
        UserRole ur = [Select Id, Name From UserRole WHERE Name = 'Admin' LIMIT 1];
        usr1.UserRoleId =ur.Id ;
        usr1.profileId = sysAdminProfile.Id;
        Database.insert(usr1);
        System.runAs(usr1){
        
        Account act = [Select Name from Account where Name='Test Intel Account'];
        User usr=[Select LastName from User where LastName='User Test1'];
        Boolean isContactSaved = Core_MDF_SearchAccountController.saveContact(usr.Id,'test','Mr.','1234567890','Cont1','Test1','1234567098','cont1test1@dell.com','India','',act.Id);
        List<Account> acctList = Core_MDF_SearchAccountController.fetchAccountList(usr.Id,'Corporate');
        assert.areEqual(act, acctList[0]);
        List<Account> acctLists = Core_MDF_SearchAccountController.fetchAccountList(usr.Id,'Agency');        
        List<String> strList = new list<String>{'Salutation'};
        List<Core_MDF_SearchAccountController.PickListValueWrapper> picklstWrapper = Core_MDF_SearchAccountController.fetchPicklistValues(strList);
        }
    }
}