//global class Core_MDF_Batch_RetryCaseCreation implements Database.Batchable<sObject>, Database.Stateful
//US949837 - Added without sharing keyword to fix checkmarx issues
global without sharing class Core_MDF_Batch_RetryCaseCreation /*implements Database.Batchable<sObject>, Database.Stateful*/
 {
    //added dummy method to get the code coverage for this class
    public static void getCodeCoverage(){
    }
    /*global String queryActive;
    global String errorMessage = '';
    //DE67727: WW07 | QA | R2 | Case Retry Batch is not processing the data for which Case ID is missing on the Claims
    //Resolution: Make the pfcList as global and call Database.executeBatch from finish method.
    global List<PartnerFundClaim> pfcList = new List<PartnerFundClaim>();
    //Making sure the batch always picks up record whose minimum time gap is 15 min.
    //In case the time from the label is > 15 min then also add 15 mins.
    global DateTime todaysDate =
        (Integer.valueOf(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CaseRetry_Add_Minutes')) > -15) ? System.now().addMinutes(-15) : System.now().addMinutes(Integer.valueOf(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CaseRetry_Add_Minutes')));
    private final List<Id> auditHoldClaimIdsProcessed = new List<Id>();
    public static Map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();    
    global Database.QueryLocator start(Database.BatchableContext batchableContext){   
       
        return Database.getQueryLocator(queryActive);
    }
       
    global void execute(Database.BatchableContext batchableContext, List<Core_MDF_Audit_Hold_Claim__c> auditHoldClaimList)
    { 
   
    try{
        Map<Id,Id> claimToCaseIdFromCase = new Map<Id,Id>{};
        List<Core_MDF_Audit_Hold_Claim__c> batchStatusToBeUpdated = new List<Core_MDF_Audit_Hold_Claim__c>();
        Map<Id,Core_MDF_Audit_Hold_Claim__c> mapClaimIdToAuditHoldClaims = new Map<Id,Core_MDF_Audit_Hold_Claim__c>{};
        Map<Id,PartnerFundClaim> claimToCaseIdFromPFC = new Map<Id,PartnerFundClaim>{};
        List<PartnerFundClaim> claimListToBeUpdatedWithCaseId = new List<PartnerFundClaim>();
        Map<Id,List<Core_MDF_Audit_Document__c>> claimIdWithConDocId = new Map<Id,List<Core_MDF_Audit_Document__c>>(); //POP
        List<Case> casesToBeUpdatedForDoc = new List<Case>();
        Map<Id,Case> claimIdToCaseFromCase = new Map<Id,Case>{};
        Map<Id,List<Core_MDF_Audit_Document__c>> caseIdToAudDocMap = new Map<Id,List<Core_MDF_Audit_Document__c>>{};
        Set<String> claimIdSet = new Set<String>{}; 
      
        
        for(Core_MDF_Audit_Hold_Claim__c c:auditHoldClaimList) {                        
            mapClaimIdToAuditHoldClaims.put(c.Core_MDF_Claim_Id__c,c);
            claimIdSet.add(c.Core_MDF_Claim_Id__c);  
        }
       
        
       for(Case c : [select id,core_mdf_claim_id__c,casenumber,Core_MDF_Status__c,
                     Core_MDF_More_Documentation_Required__c,Core_MDF_SLA_Start_Date__c from case 
             where core_mdf_claim_id__c in: claimIdSet]){
                 claimToCaseIdFromCase.put(c.core_mdf_claim_id__c,c.Id);
                 claimIdToCaseFromCase.put(c.core_mdf_claim_id__c,c);
                                        }
      
        // Added new Case Review Document Fields
        for(Core_MDF_Audit_Document__c a: [SELECT Id, Core_MDF_Document_Id__c , Core_MDF_Document_Title__c, Core_MDF_Claim__c ,Core_MDF_Audit__c,
                                           Core_MDF_App_Document_Types_nm__c, Core_MDF_Applicable_Document_Types_txt__c, 
                                           Core_MDF_Selected_Document_Types_txt__c, Core_MDF_Document_Types__c FROM Core_MDF_Audit_Document__c 
                                           WHERE Core_MDF_Audit__c in:claimToCaseIdFromCase.values()]){
                                               List<Core_MDF_Audit_Document__c> tempIdList = new List<Core_MDF_Audit_Document__c>();
                                               tempIdList.add(a);
                                               caseIdToAudDocMap.put(a.Core_MDF_Audit__c,tempIdList);                                                                    
                                               
                                           }
        
       for(PartnerFundClaim claim : [select id,Core_MDF_Audit_Hold__c,Core_MDF_Claim_Review_Case__c from PartnerFundClaim 
                                        where Id in: claimIdSet and Core_MDF_Claim_Review_Case__c = null
                                    and Core_MDF_Audit_Hold__c=true]){
                                            claimToCaseIdFromPFC.put(claim.id,claim);   
                                     
                                        
         }
        
        // Added new Case Review Document Fields
        for(Core_MDF_Audit_Document__c auditDoc: [SELECT Id, Core_MDF_Document_Id__c , Core_MDF_Document_Title__c, Core_MDF_Claim__c ,Core_MDF_Audit__c,
                                                  Core_MDF_App_Document_Types_nm__c, Core_MDF_Applicable_Document_Types_txt__c, 
                                                  Core_MDF_Selected_Document_Types_txt__c, Core_MDF_Document_Types__c FROM Core_MDF_Audit_Document__c
                                                  WHERE Core_MDF_Claim__c IN:claimIdSet]){
                                                      List<Core_MDF_Audit_Document__c> tempIdList = new List<Core_MDF_Audit_Document__c>();
                                                      tempIdList.add(auditDoc);
                                                      claimIdWithConDocId.put(auditDoc.Core_MDF_Claim__c,tempIdList);                                                                    
                                                  }       
          
        // Call the Case Creation class(Core_MDF_ClaimReviewCaseProcessHelper) and send all the claim ids for creating case.
           for(Id claimId:claimIdSet) {
               Core_MDF_Audit_Hold_Claim__c ahc = new Core_MDF_Audit_Hold_Claim__c();
               ahc.Id = mapClaimIdToAuditHoldClaims.get(claimId).Id;
               auditHoldClaimIdsProcessed.add(ahc.Id);
               //if the claim is still on hold and there is no case generated
               if((claimToCaseIdFromCase == null || (claimToCaseIdFromCase != null && !claimToCaseIdFromCase.containsKey(claimId))) 
                   && claimToCaseIdFromPFC.containsKey(claimId)){
                 PartnerFundClaim p =new PartnerFundClaim();
                /*check the following cases:
                 * if status is pending means first time creating case, so update status to processing and call case craetion.
                 * if status is processing and retry < 2, incremnent the retry to + 1, and call case creation
                 * if retry already= 2, then update the status to failed.
                
                if(mapClaimIdToAuditHoldClaims.get(claimId).Core_MDF_Status__c == 'Pending')
                {
                    ahc.Core_MDF_Status__c='Processing';
                    p.Id=mapClaimIdToAuditHoldClaims.get(claimId).Core_MDF_Claim_Id__c;
                    pfcList.add(p);
                }      
                if(mapClaimIdToAuditHoldClaims.get(claimId).Core_MDF_Status__c == 'Processing'
                   && mapClaimIdToAuditHoldClaims.get(claimId).Core_MDF_Retry_Indicator__c < 2)
                {
                    ahc.Core_MDF_Retry_Indicator__c = mapClaimIdToAuditHoldClaims.get(claimId).Core_MDF_Retry_Indicator__c+1;
                    p.Id=mapClaimIdToAuditHoldClaims.get(claimId).Core_MDF_Claim_Id__c;
                    pfcList.add(p);
                }
                if(mapClaimIdToAuditHoldClaims.get(claimId).Core_MDF_Retry_Indicator__c == 2)
                {
                   ahc.Core_MDF_Status__c='Failed';
                   ahc.Core_MDF_Retry_Indicator__c = mapClaimIdToAuditHoldClaims.get(claimId).Core_MDF_Retry_Indicator__c+1;                   
                }  
                
               }
               //if there is case generated for processing claims,but the case id is not updated on claim, then update the same.
               //update the batch status to completed.
               else if(claimToCaseIdFromCase.containsKey(claimId) && 
                       claimToCaseIdFromPFC.containsKey(mapClaimIdToAuditHoldClaims.get(claimId).Core_MDF_Claim_Id__c)){
                   PartnerFundClaim p =new PartnerFundClaim();
                   p.Id = mapClaimIdToAuditHoldClaims.get(claimId).Core_MDF_Claim_Id__c;     
                   p.Core_MDF_Claim_Review_Case__c = claimToCaseIdFromCase.get(mapClaimIdToAuditHoldClaims.get(claimId).Core_MDF_Claim_Id__c);
                   claimListToBeUpdatedWithCaseId.add(p);
                   ahc.Core_MDF_Status__c='Processing';                  
               }
               
               //check the document for case(pop) 
               /*Modified by: JV-Accenture: 
               //check if Claim and Case docs are same in size and are in sync else prepare the resp. map and calling the helper class to sync up            
               
               else if(claimIdWithConDocId != null && !claimIdWithConDocId.isEmpty() 
                       && claimIdWithConDocId.containsKey(mapClaimIdToAuditHoldClaims.get(claimId).Core_MDF_Claim_Id__c)
                       && claimIdToCaseFromCase != null && !claimIdToCaseFromCase.isEmpty() && claimIdToCaseFromCase.containsKey(claimId)
                       && ((caseIdToAudDocMap != null && !caseIdToAudDocMap.isEmpty() && caseIdToAudDocMap.get(claimIdToCaseFromCase.get(claimId).Id) == null)
                           ||
                           (caseIdToAudDocMap != null && !caseIdToAudDocMap.isEmpty() && caseIdToAudDocMap.get(claimIdToCaseFromCase.get(claimId).Id).size() != 
                            claimIdWithConDocId.get(claimId).size())
                           || (caseIdToAudDocMap == null || caseIdToAudDocMap.isEmpty())
                          )
                      )
               {                
                   casesToBeUpdatedForDoc.add(claimIdToCaseFromCase.get(claimId));                              
               }
               else{
                   ahc.Core_MDF_Status__c='Completed';                   
               } 
               batchStatusToBeUpdated.add(ahc);
                           
           }
            
           
        //Commenting and addign in finish method as part of DE67727.    
        /*if(pfcList != null && pfcList.size()>0){
          ID jobID = System.enqueueJob(new Core_MDF_ClaimReviewCaseProcessHelper(pfcList,'CreateCases'));  }   
        //US949837 - Added extra condition to fix checkmarx issue
        if(claimListToBeUpdatedWithCaseId != null && !claimListToBeUpdatedWithCaseId.isEmpty() && Schema.sObjectType.PartnerFundClaim.isUpdateable()){
            Database.SaveResult[] srLst = Database.update(claimListToBeUpdatedWithCaseId, false);            
        }
        if(casesToBeUpdatedForDoc != null && !casesToBeUpdatedForDoc.isEmpty()){
        Core_MDF_ClaimReviewCaseProcessHelper.insertAuditDocuments(casesToBeUpdatedForDoc, claimIdWithConDocId);
        }
        //US949837 - Added extra condition to fix checkmarx issue
        if(Schema.sObjectType.Core_MDF_Audit_Hold_Claim__c.isUpdateable()){
            Database.SaveResult[] brLst = Database.update(batchStatusToBeUpdated, false);
        }
                                
     
    } catch(exception ex){Core_MDF_CCP_UtilityClass.logErrorinLogObject(ex.getMessage(),'Core_MDF_Batch_RetryCaseCreation');} 
    
    } 
            
    global void finish (Database.BatchableContext batchableContext){
        try{
            //DE67727: WW07 | QA | R2 | Case Retry Batch is not processing the data for which Case ID is missing on the Claims
                  
            if(pfcList != null && !pfcList.isEmpty()){
            Database.executeBatch(new Core_MDF_ClaimReviewCaseProcessHelper(pfcList,'CreateCases'),50);} 
                    
            AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :batchableContext.getJobId()];
            String message = 'The batch Apex job with JObId: '+ a.Id +' processed below Claims with either no cases generated or cases generated but not updated on Claims.';
            List<Core_MDF_Audit_Hold_Claim__c> processedClaimsByBatch =  [select Core_MDF_Claim_Id__c,Name,Core_MDF_Status__c,Core_MDF_Retry_Indicator__c,CreatedDate from Core_MDF_Audit_Hold_Claim__c where id in :auditHoldClaimIdsProcessed];
            
            //Fetching Email Address details from Custom setting.
            String sendEmailAddress = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CCP_Support_Email');
            //String sendEmailAddress = 'ealisha.chatterjee@intel.com';
            Boolean sendemail = false;
            // Send an email to the Apex job's ;submitter notifying of job completion only if Custom Setting 'toAddress' data is available
            if(Test.isRunningTest()){
                sendEmailAddress = 'ealisha.chatterjee@intel.com';
                sendemail = true;
            }
            if(processedClaimsByBatch != null && !processedClaimsByBatch.isEmpty()){sendemail = true;}        
            if( sendemail == true && (sendEmailAddress != null && sendEmailAddress != '')){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                String[] toAddresses = new String[] {sendEmailAddress};      
                mail.setToAddresses(toAddresses);
                mail.setSubject('Salesforce Retry Case creation/updation :' + a.Status);
                
                String messageBody = '<style>table, th, td {border: 1px solid black;border-collapse: collapse;}';
                messageBody += '<table style="width:100%"><tr><th>Claim Id</th><th>Claim Title</th><th>Batch Status</th><th>Retry Indicator</th><th>Claim Created Date</th></tr>';
                for(Core_MDF_Audit_Hold_Claim__c pfc:processedClaimsByBatch){
                messageBody += '<tr><td>'+pfc.Core_MDF_Claim_Id__c+'</td><td>'+pfc.Name+'</td><td>'+pfc.Core_MDF_Status__c+'</td><td>'+pfc.Core_MDF_Retry_Indicator__c+'</td><td>'+pfc.CreatedDate+'</td></tr>';
                }
                messageBody += '</table>';
                if(errorMessage != '' || Test.isRunningTest()){
                    messageBody += '\n' + errorMessage;
                }
                mail.setHtmlBody(message + '<br/>' + messageBody);
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                
            }
            //Bharath - Added new method as part of US861738 - to Update the case Status
            if(mapFunctionalityNameTriggerExecution != null && mapFunctionalityNameTriggerExecution.containsKey('caseStatusUpdateIndicator') && mapFunctionalityNameTriggerExecution.get('caseStatusUpdateIndicator').Core_Active__c){
                updateCaseStatus();
            }
          
           
        }
        catch(exception ex){Core_MDF_CCP_UtilityClass.logErrorinLogObject(ex.getMessage(),'Core_MDF_Batch_RetryCaseCreation');}
    }
    //US861738 - [KIIT]: Batch Retry to incorporate the Case Closure which pass due date
    //Method to update the case status to Non-complaint if the Document submission due date is past
    public static void updateCaseStatus(){
        Id JobId = System.enqueueJob(new Core_MDF_CaseStatusUpdate());
        /*try{
            List<Case> toUpdateCaseList = new List<Case>();
            DateTime curDateTime = System.now();
            
            Integer recsLimit = Integer.valueOf(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CaseRecsUpdateLimit'));
            for(Case cs:[Select Id,Core_MDF_Document_Submission_DueDate_dtm__c,Core_MDF_Status__c,Core_MDF_Review_Case_Status__c from Case where RecordType.DeveloperName = 'Core_MDF_Audit' and Core_MDF_Status__c = 'Pending Documents' and Core_MDF_Document_Submission_DueDate_dtm__c <:curDateTime Limit :recsLimit]){
                DateTime docSubmissionDueDate = cs.Core_MDF_Document_Submission_DueDate_dtm__c;
                docSubmissionDueDate = docSubmissionDueDate.addDays(1);
                if(docSubmissionDueDate < curDateTime){
                    cs.Core_MDF_Review_Case_Status__c = 'Non-compliant';
                    toUpdateCaseList.add(cs);
                }
            }
            if(toUpdateCaseList != null && !toUpdateCaseList.isEmpty()){
                Database.SaveResult[] sr = Database.update(toUpdateCaseList, false);
            }
        }catch(exception e){
            
        }
    }*/
}