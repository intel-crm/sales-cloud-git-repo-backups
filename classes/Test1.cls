public class Test1 {
    
    public static void testm1(){
       List<Account> lstOfAccount = new List<Account>();  
       List <Account_Business_Types__c> lstAccountBusinessType = new List <Account_Business_Types__c>();
 
        Account acc = new Account();
                acc.Name = 'Chanda101';
                acc.BillingCountryCode = 'IND';
                acc.BillingCity = 'BSR';
                acc.BillingStreet = 'test';


          Account acc2 = new Account();
                acc2.Name = 'Chanda102';
                acc2.BillingCountryCode = 'IND';
                acc2.BillingCity = 'BSR';
                acc2.BillingStreet = 'test';
        
          Account acc3 = new Account();
                acc3.Name = 'Chanda103';
                acc3.BillingCountryCode = 'IND';
                acc3.BillingCity = 'BSR';
                acc3.BillingStreet = 'test';


                lstOfAccount.add(acc);
                lstOfAccount.add(acc2);
                lstOfAccount.add(acc3);
                
                System.debug('Ankit+lstOfAccount===>'+lstOfAccount);
        Database.SaveResult[] resultListforAccount;
        Savepoint sp = Database.setSavepoint();
        try{
                 resultListforAccount = Database.insert(lstOfAccount, true);
            for(Database.SaveResult sr : resultListforAccount) {
                    System.debug('Ankit+sr===>'+sr);
                    if(sr.isSuccess()){
                        Account_Business_Types__c accountBusinessType = new Account_Business_Types__c();
                        accountBusinessType.Account__c = sr.getid();
                    	accountBusinessType.Effective_Start_Date__c = System.today();
                    	lstAccountBusinessType.add(accountBusinessType);
                    }
                }
            
            Database.SaveResult[] resultListforBusiness = Database.insert(lstAccountBusinessType, true);
             for(Database.SaveResult sr2 : resultListforBusiness) {
                    System.debug('Ankit+sr2===>'+sr2);
                    if(sr2.isSuccess()){
                    }
                }
            
        }catch(Exception ex){
            System.debug('Ankit+catch===>'+ex.getMessage());
                Database.RollBack(sp);
        }
                
            

    }

}