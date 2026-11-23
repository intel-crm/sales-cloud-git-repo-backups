/****************************************************************************************************************************************
* Class Name  : Core_MDF_Escalation_ServiceHandler_Test 
* Version     : 1.0 
* Created Date: 19-05-2019
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture – Manasa Mahadev      19/05/2019                   Created Core_MDF_Escalation_ServiceHandler_Test to test Core_MDF_Escalation_ServiceHandler
* Intel - NP(11630236)          27/8/2019                     Added code to complete Checklist Items before saving Case Status(Release 37.6)   
*******************************************************************************************************************************************************/


@isTest(SeeAllData=false)

public class Core_MDF_Escalation_ServiceHandler_Test{

    public static Id channelProgramId;
    @TestSetup static void setUpData() {
        
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        //Creating User with utility class 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test';
        usr.UserRoleId = usRole.Id;
        Database.insert(usr);
        List<PartnerFundClaim> newClmList = new List<PartnerFundClaim>();
        
        system.runAs(usr){
            //Create Exchnage rates records
            List<Core_MDF_Currency_Exchange_Rates__c> newValues = new List<Core_MDF_Currency_Exchange_Rates__c>();            
            Core_MDF_Currency_Exchange_Rates__c record1 = new Core_MDF_Currency_Exchange_Rates__c();
            record1.Name= 'ZMK';
            record1.Core_MDF_Exchange_Rate__c = 0.0000850159;
            record1.Core_MDF_Market_Date__c =System.today()-2;
            record1.Core_MDF_Intel_WW__c = 'WW 46';
            newValues.add(record1);
            
            Core_MDF_Currency_Exchange_Rates__c record2 = new Core_MDF_Currency_Exchange_Rates__c();
            record2.Name= 'INR';
            record2.Core_MDF_Exchange_Rate__c = 1;
            record2.Core_MDF_Market_Date__c =System.today()-2;
            record2.Core_MDF_Intel_WW__c = 'WW 46';
            newValues.add(record2); 
            
            Core_MDF_Currency_Exchange_Rates__c record3 = new Core_MDF_Currency_Exchange_Rates__c();
            record3.Name= 'USD';
            record3.Core_MDF_Exchange_Rate__c = 1;
            record3.Core_MDF_Market_Date__c =System.today()-2;
            record3.Core_MDF_Intel_WW__c = 'WW 46';
            newValues.add(record3);             
            
            Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount aObj = new Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount();
            Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount bObj = new Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount();
            Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount cObj = new Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount();
            List<Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount> listvar = new List<Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount>();
            
            aObj.inputCurrency ='ZMK';
            aObj.inputAmount = 250.00;
            aObj.inputDate= date.newInstance(2018, 11, 13);
            bObj.inputCurrency ='INR';
            bObj.inputAmount = 350.00;
            bObj.inputDate= date.newInstance(2018, 11, 12);
            cObj.inputCurrency ='USD';
            cObj.inputAmount = 350.00;
            cObj.inputDate= date.newInstance(2018, 11, 12);
            listvar.add(aObj);
            listvar.add(bObj);
            listvar.add(cObj);
            Core_MDF_CCP_Multicurrency.getUSDExchangeRateBasedOnDate(listvar);
            
            database.insert(newValues);    

            Core_Trigger_Executions__c claimFunctionalityNameTriggerExecution3 = new Core_Trigger_Executions__c();
            claimFunctionalityNameTriggerExecution3.Core_Active__c = false;
            claimFunctionalityNameTriggerExecution3.Core_Class_Name__c = 'Core_MDF_PFCServiceHandler';
            claimFunctionalityNameTriggerExecution3.Core_Trigger_Events__c = 'before upate, after update';
            claimFunctionalityNameTriggerExecution3.Core_Object__c = 'PartnerFundClaim';
            claimFunctionalityNameTriggerExecution3.Name = 'checkAndSendClaimsToAudit';
            claimFunctionalityNameTriggerExecution3.Core_Description__c = 'test';
            Database.insert(claimFunctionalityNameTriggerExecution3);
            
            Core_Trigger_Executions__c claimFunctionalityNameTriggerExecution4 = new Core_Trigger_Executions__c();
            claimFunctionalityNameTriggerExecution4.Core_Active__c = true;
            claimFunctionalityNameTriggerExecution4.Core_Class_Name__c = 'Core_MDF_SendEmailHelper';
            claimFunctionalityNameTriggerExecution4.Core_Trigger_Events__c = 'after insert';
            claimFunctionalityNameTriggerExecution4.Core_Object__c = 'Core_MDF_Escalation__c';
            claimFunctionalityNameTriggerExecution4.Name = 'Core_MDF_EscalationErrorsNotification';
            claimFunctionalityNameTriggerExecution4.Core_Description__c = 'test';
            Database.insert(claimFunctionalityNameTriggerExecution4);
            
            Core_Trigger_Executions__c claimToCase = new Core_Trigger_Executions__c();
            claimToCase.Core_Active__c = true;
            claimToCase.Core_Class_Name__c = 'Core_MDF_PFCServiceHandler';
            claimToCase.Core_Description__c = 'This Custom Setting is used to turn on/off claim to case functionality.';
            claimToCase.Core_Object__c = 'PartnerFundClaim';
            claimToCase.Core_Trigger_Events__c = 'after update';
            claimToCase.Name='Core_MDF_ClaimToCase';        
            Database.insert(claimToCase);                  
            
            // Creating channel program with utility class
            ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram ('Client Co-Marketing Fund','Client CoMarketing Fund', true);
            channelProgramId = cp.Id;
            
            
            // Creating IntelAccount with utility class
            Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Test Account 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, 
                                                                            false);
            acc1.Core_Account_Type__c = 'Reseller';
            acc1.Core_Sales_Groups__c = 'Automotive Sales Group';
            acc1.Industry = 'Food & Beverage';
            acc1.Core_MDF_Channel_Program__c = cp.Id;
            acc1.Core_MDF_CoMarketingAgency__c=true;
            Database.insert(acc1);
            
            // Creating Co-marketing Account with utility class
            Account acc = Core_MDF_CCP_TestDataUtility.createAccount ('Co-marketing Test Account', cp.Id,
                                                                      Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            acc.Core_MDF_Parent_Fund_Account__c = acc1.Id;
            acc.Core_MDF_CoMarketing_Ultimate_Account__c = acc1.Id;
            Database.insert(acc);  
            
            // Creating Contact with utility class
            Contact con = Core_MDF_CCP_TestDataUtility.createContact (acc1.Id, false);
            con.RecordTypeId = Core_MDF_CCP_TestDataUtility.Intel_Contact_Record_Type;
            Database.insert(con);
            
            Profile partnerProfile = [SELECT Id FROM Profile WHERE Name='Partner' LIMIT 1];
            
            // Creating User with utility class 
            User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr1.LastName = 'User Test1';
            usr1.ProfileId = partnerProfile.Id;
            usr1.ContactId = con.Id;
            Database.insert(usr1);
            
            // Creating campaigns using utility class
            Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('TestCamp','Consumer','Intel® Corporate Logo', 
                                                                        Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF,
                                                                        'Client CoMarketing Fund',System.today().addDays(-5) ,
                                                                        System.today().addDays(200), 2000, 'Test',acc.Id,'2-in-1', true);
            
            // Creating Budget using utility class
            PartnerMarketingBudget pmb = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget',Core_MDF_CCP_TestDataUtility.budget_Record_Type,
                                                                                   acc.Id,cp.Id,5000000,System.today().addDays(-5),System.today(), 
                                                                                   true);
            
            System.debug('Core_MDF_Budget_Partner__r.Core_MDF_CoMarketing_Ultimate_Account__c@@@'+pmb.Core_MDF_Budget_Partner__c);
            
            // Creating Allocation using utility class
            PartnerFundAllocation pfa = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test Allocation',pmb,acc,1000000.0,true);
            Test.startTest();
            // Creating activities using utility class
            PartnerFundRequest pfr = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),
                                                                                           Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                           string.valueof(acc.id),pfa,pmb,'INDIA','Small Business',
                                                                                           'Desktop','Intel® Core™ i7+ Processor','Broadcast',
                                                                                           'Radio','Draft',false);
            pfr.RequestedAmount = 900000;
            pfr.Amount = 900000;
            pfr.Status = 'Approved';
            pfr.AllocationId = pfa.Id;
            pfr.BudgetId = pmb.Id;
            //pfr.Core_MDF_Ultimate_Account_Name__c = acc1.Id;
            pfr.Core_MDF_Start_Date__c = System.today().addDays(-5);
            pfr.Core_MDF_End_Date__c = System.today();
            Database.insert(pfr);
            // Creating Bank
            Core_MDF_Bank__c bank = Core_MDF_CCP_TestDataUtility.createBank(acc1.id,'Core_MDF_Client_CoMarketing_Fund',false,'1234567890');
            bank.Core_MDF_Bank_Status__c = 'Active';            
            insert bank;
            Core_MDF_Account_Bank_Mapping__c abm1 = Core_MDF_CCP_TestDataUtility.createAccountBankMap(acc.Id,bank.Id,true);

            PartnerFundRequestShare pfrShare = new PartnerFundRequestShare();
            pfrShare.ParentId = pfr.Id;
            pfrShare.UserOrGroupId = usr1.id;
            pfrShare.AccessLevel = 'Edit';
            Database.insert(pfrShare);  
            
            Core_MDF_Bank__Share bankShare  = new Core_MDF_Bank__Share();
            bankShare.ParentId = bank.Id;
            bankShare.UserOrGroupId = usr1.id;
            bankShare.AccessLevel = 'Edit'; 
            Database.insert(bankShare);  

            
            // Creating claims 
            List<PartnerFundClaim> toBeInsertedClaims= new List<PartnerFundClaim>();             
            PartnerFundClaim pfc  = new PartnerFundClaim();
            pfc.RecordTypeId = Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF;
            pfc.Title = 'Test Claim';
            pfc.RequestId = pfr.Id;
            pfc.Core_MDF_Total_Invoice_Amount_Local__c = 200;        
            pfc.Core_MDF_Audit_Hold__c = true;                 
            pfc.Core_MDF_Status__c = 'Submitted';
            pfc.Description = 'Test PFC';
            pfc.Core_MDF_Ad_Run_Start_Date__c = System.today();
            pfc.Core_MDF_Ad_Run_End_Date__c = System.today();
            pfc.Core_MDF_Invoice_Date__c = System.today();
            pfc.Core_MDF_Invoice_Number__c = '1121';
            pfc.Core_MDF_Media_Vehicle__c = 'test';
            pfc.Core_MDF_OtherCostsnotReimbursable_Local__c = 0;
            pfc.Core_MDF_Taxes_Local__c = 0;
            pfc.Core_MDF_Currency__c = 'USD';
            pfc.Core_MDF_Exchange_rate__c = 1;
            pfc.Core_MDF_Bank__c = bank.Id;
            pfc.Core_MDF_Country_Location_nm__c = 'INDIA';
            
            PartnerFundClaim pfc1  = new PartnerFundClaim();
            pfc1.RecordTypeId = Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF;
            pfc1.Title = 'Test Claim 1';
            pfc1.RequestId = pfr.Id;
            pfc1.Core_MDF_Total_Invoice_Amount_Local__c = 200;        
            pfc1.Core_MDF_Audit_Hold__c = true;                 
            pfc1.Core_MDF_Status__c = 'Submitted';
            pfc1.Description = 'Test PFC ';            
            pfc1.Core_MDF_Ad_Run_Start_Date__c = System.today();
            pfc1.Core_MDF_Ad_Run_End_Date__c = System.today();
            pfc1.Core_MDF_Invoice_Date__c = System.today();
            pfc1.Core_MDF_Invoice_Number__c = '1121';
            pfc1.Core_MDF_Media_Vehicle__c = 'test1';
            pfc1.Core_MDF_OtherCostsnotReimbursable_Local__c = 0;
            pfc1.Core_MDF_Taxes_Local__c = 0;
            pfc1.Core_MDF_Currency__c = 'USD';
            pfc1.Core_MDF_Exchange_rate__c = 1;
            pfc1.Core_MDF_Bank__c = bank.Id;
            pfc1.Core_MDF_Country_Location_nm__c = 'INDIA';
            
            toBeInsertedClaims.add(pfc);
            toBeInsertedClaims.add(pfc1);
            Database.insert(toBeInsertedClaims);
            
            pfc1.Core_MDF_FlaggedForAudit__c = true;
            pfc.Core_MDF_FlaggedForAudit__c = true;
            
            Database.update(pfc);
            Database.update(pfc1);
            
            // Creating User with utility class 
            User usr2 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr2.LastName = 'User Test2';          
            //Database.insert(usr2);        
            User usr3 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr3.LastName = 'User Test3';
            //Database.insert(usr3);
            User usr4 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr4.LastName = 'User Test3';            
            //Database.insert(usr4);
            List<User> usrList = new List<User>();
            usrList.add(usr2);
            usrList.add(usr3);
            usrList.add(usr4);
            insert usrList;            
            Test.stopTest();
            //Creating Groups
            Group grp = new Group();
            grp.Name = 'CCP INTERNAL CCF APJ TACCOUNT';
            grp.DeveloperName = 'Core_MDF_CCP_INTERNAL_CCF_APJ_TACCOUNT';
            
            Group grp1 = new Group();
            grp1.Name = 'Core_MDF_CCP_External';
            grp1.DeveloperName = 'Core_MDF_CCP_External';   
            
            Group grp2 = new Group();
            grp2.Name = 'CCP INTERNAL CCF EMEA TACCOUNT';
            grp2.DeveloperName = 'Core_MDF_CCP_INTERNAL_CCF_EMEA_TACCOUNT';
            
            Group grp3 = new Group();
            grp3.Name = 'CCP INTERNAL CCF ASMO TACCOUNT';
            grp3.DeveloperName = 'Core_MDF_CCP_INTERNAL_CCF_ASMO_TACCOUNT';
            
            Group grp4 = new Group();
            grp4.Name = 'CCP INTERNAL CCF WW TACCOUNT';
            grp4.DeveloperName = 'Core_MDF_CCP_INTERNAL_CCF_WW_TACCOUNT';
            
            Group grp5 = new Group();
            grp5.Name = 'CCP INTERNAL CCF PRC TACCOUNT';
            grp5.DeveloperName = 'Core_MDF_CCP_INTERNAL_CCF_PRC_TACCOUNT';
            
            List<Group> lstGroup = new List<Group>();
            lstGroup.add(grp);
            lstGroup.add(grp1);
            lstGroup.add(grp2);
            lstGroup.add(grp3);
            lstGroup.add(grp4);
            lstGroup.add(grp5);
            Database.insert(lstGroup);
            
            // Creating Group Members
            GroupMember grpMember = new GroupMember();
            grpMember.UserOrGroupId = usr2.Id;
            grpMember.GroupId = grp.Id;
            
            GroupMember grpMember1 = new GroupMember();
            grpMember1.UserOrGroupId = usr3.Id;
            grpMember1.GroupId = grp1.Id;
            
            GroupMember grpMember2 = new GroupMember();
            grpMember2.UserOrGroupId = usr4.Id;
            grpMember2.GroupId = grp2.Id;           
            
            GroupMember grpMember3 = new GroupMember();
            grpMember3.UserOrGroupId = usr4.Id;
            grpMember3.GroupId = grp3.Id;
            
            List<GroupMember> lstGrpMember = new List<GroupMember>();
            lstGrpMember.add(grpMember);
            lstGrpMember.add(grpMember1);
            lstGrpMember.add(grpMember2);
            lstGrpMember.add(grpMember3);
           
            Database.insert(lstGrpMember);
            
            // Creating Partner Group Mapping
            Core_MDF_Partner_Group_Mapping__c pgm = new Core_MDF_Partner_Group_Mapping__c();
            pgm.Core_MDF_Account__c = acc1.Id;
            pgm.Core_MDF_Group_Name__c = 'CCP INTERNAL CCF APJ TACCOUNT';
            pgm.Core_MDF_Type_of_Access__c = 'Internal';
            pgm.Core_MDF_Group_Id__c = grp.Id;                
            pgm.Core_MDF_Channel_Program__c = cp.Id;
            pgm.Core_MDF_Region_cd__c = 'APJ';
            pgm.Core_MDF_Source_Txt__c = 'Test';
            insert pgm;
            
            
            Core_MDF_Partner_Group_Mapping__c pgm1 = new Core_MDF_Partner_Group_Mapping__c();
            pgm1.Core_MDF_Account__c = acc1.Id;
            pgm1.Core_MDF_Group_Name__c = 'Core_MDF_CCP_External';
            pgm1.Core_MDF_Type_of_Access__c = 'External';
            pgm1.Core_MDF_Group_Id__c = grp1.Id;                
            pgm1.Core_MDF_Channel_Program__c = cp.Id;
            pgm1.Core_MDF_Source_Txt__c = 'Test';

           
            
            Core_MDF_Partner_Group_Mapping__c pgm2 = new Core_MDF_Partner_Group_Mapping__c();
            pgm2.Core_MDF_Account__c = acc1.Id;
            pgm2.Core_MDF_Group_Name__c = 'CCP INTERNAL CCF EMEA TACCOUNT';
            pgm2.Core_MDF_Type_of_Access__c = 'Internal';
            pgm2.Core_MDF_Group_Id__c = grp2.Id;                
            pgm2.Core_MDF_Channel_Program__c = cp.Id;
            pgm2.Core_MDF_Region_cd__c = 'EMEA';
            pgm2.Core_MDF_Source_Txt__c = 'Test';
            insert pgm2;
            
            Core_MDF_Partner_Group_Mapping__c pgm3 = new Core_MDF_Partner_Group_Mapping__c();
            pgm3.Core_MDF_Account__c = acc1.Id;
            pgm3.Core_MDF_Group_Name__c = 'CCP INTERNAL CCF ASMO TACCOUNT';
            pgm3.Core_MDF_Type_of_Access__c = 'Internal';
            pgm3.Core_MDF_Group_Id__c = grp2.Id;                
            pgm3.Core_MDF_Channel_Program__c = cp.Id;
            pgm3.Core_MDF_Region_cd__c = 'ASMO';
            pgm3.Core_MDF_Source_Txt__c = 'Test';
            insert pgm3;
            
            Core_MDF_Partner_Group_Mapping__c pgm4 = new Core_MDF_Partner_Group_Mapping__c();
            pgm4.Core_MDF_Account__c = acc1.Id;
            pgm4.Core_MDF_Group_Name__c = 'CCP INTERNAL CCF PRC TACCOUNT';
            pgm4.Core_MDF_Type_of_Access__c = 'Internal';
            pgm4.Core_MDF_Group_Id__c = grp2.Id;                
            pgm4.Core_MDF_Channel_Program__c = cp.Id;
            pgm4.Core_MDF_Region_cd__c = 'PRC';
            pgm4.Core_MDF_Source_Txt__c = 'Test';
            insert pgm4;
            
            Core_MDF_Partner_Group_Mapping__c pgm5 = new Core_MDF_Partner_Group_Mapping__c();
            pgm5.Core_MDF_Account__c = acc1.Id;
            pgm5.Core_MDF_Group_Name__c = 'CCP INTERNAL CCF WW TACCOUNT';
            pgm5.Core_MDF_Type_of_Access__c = 'Internal';
            pgm5.Core_MDF_Group_Id__c = grp2.Id;                
            pgm5.Core_MDF_Channel_Program__c = cp.Id;
            pgm5.Core_MDF_Region_cd__c = 'WW';
            pgm5.Core_MDF_Source_Txt__c = 'Test';
            insert pgm5;
            
            /*List<Core_MDF_Partner_Group_Mapping__c> pgmList = new List<Core_MDF_Partner_Group_Mapping__c>();
            pgmList.add(pgm);
            pgmList.add(pgm1);
            pgmList.add(pgm2);
            pgmList.add(pgm3);
            Database.insert(pgmList); */
            
            Id budgetRecType = Schema.SObjectType.Core_MDF_Escalation__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Budget').getRecordTypeId();
            Core_MDF_Escalation__c esc = new Core_MDF_Escalation__c();
            esc.Core_MDF_Escalation_Status_nm__c='Pending Review';
            esc.Core_MDF_Escalation_Name_txt__c='Test';
            esc.Core_MDF_Total_Dollar_Impact_amt__c= 56;
            esc.Core_MDF_Root_Cause_nm__c = 'Appeal of Budget';
            esc.Core_MDF_Budget_ID_Number_id__c = pmb.Id;
            esc.Core_MDF_Channel_Program_id__c = cp.Id;
            esc.recordtypeid = budgetRecType;
            Database.insert(esc);
            
            List<PartnerFundRequest> partnerFndActivityNumber = [select Core_MDF_Activity_Number__c from PartnerFundRequest where id=:pfr.id];
            Id claimRecType = Schema.SObjectType.Core_MDF_Escalation__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Late_Claim').getRecordTypeId();
            Core_MDF_Escalation__c esc1 = new Core_MDF_Escalation__c();
            esc1.Core_MDF_Escalation_Status_nm__c='Pending Review';
            esc1.Core_MDF_Escalation_Name_txt__c='Test1';
            esc1.Core_MDF_Total_Dollar_Impact_amt__c= 56;
            esc1.Core_MDF_Root_Cause_nm__c = 'Tools and Systems';
            esc1.Core_MDF_Co_Marketing_Activity_id__c = partnerFndActivityNumber[0].Id;
            esc1.Core_MDF_Channel_Program_id__c = cp.Id;
            esc1.recordtypeid= claimRecType;
            Database.insert(esc1);
            
            Case cs = new Case();
            Id caseAuditRecType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Core_MDF_Audit_Closed').getRecordTypeId();
            //cs.Id = pfc1.Core_MDF_Claim_Review_Case__c;
            cs.Status = 'Closed';
            cs.recordTypeId = caseAuditRecType;
            cs.AccountId = acc.Id;
            insert cs;  
            Id caseRecType = Schema.SObjectType.Core_MDF_Escalation__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Claim_Case_Review_Result').getRecordTypeId();
            Core_MDF_Escalation__c esc2 = new Core_MDF_Escalation__c();
            esc2.Core_MDF_Escalation_Status_nm__c='Pending Review';
            esc2.Core_MDF_Escalation_Name_txt__c='Test2';
            esc2.Core_MDF_Total_Dollar_Impact_amt__c= 45;
            esc2.Core_MDF_Root_Cause_nm__c = 'Creative';
            esc2.Core_MDF_Case_ID_Number_id__c = cs.Id;
            esc2.Core_MDF_Channel_Program_id__c = cp.Id;
            esc2.recordtypeid = caseRecType;
            
            Database.insert(esc2);
            
            
        }
        
    }
    
    @isTest static void testEscMethod(){
        test.StartTest();             
        User sysAdminUser = [SELECT Id,Email from User where LastName = 'User Test' limit 1];
        User internalUser = [SELECT Id,Email from User where LastName = 'User Test2' limit 1];
        System.runAs(sysAdminUser){
            
            Map<Id,Core_MDF_Escalation__c> elstMap = new Map<Id,Core_MDF_Escalation__c>([Select Id, recordtypeid, Core_MDF_Budget_ID_Number_id__c, Core_MDF_Co_Marketing_Activity_id__c, Core_MDF_Case_ID_Number_id__c
                                                                                         ,Core_MDF_Channel_Program_id__c from Core_MDF_Escalation__c WHERE (Core_MDF_Budget_ID_Number_id__c != null OR 
                                                                                        Core_MDF_Co_Marketing_Activity_id__c != null OR Core_MDF_Case_ID_Number_id__c != null)]);
            System.assertNotEquals(elstMap.size(),0,'to check whether we are retrieving the escalation recs as per the test data setup');
            if(elstMap != null && elstMap.size() > 0){
                Database.update(elstMap.values()[0]);    
            }
            Core_MDF_Escalation_ServiceHandler.shareEscalation(elstMap,null,true);
            
        }
        test.StopTest();
    }
    
    @isTest static void testApprovalAction(){
        List<Core_MDF_Escalation__c> escToBeupdated = new List<Core_MDF_Escalation__c>();       
        List<PartnerFundClaim> toBeupdatedClaims = new List<PartnerFundClaim>();   
        List<Core_MDF_Claim_Case_Checklist__c> checklistRecords = new List<Core_MDF_Claim_Case_Checklist__c>();
        test.StartTest();             
        User sysAdminUser = [SELECT Id,Email from User where LastName = 'User Test' limit 1];
        Case compliantCase = new Case();
        Case nonCompliantCase = new Case();
        Case paymentDueCase = new Case();
        System.runAs(sysAdminUser){
            Integer tempCounter = 0;
            for(PartnerFundClaim  pfc: [SELECT Id, Core_MDF_Claim_Review_Case__c, Core_MDF_Status__c FROM PartnerFundClaim
                WHERE Core_MDF_Claim_Review_Case__c != null]){
                System.debug('Inside SOQL');
                if(tempCounter == 0){
                    compliantCase.Id = pfc.Core_MDF_Claim_Review_Case__c;
                    
                    pfc.Core_MDF_Status__c = Label.Core_MDF_Claim_Status_Pending_Available_Fund;
                    toBeupdatedClaims.add(pfc);
                }
                if(tempCounter == 1){
                    nonCompliantCase.Id = pfc.Core_MDF_Claim_Review_Case__c;
                    nonCompliantCase.Core_MDF_Adjustment_Amount_Local__c =0;
                    nonCompliantCase.Core_MDF_Claim_Conversion_Exchange_Rate__c = 1;
                    nonCompliantCase.Core_MDF_Reimbursement_Rate__c = 50;
                    nonCompliantCase.Core_MDF_Requested_Amount_USD_Amt__c = 5;
                    //nonCompliantCase.Core_MDF_Adjustment_Amount_Local__c = 20;
                    //nonCompliantCase.Core_MDF_Adjustment_Amount_USD_Amt__c    = 20;
                    //nonCompliantCase.Core_MDF_Claim_Amount_USD__c  = 2000;
                    
                    pfc.Core_MDF_Status__c = Label.Core_MDF_Claim_Status_Denied;
                    toBeupdatedClaims.add(pfc);
                } 
                
                tempCounter = tempCounter + 1;
                    
            }
            //update nonCompliantCase;
            
            System.debug('compliantCase: '+compliantCase.Id);
            System.debug('nonCompliantCase: '+nonCompliantCase.Id);
            
            Core_MDF_Claim_Case_Checklist__c checklistRecord1 = new Core_MDF_Claim_Case_Checklist__c();
            checklistRecord1.Core_MDF_Case_ID__c = compliantCase.id;
            checklistRecord1.Core_MDF_Completion_Percentage__c = 100;
            checklistRecords.add(checklistRecord1);
            
            Core_MDF_Claim_Case_Checklist__c checklistRecord2 = new Core_MDF_Claim_Case_Checklist__c();
            checklistRecord2.Core_MDF_Case_ID__c = nonCompliantCase.id;
            checklistRecord2.Core_MDF_Checklist_Status__c = 'Non-Compliant';
            checklistRecord2.Core_MDF_Impact_Amount__c = 20;
            checklistRecord2.Core_MDF_Completion_Percentage__c = 100;
            checklistRecords.add(checklistRecord2);
            Database.insert(checklistRecords);

            if(compliantCase.Id != null){
                compliantCase.Core_MDF_Status__c  = 'Under Review';
                update compliantCase;
                
                compliantCase.Core_MDF_Review_Case_Status__c  = 'Compliant';
                compliantCase.Core_MDF_Adjustment_Amount_Local__c = 20;
                update compliantCase;
                Id caseRecType = Schema.SObjectType.Core_MDF_Escalation__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Claim_Case_Review_Result').getRecordTypeId();
                Core_MDF_Escalation__c esc2 = new Core_MDF_Escalation__c();
                esc2.Core_MDF_Escalation_Status_nm__c='Pending Review';
                esc2.Core_MDF_Escalation_Name_txt__c='Test2';
                esc2.Core_MDF_Total_Dollar_Impact_amt__c= 45;
                esc2.Core_MDF_Root_Cause_nm__c = 'Creative';
                esc2.Core_MDF_Case_ID_Number_id__c = compliantCase.Id;
                esc2.Core_MDF_Channel_Program_id__c = channelProgramId;
                esc2.recordtypeid = caseRecType;
                
                //insert escalation
                Database.insert(esc2);
                
                //Approve Escalation
                esc2.Core_MDF_Escalation_Status_nm__c = 'Approved';   
                escToBeupdated.add(esc2);
                System.debug('Update Escalation 2');                
                
            }

            if(nonCompliantCase.Id != null){
                nonCompliantCase.Core_MDF_Status__c  = 'Under Review';
                //noncompliantCase.Core_MDF_Adjustment_Amount_Local__c = 2000;
                //nonCompliantCase.Core_MDF_Adjustment_Amount_USD_Amt__c    = 2000;
                nonCompliantCase.Core_MDF_Claim_Amount_USD__c  = 2000;
                nonCompliantCase.Core_MDF_Adjustment_Amount_Local__c =2000;
                nonCompliantCase.Core_MDF_TotalTransactionAmountLocal__c = 4000;
                nonCompliantCase.Core_MDF_Claim_Taxes_Local__c = 0;
                nonCompliantCase.Core_MDF_OtherCostsnotReimbursableLocal__c = 0;
                nonCompliantCase.Core_MDF_Claim_Conversion_Exchange_Rate__c = 1;
                nonCompliantCase.Core_MDF_Reimbursement_Rate__c = 50;
                nonCompliantCase.Core_MDF_Requested_Amount_USD_Amt__c = 5;                
                update nonCompliantCase;
                
                nonCompliantCase.Core_MDF_Review_Case_Status__c  = 'Non-Compliant';
                update nonCompliantCase;
                Id caseRecType = Schema.SObjectType.Core_MDF_Escalation__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Claim_Case_Review_Result').getRecordTypeId();
                Core_MDF_Escalation__c esc3 = new Core_MDF_Escalation__c();
                esc3.Core_MDF_Escalation_Status_nm__c='Pending Review';
                esc3.Core_MDF_Escalation_Name_txt__c='Test2';
                esc3.Core_MDF_Total_Dollar_Impact_amt__c= 457917343;
                esc3.Core_MDF_Root_Cause_nm__c = 'Creative';
                esc3.Core_MDF_Case_ID_Number_id__c = nonCompliantCase.Id;
                esc3.Core_MDF_Channel_Program_id__c = channelProgramId;
                esc3.recordtypeid = caseRecType;
                
                //insert escalation
                Database.insert(esc3);
                
                //Approve Escalation
                esc3.Core_MDF_Escalation_Status_nm__c = 'Approved';   
                escToBeupdated.add(esc3);
                
                
                Core_MDF_Notify_Account_Manager__e notificationEvent = new Core_MDF_Notify_Account_Manager__e();
                notificationEvent.Core_MDF_Escalation_Id_txt__c = esc3.Id;
                notificationEvent.Core_MDF_isBusinessError_ind__c = true;
                notificationEvent.Core_MDF_errorMessage_txt__c = Label.Core_MDF_ClaimExceedsCapRemainder_ErrorMsg;
                // Call method to publish events 
                Database.SaveResult sr = EventBus.publish(notificationEvent);
                
            }
        }
        if(toBeupdatedClaims.size()>0){
            Database.update(toBeupdatedClaims);
        }
        
        if(escToBeupdated.size() > 0){
            System.debug('Update Escalation');
            Database.update(escToBeupdated,false);
            System.assertEquals(escToBeupdated[0].Core_MDF_Escalation_Status_nm__c,'Approved','As the approval process was successful status should  be approved');
        }
        test.StopTest();
        
    }
/****************************************************************************************************** 
    Method Name:        isUserEligibiletoCreateClaim
    @parameters:        NA
    Description:        This method is used to check if user has the permission to create Claim from Escalation.
    Added By:           Manasa - Accenture - 27/06/2019
    *******************************************************************************************************/    
   @isTest static void testchkClaimCreatePerm(){
        User u = [Select Id from User where LastName ='User Test' limit 1];
        System.runAs(u){
           Boolean res = Core_MDF_Escalation_ServiceHandler.isUserEligibletoCreateClaim(); 
           System.assertEquals(res,TRUE,'Admin Users should have access to create claims');
        }    
    }    
                  
}