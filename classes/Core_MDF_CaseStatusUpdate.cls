/****************************************************************************************************************************************
* Class Name  : Core_MDF_CaseStatusUpdate 
* Version     : 1.0 
* Created Date: 12-01-2021
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - Bharath 		 12-01-2021					  Queueable class invoked from Core_MDF_Batch_RetryCaseCreation
****************************************************************************************************************************************/
public without sharing class Core_MDF_CaseStatusUpdate implements Queueable {
    
    public void execute(QueueableContext context){
        try{
            List<Case> toUpdateCaseList = new List<Case>();
            DateTime curDateTime = System.now();
            Integer recsLimit = Integer.valueOf(System.Label.Core_MDF_CaseRecsUpdateLimit);
            for(Case cs:[Select Id,Core_MDF_Document_Submission_DueDate_dtm__c,Core_MDF_Status__c,Core_MDF_Review_Case_Status__c from Case where RecordType.DeveloperName = 'Core_MDF_Audit' and Core_MDF_Status__c = 'Pending Documents' and Core_MDF_Document_Submission_DueDate_dtm__c <:curDateTime Limit :recsLimit]){
                DateTime docSubmissionDueDate = cs.Core_MDF_Document_Submission_DueDate_dtm__c;
                docSubmissionDueDate = docSubmissionDueDate.addDays(1);
                if(docSubmissionDueDate < curDateTime){
                    cs.Core_MDF_Status__c = 'Non-compliant';
                    toUpdateCaseList.add(cs);
                }
            }
            if(toUpdateCaseList != null && !toUpdateCaseList.isEmpty()){
                Database.SaveResult[] sr = Database.update(toUpdateCaseList, false);
            }
        }catch(exception e){
            System.debug('Case status update Exception =>'+e.getMessage());
        }
    }

}