/*********************************************************************************************************************************************************************************
* Class Name  : Core_MDF_ProcessCCP_PartnerFundRequest 
* Version     : 1.0 
* Created Date: 8-21-2018
* Modification Log :
* Developer                     Date                          Description
* -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Intel – Narayani Perachi      8/21/2018                     callApprovalProcess() - To determine Activities to be sent for Approval process along with their approvers or to 
*                                                             auto approve the activity based on certain criteria.
*                                                             This method is called in PartnerFundRequest trigger during afterUpdate and afterInsert.
*
* Intel – Narayani Perachi      9/05/2018                     assignAccountManagers() - For Approval Process which do not have Approvers configured, 
*                                                             the Account Managers of the parent Account will be assigned as the Approvers. 
*
* Intel – Narayani Perachi      8/21/2018                     callApprovalProcess() - This will trigger the standard Approval Process
*
* Intel – Narayani Perachi      8/21/2018                     updateApprovers() - This will set the approvers in the PartnerFundRequest object.
* Accenture – Shridhar K        9/17/2018                     Replaced custom label with Id variable ccfRecordTypeId and dcfRecordTypeId.
* Intel – Narayani Perachi      9/24/2018                     Replaced variables from PFRMap to pfrMap, PFRList to pfrList, PRFreq to pfrReq as per Code scan suggestions
* Intel - Narayani Perachi      9/24/2018                     Added without sharing to class Core_MDF_ProcessCCP_PartnerFundRequest
* Accenture – Shridhar K        12/23/2018                    Added recallApprovalProcess method to recall approval process
* Intel - Narayani Perachi      02/01/2019                    SPCF Changes - Added getRecordIDFromEnvironment() to get all the CCP Recordtype IDs from the environment
* Intel - Narayani Perachi      02/01/2019                    SPCF Changes - Commented Lines #34,#35 and made changes to If() in #58
* Intel - Narayani Perachi      02/08/2019                    Made changes to incorporate Auto Approval of Activity if created/modified by Account Manager
* Accenture - Shridhar K        03/08/2019                    Modified recallApprovalProcess to prevent Approve/Reject/Reassign Cancelled Activity 
* Intel - Narayani Perachi      03/11/2019                    Made changes in checkIfActivitySubmitterIsAccountManager() to check if activity is updated by account manager     
* Intel - Narayani Perachi    03/12/2019            Made changes to catch block of every method to get the error deatils using Core_MDF_CCP_UtilityClass.getErrorDetails()
* Accenture - Sai Sugathri      06/07/2019                    Added approvers from six to ten in tobeUpdatedList
* Accenture - Ayush             12/18/2024                    Added changes for "Reclaiming SF Partner License"
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Custom Labels used:
* Core_MDF_CCP_Account_Manager_Permission_Sets : Core_MDF_CCP_Internal_CCF_Account_Manager,Core_MDF_CCP_Internal_DCF_Account_Manager,Core_MDF_CCP_Internal_SPCF_Account_Manager
* Core_MDF_Activity_Cancelled_Status           : Cancelled
* Core_MDF_Activity_Recall_Exception_Origin    : Activity Recall Process
*********************************************************************************************************************************************************************************/
public without sharing class Core_MDF_ProcessCCP_PartnerFundRequest {
    
    public static Boolean runOnce = true;
    public static Boolean apprunOnce = true;
    public static Boolean emailSendOnce = true;    //DE115127
    public static Boolean sendEmailOnce = true;
    public static Boolean plannedEmailSendOnce = true;
    public static Boolean camprunonce = true;
    public static String logEntryMsg = '';
    public static Boolean isError = false;
    public static Boolean recallRunOnce = true;
    
    public static Map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
    public static Map<Id,List<Id>> objectIdUserGroupIdListMap = new Map<Id,List<Id>>();
    Public static string ESC_APPROVED_STATUS = Core_MDF_CCP_ConstantClass.ESC_APPROVED_STATUS;
    Public static string TYPE_CLAIM = Core_MDF_CCP_ConstantClass.TYPE_CLAIM; 
    Public static string IPA_PROG = Core_MDF_CCP_ConstantClass.IPA_PROGRAM;
    Public static string Co_GTM_Tech_PROG = Core_MDF_CCP_ConstantClass.Co_GTM_TECHNICAL_PROGRAM;
    Public static string Co_GTM_PROG = Core_MDF_CCP_ConstantClass.Co_GTM_PROGRAM;
    Public static string RMF_PROG = Core_MDF_CCP_ConstantClass.RMF_PROGRAM;
        Public static string EEF_PROGRAM = Core_MDF_CCP_ConstantClass.EEF_PROGRAM;
        Public static string EEF_BUDGET_TYPE = Core_MDF_CCP_ConstantClass.EEF_BUDGET_TYPE;
    public static Boolean stopRecursion = false;

    /*****************************************************************************************************
Method Name :   notifyInternalApproversOnRejection
@return     :   NULL
@parameters :   pfr list 
Description :   Notification to L1 Approver and Notification to L1 Primary Approver for EEF Program
Added By    :   
US          :   US914737 : [Opal CCF/DCF] - Activity Rejection Notifications when rejected by POR, PCT & L2 Approver
Modified By :                      Date:03/29/2021                     Changes:None
******************************************************************************************************/
    public static void notifyInternalApproversOnRejection(List<PartnerFundRequest> pfrList){
        
        List<Core_MDF_GenericClassToSendMail.MailParams> inputList = new List<Core_MDF_GenericClassToSendMail.MailParams>();        
        for(PartnerFundRequest pfr : pfrList){
            //sending the email to L1 Approver, the email will be sent to created by user also through Process builder
            if(pfr != NULL && pfr.Core_MDF_L1_Approver_Id__c != NULL){ 
                
                Core_MDF_GenericClassToSendMail.MailParams sendEmailToReviewer = new Core_MDF_GenericClassToSendMail.MailParams();
                sendEmailToReviewer.recordId = pfr.Id;
                sendEmailToReviewer.templateName = 'Core_MDF_Internal_Status_Change';
                sendEmailToReviewer.userIdList = new List<Id>{pfr.Core_MDF_L1_Approver_Id__c};
                sendEmailToReviewer.sendDiff = false;
                inputList.add(sendEmailToReviewer);  
            }
        if(pfr != NULL && pfr.Core_MDF_Program__c == Core_MDF_CCP_ConstantClass.EEF_PROGRAM && pfr.Core_MDF_L1_Primary_Approver_Id__c!=NULL ){ 
                    Core_MDF_GenericClassToSendMail.MailParams sendEmailToReviewer = new Core_MDF_GenericClassToSendMail.MailParams();
                    sendEmailToReviewer.recordId = pfr.Id;
                    sendEmailToReviewer.templateName = 'Core_MDF_Internal_Status_Change';
                    sendEmailToReviewer.userIdList = new List<Id>{pfr.Core_MDF_L1_Primary_Approver_Id__c};
                    sendEmailToReviewer.sendDiff = false;
                    inputList.add(sendEmailToReviewer);  
            }
        }
        
        if(inputList != NULL && inputList.size() >0){
            
            Core_MDF_GenericClassToSendMail.sendEmailMethod(inputList);           
            
        }
    }
        /*****************************************************************************************************
Method Name :   notifyCCFDCFExternalReviewer
@return     :   NULL
@parameters :   pfr list 
Description :   Activity Approval Notification to CCF/DCF activity creator only, 
                if the activity was created by external user and now its in pending approval status 
Added By    :   Akilan Murugan
US          :   TWC702-1696 - [CCF/DCF] - Notify Only Activity Submitter for Acceptance
Modified By :                      Date:03/11/2022                     Changes:None
Ayush                             12-18-2024                           Added changes for "Reclaiming SF Partner License"
******************************************************************************************************/    
    public static void notifyCCFDCFExternalReviewer(List<PartnerFundRequest> pfrList){
        
        List<Core_MDF_GenericClassToSendMail.MailParams> inputList = new List<Core_MDF_GenericClassToSendMail.MailParams>(); 
        List<Id> pfrIdList = new List<Id>();
        Map<Id,Boolean> pfrIdToUserActiveMap = new Map<Id,Boolean>();

        //Ayush - getting PFR Id's in a list for quering relationship fields below
        for(PartnerFundRequest pfr : pfrList){
            pfrIdList.add(pfr.Id);
        }
        if(!pfrIdList.isEmpty()){
            //Ayush - quering if createdby user of member user is active or is partner liscence reclaimed and storing in a map of PFRId to boolean.
            for(PartnerFundRequest pfrRecord : [SELECT Id, Core_MDF_Member_Acceptor_Id__r.IsActive, Core_MDF_Member_Acceptor_Id__r.Partner_License_Reclaimed__c 
                                                FROM PartnerFundRequest WHERE Id IN: pfrIdList ]){
                                            if(!pfrIdToUserActiveMap.containsKey(pfrRecord.Id)){
                                                //Avoid Deeply Nested IF Statements
                                                boolean isActiveOrReclaimed = pfrRecord.Core_MDF_Member_Acceptor_Id__r.IsActive || pfrRecord.Core_MDF_Member_Acceptor_Id__r.Partner_License_Reclaimed__c;
                                                                              pfrIdToUserActiveMap.put(pfrRecord.Id, isActiveOrReclaimed);
                                            }
                                        }
        }
        
        for(PartnerFundRequest pfr : pfrList){
            //sending the Acceptance email to CCF/DCF activity creator only, if the activity was created by external user else to the Member Activity Owner 
            //Ayush - Added a contition below to check Activity's Member acceptor is Active or is Manually Deactivated for "Reclaiming SF Partner License"
            if(pfr != NULL && pfr.Core_MDF_Member_Acceptor_Id__c != NULL && (!pfrIdToUserActiveMap.isEmpty() && pfrIdToUserActiveMap.containsKey(pfr.Id) && pfrIdToUserActiveMap.get(pfr.Id) == true)){ 
                Core_MDF_GenericClassToSendMail.MailParams sendEmailToReviewer = new Core_MDF_GenericClassToSendMail.MailParams();
                sendEmailToReviewer.recordId = pfr.Id;
                sendEmailToReviewer.templateName = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ExternalStatusChangeCCFDCF');
                sendEmailToReviewer.userIdList = new List<Id>{pfr.Core_MDF_Member_Acceptor_Id__c};
                sendEmailToReviewer.sendDiff = false;
                inputList.add(sendEmailToReviewer); 
            }
        }
        
        if(inputList != NULL && inputList.size() >0){
            
            Core_MDF_GenericClassToSendMail.sendEmailMethod(inputList);           
            
        }
    }
        
            /*****************************************************************************************************
Method Name :   notifyPCTApprovers
@return     :   NULL
@parameters :   pfr list,accntList,geoList,programList
Description :   Activity Approval Notification to PCT Approvers
Added By    :   Akilan Murugan
US          :   
Modified By :                      Date:03/11/2022                     Changes:None
******************************************************************************************************/    
    public static void notifyPCTApprovers(List<PartnerFundRequest> pfrList, List<String> accntList, List<String> geoList, List<String> programList){
        
        List<Core_MDF_GenericClassToSendMail.MailParams> inputList = new List<Core_MDF_GenericClassToSendMail.MailParams>();      
        Set<Id> userIdSet = new Set<Id>();   
        String pctRole = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Price_Reviewer_Roles');
        String emailTemplate;
        Map<String,Object> emailTemplateMap;
        
        Map<String, Map<String, List<Id>>> resultMap = new Map<String, Map<String, List<Id>>>();
              resultMap = Core_MDF_GeneralPurpose_UI_Utility.getIupgmRecordsPCT(accntList,programList,geoList,pctRole);
        
        Map<String,Object> programNameByRecNameMap = Core_MDF_GeneralPurpose_UI_Utility.getProgramNameByRecName();            
            for(PartnerFundRequest pfr : pfrList){
            string region = pfr.Core_MDF_Host_Region_or_Region_txt__c;//For IPA & !PCT it stores Host Geo, else Transaction geo.
                String program = '';
                Map<string,List<Id>> resultsubMap;
                    if(programNameByRecNameMap.containsKey(pfr.Core_MDF_Program__c)){
                         program = ((String)programNameByRecNameMap.get(pfr.Core_MDF_Program__c));
                }
                List<Id> userIds;
                if(resultMap != null){
                    
                        String allAccountNOKey = program + region + pctRole + pfr.Core_MDF_Ultimate_Account_Id__c;
                        String allAccountNOKeyWW = program + 'WW'+ pctRole + pfr.Core_MDF_Ultimate_Account_Id__c;
                        String allAccountYesKey = program + region + pctRole +'null';
                        String allAccountYesKeyWW = program + 'WW' + pctRole +'null';
                      
                    userIds = new List<Id>();
                    if(resultMap.containsKey('allAccountsYesOrNo')){
                        resultsubMap = resultMap.get('allAccountsYesOrNo');                        
                        for(String key :resultsubMap.keySet()){
                            if(key == allAccountNOKey || key == allAccountNOKeyWW ||
                               key == allAccountYesKey || key == allAccountYesKeyWW){
                                   userIds.addAll(resultsubMap.get(Key));
                               }
                        }
                    }else if(resultMap.containsKey('allAccountsYes')){                        
                        resultsubMap = resultMap.get('allAccountsYes');
                        for(String key :resultsubMap.keySet()){
                            if(key == allAccountYesKey || key == allAccountYesKeyWW){
                                   userIds.addAll(resultsubMap.get(Key));
                               }
                        }
                    }else if(resultMap.containsKey('allAccountsNO')){
                        resultsubMap = resultMap.get('allAccountsNO');
                        for(String key :resultsubMap.keySet()){
                            if(key == allAccountNOKey || key == allAccountNOKeyWW){
                                   userIds.addAll(resultsubMap.get(Key));
                               }
                        }
                    }
                }

                 if(pfr.Core_MDF_Program__c == 'Intel Partner Alliance' && pfr.Core_MDF_Proposal_Based_Ind__c != true)
                     {
                         emailTemplateMap = getTemplateNameByProgNameIPA();
                     }
                else
                    {
                        emailTemplateMap = getTemplateNameByProgName();
                    }

                if(!emailTemplateMap.isEmpty() && emailTemplateMap.containsKey(pfr.Core_MDF_Program__c)){
                          emailTemplate = (String)emailTemplateMap.get(pfr.Core_MDF_Program__c);
                   }

                if(userIds != NULL && !userIds.isEmpty()){
                    Core_MDF_GenericClassToSendMail.MailParams sendEmailToPRCReviewer = new Core_MDF_GenericClassToSendMail.MailParams();
                    sendEmailToPRCReviewer.recordId = pfr.Id;
                    sendEmailToPRCReviewer.templateName = emailTemplate;
                    sendEmailToPRCReviewer.userIdList = userIds;
                    sendEmailToPRCReviewer.sendDiff = false;
                    inputList.add(sendEmailToPRCReviewer);                    
                }
                
            }
        
        if(inputList != NULL && inputList.size() >0 ){
            
            Core_MDF_GenericClassToSendMail.sendEmailMethod(inputList); 
            
        }
    }
        /*****************************************************************************************************
Method Name :   notifyApprovers
@return     :   NULL
@parameters :   pfr list 
Description :   Activity Approval Notification to  Approvers
Added By    :   Harshadeep Kalita
US          :   
Modified By :                      Date:21/06/2022                     Changes:None
******************************************************************************************************/    
    public static void notifyApprovers(List<PartnerFundRequest> pfrList, List<String> accntList, List<String> geoList, List<String> programList,
                                      List<String> approvalStageStatusList,List<String> budgetTypeList){
        //Akash - Added condidtion below code for KIIT metadata.
        List<String> programname = new List<String>();
        Map<String,Object> programNameByRecoNameMap = Core_MDF_GeneralPurpose_UI_Utility.getProgramNameByRecName();
        for(String prgm : programList){
            if(programNameByRecoNameMap.containsKey(prgm)){
                programname.add((String)programNameByRecoNameMap.get(prgm));
            }
        }                                
        List<Core_MDF_GenericClassToSendMail.MailParams> inputList = new List<Core_MDF_GenericClassToSendMail.MailParams>();      
        Set<Id> userIdSet = new Set<Id>();   
        List<String> roleList = new List<String>();  
        Map<String, String> approvalStageToRoleMap = new Map<String, String>();
        Map<String, String> programToEmailTemplateMap = new Map<String, String>();                                  
       
        Map<String,string> roleCheckforAccountAccessMap = new Map<String,string>();
        String emailTemplate;                                  
        String actClassification;                                 
        String category ='notifyIUPGMBasedNotification';
        String categoryGeneralUtility = 'Core_MDF_GeneralPurpose_UI_Utility_Role_Mappings';                                                                    
        List<Core_MDF_Custom_Label_Configration__mdt> mdtRecList = [SELECT DeveloperName, Core_MDF_Value_Txt__c, Core_MDF_Value2_Txt__c,
                                                                    Core_MDF_Value3_Txt__c,Core_MDF_Value4_Txt__c, Core_MDF_Category_Txt__c, 
                                                                    Core_MDF_Org_Specific_Ind__c,Core_MDF_Value5_Txt__c
                                                                    FROM Core_MDF_Custom_Label_Configration__mdt 
                                                                    WHERE Core_MDF_Category_Txt__c =: category 
                                                                    AND Core_MDF_Value3_Txt__c IN:approvalStageStatusList 
                                                                    AND Core_MDF_Value_Txt__c IN:programname AND (Core_MDF_Value5_Txt__c IN:budgetTypeList OR Core_MDF_Value5_Txt__c=null OR Core_MDF_Value5_Txt__c='Account Based')];                              
        for(Core_MDF_Custom_Label_Configration__mdt meta: mdtRecList){
            roleList.add(meta.Core_MDF_Value4_Txt__c);
            programToEmailTemplateMap.put(meta.Core_MDF_Value_Txt__c,meta.Core_MDF_Value2_Txt__c);
            
            if(!String.isBlank(meta.Core_MDF_Value5_Txt__c) && meta.Core_MDF_Value5_Txt__c!='Account Based'){
                approvalStageToRoleMap.put(meta.Core_MDF_Value_Txt__c+meta.Core_MDF_Value5_Txt__c+meta.Core_MDF_Value3_Txt__c, meta.Core_MDF_Value4_Txt__c);    
            }else{
                approvalStageToRoleMap.put(meta.Core_MDF_Value_Txt__c+meta.Core_MDF_Value3_Txt__c, meta.Core_MDF_Value4_Txt__c);    
            }
            
        }    
                                               
        
        List<Core_MDF_Custom_Label_Configration__mdt> mdtAccountRecList =  [SELECT DeveloperName, Core_MDF_Value_Txt__c,Core_MDF_Value2_Txt__c,Core_MDF_Value3_Txt__c,
                                                                            Core_MDF_Value4_Txt__c,Core_MDF_Category_Txt__c, Core_MDF_Org_Specific_Ind__c
                                                                            FROM Core_MDF_Custom_Label_Configration__mdt WHERE Core_MDF_Category_Txt__c =: categoryGeneralUtility
                                                                            AND Core_MDF_Value_Txt__c IN: programname AND Core_MDF_Value2_Txt__c IN: roleList]; 
        for(Core_MDF_Custom_Label_Configration__mdt mdtRec: mdtAccountRecList){
            roleCheckforAccountAccessMap.put(mdtRec.Core_MDF_Value_Txt__c+mdtRec.Core_MDF_Value2_Txt__c,mdtRec.Core_MDF_Value3_Txt__c);
        }       

        Map<String, Map<String, List<Id>>> resultMap = new Map<String, Map<String, List<Id>>>();
       
        resultMap = Core_MDF_GeneralPurpose_UI_Utility.getIupgmForApproversWithBudgetType(accntList,programList,geoList,roleList,budgetTypeList,approvalStageStatusList);
                     
        Map<String,Object> programNameByRecNameMap = Core_MDF_GeneralPurpose_UI_Utility.getProgramNameByRecName(); 

            for(PartnerFundRequest pfr : pfrList){
        //Akash - Latest Changes for KIIT
                String program = '';
                String ultimateAccId = '';
                Map<string, List<Id>> resultsubMap;
                    if(programNameByRecNameMap.containsKey(pfr.Core_MDF_Program__c)){
                         program = ((String)programNameByRecNameMap.get(pfr.Core_MDF_Program__c));   
                }
                                       
                String region = (String.isNotBlank(pfr.Core_MDF_Host_Region_txt__c)) ? pfr.Core_MDF_Host_Region_txt__c : pfr.Core_MDF_Region_nm__c;
                String approvalMapKey = program+pfr.Core_MDF_Budget_Type_nm__c+pfr.Core_MDF_Approval_Stage__c;
                String approvalMapKeyWithoutBudgetType = program+pfr.Core_MDF_Approval_Stage__c;
                                       
                List<Id> userIds;
                if(resultMap != null){
                    String role ='';
                    if(approvalStageToRoleMap.containsKey(approvalMapKey)){
                      role = approvalStageToRoleMap.get(approvalMapKey);  
                    }else{
                      role = approvalStageToRoleMap.get(approvalMapKeyWithoutBudgetType);    
                    }
                        if(program == Core_MDF_CCP_ConstantClass.EEF_PROGRAM 
                            && pfr.Core_MDF_Approval_Stage__c == Core_MDF_CCP_ConstantClass.L2_PRIMARY_APPROVAL){
                            ultimateAccId = pfr.Core_MDF_Campaign_Ultimate_Account_Id__c;
                        } else {
                            ultimateAccId = pfr.Core_MDF_Ultimate_Account_Id__c;
                        }
                    
                    String roleCheckforAccountKey = program+role;

                    String accountAccess = roleCheckforAccountAccessMap.get(roleCheckforAccountKey);
                   

                        String allAccountNOKey = program + region + role + ultimateAccId;
                        String allAccountNOKeyWW = program +'WW'+ role + ultimateAccId;
                        String allAccountYesKey = program + region + role +'null';
                        String allAccountYesKeyWW = program + 'WW' + role +'null';
                        String allAccountNOKeyWithBT = program + region +pfr.Core_MDF_Budget_Type_nm__c + role + ultimateAccId;
                        String allAccountYesKeyWithBT = program + region + pfr.Core_MDF_Budget_Type_nm__c + role + 'null';
                        userIds = new List<Id>();
                            if(Core_MDF_CCP_ConstantClass.stageToClassificationMap.containsKey(pfr.Core_MDF_Approval_Stage__c)){
                                actClassification = Core_MDF_CCP_ConstantClass.stageToClassificationMap.get(pfr.Core_MDF_Approval_Stage__c);
                                allAccountNOKey += actClassification;
                                allAccountNOKeyWW += actClassification;
                                allAccountYesKey  += actClassification;
                                allAccountYesKeyWW += actClassification;
                                allAccountNOKeyWithBT += actClassification;
                                allAccountYesKeyWithBT += actClassification;
                            }
   
                    if(resultMap.containsKey(role) && accountAccess=='allAccountsYesOrNo'){
                        resultsubMap = resultMap.get(role);                        
                        for(String key :resultsubMap.keySet()){
                            if(key == allAccountNOKey || key == allAccountNOKeyWW ||
                                key == allAccountYesKey || key == allAccountYesKeyWW ||
                                key  == allAccountNOKeyWithBT || key == allAccountYesKeyWithBT){
                                   userIds.addAll(resultsubMap.get(Key));
                               }
                        }
                    }else if(resultMap.containsKey(role) && accountAccess=='allAccountsYes'){
                      
                        resultsubMap = resultMap.get(role);
                        for(String key :resultsubMap.keySet()){
                                if(key == allAccountYesKey || key == allAccountYesKeyWW ||key == allAccountYesKeyWithBT ){
                                   userIds.addAll(resultsubMap.get(Key));
                               }
                        }
                    }else if(resultMap.containsKey(role) && accountAccess=='allAccountsNo'){
                        resultsubMap = resultMap.get(role);

                        for(String key :resultsubMap.keySet()){
                                if(key == allAccountNOKey || key == allAccountNOKeyWW  || key  == allAccountNOKeyWithBT){
                                   userIds.addAll(resultsubMap.get(Key));
                               }
                        }
                    }
                }
                if(programToEmailTemplateMap.containsKey(program)){
                    emailTemplate = programToEmailTemplateMap.get(program);
                }
                
               
                
                if(userIds != NULL && !userIds.isEmpty()){
                    Core_MDF_GenericClassToSendMail.MailParams sendEmailToPRCReviewer = new Core_MDF_GenericClassToSendMail.MailParams();
                    sendEmailToPRCReviewer.recordId = pfr.Id;
                  
                    sendEmailToPRCReviewer.templateName = emailTemplate;
                    sendEmailToPRCReviewer.userIdList = userIds;
                    sendEmailToPRCReviewer.sendDiff = false;
                    inputList.add(sendEmailToPRCReviewer);
                    
                }
                
            }
        
        if(inputList != NULL && inputList.size() >0 && sendEmailOnce){
            
            Core_MDF_GenericClassToSendMail.sendEmailMethod(inputList); 
            sendEmailOnce = false;
        }
    }    
    public static void notifyExternalReviewers(List<PartnerFundRequest> pfrList, Set<Id> accIdSet){
        
        Map<Id,Set<Id>> accIdUserIdSetMap = new Map<Id,Set<Id>>();
        Set<Id> userIdSet = new Set<Id>();
        
        if(accIdSet != NULL && accIdSet.Size() > 0){
            //Ayush - Added Partner_License_Reclaimed__c in where clause for "Reclaiming SF Partner License"
            for(Core_MDF_Partner_Node_User_Mapping__c pnum : [SELECT Id,Core_MDF_Account__c, Core_MDF_User__c 
                                                              FROM Core_MDF_Partner_Node_User_Mapping__c 
                                                                WHERE Core_MDF_Account__c IN : accIdSet 
                                                                AND Core_MDF_Active_Ind__c = TRUE
                                                                AND (Core_MDF_User__r.IsActive = TRUE OR Core_MDF_User__r.Partner_License_Reclaimed__c = TRUE)]){                
                                                                  if(accIdUserIdSetMap.containsKey(pnum.Core_MDF_Account__c)){
                                                                      accIdUserIdSetMap.get(pnum.Core_MDF_Account__c).add(pnum.Core_MDF_User__c);
                                                                  }else{
                                                                      accIdUserIdSetMap.put(pnum.Core_MDF_Account__c, new Set<Id> {pnum.Core_MDF_User__c});
                                                                  }
                                                                  userIdSet.add(pnum.Core_MDF_User__c);
                                                              }
            //PRC MS User
            for(Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm : [SELECT Id,Core_MDF_Account_id__c,Core_MDF_User_id__c,Core_MDF_Active_Ind__c,Core_MDF_Account_id__r.Name
                                                                   FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c
                                                                   WHERE Core_MDF_Account_id__c  IN: accIdSet AND 
                                                                   Core_MDF_is_User_Active_ind__c = TRUE AND
                                                                   Core_MDF_Active_Ind__c = TRUE AND
                                                                   Core_MDF_Role_nm__c =: Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CCP_RMF_PRC_Claim_Operations')]){ 
                                                                       
                                                                       if(accIdUserIdSetMap.containsKey(iupgm.Core_MDF_Account_id__c)){
                                                                           accIdUserIdSetMap.get(iupgm.Core_MDF_Account_id__c).add(iupgm.Core_MDF_User_id__c);
                                                                       }else{
                                                                           accIdUserIdSetMap.put(iupgm.Core_MDF_Account_id__c, new Set<Id> {iupgm.Core_MDF_User_id__c});
                                                                       }
                                                                       userIdSet.add(iupgm.Core_MDF_User_id__c);
                                                                   }   
            
            
        }
        
        Set<Id> userWithReqdPermissionSet = new Set<Id>();
        Set<Id> userWithClaimPermissionSet = new Set<Id>();
        Set<Id> userWithPRCClaimOperationPermissionSet = new Set<Id>();     
        if(userIdSet != NULL  && userIdSet.size() > 0){
            // EOL - Commented below OR condition associated to Channel MDF
            for(PermissionSetAssignment usrPer : [SELECT Id, AssigneeId, Assignee.AccountId, Assignee.IsActive, PermissionSet.Name 
                                                  FROM PermissionSetAssignment WHERE AssigneeId IN :userIdSet 
                                                  AND (PermissionSet.Name =: Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CCP_External_Activity_Approver')
                                                       OR PermissionSet.Name =: Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CCP_External_Activity_Submitter')
                                                       OR PermissionSet.Name =: Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CCP_Ext_RMF_Claim_Submitter')  
                                                       OR PermissionSet.Name =: Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CCP_RMF_PRC_Claim_Operations') 
                                                      
                                                       OR PermissionSet.Name =: Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_External_IPA_Activity_Manager') 
                                                        OR PermissionSet.Name =: Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_EEF_Primary_Partner_User'))]){ 
                                                           
                                                           if(usrPer.PermissionSet.Name == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CCP_External_Activity_Approver') 
                                                              ||  usrPer.PermissionSet.Name == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CCP_External_Activity_Submitter')                                                              
                                                         
                                                              || usrPer.PermissionSet.Name == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_External_IPA_Activity_Manager')
                                                                || usrPer.PermissionSet.Name == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_EEF_Primary_Partner_User')){
                                                                 userWithReqdPermissionSet.add(usrPer.AssigneeId);
                                                             }
                                                           
                                                               if(usrPer.PermissionSet.Name == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CCP_Ext_RMF_Claim_Submitter')|| 
                                                                  usrPer.PermissionSet.Name == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CCP_External_Activity_Approver'))
                                                                  {
                                                                      userWithClaimPermissionSet.add(usrPer.AssigneeId);
                                                                  }
                                                           if( usrPer.PermissionSet.Name == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CCP_RMF_PRC_Claim_Operations')){
                                                               userWithPRCClaimOperationPermissionSet.add(usrPer.AssigneeId);
                                                           }
                                                          
                                                       }
        }
        
        
        List<Core_MDF_GenericClassToSendMail.MailParams> inputList = new List<Core_MDF_GenericClassToSendMail.MailParams>();
        
        for(PartnerFundRequest pfr : pfrList){
            
            Set<Id> userFinalPermissionSet = new Set<Id>();
            If(pfr.Core_MDF_Fund_Request_Status__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CCP_Planned_Status') ) { 
               userFinalPermissionSet = userWithClaimPermissionSet;
            }
            //Ramapriya -Added In-Progress Pending Approval Status Check
            else if((pfr.Core_MDF_Fund_Request_Status__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Status_Pending_Approval_Nm') || pfr.Core_MDF_Fund_Request_Status__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_InProgress_Pending_Approval') ) ) { 
                userFinalPermissionSet = userWithReqdPermissionSet;
                }
            
           
            if(accIdSet.contains(pfr.ChannelPartnerId) && accIdUserIdSetMap.containsKey(pfr.ChannelPartnerId) && 
               accIdUserIdSetMap.get(pfr.ChannelPartnerId) != NULL){                
                   for(Id userId : accIdUserIdSetMap.get(pfr.ChannelPartnerId)){
                       if(pfr.Core_MDF_Program__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Retail_Program_Name') && 
                       userFinalPermissionSet.contains(userId)){
                           Core_MDF_GenericClassToSendMail.MailParams sendEmailToReviewer = new Core_MDF_GenericClassToSendMail.MailParams();
                           sendEmailToReviewer.recordId = pfr.Id;
                          
                           sendEmailToReviewer.templateName = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Notify_RMF_User');
                           sendEmailToReviewer.userIdList = new List<Id>{userId};
                               sendEmailToReviewer.sendDiff = false;
                           inputList.add(sendEmailToReviewer);                        
                       }
                       //prc
                       if(pfr.Core_MDF_Fund_Request_Status__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CCP_Planned_Status')&&
                          userWithPRCClaimOperationPermissionSet.contains(userId)){
                           Core_MDF_GenericClassToSendMail.MailParams sendEmailToPRCReviewer = new Core_MDF_GenericClassToSendMail.MailParams();
                           sendEmailToPRCReviewer.recordId = pfr.Id;
                           sendEmailToPRCReviewer.templateName = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Notify_Internal_RMF_User');
                           sendEmailToPRCReviewer.userIdList = new List<Id>{userId};
                           sendEmailToPRCReviewer.sendDiff = false;
                           inputList.add(sendEmailToPRCReviewer);                        
                       }
                       //prc
                       //TWC702-760
                       
                       if((Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CCF_Program_Name').equals(pfr.Core_MDF_Program__c) || 
                          Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_DCF_Program_Name').equals(pfr.Core_MDF_Program__c) || 
                           (( Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_PFR_IPA').equals(pfr.Core_MDF_Program__c)) && pfr.Core_MDF_Proposal_Based_Ind__c == false)) &&
                          userFinalPermissionSet.contains(userId)){  
                              String templateName = (pfr.Core_MDF_Program__c == 'Intel Partner Alliance') ? Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Notify_IPAAccountBased'): Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ExternalStatusChangeCCFDCF'); 
                              Core_MDF_GenericClassToSendMail.MailParams sendEmailToExternalUser = new Core_MDF_GenericClassToSendMail.MailParams();
                              sendEmailToExternalUser.recordId = pfr.Id;
                              sendEmailToExternalUser.templateName = templateName;
                              sendEmailToExternalUser.userIdList = new List<Id>{userId};
                                  sendEmailToExternalUser.sendDiff = false;
                              inputList.add(sendEmailToExternalUser);
                              
                          }
                   }
               }
                // For EEF External Primary Partner 
            if(pfr.Core_MDF_Program__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_EEF_Program_Name')
                   && accIdSet.contains(pfr.Core_MDF_Campaign_Account_Id__c) && accIdUserIdSetMap.containsKey(pfr.Core_MDF_Campaign_Account_Id__c) 
                    && accIdUserIdSetMap.get(pfr.Core_MDF_Campaign_Account_Id__c) != NULL){
                        for(Id userId : accIdUserIdSetMap.get(pfr.Core_MDF_Campaign_Account_Id__c)){
                            if(userFinalPermissionSet.contains(userId)){
                                String templateName = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ExternalStatusChangeCCFDCF'); 
                                Core_MDF_GenericClassToSendMail.MailParams sendEmailToExternalUser = new Core_MDF_GenericClassToSendMail.MailParams();
                                sendEmailToExternalUser.recordId = pfr.Id;
                                sendEmailToExternalUser.templateName = templateName;
                                sendEmailToExternalUser.userIdList = new List<Id>{userId};
                                sendEmailToExternalUser.sendDiff = false;
                                inputList.add(sendEmailToExternalUser);
                            }
                        }
                }
            
        }
            if(inputList != NULL && inputList.size() >0 && sendEmailOnce){
                Core_MDF_GenericClassToSendMail.sendEmailMethod(inputList);
                sendEmailOnce = false;
            } 
        
}
    
    
    
    /*****************************************************************************************************************************************
Method Name:                                             recallApprovalProcess
@return  :                                               return boolean
@parameters:                                             PFR List to be recalled , pfr Old Map
Description:                                             All the cancel activities should be recalled to prevent Approve/Reject action.
Modifies :                         Added code to recall the Approval Process when Activity is closed.

**************************************************************************************************************************************************/
    //Remove Approval lock on Activities
    public static boolean RemoveApprovalLock(List<PartnerFundRequest> pfrList)
    {           
        boolean result = false;
        
        try{
            if(pfrList != NULL && !pfrList.isEmpty()){
                List<Approval.UnlockResult> ulrList = Approval.unlock(pfrList, false);for(Approval.UnlockResult ulr:ulrList){if(ulr.isSuccess()) result = true;}
            }
            
        }
        catch(exception ex){            logEntryMsg = Core_MDF_CCP_UtilityClass.getErrorDetails(ex); Core_MDF_CCP_UtilityClass.logErrorinLogObject(logEntryMsg,Label.Core_MDF_Activity_Recall_Exception_Origin);   
                            
                           } 
        
        return result;
    }
    
    /***************************************************************************************************** 
Method Name   :        publishActivityPlatformEvent
@return       :        void
@parameters   :        
Description   :            
Added By      :        HA
Modified By   :        Date:          Changes: 
Ayush                  11.04.2025     Added NRE check
Ramapriya              25.07.2025     Added status check for In-Progress Activity edit
******************************************************************************************************/
public static void publishActivityPlatformEvent(List<PartnerFundRequest> newPFRList, Map<Id,PartnerFundRequest> oldPfrMap){        
    List<Activity_Status_Changed__e> newEventList = new List<Activity_Status_Changed__e>();
    //Map of channel program meta data
    Map<String,String> mapOfChannelProgram = new Map<String,String>();
    //Existing channel program meta data
  
for(Core_MDF_ChannelProgram__mdt cp : [SELECT Label,Core_MDF_Technical_Program_Name__c 
                                       FROM Core_MDF_ChannelProgram__mdt 
                                       WHERE Core_MDF_Technical_Program_Name__c =: IPA_PROG OR Core_MDF_Technical_Program_Name__c =: Co_GTM_Tech_PROG]){
        //String key = cp.Core_MDF_Technical_Program_Name__c == 'CoGTM' ? cp.Label : cp.Core_MDF_Technical_Program_Name__c;
        mapOfChannelProgram.put(cp.Label, cp.Label);
                                       }
    //Akash - Modidfied below If Condition
    if (newPFRList != NULL && newPFRList.size() > 0) {
        for(PartnerFundRequest pfr: newPFRList){
            boolean isCreateScenario = oldPfrMap == null || !oldPfrMap.containsKey(pfr.Id);
            boolean isEditScenario = oldPfrMap != null && oldPfrMap.containsKey(pfr.Id);

            // Check if program is IPA and activity status is Revision Required or In-progress
            if(mapOfChannelProgram != NULL && mapOfChannelProgram.size() > 0 && (mapOfChannelProgram.containsKey(pfr.Core_MDF_Program__c) && pfr.Core_MDF_Proposal_Based_Ind__c == true)){
                if (isCreateScenario && pfr.Core_MDF_Program__c == Co_GTM_PROG &&
                    (pfr.Core_MDF_Fund_Request_Status__c == Label.Core_MDF_PFR_Status_RevisionRequired)) {
                   Activity_Status_Changed__e  activityEvent = new Activity_Status_Changed__e(
                        Core_MDF_Activity_Id_txt__c = pfr.Id,
                        Core_MDF_Activity_Status_txt__c = pfr.Core_MDF_Fund_Request_Status__c,
                        Core_MDF_Campaign_Id_txt__c = pfr.CampaignId,
                        Core_MDF_Program_txt__c = mapOfChannelProgram.get(pfr.Core_MDF_Program__c) + ';'
                    );
                    newEventList.add(activityEvent);
                } else if (isEditScenario && 
                           oldPfrMap.get(pfr.Id).Core_MDF_Fund_Request_Status__c != pfr.Core_MDF_Fund_Request_Status__c &&
                           (pfr.Core_MDF_Fund_Request_Status__c == Label.Core_MDF_PFR_Status_RevisionRequired || 
                            pfr.Core_MDF_Fund_Request_Status__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_pfrInprogress') || 
                            pfr.Core_MDF_Fund_Request_Status__c == Label.Core_MDF_PFR_In_Progress_Revision_Required)) {
                    Activity_Status_Changed__e activityEvent = new Activity_Status_Changed__e(
                        Core_MDF_Activity_Id_txt__c = pfr.Id, 
                        Core_MDF_Activity_Status_txt__c = pfr.Core_MDF_Fund_Request_Status__c,
                        Core_MDF_Campaign_Id_txt__c = pfr.CampaignId,
                        Core_MDF_Program_txt__c = mapOfChannelProgram.get(pfr.Core_MDF_Program__c) 
                    );
                    newEventList.add(activityEvent);
                }
               }               
        }
        // Call method to publish events
        List<Database.SaveResult> results = EventBus.publish(newEventList);
        // Inspect publishing result for each event
        Integer eventListIndex = 0;
        for (Database.SaveResult sr : results) {
            if (!sr.isSuccess()) {  for(Database.Error err : sr.getErrors()) {  Core_MDF_CCP_UtilityClass.logErrorinLogObject(err.getMessage(),'Failed to publish event for ' + newEventList[eventListIndex].Core_MDF_Activity_Id_txt__c + ' related to ' +  newEventList[eventListIndex].Core_MDF_Campaign_Id_txt__c + ' tagged to ' +  newEventList[eventListIndex].Core_MDF_Program_txt__c + '.');}
                                 } 
            eventListIndex++;
        }
    }        
}
    
    /***************************************************************************************************** 
Method Name   :        shareActivityWithUsers
@return       :        void
@parameters   :        Map<Id,PartnerFundRequest> from Trigger.newMap
Description   :        Calls the Core_MDF_GeoBasedGenericSharing class to create sharing with geo based groups
Added By      :        Accenture - VK - 08/05/2019
Modified By   :        Date:          Changes: 
Shivaprasad            08/29/2019     Added condition to check closed status PFR records to avoid unnecessary excecution.
******************************************************************************************************/
    public static void shareActivityWithUsers(Map<Id,PartnerFundRequest> activityMap){
        list<Id> pfrIdList = new list<Id>();
        Set<Id> activityIdSet = new Set<Id>();
        
        for(PartnerFundRequest pfr: activityMap.values()){
            //Akash changes
            if(pfr.Core_MDF_Activity_Level_nm__c != 'Sub Activity') {
                pfrIdList.add(pfr.Id);
            }
            
        }
        
        
        if(pfrIdList.size() > 0){
            Core_MDF_GeoBasedGenericSharing.checkObjectAndPgm('PartnerFundRequest', pfrIdList);
        }
        
        
    }
    
    /***************************************************************************************************** 
Method Name   :        shareActivityWithInternalUsers
@return       :        void
@parameters   :        Map<Id,PartnerFundRequest> from Trigger.newMap
Map<Id,PartnerFundRequest> from Trigger.oldMap
Description   :        Checks if the Account/Owner/Country is updated
Added By      :        Accenture - VK - 08/05/2019
Modified By   :        Date:          Changes: 
Shivaprasad            08/29/2019     Added condition to check closed status PFR records to avoid unnecessary excecution.
******************************************************************************************************/
    public static void shareActivityWithInternalUsers(Map<Id,PartnerFundRequest> oldActivityMap, Map<Id,PartnerFundRequest> newActivityMap){
        //Processing closed activities unnecessarily
    // Early return when all activities are CLOSED
        if(oldActivityMap == null || newActivityMap == null || newActivityMap.isEmpty()) {
            return;
        }
        
        // Skip sharing operations for activities being closed (batch closure optimization)
        boolean hasActiveChanges = false;
        for(PartnerFundRequest pfr : newActivityMap.values()) {
            if(pfr.Core_MDF_Fund_Request_Status__c != 'Closed') {
                hasActiveChanges = true;
                break;
            }
        }
        if(!hasActiveChanges) { return; }
        
        

        Map<Id,PartnerFundRequest> updatedActivityMap = new Map<Id,PartnerFundRequest>();
       
        Set<String> accountIdProgramIdGeoSubGeoStringSet = new Set<String>();
        Set<String> accountIdProgramIdGeoStringSet = new Set<String>();
        Set<Id> accountIdSet = new Set<Id>();
        Set<String> programStrSet = new Set<String>();
        Set<Id> programIdSet = new Set<Id>();
        Set<Id> groupIdSet = new Set<Id>();
        Set<String> groupRORWIdSet = new Set<String>();
        Set<String> geoStringSet = new Set<String>();
        Set<Id> oldAccountIdSet = new Set<Id>();
        Map<Id, Account> oldAccountMap = new Map<Id, Account>();
        Map<Id, Id> pfrIdAccountIdMap = new Map<Id, Id>();
        Map<Id, Id> pfrIdOldAccountIdMap = new Map<Id, Id>();
        
        
        for(PartnerFundRequest pfr : oldActivityMap.values()){
            oldAccountIdSet.add(pfr.ChannelPartnerId);
            pfrIdAccountIdMap.put(pfr.Id, pfr.ChannelPartnerId);
            //if Account has been Changed
            if(pfr.ChannelPartnerId != newActivityMap.get(pfr.Id).ChannelPartnerId){
                pfrIdOldAccountIdMap.put(pfr.Id, pfr.ChannelPartnerId);
            }
        }
        oldAccountMap = new Map<Id, Account> ([SELECT Id, Core_MDF_CoMarketing_Ultimate_Account__c, Core_MDF_Channel_Program__c, Core_MDF_Group_Id__c
                                               FROM Account
                                               WHERE Id IN :oldAccountIdSet]);
        
        //Call the method to delete the PFRShare for old records
        if(pfrIdOldAccountIdMap != NULL && !pfrIdOldAccountIdMap.isEmpty()){
            deletePFRShare(pfrIdOldAccountIdMap, oldAccountMap);
        }
        
        
        String region = '';
        String subRegion = '';
        string Region_sub='';
        string Old_region_sub='';
        string new_region_sub='';
        string new_regn_sub='';
        //Put one Map instead of 3 Maps
       System.debug('map size===='+newActivityMap.size());
        //US1098882//// Execute query ONCE before loop (gets all 200 records)
        List<PartnerFundRequest> pfrQueryList = [SELECT Id, ChannelPartnerId,Core_MDF_Program__c, ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c,Core_MDF_Region_nm__c,
                                      ChannelPartner.Core_MDF_Channel_Program__c,ChannelPartner.Core_MDF_Channel_Program__r.Name,Core_MDF_Sub_Region_nm__c,
                                      ChannelPartner.Core_MDF_Group_Id__c, ChannelPartner.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c
                                      FROM PartnerFundRequest WHERE Id IN :newActivityMap.keySet()];
          System.debug('map size====count');                            
        //Convert to Map for instant lookups
        Map<Id, PartnerFundRequest> pfrQueryMap = new Map<Id, PartnerFundRequest>(pfrQueryList);
        
        for(PartnerFundRequest pfr : pfrQueryList){
                                          accountIdSet.add(oldAccountMap.get(pfrIdAccountIdMap.get(pfr.Id)).Core_MDF_CoMarketing_Ultimate_Account__c);
                                          programIdSet.add(oldAccountMap.get(pfrIdAccountIdMap.get(pfr.Id)).Core_MDF_Channel_Program__c);
                                          programStrSet.add(oldActivityMap.get(pfr.Id).Core_MDF_Program__c);
                                          
                                          
                                          List<String> oldRegions = new List<String>();
                                          if(oldActivityMap.get(pfr.Id).Core_MDF_Region_nm__c != null){
                                              oldRegions = oldActivityMap.get(pfr.Id).Core_MDF_Region_nm__c.split(';');
                                          }
                                          if(!oldRegions.isEmpty()){
                                              geoStringSet.addAll(oldRegions);
                                          }
                                          
                                          
  
                                              //US1098882
                                              
                                              geoStringSet.add(oldActivityMap.get(pfr.Id).Core_MDF_Region_nm__c);
                                              
                                              //Populate a String of Account + ProgramId + Geo + SubRegion(If Applicable) to delete old share records
                                              
                                              //US1098882
                                              if(oldActivityMap.get(pfr.Id).Core_MDF_Sub_Region_nm__c != NULL){
                                                  //US1098882
    
                                                  String accountIdProgramIdGeoSubGeo = (String)oldAccountMap.get(pfrIdAccountIdMap.get(pfr.Id)).Core_MDF_CoMarketing_Ultimate_Account__c + (String)oldAccountMap.get(pfrIdAccountIdMap.get(pfr.Id)).Core_MDF_Channel_Program__c + oldActivityMap.get(pfr.Id).Core_MDF_Region_nm__c + oldActivityMap.get(pfr.Id).Core_MDF_Sub_Region_nm__c;

                                                  
                                                  accountIdProgramIdGeoSubGeoStringSet.add(accountIdProgramIdGeoSubGeo);
                                                  
                                              }
                                              else{
                                                  //US1098882
                                                  
                                                  String accountIdProgramIdGeo = (String)oldAccountMap.get(pfrIdAccountIdMap.get(pfr.Id)).Core_MDF_CoMarketing_Ultimate_Account__c + (String)oldAccountMap.get(pfrIdAccountIdMap.get(pfr.Id)).Core_MDF_Channel_Program__c + oldActivityMap.get(pfr.Id).Core_MDF_Region_nm__c;
                                                  
                                                  accountIdProgramIdGeoStringSet.add(accountIdProgramIdGeo);
                                              }
                                              
                                              //Check if change in program/Geo/Sub-Region/BudgetType for re-trigger sharing 
                                              //US949836 : New Budget Type field changes replaced txt field with new global picklist field
                                              //US1098882: Replace Core_MDF_Region_cd__c with Core_MDF_Region_nm__c && Core_MDF_Sub_Region_cd__c with Core_MDF_Sub_Region_nm__c 
                                              if((oldActivityMap.get(pfr.Id).RecordTypeId != newActivityMap.get(pfr.Id).RecordTypeId)|| //Program
                                                 (oldActivityMap.get(pfr.Id).Core_MDF_Region_nm__c != newActivityMap.get(pfr.Id).Core_MDF_Region_nm__c) ||//Geo
                                                 (
                                                     (oldActivityMap.get(pfr.Id).Core_MDF_Sub_Region_nm__c != NULL || newActivityMap.get(pfr.Id).Core_MDF_Sub_Region_nm__c != NULL) && //Subgeo
                                                     oldActivityMap.get(pfr.Id).Core_MDF_Sub_Region_nm__c != newActivityMap.get(pfr.Id).Core_MDF_Sub_Region_nm__c
                                                 ) || //Budget Type 
                                                 (
                                                     (oldActivityMap.get(pfr.Id).Core_MDF_Budget_Type_nm__c != NULL || newActivityMap.get(pfr.Id).Core_MDF_Budget_Type_nm__c != NULL) && 
                                                     (oldActivityMap.get(pfr.Id).Core_MDF_Budget_Type_nm__c != newActivityMap.get(pfr.Id).Core_MDF_Budget_Type_nm__c)
                                                 )
                                                ){
                                                    updatedActivityMap.put(pfr.Id,newActivityMap.get(pfr.Id));
                                                }
                                              //Check if change in Account/Owner for re-trigger sharing 
                                              if((oldActivityMap.get(pfr.Id).OwnerId != newActivityMap.get(pfr.Id).OwnerId) || //Owner
                                                 (pfrIdAccountIdMap.get(pfr.Id) != newActivityMap.get(pfr.Id).ChannelPartnerId)){ //Account
                                                     updatedActivityMap.put(pfr.Id,newActivityMap.get(pfr.Id));
                                                     /*if owner/account changes - prepare the objId grp id map to create share records 
* objectIdUserGroupIdListMap is merged into Core_MDF_CCP_GenericUtility.createShareRecordsForInternal 
*/
                                                     if(Core_MDF_shareRecordToAccountGroup.isNodeBasedSharingReqd(pfr.ChannelPartner.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c)){
                                                         objectIdUserGroupIdListMap.put(pfr.Id, new List<Id>{pfr.ChannelPartner.Core_MDF_Group_Id__c});
                                                     }                
                                                 }
                                         
                                      }//End of PFR for loop
        
       
        
        //Fetch the RO share groups from metadata to delete Old RO share records
        for(Core_MDF_ProgramGeoGroupMap__mdt programGeoMap :[SELECT Core_MDF_Program__c, Core_MDF_Region__c,Core_MDF_Sub_Region__c,Core_MDF_Group_Name_RO__c,Core_MDF_Group_Name__c
                                                             FROM Core_MDF_ProgramGeoGroupMap__mdt
                                                             WHERE Core_MDF_Program__c IN  :programStrSet
                                                             AND Core_MDF_Region__c IN :geoStringSet]){
                                                                 groupRORWIdSet.add(programGeoMap.Core_MDF_Group_Name_RO__c);
                                                                 groupRORWIdSet.add(programGeoMap.Core_MDF_Group_Name__c);     
                                                             }
        //Get group id's from PGM based to delete records based on Account/Program/Geo/Subgeo
        groupIdSet = Core_MDF_CCP_GenericUtility.fetchGroupIdsFromPGM(accountIdSet, programIdSet, geoStringSet, accountIdProgramIdGeoSubGeoStringSet, accountIdProgramIdGeoStringSet);
        
        Set<Id> groupROIdSet = new Set<Id>();
        //Fetch group id's from DeveloperName of groupRORWIdSet 
        for(Group grpId : [SELECT Id
                           FROM Group
                           WHERE DeveloperName IN :groupRORWIdSet]){
                               groupROIdSet.add(grpId.Id);
                           }
        
        
        if(updatedActivityMap != NULL && updatedActivityMap.size() > 0 ){
            if((groupIdSet != NULL && groupIdSet.size() > 0 ) || 
               (groupROIdSet != NULL && groupROIdSet.size()>0)){
                   
                   List<PartnerFundRequestShare> pfrShareToBeDeletedList = [SELECT Id, ParentId, RowCause, UserOrGroupId
                                                                            FROM PartnerFundRequestShare
                                                                            WHERE  ParentId IN :updatedActivityMap.keySet() AND
                                                                            RowCause =: Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_RowCause_Manual') AND 
                                                                            (UserOrGroupId  IN :groupIdSet OR UserOrGroupId IN :groupROIdSet)];
                   if(pfrShareToBeDeletedList != NULL && pfrShareToBeDeletedList.size() > 0){
                       delete pfrShareToBeDeletedList;
                   }
               }
        }
        List<Id> pfrIdList = new List<Id>();
        pfrIdList.addAll(updatedActivityMap.keySet());
        if(pfrIdList != NULL && pfrIdList.size() > 0){            
            Core_MDF_GeoBasedGenericSharing.checkObjectAndPgm('PartnerFundRequest', pfrIdList);
        }
    }
    
    private static Boolean run = true;
    public static Boolean runOnce()
    {
        if(run){
            run=false;
            return true;
        }else{
            return run;
        }
    }
    
    /***************************************************************************************************** 
Method Name   :        deletePFRShare
@return       :        void
@parameters   :        Map<Id, Id> pfrIdAccountIdMap, Map<Id, Account> accountMap
Description   :        deletes Activity share records
******************************************************************************************************/    
    public static void deletePFRShare(Map<Id, Id> pfrIdAccountIdMap, Map<Id, Account> accountMap){
        Map<Id, Id> pfrIdGroupIdMap = new Map<Id, Id>();
        List<PartnerFundRequestShare> pfrShareList = new List<PartnerFundRequestShare>();
        for(Id pfrId : pfrIdAccountIdMap.keySet()){
            if(pfrIdAccountIdMap.get(pfrId) != null && accountMap.get(pfrIdAccountIdMap.get(pfrId)).Core_MDF_Group_Id__c != null) {
                pfrIdGroupIdMap.put(pfrId, accountMap.get(pfrIdAccountIdMap.get(pfrId)).Core_MDF_Group_Id__c);   
            }
        }
        
        if(pfrIdGroupIdMap != NULL && !pfrIdGroupIdMap.isEmpty()){
            for(PartnerFundRequestShare pfrShare : [SELECT Id, ParentId, UserOrGroupId
                                                    FROM PartnerFundRequestShare
                                                    WHERE ParentId IN :pfrIdGroupIdMap.keySet() AND 
                                                    UserOrGroupId IN :pfrIdGroupIdMap.values() AND
                                                    RowCause = 'Manual']){
                                                        if(pfrIdGroupIdMap.get(pfrShare.ParentId) == pfrShare.UserOrGroupId){
                                                            pfrShareList.add(pfrShare);
                                                        }
                                                    }
            if(pfrShareList != NULL && !pfrShareList.isEmpty()){
                delete pfrShareList;
            }
        }
    }

    /*****************************************************************************************************
Method Name :   validateActivityWithCampaign
@return     :   NULL
@parameters :   Map of old Activity record and Map of new Activity record
Description :   It throws the error if Sum of Activity Amount Increase beyond Campaign Amount
Added By    :   SS
Modified By :                      Date:07/16/2020                     Changes:None
******************************************************************************************************/
public static void validateActivityWithCampaign(Map<Id,PartnerFundRequest> oldMap, List<PartnerFundRequest> newList){
    try{
    // Get all the activities with cmp budget & EEF budget
    Map<Id, PartnerFundRequest> cmpEEFBudgetPfrMap = new Map<Id, PartnerFundRequest>();
    //Map to store the Activity as key and its Available Budget Amount.
    Map<Id, Decimal> mapOfCampWithAvailableBudget = new Map<Id,Decimal>();
    Map<Id, Decimal> pfrToClaimAmtMap = new Map<Id,Decimal>();
    Map<Id, Decimal> pfrToEscalationAmtMap = new Map<Id, Decimal>();
    
    //Map created for OPAL Validations - Activity Id to Budget Id
    Map<String, Id> campaignIdBudgetTypeToBudgetIdMap = new Map<String, Id>();
    
    //Map contains sum of all the activities amount against CampaignId+BudgetId+BudgetType
    Map<String, Decimal> budgetAgainstAmountMap = new Map<String, Decimal>();  
    
    //Map contains the campaign-budget's amount against CampaignId+BudgetId+BudgetType
    Map<String, Decimal> cmpIdBudgetIdBudgetTypeToAmountMap = new Map<String, Decimal>();

    Map<Id, Campaign> campaignMap = new Map<Id, Campaign>();
    List<Campaign> campReimbAmount = new List<Campaign>();
    Set<Id> pfrIds = new Set<Id>();
    Set<Id> allocationIdSet = new Set<Id>();
    Set<Id> accountId = new Set<Id>();
    //Opal CampaignId set
    Set<Id> campaignIdSet = new Set<Id>();
        //IPA,RMF & EEF CampaignId set
        Set<Id> ipaAccRMFEEFCampIdSet = new Set<Id>();
    Boolean checkCampaignError = false;
    Boolean isOpal = false;
    Decimal pfrCampaignAmtAccount = 0;

    //Client Co-Marketing Fund;Data Center Co-Marketing Fund;Retail Marketing Funds;Intel Partner Alliance;EEF
    List<String> programsForActBudgetAmtCheck = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Prog_For_Bgt_Validation_PFR').split(';');
    //OEM CMP;Service Provider CMP
    List<String> cmpBudgetTypeList = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CMP_BudgetType') != null ? Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CMP_BudgetType').split(';') : null;
    //MDF;MDF+;Retail MDF
    List<String> budgetTypeReqAllocationValidationList = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ActBudgtTypesForAllocationCheck').split(';');
    //MDF;OEM CMP;MDF+;Service Provider CMP
    List<String> opalBudgetTypeList = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_OPAL_BudgetTypes').Split(';');
    //Paid;Payment Due;Pending Payment;PIC Pending;Hold
    List<string> pfcCloseStatus = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ClaimStatus_ActivityAutoClose').split(';');
    
    // US949836 : New Budget Type field changes replaced txt field with new global picklist field
    for(PartnerFundRequest pfr : newList){
        if(programsForActBudgetAmtCheck.contains(pfr.Core_MDF_Program__c)){
           
        
        if(isAllocationAmountValidationRequired(oldMap, pfr)){
          
        
        if(opalBudgetTypeList.contains(pfr.Core_MDF_Budget_Type_nm__c)){
                    isOpal = true;
                    String campaignIdBudgetType = string.valueOf(pfr.CampaignId) + pfr.Core_MDF_Budget_Type_nm__c;
                    campaignIdBudgetTypeToBudgetIdMap.put(campaignIdBudgetType, pfr.BudgetId);
                    String cmpIdBudgetIdBudgetType = String.ValueOf(pfr.CampaignId) + string.valueOf(pfr.BudgetId) + pfr.Core_MDF_Budget_Type_nm__c;
                    
            campaignIdSet.add(pfr.CampaignId);
                    checkCampaignError = true;
                    if(budgetTypeReqAllocationValidationList.contains(pfr.Core_MDF_Budget_Type_nm__c)){
                        allocationIdSet.add(pfr.AllocationId);
                    }
                }
                    else if(isRetailAccountBasedOrEEF(pfr)){
                    
            Decimal campAmount = 0;
                    String campaignIdBudgetType = string.valueOf(pfr.CampaignId) + pfr.Core_MDF_Budget_Type_nm__c;
                    campaignIdBudgetTypeToBudgetIdMap.put(campaignIdBudgetType, pfr.BudgetId);
                    
                    
            campAmount =  pfr.Core_MDF_Campaign_Amount__c != null ? pfr.Core_MDF_Campaign_Amount__c : campAmount;
                        if(!cmpIdBudgetIdBudgetTypeToAmountMap.containsKey(campaignIdBudgetType)){
                            cmpIdBudgetIdBudgetTypeToAmountMap.put(campaignIdBudgetType, campAmount);
                        }//Creating map with camp+budgettype as key and camp amount as value,budget not considered
                        if(pfr.Core_MDF_Program__c == RMF_PROG &&
                        budgetTypeReqAllocationValidationList.contains(pfr.Core_MDF_Budget_Type_nm__c)){
                            if((oldMap == null || (oldMap != null && (pfr.RequestedAmount != oldMap.get(pfr.Id).RequestedAmount 
                            || pfr.Core_MDF_Budget_Type_nm__c != oldMap.get(pfr.Id).Core_MDF_Budget_Type_nm__c) || pfr.Core_MDF_Reimbursement_Rate_txt__c != oldMap.get(pfr.Id).Core_MDF_Reimbursement_Rate_txt__c)) && pfr.Core_MDF_Budget_Type_nm__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_RetailMDF_BudgetType')){
                                pfr.Amount = ((pfr.RequestedAmount * Decimal.valueOf(pfr.Core_MDF_Reimbursement_Rate_txt__c.removeEnd('%')))/100).setScale(2,RoundingMode.HALF_UP);                                                                     
                    }
                            if(pfr.Core_MDF_Fund_Request_Status__c == Core_MDF_CCP_ConstantClass.PFR_CANCELLED_STATUS && pfr.status == Core_MDF_CCP_ConstantClass.PFR_APPROVED_STATUS){
                                pfr.status = Core_MDF_CCP_ConstantClass.PFR_REJECTED_STATUS;
                            }
                        }
                        ipaAccRMFEEFCampIdSet.add(pfr.CampaignId);
                            if(pfr.Core_MDF_Program__c != EEF_PROGRAM){
                                allocationIdSet.add(pfr.AllocationId);
                            }
                    checkCampaignError = true;
                       
                }
               
                    
                if(oldMap != NULL && !oldMap.isEmpty()){
                    pfrIds.add(pfr.Id); 
                    }}}}
    //For OPAL, RMF, IPA AccountBased
    if(campaignIdBudgetTypeToBudgetIdMap != NULL && campaignIdBudgetTypeToBudgetIdMap.Size() > 0){
        Map<Id, Decimal> allocationInDraftState = new Map<Id, Decimal>();
        Map<Id, Decimal> finalAllocationAmountMap = new Map<Id, Decimal>();
        map<Id, Decimal> allocationIdToAllocatedAmountMap = new Map<Id,Decimal>();
        if(allocationIdSet != NULL && allocationIdSet.Size() > 0){
            for(PartnerFundAllocation pfa : [SELECT Id, Amount, TotalApprovedFrs 
                                             FROM PartnerFundAllocation
                                             WHERE Id IN: allocationIdSet]){
                finalAllocationAmountMap.put(pfa.Id,  pfa.TotalApprovedFrs);
                allocationIdToAllocatedAmountMap.put(pfa.Id,pfa.Amount);
            }
        }
       

           
        if(isOpal){  
            
        for(Core_MDF_Campaign_Budgets__c campBudget : [SELECT Id, Core_MDF_Reimbursement_Amt__c,                    Core_MDF_Budget_Type_Nm__c,Core_MDF_Campaign_Id__c,Core_MDF_Budget_Name_Id__c
                                                           FROM Core_MDF_Campaign_Budgets__c
                                                           WHERE Core_MDF_Budget_Name_Id__c IN: campaignIdBudgetTypeToBudgetIdMap.values() 
                                                           AND Core_MDF_Campaign_Id__c IN: campaignIdSet]){
                String cmpIdBudgetIdBudgetType = String.ValueOf(campBudget.Core_MDF_Campaign_Id__c) + campBudget.Core_MDF_Budget_Name_Id__c + campBudget.Core_MDF_Budget_Type_Nm__c;
                cmpIdBudgetIdBudgetTypeToAmountMap.put(cmpIdBudgetIdBudgetType, campBudget.Core_MDF_Reimbursement_Amt__c);              
            }
        }
        // US949836 : New Budget Type field changes replaced txt field with new global picklist field
        for(PartnerFundRequest pfr : [SELECT Id, BudgetId, ChannelPartnerId, Core_MDF_Activity_Reimbursement_Amt_nbr__c,Core_MDF_Is_Outcome_Based_Ind__c,Core_MDF_Fund_Request_Status__c, CampaignId, Core_MDF_Budget_Type_nm__c,Amount, Core_MDF_Proposal_Based_Ind__c,Core_MDF_Program__c
                                      FROM PartnerFundRequest
                                          WHERE ((BudgetId IN: campaignIdBudgetTypeToBudgetIdMap.values() AND CampaignId IN: campaignIdSet)
                                          OR CampaignId IN: ipaAccRMFEEFCampIdSet)
                                          AND Core_MDF_Fund_Request_Status__c != 'Cancelled' AND Id NOT IN: pfrIds]){
                                          // Looping through other activities of the campaign
                String cmpIdBudgetIdBudgetType = String.ValueOf(pfr.CampaignId) + String.ValueOf(pfr.BudgetId) + pfr.Core_MDF_Budget_Type_nm__c;
                String campaignIdBudgetType = string.valueOf(pfr.CampaignId) + pfr.Core_MDF_Budget_Type_nm__c;
        Boolean isCmpOrEEFBudget = false;
            //Avoid Deeply Nested IF Statements
            Boolean isTargetBudget = (cmpBudgetTypeList != null && cmpBudgetTypeList.contains(pfr.Core_MDF_Budget_Type_nm__c)) || pfr.Core_MDF_Program__c == EEF_PROGRAM;
            if (isTargetBudget) {
                isCmpOrEEFBudget = true;
            }
            if (isTargetBudget && pfr.Core_MDF_Fund_Request_Status__c == Core_MDF_CCP_ConstantClass.PFR_CLOSED_STATUS) {
                cmpEEFBudgetPfrMap.put(pfr.Id, pfr);
            }
                                          
                if((budgetAgainstAmountMap.containsKey(cmpIdBudgetIdBudgetType) || budgetAgainstAmountMap.containsKey(campaignIdBudgetType))
                    && pfr.Amount != null){
            
                    decimal amount = 0;
                    amount += isRetailOrAccountBased(pfr) ? budgetAgainstAmountMap.get(campaignIdBudgetType) : budgetAgainstAmountMap.get(cmpIdBudgetIdBudgetType);
        if(isCmpOrEEFBudget){
                    if(pfr.Core_MDF_Fund_Request_Status__c != Core_MDF_CCP_ConstantClass.PFR_CLOSED_STATUS && pfr.Core_MDF_Activity_Reimbursement_Amt_nbr__c != null){ 
                        amount += pfr.Core_MDF_Activity_Reimbursement_Amt_nbr__c;
                    }
                }else{
                    amount += pfr.Amount;
                }
                    if(isRetailOrAccountBased(pfr)){
                        budgetAgainstAmountMap.put(campaignIdBudgetType, amount);// map to store total of amounts on pfr for each camp+budgettype
                    } else {
                        budgetAgainstAmountMap.put(cmpIdBudgetIdBudgetType, amount);
                    }
            }else{
                if(pfr.Amount != null){
                    decimal amount = 0;
           
                    if(isCmpOrEEFBudget){
                        if(pfr.Core_MDF_Fund_Request_Status__c != Core_MDF_CCP_ConstantClass.PFR_CLOSED_STATUS && pfr.Core_MDF_Activity_Reimbursement_Amt_nbr__c != null){ 
                            amount += pfr.Core_MDF_Activity_Reimbursement_Amt_nbr__c;
                        }
                    }else{
                        amount += pfr.Amount;
                    }
                        if(isRetailOrAccountBased(pfr)){
                            budgetAgainstAmountMap.put(campaignIdBudgetType, amount);// map to store total of amounts on pfr for each camp+budgettype
                        } else {
                            budgetAgainstAmountMap.put(cmpIdBudgetIdBudgetType, amount);
                        }}}}
        //Only for CMP Budget Type & EEF Program
        if(cmpEEFBudgetPfrMap != NULL && cmpEEFBudgetPfrMap.keyset() != null && !cmpEEFBudgetPfrMap.isEmpty()){
            for(AggregateResult pfc : [SELECT RequestId Id ,sum(Amount)amt
                                       FROM PartnerFundClaim 
                                       WHERE RequestId IN:cmpEEFBudgetPfrMap.keyset() AND Core_MDF_Status__c IN:pfcCloseStatus  
                                       AND Core_MDF_Type_Txt__c =: TYPE_CLAIM AND Core_MDF_Escalation_Id__c = null 
                                       GROUP BY RequestId]){ 
                ID pfrID =(Id)pfc.get('Id');    
                Decimal pfrClaimedAmount =(Decimal)pfc.get('amt');
                pfrToClaimAmtMap.put(pfrID,pfrClaimedAmount);
            }
            for(AggregateResult esc : [SELECT Core_MDF_Co_Marketing_Activity_id__c Id,sum(Core_MDF_Approved_Amount_amt__c)amt
                                       FROM Core_MDF_Escalation__c
                                       WHERE Core_MDF_Co_Marketing_Activity_id__c IN:cmpEEFBudgetPfrMap.keyset() 
                                       AND Core_MDF_Escalation_Status_nm__c =: ESC_APPROVED_STATUS
                                       GROUP BY Core_MDF_Co_Marketing_Activity_id__c]){
                ID pfrID =(Id)esc.get('Id');
                Decimal pfrEscAmount =(Decimal)esc.get('amt');
                pfrToEscalationAmtMap.put(pfrID,pfrEscAmount); 
            }
            
                
            for(PartnerFundRequest pfr: cmpEEFBudgetPfrMap.Values()){
                Decimal totalEscAmt = 0.0;
                Decimal totalClaimedAmt = 0.0;
                Decimal totalClaimEscConsumedAmt = 0.0;
                Decimal amount = 0.0;
                String cmpIdBudgetIdBudgetType = String.ValueOf(pfr.CampaignId) + pfr.BudgetId + pfr.Core_MDF_Budget_Type_nm__c;
                if(pfr.Amount != null){
                    totalEscAmt = pfrToEscalationAmtMap.containskey(pfr.Id) ? pfrToEscalationAmtMap.get(pfr.Id) : 0;
                    totalClaimedAmt = pfrToClaimAmtMap.containskey(pfr.Id) ? pfrToClaimAmtMap.get(pfr.Id) : 0;
                    totalClaimEscConsumedAmt = totalEscAmt + totalClaimedAmt;
                    amount = totalClaimEscConsumedAmt >= pfr.Core_MDF_Activity_Reimbursement_Amt_nbr__c
                        ? pfr.Core_MDF_Activity_Reimbursement_Amt_nbr__c : totalClaimEscConsumedAmt;
                    
                    if(budgetAgainstAmountMap.containsKey(cmpIdBudgetIdBudgetType)){
                        amount += budgetAgainstAmountMap.get(cmpIdBudgetIdBudgetType);
                        budgetAgainstAmountMap.put(cmpIdBudgetIdBudgetType, amount);
                    } else{
                            budgetAgainstAmountMap.put(cmpIdBudgetIdBudgetType, amount); }}}}
       
    for(PartnerFundRequest pfr : newList){
            Boolean addError = FALSE;
            //Allocation Amount Validation
                if(pfr.Core_MDF_Program__c!=EEF_PROGRAM && (budgetTypeReqAllocationValidationList.contains(pfr.Core_MDF_Budget_Type_nm__c) || (pfr.Core_MDF_Program__c == 'Intel Partner Alliance' && pfr.Core_MDF_Proposal_Based_Ind__c == false))){
                    Decimal pfrsUsingAllocation = 0;
                    Decimal allocationAmount = 0;
                    Decimal currentActivityAmount = 0;
                    Decimal totalPfrAmountUsingAllocation = 0;
                    if(finalAllocationAmountMap.containsKey(pfr.AllocationId) && finalAllocationAmountMap.get(pfr.AllocationId) != NULL){
                        pfrsUsingAllocation = finalAllocationAmountMap.get(pfr.AllocationId);
                    }
                
        if(allocationIdToAllocatedAmountMap.containsKey(pfr.AllocationId) &&
                    allocationIdToAllocatedAmountMap.get(pfr.AllocationId) != NULL){
                    allocationAmount = allocationIdToAllocatedAmountMap.get(pfr.AllocationId);
                }
                if((oldMap == NULL) || (oldMap.get(pfr.Id).BudgetId != pfr.BudgetId)){   
                    currentActivityAmount = pfr.Amount;
                }
                else if(oldMap != NULL && oldMap.containsKey(pfr.Id) && ((pfr.Amount > oldMap.get(pfr.Id).Amount))){
                    currentActivityAmount = pfr.Amount - oldMap.get(pfr.Id).Amount; 
                }
                currentActivityAmount = currentActivityAmount != null ? currentActivityAmount : 0;
                Decimal existingPfrAmount = 0;
                    
                
                    totalPfrAmountUsingAllocation = pfrsUsingAllocation + currentActivityAmount;
                   
        // Added this flag to stop recursion when there's a Status change. Since Amount was getting added twice in Transaction
                if(!stopRecursion){
                    stopRecursion = true;
                    if(allocationAmount < totalPfrAmountUsingAllocation && pfr.Core_MDF_Fund_Request_Status__c != Core_MDF_CCP_ConstantClass.PFR_CANCELLED_STATUS){
                        //Activity Cannot be created as the total of all activities exceeds the allocated budget.
                        pfr.addError(Label.Core_MDF_ActivityAmountExceedsAllocation);
                    addError = TRUE;}}}
            //Campaign Budget Validation
            if(!addError && campaignIdBudgetTypeToBudgetIdMap.containsKey(pfr.CampaignId + pfr.Core_MDF_Budget_Type_nm__c) && 
               campaignIdBudgetTypeToBudgetIdMap.get(pfr.CampaignId+pfr.Core_MDF_Budget_Type_nm__c) != NULL){
                Id budgetId = pfr.BudgetId;                  
                String cmpIdBudgetIdBudgetType = String.ValueOf(pfr.CampaignId) + string.valueOf(pfr.BudgetId) + pfr.Core_MDF_Budget_Type_nm__c;
                String campaignIdBudgetType = string.valueOf(pfr.CampaignId) + pfr.Core_MDF_Budget_Type_nm__c;
                //Get amount from Campaign Budget
                Decimal amountOnBudget = 0;
                Decimal existingPfrAmount = 0;
                Decimal activityReimbursementAmount = 0;
                Decimal finalAmountForCompare = 0;

                    if(isRetailAccountBasedOrEEF(pfr) && cmpIdBudgetIdBudgetTypeToAmountMap.containsKey(campaignIdBudgetType)){
                        amountOnBudget += cmpIdBudgetIdBudgetTypeToAmountMap.get(campaignIdBudgetType);//amount on campaign
                    } else {
                        if(cmpIdBudgetIdBudgetTypeToAmountMap.containsKey(cmpIdBudgetIdBudgetType)){
                            amountOnBudget += cmpIdBudgetIdBudgetTypeToAmountMap.get(cmpIdBudgetIdBudgetType);
                        }
                    }
            //Get sum of all existing activities amount
                    if(isRetailOrAccountBased(pfr) && budgetAgainstAmountMap.containsKey(campaignIdBudgetType)){
                            existingPfrAmount += budgetAgainstAmountMap.get(campaignIdBudgetType);//sum of amount for existing activities
                    } else {
                        if(budgetAgainstAmountMap.containsKey(cmpIdBudgetIdBudgetType)){
                            existingPfrAmount += budgetAgainstAmountMap.get(cmpIdBudgetIdBudgetType);
                        }
                    }
        
        if(pfr.RequestedAmount != NULL && pfr.Core_MDF_Reimbursement_Rate_txt__c != NULL && pfr.Core_MDF_Reimbursement_Rate_txt__c != ''){
                    activityReimbursementAmount = ((pfr.RequestedAmount * decimal.valueOf(pfr.Core_MDF_Reimbursement_Rate_txt__c.removeEnd('%')))/100).setScale(2,RoundingMode.HALF_UP);
                }
               
        //Get current activity amount
                           Decimal currentActivityAmount = ((cmpBudgetTypeList != null && cmpBudgetTypeList.contains(pfr.Core_MDF_Budget_Type_nm__c)) || 
                                                            pfr.Core_MDF_Program__c == EEF_PROGRAM) ? activityReimbursementAmount : pfr.Amount; 
                //Total amount to be inserted/updated
                finalAmountForCompare = existingPfrAmount + currentActivityAmount;
      
    //Check if total amount is exceeding Campaign Budget's amount
                if(finalAmountForCompare > amountOnBudget && checkCampaignError && pfr.Core_MDF_Fund_Request_Status__c != 'Cancelled' ){
                  
            //Sum of all activities cannot exceed Campaign Amount.  
                    pfr.addError(Label.Core_MDF_OPAL_Amount_Validation_Error);
                } else { 
                    budgetAgainstAmountMap.put(cmpIdBudgetIdBudgetType, finalAmountForCompare);
                }
            } 
        }
    }                        
}
    catch(Exception e){
        Core_MDF_CCP_UtilityClass.logError(e);
    }
}
    /*****************************************************************************
    Method Name :   isRetailOrAccountBased
    @return     :   Boolean
    @parameters :   Activity record
    Description :   Returns true if the incoming actvity's program is RMF/IPA-Account based
    Added By    :   SS
    ****************************************************************************/
    public static Boolean isRetailOrAccountBased(PartnerFundRequest pfr){
        Boolean isRetailOrAccBased = false;
        if((pfr.Core_MDF_Program__c == IPA_PROG && pfr.Core_MDF_Proposal_Based_Ind__c == false && pfr.Core_MDF_Is_Outcome_Based_Ind__c == false) || 
            pfr.Core_MDF_Budget_Type_nm__c == System.Label.Core_MDF_RetailMDF_BudgetType){
            isRetailOrAccBased = true;
        }
        return isRetailOrAccBased;
    }
    /*****************************************************************************
    Method Name :   isRetailAccountBasedOrEEF
    @return     :   Boolean
    @parameters :   Activity record
    Description :   Returns true if the incoming actvity's program is RMF/IPA-Account based/EGF
    Added By    :   Aswin Selvaraj
    Modified By :                      Date:07/Feb/2024                     Changes:None
 * ***************************************************************************/
    public static Boolean isRetailAccountBasedOrEEF(PartnerFundRequest pfr){
        Boolean isRetailAccountBasedOrEEF = false;
        if((pfr.Core_MDF_Program__c == IPA_PROG && pfr.Core_MDF_Proposal_Based_Ind__c == false && pfr.Core_MDF_Is_Outcome_Based_Ind__c == false) || 
           (pfr.Core_MDF_Program__c == EEF_PROGRAM && pfr.Core_MDF_Budget_Type_nm__c==EEF_BUDGET_TYPE) ||
           pfr.Core_MDF_Budget_Type_nm__c == System.Label.Core_MDF_RetailMDF_BudgetType){
               isRetailAccountBasedOrEEF = true;
           }
        return isRetailAccountBasedOrEEF;
    }
/*****************************************************************************************************
Method Name :   geoLeadRecallAndSubmitApprovalProcess
@return     :   NULL
@parameters :   List of Activity record and Map of new Activity record
Description :   It approves record already in approval process
Added By    :   PD
Modified By :   NZ                   Date:07/26/2021                    Changes:None
******************************************************************************************************/
    public static void updateTotalCampaignCostIpa(Map<Id,PartnerFundRequest> oldMap, List<PartnerFundRequest> newList, Boolean isAfter){
      try{
    // Get all the activities whose Amount is decreased
      set<Id> setCampId = new set<Id>();
    Map<Id, Set<PartnerFundRequest>> campActivitiesSetMap = new Map<Id, Set<PartnerFundRequest>>();
     Map<Id,PartnerFundRequest> pfrMap = new Map<Id,PartnerFundRequest>();
    Map<Id,String> campaignStatusMap = new Map<Id,String>();
        for(PartnerFundRequest pfr : newList){
            
            if(isAfter && ((Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_PFR_IPA').equalsIgnoreCase(pfr.Core_MDF_Program__c) && pfr.Core_MDF_Proposal_Based_Ind__c == true) || (Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Co_GTM_program_name').equalsIgnoreCase(pfr.Core_MDF_Program__c)))){

                if(oldMap == NULL || 
                   (oldMap != null && !oldMap.isEmpty() && 
                    ((oldMap.get(pfr.Id).Core_MDF_Fund_Request_Status__c != pfr.Core_MDF_Fund_Request_Status__c && Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Activity_Cancelled_Status').equalsIgnoreCase(pfr.Core_MDF_Fund_Request_Status__c))
                            || oldMap.get(pfr.Id).RequestedAmount != pfr.RequestedAmount
                            || oldMap.get(pfr.Id).Core_MDF_Activity_Reimbursement_Amt_nbr__c != pfr.Core_MDF_Activity_Reimbursement_Amt_nbr__c))){
                        if(campActivitiesSetMap.containsKey(pfr.CampaignId)){  
                            campActivitiesSetMap.get(pfr.CampaignId).add(pfr);
                        }else{ 
                            campActivitiesSetMap.put(pfr.CampaignId, new Set<PartnerFundRequest>{pfr}); 
                        }
                        if(!campaignStatusMap.containsKey(pfr.CampaignId)){
                            campaignStatusMap.put(pfr.CampaignId,pfr.Core_MDF_Campaign_Status_nm__c); 
                        }
                            
                }               
            }
        }

        // Calculate the Total Amount of Activities Under Same Campaign
        // For IPA Record Type
        if(isAfter && campActivitiesSetMap != NULL && campActivitiesSetMap.size() > 0){
            
            // Get the Campaigns Amount
                List<AggregateResult> sumofPFRRequestedAmount = [SELECT CampaignID, SUM(RequestedAmount) TotalCampaignCost, 
                                                                SUM(Core_MDF_Activity_Reimbursement_Amt_nbr__c) ReimbursementAmount
                                                             FROM PartnerFundRequest
                                                             WHERE CampaignID IN :campActivitiesSetMap.keySet() AND
                                                             Core_MDF_Fund_Request_Status__c <> 'Cancelled'
                                                             GROUP BY CampaignID];
           
            List<Campaign> cmpLstTobeUpdated = new List<Campaign>();
            //To Obtain the Available Amount by decducting the sum of the Request Amount from the Camapign Budget Amount
            if(sumofPFRRequestedAmount != null && sumofPFRRequestedAmount.size() > 0){
                for(AggregateResult agg : sumofPFRRequestedAmount){
                    
                    final Decimal pfrCampaignAmt =(Decimal)agg.get('TotalCampaignCost');
                        final Decimal campaignReimbursementAmt =(Decimal)agg.get('ReimbursementAmount');
                        if (pfrCampaignAmt != null || campaignReimbursementAmt != null) { 
                        Campaign cmpObj = new Campaign();
                        cmpObj.Id = (Id)agg.get('CampaignID');
                        cmpObj.Core_MDF_Total_Campaign_Cost_Amt__c = pfrCampaignAmt;
                            cmpObj.Core_MDF_Reimbursement_Amt__c = campaignReimbursementAmt;
                        cmpLstTobeUpdated.add(cmpObj);
                        setCampId.add(cmpObj.Id);
                    }
                }
            }
               else{                   
                   for(Id campId : campActivitiesSetMap.keySet()){
                       if(!setCampId.contains(campId)){                          
                           String campaignStatus;
                           if(campaignStatusMap !=null && campaignStatusMap.containsKey(campId)){
                                campaignStatus = campaignStatusMap.get(campId);  
                            }                          
                           if(String.isNotBlank(campaignStatus) && campaignStatus != 'Cancelled'){
                               Campaign cmpObj = new Campaign();
                               cmpObj.Id = campId;
                               cmpObj.Core_MDF_Total_Campaign_Cost_Amt__c = 0;
                               cmpObj.Core_MDF_Reimbursement_Amt__c = 0;
                               cmpLstTobeUpdated.add(cmpObj);  
                           }
                       }
                    }
                }
                if (isAfter && cmpLstTobeUpdated != null && !cmpLstTobeUpdated.isEmpty()) {
                    update cmpLstTobeUpdated;
                }
            }
        }
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);throw e;}  

    }
      
    /***************************************************************************************************** 
Method Name   :        shareActivityWithAccNodeGroupMethod
@return       :        void
@parameters   :        Map<Id,PartnerFundRequest> newActivityMap, Map<Id,PartnerFundRequest> oldActivityMap
Description   :        Share the activity with Acc node groups
Added By      :        Accenture - Sai - 22/02/2022
******************************************************************************************************/
public static void shareActivityWithAccNodeGroupMethod(Map<Id,PartnerFundRequest> newActivityMap, Map<Id,PartnerFundRequest> oldActivityMap){
        //Akash changes
        // Check if any of the activities are sub-activities and remove them from processing
        Map<Id,PartnerFundRequest> activitiesToProcess = new Map<Id,PartnerFundRequest>();
        
        for(Id pfrId : newActivityMap.keySet()) {
            PartnerFundRequest pfr = newActivityMap.get(pfrId);
            
            // Skip sub-activities from sharing
            if(pfr.Core_MDF_Activity_Level_nm__c != 'Sub Activity') {
                activitiesToProcess.put(pfrId, pfr);
            }
        }
        Map<Id,List<Id>> objectIdUserGroupIdListMap = new Map<Id,List<Id>>();
        Set<Id> pfrShareToBeDeleted = new Set<Id>();
        List<PartnerFundRequestShare> pfrShareList = new List<PartnerFundRequestShare>();
        Set<Id> accountNodeIdSet = new Set<Id>();
        Set<Id> oldAccountNodeIdSet = new Set<Id>();
        Map<Id, Id> accountIdGroupIdMap = new Map<Id, Id>();
        Map<Id, Id> accountIdExternalGroupIdMap = new Map<Id, Id>();
        Map<Id, Account> accountMap = new Map<Id, Account>();
        //Boolean isExternalShareAllowed = false;
        
        for(PartnerFundRequest pfr : activitiesToProcess.values()){
            PartnerFundRequest oldrPfr = oldActivityMap != null ? oldActivityMap.get(pfr.Id) : new PartnerFundRequest();
            //Ayush - added if condition to check for NRE only share activity to external user if Core_MDF_Is_Activity_Shared_EXT_Ind__c = true.
            //Akash - Latest commented because we want to share records to external user in draft status.
            //If program not NRE then work as is. 
            /*if(pfr.Core_MDF_Program__c != Label.Core_MDF_Co_GTM_program_name || (pfr.Core_MDF_Program__c == Label.Core_MDF_Co_GTM_program_name && 
                pfr.Core_MDF_Is_Activity_Shared_EXT_Ind__c != oldrPfr.Core_MDF_Is_Activity_Shared_EXT_Ind__c && pfr.Core_MDF_Is_Activity_Shared_EXT_Ind__c)){ // check if boolean is change then only execute
                isExternalShareAllowed = true;
            }*/
            //Checking if account changes in PFR record, then adding pfr id to a set and account id to a set to delete the old pfr share record
            if((pfr.ChannelPartnerId != null && (oldrPfr.ChannelPartnerId != null && pfr.ChannelPartnerId != oldrPfr.ChannelPartnerId))){
                pfrShareToBeDeleted.add(pfr.Id);
                accountNodeIdSet.add(oldrPfr.ChannelPartnerId);
                oldAccountNodeIdSet.add(oldrPfr.ChannelPartnerId);
            }
            accountNodeIdSet.add(pfr.ChannelPartnerId);
                if(pfr.Core_MDF_Program__c ==  Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_EEF_Program_Name')){//Assumption: Campaign always created on VC
                    accountNodeIdSet.add(pfr.Core_MDF_Campaign_Account_Id__c);
                }
        }
        //if(isExternalShareAllowed){ // Ayush - added a boolean check
            for(Account acc : [SELECT Id, Core_MDF_External_Group_Id__c, Core_MDF_Group_Id__c, Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c FROM Account 
                            WHERE Id IN :accountNodeIdSet AND (Core_MDF_Group_Id__c != NULL OR Core_MDF_External_Group_Id__c != NULL)]){
                                if(acc.Core_MDF_Group_Id__c != null){
                                    accountIdGroupIdMap.put(acc.Id, acc.Core_MDF_Group_Id__c);
                                }
                                if(acc.Core_MDF_External_Group_Id__c != null){
                                    accountIdExternalGroupIdMap.put(acc.Id, acc.Core_MDF_External_Group_Id__c);
                                }
                                accountMap.put(acc.Id, acc);
                            }
            if(pfrShareToBeDeleted.size() > 0){
                set<String> groupIdSet = new set<String>();
                for(Id accId : oldAccountNodeIdSet){
                            if (accountIdGroupIdMap.containsKey(accId)) {
                                groupIdSet.add(accountIdGroupIdMap.get(accId));
                            }
                            
                            if(accountIdExternalGroupIdMap.containsKey(accId)) {
                                groupIdSet.add(accountIdExternalGroupIdMap.get(accId));
                            }
                            
                        }

               
                    for(PartnerFundRequestShare pfrShare : [SELECT Id, ParentId, UserOrGroupId, Parent.Core_MDF_Program__c
                                                            FROM PartnerFundRequestShare WHERE ParentId IN : pfrShareToBeDeleted AND
                                                            UserOrGroupId IN :groupIdSet]) {
                                                                pfrShareList.add(pfrShare);
                                                            }
                
                if(pfrShareList != NULL && pfrShareList.size() > 0){
                delete pfrShareList;
            }
        }
            for(PartnerFundRequest pfr : activitiesToProcess.values())
        {   
            List<Id> groupIds = new List<Id>();
            //If operation is insert OR is update and account/owner change occured in PFR record
                if(oldActivityMap == null || (oldActivityMap != null && (pfr.OwnerId != oldActivityMap.get(pfr.Id).OwnerId || pfrShareToBeDeleted.contains(pfr.Id)
                    //Akash - Latest commented because we want to share records to external user in draft status.
                    /*(pfr.Core_MDF_Program__c == Label.Core_MDF_Co_GTM_program_name && pfr.Core_MDF_Is_Activity_Shared_EXT_Ind__c != oldActivityMap.get(pfr.Id).Core_MDF_Is_Activity_Shared_EXT_Ind__c && pfr.Core_MDF_Is_Activity_Shared_EXT_Ind__c)*/))){
                    if(accountIdGroupIdMap.get(pfr.ChannelPartnerId) != null && (Core_MDF_shareRecordToAccountGroup.isNodeBasedSharingReqd((accountMap.get(pfr.ChannelPartnerId)).Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c))){
                        groupIds.add(accountIdGroupIdMap.get(pfr.ChannelPartnerId));
                    
                    }
                    if(accountIdExternalGroupIdMap.get(pfr.ChannelPartnerId) != null){
                        groupIds.add(accountIdExternalGroupIdMap.get(pfr.ChannelPartnerId));
                        
                    }
                        //To share Actvity with Campaign Account's Ext Grp for EEF Program
                        if(pfr.Core_MDF_Program__c ==  Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_EEF_Program_Name') && accountIdExternalGroupIdMap.containsKey(pfr.Core_MDF_Campaign_Account_Id__c) && accountIdExternalGroupIdMap.get(pfr.Core_MDF_Campaign_Account_Id__c) != NULL){
                            groupIds.add(accountIdExternalGroupIdMap.get(pfr.Core_MDF_Campaign_Account_Id__c));
                        }
                    }
                if(groupIds != null && groupIds.size() > 0){
                    objectIdUserGroupIdListMap.put(pfr.Id, groupIds);
                }
            }
            if(objectIdUserGroupIdListMap != NULL && !objectIdUserGroupIdListMap.isEmpty()){
                Core_MDF_GenericShareRecordActionClass.RecordManualShareClass rmsInst = new Core_MDF_GenericShareRecordActionClass.RecordManualShareClass('PartnerFundRequest', objectIdUserGroupIdListMap, 'Edit', 'Manual');
                Core_MDF_GenericShareRecordActionClass.createShareRecordList(rmsInst);
            }
        //}
    }
    public static Boolean isAllocationAmountValidationRequired(Map<Id,PartnerFundRequest> oldPfrMap, PartnerFundRequest pfr){
        Boolean validationRequired = false;
        if((oldPfrMap != NULL && !oldPfrMap.isEmpty() && 
            pfr.Core_MDF_Activity_Reimbursement_Amt_nbr__c != oldPfrMap.get(pfr.Id).Core_MDF_Activity_Reimbursement_Amt_nbr__c 
            /* Below condition is just to ensure that this method should not be excuted when the activities are closed(Manual/Auto) */
            && !(pfr.Core_MDF_Activity_Closure_Type__c != oldPfrMap.get(pfr.Id).Core_MDF_Activity_Closure_Type__c) 
            && pfr.Core_MDF_Activity_Reimbursement_Amt_nbr__c > oldPfrMap.get(pfr.Id).Core_MDF_Activity_Reimbursement_Amt_nbr__c &&
            ((pfr.Core_MDF_Fund_Request_Status__c != 'Cancelled') || oldPfrMap.get(pfr.Id).Core_MDF_Fund_Request_Status__c != 'Cancelled')) 
            || oldPfrMap == NULL 
            || (oldPfrMap != null 
        /* Below condition is just to ensure that this method should not be excuted when the activities are closed(Manual/Auto) */
            && !(pfr.Core_MDF_Activity_Closure_Type__c != oldPfrMap.get(pfr.Id).Core_MDF_Activity_Closure_Type__c)
                && ((oldPfrMap.get(pfr.Id).Core_MDF_Fund_Request_Status__c != pfr.Core_MDF_Fund_Request_Status__c 
                && Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Activity_Cancelled_Status').equalsIgnoreCase(pfr.Core_MDF_Fund_Request_Status__c))
                || oldPfrMap.get(pfr.Id).RequestedAmount != pfr.RequestedAmount  
                || pfr.Core_MDF_Budget_Type_nm__c != oldPfrMap.get(pfr.Id).Core_MDF_Budget_Type_nm__c ||
                (oldPfrMap.get(pfr.Id).Core_MDF_Fund_Request_Status__c != pfr.Core_MDF_Fund_Request_Status__c &&
                 oldPfrMap.get(pfr.Id).Core_MDF_Fund_Request_Status__c == 'Closed' && pfr.Core_MDF_Fund_Request_Status__c != 'Cancelled') 
                || (pfr.Core_MDF_Fund_Request_Status__c != 'Cancelled'  && (pfr.Amount != oldPfrMap.get(pfr.Id).Amount || oldPfrMap.get(pfr.Id).BudgetId != pfr.BudgetId))))){
            validationRequired = true; 
         }
         return validationRequired;
    }
    public static Map<String,Object> getTemplateNameByProgName(){
        String jsonInputString = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_EmailTemplateMappingByProgrName');
        Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(jsonInputString);
       
        return resultMap;
    }
     public static Map<String,Object> getTemplateNameByProgNameIPA(){
        String jsonInputString = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_EmailTemplateMappingByProgIPA');
        Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(jsonInputString);
       
        return resultMap;
    } 

/***************************************************************************************************** 
Method Name   :        cancelActivityForCancelledCliamsAndEsclations
@return       :        void
@parameters   :        Map<Id,PartnerFundRequest> newActivityMap, Map<Id,PartnerFundRequest> oldActivityMap
Description   :        cancel Activity based on related Claim and Escalation status
Added By      :        Accenture - Akanksha - 05/08/2024
******************************************************************************************************/
public static void cancelActivityForCancelledCliamsAndEsclations(Map<Id,PartnerFundRequest> newActivityMap, Map<Id,PartnerFundRequest> oldActivityMap){
    
    String pfrCancelledStatus = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Activity_Cancelled_Status');
    Boolean isValidUserToCancelActvity = FeatureManagement.checkPermission('Core_MDF_Allowed_Permission_Set_for_Cancel_Activity');

    Map<Id, Boolean> pfrIdAndCheckForValidClaimMap = new Map<Id, Boolean> ();
    Map<Id, PartnerFundRequest> pfrIdAndPfrMapForEscalations = new Map<Id, PartnerFundRequest> ();
    Map<Id, Boolean> pfrIdAndCheckForActiveEscalationMap = new Map<Id, Boolean>();
    List<PartnerFundRequest> pfrRecordsToUpdate = new List<PartnerFundRequest>();
    Map<Id,PartnerFundRequest> eligiblePFRMapForCancellation = new Map<Id, PartnerFundRequest>();
    Set<Id> pfrIdSet = new Set<Id>();
    try{
        for(PartnerFundRequest itrNewPfr : newActivityMap.values()){
            if(oldActivityMap.get(itrNewPfr.Id) != null && newActivityMap.get(itrNewPfr.Id) != null && (oldActivityMap.get(itrNewPfr.Id).Core_MDF_Fund_Request_Status__c.Equals(Label.Core_MDF_pfrInprogress) ||
                oldActivityMap.get(itrNewPfr.Id).Core_MDF_Fund_Request_Status__c == 'Closed' || oldActivityMap.get(itrNewPfr.Id).Core_MDF_Fund_Request_Status__c == 'In-Progress Revision Required') && itrNewPfr.Core_MDF_Fund_Request_Status__c == pfrCancelledStatus){
                //pfrIdSet.add(itrNewPfr.Id);
                eligiblePFRMapForCancellation.put(itrNewPfr.Id, itrNewPfr);
            }
        }
        if(!newActivityMap.isEmpty() && !oldActivityMap.isEmpty() && !eligiblePFRMapForCancellation.isEmpty()){
            //if(isValidUserToCancelActvity){
                //map contains pfrId and Claim status.
                pfrIdAndCheckForValidClaimMap = Core_MDF_PartnerFundRequestCreatePage.checkAndValidateClaims(eligiblePFRMapForCancellation,oldActivityMap);

                if(pfrIdAndCheckForValidClaimMap.isEmpty()){
                    pfrIdAndCheckForActiveEscalationMap = Core_MDF_PartnerFundRequestCreatePage.checkActiveEscalation(eligiblePFRMapForCancellation,oldActivityMap);
                }

                // Processing records for update
                if(!eligiblePFRMapForCancellation.isEmpty()){
                    for (PartnerFundRequest itrOnNewPfr : eligiblePFRMapForCancellation.values()) { //PFR-A has Active claim, PFR-B -no active claim, has Active escalation
                        //PFR-A has Active claim && PFR-B -no active claim
                        if(!pfrIdAndCheckForValidClaimMap.isEmpty() && pfrIdAndCheckForValidClaimMap.containsKey(itrOnNewPfr.Id) ){
                            itrOnNewPfr.addError(Label.Core_MDF_Cancel_Activity_Error_Message);
                        }else if(!pfrIdAndCheckForActiveEscalationMap.isEmpty() && pfrIdAndCheckForActiveEscalationMap.containsKey(itrOnNewPfr.Id)){
                            itrOnNewPfr.addError(Label.Core_MDF_Cancel_Activity_Error_Message);
                        }else{
                            itrOnNewPfr.Core_MDF_Fund_Request_Status__c = pfrCancelledStatus;
                        }
                    }
                }
        }
    }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}  

    }  
     
}