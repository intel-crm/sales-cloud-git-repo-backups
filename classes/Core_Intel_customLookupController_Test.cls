/***************************************************************************************************** 
Class Name :    Core_Intel_customLookupController_Test
Description:    This is the test class for Core_Intel_customLookupController class
Added By   :    Accenture - SKS 
Modified By:                      Date:07/31/2018                     Changes:None  
******************************************************************************************************/    
@isTest
public class Core_Intel_customLookupController_Test{
    
    @TestSetup static void createTestData(){
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test';
        usr.UserRoleId = usRole.Id;
        Database.insert(usr);
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_CCF_MDF_Budget_Loader' LIMIT 1];
        insert new PermissionSetAssignment(AssigneeId = usr.id, PermissionSetId = ps.Id);
        
        System.runAs(usr){
            Profile ccpCoreAccessProfile = [SELECT Id FROM Profile WHERE Name='CCP - Core Access' LIMIT 1];
            Profile partnerProfile = [SELECT Id FROM Profile WHERE Name='Partner' LIMIT 1];
            PermissionSet aacntMngrPS = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_Internal_CCF_Acct_Mgr' LIMIT 1];
            User ccfaccntmngr = Core_MDF_CCP_TestDataUtility.createUser(false);
            ccfaccntmngr.Email = 'ccfaccntmngr@example.com';
            ccfaccntmngr.Profile = ccpCoreAccessProfile;
            PermissionSetAssignment assignPermissionSetObj = new PermissionSetAssignment();
            
            assignPermissionSetObj.AssigneeId = ccfaccntmngr.Id;
            assignPermissionSetObj.PermissionSetId = aacntMngrPS.Id;
            Database.insert(ccfaccntmngr);
            
            ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram ('Client','Client CoMarketing Fund', true);
            
            Account accIntel = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Acc New 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
            
            Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Account 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
            Account accCoMarketing = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account 2', cp.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc1.Id, false);
            accCoMarketing.Core_MDF_Parent_Fund_Account__c = accIntel.Id;
            accCoMarketing.Core_MDF_CoMarketing_Ultimate_Account__c = accIntel.Id;
            Database.insert(accCoMarketing);
            accCoMarketing.IsPartner = true;
            Database.update(accCoMarketing); 
            
            Account acc3 = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Account 5', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
            Account acc4 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account 6', cp.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc3.Id, true);
            Database.update(acc4);
            
            
            UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
            Contact con = Core_MDF_CCP_TestDataUtility.createContact (acc1.Id, false);
            con.RecordTypeId = Core_MDF_CCP_TestDataUtility.Intel_Contact_Record_Type;
            insert con;
            
            User usr2 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr2.LastName = 'User Test2';
            usr2.email='ccfexternalmangr@example.com';
            usr2.ProfileId = partnerProfile.id;
            usr2.ContactId = con.Id;
            Database.insert(usr2);
            PermissionSetAssignment assignPermissionSetObj2 = new PermissionSetAssignment();
            
            assignPermissionSetObj2.AssigneeId = usr2.Id;
            assignPermissionSetObj2.PermissionSetId = aacntMngrPS.Id;
            
            List<String> bypassFunctionKeys = new List<String>();
            bypassFunctionKeys.add('Bypass_MDF_Budget_Status_Validation');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Access_Validation');
            bypassFunctionKeys.add('Bypass_ValidateActivityWithCampaign');
            bypassFunctionKeys.add('Bypass_Duplicate_Budget_Check');
            bypassFunctionKeys.add('Bypass_GeoBased_Budget_Sharing');
            bypassFunctionKeys.add('Bypass_GeoBased_Allocation_Sharing');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Access');
            bypassFunctionKeys.add('ShareActivityWithInternalUsers_Bypass');
            bypassFunctionKeys.add('Bypass_Allocation_Reservation');
            bypassFunctionKeys.add('byPassShareUnshareCampaignRecord');
            bypassFunctionKeys.add('byPassCampaignAndRelatedRecords');
            bypassFunctionKeys.add('Bypass_UpdateActivityFields');
            
            Set<String> myset1 = new Set<String>();
            List<String> result1 = new List<String>();
            myset1.addAll(bypassFunctionKeys);
            result1.addAll(myset1);
            List<Core_Trigger_Executions__c> bypassfunctinalitylist1 = Core_MDF_CCP_TestDataUtility.byPassFeature(result1,true,true);
            
            
        }
        
    }
    
@isTest
    private static void testfetchLookUpValues(){
        Test.startTest();
        User user1 = [select id,email from User where email='ccfaccntmngr@example.com' limit 1];
        System.runAs(user1){
            Account accCoMarketing = [select id from Account WHERE Name = 'Test Account 2'];
            Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 12','Gaming','Intel® Core™ i7 Processor','CMP Only', Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', System.today().addDays(2), System.today().addDays(346), 10000, 'Always Connected PC',accCoMarketing.Id,'Laptop',false); 
            camp.Core_MDF_External_Visibility_Date__c = System.today();
            //camp.Core_MDF_Opal_Budget_Type_Txt__c = 'OEM CMP';
            insert camp;
            String searchKeyWord ='Test Camp 12',  objectName='Campaign', sAdditionalFilter='startDate = 2023-03-27';
            List < sObject > result = Core_Intel_customLookupController.fetchLookUpValues (searchKeyWord,objectName,sAdditionalFilter);
            Assert.areNotEqual(null,result); 
        }
        Test.stopTest();
    } 
    
    
    @isTest
    private static void testfetchLookUpValuesExt1() {
        Test.startTest();
        User usr2=[select id,email from User where email='ccfexternalmangr@example.com' limit 1];
        
        system.runAs(usr2){
            List < sObject > result = Core_Intel_customLookupController.fetchLookUpValues ('Test Camp 12', 'Campaign',' startDate=2018-07-25');
            result = Core_Intel_customLookupController.fetchLookUpValues ('Test Account 10', 'Account',' Name!=null ');
            Assert.areNotEqual(null,result); 
        }
        
        Test.stopTest();
        
        
    }
    
    @isTest
    private static void testfetchLookUpValues2(){
        test.startTest();
        User usr2 = [select id,LastName from User where LastName='User Test2' limit 1];
        List<string> userNameList = new List<string>(); 
        System.runAs(usr2){
            String searchKeyWord ='Dell CCF Virtual Corp',  objectName='Account', sAdditionalFilter='isPartner=true';
            List < sObject > result = Core_Intel_customLookupController.fetchLookUpValues (searchKeyWord,objectName,sAdditionalFilter);
            result = Core_Intel_customLookupController.fetchLookUpValues ('Test','User','IsActive=true');
            test.stopTest();
            if(!result.isEmpty()){
                for(sObject obj: result){
                    User usr = (User)obj;
                    userNameList.add(usr.Name);
                }
            }
            
            Assert.isTrue(userNameList.contains('Test User Test')); 
        }
        
        
    } 
    
    @isTest
    private static void testfetchLookUpValues3(){
        test.startTest();
        User user1 = [select id,email from User where email='ccfaccntmngr@example.com' limit 1];
        System.runAs(user1){
            Account accCoMarketing = [select id from Account WHERE Name = 'Test Account 6'];
            Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 15','Gaming','Intel® Core™ i7 Processor','CMP Only', Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', System.today().addDays(2), System.today().addDays(346), 10000, 'Always Connected PC',accCoMarketing.Id,'Laptop',false); 
            camp.Core_MDF_External_Visibility_Date__c= System.today();
            //camp.Core_MDF_Opal_Budget_Type_Txt__c = 'OEM CMP';
            insert camp;
            
            String searchKeyWord ='Test Camp 13',  objectName='Campaign', sAdditionalFilter='';
            List < sObject > result = Core_Intel_customLookupController.fetchLookUpValues (searchKeyWord,objectName,sAdditionalFilter);
            Assert.areNotEqual(null,result); 
        }           
        
        test.stopTest();
        
    }
    @isTest
       private static void testFetchWithAccountPowerPartner() {
        ChannelProgram cp = [Select Id from ChannelProgram Where Name = 'Client' limit 1];
        Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Account', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
        acc1.BillingStateCode = '';
        insert acc1;
        List<Account> accList = new List<Account>();
        // Creating Co-marketing Account with utility class
        Account acc = Core_MDF_CCP_TestDataUtility.createAccount ('Test Account 1', cp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
        acc.Core_MDF_Parent_Fund_Account__c = acc1.Id;
        accList.add(acc);
        Database.insert(accList);
         
        Contact conRecord1 = Core_MDF_CCP_TestDataUtility.createContact(acc1.Id,true);
        
        List<User> userList = new List<User>();
        Id profileId = [SELECT Id FROM Profile WHERE Name='Partner' limit 1].Id;
        User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);        
        usr1.Email='test1@example.com';
        usr1.ContactId = conRecord1.Id;
        usr1.ProfileId = profileId;
        usr1.isActive = true;
        userList.add(usr1);
        Database.insert(userList);
           
        //Core_MDF_Partner_Node_User_Mapping__c pnumRecord = Core_MDF_CCP_TestDataUtility.createPartnerNodeUserMapping(acc.Id,usr1.Id,true);

        Test.startTest();
        List<sObject> results = Core_Intel_customLookupController.fetchLookUpValues('Test', 'Account', 'Core_MDF_Channel_Program__c != null');
        Test.stopTest();

        System.assertNotEquals(null, results);
    }
    
}