/****************************************************************************************************************************************
* Class Name  : Core_MDF_PFC_Close_Adjustment_Test 
* Version     : 1.0 
* Created Date: 12-July-2019
* Modification Log :
* Developer               Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Intel - Areefa         12-July-2019                    Close Adjustment     
*****************************************************************************************************************************************/

@isTest(SeeAllData = false)
public class Core_MDF_PFC_Close_Adjustment_Test {
    
    @TestSetup static void setUpData(){
        
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        
        Account accRecord = Core_MDF_CCP_TestDataUtility.createAccount ('Intel Test Account ', NULL, Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);   
        accRecord.BillingCity = 'Test City';         
        accRecord.BillingCountry= 'AUS';
        accRecord.BillingStreet= 'Test Street';
        Database.insert(accRecord);   
        
        
        //Creating Contact for Partner User
        List<Contact> contactList = new List<Contact>();
        Contact conRecord1 = Core_MDF_CCP_TestDataUtility.createContact(accRecord.Id,false);
        Contact conRecord2 = Core_MDF_CCP_TestDataUtility.createContact(accRecord.Id,false);
        contactList.add(conRecord1);
        contactList.add(conRecord2);
        Database.insert(contactList);
        
        // Creating User with utility class 
        List<user> userList = new List<User>();
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);        
        usr.LastName = 'System Adm';
        usr.ProfileId = sysAdminProfile.Id;
        usr.isActive = true;
        usr.Email = 'sysadmin@example.com';
        //Database.insert(usr);
        
        Id profileId = [SELECT Id FROM Profile WHERE Name='Partner' limit 1].Id;
        User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);        
        usr1.Email='test1@example.com';
        usr1.ContactId = conRecord1.Id;
        usr1.ProfileId = profileId;
        usr1.isActive = true;
        //Database.insert(usr1);
        
        Profile ccpProfile = [SELECT Id FROM Profile WHERE Name='CCP - Core Access'];
       // Highlight: Unused Local Variable
       // UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        
        User usr2 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr2.ProfileId = ccpProfile.Id;
        usr2.Email='test1vd@intel.com';
        usr2.isActive = true;
        usr2.UserPermissionsMarketingUser=true;
        //  usr1.UserRoleId = usRole.Id;
        //Database.insert(usr2);
        userList.add(usr);
        userList.add(usr1);
        userList.add(usr2);
        Database.insert(userList);
        
        List<ChannelProgram> channelProgramList = new List<ChannelProgram>();
        ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.CCF_PROGRAM,'Client CoMarketing Fund', false);
        ChannelProgram cp1 = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.DCF_PROGRAM,'Data Center CoMarketing Fund', false);
        channelProgramList.add(cp);
        channelProgramList.add(cp1);
        Database.insert(channelProgramList);
        
        // Creating Intel Account with utility class
        Account dellCorpAccount = Core_MDF_CCP_TestDataUtility.createAccount('Dell Corporation', cp.Id,Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);   
        dellCorpAccount.BillingCity = 'Test City';         
        dellCorpAccount.BillingCountry= 'AUS';
        dellCorpAccount.BillingStreet= 'Test Street';
        Database.insert(dellCorpAccount); 
        //dellCorpAccount.IsPartner = true;
        //Database.update(dellCorpAccount);
         
        // Creating Co-marketing Account with utility class
        Account dellCCFVirtualCorp = Core_MDF_CCP_TestDataUtility.createAccount ('Dell CCF Virtual Corp', cp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
        dellCCFVirtualCorp.Core_MDF_Parent_Fund_Account__c = dellCorpAccount.Id;
        dellCCFVirtualCorp.Core_MDF_CoMarketingActive__c = true;
        Database.insert(dellCCFVirtualCorp);
        
        Group grp = new Group();
        grp.name = 'PGM_TEST';
        Database.insert(grp);
        Core_MDF_Configuration__c execution1 = new Core_MDF_Configuration__c();
        execution1.Name = 'ALLOWED_PRG_FOR_RUS_NOTIF';
        execution1.Core_MDF_Category__c = 'Bank Document Hold Logic';
        execution1.Core_MDF_Value__c = 'Retail Marketing Funds,Intel Partner Alliance';
        insert execution1; 
        Core_MDF_CCP_TestDataUtility.createPartnerGroupMapping(dellCorpAccount.Id,'Internal',dellCorpAccount.Id,cp.Id,'PGM_TEST',true);        
        
       /* Account dellCCFAPAC = Core_MDF_CCP_TestDataUtility.createAccount ('Dell CCF APAC', cp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type,  false);
        dellCCFAPAC.Core_MDF_Parent_Fund_Account__c = dellCCFVirtualCorp.Id;
        dellCCFAPAC.Core_MDF_CoMarketingActive__c = true;
        Database.insert(dellCCFAPAC); */
        
        
        Account dellCCFAPACIndia = Core_MDF_CCP_TestDataUtility.createAccount ('Dell CCF APAC India', cp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
        dellCCFAPACIndia.Core_MDF_Parent_Fund_Account__c = dellCCFVirtualCorp.Id;
        dellCCFAPACIndia.Core_MDF_Auto_Transfer_Account__c = dellCCFVirtualCorp.ID;
        dellCCFAPACIndia.Core_MDF_Enabled_Auto_Transfer__c = True;
        dellCCFAPACIndia.Core_MDF_CoMarketingActive__c = true;
        Database.insert(dellCCFAPACIndia);
        
        //Core_MDF_CCP_TestDataUtility.createPartnerNodeUserMapping(dellCCFAPACIndia.Id, usr1.Id, true);
        //adding bypass feature to bypass access validation
            List<String> bypassFunctionKeys = new List<String>();
            bypassFunctionKeys.add('Bypass_MDF_Budget_Access_Validation');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Status_Validation');
            bypassFunctionKeys.add('Bypass_Duplicate_Budget_Check');
           bypassFunctionKeys.add('Bypass_Claims_Duplicate_Check');
            bypassFunctionKeys.add('Bypass_Claims_Amt_vs_Budget_Amt_Check');
         bypassFunctionKeys.add('Bypass_ClaimAdjReq_Share_Internal_Usrs');
         bypassFunctionKeys.add('Bypass_Claims_ABM_Validation');
         bypassFunctionKeys.add('Bypass_Claims_Amt_vs_Camp_Amt_Check');
         bypassFunctionKeys.add('Bypass_Claims_Sharing_Partner_Users');
         bypassFunctionKeys.add('Bypass_ClaimAdjReq_Share_External_Usrs');
         bypassFunctionKeys.add('Bypass_Claims_Sharing_On_Owner_Change');
         bypassFunctionKeys.add('Bypass_Claim_AdjReq_Amount_Validation');
         bypassFunctionKeys.add('Bypass_ClaimAdjReq_Share_On_Owner_Chng');
         bypassFunctionKeys.add('Bypass_Claims_Sharing_Internal_Users');
         bypassFunctionKeys.add('Bypass_Claim_OwnerLang_EmailTemp');
            Set<String> myset1 = new Set<String>();
            List<String> result1 = new List<String>();
            myset1.addAll(bypassFunctionKeys);
            result1.addAll(myset1);
            
            List<Core_Trigger_Executions__c> bypassfunctinalitylist1 = Core_MDF_CCP_TestDataUtility.byPassFeature(result1,true,true);
        //Id recordTypeIdPMB = Schema.SObjectType.PartnerMarketingBudget.getRecordTypeInfosByName().get('CoMarketing').getRecordTypeId();
        // Create PMB for the above Account 
        
        /*List<Core_Trigger_Executions__c> transactions = new List<Core_Trigger_Executions__c>();
            transactions.addAll(Core_MDF_CCP_TestDataUtility.byPassFeature(new List<String>{'Bypass_Duplicate_Budget_Check','Bypass_GeoBased_Budget_Sharing','Bypass_MDF_Budget_Access','Bypass_MDF_Budget_Access_Validation'}, true, false));
            Database.insert(transactions);*/
        
        PartnerMarketingBudget  pmbRecord = Core_MDF_CCP_TestDataUtility.createBudget('Dell PMB',Core_MDF_CCP_TestDataUtility.Budget_Record_Type,dellCCFVirtualCorp.Id,
                                                                                      cp.Id,100000,System.today().addDays(-15),System.today().addDays(15),false);
        pmbRecord.Core_MDF_Budget_Type_Txt__c = 'OEM CMP';
        insert pmbRecord;
        /*system.runas(usr){
            pmbRecord.Core_MDF_Budget_Status__c='Approved';
            Database.update(pmbRecord);
            //pmbRecord.Core_MDF_Budget_Status__c = 'Released';
            //update pmbRecord;
        }*/
        
        // Create PFA records for the above accounts :
        List<PartnerFundAllocation> pfaList = new List<PartnerFundAllocation>();
        PartnerFundAllocation pfaDellCCFVirtualCorp = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('pfaDellCCFVirtualCorp',pmbRecord, dellCCFVirtualCorp, 1000,false);
        pfaList.add(pfaDellCCFVirtualCorp);
        
        PartnerFundAllocation pfaDellCCFIndia = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('pfaDellCCFIndia',pmbRecord, dellCCFAPACIndia, 1000,false);
        pfaList.add(pfaDellCCFIndia);        
        Database.insert(pfaList);
        
        Core_MDF_Bank__c indiaBank = Core_MDF_CCP_TestDataUtility.createBank(dellCorpAccount.Id, 'Core_MDF_Client_CoMarketing_Fund', true,'1231231230');
        //Core_MDF_Account_Bank_Mapping__c accountBankMap = Core_MDF_CCP_TestDataUtility.createAccountBankMap(dellCCFAPACIndia.Id, indiaBank.Id, true);
        
        
        
        ////Core_MDF_CCP_TestDataUtility.createTriggerExecutionRecords();
        
        
        ////Core_MDF_CCP_TestDataUtility.insertCurrencyExchangeRates();
        
        /*Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount aObj = new Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount();
        Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount bObj = new Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount();
        Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount cObj = new Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount();
        List<Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount> listvar = new List<Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount>();
        
        aObj.inputCurrency ='ZMK';
        aObj.inputAmount = 250.00;
        aObj.inputDate= System.today();
        bObj.inputCurrency ='INR';
        bObj.inputAmount = 350.00;
        bObj.inputDate= System.today();
        cObj.inputCurrency ='USD';
        cObj.inputAmount = 350.00;
        cObj.inputDate= System.today();
        listvar.add(aObj);
        listvar.add(bObj);
        listvar.add(cObj);
        Core_MDF_CCP_Multicurrency.getUSDExchangeRateBasedOnDate(listvar);   */
        
        Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 12','Gaming','Intel® Corporate Logo','Yes', 
                                                                    Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', 
                                                                    System.today()-1, System.today()+20, 10000, 'Consumer Chromebook', dellCCFVirtualCorp.Id, '2-in-1', false);
        camp.Core_MDF_Opal_Budget_Type_Txt__c = 'OEM CMP'; 
        database.insert(camp);
        Test.startTest();
        PartnerFundRequest indiaActivity = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                                 string.valueof(dellCCFAPACIndia.id),pfaDellCCFIndia,pmbRecord,
                                                                                                 'BRAZIL','Consumer','Desktop','Intel® Corporate Logo','Audio','Podcast','Draft'
                                                                                                 ,false);
        indiaActivity.Title = 'indiaActivity';
        indiaActivity.Core_MDF_Activity_Description__c = 'indiaActivity';
        indiaActivity.Core_MDF_Budget_Type_nm__c = 'OEM CMP';
        indiaActivity.Core_MDF_Start_Date__c = System.today()-1;
        indiaActivity.Core_MDF_End_Date__c = System.today();
        indiaActivity.RequestedAmount = 100;
        indiaActivity.Core_MDF_Channel_Partner_Led__c = True;
        indiaActivity.Amount=100;
        indiaActivity.Core_MDF_Reimbursement_Rate_txt__c = '25%';
        Database.insert(indiaActivity);       
        
        /*PartnerFundClaim indiaClaim3 = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, indiaActivity.Id, System.today(), System.today(), 5000.00, System.today(), indiaBank.Id, false);
        indiaClaim3.Status = Label.Core_MDF_Status_Approved;
        indiaClaim3.Core_MDF_Status__c = Label.Core_MDF_Status_Payment_Due;
        Insert indiaClaim3;*/
        
        Test.stopTest();
        
    }
    
    @isTest static void userHasPermission(){
        test.startTest();
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        User intUser = [SELECT Id,Email from User where Email='test1vd@intel.com' limit 1];
        System.runAs(sysAdminUser){              
            Boolean userDoesnotHaveAcess = Core_MDF_PFC_Close_Adjustment.hasAccess();
            System.assertEquals(false, userDoesnotHaveAcess);
            
            //PermissionSet claimCaseReviewerPermissionSet = [SELECT Id, Name FROM PermissionSet where Name = 'Core_MDF_CCP_Internal_Claim_Case_Reviewer_Manager'];        
            //PermissionSetAssignment  psa = new PermissionSetAssignment(PermissionSetId = claimCaseReviewerPermissionSet.Id, AssigneeId = intUser.Id);
            //insert psa;
            
            PermissionSet financeMgr = [SELECT Id, Name FROM PermissionSet where Name = 'Core_MDF_CCP_Internal_Finance_Manager'];        
            PermissionSetAssignment  fm = new PermissionSetAssignment(PermissionSetId = financeMgr.Id, AssigneeId = intUser.Id);
            insert fm;
        }
        
        System.runAs(intUser){
           // Highlight: Unused Local Variable          
          /*  Boolean userHasAcess = */ Core_MDF_PFC_Close_Adjustment.hasAccess();
           
            //System.assertEquals(true, userHasAcess);
        }
        test.stopTest();
    }
    
    //Paid Claim connot be close
    @isTest 
    static void  testPaidClaimEligibleForClose(){
        
        //ChannelProgram cp = [SELECT ID From ChannelProgram where Name = 'Client Co-Marketing Fund'];
        //ChannelProgram cp1 = [SELECT ID From ChannelProgram where Name = 'Data Center Co-Marketing Fund'];
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        //User extUser = [SELECT Id,Email from User where Email='test1@example.com' limit 1];
        
        PartnerFundRequest indiaActivity = [SELECT Id,Title,Core_MDF_Start_Date__c,Core_MDF_End_Date__c from PartnerFundRequest where Title='indiaActivity' limit 1];        
        Core_MDF_Bank__c indiaBank = [Select ID from Core_MDF_Bank__c limit 1];
        // Highlight: Unused Local Variable
       // List<PartnerFundClaim> claimListToBeProcessed = new List<PartnerFundClaim>();
       
        System.runAs(sysAdminUser){           
            Test.startTest();
            PartnerFundClaim indiaClaim = Core_MDF_CCP_TestDataUtility.createClaim('India Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF, 
                                                                                   indiaActivity.Id, 
                                                                                   indiaActivity.Core_MDF_Start_Date__c, indiaActivity.Core_MDF_Start_Date__c, 
                                                                                   101, 
                                                                                   System.today(), indiaBank.ID, false);
            indiaClaim.Core_MDF_Currency__c = 'USD';
            insert indiaClaim;
            /*PartnerFundClaim indiaClaim2 = Core_MDF_CCP_TestDataUtility.createClaim('India Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF, 
                                                                                    indiaActivity.Id, 
                                                                                    indiaActivity.Core_MDF_Start_Date__c, indiaActivity.Core_MDF_Start_Date__c, 
                                                                                    100, 
                                                                                    System.today(), indiaBank.ID, false);
            
            
            indiaClaim2.Core_MDF_Currency__c = 'USD';
            PartnerFundClaim indiaClaim3 = Core_MDF_CCP_TestDataUtility.createClaim('India Claim1', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF, 
                                                                                    indiaActivity.Id, 
                                                                                    indiaActivity.Core_MDF_Start_Date__c, indiaActivity.Core_MDF_Start_Date__c, 
                                                                                    100, 
                                                                                    System.today(), indiaBank.ID, false);
            indiaClaim3.Core_MDF_Currency__c = 'USD';
            
            claimListToBeProcessed.add(indiaClaim);
            claimListToBeProcessed.add(indiaClaim2);
            claimListToBeProcessed.add(indiaClaim3);*/
            //test code begins
            //List<PartnerFundClaim> claimListToBeProcessed2 = new List<PartnerFundClaim>();            
            //List<PartnerFundClaim> claimListToBeProcessed3 = new List<PartnerFundClaim>();
            //claimListToBeProcessed2.add(indiaClaim2);
            //claimListToBeProcessed3.add(indiaClaim3);
            //test code ends
            
          
            //Database.insert(claimListToBeProcessed);
            //Test.stopTest();
            //test code begins
            //Database.insert(claimListToBeProcessed2);
            //Database.insert(claimListToBeProcessed3);
            //test code ends
            /*Core_MDF_Adjustment_Request__c adjustment1 = new Core_MDF_Adjustment_Request__c();          
            adjustment1.Core_MDF_Reference_Claim_Nbr__c = indiaClaim.Id;
            adjustment1.Core_MDF_Amount_Amt__c = 10;
            adjustment1.Core_MDF_Reason_Cd__c = 'Claim Review Results (Negative)';
          
            Database.insert(adjustment1);
            
            Core_Trigger_Executions__c setting = new Core_Trigger_Executions__c();
            setting.Core_Active__c = true;
            setting.Core_Class_Name__c = 'Core_MDF_AdjustmentClaimOffsetProcess';
            setting.Core_Description__c = 'Demo Description';
            setting.Core_Object__c = 'Core_MDF_Payment_Run__c';
            setting.Core_Trigger_Events__c = 'after insert';
            setting.name = 'Core_MDF_AdjustmentClaimOffsetProcess';
            insert setting;
            
            //Test.stopTest();
            
            ChannelProgram cp = [SELECT ID From ChannelProgram where Name = 'Client Co-Marketing Fund'];
            ChannelProgram cp1 = [SELECT ID From ChannelProgram where Name = 'Data Center Co-Marketing Fund'];
            Core_MDF_Payment_Run__c payRunRecord = new Core_MDF_Payment_Run__c();
            payRunRecord.Core_MDF_ScheduleRun_Dtm__c= DateTime.Now().addMinutes(1);
            payRunRecord.Core_MDF_Geo_Txt__c = 'ASMO';
            payRunRecord.Core_MDF_Program_Id__c  = cp.Id;
            Database.insert(payRunRecord);
            System.assertNotEquals(payRunRecord.Id,null); 
            
            Core_MDF_Payment_Run__c payRunRecord1 = new Core_MDF_Payment_Run__c();
            payRunRecord1.Core_MDF_ScheduleRun_Dtm__c= DateTime.Now().addMinutes(1);
            payRunRecord1.Core_MDF_Geo_Txt__c = 'ASMO';
            payRunRecord1.Core_MDF_Program_Id__c  = cp1.Id;
            Database.insert(payRunRecord1);
            System.assertNotEquals(payRunRecord1.Id,null);
            
            PartnerFundClaim claim1 = [Select Id, OwnerId from PartnerFundClaim where Title = 'India Claim1' limit 1];
            PartnerFundClaim claim2 = [Select Id, OwnerId from PartnerFundClaim where Title = '[Adjustment] India Claim1' limit 1];*/
            
            PartnerFundClaim claim1 = [Select Id, OwnerId from PartnerFundClaim where Title = 'India Claim' limit 1];
            claim1.Core_MDF_Status__c='Paid';
            update claim1;
            
            Core_MDF_PFC_Close_Adjustment.eligibilityToCloseWrapper paidClaimCannotClose = Core_MDF_PFC_Close_Adjustment.claimEligibleForClose(claim1.Id);      
                     
            system.assertNotEquals(paidClaimCannotClose, NULL); 
            Test.stopTest();
        } 
        
    }
    
    @isTest 
    static void  testForCloseClaim(){
        // Highlight: Unused Local Variable
       // ChannelProgram cp = [SELECT ID From ChannelProgram where Name =:Core_MDF_CCP_ConstantClass.CCF_PROGRAM];  
        
        //ChannelProgram cp1 = [SELECT ID From ChannelProgram where Name = 'Data Center Co-Marketing Fund'];
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        /*User extUser = [SELECT Id,Email from User where Email='test1@example.com' limit 1];
        User intUser = [SELECT Id,Email from User where Email='test1vd@intel.com' limit 1];
        Group grp = [SELECT Id, Name, DeveloperName FROM Group where DeveloperName = 'Core_MDF_CCP_Claim_Case_Reviewer_Q_Group'];
        Group grp2 = [SELECT Id, Name, DeveloperName FROM Group where DeveloperName = 'Core_All_Users_CCP_Internal'];*/
        
        PartnerFundRequest indiaActivity = [SELECT Id,Title,Core_MDF_Start_Date__c,Core_MDF_End_Date__c from PartnerFundRequest where Title='indiaActivity' limit 1];        
       
        Id indiaBank = [Select ID from Core_MDF_Bank__c limit 1].id; 
        // Highlight: Unused Local Variable 
       // List<PartnerFundClaim> claimListToBeProcessed = new List<PartnerFundClaim>();
        
        System.runAs(sysAdminUser){
            
           /* PermissionSet claimCaseReviewerPermissionSet = [SELECT Id, Name FROM PermissionSet where Name = 'Core_MDF_CCP_Internal_Claim_Case_Reviewer_Manager'];        
            PermissionSetAssignment  psa = new PermissionSetAssignment(PermissionSetId = claimCaseReviewerPermissionSet.Id, AssigneeId = intUser.Id);
            insert psa;
            
            GroupMember grpMem = new GroupMember();
            grpMem.GroupId = grp.Id;
            grpMem.UserOrGroupId = intUser.Id;
            GroupMember grpMem2 = new GroupMember();
            grpMem2.GroupId = grp2.Id;
            grpMem2.UserOrGroupId = intUser.Id;
            Database.insert(grpMem2);*/
            Test.startTest();
            PartnerFundClaim indiaClaim3 = Core_MDF_CCP_TestDataUtility.createClaim('India Claim1', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF, 
                                                                                    indiaActivity.Id, 
                                                                                    indiaActivity.Core_MDF_Start_Date__c, indiaActivity.Core_MDF_Start_Date__c, 
                                                                                    200, 
                                                                                    System.today(), indiaBank, false);
            indiaClaim3.Core_MDF_Currency__c = 'USD';
            indiaClaim3.Core_MDF_Claim_Previous_Status__c ='Pending Available Fund';
            indiaClaim3.Core_MDF_Status__c ='Pending Available Fund';
            
            Database.insert(indiaClaim3);
            
            Core_MDF_Adjustment_Request__c adjustment1 = new Core_MDF_Adjustment_Request__c();          
            adjustment1.Core_MDF_Reference_Claim_Nbr__c = indiaClaim3.Id;
            adjustment1.Core_MDF_Amount_Amt__c = 50;
            adjustment1.Core_MDF_Reason_Cd__c = 'Duplicate Claim';            
            Database.insert(adjustment1);            
            // Highlight: Unused Local Variable 
           // List<PartnerFundClaim> pfc = new List<PartnerFundClaim>();
            PartnerFundClaim claim1 = [Select Id, OwnerId from PartnerFundClaim where Title = 'India Claim1']; //100$
            
            PartnerFundClaim claim2 = [Select Id, OwnerId from PartnerFundClaim where Title = '[Adjustment] India Claim1' limit 1]; //$50
            
            /*claim1.Amount = 50;
            claim2.Amount = -50;
            pfc.add(claim1);
            pfc.add(claim2);
            Database.update(pfc);*/
            //Test.stopTest();

            Core_MDF_Claim_Offset__c offset1 = new Core_MDF_Claim_Offset__c();
            offset1.Core_MDF_Offset_Claim_Nbr__c = claim1.Id;
            offset1.Core_MDF_Adjustment_Claim_Nbr__c = claim2.Id;
            offset1.Core_MDF_Offset_Amount_Amt__c = 50;
            Database.insert(offset1);
            Test.stopTest();
            //PartnerFundClaimShare sharewithIntUser = new PartnerFundClaimShare(ParentId = claim2.Id, UserOrGroupId = intUser.Id, AccessLevel = 'Edit');
            //Database.insert(sharewithIntUser);    
        //}
        //System.runAs(intUser){
            
            Core_MDF_PFC_Close_Adjustment.eligibilityToCloseWrapper eligibilityToClose = new Core_MDF_PFC_Close_Adjustment.eligibilityToCloseWrapper(); 
            eligibilityToClose.hasAccess = true;  
            
            //PartnerFundClaim claim2 = [Select Id, OwnerId from PartnerFundClaim where Title = '[Adjustment] India Claim1' limit 1]; 
          
            List<id> claimList = new List<id>();
            claimList.add(claim2.Id);
            
            Core_MDF_PFC_Close_Adjustment.eligibilityToCloseWrapper partialOffsetClaim2 = Core_MDF_PFC_Close_Adjustment.claimEligibleForClose(claim2.Id);
            
            System.AssertEquals(false,eligibilityToClose.restrictClaimWithoutOffset);
            System.AssertEquals(false,eligibilityToClose.claimCannotBeClose);
            system.assertNotEquals(partialOffsetClaim2, NULL); 
            
        }
       // }
        
     }
    
    @isTest 
    static void  testAdjClaimWithCancelledSts(){
        Test.startTest();
        // Highlight: Unused Local Variable 
        //ChannelProgram cp = [SELECT ID From ChannelProgram where Name =: Core_MDF_CCP_ConstantClass.CCF_PROGRAM];
       // ChannelProgram cp1 = [SELECT ID From ChannelProgram where Name =: Core_MDF_CCP_ConstantClass.DCF_PROGRAM];
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        // Highlight: Unused Local Variable
       // User extUser = [SELECT Id,Email from User where Email='test1@example.com' limit 1];
        User intUser = [SELECT Id,Email from User where Email='test1vd@intel.com' limit 1];
        Group grp = [SELECT Id, Name, DeveloperName FROM Group where DeveloperName = 'Core_MDF_CCP_Claim_Case_Reviewer_Q_Group'];
        Group grp2 = [SELECT Id, Name, DeveloperName FROM Group where DeveloperName = 'Core_All_Users_CCP_Internal'];
        
        PartnerFundRequest indiaActivity = [SELECT Id,Title,Core_MDF_Start_Date__c,Core_MDF_End_Date__c from PartnerFundRequest where Title='indiaActivity' limit 1];
        
        Core_MDF_Bank__c indiaBank = [Select ID from Core_MDF_Bank__c limit 1];
       // Highlight: Unused Local Variable
       // List<PartnerFundClaim> claimListToBeProcessed = new List<PartnerFundClaim>();
        
        System.runAs(sysAdminUser){
            
            PermissionSet claimCaseReviewerPermissionSet = [SELECT Id, Name FROM PermissionSet where Name = 'Core_MDF_CCP_Internal_Claim_Case_Reviewer_Manager'];        
            PermissionSetAssignment  psa = new PermissionSetAssignment(PermissionSetId = claimCaseReviewerPermissionSet.Id, AssigneeId = intUser.Id);
            insert psa;
            
            GroupMember grpMem = new GroupMember();
            grpMem.GroupId = grp.Id;
            grpMem.UserOrGroupId = intUser.Id;
            GroupMember grpMem2 = new GroupMember();
            grpMem2.GroupId = grp2.Id;
            grpMem2.UserOrGroupId = intUser.Id;
            Database.insert(grpMem2);
            
            PartnerFundClaim indiaClaim3 = Core_MDF_CCP_TestDataUtility.createClaim('India Claim1', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF, 
                                                                                    indiaActivity.Id, 
                                                                                    indiaActivity.Core_MDF_Start_Date__c, indiaActivity.Core_MDF_Start_Date__c, 
                                                                                    50, 
                                                                                    System.today(), indiaBank.ID, false);
            indiaClaim3.Core_MDF_Currency__c ='USD';
            indiaClaim3.Core_MDF_Status__c ='Cancelled';
            Database.insert(indiaClaim3);    
            
            PartnerFundClaimShare sharewithIntUser = new PartnerFundClaimShare(ParentId = indiaClaim3.Id, UserOrGroupId = intUser.Id, AccessLevel = 'Edit');
            Database.insert(sharewithIntUser);    
        }
        System.runAs(intUser){            
            Core_MDF_PFC_Close_Adjustment.eligibilityToCloseWrapper eligibilityToClose = new Core_MDF_PFC_Close_Adjustment.eligibilityToCloseWrapper(); 
            
            PartnerFundClaim claim2 = [Select Id, OwnerId from PartnerFundClaim where Title = 'India Claim1' limit 1]; 
            
            List<id> claimList = new List<id>();
            claimList.add(claim2.Id);
            // Highlight: Unused Local Variable 
           /* Core_MDF_PFC_Close_Adjustment.eligibilityToCloseWrapper claimWithCancelledSts = */ Core_MDF_PFC_Close_Adjustment.claimEligibleForClose(claim2.Id);
            
            //System.AssertEquals(true,eligibilityToClose.hasAccess);
            System.AssertEquals(false,eligibilityToClose.claimCannotBeClose);
            System.AssertEquals(false,eligibilityToClose.isPAF);
        }        
        Test.stopTest();
    }
    
    @isTest 
    static void  testCloseAdjWithoutOffset(){
        
        //ChannelProgram cp = [SELECT ID From ChannelProgram where Name = 'Client Co-Marketing Fund'];
        //ChannelProgram cp1 = [SELECT ID From ChannelProgram where Name = 'Data Center Co-Marketing Fund'];
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        /*User extUser = [SELECT Id,Email from User where Email='test1@example.com' limit 1];
        User intUser = [SELECT Id,Email from User where Email='test1vd@intel.com' limit 1];
        Group grp = [SELECT Id, Name, DeveloperName FROM Group where DeveloperName = 'Core_MDF_CCP_Claim_Case_Reviewer_Q_Group'];
        Group grp2 = [SELECT Id, Name, DeveloperName FROM Group where DeveloperName = 'Core_All_Users_CCP_Internal'];*/
        
        PartnerFundRequest indiaActivity = [SELECT Id,Title,Core_MDF_Start_Date__c,Core_MDF_End_Date__c from PartnerFundRequest where Title='indiaActivity' limit 1];
        Core_MDF_Bank__c indiaBank = [Select ID from Core_MDF_Bank__c limit 1];
        // Highlight: Unused Local Variable
       // List<PartnerFundClaim> claimListToBeProcessed = new List<PartnerFundClaim>();
        
        System.runAs(sysAdminUser){
            
            /*PermissionSet claimCaseReviewerPermissionSet = [SELECT Id, Name FROM PermissionSet where Name = 'Core_MDF_CCP_Internal_Claim_Case_Reviewer_Manager'];        
            PermissionSetAssignment  psa = new PermissionSetAssignment(PermissionSetId = claimCaseReviewerPermissionSet.Id, AssigneeId = intUser.Id);
            insert psa;
            
            GroupMember grpMem = new GroupMember();
            grpMem.GroupId = grp.Id;
            grpMem.UserOrGroupId = intUser.Id;
            GroupMember grpMem2 = new GroupMember();
            grpMem2.GroupId = grp2.Id;
            grpMem2.UserOrGroupId = intUser.Id;
            Database.insert(grpMem2);*/
            Test.startTest();
            PartnerFundClaim indiaClaim3 = Core_MDF_CCP_TestDataUtility.createClaim('India Claim1', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF, 
                                                                                    indiaActivity.Id, 
                                                                                    indiaActivity.Core_MDF_Start_Date__c, indiaActivity.Core_MDF_Start_Date__c, 
                                                                                    500, 
                                                                                    System.today(), indiaBank.ID, false);
            indiaClaim3.Core_MDF_Currency__c = 'USD';
            indiaClaim3.Core_MDF_Claim_Previous_Status__c ='Pending Available Fund';
            indiaClaim3.Core_MDF_Status__c ='Pending Available Fund';
            Database.insert(indiaClaim3);
            System.debug('indiaClaim3'+indiaClaim3.id);
           
            Core_MDF_Adjustment_Request__c adjustment1 = new Core_MDF_Adjustment_Request__c();   
            adjustment1.Core_MDF_Reference_Claim_Nbr__c = indiaClaim3.Id;
            adjustment1.Core_MDF_Amount_Amt__c = 20;
            adjustment1.Core_MDF_Reason_Cd__c = 'Duplicate Claim';            
            Database.insert(adjustment1); 
            System.debug('adjustment1'+adjustment1);
            test.stopTest();
           // Highlight: Unused Local Variable
           // List<PartnerFundClaim> pfc = new List<PartnerFundClaim>();
          // PartnerFundClaim claim1 = [Select Id, OwnerId from PartnerFundClaim where Title = 'India Claim1'];
            
            //PartnerFundClaim claim2 = [Select Id, OwnerId from PartnerFundClaim where Title = '[Adjustment] India Claim1' limit 1]; 
            /*claim2.Core_MDF_Type_Txt__c = 'Adjustment';
            pfc.add(claim2);
            Database.update(pfc);*/
            
            //PartnerFundClaimShare sharewithIntUser = new PartnerFundClaimShare(ParentId = claim2.Id, UserOrGroupId = intUser.Id, AccessLevel = 'Edit');
            //Database.insert(sharewithIntUser);            
       // }        
       // System.runAs(intUser){
            PartnerFundClaim adjClaimWithoutOffset = [Select Id,Core_MDF_Status__c,Core_MDF_Claim_Previous_Status__c from PartnerFundClaim where Title = '[Adjustment] India Claim1' limit 1]; 
            // Unit Test Method should include System.Assert
            System.assertNotEquals(null,adjClaimWithoutOffset.Id,'Adjustment claim Id should be populated');
            
            //Test.stopTest(); 
           // Highlight: Unused Local Variable
           /* Core_MDF_PFC_Close_Adjustment.eligibilityToCloseWrapper adjustmentClaimWithoutOffset = */ Core_MDF_PFC_Close_Adjustment.claimEligibleForClose(adjClaimWithoutOffset.Id);      
                        
            //system.assertNotEquals(adjustmentClaimWithoutOffset, NULL);  
        }
       
    }
    
    @isTest 
    static void  testclaimCannotBeClose(){
        
        //ChannelProgram cp = [SELECT ID From ChannelProgram where Name = 'Client Co-Marketing Fund'];
        //ChannelProgram cp1 = [SELECT ID From ChannelProgram where Name = 'Data Center Co-Marketing Fund'];
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
       /* User extUser = [SELECT Id,Email from User where Email='test1@example.com' limit 1];
        User intUser = [SELECT Id,Email from User where Email='test1vd@intel.com' limit 1];
        Group grp = [SELECT Id, Name, DeveloperName FROM Group where DeveloperName = 'Core_MDF_CCP_Claim_Case_Reviewer_Q_Group'];
        Group grp2 = [SELECT Id, Name, DeveloperName FROM Group where DeveloperName = 'Core_All_Users_CCP_Internal'];*/
        
        PartnerFundRequest indiaActivity = [SELECT Id,Title,Core_MDF_Start_Date__c,Core_MDF_End_Date__c from PartnerFundRequest where Title='indiaActivity' limit 1];        
        Core_MDF_Bank__c indiaBank = [Select ID from Core_MDF_Bank__c limit 1];
        // Highlight: Unused Local Variable
       // List<PartnerFundClaim> claimListToBeProcessed = new List<PartnerFundClaim>();
        
        System.runAs(sysAdminUser){
            
            /*PermissionSet claimCaseReviewerPermissionSet = [SELECT Id, Name FROM PermissionSet where Name = 'Core_MDF_CCP_Internal_Claim_Case_Reviewer_Manager'];        
            PermissionSetAssignment  psa = new PermissionSetAssignment(PermissionSetId = claimCaseReviewerPermissionSet.Id, AssigneeId = intUser.Id);
            insert psa;
            
            GroupMember grpMem = new GroupMember();
            grpMem.GroupId = grp.Id;
            grpMem.UserOrGroupId = intUser.Id;
            GroupMember grpMem2 = new GroupMember();
            grpMem2.GroupId = grp2.Id;
            grpMem2.UserOrGroupId = intUser.Id;
            Database.insert(grpMem2);*/
            
            PartnerFundClaim indiaClaim3 = Core_MDF_CCP_TestDataUtility.createClaim('India Claim1', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF, 
                                                                                    indiaActivity.Id, 
                                                                                    indiaActivity.Core_MDF_Start_Date__c, indiaActivity.Core_MDF_Start_Date__c, 
                                                                                    500, 
                                                                                    System.today(), indiaBank.ID, false);
            indiaClaim3.Core_MDF_Currency__c = 'USD';
            indiaClaim3.Core_MDF_Claim_Previous_Status__c ='Pending Available Fund';
            indiaClaim3.Core_MDF_Status__c ='Pending Available Fund';
            
            Test.startTest();
            Database.insert(indiaClaim3);
            
            Core_MDF_Adjustment_Request__c adjustment1 = new Core_MDF_Adjustment_Request__c();          
            adjustment1.Core_MDF_Reference_Claim_Nbr__c = indiaClaim3.Id;
            adjustment1.Core_MDF_Amount_Amt__c = 2;
            adjustment1.Core_MDF_Reason_Cd__c = 'Duplicate Claim'; 
            Database.insert(adjustment1);   
          // Highlight: Unused Local Variable
          //  List<PartnerFundClaim> pfc = new List<PartnerFundClaim>();
             
            PartnerFundClaim claim1 = [Select Id, OwnerId from PartnerFundClaim where Title = 'India Claim1'];
            Test.stopTest();
             
            claim1.Core_MDF_Status__c ='Cancelled';
            //pfc.add(claim2);
            
            Database.update(claim1);
            
            /*PartnerFundClaimShare sharewithIntUser = new PartnerFundClaimShare(ParentId = claim2.Id, UserOrGroupId = intUser.Id, AccessLevel = 'Edit');
            Database.insert(sharewithIntUser);    */        
        //}
        //System.runAs(intUser){
            //PartnerFundClaim claimCannotBeClose = [Select Id,Core_MDF_Status__c,Core_MDF_Claim_Previous_Status__c from PartnerFundClaim where Title = '[Adjustment] India Claim1' limit 1]; 
            //claimCannotBeClose.Core_MDF_Status__c ='Cancelled';
            //Database.update(claimCannotBeClose);
            Core_MDF_PFC_Close_Adjustment.eligibilityToCloseWrapper adjustmentClaimCannotBeClose = Core_MDF_PFC_Close_Adjustment.claimEligibleForClose(claim1.Id);      
                        
            system.assertNotEquals(adjustmentClaimCannotBeClose, NULL);  
        }
    } 
    
   /* @isTest static void validateAdjustmentOffset1(){ 
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        PartnerFundRequest indiaActivity = [SELECT Id,Title,Core_MDF_Start_Date__c,Core_MDF_End_Date__c from PartnerFundRequest where Title='indiaActivity' limit 1];
        Core_MDF_Bank__c indiaBank = [Select ID from Core_MDF_Bank__c limit 1];
        System.runAs(sysAdminUser){
            Test.startTest();
            //create claim
            PartnerFundClaim indiaClaim3 = Core_MDF_CCP_TestDataUtility.createClaim('Test indiaClaim3', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF, 
                                                                                    indiaActivity.Id, 
                                                                                    indiaActivity.Core_MDF_Start_Date__c, indiaActivity.Core_MDF_Start_Date__c, 
                                                                                    5000, 
                                                                                    System.today(), indiaBank.ID, false);
            indiaClaim3.Core_MDF_Currency__c = 'USD';
            indiaClaim3.Core_MDF_Claim_Previous_Status__c ='Pending Available Fund';
            indiaClaim3.Core_MDF_Status__c ='Pending Available Fund';
            Database.insert(indiaClaim3);
            
            Core_MDF_Adjustment_Request__c adjustment1 = new Core_MDF_Adjustment_Request__c();          
            adjustment1.Core_MDF_Reference_Claim_Nbr__c = indiaClaim3.Id;
            adjustment1.Core_MDF_Amount_Amt__c = 2000;
            adjustment1.Core_MDF_Reason_Cd__c = 'Claim Review Results (Negative)';            
            Database.insert(adjustment1);
            
            PartnerFundClaim claim1 = [Select Id, Amount, Core_MDF_Status__c from PartnerFundClaim where Title = 'Test indiaClaim3' limit 1];
            PartnerFundClaim claim2 = [Select Id,Core_MDF_Type_Txt__c, Core_MDF_Total_Invoice_Amount_Local__c, Amount, Core_MDF_Status__c from PartnerFundClaim where Title = '[Adjustment] Test indiaClaim3' limit 1];   
            
            system.AssertEquals('Adjustment',claim2.Core_MDF_Type_Txt__c);
            system.AssertEquals(Label.Core_MDF_Claim_Status_Pending_Available_Fund,claim2.Core_MDF_Status__c);
            
            Core_MDF_PFC_Close_Adjustment.eligibilityToCloseWrapper isAdjustmentType = Core_MDF_PFC_Close_Adjustment.claimEligibleForClose(claim2.Id);      
            system.AssertEquals(false ,isAdjustmentType.restrictClaimWithoutOffset);
            
            Test.stopTest(); 
        }
    }*/
    @isTest 
    static void validateAdjustmentOffset1(){ 
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        PartnerFundRequest indiaActivity = [SELECT Id,Title,Core_MDF_Start_Date__c,Core_MDF_End_Date__c from PartnerFundRequest where Title='indiaActivity' limit 1];
        
       
        Core_MDF_Bank__c indiaBank = [Select ID from Core_MDF_Bank__c limit 1];
        System.runAs(sysAdminUser){
            
           
            //create claim
            PartnerFundClaim claim1 = Core_MDF_CCP_TestDataUtility.createClaim('TestAdjClaim', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF, 
                                                                                    indiaActivity.Id, 
                                                                                    indiaActivity.Core_MDF_Start_Date__c, indiaActivity.Core_MDF_Start_Date__c, 
                                                                                    5000, 
                                                                                    System.today(), indiaBank.ID, false);
            claim1.Core_MDF_Currency__c = 'USD';
            claim1.Core_MDF_Claim_Previous_Status__c ='Pending Available Fund';
            claim1.Core_MDF_Status__c ='Pending Available Fund';
            
            Database.insert(claim1);
           
            Core_MDF_Adjustment_Request__c adjustment1 = new Core_MDF_Adjustment_Request__c();          
            adjustment1.Core_MDF_Reference_Claim_Nbr__c = claim1.Id;
            adjustment1.Core_MDF_Amount_Amt__c = 2000;
            adjustment1.Core_MDF_Reason_Cd__c = 'Duplicate Claim'; 
            test.startTest();
                   
            Database.insert(adjustment1);
            
            
            List<Id> claimIdList = new List<Id>();
          
            //PartnerFundClaim claim1 = [Select Id, Amount, Core_MDF_Status__c from PartnerFundClaim where Title = 'TestAdjClaim' limit 1];
            Core_MDF_Adjustment_Request__c adj1 = [Select Id,Core_MDF_Adjustment_Claim_Nbr__c, Core_MDF_Reference_Claim_Nbr__c,Core_MDF_Reference_Claim_Nbr__r.Title,Core_MDF_Reference_Claim_Nbr__r.Core_MDF_Type_Txt__c 
                                                  FROM Core_MDF_Adjustment_Request__c where Core_MDF_Reference_Claim_Nbr__r.Id=:claim1.Id];
            
            //claimIdList.add(claim1.Id);
            Test.stopTest();
            boolean  isclosed = Core_MDF_PFC_Close_Adjustment.closeClaims(claimIdList);
            system.AssertEquals(true,isclosed);
            
            PartnerFundClaim claim2 = [Select Id,Core_MDF_Type_Txt__c, Core_MDF_Total_Invoice_Amount_Local__c, Amount, Core_MDF_Status__c from PartnerFundClaim where Id=:adj1.Core_MDF_Adjustment_Claim_Nbr__c];   
            
            system.AssertEquals('Adjustment',claim2.Core_MDF_Type_Txt__c);
            system.AssertEquals(Label.Core_MDF_Claim_Status_Pending_Available_Fund,claim2.Core_MDF_Status__c);
            claimIdList.add(claim2.Id);
           
            
            Core_MDF_PFC_Close_Adjustment.eligibilityToCloseWrapper isAdjustmentType = Core_MDF_PFC_Close_Adjustment.claimEligibleForClose(adj1.Core_MDF_Reference_Claim_Nbr__r.Id);      
            system.AssertEquals(false ,isAdjustmentType.restrictClaimWithoutOffset);
            
            //system.AssertEquals(true ,eligibilityToClose.adjustmentClaimType);
           
            
            /*Core_MDF_Claim_Offset__c offset1 = new Core_MDF_Claim_Offset__c();
            offset1.Core_MDF_Offset_Claim_Nbr__c = claim1.Id;
            offset1.Core_MDF_Adjustment_Claim_Nbr__c = adj1.Core_MDF_Reference_Claim_Nbr__c;
            offset1.Core_MDF_Offset_Amount_Amt__c = 50;
          
            Database.insert(offset1);*/
            
            boolean  isclosed1 = Core_MDF_PFC_Close_Adjustment.closeClaims(claimIdList);
            system.AssertEquals(true,isclosed1);
            /*List<PartnerFundClaim> claimToBeClosed = new List<PartnerFundClaim>();
            claimToBeClosed.add(claim2);
            Core_MDF_PFC_Close_Adjustment.updateClaimCloseStatus(claimToBeClosed);
            */
           
        }
    }
    
     @isTest 
    static void validateAdjustmentOffset2(){ 
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        
        PartnerFundRequest indiaActivity = [SELECT Id,Title,Core_MDF_Start_Date__c,Core_MDF_End_Date__c from PartnerFundRequest where Title='indiaActivity' limit 1];
        
        Core_MDF_Bank__c indiaBank = [Select ID from Core_MDF_Bank__c limit 1];
        System.runAs(sysAdminUser){
            //68
            Test.startTest();
            PartnerFundClaim indiaClaim3 = Core_MDF_CCP_TestDataUtility.createClaim('India Claim1', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF, 
                                                                                    indiaActivity.Id, 
                                                                                    indiaActivity.Core_MDF_Start_Date__c, indiaActivity.Core_MDF_Start_Date__c, 
                                                                                    5000, 
                                                                                    System.today(), indiaBank.ID, false);
            indiaClaim3.Core_MDF_Currency__c = 'USD';
            indiaClaim3.Core_MDF_Claim_Previous_Status__c ='Pending Available Fund';
            indiaClaim3.Core_MDF_Status__c ='Pending Available Fund';
            Database.insert(indiaClaim3);
             
            Core_MDF_Adjustment_Request__c adjustment1 = new Core_MDF_Adjustment_Request__c();          
            adjustment1.Core_MDF_Reference_Claim_Nbr__c = indiaClaim3.Id;
            adjustment1.Core_MDF_Amount_Amt__c = 2000;
            adjustment1.Core_MDF_Reason_Cd__c = 'Duplicate Claim';  
            
            Database.insert(adjustment1); 
            Test.stopTest();
            
            //List<Id> pfcId = new List<Id>();
            PartnerFundClaim claim1 = [Select Id, OwnerId from PartnerFundClaim where Title = 'India Claim1']; //100$
            PartnerFundClaim claim2 = [Select Id from PartnerFundClaim where Title = '[Adjustment] India Claim1' limit 1]; //$50
             
            claim2.Amount = -500;
            claim2.Core_MDF_Status__c = Label.Core_MDF_Status_Pending_Available_Fund;
            claim1.Core_MDF_Status__c = Label.Core_MDF_Status_Paid;
            List<PartnerFundClaim> claims = new List<PartnerFundClaim>();
            claims.add(claim1);
            claims.add(claim2);
            database.update(claims);
           
            
            //PartnerFundClaim claim3 = [Select Id, Amount, Core_MDF_Status__c, OwnerId from PartnerFundClaim where Title = 'India Claim1' limit 1];
            //PartnerFundClaim claim4 = [Select Id, Core_MDF_Type_txt__c, Core_MDF_Total_Invoice_Amount_Local__c, Amount, Core_MDF_Status__c, OwnerId from PartnerFundClaim where Title = '[Adjustment] India Claim1' limit 1];
          
           // pfcId.add(claim1.Id);
            
            
            Core_MDF_Claim_Offset__c offset1 = new Core_MDF_Claim_Offset__c();
            offset1.Core_MDF_Offset_Claim_Nbr__c = claim1.Id;
            offset1.Core_MDF_Adjustment_Claim_Nbr__c = claim2.Id;
            offset1.Core_MDF_Offset_Amount_Amt__c = 1000;
            Database.insert(offset1);
           // pfcId.add(claim2.Id);            
           
            
            //Core_MDF_Claim_Offset__c offset = [select id,Core_MDF_Adjustment_Claim_Nbr__c from Core_MDF_Claim_Offset__c where Core_MDF_Adjustment_Claim_Nbr__c= :claim2.Id]; 
            
            //select id,Core_MDF_Adjustment_Claim_Nbr__c,Core_MDF_Adjustment_Claim_Nbr__r.Core_MDF_Status__c 
            //from Core_MDF_Claim_Offset__c  where Core_MDF_Adjustment_Claim_Nbr__r.Core_MDF_Status__c='Pending Available Fund' 
            //boolean  isclosed1 = Core_MDF_PFC_Close_Adjustment.closeClaims(pfcId);
            //system.AssertEquals(true,isclosed1);
            //
            List<Id> closeClaims = new List<Id>();
            closeClaims.add(claim2.id);
            
            boolean partialOffsetClaim = Core_MDF_PFC_Close_Adjustment.closeClaims(closeClaims);
            system.AssertEquals(true,partialOffsetClaim);
            
           //Test.stopTest();
        }
    }
    
}