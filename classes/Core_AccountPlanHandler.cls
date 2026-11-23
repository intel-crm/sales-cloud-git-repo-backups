public with sharing class Core_AccountPlanHandler {

    public static void accountPlanShareToBuExecutives(List<Account_Plan__c> accountPlanRecords) {
        Set<Id> accountplanIds = new Set<Id>(); //for stoting account plan Ids
        Set<Id> accountIds = new Set<Id>();		//for stoting account Ids 
        
        
        for (Account_Plan__c accplan : accountPlanRecords) {
            accountplanIds.add(accplan.id);
            accountIds.add(accplan.Account__C);
        }
        //Id accountId = accountPlan.Account__C;
        //System.debug('AccountID : '+accountId);
        
        //Retreives BU Executives public group
        Group buExePG = [select id from group where DeveloperName ='AGS_BU_Executive_Users_Group'];
       
       
       
       List<Account_Plan__Share> apShareToInsert = new List<Account_Plan__Share>();
       List<Account_Plan__Share> apShareToDelete = new List<Account_Plan__Share>();
        
       List<ObjectTerritory2Association> accShared = [SELECT Id, ObjectId FROM ObjectTerritory2Association WHERE (Territory2.ParentTerritory2.DeveloperName = 'SMG_WW_Read' OR Territory2.DeveloperName = 'SMG_WW_Read') 
            AND ObjectId IN :accountIds];                 
       List<Account_Plan__Share> acctPlanShares = [SELECT Id, ParentId, UserOrGroupId FROM Account_Plan__Share WHERE ParentId IN :accountplanIds AND UserOrGroupId = :BUExePG.Id	 ];
       
       
       Map<Id, List<ObjectTerritory2Association>> accTerritoryMap = new Map<Id, List<ObjectTerritory2Association>>();
        for (ObjectTerritory2Association accTrty:accShared) {
            accTerritoryMap.put(accTrty.ObjectId, new List<ObjectTerritory2Association>());
            accTerritoryMap.get(accTrty.ObjectId).add(accTrty);
        }
        
		
        Map<Id, List<Account_Plan__Share>> accountPlanShareMap = new Map<Id, List<Account_Plan__Share>>();
        for (Account_Plan__Share accountPlanShare : acctPlanShares) {
            accountPlanShareMap.put(accountPlanShare.ParentId, new List<Account_Plan__Share>());
            accountPlanShareMap.get(accountPlanShare.ParentId).add(accountPlanShare);
        }

        for(Account_Plan__c accountPlanRecord : accountPlanRecords) {
            
            List<Account_Plan__Share> apShareExisting = accountPlanShareMap.get(accountPlanRecord.Id);
            Account_Plan__Share apShare = new Account_Plan__Share();
            
            Boolean isExisting = (apShareExisting != null && !apShareExisting.isEmpty());
            Boolean isAccShared = accTerritoryMap.containsKey(accountPlanRecord.Account__C) && !accTerritoryMap.get(accountPlanRecord.Account__C).isEmpty();
            Boolean isShare = apShareExisting == null || apShareExisting.isEmpty();

            if(isAccShared) {
                if (isShare) {
                    
                    apShare.ParentId = accountPlanRecord.Id;
                    apShare.UserOrGroupId = buExePG.Id;
                    apShare.AccessLevel = 'Read';
                    apShareToInsert.add(apShare);
                }
            }
            else {
                if (isExisting) {
                    apShareToDelete.addAll(apShareExisting);
                }
            }
        }
        handleRecords(apShareToInsert,apShareToDelete);    
    }
    
    public static void handleRecords(List<Account_Plan__Share> apShareToInsert,List<Account_Plan__Share> apShareToDelete) {
        
        List<Core_Log_Entry__c> listFailedOperations = new List<Core_Log_Entry__c>();
        Map<String, Core_LogEntry_Switch__c> logSwitch = Core_LogEntry_Switch__c.getall();  
        Boolean logEntrycheck = (!logSwitch.isEmpty() && logSwitch.get('Core_LogEntry_Check') != null && logSwitch.get('Core_LogEntry_Check').Is_Selected__c) ;
        //Database.SaveResult[] insertRes;
        //Database.DeleteResult[] delRes;
       
        if (!apShareToInsert.isEmpty()) {
            //insert apShareToInsert;
            Database.SaveResult[]  insertRes = Database.insert(apShareToInsert,false);
            for (Database.SaveResult saveResult:insertRes) {
                if(!saveResult.isSuccess()) {
                    listFailedOperations.add(new Core_Log_Entry__c(Core_Message__c = 'Failed at insertion', Core_Origin__c='Core_AccountPlanHandler.handleRecords', Core_Severity__c='High', Core_When__c=System.Now()));
                }
            }
        }
        if (!apShareToDelete.isEmpty()) {
            //delete apShareToDelete;
            Database.DeleteResult[]delRes = Database.delete(apShareToDelete,false);
            for (Database.DeleteResult delResult:delRes) {
                if(!delResult.isSuccess()) {
                    listFailedOperations.add(new Core_Log_Entry__c(Core_Message__c = 'Failed at deletion', Core_Origin__c='Core_AccountPlanHandler.handleRecords', Core_Severity__c='High', Core_When__c=System.Now()));
                }
            }
        }
        if(logEntrycheck) {
            insert listFailedOperations;
        }
        
           
    }
}