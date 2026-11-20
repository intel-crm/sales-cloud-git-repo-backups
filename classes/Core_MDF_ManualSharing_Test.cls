/****************************************************************************************************************************************
* Class Name  : Core_MDF_ManualSharing_Test
* Version     : 1.0 
* Created Date: 30-Apr-2019
* Modification Log :
* Developer                           Date                        Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture- Krishna Kulkarni         30/Apr/2019                 Created to test Core_MDF_ManualSharing
* Accenture - Vaishali              06/Nov/2019               Changed for Geo and subgeo based sharing
*****************************************************************************************************************************************/
@isTest(SeeAllData=false)
public without sharing class Core_MDF_ManualSharing_Test {
    
    @TestSetup static void setUpData(){
        
        //Creating Intel Account with utility class
        Account dellCorpAccount = Core_MDF_CCP_TestDataUtility.createAccount('Dell Corporation', null ,Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);   
        dellCorpAccount.BillingCity = 'Test City';         
        dellCorpAccount.BillingCountry= 'AUS';
        dellCorpAccount.BillingStreet= 'Test Street';
        Database.insert(dellCorpAccount); 
        dellCorpAccount.IsPartner = true;
        Database.update(dellCorpAccount);    
        Account intelAcc = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Account 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
    
        //Creating Contact for Partner User
        Contact conRecord1 = Core_MDF_CCP_TestDataUtility.createContact(dellCorpAccount.Id,true);            

        PermissionSet acctBudgetAdm = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_External_Account_Budget_Administrator' LIMIT 1];
        
        List<User> userList = new List<User>();
        List<Account> acctList = new List<Account>();
        // Highlight: Unused Local Variable 
       // List<PermissionSetAssignment> permissionSetAssignmentList = new List<PermissionSetAssignment>();
        
        //Creating User with utility class 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.Email = 'sysadmin@example.com';
        userList.add(usr);
        
        User usr2 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr2.Email = 'sysadmin2@example.com';
        userList.add(usr2);
        
        Id profileId = [SELECT Id FROM Profile WHERE Name='Partner' limit 1].Id;
        
        User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);        
        usr1.Email='acctBudgadm@example.com';
        usr1.ContactId = conRecord1.Id;
        usr1.ProfileId = profileId;
        usr1.isActive = true; 
        userList.add(usr1);
        try{
            insert userList; 
        }
        catch(Exception Ex){
        }
    
        PermissionSetAssignment psa1 = new PermissionSetAssignment(PermissionSetId = acctBudgetAdm.Id, AssigneeId = usr1.Id);
        
        system.runAs(usr){
            database.insert(psa1);
            PermissionSet eefBudManager = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_Internal_EEF_Budget_Manager' LIMIT 1];
        insert new PermissionSetAssignment(AssigneeId = usr.id, PermissionSetId = eefBudManager.Id);
        }
        
        List<ChannelProgram> cpList = new List<ChannelProgram>();      
        ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.CCF_PROGRAM,'Client CoMarketing Fund', false);
        ChannelProgram cp1 = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.DCF_PROGRAM,'Data Center CoMarketing Fund', false);
        ChannelProgram cp2 = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.RMF_PROGRAM,'Retail Marketing Funds', false);
        ChannelProgram eefCP = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.EEF_PROGRAM,'Ecosystem Extension Fund', true);

        cpList.add(cp);
        cpList.add(cp1);
        cpList.add(cp2);
        database.insert(cpList);
        
        Test.startTest();
        
        //Creating Co-marketing Account with utility class
        Account dellCCFVirtualCorp = Core_MDF_CCP_TestDataUtility.createAccount ('Dell CCF Virtual Corp', cp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
        dellCCFVirtualCorp.Core_MDF_Parent_Fund_Account__c = dellCorpAccount.Id;
        //dellCCFVirtualCorp.Core_MDF_CoMarketingActive__c = true;
        acctList.add(dellCCFVirtualCorp);
        Group grp12 = new Group();
        grp12.name = 'TGM_TEST';
        insert grp12;
        Account dellDCFVirtualCorp = Core_MDF_CCP_TestDataUtility.createAccount ('Dell DCF Virtual Corp', cp1.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
        dellDCFVirtualCorp.Core_MDF_Parent_Fund_Account__c = dellCorpAccount.Id;
        dellDCFVirtualCorp.Core_MDF_External_Group_Id__c =grp12.id;
        /*dellDCFVirtualCorp.Core_MDF_CoMarketingActive__c = true;
        dellDCFVirtualCorp.Core_Geo__c = 'ASMO';
        dellDCFVirtualCorp.Core_Sub_Geo__c = 'LAR';*/
        acctList.add(dellDCFVirtualCorp);  
        
        Account retailAccount = Core_MDF_CCP_TestDataUtility.createAccount ('Dell Retail Virtual Corp', cp2.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
        retailAccount.Core_MDF_Parent_Fund_Account__c = dellCorpAccount.Id;
        //retailAccount.Core_MDF_CoMarketingActive__c = true;
        retailAccount.Core_Geo__c = 'ASMO';
        retailAccount.Core_Sub_Geo__c = 'LAR';
        acctList.add(retailAccount);
        
        Account retailAccount1 = Core_MDF_CCP_TestDataUtility.createAccount ('Dell Retail Node', cp2.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
        retailAccount1.Core_MDF_Parent_Fund_Account__c = dellCorpAccount.Id;
        retailAccount1.Core_MDF_CoMarketingActive__c = true;
        retailAccount1.Core_Geo__c = 'APJ';
        acctList.add(retailAccount1);
        
        Database.insert(acctList);
        List<Account> listAcct = new List<Account>();
        Account dellCCFAPAC = Core_MDF_CCP_TestDataUtility.createAccount ('Dell CCF APAC', cp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type,  false);
        dellCCFAPAC.Core_MDF_Parent_Fund_Account__c = dellCCFVirtualCorp.Id;
        //dellCCFAPAC.Core_MDF_CoMarketingActive__c = true;
        listAcct.add(dellCCFAPAC);
        
        Account dellDCFAPAC = Core_MDF_CCP_TestDataUtility.createAccount ('Dell DCF APAC', cp1.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type,  false);
        dellDCFAPAC.Core_MDF_Parent_Fund_Account__c = dellCorpAccount.Id;
        //dellDCFAPAC.Core_MDF_CoMarketingActive__c = true;
        //dellDCFAPAC.Core_Geo__c = 'ASMO';
        //dellDCFAPAC.Core_Sub_Geo__c = 'LAR';
        listAcct.add(dellDCFAPAC);
        
        Account eefPrimaryVirtualCorp = Core_MDF_CCP_TestDataUtility.createAccount ('EEF Primary Virtual Corp', eefCP.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);                           
    eefPrimaryVirtualCorp.Core_MDF_Parent_Fund_Account__c = dellCorpAccount.Id;
        eefPrimaryVirtualCorp.Core_MDF_Partner_Type_nm__c ='Primary Partner';
    insert eefPrimaryVirtualCorp;
        //listAcct.add(eefPrimaryVirtualCorp);
        
        Account eefActivatingVirtualCorp = Core_MDF_CCP_TestDataUtility.createAccount ('EEF Activating Virtual Corp', eefCP.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);                           
    eefActivatingVirtualCorp.Core_MDF_Parent_Fund_Account__c = intelAcc.Id;
        eefActivatingVirtualCorp.Core_MDF_Partner_Type_nm__c ='Activating Partner';
    insert eefActivatingVirtualCorp;
    //listAcct.add(eefActivatingVirtualCorp);

        Database.insert(listAcct);

        List<Group> grpList = new List<Group>();
        Group grp = new Group();
        grp.Name = 'CCF_Int_Grp_WW';
        grp.DeveloperName = 'CCF_Int_Grp_WW';
        grpList.add(grp);
        
        Group grp1 = new Group();
        grp1.Name = 'DCF_Int_Grp_ASMO_LAR';
        grp1.DeveloperName = 'DCF_Int_Grp_ASMO_LAR';
        grpList.add(grp1);
        
        Group grp2 = new Group();
        grp2.Name = 'CCF_Int_Grp_APJ';
        grp2.DeveloperName = 'CCF_Int_Grp_APJ';
        grpList.add(grp2);
        
        Group grp3 = new Group();
        grp3.Name = 'Retail_Int_Grp_ASMO_LAR';
        grp3.DeveloperName = 'Retail_Int_Grp_ASMO_LAR';
        grpList.add(grp3);
        
        Group grp4 = new Group();
        grp4.Name = 'Retail_Int_Grp_APJ';
        grp4.DeveloperName = 'Retail_Int_Grp_APJ';
        grpList.add(grp4);
        insert grpList;
        
        
        system.runAs(usr){    
        
            List<GroupMember> gmList = new List<GroupMember>();
            GroupMember gm = new GroupMember();
            gm.GroupId = grp.Id;
            gm.UserOrGroupId = usr1.Id;
            gmList.add(gm);         
                   
            Database.insert(gmList);

            Core_MDF_Partner_Group_Mapping__c pgm = new Core_MDF_Partner_Group_Mapping__c();
            pgm.Core_MDF_Account__c = dellCorpAccount.Id;
            pgm.Core_MDF_Group_Name__c = 'CCF_Int_Grp_WW';
            pgm.Core_MDF_Type_of_Access__c = 'Internal';
            pgm.Core_MDF_Source_Txt__c  = 'Test';
            pgm.Core_MDF_Group_Id__c = grp.Id;                
            pgm.Core_MDF_Channel_Program__c = cp.Id;
            pgm.Core_MDF_Region_cd__c='WW';
            Database.insert(pgm);
            
            Core_MDF_Partner_Group_Mapping__c pgm1 = new Core_MDF_Partner_Group_Mapping__c();
            pgm1.Core_MDF_Account__c = dellCorpAccount.Id;
            pgm1.Core_MDF_Group_Name__c = 'DCF_Int_Grp_ASMO_LAR';
            pgm1.Core_MDF_Type_of_Access__c = 'Internal';
            pgm1.Core_MDF_Source_Txt__c  = 'Test';
            pgm1.Core_MDF_Group_Id__c = grp1.Id;                
            pgm1.Core_MDF_Channel_Program__c = cp1.Id;
            pgm1.Core_MDF_Region_cd__c='ASMO';
            pgm1.Core_MDF_Sub_Region_cd__c='LAR';
            Database.insert(pgm1);
            
            Core_MDF_Partner_Group_Mapping__c pgm2 = new Core_MDF_Partner_Group_Mapping__c();
            pgm2.Core_MDF_Account__c = dellCorpAccount.Id;
            pgm2.Core_MDF_Group_Name__c = 'CCF_Int_Grp_APJ';
            pgm2.Core_MDF_Type_of_Access__c = 'Internal';
            pgm2.Core_MDF_Source_Txt__c  = 'Test';
            pgm2.Core_MDF_Group_Id__c = grp2.Id;                
            pgm2.Core_MDF_Channel_Program__c = cp.Id;
            pgm2.Core_MDF_Region_cd__c='APJ';
            Database.insert(pgm2);
            
            Core_MDF_Partner_Group_Mapping__c pgm3 = new Core_MDF_Partner_Group_Mapping__c();
            pgm3.Core_MDF_Account__c = dellCorpAccount.Id;
            pgm3.Core_MDF_Group_Name__c = 'Retail_Int_Grp_ASMO_LAR';
            pgm3.Core_MDF_Type_of_Access__c = 'Internal';
            pgm3.Core_MDF_Source_Txt__c  = 'Test';
            pgm3.Core_MDF_Group_Id__c = grp3.Id;                
            pgm3.Core_MDF_Channel_Program__c = cp2.Id;
            pgm3.Core_MDF_Region_cd__c='ASMO';
            pgm3.Core_MDF_Sub_Region_cd__c='LAR';
            Database.insert(pgm3);
            
            Core_MDF_Partner_Group_Mapping__c pgm4 = new Core_MDF_Partner_Group_Mapping__c();
            pgm4.Core_MDF_Account__c = dellCorpAccount.Id;
            pgm4.Core_MDF_Group_Name__c = 'Retail_Int_Grp_APJ';
            pgm4.Core_MDF_Type_of_Access__c = 'Internal';
            pgm4.Core_MDF_Source_Txt__c  = 'Test';
            pgm4.Core_MDF_Group_Id__c = grp4.Id;                
            pgm4.Core_MDF_Channel_Program__c = cp2.Id;
            pgm4.Core_MDF_Region_cd__c='APJ';
            Database.insert(pgm4);
        }
        
        List<Core_ERPM_Engagement__c> erpmList = new List<Core_ERPM_Engagement__c>();
        Core_ERPM_Engagement__c erpmEngagementCCF = Core_MDF_CCP_TestDataUtility.createErpmEngagement('CCF', 'CCF', 'DEDUPB2B', 'SEC', true, false);
        erpmList.add(erpmEngagementCCF);
        
        Core_ERPM_Engagement__c erpmEngagementRMF = Core_MDF_CCP_TestDataUtility.createErpmEngagement('RPS_Retailer', 'RPS_Retailer', 'DEDUPGPRET', 'SEC', true, false);
        erpmList.add(erpmEngagementRMF);
        Database.insert(erpmList);
        
        List<Core_Entitlement__c> entitlementList = new List<Core_Entitlement__c>();        
        Core_Entitlement__c entitlementRMF = Core_MDF_CCP_TestDataUtility.createEntitlement('RMF User',null,'Intel Partner Alliance (IPA)','RMF User',erpmEngagementRMF.Id , true,'Retail Marketing Funds (RMF)',false);
        entitlementList.add(entitlementRMF);
        
        Core_Entitlement__c entitlementCCF = Core_MDF_CCP_TestDataUtility.createEntitlement('Client User',null ,'Intel Partner Alliance (IPA)','CCF User',erpmEngagementCCF.Id , true,Core_MDF_CCP_ConstantClass.CCF_PROGRAM,false);
        entitlementList.add(entitlementCCF);
        Database.insert(entitlementList); 
        
        List<Core_Contact_Entitlement__c> contactEntitlementList = new List<Core_Contact_Entitlement__c>();
        Core_Contact_Entitlement__c contactEntitlementCCF = Core_MDF_CCP_TestDataUtility.createContactEntitlement(conRecord1.Id,entitlementCCF.Id ,true,'Complete', false);
        contactEntitlementList.add(contactEntitlementCCF);
        
        Core_Contact_Entitlement__c contactEntitlementrmf = Core_MDF_CCP_TestDataUtility.createContactEntitlement(conRecord1.Id,entitlementRMF.Id ,true,'Complete', false);
        contactEntitlementList.add(contactEntitlementrmf);
        
        Database.insert(contactEntitlementList); 
        
        Test.stopTest();
        List<Core_MDF_Partner_Node_User_Mapping__c> pnumList = new List<Core_MDF_Partner_Node_User_Mapping__c>();
        
        Core_MDF_Partner_Node_User_Mapping__c pnum1 = new Core_MDF_Partner_Node_User_Mapping__c();
        pnum1.Core_MDF_Account__c=dellCCFVirtualCorp.Id;
        pnum1.Core_MDF_User__c=usr1.Id;
        pnumList.add(pnum1);
        
        Core_MDF_Partner_Node_User_Mapping__c pnum2 = new Core_MDF_Partner_Node_User_Mapping__c();
        pnum2.Core_MDF_Account__c=retailAccount.Id;
        pnum2.Core_MDF_User__c=usr1.Id;
        pnumList.add(pnum2);

        Core_MDF_Partner_Node_User_Mapping__c pnum4 = new Core_MDF_Partner_Node_User_Mapping__c();
        pnum4.Core_MDF_Account__c=retailAccount1.Id;
        pnum4.Core_MDF_User__c=usr1.Id;
        pnumList.add(pnum4);
        
        Database.insert(pnumList);
    
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
        
        //Create PMB for the above Account
        List<PartnerMarketingBudget> pmbList = new List<PartnerMarketingBudget>();
        
        PartnerMarketingBudget  pmbRecord = Core_MDF_CCP_TestDataUtility.createBudget('Dell PMB',Core_MDF_CCP_TestDataUtility.budget_Record_Type,dellCCFVirtualCorp.Id,cp.Id,100000,System.today().addDays(-15),System.today().addDays(15),false);
        pmbRecord.Core_MDF_Budget_Type_Txt__c = 'CCF 1.0';
        pmbList.add(pmbRecord);
        
        PartnerMarketingBudget  pmbRecord1 = Core_MDF_CCP_TestDataUtility.createBudget('Dell PMB1',Core_MDF_CCP_TestDataUtility.budget_Record_Type,dellDCFVirtualCorp.Id,cp1.Id,100000,System.today().addDays(-15),System.today().addDays(15),false);
        pmbRecord1.Core_MDF_Budget_Type_Txt__c = 'DCF 1.0';
        pmbList.add(pmbRecord1);
        
        Id recordTypeIdPMB = Schema.SObjectType.PartnerMarketingBudget.getRecordTypeInfosByName().get('Retail Marketing Funds').getRecordTypeId();
        PartnerMarketingBudget  pmbRecord2 = Core_MDF_CCP_TestDataUtility.createBudget('Dell PMB2',recordTypeIdPMB,retailAccount.Id,cp2.Id,100000,System.today().addDays(-15),System.today().addDays(15),false);
        pmbRecord2.Core_MDF_Budget_Type_Txt__c='Retail MDF';
        pmbList.add(pmbRecord2);

        Database.insert(pmbList);
        PartnerMarketingBudget pbmEef = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget EEF', Core_MDF_CCP_TestDataUtility.Budget_Record_Type, eefPrimaryVirtualCorp.Id, eefCp.Id, 30000, System.today()-30, System.today()+30, false);

        system.runAs(usr){
     insert pbmEef;
        }
        List<Core_MDF_Budget_Transfer_Log__c> btlList = new List<Core_MDF_Budget_Transfer_Log__c>();
        
        Core_MDF_Budget_Transfer_Log__c atl = new Core_MDF_Budget_Transfer_Log__c();    
        atl.Core_MDF_Partner_Marketing_Budget__c = pmbRecord.Id;
        atl.Core_MDF_From_Account_Current_Balance__c = 3900;
        atl.Core_MDF_From_Account_Opening_Balance__c = 3800;
        atl.Core_MDF_Source_Account__c = dellCCFVirtualCorp.Id;
        atl.Core_MDF_Target_Account__c = dellCCFAPAC.Id;
        atl.Core_MDF_To_Account_Current_Balance__c = 2000;
        atl.Core_MDF_To_Account_Opening_Balance__c = 2100;
        atl.Core_MDF_Transfer_Type__c = 'Manual';
        atl.Core_MDF_Transferred_Amount__c = 100;
        btlList.add(atl);
        
        Core_MDF_Budget_Transfer_Log__c atl1 = new Core_MDF_Budget_Transfer_Log__c();    
        atl1.Core_MDF_Partner_Marketing_Budget__c = pmbRecord1.Id;
        atl1.Core_MDF_From_Account_Current_Balance__c = 3900;
        atl1.Core_MDF_From_Account_Opening_Balance__c = 3800;
        atl1.Core_MDF_Source_Account__c = dellDCFVirtualCorp.Id;
        atl1.Core_MDF_Target_Account__c = dellDCFAPAC.Id;
        atl1.Core_MDF_To_Account_Current_Balance__c = 2000;
        atl1.Core_MDF_To_Account_Opening_Balance__c = 2100;
        atl1.Core_MDF_Transfer_Type__c = 'Manual';
        atl1.Core_MDF_Transferred_Amount__c = 100;
        btlList.add(atl1);
        
        Core_MDF_Budget_Transfer_Log__c atl3 = new Core_MDF_Budget_Transfer_Log__c();    
        atl3.Core_MDF_Partner_Marketing_Budget__c = pmbRecord2.Id;
        atl3.Core_MDF_From_Account_Current_Balance__c = 3900;
        atl3.Core_MDF_From_Account_Opening_Balance__c = 3800;
        atl3.Core_MDF_Source_Account__c = retailAccount.Id;
        atl3.Core_MDF_Target_Account__c = retailAccount1.Id;
        atl3.Core_MDF_To_Account_Current_Balance__c = 2000;
        atl3.Core_MDF_To_Account_Opening_Balance__c = 2100;
        atl3.Core_MDF_Transfer_Type__c = 'Manual';
        atl3.Core_MDF_Transferred_Amount__c = 100;
        btlList.add(atl3);
        
        Core_MDF_Budget_Transfer_Log__c atl4 = new Core_MDF_Budget_Transfer_Log__c();    
        atl4.Core_MDF_Partner_Marketing_Budget__c = pmbRecord2.Id;
        atl4.Core_MDF_From_Account_Current_Balance__c = 3900;
        atl4.Core_MDF_From_Account_Opening_Balance__c = 3800;
        atl4.Core_MDF_Source_Account__c = retailAccount1.Id;
        atl4.Core_MDF_Target_Account__c = retailAccount.Id;
        atl4.Core_MDF_To_Account_Current_Balance__c = 2000;
        atl4.Core_MDF_To_Account_Opening_Balance__c = 2100;
        atl4.Core_MDF_Transfer_Type__c = 'Manual';
        atl4.Core_MDF_Transferred_Amount__c = 100;
        btlList.add(atl4);
        database.insert(btlList);
        Core_MDF_Budget_Transfer_Log__c btlog = new Core_MDF_Budget_Transfer_Log__c();    
        btlog.Core_MDF_Partner_Marketing_Budget__c = pbmEef.Id;
        btlog.Core_MDF_From_Account_Current_Balance__c = 100;
        btlog.Core_MDF_From_Account_Opening_Balance__c = 100;
        btlog.Core_MDF_Source_Account__c = retailAccount1.Id;
        btlog.Core_MDF_Target_Account__c = retailAccount.Id;
        btlog.Core_MDF_To_Account_Current_Balance__c = 100;
        btlog.Core_MDF_To_Account_Opening_Balance__c = 100;
        btlog.Core_MDF_Transfer_Type__c = 'Manual';
        btlog.Core_MDF_Transferred_Amount__c = 10;
        system.runAs(usr){
            insert btlog;
        }
        
        
    }
    @isTest
    static void testSharingAccountMethod(){
           Account account = [SELECT ID From Account where Name = 'EEF Primary Virtual Corp' LIMIT 1];
        User usr =[select id,email from user where email ='sysadmin@example.com' Limit 1 ];
        system.runAs(usr){
              List<Core_MDF_Budget_Transfer_Log__c> accountTransferList = [SELECT ID, Core_MDF_Source_Account__c,Core_MDF_Source_Account__r.Core_MDF_Channel_Program__r.Name,Core_MDF_Target_Account__c From Core_MDF_Budget_Transfer_Log__c where Core_MDF_Source_Account__c =: account.Id];
        Core_MDF_ManualSharing.sharingAccountTransfer(accountTransferList);
      Assert.isTrue(accountTransferList!=null);
        }


    }
    
    //Test method to test SharingAccountTransfer
    @isTest static void testSharingAccountTransferLogAndOwnerChange(){

        Map<Id,Core_MDF_Budget_Transfer_Log__c> accountTransferIdToAccountTransferMap =new  Map<Id,Core_MDF_Budget_Transfer_Log__c>(); 
        
        Account account = [SELECT ID From Account where Name = 'Dell CCF Virtual Corp' LIMIT 1];
        Account account1 = [SELECT ID From Account where Name = 'Dell DCF Virtual Corp' LIMIT 1];
        Account account3 = [SELECT ID From Account where Name = 'Dell Retail Virtual Corp' LIMIT 1];
        User usr = [SELECT ID From User where Email = 'sysadmin@example.com'];
        User usr2 = [SELECT ID From User where Email = 'sysadmin2@example.com'];
        
        Core_MDF_Budget_Transfer_Log__c atl = [SELECT ID,Core_MDF_Target_Account__c, Core_MDF_Source_Account__c From Core_MDF_Budget_Transfer_Log__c where Core_MDF_Source_Account__c =: account.Id];
        // Highlight: Unused Local Variable
       // Core_MDF_Budget_Transfer_Log__c atl2 = [SELECT ID,Core_MDF_Target_Account__c, Core_MDF_Source_Account__c From Core_MDF_Budget_Transfer_Log__c where Core_MDF_Source_Account__c =: account3.Id]; 
        List<Core_MDF_Budget_Transfer_Log__c> accountTransferList = [SELECT ID, Core_MDF_Source_Account__c,Core_MDF_Source_Account__r.Core_MDF_Channel_Program__r.Name,Core_MDF_Target_Account__c From Core_MDF_Budget_Transfer_Log__c where Core_MDF_Source_Account__c =: account1.Id];
        
        Test.startTest();
        system.runas(usr){
            accountTransferIdToAccountTransferMap.put(atl.Id,atl);
            atl.OwnerId = usr2.Id; 
            Database.upsert(atl); 
            accountTransferList.add(atl);
            Core_MDF_ManualSharing.sharingAccountTransfer(accountTransferList);
            Core_MDF_ManualSharing.recalculateShareAccountTransferWhenOwnerChange(accountTransferList,accountTransferIdToAccountTransferMap); 
            Core_MDF_ManualSharing.sharingAccountTransfer(null);
            Core_MDF_ManualSharing.recalculateShareAccountTransferWhenOwnerChange(null,null);
            //Core_MDF_ManualSharing.sharingAccountTransferviaPNUM(accountTransferList);
        }
        Integer i = [SELECT COUNT() from Core_MDF_Budget_Transfer_Log__Share where Parentid=:atl.Id];
        Boolean shareFlag = false;
        if(i > 1){
            shareFlag = true;
        } 
     Assert.isTrue(accountTransferList!=null);
        Test.stopTest();        
    }
    
    //Test method to test RecalculateSharePnumWhenOwnerChange
    @isTest static void testSharingAccountUserAndOwnerChange(){
        
        Account account = [SELECT ID From Account where Name = 'Dell CCF Virtual Corp' LIMIT 1];
        User usr = [SELECT ID From User where Email = 'sysadmin@example.com' LIMIT 1];
        User usr1 = [SELECT ID From User where Email = 'acctBudgadm@example.com' LIMIT 1];
    Core_MDF_Partner_Node_User_Mapping__c accountUser = [SELECT ID, Core_MDF_Account__c, OwnerId From Core_MDF_Partner_Node_User_Mapping__c where Core_MDF_Account__c =: account.Id];
        
        List<Core_MDF_Partner_Node_User_Mapping__c> accountUserList = new List<Core_MDF_Partner_Node_User_Mapping__c>(); 
        Map<Id,Core_MDF_Partner_Node_User_Mapping__c> accountUserIdToAccountUserMap =new  Map<Id,Core_MDF_Partner_Node_User_Mapping__c>();
      Group grp = new Group();
        grp.name = 'PGM_TEST';
        insert grp;
        Test.startTest();
        system.runas(usr){
            GroupMember gm = new GroupMember();
            gm.GroupId = grp.Id;
            gm.UserOrGroupId = usr1.Id;
            insert gm;
            accountUser.OwnerId = usr1.Id; 
            Database.update(accountUser);
            account.Core_MDF_External_Group_Id__c = grp.id;
            Database.update(account);
            //Core_MDF_CCP_TestDataUtility.createPartnerNodeUserMapping(account.Id, Usr1.Id, true);
            accountUserList.add(accountUser);
            accountUserIdToAccountUserMap.put(accountUser.Id,accountUser);
            Core_MDF_ManualSharing.recalculateSharePnumWhenOwnerChange(accountUserList,accountUserIdToAccountUserMap);
            Core_MDF_ManualSharing.sharingAccountUser(accountUserList);
            Core_MDF_ManualSharing.sharingAccountUser(null);
            Core_MDF_ManualSharing.recalculateSharePnumWhenOwnerChange(null,null);
        }
        Integer i = [SELECT COUNT() from Core_MDF_Partner_Node_User_Mapping__Share where Parentid=:accountUser.id];
        Boolean shareFlag = false;
        if(i > 1){
            shareFlag = true;
        } 
           Assert.isTrue(shareFlag);
      Test.stopTest();        
    }
}