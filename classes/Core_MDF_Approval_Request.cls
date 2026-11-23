public with sharing class Core_MDF_Approval_Request {
   /* @AuraEnabled(Cacheable=true)
        public static String getSubmittedRecords(){
        set<Id> oppIds = new Set<Id>();
        set<String> objname = new Set<String>();
    List<ProcessInstance> piList = [SELECT TargetObjectId, TargetObject.Type FROM ProcessInstance where TargetObject.Type IN ('PartnerFundRequest')];
    for (ProcessInstance pi : piList) {
        oppIds.add(pi.TargetObjectId);
        objname.add(pi.TargetObject.Type);
    }
    system.debug('oppids'+oppIds);
    System.debug('Object Name'+objname);
           Set<String> matricesAPISet = new Set<String>();
         List<String> str = new List<String>();
           Map<String,List<String>> av = new Map<String,List<String>>();
            for(CCP_Approval_Req_Object_Configuration__mdt ApprovalReq : [Select Fields_Name__c,Object_Name__c from CCP_Approval_Req_Object_Configuration__mdt where Object_Name__c IN: objname]){
            
                if(ApprovalReq.Fields_Name__c!=null){
                    matricesAPISet.add(ApprovalReq.Fields_Name__c);
                    str = ApprovalReq.Fields_Name__c.split(',');
                    av.put(ApprovalReq.Object_Name__c,str);
                }
            }
           system.debug('@@@ av map'+av);
                String Query = 'Select ';
                for(List<String> obj : av.values()){
                  for(String s : obj){
                     Query += s+',';
                 } 
                }
                for(String keyset : av.keyset()){  
                    Query += ' from ' +keyset ;
                   }
              Query+= ' Where ID IN: oppids';
            system.debug('Query Formation'+Query);
         
         List<sobject> result = Database.query(Query);
                system.debug('@@@ Query'+result);
            system.debug('Serialize'+json.serialize( Database.query(Query)));
            return json.serialize( Database.query(Query));
           
            
          //  List<SubmittedRecordsWrapper> lstSubmissionWrapper = new List<SubmittedRecordsWrapper>();
        /*   for(ProcessInstance ps : piList){
                  SubmittedRecordsWrapper objSubmittedRecordsWrapper = new SubmittedRecordsWrapper();
              //  objSubmittedRecordsWrapper.workItemId = ps.WorkItems[0].Id;
           //     objSubmittedRecordsWrapper.recordId = ps.TargetObjectId;
                objSubmittedRecordsWrapper.recordName = ps.TargetObject.Name;
            
              //  objSubmittedRecordsWrapper.BudgetAmount = 
           //     objSubmittedRecordsWrapper.relatedTo = getObjectName(ps.TargetObjectId);//get the object name using the record id
           //     objSubmittedRecordsWrapper.submittedDate = Date.newInstance(ps.CreatedDate.year(),ps.CreatedDate.month(),ps.CreatedDate.day());
                
                	lstSubmissionWrapper.add(objSubmittedRecordsWrapper);
                  
              }
    
      //   return result;
     
    }
    
     public static String getObjectName(String recordId){
        //To get the label of the object name using Schema methods
        String keyPrefix = recordId.subString(0,3);
        String objectName = '';
        Map<String,Schema.SObjectType> sobjectTypeMap = Schema.getGlobalDescribe();
        for(String obj : sobjectTypeMap.keySet()){
            Schema.DescribeSObjectResult sobjectResult = sobjectTypeMap.get(obj).getDescribe();
            if(sobjectResult.getKeyPrefix() == keyPrefix){
                objectName = sobjectResult.getLabel();
                break;
            }
        }
        return objectName;
    }
    
     public class SubmittedRecordsWrapper{
    //    @AuraEnabled public Id workItemId;
    //	@AuraEnabled public String recordId;
        @AuraEnabled public String BudgetAmount;
        @AuraEnabled public String recordName;
        @AuraEnabled public String AccountName;
     //   @AuraEnabled public  
     //   @AuraEnabled public Date submittedDate;
     }
  /* public static Set<String> getMetricesAPIFields(){
        Set<String> matricesAPISet = new Set<String>();
        //Query from CCP KPI Metrics Metadata and capture all unique metrices api names on claims to a set
        for(CCP_Approval_Req_Object_Configuration__mdt ApprovalReq : [Select id,Fields_Name__c from CCP_Approval_Req_Object_Configuration__mdt where Object_Name__c != null]){
            if(ApprovalReq.Fields_Name__c!=null){
                matricesAPISet.add(ApprovalReq.Fields_Name__c);
            }
        }
        return matricesAPISet;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<ProcessInstance> getSubmittedRecords(){
     return [SELECT Id,TargetObjectId,TargetObject.Name,CreatedDate
                                  FROM ProcessInstance limit 50];
    }*/
    
    
   /*  @AuraEnabled(cacheable=true)
    public static List<SubmittedRecordsWrapper> getSubmittedRecords(){
        List<SubmittedRecordsWrapper> lstSubmissionWrapper = new List<SubmittedRecordsWrapper>();
        //Process instance stores the info of records submitted for approval,
        // Process instance work item are the records an approver sees while approving/rejecting, Process instance step stores approved/rejected record including approva;/rejection comments
List<Id> targetObjectIds = new List<Id>();
for(SObject result : Select ProcessInstance.Status,ProcessInstance.TargetObject.Name,ProcessInstance.TargetObject.Id,Actor.Name,CreatedBy.Name,CreatedDate FROM ProcessInstanceWorkitem ])
{
  targetObjectIds.add(result.ProcessInstance.TargetObject.Id);
 } 
SubmittedRecordsWrapper recWrapper = new SubmittedRecordsWrapper();
objSubmittedRecordsWrapper.relatedTo = getObjectName(ps.TargetObjectId);
get
for(ProcessInstance ps : [SELECT Id,TargetObjectId,TargetObject.Name,CreatedDate
                                  FROM ProcessInstance]){
            
                SubmittedRecordsWrapper objSubmittedRecordsWrapper = new SubmittedRecordsWrapper();
                objSubmittedRecordsWrapper.workItemId = ps.WorkItems[0].Id;
                objSubmittedRecordsWrapper.recordId = ps.TargetObjectId;
                objSubmittedRecordsWrapper.recordName = ps.TargetObject.Name;
                objSubmittedRecordsWrapper.relatedTo = getObjectName(ps.TargetObjectId);//get the object name using the record id
                objSubmittedRecordsWrapper.submittedDate = Date.newInstance(ps.CreatedDate.year(),ps.CreatedDate.month(),ps.CreatedDate.day());
                
                	lstSubmissionWrapper.add(objSubmittedRecordsWrapper);
                
            }
        
        return lstSubmissionWrapper;
    }
    */
   
    
   
	
	/*public static List<ProcessInstanceWorkItem> getApprovalRequestQueue(){
         String metricfieldsForQuery='';
        Set<String> matricesAPISet = new Set<String>();
         matricesAPISet=getMetricesAPIFields(); //Calling this method to get all metrices API Names From Claim Module
        if(matricesAPISet != null && matricesAPISet.size()>0){
        	metricfieldsForQuery = List<String>(matricesAPISet));
        }
// 2. Query all claims - Changed into dynamic query as we have to assign metrices field values dynamically on auto created claim by referring its reference claim 
        
            String query ='Select id';
        //Check if metricfieldsForQuery is not null
        if(!String.isBlank(metricfieldsForQuery)){
        	query+= ',' +metricfieldsForQuery;
        }
        query+= ' FROM PartnerFundClaim where Id IN :claimIdSet';
        System.debug('Final Query before processing' +query);
        claimsList=Database.query(String.escapeSingleQuotes(query));
        }*/
}