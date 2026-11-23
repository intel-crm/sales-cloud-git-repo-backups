public class UCD_ACM_AccountTeamCategory {
    
    @AuraEnabled
    public static Boolean getAccountCategory(String accountId){
      
      Boolean categoryValuesPresent = false;  
      String accountCategoryValue = '';  
      Map<id,Account> accountCategory = new Map<id,Account>([Select id,name,Core_Account_Category__c,(select id,Account.Name,Core_Account_Category__c from AccountTeamMembers  where Account.Id =:accountId) from Account where id =:accountId]);
      System.debug('accountCategory'+accountCategory);
        
        for(Account accounts:accountCategory.values()){
            for(AccountTeamMember acctTeamMember : accounts.AccountTeamMembers){
              if(acctTeamMember.Core_Account_Category__c != null && acctTeamMember.Core_Account_Category__c.containsNone(accountCategoryValue))
          	   {
               accountCategoryValue = accountCategoryValue +',' +acctTeamMember.Core_Account_Category__c;
              }
            }
            if(accountCategoryValue.contains(accounts.Core_Account_Category__c)){
                System.debug('value'+accounts.Core_Account_Category__c);
                categoryValuesPresent = True;
                        
            }
            else{
                categoryValuesPresent = false;
            }
       
        }
        return categoryValuesPresent;
     
    }
}