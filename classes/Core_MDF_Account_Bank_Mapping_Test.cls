@isTest(SeeAllData=false)
public class Core_MDF_Account_Bank_Mapping_Test {
      public static Id channelProgramId;
        @TestSetup static void setUpData() {
            List<String> bypassFunctionKeys = new List<String>();
            bypassFunctionKeys.add('Bypass_Duplicate_Budget_Check');
            bypassFunctionKeys.add('Bypass_GeoBased_Budget_Sharing');
            bypassFunctionKeys.add('Bypass_Allocation_Reservation');
            bypassFunctionKeys.add('Bypass_GeoBased_Allocation_Sharing');
            List<Core_Trigger_Executions__c> bypassfunctinalitylist = Core_MDF_CCP_TestDataUtility.byPassFeature(bypassFunctionKeys,true,true);
            
            //System Admin
            User systemAdm = Core_MDF_CCP_TestDataUtility.createUser(false);
            systemadm.Email = 'systemadm@example.com';
            insert systemAdm;
            List<Core_MDF_Configuration__c> configList = new List<Core_MDF_Configuration__c>();
            Core_MDF_Configuration__c config = new Core_MDF_Configuration__c();
            config.Name = 'ALLOWED_PRG_FOR_RUS_NOTIF';
            config.Core_MDF_Value__c = 'Retail Marketing Funds,Intel Partner Alliance';
            configList.add(config);
            database.insert(configList);
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
            //Role
            UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
            
            
            Profile partnerProfile = [SELECT Id FROM Profile WHERE Name='Partner' LIMIT 1];
           
            List<User> userList = new List<User>();
            
            // Creating User with utility class 
            User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr1.LastName = 'User Test1';
            usr1.ProfileId = partnerProfile.Id;
            usr1.ContactId = con.Id;
            insert usr1;
            //userList.add(usr1);
            // Creating User with utility class 
            User paymentAdmin = Core_MDF_CCP_TestDataUtility.createUser(false);
            paymentAdmin.LastName = 'Payment Admin';
            //paymentAdmin.UserRoleId = usRole.Id;
            insert paymentAdmin;
            //userList.add(paymentAdmin);
            //insert userList;
            //userList[0].ProfileId = partnerProfile.Id;
            //userList[0].ContactId = con.Id;
            //update userList[0];
            
            // Creating campaigns using utility class
            Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('TestCamp','Consumer','Intel® Corporate Logo', 'yes',
                                                                        Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF,
                                                                        'Client CoMarketing Fund',System.today().addDays(-5) ,
                                                                        System.today().addDays(200), 2000, 'Test',acc.Id,'2-in-1', false);
            camp.Core_MDF_Activity_Category_Type__c=null;
            insert camp;
            // Creating Budget using utility class
            PartnerMarketingBudget pmb = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget',Core_MDF_CCP_TestDataUtility.budget_Record_Type,
                                                                                   acc.Id,cp.Id,5000000,System.today().addDays(-5),System.today(), 
                                                                                   false);
            pmb.Core_MDF_Budget_Type_Txt__c='CCF 1.0';
            System.debug('@@@Before Budget insert---'+Limits.getQueries());
            insert pmb;
            System.debug('@@@after Budget insert---'+Limits.getQueries());
            System.debug('Core_MDF_Budget_Partner__r.Core_MDF_CoMarketing_Ultimate_Account__c@@@'+pmb.Core_MDF_Budget_Partner__c);
            
            // Creating Allocation using utility class
            System.debug('@@@Before PartnerFundAllocation insert:'+Limits.getQueries());
            PartnerFundAllocation pfa = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test Allocation',pmb,acc,1000000.0,true);
            System.debug('@@@After PartnerFundAllocation insert:'+Limits.getQueries());
             Test.startTest();  
            // Creating activities using utility class
            PartnerFundRequest pfr = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),
                                                                                           Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                           string.valueof(acc.id),pfa,pmb,'INDIA','Small Business',
                                                                                           'Desktop','Intel® Core™ i7 Processor','Broadcast',
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
            Core_MDF_Bank__c bank = Core_MDF_CCP_TestDataUtility.createBank(acc1.id,'Core_MDF_Client_CoMarketing_Fund',true,'1234567890');
           
            List<Core_MDF_Account_Bank_Mapping__c> abmList = new List<Core_MDF_Account_Bank_Mapping__c>();
            Core_MDF_Account_Bank_Mapping__c abmCCF = Core_MDF_CCP_TestDataUtility.createAccountBankMap(acc.Id, bank.Id, FALSE);
            abmCCF.Core_MDF_Active_ind__c = TRUE;
            insert abmCCF;
            
            PartnerFundRequestShare pfrShare = new PartnerFundRequestShare();
            pfrShare.ParentId = pfr.Id;
            pfrShare.UserOrGroupId = paymentAdmin.id;
            pfrShare.AccessLevel = 'Edit';
            Database.insert(pfrShare);  
            
            Core_MDF_Bank__Share bankShare  = new Core_MDF_Bank__Share();
            bankShare.ParentId = bank.Id;
            bankShare.UserOrGroupId =paymentAdmin.id;
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
            Test.stopTest();    
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
            cs.Core_MDF_Claim_ID__c=pfc1.id;
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
    @isTest
    static void createABMCCF(){
        
        
    }
}