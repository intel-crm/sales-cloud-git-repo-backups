@isTest(SeeAllData=false)
private class Test_Core_MDF_AuditSelectionHelper{
    @TestSetup static void setUpData(){
        
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        //Creating User with utility class 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test';
        usr.UserRoleId = usRole.Id;
        Database.insert(usr);

        System.runAs(usr){
            ChannelProgram retailCp = Core_MDF_CCP_TestDataUtility.createProgram ('Retail Marketing Funds','Retail Marketing Funds', true);
            
            Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test RetailAccount 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            acc1.Core_Geo__c = 'APJ';
            Database.insert(acc1);
            
            Account retailAcc = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Retail TestAccount', retailCp.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc1.Id, false); // virtual corp
            retailAcc.Core_Geo__c = 'APJ';
            Database.insert(retailAcc);
            Test.startTest();
            Campaign camp1 = Core_MDF_CCP_TestDataUtility.createCampaign('TestRetailCamp','Gaming','Athena', ' ',
                                                                         Core_MDF_CCP_TestDataUtility.campaign_RecordType_Retail, 'Retail Marketing Funds',
                                                                         System.today() - 48, System.today().addYears(1), 2000, 
                                                                         'Instore innovation', retailAcc.Id,'2-in-1', false);
            camp1.Core_MDF_Budget_Type_txt__c ='Retail MDF';
            Database.insert(camp1);
            
            PartnerMarketingBudget pmb = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget',Core_MDF_CCP_TestDataUtility.budget_Record_Type,
                                                                                   retailAcc.Id,retailCp.Id,5000000,System.today().addDays(-65),System.today().addDays(5), 
                                                                                   true);
            
            PartnerFundAllocation pfa = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test Allocation',pmb,retailAcc,1000000.0,true);
            
            PartnerFundRequest testPartnerFundRequest1 = Core_MDF_CCP_TestDataUtility.createRetailActivity(string.valueof(camp1.Id),                                                                                                         
                                                                                                         string.valueof(retailAcc.id),NULL,NULL,
                                                                                                         false);
            
            testPartnerFundRequest1.Title ='Retail MDF Activity';
            testPartnerFundRequest1.Core_MDF_Activity_Description__c ='Retail MDF Activity';
            //testPartnerFundRequest1.Core_MDF_Budget_Type_txt__c ='Retail MDF';
            testPartnerFundRequest1.Core_MDF_Start_Date__c = System.today() - 40;
            testPartnerFundRequest1.Core_MDF_End_Date__c  = System.today() + 3;
            testPartnerFundRequest1.RequestedAmount =1000;
            testPartnerFundRequest1.Amount=1000;
            //testPartnerFundRequest1.Core_MDF_Country__c ='AFGHANISTAN';
            testPartnerFundRequest1.Core_MDF_Country_nm__c = 'AFGHANISTAN';
            testPartnerFundRequest1.Core_MDF_Fund_Request_Status__c = 'Planned';
            testPartnerFundRequest1.Core_MDF_Budget_Currency_cd__c ='USD'; 
            testPartnerFundRequest1.Core_MDF_Reimbursement_Rate_pct__c='100%';
            Database.insert(testPartnerFundRequest1);
            
            Core_MDF_Bank__c retBank = Core_MDF_CCP_TestDataUtility.createBank(acc1.id,'Core_MDF_Retail_Marketing_Funds',false,'1234567800');
            retBank.Core_MDF_Bank_Status__c = 'Active';   
            retBank.Core_MDF_Intel_Company_Code__c = '150';
            retBank.Core_MDF_Tax_codes_cd__c = 'I0';
            retBank.Core_MDF_Currency_cd__c = 'USD';
            Database.insert(retBank);
            
            Core_MDF_Account_Bank_Mapping__c abm1 = Core_MDF_CCP_TestDataUtility.createAccountBankMap(retailAcc.Id,retBank.Id,true);
            
            PartnerFundClaim claim1 = Core_MDF_CCP_TestDataUtility.createClaim('Retail MDF Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_Retail, testPartnerFundRequest1.Id, System.today(), System.today(), 50.00, System.today(), retBank.Id, false);
            claim1.Core_MDF_Type_Txt__c ='Claim';
            claim1.Core_MDF_Currency__c='USD';
            claim1.Core_MDF_Country_Location_nm__c= 'AFGHANISTAN'; 
            claim1.Core_MDF_VAT_Eligibility_Ind__c = TRUE;
            claim1.Core_MDF_Status__c = 'Hold';
            claim1.Core_MDF_VAT_Hold_Ind__c = TRUE;
            /*POP mandatory for Retail*/
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
            Test.stopTest();
            Database.insert(claim1);
            
            Core_MDF_Claim_VAT_Info__c vatInvoice = new Core_MDF_Claim_VAT_Info__c();
            vatInvoice.Core_MDF_Claim_Id__c = claim1.id;
            vatInvoice.Core_MDF_VAT_Invoice_Number_Txt__c = '1234';
            vatInvoice.Core_MDF_Status_Txt__c = 'Pending Documents';
            Database.insert(vatInvoice);
        }
    }
    
    @isTest
    static void testVATWithStatusRevisionReq()
    {
        test.startTest();
        User sysAdminUser = [SELECT Id,Email,LastName from User where LastName = 'User Test' limit 1];
        System.runAs(sysAdminUser){
            Core_MDF_Claim_VAT_Info__c vatInvoice = [Select Id,Core_MDF_Status_Txt__c from Core_MDF_Claim_VAT_Info__c where 
                                                   Core_MDF_VAT_Invoice_Number_Txt__c = '1234'];
            
            vatInvoice.Core_MDF_Status_Txt__c = 'Revision Required';
            Database.Update(vatInvoice);
            system.assertEquals('Revision Required', vatInvoice.Core_MDF_Status_Txt__c);
        }
        Test.stopTest();
    }
    @isTest
    static void testVATWithStatusUnderReview()
    {
        test.startTest();
        User sysAdminUser = [SELECT Id,Email,LastName from User where LastName = 'User Test' limit 1];
        System.runAs(sysAdminUser){
            Core_MDF_Claim_VAT_Info__c vatInvoice =[Select Id,Core_MDF_Status_Txt__c from Core_MDF_Claim_VAT_Info__c where 
                                                        Core_MDF_VAT_Invoice_Number_Txt__c = '1234'];
            try{
                vatInvoice.Core_MDF_Status_Txt__c = 'Under Review';
                Database.Update(vatInvoice);
            }catch(Exception e){
                String message = e.getMessage();
                System.assert(message.contains(Label.Core_MDF_Claim_VAT_Invoice_File_ErrorMsg));                
            }
            
        }
        Test.stopTest();
    }
}