public class ER_Approve_IPA_DZP_Request {
    @InvocableMethod(label='Auto Approve DZP' description='Approve DZP request' category= 'New Registration')
    public static void AutoApproveIPARequest(List<Id> requestIds) {
        
        if(requestIds.size() > 0)
        {
            Map<Id, String> failedreqIdMap = new Map<Id, String>();
            Map<Id, String> failedABTReqIdMap = ER_ABT_TriggerHandler_Utility.AssignAccountBusinessTypes(requestIds);
            if(failedABTReqIdMap.size() > 0)
            {
                for(Id failedid : failedABTReqIdMap.keyset())
                {
                    if(requestIds.Contains(failedid))
                    {
                        requestIds.remove(requestIds.indexOf(failedid));
                    }
                }
            }
            Map<Id, String> failedCBTReqIdMap = Core_Contact_Ent_BT_Handler.AssignContactBusinessTypes(requestIds);
            //Update for failed requests method
            failedreqIdMap.putAll(failedABTReqIdMap);
            failedreqIdMap.putAll(failedCBTReqIdMap);
            updateFailedRegistrationRequests(failedreqIdMap);
            System.debug('ABTSuccess'+ER_ABT_TriggerHandler_Utility.ABTSuccess);
            System.debug('CBTSuccess'+Core_Contact_Ent_BT_Handler.CBTSuccess);
        }
        
    }
    
    public static void updateFailedRegistrationRequests(Map<Id, String> failedReqIdMap)
    {
        List<PRM_Registration_Request__c> reqToBeUpdated = new List<PRM_Registration_Request__c>();
        for(PRM_Registration_Request__c req : [Select ID,Account_ID__c,Entitlement_Details__c,PRM_Review_Note_txt__c,PRM_Email_ID__c,
                                               Current_Status__c,PRM_Status__c from PRM_Registration_Request__c where ID =: failedReqIdMap.keyset()]) 
        {
            req.Current_Status__c = 'Auto-Approval Rejected';
            req.PRM_Review_Note_txt__c = failedReqIdMap.get(req.ID);
            req.PRM_Status__c = 'Rejected';
            reqToBeUpdated.add(req);
        }
        
        System.debug('reqToBeUpdated'+reqToBeUpdated);
        
        if(reqToBeUpdated.size() > 0)
        {
            if(Schema.sObjectType.PRM_Registration_Request__c.isUpdateable())
            {
                System.debug('Update Success'+reqToBeUpdated);
                Update reqToBeUpdated;
                System.debug('Update Success 2'+reqToBeUpdated);
            }
        }        
    }
}