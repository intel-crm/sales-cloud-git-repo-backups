/******************************************************************************************************************
    *Class Name : validateDealRegForm
    *@author : Chaithaly
    *Created Date: 03-07-2024
    
*******************************************************************************************************************/  

public with sharing class PCC_InvocableMethods {
    /******************************************************************************************************************
    *Method Name : approvalProcessActions
    *@author : Chaithaly
    *Created Date: 03/04/2024
    *Description :Generic method to perform Deal Registration action
    *******************************************************************************************************************/  
  
    @InvocableMethod(label='Deal Approval Process Actions' description='Approval Process actions' category='PCC')
    public static void approvalProcessActions(list<approvalWrapper> approvalParam){
        String recordId = approvalParam[0].regId; // Pass the Record id
        ProcessInstanceWorkitem[] Pval = [SELECT Id FROM ProcessInstanceWorkItem WHERE ProcessInstance.TargetObjectId = :recordId AND ProcessInstance.Status = 'Pending'];        
        Approval.ProcessWorkItemRequest Preq= new Approval.ProcessWorkItemRequest();
        Preq.setAction(approvalParam[0].action);
        Preq.setComments(approvalParam[0].comments);
      if(Pval.size() > 0){   
         Preq.setWorkItemId(Pval[0].Id);
         Approval.ProcessResult result = Approval.process(Preq);
        }
    }
    /******************************************************************************************************************
    *Method Name : isAuthorizedUser
    *@author : Chaithaly
    *Created Date: 04/10/2024
    *Description :Method to check if user is authorized to approve deal
    *******************************************************************************************************************/  
    public static boolean isAuthorizedUser(Core_Design_Registration__c designReg){
        boolean isAuthorized = false;
        if((UserInfo.getUserId() == designReg.Core_Accepted_By_Id__c || UserInfo.getUserId() == designReg.Core_Accepted_By_Id__r.DelegatedApproverId)){
            isAuthorized = true;
        }
        return isAuthorized;
    }
    public class approvalWrapper{
        @InvocableVariable(required=true)
        public Id regId;

        @InvocableVariable(required=true)
        public String action;

        @InvocableVariable(required=true)
        public String comments;
    }
    
}