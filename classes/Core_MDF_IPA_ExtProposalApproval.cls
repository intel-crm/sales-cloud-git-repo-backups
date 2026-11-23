public with sharing class Core_MDF_IPA_ExtProposalApproval {
    
	public static Id ipaCampaignRecordId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Core_MDF_Intel_Partner_Alliance').getRecordTypeId();
	@AuraEnabled
    public static userPermissionApproval loadCampRecord(Id cmpId)
    {
        userPermissionApproval userPermissionApprovalCamp = new userPermissionApproval();
        try{
            system.debug('cmpId::' + cmpId);
            if(cmpId != NULL){
                Campaign cmpval = [SELECT Id, Status, Core_MDF_Approver_1_id__c, Core_MDF_Approver_2_id__c, Core_MDF_Approver_3_id__c,
                                   Core_MDF_Approver_4_id__c, Core_MDF_Approver_5_id__c, Core_MDF_Approver_6_id__c, Core_MDF_Approver_7_id__c,
                                   Core_MDF_Approver_8_id__c, Core_MDF_Approver_9_id__c, Core_MDF_Approver_10_id__c, RecordType.DeveloperName 
                                   FROM Campaign 
                                   WHERE Id =: cmpId 
                                   AND RecordType.DeveloperName =: Label.Core_MDF_IPA_CampClosedRecTypeDevName
                                   AND Status = 'Pending Approval'];
                userPermissionApprovalCamp.cmpInstance = cmpval;
				system.debug('cmpval::' + cmpval);
                // Use featureManagement 
                if (cmpval != NULL){
                    system.debug('Insidecmpval::' + cmpval);
                    Set<Id> approverIdSet = new Set<Id>();
                    approverIdSet.add(cmpval.Core_MDF_Approver_1_id__c);
                    approverIdSet.add(cmpval.Core_MDF_Approver_2_id__c);
                    approverIdSet.add(cmpval.Core_MDF_Approver_3_id__c);
                    approverIdSet.add(cmpval.Core_MDF_Approver_4_id__c);
                    approverIdSet.add(cmpval.Core_MDF_Approver_5_id__c);
                    approverIdSet.add(cmpval.Core_MDF_Approver_6_id__c);
                    approverIdSet.add(cmpval.Core_MDF_Approver_7_id__c);
                    approverIdSet.add(cmpval.Core_MDF_Approver_8_id__c);
                    approverIdSet.add(cmpval.Core_MDF_Approver_9_id__c);
                    approverIdSet.add(cmpval.Core_MDF_Approver_10_id__c);
                    /*String extProposalManagerPS = Label.Core_MDF_IPA_External_Proposal_Manager_Permission_Set;
                    List<PermissionSetAssignment> usrPerList = [SELECT Id, AssigneeId, PermissionSet.Name
                                                            FROM PermissionSetAssignment
                                                            WHERE AssigneeId =:UserInfo.getUserId() AND 
                                                            PermissionSet.Name =: extProposalManagerPS];
                    system.debug('usrPerList::'+usrPerList);*/
                    //if(usrPerList != null && usrPerList.size() > 0 && approverIdSet.contains(UserInfo.getUserId()))
                    if(approverIdSet.contains(UserInfo.getUserId()))
                    {
                        system.debug('insideifcond');
                        userPermissionApprovalCamp.userPermissionsPowerPartner = true;
                    }else{
                        userPermissionApprovalCamp.userPermissionsPowerPartner = false;
                    }
                }else{
                    userPermissionApprovalCamp = null;
                } 
            }
        }catch(Exception e){
            system.debug('e:' + e);
            String errorDetails = Core_MDF_CCP_UtilityClass.getErrorDetails(e); Core_MDF_CCP_UtilityClass.logErrorinLogObject(errorDetails, 'Campaign');                  
        } 
        system.debug('userPermissionApprovalCamp::' +userPermissionApprovalCamp);
        return userPermissionApprovalCamp;
    }
    
    @AuraEnabled
    public static Boolean approveRejectProposal(string buttonName, Id cmpId, Map<Id,Map<String,String>> mapValues,string approvalComments)
    {
        Map<Id,Id>  piList = new Map<Id,Id>();
        List<Id> cmpIds = new List<Id>();
        List<Campaign> cmpsToBeUpdated = new List<Campaign>();

        try {
            /*system.debug('mapvalues::' + mapValues);
            String comment, action, btnName = '';
            for(Id cmpId : mapValues.keySet()){
                cmpIds.add(cmpId);
                Map<String,String> commentStatus = mapValues.get(cmpId);
                for (String commentVal : commentStatus.keySet()){
                    comment = commentVal;
                    btnName = commentStatus.get(comment);
                    break;
                }
            }*/

			system.debug('cmpIds::' + cmpIds);
            for(Campaign cmpInst : [Select Id, Status, RecordType.DeveloperName, 
                                    Core_MDF_Approval_Step_Counter_nbr__c, RecordTypeId                                    
                                    FROM Campaign WHERE Id =:cmpId]){
                cmpIds.add(cmpId);                       
                //Call method to append comments
                system.debug('buttonName::' + buttonName);
                //cmpInst.Core_MDF_External_Approval_Comment_txt__c = populateApproverComments(buttonName,cmpInst.Core_MDF_External_Approval_Comment_txt__c,approvalComments);
                
                if (buttonName == 'Approve'){
                    cmpInst.Status = 'Proposal Accepted';
                    cmpInst.Core_MDF_Approval_Step_Counter_nbr__c = 0;
					cmpInst.RecordTypeId = ipaCampaignRecordId; //'012g0000000AAv7'; //Label.Core_MDF_IPA_RecordType;
                }
                if (buttonName == 'Reject'){
                    cmpInst.Status = 'Revision Required';
                    cmpInst.Core_MDF_Approval_Step_Counter_nbr__c = 0;
                    cmpInst.RecordTypeId = ipaCampaignRecordId; // '012g0000000AAv7'; 
					//cmpInst.RecordType.DeveloperName = Label.Core_MDF_IPA_RecordType;
                }
                cmpsToBeUpdated.add(cmpInst);
            }
            if(cmpsToBeUpdated != NULL && !cmpsToBeUpdated.isEmpty()){
                update cmpsToBeUpdated;
            }

        } catch (Exception e) {string logerror = '';logerror += 'CAMPIDs->' + string.join(cmpIds, ',->');logerror += e.getLineNumber() + '->';logerror += e.getMessage() + '->';Core_MDF_CCP_UtilityClass.logErrorinLogObject(logerror,'approveRejectProposal Method');return false;}
        return true;
    }
    
    public static String populateApproverComments(String buttonType, String previousExternalApprovalComments,String externalApproverComments){
        String externalApprovalRejectionComments = '';
        String concatenateCommentswithApprovalOrRejectionInfo;

        //Appends Approval or Rejection comments with appropriate Info And Not need to concatinate if Approval Comment is blank or null
        if(buttonType.equalsIgnoreCase(Label.Core_MDF_Retail_Approve) && String.isNotBlank(externalApproverComments)){
            //If Approvers Approves Campaign, prefix comments with 'Approval Comments :'
            concatenateCommentswithApprovalOrRejectionInfo = Label.Core_MDF_Retail_Approval_Comments +' '+ externalApproverComments;

        }else if(buttonType.equalsIgnoreCase(Label.Core_MDF_Retail_Reject)){
            //If Approvers Rejects Campaign, prefix comments with 'Reject Comments :'
            concatenateCommentswithApprovalOrRejectionInfo = 'Reject Comments :' +'  ' + externalApproverComments;

        }
        //Check if external comments field of PFR has info, then concatenate the existing comments and new comments
        if(String.isNotBlank(previousExternalApprovalComments)){
            externalApprovalRejectionComments = concatenateCommentswithApprovalOrRejectionInfo +'\n' +previousExternalApprovalComments ;
        }else{
            externalApprovalRejectionComments = concatenateCommentswithApprovalOrRejectionInfo;
        }
        return externalApprovalRejectionComments;
    }
    
    public class userPermissionApproval{
        @AuraEnabled
        public Boolean userPermissionsPowerPartner;
        @AuraEnabled
        public Campaign cmpInstance;
    }
}