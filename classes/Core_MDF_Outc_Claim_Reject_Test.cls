@isTest
public class Core_MDF_Outc_Claim_Reject_Test {
    
    // test method for data setup
    @TestSetup static void setUpData(){
        List<Account> acctList = new List<Account>();
        ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram ('Intel Partner Alliance','Intel Partner Alliance', true);
        Id campaign_RecordType_IPA = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Core_MDF_Intel_Partner_Alliance').getRecordTypeId();
        
        // Creating User with utility class 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.Email = 'sysadmin@example.com';
        Database.insert(usr);

        System.runAs(usr){
            // Creating a map of profile name and profile Id
            Map<String,Id> profileToId = new Map<String,Id>();
            List<User> userList = new List<User>();
            for(Profile prfl:[SELECT Id,Name FROM Profile WHERE Name IN ('System Administrator','CCP - Core Access')]) {
                profileToId.put(prfl.Name,prfl.Id);
            }
            // Creating a map of PS names and PS
            Map<String,PermissionSet> nameToPerSet = new Map<String,PermissionSet>();
            for(PermissionSet pSet:[SELECT Id,Name FROM PermissionSet WHERE Name IN (
                'Core_MDF_CCP_Internal_IPA_Program_Adm',
                'View_All_Data'
            )]) {
                nameToPerSet.put(pSet.Name,pSet);
            }
            
            PermissionSet ipaPaymentAdmPS = nameToPerSet.get('Core_MDF_CCP_Internal_IPA_Program_Adm');
            PermissionSet viewAllDataPS = nameToPerSet.get('View_All_Data');
            
            
            User usr2 = Core_MDF_CCP_TestDataUtility.createUser(false); 
            usr2.Email='testPayment@example.com';
            usr2.LastName='PayAdmUser';
            usr2.profileId = profileToId.get('CCP - Core Access');
            usr2.IsActive = true;
            userList.add(usr2); 
            
            // Creating User with utility class 
            User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr1.Email = 'systemadmin@example.com';
            userList.add(usr1);
            database.insert(userList);
            List<PermissionSetAssignment> permSetAssgnLst = new List<PermissionSetAssignment>();
            
            // Assigning IPA Payment Admin PS
            PermissionSetAssignment assignPermissionSetObj2 = new PermissionSetAssignment();
            assignPermissionSetObj2.AssigneeId = usr.Id;
            assignPermissionSetObj2.PermissionSetId = ipaPaymentAdmPS.Id;
            permSetAssgnLst.add(assignPermissionSetObj2);
            
            system.runAs(usr){
                Database.insert(permSetAssgnLst);
                
            }
        }
        
        
        Id acctRecord_Type = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Core_Partner_Account_Group').getRecordTypeId();
        Account acc = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test IPA Accounttest', acctRecord_Type, false);
        acc.Core_MDF_CoMarketingActive__c = false;
        insert acc;
        
        // Creating Account with utility class
        Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test IPA Account', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
        acc1.Core_Intel_Partner_Alliance_PartnerGroup__c=true;
        acc1.Core_MDF_CoMarketingActive__c = true;
        acc1.Core_IPA_One_Partner_Id__c=acc.id;
        acctList.add(acc1);
        insert(acctList);
        
        // Updating Accounts 
        acc1.isPartner = true;
        Database.update(acc1);
        
        Account acc2 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account 2', cp.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc1.Id, true);

        Id IUPGM_recordtype_IPA = Schema.SObjectType.Core_MDF_Int_Users_Partner_Geo_Mapping__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Intel_Partner_Alliance').getRecordTypeId();
        List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmList = new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm1 = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();        
        iupgm1.Core_MDF_Program_nm__c = 'Intel Partner Alliance';
        iupgm1.Core_MDF_Region_Sub_Region_nm__c = 'WW';
        iupgm1.Core_MDF_Approval_Region_nm__c = 'WW';
        iupgm1.Core_MDF_User_id__c = usr.Id;
        iupgm1.Core_MDF_All_Budget_Type_Access_Ind__c = true;
        iupgm1.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_IPA_Program_Adm';
        iupgm1.Core_MDF_All_Accounts_cd__c = 'No';
        iupgm1.Core_MDF_Account_id__c = acc1.Id;
        iupgm1.Core_MDF_Active_Ind__c =  true;
        iupgm1.RecordTypeId = IUPGM_recordtype_IPA;
        iupgmList.add(iupgm1);
        system.runAs(usr){
            insert iupgmList;
        }

        Id budget_Retail_Record_Type = Schema.SObjectType.PartnerMarketingBudget.getRecordTypeInfosByDeveloperName().get('Core_MDF_IPA_ProposalBased').getRecordTypeId();
        PartnerMarketingBudget testBudget = Core_MDF_CCP_TestDataUtility.createBudget('TestBudgetData',budget_Retail_Record_Type,
                                                                                      acc2.id, cp.Id , 2000000000,System.today().addDays(-20),System.today() , 
                                                                                      false);
        testBudget.IsIgnoreValidation = true;
        testBudget.Core_MDF_Budget_Type_Txt__c = 'Proposal I MDF';
        system.runAs(usr){
            insert testBudget;
        }
        PartnerFundAllocation pfa = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('allocation',testBudget,acc2, 100000,true);
        string budgetType = Core_MDF_CCP_IPA_TestDataUtility.createBenefit(acc2);
        budgetType = 'Account Plan';
        
        Campaign camp = Core_MDF_CCP_IPA_TestDataUtility.createIPACampaign('Test IPA Camp',acc2.Id, System.today(), System.today().addDays(300),budgetType, 1234.00, 'AFGHANISTAN','Consumer','Coffee Lake','Pending Review', false);
        camp.Core_MDF_Budget_Type_txt__c = budgetType;
        camp.Core_MDF_Reimbursement_Amt__c = 10000;
       
        Database.insert(camp);
        
        
        PartnerFundRequest pfr = Core_MDF_CCP_IPA_TestDataUtility.createIPAPartnerFundRequest(camp.Id,acc2.Id,System.today(),System.today(),false);
        
        List<Campaign> campToBeUpdated = new List<Campaign>();
        List<PartnerFundRequest> pfrToBeUpdated = new List<PartnerFundRequest>(); 
        camp.Status = 'Proposal Accepted';
        campToBeUpdated.add(camp);
        
        Test.startTest();
        Database.update(campToBeUpdated);
        
        
        pfr.Core_MDF_Fund_Request_Status__c = 'Planned';
        pfr.Status = 'Approved';
        pfr.AllocationId = pfa.Id;
        pfrToBeUpdated.add(pfr);
        
        Database.insert(pfrToBeUpdated);
        
        Core_MDF_CCP_TestDataUtility.insertCurrencyExchangeRates();        
        
        
        List<Core_MDF_Bank__c> listBank = new List<Core_MDF_Bank__c>();
        
        Core_MDF_Bank__c bank = Core_MDF_CCP_TestDataUtility.createBank(acc1.Id, 'Core_MDF_Intel_Partner_Alliance', false,'1231231230');
        bank.Core_MDF_Intel_Company_Code__c = '150';
        bank.Core_MDF_Currency_cd__c = 'USD';
        bank.Core_MDF_Tax_codes_cd__c = 'I0';
        bank.Core_MDF_Bank_Status__c = 'Active';
        database.insert(bank);
        
        //Do Account Bank Mapping for 'bank' and ABM 
        Core_MDF_Account_Bank_Mapping__c abm1 = Core_MDF_CCP_TestDataUtility.createAccountBankMap(acc2.Id,bank.Id,true);
        //Database.insert(abm1);

            List<Core_MDF_Configuration__c> configList = new List<Core_MDF_Configuration__c>();
            Core_MDF_Configuration__c config = new Core_MDF_Configuration__c();
            config.Name = 'ALLOWED_PRG_FOR_RUS_NOTIF';
            config.Core_MDF_Value__c = 'Retail Marketing Funds,Intel Partner Alliance';
            configList.add(config);
            database.insert(configList);
        List<PartnerFundClaim> claimList = new List<PartnerFundClaim>();
        PartnerFundClaim claim1 =  Core_MDF_CCP_IPA_TestDataUtility.createIPAClaim('IPA Claim',Core_MDF_CCP_IPA_TestDataUtility.claim_RecordType_IPA, pfr.Id, System.today(), System.today(),50.00, bank.Id, false); 
            claim1.Core_MDF_Type_Txt__c ='Claim';
            claim1.Core_MDF_Currency__c='USD';
            claim1.Core_MDF_Country_Location_nm__c= 'AFGHANISTAN';
            claim1.Core_MDF_Processing_Preference_nm__c = 'Get paid, then settle';
            claim1.Core_MDF_Campaign_Id__c = camp.Id;
            //claim1.Core_MDF_VAT_Eligibility_Ind__c= true ; 
            //claim1.Core_MDF_VAT_Hold_Ind__c = true;
            claim1.RequestId = pfr.Id;
        
        claimList.add(claim1);
        if(!claimList.isEmpty()){
            insert claimList;
        }
        for(PartnerFundClaim claim : claimList){
            claim.Core_MDF_Status__c = 'Pending Account Manager Clarification';
        }
        update claimList;
        

        //PIC Review
        List<Core_MDF_PIC_Review__c> reviewList = new List<Core_MDF_PIC_Review__c>();
        Core_MDF_PIC_Review__c review1 = createPICReviewResult(claim1.Id,  1, 'Failed', false);
        review1.Core_MDF_CycleNumber_nbr__c = 3;
        reviewList.add(review1);
            
        if(!reviewList.isEmpty()){
            insert reviewList;
        }
        
        Test.stopTest();
        Core_MDF_CCP_TestDataUtility.createMDFConfigurationData();
        
    }
    @isTest 
    static void OutcomeClaimRejection() { 
        Test.startTest();
        User testUser = [SELECT Id FROM User WHERE Email = 'sysadmin@example.com' limit 1];
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test IPA Account' limit 1];
        System.runAs(testUser){          
            
            
            
            // Get IPA Claim
            PartnerFundClaim ipaClaim  = [SELECT Id, Core_MDF_Status__c, Core_MDF_Ultimate_Account_ID__c, Core_MDF_Program__c, Core_MDF_Latest_Review_Cycle_Number_nbr__c
                                 FROM PartnerFundClaim
								Where Core_MDF_Program__c = 'Intel Partner Alliance' AND Core_MDF_Status__c = 'Pending Account Manager Clarification' AND Core_MDF_Latest_Review_Cycle_Number_nbr__c>=2
                                 LIMIT 1];
                        
            list<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgm = [SELECT id,Core_MDF_User_id__c,Core_MDF_Program_nm__c,Core_MDF_GeoSubGeo_Budget_Type_nm__c,Core_MDF_is_User_Active_ind__c,
                                                                     Core_MDF_Role_nm__c,Core_MDF_Region_Sub_Region_nm__c, Core_MDF_Active_Ind__c,Core_MDF_Account_id__c
                                                               FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c
                                                                    where Core_MDF_Account_id__c=:acc.Id
                                                                    and Core_MDF_Active_Ind__c = TRUE
                                                                    and Core_MDF_Role_nm__c='Core_MDF_CCP_Internal_IPA_Program_Adm'
                                                                    AND Core_MDF_is_User_Active_ind__c = TRUE];
            
            
            Core_MDF_Outcome_Claim_Rejection_Batch ipaReminder = new Core_MDF_Outcome_Claim_Rejection_Batch();
            Database.executeBatch(ipaReminder);
            System.Assert(ipaReminder!=null);
            
        }
        
        Test.stopTest();
    }
    public static Core_MDF_PIC_Review__c createPICReviewResult(String claimId, Integer cycleNumber, String status, Boolean isInsert){
        Core_MDF_PIC_Review__c newreview = new Core_MDF_PIC_Review__c(Core_MDF_Claim_ID_id__c = claimId, Core_MDF_CycleNumber_nbr__c = cycleNumber, Core_MDF_Review_Status_nm__c = status,
                                                                    Core_MDF_StartTime_dtm__c = system.now(), Core_MDF_EndTime_dtm__c = system.now().addMinutes(2));
        if(isInsert){
            insert newreview;
        }
        return newreview;
    }
}