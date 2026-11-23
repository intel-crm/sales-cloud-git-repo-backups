public class Core_MDF_CampFlowsToBatch implements Database.Batchable<sObject>, Database.Stateful {
    public String Query;
    public id recordID;
    public string actionName;  
    public string submitterID;
    
    public Core_MDF_CampFlowsToBatch(string rcdID,string actName,string submitter){
        recordID = rcdID;
        actionName = actName;
        submitterID = submitter;
    }
    
    public Core_MDF_CampFlowsToBatch(string queryStr,string actName){
        Query = queryStr;
        actionName = actName;
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        
        if(actionName == 'IPACommentsUpdate' || actionName == 'ResubmitApprovalProcess')
            Query ='Select id from campaign where ID = :recordID';
        
        system.debug('--query-:'+Query);
        return Database.getQueryLocator(query);
        
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> recordList){
        try{       
            //Notify Customer to Approve IPA campaign
            if(actionName == 'IPACommentsUpdate' && !recordList.isEmpty())
                Core_MDF_CampFlowsHelper.updateIPAcomments(recordList);
            
            //IPA Resubmit Approval process 
            if(actionName == 'ResubmitApprovalProcess' && !recordList.isEmpty())
                Core_MDF_CampFlowsHelper.reSubmitApprovalProcess(recordList,'Core_MDF_IPA_Proposal_AP_v3',submitterID,'');
        }
        catch(Exception e){ 
            Core_MDF_CCP_UtilityClass.logError(e); }  
    }
    
    public void finish(Database.BatchableContext BC){
        
        
    }
}