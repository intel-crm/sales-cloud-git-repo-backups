@isTest(SeeAllData=false)
public class Core_MDF_PIC_SendEmailToClaimOwner_Test {
    /* Method to Setup Test Data */
    @testSetup 
    static void setup() {  
        /*List<Core_Trigger_Executions__c> transactions = new List<Core_Trigger_Executions__c>();
        transactions.addAll(Core_MDF_CCP_TestDataUtility.byPassFeature(new List<String>{'Bypass_Duplicate_Budget_Check','Bypass_GeoBased_Budget_Sharing', 'Bypass_MDF_Budget_Access_Validation', 'Bypass_MDF_Budget_Access'}, true, false));       
        transactions.addAll(Core_MDF_CCP_TestDataUtility.byPassFeature(new List<String>{'Bypass_Allocation_Reservation','Bypass_GeoBased_Allocation_Sharing', 'Bypass_UniqueFieldPopulationAllocation','Bypass_SharePfaWithAccountExtGrp'}, true, false));   
        transactions.addAll(Core_MDF_CCP_TestDataUtility.byPassFeature(new List<String>{'Bypass_Duplicate_Bank_Check','Bypass_Bank_Internal_Sharing','Bypass_StampingOfActySubType_Check',
        'Bypass_Bank_External_Sharing','Bypass_Bank_Program_InActivation_Check','Bypass_Bank_ABM_Sharing'}, true, false));
        transactions.addAll(Core_MDF_CCP_TestDataUtility.byPassFeature(new List<String>{'Bypass_ABM_Internal_Sharing','Bypass_ABM_External_Sharing','Bypass_ABM_NodeGroup_Sharing'}, true, false));
        Database.insert(transactions);*/

        ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.CCF_PROGRAM,'Client CoMarketing Fund', true); 
        
        Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Acc New 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
        
        List<Contact> listContact = new List<Contact>();
        Contact conRecord1 = Core_MDF_CCP_TestDataUtility.createContact(acc1.Id,false);
        Contact conRecord2 = Core_MDF_CCP_TestDataUtility.createContact(acc1.Id,false);
        listContact.add(conRecord1);
        listContact.add(conRecord2);
        
        Database.insert(listContact);
        
        ChannelProgram cpIPA = Core_MDF_CCP_TestDataUtility.createProgram ('Intel Partner Alliance','Intel Partner Alliance', true);
        Id acctRecord_Type = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Core_Partner_Account_Group').getRecordTypeId();
        Account acc = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test IPA Accounttest', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
        
        Account accIPA1 = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test IPA Account', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
        accIPA1.Core_Intel_Partner_Alliance_PartnerGroup__c=true;
        accIPA1.Core_MDF_CoMarketingActive__c = true;
        accIPA1.Core_MDF_CoMarketing_Ultimate_Account__c = acc.Id;
        accIPA1.Core_IPA_One_Partner_Id__c=acc.id;
        List<Account> acctList = new List<Account>();
        acctList.add(accIPA1);
        insert(acctList);
        accIPA1.isPartner = true;
        Database.update(accIPA1);
        
        Account accIPA2 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account 2', cpIPA.Id, Core_MDF_CCP_TestDataUtility.account_Record_Type, accIPA1.Id, false);
        accIPA2.Core_Geo__c='APJ';
        accIPA2.Core_Sub_Geo__c='';
        accIPA2.BillingCity = 'Test City';         
        accIPA2.BillingCountry= 'AUS';
        accIPA2.BillingStreet= 'Test Street';
        accIPA2.Core_MDF_Channel_Program__c = cpIPA.Id;
        accIPA2.Core_MDF_Payment_Type_nm__c = 'Distributor (Credit Memo)';
        insert accIPA2;
        
        Id profileId = [SELECT Id FROM Profile WHERE Name='Partner' limit 1].Id;
        Profile ccpCoreProfile = [SELECT Id FROM Profile WHERE Name='CCP - Core Access' LIMIT 1];
        PermissionSet clmCaseRevPS = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_Internal_Claim_Case_Reviewer' LIMIT 1];
        
        List<Core_AGS_Role__c> agsRoleList = new List<Core_AGS_Role__c>();
        
        Core_AGS_Role__c agsRoleCCF = Core_MDF_CCP_TestDataUtility.createAgsRole('CCF_USER', 'Co-Marketing(Salesforce)-CCF USER', true, false);
        agsRoleList.add(agsRoleCCF);
        
        Core_AGS_Role__c agsRoleCCFClaimSub = Core_MDF_CCP_TestDataUtility.createAgsRole('Co-Marketing(Salesforce)-External Claim Submitter-CCF', 'Co-Marketing(Salesforce)-External Claim Submitter-CCF', true, false);
        agsRoleList.add(agsRoleCCFClaimSub);
        
        Database.insert(agsRoleList);        
        
        Core_ERPM_Engagement__c erpmEngagementCCF = Core_MDF_CCP_TestDataUtility.createErpmEngagement('CCF', 'CCF', 'DEDUPB2B', 'SEC', true, false);
        Database.insert(erpmEngagementCCF);
        
        List<Core_Entitlement__c> entitlementList = new List<Core_Entitlement__c>();
        
        Core_Entitlement__c entitlementCCF = Core_MDF_CCP_TestDataUtility.createEntitlement('Client User',agsRoleCCF.Id ,'Intel® Partner Investment Center','CCF User',erpmEngagementCCF.Id , true,'Client',false);
        entitlementList.add(entitlementCCF);
        
        Core_Entitlement__c entitlementCCFClaimSub = Core_MDF_CCP_TestDataUtility.createEntitlement('Client Claim Submitter',agsRoleCCFClaimSub.Id ,'Intel® Partner Investment Center','CCF Claim Submitter',erpmEngagementCCF.Id , true,'Client',false);
        entitlementList.add(entitlementCCFClaimSub);
        
        Database.insert(entitlementList); 
        
        List<Core_Contact_Entitlement__c> contEntList = new List<Core_Contact_Entitlement__c>();
        
        Core_Contact_Entitlement__c contactEntitlementCCF = Core_MDF_CCP_TestDataUtility.createContactEntitlement(conRecord1.Id,entitlementCCF.Id ,true,'Complete', false);
        contEntList.add(contactEntitlementCCF);
        
        Core_Contact_Entitlement__c contactEntitlementCCFClaimSub = Core_MDF_CCP_TestDataUtility.createContactEntitlement(conRecord1.Id,entitlementCCFClaimSub.Id ,true,'Complete', false);
        contEntList.add(contactEntitlementCCFClaimSub);
        
        Database.insert(contEntList);       
        
        List<User> listUser = new List<User>();
        
        User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);        
        usr1.Email='test1@example.com';
        usr1.ContactId = conRecord1.Id;
        usr1.ProfileId = profileId;
        usr1.isActive = true;
        listUser.add(usr1);        
        
        User usr2 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr2.Email='test123@example.com';
        usr2.ContactId = listContact[1].Id;
        usr2.ProfileId = profileId;
        usr2.isActive = true;
        listUser.add(usr2);
        
        User usr3 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr3.Email = 'sysadmin@example.com';
        listUser.add(usr3);
        
        //Login as claim claim Case reviewer
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User ccrUser = Core_MDF_CCP_TestDataUtility.createUser(false);
        ccrUser.Email='testCCR@example.com';
        ccrUser.ProfileId = p.id;
        listUser.add(ccrUser);
        
        //creating system admin user
        User sysAdmUsr = Core_MDF_CCP_TestDataUtility.createUser(false);
        sysAdmUsr.LastName = 'System Adm';
        listUser.add(sysAdmUsr);
        
        //creating claim case user
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName='Claim Case User';
        usr.profile=ccpCoreProfile;
        listUser.add(usr);
        
        Database.insert(listUser);  
        
        Group grp = new Group();
        grp.name = 'PGM_TEST';
        insert grp;
        system.runAs(sysAdmUsr){
            
            //Data prep for IPA outcome based claim - start
           
            //Data prep for IPA outcome based claim - end
            
            GroupMember gm = new GroupMember();
            gm.GroupId = grp.Id;
            gm.UserOrGroupId = usr1.Id;
            insert gm;
            
            //asigning permission set to claim case user
            PermissionSetAssignment assignPermissionSetObj = new PermissionSetAssignment();
            assignPermissionSetObj.AssigneeId = usr.Id;
            assignPermissionSetObj.PermissionSetId = clmCaseRevPS.Id;
            
            Database.insert(assignPermissionSetObj);
            
            Account acc2 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Acc New 2', cp.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc1.Id, true);
            
            
            Core_MDF_CCP_TestDataUtility.createPartnerGroupMapping(acc1.Id,'Internal',acc1.Id,cp.Id,'PGM_TEST',true);
            
            List<Core_MDF_Bank__c> listBank = new List<Core_MDF_Bank__c>();
            List<Core_MDF_Bank__c> bankList = new List<Core_MDF_Bank__c>();       
            
            
            Core_MDF_Bank__c bank = Core_MDF_CCP_TestDataUtility.createBank(acc1.Id, 'Core_MDF_Client_CoMarketing_Fund', false,'1231231230');
            bank.Core_MDF_Bank_Status__c='Active';
            listBank.add(bank);
            
            Core_MDF_Bank__c bank1 = Core_MDF_CCP_TestDataUtility.createBank(acc1.Id, 'Core_MDF_Client_CoMarketing_Fund', false,'1241241240');
            bank1.Core_MDF_Bank_Status__c='Active';
            bank1.Core_MDF_Bank_Location__c ='AM';
            listBank.add(bank1); 
            
            Core_MDF_Bank__c bank2 = Core_MDF_CCP_TestDataUtility.createBank(acc1.Id, 'Core_MDF_Client_CoMarketing_Fund', false,'1249641240');
            bank2.Core_MDF_Bank_Status__c='Active';
            bank2.Core_MDF_Bank_Location__c ='IN';
            listBank.add(bank2);
            
            Database.insert(listBank);
            
            bank.Core_MDF_Bank_Alias_Name__c='TestActiveBank1';
            BankList.add(bank);
            
            bank1.Core_MDF_Bank_Alias_Name__c='TestActiveBank2';
            BankList.add(bank1);              
            
            bank2.Core_MDF_Bank_Alias_Name__c='TestActiveBank3';
            BankList.add(bank2); 
            
            Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 13','Gaming','Intel® Core™ i7 Processor','Yes', Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', System.today().addDays(-15), System.today().addDays(15), 10000, 'Always Connected PC', acc2.Id,'Desktop', false);             
            camp.Core_MDF_Opal_Budget_Type_Txt__c = 'OEM CMP';
            Database.insert(camp);
            Core_MDF_CCP_TestDataUtility.insertCurrencyExchangeRates();
            //adding bypass feature to bypass access validation
      List<String> bypassFunctionKeys = new List<String>();

            bypassFunctionKeys.add('Bypass_Duplicate_Budget_Check');
            bypassFunctionKeys.add('Bypass_GeoBased_Budget_Sharing');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Access');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Access_Validation');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Status_Validation');
            bypassFunctionKeys.add('Bypass_ShareActivityWithUsers');
            bypassFunctionKeys.add('Bypass_Activity_ApprovalProcess');
            bypassFunctionKeys.add('Bypass_ShareActivityWithAccNodeGroup');
            bypassFunctionKeys.add('ShareActivityWithInternalUsers_Bypass');
            bypassFunctionKeys.add('Bypass_ABM_Internal_Sharing');
            bypassFunctionKeys.add('Bypass_ABM_External_Sharing');
            bypassFunctionKeys.add('Bypass_ABM_NodeGroup_Sharing');
            bypassFunctionKeys.add('ByPass_BlockLegacyBudgetCreation');
            bypassFunctionKeys.add('Core_MDF_Bypass_BudgetApvrNotification');
            bypassFunctionKeys.add('Core_MDF_Bypass_ATFBatchUpdate');
            bypassFunctionKeys.add('Bypass_geoLeadApprovalProcess');
            bypassFunctionKeys.add('Bypass_Allocation_Reservation');
            bypassFunctionKeys.add('Bypass_Duplicate_Bank_Check');
            bypassFunctionKeys.add('Bypass_Bank_Internal_Sharing');
            bypassFunctionKeys.add('Bypass_Bank_External_Sharing');
            bypassFunctionKeys.add('Bypass_Bank_ABM_Sharing');
            bypassFunctionKeys.add('byPassShareUnshareCampaignRecord');
            bypassFunctionKeys.add('byPassCampaignAndRelatedRecords');
            bypassFunctionKeys.add('Bypass_PaymentRun_Duplicate_Check');
            bypassFunctionKeys.add('Bypass_Claims_Duplicate_Check');
            bypassFunctionKeys.add('Bypass_Claims_Sharing_Internal_Users');
            bypassFunctionKeys.add('Bypass_Claims_Amt_vs_Budget_Amt_Check');
            bypassFunctionKeys.add('Bypass_Claims_ABM_Validation');
            bypassFunctionKeys.add('Bypass_Claims_Sharing_Partner_Users');
            bypassFunctionKeys.add('Bypass_Payment_Doc_InvFileVAT_Validate');
            bypassFunctionKeys.add('Bypass_Bank_Program_InActivation_Check');
            bypassFunctionKeys.add('Bypass_Claims_Amt_vs_Camp_Amt_Check');
            bypassFunctionKeys.add('Bypass_Claim_OwnerLang_EmailTemp');
            bypassFunctionKeys.add('Bypass_StampingOfActySubType_Check');
            bypassFunctionKeys.add('Bypass_Claims_Sharing_On_Owner_Change');
            bypassFunctionKeys.add('Bypass_UpdateActivityFields');
            bypassFunctionKeys.add('Bypass_ValidateActivityWithCampaign');
            bypassFunctionKeys.add('Core_MDF_XMLToXLSGenerationFlag');
            bypassFunctionKeys.add('Core_MDF_StringToXLSGenerationFlag');
            bypassFunctionKeys.add('Core_MDF_Bypass_PMB_Trigger');

            Set<String> myset1 = new Set<String>();
            List<String> result1 = new List<String>();
            myset1.addAll(bypassFunctionKeys);
            result1.addAll(myset1);
            
            List<Core_Trigger_Executions__c> bypassfunctinalitylist1 = Core_MDF_CCP_TestDataUtility.byPassFeature(result1,true,true);
            
            PartnerMarketingBudget budget = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget New CCF 1.0',Core_MDF_CCP_TestDataUtility.budget_Record_Type,acc2.Id,cp.Id,200000,System.today().addDays(-2),System.today().addDays(20), false);
            budget.Core_MDF_Budget_Type_Txt__c='CCF 1.0';
            Database.insert(budget);
            test.startTest();   
            
            //string budgetType = Core_MDF_CCP_IPA_TestDataUtility.createBenefit(accIPA2);
            string budgetType = 'Proposal I MDF';
            PartnerMarketingBudget budgetIPA = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget New',Core_MDF_CCP_IPA_TestDataUtility.budgetIPA_ProposalBased_Record_Type,accIPA2.Id,cpIPA.Id,2000,System.today().addDays(-20),System.today(), false);
            budgetIPA.Core_MDF_Budget_Type_Txt__c= budgetType;
            budgetIPA.Core_MDF_Program__c = cpIPA.Id;
            Database.insert(budgetIPA);
            
            PartnerFundAllocation allocation = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test Allocation New',budget,acc2,200.0,true);
            // Highlight: Unused Local Variable - Indira
           // PartnerMarketingBudget pmb1 = [SELECT Id,Title, Core_MDF_Budget_Status__c, TotalAllocatedAmount FROM PartnerMarketingBudget WHERE Title ='Test Budget New CCF 1.0'];
            
            
            List<Core_MDF_Account_Bank_Mapping__c> abmList = new List<Core_MDF_Account_Bank_Mapping__c>();
            
            //creating ABM for bank1                    
            Core_MDF_Account_Bank_Mapping__c abm1 = Core_MDF_CCP_TestDataUtility.createAccountBankMap(acc2.Id,bank.Id,false);
            abmList.add(abm1);
            Core_MDF_Account_Bank_Mapping__c abm2 = Core_MDF_CCP_TestDataUtility.createAccountBankMap(acc2.Id,bank1.Id,false);
            abmList.add(abm2);
            //creating ABM for bank2
            Core_MDF_Account_Bank_Mapping__c abm = Core_MDF_CCP_TestDataUtility.createAccountBankMap(acc2.Id,bank2.Id,false);
            abmList.add(abm);
            Database.insert(abmList);
            abm.Core_MDF_Active_ind__c=false;
            
            PartnerFundRequest testPartnerFundRequest = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(String.valueof(camp.Id), 
                                                                                                              Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                                              String.valueof(acc2.id),allocation,null,'INDIA',
                                                                                                              'Consumer',
                                                                                                              'Desktop',
                                                                                                              'Intel® Core™ i5 Processor',
                                                                                                              'Broadcast (Pre-2025)',
                                                                                                              'Podcast',
                                                                                                              'Draft',
                                                                                                              false);
            
            
            testPartnerFundRequest.Core_MDF_Start_Date__c = system.today().addDays(-1);
            testPartnerFundRequest.Core_MDF_End_Date__c  = system.today().addDays(10);
            testPartnerFundRequest.Core_MDF_Country_nm__c = 'INDIA';
            testPartnerFundRequest.amount = 1000;
            testPartnerFundRequest.Core_MDF_Budget_Type_nm__c = 'OEM CMP';
            testPartnerFundRequest.ChannelPartnerId=acc2.Id;
            testPartnerFundRequest.Core_MDF_Reimbursement_Rate_txt__c='60%';
            insert testPartnerFundRequest;
            //inserting currency data
        }
        Core_MDF_Configuration__c config8 = new Core_MDF_Configuration__c();
        config8.Core_MDF_Value__c = 'Core_MDF_CCP_RMF_Internal_Claim_Operations';
        config8.Name = 'PRC_CLAIM_OPERATION_CUSTOM_PERMISSION';
        insert config8;
        Core_MDF_Configuration__c config9 = new Core_MDF_Configuration__c();
        config9.Core_MDF_Value__c = 'MDF,MDF+';
        config9.Name = 'BUDGET_TYPE_CLAIM_BANK_HIDE';
        insert config9;        
        Core_MDF_CCP_TestDataUtility.createMDFConfigurationData();
    }
    
    /* Method to test Send Email To Claim Owner */
    @isTest
    static void testSendEmailToClaimOwner()
    {
        Test.startTest();
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        System.runAs(sysAdminUser){
            Account acc2 = [Select id from Account where Name = 'Test Acc New 2'];
            User Usr1 =[Select id from user where email = 'test1@example.com'];
            Core_MDF_CCP_TestDataUtility.createPartnerNodeUserMapping(acc2.Id, Usr1.Id, true);
            Core_MDF_Bank__c bank1 = [Select Id from Core_MDF_Bank__c where Core_MDF_Supplier_Number__c='1241241240' limit 1];
            PartnerFundRequest pfr = [Select Id,Title from PartnerFundRequest where Title = 'test'];
            
            //PartnerFundClaim
            List<PartnerFundClaim> claimList = new List<PartnerFundClaim>();
            PartnerFundClaim claim1 = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim1', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, pfr.Id, System.today(), System.today(), 50.00, System.today(), bank1.Id, false);
            //claim1.Core_MDF_Total_Review_Duration_Mins_nbr__c = 2;
            claim1.Core_MDF_Processing_Preference_nm__c = 'Get paid, then settle';
            claimList.add(claim1);
            PartnerFundClaim claim2 = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim2', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, pfr.Id, System.today(), System.today(), 50.00, System.today(), bank1.Id, false);
            //claim2.Core_MDF_Total_Review_Duration_Mins_nbr__c = 2;
            claim2.Core_MDF_Processing_Preference_nm__c = 'Get paid, then settle';
            claimList.add(claim2);
            
            if(!claimList.isEmpty()){
                insert claimList;
            }
            
            //PIC Review Questions
            List<core_MDF_PICReviewQuestion__c> questionList = new List<core_MDF_PICReviewQuestion__c>();
            core_MDF_PICReviewQuestion__c question1 = createPICReviewQuestion(new PICReviewQuestionWrapper(1, 'Internal English question', 'External English Issue', false));   // ATHR Avoid long parameter lists - Indira
            questionList.add(question1);
            core_MDF_PICReviewQuestion__c question2 = createPICReviewQuestion(new PICReviewQuestionWrapper(2, 'Internal English question1', 'External English Issue1', false));    // ATHR Avoid long parameter lists - Indira
            questionList.add(question2);
            
            if(!questionList.isEmpty()){
                insert questionList;
            }
            

            //PIC Review
            List<Core_MDF_PIC_Review__c> reviewList = new List<Core_MDF_PIC_Review__c>();
            Core_MDF_PIC_Review__c review1 = createPICReviewResult(new PICReviewWrapper(claim1.Id,  1, 'Failed', false));   // ATHR Avoid long parameter lists - Indira
            reviewList.add(review1);
            Core_MDF_PIC_Review__c review2 = createPICReviewResult(new PICReviewWrapper(claim2.Id, 2, 'Failed', false));    // ATHR Avoid long parameter lists - Indira
            reviewList.add(review2);
            
            if(!reviewList.isEmpty()){
                insert reviewList;
            }

            //PIC Review Result
            List<core_MDF_PICReviewResult__c> resultList = new List<core_MDF_PICReviewResult__c>();
            core_MDF_PICReviewResult__c result1 = createPICReviewResult(new PICReviewResultWrapper(review1.Id, question1.Id, 'testFile.xls', 'No', false));   // ATHR Avoid long parameter lists - Indira
            resultList.add(result1);
            core_MDF_PICReviewResult__c result2 = createPICReviewResult(new PICReviewResultWrapper(review2.Id, question2.Id, '', 'No', false));    // ATHR Avoid long parameter lists - Indira
            resultList.add(result2);
            
            if(!resultList.isEmpty()){
                insert resultList;
            }
            
            for(PartnerFundClaim claim : claimList){
                claim.Core_MDF_Doc_Hold_Doc_Sub_Due_Date_Dtm__c = system.now() + Integer.valueOf(Label.Core_MDF_Document_Submission_Days);
                claim.Core_MDF_Status__c = 'Resubmission Required';
                claim.Core_MDF_Legacy_Reminder_txt__c = Label.Core_MDF_Legacy_Reminder_1;          
            }
            update claimList;
                     
            System.assertEquals(2, [SELECT Id FROM PartnerFundClaim].size());
            
            Test.stopTest();
        }
    }

  //  public static Core_MDF_PIC_Review__c createPICReviewResult(String claimId, Integer cycleNumber, String status, Boolean isInsert){
  // ATHR Avoid long parameter lists - Indira - start 
    public static Core_MDF_PIC_Review__c createPICReviewResult(PICReviewWrapper wrapper) {
    // Immediately unpack wrapper into local variables
    String claimId = wrapper.claimId;
    Integer cycleNumber = wrapper.cycleNumber;
    String status = wrapper.status;
    Boolean isInsert = wrapper.isInsert;
   // ATHR Avoid long parameter lists - Indira - end
          
        Core_MDF_PIC_Review__c newreview = new Core_MDF_PIC_Review__c(Core_MDF_Claim_ID_id__c = claimId, Core_MDF_CycleNumber_nbr__c = cycleNumber, Core_MDF_Review_Status_nm__c = status,
                                                                    Core_MDF_StartTime_dtm__c = system.now(), Core_MDF_EndTime_dtm__c = system.now().addMinutes(2));
        if(isInsert){
            insert newreview;
        }
        return newreview;
    }
    
   // public static core_MDF_PICReviewResult__c createPICReviewResult(String picReviewId, String questionId, String filesAffected, String response, Boolean isInsert){
   // ATHR Avoid long parameter lists - Indira - start
    public static core_MDF_PICReviewResult__c createPICReviewResult(PICReviewResultWrapper wrapper) {
    // Immediately unpack wrapper into local variables
    String picReviewId = wrapper.picReviewId;
    String questionId = wrapper.questionId;
    String filesAffected = wrapper.filesAffected;
    String response = wrapper.response;
    Boolean isInsert = wrapper.isInsert;
    // ATHR Avoid long parameter lists - Indira - end
        core_MDF_PICReviewResult__c newResult = new core_MDF_PICReviewResult__c(Core_MDF_PIC_Review_id__c = picReviewId, Core_MDF_Question_id__c=questionId,
                                                                               Core_MDF_FilesAffected_txt__c = filesAffected,
                                                                               Core_MDF_Response_txt__c = response);
        if(isInsert){
            insert newResult;
            Assert.areNotEqual(null,newResult.id);
        }
        return newResult;
    }
    
   // public static core_MDF_PICReviewQuestion__c createPICReviewQuestion(Integer sortOrder, String englishText, String englishTextExternal, Boolean isInsert){
   // ATHR Avoid long parameter lists - Indira - start
   public static core_MDF_PICReviewQuestion__c createPICReviewQuestion(PICReviewQuestionWrapper wrapper) {
    // Immediately unpack wrapper into local variables
    Integer sortOrder = wrapper.sortOrder;
    String englishText = wrapper.englishText;
    String englishTextExternal = wrapper.englishTextExternal;
    Boolean isInsert = wrapper.isInsert;
     // ATHR Avoid long parameter lists - Indira - end  
        core_MDF_PICReviewQuestion__c newQuestion = new core_MDF_PICReviewQuestion__c(Core_MDF_Sort_Order__c = sortOrder, Core_MDF_Question_English_txt__c=englishText,
                                                                               Core_MDF_Question_English_External_txt__c = englishTextExternal, Core_MDF_Is_Active_ind__c = true,
                                                                               Core_MDF_EffectiveDate_dt__c = System.today(), Core_MDF_IneffectiveDate_dt__c = System.today() + 10,
                                                                               Core_MDF_All_Budget_Types_Ind__c = true, Core_MDF_All_Programs_Ind__c = true);
        if(isInsert){
            insert newQuestion;
            Assert.areNotEqual(null,newQuestion.id);
        }
        return newQuestion;
    }
    
     @isTest
    static void testOutcomeBasedPICFailEmail() {
      
        test.startTest();
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        System.runAs(sysAdminUser){
        ChannelProgram cpIPA = [Select Id from ChannelProgram where Name = 'Intel Partner Alliance'];
        
        Account accIPA2 = [Select Id from Account where Name = 'Test Account 2'];
        PartnerMarketingBudget budgetIPA = [Select Id, Core_MDF_Budget_Type_Txt__c from PartnerMarketingBudget where Title = 'Test Budget New'];
        PartnerFundAllocation pfaIPA = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('allocation',budgetIPA,accIPA2, 10,true);
        
        Core_MDF_Account_Node_Attributes__c accNodeAttr = new Core_MDF_Account_Node_Attributes__c();
        accNodeAttr.Core_MDF_Account_id__c = accIPA2.Id;
        accNodeAttr.Core_MDF_Program_id__c = cpIPA.Id;
        accNodeAttr.Core_MDF_CSAR_GL_Account_nbr__c = 402110;
        accNodeAttr.Core_MDF_NonPO_GL_Account_nbr__c = 506710;
        accNodeAttr.Core_MDF_Customer_NonPO_GL_Account_nbr__c = 244200;
        insert accNodeAttr;
        
        Campaign campIPA = Core_MDF_CCP_IPA_TestDataUtility.createIPACampaign('Test IPA Camp',accIPA2.Id, System.today().addDays(-30), System.today().addDays(300),'Business Client Acceleration - MDF', 1234.00, 'AFGHANISTAN','Consumer','','Planned', false);
        campIPA.Core_MDF_Region_cd__c = 'APJ';
        campIPA.Core_MDF_Budget_Type_txt__c = 'Proposal I MDF';
        campIPA.Core_MDF_Budget__c = budgetIPA.Id;
        campIPA.Core_MDF_Reimbursement_Amt__c = 1000;
        campIPA.Core_MDF_CampOutcomeOpt_In_Ind__c=true;
        campIPA.Core_MDF_Outcomes_nm__c='Volume - Units';
        Database.insert(campIPA);
        
        Core_MDF_Campaign_Outcomes__c outcome = new Core_MDF_Campaign_Outcomes__c();
        outcome.Core_MDF_Campaign_Id__c = campIPA.Id;
        outcome.Core_MDF_Active_Ind__c = true;
        outcome.Core_MDF_Quantity_nbr__c = 100;
        outcome.Core_MDF_Outcome_Criteria_txt__c = 'test';
        insert outcome;
        
        PartnerFundRequest pfrIPA = Core_MDF_CCP_IPA_TestDataUtility.createIPAPartnerFundRequest(campIPA.Id,accIPA2.Id,System.today().addDays(-25),System.today().addDays(25),false);
        pfrIPA.amount = 500;
        pfrIPA.Core_MDF_Reimbursement_Rate_txt__c='60%';
        pfrIPA.Core_MDF_Budget_Type_nm__c = 'Proposal I MDF';
        pfrIPA.AllocationId = pfaIPA.Id;
        pfrIPA.Core_MDF_ActivityCategory__c = 'Outcome-Based';
        pfrIPA.Core_MDF_Activity_Types__c = 'Outcome-Based';
        Database.insert(pfrIPA);
        List<Campaign> campToBeUpdated = new List<Campaign>();
        List<PartnerFundRequest> pfrToBeUpdated = new List<PartnerFundRequest>(); 
        campIPA.Status = 'Proposal Accepted';
        campToBeUpdated.add(campIPA);
        Database.update(campToBeUpdated);
        
        pfrIPA.Core_MDF_Fund_Request_Status__c = 'Planned';
        pfrIPA.Status = 'Approved';
        pfrIPA.Core_MDF_Reimbursement_Rate_pct__c ='100%';
        pfrToBeUpdated.add(pfrIPA);
        Database.update(pfrToBeUpdated);
        
        PartnerFundClaim claimIPA =  Core_MDF_CCP_IPA_TestDataUtility.createIPAClaim('IPA Claim',Core_MDF_CCP_IPA_TestDataUtility.claim_RecordType_IPA, pfrIPA.Id, System.today().addDays(-20), System.today().addDays(-5),5.00, null, false); 
        claimIPA.Core_MDF_Type_Txt__c ='Claim';
        claimIPA.Core_MDF_Currency__c='USD';
        claimIPA.Core_MDF_Country_Location_nm__c= 'AFGHANISTAN'; 
        claimIPA.Core_MDF_Campaign_Id__c = campIPA.Id;
        claimIPA.Core_MDF_VAT_Opt_In__c = 'Service Invoice to Intel (VAT may apply)';
        claimIPA.Core_MDF_VAT_Eligibility_Ind__c= true ; 
        claimIPA.Core_MDF_VAT_Hold_Ind__c = true;
        claimIPA.Core_MDF_Paid_By_Payment_Type_nm__c = 'Distributor (Credit Memo)';
        claimIPA.Core_MDF_Processing_Preference_nm__c = 'Get paid, then settle';
        insert claimIPA;
        
            List<core_MDF_PICReviewQuestion__c> questionList = new List<core_MDF_PICReviewQuestion__c>();
            core_MDF_PICReviewQuestion__c question1 = createPICReviewQuestion(new PICReviewQuestionWrapper(1, 'Internal Q1', 'External Q1', false));   // ATHR Avoid long parameter lists - Indira
            core_MDF_PICReviewQuestion__c question2 = createPICReviewQuestion(new PICReviewQuestionWrapper(2, 'Internal Q2', 'External Q2', false));   // ATHR Avoid long parameter lists - Indira
            questionList.addAll(new List<core_MDF_PICReviewQuestion__c>{question1, question2});
            insert questionList;
            
            List<Core_MDF_PIC_Review__c> reviewList = new List<Core_MDF_PIC_Review__c>();
            Core_MDF_PIC_Review__c review1 = createPICReviewResult(new PICReviewWrapper(claimIPA.Id, 1, 'Failed', false));    // ATHR Avoid long parameter lists - Indira
            Core_MDF_PIC_Review__c review2 = createPICReviewResult(new PICReviewWrapper(claimIPA.Id, 2, 'Failed', false));   // ATHR Avoid long parameter lists - Indira
            reviewList.addAll(new List<Core_MDF_PIC_Review__c>{review1, review2});
            insert reviewList;
            
            List<core_MDF_PICReviewResult__c> resultList = new List<core_MDF_PICReviewResult__c>();
            core_MDF_PICReviewResult__c result1 = createPICReviewResult(new PICReviewResultWrapper(review1.Id, question1.Id, 'evidence1.xls', 'No', false));    // ATHR Avoid long parameter lists - Indira
            core_MDF_PICReviewResult__c result2 = createPICReviewResult(new PICReviewResultWrapper(review2.Id, question2.Id, '', 'No', false));    // ATHR Avoid long parameter lists - Indira
            resultList.addAll(new List<core_MDF_PICReviewResult__c>{result1, result2});
            insert resultList;
            List<PartnerFundClaim> pfcLst = new List<PartnerFundClaim>{claimIPA};
            for(PartnerFundClaim c : pfcLst) {
                c.Core_MDF_Status__c = 'Pending Account Manager Clarification';
                c.Core_MDF_Doc_Hold_Doc_Sub_Due_Date_Dtm__c = System.now().addDays(5);
            }
            update pfcLst;
            
            test.stopTest();
        }
    }
    // ATHR Avoid long parameter lists - Indira - start
    public class PICReviewWrapper {
    public String claimId;
    public Integer cycleNumber;
    public String status;
    public Boolean isInsert;
    
    // Constructor
    public PICReviewWrapper(String claimId, Integer cycleNumber, String status, Boolean isInsert) {
        this.claimId = claimId;
        this.cycleNumber = cycleNumber;
        this.status = status;
        this.isInsert = isInsert;
    }
   
}
    
    public class PICReviewResultWrapper {
    public String picReviewId;
    public String questionId;
    public String filesAffected;
    public String response;
    public Boolean isInsert;
    
    // Constructor
    public PICReviewResultWrapper(String picReviewId, String questionId, String filesAffected, String response, Boolean isInsert) {
        this.picReviewId = picReviewId;
        this.questionId = questionId;
        this.filesAffected = filesAffected;
        this.response = response;
        this.isInsert = isInsert;
    }
   
}
  
    public class PICReviewQuestionWrapper {
    public Integer sortOrder;
    public String englishText;
    public String englishTextExternal;
    public Boolean isInsert;
    
    // Constructor
    public PICReviewQuestionWrapper(Integer sortOrder, String englishText, String englishTextExternal, Boolean isInsert) {
        this.sortOrder = sortOrder;
        this.englishText = englishText;
        this.englishTextExternal = englishTextExternal;
        this.isInsert = isInsert;
    }

}
 // ATHR Avoid long parameter lists - Indira - end
   
}