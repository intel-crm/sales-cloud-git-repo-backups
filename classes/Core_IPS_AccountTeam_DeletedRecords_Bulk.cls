global class Core_IPS_AccountTeam_DeletedRecords_Bulk implements Database.Batchable<sObject>,Database.Stateful {
    global Core_Batch_Processing__c batchProcessing;
    global integer count = 0;
    global Integer batchsize=0;
    global List<Core_Account_team__c> toBeDeletedList;
    global Database.QueryLocator start(Database.BatchableContext BC) {

            System.debug('#01 Database.QueryLocator start'); 
        
            String query='';
            batchProcessing = new Core_Batch_Processing__c();
            Core_Batch_header__c header=AccountTeamBatchHandler.getHeader('Core_IPS_AccountTeam_DeletedRecords_Bulk');
            System.debug('#02 header = ' + header);

            batchProcessing.Core_Start_Date_Time__c = system.Now();
            try{
            
                /* Custom Label mode is OFF                            
                Set<Id> acctIds = new Set<Id>(); 
                List<String> accountList = Label.Core_Account_List.Split(',');
                for (String strAcct : accountList)
                    acctIds.add(Id.valueOf(strAcct));
                */  
                        
                toBeDeletedList = new List<Core_Account_team__c>();
                if(Test.isRunningTest()){
                    query = 'SELECT Id, Core_Account__c, Core_Team_Member__c ' +
                            'FROM Core_Account_Team__c ' + 
                            'ORDER BY Core_Account__c';
                }else{
                    /* Custom Label mode is OFF                            
                    query = 'SELECT Id, Core_Account__c, Core_Team_Member__c ' + 
                            'FROM Core_Account_Team__c ' + 
                            'WHERE Core_Account__c IN :acctIds ' + 
                            'ORDER BY Core_Account__c';
                    */        

                    // FULL Batch mode is ON
                    query = 'SELECT Id, Core_Account__c, Core_Team_Member__c ' + 
                            'FROM Core_Account_Team__c ' + 
                            'ORDER BY Core_Account__c';

                }

                batchProcessing.Batch_Header__C = header.id;
                batchProcessing.Core_Salesforce_Job_Id__c = BC.getJobId();
                batchProcessing.Core_Batch_Query__c = query;
                batchProcessing.Core_Email_Distribution_List__c=header.Email_Distribution_List__c;
                batchProcessing.Core_Object_Name__c = 'Account';
                System.debug('#03 batchProcessing = ' + batchProcessing);
                
                insert batchProcessing;
                return Database.getQuerylocator(query);
            }catch(Exception e){
                System.debug('#05 e.message(): ' + e.getMessage());
                System.debug('#06 e): ' + e);
                batchProcessing.Core_Exception_Log__c=e.getMessage();
                insert batchProcessing;
                return null;
            }
        
    }
    
    global void execute(Database.BatchableContext BC, List<Core_Account_Team__c> scope) {

        if (scope != NULL) { 
            System.debug('#21 scope[0]: '     + scope[0]);
            System.debug('#22 scope.size(): ' + scope.size());
        }
                
        batchsize = scope.size();
        String searchKey;   
        
        try {
            SET<id> setAcctIds = new SET<id>();
            Map <String, Core_Account_Team__c> mapCustAccountTeam = new Map <String, Core_Account_Team__c>();
            for (Core_Account_Team__c custTeamMember : scope) {
                if (!setAcctIds.contains(custTeamMember.Core_Account__c)) 
                    setAcctIds.add(custTeamMember.Core_Account__c);
               
                searchKey = createSearchKey(custTeamMember.Core_Account__c, custTeamMember.Core_Team_Member__c);
                mapCustAccountTeam.put(searchKey, custTeamMember);
            }
    
            if (setAcctIds.size() == 0)
                return;
            
            List <AccountTeamMember> lstAcctTeamMember = [SELECT Id, AccountId, UserId 
                                                          FROM AccountTeamMember
                                                          WHERE AccountId IN :setAcctIds];
        
            System.debug('#23 lstAcctTeamMember: ' + lstAcctTeamMember);       
        
            if (lstAcctTeamMember == NULL || lstAcctTeamMember.size() == 0)
                return;    
        
            Core_Account_Team__c custMatch;
            for (AccountTeamMember stdAcctTeam : lstAcctTeamMember) {
                searchKey = createSearchKey(stdAcctTeam.AccountId, stdAcctTeam.UserId);
                custMatch = mapCustAccountTeam.remove(searchKey);                
                //System.debug('#25 custMatch: ' + custMatch + '  stdAcctTeam: ' + stdAcctTeam);
            }
        
            if (mapCustAccountTeam.size() > 0) {
                delete mapCustAccountTeam.values();    
                System.debug('#26 DELETED mapCustAccountTeam.values(): ' + mapCustAccountTeam.values());
            }    
                
        } catch (Exception e) {
            
        }
    }
    
    global String createSearchKey(Id acctId, Id userId) { 
        return String.valueOf(acctId) + String.valueOf(userId);
    }    
    
    global void finish(Database.BatchableContext BC) {
        batchProcessing.Core_Total_Number_of_Records__c=count;
        batchProcessing.Core_End_Date_Time__c=System.Now();
        batchProcessing.Core_Batch_Size__c=batchSize;
        batchProcessing.Core_Send_Email__c=true;
        update batchProcessing;
    }
}