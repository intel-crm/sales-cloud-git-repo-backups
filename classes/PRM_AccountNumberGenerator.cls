public class PRM_AccountNumberGenerator {
    /**
*  @description      : Retrieves maximum account number from org. Increments it by 1 and populate it for a NON-IPA Account.
*  @name             : getAccountNum
*  @param            : NONE
*  @throws exception : NONE
**/
    public static String getAccountNum(){
        System.debug('Entered getAccountNum Method');
        System.debug('Total number of queries executed so far:'+Limits.getQueries());
        System.debug('Total number of records returned by SOQL queries so far:'+Limits.getQueryRows());
        Long i;
        String num = '';
        try{
            // AggregateResult ar = [Select Max(PRM_AccountNumberFormula__c) act from Account where LastModifiedDate = LAST_N_DAYS:4];
            Account__c acs = Account__c.getValues('AccountNumber');
            if(acs!=null){
                string accontNum = Account__c.getValues('AccountNumber').PRM_Max_Account_Number__c;
                
                system.debug('accontNum'+accontNum);
                system.debug('Account_c values'+Account__c.getValues('AccountNumber'));
                system.debug('acs account number custom'+acs);
                
                // i = long.valueOf(String.valueOf(acs.get('PRM_Max_Account_Number__c')))+1;
                i = long.valueOf(accontNum)+1;
                System.debug('Long value of I'+long.valueOf(accontNum));
                System.debug('@@ i'+i);
                num = String.valueOf(i);
                System.debug('@@ num'+num);
            }
        }catch(Exception e){
            System.debug('Exception '+e);
        }
        return num;
    }
    //new code - after update
    public static void updateAccountNumberCS (List<Account> accList, Map<Id,Account> oldMap)
    {  
        //Account__c acs = [select id, name, PRM_Max_Account_Number__c from Account__c where name like '%AccountNumber%'];
        try{
            boolean isMaxActNbr = false;
            Account__c acs = Account__c.getValues('AccountNumber');
            system.debug('isInsert==>'+trigger.isInsert);
            System.debug('oldMap'+oldMap);
            System.debug('accList'+accList);
            if(acs!=null){
                Long accountnum = Long.valueOf(acs.PRM_Max_Account_Number__c);
                for(Account acc : accList){  
                    if(acc.AccountNumber!= null){
                        Account accOld ; 
                        if(oldMap!=null && oldMap.size()>0){ accOld = (Account) oldMap.get(acc.id) ;}
                        if((oldMap==null) || ((oldMap!=null && oldMap.size()>0)&&(accOld.AccountNumber != acc.AccountNumber)))
                        {
                            
                            Long maxAccountNumber = Long.valueOf(acc.AccountNumber);
                            if(maxAccountNumber>accountnum){ accountnum = maxAccountNumber;isMaxActNbr = true;}
                        }    
                        
                    }   
                    
                }
                if(isMaxActNbr){
                    System.debug('Updating max Account Number on Custom Setting');
                    acs.PRM_Max_Account_Number__c = String.valueOf(accountnum);                    
                    update acs;
                }
            }
        }catch(Exception ex){
            PRM_ErrorUtilityClass.logError(ex);
        }
    }
}