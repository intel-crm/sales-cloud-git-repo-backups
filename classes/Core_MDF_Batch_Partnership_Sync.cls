//Class to sync up Partnership Score and Detail record for the Reopened Cases
public without sharing class Core_MDF_Batch_Partnership_Sync implements Database.Batchable<sObject>, Database.Stateful {
    //Configurable params for the Batch class
    public List<Core_MDF_Custom_Label_Configration__mdt> params= new List<Core_MDF_Custom_Label_Configration__mdt>();//
    
    //Query the reopened cases in the given timeframe
    public Database.QueryLocator start(Database.BatchableContext bcontext) {
        params = [select Core_MDF_Value_Txt__c,Core_MDF_Value2_Txt__c,Core_MDF_Value3_Txt__c from Core_MDF_Custom_Label_Configration__mdt where Label = 'Core_MDF_Batch_Partnership_Sync_Params'];
        String strQuery ='select id, Core_MDF_Earlier_Quarter_Closed_Dt__c,Account.Core_MDF_CoMarketing_Ultimate_Account__c,Core_MDF_Channel_Program_txt__c '+
            'from Case '+
            'where Core_MDF_Earlier_Quarter_Closed_Dt__c != null '+
            'and RecordType.DeveloperName in (\''+ CCPConstantClass.CASE_OPEN_RECORDTYPE_NAME +'\',\''+CCPConstantClass.CASE_CLOSED_RECORDTYPE_NAME+'\') '+
            'and LastModifiedDate = LAST_N_DAYS:'+ params[0].Core_MDF_Value_Txt__c; 
            //+ ' limit 1';
        return Database.getQueryLocator(strQuery);
    }

    //Prepare map and send to IAH Batch to sync up the data
    public void execute(Database.BatchableContext bcontext, List<Case> caseList) {
        Map<string,set<id>> qtrPgmToAcctIdMap = new Map<string,set<id>>();
        List<Core_MDF_Batch_Scheduler__c> custmSchList = new List<Core_MDF_Batch_Scheduler__c>();
        integer count = 1;
        try {
            for(case rec:caseList){
                string quarter = Core_MDF_ReverseAuditDecision.determineQuartYear(date.newinstance(rec.Core_MDF_Earlier_Quarter_Closed_Dt__c.year(), rec.Core_MDF_Earlier_Quarter_Closed_Dt__c.month(), rec.Core_MDF_Earlier_Quarter_Closed_Dt__c.day()));
                string key = quarter + ';' + rec.Core_MDF_Channel_Program_txt__c;
                if(qtrPgmToAcctIdMap.containsKey(key)) {
                    qtrPgmToAcctIdMap.get(key).add(rec.Account.Core_MDF_CoMarketing_Ultimate_Account__c);
                }
                else {
                    set<id> accountIds = new set<id>();
                    accountIds.add(rec.Account.Core_MDF_CoMarketing_Ultimate_Account__c);
                    qtrPgmToAcctIdMap.put(key,accountIds);
                }
                
            }
            
            //Call IAH Batch
            for(string key:qtrPgmToAcctIdMap.keyset()) {
                List<string> keySplit = key.split(';');
                List<id> accountIds = new List<id>(qtrPgmToAcctIdMap.get(key));
                integer minutes = count * Integer.valueOf(params[0].Core_MDF_Value2_Txt__c);
                string accountIdList = accountIds.size()>1 ? String.join(accountIds,',') : accountIds[0];
                Core_MDF_Batch_IAH_Pull iahPull = new Core_MDF_Batch_IAH_Pull(keySplit[1],keySplit[0],accountIdList);          
                Core_MDF_Batch_Scheduler__c customSch = new Core_MDF_Batch_Scheduler__c();
                String jsonString = JSON.serialize(iahPull); 
                customSch.Core_MDF_Object_JSON_Txt__c = jsonString;
                customSch.Core_MDF_Batch_Size_Nbr__c = Integer.valueOf(params[0].Core_MDF_Value3_Txt__c);
                customSch.Core_MDF_Effective_Start_Time_Dt__c = System.now().addMinutes(minutes);
                customSch.Scheduled_Time_Dt__c = System.now().addMinutes(minutes);
                customSch.Core_MDF_Batch_Class_Name_Txt__c = 'Core_MDF_Batch_IAH_Pull';
                customSch.Core_MDF_Job_Frequency__c = 'Once';
                customSch.Core_MDF_Priority__c = 'High';
                customSch.Core_MDF_Program_Txt__c = 'CCP';
                custmSchList.add(customSch);
                count++;
            }
            if(custmSchList!=null && custmSchList.size()>0) {
                Database.insert(custmSchList);
                Database.SaveResult[] results = Database.insert(custmSchList,false);
            }
        }
        catch(exception ex) {Core_MDF_CCP_UtilityClass.logError(ex);} 
    }

    //Finish Method
    public void finish(Database.BatchableContext bcontext) {
    }
    
}