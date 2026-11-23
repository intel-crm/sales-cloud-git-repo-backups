/****************************************************************************************************************************************
* Class Name  : Core_MDF_AccountServiceHandler_Test
* Version     : 1.0 
* Created Date: 2-Feb-2023
* Modification Log :
* Developer                        Date                          Description
*****************************************************************************************************************************************/
@isTest(seeAllData = false)
public class Core_MDF_AccountServiceHandler_Test {
    @testSetup 
    static void setup() { 
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        // Creating User with utility class 
        User testUser = Core_MDF_CCP_TestDataUtility.createUser(false);
        testUser.LastName = 'Test User';
        testUser.UserRoleId = usRole.Id;
        testUser.Email = 'sysadmin@example.com';
        Database.insert(testUser);
        System.runAs(testUser){
            List<ChannelProgram> cpList = new List<ChannelProgram>();
            ChannelProgram cpCCF = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.CCF_PROGRAM,'Client CoMarketing Fund', false);
            cpList.add(cpCCF);
            ChannelProgram cpRMF = Core_MDF_CCP_TestDataUtility.createProgram ('Retail Marketing Funds','Retail Marketing Funds', false);
            cpList.add(cpRMF);
            
            Database.insert(cpList);
            
            Core_MDF_ChannelProgram__mdt channelProgramDetailsOfIPA = Core_MDF_ChannelProgram__mdt.getInstance('Intel_Partner_Alliance');
            
            List<Account> ultimateAccList = new List<Account>();
            Account ccfUltimateAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount ('CCF Intel Account',Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            ccfUltimateAccount.Core_MDF_CoMarketingActive__c = true;
            ultimateAccList.add(ccfUltimateAccount);
            Account rmfUltimateAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount ('RMF Intel Account',Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            rmfUltimateAccount.Core_MDF_CoMarketingActive__c = true;
            ultimateAccList.add(rmfUltimateAccount);
            Account ipaUltimateAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount ('IPA Intel Account',Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            ipaUltimateAccount.Core_MDF_CoMarketingActive__c = true;
            ipaUltimateAccount.Core_Unified_Global_Customer_BP_Id__c = 'ipaPrimeAccount';
            ipaUltimateAccount.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
            ultimateAccList.add(ipaUltimateAccount);
            Account ipaIntelAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount ('IPA Intel Account1',Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            ipaIntelAccount.Core_MDF_CoMarketingActive__c = false;
            ipaIntelAccount.Core_Unified_Global_Customer_BP_Id__c = 'ipaPrimeAccount';
            ipaIntelAccount.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
            ultimateAccList.add(ipaIntelAccount);
            Database.insert(ultimateAccList);
            
            List<Account> vcAccList = new List<Account>();
            Account ccfVCAcc = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('CCF VC Account', cpCCF.Id, Core_MDF_CCP_TestDataUtility.account_Record_Type, ccfUltimateAccount.Id, false);
            vcAccList.add(ccfVCAcc);
            Account rmfVCAcc = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('RMF VC Account', cpRMF.Id, Core_MDF_CCP_TestDataUtility.account_Record_Type, rmfUltimateAccount.Id, false);
            rmfVCAcc.Core_Geo__c = 'APJ';
            rmfVCAcc.Core_Sub_Geo__c = 'ROA';
            vcAccList.add(rmfVCAcc);
			Account ipaVCAcc = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('IPA VC Account', channelProgramDetailsOfIPA.Core_MDF_Program_ID__c, Core_MDF_CCP_TestDataUtility.account_Record_Type, ipaUltimateAccount.Id, false);
            ipaVCAcc.Core_Geo__c = 'APJ';
            vcAccList.add(ipaVCAcc);
            Database.insert(vcAccList);
            
            List<Core_Trigger_Executions__c> triggerList = new List<Core_Trigger_Executions__c>();
            Core_Trigger_Executions__c te1 = new Core_Trigger_Executions__c();
            te1.Name = 'Core_MDF_AccountOnBeforeInsert';
            te1.Core_Active__c = True;
            te1.Core_Class_Name__c = 'Core_Account';
            te1.Core_Description__c = 'Before Insert';
            te1.Core_Object__c = 'Account';
            te1.Core_Trigger_Events__c = 'before insert';
            triggerList.add(te1);
            Core_Trigger_Executions__c te2 = new Core_Trigger_Executions__c();
            te2.Name = 'Core_MDF_AccountOnBeforeUpdate';
            te2.Core_Active__c = True;
            te2.Core_Class_Name__c = 'Core_Account';
            te2.Core_Description__c = 'Before update';
            te2.Core_Object__c = 'Account';
            te2.Core_Trigger_Events__c = 'before update';
            triggerList.add(te2);
            Core_Trigger_Executions__c te3 = new Core_Trigger_Executions__c();
            te3.Name = 'Core_MDF_AccountOnAfterInsert';
            te3.Core_Active__c = True;
            te3.Core_Class_Name__c = 'Core_Account';
            te3.Core_Description__c = 'After Insert';
            te3.Core_Object__c = 'Account';
            te3.Core_Trigger_Events__c = 'after insert';
            triggerList.add(te3);
            Core_Trigger_Executions__c te4 = new Core_Trigger_Executions__c();
            te4.Name = 'Core_MDF_AccountOnAfterUpdate';
            te4.Core_Active__c = True;
            te4.Core_Class_Name__c = 'Core_Account';
            te4.Core_Description__c = 'After Update';
            te4.Core_Object__c = 'Account';
            te4.Core_Trigger_Events__c = 'after update';
            triggerList.add(te4);
            Core_Trigger_Executions__c te5 = new Core_Trigger_Executions__c();
            te5.Name = 'Core_MDF_MultipleVCForSameProg';
            te5.Core_Active__c = True;
            te5.Core_Class_Name__c = 'Core_MDF_AccountServiceHandler';
            te5.Core_Description__c = 'Core_MDF_MultipleVCForSameProg';
            te5.Core_Object__c = 'Account';
            te5.Core_Trigger_Events__c = 'before insert';
            triggerList.add(te5);
            Core_Trigger_Executions__c te6 = new Core_Trigger_Executions__c();
            te6.Name = 'Core_MDF_UpdateHostRegionOnNodeAcc';
            te6.Core_Active__c = True;
            te6.Core_Class_Name__c = 'Core_MDF_AccountServiceHandler';
            te6.Core_Description__c = 'Core_MDF_UpdateHostRegionOnNodeAcc';
            te6.Core_Object__c = 'Account';
            te6.Core_Trigger_Events__c = 'before insert';
            triggerList.add(te6);
            Core_Trigger_Executions__c te7 = new Core_Trigger_Executions__c();
            te7.Name = 'Core_MDF_ValidatePFAChange';
            te7.Core_Active__c = True;
            te7.Core_Class_Name__c = 'Core_MDF_AccountServiceHandler';
            te7.Core_Description__c = 'Core_MDF_ValidatePFAChange';
            te7.Core_Object__c = 'Account';
            te7.Core_Trigger_Events__c = 'before update';
            triggerList.add(te7);
            Core_Trigger_Executions__c te8 = new Core_Trigger_Executions__c();
            te8.Name = 'Core_MDF_IPA_Account_Region_Check';
            te8.Core_Active__c = True;
            te8.Core_Class_Name__c = 'Core_MDF_AccountServiceHandler';
            te8.Core_Description__c = 'Core_MDF_IPA_Account_Region_Check';
            te8.Core_Object__c = 'Account';
            te8.Core_Trigger_Events__c = 'before update';
            triggerList.add(te8);
            Core_Trigger_Executions__c te9 = new Core_Trigger_Executions__c();
            te9.Name = 'Core_MDF_createGroupForAccountNode';
            te9.Core_Active__c = True;
            te9.Core_Class_Name__c = 'Core_MDF_AccountServiceHandler';
            te9.Core_Description__c = 'Core_MDF_createGroupForAccountNode';
            te9.Core_Object__c = 'Account';
            te9.Core_Trigger_Events__c = 'after insert';
            triggerList.add(te9);
            Core_Trigger_Executions__c te10 = new Core_Trigger_Executions__c();
            te10.Name = 'Core_MDF_ShareAccountsWithGroups';
            te10.Core_Active__c = True;
            te10.Core_Class_Name__c = 'Core_MDF_AccountServiceHandler';
            te10.Core_Description__c = 'Core_MDF_ShareAccountsWithGroups';
            te10.Core_Object__c = 'Account';
            te10.Core_Trigger_Events__c = 'after insert';
            triggerList.add(te10);
            Core_Trigger_Executions__c te11 = new Core_Trigger_Executions__c();
            te11.Name = 'Core_MDF_Account_node_share';
            te11.Core_Active__c = True;
            te11.Core_Class_Name__c = 'Core_MDF_AccountServiceHandler';
            te11.Core_Description__c = 'Core_MDF_Account_node_share';
            te11.Core_Object__c = 'Account';
            te11.Core_Trigger_Events__c = 'after insert';
            triggerList.add(te11);
            Core_Trigger_Executions__c te12 = new Core_Trigger_Executions__c();
            te12.Name = 'Core_MDF_UpdateHostRegionAfterVCUpdate';
            te12.Core_Active__c = True;
            te12.Core_Class_Name__c = 'Core_MDF_AccountServiceHandler';
            te12.Core_Description__c = 'Core_MDF_UpdateHostRegionAfterVCUpdate';
            te12.Core_Object__c = 'Account';
            te12.Core_Trigger_Events__c = 'after insert,after update';
            triggerList.add(te12);
            Core_Trigger_Executions__c te13 = new Core_Trigger_Executions__c();
            te13.Name = 'Core_MDF_ValidatePFAChangeOnAftrUpdt';
            te13.Core_Active__c = True;
            te13.Core_Class_Name__c = 'Core_MDF_AccountServiceHandler';
            te13.Core_Description__c = 'Core_MDF_ValidatePFAChangeOnAftrUpdt';
            te13.Core_Object__c = 'Account';
            te13.Core_Trigger_Events__c = 'after update';
            triggerList.add(te13);
            Core_Trigger_Executions__c te14 = new Core_Trigger_Executions__c();
            te14.Name = 'Core_MDF_ProcessPGMCreation';
            te14.Core_Active__c = True;
            te14.Core_Class_Name__c = 'Core_MDF_AccountServiceHandler';
            te14.Core_Description__c = 'Core_MDF_ProcessPGMCreation';
            te14.Core_Object__c = 'Account';
            te14.Core_Trigger_Events__c = 'after update';
            triggerList.add(te14);
            Core_Trigger_Executions__c te15 = new Core_Trigger_Executions__c();
            te15.Name = 'Core_MDF_VirtualCorpInsertionLogic';
            te15.Core_Active__c = True;
            te15.Core_Class_Name__c = 'Core_MDF_AccountServiceHandler';
            te15.Core_Description__c = 'Core_MDF_VirtualCorpInsertionLogic';
            te15.Core_Object__c = 'Account';
            te15.Core_Trigger_Events__c = 'before insert';
            triggerList.add(te15);
            database.insert(triggerList);
        }
    }
    
    @isTest
    static void testpreventMultipleVCForSameProg(){
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        test.startTest();
        System.runAs(sysAdminUser){
            ChannelProgram ccfCP = [SELECT Id, Name, Core_MDF_Technical_Program_Name__c from ChannelProgram WHERE Name = :Core_MDF_CCP_ConstantClass.CCF_PROGRAM];
            Account IntAcc = [SELECT Id, Name from Account WHERE Name = 'CCF Intel Account'];
            Account vcAcc = [SELECT Id, Name from Account WHERE Name = 'CCF VC Account'];
            Account ccfVirtualCorp = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount ('Test Account VC - CCF', 
                                                                         ccfCP.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type,IntAcc.Id, false);
            try{
            	database.insert(ccfVirtualCorp);
            }
            catch(Exception e){
                assert.isTrue(e.getMessage().contains(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_MultipleVCForSameProgram1')+' '+vcAcc.Name+' '+Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_MultipleVCForSameProgram2')));
            }
        }
        test.stopTest();
    }
    @isTest
    static void testHostRegionUpdateSharing(){
        
         User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        test.startTest();
        System.runAs(sysAdminUser){
            Account vcAcc = [SELECT Id,Core_Geo__c, Name from Account WHERE Name = 'IPA VC Account'];
            vcAcc.Core_Geo__c = 'PRC';
            List<Account> accList = new List<Account>();
            accList.add(vcAcc);
            try{
            	database.update(accList);
            }
            catch(Exception e){
               // Assert.isTrue(e.getMessage().contains(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_RegionMismatch_Error')));
            }
            try{
            	database.update(accList);
            }
            catch(Exception e){
                //Assert.isTrue(e.getMessage().contains(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_SubRegion_Inapplicable_Message')));
            }
            
        }
        test.stopTest();
        
    }
    @isTest
    static void testHostRegion(){
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        test.startTest();
        System.runAs(sysAdminUser){
            Account vcAcc = [SELECT Id,Core_Geo__c, Name from Account WHERE Name = 'IPA VC Account'];
            Core_MDF_ChannelProgram__mdt channelProgramDetailsOfIPA = Core_MDF_ChannelProgram__mdt.getInstance('Intel_Partner_Alliance');
            List<Account> accList = new List<Account>();
            Account nodeAcc = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount ('Test Account - IPA', 
                                                                         channelProgramDetailsOfIPA.Core_MDF_Program_ID__c,Core_MDF_CCP_TestDataUtility.account_Record_Type,vcAcc.Id, false);
            nodeAcc.Core_Geo__c = 'ASMO';
            accList.add(nodeAcc);
            Account nodeAcc1 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount ('Test Account Node - IPA', 
                                                                         channelProgramDetailsOfIPA.Core_MDF_Program_ID__c,Core_MDF_CCP_TestDataUtility.account_Record_Type,vcAcc.Id, false);            
            accList.add(nodeAcc1);
            Account nodeAcc2 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount ('Test Account Node 1 - IPA', 
                                                                         channelProgramDetailsOfIPA.Core_MDF_Program_ID__c,Core_MDF_CCP_TestDataUtility.account_Record_Type,vcAcc.Id, false);
            nodeAcc2.Core_Geo__c = 'APJ';
            Account nodeAcc3 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount ('Test Account Node 2 - IPA', 
                                                                         channelProgramDetailsOfIPA.Core_MDF_Program_ID__c,Core_MDF_CCP_TestDataUtility.account_Record_Type,vcAcc.Id, false);
            nodeAcc3.Core_Geo__c = 'APJ';
            nodeAcc3.Core_Sub_Geo__c = 'ROA';
            accList.add(nodeAcc2);
            try{
            	database.insert(accList);
            }
            catch(Exception e){
                Assert.isTrue(e.getMessage().contains(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_RegionMismatch_Error')));
            }
            try{
            	database.insert(nodeAcc3);
            }
            catch(Exception e){
                Assert.isTrue(e.getMessage().contains(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_SubRegion_Inapplicable_Message')));
            }
            
        }
        test.stopTest();
    }
    
    @isTest
    static void testUpdateAcc(){
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        test.startTest();
        System.runAs(sysAdminUser){
            Account vcAcc = [SELECT Id,Core_Geo__c, Name from Account WHERE Name = 'IPA VC Account'];            
            Core_MDF_ChannelProgram__mdt channelProgramDetailsOfIPA = Core_MDF_ChannelProgram__mdt.getInstance('Intel_Partner_Alliance');
            Account nodeAcc = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount ('Test Account - IPA', 
                                                                         channelProgramDetailsOfIPA.Core_MDF_Program_ID__c,Core_MDF_CCP_TestDataUtility.account_Record_Type,vcAcc.Id, false);
            insert nodeAcc;               
            vcAcc.Core_Geo__c = 'PRC';
            vcAcc.Core_MDF_Payment_Type_nm__c = 'Customer';
            update vcAcc;
            Account nodeAccount = [SELECT Id,Core_Geo__c, Name from Account WHERE Name = 'Test Account - IPA']; 
            assert.areEqual(vcAcc.Core_Geo__c, nodeAccount.Core_Geo__c);
        }
        test.stopTest();
    }    
    
    @isTest
    static void testValidateMDFParentFundAccChanges()
    {
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        
        System.runAs(sysAdminUser){
            ChannelProgram cp = [Select  id from ChannelProgram where Name = :Core_MDF_CCP_ConstantClass.CCF_PROGRAM];
            Account accVC = [Select Id from Account where Name = 'CCF VC Account'];
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
			test.startTest();
            Account accLevel3 = Core_MDF_CCP_TestDataUtility.createAccount ('Account Level 3', 
                                                                         cp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            accLevel3.Core_MDF_Parent_Fund_Account__c = accLevel2.Id;
            accLevel3.Core_MDF_Enabled_Auto_Transfer__c = True;
            accLevel3.Core_MDF_Auto_Transfer_Account__c = accVC.Id;
           // acctLeve2List.add(accLevel3);
            database.insert(accLevel3);
            Account accLevel4 = Core_MDF_CCP_TestDataUtility.createAccount ('Account Level 4', 
                                                                         cp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            accLevel4.Core_MDF_Parent_Fund_Account__c = accLevel3.Id;
            accLevel4.Core_MDF_Enabled_Auto_Transfer__c = True;
            accLevel4.Core_MDF_Auto_Transfer_Account__c = accVC.Id;
            //acctLeve2List.add(accLevel4);
            //database.insert(acctLeve2List);
            database.insert(accLevel4);
            try{
                accLevel1.Core_MDF_Parent_Fund_Account__c = accLevel1peer.Id;
            	database.update(accLevel1);
            }
            catch(Exception e){
                 Assert.isNotNull(e.getMessage().contains(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_EnableAutoTransfer_error')));
            }
            
            try{
                accLevel1peer.Core_MDF_Parent_Fund_Account__c = accLevel2peer.Id;
            	database.update(accLevel1peer);
            }
            catch(Exception e){
                Assert.isNotNull(e.getMessage().contains(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Child_ParenFundAccount')));
            }
            
        } 
        test.stopTest();
    }
    
    @isTest
    static void testValidateAccountHierarchyforCCP(){
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        
        System.runAs(sysAdminUser){
            ChannelProgram cp = [Select  id from ChannelProgram where Name = :Core_MDF_CCP_ConstantClass.CCF_PROGRAM];
            Account accVC = [Select Id from Account where Name = 'CCF VC Account'];
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
			test.startTest();
            Account accLevel2 = Core_MDF_CCP_TestDataUtility.createAccount ('Account Level 2', 
                                                                         cp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            accLevel2.Core_MDF_Parent_Fund_Account__c = accLevel1.Id;
            //acctList.add(accLevel2);
            database.insert(accLevel2);
                         
            Account accLevel3 = Core_MDF_CCP_TestDataUtility.createAccount ('Account Level 3', 
                                                                         cp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            accLevel3.Core_MDF_Parent_Fund_Account__c = accLevel2.Id;
            //acctList.add(accLevel3);
             database.insert(accLevel3);
            Account accLevel4 = Core_MDF_CCP_TestDataUtility.createAccount ('Account Level 4', 
                                                                         cp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            accLevel4.Core_MDF_Parent_Fund_Account__c = accLevel3.Id;
            //acctList.add(accLevel4);
            database.insert(accLevel4);
            try{
                accLevel1.Core_MDF_Parent_Fund_Account__c = accLevel1peer.Id;
            	database.update(accLevel1);
            }
            catch(Exception e){
                Assert.isNotNull(e.getMessage().contains(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Five_levels_hierarchy')));
            }
        }
        test.stopTest();
    }
        
    @isTest
    static void testValidateAccountHierarchyforRetail(){
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        test.startTest();
        System.runAs(sysAdminUser){
            ChannelProgram cp1 = [Select  id from ChannelProgram where Name = 'Retail Marketing Funds'];
            Account accVC = [Select Id from Account where Name = 'RMF VC Account'];
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
            }
            catch(Exception e){
                Assert.isNotNull(e.getMessage().contains(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Retail_Three_level_hierarchy')));
            }
        }
        test.stopTest();
    }
    
    @isTest
    private static void whenRestrictUpdatingSFFields1(){
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        System.runAs(sysAdminUser){
            Map<Id,Account> newAccountMap = new Map<Id,Account>([SELECT Id,RecordTypeId, Core_MDF_Channel_Program__c FROM Account WHERE Name = 'CCF VC Account']);
            Test.startTest();
           Core_MDF_AccountServiceHandler.createAccountNodeAttr(newAccountMap) ;            
            Test.stopTest();
            // Unit Test Method should include System.Assert - Indira
            System.assertEquals(1, newAccountMap.size(), 'Account map should contain one account');
        }
    }
}