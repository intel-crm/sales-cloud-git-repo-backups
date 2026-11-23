public without sharing class Core_MDF_CampaignPurposeHandlerClass {
    public static set<Id> getIupgmAndSendEmail(Set<string> ultimateAccountIds){
        
        Set<Id> iupgmUserIdSet = new Set<Id>();
        List<String> accMgrRolesList = Core_MDF_CustomLabelConfig.getTextList('Core_MDF_Account_Manager_Roles');
        List<Messaging.SingleEmailMessage> emailTosendList= new List<Messaging.SingleEmailMessage>();
        
        Id EmailTemplateId = [SELECT Id, Name, DeveloperName FROM EmailTemplate where DeveloperName='Core_MDF_Reminder_Result_Quantity'].Id;
        
        if(!ultimateAccountIds.isEmpty()){
            for(Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm : [SELECT Id,Core_MDF_Account_id__c,Core_MDF_User_id__c,Core_MDF_Active_Ind__c,Core_MDF_Account_id__r.Name,
                                                                   Core_MDF_User_id__r.Email,Core_MDF_Role_nm__c,Core_MDF_is_User_Active_ind__c
                                                                   FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c
                                                                   WHERE Core_MDF_Account_id__c  IN: ultimateAccountIds
                                                                   AND Core_MDF_Role_nm__c IN:accMgrRolesList 
                                                                   AND Core_MDF_is_User_Active_ind__c = TRUE 
                                                                   AND Core_MDF_Active_Ind__c = TRUE
                                                                  ]){
                                                                      iupgmUserIdSet.add(iupgm.Core_MDF_User_id__c);
                                                                  }
        }
        
        return iupgmUserIdSet;
      /*  if(!iupgmUserIdSet.isEmpty() && EmailTemplateId!=NULL){
            for(Id userId:iupgmUserIdSet){
                
                emailTosendList.add(createEmailInstanceTarget(userId,EmailTemplateId,userId));
            }
        }
        if(emailTosendList != NULL && !emailTosendList.isEmpty()) {
            List<Messaging.SendEmailResult> res= Core_MDF_GenericClassToSendMail.sendEmails(emailTosendList);
        } */
        
    }
   /* public static Messaging.SingleEmailMessage createEmailInstanceTarget(Id recordId, Id templateId,String setTargetObjectId){
        return Core_MDF_GenericClassToSendMail.createEmailInstanceTarget(recordId,templateId,setTargetObjectId);   
    }*/
    
}