public without sharing class PCC_RebateClaimHandler_2 {
    public static void UpdatePaymentProcessedStatus(List<PCC_Rebate_Claim__c> newList) {        
        for (PCC_Rebate_Claim__c newClaim : newList) {
            if (newClaim.PCC_CSAR_ID__c != null && newClaim.PCC_Payment_Ref_Id__c != null &&  newClaim.PCC_Claim_Status__c == 'Claim Approved - Payment Pending') {
                newClaim.PCC_Claim_Status__c = 'Payment Processed';
                newClaim.PCC_Payment_Date__c = Date.today();
            }
        }
    }
    
    public static void AddRebateClaimToApprovalQueue(List<PCC_Rebate_Claim__c> RCDataNew, map<Id,PCC_Rebate_Claim__c> oldMap){
        try{          
            for(PCC_Rebate_Claim__c ObjRC: RCDataNew) {
                PCC_Rebate_Claim__c oldClaim = oldMap.get(ObjRC.Id);
                if (ObjRC.PCC_Claim_Status__c == 'Claim Submitted' && oldClaim.PCC_Claim_Status__c != 'Claim Submitted')
                {  
                    Approval.ProcessSubmitRequest approvalRequest = new Approval.ProcessSubmitRequest();                
                    approvalRequest.setObjectId(ObjRC.Id);
                    approvalRequest.setComments('Rebate Claim Submitted for Approval');
                    approvalRequest.setProcessDefinitionNameOrId('PCC_Rebate_Claim_Approval_Process');
                    approvalRequest.setSkipEntryCriteria(false);
                    if(!Test.isRunningTest()){
                        Approval.ProcessResult approvalResult = Approval.process(approvalRequest);
                        if(approvalResult.isSuccess()){ 
                            // System.debug('PCC_RebateClaim_Approval');
                        }
                        else{ 
                            insert new Core_Log_Entry__c(Core_Message__c = 'Message',Core_Details__c ='Rebate Claim Submitted for Approval is failed', Core_Origin__c='PCC_RebateClaimHandler.AddRebateClaimToApprovalQueue', Core_Severity__c='Low', Core_When__c=System.Now(), Core_Project__c = 'Sales CRM');    
                        }
                    }
                }   
            }
        }
        Catch(Exception e){ 
            insert new Core_Log_Entry__c(Core_Message__c = 'Message',Core_Details__c = e.getMessage(), Core_Origin__c='PCC_RebateClaimHandler.AddRebateClaimToApprovalQueue', Core_Severity__c='Low', Core_When__c=System.Now(), Core_Project__c = 'Sales CRM');    
        }
        finally{ }  
    }
    
    public static void SendPaymentProcessedEmailNoty(List <PCC_Rebate_Claim__c> newList,map<Id,PCC_Rebate_Claim__c> oldMap){
        
        List <PCC_Rebate_Claim__c> rcsList = [Select Id,PCC_Claim_Status__c,PCC_Submitted_By__r.Email,PCC_Payment_Ref_Id__c,PCC_Partner__r.Name,PCC_Total_Approved_Rebate__c FROM PCC_Rebate_Claim__c WHERE Id IN: newList];                   
        
        try{
            // Iterate over the records to check if PCC_Claim_Status__c has changed to 'payment processed'
            for (PCC_Rebate_Claim__c newClaim : rcsList) {               
                PCC_Rebate_Claim__c oldClaim = oldMap.get(newClaim.Id);
                if ((oldClaim.PCC_Claim_Status__c == 'Claim Approved - Payment Pending') && newClaim.PCC_Claim_Status__c == 'Payment Processed') {                    
                    List<String> toEmailAddresses = new List<String>{newClaim.PCC_Submitted_By__r.Email};
                        List<PCC_Rebate_Claim_Line_Item__c> rebateClaimLIList = [SELECT Id, PCC_Opportunity__r.Owner.Email FROM PCC_Rebate_Claim_Line_Item__c WHERE PCC_Rebate_Claim__c =: newClaim.Id]; 
                    List<String> ccEmailOptyOwner= new List<String>();       
                    for(PCC_Rebate_Claim_Line_Item__c rcli :rebateClaimLIList) {
                        // generate CC email id for all the Opty Owners
                        ccEmailOptyOwner.add(rcli.PCC_Opportunity__r.Owner.Email);
                    }
                    PCC_RebateClaimEmailNotification.SendEmail('PCC_RebateClaim_PaymentProcessedNoty',toEmailAddresses,ccEmailOptyOwner, newClaim.Id);
                }
            }
        } catch (Exception e) {
            insert new Core_Log_Entry__c(Core_Message__c = 'Message',Core_Details__c = e.getMessage(), Core_Origin__c='PCC_RebateClaimHandler.SendPaymentProcessedEmailNoty', Core_Severity__c='high', Core_When__c=System.Now(), Core_Project__c = 'Sales CRM'); 
        }
        finally{ }
    }
}