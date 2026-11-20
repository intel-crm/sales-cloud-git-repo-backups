public without sharing class ACM_AI_createAccountTeam implements UCD_ACM_ServiceContracts.IAfterInsertAccountTrigger {
    static boolean runOnce = true;
    Id intelRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
    /**
     * Method to create Account team
     */
    public void execute(UCD_ACM_UnitOfWork unitOfWork, Map<Id, Account> oldAccounts, Map<Id, Account> newAccounts) {
        try {
            // Run the logic only once and after all validations are completed
            if (runOnce) {
                createAccountTeams(unitOfWork, newAccounts);
            }
            runOnce = false;
        } catch (Exception ex) {
            UCD_ACM_Logger.error('ACM_AI_createAccountTeam','execute',ex.getMessage() +  '==>' + ex.getStackTraceString(),null);
        }
    }


    
    private void createAccountTeams(UCD_ACM_UnitOfWork unitOfWork, Map<Id, Account> newAccounts){

        for(Account newAccount : newAccounts.values()){
            if(newAccount.recordtypeID == intelRecordTypeId && newAccount.OwnerId != System.Label.Core_Uncovered_Account_ID){
                createAccountTeamRec(unitOfWork, newAccount);
            }
        }
    }


    private void createAccountTeamRec(UCD_ACM_UnitOfWork unitOfWork, Account account){

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

    }


}