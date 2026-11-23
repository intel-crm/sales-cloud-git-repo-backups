/****************************************************************************************************************************************
* Class Name  : Core_MDF_CCPAccount_Onboard_Test
* Version     : 1.0 
* Created Date: 06-August-2020
* Modification Log :
* Developer : SM                       Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------

*****************************************************************************************************************************************/

@isTest(SeeAllData = false)
public class Core_MDF_CCPAccount_Onboard_Test {
    
    @TestSetup 
    static void createTestData() 
    { 
        test.startTest();
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        // Creating User with utility class 
        //PermissionSet accountManager = [select id from PermissionSet where name='Core_MDF_CCP_Internal_DCF_Acct_Mgr'];
        User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr1.LastName = 'User Test1';
        usr1.UserRoleId = usRole.Id;
        Database.insert(usr1);
        
        
        
        
        System.runAs(usr1){
            List <Core_Trigger_Executions__c> Customlist = new List <Core_Trigger_Executions__c>();
            Core_Trigger_Executions__c Settings1 = new Core_Trigger_Executions__c();
            Settings1.Name = 'Core_MDF_ValidatePFAChange';
            Settings1.Core_Active__c = True;
            Settings1.Core_Class_Name__c = 'Core_AccountHandler';
            Settings1.Core_Description__c = 'To validate the parent fund account changes';
            Settings1.Core_Object__c = 'Account';
            Settings1.Core_Trigger_Events__c = 'Before Update';
            Customlist.add(Settings1);
            
            Core_Trigger_Executions__c Settings2 = new Core_Trigger_Executions__c();
            Settings2.Name = 'Core_MDF_ValidatePFAChangeOnAftrUpdt';
            Settings2.Core_Active__c = True;
            Settings2.Core_Class_Name__c = 'Core_AccountHandler';
            Settings2.Core_Description__c = 'To validate the parent fund account changes on after update';
            Settings2.Core_Object__c = 'Account';
            Settings2.Core_Trigger_Events__c = 'After Update';
            Customlist.add(Settings2);
            
            Core_Trigger_Executions__c Settings3 = new Core_Trigger_Executions__c();
            Settings3.Name = 'preventUncoveredAccountChangeOppStatus';
            Settings3.Core_Active__c = True;
            Settings3.Core_Class_Name__c = 'Core_AccountHandler';
            Settings3.Core_Description__c = 'To prevent Uncovered Account Change Opp Status';
            Settings3.Core_Object__c = 'Account';
            Settings3.Core_Trigger_Events__c = 'Before Update';
            Customlist.add(Settings3);
            
            Core_Trigger_Executions__c Settings4 = new Core_Trigger_Executions__c();
            Settings4.Name = 'Core_MDF_Account_node_share';
            Settings4.Core_Active__c = True;
            Settings4.Core_Class_Name__c = 'Core_Account';
            Settings4.Core_Description__c = 'method is used Create PNUM based External sharing group';
            Settings4.Core_Object__c = 'Account';
            Settings4.Core_Trigger_Events__c = 'after insert';
            Customlist.add(Settings4);
             Core_Trigger_Executions__c Settings5 = new Core_Trigger_Executions__c();
            Settings5.Name = 'UCD_ACM_IgnoreUpdateAccountFields';
            Settings5.Core_Active__c = True;
            Settings5.Core_Class_Name__c = 'Core_Account';
            Settings5.Core_Description__c = 'test';
            Settings5.Core_Object__c = 'Account';
            Settings5.Core_Trigger_Events__c = 'Before insert, before update';
            Customlist.add(Settings5);
             Core_Trigger_Executions__c Settings6 = new Core_Trigger_Executions__c();
            Settings6.Name = 'UCD_ACM_UpdateRecordType';
            Settings6.Core_Active__c = True;
            Settings6.Core_Class_Name__c = 'Core_Account';
            Settings6.Core_Description__c = 'test';
            Settings6.Core_Object__c = 'Account';
            Settings6.Core_Trigger_Events__c = 'Before insert, before update';
            Customlist.add(Settings6);
             Core_Trigger_Executions__c Settings7 = new Core_Trigger_Executions__c();
            Settings7.Name = 'UCD_ACM_UpdateHierarchy';
            Settings7.Core_Active__c = True;
            Settings7.Core_Class_Name__c = 'Core_Account';
            Settings7.Core_Description__c = 'test';
            Settings7.Core_Object__c = 'Account';
            Settings7.Core_Trigger_Events__c = 'Before insert, before update';
            Customlist.add(Settings7);
             Core_Trigger_Executions__c Settings8 = new Core_Trigger_Executions__c();
            Settings8.Name = 'UpdatePrimaryDirectAccount';
            Settings8.Core_Active__c = True;
            Settings8.Core_Class_Name__c = 'Core_Account';
            Settings8.Core_Description__c = 'test';
            Settings8.Core_Object__c = 'Account';
            Settings8.Core_Trigger_Events__c = 'After Insert, After Update';
            Customlist.add(Settings8);
             Core_Trigger_Executions__c Settings9 = new Core_Trigger_Executions__c();
            Settings9.Name = 'CIMIDStampCheck';
            Settings9.Core_Active__c = True;
            Settings9.Core_Class_Name__c = 'Core_Account';
            Settings9.Core_Description__c = 'test';
            Settings9.Core_Object__c = 'Account';
            Settings9.Core_Trigger_Events__c = 'After Update';
            Customlist.add(Settings9);
        
        Core_Trigger_Executions__c Settings10 = new Core_Trigger_Executions__c();
            Settings10.Name = 'Core_MDF_MultipleVCForSameProg';
            Settings10.Core_Active__c = True;
            Settings10.Core_Class_Name__c = 'Core_AccountHandler';
            Settings10.Core_Description__c = 'To Prevent Multiple Virtual Corp for same program.';
            Settings10.Core_Object__c = 'Account';
            Settings10.Core_Trigger_Events__c = 'before insert';
            Customlist.add(Settings10);
            database.insert(Customlist);
            
            // Creating channel program with utility class
            List<ChannelProgram> channelProgList = new List<ChannelProgram>();
            
            ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.CCF_PROGRAM,'Client CoMarketing Fund', false);
            channelProgList.add(cp);
            
            ChannelProgram cp1 = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.RMF_PROGRAM,'Retail Marketing Funds', false);
            channelProgList.add(cp1);
            Database.insert(channelProgList);
            
            Account masterAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Test Master Account', 
                                                                              Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            masterAccount.Core_Account_Type__c = 'Reseller';
            masterAccount.Industry = 'Food & Beverage';
            Database.insert(masterAccount);
            
            List<Account> level1Accounts = new List<Account>();
            
            Account ccfVirtualCorp = Core_MDF_CCP_TestDataUtility.createAccount ('Test Account VC - CCF', 
                                                                         cp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            ccfVirtualCorp.Core_MDF_Parent_Fund_Account__c = masterAccount.Id;
            ccfVirtualCorp.OwnerId = usr1.Id;
            level1Accounts.add(ccfVirtualCorp);
            
            Account retailVirtualCorp = Core_MDF_CCP_TestDataUtility.createAccount ('Test Account VC - Retail', 
                                                                         cp1.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            retailVirtualCorp.Core_MDF_Parent_Fund_Account__c = masterAccount.Id;
            retailVirtualCorp.Core_Geo__c = 'APJ';
            retailVirtualCorp.Core_Sub_Geo__c = 'ROA';
            level1Accounts.add(retailVirtualCorp);
            
            database.insert(level1Accounts);
           
        }
        test.stopTest();
        
    }
    
    @isTest 
    static void validateCCPAccount_Onboard(){ 
    
    Test.startTest();
        
        Core_Trigger_Executions__c enableIPAMDFAccountOnboarding = new Core_Trigger_Executions__c();
        enableIPAMDFAccountOnboarding.name = 'Core_MDF_EnableIPAMDFAccountOnboarding';
        enableIPAMDFAccountOnboarding.Core_Object__c = 'Account';
        enableIPAMDFAccountOnboarding.Core_Trigger_Events__c = 'Before Update';
        enableIPAMDFAccountOnboarding.Core_Active__c = TRUE;
        enableIPAMDFAccountOnboarding.Core_Description__c = 'To enable IPA MDF Account OnBoarding';
        enableIPAMDFAccountOnboarding.Core_Class_Name__c = 'Core_AccountHandler';
        insert enableIPAMDFAccountOnboarding;
        
      // Creating channel program with utility class
    ChannelProgram cp1 = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Technical_program_name'),Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Technical_program_name'), true);

    Id acctRecord_Type = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Core_Partner_Account_Group').getRecordTypeId();
        
    // Creating Account with utility class
    Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test IPA Account', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
     acc1.Core_Intel_Partner_Alliance_PartnerGroup__c=true;
        acc1.Core_MDF_CoMarketingActive__c = false;
        insert acc1;

        //Creating Contact for Partner User
    Contact conRecord1 = Core_MDF_CCP_TestDataUtility.createContact(acc1.Id,true);
        conRecord1.Core_Primary_Contact__c=true;
        Database.update(conRecord1);
        
        
        Id PAG_Account_Record_Type = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Core_Partner_Account_Group').getRecordTypeId();
        Account pagAccount = new Account(Name='IPA PAG Account', RecordTypeId=PAG_Account_Record_Type);           
        insert pagAccount;
            
        Account pagAcc = [Select id from Account where Name='IPA PAG Account' and RecordTypeId=:PAG_Account_Record_Type limit 1];

        Core_Account_Group_Member__c agm = new Core_Account_Group_Member__c(Core_Partner_Account_Id__c=pagAcc.Id,Core_Intel_Account_Id__c=acc1.Id);
        insert agm;

        ChannelProgram cpid = new ChannelProgram(); //Channel Program
        cpid.Name='Intel Partner Alliance';
        //cpid.PRM_programCode__c='IPA';
        insert cpid;   
       
        ChannelProgramLevel cplTest = new ChannelProgramLevel(); //Channel Program Level
        cplTest.Name='Titanium';
        cplTest.ProgramId=cpid.Id;
        //insert cplTest;
        
        List<PRM_PartnerBenefit__c> pbList = new List<PRM_PartnerBenefit__c>();
        
        PRM_PartnerBenefit__c pbTest4 = new PRM_PartnerBenefit__c(); //Partner Benefit
        pbTest4.Name = 'SP Enthusiast MDF';
        pbTest4.PRM_Benefit_Cd__c = 'SPMDF';
        pbTest4.PRM_Channel_Program_Id__c= cpid.id;
        pbTest4.PRM_InActive_Ind__c = false;
        pbTest4.PRM_Account_Type_Nm__c='Both';
        pbList.add(pbTest4);
        //insert pbList;
        
        List<PRM_AccountChannelMembership__c> acmList = new List<PRM_AccountChannelMembership__c>();
        PRM_AccountChannelMembership__c acctChnlMemTest= new PRM_AccountChannelMembership__c(); //Account Channel Membership
        acctChnlMemTest.PRM_Account_Id__c=acc1.Id;
        acctChnlMemTest.PRM_Channel_Program_Id__c=cpid.Id;
        acctChnlMemTest.PRM_Channel_Program_Level_Id__c=cplTest.Id;
        acctChnlMemTest.PRM_Partner_Role__c='SP MDF';
        acctChnlMemTest.PRM_Status_Nm__c='Approved';
        acctChnlMemTest.PRM_Partner_Role__c='Service Provider';
        acmList.add(acctChnlMemTest);
        
        
        //insert acmList;
        
        PRM_PartnerType__c ptTest = new PRM_PartnerType__c();
        ptTest.Name = 'MDF';
        ptTest.PRM_channelprogram__c = cpid.id;
        ptTest.PRM_Role_Name__c = 'Service Provider MDF';
        ptTest.PRM_PartneryTypeCode__c = 'CSP MDF';
        ptTest.PRM_PartnerRoleCode__c = 'SPR MDF';
      // insert ptTest;
        
        PRM_VXBnftMatrix__c bmTest2 = new PRM_VXBnftMatrix__c();
        bmTest2.PRM_Partner_Benefit_Id__c = pbTest4.Id;
        bmTest2.PRM_Channel_Program_Id__c = cpid.Id;
        bmTest2.PRM_Channel_Program_Level_Id__c = cplTest.Id;
        bmTest2.PRM_Partner_Type_Id__c = ptTest.Id;
        bmTest2.PRM_Approval_Type_Nm__c = 'Automatic';
        bmTest2.PRM_Covered_Account_Ind__c = true;
        bmTest2.PRM_IsActive_Ind__c = true;
        bmTest2.PRM_Partner_Role_Nm__c='Service Provider';
        //insert bmTest2;
        
        PRM_BatchCustomSetting__c bcss = new PRM_BatchCustomSetting__c();
        bcss.name= 'BatchFieldValues';
        bcss.PRM_MP_Benefits__c='Speciality';
        bcss.PRM_PartnerRole__c='Service Provider';
        bcss.PRM_PartnerType__c='Cloud Service Provider (CSP)';
        insert bcss;
             
         
        Id selectBenRT=Schema.getGlobalDescribe().get('PRM_Specialty__c').getDescribe().getRecordTypeInfosByDeveloperName().get('PRM_Select_Benefits').getRecordTypeId();  
        PRM_Specialty__c spec1 = new PRM_Specialty__c();
        spec1.name='Enthusiast PC Specialty';
        spec1.PRM_Description_Txt__c='This is description';
        spec1.PRM_Funding_BU_Nm__c='CCG Sales Group';
        spec1.PRM_Role_Nm__c='Service Provider';
        spec1.PRM_Tier_Nm__c='Gold';
        spec1.PRM_Start_Date_Dt__c= system.today() + 7;
        spec1.PRM_End_Date_Dt__c= spec1.PRM_Start_Date_Dt__c + 5;
        spec1.PRM_Access_Level_Nm__c='Public';
        spec1.RecordTypeId=selectBenRT;
        spec1.PRM_Inactive_Ind__c=false;
        insert spec1;
        
        
            PRM_Account_Specialty_Association__c asa = new PRM_Account_Specialty_Association__c();
            asa.PRM_InActive_Ind__c  = FALSE;
            asa.PRM_Specialty_Id__c = spec1.ID;
            asa.PRM_Account_Id__c =pagAcc.id;
            insert asa;
        
        PRM_AccountBenefitAssociation__c accBenAssoc = new PRM_AccountBenefitAssociation__c();
        accBenAssoc.PRM_Account_Id__c = acc1.Id;
        accBenAssoc.PRM_Source__c = 'Specialty';
        accBenAssoc.PRM_Partner_Benefit_Id__c = pbTest4.Id;
        accBenAssoc.PRM_Status_Nm__c='Active';
      //  Database.insert(accBenAssoc);
        
        // Updating Accounts 
        acc1.isPartner = true;
        acc1.Core_MDF_CoMarketingActive__c = true;
        //acc1.Core_IPA_One_Partner_Id__c=acc.id;
        acc1.Core_Intel_Partner_Alliance_PartnerGroup__c=true;
        Database.update(acc1);
        Set<Account> accInSet = new Set<Account>();
        accInSet.add(acc1);
        Set<Account> accSet = new Set<Account>();
        List<Account> accList = new List<Account>();
        accList.add(acc1);
        accSet = Core_MDF_CCPAccount_Onboard.hasComarketingActive(accInSet);
        Assert.isNotNull(accSet);
        accSet = Core_MDF_CCPAccount_Onboard.isOpiAccount(accList);
        try{
            accSet = Core_MDF_CCPAccount_Onboard.hasMDFBenefit(accInSet);
        }catch(Exception e){
            Assert.isNotNull(e.getMessage());
        }
        List<Core_MDF_CCPAccountOnboardWrapper> accWrapLst = new List<Core_MDF_CCPAccountOnboardWrapper>();
        Core_MDF_CCPAccountOnboardWrapper accWrap = new Core_MDF_CCPAccountOnboardWrapper();
        accWrap.account=acc1;
        accWrap.program=Label.Core_MDF_IPA_Technical_program_name;
        accWrapLst.add(accWrap);
        Core_MDF_CCPAccount_Onboard.onboardAccountToCCP(accWrapLst);
        
        //To hold group name
        String groupName;
        //To hold group developer name
        String groupDeveloperName;
        //To hold intial group developer name
        Integer initalGroupDeveloperName;
        //To hold account name length
        Integer accountNameLength;
        //Map of technical program name to program abbrivated name
      Map<string,string> prgmAbbName = new Map<string,string>();
        //Preparing map of technical program name to program abbrivated name
        for(Core_MDF_ChannelProgram__mdt cpm : [SELECT Core_MDF_Abbreviated_ProgramName_txt__c, Core_MDF_Technical_Program_Name__c, MasterLabel
                                                FROM Core_MDF_ChannelProgram__mdt
                                                WHERE Core_MDF_Technical_Program_Name__c = :Label.Core_MDF_IPA_Technical_program_name])
        {
            prgmAbbName.put(cpm.Core_MDF_Technical_Program_Name__c, cpm.Core_MDF_Abbreviated_ProgramName_txt__c);
        }
        
        ChannelProgram prgm = [Select Id, Core_MDF_Technical_Program_Name__c, Name 
                                   from ChannelProgram 
                                   where Core_MDF_Technical_Program_Name__c = :Label.Core_MDF_IPA_Technical_program_name];
         //Remove all the special characters and change to Upper Case
            //String accountName = acc1.Name.split('#')[0].replaceAll('[^a-zA-Z\\s+]', '').deleteWhitespace().toUpperCase();
           // initalGroupDeveloperName = ('Core_MDF_CCP_'+'_'+prgmAbbName.get(Label.Core_MDF_IPA_Technical_program_name).left(4)+'_'+'EXTERNAL').length();
           // accountNameLength = math.abs(35 - initalGroupDeveloperName);
            groupDeveloperName = 'Core_MDF_CCP_'+String.valueOf(acc1.Id)+'_'+prgmAbbName.get(Label.Core_MDF_IPA_Technical_program_name)+'_'+'EXT';
            groupName = 'CCP '+String.valueOf(acc1.Id)+ ' ' + prgmAbbName.get(Label.Core_MDF_IPA_Technical_program_name) + ' ' + ' EXT';
            
        
        
          /*Core_MDF_Partner_Group_Mapping__c pgm = [Select id, Core_MDF_Account__c, Core_MDF_Channel_Program__c, Core_MDF_Group_Name__c,
                                                 Core_MDF_Type_of_Access__c From Core_MDF_Partner_Group_Mapping__c where  Core_MDF_Account__c = :acc1.Id];
          System.assertEquals(acc1.Id, pgm.Core_MDF_Account__c);
          System.assertEquals(prgm.Id, pgm.Core_MDF_Channel_Program__c);
          System.assertEquals(groupDeveloperName, pgm.Core_MDF_Group_Name__c);
            System.assertEquals('External', pgm.Core_MDF_Type_of_Access__c);
        
        ID coMarketingRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Core_MDF_Co_Marketing').getRecordTypeId();
         Account corpAcc = [Select Id, Name, RecordTypeId, Core_MDF_CoMarketingActive__c, Core_MDF_Parent_Fund_Account__c, Core_MDF_Channel_Program__c 
                           From Account where Core_MDF_Parent_Fund_Account__c = :acc1.Id]; 

            System.assertEquals(coMarketingRecordTypeId,corpAcc.RecordTypeId);
            System.assertEquals(acc1.Id,corpAcc.Core_MDF_Parent_Fund_Account__c);
            System.assertEquals(prgm.Id,corpAcc.Core_MDF_Channel_Program__c);
            System.assertEquals('IPA - '+acc1.Name,corpAcc.Name);*/

        }
    @isTest
    static void testValidateMDFParentFundAccChanges()
    {
        User usr = [Select id from user where LastName=: 'User Test1' limit 1];
        test.startTest();
        System.runAs(usr){
            ChannelProgram cp = [Select  id from ChannelProgram where Name =:Core_MDF_CCP_ConstantClass.CCF_PROGRAM];
            Account accVC = [Select Id from Account where Name =: 'Test Account VC - CCF'];
            List<Account> acctList = new List<Account>();
            Account accLevel1 = Core_MDF_CCP_TestDataUtility.createAccount ('Account Level 1', 
                                                                         cp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            accLevel1.Core_MDF_Parent_Fund_Account__c = accVC.Id;
            acctList.add(accLevel1);
            
            Account accLevel1peer = Core_MDF_CCP_TestDataUtility.createAccount ('Account Level 1 peer', 
                                                                         cp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            accLevel1peer.Core_MDF_Parent_Fund_Account__c = accVC.Id;
            acctList.add(accLevel1peer);
            database.insert(acctList);
            
            List<Account> acctLeve2List = new List<Account>();
            Account accLevel2 = Core_MDF_CCP_TestDataUtility.createAccount ('Account Level 2', 
                                                                         cp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            accLevel2.Core_MDF_Parent_Fund_Account__c = accLevel1.Id;
            accLevel2.Core_MDF_Enabled_Auto_Transfer__c = True;
            accLevel2.Core_MDF_Auto_Transfer_Account__c = accVC.Id;
            acctLeve2List.add(accLevel2);
            
            Account accLevel2peer = Core_MDF_CCP_TestDataUtility.createAccount ('Account Level 2 peer', 
                                                                         cp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            accLevel2peer.Core_MDF_Parent_Fund_Account__c = accLevel1peer.Id;
            acctLeve2List.add(accLevel2peer);
            database.insert(acctLeve2List);
            
            Account accLevel3 = Core_MDF_CCP_TestDataUtility.createAccount ('Account Level 3', 
                                                                         cp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            accLevel3.Core_MDF_Parent_Fund_Account__c = accLevel2.Id;
            accLevel3.Core_MDF_Enabled_Auto_Transfer__c = True;
            accLevel3.Core_MDF_Auto_Transfer_Account__c = accVC.Id;
            database.insert(accLevel3);
            
            Account accLevel4 = Core_MDF_CCP_TestDataUtility.createAccount ('Account Level 4', 
                                                                         cp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            accLevel4.Core_MDF_Parent_Fund_Account__c = accLevel3.Id;
            accLevel4.Core_MDF_Enabled_Auto_Transfer__c = True;
            accLevel4.Core_MDF_Auto_Transfer_Account__c = accVC.Id;
            database.insert(accLevel4);
            
            try{
                accLevel1.Core_MDF_Parent_Fund_Account__c = accLevel1peer.Id;
                database.update(accLevel1);
            }
            catch(Exception e){
                 System.Assert(e.getMessage().contains(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_EnableAutoTransfer_error')));
            }
            
            try{
                accLevel1peer.Core_MDF_Parent_Fund_Account__c = accLevel2peer.Id;
                database.update(accLevel1peer);
            }
            catch(Exception e){
                System.Assert(e.getMessage().contains(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Child_ParenFundAccount')));
            }
            
        } 
        test.stopTest();
    }
    
    @isTest
    static void testValidateAccountHierarchyforCCP(){
        User usr = [Select id from user where LastName=: 'User Test1' limit 1];
        test.startTest();
        System.runAs(usr){
            ChannelProgram cp = [Select  id from ChannelProgram where Name =:Core_MDF_CCP_ConstantClass.CCF_PROGRAM];
            Account accVC = [Select Id from Account where Name =: 'Test Account VC - CCF'];
            List<Account> acctList = new List<Account>();
            Account accLevel1 = Core_MDF_CCP_TestDataUtility.createAccount ('Account Level 1', 
                                                                         cp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            accLevel1.Core_MDF_Parent_Fund_Account__c = accVC.Id;
            acctList.add(accLevel1);
            
            Account accLevel1peer = Core_MDF_CCP_TestDataUtility.createAccount ('Account Level 1 peer', 
                                                                         cp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            accLevel1peer.Core_MDF_Parent_Fund_Account__c = accVC.Id;
            acctList.add(accLevel1peer);
            database.insert(acctList);
            
            Account accLevel2 = Core_MDF_CCP_TestDataUtility.createAccount ('Account Level 2', 
                                                                         cp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            accLevel2.Core_MDF_Parent_Fund_Account__c = accLevel1.Id;
            database.insert(accLevel2);
            
            Account accLevel3 = Core_MDF_CCP_TestDataUtility.createAccount ('Account Level 3', 
                                                                         cp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            accLevel3.Core_MDF_Parent_Fund_Account__c = accLevel2.Id;
            database.insert(accLevel3);
            
            Account accLevel4 = Core_MDF_CCP_TestDataUtility.createAccount ('Account Level 4', 
                                                                         cp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            accLevel4.Core_MDF_Parent_Fund_Account__c = accLevel3.Id;
            database.insert(accLevel4);
            
            try{
                accLevel1.Core_MDF_Parent_Fund_Account__c = accLevel1peer.Id;
                database.update(accLevel1);
            }
            catch(Exception e){
                System.Assert(e.getMessage().contains(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Five_levels_hierarchy')));
            }
        }
        test.stopTest();
    }
        
    @isTest
    static void testValidateAccountHierarchyforRetail(){
        User usr = [Select id from user where LastName=: 'User Test1' limit 1];
        test.startTest();
        System.runAs(usr){
            ChannelProgram cp1 = [Select  id from ChannelProgram where Name =: 'Retail Marketing Funds'];
            Account accVC = [Select Id from Account where Name =: 'Test Account VC - Retail'];
            List<Account> acctList = new List<Account>();
            Account accLevel1 = Core_MDF_CCP_TestDataUtility.createAccount ('Retail Account Level 1', 
                                                                         cp1.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            accLevel1.Core_MDF_Parent_Fund_Account__c = accVC.Id;
            acclevel1.Core_Geo__c = 'APJ';
            acclevel1.Core_Sub_Geo__c = 'ROA';
            acctList.add(accLevel1);
            
            Account accLevel1peer = Core_MDF_CCP_TestDataUtility.createAccount ('Retail Account Level 1 peer', 
                                                                         cp1.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            accLevel1peer.Core_MDF_Parent_Fund_Account__c = accVC.Id;
            accLevel1peer.Core_Geo__c = 'APJ';
            accLevel1peer.Core_Sub_Geo__c = 'ROA';
            acctList.add(accLevel1peer);
            database.insert(acctList);
            
            Account accLevel2 = Core_MDF_CCP_TestDataUtility.createAccount ('Retail Account Level 2', 
                                                                         cp1.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            accLevel2.Core_MDF_Parent_Fund_Account__c = accLevel1.Id;
            accLevel2.Core_Geo__c = 'APJ';
            accLevel2.Core_Sub_Geo__c = 'ROA';
            database.insert(accLevel2);
            
            
            try{
                accLevel1.Core_MDF_Parent_Fund_Account__c = accLevel1peer.Id;
                database.update(accLevel1);
                Core_MDF_CCPAccount_Onboard.isAccountEligibleForMDF(acctList);
            }
            catch(Exception e){
                System.Assert(e.getMessage().contains(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Retail_Three_level_hierarchy')));
            }
        }
        test.stopTest();
    }
     @isTest
    static void testPreventUncoveredAccountChangeOnOppStatus(){
        User usr = [Select id from user where LastName=: 'User Test1' limit 1];
        test.startTest();
        System.runAs(usr){
            //ChannelProgram cp = [Select  id from ChannelProgram where Name =: 'Client Co-Marketing Fund'];
            //Id opportunityRecordtype = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Core_Opportunity').getRecordTypeId();
            Account accVC = [Select Id,OwnerId  from Account where Name =: 'Test Account VC - CCF'];
            accVC.OwnerId = Label.Core_Uncovered_Account_ID;
            database.update(accVC);
        }
    }
    
    @isTest
    static void testpreventMultipleVCForSameProg(){
         User usr = [Select id from user where LastName=: 'User Test1' limit 1];
        test.startTest();
        System.runAs(usr){
            ChannelProgram cp = [Select  id from ChannelProgram where Name =:Core_MDF_CCP_ConstantClass.CCF_PROGRAM];
            Account masterAccount = [Select Id from Account where Name =: 'Test Master Account'];
            Account vcAccount = [Select Id,Name from Account where Name =: 'Test Account VC - CCF'];
            Account ccfVirtualCorp = Core_MDF_CCP_TestDataUtility.createAccount ('Test Account VC - CCF', 
                                                                         cp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            ccfVirtualCorp.Core_MDF_Parent_Fund_Account__c = masterAccount.Id;
            ccfVirtualCorp.OwnerId = usr.Id;
            try{
                database.insert(ccfVirtualCorp);
            }
            catch(Exception e){
                System.Assert(e.getMessage().contains(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_MultipleVCForSameProgram1')+' '+vcAccount.Name+' '+Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_MultipleVCForSameProgram2')));
            }
        }
    }
}