public with sharing class ER_ProcessAutoApprovedRecordsUtility 
{
    public static final String LOG_ENTRY_INFO     = 'info';
    public static final String LOG_ENTRY_ERROR    = 'error';
    public static final String LOG_ENTRY_SCOPE    = 'ER_ProcessAutoApprovedRecordsUtility';
    public static void AssignABTandCBT(List<ProcessAutoApprovedRecords__e> evtobjList)
    {
       
        //List<Id> requestIds = new List<Id>();
        Set<Id> entIds = new Set<Id>();
        Map<Id,Id> entBusinessTypeMap = new Map<Id,Id>();
        String params = '';
        Id eBREnttRecTypeId = Schema.SObjectType.PRM_VXEnttlmntMatrix__c.getRecordTypeInfosByName().get(System.Label.EBREntitlementRecordTypeName).getRecordTypeId();
        List<PRM_Registration_Request__c> reqs = new List<PRM_Registration_Request__c>();
        try {                    
            //Loop through platform event msg
            for(ProcessAutoApprovedRecords__e evtobj : evtobjList)
            {
                PRM_Registration_Request__c req = new PRM_Registration_Request__c();
                req.Id = evtobj.RequestID__c;
                req.PRM_Salesforce_ID__c = evtobj.AccountId__c;
                req.PRM_Contact_Salesforce_Id__c = evtobj.ContactId__c;
                req.Entitlement_Details__c = evtobj.EntitlementId__c;
                reqs.add(req);
                entIds.add(evtobj.EntitlementId__c);
                params = evtobj.RequestID__c + ';';
            }
            ER_ErrorUtility.createLogEntry('Platform Event Recieved Request ID- '+params,null, LOG_ENTRY_INFO, LOG_ENTRY_SCOPE, 'RequestID- '+params);
            
            if(Test.isRunningTest() && evtobjList[0].EntitlementId__c == null) {
                throw new ER_ErrorUtility.CustomException('exception');
            }
            
            //Get Business type for each entitlement passed in platform event msg
            for(PRM_VXEnttlmntMatrix__c mat : [SELECT Business_Types__c,PRM_Entitlement_Id__c 
                                               FROM PRM_VXEnttlmntMatrix__c 
                                               WHERE PRM_Entitlement_Id__c IN : entIds and RecordTypeId=: eBREnttRecTypeId])
            {
                entBusinessTypeMap.put(mat.PRM_Entitlement_Id__c,mat.Business_Types__c);
            }
            
            //Assign Account and contact business types
            if(reqs.size() > 0)
            {
                Map<Id, String> failedreqIdMap = new Map<Id, String>();
                Map<Id, String> failedCBTReqIdMap = new Map<Id, String>();
                List<PRM_Registration_Request__c> requests = new List<PRM_Registration_Request__c>();
                Map<Id, String> failedABTReqIdMap = ER_ABT_TriggerHandler_Utility.AssignAccountBusinessTypes(reqs, entBusinessTypeMap);
                //Exclude failed registration request to add CBT
                if(failedABTReqIdMap.size() > 0)
                {             
                    for(PRM_Registration_Request__c request : reqs) {
                        if(!failedABTReqIdMap.keyset().contains(request.Id)) {
                            requests.add(request);
                        }
                    }
                }
                else {
                    requests.addAll(reqs);
                }
                //Assign contact business type
                if(requests.size() > 0)
                {
                    failedCBTReqIdMap = Core_Contact_Ent_BT_Handler.AssignContactBusinessTypes(requests, entBusinessTypeMap);
                }
                //Update for failed requests method
                failedreqIdMap.putAll(failedABTReqIdMap);
                failedreqIdMap.putAll(failedCBTReqIdMap);
                if(failedreqIdMap.size()>0)
                {
                    updateFailedRegistrationRequests(failedreqIdMap);
                }
            }
        }
        catch(Exception ex) {
            ER_ErrorUtility.CustomException custEx = new ER_ErrorUtility.CustomException();
            custEx.Message = ex.getMessage();
            custEx.Cause = ex.getCause();
            custEx.StackTraceString = ex.getStackTraceString();
            custEx.LineNumber = ex.getLineNumber();                
            custEx.TypeName = ex.getTypeName();            
            ER_ErrorUtility.createLogEntry('Error in AssignABTandCBT', custEx, LOG_ENTRY_ERROR, LOG_ENTRY_SCOPE, params);
        }   
    }   
    
    public static void updateFailedRegistrationRequests(Map<Id, String> failedReqIdMap)
    {
        List<PRM_Registration_Request__c> reqToBeUpdated = new List<PRM_Registration_Request__c>();
        for(PRM_Registration_Request__c req : [Select ID,Account_ID__c,Entitlement_Details__c,PRM_Review_Note_txt__c,PRM_Email_ID__c,
                                               Current_Status__c,PRM_Status__c from PRM_Registration_Request__c where ID =: failedReqIdMap.keyset()]) 
        {
            req.Current_Status__c = 'Open';
            req.PRM_Review_Note_txt__c = failedReqIdMap.get(req.ID);
            //req.PRM_Status__c = 'Rejected';
            reqToBeUpdated.add(req);
        }
        
        if(reqToBeUpdated.size() > 0)
        {
            if(Schema.sObjectType.PRM_Registration_Request__c.isUpdateable())
            {
                Update reqToBeUpdated;
            }
        }
    }

    public class CustomException extends Exception{}
}