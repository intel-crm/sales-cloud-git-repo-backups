@isTest(SeeAllData=false)
public class PNUM_Dummy_Test {
    
    @TestSetup static void setUpData(){
        ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram ('Client Co-Marketing Fund','Client CoMarketing Fund', true);
        Id profileId = [SELECT Id FROM Profile WHERE Name='Partner' limit 1].Id;
        Profile ccpCoreProfile = [SELECT Id FROM Profile WHERE Name='CCP - Core Access' LIMIT 1];
        PermissionSet claimSubmitterPS = [SELECT Id, Name From PermissionSet WHERE Name='Core_MDF_CCP_External_Claim_Submitter' LIMIT 1];
        Core_Trigger_Executions__c te1 = new Core_Trigger_Executions__c();
        te1.Name = 'Core_MDF_Account_node_share';
        te1.Core_Active__c=true;
        te1.Core_Class_Name__c='Core_Account';
        te1.Core_Object__c='Account';
        te1.Core_Description__c='method is used Create PNUM based External sharing group';
        te1.Core_Trigger_Events__c='After Insert';
        database.insert(te1);
        Core_Trigger_Executions__c te2 = new Core_Trigger_Executions__c();
        te2.Name = 'Bypass_External_Group_Creation';
        te2.Core_Active__c=false;
        te2.Core_Class_Name__c='Core_AccountHandler';
        te2.Core_Object__c='Account';
        te2.Core_Description__c='method is used Create PNUM based External sharing group';
        te2.Core_Trigger_Events__c='After Insert';
        database.insert(te2);
        Core_Trigger_Executions__c te3 = new Core_Trigger_Executions__c();
        te3.Name = 'Bypass_AcctUserMapping_Obj_Share';
        te3.Core_Active__c=false;
        te3.Core_Class_Name__c='Core_MDF_PNUMappingTriggerHandler';
        te3.Core_Object__c='Core_MDF_Partner_Node_User_Mapping__c';
        te3.Core_Description__c='Bypass_AcctUserMapping_Obj_Share';
        te3.Core_Trigger_Events__c='After Insert';
        database.insert(te3);
        Account accRecord = Core_MDF_CCP_TestDataUtility.createAccount ('Intel Test Account', NULL, Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);   
        accRecord.BillingCity = 'Test City';         
        accRecord.BillingCountry= 'AUS';
        accRecord.BillingStreet= 'Test Street'; 
        Database.insert(accRecord);
        
        List<Contact> contList = new List<Contact>();
        Contact conRecord1 = Core_MDF_CCP_TestDataUtility.createContact(accRecord.Id,false);
        contList.add(conRecord1);
        Database.insert(contList);
        Test.startTest();
        Account dellCCFVirtualCorp = Core_MDF_CCP_TestDataUtility.createAccount ('Dell CCF Virtual Corp', cp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
        dellCCFVirtualCorp.Core_MDF_Parent_Fund_Account__c = accRecord.Id;
        Database.insert(dellCCFVirtualCorp);
        
        
        Core_ERPM_Engagement__c erpmEngagementCCF = Core_MDF_CCP_TestDataUtility.createErpmEngagement('CCF', 'CCF', 'DEDUPB2B', 'SEC', true, false);
        Database.insert(erpmEngagementCCF);
        
        Core_Entitlement__c entitlementCCF = Core_MDF_CCP_TestDataUtility.createEntitlement('CCF User',null ,'Consolidated Co-marketing Platform','CCF User',erpmEngagementCCF.Id , true,'Client Co-Marketing Fund (CCF)',false);
        Database.insert(entitlementCCF); 
        
        Core_Contact_Entitlement__c contactEntitlementCCF = Core_MDF_CCP_TestDataUtility.createContactEntitlement(conRecord1.Id,entitlementCCF.Id ,true,'Complete', false);
        Database.insert(contactEntitlementCCF);  
        
        // Creating User with utility class 
        List<User> usrList = new List<User>();
        
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.Email = 'sysadmin@example.com';
        usrList.add(usr);
        
        User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);        
        usr1.Email='test1@example.com';
        usr1.ContactId = conRecord1.Id;
        usr1.ProfileId = profileId;
        usr1.isActive = true;
        usrList.add(usr1);
        
        Database.insert(usrList);
        
        Group grp = new Group();
        grp.name = 'PGM_TEST';
        insert grp;
        
        system.runAs(usr){
            GroupMember gm = new GroupMember();
            gm.GroupId = grp.Id;
            gm.UserOrGroupId = usr1.Id;
            insert gm;
            
            List<PermissionSetAssignment> assignPermissionList = new List<PermissionSetAssignment>();    
            PermissionSetAssignment assignPermissionSetObj2 = new PermissionSetAssignment();
            assignPermissionSetObj2.AssigneeId = usr1.Id;
            assignPermissionSetObj2.PermissionSetId = claimSubmitterPS.Id;
            assignPermissionList.add(assignPermissionSetObj2);
            Database.insert(assignPermissionList);
            
        }
        
        
        Core_MDF_CCP_TestDataUtility.createPartnerGroupMapping(accRecord.Id,'Internal',accRecord.Id,cp.Id,'PGM_TEST',true);
        
        Core_MDF_CCP_TestDataUtility.createPartnerNodeUserMapping(dellCCFVirtualCorp.Id, Usr1.Id, true);
        Test.stopTest();
        Account acc = [Select Id,Name,Core_MDF_External_Group_Id__c from Account where Name='Dell CCF Virtual Corp' limit 1];
       system.runAs(usr){
        groupmember gm = new groupmember();
        gm.groupid=acc.Core_MDF_External_Group_Id__c;
        gm.UserOrGroupId=Usr1.Id;
        insert gm;
       }
    }
    
     @isTest static void pnumAccQuery(){
         test.startTest();
         User claimSub = [SELECT Id,Email from User where Email='test1@example.com' limit 1];
         List<core_MDF_Partner_Node_User_Mapping__c> pnum = [Select id from core_MDF_Partner_Node_User_Mapping__c where Core_MDF_user__c= :claimSub.Id];
         Account acc = [Select Id,Name,Core_MDF_External_Group_Id__c from Account where Name='Dell CCF Virtual Corp' limit 1];
         system.debug('acc  :  ' + acc);    
         system.debug('acc.ext  :  ' + acc.Core_MDF_External_Group_Id__c);
         system.debug('pnum  :  ' + pnum);
         groupMember gm = [Select id,userorgroupid from groupmember where groupid=:acc.Core_MDF_External_Group_Id__c];
         system.debug('gm '+ gm);
         system.runAs(claimSub){
             Account acc1 = [Select Id,Name from Account where Name='Dell CCF Virtual Corp' limit 1];
             system.debug('acc  :  ' + acc1);
             
         }
          Test.stopTest();
     }
}