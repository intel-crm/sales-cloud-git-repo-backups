public class Core_MDF_Custom_Approval_Hist {
    @AuraEnabled(cacheable=true)
  
    public static List<History> loadData(){
    List<History> newHistList = new List<History>();
    List<string> records = new List<string>{'04gg0000001EtfJAAS'};
    List<string> records1 = new List<string>{'701g0000001arHlAAI'};
    String query = 'SELECT TargetObjectId,LastActorId,LastActor.Name,'+
        		 '(SELECT Id, ActorId,OriginalActor.Name,Comments, ProcessInstanceId FROM StepsAndWorkitems ),'+
        		 '(SELECT Id, StepStatus, Comments  FROM Steps ORDER BY CreatedDate DESC ) FROM ProcessInstance where id IN :records';
        
    string query2 = 'SELECT Id, ActorId,OriginalActor.Name,Comments, ProcessInstanceId FROM StepsAndWorkitems where TargetObjectId IN :records1';
    List<sObject> historyDatafromQuery = Database.query(query);
        List<sObject> historyDatafromQuery1 = Database.query(query2);
    system.debug('line 10'+historyDatafromQuery);
        system.debug('line 14'+historyDatafromQuery1);
             for(SObject hData : historyDatafromQuery){
                 										system.debug('line 11'+hdata);
                 										//system.debug('line 12'+hdata.LastActorId);
                                                     }
    return newHistList;
    }
	  public class History {
        @AuraEnabled public String id  { get; set; }
        @AuraEnabled public String createdDate  { get; set; }
        @AuraEnabled public String field { get; set; }
        @AuraEnabled public String user { get; set; }
        @AuraEnabled public String oldValue          { get; set; }
        @AuraEnabled public String newValue           { get; set; }
        @AuraEnabled public String userUrl           { get; set; }
        @AuraEnabled public String oldValueUrl           { get; set; }
        @AuraEnabled public String newValueUrl           { get; set; }
        @AuraEnabled public Boolean isCheckbox           { get; set; }
    }
    
}