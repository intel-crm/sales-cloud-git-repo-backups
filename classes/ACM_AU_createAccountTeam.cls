public without sharing class ACM_AU_createAccountTeam implements UCD_ACM_ServiceContracts.IAfterUpdateAccountTrigger {
    static boolean runOnce = true;
    Id intelRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();

    /**
     * Method to create/update account team record
     */
    public void execute(UCD_ACM_UnitOfWork unitOfWork, Map<Id, Account> oldAccounts, Map<Id, Account> newAccounts) {
        try {
            // Run the logic only once and after all validations are completed
            if (runOnce ) {
                createAccountTeams(unitOfWork, oldAccounts, newAccounts);
            }
            runOnce = false;
        } catch (Exception ex) {
            UCD_ACM_Logger.error('ACM_AU_createAccountTeam','execute',ex.getMessage() +  '==>' + ex.getStackTraceString(),null);
        }
    }


    
    private void createAccountTeams(UCD_ACM_UnitOfWork unitOfWork, Map<Id, Account> oldAccounts, Map<Id, Account> newAccounts){

        Map<Id, Account> mapOfIdwithAccountTeams = new Map<Id, Account>([select id,OwnerId, (Select id, TeamMemberRole, UserId, Core_Account_Category__c	from AccountTeamMembers where TeamMemberRole = 'Account Owner') from Account where ID IN :newAccounts.keySet()]);

        Map<Id, List<AccountTeamMember>> mapAccountIdByAccountTeamMember = new Map<Id, List<AccountTeamMember>>();
        List<String> accountIdsForAccountTeam = new List<String>();
        for(Account newAccount : newAccounts.values()){

            Account oldAccount = oldAccounts.get(newAccount.Id);

            if(newAccount.recordtypeID == intelRecordTypeId && (newAccount.OwnerId != oldAccount.OwnerId || oldAccount.recordtypeID != intelRecordTypeId) && (newAccount.OwnerId != System.Label.Core_Uncovered_Account_ID)){
                createAccountTeamRec(unitOfWork, newAccount, mapOfIdwithAccountTeams);
                //accountIdsForAccountTeam.add(newAccount.Id);
            }

            if(newAccount.recordtypeID == intelRecordTypeId && (newAccount.Core_Account_Category__c != oldAccount.Core_Account_Category__c  ) && (newAccount.OwnerId != System.Label.Core_Uncovered_Account_ID) ){
                accountIdsForAccountTeam.add(newAccount.Id);
                createAccountTeamRec(unitOfWork, newAccount, mapOfIdwithAccountTeams);

            }



            
            

        }

        if(!accountIdsForAccountTeam.isEmpty()){
            List<AccountTeamMember> lstAccountTeamMember = new List<AccountTeamMember>();

                    lstAccountTeamMember = [Select id, AccountId, UserId,Core_Account_Category__c,TeamMemberRole from AccountTeamMember where AccountId IN : accountIdsForAccountTeam  Order By CreatedDate ];
            

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

        if(!mapAccountIdByAccountTeamMember.isEmpty()){

            for(Account newAccount : newAccounts.values()){
                Account oldAccount = oldAccounts.get(newAccount.Id);
                if(newAccount.recordtypeID == intelRecordTypeId && newAccount.Core_Account_Category__c != oldAccount.Core_Account_Category__c){
                    List<String> lstAccountCategory = new List<String>();
                    Map<Integer,List<String>> lstAccountTeamCategory = new Map<Integer,List<String>>();

                    if(newAccount.OwnerId != System.Label.Core_Uncovered_Account_ID){
                        //createAccountTeamRecForUpdation(unitOfWork, newAccount, mapAccountIdByAccountTeamMember);
                        createAccountTeamRec(unitOfWork, newAccount, mapOfIdwithAccountTeams);
                    }
                    
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
        
        
                        for(List<String>  lstaccTeamCat : lstAccountTeamCategory.values()){

                            for(String  accTeamCatRec : lstaccTeamCat){
                                 if( ! accountCategory.contains(accTeamCatRec)){
                                    newAccount.addError(System.Label.UCD_AccountTeam_AccountMessage);
                                }
                            } 
                        }
                    }
                }

            }
        }


    }


    private void createAccountTeamRec(UCD_ACM_UnitOfWork unitOfWork, Account account, Map<Id, Account> mapOfIdwithAccountTeams){
        
        AccountTeamMember accountTeamMember = new AccountTeamMember();
        accountTeamMember.AccountId = account.Id;
        accountTeamMember.UserId = account.OwnerId ;
        accountTeamMember.TeamMemberRole = 'Account Owner';
        if(account.Core_Account_Category__c != null && account.Core_Account_Category__c.contains(';')){
            accountTeamMember.Core_Account_Category__c = '';
        }else{
            accountTeamMember.Core_Account_Category__c = account.Core_Account_Category__c ;
        }
        Core_AccountTeamMemberHandler.bypassValidationonAccountTeam = true;
        unitOfWork.registerNew(accountTeamMember);

        if(!mapOfIdwithAccountTeams.isEmpty() && account != null && mapOfIdwithAccountTeams.get(account.Id) != null){

            for(AccountTeamMember  accTeamMemberData : mapOfIdwithAccountTeams.get(account.Id).AccountTeamMembers){

                //     abhi != 
                //accTeamMemberData.Core_Account_Category__c != 'Account Owner'
                if(account.OwnerId != accTeamMemberData.UserId ){
                    accTeamMemberData.TeamMemberRole = 'Team Member (100%)';
                    accTeamMemberData.Core_Account_Category__c = '';
                    unitOfWork.registerModified(accTeamMemberData);
                }
            }
        }



    }

    /*
    private void createAccountTeamRecForUpdation(UCD_ACM_UnitOfWork unitOfWork, Account account, Map<Id, List<AccountTeamMember>> mapAccountIdByAccountTeamMember){

        String teamRole = 'Account Owner';
        if(mapAccountIdByAccountTeamMember.get(account.Id) != null){
            List<AccountTeamMember> accountTeamMemberToUpdate = mapAccountIdByAccountTeamMember.get(account.Id);
            for(AccountTeamMember accTeamMem : accountTeamMemberToUpdate){
                if(accTeamMem.UserId == Account.OwnerId){
                    teamRole = accTeamMem.TeamMemberRole ;
                }
            }
        }
        AccountTeamMember accountTeamMember = new AccountTeamMember();
        accountTeamMember.AccountId = account.Id;
        accountTeamMember.UserId = account.OwnerId ;
        accountTeamMember.TeamMemberRole = teamRole;
        if(account.Core_Account_Category__c != null && account.Core_Account_Category__c.contains(';')){
            accountTeamMember.Core_Account_Category__c = '';
        }else{
            accountTeamMember.Core_Account_Category__c = account.Core_Account_Category__c ;
        }
        Core_AccountTeamMemberHandler.bypassValidationonAccountTeam = true;
        unitOfWork.registerNew(accountTeamMember);

    }
    */



}