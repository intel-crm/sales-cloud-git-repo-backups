/****************************************************************************************************************************************
* Class Name  : Core_MDF_CCP_TestDataUtility
* Version     : 1.0 
* Created Date: 7-12-2018
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Raj Dubey                    7/12/2018                    Utility Class to create test data.
* Jayesh Variyani              7/30/2018                    Added method for creating PartnerNodeUserMapping Record.
* Accenture - Shridhar K       7/31/2018                    Added priority pickliscreatePartnerFundAllocationt value in createCampaign method and removed createPriority method.
* Jayesh Variyani              8/01/2018                    Added method for creating PartnerFundAllocation,Priority and PartnerFundRequest Record.
* Varun Kumar                  8/08/2018                    Removed the method for creating Priority
* Harika Punnam                8/08/2018                    Added Priority parameter in createCampaign method
* Varun Kumar                  8/20/2018                    Added method for creating contentDocument 
* Harika Punnam                8/27/2018                    Added methods for creating Core_MDF_Criteria__c, Core_MDF_Approver__c, Core_MDF_Criteria_Rule__c.
* Harika Punnam                8/31/2018                    Added productType parameter in createCampaign method
* Gaurav                       11/19/2018                   Changed the Currency Value, Changed the Bank Record Status 
* Accenture - AS               12/18/2018                   Changed end date in createPartnerFundRequestwithCP(). 
* Hamza Akhtar                 3/15/2019                    Added account filter check in createIntelAccount() method
* Manasa                       9/23/2019                    Added lines to dynamically fetch and assign the Campaign picklist values 
* Nuzhath                      9/25/2019                    Changed the single country field to multiple country field
* NP - 11630236                10/17/2019                   Added code in createPartnerGroupMapping() to add only valid groups to PGM
* NP(11630236)                 28/2/2020                    Added source for PGM insert
* Accenture - AG                16/2/2020                   Added a method to generate MDF Configration - Custom Setting Data.
* Accenture                     23/09/2021                  Added a method to Bypass Unwanted Query execution while running Test classes related to Budget,Allocation, Bank, AccountBankMapping, Account User
*****************************************************************************************************************************************/
@isTest
public class Core_MDF_CCP_TestDataUtility {
    
    public static Id campaign_RecordType_CCF = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Core_MDF_Client_CoMarketing_Fund').getRecordTypeId();
    public static Id campaign_RecordType_DCF = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Core_MDF_Data_Center_CoMarketing_Fund').getRecordTypeId(); 
    public static Id campaign_RecordType_SPCF = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Core_MDF_Service_Provider_CoMarketing_Fund').getRecordTypeId();
    public static Id campaign_RecordType_Retail = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Core_MDF_Retail_Marketing_Funds').getRecordTypeId();
    
    public static Id claim_RecordType_CCF = Schema.SObjectType.PartnerFundClaim.getRecordTypeInfosByDeveloperName().get('Core_MDF_Client_Co_Marketing_Fund').getRecordTypeId();
    public static Id claim_RecordType_DCF = Schema.SObjectType.PartnerFundClaim.getRecordTypeInfosByDeveloperName().get('Core_MDF_Data_Center_Co_Marketing_Fund').getRecordTypeId(); 
    public static Id claim_RecordType_SPCF = Schema.SObjectType.PartnerFundClaim.getRecordTypeInfosByDeveloperName().get('Core_MDF_Service_Provider_Co_Marketing_Fund').getRecordTypeId(); 
    
    //Claim Retail Record Types
    public static Id claim_RecordType_Retail = Schema.SObjectType.PartnerFundClaim.getRecordTypeInfosByDeveloperName().get('Core_MDF_Retail_Marketing_Funds').getRecordTypeId();   
        
    public static Id account_Record_Type = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Core_MDF_Co_Marketing').getRecordTypeId();
    public static Id intel_Account_Record_Type = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
    public static Id budget_Record_Type = Schema.SObjectType.PartnerMarketingBudget.getRecordTypeInfosByDeveloperName().get('Core_MDF_Co_Marketing').getRecordTypeId();
    public static Id allocation_Record_Type = Schema.SObjectType.PartnerFundAllocation.getRecordTypeInfosByDeveloperName().get('Core_MDF_Client_CoMarketing_Fund').getRecordTypeId();
    public static Id partnerFund_RecordType_CCF = Schema.SObjectType.PartnerFundRequest.getRecordTypeInfosByDeveloperName().get('Core_MDF_Client_CoMarketing_Fund').getRecordTypeId();
    public static Id partnerFund_RecordType_DCF = Schema.SObjectType.PartnerFundRequest.getRecordTypeInfosByDeveloperName().get('Core_MDF_Data_Center_CoMarketing_Fund').getRecordTypeId();
    public static Id partnerFund_RecordType_SPCF = Schema.SObjectType.PartnerFundRequest.getRecordTypeInfosByDeveloperName().get('Core_MDF_Service_Provider_CoMarketing_Fund').getRecordTypeId();
    public static Id partnerFund_RecordType_Retail = Schema.SObjectType.PartnerFundRequest.getRecordTypeInfosByDeveloperName().get('Core_MDF_Retail_Marketing_Funds').getRecordTypeId();
    public static Id intel_Contact_Record_Type = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Core_Intel_Contact').getRecordTypeId();
    public static Id budget_Retail_Record_Type = Schema.SObjectType.PartnerMarketingBudget.getRecordTypeInfosByDeveloperName().get('Core_MDF_Retail_Marketing_Funds').getRecordTypeId();
    
    public static User createUser(Boolean isInsert){
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        //UserRole ur = [Select Id, Name From UserRole limit 1];
        User testUser = new User(/**UserRoleId  = ur.Id,**/Alias = String.valueOf(datetime.now()).substring(0,8), Email='testUsercoreMDF@intel.com',
                                 EmailEncodingKey='UTF-8', LastName='User'+String.valueOf(date.today()), LanguageLocaleKey='en_US',
                                 LocaleSidKey='en_US', ProfileId = sysAdminProfile.Id,
                                 TimeZoneSidKey='America/Los_Angeles', UserName='testUser'+String.valueOf(Math.random())+'@CoreMDF.com',FirstName='Test',
                                 UserPermissionsMarketingUser = TRUE);
        if(isInsert){
            insert testUser;
        }
        return testUser;
        
    }  
    public static User createPartnerUser(Boolean isInsert){
        Profile partnerProfile = [SELECT Id FROM Profile WHERE Name='Partner'];
        ChannelProgram cp = createProgram (Core_MDF_CCP_ConstantClass.CCF_PROGRAM,'Client CoMarketing Fund', true);
        Account acc1 = createIntelAccount('Test Acc New 2', intel_Account_Record_Type, true);
        Account acc2 = createCoMarketingAccount('Test Acc New 8', cp.Id, Account_Record_Type, acc1.Id, true);
        Contact con  = createContact(acc1.Id, true);
        //UserRole ur = [Select Id, Name From UserRole limit 1];
        User testPartnerUser = new User(/**UserRoleId  = ur.Id,**/Alias = String.valueOf(datetime.now()).substring(0,8), Email='testUsercoreMDF@intel.com',
                                 EmailEncodingKey='UTF-8', LastName='User'+String.valueOf(date.today()), LanguageLocaleKey='en_US',
                                 LocaleSidKey='en_US', ProfileId = partnerProfile.Id, ContactId = con.Id,
                                 TimeZoneSidKey='America/Los_Angeles', UserName='testUser'+String.valueOf(Math.random())+'@CoreMDF.com',FirstName='Test');
        if(isInsert){
            insert testPartnerUser;
        }
        return testPartnerUser;
    }

    public static ChannelProgram createProgram(String cpName, String technicalProgramName, Boolean isInsert){
        ChannelProgram testChannelProgram = new ChannelProgram(Name = cpName, Core_MDF_Technical_Program_Name__c=technicalProgramName);
        if(isInsert){
            insert testChannelProgram;
        }
        return testChannelProgram;
    }
    
    
    public static Account createAccount(String accountName, Id channelProgramId, Id accountRecordTypeId, Boolean isInsert){
        
        Account testAccount = new Account(Name = accountName , RecordTypeId = accountRecordTypeId, Core_MDF_Channel_Program__c = channelProgramId, Core_MDF_CoMarketingActive__c = true);
        if(isInsert){
            insert testAccount;
        }
        return testAccount;
    }
    
    public static Account createIntelAccount(String accountName, Id accountRecordTypeId, Boolean isInsert){
        
        Account testAccount = new Account(Name = accountName , RecordTypeId = accountRecordTypeId, Core_Account_Type__c = 'Distributor',Industry = 'Communications',
                                          BillingCity='Pune', BillingCountry='IND',/*Core_Geo__c='APJ',Core_Sub_Geo__c='SA',*/ BillingCountryCode = 'IND', BillingState = 'MH',BillingStateCode = 'MH', BillingStreet = 'TestStreet', Core_MDF_CoMarketingActive__c = true);
        if(isInsert){
            insert testAccount;
        }
        return testAccount;
    }
    
    
    
    public static Account createCoMarketingAccount(String accountName, Id channelProgramId, Id accountRecordTypeId, Id parentFundAccountId, Boolean isInsert){
        
      //  Account testAccount = new Account(Name = accountName , RecordTypeId = accountRecordTypeId,Core_Geo__c='APJ',Core_Sub_Geo__c='SA', Core_MDF_Channel_Program__c = channelProgramId, Core_MDF_Parent_Fund_Account__c = parentFundAccountId);
        Account testAccount = new Account(Name = accountName , RecordTypeId = accountRecordTypeId, Core_MDF_Channel_Program__c = channelProgramId, Core_MDF_Parent_Fund_Account__c = parentFundAccountId);
        
        if(isInsert){
            insert testAccount;
        }
        return testAccount;
    }
    
    
    
    public static Campaign createCampaign(String campaignName, String audience, String brandName,String SupportslegacyProgram, Id campaignRecordTypeId, String programType, Date startDate, Date endDate, Decimal firstYearAmount, String priority, Id accountId, String productType,  Boolean isInsert){
        
        Campaign testCampaign = new Campaign();        
        testCampaign.RecordTypeId = campaignRecordTypeId;
        testCampaign.Core_MDF_Program__c = programType;
        testCampaign.Name = campaignName;
        testCampaign.Core_MDF_Account__c = accountId;
        //testCampaign.Core_MDF_External_Visibility_Date__c = System.today();
        testCampaign.Core_MDF_External_Visibility_Date__c = startDate;
        testCampaign.StartDate = startDate;
        testCampaign.EndDate = endDate; 
        testCampaign.Core_MDF_First_Year_Budget_Amount__c = firstYearAmount;
        testCampaign.Description = 'Test Campaign';
        testCampaign.Core_MDF_Story__c = 'Test Story';
        testCampaign.Core_MDF_Metrics__c=' Test Campaign';
        testCampaign.Core_MDF_Messaging__c='Test Campaign';
        testCampaign.Core_MDF_Industry_Nm__c='Accommodation and Food Services';
        //testCampaign.Core_MDF_Spending_Cap_Amt__c = 2000000000;
        //testCampaign.Core_MDF_Priority__c = priority;
        Schema.DescribeFieldResult fieldResult1 = Schema.sObjectType.Campaign.fields.Core_MDF_Priority__c.getSObjectField().getDescribe();
        List<Schema.PicklistEntry> ple1 = fieldResult1.getPicklistValues();
        for (Schema.PicklistEntry p1: ple1) {
        if(p1.getValue().contains(priority)) {
            testCampaign.Core_MDF_Priority__c = priority; 
            }else{testCampaign.Core_MDF_Priority__c = null; }
        }
        Schema.DescribeFieldResult fieldResult2 = Schema.sObjectType.Campaign.fields.Core_MDF_Brand__c.getSObjectField().getDescribe();
        List<Schema.PicklistEntry> ple2 = fieldResult2.getPicklistValues();
        for (Schema.PicklistEntry p2: ple2) {
        if(p2.getValue().contains(brandName)) {
            testCampaign.Core_MDF_Brand__c = brandName; 
            }else{testCampaign.Core_MDF_Brand__c = null; }
        }
        Schema.DescribeFieldResult fieldResult3 = Schema.sObjectType.Campaign.fields.Core_MDF_Product_Type__c.getSObjectField().getDescribe();
        List<Schema.PicklistEntry> ple3 = fieldResult3.getPicklistValues();
        for (Schema.PicklistEntry p3: ple3) {
        if(p3.getValue().contains(productType)) {
            testCampaign.Core_MDF_Product_Type__c = productType; 
            }else{testCampaign.Core_MDF_Product_Type__c = null; }
        }
                
        
        //testCampaign.Core_MDF_Market__c='ALBANIA;AUSTRALIA';
        testCampaign.Core_MDF_Market__c='UNITED STATES;UNITED KINGDOM';
        Schema.DescribeFieldResult fieldResult4 = Schema.sObjectType.Campaign.fields.Core_MDF_Audience__c.getSObjectField().getDescribe();
        List<Schema.PicklistEntry> ple4 = fieldResult4.getPicklistValues();
        for (Schema.PicklistEntry p4: ple4) {
        if(p4.getValue().contains(audience)) {
            testCampaign.Core_MDF_Audience__c = audience; 
            }else{testCampaign.Core_MDF_Audience__c = null; }
        }
        Schema.DescribeFieldResult fieldResult5 = Schema.sObjectType.Campaign.fields.Core_MDF_Supports_legacy_program__c.getSObjectField().getDescribe();
        List<Schema.PicklistEntry> ple5 = fieldResult5.getPicklistValues();
        for (Schema.PicklistEntry p5: ple5) {
        if(p5.getValue().contains(SupportslegacyProgram)) {
            testCampaign.Core_MDF_Supports_legacy_program__c = SupportslegacyProgram; 
            }
        }
        
        //testCampaign.Core_MDF_Audience__c=audience;
        testCampaign.Core_MDF_Marketing_Objective_Strategy__c = 'Test Marketing Objective/ Strategy';
        testCampaign.Core_MDF_Hero_Product__c = 'Test Hero';
        testCampaign.Core_MDF_Key_Performance_Indicator__c = 'Test Key Performance';
        //testCampaign.Core_MDF_Product_Type__c = productType;
        if(programType == 'Client CoMarketing Fund'){
            testCampaign.Core_MDF_Technology__c = Label.Core_MDF_CCF_Technology_For_TestClass;
        }
        else if(programType == 'Data Center CoMarketing Fund'){
            testCampaign.Core_MDF_Technology__c = Label.Core_MDF_DCF_Technology_For_TestClass;
        }
        else{
            testCampaign.Core_MDF_Technology__c = null;
        }
        
        
        
        //testCampaign.Core_MDF_Brand__c= brandName;
        if (programType != 'Retail Marketing Funds')
        {
            //testCampaign.Core_MDF_Activity_Category_Type__c ='Digital Media->Email';
            testCampaign.Core_MDF_Reimbursement_Rate__c='50%';
        }
        else{
            testCampaign.Core_MDF_Reimbursement_Rate__c='100%';
        }
        if(programType == 'Client CoMarketing Fund' || programType == 'Data center CoMarketing Fund' || programType == 'Ecosystem Extension Fund'){
            Integer startYear = startDate.year();
            Integer endYear = endDate.year();
            if(testCampaign.Core_MDF_Opal_Budget_Type_Txt__c=='OEM CMP' || testCampaign.Core_MDF_Opal_Budget_Type_Txt__c=='Service Provider CMP'){
                testCampaign.Core_MDF_Supports_legacy_program__c =startYear >= 2025 ? 'New CMP only' : 'CMP Only';
                testCampaign.Core_MDF_Activity_Category_Type__c = testCampaign.Core_MDF_Supports_legacy_program__c=='New CMP only' ?'Digital 2025->Web Content'  : 'Broadcast->Podcast';
            } else if(testCampaign.Core_MDF_Opal_Budget_Type_Txt__c=='MDF' || testCampaign.Core_MDF_Opal_Budget_Type_Txt__c=='MDF+'){
                testCampaign.Core_MDF_Supports_legacy_program__c = startYear >= 2025 ? 'New MDF or both CMP & MDF' : 'MDF or both CMP & MDF';
                 testCampaign.Core_MDF_Activity_Category_Type__c = testCampaign.Core_MDF_Supports_legacy_program__c=='New MDF or both CMP & MDF' ? 'Digital 2025->Web Content' : 'Broadcast->Podcast';
            }
        }else if(programType == 'Intel Partner Alliance' && programType=='Retail Marketing Funds'){
            Integer startYear = startDate.year();
            Integer endYear = endDate.year();
            if(startYear < 2025 && endYear >= 2025) {
                testCampaign.Core_MDF_Supports_legacy_program__c ='All MDF or both CMP & MDF';
                testCampaign.Core_MDF_Activity_Category_Type__c = 'Broadcast->Podcast';
            } else if(startYear >= 2025){
                testCampaign.Core_MDF_Supports_legacy_program__c ='New MDF or both CMP & MDF';
                 testCampaign.Core_MDF_Activity_Category_Type__c = 'Digital 2025->Web Content';
            }
        }
        testCampaign.Status = 'Planned';  
        if(isInsert){
            insert testCampaign;            
        }
        return testCampaign;
    }
    
   
    
    
    public static PartnerMarketingBudget createBudget(String budgetTitle, Id budgetRecordTypeId, Id accountId, Id channelProgramId, Double amount, Date startDate, Date endDate, Boolean isInsert ){
        
        PartnerMarketingBudget testBudget = new PartnerMarketingBudget();
        testBudget.Title = budgetTitle;
        testBudget.Amount = amount;
        testBudget.Core_MDF_Budget_Partner__c = accountId;
        testBudget.RecordTypeId = budgetRecordTypeId;
        testBudget.Description = 'Test Description';
        testBudget.StartDate = startDate;
        testBudget.EndDate = endDate;
        testBudget.Core_MDF_Budget_Comments__c = 'Test Comments';
        testBudget.Core_MDF_Program__c = channelProgramId;
        testBudget.IsIgnoreValidation = true;
        
        
        if(isInsert){
            insert testBudget;
        }
        return testBudget;
    }
    
    //Areefa:createRetailBudget
    public static PartnerMarketingBudget createRetailBudget(String budgetTitle, Id budgetRecordTypeId, Id accountId, Id channelProgramId, Double amount, 
                                                            Date startDate, Date endDate, Boolean isInsert, String budgetType){
        PartnerMarketingBudget retailBudget = createBudget(budgetTitle,budgetRecordTypeId,accountId,channelProgramId,amount,startDate,endDate,false);
        retailBudget.Core_MDF_Budget_Type_Txt__c = budgetType;
        if(isInsert){
            insert  retailBudget;                                            
        }                                                           
        return retailBudget;                                                        
    }
    
    
    public static Core_MDF_Criteria__c createCriteria(String objectType, String approvalProcess, String fieldName1, String operator1, String value1, String fieldName2, String operator2, String value2, String fieldName3, String operator3, String value3, 
                                                      String fieldName4, String operator4, String value4, String fieldName5, String operator5, String value5, Boolean isInsert){
                                                          Core_MDF_Criteria__c testCriteria = new Core_MDF_Criteria__c();
                                                          testCriteria.Core_MDF_Object_Type__c = objectType;
                                                          testCriteria.Core_MDF_Approval_Process__c = approvalProcess;
                                                          testCriteria.Core_MDF_Field_Name_1__c = fieldName1;
                                                          testCriteria.Core_MDF_Operator_1__c = operator1;
                                                          testCriteria.Core_MDF_Value_1__c = value1;
                                                          testCriteria.Core_MDF_Field_Name_2__c = fieldName2;
                                                          testCriteria.Core_MDF_Operator_2__c = operator2;
                                                          testCriteria.Core_MDF_Value_2__c = value2;
                                                          testCriteria.Core_MDF_Field_Name_3__c = fieldName3;
                                                          testCriteria.Core_MDF_Operator_3__c = operator3;
                                                          testCriteria.Core_MDF_Value_3__c = value3;
                                                          testCriteria.Core_MDF_Field_Name_4__c = fieldName4;
                                                          testCriteria.Core_MDF_Operator_4__c = operator4;
                                                          testCriteria.Core_MDF_Value_4__c = value4;
                                                          testCriteria.Core_MDF_Field_Name_5__c = fieldName5;
                                                          testCriteria.Core_MDF_Operator_5__c = operator5;
                                                          testCriteria.Core_MDF_Value_5__c = value5;
                                                          
                                                          if(isInsert){
                                                              insert testCriteria;
                                                          }
                                                          return testCriteria;
                                                      }
    
    public static Core_MDF_Approver__c createApprover (Id criteriaId, Id approverId, Boolean isInsert){
        Core_MDF_Approver__c testApprover = new Core_MDF_Approver__c();
        testApprover.Core_MDF_Criteria__c = criteriaId;
        testApprover.Core_MDF_Approver_1__c = approverId;
        
        if(isInsert){
            insert testApprover;
        }
        return testApprover;
    }
    
    public static Core_MDF_Criteria_Rule__c createCriteriaRule (Id approverId, String fieldName, String operator, String value, Boolean isInsert){
        Core_MDF_Criteria_Rule__c testCriteriaRule = new Core_MDF_Criteria_Rule__c();
        testCriteriaRule.Core_MDF_Approver__c = approverId;
        testCriteriaRule.Core_MDF_Field_Name__c = fieldName;
        testCriteriaRule.Core_MDF_Operator__c = operator;
        testCriteriaRule.Core_MDF_Value__c = value;
        
        if(isInsert){
            insert testCriteriaRule;
        }
        return testCriteriaRule;
    }
    
    public static Contact createContact(Id accountId,Boolean isInsert){
         Contact testContact = new Contact(Salutation = 'Mr',FirstName = 'Test',LastName='Contact',
                                          Email='testcontact'+String.valueOf(Math.random())+'@coremdf.com',
                                          AccountId=accountId,Phone='123456798',MailingCountry='India',Core_Audience_List__c='CCF User;DCF User;RMF User',RecordTypeId=intel_Contact_Record_Type);    
        if(isInsert){
            insert testContact;
        }
        
        return testContact;
    }
    
    public static PartnerFundAllocation createPartnerFundAllocation(String titleName,PartnerMarketingBudget pmbRecord,Account cp,Decimal allocationAmount,Boolean isInsert){
        PartnerFundAllocation testPartnerFundAllocation = new PartnerFundAllocation(Title=titleName, Budget = pmbRecord, BudgetId=pmbRecord.Id, ChannelPartnerId=cp.Id, Amount=allocationAmount);       
        if(isInsert){
            insert testPartnerFundAllocation;
        }
        
        return testPartnerFundAllocation;
    }
    
    public static PartnerFundRequest createPartnerFundRequest1(Account channelPartner,PartnerFundAllocation pfaRec,PartnerMarketingBudget pmbRec,String targetAudience,Boolean isInsert){
        PartnerFundRequest testPartnerFundRequest = new PartnerFundRequest(ChannelPartnerId = channelPartner.Id,Allocation=pfaRec,Budget=pmbRec,RequestedAmount=12345,Title='TestPFR',Core_MDF_TargetAudience__c=targetAudience);
        if(isInsert){
            insert testPartnerFundRequest;
        }
        
        return testPartnerFundRequest;
    }
    public static PartnerFundRequest createPartnerFundRequest(String campaignId,String recTypeId,String channelPartnerId,PartnerFundAllocation pfaRec,PartnerMarketingBudget pmbRec,String country,String targetAudience,String productType,String brand,String activityCategory,String activityTypes,String status,Boolean isInsert){
        PartnerFundRequest testPartnerFundRequest = NULL;

        if (pfaRec == NULL){
            testPartnerFundRequest = new PartnerFundRequest(CampaignId=campaignId,recordtypeid = recTypeId,ChannelPartnerId = channelPartnerId,Core_MDF_Country_nm__c=country,Core_MDF_Brand_nm__c=brand,Core_MDF_ProductType__c=productType,Core_MDF_ActivityCategory__c=activityCategory,
                                                                           Core_MDF_Activity_Types__c=activityTypes,RequestedAmount=12345,Core_MDF_TargetAudience__c=targetAudience,Core_MDF_Start_Date__c=System.today(),Core_MDF_End_Date__c = system.today(),Status=status,Title ='test',
                                                                           Core_MDF_Activity_Description__c ='test123');
        }
        else{
            testPartnerFundRequest = new PartnerFundRequest(CampaignId=campaignId,recordtypeid = recTypeId,ChannelPartnerId = channelPartnerId,Core_MDF_Country_nm__c=country,
                                                           Core_MDF_Brand_nm__c=brand,Core_MDF_ProductType__c=productType,Core_MDF_ActivityCategory__c=activityCategory,
                                                                           Core_MDF_Activity_Types__c=activityTypes,RequestedAmount=12345,Core_MDF_TargetAudience__c=targetAudience,Core_MDF_Start_Date__c=System.today(),Core_MDF_End_Date__c = system.today(),Status=status,Title ='test',
                                                                           Core_MDF_Activity_Description__c ='test123',AllocationId = pfaRec.Id);
        }
        
        if(isInsert){
            insert testPartnerFundRequest;
        }
        
        return testPartnerFundRequest;
    }
     public static PartnerFundRequest createRetailActivity(String campaignId,String channelPartnerId,Date startDate,Date endDate,Boolean isInsert){/*String country,String targetAudience,String productType,String brand,String activityCategory,String activityTypes,String status,*/
        PartnerFundRequest testPartnerFundRequest = NULL;

       // if (pfaRec == NULL){
            testPartnerFundRequest = new PartnerFundRequest(CampaignId=campaignId,recordtypeid = Core_MDF_CCP_TestDataUtility.partnerFund_RecordType_Retail,ChannelPartnerId = channelPartnerId,Core_MDF_Country_nm__c='INDIA',Core_MDF_Brand_nm__c='Intel® 11ᵗʰ Gen',Core_MDF_ProductType__c='Traditional Notebook',Core_MDF_ActivityCategory__c='Sales Readiness',
                                                                           Core_MDF_Activity_Types__c='In-Store Promotion',RequestedAmount=12345,Core_MDF_TargetAudience__c='Enthusiast Gaming',Core_MDF_Start_Date__c=startDate,Core_MDF_End_Date__c =endDate,Title ='Test Retail',
                                                                           Core_MDF_Activity_Description__c ='Test Retail Description');
        /*}
        else{
            testPartnerFundRequest = new PartnerFundRequest(CampaignId=campaignId,recordtypeid = recTypeId,ChannelPartnerId = channelPartnerId,Core_MDF_Country_nm__c=country,
                                                            Core_MDF_Brand__c=brand,Core_MDF_ProductType__c=productType,Core_MDF_ActivityCategory__c=activityCategory,
                                                                           Core_MDF_Activity_Types__c=activityTypes,RequestedAmount=12345,Core_MDF_TargetAudience__c=targetAudience,Core_MDF_Start_Date__c=System.today(),Core_MDF_End_Date__c = system.today(),Status=status,Title ='test',
                                                                           Core_MDF_Activity_Description__c ='test123',AllocationId = pfaRec.Id);
        }*/
        
        if(isInsert){
            insert testPartnerFundRequest;
        }
        
        return testPartnerFundRequest;
    }
    
        public static PartnerFundRequest insertPartnerFundRequest(String campaignId,String recTypeId,String channelPartnerId,PartnerFundAllocation pfaRec,PartnerMarketingBudget pmbRec,String country,String targetAudience,String productType,String brand,String activityCategory,String activityTypes,String status,Boolean isInsert){
        PartnerFundRequest testPartnerFundRequest = new PartnerFundRequest(CampaignId=campaignId,recordtypeid = recTypeId,ChannelPartnerId = channelPartnerId,Core_MDF_Country_nm__c=country,Core_MDF_Brand_nm__c=brand,Core_MDF_ProductType__c=productType,Core_MDF_ActivityCategory__c=activityCategory,Core_MDF_Activity_Types__c=activityTypes,RequestedAmount=100,Core_MDF_TargetAudience__c=targetAudience,Core_MDF_Start_Date__c=System.today(),Core_MDF_End_Date__c = system.today(),Status=status,Title ='test',Core_MDF_Activity_Description__c ='test123');
        if(isInsert){
            insert testPartnerFundRequest;
        }
        
        return testPartnerFundRequest;
    }
    
    public static Core_MDF_Partner_Node_User_Mapping__c createPartnerNodeUserMapping(Id accountId,Id userId, Boolean isInsert){
        Core_MDF_Partner_Node_User_Mapping__c testPartnerNodeUserMapping = new Core_MDF_Partner_Node_User_Mapping__c(Core_MDF_Account__c = accountId,Core_MDF_User__c=userId, Core_MDF_Active_Ind__c= true);       
        if(isInsert){
            insert testPartnerNodeUserMapping;
        }
        
        return testPartnerNodeUserMapping;
    }
    
    public static list<contentDocument> createContentDocument(Boolean isInsert) {       
        list<contentDocument> documents = new list<contentDocument>();        
        ContentVersion contentVersion1 = new ContentVersion(
            Title = 'Test',
            PathOnClient = 'Test.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        if(isInsert){
            insert contentVersion1;
            ContentVersion contentVersion2 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion1.Id LIMIT 1];
            documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument WHERE Id = :contentVersion2.ContentDocumentId];
        }
        return documents;
    }
    public static PartnerFundRequest createPartnerFundRequestwithCP(String campaignId,String recTypeId,String channelPartnerId,PartnerFundAllocation pfaRec,PartnerMarketingBudget pmbRec,String country,String targetAudience,String productType,String brand,String activityCategory,String activityTypes,String status,Boolean isInsert,Boolean cpLed, String cpName, String otherCPName)
    {
        PartnerFundRequest testPartnerFundRequest = new PartnerFundRequest(CampaignId=campaignId,recordtypeid = recTypeId,ChannelPartnerId = channelPartnerId,Core_MDF_Country_nm__c=country,Core_MDF_Brand_nm__c=brand,Core_MDF_ProductType__c=productType,Core_MDF_ActivityCategory__c=activityCategory,Core_MDF_Activity_Types__c=activityTypes,Allocation=pfaRec,Budget=pmbRec,RequestedAmount=12345,Amount = 100,Core_MDF_TargetAudience__c=targetAudience,Core_MDF_Start_Date__c=System.today(),Core_MDF_End_Date__c = system.today(),Status=status,Title ='test',Core_MDF_Activity_Description__c ='test123',
                                                                           Core_MDF_Channel_Partner__c=cpName,Core_MDF_Channel_Partner_Led__c = cpLed,Core_MDF_Other_Channel_Partner__c = otherCPName,Core_MDF_Fund_Request_Status__c='Revision Required');
        if(isInsert){
            insert testPartnerFundRequest;
        }
        
        return testPartnerFundRequest;
    }
    
    public static PartnerFundClaim createClaim(String claimName, Id claimRecordTypeId, Id requestId, Date startDate, Date endDate,Decimal amount, Date invoiceDate, Id bankId, Boolean isInsert){
        
        PartnerFundClaim pfc = new PartnerFundClaim();
        pfc.RequestId = requestId;
        pfc.RecordTypeId = claimRecordTypeId;
        pfc.amount = amount;
        pfc.Core_MDF_Status__c = 'Submitted';
        pfc.Core_MDF_Invoice_Date__c = invoiceDate;
        pfc.Core_MDF_Invoice_Number__c = 'INV1686';
        pfc.Core_MDF_Media_Vehicle__c = 'Test';
        pfc.Core_MDF_OtherCostsnotReimbursable_Local__c = 0;
        pfc.Core_MDF_Taxes_Local__c = 12;
        pfc.Core_MDF_Total_Invoice_Amount_Local__c = amount;
        pfc.Core_MDF_Ad_Run_Start_Date__c = startDate;
        pfc.Core_MDF_Ad_Run_End_Date__c = endDate;
        //pfc.Core_MDF_AuditSelectionInProgress__c=true;
        pfc.Title = claimName;
        pfc.Core_MDF_Currency__c = 'INR';        
        pfc.Core_MDF_Bank__c = bankId;
        pfc.Description = 'Test';
        pfc.Core_MDF_Country_Location_nm__c= 'BRAZIL';
        //pfc.Core_MDF_Audit_Adjustment_Amount__c= 500.00;
        //pfc.Core_MDF_To_Be_Audited_Ind__c=true;
        //pfc.Core_MDF_Exchange_rate__c=30;
       pfc.Core_MDF_Reimbursable_Transaction_Amount__c=100;
        
        if(isInsert){
            insert pfc;            
        }
        return pfc;
    }
    
    public static PartnerFundClaim createRetailRSAMDClaim(Id claimRecordTypeId, Id requestId, Date startDate, Date endDate,Decimal amount, Boolean isInsert){
        
        PartnerFundClaim pfc = new PartnerFundClaim();
        pfc.RequestId = requestId;
        pfc.RecordTypeId = claimRecordTypeId;        
        pfc.Core_MDF_Status__c = 'Submitted';
        pfc.Core_MDF_Total_Invoice_Amount_Local__c = amount;
        pfc.Core_MDF_Ad_Run_Start_Date__c = startDate;
        pfc.Core_MDF_Ad_Run_End_Date__c = endDate;
        //pfc.Title = claimName;
        pfc.Core_MDF_Currency__c = 'USD'; 
        //pfc.Description = 'Test';
        pfc.Core_MDF_Country_Location_nm__c= 'BRAZIL';        
        if(isInsert){
            insert pfc;            
        }
        return pfc;
    }
    
    
    public static Core_MDF_Bank__c createBank(Id account, string program, Boolean isInsert, String supplierno)
    {
        Core_MDF_Bank__c bank = new Core_MDF_Bank__c();
        bank.Core_MDF_Bank_Alias_Name__c = 'Test';
        bank.Core_MDF_Supplier_Number__c = supplierno;
        bank.Core_MDF_Effective_Date__c = System.today();
        bank.Core_MDF_Payment_Method_Code__c = 'C';
        bank.Core_MDF_Intel_Company_Code__c = '100';
        bank.Core_MDF_Bank_Account_Number__c = '1234';
        bank.Core_MDF_Bank_Beneficiary_Name__c = 'Test';
        bank.Core_MDF_Account__c = account;
        bank.Core_MDF_Bank_Status__c = 'Draft';
        bank.Core_MDF_Program__c = program;
        bank.Core_MDF_ESD_Update__c = true;
        bank.Name = 'Test';
        bank.Core_MDF_Currency_cd__c = 'USD';
        bank.Core_MDF_Payment_Currency_Cd__c = 'USD';
        if(isInsert){
            insert bank;
            bank.Core_MDF_Bank_Status__c = 'Active';            
            update bank;
        }
        return bank;
    }
    
    public static Core_MDF_Account_Bank_Mapping__c createAccountBankMap(Id account, Id bank, Boolean isInsert)
    {
        Core_MDF_Account_Bank_Mapping__c accountBankMap = new Core_MDF_Account_Bank_Mapping__c();
        accountBankMap.Core_MDF_Account__c = account;
        accountBankMap.Core_MDF_Bank__c = bank;
        accountBankMap.Core_MDF_Active_ind__c = true;
        if(isInsert){
            insert accountBankMap;            
        }
        return accountBankMap;
    }
    
    public static Core_AGS_Role__c createAgsRole(String agsRoleName, String technicalName, Boolean isActive, Boolean isInsert){
        Core_AGS_Role__c agsRoleObj = new Core_AGS_Role__c();
        agsRoleObj.Name = agsRoleName;
        agsRoleObj.Core_Technical_Name__c = technicalName;
        agsRoleObj.Core_IsActive__c = isActive;
        
        if(isInsert){
            insert agsRoleObj;            
        }
        return agsRoleObj;
    }
    
    public static Core_ERPM_Engagement__c createErpmEngagement(String erpmName, String technicalEngagementCode, String technicalDedupNumber, String engagementType, Boolean isActive, Boolean isInsert){
        Core_ERPM_Engagement__c erpmEngagementObj = new Core_ERPM_Engagement__c();
        erpmEngagementObj.Name = erpmName;
        erpmEngagementObj.Core_Technical_Engagement_Code__c = technicalEngagementCode;
        erpmEngagementObj.Core_Technical_DeDup_Number__c = technicalDedupNumber;
        erpmEngagementObj.Core_Engagement_Type__c = engagementType;
        erpmEngagementObj.Core_IsActive__c = isActive;
        
        if(isInsert){
            insert erpmEngagementObj;            
        }
        return erpmEngagementObj;
    }
    
    public static Core_Entitlement__c createEntitlement(String name, Id agsRole,String category,String displayName, Id erpmEngagement, Boolean isActive,String subCategory,Boolean isInsert){
        Core_Entitlement__c entitlementObj = new Core_Entitlement__c();
        entitlementObj.Name = name;
        entitlementObj.Core_AGS_Role_Id__c = agsRole;
        entitlementObj.Core_Category__c = category;
        entitlementObj.Core_Display_Name__c = displayName;
        entitlementObj.Core_ERPM_Engagement_Id__c = erpmEngagement;
        entitlementObj.Core_IsActive__c = isActive;
        entitlementObj.Core_Sub_Category__c = subCategory;
        
        if(isInsert){
            insert entitlementObj;            
        }
        return entitlementObj;
    }
    
    public static Core_Contact_Entitlement__c createContactEntitlement(Id contact, Id entitlementDetail, Boolean selected, String status, Boolean isInsert){
        Core_Contact_Entitlement__c contactEntitlementObj = new Core_Contact_Entitlement__c();
        contactEntitlementObj.Core_Contact_Id__c = contact;
        contactEntitlementObj.Core_Entitlement_Id__c = entitlementDetail;
        contactEntitlementObj.Core_Status__c = status;
        contactEntitlementObj.Core_Selected__c = selected;
        
        if(isInsert){
            insert contactEntitlementObj;            
        }
        return contactEntitlementObj;
    }
    
    public static PermissionSetAssignment createPermissionSetAssignment(Id AssigneeId,Id PermissionSetId,Boolean isInsert){
        PermissionSetAssignment assignPermissionSetObj = new PermissionSetAssignment();
        assignPermissionSetObj.AssigneeId = AssigneeId;
        assignPermissionSetObj.PermissionSetId = PermissionSetId;
        
        if(isInsert){
            insert assignPermissionSetObj;            
        }
        return assignPermissionSetObj;
    }
    
    public static void createPartnerGroupMapping(Id accId,String accessType, Id worksFor, Id ChannelProgram,String groupName,Boolean isInsert){
        //Added code to create a valid group since only valid groups are allowed on PGM Group Name field
        Group group1 = new Group();
        group1.developername = 'Test_PGM_Group_' + Integer.valueof((Math.random() * 10));
        group1.name='Test_PGM_Group_' + groupName + Integer.valueof((Math.random() * 10)); 
        insert group1;
        
        Core_MDF_Partner_Group_Mapping__c pgm = new Core_MDF_Partner_Group_Mapping__c();
        pgm.Core_MDF_Account__c = accId;
        pgm.Core_MDF_Type_of_Access__c = accessType;
        pgm.Core_MDF_Works_For__c = worksFor;
        pgm.Core_MDF_Channel_Program__c = ChannelProgram;
        pgm.Core_MDF_Group_Name__c = group1.developername;
        if(accessType == 'Internal'){pgm.Core_MDF_Source_Txt__c = 'Test';}
        
        if(isInsert){
            insert pgm;
        }
           
    }
    
    public static Core_MDF_Account_Bank_Mapping__c createBankAccountMap(Id account,Id bank,Boolean isInsert){
        Core_MDF_Account_Bank_Mapping__c testBankAccount = new Core_MDF_Account_Bank_Mapping__c(Core_MDF_Account__c=account, Core_MDF_Bank__c = bank);       
        if(isInsert){
            insert testBankAccount;
        }
        
        return testBankAccount;
    }
    
    public static Core_MDF_Adjustment_Request__c createAdjustmentReq(Id refClaim, String reason, Decimal amt, boolean isInsert)
    {
        Core_MDF_Adjustment_Request__c adjReq = new Core_MDF_Adjustment_Request__c(Core_MDF_Reference_Claim_Nbr__c=refClaim, Core_MDF_Amount_Amt__c = amt, Core_MDF_Reason_Cd__c = reason);       
        if(isInsert){
            insert adjReq;
        }
        
        return adjReq;
    }
    
    public static void insertCurrencyExchangeRates(){
        List<Core_MDF_Currency_Exchange_Rates__c> newValues = new List<Core_MDF_Currency_Exchange_Rates__c>();
        
        Core_MDF_Currency_Exchange_Rates__c record1 = new Core_MDF_Currency_Exchange_Rates__c();
        record1.Name= 'ZMK';
        record1.Core_MDF_Exchange_Rate__c = 0.0000850159;
        record1.Core_MDF_Market_Date__c =System.today();
        record1.Core_MDF_Intel_WW__c = Core_MDF_CCP_Multicurrency.calculateIntelWorkWeek(System.today());
        record1.Core_MDF_Unique_Key__c = 'ZMK'+Core_MDF_CCP_Multicurrency.calculateIntelWorkWeek(System.today());
        newValues.add(record1);
        
        Core_MDF_Currency_Exchange_Rates__c record2 = new Core_MDF_Currency_Exchange_Rates__c();
        record2.Name= 'INR';
        record2.Core_MDF_Exchange_Rate__c = 1;
        record2.Core_MDF_Market_Date__c =System.today();
        record2.Core_MDF_Intel_WW__c = Core_MDF_CCP_Multicurrency.calculateIntelWorkWeek(System.today());
        record2.Core_MDF_Unique_Key__c = 'INR'+Core_MDF_CCP_Multicurrency.calculateIntelWorkWeek(System.today());
        newValues.add(record2); 
        
        Core_MDF_Currency_Exchange_Rates__c record3 = new Core_MDF_Currency_Exchange_Rates__c();
        record3.Name= 'USD';
        record3.Core_MDF_Exchange_Rate__c = 1;
        record3.Core_MDF_Market_Date__c =System.today();
        record3.Core_MDF_Intel_WW__c = Core_MDF_CCP_Multicurrency.calculateIntelWorkWeek(System.today());
        record3.Core_MDF_Unique_Key__c = 'USD'+Core_MDF_CCP_Multicurrency.calculateIntelWorkWeek(System.today());
        newValues.add(record3); 
        database.insert(newValues);
    }
    
    public static void createEscalation(){
        Core_MDF_Escalation__c escalationRecord = new Core_MDF_Escalation__c();
        escalationRecord.Core_MDF_Root_Cause_nm__c = 'Appeal of Budget';
        escalationRecord.Core_MDF_Total_Dollar_Impact_amt__c = 23;
        escalationRecord.Core_MDF_Escalation_Name_txt__c = 'TestEscalation';
        database.insert(escalationRecord);
        
    }
    
    public static void createTriggerExecutionRecords(){
        List<Core_Trigger_Executions__c> executionList = new List<Core_Trigger_Executions__c>();
        Core_Trigger_Executions__c claimFunctionalityNameTriggerExecution = new Core_Trigger_Executions__c();
        claimFunctionalityNameTriggerExecution.Core_Active__c = true;
        claimFunctionalityNameTriggerExecution.Core_Class_Name__c = 'Core_MDF_ProcessCCP_Claim';
        claimFunctionalityNameTriggerExecution.Core_Trigger_Events__c = 'after insert';
        claimFunctionalityNameTriggerExecution.Core_Object__c = 'PartnerFundClaim';
        claimFunctionalityNameTriggerExecution.Name = 'fundReservation';
        claimFunctionalityNameTriggerExecution.Core_Description__c = 'description';
        executionList.add(claimFunctionalityNameTriggerExecution);
        Core_Trigger_Executions__c claimFunctionalityNameTriggerExecution2 = new Core_Trigger_Executions__c();
        claimFunctionalityNameTriggerExecution2.Core_Active__c = true;
        claimFunctionalityNameTriggerExecution2.Core_Class_Name__c = 'Core_MDF_ProcessCCP_Claim';
        claimFunctionalityNameTriggerExecution2.Core_Trigger_Events__c = 'before insert';
        claimFunctionalityNameTriggerExecution2.Core_Object__c = 'PartnerFundClaim';
        claimFunctionalityNameTriggerExecution2.Name = 'checkESDHoldAndUpdateClaimStatus';
        claimFunctionalityNameTriggerExecution2.Core_Description__c = 'check ESD hold for the bank selected on Claim and change Claim status to Hold if it is on ESD Hold';
        executionList.add(claimFunctionalityNameTriggerExecution2);
        Core_Trigger_Executions__c claimFunctionalityNameTriggerExecution1 = new Core_Trigger_Executions__c();
        claimFunctionalityNameTriggerExecution1.Core_Active__c = true;
        claimFunctionalityNameTriggerExecution1.Core_Class_Name__c = 'Core_MDF_ProcessCCP_Claim';
        claimFunctionalityNameTriggerExecution1.Core_Trigger_Events__c = 'before insert';
        claimFunctionalityNameTriggerExecution1.Core_Object__c = 'PartnerFundClaim';
        claimFunctionalityNameTriggerExecution1.Name = 'duplicateClaimCheck';
        claimFunctionalityNameTriggerExecution1.Core_Description__c = 'check ESD hold for the bank selected on Claim and change Claim status to Hold if it is on ESD Hold';
        executionList.add(claimFunctionalityNameTriggerExecution1);
        Core_Trigger_Executions__c claimFunctionalityNameTriggerExecution3 = new Core_Trigger_Executions__c();
        claimFunctionalityNameTriggerExecution3.Core_Active__c = true;
        claimFunctionalityNameTriggerExecution3.Core_Class_Name__c = 'Core_MDF_PFCServiceHandler';
        claimFunctionalityNameTriggerExecution3.Core_Trigger_Events__c = 'before upate, after update';
        claimFunctionalityNameTriggerExecution3.Core_Object__c = 'PartnerFundClaim';
        claimFunctionalityNameTriggerExecution3.Name = 'checkAndSendClaimsToAudit';
        claimFunctionalityNameTriggerExecution3.Core_Description__c = 'test';
        executionList.add(claimFunctionalityNameTriggerExecution3);
        
        Database.insert(executionList);
    }
    
    public static Map<String,Core_MDF_Configuration__c> createMDFConfigurationData(){
      Map<String,Core_MDF_Configuration__c> configMap = new Map<String,Core_MDF_Configuration__c>();
      configMap.put('ADD_BUS_DAYS_ON_REMINDER_DATE_CLAIM',new Core_MDF_Configuration__c(Name='ADD_BUS_DAYS_ON_REMINDER_DATE_CLAIM',Core_MDF_Value__c='3',Core_MDF_Category__c='Bank Document Hold Logic'));
      configMap.put('BUDGET_TYPE_SKIP_BANK_DOC_HOLD',new Core_MDF_Configuration__c(Name='BUDGET_TYPE_SKIP_BANK_DOC_HOLD',Core_MDF_Value__c='RSA MD',Core_MDF_Category__c='Bank Document Hold Logic'));
      configMap.put('ALLOWED_PRG_FOR_RUS_NOTIF',new Core_MDF_Configuration__c(Name='ALLOWED_PRG_FOR_RUS_NOTIF',Core_MDF_Value__c='Retail Marketing Funds,Intel Partner Alliance',Core_MDF_Category__c='Bank Document Hold Logic'));
      configMap.put('BATCH_RECORD_LIMIT_FOR_UPDATE_REM_DATE',new Core_MDF_Configuration__c(Name='BATCH_RECORD_LIMIT_FOR_UPDATE_REM_DATE',Core_MDF_Value__c='30',Core_MDF_Category__c='Bank Document Hold Logic'));
      configMap.put('ALLOWED_REGION_FOR_BDH_NOTIF',new Core_MDF_Configuration__c(Name='ALLOWED_REGION_FOR_BDH_NOTIF',Core_MDF_Value__c='EMEA',Core_MDF_Category__c='Bank Document Hold Logic'));
      configMap.put('PRC_CLAIM_OPERATION_CUSTOM_PERMISSION',new Core_MDF_Configuration__c(Name='PRC_CLAIM_OPERATION_CUSTOM_PERMISSION',Core_MDF_Value__c='Core_MDF_CCP_RMF_Internal_Claim_Operations',Core_MDF_Category__c='PRC RMF Claim Operation'));
      configMap.put('ELIGIBLE_CP_FOR_OEM_BUDGET_TRANSFER',new Core_MDF_Configuration__c(Name='ELIGIBLE_CP_FOR_OEM_BUDGET_TRANSFER',Core_MDF_Value__c='Core_MDF_CCP_Budget_Administrator;Core_MDF_CCP_Internal_Budget_transfer',Core_MDF_Category__c='Budget Transfer'));
      configMap.put('ELIGIBLE_PROG_FOR_OEM_BUDGET_TRANSFER',new Core_MDF_Configuration__c(Name='ELIGIBLE_PROG_FOR_OEM_BUDGET_TRANSFER',Core_MDF_Value__c='Client CoMarketing Fund;Data Center CoMarketing Fund',Core_MDF_Category__c='Budget Transfer'));
      configMap.put('PROGRAMS_FOR_BU_SPLIT',new Core_MDF_Configuration__c(Name='PROGRAMS_FOR_BU_SPLIT',Core_MDF_Value__c='Intel Partner Alliance',Core_MDF_Category__c='BU Split Payments'));
      insert configMap.values();
      return configMap;
    }
    
    public static Map<String,Core_MDF_CCP_Budget_Transfer_Config__c> createCCPBudgetTransferData(){
      Map<String,Core_MDF_CCP_Budget_Transfer_Config__c> configMap = new Map<String,Core_MDF_CCP_Budget_Transfer_Config__c>();
      configMap.put('CCP Budget Administrator',new Core_MDF_CCP_Budget_Transfer_Config__c(Name='CCP Budget Administrator',Core_MDF_Budget_Type_Txt__c='OEM CMP;CCF 1.0;DCF 1.0',Core_MDF_Custom_Permission_Name_Txt__c='Core_MDF_CCP_Budget_Administrator',Core_MDF_Program_Txt__c='Client CoMarketing Fund;Data Center CoMarketing Fund'));
      configMap.put('CCP Internal MDF Budget Manager',new Core_MDF_CCP_Budget_Transfer_Config__c(Name='CCP Internal MDF Budget Manager',Core_MDF_Budget_Type_Txt__c='MDF;MDF+',Core_MDF_Custom_Permission_Name_Txt__c='Core_MDF_CCP_Internal_MDF_Budget_Manager',Core_MDF_Program_Txt__c='Client CoMarketing Fund;Data Center CoMarketing Fund'));
      insert configMap.values();
      return configMap;
    }
    
    public static List<Core_Trigger_Executions__c> byPassFeature(List<String> functionalityKeys, Boolean isActive, Boolean isInsert){
     List<Core_Trigger_Executions__c> byPassFeatures = new List<Core_Trigger_Executions__c>();
        if(!functionalityKeys.isEmpty()){
            for(String funKey: functionalityKeys){
                Core_Trigger_Executions__c byPass = new Core_Trigger_Executions__c();
                byPass.Name = funKey;
                byPass.Core_Active__c = isActive;
                byPass.Core_Class_Name__c = 'TestClass';
                byPass.Core_Description__c = funKey;
                byPass.Core_Object__c = 'TestObject';
                byPass.Core_Trigger_Events__c = 'TestTriggerEvent';
                byPassFeatures.add(byPass);
            }
        }        
        if(isInsert){
            if(!byPassFeatures.isEmpty())
                Database.insert(byPassFeatures);
        }
        return byPassFeatures;
    }
     public static Core_MDF_PICReviewQuestion__c createPICReviewQuestion(String issue, String issueExternal, double sortOrder){
        
        Core_MDF_PICReviewQuestion__c picReviewQuestion = new Core_MDF_PICReviewQuestion__c();
        picReviewQuestion.Core_MDF_Question_English_txt__c = issue;
        picReviewQuestion.Core_MDF_Is_Active_ind__c = true;
        picReviewQuestion.Core_MDF_EffectiveDate_dt__c = System.today().addDays(-1);
        picReviewQuestion.Core_MDF_IneffectiveDate_dt__c = System.today().addDays(30);
        picReviewQuestion.Core_MDF_Question_English_External_txt__c = issueExternal;
        picReviewQuestion.Core_MDF_Sort_Order__c = sortOrder;
        
       
        insert picReviewQuestion;
            
        return picReviewQuestion;
    }
    
    /*public static Core_MDF_PICReviewResult__c createPICReviewResult(String response, PartnerFundClaim claim,Core_MDF_PICReviewQuestion__c question){
        
        Core_MDF_PICReviewResult__c reviewResult = new Core_MDF_PICReviewResult__c();
        //reviewResult.Core_MDF_Claim_ID_id__c = claim.id;
        reviewResult.Core_MDF_Question_id__c = question.id;
        reviewResult.Core_MDF_Response_txt__c = response;
        reviewResult.Core_MDF_StartTime_dtm__c = System.now();
        reviewResult.Core_MDF_EndTime_dtm__c = System.now() + 1;
        
        insert reviewResult;
        
        return reviewResult;
    }*/
    public static Core_MDF_PIC_Review__c insertPICReview(double reviewCycle,String intComments, Datetime startDate, Datetime endDate, Id claimId, Id userId,Boolean isReviewFailed){
        
        Core_MDF_PIC_Review__c picReview = new Core_MDF_PIC_Review__c();
        
        picReview.Core_MDF_InternalComments_txt__c = intComments;
        picReview.Core_MDF_Claim_ID_id__c = claimId;
        picReview.Core_MDF_CycleNumber_nbr__c = reviewCycle;
        picReview.Core_MDF_StartTime_dtm__c = startDate;
        picReview.Core_MDF_EndTime_dtm__c = endDate;
        picReview.Core_MDF_ReviewedBy_id__c = userId; 
        
        if(isReviewFailed == true)
        {
            picReview.Core_MDF_Review_Status_nm__c = 'Failed';
        }
        else if(isReviewFailed == false)
        {
          picReview.Core_MDF_Review_Status_nm__c = 'Completed';  
        }
        
        insert picReview;
        return picReview; 
        
    }
}