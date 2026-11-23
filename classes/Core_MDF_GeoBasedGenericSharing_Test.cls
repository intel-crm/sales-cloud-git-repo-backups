/****************************************************************************************************************************************
* Class Name        : Core_MDF_GeoBasedGenericSharing_Test
* Created Date      : 11/5/2019
* Modification Log
* Developer            Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - HA       11/5/2019         Test Class for Core_MDF_GeoBasedGenericSharing
*****************************************************************************************************************************************/
@isTest(SeeAllData=false)
public class Core_MDF_GeoBasedGenericSharing_Test {
    @TestSetUp
    static void createData(){
        
        
        profile systemAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator' limit 1];
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);    
        usr.LastName = 'User Test';
        usr.UserRoleId = usRole.Id;
        Database.insert(usr);
        PermissionSet ps1 = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_CCF_MDF_Budget_Loader' LIMIT 1];
        insert new PermissionSetAssignment(AssigneeId = usr.id, PermissionSetId = ps1.Id);
        List<Core_MDF_Partner_Group_Mapping__c> ccfpgmList = new List<Core_MDF_Partner_Group_Mapping__c>();
        
        System.runAs(usr){
            
            //Adding Bypass functions
            List<String> bypassFunctionKeys = new List<String>();
            bypassFunctionKeys.add('Bypass_MDF_Budget_Access_Validation');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Status_Validation');
            bypassFunctionKeys.add('Bypass_Duplicate_Budget_Check');
            bypassFunctionKeys.add('Bypass_Allocation_Reservation');
            bypassFunctionKeys.add('Bypass_GeoBased_Allocation_Sharing');
            bypassFunctionKeys.add('Bypass_ValidateActivityWithCampaign');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Access');
            bypassFunctionKeys.add('Bypass_Duplicate_Budget_Check');
            bypassFunctionKeys.add('byPassMDFPFAChangesMethod');
            bypassFunctionKeys.add('byPassRetailCampSharingOnPFAChange');
            bypassFunctionKeys.add('byPassValidateAccountHierarchy');
            bypassFunctionKeys.add('Bypass_GeoBased_Budget_Sharing');
            bypassFunctionKeys.add('Bypass_Allocation_Reservation');
            bypassFunctionKeys.add('Bypass_GeoBased_Allocation_Sharing');
            bypassFunctionKeys.add('byPassShareUnshareCampaignRecord');
            bypassFunctionKeys.add('byPassCampaignAndRelatedRecords');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Access_Validation');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Status_Validation');
            
            Set<String> myset1 = new Set<String>();
            List<String> result1 = new List<String>();
            myset1.addAll(bypassFunctionKeys);
            result1.addAll(myset1);
            
            List<Core_Trigger_Executions__c> bypassfunctinalitylist1 = Core_MDF_CCP_TestDataUtility.byPassFeature(result1,true,true);
            
            Profile ccpCoreAccessProfile = [SELECT Id FROM Profile WHERE Name='CCP - Core Access' LIMIT 1];
            //fetching permission sets
            Set<String> psNameSet = new Set<String> ();
            Map<string,String>  psNameVsIdMap = new Map<string,String>();
            psNameSet.add('Core_MDF_CCP_Internal_CCF_Acct_Mgr');
            psNameSet.add('Core_MDF_CCP_Internal_IPA_Acct_Mgr');
            psNameVsIdMap = getPermissionSetIdbyName(psNameSet);
            String ccfAcctMgrPsId =  psNameVsIdMap.get('Core_MDF_CCP_Internal_CCF_Acct_Mgr');
            String ipaAcctMgrPsId =  psNameVsIdMap.get('Core_MDF_CCP_Internal_IPA_Acct_Mgr');
            
            //Creating CCF User
            User ccfaccntmngr = Core_MDF_CCP_TestDataUtility.createUser(false);
            ccfaccntmngr.Email = 'ccfaccntmngr@example.com';
            ccfaccntmngr.Profile = ccpCoreAccessProfile;
            PermissionSetAssignment assignPermissionSetObj = new PermissionSetAssignment();
            assignPermissionSetObj.AssigneeId = ccfaccntmngr.Id;
            assignPermissionSetObj.PermissionSetId = ccfAcctMgrPsId;
            Database.insert(ccfaccntmngr); 
            
            //Creating IPA User
            User ipaaccntmngr = Core_MDF_CCP_TestDataUtility.createUser(false);
            ipaaccntmngr.Email = 'ipaaccntmngr@example.com';
            ipaaccntmngr.Profile = ccpCoreAccessProfile;
            PermissionSetAssignment assignPermissionSetObj2 = new PermissionSetAssignment();
            assignPermissionSetObj2.AssigneeId = ipaaccntmngr.Id;
            assignPermissionSetObj2.PermissionSetId = ipaAcctMgrPsId;
            Database.insert(ipaaccntmngr);
            
            //Create CCF Channel Program
            ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.CCF_PROGRAM,'Client CoMarketing Fund', true);
            ChannelProgram cpRetail = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.RMF_PROGRAM,'Retail Marketing Funds', true);
            ChannelProgram ipaCP = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.IPA_PROGRAM,'Intel Partner Alliance', true);
            
            List<Account> listAcc = new List<Account>();
            //Create Intel Account
            Account acc = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Account', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
            
            Account ipaAcc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test ipaAcc1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            ipaAcc1.Core_MDF_CoMarketingActive__c = true;
            listAcc.add(ipaAcc1);
            
            
            
            // Creating Intel Account for retail program
            Account acc1Retail = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Test Account Retail', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, 
                                                                                  false);
            acc1Retail.Core_Account_Type__c = 'Reseller';
            
            acc1Retail.Industry = 'Food & Beverage';
            acc1Retail.Core_MDF_Channel_Program__c = cpRetail.Id;
            acc1Retail.Core_Geo__c = 'ASMO';
            acc1Retail.Core_Sub_Geo__c = 'LAR';
            listAcc.add(acc1Retail);
            
            Database.insert(listAcc);
            
            //Create Co-Marketing Account
            Account acc2 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test CCF Account', cp.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc.Id, true);
            
            // Creating Retail Account with utility class
            List<Account> accCoMarketingList = new List<Account>();  
            
            Account accRetail = Core_MDF_CCP_TestDataUtility.createAccount ('Co-marketing Test Account Retail', cpRetail.Id,
                                                                            Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            accRetail.Core_MDF_Parent_Fund_Account__c = acc1Retail.Id;
            accRetail.Core_Geo__c = 'ASMO';
            accRetail.Core_Sub_Geo__c = 'LAR';
            accCoMarketingList.add(accRetail);
            
            //Creating IPA Co Marketing Account
            Account ipaCoMarketingAccount = Core_MDF_CCP_TestDataUtility.createAccount('IPA Virtual Acc', ipaCP.id, Core_MDF_CCP_TestDataUtility.Account_Record_Type,false);
            ipaCoMarketingAccount.Core_MDF_Parent_Fund_Account__c = ipaAcc1.Id;
            accCoMarketingList.add(ipaCoMarketingAccount);    
            
            Database.insert(accCoMarketingList);
            
            //Create CCF Group
            List<Group> grpList = new List<Group>();
            Group ccfgrp = new Group();
            ccfgrp.Name = 'Core CCP CCF Internal';
            ccfgrp.DeveloperName = 'Core_CCP_CCF_Internal';
            grpList.add(ccfgrp);
            
            //Create CCF Group
            Group ccfgrp2 = new Group();
            ccfgrp2.Name = 'Core CCP CCF Internal WW';
            ccfgrp2.DeveloperName = 'Core_CCP_CCF_Internal_WW';
            grpList.add(ccfgrp2);
            
            //Create Retail Group
            Group ccfgrp3 = new Group();
            ccfgrp3.Name = 'Core CCP CCF Internal ASMO';
            ccfgrp3.DeveloperName = 'Core_CCP_CCF_Internal_ASMO';
            grpList.add(ccfgrp3);
            
            Group ipaGrp = new Group();
            ipaGrp.Name = 'Core CCP IPA Internal';
            ipaGrp.DeveloperName = 'Core_MDF_CCP_IPA_Internal';
            grpList.add(ipaGrp);
            
            insert grpList;
            
            GroupMember ipaGrpMem = new GroupMember();
            ipaGrpMem.UserOrGroupId = usr.Id;
            ipaGrpMem.GroupId = ipaGrp.Id;
            system.runAs(usr){
                Database.insert(ipaGrpMem);
            }
            
            
            //Create PGM
            List<Core_MDF_Partner_Group_Mapping__c> pgmList = new List<Core_MDF_Partner_Group_Mapping__c>();
            Core_MDF_Partner_Group_Mapping__c ccfPgm = new Core_MDF_Partner_Group_Mapping__c();
            ccfPgm.Core_MDF_Account__c = acc.Id;
            ccfPgm.Core_MDF_Group_Name__c = 'Core_CCP_CCF_Internal';
            ccfPgm.Core_MDF_Type_of_Access__c = 'Internal';
            ccfPgm.Core_MDF_Group_Id__c = ccfgrp.Id;
            ccfPgm.Core_MDF_Channel_Program__c = cp.Id;
            ccfPgm.Core_MDF_Virtual_Corp_nm__c = acc2.Id;
            ccfPgm.Core_MDF_Region_cd__c = 'EMEA';
            ccfPgm.Core_MDF_Source_Txt__c = 'test';
            ccfPgm.Core_MDF_AccountIdGroupName__c = acc.Id + '_Core_CCP_CCF_Internal';
            
            pgmList.add(ccfPgm);
            
            Core_MDF_Partner_Group_Mapping__c ccfPgm2 = new Core_MDF_Partner_Group_Mapping__c();
            ccfPgm2.Core_MDF_Account__c = acc.Id;
            ccfPgm2.Core_MDF_Group_Name__c = 'Core_CCP_CCF_Internal_WW';
            ccfPgm2.Core_MDF_Type_of_Access__c = 'Internal';
            ccfPgm2.Core_MDF_Group_Id__c = ccfgrp2.Id;
            ccfPgm2.Core_MDF_Channel_Program__c = cp.Id;
            ccfPgm2.Core_MDF_Virtual_Corp_nm__c = acc2.Id;
            ccfPgm2.Core_MDF_Region_cd__c = 'WW';
            ccfPgm2.Core_MDF_Source_Txt__c = 'test';
            ccfPgm2.Core_MDF_AccountIdGroupName__c = acc.Id + '_Core_CCP_CCF_Internal_WW';
            
            pgmList.add(ccfPgm2);
            
            Core_MDF_Partner_Group_Mapping__c ccfPgm3 = new Core_MDF_Partner_Group_Mapping__c();
            ccfPgm3.Core_MDF_Account__c = acc1Retail.Id;
            ccfPgm3.Core_MDF_Group_Name__c = 'Core_CCP_Retail_Internal_ASMO';
            ccfPgm3.Core_MDF_Type_of_Access__c = 'Internal';
            ccfPgm3.Core_MDF_Group_Id__c = ccfgrp3.Id;
            ccfPgm3.Core_MDF_Channel_Program__c = cpRetail.Id;
            ccfPgm3.Core_MDF_Virtual_Corp_nm__c = accRetail.Id;
            ccfPgm3.Core_MDF_Region_cd__c = 'ASMO';
            ccfPgm3.Core_MDF_Sub_Region_cd__c = 'LAR';
            ccfPgm3.Core_MDF_Source_Txt__c = 'test';
            ccfPgm3.Core_MDF_AccountIdGroupName__c = acc1Retail.Id + '_Core_CCP_Retail_Internal_ASMO';
            pgmList.add(ccfPgm3);
            
            Core_MDF_Partner_Group_Mapping__c pgmIPA = new Core_MDF_Partner_Group_Mapping__c();
            pgmIPA.Core_MDF_Account__c = ipaAcc1.Id;
            pgmIPA.Core_MDF_Group_Name__c = 'Core_MDF_CCP_IPA_Internal';
            pgmIPA.Core_MDF_Type_of_Access__c = 'Internal';
            pgmIPA.Core_MDF_Group_Id__c = ipaGrp.Id;
            pgmIPA.Core_MDF_Virtual_Corp_nm__c = ipaCoMarketingAccount.Id;
            pgmIPA.Core_MDF_BudgetType_nm__c = 'Client Specialties MDF';
            pgmIPA.Core_MDF_Channel_Program__c = ipaCP.Id;
            pgmIPA.Core_MDF_Source_Txt__c = 'Test';
            pgmIPA.Core_MDF_Region_cd__C = 'APJ';
            pgmIPA.Core_MDF_AccountIdGroupName__c = ipaAcc1.Id+'Core_MDF_CCP_IPA_Internal';
            pgmList.add(pgmIPA);
            
            insert pgmList;
            
            Test.startTest();
            //Create Bank
            Core_MDF_Bank__c bank = Core_MDF_CCP_TestDataUtility.createBank(acc.Id, 'Core_MDF_Client_CoMarketing_Fund', true,'1231231230');
            
            //Create Budget
            PartnerMarketingBudget testBudget = Core_MDF_CCP_TestDataUtility.createBudget('TestBudgetData',Core_MDF_CCP_TestDataUtility.budget_Record_Type,
                                                                                          acc2.id, cp.Id , 100000 , System.today()-60 , System.today() + 60 , 
                                                                                          false);
            testBudget.Core_MDF_Budget_Type_Txt__c='MDF';  
            insert testBudget;  
            
            
            //create Allocation
            PartnerFundAllocation pfaIPA = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('allocation',testBudget,ipaCoMarketingAccount, 10000,true);
            
            //Create Campaign
            List<Campaign> campList = new List<Campaign>();
            
            string budgetType = Core_MDF_CCP_ConstantClass.BCA_MDF_BUDGET_TYPE;
            Campaign ipaCampaign = Core_MDF_CCP_IPA_TestDataUtility.createIPACampaign('Test Campaign - IPA',
                                                                                      ipaCoMarketingAccount.id, 
                                                                                      System.today().addDays(3), System.today().adddays(30),
                                                                                      budgetType, 110000,'INDIA', 'Consumer', 
                                                                                      'Apollo Lake', 'Planned', true);                  
            
            Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp CCF','Gaming','Intel® Core™ i7 Processor', 'Yes',
                                                                        Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 
                                                                        'Client CoMarketing Fund', System.today(), System.today().addDays(30), 
                                                                        10000, 'Always Connected PC', acc2.Id,'Desktop', false);
            camp.Core_MDF_Supports_legacy_program__c = 'Yes'; 
            campList.add(camp);
            Campaign campRetail = Core_MDF_CCP_TestDataUtility.createCampaign('TestRetailCamp','Gaming','Athena', 'Yes',
                                                                              Core_MDF_CCP_TestDataUtility.campaign_RecordType_Retail, 'Retail Marketing Funds',System.today().addDays(-10), 
                                                                              System.today().addDays(10), 2000, 'Instore innovation', accRetail.Id,'2-in-1', false);
            
            campRetail.Core_MDF_Supports_legacy_program__c = 'Yes'; 
            campList.add(campRetail);
            insert campList;
            Test.stopTest();
        }
    }
    
    static Map<string,String> getPermissionSetIdbyName(Set<String> psNameSet){
        Map<string,String>  resultMap = new Map<string,String>();
        for(permissionSet ps: [SELECT Id , Name
                               FROM PermissionSet
                               WHERE Name IN:psNameSet]){
                                   resultMap.put(ps.Name, ps.Id);
                                   
                               }
        return resultMap;
    }
    
    @isTest static void ipaPFR(){
        
        User usrIPA = [select id,email from User where email='ipaaccntmngr@example.com' limit 1];
        System.runAs(usrIPA)
        {
            
            Account ipaCoMarketingAccount = [select id,Core_MDF_Parent_Fund_Account__r.name from account where name = 'IPA Virtual Acc']; 
            Test.startTest(); 
            Campaign ipaCampaign = [Select Id, Name from Campaign where name = 'Test Campaign - IPA'];
            PartnerFundallocation pfa=[Select Id from PartnerFundAllocation where Title='allocation'];
            
            PartnerFundRequest ipaPFR = Core_MDF_CCP_IPA_TestDataUtility.createIPAPartnerFundRequest(ipaCampaign.id,ipaCoMarketingAccount.id,
                                                                                                     System.today().addDays(4),
                                                                                                     System.today().addDays(5),
                                                                                                     false);  
            
            
            ipaPFR.Core_MDF_Fund_Request_Status__c = 'Planned';
            ipaPFR.Title = 'IPA Activity';
            //ipaPFR.Core_MDF_Budget_Type_nm__c = 'Client Specialties MDF';
            ipaPFR.Core_MDF_Budget_Type_nm__c = Core_MDF_CCP_ConstantClass.BCA_MDF_BUDGET_TYPE;
            //ipaPFR.Core_MDF_Region_cd__c = 'APJ';
            ipaPFR.AllocationId=pfa.id;
            insert ipaPFR;
            Test.stopTest();
            
        }
    }
    
    
    @isTest
    static void bankGeoShare()
    {
        
        User usr3 = [select id,email from User where email='ccfaccntmngr@example.com' limit 1];
        test.startTest();
        System.runAs(usr3)
        {
            Account acc = [select id from account where name = 'Test Account']; 
            List<Core_MDF_BankProgram_Entitlement_Mapping__mdt> bpemList = [SELECT Core_MDF_Bank_Program_Name__c, Core_MDF_Channel_Program__c
                                                                            FROM Core_MDF_BankProgram_Entitlement_Mapping__mdt];
            Core_MDF_Bank__c newBank = Core_MDF_CCP_TestDataUtility.createBank(acc.id, 'Core_MDF_Client_CoMarketing_Fund', false,'1234567891');
            newBank.Core_MDF_Bank_Status__c = 'Draft';
            newBank.Core_MDF_DUNS__c = '578299333';
            newBank.Core_MDF_Bank_Beneficiary_Name__c = 'TEST BENEFICIARY NAME';
            newBank.Core_MDF_Bank_Location__c = 'IN';
            newBank.Core_MDF_Swift_Code__c = 'BOFSGB21124';
            newBank.Core_MDF_Intermediary_Indicator__c = 'N';
            newBank.Core_MDF_Routing_Number__c = '123456';
            newBank.Core_MDF_ESD_Hold_Indicator__c = FALSE;
            newBank.Core_MDF_Effective_Date__c = system.today() - 10;
            newBank.Core_MDF_Supplier_Name__c='TEST SUPPLIER NAME';
            newBank.Core_MDF_Currency_cd__c = 'USD';
            Insert newBank;
            
            Core_Integration_Inbound_Message__c payLoad1 = new Core_Integration_Inbound_Message__c();
            payLoad1.Core_Payload__c = '[{"SUPPL_HLD_PMT_IND":"N","bnfcy_nm":"TEST BENEFICIARY NAME","intrmd_bank_ind":"N","bnk_nm":"TEST BANK","bnk_nbr":"123456","ap_vndr_nbr":1234567891,"DUNS_NBR":"578299333","ctry_cd":"GB","suppl_nm":"Test","swift_cd":"BOFSGB21124 ","currency_cd": "USD","suppliercity": "SAO PAULO","supplierregion": "Sao Paulo","supplierpostal": "01327-905","suppliercountry": "Brazil"}]';
            payLoad1.Core_Message_Type__c = 'Bank';
            payLoad1.Core_Source_System__c   = 'EDW';
            insert payLoad1;
            
            List<Id> grpIdBankList = new List<Id>();
            for(Core_MDF_Bank__share bankShare : [select id,UserOrGroupId,ParentId from 
                                                  Core_MDF_Bank__share where 
                                                  ParentId =: newBank.id and RowCause = 'Manual'])
            {
                grpIdBankList.add(bankShare.UserOrGroupId);
            }
            
            
            Core_MDF_Partner_Group_Mapping__c pgm = [select id,Core_MDF_Group_Id__c,Core_MDF_Group_Name__c 
                                                     from Core_MDF_Partner_Group_Mapping__c
                                                     where Core_MDF_Group_Name__c = 'Core_CCP_CCF_Internal'];
            Assert.isTrue(grpIdBankList.contains(pgm.Core_MDF_Group_Id__c),'true');
            
        }
        test.stopTest();
    }
    
    @isTest
    static void bankIPAGeoShare()
    {
        
        User usr3 = [select id,email from User where email='ipaaccntmngr@example.com' limit 1];
        test.startTest();
        System.runAs(usr3)
        {
            Account acc = [select id from account where name = 'Test Account']; 
            List<Core_MDF_BankProgram_Entitlement_Mapping__mdt> bpemList = [SELECT Core_MDF_Bank_Program_Name__c, Core_MDF_Channel_Program__c
                                                                            FROM Core_MDF_BankProgram_Entitlement_Mapping__mdt];
            Core_MDF_Bank__c newBank = Core_MDF_CCP_TestDataUtility.createBank(acc.id, 'Core_MDF_Intel_Partner_Alliance', false,'1234567891');
            newBank.Core_MDF_Bank_Status__c = 'Draft';
            newBank.Core_MDF_DUNS__c = '578299333';
            newBank.Core_MDF_Bank_Beneficiary_Name__c = 'TEST BENEFICIARY NAME';
            newBank.Core_MDF_Bank_Location__c = 'IN';
            newBank.Core_MDF_Swift_Code__c = 'BOFSGB21124';
            newBank.Core_MDF_Intermediary_Indicator__c = 'N';
            newBank.Core_MDF_Routing_Number__c = '123456';
            newBank.Core_MDF_ESD_Hold_Indicator__c = FALSE;
            newBank.Core_MDF_Effective_Date__c = system.today() - 10;
            newBank.Core_MDF_Supplier_Name__c='TEST SUPPLIER NAME';
            newBank.Core_MDF_Currency_cd__c = 'USD';
            newBank.Core_MDF_Intel_Company_Code__c = '150';
            newBank.Core_MDF_Tax_codes_cd__c = 'I0';
            Insert newBank;
            
            Core_Integration_Inbound_Message__c payLoad1 = new Core_Integration_Inbound_Message__c();
            payLoad1.Core_Payload__c = '[{"SUPPL_HLD_PMT_IND":"N","bnfcy_nm":"TEST BENEFICIARY NAME","intrmd_bank_ind":"N","bnk_nm":"TEST BANK","bnk_nbr":"123456","ap_vndr_nbr":1234567891,"DUNS_NBR":"578299333","ctry_cd":"GB","suppl_nm":"Test","swift_cd":"BOFSGB21124 ","currency_cd": "USD","suppliercity": "SAO PAULO","supplierregion": "Sao Paulo","supplierpostal": "01327-905","suppliercountry": "Brazil"}]';
            payLoad1.Core_Message_Type__c = 'Bank';
            payLoad1.Core_Source_System__c   = 'EDW';
            insert payLoad1;
            test.stopTest();
            
            
        }
    }
    
    
    @isTest
    static void pfrGeoShare()
    {
        
        User usr2 = [SELECT Id,Email from User where Email='ccfaccntmngr@example.com' limit 1];
        Campaign camp=[select id,Name from Campaign where Name ='Test Camp CCF'];
        
        Account acc2 = [select id from account where name = 'Test CCF Account']; 
        
        
        
        PartnerMarketingBudget testBudget = [select id from PartnerMarketingBudget where Title ='TestBudgetData'];
        List<Core_MDF_CCP_Country_Geo_Mapping__mdt> cgmList = [SELECT MasterLabel, Core_MDF_Geo__c, Core_MDF_Sub_Geo__c  
                                                               FROM Core_MDF_CCP_Country_Geo_Mapping__mdt];
        Test.startTest();
        //Added by Ealisha-start
        List<PartnerFundRequest> pfrListToBeInserted = new List<PartnerFundRequest>();
        //Added by Ealisha-end
        PartnerFundRequest testPartnerFundRequestRecord2 = Core_MDF_CCP_TestDataUtility.insertPartnerFundRequest(camp.id,Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,acc2.Id,null,
                                                                                                                 testBudget,'United Kingdom','Consumer','Desktop','Intel® Corporate Logo','Event',
                                                                                                                 'Member Participation in Third-Party Event','Draft',false);
        System.runAs(usr2)
        {
            Date stDate =  System.today().addDays(1);
            Date endDate = System.today().addDays(10);
            testPartnerFundRequestRecord2.Core_MDF_Start_Date__c = stdate;
            testPartnerFundRequestRecord2.Core_MDF_End_Date__c = endDate;
            testPartnerFundRequestRecord2.RequestedAmount = 16250;
            testPartnerFundRequestRecord2.Core_MDF_Fund_Request_Status__c = 'Planned';
            testPartnerFundRequestRecord2.Core_MDF_Country_nm__c = 'United Kingdom';
            
            
            PartnerFundRequest testPartnerFundRequestRecord3 = Core_MDF_CCP_TestDataUtility.insertPartnerFundRequest(camp.id,Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,acc2.Id,null,
                                                                                                                     testBudget,'COLOMBIA','Consumer','Desktop','Intel® Corporate Logo','Event',
                                                                                                                     'Member Participation in Third-Party Event','Draft',false);
            
            Date strDate = System.today().addDays(1);
            Date edDate = System.today().addDays(15);
            testPartnerFundRequestRecord3.Core_MDF_Start_Date__c = stdate;
            testPartnerFundRequestRecord3.Core_MDF_End_Date__c = endDate;
            testPartnerFundRequestRecord3.RequestedAmount = 16250;
            testPartnerFundRequestRecord3.Core_MDF_Fund_Request_Status__c = 'Planned';
            testPartnerFundRequestRecord3.Core_MDF_Country_nm__c = 'COLOMBIA';
            //Added by Ealisha-start
            pfrListToBeInserted.add(testPartnerFundRequestRecord2);
            pfrListToBeInserted.add(testPartnerFundRequestRecord3);
            insert pfrListToBeInserted;
            
            
        }
        //Added by Ealisha-end
        User user = [SELECT Id, LastName FROM User WHERE LastName ='User Test'  LIMIT 1];
        Campaign camp2 = [SELECT Id FROM Campaign WHERE Name ='TestRetailCamp'  LIMIT 1];
        Account acc = [SELECT Id FROM Account WHERE Name ='Co-marketing Test Account Retail' LIMIT 1];
        Account acc1 = [SELECT Id FROM Account WHERE Name ='Test CCF Account'  LIMIT 1];
        list<PartnerFundRequest> pfrs = new list<PartnerFundRequest>();
        
        System.runAs(user){
            
            
            PartnerFundRequest pfr = Core_MDF_CCP_TestDataUtility.createRetailActivity(string.valueof(camp2.Id),
                                                                                       string.valueof(acc.id),System.today(),System.today(),false); 
            pfr.Title = 'Test Retail Activity';
            pfr.Core_MDF_Activity_Description__c = 'Test Retail Activity';
            pfr.Core_MDF_Start_Date__c = System.today();
            pfr.Core_MDF_End_Date__c = System.today();
            pfr.RequestedAmount = 1000;
            pfr.Core_MDF_Country_nm__c = 'INDIA';
            //pfr.Core_MDF_Country__c = 'INDIA';
            
            pfr.Core_MDF_Fund_Request_Status__c = 'Pending Review';
            
            
            PartnerFundRequest pfr1 = Core_MDF_CCP_TestDataUtility.createRetailActivity(string.valueof(camp.Id),
                                                                                        string.valueof(acc1.id),System.today(),System.today(),false); 
            pfr1.Title = 'Test Retail Activity 1';
            pfr1.Core_MDF_Activity_Description__c = 'Test Retail Activity';
            pfr1.Core_MDF_Start_Date__c = System.today().addDays(5);
            pfr1.Core_MDF_End_Date__c = System.today().addDays(10);
            pfr1.RequestedAmount = 1000;
            pfr1.Core_MDF_Country_nm__c = 'COLOMBIA';
            //pfr1.Core_MDF_Country__c = 'COLOMBIA';
            
            pfr1.Core_MDF_Fund_Request_Status__c = 'Pending Review';
            
            pfrs.add(pfr);
            pfrs.add(pfr1);
            
            
            
        }
        
        Test.stopTest();
        System.assert(testPartnerFundRequestRecord2.Id != NULL);
        
    }
    
    
    
}