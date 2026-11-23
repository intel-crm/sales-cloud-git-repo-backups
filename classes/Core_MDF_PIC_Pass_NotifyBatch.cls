public class Core_MDF_PIC_Pass_NotifyBatch implements Database.Batchable<sObject>, Database.Stateful {
    
    Set<Id> extUserIdSet = new Set<Id>();
     Public List<string> Intel_Owner_Based_Notification_Prog = Core_MDF_CCP_ConstantClass.Intel_Owner_Based_Notification_Prog;
    public Database.QueryLocator start(Database.BatchableContext bc){
        String Query ='select id,Core_MDF_Claim_ID_id__r.Core_MDF_PIC_Review_Completed__c, Core_MDF_Review_Date_dt__c FROM Core_MDF_PIC_Review__c LIMIT 500';
        return Database.getQueryLocator(Query);
        
    }
    Public void Execute(Database.BatchableContext bc,List<Core_MDF_PIC_Review__c> picReviewList) {
        Set<id> accIdSet = new Set<Id>();
        try{
            for(Core_MDF_PIC_Review__c picReviewRec:picReviewList){
                
                accIdSet.add(picReviewRec.Core_MDF_Claim_ID_id__r.ChannelPartnerId);
            }
            //Ayush - Added Partner_License_Reclaimed__c in where clause for "Reclaiming SF Partner License"
             for(Core_MDF_Partner_Node_User_Mapping__c pnum :[SELECT Id,Core_MDF_Account__c, Core_MDF_User__c,Core_MDF_User__r.Id 
                                                             FROM Core_MDF_Partner_Node_User_Mapping__c 
                                                             WHERE Core_MDF_Account__c IN : accIdSet AND
                                                              Core_MDF_Active_Ind__c = TRUE AND
                                                             (Core_MDF_User__r.IsActive = TRUE OR Core_MDF_User__r.Partner_License_Reclaimed__c = TRUE)]){
                                                                 
                                                                     extUserIdSet.add(pnum.Core_MDF_User__c);
                                                                
                                                             }
            
        }catch(Exception Ex){
            System.debug('Exception-->'+Ex.getmessage());
        }
        
    }
    public void finish(Database.BatchableContext bc){
         List<Messaging.SingleEmailMessage> emailTosendList= new List<Messaging.SingleEmailMessage>();
         List<Id> userIdListForSanitization = new List<Id>();
        Set<Id> userId = new Set<Id>();
        if(extUserIdSet!=null){
            for(PermissionSetAssignment userPer : [SELECT Id, AssigneeId, Assignee.AccountId, Assignee.IsActive, PermissionSet.Name 
                                                   FROM PermissionSetAssignment WHERE AssigneeId IN :extUserIdSet 
                                                   AND  PermissionSet.Name ='Core_MDF_CCP_External_Claim_Submitter'  
                                                        
                                                       ]){ 
                                                           if(!userId.contains(userPer.AssigneeId)){
                                                            emailTosendList.add(Core_MDF_GenericClassToSendMail.createEmailInstanceTarget(null,'Core_MDF_PIC_Completed_Notification',userPer.AssigneeId));
                                                           userId.add(userPer.AssigneeId);
                                                           }
                                                       }
        }
         if(emailTosendList != NULL && !emailTosendList.isEmpty()) {
                List<Messaging.SendEmailResult> res= Core_MDF_GenericClassToSendMail.sendEmails(emailTosendList);
                System.debug('result-->'+res);
            } 
    }
}