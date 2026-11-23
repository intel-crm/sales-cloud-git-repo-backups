@isTest
private class Core_PrimeAccountName_BatchTest {
  static List<Account>  lstAccount;
  static List<Opportunity>  lstOpp;
  Static String batchClassName;
  static Core_Batch_Header__c batchHeader;
  @testSetup
  static void setupTestData(){    
      
      
        
    
       batchClassName='Core_PrimeAccountName_BatchClass';         
        lstAccount = Core_Test_Utility.createAccount(1);
         lstAccount[0].Core_Prime_Account_Name__c='PrimeAccountName1';
         lstAccount[0].Core_Sales_Groups__c = 'GMP India Sales Group'; 
        insert lstAccount;
        lstOpp = Core_Test_Utility.createOpportunity(1);
        lstOpp[0].AccountId=lstAccount[0].Id;
        lstOpp[0].Core_Opp_Prime_Account_Name__c='PrimeAccountName2';
        insert lstOpp;    
        lstOpp[0].Core_Opp_Prime_Account_Name__c='PrimeAccountName3';
        update lstOpp;

        batchHeader                = new Core_Batch_Header__c();
        batchHeader.Description__c = 'Core_PrimeAccountName_BatchClass';
        batchHeader.Name           = 'Core_PrimeAccountName_BatchClass';        
        insert batchHeader;       
    }
     static testMethod void executeSheduleTest() {
        Test.startTest();
             String CRON_EXP = system.now().addMinutes(10).format('ss mm HH dd MM ? yyyy');        
             System.schedule('Core_PrimeAccountNameScheduler', CRON_EXP, new Core_PrimeAccountNameScheduler());
             database.executebatch(new Core_PrimeAccountName_BatchClass(),50);            
        Test.stopTest(); 
    }
  
  
    }