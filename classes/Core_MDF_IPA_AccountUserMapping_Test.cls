/****************************************************************************************************************************************
* Class Name  : Core_MDF_IPA_AccountUserMapping_Test 
* Version     : 1.0 
* Created Date: 01-06-2020
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - Vaishali D        01-06-2020                   Created to test IPA Account User record creation
*****************************************************************************************************************************************/
@isTest(SeeAllData=false)
private class Core_MDF_IPA_AccountUserMapping_Test {
    private static  Account intAcc = new  Account ();
/****************************************************************************************************************************************
Method Name:    setupMethod                               
Description:                                   
Added By:                                      Accenture – VD  -  10-05-2019
Modified By:           Date:                    Changes: 
Accenture – VD       01-06-2020               Created.
*****************************************************************************************************************************************/       
    @TestSetup static void setupMethod(){
        List<Account> acctList = new List<Account>();
        
        // Creating IntelAccount with utility class
        intAcc = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Test Intel Account',Core_MDF_CCP_TestDataUtility.intel_Account_Record_Type, false);
        //intAcc.Core_Account_Type__c = 'Reseller';
        //intAcc.Core_Sales_Groups__c = 'Automotive Sales Group';
        //intAcc.Industry = 'Food & Beverage';
        acctList.add(intAcc);
        
        Account intAcc2 = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Test Intel Account2',Core_MDF_CCP_TestDataUtility.intel_Account_Record_Type, false);
        //intAcc2.Core_Account_Type__c = 'Reseller';
        //intAcc2.Core_Sales_Groups__c = 'Automotive Sales Group';
        //intAcc2.Industry = 'Food & Beverage';
        acctList.add(intAcc2);
        
        Database.insert(acctList);
        
        intAcc.Core_MDF_CoMarketingActive__c = true;
        Database.update(intAcc);
        
        List<Contact> contList = new List<Contact>();
        
        //creating contact with utility class
        Contact con = Core_MDF_CCP_TestDataUtility.createContact(intAcc.Id, false);
        con.RecordTypeId = Core_MDF_CCP_TestDataUtility.Intel_Contact_Record_Type;
        con.LastName='Contact1';
        con.Email='cont1@example.com';
        contList.add(con);
        
        //creating contact with utility class
        Contact con2 = Core_MDF_CCP_TestDataUtility.createContact(intAcc2.Id, false);
        con2.RecordTypeId = Core_MDF_CCP_TestDataUtility.Intel_Contact_Record_Type;
        con2.LastName='Contact2';
        con2.Email='cont2@example.com';
        contList.add(con2);
        
        Database.insert(contList);
        // Highlight: Unused Local Variable 
      //  List<Core_AGS_Role__c> agsRoleList = new List<Core_AGS_Role__c>();
        
        Core_AGS_Role__c agsRoleIPA = Core_MDF_CCP_TestDataUtility.createAgsRole('IPA_USER', 'Co-Marketing(Salesforce)-IPA USER', true, true);
        
        Core_ERPM_Engagement__c erpmEngagementIPA = Core_MDF_CCP_TestDataUtility.createErpmEngagement('Intel Partner Alliance', 'IPA', '', '', true, true);
        
        Core_Entitlement__c entitlementIPA = Core_MDF_CCP_TestDataUtility.createEntitlement('IPA-MP User',agsRoleIPA.Id ,'Intel Partner Alliance (IPA)','CCF User',erpmEngagementIPA.Id , true,'Solutions Marketplace',true);
        
        List<Core_Contact_Entitlement__c> contactEntitlementList = new List<Core_Contact_Entitlement__c>();
        Core_Contact_Entitlement__c contactEntitlementIPA = Core_MDF_CCP_TestDataUtility.createContactEntitlement(con.Id,entitlementIPA.Id ,true,'Complete', false);
        Core_Contact_Entitlement__c contactEntitlementIPA1 = Core_MDF_CCP_TestDataUtility.createContactEntitlement(con2.Id,entitlementIPA.Id ,true,'Complete', false);
        contactEntitlementList.add(contactEntitlementIPA);
        contactEntitlementList.add(contactEntitlementIPA1);
        Database.insert(contactEntitlementList);
        
        // Creating channel program with utility class
        ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram ('Intel Partner Alliance','Intel Partner Alliance', true);
        Profile partnerProfile = [SELECT Id FROM Profile WHERE Name = 'Partner' LIMIT 1];
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        
        List<User> usrlist = new List<User>();
        
        // Creating User with utility class
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test';
        usr.ProfileId = partnerProfile.Id;
        usr.ContactId = con.Id;
        usr.isActive = true;
        usrlist.add(usr);       
        
        // Creating User with utility class
        User usr2 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr2.LastName = 'User Test2';
        usr2.ProfileId = partnerProfile.Id;
        usr2.ContactId = con2.Id;
        usr2.isActive = true;
        usrlist.add(usr2);
        
        Database.insert(usrlist);
        
        User usr3 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr3.LastName = 'System Adm';
        usr3.ProfileId = sysAdminProfile.Id;
        usr3.isActive = true;
        usr3.Email = 'systemadm@example.com';
        Database.insert(usr3);               
        
        //Creating Groups
        Group grp1 = new Group();
        grp1.Name = 'Test_V_External1';
        grp1.DeveloperName = 'Test_V_External1';
        Database.insert(grp1);
        
        system.runas(usr3){
            // Creating Group Members
            GroupMember grpMember = new GroupMember();
            grpMember.UserOrGroupId = usr.Id;
            grpMember.GroupId = grp1.Id;
            
            GroupMember grpMember2 = new GroupMember();
            grpMember2.UserOrGroupId = usr2.Id;
            grpMember2.GroupId = grp1.Id;
            
            List<GroupMember> lstGrpMember = new List<GroupMember>();
            lstGrpMember.add(grpMember);
            lstGrpMember.add(grpMember2);
            
            Database.insert(lstGrpMember);
        }

        List<Core_MDF_Partner_Group_Mapping__c> pgmlist = new List<Core_MDF_Partner_Group_Mapping__c>();
        
        Core_MDF_Partner_Group_Mapping__c pgm1 = new Core_MDF_Partner_Group_Mapping__c();
        pgm1.Core_MDF_Account__c = intAcc.Id;
        pgm1.Core_MDF_Type_of_Access__c = 'External';
        pgm1.Core_MDF_Channel_Program__c = cp.Id;
        pgm1.Core_MDF_Group_Name__c = 'Test_V_External1';
        pgmlist.add(pgm1);
        
        Core_MDF_Partner_Group_Mapping__c pgm2 = new Core_MDF_Partner_Group_Mapping__c();
        pgm2.Core_MDF_Account__c = intAcc2.Id;
        pgm2.Core_MDF_Type_of_Access__c = 'External';
        pgm2.Core_MDF_Channel_Program__c = cp.Id;
        pgm2.Core_MDF_Group_Name__c = 'Test_V_External1';
        pgmlist.add(pgm2);
        
        database.insert(pgmlist);
        
        // Creating Top virtual Account with utility class
        Account acc = Core_MDF_CCP_TestDataUtility.createAccount('Test Account', cp.Id,Core_MDF_CCP_TestDataUtility.account_Record_Type, false);
        acc.Core_MDF_Parent_Fund_Account__c = intAcc.Id;
        Database.insert(acc);  
        
        Account acc2 = Core_MDF_CCP_TestDataUtility.createAccount('Test Account22', cp.Id,Core_MDF_CCP_TestDataUtility.account_Record_Type, false);
        acc2.Core_MDF_Parent_Fund_Account__c = intAcc.Id;
        Database.insert(acc2);
    }
    
    /****************************************************************************************************************************************
Method Name:                                   creatingPnumTest
Description:                                   
Added By:                                      Accenture – VD  -  01-06-2020
Modified By:                  Date:            Changes: 
Accenture – VD              01-06-2020         Created.
*****************************************************************************************************************************************/     
    @isTest static void creatingPnumTest(){
        
        User usr=[SELECT Id FROM User WHERE Email='systemadm@example.com' LIMIT 1];
        // Highlight: Unused Local Variable
       // Account intAcc = [Select Id from Account where Name = 'Test Intel Account' LIMIT 1];
        Contact cont = [select id from Contact where email='cont1@example.com' LIMIT 1 ];        
        Contact cont2 = [select id from Contact where email='cont2@example.com' LIMIT 1 ];
        
        Core_Contact_Entitlement__c contEnt = [select id,Core_Entitlement_Id__r.Name from Core_Contact_Entitlement__c where Core_Contact_Id__c=:cont.Id];
        Account acct = [select id from account where name ='Test Account'];
        User usr1 = [select id from user where contactId=:cont.Id];
        User usr2 = [select id from user where contactId=:cont2.Id];
        Group grp = [select id from group where developername='Test_V_External1'];
        
        List<id> grpId = new List<Id>();
        Map<Id,List<Id>> userGrpIdListMap = new Map<Id,List<Id>>();
        
        grpId.add(grp.id);
        userGrpIdListMap.put(usr1.id,grpId);
        userGrpIdListMap.put(usr2.id,grpId);
         GroupMember grpMember2 = new GroupMember();
            grpMember2.UserOrGroupId = usr2.Id;
            grpMember2.GroupId = grp.Id;
        insert grpMember2;
        
        Map<Id,Id> userIdToCorpIdMap = new Map<Id,Id>();
        userIdToCorpIdMap.put(usr1.id,acct.id);
        Map<Id,Id> user2ToCorpIdMap = new Map<Id,Id>();

        system.runas(usr){ 
            Test.startTest();            
            assert.areEqual('IPA-MP User',contEnt.Core_Entitlement_Id__r.Name,'true');            
            System.enqueueJob(new Core_MDF_IPA_AccountUserMapping(userIdToCorpIdMap)); 
            
              System.enqueueJob(new Core_MDF_IPA_AccountUserMapping(user2ToCorpIdMap)); 
         
            Test.stopTest();
        }
    }
}