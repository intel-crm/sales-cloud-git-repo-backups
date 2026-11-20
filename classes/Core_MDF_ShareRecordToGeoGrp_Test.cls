@isTest(SeeAllData = false)
public class Core_MDF_ShareRecordToGeoGrp_Test {
    
    // test method for data setup
    @TestSetup static void setUpData(){
        
        Profile systemAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator' limit 1];
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        User usr2 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr2.profileId = systemAdminProfile.Id;
        usr2.Email='test2@example.com';
        usr2.UserRoleId=usRole.Id;
        Database.insert(usr2);
        System.runAs(usr2){
        
        List<Core_Trigger_Executions__c> triggerExecutionList = new List<Core_Trigger_Executions__c>();
    Core_Trigger_Executions__c execution1 = new Core_Trigger_Executions__c();
    execution1.Name = 'Core_MDF_ProcessEntitlementsFlag';
    execution1.Core_Active__c = true;
    execution1.Core_Class_Name__c = 'Core_ContactEntitlementHandler';
    execution1.Core_Description__c = 'Process CCP Contacts';
    execution1.Core_Object__c = 'Contact Entitlement';
    execution1.Core_Trigger_Events__c = 'After Update';

    Core_Trigger_Executions__c execution2 = new Core_Trigger_Executions__c();
    execution2.Name = 'pnumDeletionIndicator';
    execution2.Core_Active__c = true;
    execution2.Core_Class_Name__c = 'Core_MDF_UserGroupMapping_Deletion';
    execution2.Core_Description__c = 'Process CCP Contacts';
    execution2.Core_Object__c = 'Contact Entitlement';
    execution2.Core_Trigger_Events__c = 'After Update';

    Core_Trigger_Executions__c execution3 = new Core_Trigger_Executions__c();
    execution3.Name = 'callExternalUserSharingFromUGMDeletion';
    execution3.Core_Active__c = true;
    execution3.Core_Class_Name__c = 'Core_MDF_UserGroupMapping_Deletion';
    execution3.Core_Description__c = 'Process CCP Contacts';
    execution3.Core_Object__c = 'Contact Entitlement';
    execution3.Core_Trigger_Events__c = 'After Update';

    Core_Trigger_Executions__c execution4 = new Core_Trigger_Executions__c();
    execution4.Name = 'callExtUsrSharingFrmUGMAutomation';
    execution4.Core_Active__c = true;
    execution4.Core_Class_Name__c = 'Core_MDF_Process_CCP_Contacts';
    execution4.Core_Description__c = 'Process CCP Contacts';
    execution4.Core_Object__c = 'Contact Entitlement';
    execution4.Core_Trigger_Events__c = 'After Update';
  
    Core_Trigger_Executions__c execution6 = new Core_Trigger_Executions__c();
    execution6.Name = 'Core_MDF_PNUM_Addition';
    execution6.Core_Active__c = true;
    execution6.Core_Class_Name__c = 'Core_MDF_ProcessEntitlements';
    execution6.Core_Description__c = 'Process CCP Contacts';
    execution6.Core_Object__c = 'Contact Entitlement';
    execution6.Core_Trigger_Events__c = 'After Update'; 

    triggerExecutionList.add(execution1); triggerExecutionList.add(execution6); triggerExecutionList.add(execution2);triggerExecutionList.add(execution3);triggerExecutionList.add(execution4);

    Database.insert(triggerExecutionList);
  
    List<Core_MDF_Configuration__c> configlist=new List<Core_MDF_Configuration__c>();
    Core_MDF_Configuration__c config=new Core_MDF_Configuration__c();
    config.Core_MDF_Category__c='ProcessEntitlements';
    config.Name='Core_MDF_ProcessEntitlements_Class';
    config.Core_MDF_Value__c='Core_MDF_ProcessEntitlements';
    configlist.add(config);
    Database.insert(configlist);
    
        List<Account> toBeUpdated = new List<Account>();
        
        // Creating Account with utility class
        Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Account 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
        Contact conRecord1 = Core_MDF_CCP_TestDataUtility.createContact(acc1.Id,true);
        Id profileId = [SELECT Id FROM Profile WHERE Name='Partner' limit 1].Id;
        User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);        
        usr1.Email='test1@example.com';
        usr1.ContactId = conRecord1.Id;
        usr1.ProfileId = profileId;
        usr1.isActive = true;
        Database.insert(usr1);
        Map<String,PermissionSet> nameToPerSet = new Map<String,PermissionSet>();
        for(PermissionSet pSet:[SELECT Id,Name FROM PermissionSet WHERE Name IN (
                            'Core_MDF_CCP_Internal_Retail_Finance_Usr','Core_MDF_CCP_Internal_IPA_Budget_Loader',
                            'Core_MDF_CCP_Internal_Finance_Usr','Core_MDF_CCP_Internal_CCF_User',
                            'Core_MDF_CCP_Internal_DCF_User'
                            )]) {
            nameToPerSet.put(pSet.Name,pSet);
        }
        
         
        List<PermissionSetAssignment> permSetAssgnLst = new List<PermissionSetAssignment>();
        PermissionSet retailInternalFinanceUser = nameToPerSet.get('Core_MDF_CCP_Internal_Retail_Finance_Usr');
        PermissionSetAssignment assignMDFBudgetLoaderPermissionSet = new PermissionSetAssignment();
        assignMDFBudgetLoaderPermissionSet.AssigneeId = usr2.Id;
        assignMDFBudgetLoaderPermissionSet.PermissionSetId = retailInternalFinanceUser.Id; 
        permSetAssgnLst.add(assignMDFBudgetLoaderPermissionSet);
        PermissionSet ipaFinanceUser = nameToPerSet.get('Core_MDF_CCP_Internal_IPA_Budget_Loader');
        PermissionSetAssignment assignIPAPermissionSet = new PermissionSetAssignment();
        assignIPAPermissionSet.AssigneeId = usr2.Id;
        assignIPAPermissionSet.PermissionSetId = ipaFinanceUser.Id; 
        permSetAssgnLst.add(assignIPAPermissionSet);
        PermissionSet internalFinanceUser = nameToPerSet.get('Core_MDF_CCP_Internal_Finance_Usr');
        PermissionSetAssignment assignInternalFinanceUserPermissionSet = new PermissionSetAssignment();
        assignInternalFinanceUserPermissionSet.AssigneeId = usr2.Id;
        assignInternalFinanceUserPermissionSet.PermissionSetId = internalFinanceUser.Id; 
        permSetAssgnLst.add(assignInternalFinanceUserPermissionSet);
        PermissionSet internalCCFUser = nameToPerSet.get('Core_MDF_CCP_Internal_CCF_User');
        PermissionSetAssignment assignInternalCCFUserPermissionSet = new PermissionSetAssignment();
        assignInternalCCFUserPermissionSet.AssigneeId = usr2.Id;
        assignInternalCCFUserPermissionSet.PermissionSetId = internalCCFUser.Id; 
        permSetAssgnLst.add(assignInternalCCFUserPermissionSet);
        PermissionSet internalDCFUser = nameToPerSet.get('Core_MDF_CCP_Internal_DCF_User');
        PermissionSetAssignment assigninternalDCFUserPermissionSet = new PermissionSetAssignment();
        assigninternalDCFUserPermissionSet.AssigneeId = usr2.Id;
        assigninternalDCFUserPermissionSet.PermissionSetId = internalDCFUser.Id; 
        permSetAssgnLst.add(assigninternalDCFUserPermissionSet);
        system.runAs(usr2){
            Database.insert(permSetAssgnLst);
        }
        
        Group newGroup = new Group();
        newGroup.Name = 'IPA Test Group';
        newGroup.DeveloperName = 'IPA_Test_Group';
        Database.insert(newGroup);
        
        // Creating channel program with utility class
        ChannelProgram cp1 = Core_MDF_CCP_TestDataUtility.createProgram ('Retail Marketing Funds','Retail Marketing Funds', true);
        ChannelProgram cp2 = Core_MDF_CCP_TestDataUtility.createProgram ('Client','Client CoMarketing Fund', true);
        ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram ('Intel Partner Alliance','Intel Partner Alliance', true);
        
        Core_MDF_Partner_Group_Mapping__c pgm1 = new Core_MDF_Partner_Group_Mapping__c();
        pgm1.Core_MDF_Account__c = acc1.Id;
        pgm1.Core_MDF_Type_of_Access__c = 'External';
        pgm1.Core_MDF_Channel_Program__c = cp.Id;
        pgm1.Core_MDF_Group_Name__c = 'IPA_Test_Group';
        Database.insert(pgm1);
        
        Account acc2 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account 2', cp1.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc1.Id, false);
                
        Account acc3 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account 3', cp2.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc1.Id, false);
        
        Account acc4 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account 4', cp.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc1.Id, true);
    // Updating Accounts 
        acc1.isPartner = true;
        acc1.Core_Geo__c='ASMO';
        acc1.Core_Sub_Geo__c='LAR';
        acc2.Core_MDF_CoMarketingActive__c = true;
        acc2.Core_Geo__c='ASMO';
        acc2.Core_Sub_Geo__c='LAR';
        acc3.Core_MDF_CoMarketingActive__c = true;
        acc3.Core_Geo__c='';
        acc3.Core_Sub_Geo__c='';
        acc4.Core_Geo__c='ASMO';
        acc4.Core_Sub_Geo__c='NAR';
        toBeUpdated.add(acc1);
        toBeUpdated.add(acc2);
        toBeUpdated.add(acc3);
        toBeUpdated.add(acc4);
        Database.upsert(toBeUpdated);
        
        
        test.startTest();
        Core_AGS_Role__c agsRoleCCF = Core_MDF_CCP_TestDataUtility.createAgsRole('IPA_MDF_USER', 'Co-Marketing(Salesforce)-IPA MDF USER', true, false);
        
        Core_ERPM_Engagement__c erpmEngagementIPA = Core_MDF_CCP_TestDataUtility.createErpmEngagement('IPA', 'IPA', 'DEDUPB2B', 'SEC', true, false);
        Database.insert(erpmEngagementIPA);
        
        Core_Entitlement__c entitlementIPA = Core_MDF_CCP_TestDataUtility.createEntitlement('IPA MDF User',agsRoleCCF.Id ,'Intel® Partner Investment Center','IPA MDF User',erpmEngagementIPA.Id , true,'Solutions Marketplace',false);
        Database.insert(entitlementIPA); 
        
        Core_Contact_Entitlement__c contactEntitlementIPA = Core_MDF_CCP_TestDataUtility.createContactEntitlement(conRecord1.Id,entitlementIPA.Id ,true,'Complete', false);
        Database.insert(contactEntitlementIPA);    
        
        
        // Creating Account with utility class
        Account acc5 = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Account 5', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
        
        Account acc6 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account 6', cp1.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc5.Id, false);
        
        // Updating Accounts 
        acc5.isPartner = true;
        acc5.Core_Geo__c='EMEA';
        acc5.Core_MDF_CoMarketingActive__c = true;
        acc6.Core_Geo__c='EMEA';
        toBeUpdated.add(acc5);
        toBeUpdated.add(acc6);
        Database.upsert(toBeUpdated);
        
    string budgetType = Core_MDF_CCP_IPA_TestDataUtility.createBenefit(acc6);
        
        Core_MDF_ProcessEntitlementsSchedulable test1 = new Core_MDF_ProcessEntitlementsSchedulable();
        test1.execute(null);
        
        test.stopTest();
        }
    }
    @isTest static void validateShareRecordToGeoGroup(){
        //adding bypass feature to bypass access validation
    List<String> bypassFunctionKeys = new List<String>();
    bypassFunctionKeys.add('Bypass_MDF_Budget_Access_Validation');
    bypassFunctionKeys.add('Bypass_MDF_Budget_Status_Validation');

    Set<String> myset1 = new Set<String>();
    List<String> result1 = new List<String>();
    myset1.addAll(bypassFunctionKeys);
    result1.addAll(myset1);

    List<Core_Trigger_Executions__c> bypassfunctinalitylist1 = Core_MDF_CCP_TestDataUtility.byPassFeature(result1,true,true);
  
        test.startTest();
        
        User usr1 = [Select id from User where Email='test1@example.com' limit 1];
        User usr2 = [Select id from User where Email='test2@example.com' limit 1]; 
        System.runAs(usr2){
        Group newGrp = [Select id, DeveloperName from Group where DeveloperName='IPA_Test_Group' limit 1];
        
        
        Account acc1 = [Select Id, Name,Core_MDF_Parent_Fund_Account__c from Account where Name in ('Test Account 2')];
        Account acc2 = [Select Id, Name,Core_MDF_Parent_Fund_Account__c from Account where Name in ('Test Account 3')];
        Account acc3 = [Select Id, Name,Core_MDF_Parent_Fund_Account__c,Core_Geo__c,Core_Sub_Geo__c from Account where Name in ('Test Account 4')];
        Account acc4 = [Select Id, Name,Core_MDF_Parent_Fund_Account__c from Account where Name in ('Test Account 6')];
    Core_MDF_RecordGeoShare share5 = new Core_MDF_RecordGeoShare(acc1.Id,'ASMO','LAR','Intel Partner Alliance',null);
    List<Core_MDF_RecordGeoShare> shareLst5 = new List<Core_MDF_RecordGeoShare>();
    shareLst5.add(share5);
    Core_MDF_ShareRecordToGeoGroup.getShareRecordToGeoGroup('Account', shareLst5);
    Id ipaRecordtype = Schema.SObjectType.PartnerMarketingBudget.getRecordTypeInfosByDeveloperName().get(Label.Core_MDF_IPA_Record_Type_Developer_Name).getRecordTypeId();  
        
        ChannelProgram cp1 = [Select Id, Name from ChannelProgram where Name in('Retail Marketing Funds')];
        ChannelProgram cp2 = [Select Id, Name from ChannelProgram where Name in('Client')];
        ChannelProgram cp3 = [Select Id, Name from ChannelProgram where Name in('Intel Partner Alliance')];
        List<PartnerMarketingBudget> pmbList = new List<PartnerMarketingBudget>();
        PartnerMarketingBudget pmb1 = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget 1', Core_MDF_CCP_TestDataUtility.Budget_Record_Type, acc1.Id, cp1.Id, 3000, System.Today(), System.Today().addDays(10), false);
        pmbList.add(pmb1);
        PartnerMarketingBudget pmb2 = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget 2', Core_MDF_CCP_TestDataUtility.Budget_Record_Type, acc4.Id, cp1.Id, 3000, System.Today(), System.Today().addDays(10), false);
        pmbList.add(pmb2);
        PartnerMarketingBudget pmb3 = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget 3', Core_MDF_CCP_TestDataUtility.Budget_Record_Type, acc2.Id, cp2.Id, 3000, System.Today(), System.Today().addDays(10), false);
        pmbList.add(pmb3);
        pmb3.Core_MDF_Budget_Type_Txt__c = 'OEM CMP';
        insert pmbList;
        
        PartnerMarketingBudget pmb4 = new PartnerMarketingBudget(Title='Test Budget 4',StartDate=System.today(),EndDate=System.today(),
        Core_MDF_Budget_Partner__c=acc3.Id,Core_MDF_Program__c=cp3.Id,Core_MDF_Budget_Type_Txt__c='Client Specialties MDF', Amount=10000, RecordTypeId = ipaRecordtype,Core_MDF_Budget_Status__c ='Released');
        
        Campaign cmp = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 12','Gaming','Intel® Core™ i7 Processor','Yes', Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', System.today(), System.today().addDays(300), 10000, 'Always Connected PC', acc2.Id,'Desktop', false);
        cmp.Core_MDF_Opal_Budget_Type_Txt__c = 'OEM CMP';
        database.insert(cmp);
        
    Profile systemAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator' limit 1];

        //Core_MDF_Partner_Node_User_Mapping__c pnum = [Select id from Core_MDF_Partner_Node_User_Mapping__c where Core_MDF_User__c = :usr1.ID];
        
        // Creating User with utility class 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.profileId = systemAdminProfile.Id;
        Database.insert(usr);
        
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
    Core_MDF_RecordGeoShare share2 = new Core_MDF_RecordGeoShare(pmb2.Id,'EMEA','Retail Marketing Funds');
    Core_MDF_RecordGeoShare share3 = new Core_MDF_RecordGeoShare(pmb3.Id,'Client Co-Marketing Fund');
    Core_MDF_RecordGeoShare share4 = new Core_MDF_RecordGeoShare(pmb4.Id,'ASMO','LAR','Intel Partner Alliance','Client Specialties MDF');
    List<Core_MDF_RecordGeoShare> shareLst = new List<Core_MDF_RecordGeoShare>();
    List<Core_MDF_RecordGeoShare> shareLst2 = new List<Core_MDF_RecordGeoShare>();
    List<Core_MDF_RecordGeoShare> shareLst3 = new List<Core_MDF_RecordGeoShare>();
    shareLst.add(share);
    shareLst.add(share2);
    shareLst.add(share3);
    shareLst2.add(share4);
    Core_MDF_ShareRecordToGeoGroup.getShareRecordToGeoGroup('PartnerMarketingBudget', shareLst);
    Core_MDF_ShareRecordToGeoGroup.getShareRecordToGeoGroup('PartnerMarketingBudget', shareLst2);
    Core_MDF_ShareRecordToGeoGroup.ShareRecordToGeoGroup('PartnerMarketingBudget', shareLst);
    Core_MDF_ShareRecordToGeoGroup.ShareRecordToGeoGroup('PartnerMarketingBudget', shareLst2);
    List<sObject> sharedRecordsBatch = Core_MDF_ShareRecordToGeoGroup.shareRecordToGeoGroupforBatch('PartnerMarketingBudget', shareLst);
  
    Core_MDF_ProgramGeoGroupMap__mdt metaRec = [SELECT Core_MDF_Group_Name__c,Core_MDF_Group_Name_RO__c, Core_MDF_Program__c,Core_MDF_Region__c,Core_MDF_Sub_Region__c
                                                        From Core_MDF_ProgramGeoGroupMap__mdt
                                                        where Core_MDF_Region__c = 'ASMO' and Core_MDF_Sub_Region__c='LAR' and Core_MDF_Program__c = 'Retail Marketing Funds'];
    grpNames.add(metaRec.Core_MDF_Group_Name__c);
    grpNames.add(metaRec.Core_MDF_Group_Name_RO__c);
    
    Core_MDF_ProgramGeoGroupMap__mdt metaRec2 = [SELECT Core_MDF_Group_Name__c, Core_MDF_Group_Name_RO__c, Core_MDF_Program__c,Core_MDF_Region__c,Core_MDF_Sub_Region__c
                          From Core_MDF_ProgramGeoGroupMap__mdt
                          where Core_MDF_Region__c = 'EMEA' and Core_MDF_Program__c = 'Retail Marketing Funds'];
    grpNames.add(metaRec2.Core_MDF_Group_Name__c);  
    grpNames.add(metaRec2.Core_MDF_Group_Name_RO__c);
    
    Core_MDF_ProgramGeoGroupMap__mdt metaRec3 = [SELECT Core_MDF_Group_Name__c, Core_MDF_Group_Name_RO__c,Core_MDF_Budget_Type_txt__c, Core_MDF_Program__c,Core_MDF_Region__c,Core_MDF_Sub_Region__c
                          From Core_MDF_ProgramGeoGroupMap__mdt
                          where Core_MDF_Region__c = 'ASMO' and Core_MDF_Program__c = 'Client' limit 1];
    grpNames.add(metaRec3.Core_MDF_Group_Name__c);
    grpNames.add(metaRec3.Core_MDF_Group_Name_RO__c);
    
    Core_MDF_ProgramGeoGroupMap__mdt metaRec4 = [SELECT Core_MDF_Group_Name__c, Core_MDF_Group_Name_RO__c, Core_MDF_Program__c,Core_MDF_Region__c,Core_MDF_Sub_Region__c
                          From Core_MDF_ProgramGeoGroupMap__mdt
                          where Core_MDF_Region__c = '' and Core_MDF_Program__c = 'Client'];
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
        Core_MDF_ProgramGeoGroupMap__mdt geoGroupMap = [SELECT Core_MDF_Group_Name__c, Core_MDF_Group_Name_RO__c,Core_MDF_Budget_Type_txt__c, Core_MDF_Program__c,Core_MDF_Region__c,Core_MDF_Sub_Region__c
                                                        From Core_MDF_ProgramGeoGroupMap__mdt
                                                        where Core_MDF_Region__c = 'ASMO' and Core_MDF_Program__c = 'Intel Partner Alliance' limit 1];
        grpNames.add(geoGroupMap.Core_MDF_Group_Name__c);
        grpNames.add(geoGroupMap.Core_MDF_Group_Name_RO__c);
            
        // Create a partner marketing budget with matching budget type
        PartnerMarketingBudget testBudget = Core_MDF_CCP_TestDataUtility.createBudget('TestBudgetData',Core_MDF_CCP_TestDataUtility.budget_Record_Type,
                                                                                      acc3.id, cp3.Id , 2000000,System.today().addDays(-20),System.today() , 
                                                                                      false);
        testBudget.IsIgnoreValidation = true;
        testBudget.Core_MDF_Budget_Type_Txt__c = geoGroupMap.Core_MDF_Budget_Type_txt__c;
        
    Core_MDF_RecordGeoShare shareRecord = new Core_MDF_RecordGeoShare(testBudget.Id, acc3.Core_Geo__c, acc3.Core_Sub_Geo__c, cp3.Name, geoGroupMap.Core_MDF_Budget_Type_txt__c);
        List<Core_MDF_RecordGeoShare> shareList = new List<Core_MDF_RecordGeoShare>{shareRecord};

        List<Core_MDF_RecordGeoShare> updatedShareList = Core_MDF_ShareRecordToGeoGroup.addGroupstoRecordGeoShareLst('PartnerMarketingBudget', shareList);
            
        }
        test.stopTest();  
    }

}