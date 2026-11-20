/*
 * class to handle the account number generation logic implementation
*/
public class PRM_AI_AccountNumberGenerator implements UCD_ACM_ServiceContracts.IAfterInsertAccountTrigger {
    static boolean isAccountNumberInsertCalled = false;
    Id accountRecordType = Schema.getGlobalDescribe()
    .get('Account')
    .getDescribe()
    .getRecordTypeInfosByDeveloperName()
    .get(System.Label.PRM_Intel_Account)
    .getRecordTypeId();

    public void execute(UCD_ACM_UnitOfWork unitOfWork, Map<Id, Account> oldAccounts, Map<Id, Account> newAccounts){
        try{
            if ( isAccountNumberInsertCalled == false) {
              List<Account> accountNewList = newAccounts.values();
              AU_AccNumberGenerator_Method(accountNewList);
                     
         }
      } 
      catch(Exception ex){
            System.debug('Error in class PRM_AI_AccountNumnerGenerator. Error - ' + ex.getMessage());
      }
    }
    private void AU_AccNumberGenerator_Method(List<Account> accountNewList){
        List<Account> accList = new List<Account>();
              for (Account acc : accountNewList) {
                if (String.isNotBlank(acc.AccountNumber) && acc.RecordTypeId == accountRecordType) {
                  accList.add(acc);
                }
              }
              System.debug('accList'+accList);
              if(accList!= null && !accList.isEmpty()) {
               PRM_AccountNumberGenerator.updateAccountNumberCS(accList, null);
               isAccountNumberInsertCalled = true;
            }         
    }
    
}