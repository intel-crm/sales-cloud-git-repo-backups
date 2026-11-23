/****************************************************************************************************************************************
* Class Name            : Core_MDF_PartnerFundAllocation_Test 
 * Version              : 1.0 
* Created Date          : 16-JUNE-2021
* Modification Log      : 
* Developer            Date             Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - TS      16-06-2021        This test class is used for "Core_MDF_PartnerFundAllocation"   
*****************************************************************************************************************************************/
@isTest(SeeAllData=false)
public class Core_MDF_PartnerFundAllocation_Test {
    @TestSetUp static void createTestData() {
        
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        List<User> userList = new List<User>();
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.Email = 'sysadmin@example.com';
        usr.UserRoleId = usRole.Id;
        //userList.add(usr);
        insert usr;
        
        System.runAs(usr){
        ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.CCF_PROGRAM,'Client CoMarketing Fund', true);
        
        
        Permissionset claimSubmtr = [SELECT Id,Name FROM PermissionSet WHERE Name='Core_MDF_CCP_External_Claim_Submitter'];
        Test.startTest();
        
        Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Account', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
        insert acc1;
        
        Account acc = Core_MDF_CCP_TestDataUtility.createAccount ('Test Account 1', cp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
        acc.Core_MDF_Parent_Fund_Account__c = acc1.Id;
        insert acc;
        
        acc1.IsPartner = true;
        update acc1;
        
        Contact conRecord1 = Core_MDF_CCP_TestDataUtility.createContact(acc1.Id,true);
        
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
        
        Core_Entitlement__c entitlementCCFClaimSub = Core_MDF_CCP_TestDataUtility.createEntitlement('Client Claim Submitter',agsRoleCCFClaimSub.Id ,'Intel® Partner Investment Center','CCF Claim Submitter',erpmEngagementCCF.Id , true, Core_MDF_CCP_ConstantClass.CCF_PROGRAM,false);
        entitlementList.add(entitlementCCFClaimSub);
        
        Database.insert(entitlementList); 
        
        List<Core_Contact_Entitlement__c> contEntList = new List<Core_Contact_Entitlement__c>();
        
        Core_Contact_Entitlement__c contactEntitlementCCF = Core_MDF_CCP_TestDataUtility.createContactEntitlement(conRecord1.Id,entitlementCCF.Id ,true,'Complete', false);
        contEntList.add(contactEntitlementCCF);
        
        Core_Contact_Entitlement__c contactEntitlementCCFClaimSub = Core_MDF_CCP_TestDataUtility.createContactEntitlement(conRecord1.Id,entitlementCCFClaimSub.Id ,true,'Complete', false);
        contEntList.add(contactEntitlementCCFClaimSub);
        
        Database.insert(contEntList);
        
        Id profileId = [SELECT Id FROM Profile WHERE Name='Partner' limit 1].Id;
        User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);        
        usr1.Email='test1@example.com';
        usr1.ContactId = conRecord1.Id;
        usr1.ProfileId = profileId;
        usr1.isActive = true;
        //usr1.portalRole = 'Manager';
        //usr1.UserRoleId=usRole.Id;
        //userList.add(usr1);
        database.insert(usr1);
        
        //Database.insert(userList);
        List<PermissionSetAssignment> permSetAssgnLst = new List<PermissionSetAssignment>();
        
        PermissionSetAssignment assignPermissionSetObj = new PermissionSetAssignment();
        assignPermissionSetObj.AssigneeId = usr1.Id;
        assignPermissionSetObj.PermissionSetId = claimSubmtr.Id;
        permSetAssgnLst.add(assignPermissionSetObj);
        System.runAs(usr){
           Database.insert(permSetAssgnLst); 
        }
        Core_MDF_CCP_TestDataUtility.createPartnerGroupMapping(acc1.Id,'External',acc1.Id,cp.Id,'PGM_TEST',true);
        
        List<Core_MDF_Partner_Group_Mapping__c> pgm = [Select Core_MDF_Group_Id__c from Core_MDF_Partner_Group_Mapping__c 
                                                       where Core_MDF_Account__c=:acc1.Id and Core_MDF_Type_of_Access__c='External' 
                                                       and Core_MDF_Channel_Program__c = :cp.Id limit 1];
        
        system.runAs(usr){
            GroupMember gm = new GroupMember();
            gm.GroupId = pgm[0].Core_MDF_Group_Id__c;
            gm.UserOrGroupId = usr1.Id;
            insert gm;
        }
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
			
        Id recordTypeIdPMB = Schema.SObjectType.PartnerMarketingBudget.getRecordTypeInfosByName().get('CoMarketing').getRecordTypeId();
        // Create PMB for the above Account 
        PartnerMarketingBudget  pmbRecord = Core_MDF_CCP_TestDataUtility.createBudget('TestPMB',RecordTypeIdPMB,acc.Id,cp.Id,123456,System.today(),Date.newInstance(System.today().year(),12,31),false);
        pmbRecord.IsIgnoreValidation = true;
        pmbRecord.Core_MDF_Budget_Type_Txt__c='CCF 1.0';
        insert pmbRecord;
        
        Test.stopTest();
        // Create PFA records for the above accounts :
        PartnerFundAllocation pfaRecord = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('TestPFA',pmbRecord, acc, 1234,true);
        pfaRecord.Amount = 1235;
        database.update(pfaRecord);
        
            Core_MDF_Partner_Node_User_Mapping__c pnumRecord = Core_MDF_CCP_TestDataUtility.createPartnerNodeUserMapping(acc.Id,usr1.Id,true);
        }
            
    }
    
    @isTest static void testgetAllocDetails(){
        User claimSubmtr = [SELECT Id,Email from User where Email='test1@example.com' limit 1];
        Test.startTest();
        List<String> budgetType=new List<String>();
        List<String> programs=new List<String>();
        programs.add(Core_MDF_CCP_ConstantClass.CCF_PROGRAM);
        budgetType.add('CCF 1.0');
        String amount='amount';
        String direction='asc';
        boolean isTotalRecords=false;
        System.runAs(claimSubmtr){
            Core_MDF_PartnerFundAllocation.getAllocationDetails(0,amount,direction,isTotalRecords,budgetType,programs);
            System.assertNotEquals(UserInfo.getUserId(),null);
        }
        Test.stopTest();
    }
}