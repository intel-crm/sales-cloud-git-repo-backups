/*************************************************************************************************************************************
Apex Class Name     : PRM_AccountChangeEventSubscriber 
Created Date        : Oct 2023

Modification Log    :
* Developer                 Date                    Description
* --------------------------------------------------------------------------------------------------------------------------
* Shraddha                Oct- 2023           Created class to update associated registration reg on creation of account 
***************************************************************************************************************************************/

public without sharing class PRM_AccountChangeEventSubscriber {
    /*to create log entry*/
    public static final String ORIGIN = 'PRM_AccountChangeEventSubscriber';
    /*to create log entry*/
    public static final String SEVERITY = 'Critical';
    /*to create log entry*/
    public static final String PROJECT = 'IPA Registrations';  
    /*to create log entry*/
    public static final string SCOPE = 'PRM_AccountChangeEventSubscriber';
	public static String logEntryMsg='';
	public static List<Core_Log_Entry__c> listOfLogEntries = new List<Core_Log_Entry__c>();
/*****************************************************************************************************************
* Method Name: processACMResponseForPlatformEvents
* Date: 04/2024
* Owner: Shraddha M
* Description: Read the the ACM_Account_Change_Event__e events from flow
* Return: void
******************************************************************************************************************/
    @InvocableMethod(label='SubscribeToARQEvents')
    public static void processACMResponseForPlatformEvents(List<ACM_Account_Request_Event__e> acmAccChangeEventList) {
	logEntryMsg+='Entered processACMResponseForPlatformEvents: acmAccChangeEventList'+acmAccChangeEventList;
        processACMResponseForRegistration(acmAccChangeEventList);
    }
    
/*****************************************************************************************************************
* Method Name: processACMResponseForRegistration
* Date: 11/2023    
* Owner: Shraddha M
* Description: Process the ACM_Account_Change_Event__e event responses
* Return: void
******************************************************************************************************************/
    public static void processACMResponseForRegistration(List<ACM_Account_Request_Event__e> acmAccChangeEventList) {
	logEntryMsg+='Entered processACMResponseForRegistration: acmAccChangeEventList'+acmAccChangeEventList;
        List<PRM_UCD_ResponseWrapper.arqResponseData> ucdResList = new List<PRM_UCD_ResponseWrapper.arqResponseData>(); 
        
        try {
            if (!acmAccChangeEventList.isEmpty() && acmAccChangeEventList!= null) {
                for(ACM_Account_Request_Event__e event: acmAccChangeEventList) { 
                    if (event.Message__c != null) { //&& event.Headers__c != null
                        PRM_UCD_ResponseWrapper.arqResponseData jsonRes = (PRM_UCD_ResponseWrapper.arqResponseData)System.JSON.deserialize(event.Message__c, PRM_UCD_ResponseWrapper.arqResponseData.class);
                        
                        PRM_UCD_ResponseWrapper.AccountResponseModel accWrp = new PRM_UCD_ResponseWrapper.AccountResponseModel();
                        accWrp = jsonRes.Account;
                        
                        if (String.isNotBlank(jsonRes.AccountReferenceSourceName) && jsonRes.AccountReferenceSourceName == 'Partner') {
                            ucdResList.add(jsonRes);
                        }
                    }
                }
                
                if (!ucdResList.isEmpty()) {
                    processUCDResponses(ucdResList);
					logEntryMsg+='Entering processUCDResponses: ucdResList'+ucdResList;
                }
            }
        }
        catch (exception ex) { Core_Log_Entry.logEntryWithException(ORIGIN, PROJECT, SCOPE, SEVERITY,'', '' ,'' ,'processACMResponseForRegistration' ,'' ,ex);
        }
        
    }

/*****************************************************************************************************************
* Method Name: processUCDResponses
* Date: 11/2023    
* Owner: Shraddha M
* Description: Process the ACM_Account_Change_Event__e event responses
* Return: void
******************************************************************************************************************/ 
    public static void processUCDResponses(List<PRM_UCD_ResponseWrapper.arqResponseData> ucdResList) {
        List<PRM_Registration_Request__c> listOfRegReqToUpdate = new List<PRM_Registration_Request__c>();
        Map<Id, String> regReqIdToCommentMap = new Map<Id, String>();
        Map<Id, String> workItemIdToCommentMap = new Map<Id, String>();
        Map<Id, PRM_UCD_ResponseWrapper.arqResponseData> accIdToUcdResMap = new Map<Id, PRM_UCD_ResponseWrapper.arqResponseData>();
        logEntryMsg+='Entered processUCDResponses: ucdResList'+ucdResList;
        for(PRM_UCD_ResponseWrapper.arqResponseData ucdResponseObj : ucdResList) {
            accIdToUcdResMap.put(ucdResponseObj.RequestId, ucdResponseObj);
        }
                
        if (!accIdToUcdResMap.isEmpty() && accIdToUcdResMap != null) {
            for(PRM_Registration_Request__c regReq : [SELECT id, PRM_Status__c, PRM_Review_Note_txt__c, PRM_Reject_Reason__c, PRM_Account_Request_Queue__c,
                                                      PRM_Account_Request_Queue__r.id
                                                      FROM PRM_Registration_Request__c
                                                      WHERE PRM_Account_Request_Queue__c IN: accIdToUcdResMap.keySet()]
               ) {
                   PRM_UCD_ResponseWrapper.arqResponseData ucdResponseData = accIdToUcdResMap.get(regReq.PRM_Account_Request_Queue__r.id);
                   PRM_UCD_ResponseWrapper.AccountResponseModel acc = ucdResponseData.Account;
                   
                   //update new Reg Req
                   PRM_Registration_Request__c req = new PRM_Registration_Request__c();
                   req.Id = regReq.Id;
                   if (acc.RecordType == 'Intel Account' && String.isBlank(ucdResponseData.RejectionReason)) {
                       req.PRM_Salesforce_ID__c = acc.AccountId;
                       //for approval
                       String approverComment = String.isNotBlank(regReq.PRM_Review_Note_txt__c) ? regReq.PRM_Review_Note_txt__c : '';
                       regReqIdToCommentMap.put(req.Id, approverComment);
					   logEntryMsg+='Updated PRM_Salesforce_ID__c'+acc.AccountId+ 'on registration request: '+req.id;
                   }
                   else if (acc.RecordType == 'Rejected Account') {
                       req.PRM_Rejected_By__c = 'MDM';
                       req.PRM_MDM_Rejection_Reason__c = String.isNotBlank(ucdResponseData.RejectionReason) 
                           ? ucdResponseData.RejectionReason : LabelConfiguration__mdt.getInstance('PRM_UCD_Rejection').Value__c;
						    logEntryMsg+='Updated rejection details on registration'+req.id;
                   }
                   else if (acc.RecordType == 'Intel Account' && ucdResponseData.RejectionReason.contains('Reuse Account')) {
                       req.PRM_Rejected_By__c = 'Data Ops';
                       req.PRM_MDM_Rejection_Reason__c = String.isNotBlank(ucdResponseData.RejectionReason) 
                           ? ucdResponseData.RejectionReason : LabelConfiguration__mdt.getInstance('PRM_DataOps_Rejection').Value__c;
                       req.PRM_Suggested_Account__c = acc.AccountId;
					    logEntryMsg+='Updated PRM_Suggested_Account__c'+acc.AccountId+ 'on registration request: '+req.id;
                   }
                   else if (ucdResponseData.Status == 'Rejected' && String.isNotBlank(ucdResponseData.RejectionReason) && acc.AccountId == null) {
                        req.PRM_Rejected_By__c = 'Data Ops';
                        req.PRM_MDM_Rejection_Reason__c = ucdResponseData.RejectionReason;
						logEntryMsg+='Updated rejection details on registration'+req.id;
                   }
                   listOfRegReqToUpdate.add(req);
               }
        }
                
        //update listOfRegReqToUpdate
        if (!listOfRegReqToUpdate.isEmpty() && listOfRegReqToUpdate!= null) {
		logEntryMsg+='Updated listOfRegReqToUpdate line 133'+listOfRegReqToUpdate;
          List<Database.SaveResult> listOfRegReqResult=  Database.Update(listOfRegReqToUpdate, false);
                    for (Database.SaveResult sr: listOfRegReqResult) {
                        if (!sr.isSuccess()) {
                            String errorMsg = 'Id - '+sr.getId();
                            for (Database.Error err: sr.getErrors()) {
                                errorMsg = errorMsg +' **** '+ err.getStatusCode()+'- '+err.getMessage()+ 'Fields- '+err.getFields();                               
                            }
							logEntryMsg+='Error Occured while updating registrations'+errorMsg;
					} 
				}
			
			}
        
        //fetch approval record realted to registration request
        if (!regReqIdToCommentMap.isEmpty() && regReqIdToCommentMap!= null) {
			logEntryMsg+='Calling fetchApprovalRecords line 138: regReqIdToCommentMap'+regReqIdToCommentMap;
            workItemIdToCommentMap = fetchApprovalRecords(regReqIdToCommentMap);
        }
                
        //update approval record realted to registration request
        if (!workItemIdToCommentMap.isEmpty() && workItemIdToCommentMap!= null) {
		logEntryMsg+='Calling updateApprovalProcess line 144: workItemIdToCommentMap'+workItemIdToCommentMap;
            PRM_AccountChangeSubHandler.updateApprovalProcess(workItemIdToCommentMap);
        }
        
    }
    
    
    /**
*  @description      : fetch the ProcessInstanceWorkitem for the related new registration
*  @name             : fetchApprovalRecords
*  @param            : Map<Id, String> regReqIdToCommentMap
*  @throws exception : NONE
**/
    public static Map<Id, String> fetchApprovalRecords(Map<Id, String> regReqIdToCommentMap) {   
        logEntryMsg+='entered fetchApprovalRecords line 158: regReqIdToCommentMap'+regReqIdToCommentMap;
        Map<Id, String> workItemIdToCommentMap = new Map<Id, String>();
        
        for(ProcessInstanceWorkitem workItem : [SELECT Id, ProcessInstanceId, ActorId, ProcessInstance.TargetObjectId FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId IN :regReqIdToCommentMap.keySet()]
           ) {
               Id regReqId = workItem.ProcessInstance.TargetObjectId;
               String comment = regReqIdToCommentMap.containsKey(regReqId) ? regReqIdToCommentMap.get(regReqId) : '';
               workItemIdToCommentMap.put(workItem.Id, comment);
           }
         logEntryMsg+='returning workItemIdToCommentMap'+workItemIdToCommentMap;
        if(!string.isNotBlank(logEntryMsg)){
        listOfLogEntries.add(new Core_Log_Entry__c(Core_Message__c = 'PRM_AccountChangeEventSubscriber', 
                                               Core_Origin__c = ORIGIN, Core_Details__c = logEntryMsg, 
                                               Core_Severity__c = SEVERITY, Core_When__c = System.Now(), 
                                               Core_Project__c = PROJECT));
    }
	
	// insert a log entry for 
    if (!listOfLogEntries.isEmpty() && listOfLogEntries !=null) { Core_Log_Entry.createLogEntries(listOfLogEntries);
   }
        return workItemIdToCommentMap;
    }
    
}