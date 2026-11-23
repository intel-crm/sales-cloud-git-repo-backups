public class RMFexceptionnotificationdnr {

        
        
    public static void notifyExternalReviewers(list<Campaign> campaignList){
        
        Set<Id> campAccIdSet =new Set<Id>();
        Set<Id> userIdSet = new Set<Id>();
        List<Core_MDF_GenericClassToSendMail.MailParams> inputList = new List<Core_MDF_GenericClassToSendMail.MailParams>();
        Map<Id, Set<Id>> pnumAccountIdUserIdsMap = new Map<Id,Set<Id>>();
       List<id> externalUsersIdMap = new List<Id>();
        try{
            system.debug('line 13'+campaignList);
            if(campaignList!= null && campaignList.size() > 0){
                
                for(Campaign camp : campaignList){
                    campAccIdSet.add(camp.Core_MDF_Account__c);
                }
            }
            Map<Id,Set<Id>> pnumAccIdUserMap = new Map<Id,Set<Id>>();
            Map<Id, Set<Id>> pnumAccIdUserIdMap = new Map<Id,Set<Id>>();
            if(campAccIdSet != null && campAccIdSet.size() > 0){
        
                for(PermissionSetAssignment usrPer : [SELECT Id, AssigneeId, Assignee.AccountId, Assignee.IsActive, PermissionSet.Name 
                                                      FROM PermissionSetAssignment WHERE 
                                                       PermissionSet.Name = :  Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_RMF_Finance_Int')]){
                                                          //AND PermissionSet.Name =: Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Extrnl_Prposl_Mgr_Prmsn_Set')]){
                                                          externalUsersIdMap.add(usrPer.AssigneeId);
                                                      }
                
            }       
            if(campaignList!= null && campaignList.size() > 0){
                for(Campaign camp : campaignList){
                    system.debug('camplist'+campaignList);
                    List<Id> extUserIdList = new List<Id>();
                    List<Id> externalUserIds = externalUsersIdMap; 
                    for(Id externalUserId : externalUserIds){
                        if(externalUsersIdMap != null){
                            extUserIdList.add(externalUserId);
                        }    
                    }
                    System.debug('extUserIdList1: '+extUserIdList);                    
                    Core_MDF_GenericClassToSendMail.MailParams sendEmailToExt = new Core_MDF_GenericClassToSendMail.MailParams();
                    sendEmailToExt.recordId = camp.Id;
                    system.debug('pgmchk::'+camp.Core_MDF_Program__c);
               
                    sendEmailToExt.templateName = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_RMF_Template_Name_Budget_Inc');
                    sendEmailToExt.userIdList = extUserIdList;
                    sendEmailToExt.sendDiff = false;
                    inputList.add(sendEmailToExt);
                    
                }     
                if(inputList != NULL && inputList.size() >0){
                    system.debug('line 52'+inputList);
                    Core_MDF_GenericClassToSendMail.sendEmailMethod(inputList);
                }
            }
        }
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}
    }
    
    

}