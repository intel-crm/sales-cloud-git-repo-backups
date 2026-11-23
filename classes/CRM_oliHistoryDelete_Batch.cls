global class CRM_oliHistoryDelete_Batch implements Database.Batchable<sObject> {
    
    private Date startDate;
    private Date endDate;
    
    global CRM_oliHistoryDelete_Batch (String csName){
        CRM_oliHistoryDeleteDates__c datesRange = CRM_oliHistoryDeleteDates__c.getValues(csName);
        
        if(datesRange == null || datesRange.Start_Date__c == null || datesRange.End_Date__c == null){
            throw new AuraHandledException('error');
        }
        startDate = datesRange.Start_Date__c;
        endDate = datesRange.End_Date__c;
    }
    
    global CRM_oliHistoryDelete_Batch(){
        this(Label.Core_FY_to_delete_OLI_History);
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        String query = 'Select Id ' + 'from Core_Opportunity_Product_History__c ' + 'Where CreatedDate >= :startDate ' 
            			+ 'AND CreatedDate <= :endDate '+ 'AND Core_Opportunity__r.IsClosed = true';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<Core_Opportunity_Product_History__c> scope){
        if(scope != null){
            try{
                delete scope;
            }catch(Exception e) {
                PMP_Utility.logError(e, 'CRM_oliHistoryDelete_Batch.execute'); 
            }
        }
        
    }
    
    global void finish(Database.BatchableContext bc){
    }
    
}