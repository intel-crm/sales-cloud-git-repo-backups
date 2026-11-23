public with sharing class AnkitPOCLInkController {

    @AuraEnabled(cacheable=true)
    public static List<Core_Contact_Entitlement__c> retrieveEntitlements(String ContactMoveGovernanceId) {

        Set<String> setOfContactId = new Set<String>();

        System.debug('ContactMoveGovernanceId===@'+ContactMoveGovernanceId);
        for( Contact_Move_Governance__c cmg : [select id , Contact__c From  Contact_Move_Governance__c Where Id =: ContactMoveGovernanceId]){
            setOfContactId.add(cmg.Contact__c);
            System.debug('setOfContactId===@'+setOfContactId);
        }
        List<Core_Contact_Entitlement__c> ccc = new List<Core_Contact_Entitlement__c>();

        ccc =   [ SELECT id, Name , Core_Contact_Id__c, Core_Contact_Id__r.Name , Core_Engagement_Tier__c, Core_Entitlement_Id__c, Core_From_Source__c, Core_Selected__c,Core_Entitlement_Id__r.Core_Display_Name__c,  Core_Type__c FROM Core_Contact_Entitlement__c WHERE Core_Contact_Id__c IN:setOfContactId AND Core_Entitlement_Id__r.Core_IsActive__c = true];

        System.debug('ccc===@'+ccc);
        return ccc;
    }

    @AuraEnabled
    public static void approveRecord(String ContactMoveGovernanceId)
    {
        Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
        req.setComments('Approving request using Trigger');
        req.setAction('Approve');
        //req.setNextApproverIds(new Id[] {opp.Next_Approver__c});
        Id workItemId = getWorkItemId(ContactMoveGovernanceId);
        System.debug('workItemId==@@'+workItemId);
        if(workItemId == null)
        {

            //opp.addError('Error Occured in Trigger');
        }
        else
        {
            req.setWorkitemId(workItemId);
            System.debug('req==@@'+req);

            // Submit the request for approval
            Approval.ProcessResult result =  Approval.process(req);
            System.debug('result==@@'+result);

           // updateContactEntitlementList(ContactMoveGovernanceId);
        }
    }

    public static Id getWorkItemId(Id targetObjectId)
    {
        Id retVal = null;
 
        for(ProcessInstanceWorkitem workItem  : [Select p.Id from ProcessInstanceWorkitem p
            where p.ProcessInstance.TargetObjectId =: targetObjectId])
        {
            retVal  =  workItem.Id;
        }
 
        return retVal;
    }


    @AuraEnabled
    public static void rejectRecord(String ContactMoveGovernanceId , String reason){
        Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
        req.setComments('Rejected request using Trigger');
        req.setAction('Reject');
        //req.setNextApproverIds(new Id[] {UserInfo.getUserId()});
        Id workItemId = getWorkItemId(ContactMoveGovernanceId);

        if(workItemId == null)
        {
        }
        else
        {
            Contact_Move_Governance__c cmg = new Contact_Move_Governance__c();
            cmg.Id = ContactMoveGovernanceId;
            cmg.New_Comments__c = reason;
            update cmg;

            req.setWorkitemId(workItemId);
            // Submit the request for approval
            Approval.ProcessResult result =  Approval.process(req);
            
        }
    }


    public void updateContactEntitlementList(String ContactMoveGovernanceId){
       List<Contact_Move_Governance__c> cmglist = [Select id, Keep_Entitlement__c,Contact__c from Contact_Move_Governance__c where ID =: ContactMoveGovernanceId ];

        if(!cmglist[0].Keep_Entitlement__c){
            List<Core_Contact_Entitlement__c> ceList = [select Id, Name,Core_Entitlement_Id__r.name,Core_Entitlement_Id__r.Core_IsActive__c,Core_Status__c,
                                                        Core_Selected__c, Core_Update_Reason__c
                                                        FROM Core_Contact_Entitlement__c 
                                                        WHERE Core_Entitlement_Id__r.Core_IsActive__c = true AND Core_Contact_Id__c  =: cmglist[0].Contact__c
                                                        AND Core_Selected__c = true];
            for(Core_Contact_Entitlement__c ceObject : ceList)
            {
                ceObject.Core_Selected__c = false;
                ceObject.Core_Status__c = 'Pending';
                ceObject.Core_Update_Reason__c = 'Change Account';
                //ceList.add(ceObject);
            }
            
            //US:US390485 - Dev:Aparna - Description:updating records in future call to overcome 101 Error - Date:26/6/2019
            //update ceList;
            
            string cntEntrecords=JSON.serialize(ceList);
            if(string.isNotblank(cntEntrecords)){
                updateCntEntitlementInFuture(cntEntrecords);
            }
            //End for US390485
        }
    } 


    @future
    public static void updateCntEntitlementInFuture(string strList){
        try {
            List<Core_Contact_Entitlement__c > newCntEntList = (List<Core_Contact_Entitlement__c >)JSON.deserialize(strList, List<Core_Contact_Entitlement__c >.class);
            if(newCntEntList !=null && newCntEntList .size()>0){
                database.update(newCntEntList); 
            } 
        } catch(Exception e){ 
            //Core_IPS_ExceptionHandling.logEntryWithException(e, 'Contact_Entitlement', 'Core_IPS_MoveContactWithCases_Controller');
            //System.debug('Core_IPS_MoveContactWithCases_Controller-->updateCntEntitlementInFuture-->Exception--->'+e.getMessage()+'At Line Number-->'+e.getLineNumber()); 
        }
    }
}