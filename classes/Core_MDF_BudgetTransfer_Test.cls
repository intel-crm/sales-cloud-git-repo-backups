/**************************************************************************************
Apex Class Name:  Core_MDF_BudgetTransfer_Test 
Version     : 1.0 
Created Date: 02 08 2018
Function    : Test class for the Core_MDF_BudgetTransfer used for Budget Transfer.
Author      : Sarah Manuel
Modification Log :
* Change#           Author                   Date                   Description
* ----------------------------------------------------------------------------                 
* Core MDF Rel1   Sarah Manuel         02/08/2018              Original Version
*
*************************************************************************************/
@isTest(SeeAllData=false) 
public class Core_MDF_BudgetTransfer_Test {
    
    @isTest static void validateAccountIDNameMapping(){
        Test.startTest();
        List<Account> toBeUpdated = new List<Account>();
        
        // Creating Account with utility class
        Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Account 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
        
       
        // Updating Accounts 
        acc1.isPartner = true;
        toBeUpdated.add(acc1);
        Database.update(toBeUpdated);
    
        Profile systemAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator' limit 1];
        
        // Creating User with utility class 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.profileId = systemAdminProfile.Id;
        Database.insert(usr);
        System.runAs(usr){
            
            Account accountDetail = Core_MDF_BudgetTransfer.AccountIDNameMapping(acc1.Id);
            System.assertEquals(acc1.Name, accountDetail.Name);
            
        }
        Test.stopTest();
    }
    
    @isTest static void validatecheckAccess(){  
        Test.startTest();
        Profile systemAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator' limit 1];
        
        // Creating User with utility class 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.profileId = systemAdminProfile.Id;
        Database.insert(usr);
        System.runAs(usr){
            
            System.assertEquals(false, Core_MDF_BudgetTransfer.checkAccess());
            
        }
        Test.stopTest();
    }
    
    @isTest static void validateSearchAccountsLookup(){
        Test.startTest();
        List<Account> toBeUpdated = new List<Account>();
        
        // Creating channel program with utility class
        ChannelProgram cp1 = Core_MDF_CCP_TestDataUtility.createProgram ('Client Co-Marketing Fund','Client CoMarketing Fund', true);
    
        // Creating Account with utility class
        Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Account 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
        
        Account acc2 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account 2', cp1.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc1.Id, true);
        
       
        // Updating Accounts 
        acc1.isPartner = true;
        acc2.isPartner = true;
      
        toBeUpdated.add(acc1);
        toBeUpdated.add(acc2);
       
        Database.update(toBeUpdated);
        
       
    
        Profile systemAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator' limit 1];
        
        // Creating User with utility class 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.profileId = systemAdminProfile.Id;
        Database.insert(usr);
        
        System.runAs(usr){
            
            
            List<Account> accountDetail = Core_MDF_BudgetTransfer.SearchAccountsLookup(acc2.Name);
            if(!accountDetail.IsEmpty() && accountDetail.size()>0){
                System.assertEquals(acc2.Id, accountDetail[0].Id);
            }
        }
        Test.stopTest();
    }
    
    @isTest static void validateGetToAccounts(){
        List<Account> toBeUpdated = new List<Account>();
        Test.startTest();
        // Creating channel program with utility class
        ChannelProgram cp1 = Core_MDF_CCP_TestDataUtility.createProgram ('Client Co-Marketing Fund','Client CoMarketing Fund', true);
    
        // Creating Account with utility class
        Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Account 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
        
        Account acc2 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account 2', cp1.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc1.Id, true);
        
        Account acc3 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account 3', cp1.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc2.Id, true);
        
        Account acc4 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account 4', cp1.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc3.Id, true);
    
        // Updating Accounts 
        acc1.isPartner = true;
        acc2.isPartner = true;
        acc3.isPartner = true;
        acc4.isPartner = true;
        toBeUpdated.add(acc1);
        toBeUpdated.add(acc2);
        toBeUpdated.add(acc3);
        toBeUpdated.add(acc4);
        Database.update(toBeUpdated);
        
        Profile systemAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator' limit 1];
        
        // Creating User with utility class 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.profileId = systemAdminProfile.Id;
        Database.insert(usr);
        
        System.runAs(usr){
            
            List<Account> accountDetail = Core_MDF_BudgetTransfer.GetToAccounts(acc4.Id);
            if(!accountDetail.IsEmpty() && accountDetail.size()>0){
                System.assertEquals(acc2.Id, accountDetail[0].Id);
                System.assertEquals(acc3.Id, accountDetail[1].Id);
            }
        }
        Test.stopTest();
    }
    
    @isTest static void validateGetBudgetList(){
        List<Account> toBeUpdated = new List<Account>();
        
        // Creating channel program with utility class
        ChannelProgram cp1 = Core_MDF_CCP_TestDataUtility.createProgram ('Client Co-Marketing Fund','Client CoMarketing Fund', true);
        ChannelProgram cp2 = Core_MDF_CCP_TestDataUtility.createProgram ('Data Center Co-Marketing Fund','Data Center CoMarketing Fund', true);
    
        // Creating Account with utility class
        Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Account 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
        
        Account acc2 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account 2', cp1.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc1.Id, true);
        
        Account acc3 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account 3', cp1.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc2.Id, true);
        
        Account acc4 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account 4', cp1.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc3.Id, true);
    
        // Updating Accounts 
        acc1.isPartner = true;
        acc2.isPartner = true;
        acc2.Core_MDF_CoMarketingActive__c = true;
        acc3.isPartner = true;
        acc3.Core_MDF_CoMarketingActive__c = true;
        acc4.isPartner = true;
        acc4.Core_MDF_CoMarketingActive__c = true;
        toBeUpdated.add(acc1);
        toBeUpdated.add(acc2);
        toBeUpdated.add(acc3);
        toBeUpdated.add(acc4);
        Database.update(toBeUpdated);
        
        PartnerMarketingBudget pbm1 = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget 1', Core_MDF_CCP_TestDataUtility.Budget_Record_Type, acc2.Id, cp1.Id, 3000, Date.newInstance(2019,01,01), Date.newInstance(2019,12,31), true);
      
        PartnerMarketingBudget pbm2 = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget 2', Core_MDF_CCP_TestDataUtility.Budget_Record_Type, acc2.Id, cp1.Id, 3000, Date.newInstance(2020,01,01), Date.newInstance(2020,12,31), true);
        
        PartnerFundAllocation pfaRecord = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test PFA', pbm2, acc2, 1000, true);
        PartnerFundAllocation pfaRecord2 = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test PFA', pbm2, acc3, 300, true);
        Test.startTest();
        Profile systemAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator' limit 1];
        
        // Creating User with utility class 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.profileId = systemAdminProfile.Id;
        Database.insert(usr);
         
        System.runAs(usr){
            
           
            try
            {
                List<PartnerMarketingBudget> pbmList1 = Core_MDF_BudgetTransfer.GetBudgetList (acc2.Id);
                
                List<PartnerMarketingBudget> pbmList2 = Core_MDF_BudgetTransfer.GetBudgetList (acc3.Id);
                List<PartnerMarketingBudget> pbmList3 = Core_MDF_BudgetTransfer.GetBudgetList (acc4.Id);
                
                System.assertEquals(pbm2.Id, pbmList1[0].Id);
            }
            catch(Exception ex)
            {
                System.debug(ex.getMessage());
            }
        }
              test.stopTest();
    }
    
    @isTest static void validateGetBalanceAllocationAmount(){
        
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
        
        List<Account> toBeUpdated = new List<Account>();
        
        // Creating channel program with utility class
        ChannelProgram cp1 = Core_MDF_CCP_TestDataUtility.createProgram ('Client Co-Marketing Fund','Client CoMarketing Fund', true);
    
        // Creating Account with utility class
        Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Account 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
        
        Account acc2 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account 2', cp1.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc1.Id, true);
        
        Account acc3 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account 3', cp1.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc2.Id, true);
        
    
        // Updating Accounts 
        acc1.isPartner = true;
        acc2.isPartner = true;
        acc3.isPartner = true;
        toBeUpdated.add(acc1);
        toBeUpdated.add(acc2);
        toBeUpdated.add(acc3);
        Database.update(toBeUpdated);
        
        PartnerMarketingBudget pbm = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget 2', Core_MDF_CCP_TestDataUtility.Budget_Record_Type, acc2.Id, cp1.Id, 30000, System.today(), System.today().addDays(364), true);
        
        PartnerFundAllocation pfaRecord = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test PFA', pbm, acc2, 30000, true);
    
        Profile systemAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator' limit 1];
        
        // Creating User with utility class 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.profileId = systemAdminProfile.Id;
        Database.insert(usr);
        
        System.runAs(usr){
            
            pbm.IsIgnoreValidation = true;
            update pbm;
            
            PartnerFundAllocation pfa = [Select id, Amount from PartnerFundAllocation where BudgetId =: pbm.Id and Title='Test PFA' limit 1];
            
            Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 12','Gaming','Intel® Core™ i7 Processor', Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', System.today(), System.today().addDays(300), 10000, 'Always Connected PC', acc2.Id,'Desktop', true);
            Test.startTest();
            PartnerFundRequest testPartnerFundRequestRecord = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(camp.id,Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,acc2.Id,pfa,pbm,'ALBANIA','Consumer','Desktop','Intel® Corporate Logo','Broadcast','Radio','Draft',true);
            testPartnerFundRequestRecord.Amount = testPartnerFundRequestRecord.RequestedAmount;
            //testPartnerFundRequestRecord.AllocationId = pfa.Id;
            testPartnerFundRequestRecord.Status = 'Approved';
            update testPartnerFundRequestRecord;
             
            Core_MDF_Bank__c bank = Core_MDF_CCP_TestDataUtility.createBank(acc1.Id, 'Core_MDF_Client_CoMarketing_Fund', true,'1231231230');
            Core_MDF_Account_Bank_Mapping__c accountBankMap = Core_MDF_CCP_TestDataUtility.createAccountBankMap(acc2.Id, bank.Id, true);
            Test.stopTest();
            PartnerFundClaim claim1 = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, testPartnerFundRequestRecord.Id, System.today(), System.today(), 5000.00, System.today(), bank.Id, true);
            claim1.Status = 'Approved';
            update claim1;
            
            PartnerFundAllocation pfaNew = [Select id, Core_MDF_Available_Allocation_Amount__c from PartnerFundAllocation where BudgetId =: pbm.Id and Title='Test PFA' limit 1];
            Decimal amount = Core_MDF_BudgetTransfer.GetBalanceAllocationAmount(acc2.Id, pbm.Id);
            
            System.assertEquals(pfaNew.Core_MDF_Available_Allocation_Amount__c, amount);
           
        }
    }
    
    
    @isTest static void validateTransferAllocationAmount(){
       List<Account> toBeUpdated = new List<Account>();
        test.startTest();
        // Creating channel program with utility class
        ChannelProgram cp1 = Core_MDF_CCP_TestDataUtility.createProgram ('Client Co-Marketing Fund','Client CoMarketing Fund', true);
        ChannelProgram cp2 = Core_MDF_CCP_TestDataUtility.createProgram ('Data Center Co-Marketing Fund','Data Center CoMarketing Fund', true);
    
        // Creating Account with utility class
        Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Account 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
        
        Account acc2 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account 2', cp1.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc1.Id, true);
        
        Account acc3 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account 3', cp1.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc2.Id, true);
        
    
        // Updating Accounts 
        acc1.isPartner = true;
        acc2.isPartner = true;
        acc3.isPartner = true;
        toBeUpdated.add(acc1);
        toBeUpdated.add(acc2);
        toBeUpdated.add(acc3);
        Database.update(toBeUpdated);
        
        PartnerMarketingBudget pbm1 = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget 1', Core_MDF_CCP_TestDataUtility.Budget_Record_Type, acc2.Id, cp1.Id, 3000, Date.newInstance(2019,01,01), Date.newInstance(2019,12,31), true);
      
       
    
        Profile systemAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator' limit 1];
        
        // Creating User with utility class 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.profileId = systemAdminProfile.Id;
        Database.insert(usr);
        
        System.runAs(usr){
            
            
            pbm1.Core_MDF_Budget_Status__c = 'Approved';
            update pbm1;
            
            pbm1.Core_MDF_Budget_Status__c = 'Released';
            update pbm1;
            
            string response1 = Core_MDF_BudgetTransfer.TransferAllocationAmount((string)acc2.Id, (string)acc3.Id, (string)pbm1.Id, 500.00,Label.Core_MDF_Budget_Transfer_Type_Manual);
            System.assertEquals('Success', response1);
      
        }
              test.stopTest();
    }
    
    @isTest static void validateTransferAllocationAmountForPendingReviewBudget(){
       List<Account> toBeUpdated = new List<Account>();
        
        // Creating channel program with utility class
        ChannelProgram cp1 = Core_MDF_CCP_TestDataUtility.createProgram ('Client Co-Marketing Fund','Client CoMarketing Fund', true);
        ChannelProgram cp2 = Core_MDF_CCP_TestDataUtility.createProgram ('Data Center Co-Marketing Fund','Data Center CoMarketing Fund', true);
    
        // Creating Account with utility class
        Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Account 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
        
        Account acc2 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account 2', cp1.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc1.Id, true);
        
        Account acc3 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account 3', cp1.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc2.Id, true);
    
        // Updating Accounts 
        acc1.isPartner = true;
        acc2.isPartner = true;
        acc3.isPartner = true;
        toBeUpdated.add(acc1);
        toBeUpdated.add(acc2);
        toBeUpdated.add(acc3);
        Database.update(toBeUpdated);
        test.startTest();
        PartnerMarketingBudget pbm1 = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget 1', Core_MDF_CCP_TestDataUtility.Budget_Record_Type, acc2.Id, cp1.Id, 3000, Date.newInstance(2019,01,01), Date.newInstance(2019,12,31), true);
      
    
        Profile systemAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator' limit 1];
        
        // Creating User with utility class 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.profileId = systemAdminProfile.Id;
        Database.insert(usr);
        System.runAs(usr){
            

           // PartnerFundAllocation pfaRecord = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test PFA', pbm1, acc2, 1000, true);
            PartnerFundAllocation pfaRecord2 = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test PFA', pbm1, acc3, 300, true);
            
            string response1 = Core_MDF_BudgetTransfer.TransferAllocationAmount((string)acc2.Id, (string)acc3.Id, (string)pbm1.Id, 500.00,Label.Core_MDF_Budget_Transfer_Type_Manual);
            System.assertEquals('Success', response1);
           
        }
         test.stopTest();
    }

}