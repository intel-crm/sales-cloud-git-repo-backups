public class Areefa_PCC_SendPaymentProcessedEmailNoty {
    //Areefa
    public static void SendPaymentProcessedEmailNoty1(List <PCC_Rebate_Claim__c> newList,map<Id,PCC_Rebate_Claim__c> oldMap){
        List<Core_Log_Entry__c> logEntries = new List<Core_Log_Entry__c>();
        try
        {
            Set<Id> claimIds = new Set<Id>();
            
            // Iterate over the records to check if PCC_Claim_Status__c has changed to 'payment processed'
            for (PCC_Rebate_Claim__c newClaim : newList) {
                PCC_Rebate_Claim__c oldClaim = oldMap.get(newClaim.Id);
                
                if ((oldClaim.PCC_Claim_Status__c == 'Claim Approved - Payment Pending') && newClaim.PCC_Claim_Status__c == 'Payment Processed') {
                    String emailTemplateName = 'PCC_RebateClaim_PaymentProcessedNoty'; 
                    List<String> toEmailAddresses = new List<String>{newClaim.PCC_Submitted_By__r.Email}; //'areefa.banu@intel.com,shijas.km@intel.com,vijaykumar.s@intel.com';
                    System.debug('@toEmailAddress:' +toEmailAddresses); 
                    PCC_RebateClaimEmailNotification.SendEmail(emailTemplateName,toEmailAddresses,null, newClaim.Id);
                }
            }
        } catch (Exception e) {
            logEntries.add(new Core_Log_Entry__c(Core_Message__c = 'Message',Core_Details__c = e.getMessage(), Core_Origin__c='SendPaymentProcessedEmailNoty', Core_Severity__c='high', Core_When__c=System.Now(), Core_Project__c = 'Sales CRM'));   
        
        }
        finally{ insert logEntries;}
    }
}
        /*if (!claimsToProcess.isEmpty()) {
            List<PCC_Rebate_Claim_Line_Item__c> lineItems = [SELECT Id, PCC_Opportunity__c, PCC_Opportunity__r.Owner.Email FROM PCC_Rebate_Claim_Line_Item__c WHERE PCC_Rebate_Claim__c IN :claimIds];
            
            Set<String> emailAddresses = new Set<String>();
            for (PCC_Rebate_Claim_Line_Item__c lineItem : lineItems) {
                if (lineItem.PCC_Opportunity__r.Owner.Email != null) {
                    emailAddresses.add(lineItem.PCC_Opportunity__r.Owner.Email); // map <id, list(string)>
                }
            }
            
            // Convert the Set of email addresses to a comma-separated string
            String ccEmailAddresses = String.join(new List<String>(emailAddresses), ',');
            
            
            for (PCC_Rebate_Claim__c claim : claimsToProcess) {
                String emailTemplateName = 'PCC_RebateClaim_PaymentProcessedNoty'; 
                String toEmailAddress = claim.PCC_Submitted_By__r.Email;
                System.debug('@toEmailAddress:' +toEmailAddress);
                
                // Send the email               
                PCC_RebateClaimEmailNotification.SendEmail(emailTemplateName,toEmailAddress, null , claim.Id);
            }
            
        }
        
        
        
    }
}*/