public with sharing class Core_MDF_PFR_Approval
{
    /*****************************************************************************************************
    Method Name : loadPFRRecord
    @return     : Object
    @parameters : PFR Record
    Description : US106541 - Create Activity initial screen
    Added By    : Sridhar on 3-Jun-2020
    Modified By : Nuzhath Zaiba                  Date:  14/11/2019                  Changes:None
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
                if (dbPer.PermissionSet.Name.contains(Label.Core_MDF_Retail_Reviewer_Permission_Set) && UserInfo.getUserType() != 'PowerPartner')
                {
                    userPermissionApprovalPFR.userPermissionsPowerPartner = false;
                }
                else if (dbPer.PermissionSet.Name.contains(Label.Core_MDF_External_Activity_Approver_PermissionSet) && UserInfo.getUserType() == 'PowerPartner'){userPermissionApprovalPFR.userPermissionsPowerPartner = true;
                }
            }

            userPermissionApprovalPFR.approverAssigned = isApproverAssigned(pfrId,userId,userPermissionApprovalPFR.userPermissionsPowerPartner);
            userPermissionApprovalPFR.pfrMapInstance = new Map<Id,Map<String,String>>();
            userPermissionApprovalPFR.statusMapInstance = new Map<String,String>();
        }
        else{userPermissionApprovalPFR = null;
        }
        // system.debug('PermissionSetAssignment--->'+userPerSets.PermissionSet.Name);
        return userPermissionApprovalPFR;
    }

    /*****************************************************************************************************
    Method Name :  Update PFR Record on Approval (Updates status to planned when External User Approves)
    Added By    : Sridhar on 3-Jun-2020
    Modified By : Nuzhath Zaiba                  Date:  14/11/2019                  Changes:None
    ******************************************************************************************************/
    @AuraEnabled
    public static Boolean submitForApproval(List<Id> pfrIds)
    {
        Map<id,PartnerFundRequest> mapPfr = new Map<id,PartnerFundRequest>();
        List<PartnerFundRequest> listPfr = new List<PartnerFundRequest>();
        List<PartnerFundRequest> pfrvals = new List<PartnerFundRequest>();
        String queryFields = '';
        String querystr = '';
        Boolean isSubmitted = false;
        try
        {
            // Read the field names from fieldset and query the values
            Schema.FieldSet fieldSet = SObjectType.PartnerFundRequest.FieldSets.Core_MDF_Approval_Field_Set;

            if (fieldSet != null){

                List<String> fields = new  List<String>();

                for(FieldSetMember field: fieldSet.getFields()) {
                    fields.add(field.getFieldPath());
                }
                queryFields = String.join(fields,',');

                querystr = String.format(
                    'SELECT {0} FROM {1} where id IN :pfrIds',
                    new List<String>{
                        String.escapeSingleQuotes(queryFields),
                            String.escapeSingleQuotes('PartnerFundRequest')
                            }
                );

                System.debug('submitForApproval->querystr->' + querystr);
                pfrvals = Database.query(querystr);

                for (PartnerFundRequest pfrl : pfrvals){
                    mapPfr.put(pfrl.Id,pfrl); listPfr.add(pfrl);
                }

                Core_MDF_ProcessCCP_PartnerFundRequest.callApprovalProcess( mapPfr, listPfr, null,true);
            }

            isSubmitted = true;

        } catch (Exception e){ string errorlog = 'Submit for approval failed for activities->' + pfrIds + '-> Error->' + e; Core_MDF_CCP_UtilityClass.logErrorinLogObject(errorlog,'submitForApproval Method'); throw e;}
        return isSubmitted;
    }

    /*****************************************************************************************************
    Method Name :  isApproverAssigned (Verify the assigned approvers from process instance object)
    Added By    : Sridhar on 3-Jun-2020
    Modified By : Nuzhath Zaiba                  Date:  14/11/2019                  Changes:None
    ******************************************************************************************************/

    @AuraEnabled
    public static Boolean isApproverAssigned(String pfrId, Id userId, Boolean isPartnerUser)
    {
        if (isPartnerUser){return [SELECT Id, TargetObjectId, Status, (select actorid from Workitems where actorid =: userId) FROM ProcessInstance WHERE TargetObjectId =: pfrId and Status =: 'Pending' limit 1].size() > 0;
                           //ProcessInstance processInsItem = [SELECT Id, TargetObjectId, Status, (select actorid from Workitems where actorid =: userId) FROM ProcessInstance WHERE TargetObjectId =: pfrId and Status =: 'Pending' limit 1];

                          }
        else{
            ProcessInstance[] processInsItem = [SELECT Id, TargetObjectId, Status FROM ProcessInstance WHERE TargetObjectId =: pfrId and Status =: 'Pending' limit 1];
            return processInsItem.size() > 0;

        }
    }

    /*****************************************************************************************************
    Method Name : approveRejectActivity (Handle the submit or reject actions)
    Added By    : Sridhar on 3-Jun-2020
    Modified By : Nuzhath Zaiba                  Date:  14/11/2019                  Changes:None
    ******************************************************************************************************/
    @AuraEnabled
    public static Boolean approveRejectActivity(Map<Id,Map<String,String>> mapValues,string approvalComments)
    {
        Map<Id,Id>  piList = new Map<Id,Id>();
        List<Id> pfrIds = new List<Id>();
        List<PartnerFundRequest> pfrsToBeUpdated = new List<PartnerFundRequest>();

        try {
            for(Id pfrId : mapValues.keySet()){
                pfrIds.add(pfrId);
            }

            //System.debug('##pfrIds->' + pfrIds);
            for(ProcessInstanceWorkItem piwitm : [SELECT ProcessInstance.TargetObjectId, Id FROM ProcessInstanceWorkItem
                                                  WHERE ProcessInstance.Status = 'Pending' AND ActorId = :UserInfo.getUserId() and ProcessInstance.TargetObjectId IN:pfrIds]){piList.put(piwitm.ProcessInstance.TargetObjectId, piwitm.Id);
            }
            String comment, action, btnName = '';
            //for(PartnerFundRequest pfrInst : [Select Id, Core_MDF_External_Approval_Comment_txt__c,Core_MDF_Fund_Request_Status__c FROM PartnerFundRequest WHERE Id IN :piList.keySet()]){
            for(Id pfrId : piList.keySet()) { Map<String,String> commentStatus = mapValues.get(pfrId);for (String commentVal : commentStatus.keySet()){comment = commentVal;btnName = commentStatus.get(comment);if (btnName != 'Decline'){action = btnName;}else if (btnName == 'Decline'){action = 'Reject';comment = 'Recalled';}break;}Approval.ProcessResult processResult = null;Approval.ProcessWorkitemRequest aprReq = new Approval.ProcessWorkitemRequest();aprReq.setComments(comment);aprReq.setAction(action);aprReq.setWorkitemId(piList.get(pfrId));aprReq.setNextApproverIds(new Id[] {UserInfo.getUserId()});processResult = Approval.process(aprReq);
                if (processResult != null && !processResult.isSuccess()){string errorlog = 'Approval failed for activiy ->' + pfrId + ';' ; for(Database.Error errDet : processResult.getErrors()){errorlog += errDet.getMessage();} Core_MDF_CCP_UtilityClass.logErrorinLogObject(errorlog,'approveRejectActivity Method');return false;}
           
            }
            for(PartnerFundRequest pfrInst : [Select Id, Core_MDF_External_Approval_Comment_txt__c,Core_MDF_Fund_Request_Status__c FROM PartnerFundRequest WHERE Id IN :piList.keySet()]){
                //Call method to append comments
                pfrInst.Core_MDF_External_Approval_Comment_txt__c = populateApproverComments(btnName,pfrInst.Core_MDF_External_Approval_Comment_txt__c,approvalComments);if (btnName == 'Decline'){pfrInst.Core_MDF_Fund_Request_Status__c = 'Revision Required';pfrInst.Core_MDF_Approval_Step_Completed__c = 0;
                }
                pfrsToBeUpdated.add(pfrInst);
            }
            
            if(pfrsToBeUpdated != NULL && !pfrsToBeUpdated.isEmpty()){update pfrsToBeUpdated;
            }

        } catch (Exception e) {string logerror = '';logerror += 'PFRIDs->' + string.join(pfrIds, ',->');logerror += e.getLineNumber() + '->';logerror += e.getMessage() + '->';Core_MDF_CCP_UtilityClass.logErrorinLogObject(logerror,'approveRejectActivity Method');return false;}
        return true;
    }

    /*****************************************************************************************************
    Method Name :   populateApproverComments
    @return     :   String
    @parameters :   String - buttonType
    String - existingApprovalComments
    String - approvalComments
    Description :   The method concatenates Approve or Rejection informatio along with approval comments and with existing comments(if present)
    Created By  :   Nuzhath Zaiba                  Date:  04/15/2020
    ******************************************************************************************************/
    public static String populateApproverComments(String buttonType, String previousExternalApprovalComments,String externalApproverComments){
        String externalApprovalRejectionComments = '';
        String concatenateCommentswithApprovalOrRejectionInfo;

        //Custom Label used below
        //Core_MDF_Retail_Approve - approve
        //Core_MDF_Activity_Decline  - Decline,
        //Core_MDF_Retail_Approval_Comments - Approval Comments : , Core_MDF_Activity_Decline_Comments - Decline Comments : ,

        //Appends Approval or Rejection comments with appropriate Info And Not need to concatinate if Approval Comment is blank or null
        if(buttonType.equalsIgnoreCase(Label.Core_MDF_Retail_Approve) && String.isNotBlank(externalApproverComments)){
            //If Approvers Approves Activity prefix comments with 'Approval Comments :'
            concatenateCommentswithApprovalOrRejectionInfo = Label.Core_MDF_Retail_Approval_Comments +' '+ externalApproverComments;

        }else if(buttonType.equalsIgnoreCase(Label.Core_MDF_Activity_Decline_Nm)){
            //If Approvers DEclines Activity prefix comments with 'Decline Comments :'
            concatenateCommentswithApprovalOrRejectionInfo = Label.Core_MDF_Activity_Decline_Comments +'  ' + externalApproverComments;

        }
        //Check if external comments field of PFR has info, then concatenate the existing comments and new comments
        if(String.isNotBlank(previousExternalApprovalComments)){
            externalApprovalRejectionComments = concatenateCommentswithApprovalOrRejectionInfo +'\n' +previousExternalApprovalComments ;
        }else{
            externalApprovalRejectionComments = concatenateCommentswithApprovalOrRejectionInfo;
        }
        return externalApprovalRejectionComments;
    }


    /*****************************************************************************************************
    Method Name :   userPermissionApproval (Created a Wrapper to reduce the server side call)
    Added By    : Sridhar on 3-Jun-2020
    Modified By : Nuzhath Zaiba                  Date:  14/11/2019                  Changes:None
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
        @AuraEnabled
        public Boolean isUserApprover;
    }
}