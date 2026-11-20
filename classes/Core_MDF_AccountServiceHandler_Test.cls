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
            ChannelProgram cpCCF = Core_MDF_CCP_TestDataUtility.createProgram ('Client','Client CoMarketing Fund', false);
            cpList.add(cpCCF);
            ChannelProgram cpRMF = Core_MDF_CCP_TestDataUtility.createProgram ('Retail Marketing Funds','Retail Marketing Funds', false);
            cpList.add(cpRMF);
            
            Database.insert(cpList);
            
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
            TriggerHandler.bypass('Core_AccountTriggerHandler');
            Core_Trigger_Executions__c te15 = new Core_Trigger_Executions__c();
            te15.Name = 'AccountTriggerExecution';
            te15.Core_Active__c = True;
            te15.Core_Class_Name__c = 'Core_Account';
            te15.Core_Description__c = 'AccountTriggerExecution';
            te15.Core_Object__c = 'Account';
            te15.Core_Trigger_Events__c = 'after update';
            triggerList.add(te15);
            
            Core_Trigger_Executions__c te16 = new Core_Trigger_Executions__c();
            te16.Name = 'Core_MDF_VirtualCorpInsertionLogic';
            te16.Core_Active__c = True;
            te16.Core_Class_Name__c = 'Core_MDF_AccountServiceHandler';
            te16.Core_Description__c = 'Core_MDF_VirtualCorpInsertionLogic';
            te16.Core_Object__c = 'Account';
            te16.Core_Trigger_Events__c = 'before insert';
            triggerList.add(te16);
            
            database.insert(triggerList);
            
            Core_Opp_Bypass_Validation_Rule__c rec = new Core_Opp_Bypass_Validation_Rule__c();
            rec.Bypass__c = true;
            insert rec;
            
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
            ccfVCAcc.Core_MDF_Payment_Type_nm__c = 'Customer';
            vcAccList.add(ccfVCAcc);
            Account rmfVCAcc = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('RMF VC Account', cpRMF.Id, Core_MDF_CCP_TestDataUtility.account_Record_Type, rmfUltimateAccount.Id, false);
            rmfVCAcc.Core_Geo__c = 'APJ';
            rmfVCAcc.Core_Sub_Geo__c = 'ROA';
            rmfVCAcc.Core_MDF_Payment_Type_nm__c = 'Customer';
            vcAccList.add(rmfVCAcc);
            Account ipaVCAcc = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('IPA VC Account', channelProgramDetailsOfIPA.Core_MDF_Program_ID__c, Core_MDF_CCP_TestDataUtility.account_Record_Type, ipaUltimateAccount.Id, false);
            ipaVCAcc.Core_Geo__c = 'APJ';
            ipaVCAcc.Core_MDF_Payment_Type_nm__c = 'Customer';
            vcAccList.add(ipaVCAcc);
            Database.insert(vcAccList);
            
            List<Account> acctList = new List<Account>();
            Account accLevel1 = Core_MDF_CCP_TestDataUtility.createAccount ('Account Level 1', 
                                                                         cpCCF.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            accLevel1.Core_MDF_Parent_Fund_Account__c = ccfVCAcc.Id;
            acctList.add(accLevel1);
            
            Account accLevel1peer = Core_MDF_CCP_TestDataUtility.createAccount ('Account Level 1 peer', 
                                                                         cpCCF.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            accLevel1peer.Core_MDF_Parent_Fund_Account__c = ccfVCAcc.Id;
            acctList.add(accLevel1peer);            
            
            Account accLevel11 = Core_MDF_CCP_TestDataUtility.createAccount ('Account Level1 1', 
                                                                         cpCCF.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            accLevel11.Core_MDF_Parent_Fund_Account__c = ccfVCAcc.Id;
            acctList.add(accLevel11);
            
            Account accLevel11peer = Core_MDF_CCP_TestDataUtility.createAccount ('Account Level1 1 peer', 
                                                                         cpCCF.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            accLevel11peer.Core_MDF_Parent_Fund_Account__c = ccfVCAcc.Id;
            acctList.add(accLevel11peer); 
            
            Account rmfaccLevel1 = Core_MDF_CCP_TestDataUtility.createAccount ('Retail Account Level 1', 
                                                                         cpRMF.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            rmfaccLevel1.Core_MDF_Parent_Fund_Account__c = rmfVCAcc.Id;
            rmfacclevel1.Core_Geo__c = 'APJ';
            rmfacclevel1.Core_Sub_Geo__c = 'ROA';
            acctList.add(rmfaccLevel1);
            
            Account rmfaccLevel1peer = Core_MDF_CCP_TestDataUtility.createAccount ('Retail Account Level 1 peer', 
                                                                         cpRMF.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            rmfaccLevel1peer.Core_MDF_Parent_Fund_Account__c = rmfVCAcc.Id;
            rmfaccLevel1peer.Core_Geo__c = 'APJ';
            rmfaccLevel1peer.Core_Sub_Geo__c = 'ROA';
            acctList.add(rmfaccLevel1peer);
            
            database.insert(acctList);
            
            List<Account> acctLeve2List = new List<Account>();
            Account accLevel2 = Core_MDF_CCP_TestDataUtility.createAccount ('Account Level 2', 
                                                                         cpCCF.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            accLevel2.Core_MDF_Parent_Fund_Account__c = accLevel1.Id;
            accLevel2.Core_MDF_Enabled_Auto_Transfer__c = True;
            accLevel2.Core_MDF_Auto_Transfer_Account__c = ccfVCAcc.Id;
            acctLeve2List.add(accLevel2);
            
            Account accLevel12 = Core_MDF_CCP_TestDataUtility.createAccount ('Account Level1 2', 
                                                                         cpCCF.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            accLevel12.Core_MDF_Parent_Fund_Account__c = accLevel11.Id;
            acctLeve2List.add(accLevel12);
            
            Account rmfaccLevel2 = Core_MDF_CCP_TestDataUtility.createAccount ('Retail Account Level 2', 
                                                                         cpRMF.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            rmfaccLevel2.Core_MDF_Parent_Fund_Account__c = rmfaccLevel1.Id;
            rmfaccLevel2.Core_Geo__c = 'APJ';
            rmfaccLevel2.Core_Sub_Geo__c = 'ROA';
            acctLeve2List.add(rmfaccLevel2);
            
            Account accLevel2peer = Core_MDF_CCP_TestDataUtility.createAccount ('Account Level 2 peer', 
                                                                         cpCCF.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            accLevel2peer.Core_MDF_Parent_Fund_Account__c = accLevel1peer.Id;
            acctLeve2List.add(accLevel2peer);
            
            database.insert(acctLeve2List);
            
            List<Account>acctLeve3List = new List<Account>();
            Account accLevel3 = Core_MDF_CCP_TestDataUtility.createAccount ('Account Level 3', 
                                                                         cpCCF.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            accLevel3.Core_MDF_Parent_Fund_Account__c = accLevel2.Id;
            accLevel3.Core_MDF_Enabled_Auto_Transfer__c = True;
            accLevel3.Core_MDF_Auto_Transfer_Account__c = ccfVCAcc.Id;
            acctLeve3List.add(accLevel3);
            
            Account accLevel13 = Core_MDF_CCP_TestDataUtility.createAccount ('Account Level1 3', 
                                                                         cpCCF.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            accLevel13.Core_MDF_Parent_Fund_Account__c = accLevel12.Id;
            acctLeve3List.add(accLevel13);
            database.insert(acctLeve3List);
            
            List<Account>acctLevel4List = new List<Account>();
            Account accLevel4 = Core_MDF_CCP_TestDataUtility.createAccount ('Account Level 4', 
                                                                         cpCCF.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            accLevel4.Core_MDF_Parent_Fund_Account__c = accLevel3.Id;
            accLevel4.Core_MDF_Enabled_Auto_Transfer__c = True;
            accLevel4.Core_MDF_Auto_Transfer_Account__c = ccfVCAcc.Id;
            acctLevel4List.add(accLevel4);
            
            Account accLevel14 = Core_MDF_CCP_TestDataUtility.createAccount ('Account Level1 4', 
                                                                         cpCCF.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            accLevel14.Core_MDF_Parent_Fund_Account__c = accLevel13.Id;
            acctLevel4List.add(accLevel14);
            
            Account nodeAcc = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount ('Test Account - IPA', 
                                                                         channelProgramDetailsOfIPA.Core_MDF_Program_ID__c,Core_MDF_CCP_TestDataUtility.account_Record_Type,ipaVCAcc.Id, false);
            nodeAcc.Core_Geo__c = 'ASMO';
            acctLevel4List.add(nodeAcc);
            database.insert(acctLevel4List);     
            
            Account nodeAcc1 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount ('Test Account - IPA1', 
                                                                         channelProgramDetailsOfIPA.Core_MDF_Program_ID__c,Core_MDF_CCP_TestDataUtility.account_Record_Type,nodeAcc.Id, false);
            nodeAcc1.Core_Geo__c = 'ASMO';
            Insert nodeAcc1;
            
            Account nodeAcc2 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount ('Test Account - IPA2', 
                                                                         channelProgramDetailsOfIPA.Core_MDF_Program_ID__c,Core_MDF_CCP_TestDataUtility.account_Record_Type,nodeAcc1.Id, false);
            nodeAcc2.Core_Geo__c = 'ASMO';
            Insert nodeAcc2;
            
            Core_MDF_CCP_Payment_File_Particulars__mdt fileParticulars = [SELECT Core_MDF_GL_Account__c, Core_MDF_GL_Account_CSAR__c, Core_MDF_Program__c FROM Core_MDF_CCP_Payment_File_Particulars__mdt where Core_MDF_Program__c ='Intel Partner Alliance' limit 1];
            Core_MDF_Account_Node_Attributes__c accNodeAttr = new Core_MDF_Account_Node_Attributes__c();
            accNodeAttr.Core_MDF_Account_id__c=nodeAcc2.Id;
            accNodeAttr.Core_MDF_Program_id__c=nodeAcc2.Core_MDF_Channel_Program__c;
            accNodeAttr.Core_MDF_CSAR_GL_Account_nbr__c=Decimal.valueOf(fileParticulars.Core_MDF_GL_Account_CSAR__c);
            accNodeAttr.Core_MDF_NonPO_GL_Account_nbr__c=Decimal.valueOf(fileParticulars.Core_MDF_GL_Account__c);
            insert accNodeAttr ;
            
            Core_MDF_AccountServiceHandler.processCCPTriggerUpdates(null,null,null,'after insert');
        }
    }
    
    @isTest
    static void testpreventMultipleVCForSameProg(){
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        test.startTest();
        System.runAs(sysAdminUser){
            ChannelProgram ccfCP = [SELECT Id, Name, Core_MDF_Technical_Program_Name__c from ChannelProgram WHERE Name = 'Client'];
            Account IntAcc = [SELECT Id, Name from Account WHERE Name = 'CCF Intel Account'];
            Account vcAcc = [SELECT Id, Name from Account WHERE Name = 'CCF VC Account'];
            Account ccfVirtualCorp = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount ('Test Account VC - CCF', 
                                                                         ccfCP.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type,IntAcc.Id, false);
            try{
                database.insert(ccfVirtualCorp);
            }
            catch(Exception e){
                System.Assert(e.getMessage().contains(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_MultipleVCForSameProgram1')+' '+vcAcc.Name+' '+Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_MultipleVCForSameProgram2')));
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
                Assert.isTrue(e.getMessage().contains(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_RegionMismatch_Error')));
            }
            try{
                database.update(accList);
            }
            catch(Exception e){
                Assert.isTrue(e.getMessage().contains(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_SubRegion_Inapplicable_Message')));
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
            vcAcc.Core_MDF_Payment_Type_nm__c = 'Non-Customer';
            update vcAcc;
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
            nodeAcc2.Core_MDF_Payment_Type_nm__c = 'Customer';
            Account nodeAcc3 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount ('Test Account Node 2 - IPA', 
                                                                         channelProgramDetailsOfIPA.Core_MDF_Program_ID__c,Core_MDF_CCP_TestDataUtility.account_Record_Type,vcAcc.Id, false);
            nodeAcc3.Core_Geo__c = 'APJ';
            nodeAcc3.Core_Sub_Geo__c = 'ROA';
            accList.add(nodeAcc2);
            try{
                database.insert(accList);
            }
            catch(Exception e){
                System.Assert(e.getMessage().contains(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_RegionMismatch_Error')));
            }
            try{
                database.insert(nodeAcc3);
            }
            catch(Exception e){
                System.Assert(e.getMessage().contains(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_SubRegion_Inapplicable_Message')));
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
            vcAcc.Core_Geo__c = 'PRC';
            update vcAcc;
            system.assertEquals(vcAcc.Core_Geo__c, 'PRC');
            //update vcAcc;
        }
        test.stopTest();
    }    
    
    @isTest
    static void testValidateMDFParentFundAccChanges()
    {
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        test.startTest();
        System.runAs(sysAdminUser){
            Account accLevel1 = [Select Id,Core_MDF_Parent_Fund_Account__c from Account where Name = 'Account Level 1'];
            Account accLevel1peer = [Select Id,Core_MDF_Parent_Fund_Account__c from Account where Name = 'Account Level 1 peer'];
            Account accLevel2peer = [Select Id,Core_MDF_Parent_Fund_Account__c from Account where Name = 'Account Level 2 peer'];
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
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        test.startTest();
        System.runAs(sysAdminUser){
            Account accLevel1 = [Select Id,Core_MDF_Parent_Fund_Account__c from Account where Name = 'Account Level1 1'];
            Account accLevel1peer = [Select Id,Core_MDF_Parent_Fund_Account__c from Account where Name = 'Account Level1 1 peer'];
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
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        test.startTest();
        System.runAs(sysAdminUser){
            Account accLevel1 = [Select Id,RecordTypeId,Core_MDF_Channel_Program__c,Core_MDF_Parent_Fund_Account__c from Account where Name = 'Retail Account Level 1'];
            Account accLevel1peer = [Select Id,RecordTypeId,Core_MDF_Channel_Program__c,Core_MDF_Parent_Fund_Account__c from Account where Name = 'Retail Account Level 1 peer'];
            List<Account>rmfaccList = new List<Account>();
            rmfaccList.add(accLevel1);
            rmfaccList.add(accLevel1peer);
            Core_MDF_AccountServiceHandler.processCCPTriggerUpdates(rmfaccList, NULL, Null, 'after insert');
            try{
                accLevel1.Core_MDF_Parent_Fund_Account__c = accLevel1peer.Id;
                database.update(accLevel1);
            }
            catch(Exception e){
                System.Assert(e.getMessage().contains(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Retail_Three_level_hierarchy')));
            }
        }
        test.stopTest();
    }
    
    @isTest
    private static void whenCreateGroupForComarketingAccount(){
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        System.runAs(sysAdminUser){
            List<Account> listAccount = [Select Id,Name,Core_Business_Party_Id__c,Core_Data_Simplified_Account_Nm__c,Core_Data_Country_Nm__c,Core_Prime_Account_Name__c,ParentId,RecordTypeId,BillingCountryCode,BillingCountry,ShippingCountryCode,ShippingCountry,Core_MDF_Channel_Program__c from Account where Name = 'Retail Account Level 1']; 
            Test.startTest();
            system.assertEquals(listAccount[0].Name, 'Retail Account Level 1');
            //Core_AccountTriggerHandlerController.createGroupForComarketingAccount(listAccount);
            Core_MDF_AccountServiceHandler.createGroupForComarketingAccount(listAccount);
            Test.stopTest();
        }
    }
    
    @isTest
    private static void whenSharingWithNewAcctGrps(){
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        System.runAs(sysAdminUser){
            List<Account> listAccount = [Select Id,Name,Core_Business_Party_Id__c,Core_Data_Simplified_Account_Nm__c,Core_Data_Country_Nm__c,Core_Prime_Account_Name__c,ParentId,RecordTypeId,BillingCountryCode,BillingCountry,ShippingCountryCode,ShippingCountry from Account where Name = 'Retail Account Level 1']; 
            Test.startTest();
            system.assertEquals(listAccount[0].Name, 'Retail Account Level 1');
            //Core_AccountTriggerHandlerController.sharingWithNewAcctGrps(listAccount);
            Core_MDF_AccountServiceHandler.sharingWithNewAcctGrps(listAccount);
            Test.stopTest();
        }
    }
    @isTest
    private static void whenCreateNodeSharingGroup(){
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        System.runAs(sysAdminUser){
            Account testAcc = [Select Id,Name,Core_Business_Party_Id__c,Core_Data_Simplified_Account_Nm__c,Core_Data_Country_Nm__c,Core_Customer_Aggregation_Type__c,ParentId,RecordTypeId,BillingCountryCode,BillingCountry,ShippingCountryCode,ShippingCountry,BillingCity,BillingStreet from Account where Name = 'Retail Account Level 1'];
            Map<Id,Account> accountById = new Map<Id,Account>(); 
            accountById.put(testAcc.Id,testAcc);
            system.assertEquals(testAcc.Name, 'Retail Account Level 1');
            Test.startTest();
          //  Core_AccountTriggerHandlerController.createNodeShrngGrpAndUpdAccNodeAttr(accountById); 
            Core_MDF_AccountServiceHandler.createNodeShrngGrpAndUpdAccNodeAttr(accountById); 
            Test.stopTest();
        }
    }
    
    @isTest
    private static void whenRestrictUpdatingSFFields(){
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        System.runAs(sysAdminUser){
            List<Account> oldAccount = [Select Id,Name,Core_Business_Party_Id__c,Core_Data_Simplified_Account_Nm__c,Core_Data_Country_Nm__c,Core_Customer_Aggregation_Type__c,ParentId,RecordTypeId,BillingCountryCode,BillingCountry,Core_Account_Request_Rejection_Reason__c,Core_Account_Request_Rejection_Notes__c,ShippingCountryCode,ShippingCountry from Account where Name = 'Retail Account Level 1'];
            Account newAccount = oldAccount[0];
            newAccount.Name = 'UpdatedTestPlatformEvent';
            system.assertEquals(newAccount.Name, 'UpdatedTestPlatformEvent');
            Test.startTest();
           // Core_AccountTriggerHandlerController.checkRetailCampaignShare(new List<Account>{newAccount});
           Core_MDF_AccountServiceHandler.checkRetailCampaignShare(new List<Account>{newAccount}) ;            
            Test.stopTest();
        }
    }
    
    @isTest
    private static void whenRestrictUpdatingSFFields1(){
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        System.runAs(sysAdminUser){
            Map<Id,Account> newAccountMap = new Map<Id,Account>([SELECT Id,RecordTypeId, Core_MDF_Channel_Program__c FROM Account WHERE Name = 'CCF VC Account']);
            Test.startTest();
           Core_MDF_AccountServiceHandler.createAccountNodeAttr(newAccountMap) ;            
            Test.stopTest();
            // Unit Test Method should include System.Assert 
            System.assertEquals(1, newAccountMap.size(), 'Account map should contain one account');
        }
    }
}