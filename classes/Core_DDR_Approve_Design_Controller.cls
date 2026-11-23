public with sharing Class Core_DDR_Approve_Design_Controller {
    public string callAlertFunc{get;set;}
    public string callException{get;set;}
    public static string DR_STATUS_APPROVED = 'Approved';
    public static string DR_STATUS_REJECTED = 'Rejected';
    public static string DR_STATUS_RESUBMITTED = 'Re-Submitted';
    
    public Core_DDR_Approve_Design_Controller(ApexPages.StandardController controller){}
    
    public PageReference ApproveReSubmitedDR() {            
        List<Core_Design_Registration__c> designRegList = [select id, Core_Design_Registration_Status_Nm__c from Core_Design_Registration__c WHERE Id = :ApexPages.currentPage().getParameters().get('id')];
        
        List<Core_Design_Registration__c> designRegListUpdate = new List<Core_Design_Registration__c>();
        
        for(Core_Design_Registration__c designRegUpdate: designRegList) {
            if(designRegUpdate.Core_Design_Registration_Status_Nm__c == DR_STATUS_RESUBMITTED) {
                designRegUpdate.Core_Design_Registration_Status_Nm__c = DR_STATUS_APPROVED;
                designRegUpdate.Core_Rejection_Reason_Nm__c = '';
                designRegUpdate.Core_Rejection_Comment_Txt__c = '';
                designRegListUpdate.add(designRegUpdate);
            }            
        }
        try {
            Approval.unlock(designRegListUpdate, true);
            
            update designRegListUpdate;
            
            Approval.lock(designRegListUpdate, true);
            callAlertFunc='<script> approvedSuccessfully() </script>';
            return null;
            }/*
            catch(Exception e)
            {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage());
            callException = string.valueof(myMsg);
            callAlertFunc='<script> exceptionMsg() </script>';
            return null;
        }*/
        catch(System.DmlException e) {
            //ApexPages.addMessages(ex);
            for (Integer i = 0; i < e.getNumDml(); i++) {
                callException = e.getDmlMessage(i);             
            }callAlertFunc='<script> exceptionMsg() </script>';return null;             
        }       
    }
}