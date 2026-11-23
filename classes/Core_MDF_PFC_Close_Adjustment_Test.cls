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
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        
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
        ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram ('Client Co-Marketing Fund','Client CoMarketing Fund', false);
        ChannelProgram cp1 = Core_MDF_CCP_TestDataUtility.createProgram ('Data Center Co-Marketing Fund','Data Center CoMarketing Fund', false);
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
        
        Core_MDF_CCP_TestDataUtility.createPartnerNodeUserMapping(dellCCFAPACIndia.Id, usr1.Id, true);
        
        //Id recordTypeIdPMB = Schema.SObjectType.PartnerMarketingBudget.getRecordTypeInfosByName().get('CoMarketing').getRecordTypeId();
        // Create PMB for the above Account 
        PartnerMarketingBudget  pmbRecord = Core_MDF_CCP_TestDataUtility.createBudget('Dell PMB',Core_MDF_CCP_TestDataUtility.Budget_Record_Type,dellCCFVirtualCorp.Id,cp.Id,100000,System.today().addDays(-15),System.today().addDays(15),true);
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
        Test.startTest();
        Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 12','Gaming','Intel® Core™ i7 Processor', Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', System.today(), System.today()+20, 10000, 'Consumer Chromebook', dellCCFVirtualCorp.Id, '2-in-1', true); 
        
        PartnerFundRequest indiaActivity = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                                 string.valueof(dellCCFAPACIndia.id),pfaDellCCFIndia,pmbRecord,
                                                                                                 'BRAZIL','Consumer','Desktop','Intel® Core™ i7 Processor','Broadcast','Podcast','Draft'
                                                                                                 ,false);
        indiaActivity.Title = 'indiaActivity';
        indiaActivity.Core_MDF_Activity_Description__c = 'indiaActivity';
        indiaActivity.Core_MDF_Start_Date__c = System.today();
        indiaActivity.Core_MDF_End_Date__c = System.today();
        indiaActivity.RequestedAmount = 100;
        indiaActivity.Core_MDF_Channel_Partner_Led__c = True;
        indiaActivity.Amount=0;
        Database.insert(indiaActivity);       
        
        Core_MDF_CCP_TestDataUtility.createTriggerExecutionRecords();
        
        Core_MDF_Bank__c indiaBank = Core_MDF_CCP_TestDataUtility.createBank(dellCorpAccount.Id, 'Core_MDF_Client_CoMarketing_Fund', true,'1231231230');
        //indiaBank.Core_MDF_Bank_Status__c = 'Draft';
        //Database.insert(indiaBank);
        
        Core_MDF_Account_Bank_Mapping__c accountBankMap = Core_MDF_CCP_TestDataUtility.createAccountBankMap(dellCCFAPACIndia.Id, indiaBank.Id, true);
        
        Core_MDF_CCP_TestDataUtility.insertCurrencyExchangeRates();
        
        Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount aObj = new Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount();
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
        Core_MDF_CCP_Multicurrency.getUSDExchangeRateBasedOnDate(listvar);   
        
        PartnerFundClaim indiaClaim3 = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, indiaActivity.Id, System.today(), System.today(), 5000.00, System.today(), indiaBank.Id, false);
        indiaClaim3.Status = Label.Core_MDF_Status_Approved;
        indiaClaim3.Core_MDF_Status__c = Label.Core_MDF_Status_Payment_Due;
        Insert indiaClaim3;
        
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
            Boolean userHasAcess = Core_MDF_PFC_Close_Adjustment.hasAccess();
            system.debug('userHasAcess' +userHasAcess);
            //System.assertEquals(true, userHasAcess);
        }
        test.stopTest();
    }
    
    //Paid Claim connot be close
    @isTest 
    static void  testPaidClaimEligibleForClose(){
        Test.startTest();
        ChannelProgram cp = [SELECT ID From ChannelProgram where Name = 'Client Co-Marketing Fund'];
        ChannelProgram cp1 = [SELECT ID From ChannelProgram where Name = 'Data Center Co-Marketing Fund'];
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        User extUser = [SELECT Id,Email from User where Email='test1@example.com' limit 1];
        
        PartnerFundRequest indiaActivity = [SELECT Id,Title,Core_MDF_Start_Date__c,Core_MDF_End_Date__c from PartnerFundRequest where Title='indiaActivity' limit 1];
        
        Core_MDF_Bank__c indiaBank = [Select ID from Core_MDF_Bank__c limit 1];
        
        List<PartnerFundClaim> claimListToBeProcessed = new List<PartnerFundClaim>();
        
        System.runAs(sysAdminUser){           
            
            PartnerFundClaim indiaClaim = Core_MDF_CCP_TestDataUtility.createClaim('India Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF, 
                                                                                   indiaActivity.Id, 
                                                                                   indiaActivity.Core_MDF_Start_Date__c, indiaActivity.Core_MDF_Start_Date__c, 
                                                                                   101, 
                                                                                   System.today(), indiaBank.ID, false);
            indiaClaim.Core_MDF_Currency__c = 'USD';
            PartnerFundClaim indiaClaim2 = Core_MDF_CCP_TestDataUtility.createClaim('India Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF, 
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
            claimListToBeProcessed.add(indiaClaim3);
            
            Database.insert(claimListToBeProcessed);
            
            Core_MDF_Adjustment_Request__c adjustment1 = new Core_MDF_Adjustment_Request__c();          
            adjustment1.Core_MDF_Reference_Claim_Nbr__c = indiaClaim3.Id;
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
            PartnerFundClaim claim2 = [Select Id, OwnerId from PartnerFundClaim where Title = '[Adjustment] India Claim1' limit 1];
            
            Core_MDF_PFC_Close_Adjustment.eligibilityToCloseWrapper paidClaimCannotClose = Core_MDF_PFC_Close_Adjustment.claimEligibleForClose(claim2.Id);      
            system.debug('paidClaimCannotClose-->' +paidClaimCannotClose);            
            system.assertNotEquals(paidClaimCannotClose, NULL);            
        } 
        Test.stopTest();
    }
    
    @isTest 
    static void  testForCloseClaim(){
        Test.startTest();
        ChannelProgram cp = [SELECT ID From ChannelProgram where Name = 'Client Co-Marketing Fund'];
        ChannelProgram cp1 = [SELECT ID From ChannelProgram where Name = 'Data Center Co-Marketing Fund'];
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        User extUser = [SELECT Id,Email from User where Email='test1@example.com' limit 1];
        User intUser = [SELECT Id,Email from User where Email='test1vd@intel.com' limit 1];
        Group grp = [SELECT Id, Name, DeveloperName FROM Group where DeveloperName = 'Core_MDF_CCP_Claim_Case_Reviewer_Q_Group'];
        Group grp2 = [SELECT Id, Name, DeveloperName FROM Group where DeveloperName = 'Core_All_Users_CCP_Internal'];
        
        PartnerFundRequest indiaActivity = [SELECT Id,Title,Core_MDF_Start_Date__c,Core_MDF_End_Date__c from PartnerFundRequest where Title='indiaActivity' limit 1];
        
        Core_MDF_Bank__c indiaBank = [Select ID from Core_MDF_Bank__c limit 1];
        
        List<PartnerFundClaim> claimListToBeProcessed = new List<PartnerFundClaim>();
        
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
            indiaClaim3.Core_MDF_Currency__c = 'USD';
            indiaClaim3.Core_MDF_Claim_Previous_Status__c ='Pending Available Fund';
            indiaClaim3.Core_MDF_Status__c ='Pending Available Fund';
            Database.insert(indiaClaim3);
            
            Core_MDF_Adjustment_Request__c adjustment1 = new Core_MDF_Adjustment_Request__c();          
            adjustment1.Core_MDF_Reference_Claim_Nbr__c = indiaClaim3.Id;
            adjustment1.Core_MDF_Amount_Amt__c = 2;
            adjustment1.Core_MDF_Reason_Cd__c = 'Claim Review Results (Negative)';            
            Database.insert(adjustment1);            
            
            List<PartnerFundClaim> pfc = new List<PartnerFundClaim>();
            PartnerFundClaim claim1 = [Select Id, OwnerId from PartnerFundClaim where Title = 'India Claim1'];
            PartnerFundClaim claim2 = [Select Id, OwnerId from PartnerFundClaim where Title = '[Adjustment] India Claim1' limit 1]; 
            claim1.Amount = 50;
            claim2.Amount = -50;
            pfc.add(claim1);
            pfc.add(claim2);
            Database.update(pfc);
            
            Core_MDF_Claim_Offset__c offset1 = new Core_MDF_Claim_Offset__c();
            offset1.Core_MDF_Offset_Claim_Nbr__c = claim1.Id;
            offset1.Core_MDF_Adjustment_Claim_Nbr__c = claim2.Id;
            offset1.Core_MDF_Offset_Amount_Amt__c = 50;
            Database.insert(offset1);
            
            PartnerFundClaimShare sharewithIntUser = new PartnerFundClaimShare(ParentId = claim2.Id, UserOrGroupId = intUser.Id, AccessLevel = 'Edit');
            Database.insert(sharewithIntUser);    
        }
        System.runAs(intUser){
            
            Core_MDF_PFC_Close_Adjustment.eligibilityToCloseWrapper eligibilityToClose = new Core_MDF_PFC_Close_Adjustment.eligibilityToCloseWrapper(); 
            eligibilityToClose.hasAccess = true;  
            
            PartnerFundClaim claim2 = [Select Id, OwnerId from PartnerFundClaim where Title = '[Adjustment] India Claim1' limit 1]; 
            System.debug('claim2' +claim2);
            List<id> claimList = new List<id>();
            claimList.add(claim2.Id);
            
            Core_MDF_PFC_Close_Adjustment.eligibilityToCloseWrapper partialOffsetClaim2 = Core_MDF_PFC_Close_Adjustment.claimEligibleForClose(claim2.Id);
            system.debug('partialOffsetClaim2-->' + partialOffsetClaim2);
            System.AssertEquals(false,eligibilityToClose.restrictClaimWithoutOffset);
            System.AssertEquals(false,eligibilityToClose.claimCannotBeClose);
            system.assertNotEquals(partialOffsetClaim2, NULL); 
        }
        
        Test.stopTest();
    }
    
    @isTest 
    static void  testAdjClaimWithCancelledSts(){
        Test.startTest();
        ChannelProgram cp = [SELECT ID From ChannelProgram where Name = 'Client Co-Marketing Fund'];
        ChannelProgram cp1 = [SELECT ID From ChannelProgram where Name = 'Data Center Co-Marketing Fund'];
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        User extUser = [SELECT Id,Email from User where Email='test1@example.com' limit 1];
        User intUser = [SELECT Id,Email from User where Email='test1vd@intel.com' limit 1];
        Group grp = [SELECT Id, Name, DeveloperName FROM Group where DeveloperName = 'Core_MDF_CCP_Claim_Case_Reviewer_Q_Group'];
        Group grp2 = [SELECT Id, Name, DeveloperName FROM Group where DeveloperName = 'Core_All_Users_CCP_Internal'];
        
        PartnerFundRequest indiaActivity = [SELECT Id,Title,Core_MDF_Start_Date__c,Core_MDF_End_Date__c from PartnerFundRequest where Title='indiaActivity' limit 1];
        
        Core_MDF_Bank__c indiaBank = [Select ID from Core_MDF_Bank__c limit 1];
        
        List<PartnerFundClaim> claimListToBeProcessed = new List<PartnerFundClaim>();
        
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
            System.debug('claim2' +claim2);
            List<id> claimList = new List<id>();
            claimList.add(claim2.Id);
            
            Core_MDF_PFC_Close_Adjustment.eligibilityToCloseWrapper claimWithCancelledSts = Core_MDF_PFC_Close_Adjustment.claimEligibleForClose(claim2.Id);
            system.debug('claimWithCancelledSts-->' + claimWithCancelledSts);
            //System.AssertEquals(true,eligibilityToClose.hasAccess);
            System.AssertEquals(false,eligibilityToClose.claimCannotBeClose);
            System.AssertEquals(false,eligibilityToClose.isPAF);
        }        
        Test.stopTest();
    }
    
    @isTest 
    static void  testCloseAdjWithoutOffset(){
        Test.startTest();
        ChannelProgram cp = [SELECT ID From ChannelProgram where Name = 'Client Co-Marketing Fund'];
        ChannelProgram cp1 = [SELECT ID From ChannelProgram where Name = 'Data Center Co-Marketing Fund'];
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        User extUser = [SELECT Id,Email from User where Email='test1@example.com' limit 1];
        User intUser = [SELECT Id,Email from User where Email='test1vd@intel.com' limit 1];
        Group grp = [SELECT Id, Name, DeveloperName FROM Group where DeveloperName = 'Core_MDF_CCP_Claim_Case_Reviewer_Q_Group'];
        Group grp2 = [SELECT Id, Name, DeveloperName FROM Group where DeveloperName = 'Core_All_Users_CCP_Internal'];
        
        PartnerFundRequest indiaActivity = [SELECT Id,Title,Core_MDF_Start_Date__c,Core_MDF_End_Date__c from PartnerFundRequest where Title='indiaActivity' limit 1];
        Core_MDF_Bank__c indiaBank = [Select ID from Core_MDF_Bank__c limit 1];
        
        List<PartnerFundClaim> claimListToBeProcessed = new List<PartnerFundClaim>();
        
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
            indiaClaim3.Core_MDF_Currency__c = 'USD';
            indiaClaim3.Core_MDF_Claim_Previous_Status__c ='Pending Available Fund';
            indiaClaim3.Core_MDF_Status__c ='Pending Available Fund';
            Database.insert(indiaClaim3);
            
            Core_MDF_Adjustment_Request__c adjustment1 = new Core_MDF_Adjustment_Request__c();          
            adjustment1.Core_MDF_Reference_Claim_Nbr__c = indiaClaim3.Id;
            adjustment1.Core_MDF_Amount_Amt__c = 2;
            adjustment1.Core_MDF_Reason_Cd__c = 'Claim Review Results (Negative)';            
            Database.insert(adjustment1);   
            
            List<PartnerFundClaim> pfc = new List<PartnerFundClaim>();
            PartnerFundClaim claim1 = [Select Id, OwnerId from PartnerFundClaim where Title = 'India Claim1'];
            PartnerFundClaim claim2 = [Select Id, OwnerId from PartnerFundClaim where Title = '[Adjustment] India Claim1' limit 1]; 
            claim2.Core_MDF_Type_Txt__c = 'Adjustment';
            pfc.add(claim2);
            Database.update(pfc);
            
            PartnerFundClaimShare sharewithIntUser = new PartnerFundClaimShare(ParentId = claim2.Id, UserOrGroupId = intUser.Id, AccessLevel = 'Edit');
            Database.insert(sharewithIntUser);            
        }        
        System.runAs(intUser){
            PartnerFundClaim adjClaimWithoutOffset = [Select Id,Core_MDF_Status__c,Core_MDF_Claim_Previous_Status__c from PartnerFundClaim where Title = '[Adjustment] India Claim1' limit 1]; 
            Core_MDF_PFC_Close_Adjustment.eligibilityToCloseWrapper adjustmentClaimWithoutOffset = Core_MDF_PFC_Close_Adjustment.claimEligibleForClose(adjClaimWithoutOffset.Id);      
            system.debug('adjustmentClaimWithoutOffset-->' +adjustmentClaimWithoutOffset);            
            system.assertNotEquals(adjustmentClaimWithoutOffset, NULL);  
        }
        Test.stopTest();
    }
    
    @isTest 
    static void  testclaimCannotBeClose(){
        Test.startTest();
        ChannelProgram cp = [SELECT ID From ChannelProgram where Name = 'Client Co-Marketing Fund'];
        ChannelProgram cp1 = [SELECT ID From ChannelProgram where Name = 'Data Center Co-Marketing Fund'];
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        User extUser = [SELECT Id,Email from User where Email='test1@example.com' limit 1];
        User intUser = [SELECT Id,Email from User where Email='test1vd@intel.com' limit 1];
        Group grp = [SELECT Id, Name, DeveloperName FROM Group where DeveloperName = 'Core_MDF_CCP_Claim_Case_Reviewer_Q_Group'];
        Group grp2 = [SELECT Id, Name, DeveloperName FROM Group where DeveloperName = 'Core_All_Users_CCP_Internal'];
        
        PartnerFundRequest indiaActivity = [SELECT Id,Title,Core_MDF_Start_Date__c,Core_MDF_End_Date__c from PartnerFundRequest where Title='indiaActivity' limit 1];
        
        Core_MDF_Bank__c indiaBank = [Select ID from Core_MDF_Bank__c limit 1];
        
        List<PartnerFundClaim> claimListToBeProcessed = new List<PartnerFundClaim>();
        
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
            indiaClaim3.Core_MDF_Currency__c = 'USD';
            indiaClaim3.Core_MDF_Claim_Previous_Status__c ='Pending Available Fund';
            indiaClaim3.Core_MDF_Status__c ='Pending Available Fund';
            Database.insert(indiaClaim3);
            
            Core_MDF_Adjustment_Request__c adjustment1 = new Core_MDF_Adjustment_Request__c();          
            adjustment1.Core_MDF_Reference_Claim_Nbr__c = indiaClaim3.Id;
            adjustment1.Core_MDF_Amount_Amt__c = 2;
            adjustment1.Core_MDF_Reason_Cd__c = 'Claim Review Results (Negative)';            
            Database.insert(adjustment1);   
            
            List<PartnerFundClaim> pfc = new List<PartnerFundClaim>();
            PartnerFundClaim claim1 = [Select Id, OwnerId from PartnerFundClaim where Title = 'India Claim1'];
            PartnerFundClaim claim2 = [Select Id, OwnerId from PartnerFundClaim where Title = '[Adjustment] India Claim1' limit 1]; 
            claim2.Core_MDF_Type_Txt__c = 'Adjustment';
            claim2.Core_MDF_Status__c ='Hold';
            pfc.add(claim2);
            Database.update(pfc);
            
            PartnerFundClaimShare sharewithIntUser = new PartnerFundClaimShare(ParentId = claim2.Id, UserOrGroupId = intUser.Id, AccessLevel = 'Edit');
            Database.insert(sharewithIntUser);            
        }
        System.runAs(intUser){
            PartnerFundClaim claimCannotBeClose = [Select Id,Core_MDF_Status__c,Core_MDF_Claim_Previous_Status__c from PartnerFundClaim where Title = '[Adjustment] India Claim1' limit 1]; 
            Core_MDF_PFC_Close_Adjustment.eligibilityToCloseWrapper adjustmentClaimCannotBeClose = Core_MDF_PFC_Close_Adjustment.claimEligibleForClose(claimCannotBeClose.Id);      
            system.debug('adjustmentClaimCannotBeClose-->' +adjustmentClaimCannotBeClose);            
            system.assertNotEquals(adjustmentClaimCannotBeClose, NULL);  
        }
        Test.stopTest();
    }
    
    @isTest static void validateAdjustmentOffset(){ 
       Test.startTest();
        //ChannelProgram cp = [SELECT ID From ChannelProgram where Name = 'Client Co-Marketing Fund'];
        //ChannelProgram cp1 = [SELECT ID From ChannelProgram where Name = 'Data Center Co-Marketing Fund'];
        
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        User intUser = [SELECT Id,Email from User where Email='test1vd@intel.com' limit 1];
        //Group grp = [SELECT Id, Name, DeveloperName FROM Group where DeveloperName = 'Core_MDF_CCP_Claim_Case_Reviewer_Q_Group'];
        Group grp2 = [SELECT Id, Name, DeveloperName FROM Group where DeveloperName = 'Core_All_Users_CCP_Internal'];
        
        /*PartnerFundRequest indiaActivity = [SELECT Id,Title,Core_MDF_Start_Date__c,Core_MDF_End_Date__c from PartnerFundRequest where Title='indiaActivity' limit 1];
        Core_MDF_Bank__c indiaBank = [Select ID from Core_MDF_Bank__c limit 1];
        PartnerFundClaim indiaClaim3 = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, indiaActivity.Id, System.today(), System.today(), 5000.00, System.today(), indiaBank.Id, false);
        indiaClaim3.Status = Label.Core_MDF_Status_Approved;
        indiaClaim3.Core_MDF_Status__c = Label.Core_MDF_Status_Payment_Due;
        Insert indiaClaim3;*/

        System.runAs(sysAdminUser){            
            PermissionSet claimCaseReviewerPermissionSet = [SELECT Id, Name FROM PermissionSet where Name = 'Core_MDF_CCP_Internal_Claim_Case_Reviewer_Manager'];        
            PermissionSetAssignment  psa = new PermissionSetAssignment(PermissionSetId = claimCaseReviewerPermissionSet.Id, AssigneeId = intUser.Id);
            insert psa;

            /*GroupMember grpMem = new GroupMember();
            grpMem.GroupId = grp.Id;
            grpMem.UserOrGroupId = intUser.Id;*/
            GroupMember grpMem2 = new GroupMember();
            grpMem2.GroupId = grp2.Id;
            grpMem2.UserOrGroupId = intUser.Id;
            Database.insert(grpMem2);

            PartnerFundClaim claim = [Select Id, OwnerId from PartnerFundClaim where Title = 'Test Claim' limit 1];
            claim.OwnerId = intUser.id;
            //claim.Owner.Email='test1vd@intel.com';
            database.update(claim);
            
            Core_MDF_Adjustment_Request__c adjReq = Core_MDF_CCP_TestDataUtility.createAdjustmentReq(claim.Id, 'Claim Review Results (Negative)', 2000.00, true);
            Test.stopTest();
           /* Core_MDF_Adjustment_Request__c adjustment1 = new Core_MDF_Adjustment_Request__c();          
            adjustment1.Core_MDF_Reference_Claim_Nbr__c = claim.Id;
            adjustment1.Core_MDF_Amount_Amt__c = 2000;
            adjustment1.Core_MDF_Reason_Cd__c = 'Claim Review Results (Negative)';
            
            Database.insert(adjustment1);*/
            
            
            PartnerFundClaim claim1 = [Select Id, Amount, Core_MDF_Status__c, OwnerId from PartnerFundClaim where Title = 'Test Claim' limit 1];
            PartnerFundClaim claim2 = [Select Id, Core_MDF_Total_Invoice_Amount_Local__c, Amount, Core_MDF_Status__c, OwnerId from PartnerFundClaim where Title = '[Adjustment] Test Claim' limit 1];   
            System.debug('claim2: '+claim2);
            
            
            claim2.Amount = -500;
            //claim1.Amount =0.0;
            claim2.Core_MDF_Status__c = Label.Core_MDF_Status_Pending_Available_Fund;
            claim1.Core_MDF_Status__c = Label.Core_MDF_Status_Paid;
            List<PartnerFundClaim> claims = new List<PartnerFundClaim>();
            claims.add(claim1);
            claims.add(claim2);
            database.update(claims);
            PartnerFundClaim claim3 = [Select Id, Amount, Core_MDF_Status__c, OwnerId from PartnerFundClaim where Title = 'Test Claim' limit 1];
            PartnerFundClaim claim4 = [Select Id, Core_MDF_Type_txt__c, Core_MDF_Total_Invoice_Amount_Local__c, Amount, Core_MDF_Status__c, OwnerId from PartnerFundClaim where Title = '[Adjustment] Test Claim' limit 1];
            System.debug('claim4: '+claim4);
            Core_MDF_Claim_Offset__c offset = New Core_MDF_Claim_Offset__c();
            offset.Core_MDF_Offset_Amount_Amt__c = 1000;
            offset.Core_MDF_Adjustment_Claim_Nbr__c = claim4.Id;
            offset.Core_MDF_Offset_Claim_Nbr__c = claim3.Id;
            database.insert(offset);
            List<Id> closeClaims = new List<Id>();
            closeClaims.add(claim4.id);
            boolean partialOffsetClaim = Core_MDF_PFC_Close_Adjustment.closeClaims(closeClaims);
            system.AssertEquals(true,partialOffsetClaim);
            
        }
    }    
}