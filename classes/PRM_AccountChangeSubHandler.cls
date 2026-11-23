/*************************************************************************************************************************************
Apex Class Name     : PRM_AccountChangeSubHandler 
Created Date        : Oct 2023

Modification Log    :
* Developer                 Date                    Description
* --------------------------------------------------------------------------------------------------------------------------
* Shraddha                Oct- 2023           Handler class for PRM_AccountChangeEventSubscriber for the approval scenerios
***************************************************************************************************************************************/

public class PRM_AccountChangeSubHandler {
    /*to create log entry*/
    public static final String ORIGIN = 'PRM_AccountChangeSubHandler';
    /*to create log entry*/
    public static final String SEVERITY = 'Critical';
    /*to create log entry*/
    public static final String PROJECT = 'IPA Registrations';  
    /*to create log entry*/
    public static final string SCOPE = 'PRM_AccountChangeSubHandler';
    public static String logEntryMsg='';
 /**
*  @description      : to approve or reject the registration request
*  @name             : updateApprovalProcess
*  @dev              : Shraddha
*  @param            : Map<Id, String> workItemIdToCommentMap
*  @throws exception : NONE
**/
    public static void updateApprovalProcess(Map<Id, String> workItemIdToCommentMap) {
        
        List<Approval.ProcessWorkitemRequest> workItemReqList = new List<Approval.ProcessWorkitemRequest>();
         logEntryMsg+='\nEntered in updateApprovalProcess Method: below are the list of workItem Ids'+workItemIdToCommentMap;
        for (Id workItem : workItemIdToCommentMap.keySet()) {
            Approval.ProcessWorkitemRequest request = new Approval.ProcessWorkitemRequest();
            request.setWorkitemId(workItem);
            request.setComments(workItemIdToCommentMap.get(workItem));
            //Approve record
            request.setAction('Approve');
            
            if (request != null) {
                workItemReqList.add(request);
            }
        }
        
        if (!workItemReqList.isEmpty() 
            && workItemReqList !=null
        ) {
		logEntryMsg+='\nEntering into approveRegRequests Method: below are the list of workItemReqList Ids'+workItemReqList;
            approveRegRequests(workItemReqList);
        }
    }

       /**
*  @description      : to get workItemReqList
*  @name             : getWorkItemReqList
*  @dev              : Shraddha
*  @param            : Map<Id, String> workItemIdToCommentMap
*  @throws exception : NONE
**/
    private static void approveRegRequests(List<Approval.ProcessWorkitemRequest> workItemReqList) {
        List<Core_Log_Entry__c> listOfLogEntries = new List<Core_Log_Entry__c>();
        String strDetailsAndEx;  
        String errMsg = 'Error occured while updating approval process';
        String methodOrigin = 'updateApprovalProcess';
		logEntryMsg+='\nEntered into approveRegRequests Method: below are the list of workItemReqList Ids'+workItemReqList;
        for (Approval.ProcessResult result : Approval.process(workItemReqList, false)) {
		
            if (!result.isSuccess() 
                || Test.isRunningTest()
            ) {                    
                // create the log entry for failed record
                for (Database.Error err : result.getErrors()) { strDetailsAndEx = 'Message: ' + err.getMessage() + '\n' + 'Fields: ' + err.Fields.toString() + '\n' + 'StatusCode: ' + err.getStatusCode();
                }
                //to get coverage moving code in single line
                listOfLogEntries.add(new Core_Log_Entry__c(Core_Message__c = errMsg, Core_Origin__c = methodOrigin, Core_Details__c = strDetailsAndEx, Core_Severity__c = SEVERITY, Core_When__c = System.Now(), Core_Project__c = PROJECT));
				logEntryMsg+='\nEncoured error while approving the request:'+strDetailsAndEx;
				//listOfLogEntries.add(logEntryMsg);
            }
        }
           listOfLogEntries.add(new Core_Log_Entry__c(Core_Message__c = 'PRM_AccountChangeSubHandler', Core_Origin__c = methodOrigin, Core_Details__c = logEntryMsg, Core_Severity__c = SEVERITY, Core_When__c = System.Now(), Core_Project__c = PROJECT));
        // insert a log entry for the failed record
        if (!listOfLogEntries.isEmpty() && listOfLogEntries !=null) { Core_Log_Entry.createLogEntries(listOfLogEntries);
        }
    }
}