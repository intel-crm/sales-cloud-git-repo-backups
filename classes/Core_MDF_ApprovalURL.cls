/*********************************************************************************************************************************************************************************
* Class Name  : Core_MDF_ApprovalURL 
* Version     : 1.0 
* Created Date: 10-23-2018
* Modification Log : 
* Developer                     Date                          Description
  Accenture - NZ				12.07.2021					  US1033387_[RMF] - ATF Approval - SPIF Approver Notified on ATF approval
***********************************************************************************************************************************************************************************/
public without sharing class Core_MDF_ApprovalURL {
    
    public String recID {get; set;}
    
    public String actrID {get; set;}
    
    public String urlStr{  get { return generateApprovalURL(recID,actrID); } set;}
    /******************************************************************************************************************************************************************
    * Class Name  : generateApprovalURL 
    * Description : Get the Approval URL for id and respective User
    * Param		  : recID,actrID
    * Return	  : String
    * *****************************************************************************************************************************************************************/
    public static String generateApprovalURL(String recID,String actrID){
        String url='';
         List<ProcessInstanceWorkitem> workItemLst = new List<ProcessInstanceWorkitem>(); 
       
        String queryStr = '';
        PartnerFundRequest pfr = [SELECT id 
                                  FROM PartnerFundRequest 
                                  WHERE Id = :recID LIMIT 1];
        if(pfr.Core_MDF_Price_reviewer_check_ind__c = true){
            actrID = '';  
            queryStr = 'SELECT id FROM ProcessInstanceWorkitem WHERE processInstance.TargetObjectId=:recID';
         
        }else{  
            queryStr = 'SELECT id FROM ProcessInstanceWorkitem WHERE processInstance.TargetObjectId=:recID  AND ActorId =:actrID';
        }
        workItemLst = Database.query(queryStr);
        if(workItemLst != NULL && workItemLst.size() > 0) { 
            //url='https://'+ System.URL.getSalesforceBaseUrl().getHost() + '/p/process/ProcessInstanceWorkitemWizardStageManager?id=' + workItemLst[0].id;
            url='https://'+ System.URL.getOrgDomainUrl().getHost() + '/p/process/ProcessInstanceWorkitemWizardStageManager?id=' + workItemLst[0].id;   
        } 
        return url;
    }
}