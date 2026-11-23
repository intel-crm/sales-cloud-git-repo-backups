public without sharing class UCD_ACM_AccountTeamCategory {
      
    @AuraEnabled
    public static String getAccountCategory(String accountId){

        String unCoveredOwnerId = System.Label.Core_Uncovered_Account_ID;
        Id intelRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
        List<Account> lstAccount = new List<Account>();
        String finalValues = '' ;

        if(String.isBlank(accountId)){
            return  finalValues;
        }

            lstAccount = [Select id,name,Core_Account_Category__c,(select id,Account.Name,Core_Account_Category__c from AccountTeamMembers  where AccountId =:accountId) from Account where id =:accountId AND recordtypeID =:intelRecordTypeId  AND Core_Account_Category__c != null AND OwnerId !=: unCoveredOwnerId WITH SECURITY_ENFORCED];



        for(Account accounts:lstAccount){

            Set<String> accCatValues =  new Set<String>(accounts.Core_Account_Category__c.split(';'));

            Set<String> uniqueAccountTeamCatagory = new Set<String>();
            for(AccountTeamMember acctTeamMember : accounts.AccountTeamMembers){

                List<String> accTeamCatValues = new  List<String>();
                if(acctTeamMember.Core_Account_Category__c != null){
                    accTeamCatValues = acctTeamMember.Core_Account_Category__c.split(';');
                }
                if(!accTeamCatValues.isEmpty()){
                    uniqueAccountTeamCatagory.addAll(new Set<String>(accTeamCatValues));
                }
            }

            for(String accCatValue : accCatValues){

                if( ! uniqueAccountTeamCatagory.contains(accCatValue)){
                    finalValues += accCatValue + ',' ;
                }
            }
        }
        return finalValues;
    }
}