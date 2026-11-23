/****************************************************************************************************************************************
* Class Name  : Core_MDF_ProcessCCPEscalation_Test
* Version     : 1.0 
* Created Date: 17-05-2019
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture -SA
*****************************************************************************************************************************************/
@isTest
private class Core_MDF_ProcessCCPEscalation_Test {
    
    @isTest static void createEscalationRecords(){
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        //Creating User with utility class 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test';
        usr.UserRoleId = usRole.Id;
        Database.insert(usr);
        List<PartnerFundClaim> newClmList = new List<PartnerFundClaim>();
        
        System.runAs(usr){
            
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
            
            // Creating channel program with utility class
            ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram ('Client Co-Marketing Fund','Client CoMarketing Fund', true);
           // List<Account> accList = new list<account>(); 
            // Creating IntelAccount with utility class
            Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Test Account 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, 
                                                                            false);
            acc1.Core_Account_Type__c = 'Reseller';
            acc1.Core_Sales_Groups__c = 'Automotive Sales Group';
            acc1.Industry = 'Food & Beverage';
            acc1.Core_MDF_Channel_Program__c = cp.Id;
            acc1.Core_MDF_CoMarketingAgency__c=true;
            Database.insert(acc1);
            //accList.add(acc1);
            
            // Creating Co-marketing Account with utility class
            Account acc = Core_MDF_CCP_TestDataUtility.createAccount ('Co-marketing Test Account', cp.Id,
                                                                      Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            acc.Core_MDF_Parent_Fund_Account__c = acc1.Id;
             //accList.add(acc);
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
            Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('TestCamp','Consumer','Intel® Corporate Logo','Yes',
                                                                        Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF,'Client CoMarketing Fund',
                                                                        System.today().addDays(5),System.today().addDays(200), 2000, 'Consumer Chromebook',acc.Id,'2-in-1', false);
            camp.Core_MDF_Opal_Budget_Type_Txt__c= 'CCF 1.0';
            Database.insert(camp);
            // Creating Budget using utility class
            PartnerMarketingBudget pmb = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget',Core_MDF_CCP_TestDataUtility.budget_Record_Type,
                                                                                   acc.Id,cp.Id,5000000,System.today(),System.today().addDays(110), 
                                                                                   false);
            pmb.Core_MDF_Budget_Type_Txt__c='CCF 1.0';
             Database.insert(pmb);
            
            // Creating Allocation using utility class
            PartnerFundAllocation pfa = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test Allocation',pmb,acc,1000000.0,true);
            // Creating activities using utility class
            PartnerFundRequest pfr = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),
                                                                                           Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                           string.valueof(acc.id),pfa,pmb,'INDIA','Small Business',
                                                                                           'Desktop','Intel vPro® platform','Broadcast',
                                                                                           'Podcast','Draft',false);
            pfr.RequestedAmount = 900000;
            pfr.Amount = 900000;
            pfr.Status = 'Approved';
            pfr.AllocationId = pfa.Id;
            pfr.BudgetId = pmb.Id;
            pfr.Core_MDF_Start_Date__c = System.today().addDays(5);
            pfr.Core_MDF_End_Date__c = System.today().addDays(10) ;
            Database.insert(pfr);
            // Creating Bank
            Core_MDF_Bank__c bank = Core_MDF_CCP_TestDataUtility.createBank(acc1.id,'Core_MDF_Client_CoMarketing_Fund',true,'1234567890');
            
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
            pfc.Core_MDF_Total_Invoice_Amount_Local__c = 20000;        
            pfc.Core_MDF_Audit_Hold__c = true;                 
            pfc.Core_MDF_Status__c = 'Submitted';
            pfc.Description = 'Test PFC ';
            pfc.Core_MDF_FlaggedForAudit__c = true;
            pfc.Core_MDF_Ad_Run_Start_Date__c = System.today().addDays(7);
            pfc.Core_MDF_Ad_Run_End_Date__c = System.today().addDays(9);
            pfc.Core_MDF_Invoice_Date__c = System.today();
            pfc.Core_MDF_Invoice_Number__c = '1121';
            pfc.Core_MDF_Media_Vehicle__c = 'test';
            pfc.Core_MDF_OtherCostsnotReimbursable_Local__c = 0;
            pfc.Core_MDF_Taxes_Local__c = 0;
            pfc.Core_MDF_Currency__c = 'USD';
            pfc.Core_MDF_Exchange_rate__c = 1;
            pfc.Core_MDF_Bank__c = bank.Id;
            pfc.Core_MDF_Country_Location_nm__c= 'UNITED KINGDOM';
            
           /* Core_MDF_Configuration__c setting = new Core_MDF_Configuration__c();
            setting.Name = 'Test Setting';
            setting.Core_MDF_Category__c='Bank Document Hold Logic';
            setting.Core_MDF_Value__c='Retail Marketing Funds,Intel Partner Alliance';
            insert setting;*/
            Core_MDF_CCP_TestDataUtility.createMDFConfigurationData();
            toBeInsertedClaims.add(pfc);
            test.StartTest();
            Database.insert(toBeInsertedClaims);
            
           
            
            Id budgetRecType = Schema.SObjectType.Core_MDF_Escalation__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Budget').getRecordTypeId();
            Id claimRecType = Schema.SObjectType.Core_MDF_Escalation__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Late_Claim').getRecordTypeId();
            
            Core_MDF_Escalation__c escalation = new Core_MDF_Escalation__c(Core_MDF_Escalation_Status_nm__c='Pending Review', Core_MDF_Escalation_Name_txt__c='Test',
                                                                           Core_MDF_Total_Dollar_Impact_amt__c= 56, Core_MDF_Root_Cause_nm__c = 'Appeal of Budget', Core_MDF_Budget_ID_Number_id__c = pmb.Id, recordtypeid= budgetRecType); //'0123D000000dvPHQAY';
            Database.insert(escalation);
            List<PartnerFundRequest> partnerFndActivityNumber = [select Core_MDF_Activity_Number__c from PartnerFundRequest where id=:pfr.id];
            
          // Core_MDF_Escalation__c escalation2 = new Core_MDF_Escalation__c(Core_MDF_Escalation_Status_nm__c='Pending Review', Core_MDF_Escalation_Name_txt__c='Test',
                                                                          //  Core_MDF_Total_Dollar_Impact_amt__c= 56, Core_MDF_Root_Cause_nm__c = 'Tools and Systems', Core_MDF_Co_Marketing_Activity_id__c= partnerFndActivityNumber[0].id, recordtypeid= claimRecType);
           // insert escalation2;
          
            
             //Core_MDF_Escalation__c escalation3 = new Core_MDF_Escalation__c(Core_MDF_Escalation_Status_nm__c='Pending Review', Core_MDF_Escalation_Name_txt__c='Test',
            //                                                                Core_MDF_Total_Dollar_Impact_amt__c= 56, Core_MDF_Root_Cause_nm__c = 'Tools and Systems', Core_MDF_Activity_Number_txt__c= '777777', recordtypeid= '0123D000000dvPMQAY');
           // insert escalation3;
            Core_MDF_ProcessCCPEscalation.updateActivityOnEscalation(null);
            test.StopTest();
            
        }
    }
}