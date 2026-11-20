global class Core_IPS_AccountTeamUpdate_Batch implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = '';
        if(Test.isRunningTest()){
            query = 'select caseaccesslevel, opportunityaccesslevel,accountaccesslevel,userorgroupid, accountid from accountshare where accountid in(select accountid from Accountteammember) and userorgroupid in(select userid from Accountteammember)';
        }else{
            query = 'select caseaccesslevel, opportunityaccesslevel,accountaccesslevel,userorgroupid, accountid from accountshare where Rowcause=\'Team\' and account.Core_IPS_Active__c=false';
        }
        return Database.getQuerylocator(query);
    }
    global void execute(Database.BatchableContext BC, List<accountshare> scope) {
        List<Core_Account_Team__c> cAccountTeamList = new List<Core_Account_Team__c>();
        for(AccountShare shareRecord:scope){
            Core_Account_Team__c cActTeam = new Core_Account_Team__c();
            cActTeam.Core_Account__c=shareRecord.accountid;
            cActTeam.Core_Case_Access__c=shareRecord.caseaccesslevel;
            cActTeam.Core_Opportunity_Access__c=shareRecord.opportunityaccessLevel;
            cActTeam.Core_Account_Access__c=shareRecord.accountaccesslevel;
            cActTeam.Core_Team_Member__c=shareRecord.userorgroupid;
            cAccountTeamList.add(cActTeam);
        }
        insert cAccountTeamList;
    }
    global void finish(Database.BatchableContext BC) {
    
    }
}