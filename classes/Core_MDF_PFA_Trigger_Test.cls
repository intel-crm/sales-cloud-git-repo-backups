@isTest(SeeAllData=false)
public class Core_MDF_PFA_Trigger_Test {
	// test method for data setup
    @TestSetup static void setUpData(){
        //creating system admin user
        UserRole usRole1 = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        User sysAdmUsr = Core_MDF_CCP_TestDataUtility.createUser(false);
        sysAdmUsr.LastName = 'System Adm';
        sysAdmUsr.UserRoleId=usRole1.id;
        system.runAs(sysAdmUsr){
        ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.CCF_PROGRAM,'Client CoMarketing Fund', true);
        Test.startTest();
        
        List<Account> accList = new List<Account>();
        List<Account> updateAccList = new List<Account>();        
        
        Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Account', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
        insert acc1;
        
        // Creating Co-marketing Account with utility class
        Account acc = Core_MDF_CCP_TestDataUtility.createAccount ('Test Account 1', cp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
        acc.Core_MDF_Parent_Fund_Account__c = acc1.Id;
        accList.add(acc);
        
        Account acc2 = Core_MDF_CCP_TestDataUtility.createAccount ('Test Account 2', cp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type,  false);
        acc2.Core_MDF_Parent_Fund_Account__c = acc1.Id;
        accList.add(acc2);
        
        Database.insert(accList);
        
        acc1.IsPartner = true;
        updateAccList.add(acc1);
        acc.IsPartner = true;
        updateAccList.add(acc);
        acc2.IsPartner = true;
        updateAccList.add(acc2);
        
        Database.update(updateAccList);
        
        //Creating Contact for Partner User
        Contact conRecord1 = Core_MDF_CCP_TestDataUtility.createContact(acc1.Id,true);
        Contact conRecord2 = Core_MDF_CCP_TestDataUtility.createContact(acc1.Id,true);
        Contact conRecord3 = Core_MDF_CCP_TestDataUtility.createContact(acc1.Id,true);
        
        List<Core_AGS_Role__c> agsRoleList = new List<Core_AGS_Role__c>();
        
        Core_AGS_Role__c agsRoleCCF = Core_MDF_CCP_TestDataUtility.createAgsRole('CCF_USER', 'Co-Marketing(Salesforce)-CCF USER', true, false);
        agsRoleList.add(agsRoleCCF);
        
        Core_AGS_Role__c agsRoleCCFClaimSub = Core_MDF_CCP_TestDataUtility.createAgsRole('Co-Marketing(Salesforce)-External Claim Submitter-CCF', 'Co-Marketing(Salesforce)-External Claim Submitter-CCF', true, false);
        agsRoleList.add(agsRoleCCFClaimSub);
        
        Database.insert(agsRoleList);        
        
        Core_ERPM_Engagement__c erpmEngagementCCF = Core_MDF_CCP_TestDataUtility.createErpmEngagement('CCF', 'CCF', 'DEDUPB2B', 'SEC', true, false);
        Database.insert(erpmEngagementCCF);
        
        List<Core_Entitlement__c> entitlementList = new List<Core_Entitlement__c>();
        
        Core_Entitlement__c entitlementCCF = Core_MDF_CCP_TestDataUtility.createEntitlement('Client User',agsRoleCCF.Id ,'Intel® Partner Investment Center','CCF User',erpmEngagementCCF.Id , true,Core_MDF_CCP_ConstantClass.CCF_PROGRAM,false);
        entitlementList.add(entitlementCCF);
        
        Core_Entitlement__c entitlementCCFClaimSub = Core_MDF_CCP_TestDataUtility.createEntitlement('Client Claim Submitter',agsRoleCCFClaimSub.Id ,'Intel® Partner Investment Center','CCF Claim Submitter',erpmEngagementCCF.Id , true,Core_MDF_CCP_ConstantClass.CCF_PROGRAM,false);
        entitlementList.add(entitlementCCFClaimSub);
        
        Database.insert(entitlementList); 
        
        List<Core_Contact_Entitlement__c> contEntList = new List<Core_Contact_Entitlement__c>();
        
        Core_Contact_Entitlement__c contactEntitlementCCF = Core_MDF_CCP_TestDataUtility.createContactEntitlement(conRecord1.Id,entitlementCCF.Id ,true,'Complete', false);
        contEntList.add(contactEntitlementCCF);
        
        Core_Contact_Entitlement__c contactEntitlementCCFClaimSub = Core_MDF_CCP_TestDataUtility.createContactEntitlement(conRecord1.Id,entitlementCCFClaimSub.Id ,true,'Complete', false);
        contEntList.add(contactEntitlementCCFClaimSub);
        
        Core_Contact_Entitlement__c contactEntitlementCCF2 = Core_MDF_CCP_TestDataUtility.createContactEntitlement(conRecord2.Id,entitlementCCF.Id ,true,'Complete', false);
        contEntList.add(contactEntitlementCCF2);
        
        Core_Contact_Entitlement__c contactEntitlementCCFClaimSub2 = Core_MDF_CCP_TestDataUtility.createContactEntitlement(conRecord2.Id,entitlementCCFClaimSub.Id ,true,'Complete', false);
        contEntList.add(contactEntitlementCCFClaimSub2);
 
        Database.insert(contEntList);  
        
        //Creating Case on the Account
        Case case1 = new Case(AccountId=acc.Id);
        Database.insert(case1);
        
        // Creating User with utility class 
        List<User> userList = new List<User>();
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.Email = 'sysadmin@example.com';
        userList.add(usr);
        
        User adminUser = Core_MDF_CCP_TestDataUtility.createUser(false);
        adminUser.Email = 'sysadmin1@example.com';
        userList.add(adminUser);
        
        Id profileId = [SELECT Id FROM Profile WHERE Name='Partner' limit 1].Id;
        User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);        
        usr1.Email='test1@example.com';
        usr1.ContactId = conRecord1.Id;
        usr1.ProfileId = profileId;
        usr1.isActive = true;
        userList.add(usr1);
        
        
       // userList.add(sysAdmUsr);
        Database.insert(userList);

        Core_MDF_CCP_TestDataUtility.createPartnerGroupMapping(acc1.Id,'External',acc1.Id,cp.Id,'PGM_TEST',true);
        
        List<Core_MDF_Partner_Group_Mapping__c> pgm = [Select Core_MDF_Group_Id__c from Core_MDF_Partner_Group_Mapping__c 
                                                 where Core_MDF_Account__c=:acc1.Id and Core_MDF_Type_of_Access__c='External' 
                                                 and Core_MDF_Channel_Program__c = :cp.Id limit 1];
      
        //system.runAs(sysAdmUsr){
        GroupMember gm = new GroupMember();
        gm.GroupId = pgm[0].Core_MDF_Group_Id__c;
        gm.UserOrGroupId = usr1.Id;
        insert gm;
       // }
        
        Id recordTypeIdPMB = Schema.SObjectType.PartnerMarketingBudget.getRecordTypeInfosByName().get('CoMarketing').getRecordTypeId();
        //adding bypass feature to bypass access validation
			List<String> bypassFunctionKeys = new List<String>();
            bypassFunctionKeys.add('Bypass_MDF_Budget_Access_Validation');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Status_Validation');
            bypassFunctionKeys.add('ByPass_BlockLegacyBudgetCreation');
            
            Set<String> myset1 = new Set<String>();
            List<String> result1 = new List<String>();
            myset1.addAll(bypassFunctionKeys);
            result1.addAll(myset1);
            
            List<Core_Trigger_Executions__c> bypassfunctinalitylist1 = Core_MDF_CCP_TestDataUtility.byPassFeature(result1,true,true);
        // Create PMB for the above Account 
        PartnerMarketingBudget  pmbRecord = Core_MDF_CCP_TestDataUtility.createBudget('TestPMB',RecordTypeIdPMB,acc.Id,cp.Id,123456,System.today(),Date.newInstance(System.today().year(),12,31),false);
        pmbRecord.IsIgnoreValidation = true;
        pmbRecord.Core_MDF_Budget_Type_Txt__c='CCF 1.0';
        insert pmbRecord;
        
        Test.stopTest();
        }
    }
    
    @isTest static void testPartnerFundAllocationInsertion(){

        Test.startTest();
        Account accinstance = [SELECT Id, Name FROM Account WHERE Name = 'Test Account 1' LIMIT 1];
        PartnerMarketingBudget budgetinstance = [SELECT Id FROM PartnerMarketingBudget WHERE Title = 'TestPMB' LIMIT 1];
        
        User adminUser = [SELECT Id FROM User WHERE email = 'sysadmin@example.com'];
        User adminUser1 = [SELECT Id FROM User WHERE email = 'sysadmin1@example.com'];
        
        PartnerFundAllocation pfaRecord = new PartnerFundAllocation();
        // Create PFA records.
        System.runAs(adminUser){
            pfaRecord = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('TestPFA',budgetinstance, accinstance, 1234,false);
            pfaRecord.OwnerId = adminUser.Id;
            insert pfaRecord;
            
            PartnerFundAllocationShare pfaShare = [SELECT Id,ParentId FROM PartnerFundAllocationShare WHERE ParentId =: pfaRecord.Id LIMIT 1];
            System.assertEquals(true, pfaShare != null);
        }
        
        System.runAs(adminUser1){
            pfaRecord.Title = 'PFA Update';
            pfaRecord.OwnerId = adminUser1.Id;
            pfaRecord.Amount = 1235;
        	update pfaRecord;
        }
        Test.stopTest();
    }
}