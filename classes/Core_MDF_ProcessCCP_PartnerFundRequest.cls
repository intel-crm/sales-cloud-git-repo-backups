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
* Intel - Narayani Perachi		03/12/2019					  Made changes to catch block of every method to get the error deatils using Core_MDF_CCP_UtilityClass.getErrorDetails()
* Accenture - Sai Sugathri      06/07/2019                    Added approvers from six to ten in tobeUpdatedList
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Custom Labels used:
* Core_MDF_CCP_Account_Manager_Permission_Sets : Core_MDF_CCP_Internal_CCF_Account_Manager,Core_MDF_CCP_Internal_DCF_Account_Manager,Core_MDF_CCP_Internal_SPCF_Account_Manager
* Core_MDF_Activity_Cancelled_Status           : Cancelled
* Core_MDF_Activity_Recall_Exception_Origin    : Activity Recall Process
*********************************************************************************************************************************************************************************/
public without sharing class Core_MDF_ProcessCCP_PartnerFundRequest {
    
    public static Boolean runOnce = true;
    public static Boolean apprunOnce = true;
    public static Boolean camprunonce = true;
    public static String logEntryMsg = '';
    public static Boolean isError = false;
 
    //Commented the following code as part of SPCF Changes - Narayani Perachi
    //Follwing record type id variables are added by Shridhar to replace custom label
    //public static Id ccfRecordTypeId = Schema.SObjectType.PartnerFundRequest.getRecordTypeInfosByDeveloperName().get('Core_MDF_Client_CoMarketing_Fund').getRecordTypeId();
    //public static Id dcfRecordTypeId = Schema.SObjectType.PartnerFundRequest.getRecordTypeInfosByDeveloperName().get('Core_MDF_Data_Center_CoMarketing_Fund').getRecordTypeId();
    
    public static Map<id,string> ccpRecordTypeIds= getRecordIDFromEnvironment();
    
    
    public static void callApprovalProcess(Map<id,PartnerFundRequest> pfrMap, List<PartnerFundRequest> pfrList, List<SObject> sObjectList, Boolean emeaSubmission)
    {
        List<PartnerFundRequest> toBeUpdated = new List<PartnerFundRequest>();
        List<PartnerFundRequest> toBeUpdatedApproval = new List<PartnerFundRequest>();
        List<PartnerFundRequest> toBeUpdatedNullApproval = new List<PartnerFundRequest>();
        List<PartnerFundRequest> toBeSentForApproval = new List<PartnerFundRequest>();
        List<SObject> toBeProcessed = new List<SObject>();  
        List<string> nullApprovers = new List<string>();
        Set<id> campaignId = new set<id>();

        List<PartnerFundRequest> checkIfSubmittedByAccountManagerInput = new List<PartnerFundRequest>();
        Map<string,List<sobject>> checkIfSubmittedByAccountManagerOutput = new Map<string,List<sobject>>();
            
        Map<String, Map<String,List<Id>>> sObjResultMap = new Map<String, Map<String,List<Id>>>();
        Map<Id, string> autoApprovedmap = new Map<Id, string>();
        Map<String,List<id>> approvalRequiredmap = new Map<String,List<id>>();
        Map<Id, string> approvalTemplatemap = new Map<Id, string>();
        Map<String, list<id>> accountManagerApproverList = new  Map<String, list<id>>();
        Map<id,string> idAndUpdateStatus = new Map<id,string>();
        
        try{

            // Country Geo Map
            Map<String , String> countryGeoMap = new Map <String , String>();
            for (Core_MDF_CCP_Country_Geo_Mapping__mdt countryGeoMetaData : [SELECT Id, MasterLabel, Core_MDF_Geo__c FROM Core_MDF_CCP_Country_Geo_Mapping__mdt]){
                countryGeoMap.put(countryGeoMetaData.MasterLabel , countryGeoMetaData.Core_MDF_Geo__c );
            }
            
            for(PartnerFundRequest pfr: pfrList)
            {
                if((pfr.Core_MDF_Fund_Request_Status__c == Label.Core_MDF_Exception_PendingReview_Status 
                    || pfr.Core_MDF_Fund_Request_Status__c == Label.Core_MDF_Status_Pending_Approval_Nm) 
                   && (ccpRecordTypeIds.containsKey(pfr.RecordTypeId)) 
                   && pfr.Core_MDF_Fund_Request_Status__c != label.Core_MDF_PFR_Status_Closed)
                {
                    if (pfr.Core_MDF_Program__c != Label.Core_MDF_Retail_Program_Name){
                    	checkIfSubmittedByAccountManagerInput.add(pfr);    
                    }
                    else{
                        
                        // Get all the Geo values to check the existence with the PFR
                        Set<String> geoSet = new Set<String>();
                        for(String splitCountry : pfr.Core_MDF_Country_nm__c.split(';'))
                        {
                            if(countryGeoMap.containsKey(splitCountry)){
                                geoSet.add(countryGeoMap.get(splitCountry));    
                                break;
                            }                                
                        }

                        if ((emeaSubmission == false && !geoSet.contains('EMEA'))
                            || (emeaSubmission == false && pfr.Core_MDF_Approval_Step_Completed__c > 0) 
                            || emeaSubmission == true)
                        {
                            if (checkIfSubmittedByAccountManagerOutput.containsKey('approvalReq'))
                            {
                                checkIfSubmittedByAccountManagerOutput.get('approvalReq').add(pfr);
                            }
                            else {
                                checkIfSubmittedByAccountManagerOutput.put('approvalReq',new List<sobject>{pfr});
                            }
                        }
                    }
                }
            }
            
            //Calling method to check if the Activity Submitter is Account Manager
            if (checkIfSubmittedByAccountManagerOutput.size() == 0){
            	checkIfSubmittedByAccountManagerOutput = checkIfActivitySubmitterIsAccountManager(checkIfSubmittedByAccountManagerInput);    
            }
            
            
            for(string mapKey :checkIfSubmittedByAccountManagerOutput.keySet())
            {
                if(mapKey=='approvalReq')
                {
                    for(sobject pfr:checkIfSubmittedByAccountManagerOutput.get(mapkey))
                    {
                        toBeProcessed.add(pfr);
                    }  
                }
                else if(mapKey=='noApproval')
                {
                    for(sobject pfr:checkIfSubmittedByAccountManagerOutput.get(mapkey))
                    {
                        autoApprovedmap.put(pfr.Id, 'Planned');
                        
                    }
                }
            }
            
            //Calling method to identify IDs for approval and their approvers
            /*if (toBeProcessed.size()>0)
            {*/
                sObjResultMap = Core_MDF_GenericApprovalProcess.setApprovers(toBeProcessed);

                Map<Id,Core_MDF_Approver__c> pfrIdApprId = new Map<Id,Core_MDF_Approver__c>();

                for(string key: sObjResultMap.keySet())
                    { 
						                       
                        //Assign all Approval required IDs to approvalRequired
                        if(key=='approvalRequired'){
                            for(string key1:sObjResultMap.get(key).keyset())
                            {
                                if(sObjResultMap.get(key).keyset()!=NULL)
                                {
                                    approvalRequiredmap.put(key1,sObjResultMap.get(key).get(key1));
                                }                                           
                            }
                        }
                        //Assign all Auto Approved IDs to autoApprovedmap
                        else if(key=='autoApproved'){
                            
                            for(Id key1:sObjResultMap.get(key).keyset())
                            {
                                if(sObjResultMap.get(key).keyset()!=NULL)
                                {
                                    autoApprovedmap.put(key1,'Planned');
                                }         
                            }
                        }
                        //Assign Approval Template name
                        else
                        {
                            for(string key2:sObjResultMap.get(key).keyset())
                                {
                                    if(sObjResultMap.get(key).keyset()!=NULL){
                                    //create list for approval template name
                                    approvalTemplatemap.put(key,key2);
                                    }
                                }
                        }                    
                    }        
                    //Set Fund Request Status as 'Planned' for all Auto approved IDs
                    for(id autoApprovalID:autoApprovedmap.keyset())
                    {        
                        if(runOnce)
                            {        
                                PartnerFundRequest autoApprovalpfr = new PartnerFundRequest(Id = autoApprovalID);
                                autoApprovalpfr.Core_MDF_Fund_Request_Status__c = 'Planned';
                                toBeUpdated.add(autoApprovalpfr);               
                                
                            }
                        runOnce = false;
                    }
                    
                    //Initiate Approval Process
                    for(id appRequiredID:approvalRequiredmap.keyset())
                    {
                        if(apprunOnce &&  approvalRequiredmap.get(appRequiredID) != NULL)
                        {
                            toBeUpdatedApproval = updateApprovers(approvalRequiredmap);
                        }
                        else if(approvalRequiredmap.get(appRequiredID) == NULL && pfrMap.get(appRequiredID).Core_MDF_Program__c != Label.Core_MDF_Retail_Program_Name)
                        {
                            campaignId.add(pfrMap.get(appRequiredID).CampaignId);
                            nullApprovers.add(appRequiredID);
                            
                        }
                    
                        apprunOnce = false;
                    }
                    
                    if(campaignId.size() > 0 && camprunonce)
                    {
                        accountManagerApproverList = assignAccountManagers(pfrMap,campaignId,nullApprovers);
                        if(accountManagerApproverList.size()>0)
                            {
                                toBeUpdatedNullApproval = updateApprovers(accountManagerApproverList);
                                toBeUpdatedApproval.addall(toBeUpdatedNullApproval);
                            }
                        camprunonce=false;
                    }
            
                
                toBeUpdated.addall(toBeUpdatedApproval); //Adding all Autoapproval and Approval object to be updated
                
                if(toBeUpdated!=NULL && toBeUpdated.size()>0)
                {  
                    Map<String, Object> databaseResult = new map<String,Object>();
                    databaseResult = Core_MDF_CCP_UtilityClass.updateListAndLogErrors(toBeUpdated, logEntryMsg);
                    idAndUpdateStatus = (Map<id,string>) databaseResult.get('DatabaseResult');
                    logEntryMsg = (string)databaseResult.get('ErrorMessage');
                }
                
                for(PartnerFundRequest updateId: toBeUpdatedApproval)
                {
                    if(idAndUpdateStatus.get(updateId.Id) == 'Success'){
                    toBeSentForApproval.add(updateId);
                    }
                }      



                //Call method to initiate Approval Process
                callApprovalProcessCall(toBeSentForApproval,approvalTemplatemap,pfrList);
            }
        //}
        
        catch(exception ex)
        {
            logEntryMsg += Core_MDF_CCP_UtilityClass.getErrorDetails(ex);
            isError = true;
        }      
        finally
        {           
            if(isError || idAndUpdateStatus.values().contains('Failed'))
            {
                Core_MDF_CCP_UtilityClass.logErrorinLogObject(logEntryMsg,'PFR Trigger - Main class()');
            }
        }   
    }  
    //Method to assign Internal Account Managers as Approvers in case of NULL Approvers
    public static Map<String, list<id>> assignAccountManagers(Map<id,PartnerFundRequest> pfrMap, set<id> campaignId,List<string> nullApprovers)
    {
        Map<Id, String> campaignProgramMap = new Map<Id, String>();
        Map<String, List<Id>> partnerGroupIdMap = new Map<String,List<Id>>();
        Map<Id, List<Id>> groupUserMap =  new Map<Id, List<Id>>();  
        Map<String, list<id>> accountManagerApproverList = new  Map<String, list<id>>();
        List<string> accountManagerPermissionSet = Label.Core_MDF_CCP_Account_Manager_Permission_Sets.split(',');
               
        Set<Id> parentAccountIds = new Set<Id>();
        Set<Id> channelProgramIdSet = new Set<Id>();
        Set<Id> groupIds = new Set<Id>();
        
        try{
            for(PartnerFundRequest pfr : [SELECT Id, CampaignId, Campaign.Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c, 
                                          Campaign.Core_MDF_Channel_Program__c,Core_MDF_Region_cd__c 
                                          FROM PartnerFundRequest 
                                          WHERE Id IN: pfrMap.keySet()]){
                                              parentAccountIds.add(pfr.Campaign.Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c);
                                              channelProgramIdSet.add(pfr.Campaign.Core_MDF_Channel_Program__c);
                                              String value =  (String)pfr.Campaign.Core_MDF_Channel_Program__c + (String)pfr.Campaign.Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c + pfr.Core_MDF_Region_cd__c;
                                              campaignProgramMap.put(pfr.CampaignId, value);    
                                          }
            
            for(Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm : [SELECT Id, Core_MDF_Account_id__c, Core_MDF_Channel_Program_id__c,
                                                                   Core_MDF_Region_cd__c, Core_MDF_User_id__c,Core_MDF_Sub_Region_cd__c,
                                                                   Core_MDF_Region_Sub_Region_nm__c,Core_MDF_Role_nm__c 
                                                                   FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c 
                                                                   WHERE Core_MDF_Account_id__c IN: parentAccountIds AND 
                                                                   Core_MDF_Channel_Program_id__c IN: channelProgramIdSet AND
                                                                   Core_MDF_Role_nm__c IN:accountManagerPermissionSet AND
                                                                   Core_MDF_Active_Ind__c = TRUE]){
                                                                       for(String region : iupgm.Core_MDF_Region_cd__c.Split(';')){
                                                                           String key;
                                                                           if(region != 'WW'){
                                                                               key = (String)iupgm.Core_MDF_Channel_Program_id__c + iupgm.Core_MDF_Account_id__c + iupgm.Core_MDF_Region_cd__c;
                                                                           }
                                                                           else{
                                                                               key = (String)iupgm.Core_MDF_Channel_Program_id__c + iupgm.Core_MDF_Account_id__c;
                                                                           }
                                                                           
                                                                           if(partnerGroupIdMap.containsKey(key)){
                                                                               partnerGroupIdMap.get(key).add(iupgm.Core_MDF_User_id__c);
                                                                           }
                                                                           else{
                                                                               partnerGroupIdMap.put(key, new List<Id>{iupgm.Core_MDF_User_id__c});
                                                                           }
                                                                           
                                                                       }
                                                                   }
            
            for(String pfrReq:nullApprovers){
                String parentProgram = campaignProgramMap.get(pfrMap.get(pfrReq).campaignId);
                String forWW = parentProgram.left(36);
                
                if(parentProgram != null && forWW != null)
                {
                    List<Id> userList = new List<Id>();
                    if(partnerGroupIdMap.get(forWW) != NULL){
                        userList.addAll(partnerGroupIdMap.get(forWW));
                    }  
                    if(partnerGroupIdMap.get(parentProgram) != NULL){
                        userList.addAll(partnerGroupIdMap.get(parentProgram));
                    } 
                    if(userList.size() > 0){
                        while(userlist.size() < 10){
                            userlist.add(userlist[0]);
                        }
                        accountManagerApproverList.put(pfrReq,userList);
                    }
                }                                              
            }
        }
        
        catch(exception ex){
            logEntryMsg = Core_MDF_CCP_UtilityClass.getErrorDetails(ex); Core_MDF_CCP_UtilityClass.logErrorinLogObject(logEntryMsg,'PFR Trigger - assignAccountManagers()');
        }
        
        return accountManagerApproverList;       
    }
    
    //Method to initiate Approval Process
    public static void callApprovalProcessCall(List<PartnerFundRequest> toBeUpdatedApproval, Map<Id, string> approvalTemplatemap,List<PartnerFundRequest> pfrnew)
    {
        List<Approval.ProcessSubmitRequest> appRequests = new List<Approval.ProcessSubmitRequest> ();
        List<Id> instancrNotExists = new List<Id>();
        //Calling Approval Process
        try{

            instancrNotExists = isProcessInstanceExist(pfrnew);
            
            for(PartnerFundRequest pfr : toBeUpdatedApproval)
            {
                for (PartnerFundRequest pfrn : pfrnew){
                    if (pfrn.id == pfr.id){
                        pfr.Core_MDF_Approval_Step_Completed__c = pfrn.Core_MDF_Approval_Step_Completed__c;
                        pfr.Core_MDF_PriorValueOfStatus__c = pfrn.Core_MDF_PriorValueOfStatus__c;
                        pfr.Core_MDF_Fund_Request_Status__c = pfrn.Core_MDF_Fund_Request_Status__c;
                        break;
                    }
                }
            }

            for(PartnerFundRequest updatedpfr:toBeUpdatedApproval) 
            {
                Integer stepsCompleted = updatedpfr.Core_MDF_Approval_Step_Completed__c == null ? 0 : Integer.valueOf(updatedpfr.Core_MDF_Approval_Step_Completed__c);
                if (!instancrNotExists.contains(updatedpfr.Id) && ((stepsCompleted == 0 || updatedpfr.Core_MDF_PriorValueOfStatus__c == Label.Core_MDF_PFR_Revision_Required)
                        || updatedpfr.Core_MDF_Fund_Request_Status__c == Label.Core_MDF_Status_Pending_Approval_Nm)){

                    /*if (updatedpfr.Core_MDF_PriorValueOfStatus__c == 'Revision Required'){
                        updatedpfr.Core_MDF_Approval_Step_Completed__c = 0;
                    }*/

                    Approval.ProcessSubmitRequest appObj = new Approval.ProcessSubmitRequest();
                    appObj.setObjectId(updatedpfr.id);
                    appObj.setProcessDefinitionNameOrId(approvalTemplatemap.get(updatedpfr.Id));
                    appObj.setComments('Record submitted for approval');
                    appRequests.add(appObj);

                    if (appRequests.size()> 0)
                    {
                        Approval.ProcessResult[] result = Approval.process(appRequests);
                    }
                }
            }
        }
        catch(exception ex)
        {
             logEntryMsg = Core_MDF_CCP_UtilityClass.getErrorDetails(ex); Core_MDF_CCP_UtilityClass.logErrorinLogObject(logEntryMsg,'PFR Trigger - callApprovalProcess()');
        }
        
    }

    //Method to Update the Approvers in PartnerFundRequest Object
    public static List<PartnerFundRequest> updateApprovers(Map<String, list<id>> approverIdList)
    {
        
        List<PartnerFundRequest> tobeUpdatedList = new List<PartnerFundRequest>();       
        try{
        for(id appRequiredID:approverIdList.keyset())
        {
            PartnerFundRequest appPFR = new PartnerFundRequest(Id = appRequiredID);
            List<id> approvers = approverIdList.get(appRequiredID);

            appPFR.Core_MDF_Approver_1__c = approvers[0];
            appPFR.Core_MDF_Approver_2__c = approvers[1];
            appPFR.Core_MDF_Approver_3__c = approvers[2];
            appPFR.Core_MDF_Approver_4__c = approvers[3];
            appPFR.Core_MDF_Approver_5__c = approvers[4];
            appPFR.Core_MDF_Approver_6__c = approvers[5];
            appPFR.Core_MDF_Approver_7__c = approvers[6];
            appPFR.Core_MDF_Approver_8__c = approvers[7];
            appPFR.Core_MDF_Approver_9__c = approvers[8];
            appPFR.Core_MDF_Approver_10__c = approvers[9];
            tobeUpdatedList.add(appPFR);
        }
        }
        catch(exception ex)
        {
             logEntryMsg = Core_MDF_CCP_UtilityClass.getErrorDetails(ex); Core_MDF_CCP_UtilityClass.logErrorinLogObject(logEntryMsg,'PFR Trigger - updateApprovers()');
        }
        return tobeUpdatedList;       
    }

    //Method to check if the Activity Submitter is Account Manager
    public static Map<string,List<sobject>> checkIfActivitySubmitterIsAccountManager(List<partnerfundrequest> toBeProcessed)
    {
        List<string> accountManagerPermissionSet = Label.Core_MDF_CCP_Account_Manager_Permission_Sets.split(',');
        List<id> createdAndModifiedBy = new List<id>();
        List<id> accountManagerList = new List<id>();
        List<sobject> autoApproval = new List<sobject>();
        List<sobject> needApproval = new List<sobject>();
        Map<string,id> pfrAccountManagerMap = new Map<string,id>();
        Map<string,List<sobject>> outputMap = new Map<string,List<sobject>>();
        
        try
        {
            for(partnerfundrequest pfr:toBeProcessed)
            {
                createdAndModifiedBy.add(pfr.CreatedById);
                createdAndModifiedBy.add(pfr.LastModifiedById); 
            }
            
            

            List<PermissionSetAssignment> permissionSetToAssignee = [SELECT Id, PermissionSetId, PermissionSet.Name, AssigneeId FROM PermissionSetAssignment where AssigneeId IN: createdAndModifiedBy and PermissionSet.Name IN: accountManagerPermissionSet];
            
            for(PermissionSetAssignment permissionSet:permissionSetToAssignee )
            {
            
                accountManagerList.add(permissionSet.AssigneeId);
            }
            
            

            for(partnerfundrequest pfr:toBeProcessed)
            {
                if (pfr.Core_MDF_Program__c != Label.Core_MDF_Retail_Program_Name){
                    if((accountManagerList.contains(pfr.CreatedById) && accountManagerList.contains(pfr.LastModifiedById)) || accountManagerList.contains(pfr.LastModifiedById)) 
                    {  
                        autoApproval.add(pfr);
                    }
                    else 
                    {
                        needApproval.add(pfr);
                    }
                }
            }

            outputMap.put('approvalReq', needApproval);
            outputMap.put('noApproval', autoApproval);
        }

        catch(exception ex)
            {
                logEntryMsg = Core_MDF_CCP_UtilityClass.getErrorDetails(ex); Core_MDF_CCP_UtilityClass.logErrorinLogObject(logEntryMsg,'PFR Trigger - checkIfActivitySubmitterIsAccountManager()');         
            } 
        
        return outputMap;
    }

    //Method to check if the PartnerFundRequest Belongs to any of the mentioned RecordTypes
    public static Map<id,string>  getRecordIDFromEnvironment()
    {
            Map<id,string> ccpRecordTypeIds= new Map<id,string> ();
            List<string> ccpProgramsInList = Label.Core_MDF_CCP_RecordType_API_Name.split(',');
            
            //'Core_MDF_Client_CoMarketing_Fund,Core_MDF_Data_Center_CoMarketing_Fund,Core_MDF_Service_Provider_CoMarketing_Fund';
                           
            try
            {
                for(string program:ccpProgramsInList)
                {
                     id recordTypeId = Schema.SObjectType.PartnerFundRequest.getRecordTypeInfosByDeveloperName().get(program).getRecordTypeId();
                     string recordTypeName = Schema.SObjectType.PartnerFundRequest.getRecordTypeInfosByDeveloperName().get(program).getName();
                     ccpRecordTypeIds.put(recordTypeId,recordTypeName);   
                }
            }

            catch(exception ex)
            {
                logEntryMsg = Core_MDF_CCP_UtilityClass.getErrorDetails(ex); Core_MDF_CCP_UtilityClass.logErrorinLogObject(logEntryMsg,'PFR Trigger - getRecordIDFromEnvironment()');
                //isError = true;         
            } 
               
            
            return ccpRecordTypeIds;        
    }
    
/****************************************************************************************************************************************
Method Name:                                             recallApprovalProcess
@return  :                                               return null
@parameters:                                             PFR List to be recalled 
Description:                                             All the cancel activities should be recalled to prevent Approve/Reject action.
Added By:                                                Accenture – Shridhar K
Modified By:                  Date:                      Changes: 
Accenture – Shridhar K        12/23/2018                 Created. 
Accenture – Shridhar K        03/08/2019                 Modified recallApprovalProcess to prevent Approve/Reject/Reassign Cancelled Activity . 
                                                         Since Approval recall works only for submitter or System Admin, recall functionality code 
                                                         is replaced by delete ProcessIntanceWorkItems. 
*****************************************************************************************************************************************/    
    
    public static void recallApprovalProcess(List<PartnerFundRequest> pfrList, Map<id,PartnerFundRequest> pfrOldMap){
        
        list<Id> cancelledPFRId = new list<Id>();
        list<ProcessInstanceWorkitem>  piList = new list<ProcessInstanceWorkitem>();
        try{
            //Collecting All Cancelled Activities
            for(PartnerFundRequest pfr: pfrList){
                system.debug('pfr.Core_MDF_Fund_Request_Status__c-> '+pfr.Core_MDF_Fund_Request_Status__c);
            system.debug('pfrOldMap.get(pfr.Id).Core_MDF_Fund_Request_Status__c-> '+pfrOldMap.get(pfr.Id).Core_MDF_Fund_Request_Status__c);
                if(pfr.Core_MDF_Fund_Request_Status__c != pfrOldMap.get(pfr.Id).Core_MDF_Fund_Request_Status__c &&  
                    pfr.Core_MDF_Fund_Request_Status__c == Label.Core_MDF_Activity_Cancelled_Status){
                        cancelledPFRId.add(pfr.Id);
                }
            }   

			//test code begins
			system.debug('cancelledPFRId-> '+cancelledPFRId);
            
            
            //test code ends            
            
            //Preparing List of all ProcessInstanceWorkitem related to cancelled activities
            if(cancelledPFRId.size()>0){
                for(ProcessInstance pi : [SELECT Id, TargetObjectId,(SELECT Id FROM Workitems) FROM ProcessInstance WHERE TargetObjectId IN: cancelledPFRId]){   
                    if(pi.Workitems.size() > 0){
                        piList.addAll(pi.Workitems);
                    }
                }
            }
            
            system.debug('piList-> '+piList);
            
            //Deleting all ProcessInstanceWorkitem to prevent Approve/Reject for cancelled activities 
            if(piList.size() > 0){
                Database.delete(piList);
            } 
        }
        catch(exception ex){
            logEntryMsg = Core_MDF_CCP_UtilityClass.getErrorDetails(ex);
            
            Core_MDF_CCP_UtilityClass.logErrorinLogObject(logEntryMsg,Label.Core_MDF_Activity_Recall_Exception_Origin);         
        }                       
    }   

    public static List<Id> isProcessInstanceExist(List<PartnerFundRequest> recordIds)
    {
        List<Id> ids = new List<Id>();
        if(recordIds.size()>0)
        {
            List<Id> pfrIds = new List<Id>();

            for(PartnerFundRequest recId : recordIds)
            {
                pfrIds.add(recId.Id);
            }

            for(ProcessInstance pi : [SELECT Id, TargetObjectId ,Status FROM ProcessInstance 
                        WHERE TargetObjectId IN: pfrIds and Status != 'Rejected' and Status != 'Removed' and Status != 'Approved'])
            {
                ids.add(pi.TargetObjectId);
            }
            
        }

        return ids;
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
            if(pfr.Core_MDF_Fund_Request_Status__c != label.Core_MDF_PFR_Status_Closed){
                pfrIdList.add(pfr.Id);
            	}
            }
        
        //activityIdSet = activityMap.keySet();
        //pfrIdList.addAll(activityIdSet);
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
        Map<Id,PartnerFundRequest> updatedActivityMap = new Map<Id,PartnerFundRequest>();
        //Set<Id> pfrIdSet = new Set<Id>();
        Set<String> accountIdProgramIdGeoSubGeoStringSet = new Set<String>();
        Set<String> accountIdProgramIdGeoStringSet = new Set<String>();
        Set<Id> accountIdSet = new Set<Id>();
        Set<Id> programIdSet = new Set<Id>();
        Set<Id> groupIdSet = new Set<Id>();
        Set<String> geoStringSet = new Set<String>();
        Set<Id> oldAccountIdSet = new Set<Id>();
        Map<Id, Account> oldAccountMap = new Map<Id, Account>();
        Map<Id, Id> pfrIdAccountIdMap = new Map<Id, Id>();
        
        Map<Id, PartnerFundRequest> oldStaticPFRMap = Core_MDF_UpdateActivityFields.oldStaticPFRMap;
        for(PartnerFundRequest pfr : oldStaticPFRMap.values()){
            oldAccountIdSet.add(pfr.ChannelPartnerId);
            pfrIdAccountIdMap.put(pfr.Id, pfr.ChannelPartnerId);
        }
        
        for(Account accountRecord : [SELECT Id, Core_MDF_CoMarketing_Ultimate_Account__c, Core_MDF_Channel_Program__c
                                     FROM Account
                                     WHERE Id IN :oldAccountIdSet]){
            oldAccountMap.put(accountRecord.Id, accountRecord);
        }
        //Put one Map instead of 3 Maps
        for(PartnerFundRequest pfr : [SELECT Id, ChannelPartnerId, ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c, Core_MDF_Region_cd__c,
                                     ChannelPartner.Core_MDF_Channel_Program__c, Core_MDF_Sub_Region_cd__c 
                              FROM PartnerFundRequest WHERE Id IN :newActivityMap.keySet()]){
            accountIdSet.add(oldAccountMap.get(pfrIdAccountIdMap.get(pfr.Id)).Core_MDF_CoMarketing_Ultimate_Account__c);
            programIdSet.add(oldAccountMap.get(pfrIdAccountIdMap.get(pfr.Id)).Core_MDF_Channel_Program__c);
            geoStringSet.add(oldActivityMap.get(pfr.Id).Core_MDF_Region_cd__c);

            if(oldActivityMap.get(pfr.Id).Core_MDF_Sub_Region_cd__c != NULL){
                String accountIdProgramIdGeoSubGeo = (String)oldAccountMap.get(pfrIdAccountIdMap.get(pfr.Id)).Core_MDF_CoMarketing_Ultimate_Account__c + (String)oldAccountMap.get(pfrIdAccountIdMap.get(pfr.Id)).Core_MDF_Channel_Program__c + oldActivityMap.get(pfr.Id).Core_MDF_Region_cd__c + oldActivityMap.get(pfr.Id).Core_MDF_Sub_Region_cd__c;
                //String accountIdProgramIdGeoSubGeo = (String)oldActivityMap.get(pfr.Id).ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c + (String)oldActivityMap.get(pfr.Id).ChannelPartner.Core_MDF_Channel_Program__c + oldActivityMap.get(pfr.Id).Core_MDF_Region_cd__c + oldActivityMap.get(pfr.Id).Core_MDF_Sub_Region_cd__c;
                accountIdProgramIdGeoSubGeoStringSet.add(accountIdProgramIdGeoSubGeo);
            }
            else{
                String accountIdProgramIdGeo = (String)oldAccountMap.get(pfrIdAccountIdMap.get(pfr.Id)).Core_MDF_CoMarketing_Ultimate_Account__c + (String)oldAccountMap.get(pfrIdAccountIdMap.get(pfr.Id)).Core_MDF_Channel_Program__c + oldActivityMap.get(pfr.Id).Core_MDF_Region_cd__c;
                //String accountIdProgramIdGeo = (String)oldActivityMap.get(pfr.Id).ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c + (String)oldActivityMap.get(pfr.Id).ChannelPartner.Core_MDF_Channel_Program__c + oldActivityMap.get(pfr.Id).Core_MDF_Region_cd__c;
                accountIdProgramIdGeoStringSet.add(accountIdProgramIdGeo);
            }
            
            if(oldActivityMap.get(pfr.Id).Core_MDF_Fund_Request_Status__c != Label.Core_MDF_PFR_Status_Closed){
                if((oldActivityMap.get(pfr.Id).OwnerId != newActivityMap.get(pfr.Id).OwnerId) || //Owner
                   (pfrIdAccountIdMap.get(pfr.Id) != newActivityMap.get(pfr.Id).ChannelPartnerId)|| //Account
                   (oldActivityMap.get(pfr.Id).Core_MDF_Region_cd__c != newActivityMap.get(pfr.Id).Core_MDF_Region_cd__c) ||//Geo
                   (
                        (oldActivityMap.get(pfr.Id).Core_MDF_Sub_Region_cd__c != NULL || newActivityMap.get(pfr.Id).Core_MDF_Sub_Region_cd__c != NULL) && //Subgeo
                        oldActivityMap.get(pfr.Id).Core_MDF_Sub_Region_cd__c != newActivityMap.get(pfr.Id).Core_MDF_Sub_Region_cd__c
                    )
                ){
                    updatedActivityMap.put(pfr.Id,newActivityMap.get(pfr.Id));
                }
            }
        }

        groupIdSet = Core_MDF_CCP_GenericUtility.fetchGroupIdsFromPGM(accountIdSet, programIdSet, geoStringSet, accountIdProgramIdGeoSubGeoStringSet, accountIdProgramIdGeoStringSet);

        if(updatedActivityMap != NULL && updatedActivityMap.size() > 0 && groupIdSet != NULL && groupIdSet.size() > 0){
            List<PartnerFundRequestShare> pfrShareToBeDeletedList = [SELECT Id, ParentId, RowCause, UserOrGroupId
                                                                     FROM PartnerFundRequestShare
                                                                     WHERE ParentId IN :updatedActivityMap.keySet() AND
                                                                           RowCause =: Label.Core_MDF_RowCause_Manual AND 
                                                                           UserOrGroupId  IN :groupIdSet];
            if(pfrShareToBeDeletedList != NULL && pfrShareToBeDeletedList.size() > 0){
                delete pfrShareToBeDeletedList;
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

}