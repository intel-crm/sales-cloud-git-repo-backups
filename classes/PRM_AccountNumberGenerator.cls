public with sharing class PRM_AccountNumberGenerator {
    /**
*  @description      : Retrieves maximum account number from org. Increments it by 1 and populate it for a NON-IPA Account.
*  @name             : getAccountNum
*  @param            : NONE
*  @throws exception : NONE
**/
    public static String getAccountNum(){
        Long i;
        String num = '';
        try{
            // AggregateResult ar = [Select Max(PRM_AccountNumberFormula__c) act from Account where LastModifiedDate = LAST_N_DAYS:4];
            Account__c acs = Account__c.getValues('AccountNumber');
            if(acs!=null){
                string accontNum = Account__c.getValues('AccountNumber').PRM_Max_Account_Number__c;

                
                // i = long.valueOf(String.valueOf(acs.get('PRM_Max_Account_Number__c')))+1;
                i = long.valueOf(accontNum)+1;
                num = String.valueOf(i);
            }
        }catch(Exception e){
            System.debug('Exception '+e);
        }
        return num;
    }
    //new code - after update
    public static void updateAccountNumberCS (List<Account> accList, Map<Id,Account> oldMap)// Cyclomatic Complexity of 13=>less than 10
    {  
        //Account__c acs = [select id, name, PRM_Max_Account_Number__c from Account__c where name like '%AccountNumber%'];
        try{
            boolean isMaxActNbr = false;
            Account__c acs = Account__c.getValues('AccountNumber');
            if(acs!=null){
                Long accountnum = Long.valueOf(acs.PRM_Max_Account_Number__c);
                for(Account acc : accList){ 

                    if(oldMap==null || (!oldMap.isEmpty() && oldMap.get(acc.id).AccountNumber != acc?.AccountNumber)){
                        Long maxAccountNumber = Long.valueOf(acc.AccountNumber);
                        if(maxAccountNumber>accountnum){ 
                            accountnum = maxAccountNumber;
                            isMaxActNbr = true;
                        }     
                    }    
                }
                if(isMaxActNbr){
                    acs.PRM_Max_Account_Number__c = String.valueOf(accountnum);                    
                    update acs;
                }
            }
        }catch(Exception ex){
            PRM_ErrorUtilityClass.logError(ex);
        }
    }
}