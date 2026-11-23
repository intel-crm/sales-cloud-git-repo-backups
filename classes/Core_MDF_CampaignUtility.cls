public class Core_MDF_CampaignUtility {
    
    public static Boolean sendEmailOnce = true;
    /*****************************************************************************************************
Method Name :   notifyPCTApprovers
@return     :   NULL
@parameters :   campaign list 
Description :   Proposal Approval Notification to PCT Approvers
Added By    :   Sarah Manuel
US          :   
Modified By :                      Date:11/05/2022                     Changes:None
******************************************************************************************************/    
    public static void notifyApprovers(notificationWrapper wrapper, string role){
        
        
        
        List<Core_MDF_GenericClassToSendMail.MailParams> inputList = new List<Core_MDF_GenericClassToSendMail.MailParams>();      
        Set<Id> userIdSet = new Set<Id>();   
        String emailTemplate;
		Map<String,Object> emailTemplateMap = getTemplateNameByProgName();
        
        Map<String, Map<String, List<Id>>> resultMap = new Map<String, Map<String, List<Id>>>();
        Map<String, String> accIDMap;
        resultMap = Core_MDF_GeneralPurpose_UI_Utility.getIupgmRecordsPCT(wrapper.accntList,wrapper.programList,wrapper.geoList,role);
        System.debug('resultMap:::'+resultMap);
        Map<String,Object> programNameByRecNameMap = Core_MDF_GeneralPurpose_UI_Utility.getProgramNameByRecName();            
            for(Campaign camp : wrapper.campList){
                String program = '';
                Map<string,List<Id>> resultsubMap;
                    if(programNameByRecNameMap.containsKey(camp.Core_MDF_Program__c)){
                         program = ((String)programNameByRecNameMap.get(camp.Core_MDF_Program__c));
                }
                List<Id> userIds;
                if(resultMap != null){
						Id accID = camp.Core_MDF_Ultimate_Account_txt__c;
					    String allAccountNOKey = program+camp.Core_MDF_Region_cd__c+role+accID;
                        String allAccountNOKeyWW = program+'WW'+role+accID;
                        String allAccountYesKey = program+camp.Core_MDF_Region_cd__c+role+'null';
                        String allAccountYesKeyWW = program+'WW'+role+'null';
						System.debug('<<allAccountNOKey>>' + allAccountNOKey + '<<allAccountNOKeyWW>>' + allAccountNOKeyWW + '<<allAccountYesKey>>' + allAccountYesKey + '<<allAccountYesKeyWW>>' + allAccountYesKeyWW);
                    userIds = new List<Id>();
                    if(resultMap.containsKey('allAccountsYesOrNo')){
                        resultsubMap = resultMap.get('allAccountsYesOrNo');                        
                        for(String key :resultsubMap.keySet()){
                            if(key == allAccountNOKey || key == allAccountNOKeyWW ||
                               key == allAccountYesKey || key == allAccountYesKeyWW){
                                   userIds.addAll(resultsubMap.get(key));
                               }
                        }
                    }/*else if(resultMap.containsKey('allAccountsYes')){
                        System.debug('<<Inside allAccountsYes Condition>>');
						resultsubMap = resultMap.get('allAccountsYes');
                        for(String key :resultsubMap.keySet()){
                            if(key == allAccountYesKey || key == allAccountYesKeyWW){
                                   userIds.addAll(resultsubMap.get(key));
                               }
                        }
					}else if(resultMap.containsKey('allAccountsNO')){
						resultsubMap = resultMap.get('allAccountsNO');
                        for(String key :resultsubMap.keySet()){
                            if(key == allAccountNOKey || key == allAccountNOKeyWW){
                                   userIds.addAll(resultsubMap.get(key));
                               }
                        }
					}*/
                }
                System.debug('<<userIds>>' + userIds);
                System.debug('<<emailTemplateMap>>' + emailTemplateMap);
                if(!emailTemplateMap.isEmpty() && emailTemplateMap.containsKey(camp.Core_MDF_Program__c)){
                          emailTemplate = (String)emailTemplateMap.get(camp.Core_MDF_Program__c);
                   }
                System.debug('<<emailTemplate>>' + emailTemplate);
                if(userIds != NULL && !userIds.isEmpty()){
                    Core_MDF_GenericClassToSendMail.MailParams sendEmailToReviewer = new Core_MDF_GenericClassToSendMail.MailParams();
                    sendEmailToReviewer.recordId = camp.Id;
                   // sendEmailToPRCReviewer.templateName = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_PCTApproverNotification');
                    sendEmailToReviewer.templateName = emailTemplate;
                    sendEmailToReviewer.userIdList = userIds;
                    sendEmailToReviewer.sendDiff = false;
                    inputList.add(sendEmailToReviewer);
                    System.debug('<<inputListLoop>>' + inputList);
                }
                
            }
        
        if(inputList != NULL && inputList.size() >0 && sendEmailOnce){
            System.debug('<<inputList>>' + inputList);
            Core_MDF_GenericClassToSendMail.sendEmailMethod(inputList); 
            sendEmailOnce = false;
            
        }
    }
    
    public static Map<String,Object> getTemplateNameByProgName(){
        String jsonInputString = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_EmailTemplateMappingByProgrName');
 	    Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(jsonInputString);
 		System.debug('<<resultMapOutput>>'+resultMap);
        return resultMap;
    }
    
      /***************************************************************************************************** 
Class Name:         RMF notification 
Description:        
@Added By:          Navneet 26-05-2022
Modified By:        Date:       Changes: 
******************************************************************************************************/ 
     public static void notifyFinanceusers(list<Campaign> campaignList){
                 //notifyFinanceUsersandFinManager
                          List<String> PermSetsList = new List<String>();
                          List<Id> intRMFUserIdList = new List<Id>();
         				  List<Core_MDF_GenericClassToSendMail.MailParams> inputList = new List<Core_MDF_GenericClassToSendMail.MailParams>();
                        
                		  String intPermSet = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_RMF_Finance_Int');
                			if(intPermSet != null){
                   			 PermSetsList = intPermSet.split(','); 
                			}
                        
                            for(PermissionSetAssignment usrPer : [SELECT Id, AssigneeId, Assignee.AccountId, Assignee.IsActive, PermissionSet.Name 
                                                      FROM PermissionSetAssignment WHERE PermissionSet.Name = : PermSetsList and Assignee.IsActive =true]){
                                                          //AND PermissionSet.Name =: Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Extrnl_Prposl_Mgr_Prmsn_Set')]){
                                                          intRMFUserIdList.add(usrPer.AssigneeId);
                                                      }
                        system.debug('Line 380'+intRMFUserIdList);
                         Core_MDF_GenericClassToSendMail.MailParams sendEmailToExt = new Core_MDF_GenericClassToSendMail.MailParams();
         for(Campaign cmp : campaignList){
                    	 sendEmailToExt.recordId = cmp.Id;
                         sendEmailToExt.templateName = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_RMF_Template_Name_Budget_Inc');
                        sendEmailToExt.userIdList = intRMFUserIdList;
                    	sendEmailToExt.sendDiff = false;
                    	inputList.add(sendEmailToExt);
                        
         }                   
                     if(inputList != NULL && inputList.size() >0){
                         system.debug('Line 392'+inputList);
                    Core_MDF_GenericClassToSendMail.sendEmailMethod(inputList);
                }
    
     }
    
    
/***************************************************************************************************** 
Class Name:         notificationWrapper 
Description:        Wrapper to store notification details
@Added By:          Sarah Manuel 18-05-2022
Modified By:        Date:       Changes: 
******************************************************************************************************/ 
    public class notificationWrapper {
        
        List<Campaign> campList;
        List<String> accntList;
        List<String> geoList;
        List<String> programList;
        
        public notificationWrapper(List<Campaign> campList, List<String> accntList, List<String> geoList, List<String> programList){
                                     this.campList = campList;
                                     this.accntList = accntList;
                                     this.geoList = geoList;
                                     this.programList = programList;  
                                 }
        
        }

}