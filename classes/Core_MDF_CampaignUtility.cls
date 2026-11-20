public without sharing class Core_MDF_CampaignUtility {
        
        public static Boolean sendEmailOnce = true;
        public static Boolean sendEmailOnceForNonPCT = true;
        /*****************************************************************************************************
    Method Name :   notifyPCTApprovers
    @return     :   NULL
    @parameters :   campaign list 
    Description :   Proposal Approval Notification to PCT Approvers
    Added By    :   Sarah Manuel
    US          :   
    Modified By :                      Date:11/05/2022                     Changes:None
    ******************************************************************************************************/    
    public static void notifyPCTApprovers(notificationWrapper wrapper, string role){
            
            
            
            List<Core_MDF_GenericClassToSendMail.MailParams> inputList = new List<Core_MDF_GenericClassToSendMail.MailParams>();      
            //Set<Id> userIdSet = new Set<Id>();   
            String emailTemplate;
            Map<String,Object> emailTemplateMap = getTemplateNameByProgName();
            
            Map<String, Map<String, List<Id>>> resultMap = new Map<String, Map<String, List<Id>>>();
            //Map<String, String> accIDMap;
            resultMap = Core_MDF_GeneralPurpose_UI_Utility.getIupgmRecordsPCT(wrapper.accntList,wrapper.programList,wrapper.geoList,role);
          
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
            		    
                            // Roshan - IUPGM fix for CoGTM
            		        String geo = '';
            		        if (program == 'CoGTM') {
                	            geo = camp.Core_MDF_Region_cd__c + ';WW';
                            } else if (program == 'Intel Partner Alliance') {
                                geo = camp.Core_MDF_Host_Region_cd__c + ';WW';
                            }

                            IupgmKeyWrapper keyWrapper = new IupgmKeyWrapper(program, geo, role, accID, null, null);
                           
                        userIds = new List<Id>();
                        if(resultMap.containsKey('allAccountsYesOrNo')){
                            resultsubMap = resultMap.get('allAccountsYesOrNo');                        
                            for(String key :resultsubMap.keySet()){
                                for (String matchKey : keyWrapper.allAccountsYesOrNo) {
                                    if (key.contains(matchKey)) {
                                        userIds.addAll(resultSubMap.get(key));
                                    }
                                }
                            }
                        }/*else if(resultMap.containsKey('allAccountsYes')){
                           
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
                    
                    if(!emailTemplateMap.isEmpty() && emailTemplateMap.containsKey(camp.Core_MDF_Program__c)){
                            emailTemplate = (String)emailTemplateMap.get(camp.Core_MDF_Program__c);
                    }
                   
                    if(userIds != NULL && !userIds.isEmpty()){
                        Core_MDF_GenericClassToSendMail.MailParams sendEmailToReviewer = new Core_MDF_GenericClassToSendMail.MailParams();
                        sendEmailToReviewer.recordId = camp.Id;
                    // sendEmailToPRCReviewer.templateName = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_PCTApproverNotification');
                        sendEmailToReviewer.templateName = emailTemplate;
                        sendEmailToReviewer.userIdList = userIds;
                        sendEmailToReviewer.sendDiff = false;
                        inputList.add(sendEmailToReviewer);
                        
                    }
                    
                }
            
            if(inputList != NULL && inputList.size() >0 && sendEmailOnce){
                
                Core_MDF_GenericClassToSendMail.sendEmailMethod(inputList); 
                sendEmailOnce = false;
                
            }
        }
        
        /*****************************************************************************************************
    Method Name :   notifyAllApprovers
    @return     :   NULL
    @parameters :   campaign list 
    Description :   Proposal Approval Notification to All the Approvers
    Added By    :   Saikat Manna
    US          :   
    Modified By :  Date:24/06/2022                     Changes:None
    ******************************************************************************************************/    
        public static void notifyAllApprovers(notificationForAllApproversWrapper wrapper){
            List<Core_MDF_GenericClassToSendMail.MailParams> inputList = new List<Core_MDF_GenericClassToSendMail.MailParams>();      
            //Set<Id> userIdSet = new Set<Id>();   
            Map<String, Object> emailTemplateMap = getTemplateNameByProgName();
            Map<String, String> approvalStageToRoleMap = new Map<String, String>();
            Map<String, string> roleCheckforAccountAccessMap = new Map<String, string>();
            List<String> roleList = new List<String>();
            Map<String, Map<String, List<Id>>> resultMap = new Map<String, Map<String, List<Id>>>();
            //Map<String, String> accIDMap;
            String emailTemplate;
        String categoryGeneralUtility = 'Core_MDF_GeneralPurpose_UI_Utility_Role_Mappings';
        String category ='notifyIUPGMBasedNotification';  
        
        
        for(Core_MDF_Custom_Label_Configration__mdt meta: [SELECT DeveloperName, Core_MDF_Value_Txt__c, Core_MDF_Value2_Txt__c, Core_MDF_Value3_Txt__c,
                                                           Core_MDF_Value4_Txt__c, Core_MDF_Category_Txt__c, Core_MDF_Org_Specific_Ind__c,
                                                           Core_MDF_Value5_Txt__c
                                                           FROM Core_MDF_Custom_Label_Configration__mdt 
                                                           WHERE Core_MDF_Category_Txt__c =: category 
                                                           AND Core_MDF_Value3_Txt__c IN: wrapper.approvalStageStatusList 
                                                           AND Core_MDF_Value_Txt__c IN: wrapper.programList 
                                                           AND (Core_MDF_Value5_Txt__c IN: wrapper.budgetTypeList OR Core_MDF_Value5_Txt__c = null OR Core_MDF_Value5_Txt__c ='Proposal Based')]){
                                                               
                                                             
            roleList.add(meta.Core_MDF_Value4_Txt__c);
            if(!String.isBlank(meta.Core_MDF_Value5_Txt__c) && meta.Core_MDF_Value5_Txt__c!='Proposal Based'){
            	approvalStageToRoleMap.put(meta.Core_MDF_Value_Txt__c+meta.Core_MDF_Value5_Txt__c+meta.Core_MDF_Value3_Txt__c, meta.Core_MDF_Value4_Txt__c);    
            }else{
                approvalStageToRoleMap.put(meta.Core_MDF_Value_Txt__c+meta.Core_MDF_Value3_Txt__c, meta.Core_MDF_Value4_Txt__c);    
            }
                                                               
            //String approvalStageToRoleMapKey = String.isBlank(meta.Core_MDF_Value5_Txt__c) ? meta.Core_MDF_Value_Txt__c + meta.Core_MDF_Value3_Txt__c : meta.Core_MDF_Value_Txt__c + meta.Core_MDF_Value5_Txt__c + meta.Core_MDF_Value3_Txt__c;                                                            
            //approvalStageToRoleMap.put(approvalStageToRoleMapKey, meta.Core_MDF_Value4_Txt__c);
        }    
        
        //resultMap = Core_MDF_GeneralPurpose_UI_Utility.getIupgmRecordsPCT(wrapper.accntList,wrapper.programList,wrapper.geoList,role);
        
        
        for(Core_MDF_Custom_Label_Configration__mdt mdtRec: [SELECT DeveloperName, Core_MDF_Value_Txt__c,Core_MDF_Value2_Txt__c,Core_MDF_Value3_Txt__c,
															 Core_MDF_Value4_Txt__c,Core_MDF_Category_Txt__c, Core_MDF_Org_Specific_Ind__c
															 FROM Core_MDF_Custom_Label_Configration__mdt WHERE Core_MDF_Category_Txt__c =: categoryGeneralUtility
                                                             AND Core_MDF_Value_Txt__c IN: wrapper.programList AND Core_MDF_Value2_Txt__c IN: roleList]){	
			roleCheckforAccountAccessMap.put(mdtRec.Core_MDF_Value_Txt__c + mdtRec.Core_MDF_Value2_Txt__c, mdtRec.Core_MDF_Value3_Txt__c);
        }       
       
        
        //resultMap = Core_MDF_GeneralPurpose_UI_Utility.getIupgmRecordsForApprovers(wrapper.accntList, wrapper.programList, wrapper.geoList, roleList);
            resultMap = Core_MDF_GeneralPurpose_UI_Utility.getIupgmForApproversWithBudgetType(wrapper.accntList, wrapper.programList, wrapper.geoList, roleList, wrapper.budgetTypeList,wrapper.approvalStageStatusList);
        
        
        Map<String, Object> programNameByRecNameMap = Core_MDF_GeneralPurpose_UI_Utility.getProgramNameByRecName();            
        for(Campaign camp : wrapper.campList){
            String approvalMapKey = camp.Core_MDF_Program__c + camp.Core_MDF_Budget_Type_txt__c + camp.Core_MDF_Approval_Stage_nm__c;
            String approvalMapKeyWithoutBudgetType = camp.Core_MDF_Program__c + camp.Core_MDF_Approval_Stage_nm__c;
            //String approvalMapKey = camp.Core_MDF_Program__c + camp.Core_MDF_Budget_Type_txt__c + 'L1 Approval';
            //String approvalMapKeyWithoutBudgetType = camp.Core_MDF_Program__c + 'L1 Approval';
           
            String program = '';
            Map<string, List<Id>> resultsubMap;
            if(programNameByRecNameMap.containsKey(camp.Core_MDF_Program__c)){
                program = ((String)programNameByRecNameMap.get(camp.Core_MDF_Program__c));
            }
            List<Id> userIds;
            if(resultMap != null){
                String role = approvalStageToRoleMap.containsKey(approvalMapKey) ? approvalStageToRoleMap.get(approvalMapKey) : approvalStageToRoleMap.get(approvalMapKeyWithoutBudgetType);
               
                
                String roleCheckforAccountKey = camp.Core_MDF_Program__c + role;
                
                
                String accountAccess = roleCheckforAccountAccessMap.get(roleCheckforAccountKey);
                
                
                Id accID = camp.Core_MDF_Ultimate_Account_txt__c;
            
                //Roshan - IUPGM logic fix for CoGTM
                String geo = '';
                if (program == 'CoGTM') {
                    geo = camp.Core_MDF_Region_cd__c + ';WW';
                } else if (program == 'Intel Partner Alliance') {
                    geo = camp.Core_MDF_Host_Region_cd__c + ';WW';
                    }

                IupgmKeyWrapper keyWrapper = new IupgmKeyWrapper(program, geo, role, accID, camp.Core_MDF_Opal_Budget_Type_Txt__c, camp.Core_MDF_Approval_Stage_nm__c);

                userIds = new List<Id>();
                if(resultMap.containsKey(role)  && accountAccess=='allAccountsYesOrNo'){
                   
                    resultsubMap = resultMap.get(role);                        
                    for(String key :resultsubMap.keySet()){	   
			for(String ikey : keyWrapper.allAccountsYesOrNo) {    
                            if (key.contains(ikey)) {
                                userIds.addAll(resultsubMap.get(key));
                            }
                        }
                    }
                } else if(resultMap.containsKey(role) && accountAccess=='allAccountsYes'){
                   
                    resultsubMap = resultMap.get(role);
                    for(String key :resultsubMap.keySet()){
                        for(String ikey : keyWrapper.allAccountsYes) {
                            if (key.contains(ikey)) {
                                userIds.addAll(resultsubMap.get(key));
                            }
                        }
                    }
                } else if(resultMap.containsKey(role) && accountAccess=='allAccountsNo'){
                   
                    resultsubMap = resultMap.get(role);
                    for(String key :resultsubMap.keySet()){
                        for(String ikey : keyWrapper.allAccountsNo) {
                            if (key.contains(ikey)) {
                                userIds.addAll(resultsubMap.get(key));
                            }
                        }
                    }
                }
            }
            
            if(!emailTemplateMap.isEmpty() && emailTemplateMap.containsKey(camp.Core_MDF_Program__c)){
                emailTemplate = (String)emailTemplateMap.get(camp.Core_MDF_Program__c);
            }
            
            if(userIds != NULL && !userIds.isEmpty()){
                Core_MDF_GenericClassToSendMail.MailParams sendEmailToReviewer = new Core_MDF_GenericClassToSendMail.MailParams();
                sendEmailToReviewer.recordId = camp.Id;
                sendEmailToReviewer.templateName = emailTemplate;
                sendEmailToReviewer.userIdList = userIds;
                sendEmailToReviewer.sendDiff = false;
                inputList.add(sendEmailToReviewer);
               
            }
        }
        if(inputList != NULL && inputList.size() >0 && sendEmailOnceForNonPCT){
           
            Core_MDF_GenericClassToSendMail.sendEmailMethod(inputList); 
            sendEmailOnceForNonPCT = false;
        }
    }
    
    public static Map<String,Object> getTemplateNameByProgName(){
        String jsonInputString = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_EmailTemplateMappingByProgrName');
 	    Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(jsonInputString);
 		
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
                        
                            // Roshan - Added Partner_License_Reclaimed__c in where clause for "Reclaiming SF Partner License"
                            for(PermissionSetAssignment usrPer : [SELECT Id, AssigneeId, Assignee.AccountId, Assignee.IsActive, Assignee.Partner_License_Reclaimed__c, PermissionSet.Name 
                                                      FROM PermissionSetAssignment WHERE PermissionSet.Name = : PermSetsList and (Assignee.IsActive =true or Assignee.Partner_License_Reclaimed__c = true)]){
                                                          //AND PermissionSet.Name =: Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Extrnl_Prposl_Mgr_Prmsn_Set')]){
                                                          intRMFUserIdList.add(usrPer.AssigneeId);
                                                      }
                        
                         Core_MDF_GenericClassToSendMail.MailParams sendEmailToExt = new Core_MDF_GenericClassToSendMail.MailParams();
         for(Campaign cmp : campaignList){
                    	 sendEmailToExt.recordId = cmp.Id;
                         sendEmailToExt.templateName = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_RMF_Template_Name_Budget_Inc');
                        sendEmailToExt.userIdList = intRMFUserIdList;
                    	sendEmailToExt.sendDiff = false;
                    	inputList.add(sendEmailToExt);
                        
         }                   
                     if(inputList != NULL && inputList.size() >0){
                         
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

   /***************************************************************************************************** 
Class Name:         notificationWrapperForAllApprovers 
Description:        Wrapper to store notification details
@Added By:          Saikat Manna 
Modified By:        Date: 24-06-2022      Changes: 
******************************************************************************************************/ 
    public class notificationForAllApproversWrapper {
        List<Campaign> campList;
        List<String> accntList;
        List<String> geoList;
        List<String> programList;
        List<String> approvalStageStatusList;
        List<String> budgetTypeList;
        
        public notificationForAllApproversWrapper(List<Campaign> campList, List<String> accntList, List<String> geoList,
                                                  List<String> programList, List<String> approvalStageStatusList, List<String> budgetTypeList){
                                                      this.campList = campList;
                                                      this.accntList = accntList;
                                                      this.geoList = geoList;
                                                      this.programList = programList;
                                                      this.approvalStageStatusList = approvalStageStatusList;  
                                                      this.budgetTypeList = budgetTypeList;
                                                  }
        }
    /***************************************************************************************************** 
    Class Name:         IupgmKeyWrapper
    Description:        Wrapper to prepare and store the keys used for matching IUPGMs
    @Added By:          Roshan 18-04-2025
    Modified By:        Date:       Changes: 
    ******************************************************************************************************/ 
    private class IupgmKeyWrapper {
        public Set<String> allAccountsYesOrNo;
        public Set<String> allAccountsYes;
        public Set<String> allAccountsNo;
        
        public IupgmKeyWrapper(String program, String geo, String role, Id accId, String budgetType, String approvalStage) {
            allAccountsYesOrNo = new Set<String>();
            allAccountsYes = new Set<String>();
            allAccountsNo = new Set<String>();
        
            String classification = '';
            // Skip adding classification to the keys if approvalStage is blank
            if (!String.isBlank(approvalStage) && Core_MDF_CCP_ConstantClass.stageToClassificationMap.containsKey(approvalStage)) {
                classification = Core_MDF_CCP_ConstantClass.stageToClassificationMap.get(approvalStage);
            }
        
            List<String> geoList = geo.split(';');
            for (String geoRec : geoList) {
            
                allAccountsYesOrNo.add(program + geoRec + role + accId + classification);
                allAccountsNo.add(program + geoRec + role + accId + classification);
                allAccountsYesOrNo.add(program + geoRec + role + 'null' + classification);
                allAccountsYes.add(program + geoRec + role + 'null' + classification);

                if (program == 'Intel Partner Alliance' && geoRec == 'WW') continue;
        
                // Skip adding budgetType to the keys if budgetType is blank
                if (!String.isBlank(budgetType)) {
                    allAccountsYesOrNo.add(program + geoRec + budgetType + role + accId + classification);
                    allAccountsNo.add(program + geoRec + budgetType + role + accId + classification);
                    allAccountsYesOrNo.add(program + geoRec + budgetType + role + 'null' + classification);
                    allAccountsYes.add(program + geoRec + budgetType + role + 'null' + classification);
                }
            }
        }
    }
    /***************************************************************************************************** 
    Class Name:         Core_MDF_CampaignUtility
    Method Name:        getBudgetTypeBenefitRec
    Description:        Change Custom Setting (Core_MDF_BudgetType_Benefit_Mappings__c) from Custom Metedata (Core_MDF_BudgetType_Benefit_Mapping__mdt)
    @Added By:          ankit7x.kumar@intel.com 09-06-2025
    ******************************************************************************************************/ 
    @AuraEnabled(cacheable=true)
    public static List<sObject> getBudgetTypeBenefitRec(String objectApiName, String whereClause) {
        List<sObject> queryResults = new List<sObject>();
        try{
            if(objectApiName != null){
                switch on objectApiName {
                        when 'Core_MDF_BudgetType_Benefit_Mappings__c' {
                            String queryString = 'Select Id, Name, Core_MDF_RecordType__c,Core_MDF_Record_Developer_Nm__c,Core_MDF_Budget_Type__c,Core_MDF_Partner_Benefit__c from Core_MDF_BudgetType_Benefit_Mappings__c';
                            if(whereClause != null && whereClause.trim() != ''){
                                String sanitizedWhereClause = String.escapeSingleQuotes(whereClause).replaceAll('\\\\','');
                                queryString += ' Where '+sanitizedWhereClause;
                        }
                        queryResults = Database.query(queryString);
                    }
                }
            }
        }catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex);} 
        return queryResults;
    }
}