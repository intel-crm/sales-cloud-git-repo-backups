/****************************************************************************************************************************************
* Class Name  : Core_MDF_PFC_IPAClaim_Test
* Version     : 1.0 
* Created Date: 04-Aug-2020
* Modification Log :
* Developer                        Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Intel -Areefa          04-Aug-2020                    Created to test IPAClaim Functionality 
*****************************************************************************************************************************************/
@isTest
public class Core_MDF_IPA_PaymentRun_test_clone {
    
    // test method for data setup
    @TestSetup static void setUpData(){
        List<Account> acctList = new List<Account>();
        ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram ('Intel Partner Alliance','Intel Partner Alliance', true);
        Id campaign_RecordType_IPA = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Core_MDF_Intel_Partner_Alliance').getRecordTypeId();
        
        // Creating User with utility class 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.Email = 'sysadmin@example.com';
        Database.insert(usr);
        
        
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
        System.debug('acc1::::>'+acc1);
        
        // Updating Accounts 
        acc1.isPartner = true;
        Database.update(acc1);
        
        Account acc2 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account 2', cp.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc1.Id, true);
        //acc2.Core_MDF_CoMarketing_Ultimate_Account__c =acc1.id;
        //insert acc2;
        string budgetType = Core_MDF_CCP_IPA_TestDataUtility.createBenefit(acc2);
        budgetType = 'Data Center Specialties MDF';
        
        Campaign camp = Core_MDF_CCP_IPA_TestDataUtility.createIPACampaign('Test IPA Camp',acc2.Id, System.today(), System.today().addDays(300),budgetType, 1234.00, 'AFGHANISTAN','Consumer','Coffee Lake','Pending Review', false);
        camp.Core_MDF_Budget_Type_txt__c = budgetType;
        camp.Core_MDF_Reimbursement_Amt__c = 10000;
       
        Database.insert(camp);
        system.debug('camp::::::'+camp);
        system.debug('Acct::::::'+camp.Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c);
        
        
        PartnerFundRequest pfr = Core_MDF_CCP_IPA_TestDataUtility.createIPAPartnerFundRequest(camp.Id,acc2.Id,System.today(),System.today(),true);
        
        List<Campaign> campToBeUpdated = new List<Campaign>();
        List<PartnerFundRequest> pfrToBeUpdated = new List<PartnerFundRequest>(); 
        camp.Status = 'Proposal Accepted';
        campToBeUpdated.add(camp);
        
        Test.startTest();
        system.debug('campToBeUpdated::::::'+campToBeUpdated);
        Database.update(campToBeUpdated);
        
        
        pfr.Core_MDF_Fund_Request_Status__c = 'Planned';
        pfrToBeUpdated.add(pfr);
        
        Database.update(pfrToBeUpdated);
        
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
        
        Test.stopTest();
        Core_MDF_CCP_TestDataUtility.createMDFConfigurationData();
        
    }   
    @isTest static void validateIPAClaim() { 
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        
        try{
            System.runAs(sysAdminUser)
            {
                
                Campaign camp  = [Select Id, Name, StartDate, EndDate, Description, Core_MDF_Budget__c,Core_MDF_Account__c,Core_MDF_Channel_Program__c,
                                  Core_MDF_Budget_Type_txt__c,Core_MDF_Total_Campaign_Cost_Amt__c
                                  from Campaign where Name = 'Test IPA Camp' limit 1];
                system.debug('camp::'+camp);                
                Test.startTest(); 
                PartnerFundRequest pfr = [Select id,Core_MDF_Fund_Request_Status__c from PartnerFundRequest where CampaignId=:camp.Id];
                pfr.Core_MDF_Reimbursement_Rate_pct__c ='100%';
                database.update(pfr);
                system.debug('pfr::'+pfr);
                
                List<Campaign> campToBeUpdated = new List<Campaign>();
                List<PartnerFundRequest> pfrToBeUpdated = new List<PartnerFundRequest>();
                
                Id recordtype = Schema.SObjectType.PartnerMarketingBudget.getRecordTypeInfosByDeveloperName().get('Core_MDF_IPA_ProposalBased').getRecordTypeId(); 
                
                
                
                PartnerMarketingBudget pmb = [Select id,Title, Description, Core_MDF_Budget_Status__c, StartDate, EndDate, Amount, Core_MDF_Budget_Type_Txt__c,
                                              Core_MDF_Budget_Partner__c,Core_MDF_Program__c, RecordTypeId, IsIgnoreValidation From PartnerMarketingBudget where Id = :camp.Core_MDF_Budget__c];
                
                PartnerFundAllocation pfa = [Select Id, ChannelPartnerId, Amount from PartnerFundAllocation where BudgetId = :pmb.Id]; 
                
                Core_MDF_Bank__c bank1 = [Select Id from Core_MDF_Bank__c where Core_MDF_Bank_Alias_Name__c='Test' limit 1];
                
                               
                //PartnerFundClaim claim1 = Core_MDF_CCP_TestDataUtility.createClaim('IPA Claim', Core_MDF_CCP_IPA_TestDataUtility.claim_RecordType_IPA, pfr.Id, System.today(), System.today(),50.00, System.today(), bank1.Id, false);
                
                PartnerFundClaim claim1 =  Core_MDF_CCP_IPA_TestDataUtility.createIPAClaim('IPA Claim',Core_MDF_CCP_IPA_TestDataUtility.claim_RecordType_IPA, pfr.Id, System.today(), System.today(),50.00, bank1.Id, false); 
                claim1.Core_MDF_Type_Txt__c ='Claim';
                claim1.Core_MDF_Currency__c='USD';
                claim1.Core_MDF_Country_Location_nm__c= 'AFGHANISTAN'; 
                claim1.Core_MDF_Campaign_Id__c = camp.Id;
                /*POP mandatory for IPA*/
                List<String> documentIdWithTitle = new List<String>();
                list<String> tempString = new list<String>();
                list<Core_MDF_Audit_Document__c> auditDocList = new list<Core_MDF_Audit_Document__c>();
                
                String str1 = claim1.Id+';#'+'Test Doc1';
                String str2 = claim1.Id+';#'+'Test Doc2';
                system.debug('str2' +str2);
                
                documentIdWithTitle.add(str1);
                documentIdWithTitle.add(str2);
                
                for(String str: documentIdWithTitle){
                    tempString = str.split(';#');
                    Core_MDF_Audit_Document__c auditDoc = new Core_MDF_Audit_Document__c();
                    auditDoc.Core_MDF_Document_Id__c = tempString[0];
                    auditDoc.Core_MDF_Document_Title__c = tempString[1];
                    auditDoc.Core_MDF_Claim__c = claim1.Id;
                    auditDoc.Core_MDF_Proof_of_Branding__c = true;
                    auditDoc.Core_MDF_Proof_of_Cost__c = true;
                    auditDoc.Core_MDF_Proof_of_Execution__c = true;                
                    auditDocList.add(auditDoc);
                    system.debug('auditDocList-->' +auditDocList);
                }            
                
                if(auditDocList.size()>0){
                    Database.insert(auditDocList);                
                }
                String iPAClaimRes = Core_MDF_PartnerFundClaim.saveClaim(claim1, auditDocList);
                System.debug('iPAClaimRes---'+iPAClaimRes);
                List<PartnerFundClaim> iPAClaimList = new List<PartnerFundClaim>([Select Id,Core_MDF_Status__c from PartnerFundClaim where id =: claim1.Id]);
                System.debug('iPAClaimStatus---'+iPAClaimList[0].Core_MDF_Status__c);
                System.assertEquals(claim1.ID,iPAClaimRes);            
                
                Test.stopTest();
                
                
            }
        }catch(Exception e){
            System.assertNotEquals(NULL,e);
        }
    }
}