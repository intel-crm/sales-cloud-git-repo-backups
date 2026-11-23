public without sharing class ACM_AU_createAccountTeam implements UCD_ACM_ServiceContracts.IAfterUpdateAccountTrigger {
    static boolean runOnce = true;
    Id intelRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
    Map<String, Account> dealAccountByBpIds = new Map<String, Account>();
    List<String> validRecordTypeDeveloperName = new List<String>{'Mastered_Account'};

    /**
     * Method to set parent to Deal child accounts when BpId is updated
     */
    public void execute(UCD_ACM_UnitOfWork unitOfWork, Map<Id, Account> oldAccounts, Map<Id, Account> newAccounts) {
        try {
            System.debug('ACM_AU_createAccountTeam==>');
        // Run the logic only once and after all validations are completed
        if (runOnce ) {
 
            createAccountTeams(unitOfWork, oldAccounts, newAccounts);
        }
        runOnce = false;
        } catch (Exception ex) {
            System.debug('Issue in class - ACM_AU_createAccountTeam. Error '+ ex.getMessage() + ex.getStackTraceString());
        }
    }

    private void createAccountTeams(UCD_ACM_UnitOfWork unitOfWork, Map<Id, Account> oldAccounts, Map<Id, Account> newAccounts){

        List<String> accountIdsForAccountTeam = new List<String>();
        for(Account newAccount : newAccounts.values()){

            Account oldAccount = oldAccounts.get(newAccount.Id);

            if(newAccount.recordtypeID == intelRecordTypeId &&  newAccount.Core_Business_Party_Id__c != null && newAccount.Core_Customer_Aggregation_Type__c != null && newAccount.OwnerId != oldAccount.OwnerId){

                AccountTeamMember accountTeamMember = new AccountTeamMember();
                accountTeamMember.AccountId = newAccount.Id;
                accountTeamMember.UserId = newAccount.OwnerId ;
                accountTeamMember.TeamMemberRole = 'Account Owner';
                    if(newAccount.Core_Account_Category__c != null && newAccount.Core_Account_Category__c.contains(';')){
                        accountTeamMember.Core_Account_Category__c = '';
                    }else{
                        accountTeamMember.Core_Account_Category__c = newAccount.Core_Account_Category__c ;
                    }
                unitOfWork.registerNew(accountTeamMember);
            }

            if(newAccount.recordtypeID == intelRecordTypeId &&  newAccount.Core_Business_Party_Id__c != null && newAccount.Core_Customer_Aggregation_Type__c != null && newAccount.Core_Account_Category__c != oldAccount.Core_Account_Category__c){
                accountIdsForAccountTeam.add(newAccount.Id);
            }

        }

        Map<Id, List<AccountTeamMember>> mapAccountIdByAccountTeamMember = new Map<Id, List<AccountTeamMember>>();

        if(!accountIdsForAccountTeam.isEmpty()){
            List<AccountTeamMember> lstAccountTeamMember = new List<AccountTeamMember>();

            lstAccountTeamMember = [Select id, AccountId, UserId, Core_Account_Category__c from AccountTeamMember where AccountId IN : accountIdsForAccountTeam AND TeamMemberRole = 'Account Owner' Order By CreatedDate ];
            System.debug('lstAccountTeamMember==>'+lstAccountTeamMember);

            for(AccountTeamMember accountTeamRec: lstAccountTeamMember){

                if(mapAccountIdByAccountTeamMember.get(accountTeamRec.AccountId) != null){
                    mapAccountIdByAccountTeamMember.get(accountTeamRec.AccountId).add(accountTeamRec);
                }else{
                    List<AccountTeamMember> lstAccountTeamMemberRec = new List<AccountTeamMember>();
                    lstAccountTeamMemberRec.add(accountTeamRec);

                    mapAccountIdByAccountTeamMember.put(accountTeamRec.AccountId, lstAccountTeamMemberRec);
                }

            }

        }

        System.debug('mapAccountIdByAccountTeamMember==>'+mapAccountIdByAccountTeamMember);
        if(!mapAccountIdByAccountTeamMember.isEmpty()){

            for(Account newAccount : newAccounts.values()){
                Account oldAccount = oldAccounts.get(newAccount.Id);
                if(newAccount.recordtypeID == intelRecordTypeId &&  newAccount.Core_Business_Party_Id__c != null && newAccount.Core_Customer_Aggregation_Type__c != null && newAccount.Core_Account_Category__c != oldAccount.Core_Account_Category__c){

                    List<String> lstAccountCategory = new List<String>();
                    Map<Integer,List<String>> lstAccountTeamCategory = new Map<Integer,List<String>>();



                    if(mapAccountIdByAccountTeamMember.get(newAccount.Id) != null){
                        List<AccountTeamMember> accountTeamMemberToUpdate = mapAccountIdByAccountTeamMember.get(newAccount.Id);

                        String accountCategory =  newAccount.Core_Account_Category__c != null ? newAccount.Core_Account_Category__c : '';
        
                        if(accountCategory.contains(';')){
                            lstAccountCategory = accountCategory.split(';');
                        }else{
                            if(String.isNotBlank(accountCategory)){
                                lstAccountCategory.add(accountCategory);
                            }
                        }

                        for(AccountTeamMember accTeamMemberRec :    accountTeamMemberToUpdate){
                            String accountTeamCategory = accTeamMemberRec.Core_Account_Category__c != null ? accTeamMemberRec.Core_Account_Category__c : '' ;
                            Integer count = 1 ;
                            if(accountTeamCategory.contains(';')){
                                lstAccountTeamCategory.put(count , accountTeamCategory.split(';'));
                            }else{
                                if(String.isNotBlank(accountTeamCategory)){
                                    List<String> lstaccTeamMem = new List<String>();
                                    lstaccTeamMem.add(accountTeamCategory);
                                    lstAccountTeamCategory.put(count , lstaccTeamMem);
                                }
                            }
                            count++;
                        }
        
        
                        System.debug('lstAccountTeamCategory===>'+lstAccountTeamCategory);
                        for(List<String>  lstaccTeamCat : lstAccountTeamCategory.values()){

                            for(String  accTeamCatRec : lstaccTeamCat){
                                 if(accountCategory.contains(accTeamCatRec)){
        
                                }else{
                                    newAccount.addError('Account Category can not be updated with active Category Owner, please review Account Teams');
                                }
                            }
                           
                        } 

                        if(newAccount.Core_Account_Category__c!= null && newAccount.Core_Account_Category__c.contains(';')){
                            for(AccountTeamMember  accTeamMember : accountTeamMemberToUpdate){
                                if(accTeamMember.TeamMemberRole == 'Account Owner'){
                                    accTeamMember.Core_Account_Category__c = '';
                                    unitOfWork.registerModified(accTeamMember);
                                    System.debug('accTeamMember11==>'+accTeamMember);
                                }
                            }
                        }else{
                            for(AccountTeamMember  accTeamMember : accountTeamMemberToUpdate){
                                if(accTeamMember.TeamMemberRole == 'Account Owner'){
                                    accTeamMember.Core_Account_Category__c = newAccount.Core_Account_Category__c;
                                    unitOfWork.registerModified(accTeamMember);
                                    System.debug('accTeamMember22==>'+accTeamMember);

                                }

                            }
                        }
                    }
                }

            }
        }



    }
}