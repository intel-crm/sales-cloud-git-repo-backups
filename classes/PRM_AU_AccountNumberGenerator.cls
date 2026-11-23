/*
 * class to handle the account number generation logic implementation
*/
public class PRM_AU_AccountNumberGenerator implements UCD_ACM_ServiceContracts.IAfterUpdateAccountTrigger  {
    static boolean isAccountNumberUpdateCalled = false;
    Id accountRecordType = Schema.getGlobalDescribe()
    .get('Account')
    .getDescribe()
    .getRecordTypeInfosByDeveloperName()
    .get(System.Label.PRM_Intel_Account)
    .getRecordTypeId();
    public void execute(UCD_ACM_UnitOfWork unitOfWork, Map<Id, Account> oldAccounts, Map<Id, Account> newAccounts){
        try{
            if (isAccountNumberUpdateCalled == false) {
              List<Account> accountNewListupdate = newAccounts.values();
              //Map<Id, Account> oldMap = oldAccounts;
              AU_AccNumberGenerator_Method(accountNewListupdate,oldAccounts);                           
           }            
       }
       catch(Exception ex){
            System.debug('Error in class PRM_AU_AccountNumberGenerator. Error - ' + ex.getMessage());
      }        
    }
    private void AU_AccNumberGenerator_Method(List<Account> accountNewListupdate,Map<Id, Account> oldMap){
        List<Account> accListupdate = new List<Account>(); 
        for (Account acc : accountNewListupdate) {
            //system.debug('oldMap--->'+oldMap);
            //system.debug('oldMap.get(acc.Id)'+oldMap.get(acc.Id));
            if (oldMap !=null && oldMap.get(acc.Id).AccountNumber!=acc.AccountNumber &&
                String.isNotBlank(acc.AccountNumber) && acc.RecordTypeId == accountRecordType) {
                accListupdate.add(acc);
                //system.debug('accAccountNumber'+acc.AccountNumber);
                }
         }
         //System.debug('accListupdate'+accListupdate);
         if(accListupdate!= null && !accListupdate.isEmpty()) {
             PRM_AccountNumberGenerator.updateAccountNumberCS(accListupdate, oldMap);
             isAccountNumberUpdateCalled = true;
         }
    }
}