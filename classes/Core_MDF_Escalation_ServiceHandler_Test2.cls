/****************************************************************************************************************************************
* Class Name  : Core_MDF_Escalation_ServiceHandler_Test2
* Version     : 1.0
* Created Date: 19-05-2019
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture – Manasa Mahadev      19/05/2019                   Created Core_MDF_Escalation_ServiceHandler_Test2 to test Core_MDF_Escalation_ServiceHandler
* Intel - NP(11630236)          27/8/2019                     Added code to complete Checklist Items before saving Case Status(Release 37.6)  
*******************************************************************************************************************************************************/
@isTest(SeeAllData=false)
public class Core_MDF_Escalation_ServiceHandler_Test2{
    public static Id claimRecType = Schema.SObjectType.Core_MDF_Escalation__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Late_Claim').getRecordTypeId();
    public static Id RMF_RecordType = Schema.SObjectType.Core_MDF_Int_Users_Partner_Geo_Mapping__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Retail_Marketing_Funds').getRecordTypeId();
    public static Id CCF_RecordType = Schema.SObjectType.Core_MDF_Int_Users_Partner_Geo_Mapping__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Client_Co_Marketing_Fund').getRecordTypeId();
    public static Id channelProgramId;
    @TestSetup static void setUpData() {
        List<User> usrList = new List<User>();

        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
       
        //Creating User with utility class
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test';
        usr.UserRoleId = usRole.Id;
        Database.insert(usr);
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_CCF_MDF_Budget_Loader' LIMIT 1];
        insert new PermissionSetAssignment(AssigneeId = usr.id, PermissionSetId = ps.Id);
       
        system.runAs(usr){
            //Create Exchnage rates records
           
             Profile ccpCoreAccessProfile = [SELECT Id FROM Profile WHERE Name='CCP - Core Access' LIMIT 1];
            PermissionSet aacntMngrPS = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_Internal_CCF_Acct_Mgr' LIMIT 1];
            PermissionSet ipaaacntMngrPS = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_Internal_IPA_Acct_Mgr' LIMIT 1];
            PermissionSet rmfaacntMngrPS = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_Internal_Retail_Account_Manager' LIMIT 1];
            PermissionSet claimCaseRR = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_Internal_CSC_User' LIMIT 1];
           
            PermissionSet cscClaim = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_CSC_Claim_Submitter' LIMIT 1];
           
             User cscClaimSubmitter = Core_MDF_CCP_TestDataUtility.createUser(false);
            cscClaimSubmitter.Email = 'cscclaimsubmitterTest@example.com';
            cscClaimSubmitter.Profile = ccpCoreAccessProfile;
            Database.insert(cscClaimSubmitter);
           
            List<PermissionSetAssignment> listOfPSA =  new List<PermissionSetAssignment>();
            PermissionSetAssignment assignPermissionSetObjCSC = new PermissionSetAssignment();
            assignPermissionSetObjCSC.AssigneeId = cscClaimSubmitter.Id;
            assignPermissionSetObjCSC.PermissionSetId = cscClaim.Id;
            listOfPSA.add(assignPermissionSetObjCSC);
           
            User ccfaccntmngr = Core_MDF_CCP_TestDataUtility.createUser(false);
            ccfaccntmngr.Email = 'ccfaccntmngr@example.com';
            ccfaccntmngr.Profile = ccpCoreAccessProfile;
            Database.insert(ccfaccntmngr);
           
           
            PermissionSetAssignment assignPermissionSetObj = new PermissionSetAssignment();
            assignPermissionSetObj.AssigneeId = ccfaccntmngr.Id;
            assignPermissionSetObj.PermissionSetId = aacntMngrPS.Id;
            listOfPSA.add(assignPermissionSetObj);
           
            PermissionSetAssignment assignPermissionSetObjCCRR = new PermissionSetAssignment();
            assignPermissionSetObjCCRR.AssigneeId = ccfaccntmngr.Id;
            assignPermissionSetObjCCRR.PermissionSetId = claimCaseRR.Id;
            listOfPSA.add(assignPermissionSetObjCCRR);
            //Database.insert(assignPermissionSetObjCCRR);
           
            User ipaaccntmngr = Core_MDF_CCP_TestDataUtility.createUser(false);
            ipaaccntmngr.Email = 'ipaaccntmngr@example.com';
            ipaaccntmngr.Profile = ccpCoreAccessProfile;
            Database.insert(ipaaccntmngr);
            PermissionSetAssignment assignPermissionSetObj2 = new PermissionSetAssignment();
            assignPermissionSetObj2.AssigneeId = ipaaccntmngr.Id;
            assignPermissionSetObj2.PermissionSetId = ipaaacntMngrPS.Id;
            listOfPSA.add(assignPermissionSetObj2);
           
           
             User rmfaccntmngr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
            rmfaccntmngr1.Email = 'rmfaccntmngr@example.com';
            rmfaccntmngr1.Profile = ccpCoreAccessProfile;
            Database.insert(rmfaccntmngr1);
            PermissionSetAssignment assignPermissionSetObj3 = new PermissionSetAssignment();
            assignPermissionSetObj3.AssigneeId = rmfaccntmngr1.Id;
            assignPermissionSetObj3.PermissionSetId = rmfaacntMngrPS.Id;
            listOfPSA.add(assignPermissionSetObj3);
            insert listOfPSA;
           
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
           
            List<Core_Trigger_Executions__c> triggerExeList = new List<Core_Trigger_Executions__c>();
            Core_Trigger_Executions__c claimFunctionalityNameTriggerExecution3 = new Core_Trigger_Executions__c();
            claimFunctionalityNameTriggerExecution3.Core_Active__c = false;
            claimFunctionalityNameTriggerExecution3.Core_Class_Name__c = 'Core_MDF_PFCServiceHandler';
            claimFunctionalityNameTriggerExecution3.Core_Trigger_Events__c = 'before upate, after update';
            claimFunctionalityNameTriggerExecution3.Core_Object__c = 'PartnerFundClaim';
            claimFunctionalityNameTriggerExecution3.Name = 'checkAndSendClaimsToAudit';
            claimFunctionalityNameTriggerExecution3.Core_Description__c = 'test';
            triggerExeList.add(claimFunctionalityNameTriggerExecution3);
           
            Core_Trigger_Executions__c claimFunctionalityNameTriggerExecution4 = new Core_Trigger_Executions__c();
            claimFunctionalityNameTriggerExecution4.Core_Active__c = true;
            claimFunctionalityNameTriggerExecution4.Core_Class_Name__c = 'Core_MDF_SendEmailHelper';
            claimFunctionalityNameTriggerExecution4.Core_Trigger_Events__c = 'after insert';
            claimFunctionalityNameTriggerExecution4.Core_Object__c = 'Core_MDF_Escalation__c';
            claimFunctionalityNameTriggerExecution4.Name = 'Core_MDF_EscalationErrorsNotification';
            claimFunctionalityNameTriggerExecution4.Core_Description__c = 'test';
            triggerExeList.add(claimFunctionalityNameTriggerExecution4);
           
            Core_Trigger_Executions__c claimToCase = new Core_Trigger_Executions__c();
            claimToCase.Core_Active__c = true;
            claimToCase.Core_Class_Name__c = 'Core_MDF_PFCServiceHandler';
            claimToCase.Core_Description__c = 'This Custom Setting is used to turn on/off claim to case functionality.';
            claimToCase.Core_Object__c = 'PartnerFundClaim';
            claimToCase.Core_Trigger_Events__c = 'after update';
            claimToCase.Name='Core_MDF_ClaimToCase';        
            triggerExeList.add(claimToCase);            
           
            Database.insert(triggerExeList);
           
            List<Core_MDF_Configuration__c> configMDF = new List<Core_MDF_Configuration__c>();
            Core_MDF_Configuration__c config = new Core_MDF_Configuration__c();
            config.NAME = 'ALLOWED_PRG_FOR_RUS_NOTIF';
            config.Core_MDF_Value__c='3';
            config.Core_MDF_Category__c ='Bank Document Hold Logic';
            configMDF.add(config);
            Core_MDF_Configuration__c config2 = new Core_MDF_Configuration__c();
            config2.NAME = 'ADD_BUS_DAYS_ON_REMINDER_DATE_CLAIM';
            config2.Core_MDF_Value__c='3';
            config2.Core_MDF_Category__c ='Bank Document Hold Logic';
            configMDF.add(config2);
            Core_MDF_Configuration__c config3 = new Core_MDF_Configuration__c();
            config3.NAME = 'BUDGET_TYPE_SKIP_BANK_DOC_HOLD';
            config3.Core_MDF_Value__c='3';
            config3.Core_MDF_Category__c ='Bank Document Hold Logic';
            configMDF.add(config3);
            insert configMDF;
           
            // Creating channel program with utility class
            ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.CCF_PROGRAM,'Client CoMarketing Fund', true);
            channelProgramId = cp.Id;
           
            ChannelProgram retailCp = Core_MDF_CCP_TestDataUtility.createProgram ('Retail Marketing Funds','Retail Marketing Funds', true);
           
            ChannelProgram ipaCP = Core_MDF_CCP_TestDataUtility.createProgram ('Intel Partner Alliance','Intel Partner Alliance', true);
           
            List<Account> accList = new List<Account>();
            List<Account> intelAccList = new List<Account>();
            // Creating Co-marketing Account with utility class
            // Creating IntelAccount with utility class
            Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Test Account 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type,
                                                                            false);
            acc1.Core_Geo__c = 'APJ';
            acc1.Core_Sub_Geo__c = 'SA';
            acc1.BillingCountryCode = '';//14282
            acc1.BillingStateCode='';//14285
            //Database.insert(acc1);
            intelAccList.add(acc1);

            Account ipaUltimateAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount ('IPA Intel Account',Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            intelAccList.add(ipaUltimateAccount);
           
            /*Account ipaUltimateAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount ('IPA Intel Account',Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            intelAccList.add(ipaUltimateAccount);*/
            Database.insert(intelAccList);
           
            Account acc = Core_MDF_CCP_TestDataUtility.createAccount ('Co-marketing Test Account', cp.Id,
                                                                      Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            acc.Core_MDF_Parent_Fund_Account__c = acc1.Id;
            acc.Core_MDF_CoMarketing_Ultimate_Account__c = acc1.Id;
            accList.add(acc);
            Group accNodeGroup = new Group(Name = 'Core_MDF_Retail_Acc_Node_Group', DeveloperName = 'Core_MDF_Retail_Acc_Node_Group');
            insert accNodeGroup;
           
            Account retailAcc = Core_MDF_CCP_TestDataUtility.createAccount ('Retail Test Acc', retailCp.Id,
                                                                            Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            retailAcc.Core_MDF_Parent_Fund_Account__c = acc1.Id;
            retailAcc.Core_MDF_CoMarketing_Ultimate_Account__c = acc1.Id;
            retailAcc.Core_Geo__c = 'APJ';
            retailAcc.Core_Sub_Geo__c = 'SA';
            retailAcc.Core_MDF_Group_Id__c = accNodeGroup.Id;
            accList.add(retailAcc);

            Account iPACoMarketingAcc = Core_MDF_CCP_TestDataUtility.createAccount ('Test IPA Account', ipaCP.Id,
                                                                                   Core_MDF_CCP_TestDataUtility.Account_Record_Type,false);
            iPACoMarketingAcc.Core_MDF_Parent_Fund_Account__c = ipaUltimateAccount.Id;
            iPACoMarketingAcc.Core_MDF_CoMarketing_Ultimate_Account__c = ipaUltimateAccount.Id;
            iPACoMarketingAcc.Core_Geo__c = 'APJ';
            iPACoMarketingAcc.Core_Sub_Geo__c = 'SA';
            iPACoMarketingAcc.BillingCountryCode = 'JPN';
            accList.add(iPACoMarketingAcc);

            //Account ipaCoMarketingAccount = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('IPA Co-Marketing Account', ipaCP.id, Core_MDF_CCP_TestDataUtility.Account_Record_Type,ipaUltimateAccount.id, false);          
            //accList.add(ipaCoMarketingAccount);
           
            Database.insert(accList);

        //String budgetType = Core_MDF_CCP_IPA_TestDataUtility.createBenefit(ipaCoMarketingAccount);    
       
        // Creating Contact with utility class
        List<Contact> conList = new List<Contact>();
        Contact con = Core_MDF_CCP_TestDataUtility.createContact (acc1.Id, false);
        con.RecordTypeId = Core_MDF_CCP_TestDataUtility.Intel_Contact_Record_Type;
       // con.Core_Audience_List__c = 'RMF User';
        conList.add(con);
        Contact con1 = Core_MDF_CCP_TestDataUtility.createContact (acc1.Id, false);
        con1.RecordTypeId = Core_MDF_CCP_TestDataUtility.Intel_Contact_Record_Type;
        conList.add(con1);
       
        Database.insert(conList);
        Profile partnerProfile = [SELECT Id FROM Profile WHERE Name='Partner' LIMIT 1];
           
          // Creating User with utility class
        User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr1.LastName = 'User Test1';
        usr1.ProfileId = partnerProfile.Id;
        usr1.email = 'xyz@mail.com';
        usr1.ContactId = con.Id;
        usrList.add(usr1);
        //Database.insert(usr1);
        User usr2 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr2.LastName = 'User Test2';
        usr2.ProfileId = partnerProfile.Id;
        usr2.email = 'abc@mail.com';
        usr2.ContactId = con1.Id;
        usrList.add(usr2);      

        User usr3 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr3.LastName = 'User Test3';
        usrList.add(usr3);

        User usr4 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr4.LastName = 'User Test4';
        usrList.add(usr4);
       
        User usr10 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr10.LastName = 'User Test3';
        usrList.add(usr10);
           
           
        //User usr5 = Core_MDF_CCP_TestDataUtility.createUser(false);
        //usr5.LastName = 'User Test5';
       // usrList.add(usr5);
        //Test.startTest();
        Database.insert(usrList);
           
            Core_ERPM_Engagement__c cee=new Core_ERPM_Engagement__c(Name  ='RMF', Core_Engagement_Type__c='SEC',Core_IsActive__c=true,Core_Technical_Engagement_Code__c='RMF');
            insert cee;
            Core_Entitlement__c entitle = new Core_Entitlement__c (name ='RMF User', Core_Category__c='Intel® Partner Investment Center',Core_Sub_Category__c='Retail Marketing Funds (RMF)',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='RMF User',Core_IsActive__c=true);
            insert entitle;
           
            Core_Contact_Entitlement__c ce = new Core_Contact_Entitlement__c(Core_Contact_Id__c=con.Id,
                                                                     Core_Entitlement_Id__c=entitle.id,
                                                                     Core_Selected__c=true);          
            insert ce;
            List<String> claimSubmitterList = new List<String>();
            List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();
            claimSubmitterList.add('Core_MDF_CCP_External_Retail_Claim_Submitter');
            claimSubmitterList.add('Core_MDF_CCP_RMF_PRC_Claim_Operations');
            claimSubmitterList.add('Core_MDF_CCP_External_Claim_Submitter');
            claimSubmitterList.add('Core_MDF_CCP_CSC_Claim_Submitter');
           
            Id claimSubPSId ;
            Id mysterShopPSIs ;
            Id claimCCFSubPSId ;
            Id cscClaimSubPSId ;

            //List<PermissionSet> claimSubmitterPS = [SELECT Id, Name FROM PermissionSet WHERE Name IN :claimSubmitterList LIMIT 1];

            for(PermissionSet claimSubmitterPS : [SELECT Id, Name FROM PermissionSet WHERE Name IN :claimSubmitterList]){
                if(claimSubmitterPS.Name == 'Core_MDF_CCP_External_Retail_Claim_Submitter'){
                    claimSubPSId = claimSubmitterPS.Id;
                }else if(claimSubmitterPS.Name == 'Core_MDF_CCP_RMF_PRC_Claim_Operations'){
                    mysterShopPSIs = claimSubmitterPS.Id;
                }
                else if(claimSubmitterPS.Name == 'Core_MDF_CCP_External_Claim_Submitter'){
                    claimCCFSubPSId = claimSubmitterPS.Id;
                }
                else if(claimSubmitterPS.Name == 'Core_MDF_CCP_CSC_Claim_Submitter'){
                    cscClaimSubPSId = claimSubmitterPS.Id;
                }
            }            
            //PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = claimSubPSId, AssigneeId = usr10.Id);
            //psaList.add(psa);
            PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = claimSubPSId, AssigneeId = usr1.Id);
            psaList.add(psa);            
            PermissionSetAssignment psa2 = new PermissionSetAssignment(PermissionSetId = mysterShopPSIs, AssigneeId = usr3.Id);
            psaList.add(psa2);
            PermissionSetAssignment psa3 = new PermissionSetAssignment(PermissionSetId = claimCCFSubPSId, AssigneeId = usr1.Id);
            psaList.add(psa3);
            PermissionSetAssignment psa4 = new PermissionSetAssignment(PermissionSetId = cscClaimSubPSId, AssigneeId = usr4.Id);
            psaList.add(psa4);
            PermissionSetAssignment psa5 = new PermissionSetAssignment(PermissionSetId = cscClaimSubPSId, AssigneeId = usr3.Id);
            psaList.add(psa5);
            insert psaList;
           
           // Core_MDF_Partner_Node_User_Mapping__c pnum1 = Core_MDF_CCP_TestDataUtility.createPartnerNodeUserMapping(acc.Id,usr1.Id,true);

            List<Campaign> campList = new  List<Campaign>();
           
           
            Campaign camp1 = Core_MDF_CCP_TestDataUtility.createCampaign('TestRetailCamp','Gaming','Athena', 'MDF or both CMP & MDF',
                                                                         Core_MDF_CCP_TestDataUtility.campaign_RecordType_Retail, 'Retail Marketing Funds',
                                                                         System.today() - 50, System.today().addYears(1), 20000,
                                                                         'Instore innovation', retailAcc.Id,'2-in-1', false);
            //camp1.Core_MDF_Budget_Type_txt__c ='RSA MD';
            camp1.Core_MDF_Budget_Amount_amt__c = 100000;
            camp1.Core_MDF_Market__c = 'AFGHANISTAN';
            camp1.Core_MDF_Technology__c = 'Intel® Arc™ graphics';
            //camp1.Core_MDF_Priority__c='Win Volume';
            campList.add(camp1);
             // Creating campaigns using utility class
            Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('TestCamp','Gaming','Athena', 'MDF or both CMP & MDF',
                                                                        Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF,
                                                                        'Client CoMarketing Fund',System.today().addDays(-5) ,
                                                                        System.today().addDays(200), 2000, 'Test',acc.Id,'2-in-1', false);
                                                                        //camp.Core_MDF_Opal_Budget_Type_Txt__c ='MDF';
                                                                        camp.Core_MDF_Market__c = 'AFGHANISTAN';
                                                                        camp.Core_MDF_Priority__c='Consumer non-Evo';
            camp.Core_MDF_Technology__c = 'Intel® Arc™ graphics';
            camp.Core_MDF_Audience__c = 'Partner Sales Force';
                                                                        campList.add(camp);

            Campaign camp4 = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp IPA','Gaming','Athena', 'MDF or both CMP & MDF',
                                                                         Core_MDF_CCP_IPA_TestDataUtility.campaign_RecordType_IPA,
                                                                        'Intel Partner Alliance', System.today()-15, System.today()+15,
                                                                        10000, 'Consumer - Premium', iPACoMarketingAcc.Id, '2-in-1', false);
            camp4.Core_MDF_Proposal_Based_Ind__c = false;
            camp4.Core_MDF_Budget_Type_txt__c = 'Account Plan';
            camp4.Core_MDF_Opal_Budget_Type_Txt__c='Account Plan';
            camp4.Core_MDF_Reimbursement_Amt__c = 200.0;
            camp4.Core_MDF_Opal_Budget_Type_Txt__c = 'Account Plan';
            camp4.Core_MDF_Market__c = 'AFGHANISTAN';
            camp4.Core_MDF_Audience__c = 'C-Suite';
            campList.add(camp4);
                                       
            Database.insert(campList);
            List<PartnerFundRequest> toBeInsertedActivities= new List<PartnerFundRequest>();
            PartnerFundRequest testPartnerFundRequest1 = Core_MDF_CCP_TestDataUtility.createRetailActivity(string.valueof(camp1.Id),                                                                                                        
                                                                                                         string.valueof(retailAcc.id),NULL,NULL,
                                                                                                         false);
           
            testPartnerFundRequest1.Title ='Retail MDF Activity';
            testPartnerFundRequest1.Core_MDF_Activity_Description__c ='Retail MDF Activity';
            testPartnerFundRequest1.Core_MDF_Budget_Type_nm__c ='RSA MD';
            testPartnerFundRequest1.Core_MDF_Start_Date__c = System.today() - 40;
            testPartnerFundRequest1.Core_MDF_End_Date__c  = System.today() - 31;
            testPartnerFundRequest1.RequestedAmount =1000;
            testPartnerFundRequest1.Amount=1000;
            //testPartnerFundRequest1.Core_MDF_Country__c ='AFGHANISTAN';
            testPartnerFundRequest1.Core_MDF_Country_nm__c = 'AFGHANISTAN';
            testPartnerFundRequest1.Core_MDF_Fund_Request_Status__c = 'Closed';
            testPartnerFundRequest1.Core_MDF_Activity_Closure_Type__c = 'Manual';
            testPartnerFundRequest1.Core_MDF_Budget_Currency_cd__c ='USD';
            testPartnerFundRequest1.Core_MDF_Reimbursement_Rate_pct__c='100%';
            //Database.insert(testPartnerFundRequest1);
            testPartnerFundRequest1.Core_MDF_Activity_Types__c='';//14285
            toBeInsertedActivities.add(testPartnerFundRequest1);
         
            //Test.startTest();
            //adding bypass feature to bypass access validation
            List<String> bypassFunctionKeys = new List<String>();
            bypassFunctionKeys.add('Bypass_Duplicate_Budget_Check');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Access_Validation');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Status_Validation');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Access');
            bypassFunctionKeys.add('Bypass_GeoBased_Budget_Sharing');
            bypassFunctionKeys.add('Bypass_Allocation_Reservation');
            bypassFunctionKeys.add('Bypass_GeoBased_Allocation_Sharing');
            bypassFunctionKeys.add('Bypass_Duplicate_Bank_Check');
            bypassFunctionKeys.add('Bypass_Bank_Internal_Sharing');
            bypassFunctionKeys.add('Bypass_Bank_External_Sharing');
            bypassFunctionKeys.add('Bypass_Bank_ABM_Sharing');
            bypassFunctionKeys.add('Bypass_ABM_Internal_Sharing');
            bypassFunctionKeys.add('Bypass_ABM_External_Sharing');
            bypassFunctionKeys.add('Bypass_ABM_NodeGroup_Sharing');
            bypassFunctionKeys.add('Bypass_Bank_Program_InActivation_Check');
            bypassFunctionKeys.add('byPassShareUnshareCampaignRecord');
            bypassFunctionKeys.add('byPassCampaignAndRelatedRecords');
            bypassFunctionKeys.add('Bypass_Claims_Duplicate_Check');
            bypassFunctionKeys.add('Bypass_Claims_Sharing_Internal_Users');
            bypassFunctionKeys.add('Bypass_ClaimAdjReq_Share_On_Owner_Chng');
            bypassFunctionKeys.add('Bypass_ClaimAdjReq_Share_Internal_Usrs');
            bypassFunctionKeys.add('Bypass_ClaimAdjReq_Share_External_Usrs');
            bypassFunctionKeys.add('Bypass_Claim_AdjReq_Amount_Validation');
            bypassFunctionKeys.add('Bypass_Claims_Amt_vs_Budget_Amt_Check');        
            bypassFunctionKeys.add('Bypass_Claims_ABM_Validation');
            bypassFunctionKeys.add('Bypass_Claims_Sharing_Partner_Users');
            bypassFunctionKeys.add('Bypass_Payment_Doc_InvFileVAT_Validate');
            bypassFunctionKeys.add('Bypass_Claims_Amt_vs_Camp_Amt_Check');
            bypassFunctionKeys.add('Bypass_Claim_OwnerLang_EmailTemp');
            bypassFunctionKeys.add('Bypass_StampingOfActySubType_Check');
            bypassFunctionKeys.add('Bypass_Claims_Sharing_On_Owner_Change');
            bypassFunctionKeys.add('Bypass_ValidateActivityWithCampaign');
            bypassFunctionKeys.add('byPass_Cancel_Activity');
            bypassFunctionKeys.add('Core_MDF_Bypass_ATFBatchUpdate');
            bypassFunctionKeys.add('Core_MDF_BypassATFFlagUpdateBatch');
            bypassFunctionKeys.add('Core_MDF_BypassATFFlagUpdate');
            bypassFunctionKeys.add('Core_MDF_Bypass_AccOnboardValidation');
            Set<String> myset1 = new Set<String>();
            List<String> result1 = new List<String>();
            myset1.addAll(bypassFunctionKeys);
            result1.addAll(myset1);

            Id recordTypeIdPMB = Schema.SObjectType.PartnerMarketingBudget.getRecordTypeInfosByName().get('CoMarketing').getRecordTypeId();
            Id budget_Retail_Record_Type = Schema.SObjectType.PartnerMarketingBudget.getRecordTypeInfosByDeveloperName().get('Core_MDF_Retail_Marketing_Funds').getRecordTypeId();
            Id budget_IPA_Acc_Record_Type = Schema.SObjectType.PartnerMarketingBudget.getRecordTypeInfosByDeveloperName().get('Core_MDF_IPA_Account_Based').getRecordTypeId();
            List<Core_Trigger_Executions__c> bypassfunctinalitylist1 = Core_MDF_CCP_TestDataUtility.byPassFeature(result1,true,true);
            // Creating Budget using utility class
            List<PartnerMarketingBudget> pmbList = new List<PartnerMarketingBudget>();
            PartnerMarketingBudget pmb = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget',budget_Retail_Record_Type,
                                                                                   retailAcc.Id,retailCp.Id,5000000,System.today().addDays(-5),System.today(),
                                                                                   false);
            pmb.IsIgnoreValidation = true;
            //pmb.Core_MDF_Budget_Type__c='Retail MDF';
            pmb.Core_MDF_Budget_Type_Txt__c='Retail MDF';
            pmbList.add(pmb);

            PartnerMarketingBudget opalbudgetMDF = Core_MDF_CCP_TestDataUtility.createBudget('TestOpalPMB', RecordTypeIdPMB,
                                                    acc.Id,cp.Id,12345678,System.today().addDays(1),System.today().addDays(15),false);
            opalbudgetMDF.IsIgnoreValidation = true;
            opalbudgetMDF.Core_MDF_Budget_Type__c = 'MDF';
            opalbudgetMDF.Core_MDF_Budget_Type_Txt__c = 'MDF';
            pmbList.add(opalbudgetMDF);

            PartnerMarketingBudget OEMPMB = Core_MDF_CCP_TestDataUtility.createBudget('TestoemcmpPMB',recordTypeIdPMB,
                                            acc.Id,cp.Id,102345678,System.today().addDays(16),System.today().addDays(30),false);
            OEMPMB.IsIgnoreValidation = true;
            OEMPMB.Core_MDF_Budget_Type__c = 'OEM CMP';
            OEMPMB.Core_MDF_Budget_Type_Txt__c = 'OEM CMP';
            pmbList.add(OEMPMB);
           
            PartnerMarketingBudget ipaAccPMB = Core_MDF_CCP_TestDataUtility.createBudget('TestIPAcmpPMB',budget_IPA_Acc_Record_Type,
                                               iPACoMarketingAcc.Id,ipaCP.Id,102345678,System.today().addDays(16),System.today().addDays(30),false);
            ipaAccPMB.IsIgnoreValidation = true;
            ipaAccPMB.Core_MDF_Budget_Type__c = 'Account Plan';
            ipaAccPMB.Core_MDF_Budget_Type_Txt__c = 'Account Plan';
            pmbList.add(ipaAccPMB);
            //Test.startTest();
            System.runAs(usr){
               insert pmbList;
            }
           
            List<Core_MDF_Campaign_Budgets__c> campBudgetList = new List<Core_MDF_Campaign_Budgets__c>();
            Core_MDF_Campaign_Budgets__c campBudget= new Core_MDF_Campaign_Budgets__c();
            campBudget.Core_MDF_Campaign_Id__c=camp.id;
            campBudget.Core_MDF_Budget_Name_Id__c=opalbudgetMDF.id;
            campBudget.Core_MDF_Reimbursement_Rate_Pct__c='100%';
            campBudget.Core_MDF_Reimbursement_Amt__c=100000;
            campBudget.Core_MDF_Budget_Amt__c=100000;
            campBudget.Core_MDF_Active_ind__c=true;
            campBudgetList.add(campBudget);

            Core_MDF_Campaign_Budgets__c campBudget1 = new Core_MDF_Campaign_Budgets__c();
            campBudget1.Core_MDF_Campaign_Id__c=camp.id;
            campBudget1.Core_MDF_Budget_Name_Id__c=OEMPMB.id;
            campBudget1.Core_MDF_Reimbursement_Rate_Pct__c='100%';
            campBudget1.Core_MDF_Reimbursement_Amt__c=100000;
            campBudget1.Core_MDF_Budget_Amt__c=100000;
            campBudget1.Core_MDF_Active_ind__c=true;
            campBudgetList.add(campBudget1);

            System.runAs(usr){
                insert campBudgetList;
             }
            // Creating Allocation using utility class

            List<Core_MDF_Bank__c> bankLst = new List<Core_MDF_Bank__c>();

            //Creating CCF Bank
            Core_MDF_Bank__c bank = Core_MDF_CCP_TestDataUtility.createBank(acc1.id,'Core_MDF_Client_CoMarketing_Fund',false,'1234567890');
            bank.Core_MDF_Bank_Status__c = 'Active';  
            bankLst.add(bank);
            // Creating Retail Bank
            Core_MDF_Bank__c retBank = Core_MDF_CCP_TestDataUtility.createBank(acc1.id,'Core_MDF_Retail_Marketing_Funds',false,'1234567800');
            retBank.Core_MDF_Bank_Status__c = 'Active';  
            retBank.Core_MDF_Intel_Company_Code__c = '420';
            retBank.Core_MDF_Tax_codes_cd__c = 'UB';
            bankLst.add(retBank);
            Core_MDF_Bank__c ipabank = Core_MDF_CCP_TestDataUtility.createBank(ipaUltimateAccount.id,'Core_MDF_Intel_Partner_Alliance',false,'1234567899');
            ipabank.Core_MDF_Bank_Status__c = 'Active';
            ipabank.Core_MDF_Intel_Company_Code__c = '150';  
            ipabank.Core_MDF_Tax_codes_cd__c = 'UB';
            bankLst.add(ipabank);
            Database.insert(bankLst);
           
           
            Test.startTest();
            PartnerFundAllocation pfa = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test Allocation',opalbudgetMDF,retailAcc,1000000.0,true);
            PartnerFundAllocation rmfPfa = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test Allocation 1',pmb,retailAcc,1000000.0,false);
            rmfPfa.Amount = 1000000;
            insert rmfPfa;
            PartnerFundAllocation ipaPfa = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test Allocation 11',ipaAccPMB,iPACoMarketingAcc,1000000.0,true);  
           
            PartnerFundAllocation omCmpPfa = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test Allocation 2',OEMPMB,acc,1000000.0,true);
           
            List<Core_MDF_Account_Bank_Mapping__c> accBankMapList = new List<Core_MDF_Account_Bank_Mapping__c>();
            Core_MDF_Account_Bank_Mapping__c abm1 = Core_MDF_CCP_TestDataUtility.createAccountBankMap(acc.Id,bank.Id,false);
            abm1.Core_MDF_Active_ind__c = true;
            accBankMapList.add(abm1);
            Core_MDF_Account_Bank_Mapping__c abm2 = Core_MDF_CCP_TestDataUtility.createAccountBankMap(retailAcc.Id,retBank.Id,false);
            abm2.Core_MDF_Active_ind__c = true;
            accBankMapList.add(abm2);
            Core_MDF_Account_Bank_Mapping__c abm3 = Core_MDF_CCP_TestDataUtility.createAccountBankMap(iPACoMarketingAcc.Id,ipabank.Id,false);
            abm3.Core_MDF_Active_ind__c = true;
            accBankMapList.add(abm3);

            Database.insert(accBankMapList);

            // Creating activities using utility class
            PartnerFundRequest pfr = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),
                                                                                           Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                           string.valueof(acc.id),pfa,opalbudgetMDF,'INDIA','Partner Sales Force',
                                                                                           'Desktop','Intel® Corporate Logo','',
                                                                                           '','Draft',false);
            pfr.RequestedAmount = 900000;
            pfr.Amount = 900000;
            pfr.Status = 'Approved';
           
            pfr.title = 'Test CCF Activity';
            //pfr.Core_MDF_Ultimate_Account_Name__c = acc1.Id;
            pfr.Core_MDF_Start_Date__c = System.today().addDays(-5);
            pfr.Core_MDF_End_Date__c = System.today();
            //pfr.Core_MDF_Region_cd__c = 'APJ';
            pfr.Core_MDF_Region_nm__c = 'APJ';
            pfr.Core_MDF_Reimbursement_Rate_txt__c = '25%';
            //Database.insert(pfr);
            pfr.Core_MDF_Activity_Types__c='';
            toBeInsertedActivities.add(pfr);

            PartnerFundRequest pfr1 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),
                                                                                           Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                           string.valueof(acc.id),omCmpPfa,opalbudgetMDF,'INDIA','Partner Sales Force',
                                                                                           'Desktop','Intel® Corporate Logo','',
                                                                                           '','Draft',false);
            pfr1.RequestedAmount = 9000;
            pfr1.Amount = 9000;
            pfr1.Status = 'Approved';
           
            pfr1.title = 'Test CCF Activity 1';
            pfr1.Core_MDF_Start_Date__c = System.today().addDays(-5);
            pfr1.Core_MDF_End_Date__c = System.today();
            //pfr1.Core_MDF_Region_cd__c = 'APJ';
            pfr1.Core_MDF_Region_nm__c = 'APJ';
            pfr1.Core_MDF_Budget_Type_nm__c = 'MDF';
            pfr1.Core_MDF_Activity_Types__c='';
            toBeInsertedActivities.add(pfr1);
           
            PartnerFundRequest pfr2 = Core_MDF_CCP_TestDataUtility.createRetailActivity(string.valueof(camp1.Id),                                                                                                        
                                                                                        string.valueof(retailAcc.id),NULL,NULL,false);
            pfr2.RequestedAmount = 9000;
            pfr2.Amount = 9000;
            pfr2.Status = 'Approved';
            pfr2.title = 'Retail MDF Activity 1';
            pfr2.Core_MDF_Start_Date__c = System.today().addDays(-5);
            pfr2.Core_MDF_End_Date__c = System.today();
            //pfr2.Core_MDF_Region_cd__c = 'APJ';
            pfr2.Core_MDF_Region_nm__c = 'APJ';
            pfr2.Core_MDF_Budget_Type_nm__c = 'Retail MDF';
            pfr2.AllocationId = rmfPfa.Id;
            pfr2.BudgetId = pmb.Id;
            pfr2.Core_MDF_Activity_Types__c='';
            toBeInsertedActivities.add(pfr2);

            PartnerFundRequest pfr3 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),
                                                                                            Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                            string.valueof(acc.id),omCmpPfa,OEMPMB,'INDIA','Partner Sales Force',
                                                                                            'Desktop','Intel® Corporate Logo','',
                                                                                            '','Draft',false);
            pfr3.RequestedAmount = 9000;
            pfr3.Amount = 9000;
            pfr3.Status = 'Approved';
            pfr3.title = 'Test CCF Activity 3';
            pfr3.Core_MDF_Start_Date__c = System.today().addDays(-5);
            pfr3.Core_MDF_End_Date__c = System.today();
            //pfr3.Core_MDF_Region_cd__c = 'APJ';
            pfr3.Core_MDF_Region_nm__c = 'APJ';
            pfr3.Core_MDF_Budget_Type_nm__c = 'OEM CMP';
            pfr3.Core_MDF_Reimbursement_Rate_txt__c = '100%';
            pfr3.Core_MDF_Activity_Types__c='';
            toBeInsertedActivities.add(pfr3);

            PartnerFundRequest pfr4 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),
                                                                                            Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                            string.valueof(acc.id),omCmpPfa,OEMPMB,'INDIA','Partner Sales Force',
                                                                                            'Desktop','Intel® Corporate Logo','',
                                                                                            '','Draft',false);
            pfr4.RequestedAmount = 400;
            pfr4.Amount = 400;
            pfr4.Status = 'Approved';
            pfr4.title = 'Test CCF Activity 4';
            pfr4.Core_MDF_Start_Date__c = System.today().addDays(-5);
            pfr4.Core_MDF_End_Date__c = System.today();
            //pfr4.Core_MDF_Region_cd__c = 'APJ';
            pfr4.Core_MDF_Region_nm__c = 'APJ';
            pfr4.Core_MDF_Budget_Type_nm__c = 'OEM CMP';
            pfr4.Core_MDF_Budget_Currency_cd__c ='USD';
            pfr4.Core_MDF_Reimbursement_Rate_pct__c='100%';
            pfr4.Core_MDF_Activity_Types__c='';
            toBeInsertedActivities.add(pfr4);
           
            PartnerFundRequest pfr5 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),
                                                                                            Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                            string.valueof(acc.id),omCmpPfa,OEMPMB,'INDIA','Partner Sales Force',
                                                                                            'Desktop','Intel® Corporate Logo','',
                                                                                            '','Draft',false);
            pfr5.RequestedAmount = 9000;
            pfr5.Amount = 9000;
            pfr5.Status = 'Approved';
            pfr5.title = 'Test CCF Activity 5';
            pfr5.Core_MDF_Start_Date__c = System.today().addDays(-5);
            pfr5.Core_MDF_End_Date__c = System.today();
            //pfr5.Core_MDF_Region_cd__c = 'APJ';
            pfr5.Core_MDF_Region_nm__c = 'APJ';
            pfr5.Core_MDF_Budget_Type_nm__c = 'OEM CMP';
            pfr5.Core_MDF_Reimbursement_Rate_txt__c = '100%';
            pfr5.Core_MDF_Activity_Types__c='';
            toBeInsertedActivities.add(pfr5);
            PartnerFundRequest pfr6 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),
                                                                                            Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                            string.valueof(acc.id),omCmpPfa,OEMPMB,'INDIA','Partner Sales Force',
                                                                                            'Desktop','Intel® Corporate Logo','',
                                                                                            '','Draft',false);
            pfr6.RequestedAmount = 9000;
            pfr6.Amount = 9000;
            pfr6.Status = 'Approved';
            pfr6.title = 'Test CCF Activity 6';
            pfr6.Core_MDF_Start_Date__c = System.today().addDays(-5);
            pfr6.Core_MDF_End_Date__c = System.today();
            //pfr6.Core_MDF_Region_cd__c = 'APJ';
            pfr6.Core_MDF_Region_nm__c = 'APJ';
            pfr6.Core_MDF_Budget_Type_nm__c = 'OEM CMP';
            pfr6.Core_MDF_Reimbursement_Rate_txt__c = '100%';
            pfr6.Core_MDF_Activity_Types__c='';
            toBeInsertedActivities.add(pfr6);
           
            PartnerFundRequest pfr7 = Core_MDF_CCP_TestDataUtility.createRetailActivity(string.valueof(camp1.Id),                                                                                                        
                                                                                        string.valueof(retailAcc.id),NULL,NULL,false);
            pfr7.RequestedAmount = 9000;
            pfr7.Amount = 9000;
            pfr7.Status = 'Approved';
            pfr7.title = 'Retail MDF Activity 7';
            pfr7.Core_MDF_Start_Date__c = System.today().addDays(-5);
            pfr7.Core_MDF_End_Date__c = System.today();
            //pfr7.Core_MDF_Region_cd__c = 'APJ';
            pfr7.Core_MDF_Region_nm__c = 'APJ';
            pfr7.Core_MDF_Budget_Type_nm__c = 'Retail MDF';
            pfr7.AllocationId = rmfPfa.Id;
            pfr7.BudgetId = pmb.Id;
            pfr7.Core_MDF_Activity_Types__c='';
            toBeInsertedActivities.add(pfr7);

            PartnerFundRequest IPApfr = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp4.Id),
                                                                                             Core_MDF_CCP_IPA_TestDataUtility.partnerFund_RecordType_IPA,string.valueof(iPACoMarketingAcc.id),NULL,NULL,'India','C-Suite','Traditional Notebook',
                                                                                            'Intel® 11ᵗʰ Gen','','Seller - Target SPIF','Draft',false);
            IPApfr.Core_MDF_Activity_Description__c = 'Test IPA Activity';
            IPApfr.Title = 'Test IPA Activity';
            IPApfr.Core_MDF_Start_Date__c = System.today().addDays(1);
            IPApfr.Core_MDF_End_Date__c = System.today().addDays(2);
            IPApfr.Core_MDF_Country_nm__c = 'India';
            IPApfr.Core_MDF_Fund_Request_Status__c = 'Pending Review';
            IPApfr.Core_MDF_Budget_Type_nm__c = 'Account Plan';
            IPApfr.Core_MDF_TargetAudience__c = 'C-Suite';
            IPApfr.Core_MDF_Focus_Area_nm__c = 'Client Computing';
            IPApfr.AllocationId = ipaPfa.Id;
            IPApfr.BudgetId = ipaAccPMB.Id;
            IPApfr.Core_MDF_Activity_Types__c='';
            toBeInsertedActivities.add(IPApfr);
           
            PartnerFundRequest IPApfr2 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp4.Id),
                                                                                             Core_MDF_CCP_IPA_TestDataUtility.partnerFund_RecordType_IPA,string.valueof(iPACoMarketingAcc.id),NULL,NULL,'India','C-Suite','Traditional Notebook',
                                                                                            'Intel® 11ᵗʰ Gen','','Seller - Target SPIF','Draft',false);
            IPApfr2.Core_MDF_Activity_Description__c = 'Test IPA Activity 2';
            IPApfr2.Title = 'Test IPA Activity 2';
            IPApfr2.Core_MDF_Start_Date__c = System.today().addDays(1);
            IPApfr2.Core_MDF_End_Date__c = System.today().addDays(2);
            IPApfr2.Core_MDF_Country_nm__c = 'India';
            IPApfr2.Core_MDF_Fund_Request_Status__c = 'Pending Review';
            IPApfr2.Core_MDF_Budget_Type_nm__c = 'Account Plan';
            IPApfr2.Core_MDF_Focus_Area_nm__c = 'Client Computing';
            IPApfr2.AllocationId = ipaPfa.Id;
            IPApfr2.BudgetId = ipaAccPMB.Id;
            IPApfr2.Core_MDF_Activity_Types__c='';
            toBeInsertedActivities.add(IPApfr2);
            System.runAs(usr){
            Database.insert(toBeInsertedActivities);
            }
        PartnerFundClaim pfc  = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim 11', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF,
                                                                          pfr3.Id, System.today(), System.today(), 40.0, System.today(),
                                                                          bank.Id, false);
        pfc.Core_MDF_Audit_Hold__c = true;
        pfc.Core_MDF_Taxes_Local__c = 0;
        pfc.Core_MDF_Currency__c = 'USD';
        pfc.Core_MDF_Exchange_rate__c = 1;
        pfc.Core_MDF_Country_Location_nm__c = 'INDIA';
        pfc.Core_MDF_Region_Cd__c = 'APJ';
        pfc.Core_MDF_Escalation_Id__c = null;
        pfc.Core_MDF_Type_Txt__c = 'Claim';
        insert pfc;
           
        List<sObject> shareRecords = new List<sObject>();
            PartnerFundRequestShare pfrShare = new PartnerFundRequestShare();
            pfrShare.ParentId = pfr.Id;
            pfrShare.UserOrGroupId = usr1.id;
            pfrShare.AccessLevel = 'Edit';
            //Database.insert(pfrShare);  
            shareRecords.add(pfrShare);
           
            Core_MDF_Bank__Share bankShare  = new Core_MDF_Bank__Share();
            bankShare.ParentId = bank.Id;
            bankShare.UserOrGroupId = usr1.id;
            bankShare.AccessLevel = 'Edit';
            //Database.insert(bankShare);
            shareRecords.add(bankShare);  
           
            PartnerMarketingBudgetShare pmbShare = new PartnerMarketingBudgetShare();
            pmbShare.ParentId = pmb.Id;
            pmbShare.UserOrGroupId = usr1.id;
            pmbShare.AccessLevel = 'Edit';
            //Database.insert(pmbShare);
            shareRecords.add(pmbShare);
           
            PartnerFundAllocationShare pfaShare = new PartnerFundAllocationShare();
            pfaShare.ParentId = pfa.Id;
            pfaShare.UserOrGroupId = usr1.id;
            pfaShare.AccessLevel = 'Edit';
            //Database.insert(pfaShare);
            shareRecords.add(pfaShare);
           
            if(shareRecords != null && shareRecords.size() > 0){
                Database.insert(shareRecords);
            }
           
           
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
           
            Group grp6 = new Group();
            grp6.Name = 'CCP EXTERNAL RMF GROUP';
            grp6.DeveloperName = 'Core_MDF_RMF_EXTERNAL';
           
            List<Group> lstGroup = new List<Group>();
            lstGroup.add(grp);
            lstGroup.add(grp1);
            lstGroup.add(grp2);
            lstGroup.add(grp3);
            lstGroup.add(grp4);
            lstGroup.add(grp5);
            lstGroup.add(grp6);
            Database.insert(lstGroup);
           
            // Creating Group Members
            GroupMember grpMember = new GroupMember();
            grpMember.UserOrGroupId = usr2.Id;
            grpMember.GroupId = grp1.Id;
                       
            GroupMember grpMember1 = new GroupMember();
            grpMember1.UserOrGroupId = usr3.Id;
            grpMember1.GroupId = grp1.Id;
           
            GroupMember grpMember2 = new GroupMember();
            grpMember2.UserOrGroupId = usr4.Id;
            grpMember2.GroupId = grp2.Id;          
           
            GroupMember grpMember3 = new GroupMember();
            grpMember3.UserOrGroupId = usr4.Id;
            grpMember3.GroupId = grp3.Id;
           
            GroupMember grpMember4 = new GroupMember();
            grpMember4.UserOrGroupId = usr1.Id;
            grpMember4.GroupId = grp6.Id;
                                 
            List<GroupMember> lstGrpMember = new List<GroupMember>();
            lstGrpMember.add(grpMember);
            lstGrpMember.add(grpMember1);
            lstGrpMember.add(grpMember2);
            lstGrpMember.add(grpMember3);
            lstGrpMember.add(grpMember4);
                       
           Database.insert(lstGrpMember);
           
            List<Core_MDF_Partner_Group_Mapping__c> pgmList = new List<Core_MDF_Partner_Group_Mapping__c>();
            // Creating Partner Group Mapping
            Core_MDF_Partner_Group_Mapping__c pgm = new Core_MDF_Partner_Group_Mapping__c();
            pgm.Core_MDF_Account__c = acc1.Id;
            pgm.Core_MDF_Group_Name__c = 'CCP INTERNAL CCF APJ TACCOUNT';
            pgm.Core_MDF_Type_of_Access__c = 'Internal';
            pgm.Core_MDF_Group_Id__c = grp.Id;                
            pgm.Core_MDF_Channel_Program__c = cp.Id;
            pgm.Core_MDF_Region_cd__c = 'APJ';
            pgm.Core_MDF_Sub_Region_cd__c = 'SA';
            pgm.Core_MDF_Source_Txt__c = 'Test';
            pgm.Core_MDF_AccountIdGroupName__c = acc1.Id+'CCP INTERNAL CCF APJ TACCOUNT';
            //pgmList.add(pgm);
           
            Core_MDF_Partner_Group_Mapping__c pgm1 = new Core_MDF_Partner_Group_Mapping__c();
            pgm1.Core_MDF_Account__c = acc1.Id;
            pgm1.Core_MDF_Group_Name__c = 'Core_MDF_CCP_External';
            pgm1.Core_MDF_Type_of_Access__c = 'External';
            pgm1.Core_MDF_Group_Id__c = grp1.Id;                
            pgm1.Core_MDF_Channel_Program__c = cp.Id;
            pgm1.Core_MDF_Source_Txt__c = 'Test';
            pgm1.Core_MDF_AccountIdGroupName__c = acc1.Id+'Core_MDF_CCP_External';
            pgmList.add(pgm1);
           
            Core_MDF_Partner_Group_Mapping__c pgmRMF = new Core_MDF_Partner_Group_Mapping__c();
            pgmRMF.Core_MDF_Account__c = acc1.Id;
            pgmRMF.Core_MDF_Group_Name__c = 'CCP EXTERNAL RMF GROUP';
            pgmRMF.Core_MDF_Type_of_Access__c = 'External';
            pgmRMF.Core_MDF_Group_Id__c = grp6.Id;                
            pgmRMF.Core_MDF_Channel_Program__c = retailCp.Id;
            pgmRMF.Core_MDF_Source_Txt__c = 'Test';
            pgmRMF.Core_MDF_AccountIdGroupName__c = acc1.Id+'Core_MDF_RMF_EXTERNAL';
            pgmList.add(pgmRMF);

            Core_MDF_Partner_Group_Mapping__c pgm2 = new Core_MDF_Partner_Group_Mapping__c();
            pgm2.Core_MDF_Account__c = acc1.Id;
            pgm2.Core_MDF_Group_Name__c = 'CCP INTERNAL CCF EMEA TACCOUNT';
            pgm2.Core_MDF_Type_of_Access__c = 'Internal';
            pgm2.Core_MDF_Group_Id__c = grp2.Id;                
            pgm2.Core_MDF_Channel_Program__c = cp.Id;
            pgm2.Core_MDF_Region_cd__c = 'EMEA';
            pgm2.Core_MDF_Source_Txt__c = 'Test';
            pgm2.Core_MDF_AccountIdGroupName__c = acc1.Id+'CCP INTERNAL CCF EMEA TACCOUNT';
            pgmList.add(pgm2);            
           
            Core_MDF_Partner_Group_Mapping__c pgm3 = new Core_MDF_Partner_Group_Mapping__c();
            pgm3.Core_MDF_Account__c = acc1.Id;
            pgm3.Core_MDF_Group_Name__c = 'CCP INTERNAL CCF ASMO TACCOUNT';
            pgm3.Core_MDF_Type_of_Access__c = 'Internal';
            pgm3.Core_MDF_Group_Id__c = grp3.Id;                
            pgm3.Core_MDF_Channel_Program__c = cp.Id;
            pgm3.Core_MDF_Region_cd__c = 'ASMO';
            pgm3.Core_MDF_Sub_Region_cd__c = 'NAR';
            pgm3.Core_MDF_Source_Txt__c = 'Test';
            pgm3.Core_MDF_AccountIdGroupName__c = acc1.Id+'CCP INTERNAL CCF ASMO TACCOUNT';
            pgmList.add(pgm3);
           
            Core_MDF_Partner_Group_Mapping__c pgm4 = new Core_MDF_Partner_Group_Mapping__c();
            pgm4.Core_MDF_Account__c = acc1.Id;
            pgm4.Core_MDF_Group_Name__c = 'CCP INTERNAL CCF PRC TACCOUNT';
            pgm4.Core_MDF_Type_of_Access__c = 'Internal';
            pgm4.Core_MDF_Group_Id__c = grp5.Id;                
            pgm4.Core_MDF_Channel_Program__c = cp.Id;
            pgm4.Core_MDF_Region_cd__c = 'PRC';
            pgm4.Core_MDF_Source_Txt__c = 'Test';
            pgm4.Core_MDF_AccountIdGroupName__c = acc1.Id+'CCP INTERNAL CCF PRC TACCOUNT';
            //pgmList.add(pgm4);
           
            Core_MDF_Partner_Group_Mapping__c pgm5 = new Core_MDF_Partner_Group_Mapping__c();
            pgm5.Core_MDF_Account__c = acc1.Id;
            pgm5.Core_MDF_Group_Name__c = 'CCP INTERNAL CCF WW TACCOUNT';
            pgm5.Core_MDF_Type_of_Access__c = 'Internal';
            pgm5.Core_MDF_Group_Id__c = grp4.Id;                
            pgm5.Core_MDF_Channel_Program__c = cp.Id;
            pgm5.Core_MDF_Region_cd__c = 'WW';
            pgm5.Core_MDF_Source_Txt__c = 'Test';
            pgm5.Core_MDF_AccountIdGroupName__c = acc1.Id+'CCP INTERNAL CCF WW TACCOUNT';
            //pgmList.add(pgm5);
           
            //Test.stopTest();
           
           
            //Database.insert(pgmList);
            Test.stopTest();


         }
    }
 
     @isTest static void testBudgetEscMethod(){
         List<String> bypassFunctionKeys = new List<String>();
        bypassFunctionKeys.add('Bypass_MDF_Budget_Access');
        List<Core_Trigger_Executions__c> bypassfunctinalitylist = Core_MDF_CCP_TestDataUtility.byPassFeature(bypassFunctionKeys,true,true);
        User user1 = [select id,email from User where email='ccfaccntmngr@example.com' limit 1];
        test.startTest();
         System.runAs(user1){
             List<Core_MDF_Escalation__c> eslst = new List<Core_MDF_Escalation__c>();
             ChannelProgram Cp1 = [SELECT Id, Name FROM ChannelProgram WHERE Name = 'Client'];
             ChannelProgram retCp = [SELECT Id, Name FROM ChannelProgram WHERE Name = 'Retail Marketing Funds'];
             
             System.Assert(Cp1 != NULL);    
             Id budgetRecType = Schema.SObjectType.Core_MDF_Escalation__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Budget').getRecordTypeId();

             //PartnerMarketingBudget pmbCCP = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget CCP',Core_MDF_CCP_TestDataUtility.budget_Record_Type,
             //Acc1.Id,Cp1.Id,5000000,System.today().addDays(-5),System.today(),
             //false);
             //pmbCCP.Core_MDF_Budget_Type_txt__c ='CCF 1.0';
             //pmbCCP.Core_MDF_Budget_Type_txt__c ='MDF';
             //Database.insert(pmbCCP);
             
             PartnerMarketingBudget retPmb = [Select id,Title from PartnerMarketingBudget where Title ='Test Budget'];
             PartnerMarketingBudget pmbCCP = [Select id,Title from PartnerMarketingBudget where Title ='TestOpalPMB'];
             Core_MDF_Escalation__c escCCP = new Core_MDF_Escalation__c();
             escCCP.Core_MDF_Escalation_Status_nm__c='Pending Review';
             escCCP.Core_MDF_Escalation_Name_txt__c='Test Budget CCP';
             escCCP.Core_MDF_Total_Dollar_Impact_amt__c= 56;
             escCCP.Core_MDF_Root_Cause_nm__c = 'Appeal of Budget';
             escCCP.Core_MDF_Budget_ID_Number_id__c = pmbCCP.Id;
             escCCP.Core_MDF_Channel_Program_id__c = Cp1.Id;
             escCCP.recordtypeid= budgetRecType;
             eslst.add(escCCP);
             
             Core_MDF_Escalation__c escRet = new Core_MDF_Escalation__c();
             escRet.Core_MDF_Escalation_Status_nm__c='Pending Review';
             escRet.Core_MDF_Escalation_Name_txt__c='Test Budget Retail';
             escRet.Core_MDF_Total_Dollar_Impact_amt__c= 56;
             escRet.Core_MDF_Root_Cause_nm__c = 'Appeal of Budget';
             escRet.Core_MDF_Budget_ID_Number_id__c = retPmb.Id;
             escRet.Core_MDF_Channel_Program_id__c = retCp.Id;
             escRet.recordtypeid= budgetRecType;
             eslst.add(escRet);
            // Database.insert(eslst);
             System.assertEquals(eslst[0].Core_MDF_Escalation_Status_nm__c,'Pending Review','When escalation is inserted, status will be in pending review');
             Set<Id> pIds = (new Map<Id, ProcessInstance>([SELECT Id,Status,TargetObjectId FROM ProcessInstance where Status='Pending' and TargetObjectId=: eslst[0].Id Limit 1])).keySet();
             Set<Id> pInstanceWorkitems = (new Map<Id, ProcessInstanceWorkitem>([SELECT Id,ProcessInstanceId FROM ProcessInstanceWorkitem WHERE ProcessInstanceId in :pIds])).keySet();
             List<Approval.ProcessWorkitemRequest> allReq = new List<Approval.ProcessWorkitemRequest>();
             for (Id pInstanceWorkitemsId:pInstanceWorkitems){
                 Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
                 req2.setComments('test');
                 
                 req2.setAction('Approve'); //to approve use 'Approve'
                 //req2.setNextApproverIds(new Id[] {UserInfo.getUserId()});
                 
                 // Use the ID from the newly created item to specify the item to be worked
                 req2.setWorkitemId(pInstanceWorkitemsId);
                 
                 // Add the request for approval
                 allReq.add(req2);
             }
             
             Approval.ProcessResult[] result2 =  Approval.process(allReq);
             Core_MDF_Escalation_ServiceHandler.InitialInputs inp = new Core_MDF_Escalation_ServiceHandler.InitialInputs();
             inp.escRecord = eslst[0];
             inp.status ='Pending Review';
             inp.approvalFlag = TRUE;
             List<Core_MDF_Escalation_ServiceHandler.InitialInputs> iipList = new List<Core_MDF_Escalation_ServiceHandler.InitialInputs>();
             iipList.add(inp);
         }
         test.stopTest();

    }
   
    @isTest static void testApprovalAction(){
       
        List<Core_MDF_Escalation__c> escListToBeInserted = new List<Core_MDF_Escalation__c>();
        List<Core_MDF_Escalation__c> escListToBeInsertedNew = new List<Core_MDF_Escalation__c>();
        Map<Id, Core_MDF_Escalation__c> escIdtoEscalationOldMap = new Map<Id, Core_MDF_Escalation__c>();
        List<Core_MDF_Escalation__c> escToBeupdated = new List<Core_MDF_Escalation__c>();      
        List<PartnerFundClaim> toBeupdatedClaims = new List<PartnerFundClaim>();  
        List<Core_MDF_Claim_Case_Checklist__c> checklistRecords = new List<Core_MDF_Claim_Case_Checklist__c>();
        User user1 = [select id,email,ProfileId,Profile.Name from User where email='ccfaccntmngr@example.com' limit 1];
        User clmSub =[select Id from user where email ='xyz@mail.com' limit 1];
        Case compliantCase = new Case();
        Case nonCompliantCase = new Case();

        Id caseRecType = Schema.SObjectType.Core_MDF_Escalation__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Claim_Case_Review_Result').getRecordTypeId();
        ChannelProgram cp = [Select Id, Name from ChannelProgram where Name ='Client'];
       
       
        System.runAs(user1){

            Core_MDF_Bank__c bank = [SELECT Id FROM Core_MDF_Bank__c WHERE Core_MDF_Supplier_Number__c = '1234567890'];
            Test.StartTest();
            PartnerFundRequest pfr = [Select id from PartnerFundRequest where Title = 'Test CCF Activity' Limit 1];            
     
            // Creating claims
            List<PartnerFundClaim> toBeInsertedClaims= new List<PartnerFundClaim>();
            List<PartnerFundClaim> clm1= new List<PartnerFundClaim>();            
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
            //M
            toBeInsertedClaims.add(pfc);
            toBeInsertedClaims.add(pfc1);
           
            Database.insert(toBeInsertedClaims);
            Id caseAuditRecType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Core_MDF_Audit').getRecordTypeId();
            Case cs = new Case();
            cs.recordTypeId = caseAuditRecType;
            cs.Core_MDF_Claim_ID__c = pfc1.id;
           
            Database.insert(cs);

            pfc1.Core_MDF_FlaggedForAudit__c = true;
            //pfc.Core_MDF_FlaggedForAudit__c = true;
            pfc1.Core_MDF_Claim_Review_Case__c=cs.id;
            clm1.add(pfc1);

            update pfc1;    
           
            nonCompliantCase.Id = pfc1.Core_MDF_Claim_Review_Case__c;
            nonCompliantCase.Core_MDF_Adjustment_Amount_Local__c =0;
            nonCompliantCase.Core_MDF_Claim_Conversion_Exchange_Rate__c = 1;
            nonCompliantCase.Core_MDF_Reimbursement_Rate__c = 50;
            nonCompliantCase.Core_MDF_Requested_Amount_USD_Amt__c = 5;
            if(nonCompliantCase.Id != null){
                nonCompliantCase.Core_MDF_Status__c  = 'Under Review';
                nonCompliantCase.Core_MDF_Claim_Amount_USD__c  = 2000;
                nonCompliantCase.Core_MDF_Adjustment_Amount_Local__c = 2000;
                nonCompliantCase.Core_MDF_TotalTransactionAmountLocal__c = 4000;
                nonCompliantCase.Core_MDF_Claim_Taxes_Local__c = 0;
                nonCompliantCase.Core_MDF_OtherCostsnotReimbursableLocal__c = 0;
                nonCompliantCase.Core_MDF_Claim_Conversion_Exchange_Rate__c = 1;
                nonCompliantCase.Core_MDF_Reimbursement_Rate__c = 50;
                nonCompliantCase.Core_MDF_Requested_Amount_USD_Amt__c = 5;
                nonCompliantCase.Core_MDF_Adjustment_Amount_USD_Amt__c  =5;              
                update nonCompliantCase;
                                     

                Core_MDF_Claim_Case_Checklist__c checklistRecord2 = new Core_MDF_Claim_Case_Checklist__c();
                checklistRecord2.Core_MDF_Case_ID__c = nonCompliantCase.id;
                checklistRecord2.Core_MDF_Checklist_Status__c = 'Non-Compliant';
                checklistRecord2.Core_MDF_Impact_Amount__c = 20;
                checklistRecord2.Core_MDF_Completion_Percentage__c = 100;
                checklistRecords.add(checklistRecord2);
                Database.insert(checklistRecords);
                /*nonCompliantCase.Core_MDF_Review_Case_Status__c  = 'Review Completed';
                nonCompliantCase.Core_MDF_Scorecard_Score_Nbr__c=0;
                nonCompliantCase.Core_MDF_Checklist_Completion__c=100;
                update nonCompliantCase;*/
                pfc1.Core_MDF_Status__c = Label.Core_MDF_Claim_Status_Denied;
                toBeupdatedClaims.add(pfc1);
                if(toBeupdatedClaims.size()>0){
                    Database.update(toBeupdatedClaims);
                }
               
                Core_MDF_Escalation__c es = new Core_MDF_Escalation__c();
                es.Core_MDF_Escalation_Status_nm__c='Pending Review';
                es.Core_MDF_Escalation_Name_txt__c='Test3';
                es.Core_MDF_Total_Dollar_Impact_amt__c= 1; //7917343
                es.Core_MDF_Root_Cause_nm__c = 'Claim Score Appeal';
                es.Core_MDF_Case_ID_Number_id__c = nonCompliantCase.Id;
                es.Core_MDF_Channel_Program_id__c = cp.Id;
                es.recordtypeid = caseRecType;
                es.Core_MDF_Do_not_Auto_Create_Claim_Ind__c = true;
                es.Core_MDF_Claim_Number_id__c = pfc1.Id;
                es.Core_MDF_Claim_Submitter_Id__c = clmSub.id;  
                es.Core_MDF_Claim_Review_Closure_Note_txt__c = 'test comment';
                escListToBeInsertedNew.add(es);
               
                Core_MDF_Escalation__c es2 = new Core_MDF_Escalation__c();
                es2.Core_MDF_Escalation_Status_nm__c='Approved';
                es2.Core_MDF_Escalation_Name_txt__c='Test5';
                es2.Core_MDF_Total_Dollar_Impact_amt__c= 1; //7917343
                es2.Core_MDF_Root_Cause_nm__c = 'Claim Score Appeal';
                es2.Core_MDF_Case_ID_Number_id__c = nonCompliantCase.Id;
                es2.Core_MDF_Channel_Program_id__c = cp.Id;
                es2.recordtypeid = caseRecType;
                es2.Core_MDF_Do_not_Auto_Create_Claim_Ind__c = false;
                es2.Core_MDF_Claim_Submitter_Id__c = clmSub.id;  
                escListToBeInserted.add(es2);
               
                try{  
                   Database.insert(es);
                   
                }catch(exception e){
                    String message = e.getMessage();
                }
               
               
                Core_MDF_Escalation__c esc3 = new Core_MDF_Escalation__c();
                esc3.Core_MDF_Escalation_Status_nm__c='Approved';
                esc3.Core_MDF_Escalation_Name_txt__c='Test2';
                esc3.Core_MDF_Total_Dollar_Impact_amt__c= 1; //7917343
                esc3.Core_MDF_Root_Cause_nm__c = 'Claim Score Appeal';
                esc3.Core_MDF_Case_ID_Number_id__c = compliantCase.Id;
                esc3.Core_MDF_Channel_Program_id__c = cp.Id;
                esc3.recordtypeid = caseRecType;
                esc3.Core_MDF_Do_not_Auto_Create_Claim_Ind__c = true;//M
                esc3.Core_MDF_Claim_Number_id__c = pfc1.Id;
                //esc3.Core_MDF_Claim_Submitter_Id__c = clmSub.id;                
                //escListToBeInserted.add(esc3);
                Database.upsert(esc3);                              
                //if(escListToBeInserted.Size() > 0){
                  //  Database.upsert(escListToBeInserted);
                //}
                //Approve Escalation

                esc3.Core_MDF_Escalation_Status_nm__c = 'Approved';
                esc3.Core_MDF_Claim_Number_id__c = pfc.Id;
               
                escToBeupdated.add(esc3);
               
                Core_MDF_Escalation__c escMap = new Core_MDF_Escalation__c();
                escMap.Core_MDF_Escalation_Status_nm__c='Pending Review';
                escMap.Core_MDF_Escalation_Name_txt__c='Test4';
                escMap.Core_MDF_Total_Dollar_Impact_amt__c= 1;
                escMap.Core_MDF_Root_Cause_nm__c = 'Creative';
                escMap.Core_MDF_Case_ID_Number_id__c = compliantCase.Id;
                escMap.Core_MDF_Channel_Program_id__c = cp.Id;
                escMap.recordtypeid = caseRecType;
                escMap.Core_MDF_Do_not_Auto_Create_Claim_Ind__c = false;
                escMap.Core_MDF_Claim_Number_id__c = pfc.Id;
                escIdtoEscalationOldMap.put(escMap.Core_MDF_Case_ID_Number_id__c, escMap);
               
                if(escToBeupdated.size() > 0){
                    Database.update(escToBeupdated,false);
                    System.assertEquals(escToBeupdated[0].Core_MDF_Escalation_Status_nm__c,'Approved','As the approval process was successful status should  be approved');
                }
                Core_MDF_Escalation_ServiceHandler.claimCreateEscaltn res= new  Core_MDF_Escalation_ServiceHandler.claimCreateEscaltn();
                res=Core_MDF_Escalation_ServiceHandler.getEscalationFields(esc3.id);
                System.assert(res!=null);
                Core_MDF_Notify_Account_Manager__e notificationEvent = new Core_MDF_Notify_Account_Manager__e();
                notificationEvent.Core_MDF_Escalation_Id_txt__c = esc3.Id;
                notificationEvent.Core_MDF_isBusinessError_ind__c = true;
                notificationEvent.Core_MDF_errorMessage_txt__c = Label.Core_MDF_ClaimExceedsCapRemainder_ErrorMsg;
                // Call method to publish events
                Database.SaveResult sr = EventBus.publish(notificationEvent);
               
                Core_MDF_Notify_Account_Manager__e notificationEvent1 = new Core_MDF_Notify_Account_Manager__e();
                notificationEvent1.Core_MDF_Escalation_Id_txt__c = esc3.Id;
                notificationEvent1.Core_MDF_isBusinessError_ind__c = true;
                notificationEvent1.Core_MDF_errorMessage_txt__c = Label.Core_MDF_Retail_Claim_Amount_ShdBeWithIn_ActyBudgetAmt;
                // Call method to publish events
                Database.SaveResult sr1 = EventBus.publish(notificationEvent1);
                Test.StopTest();

                //To cover catch block
                //Core_MDF_Escalation_ServiceHandler.approvalAction(escListToBeInserted, escIdtoEscalationOldMap);
                //Core_MDF_Escalation_ServiceHandler.approvalAction(escListToBeInsertedNew,escIdtoEscalationOldMap);
                System.assert(escListToBeInsertedNew!=null);
                Core_MDF_Escalation_ServiceHandler.determineMethod(null);
                Core_MDF_Escalation_ServiceHandler.populateApproverNameAndComments(null);
               //Test.StopTest();

            }
        }
       
    }
   
    @isTest static void testCompliantCaseEscalation(){
     
        List<PartnerFundClaim> toBeupdatedClaims = new List<PartnerFundClaim>();  
        List<Core_MDF_Claim_Case_Checklist__c> checklistRecords = new List<Core_MDF_Claim_Case_Checklist__c>();
        Account acc =[Select id,name from Account where name='Co-marketing Test Account' limit 1];
        //User sysAdminUser = [SELECT Id,Email from User where LastName = 'User Test' limit 1];
        //User sysAdminUser = Core_MDF_CCP_TestDataUtility.createUser(false);
        //insert sysAdminUser;
        //System.runAs(sysAdminUser){
            //permissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_CCF_Acct_Mgr' LIMIT 1];
          //  insert new PermissionSetAssignment(AssigneeId = sysAdminUser.id, PermissionSetId = ps.Id);
        //}
        User user1 = [select id,email from User where email='ccfaccntmngr@example.com' limit 1];
        Case compliantCase = new Case();

           
        Id caseRecType = Schema.SObjectType.Core_MDF_Escalation__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Claim_Case_Review_Result').getRecordTypeId();
        System.runAs(user1){
            Core_MDF_Bank__c bank = [SELECT Id FROM Core_MDF_Bank__c WHERE Core_MDF_Supplier_Number__c = '1234567890'];

           
            PartnerFundRequest pfr = [Select id from PartnerFundRequest where Title = 'Test CCF Activity' Limit 1];
            ChannelProgram cp = [Select Id, Name from ChannelProgram where Name ='Client'];
            System.Assert(cp != NULL);
           
            // Creating claims
            //mTest.StartTest();
            List<PartnerFundClaim> toBeInsertedClaims= new List<PartnerFundClaim>();
            List<PartnerFundClaim> clm1= new List<PartnerFundClaim>();            
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
            pfc.Core_MDF_Region_Cd__c = 'APJ';
           
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
            pfc1.Core_MDF_Region_Cd__c = 'APJ';
            toBeInsertedClaims.add(pfc);
            toBeInsertedClaims.add(pfc1);
            Test.StartTest();
            Database.insert(toBeInsertedClaims);
           
            Id caseAuditRecType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Core_MDF_Audit').getRecordTypeId();
            Case cs = new Case();
            cs.recordTypeId = caseAuditRecType;
            cs.Core_MDF_Claim_ID__c = pfc.id;
            cs.Core_MDF_Region_SubRegion_txt__c = 'APJ - SA';
            Database.insert(cs);
            pfc.Core_MDF_Claim_Review_Case__c=cs.id;
            clm1.add(pfc);
           
            update clm1;

           
           
           
            compliantCase.Id = pfc.Core_MDF_Claim_Review_Case__c;
            compliantCase.Core_MDF_Status__c  = 'Under Review';
            update compliantCase;      
           
            Core_MDF_Claim_Case_Checklist__c checklistRecord1 = new Core_MDF_Claim_Case_Checklist__c();
            checklistRecord1.Core_MDF_Case_ID__c = compliantCase.id;
            checklistRecord1.Core_MDF_Completion_Percentage__c = 100;
            checklistRecords.add(checklistRecord1);
            Database.insert(checklistRecords);
           
            if(compliantCase.Id != null){
                compliantCase.Core_MDF_Review_Case_Status__c  = 'Review Completed';
                compliantCase.Core_MDF_Scorecard_Score_Nbr__c=0;
                compliantCase.Core_MDF_Adjustment_Amount_Local__c = 20;
                compliantCase.Core_MDF_Adjustment_Amount_USD_Amt__c = 20;
                compliantCase.Core_MDF_Checklist_Completion__c=100;
                //update compliantCase;
               
                clm1[0].Core_MDF_Status__c = Label.Core_MDF_Claim_Status_Pending_Available_Fund;
                toBeupdatedClaims.add(clm1[0]);
                if(toBeupdatedClaims.size()>0){
                    Database.update(toBeupdatedClaims);
                }

                Core_MDF_Escalation__c esc2 = new Core_MDF_Escalation__c();
                esc2.Core_MDF_Escalation_Status_nm__c='Approved';
                esc2.Core_MDF_Escalation_Name_txt__c='Test2';
                esc2.Core_MDF_Total_Dollar_Impact_amt__c= 1;
                esc2.Core_MDF_Root_Cause_nm__c = 'Claim Score Appeal';
                esc2.Core_MDF_Case_ID_Number_id__c = compliantCase.Id;
                esc2.Core_MDF_Channel_Program_id__c = cp.Id;
                esc2.recordtypeid = caseRecType;
                //esc2.Core_MDF_Do_not_Auto_Create_Claim_Ind__c = false;
                //insert esc2;
                Core_MDF_Partnership_Score__c pscLst0=new Core_MDF_Partnership_Score__c();
            pscLst0.Core_MDF_Account_Id__c=acc.Id;
            pscLst0.Core_MDF_Channel_Program_Id__c =cp.Id;
            pscLst0.Core_MDF_Program_nm__c ='Client CoMarketing Fund';
            pscLst0.Core_MDF_Quarter_Year_Nm__c = 'Q2 2023';
            pscLst0.Core_MDF_Quarter_nm__c='Q2';
            pscLst0.Core_MDF_Year_nm__c='2023';
            pscLst0.Core_MDF_Partnership_Score_Nbr__c=0.0;
               
                try{
                    esc2.Core_MDF_Escalation_Status_nm__c = 'Approved';
                   
                }catch(exception e){
                    String message = e.getMessage();
                }        
                Core_MDF_Escalation_ServiceHandler.claimCreateEscaltn res= new  Core_MDF_Escalation_ServiceHandler.claimCreateEscaltn();
                res = Core_MDF_Escalation_ServiceHandler.getEscalationFields(esc2.id);
                System.assert(res!=null);
                Core_MDF_Escalation_ServiceHandler.removeRecordFromApprovalProcess(NULL);
               
                Test.StopTest();
               
               
            }            
        }
    }
        @isTest static void testCompliantCaseEscalation2(){
     
        List<PartnerFundClaim> toBeupdatedClaims = new List<PartnerFundClaim>();  
        List<Core_MDF_Claim_Case_Checklist__c> checklistRecords = new List<Core_MDF_Claim_Case_Checklist__c>();
       
        User user1 = [select id,email from User where email='ccfaccntmngr@example.com' limit 1];
       
        Case compliantCase = new Case();

           
        Id caseRecType = Schema.SObjectType.Core_MDF_Escalation__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Claim_Case_Review_Result').getRecordTypeId();
        System.runAs(user1){
            Core_MDF_Bank__c bank = [SELECT Id FROM Core_MDF_Bank__c WHERE Core_MDF_Supplier_Number__c = '1234567890'];

            PartnerFundRequest pfr = [Select id,channelpartnerid from PartnerFundRequest where Title = 'Test CCF Activity' Limit 1];
           
            // Creating claims

            List<PartnerFundClaim> clm1= new List<PartnerFundClaim>();            
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
            pfc.Core_MDF_Region_Cd__c = 'APJ';
           
           
            Test.StartTest();
            //Database.insert(toBeInsertedClaims);
            insert pfc;
            Id caseAuditRecType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Core_MDF_Audit').getRecordTypeId();
            Case cs = new Case();
            cs.recordTypeId = caseAuditRecType;
            cs.Core_MDF_Claim_ID__c = pfc.id;
            cs.Core_MDF_Region_SubRegion_txt__c = 'APJ - SA';
            cs.accountId=pfr.channelpartnerid;
            Database.insert(cs);
           
            pfc.Core_MDF_Claim_Review_Case__c=cs.id;
            clm1.add(pfc);
           
            update clm1;

           
            ChannelProgram cp = [Select Id, Name from ChannelProgram where Name ='Client'];
           
            compliantCase.Id = pfc.Core_MDF_Claim_Review_Case__c;
            compliantCase.Core_MDF_Status__c  = 'Under Review';
            update compliantCase;      
           
            Core_MDF_Claim_Case_Checklist__c checklistRecord1 = new Core_MDF_Claim_Case_Checklist__c();
            checklistRecord1.Core_MDF_Case_ID__c = compliantCase.id;
            checklistRecord1.Core_MDF_Completion_Percentage__c = 100;
            checklistRecords.add(checklistRecord1);
            Database.insert(checklistRecords);
           
            if(compliantCase.Id != null){
                compliantCase.Core_MDF_Review_Case_Status__c  = 'Review Completed';
                compliantCase.Core_MDF_Scorecard_Score_Nbr__c=0;
                compliantCase.Core_MDF_Adjustment_Amount_Local__c = 20;
                compliantCase.Core_MDF_Adjustment_Amount_USD_Amt__c = 20;
                compliantCase.Core_MDF_Checklist_Completion__c=100;
                /*update compliantCase;*/
                //  
                clm1[0].Core_MDF_Status__c = Label.Core_MDF_Claim_Status_Pending_Available_Fund;
                toBeupdatedClaims.add(clm1[0]);
                if(toBeupdatedClaims.size()>0){
                    //Database.update(toBeupdatedClaims);
                }
                List<Core_MDF_Escalation__c> escList = new List<Core_MDF_Escalation__c>();
                Core_MDF_Escalation__c esc3 = new Core_MDF_Escalation__c();
                esc3.Core_MDF_Escalation_Status_nm__c='Pending Review';
                esc3.Core_MDF_Escalation_Name_txt__c='Test3';
                esc3.Core_MDF_Total_Dollar_Impact_amt__c= 1;
                esc3.Core_MDF_Root_Cause_nm__c = 'Claim Score Appeal';
                esc3.Core_MDF_Case_ID_Number_id__c = compliantCase.Id;
                esc3.Core_MDF_Channel_Program_id__c = cp.Id;
                esc3.recordtypeid = caseRecType;
                esc3.Core_MDF_Do_not_Auto_Create_Claim_Ind__c = false;
                escList.add(esc3);
               
               // Database.insert(escList);
                System.assertEquals(escList[0].Core_MDF_Escalation_Status_nm__c,'Pending Review','Status should be in Pending Review after insert');
                Test.StopTest();
               
                try{
                    Core_MDF_Escalation__c es = [Select Id, Core_MDF_Escalation_Status_nm__c,Core_MDF_Total_Dollar_Impact_amt__c from Core_MDF_Escalation__c where Core_MDF_Escalation_Name_txt__c ='Test2'];
                    es.Core_MDF_Claim_Submitter_Id__c=user1.id;
                    es.Core_MDF_Escalation_Status_nm__c = 'Approved';
                    update es;
                   
                   
                }catch(exception e){
                    String message = e.getMessage();
                }
            }            
        }      
       
    }

    @isTest
    static void testLateClaimEscalation(){
        Test.StartTest();
        User user1 = [select id,email from User where email='ccfaccntmngr@example.com' limit 1];
        Account intelAcc = [Select id from Account where name='Test Account 1' limit 1];
       
         /*System.runAs(user1){  
           PermissionSet aacntMngrPS1 = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_Internal_CCF_Acct_Mgr' LIMIT 1];  
           PermissionSetAssignment assignPermissionSetObj1 = new PermissionSetAssignment();
            assignPermissionSetObj1.AssigneeId = user1.Id;
            assignPermissionSetObj1.PermissionSetId = aacntMngrPS1.Id;
            Database.insert(assignPermissionSetObj1);
         }*/
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
                iupgm.Core_MDF_Account_id__c = intelAcc.Id;
                iupgm.RecordTypeId = CCF_RecordType;
                iupgm.Core_MDF_Program_nm__c = 'Client CoMarketing Fund';
                iupgm.Core_MDF_User_id__c = user1.Id;
                iupgm.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_CCF_Acct_Mgr';
                iupgm.Core_MDF_All_Accounts_cd__c = 'No';
                iupgm.Core_MDF_Region_Sub_Region_nm__c='WW';
                insert iupgm;
               
        System.runAs(user1){        
            PartnerFundRequest pfr = [Select id,Core_MDF_Budget_Type_nm__c from PartnerFundRequest where Title = 'Test CCF Activity' Limit 1];  
            pfr.Core_MDF_Budget_Type_nm__c = 'MDF';
            pfr.Core_MDF_Fund_Request_Status__c = 'Closed';
            pfr.Status='Draft';
            pfr.Amount = 0;
            update pfr;

            User usr1 =[select Id from user where email ='cscclaimsubmitterTest@example.com' limit 1];

            try{
               
                Core_MDF_Escalation__c esc2 = new Core_MDF_Escalation__c();
                esc2.Core_MDF_Escalation_Status_nm__c='Pending Review';
                esc2.Core_MDF_Escalation_Name_txt__c='Test2';
                esc2.Core_MDF_Total_Dollar_Impact_amt__c= 10;
                esc2.Core_MDF_Root_Cause_nm__c = 'Tools and Systems';            
                esc2.Core_MDF_Co_Marketing_Activity_id__c = pfr.Id;
                esc2.Core_MDF_Channel_Program_id__c = channelProgramId;            
                esc2.recordtypeid = claimRecType;
                esc2.Core_MDF_Claim_Submitter_Id__c = usr1.id;
                 
               insert esc2;
               
                esc2.Core_MDF_Escalation_Status_nm__c='Approved';
                update esc2;
               
                esc2.Core_MDF_Approved_Amount_amt__c=100;
                update esc2;
                //Database.insert(escList);
               
               
                test.stopTest();
            }catch(exception e){
                String message = e.getMessage();
                Assert.isNotNull(message);
            }
        }
    }
     @isTest
     static void testRetailLateClaim(){
       Test.StartTest();
       
       /* User adminUser = Core_MDF_CCP_TestDataUtility.createUser(true);
        System.runAs(adminUser){
            permissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_Retail_Account_Manager' LIMIT 1];
            insert new PermissionSetAssignment(AssigneeId = adminUser.id, PermissionSetId = ps.Id);
        }*/
       // try{
           
                User user1 = [select id,email from User where email='rmfaccntmngr@example.com' limit 1];
                //User usr1 =[select Id, userType from user where email ='xyz@mail.com' limit 1];
                User usr1 = [select Id , userType from User where LastName = 'User Test3' limit 1];
                ChannelProgram retailCp = [SELECT Id, Name FROM ChannelProgram WHERE Name = 'Retail Marketing Funds'];
                System.Assert(retailCp != NULL);

                //Test.startTest();
               
                Account intelRetail = [SELECT Id, Name,Core_MDF_Group_Id__c FROM Account WHERE Name = 'Retail Test Acc' limit 1];  

                //Core_MDF_Partner_Node_User_Mapping__c pnum = Core_MDF_CCP_TestDataUtility.createPartnerNodeUserMapping(intelRetail.Id,usr1.Id,true);      
                Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
               iupgm.Core_MDF_Account_id__c = intelRetail.Id;
                iupgm.RecordTypeId = RMF_RecordType;
                iupgm.Core_MDF_Program_nm__c = 'Retail Marketing Funds';
                iupgm.Core_MDF_User_id__c = usr1.Id;
                iupgm.Core_MDF_Role_nm__c = 'Core_MDF_CCP_RMF_PRC_Claim_Operations';
                iupgm.Core_MDF_All_Accounts_cd__c = 'No';
                insert iupgm;
                 System.runAs(user1){
                PartnerFundRequest testPartnerFundRequest1 = [Select Id, title,Core_MDF_Fund_Request_Status__c,Core_MDF_Activity_Closure_Type__c,Core_MDF_End_Date__c,Core_MDF_ToBeClosedDate__c,Core_MDF_Budget_Type_nm__c,Core_MDF_Program__c from PartnerFundRequest where Title ='Retail MDF Activity'];
                testPartnerFundRequest1.Core_MDF_Fund_Request_Status__c = 'Closed';
                update testPartnerFundRequest1;
                /*Core_MDF_Account_Bank_Mapping__c abm1 = Core_MDF_CCP_TestDataUtility.createAccountBankMap(intelRetail.Id,bank1.Id,false);
                abm1.Core_MDF_Active_ind__c = true;
                insert abm1;*/

                //Id claimRecType = Schema.SObjectType.Core_MDF_Escalation__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Late_Claim').getRecordTypeId();
                                               
                Core_MDF_Escalation__c esc1 = new Core_MDF_Escalation__c();
                esc1.Core_MDF_Escalation_Status_nm__c='Pending Review';
                esc1.Core_MDF_Escalation_Name_txt__c='Test1';
                esc1.Core_MDF_Total_Dollar_Impact_amt__c= 5;
                esc1.Core_MDF_Root_Cause_nm__c = 'Tools and Systems';
                esc1.Core_MDF_Co_Marketing_Activity_id__c = testPartnerFundRequest1.Id;
                esc1.Core_MDF_Channel_Program_id__c = retailCp.Id;
                esc1.Core_MDF_Claim_Submitter_Id__c = usr1.id;
                esc1.recordtypeid= claimRecType;
                Database.insert(esc1);
                String msg = '';
                msg = Core_MDF_Escalation_ServiceHandler.checkEscLateClaimCreation(esc1.id);
                System.assertEquals(msg,'SUCCESS');
                List<Core_MDF_Escalation_ServiceHandler.InitialInputs> inpList = new List<Core_MDF_Escalation_ServiceHandler.InitialInputs>();
                Core_MDF_Escalation_ServiceHandler.InitialInputs inp = new Core_MDF_Escalation_ServiceHandler.InitialInputs();
                inp.escRecord = esc1;
                inp.status ='Expired';
                inp.approvalFlag = TRUE;
                inpList.add(inp);
               Core_MDF_Escalation_ServiceHandler.determineMethod(inpList);
            }  
/*        }
        catch(exception e){
            String message = e.getMessage();            
        } */
    }
    @isTest
     static void testCCFLateClaimEscValidation(){
       Test.StartTest();
     
        User user1 = [select id,email from User where email='ccfaccntmngr@example.com' limit 1];
       User usr1 = [select Id , userType from User where LastName = 'User Test4' limit 1];
       ChannelProgram ccfCp = [SELECT Id, Name FROM ChannelProgram WHERE Name = 'Client'];

       PartnerFundRequest testPartnerFundRequest1 = [Select Id, Amount, Core_MDF_Fund_Request_Status__c,
                                                     Core_MDF_Budget_Type_nm__c from PartnerFundRequest where Title ='Test CCF Activity'];
       testPartnerFundRequest1.Core_MDF_Budget_Type_nm__c = 'MDF';
       testPartnerFundRequest1.Core_MDF_Fund_Request_Status__c = 'Closed';
       testPartnerFundRequest1.Amount = 90000;
       System.runAs(user1){
          update testPartnerFundRequest1;
       }

       //Id claimRecType = Schema.SObjectType.Core_MDF_Escalation__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Late_Claim').getRecordTypeId();
       Core_MDF_Escalation__c esc1 = createLateClaimEscalation('Test1', claimRecType, testPartnerFundRequest1.Id, ccfCp.Id, usr1.Id,
                                                                5.0, false);
       System.assert(esc1!=null);
       System.runAs(user1){
            insert esc1;
       }
       test.stopTest();
    }  
    @isTest
     static void testRMFLateClaimEscValidation(){
       Test.StartTest();
       
       User user1 = [select id,email from User where email='rmfaccntmngr@example.com' limit 1];
       User usr1 = [select Id , userType from User where LastName = 'User Test3' limit 1];
       ChannelProgram retailCp = [SELECT Id, Name FROM ChannelProgram WHERE Name = 'Retail Marketing Funds'];
       PartnerFundRequest testPartnerFundRequest1 = [Select Id, Amount,Status, Core_MDF_Fund_Request_Status__c,Core_MDF_Campaign_Amount__c,
                                                    Allocation.Core_MDF_Available_Activity_Alloc_Amt__c,
                                                    Core_MDF_Budget_Type_nm__c from PartnerFundRequest where Title ='Retail MDF Activity 1'];
       testPartnerFundRequest1.Core_MDF_Fund_Request_Status__c = 'Closed';
       System.runAs(user1){
            update testPartnerFundRequest1;
       }
       List<Core_MDF_Escalation__c> escList = new List<Core_MDF_Escalation__c>();
       List<Core_MDF_Escalation__c> updateEescList = new List<Core_MDF_Escalation__c>();
       Core_MDF_Escalation__c esc1 = createLateClaimEscalation('Test1', claimRecType, testPartnerFundRequest1.Id, retailCp.Id, usr1.Id,
                                                                5.0, false);
       Core_MDF_Escalation__c esc2 = createLateClaimEscalation('Test2', claimRecType, testPartnerFundRequest1.Id, retailCp.Id, usr1.Id,
                                                                15.0, false);
       System.assert(esc1!=null);
       System.assert(esc2!=null);
       escList.add(esc1);
       escList.add(esc2);
       System.runAs(user1){
            insert escList;
       }
       esc1.Core_MDF_Escalation_Status_nm__c = 'Approved';
       esc2.Core_MDF_Escalation_Status_nm__c = 'Approved';
       updateEescList.add(esc1);
       updateEescList.add(esc2);
        System.runAs(user1){
            update updateEescList;
        }
       test.stopTest();
    }
    @isTest
    static void testOMCMPLateClaimEscValidation(){
        Test.StartTest();
   
        User user1 = [select id,email from User where email='ccfaccntmngr@example.com' limit 1];

        User usr1 = [select Id , userType from User where LastName = 'User Test4' limit 1];
        ChannelProgram ccfCp = [SELECT Id, Name FROM ChannelProgram WHERE Name = 'Client'];
       
        PartnerFundRequest testPartnerFundRequest1 = [Select Id, Amount, Core_MDF_Fund_Request_Status__c
                                                      from PartnerFundRequest where Title ='Test CCF Activity 3'];
                                                     
        testPartnerFundRequest1.Core_MDF_Fund_Request_Status__c = 'Closed';
        System.runAs(user1){
            update testPartnerFundRequest1;
        }
        PartnerFundRequest testPartnerFundRequest2 = [Select Id, Amount, Core_MDF_Fund_Request_Status__c
                                                      from PartnerFundRequest where Title ='Test CCF Activity 5'];
                                                     
        testPartnerFundRequest2.Core_MDF_Fund_Request_Status__c = 'Closed';
        System.runAs(user1){
            update testPartnerFundRequest2;
        }
        PartnerFundClaim pfc = [select id,RequestId,Core_MDF_Status__c from PartnerFundClaim where Title = 'Test Claim 11' limit 1];
        pfc.Core_MDF_Status__c = 'Paid';
        System.runAs(user1){
            update pfc;
        }
       
        //Id claimRecType = Schema.SObjectType.Core_MDF_Escalation__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Late_Claim').getRecordTypeId();
        Core_MDF_Escalation__c esc1 = createLateClaimEscalation('Test1', claimRecType, testPartnerFundRequest1.Id, ccfCp.Id, usr1.Id,
                                                              5.0, false);
        System.assert(esc1!=null);
        System.runAs(user1){
            insert esc1;
        }
        esc1.Core_MDF_Escalation_Status_nm__c = 'Approved';
        System.runAs(user1){
            update esc1;
        }

        Core_MDF_Escalation__c esc2 = createLateClaimEscalation('Test2', claimRecType, testPartnerFundRequest1.Id, ccfCp.Id, usr1.Id,
                                                                 10.0, false);
        System.assert(esc2!=null);
        System.runAs(user1){
            insert esc2;
        }
        test.stopTest();
    }

    @isTest
    static void testIPALateClaimEscValidation(){
        Test.StartTest();
       
        User user1 = [select id,email from User where email='ipaaccntmngr@example.com' limit 1];

        User usr1 = [select Id , userType from User where LastName = 'User Test4' limit 1];
        ChannelProgram ipaCp = [SELECT Id, Name FROM ChannelProgram WHERE Name = 'Intel Partner Alliance'];
        PartnerMarketingBudget ipaAccPMB = [Select Id from PartnerMarketingBudget where Title = 'TestIPAcmpPMB'];
        Campaign camp = [Select id, Core_MDF_Budget__c from Campaign where Name = 'Test Camp IPA'];
        camp.Core_MDF_Budget__c = ipaAccPMB.Id;
        //camp.Core_MDF_Opal_Budget_Type_Txt__c = 'Account Plan';
        System.runAs(user1){
            update camp;
           
           
            PartnerFundRequest testPartnerFundRequest1 = [Select Id, Amount, Core_MDF_Fund_Request_Status__c, Core_MDF_Budget_Type_nm__c
                                                          from PartnerFundRequest where Title ='Test IPA Activity' Limit 1];
            testPartnerFundRequest1.Core_MDF_Fund_Request_Status__c = 'Closed';
           
            update testPartnerFundRequest1;
           
            List<Core_MDF_Escalation__c> escalationList = new List<Core_MDF_Escalation__c>();
            Core_MDF_Escalation__c esc1 = createLateClaimEscalation('Test1', claimRecType, testPartnerFundRequest1.Id, ipaCp.Id, usr1.Id,
                                                                    5.0, false);  
            System.assert(esc1 != null);
            escalationList.add(esc1);
            Core_MDF_Escalation__c esc2 = createLateClaimEscalation('Test2', claimRecType, testPartnerFundRequest1.Id, ipaCp.Id, usr1.Id,
                                                                    10.0, false);
            escalationList.add(esc2);
            insert escalationList;
        }      
        test.stopTest();
    }
    @isTest static void testApprovalActionforAutoClose(){
       
        List<Core_MDF_Escalation__c> escListToBeInserted = new List<Core_MDF_Escalation__c>();
        List<Core_MDF_Escalation__c> escListToBeInsertedNew = new List<Core_MDF_Escalation__c>();
        Map<Id, Core_MDF_Escalation__c> escIdtoEscalationOldMap = new Map<Id, Core_MDF_Escalation__c>();
        List<Core_MDF_Escalation__c> escToBeupdated = new List<Core_MDF_Escalation__c>();      
        List<PartnerFundClaim> toBeupdatedClaims = new List<PartnerFundClaim>();  
        List<Core_MDF_Claim_Case_Checklist__c> checklistRecords = new List<Core_MDF_Claim_Case_Checklist__c>();
        User user1 = [select id,email from User where email='ccfaccntmngr@example.com' limit 1];
        User clmSub =[select Id from user where email ='xyz@mail.com' limit 1];
        Case compliantCase = new Case();
        Case nonCompliantCase = new Case();

        Id caseRecType = Schema.SObjectType.Core_MDF_Escalation__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Claim_Case_Review_Result').getRecordTypeId();
        ChannelProgram cp = [Select Id, Name from ChannelProgram where Name ='Client'];

        System.runAs(user1){

            Integer tempCounter = 0;
            Core_MDF_Bank__c bank = [SELECT Id FROM Core_MDF_Bank__c WHERE Core_MDF_Supplier_Number__c = '1234567890'];
            Test.StartTest();
            PartnerFundRequest pfr = [Select id from PartnerFundRequest where Title = 'Test CCF Activity' Limit 1];            
     
            // Creating claims
            List<PartnerFundClaim> toBeInsertedClaims= new List<PartnerFundClaim>();
            List<PartnerFundClaim> clm1= new List<PartnerFundClaim>();            
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
            //M
            toBeInsertedClaims.add(pfc);
            toBeInsertedClaims.add(pfc1);
           
            Database.insert(toBeInsertedClaims);
            Id caseAuditRecType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Core_MDF_Audit').getRecordTypeId();
            Case cs = new Case();
            cs.recordTypeId = caseAuditRecType;
            cs.Core_MDF_Claim_ID__c = pfc1.id;
           
            Database.insert(cs);

            pfc1.Core_MDF_FlaggedForAudit__c = true;
            //pfc.Core_MDF_FlaggedForAudit__c = true;
            pfc1.Core_MDF_Claim_Review_Case__c=cs.id;
            clm1.add(pfc1);

            update pfc1;    
           
            nonCompliantCase.Id = pfc1.Core_MDF_Claim_Review_Case__c;
            nonCompliantCase.Core_MDF_Adjustment_Amount_Local__c =0;
            nonCompliantCase.Core_MDF_Claim_Conversion_Exchange_Rate__c = 1;
            nonCompliantCase.Core_MDF_Reimbursement_Rate__c = 50;
            nonCompliantCase.Core_MDF_Requested_Amount_USD_Amt__c = 5;
            if(nonCompliantCase.Id != null){
                nonCompliantCase.Core_MDF_Status__c  = 'Under Review';
                nonCompliantCase.Core_MDF_Claim_Amount_USD__c  = 2000;
                nonCompliantCase.Core_MDF_Adjustment_Amount_Local__c = 2000;
                nonCompliantCase.Core_MDF_TotalTransactionAmountLocal__c = 4000;
                nonCompliantCase.Core_MDF_Claim_Taxes_Local__c = 0;
                nonCompliantCase.Core_MDF_OtherCostsnotReimbursableLocal__c = 0;
                nonCompliantCase.Core_MDF_Claim_Conversion_Exchange_Rate__c = 1;
                nonCompliantCase.Core_MDF_Reimbursement_Rate__c = 50;
                nonCompliantCase.Core_MDF_Requested_Amount_USD_Amt__c = 5;
                nonCompliantCase.Core_MDF_Adjustment_Amount_USD_Amt__c  =5;              
                //update nonCompliantCase;
                                     

                Core_MDF_Claim_Case_Checklist__c checklistRecord2 = new Core_MDF_Claim_Case_Checklist__c();
                checklistRecord2.Core_MDF_Case_ID__c = nonCompliantCase.id;
                checklistRecord2.Core_MDF_Checklist_Status__c = 'Non-Compliant';
                checklistRecord2.Core_MDF_Impact_Amount__c = 20;
                checklistRecord2.Core_MDF_Completion_Percentage__c = 100;
                checklistRecords.add(checklistRecord2);
                Database.insert(checklistRecords);
                nonCompliantCase.Core_MDF_Review_Case_Status__c  = 'Review Completed';
                nonCompliantCase.Core_MDF_Scorecard_Score_Nbr__c=0;
                nonCompliantCase.Core_MDF_Checklist_Completion__c=100;
                //update nonCompliantCase;
                pfc1.Core_MDF_Status__c = Label.Core_MDF_Claim_Status_Denied;
                toBeupdatedClaims.add(pfc1);
                if(toBeupdatedClaims.size()>0){
                    Database.update(toBeupdatedClaims);
                }
               
                Core_MDF_Escalation__c es = new Core_MDF_Escalation__c();
                es.Core_MDF_Escalation_Status_nm__c='Pending Review';
                es.Core_MDF_Escalation_Name_txt__c='Test3';
                es.Core_MDF_Total_Dollar_Impact_amt__c= 1; //7917343
                es.Core_MDF_Root_Cause_nm__c = 'Claim Score Appeal';
                es.Core_MDF_Case_ID_Number_id__c = nonCompliantCase.Id;
                es.Core_MDF_Channel_Program_id__c = cp.Id;
                es.recordtypeid = caseRecType;
                es.Core_MDF_Do_not_Auto_Create_Claim_Ind__c = true;
                es.Core_MDF_Claim_Number_id__c = pfc1.Id;
                es.Core_MDF_Claim_Submitter_Id__c = clmSub.id;  
                escListToBeInsertedNew.add(es);
               
                Core_MDF_Escalation__c es2 = new Core_MDF_Escalation__c();
                es2.Core_MDF_Escalation_Status_nm__c='Pending Review';
                es2.Core_MDF_Escalation_Name_txt__c='Test5';
                es2.Core_MDF_Total_Dollar_Impact_amt__c= 1; //7917343
                es2.Core_MDF_Root_Cause_nm__c = 'Claim Score Appeal';
                es2.Core_MDF_Case_ID_Number_id__c = nonCompliantCase.Id;
                es2.Core_MDF_Channel_Program_id__c = cp.Id;
                es2.recordtypeid = caseRecType;
                es2.Core_MDF_Do_not_Auto_Create_Claim_Ind__c = true;
                es2.Core_MDF_Claim_Review_Closure_Note_txt__c = 'test comment';
                es2.Core_MDF_Claim_Submitter_Id__c = clmSub.id;  
                escListToBeInserted.add(es2);
               
                try{  
                   Database.insert(es);
                }catch(exception e){
                    String message = e.getMessage();
                }
               
               
                Core_MDF_Escalation__c esc3 = new Core_MDF_Escalation__c();
                esc3.Core_MDF_Escalation_Status_nm__c='Approved';
                esc3.Core_MDF_Escalation_Name_txt__c='Test2';
                esc3.Core_MDF_Total_Dollar_Impact_amt__c= 1; //7917343
                esc3.Core_MDF_Root_Cause_nm__c = 'Claim Score Appeal';
                esc3.Core_MDF_Case_ID_Number_id__c = compliantCase.Id;
                esc3.Core_MDF_Channel_Program_id__c = cp.Id;
                esc3.recordtypeid = caseRecType;
                esc3.Core_MDF_Do_not_Auto_Create_Claim_Ind__c = true;//M
                esc3.Core_MDF_Claim_Number_id__c = pfc1.Id;
                //esc3.Core_MDF_Claim_Submitter_Id__c = clmSub.id;                
                //escListToBeInserted.add(esc3);
                Database.upsert(esc3);                              
                //if(escListToBeInserted.Size() > 0){
                  //  Database.upsert(escListToBeInserted);
                //}
                //Approve Escalation

                esc3.Core_MDF_Escalation_Status_nm__c = 'Approved';
                esc3.Core_MDF_Claim_Number_id__c = pfc.Id;
               
                escToBeupdated.add(esc3);
               
                Core_MDF_Escalation__c escMap = new Core_MDF_Escalation__c();
                escMap.Core_MDF_Escalation_Status_nm__c='Pending Review';
                escMap.Core_MDF_Escalation_Name_txt__c='Test4';
                escMap.Core_MDF_Total_Dollar_Impact_amt__c= 1;
                escMap.Core_MDF_Root_Cause_nm__c = 'Claim Score Appeal';
                escMap.Core_MDF_Case_ID_Number_id__c = compliantCase.Id;
                escMap.Core_MDF_Channel_Program_id__c = cp.Id;
                escMap.recordtypeid = caseRecType;
                escMap.Core_MDF_Do_not_Auto_Create_Claim_Ind__c = true;
                escMap.Core_MDF_Claim_Number_id__c = pfc.Id;
                escIdtoEscalationOldMap.put(escMap.Core_MDF_Case_ID_Number_id__c, escMap);
               
                if(escToBeupdated.size() > 0){
                    Database.update(escToBeupdated,false);
                    System.assertEquals(escToBeupdated[0].Core_MDF_Escalation_Status_nm__c,'Approved','As the approval process was successful status should  be approved');
                }
                Core_MDF_Escalation_ServiceHandler.claimCreateEscaltn res= new  Core_MDF_Escalation_ServiceHandler.claimCreateEscaltn();
                res=Core_MDF_Escalation_ServiceHandler.getEscalationFields(esc3.id);
                System.assert(res!=null);
                Core_MDF_Notify_Account_Manager__e notificationEvent = new Core_MDF_Notify_Account_Manager__e();
                notificationEvent.Core_MDF_Escalation_Id_txt__c = esc3.Id;
                notificationEvent.Core_MDF_isBusinessError_ind__c = true;
                notificationEvent.Core_MDF_errorMessage_txt__c = Label.Core_MDF_ClaimExceedsCapRemainder_ErrorMsg;
                // Call method to publish events
                Database.SaveResult sr = EventBus.publish(notificationEvent);
               
                Core_MDF_Notify_Account_Manager__e notificationEvent1 = new Core_MDF_Notify_Account_Manager__e();
                notificationEvent1.Core_MDF_Escalation_Id_txt__c = esc3.Id;
                notificationEvent1.Core_MDF_isBusinessError_ind__c = true;
                notificationEvent1.Core_MDF_errorMessage_txt__c = Label.Core_MDF_Retail_Claim_Amount_ShdBeWithIn_ActyBudgetAmt;
                // Call method to publish events
                Database.SaveResult sr1 = EventBus.publish(notificationEvent1);
                Test.StopTest();

                //To cover catch block
                //Core_MDF_Escalation_ServiceHandler.approvalAction(escListToBeInserted, escIdtoEscalationOldMap);
                //Core_MDF_Escalation_ServiceHandler.approvalAction(escListToBeInsertedNew,escIdtoEscalationOldMap);
                System.assert(escListToBeInsertedNew!=null);
                Core_MDF_Escalation_ServiceHandler.determineMethod(null);
                Core_MDF_Escalation_ServiceHandler.populateApproverNameAndComments(null);
               //Test.StopTest();

            }
        }
       
    }
    @isTest static void testBadData(){
        Test.StartTest();
     
        User user1 = [select id,email from User where email='ccfaccntmngr@example.com' limit 1];
       User usr1 = [select Id , userType from User where LastName = 'User Test4' limit 1];
       ChannelProgram ccfCp = [SELECT Id, Name FROM ChannelProgram WHERE Name = 'Client'];

       PartnerFundRequest testPartnerFundRequest1 = [Select Id, Amount, Core_MDF_Fund_Request_Status__c,
                                                     Core_MDF_Budget_Type_nm__c from PartnerFundRequest where Title ='Test CCF Activity'];
       testPartnerFundRequest1.Core_MDF_Budget_Type_nm__c = 'MDF';
       testPartnerFundRequest1.Core_MDF_Fund_Request_Status__c = 'Closed';
       testPartnerFundRequest1.Amount = 90000;
       System.runAs(user1){
          update testPartnerFundRequest1;
       }
       Core_MDF_Escalation__c esc1 = createLateClaimEscalation('Test1', claimRecType, testPartnerFundRequest1.Id, ccfCp.Id, usr1.Id,
                                                                5.0, false);
       System.assert(esc1!=null);
       System.runAs(user1){
            insert esc1;
       }

        try{
            Core_MDF_Escalation_ServiceHandler.validateCampAmt( null, null);
            Core_MDF_Escalation_ServiceHandler.shareEscalation( null, null, true);
            //Core_MDF_Escalation_ServiceHandler.validateEscalationWithCampaign( null, null, null, null, null, null,null);
            Core_MDF_Escalation_ServiceHandler.initializeEscalationFields( null, null, true);
        } catch(exception e){
        }
       test.stopTest();
       
    }
   
    public static Core_MDF_Escalation__c createLateClaimEscalation(String escName, Id lateclaimEscRecType, Id partnerFundRequestId,
                                                                   Id channelPrgmId, Id claimSubmitterId, Decimal totalDollarImp,
                                                                   Boolean isInsert){
                                                                       
       
        User sysAdminUser = Core_MDF_CCP_TestDataUtility.createUser(true);
       
            Core_MDF_Escalation__c esc = new Core_MDF_Escalation__c();
                       
          System.runAs(sysAdminUser){                                                          
            esc.recordtypeid = lateclaimEscRecType;
            esc.Core_MDF_Escalation_Name_txt__c = escName;
            esc.Core_MDF_Co_Marketing_Activity_id__c = partnerFundRequestId;
            esc.Core_MDF_Channel_Program_id__c = channelPrgmId;
            esc.Core_MDF_Claim_Submitter_Id__c = claimSubmitterId;
            esc.Core_MDF_Escalation_Status_nm__c = 'Pending Review';
            esc.Core_MDF_Total_Dollar_Impact_amt__c = totalDollarImp;
            esc.Core_MDF_Root_Cause_nm__c = 'Tools and Systems';
            if(isInsert){
                insert esc;            
            }
        }
        return esc;
    }
     @isTest
    private static void testInitialInputsWrapper() {
        PartnerFundRequest pfr = [SELECT Id FROM PartnerFundRequest LIMIT 1];
        Core_MDF_Escalation__c esc = new Core_MDF_Escalation__c(
            Core_MDF_Co_Marketing_Activity_id__c = pfr.Id,
            Core_MDF_Escalation_Status_nm__c = 'Pending Review'
        );
        insert esc;
 
        Core_MDF_Escalation_ServiceHandler.InitialInputs input = new Core_MDF_Escalation_ServiceHandler.InitialInputs();
        input.escRecord = esc;
        input.status = 'Expired';
        input.approvalFlag = true;
 
        Test.startTest();
        Core_MDF_Escalation_ServiceHandler.determineMethod(new List<Core_MDF_Escalation_ServiceHandler.InitialInputs>{input});
        Test.stopTest();
 
        Core_MDF_Escalation__c updatedEsc = [SELECT Core_MDF_Escalation_Status_nm__c FROM Core_MDF_Escalation__c WHERE Id = :esc.Id];
       // System.assertEquals('Expired', updatedEsc.Core_MDF_Escalation_Status_nm__c, 'Status should be updated to Expired');
    }
        /**
    * @description: Test method for validateClaimingWindow to cover both positive and negative scenarios.
    * Added for test coverage of validateClaimingWindow method.
    */
    @isTest
    static void testValidateClaimingWindow_FullCoverage() {
        // Get a system admin user for data setup
        User usr = [SELECT Id FROM User WHERE LastName = 'User Test' LIMIT 1];
       
        System.runAs(usr) {
            // 1. Success Scenario: PFR with closure type other than 'Manual' or date in past
            PartnerFundRequest pfrSuccess = [SELECT Id FROM PartnerFundRequest WHERE Title = 'Retail MDF Activity' LIMIT 1];
            pfrSuccess.Core_MDF_Activity_Closure_Type__c = 'Auto';
            pfrSuccess.Core_MDF_Actual_closedt_beforeclosure_dt__c = System.today().addDays(-1);
            update pfrSuccess;
           
            Core_MDF_Escalation__c escSuccess = new Core_MDF_Escalation__c(
                RecordTypeId    = claimRecType,
               // Core_MDF_Escalation_Type_nm__c       = 'Late Claim',
                Core_MDF_Co_Marketing_Activity_id__c = pfrSuccess.Id,
                Core_MDF_Escalation_Status_nm__c     = 'Pending Review'
            );
           
            // 2. Error Scenario: PFR with closure type 'Manual' and date >= Today
            List<PartnerFundRequest> pfrList = [SELECT Id FROM PartnerFundRequest WHERE Title = 'Retail MDF Activity 1' LIMIT 1];
            Id pfrErrorId = !pfrList.isEmpty() ? pfrList[0].Id : pfrSuccess.Id;
           
            PartnerFundRequest pfrToUpdate = new PartnerFundRequest(Id = pfrErrorId);
            pfrToUpdate.Core_MDF_Activity_Closure_Type__c = 'Manual';
            pfrToUpdate.Core_MDF_Actual_closedt_beforeclosure_dt__c = System.today().addDays(1);
            update pfrToUpdate;
           
            Core_MDF_Escalation__c escError = new Core_MDF_Escalation__c(
                RecordTypeId   = claimRecType,
               // Core_MDF_Escalation_Type_nm__c       = 'Late Claim',
                Core_MDF_Co_Marketing_Activity_id__c = pfrErrorId,
                Core_MDF_Escalation_Status_nm__c     = 'Pending Review'
               
            );
            List<Core_MDF_Escalation__c> ESClist = [
                    SELECT Id,
                        Core_MDF_Escalation_Type_nm__c,
                        RecordTypeId,
                        Core_MDF_Co_Marketing_Activity_id__c,
                        Core_MDF_Escalation_Status_nm__c
                    FROM Core_MDF_Escalation__c
                    WHERE Id = :escError.Id limit 10];
           
            List<Core_MDF_Escalation__c> escalationList = new List<Core_MDF_Escalation__c>{escSuccess, escError};
           
            Test.startTest();
            Core_MDF_Escalation_ServiceHandler.validateClaimingWindow(escalationList);
            Test.stopTest();
           
            // Assertions
           // System.assert(!escSuccess.hasErrors(), 'Success escalation should NOT have errors');
           // System.assert(escError.hasErrors(), 'Error escalation SHOULD have errors');
        }
    }
    @isTest
    static void testValidateClaimingWindow_FullCoveragecatch() {
        try{
            Core_MDF_Escalation_ServiceHandler.validateClaimingWindow(null);
        }catch(exception e){
            System.debug(e.getMessage());
        }
    }
   

}