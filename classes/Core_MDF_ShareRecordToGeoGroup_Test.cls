/**************************************************************************************
Apex Class Name:  Core_MDF_ShareRecordToGeoGroup_Test 
Version     : 1.0 
Created Date: 02 08 2018
Function    : Test class for the Core_MDF_ShareRecordToGeoGroup used for Program and geo based sharing.
Author      : Sarah Manuel
Modification Log :
* Change#           Author                   Date                   Description
* ----------------------------------------------------------------------------                 
* Core MDF Rel1   Sarah Manuel         22/10/2019              Original Version
*
*************************************************************************************/
@isTest(SeeAllData=false) 
public class Core_MDF_ShareRecordToGeoGroup_Test {
    
    
    @isTest static void validateShareRecordToGeoGroup(){
        List<Account> toBeUpdated = new List<Account>();
        List<Account> toBeInserted = new List<Account>();
        // Creating Account with utility class
       
        Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Account 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
        acc1.Core_Geo__c='ASMO';
        acc1.Core_Sub_Geo__c='LAR';
        toBeInserted.add(acc1);
        Account acc3 = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Account 3', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
        acc3.Core_Geo__c='APJ';
        toBeInserted.add(acc3);
        Database.insert(toBeInserted);
        
        Contact conRecord1 = Core_MDF_CCP_TestDataUtility.createContact(acc1.Id,true);
        
        Group newGroup = new Group();
        newGroup.Name = 'IPA Test Group';
        newGroup.DeveloperName = 'IPA_Test_Group';
        Database.insert(newGroup);
        
        
        
        // Creating channel program with utility class
        ChannelProgram cp1 = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.RMF_PROGRAM,'Retail Marketing Funds', true);
        ChannelProgram cp2 = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.CCF_PROGRAM,'Client CoMarketing Fund', true);
        ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.IPA_PROGRAM,'Intel Partner Alliance', true);
        
        Core_MDF_Partner_Group_Mapping__c pgm1 = new Core_MDF_Partner_Group_Mapping__c();
        pgm1.Core_MDF_Account__c = acc1.Id;
        pgm1.Core_MDF_Type_of_Access__c = 'External';
        pgm1.Core_MDF_Channel_Program__c = cp.Id;
        pgm1.Core_MDF_Group_Name__c = 'IPA_Test_Group';
        Database.insert(pgm1);
        
        List<String> bypassFunctionKeys = new List<String>();
            bypassFunctionKeys.add('Bypass_Duplicate_Budget_Check');
            //bypassFunctionKeys.add('Bypass_GeoBased_Budget_Sharing');
            bypassFunctionKeys.add('Bypass_Allocation_Reservation');
            bypassFunctionKeys.add('Bypass_GeoBased_Allocation_Sharing');
            bypassFunctionKeys.add('Bypass_Duplicate_Bank_Check');
            //bypassFunctionKeys.add('Bypass_Bank_Internal_Sharing');
            bypassFunctionKeys.add('Bypass_Bank_External_Sharing');
            bypassFunctionKeys.add('Bypass_Bank_ABM_Sharing');
            bypassFunctionKeys.add('Bypass_ABM_Internal_Sharing');
            //bypassFunctionKeys.add('Bypass_ABM_External_Sharing');
            bypassFunctionKeys.add('Bypass_ABM_NodeGroup_Sharing');        
            //bypassFunctionKeys.add('byPassShareUnshareCampaignRecord');
            bypassFunctionKeys.add('byPassCampaignAndRelatedRecords');
            bypassFunctionKeys.add('Bypass_PaymentRun_Duplicate_Check');
            bypassFunctionKeys.add('Bypass_Claims_Duplicate_Check');
            //bypassFunctionKeys.add('Bypass_Claims_Sharing_Internal_Users');
            //bypassFunctionKeys.add('Bypass_ClaimAdjReq_Share_On_Owner_Chng');
            //bypassFunctionKeys.add('Bypass_ClaimAdjReq_Share_Internal_Usrs');
            bypassFunctionKeys.add('Bypass_Claims_Amt_vs_Budget_Amt_Check');        
            bypassFunctionKeys.add('Bypass_Claims_ABM_Validation');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Access_Validation');
            bypassFunctionKeys.add('Bypass_Payment_Doc_InvFileVAT_Validate');
            bypassFunctionKeys.add('Bypass_Bank_Program_InActivation_Check');
            bypassFunctionKeys.add('Core_MDF_Bypass_Manual_Share');
            bypassFunctionKeys.add('ByPass_BlockLegacyBudgetCreation');
  
            List<Core_Trigger_Executions__c> bypassfunctinalitylist = Core_MDF_CCP_TestDataUtility.byPassFeature(bypassFunctionKeys,true,true);
           Core_Trigger_Executions__c accountShareSetting = new Core_Trigger_Executions__c();
            accountShareSetting.Core_Active__c = false;
            accountShareSetting.Core_Class_Name__c = 'Core_MDF_Payment_Sharing';
            accountShareSetting.Core_Trigger_Events__c = 'after insert';
            accountShareSetting.Core_Object__c = 'Core_MDF_Payment__c';
            accountShareSetting.Name = 'Bypass_PaymentsBulkAPISharing';
            accountShareSetting.Core_Description__c = 'test';
            insert accountShareSetting;
        Account acc2 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account 2', cp1.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc1.Id, false);
                
        Account acc5 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account 5', cp2.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc1.Id, false);
        
        Account acc6 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account 3', cp.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc1.Id, false);
        //Account acc4 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account 4', cp1.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc3.Id, false);
        // Updating Accounts 
        acc1.isPartner = true;
        //acc1.Core_Geo__c='ASMO';
        //acc1.Core_Sub_Geo__c='LAR';
        database.update(acc1);
        acc2.Core_MDF_CoMarketingActive__c = true;
        acc2.Core_Geo__c='ASMO';
        acc2.Core_Sub_Geo__c='LAR';
        acc5.Core_MDF_CoMarketingActive__c = true;
      //acc4.Core_Geo__c='EMEA';
        //toBeUpdated.add(acc1);
        toBeUpdated.add(acc2);
        toBeUpdated.add(acc5);
        toBeUpdated.add(acc6);
        //toBeUpdated.add(acc4);
        Database.insert(toBeUpdated);
        
        Account acc4 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account 4', cp1.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc3.Id, false);
        acc4.Core_Geo__c='APJ';
        database.insert(acc4);
        
        Core_AGS_Role__c agsRoleCCF = Core_MDF_CCP_TestDataUtility.createAgsRole('IPA_MDF_USER', 'Co-Marketing(Salesforce)-IPA MDF USER', true, false);
        
        Core_ERPM_Engagement__c erpmEngagementIPA = Core_MDF_CCP_TestDataUtility.createErpmEngagement('IPA', 'IPA', 'DEDUPB2B', 'SEC', true, false);
        Database.insert(erpmEngagementIPA);
        
        Core_Entitlement__c entitlementIPA = Core_MDF_CCP_TestDataUtility.createEntitlement('IPA MDF User',agsRoleCCF.Id ,'Pricing','IPA MDF User',erpmEngagementIPA.Id , true,'Solutions Marketplace',false);
        Database.insert(entitlementIPA); 
        
        Core_Contact_Entitlement__c contactEntitlementIPA = Core_MDF_CCP_TestDataUtility.createContactEntitlement(conRecord1.Id,entitlementIPA.Id ,true,'Complete', false);
        Database.insert(contactEntitlementIPA);    
        
        
        
        PartnerMarketingBudget pmb1 = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget 1', Core_MDF_CCP_TestDataUtility.Budget_Record_Type, acc2.Id, cp1.Id, 3000, System.Today(), System.Today().addDays(10), true);
        
        //test.stopTest();
        // Creating Account with utility class
        /*Account acc3 = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Account 3', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
        //acc3.isPartner = true;
        acc3.Core_Geo__c='EMEA';
        acc3.Core_MDF_CoMarketingActive__c = true;
        Database.insert(acc3);*/
        //Account acc4 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account 4', cp1.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc3.Id, true);
        
        // Updating Accounts 
        /*acc3.isPartner = true;
        acc3.Core_Geo__c='EMEA';
        acc3.Core_MDF_CoMarketingActive__c = true;*/
        //acc4.Core_Geo__c='EMEA';
        //toBeUpdated.add(acc3);
        /*toBeUpdated.add(acc4);
        Database.upsert(toBeUpdated);*/
        
        
        insert new Core_MDF_BudgetType_Benefit_Mappings__c(Name = 'Business_Client_Acceleration_Managed_M', Core_MDF_IsActive__c = true, Core_MDF_Is_IUPGM_Monitor_Applicable_Ind__c = false, Core_MDF_Partner_Benefit__c = 'Business Client Acceleration - MDF', Core_MDF_Record_Developer_Nm__c = '', Core_MDF_Budget_Type__c = 'Business Client Acceleration - MDF', Core_MDF_Program_Nm__c = '', Core_MDF_RecordType__c = '');
        string budgetType = Core_MDF_CCP_IPA_TestDataUtility.createBenefit(acc6);
        Id ipaRecordtype = Schema.SObjectType.PartnerMarketingBudget.getRecordTypeInfosByDeveloperName().get(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Record_Type_Developer_Name')).getRecordTypeId();  
        
        PartnerMarketingBudget pmb2 = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget 2', Core_MDF_CCP_TestDataUtility.Budget_Record_Type, acc4.Id, cp1.Id, 3000, System.Today(), System.Today().addDays(10), false);
         
        PartnerMarketingBudget pmb3 = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget 3', Core_MDF_CCP_TestDataUtility.Budget_Record_Type, acc5.Id, cp2.Id, 3000, System.Today(), System.Today().addDays(10), false);
        pmb3.Core_MDF_Budget_Type_Txt__c = 'OEM CMP';
        insert pmb3;
        
        PartnerMarketingBudget pmb4 = new PartnerMarketingBudget(Title='Test Budget 4',StartDate=System.today(),EndDate=System.today(),
        Core_MDF_Budget_Partner__c=acc6.Id,Core_MDF_Program__c=cp.Id,Core_MDF_Budget_Type_Txt__c=budgetType, Amount=10000, RecordTypeId = ipaRecordtype,Core_MDF_Budget_Status__c ='Released');
        Test.startTest();
       Campaign cmp  = new Campaign();
        Profile systemAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator' limit 1];
        
        // Creating User with utility class 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.profileId = systemAdminProfile.Id;
        Database.insert(usr);
        system.runAs(usr){
             cmp = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 12','Gaming','Intel® Core™ i7 Processor','Yes', Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', System.today(), System.today().addDays(300), 10000, 'Always Connected PC', acc5.Id,'Desktop', false);
            
             cmp.Core_MDF_Budget_Type_txt__c = 'OEM CMP';
        }
        
        Profile partnerProfile = [SELECT Id FROM Profile WHERE Name='Partner' limit 1];
        User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);        
        usr1.Email='test1@example.com';
        usr1.ContactId = conRecord1.Id;
        usr1.ProfileId = partnerProfile.id;
        usr1.isActive = true;
        Database.insert(usr1);
        
        
        
        Core_MDF_Partner_Node_User_Mapping__c pnum = new Core_MDF_Partner_Node_User_Mapping__c();
        pnum.Core_MDF_Account__c = acc6.Id;
        pnum.Core_MDF_User__c = usr1.Id;
        
        
        System.runAs(usr){
                
                GroupMember newGroupMember = new GroupMember();
                newGroupMember.GroupId = newGroup.ID;
                newGroupMember.UserOrGroupId = usr1.Id;
                Database.insert(newGroupMember);
                Database.insert(pnum);
           // try
            //{
            //
                Boolean isAsmoShared = false;
                Boolean isAsmoLarROShared = false;
                Boolean isEmeaShared = false;
                Boolean isApjShared = false;
                Boolean isCmpAsmoShared = false;
                Boolean isCmpAsmoROShared = false;
                Map<String,Id> grpNameIdMap = new Map<String,Id>();
                Set<String> grpNames = new Set<String>();
                Set<Id> budgetId = new Set<Id>();
                budgetId.add(pmb1.Id);
                budgetId.add(pmb2.Id);
                budgetId.add(pmb3.Id);
                Core_MDF_RecordGeoShare share = new Core_MDF_RecordGeoShare(pmb1.Id,'ASMO','LAR','Retail Marketing Funds');
                Core_MDF_RecordGeoShare share2 = new Core_MDF_RecordGeoShare(pmb2.Id,'APJ','Retail Marketing Funds');
                Core_MDF_RecordGeoShare share3 = new Core_MDF_RecordGeoShare(pmb3.Id,Core_MDF_CCP_ConstantClass.CCF_PROGRAM);
                Core_MDF_RecordGeoShare share4 = new Core_MDF_RecordGeoShare(pmb4.Id,'ASMO','LAR','Intel Partner Alliance',budgetType);
                Core_MDF_RecordGeoShare share5 = new Core_MDF_RecordGeoShare(pnum.Id,'ASMO','LAR','Intel Partner Alliance');
                List<Core_MDF_RecordGeoShare> shareLst = new List<Core_MDF_RecordGeoShare>();
                List<Core_MDF_RecordGeoShare> shareLst2 = new List<Core_MDF_RecordGeoShare>();
                List<Core_MDF_RecordGeoShare> shareLst3 = new List<Core_MDF_RecordGeoShare>();
                shareLst.add(share);
                shareLst.add(share2);
                shareLst.add(share3);
                shareLst2.add(share4);
                shareLst3.add(share5);
                Core_MDF_ShareRecordToGeoGroup.getShareRecordToGeoGroup('PartnerMarketingBudget', shareLst);
            Core_MDF_ShareRecordToGeoGroup.getShareRecordToGeoGroup('PartnerMarketingBudget', shareLst2);
                Core_MDF_ShareRecordToGeoGroup.ShareRecordToGeoGroup('PartnerMarketingBudget', shareLst);
                Core_MDF_ShareRecordToGeoGroup.ShareRecordToGeoGroup('PartnerMarketingBudget', shareLst2);
            Core_MDF_ShareRecordToGeoGroup.ShareRecordToGeoGroup('Core_MDF_Payment__c',shareLst2);
               // Core_MDF_ShareRecordToGeoGroup.ShareRecordToGeoGroup('Core_MDF_Partner_Node_User_Mapping__c', shareLst3);
                Core_MDF_ProgramGeoGroupMap__mdt metaRec = [SELECT Core_MDF_Group_Name__c,Core_MDF_Group_Name_RO__c, Core_MDF_Program__c,Core_MDF_Region__c,Core_MDF_Sub_Region__c
                                                        From Core_MDF_ProgramGeoGroupMap__mdt
                                                        where Core_MDF_Region__c = 'ASMO' and Core_MDF_Sub_Region__c='LAR' and Core_MDF_Program__c =:Core_MDF_CCP_ConstantClass.RMF_PROGRAM];
            grpNames.add(metaRec.Core_MDF_Group_Name__c);
            grpNames.add(metaRec.Core_MDF_Group_Name_RO__c);
            
            Core_MDF_ProgramGeoGroupMap__mdt metaRec2 = [SELECT Core_MDF_Group_Name__c, Core_MDF_Group_Name_RO__c, Core_MDF_Program__c,Core_MDF_Region__c,Core_MDF_Sub_Region__c
                                                        From Core_MDF_ProgramGeoGroupMap__mdt
                                                        where Core_MDF_Region__c = 'APJ' and Core_MDF_Program__c =:Core_MDF_CCP_ConstantClass.RMF_PROGRAM];
            grpNames.add(metaRec2.Core_MDF_Group_Name__c);  
            grpNames.add(metaRec2.Core_MDF_Group_Name_RO__c);
            Core_MDF_ProgramGeoGroupMap__mdt metaRec3 = [SELECT Core_MDF_Group_Name__c, Core_MDF_Group_Name_RO__c, Core_MDF_Program__c,Core_MDF_Region__c,Core_MDF_Sub_Region__c
                                                        From Core_MDF_ProgramGeoGroupMap__mdt
                                                        where Core_MDF_Region__c = 'ASMO' and Core_MDF_Program__c =: Core_MDF_CCP_ConstantClass.CCF_PROGRAM limit 1];
            grpNames.add(metaRec3.Core_MDF_Group_Name__c);
            grpNames.add(metaRec3.Core_MDF_Group_Name_RO__c);
            Core_MDF_ProgramGeoGroupMap__mdt metaRec4 = [SELECT Core_MDF_Group_Name__c, Core_MDF_Group_Name_RO__c, Core_MDF_Program__c,Core_MDF_Region__c,Core_MDF_Sub_Region__c
                                                        From Core_MDF_ProgramGeoGroupMap__mdt
                                                        where Core_MDF_Region__c = '' and Core_MDF_Program__c =: Core_MDF_CCP_ConstantClass.CCF_PROGRAM];
            grpNames.add(metaRec4.Core_MDF_Group_Name__c);
            for(Group grp : [Select Id, DeveloperName from Group where DeveloperName IN :grpNames])
                {
                    grpNameIdMap.put(grp.DeveloperName,grp.Id);
                }            
               
            List<PartnerMarketingBudgetShare> pmbShare = [SELECT ParentId, UserOrGroupId from PartnerMarketingBudgetShare where ParentId IN :budgetId];
               
            for(PartnerMarketingBudgetShare shareRec : pmbShare)
                {
                   
                    if(shareRec.ParentId==pmb1.Id && shareRec.UserOrGroupId.equals(grpNameIdMap.get(metaRec.Core_MDF_Group_Name__c))){
                        isAsmoShared = true;
                    }
                    if(shareRec.ParentId==pmb1.Id && shareRec.UserOrGroupId.equals(grpNameIdMap.get(metaRec.Core_MDF_Group_Name_RO__c))){
                        isAsmoLarROShared = true;
                    }
                    if(shareRec.ParentId==pmb2.Id && shareRec.UserOrGroupId.equals(grpNameIdMap.get(metaRec2.Core_MDF_Group_Name__c))){
                        isEmeaShared = true;
                    }
                    if(shareRec.ParentId==pmb3.Id && shareRec.UserOrGroupId.equals(grpNameIdMap.get(metaRec4.Core_MDF_Group_Name__c))){
                        isApjShared = true;
                    }
                        
                }
                System.assertEquals(true,isAsmoShared);
                System.assertEquals(true,isAsmoLarROShared);
                System.assertEquals(false,isEmeaShared);
                System.assertEquals(true,isApjShared);
                
                List<CampaignShare> cmpShare = [SELECT CampaignId, UserOrGroupId from CampaignShare where CampaignId = :cmp.Id];
            
            for(CampaignShare cmpShareRec : cmpShare)
                {
                    if(cmpShareRec.UserOrGroupId.equals(grpNameIdMap.get(metaRec3.Core_MDF_Group_Name__c))){
                        isCmpAsmoShared = true;
                    }
                    if(cmpShareRec.UserOrGroupId.equals(grpNameIdMap.get(metaRec3.Core_MDF_Group_Name_RO__c))){
                        isCmpAsmoROShared = true;
                    }    
                }
               // System.assertEquals(true,isCmpAsmoShared);
               // System.assertEquals(true,isCmpAsmoROShared);
            
            //}
           /* catch(Exception ex)
            {
                System.debug(ex.getMessage());
            }*/
        }
        test.stopTest();
    }
    @isTest static void testCreateShareBulkString() {
        ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram ('Client','Client CoMarketing Fund', true);
        Account Masteracc = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Account 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
       	Account acc = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account CCF', cp.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, Masteracc.Id, true);        
        User usr = [Select Id from User limit 1];
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        //Core_MDF_Payment__Share testShare = new Core_MDF_Payment__Share(ParentId = 'a01xx000000001A', UserOrGroupId = '005xx0000000AAA', RowCause = 'Manual', AccessLevel = 'Read');
        Core_MDF_Payment__Share testShare = new Core_MDF_Payment__Share(ParentId = acc.Id, UserOrGroupId = usr.Id, RowCause = 'Manual', AccessLevel = 'Read');
        List<sObject> dynObjectList = new List<sObject>{testShare};

        Test.startTest();
        Core_MDF_GenericShareRecordActionClass.createShareBulkString(dynObjectList, 'Core_MDF_Payment__Share');
        Test.stopTest();
    }
    
}