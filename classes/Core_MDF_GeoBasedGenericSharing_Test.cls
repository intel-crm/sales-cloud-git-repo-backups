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
        
        User usr = Core_MDF_CCP_TestDataUtility.createUser(true);
        List<Core_MDF_Partner_Group_Mapping__c> ccfpgmList = new List<Core_MDF_Partner_Group_Mapping__c>();
        
        System.runAs(usr){
            Test.startTest();
            //Create CCF Channel Program
            ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram ('Client Co-Marketing Fund','Client CoMarketing Fund', true);
            ChannelProgram cpRetail = Core_MDF_CCP_TestDataUtility.createProgram ('Retail Marketing Funds','Retail Marketing Funds', true);
            
            
            //Create Intel Account
            Account acc = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Account', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
            
            // Creating Intel Account for retail program
            Account acc1Retail = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Test Account Retail', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, 
                                                                                  false);
            acc1Retail.Core_Account_Type__c = 'Reseller';
            acc1Retail.Core_Sales_Groups__c = 'Automotive Sales Group';
            acc1Retail.Industry = 'Food & Beverage';
            acc1Retail.Core_MDF_Channel_Program__c = cpRetail.Id;
            acc1Retail.Core_Geo__c = 'ASMO';
            acc1Retail.Core_Sub_Geo__c = 'LAR';
            Database.insert(acc1Retail);
            
            //Create Co-Marketing Account
            Account acc2 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test CCF Account', cp.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc.Id, true);
            // Creating Retail Account with utility class
            Account accRetail = Core_MDF_CCP_TestDataUtility.createAccount ('Co-marketing Test Account Retail', cpRetail.Id,
                                                                            Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            accRetail.Core_MDF_Parent_Fund_Account__c = acc1Retail.Id;
            accRetail.Core_Geo__c = 'ASMO';
            accRetail.Core_Sub_Geo__c = 'LAR';
            Database.insert(accRetail);
            
            //Create CCF Group
            Group ccfgrp = new Group();
            ccfgrp.Name = 'Core CCP CCF Internal';
            ccfgrp.DeveloperName = 'Core_CCP_CCF_Internal';
            Database.insert(ccfgrp);
            
            //Create CCF Group
            Group ccfgrp2 = new Group();
            ccfgrp2.Name = 'Core CCP CCF Internal WW';
            ccfgrp2.DeveloperName = 'Core_CCP_CCF_Internal_WW';
            Database.insert(ccfgrp2);
            
            //Create Retail Group
            Group ccfgrp3 = new Group();
            ccfgrp3.Name = 'Core CCP CCF Internal ASMO';
            ccfgrp3.DeveloperName = 'Core_CCP_CCF_Internal_ASMO';
            Database.insert(ccfgrp3);
            
            //Create PGM
            Core_MDF_Partner_Group_Mapping__c ccfPgm = new Core_MDF_Partner_Group_Mapping__c();
            ccfPgm.Core_MDF_Account__c = acc.Id;
            ccfPgm.Core_MDF_Group_Name__c = 'Core_CCP_CCF_Internal';
            ccfPgm.Core_MDF_Type_of_Access__c = 'Internal';
            ccfPgm.Core_MDF_Group_Id__c = ccfgrp.Id;
            ccfPgm.Core_MDF_Channel_Program__c = cp.Id;
            ccfPgm.Core_MDF_Region_cd__c = 'EMEA';
            Database.insert(ccfPgm);
            
            Core_MDF_Partner_Group_Mapping__c ccfPgm2 = new Core_MDF_Partner_Group_Mapping__c();
            ccfPgm2.Core_MDF_Account__c = acc.Id;
            ccfPgm2.Core_MDF_Group_Name__c = 'Core_CCP_CCF_Internal_WW';
            ccfPgm2.Core_MDF_Type_of_Access__c = 'Internal';
            ccfPgm2.Core_MDF_Group_Id__c = ccfgrp2.Id;
            ccfPgm2.Core_MDF_Channel_Program__c = cp.Id;
            ccfPgm2.Core_MDF_Region_cd__c = 'WW';
            Database.insert(ccfPgm2);
            
            Core_MDF_Partner_Group_Mapping__c ccfPgm3 = new Core_MDF_Partner_Group_Mapping__c();
            ccfPgm3.Core_MDF_Account__c = acc1Retail.Id;
            ccfPgm3.Core_MDF_Group_Name__c = 'Core_CCP_Retail_Internal_ASMO';
            ccfPgm3.Core_MDF_Type_of_Access__c = 'Internal';
            ccfPgm3.Core_MDF_Group_Id__c = ccfgrp3.Id;
            ccfPgm3.Core_MDF_Channel_Program__c = cpRetail.Id;
            ccfPgm3.Core_MDF_Region_cd__c = 'ASMO';
            ccfPgm3.Core_MDF_Sub_Region_cd__c = 'LAR';
            Database.insert(ccfPgm3);
            
            
            Profile ccpCoreProfile = [SELECT Id FROM Profile WHERE Name = 'CCP - Core Access'];
            
            PermissionSet ccfAccManagerPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_CCF_Acct_Mgr' LIMIT 1];            
            List<User> userList = new List<User>();
            List<PermissionSetAssignment> permissionSetAssignmentList = new List<PermissionSetAssignment>();
            
            User ccfAccountManager = Core_MDF_CCP_TestDataUtility.createUser(false);
            ccfAccountManager.profileId = ccpCoreProfile.Id;
            ccfAccountManager.LastName = 'CCF Acc Manager';
            userList.add(ccfAccountManager);
            
            insert userList;
            
            PermissionSetAssignment psa1 = new PermissionSetAssignment(PermissionSetId = ccfAccManagerPS.Id, AssigneeId = ccfAccountManager.Id);
            permissionSetAssignmentList.add(psa1);
            
            insert permissionSetAssignmentList;
            
            //Create Bank
            Core_MDF_Bank__c bank = Core_MDF_CCP_TestDataUtility.createBank(acc.Id, 'Core_MDF_Client_CoMarketing_Fund', true,'1231231230');
            
            //Create Budget
            PartnerMarketingBudget testBudget = Core_MDF_CCP_TestDataUtility.createBudget('TestBudgetData',Core_MDF_CCP_TestDataUtility.budget_Record_Type,
                                                                                          acc2.id, cp.Id , 10000 , System.today()-60 , System.today() + 60 , 
                                                                                          true);
            
            //Create Campaign
            Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 13','Gaming','Intel® Core™ i7 Processor', 
                                                                        Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 
                                                                        'Client CoMarketing Fund', System.today(), System.today().addDays(15), 
                                                                        10000, 'Always Connected PC', acc2.Id,'Desktop', true); 
            Campaign camp2 = Core_MDF_CCP_TestDataUtility.createCampaign('TestRetailCamp','Gaming','Athena', 
                                                                         Core_MDF_CCP_TestDataUtility.campaign_RecordType_Retail, 'Retail Marketing Funds',System.today().addDays(16) , 
                                                                         System.today().addYears(1), 2000, 'Instore innovation', accRetail.Id,'2-in-1', true);
            
            
            Test.stopTest();
        }
    }
    @isTest
    static void pfrGeoShare()
    {
        UserRole usrRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        User usr2 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr2.LastName = 'User Test';
        usr2.UserRoleId = usrRole.Id;
        Database.insert(usr2);
        System.runAs(usr2)
        {
            Account acc2 = [select id from account where name = 'Test CCF Account']; 
            Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 13','Gaming','Intel® Core™ i7 Processor', 
                                                                        Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 
                                                                        'Client CoMarketing Fund', system.today(), //System.today().addDays(-300), 
                                                                        date.valueOf('2020-12-30'), 10000, 'Always Connected PC', 
                                                                        acc2.Id,'Desktop', true); 
            
            
            PartnerMarketingBudget testBudget = [select id from PartnerMarketingBudget where Title ='TestBudgetData'];
            List<Core_MDF_CCP_Country_Geo_Mapping__mdt> cgmList = [SELECT MasterLabel, Core_MDF_Geo__c, Core_MDF_Sub_Geo__c  
                                                                   FROM Core_MDF_CCP_Country_Geo_Mapping__mdt];
            Test.startTest();
            
            PartnerFundRequest testPartnerFundRequestRecord2 = Core_MDF_CCP_TestDataUtility.insertPartnerFundRequest(camp.id,Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,acc2.Id,null,
                                                                                                                     testBudget,'United Kingdom','Consumer','Desktop','Intel® Corporate Logo','Event',
                                                                                                                     'Member Participation in Third-Party Event','Draft',false);
            
            Date stDate = date.valueOf('2019-10-25');
            Date endDate = date.valueOf('2019-11-02');
            testPartnerFundRequestRecord2.Core_MDF_Start_Date__c = stdate;
            testPartnerFundRequestRecord2.Core_MDF_End_Date__c = endDate;
            testPartnerFundRequestRecord2.RequestedAmount = 16250;
            testPartnerFundRequestRecord2.Core_MDF_Fund_Request_Status__c = 'Planned';
            testPartnerFundRequestRecord2.Core_MDF_Country_nm__c = 'United Kingdom';
            //          testPartnerFundRequestRecord2.Core_MDF_Region_cd__c = 'EMEA';
            insert testPartnerFundRequestRecord2;
            
            PartnerFundRequest testPartnerFundRequestRecord3 = Core_MDF_CCP_TestDataUtility.insertPartnerFundRequest(camp.id,Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,acc2.Id,null,
                                                                                                                     testBudget,'COLOMBIA','Consumer','Desktop','Intel® Corporate Logo','Event',
                                                                                                                     'Member Participation in Third-Party Event','Draft',false);
            
            Date strDate = date.valueOf('2019-10-25');
            Date edDate = date.valueOf('2019-11-02');
            testPartnerFundRequestRecord3.Core_MDF_Start_Date__c = stdate;
            testPartnerFundRequestRecord3.Core_MDF_End_Date__c = endDate;
            testPartnerFundRequestRecord3.RequestedAmount = 16250;
            testPartnerFundRequestRecord3.Core_MDF_Fund_Request_Status__c = 'Planned';
            testPartnerFundRequestRecord3.Core_MDF_Country_nm__c = 'COLOMBIA';
            //          testPartnerFundRequestRecord3.Core_MDF_Region_cd__c = 'EMEA';
            insert testPartnerFundRequestRecord3;
            
            User user = [SELECT Id, LastName FROM User WHERE LastName ='User Test'  LIMIT 1];
            Campaign camp2 = [SELECT Id FROM Campaign WHERE Name ='TestRetailCamp'  LIMIT 1];
            Account acc = [SELECT Id FROM Account WHERE Name ='Co-marketing Test Account Retail'  LIMIT 1];
            Account acc1 = [SELECT Id FROM Account WHERE Name ='Test CCF Account'  LIMIT 1];
            list<PartnerFundRequest> pfrs = new list<PartnerFundRequest>();
            
            System.runAs(user){
                
                //Creating partner fund request
                PartnerFundRequest pfr = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp2.Id),
                                                                                               Core_MDF_CCP_TestDataUtility.partnerFund_RecordType_Retail,string.valueof(acc.id),NULL,NULL,'COLOMBIA','Gaming','2-in-1',
                                                                                               'Athena','Online','Customer.com','Draft',false);
                pfr.Title = 'Test Retail Activity';
                pfr.Core_MDF_Activity_Description__c = 'Test Retail Activity';
                pfr.Core_MDF_Start_Date__c = System.today().addDays(17);
                pfr.Core_MDF_End_Date__c = System.today().addDays(18);
                pfr.RequestedAmount = 1000;
                pfr.Core_MDF_Country_nm__c = 'INDIA';
                pfr.Core_MDF_Country__c = 'INDIA';
                pfr.Core_MDF_Fund_Request_Status__c = 'Pending Review';
                
                PartnerFundRequest pfr1 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),
                                                                                                Core_MDF_CCP_TestDataUtility.partnerFund_RecordType_Retail,string.valueof(acc1.id),NULL,NULL,'COLOMBIA','Gaming','2-in-1',
                                                                                                'Athena','Online','Customer.com','Draft',false);
                pfr1.Title = 'Test Retail Activity 1';
                pfr1.Core_MDF_Activity_Description__c = 'Test Retail Activity';
                pfr1.Core_MDF_Start_Date__c = System.today().addDays(17);
                pfr1.Core_MDF_End_Date__c = System.today().addDays(18);
                pfr1.RequestedAmount = 1000;
                pfr1.Core_MDF_Country_nm__c = 'COLOMBIA';
                pfr1.Core_MDF_Country__c = 'COLOMBIA';
                pfr1.Core_MDF_Fund_Request_Status__c = 'Pending Review';
                
                pfrs.add(pfr);
                pfrs.add(pfr1);
                
                Database.insert(pfrs);
                
            }
            
            Test.stopTest();
            System.assert(testPartnerFundRequestRecord2.Id != NULL);
            
        }
    }
    
    @isTest
    static void bankGeoShare()
    {
        UserRole usrRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        User usr3 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr3.LastName = 'User Test';
        usr3.UserRoleId = usrRole.Id;
        Database.insert(usr3);
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
            Insert newBank;
            
            Core_Integration_Inbound_Message__c payLoad1 = new Core_Integration_Inbound_Message__c();
            payLoad1.Core_Payload__c = '[{"SUPPL_HLD_PMT_IND":"N","bnfcy_nm":"TEST BENEFICIARY NAME","intrmd_bank_ind":"N","bnk_nm":"TEST BANK","bnk_nbr":"123456","ap_vndr_nbr":1234567891,"DUNS_NBR":"578299333","ctry_cd":"GB","suppl_nm":"Test","swift_cd":"BOFSGB21124 "}]';
            payLoad1.Core_Message_Type__c = 'Bank';
            payLoad1.Core_Source_System__c   = 'EDW';
            insert payLoad1;
            System.assert(newBank.Id != NULL);
        }
    }
    
}