public with sharing class Core_MDF_PFR_Approval 
{

    /***************************************************************************************************** 
    Method Name : loadPFRRecord
    @return     : Object
    @parameters : PFR Record
    Description : US106541 - Create Activity initial screen
    Added By    : Nuzhath Zaiba 14/11/2019
    Modified By :                      Date:                    Changes:None                                
    ******************************************************************************************************/
    
    @AuraEnabled
    public static userPermissionApproval loadPFRRecord(String pfrId)
    {
            userPermissionApproval userPermissionApprovalPFR = new userPermissionApproval();
            List<String> pfrIds = new List<String>();
            pfrIds.add(pfrId);
            PartnerFundRequest pfrval = [SELECT Id,Core_MDF_Region_cd__c,Core_MDF_Fund_Request_Status__c,recordtype.developername FROM PartnerFundRequest where Id IN: pfrIds];
            userPermissionApprovalPFR.pfrInstance = pfrval;
            //System.debug('userPermissionApprovalPFR.pfrInstance-' +userPermissionApprovalPFR.pfrInstance);
            String userId = UserInfo.getUserId();
            List<PermissionSetAssignment> userPerSets = new List<PermissionSetAssignment>();
            //System.debug('userId->' + userId);
            
        	if (pfrval.recordtype.developername == Label.Core_MDF_Retail_Record_Type_Developer_Name){
                userPerSets = [SELECT PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId = :userId];
                for(PermissionSetAssignment dbPer : userPerSets)
                {
                    if (dbPer.PermissionSet.Name.contains(Label.Core_MDF_Retail_AM_PermissionSet) && UserInfo.getUserType() != 'PowerPartner')
                    {
                        userPermissionApprovalPFR.userPermissionsPowerPartner = false;
                    }
                    else if (dbPer.PermissionSet.Name.contains(Label.Core_MDF_External_Activity_Approver_PermissionSet) && UserInfo.getUserType() == 'PowerPartner')
                    {
                        userPermissionApprovalPFR.userPermissionsPowerPartner = true;
                    }
                }
                
                userPermissionApprovalPFR.approverAssigned = isApproverAssigned(pfrId);
                userPermissionApprovalPFR.pfrMapInstance = new Map<Id,Map<String,String>>();
                userPermissionApprovalPFR.statusMapInstance = new Map<String,String>();
            }
            else{
                userPermissionApprovalPFR = null;
            }
    	 // system.debug('PermissionSetAssignment--->'+userPerSets.PermissionSet.Name);
        return userPermissionApprovalPFR;   
    }
  
     /***************************************************************************************************** 
    Method Name :  Update PFR Record on Approval (Updates status to planned when External User Approves)
    Added By    :    Accenture - NZ 14/11/2019
    Modified By :                      Date:                  Changes:None  
    ******************************************************************************************************/
    @AuraEnabled
    public static Boolean submitForApproval(List<Id> pfrIds)
    {
        Map<id,PartnerFundRequest> mapPfr = new Map<id,PartnerFundRequest>();
        List<PartnerFundRequest> listPfr = new List<PartnerFundRequest>();
        List<PartnerFundRequest> pfrvals = new List<PartnerFundRequest>();
        try 
        {
            //system.debug('##pfrIds->' + pfrIds);
            pfrvals = [SELECT Id,RecordTypeId, Core_MDF_Region_cd__c, Core_MDF_Fund_Request_Status__c, Core_MDF_Program__c,
                        RequestedAmount,CampaignId,Core_MDF_End_Date__c,Core_MDF_Start_Date__c,Core_MDF_Sub_Region_cd__c,Core_MDF_Approval_Step_Completed__c,
                        Core_MDF_Approver_1__c,Core_MDF_Approver_2__c,Core_MDF_Approver_3__c,Core_MDF_Approver_4__c,Core_MDF_Approver_5__c,
                        Core_MDF_Approver_6__c,Core_MDF_Approver_7__c,Core_MDF_Approver_8__c,Core_MDF_Approver_9__c,Core_MDF_Approver_10__c,Core_MDF_Country_nm__c,
                        Core_MDF_PriorValueOfStatus__c,Core_MDF_Country__c
                        FROM PartnerFundRequest where Id IN: pfrIds];

            for (PartnerFundRequest pfrl : pfrvals){ mapPfr.put(pfrl.Id,pfrl); listPfr.add(pfrl);
            }

            //system.debug('##mapPfr->' + mapPfr);
            //system.debug('##listPfr->' + listPfr);
            Core_MDF_ProcessCCP_PartnerFundRequest.callApprovalProcess( mapPfr, listPfr, null,true);
        } catch (Exception e) 
        { return false;}
        return true;
    }
    
    @AuraEnabled
    public static Boolean isApproverAssigned(String pfrId)
    {
        
        List<Id> assignedRecords = new List<Id>();
        List<String> ids = new List<String>();

        ids.add(pfrId);
        for (ProcessInstance pi: [SELECT Id, TargetObjectId, Status FROM ProcessInstance
                WHERE TargetObjectId IN: ids and Status != 'Removed']) { assignedRecords.add(pi.TargetObjectId);
        }

        if (assignedRecords.size() > 0){ return true;
        }
        else{
            return false;
        }
    }

    @AuraEnabled
    public static Boolean approveRejectActivity(Map<Id,Map<String,String>> mapValues)
    {
        Map<Id,Id>  piList = new Map<Id,Id>();
        List<Id> pfrIds = new List<Id>();

        try {
                //System.debug('##pfrIds->' + pfrIds);
                
                for(Id pfrId : mapValues.keySet()){
                    pfrIds.add(pfrId);
                }

                for(ProcessInstanceWorkItem piwitm : [SELECT ProcessInstance.TargetObjectId, Id FROM ProcessInstanceWorkItem 
                                            WHERE ProcessInstance.Status = 'Pending' AND ActorId = :UserInfo.getUserId() and ProcessInstance.TargetObjectId IN:pfrIds])
                {   
                    piList.put(piwitm.ProcessInstance.TargetObjectId, piwitm.Id);
                }

                for (Id pfrId : piList.keySet())
                {
                    String comment = '';
                    String action = '';
                    // Expect only one value from this map so wrote the code to break the for loop
                    Map<String,String> commentStatus = mapValues.get(pfrId);
                    
                    for (String commentVal : commentStatus.keySet()){
                        comment = commentVal;
                        action = commentStatus.get(comment);
                        break;
                    }
                    Approval.ProcessWorkitemRequest aprReq = new Approval.ProcessWorkitemRequest();
                    aprReq.setComments(comment);
                    aprReq.setAction(action);
                    aprReq.setNextApproverIds(new Id[] {UserInfo.getUserId()});
                    // Use the ID from the newly created item to specify the item to be worked  
                    aprReq.setWorkitemId(piList.get(pfrId));
                    // Submit the request for approval  
                    Approval.ProcessResult result2 =  Approval.process(aprReq);
                    
                    if (!result2.isSuccess()){
                        string errorlog = 'Approval failed for activiy ->' + pfrId;
                        Core_MDF_CCP_UtilityClass.logErrorinLogObject(errorlog,'approveRejectActivity Method');
                        return false;
                    }
                    //System.debug('##resuklt->' + result2);
                }
            
        } catch (Exception e) {string logerror = '';logerror += 'PFRIDs->' + string.join(pfrIds, ',->');logerror += e.getLineNumber() + '->';logerror += e.getMessage() + '->';Core_MDF_CCP_UtilityClass.logErrorinLogObject(logerror,'approveRejectActivity Method');return false;}
        return true;
    }

    /***************************************************************************************************** 
    Method Name :   userPermissionApproval (Created a Wrapper to reduce the server side call)
    Added By   :    Accenture - NZ 14/11/2019
    Modified By:                      Date:                   Changes:None  
    ******************************************************************************************************/
    public class userPermissionApproval{
        @AuraEnabled   
        public Boolean userPermissionsPowerPartner;
        @AuraEnabled 
        public PartnerFundRequest pfrInstance;
        @AuraEnabled 
        public Boolean approverAssigned;
        @AuraEnabled 
        public Map<Id,Map<String,String>> pfrMapInstance;
        @AuraEnabled
        public Map<String,String> statusMapInstance;
    }
    
}