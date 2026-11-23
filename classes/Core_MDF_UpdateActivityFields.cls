/****************************************************************************************************** 
Class Name:         Core_MDF_UpdateActivityFields
@parameters:        N/A
Description:        Before Insert/Upadte call these functions and update the activity to be closed date
Added By:           Sridhar   06-17-2019
Modified By:        Date:           Changes:
Shivaprasad         08-29-2019      Added the condition to check closed status of PFR records in populateBackEndFieldsUpdate method.
Ayush               12-18-2024      Added changes for "Reclaiming SF Partner License"
*******************************************************************************************************/
public without sharing class Core_MDF_UpdateActivityFields {
    
    public static void getActivityRejectionComments(List<flowInputs> inputIdList){
        Set<Id> pfrIDSet = new Set<Id>();
        Set<Id> acctIdSet = new Set<Id>();
        // Highlight: Unused Local Variable - 14285
        // Map<Id,String> pfrIdCommentsMap = new Map<Id,String>();
        Map<Id,String> pfrIdmemberIdMap = new Map<ID,String>();
        List<PartnerFundRequest> ipaPFRList = new List<PartnerFundRequest>();
        List<PartnerFundRequest> pfrList = new List<PartnerFundRequest>();
        Map<Id,List<ProcessInstanceStep>> piAndListofPiStepMap = new Map<Id,List<ProcessInstanceStep>>();
        Map<Id,Id> pfrIdProcessInstId = new Map<Id,Id>();
        // Highlight: Unused Local Variable - 14285
        // Set<Id> stepNodeIdSet = new Set<Id>();
        
        Map<Id,String> stepNodeIdStepNameMap = new Map<Id,String>();
        
        // Highlight: Unused Local Variable - 14285
        // Map<Id,List<String>> actorIDPermSetMap = new map<Id,List<String>>();
        List<Id> processDefList = new List<id>();
        Boolean priceReviewerFlag = FeatureManagement.checkPermission('Core_MDF_PriceReviewer');
        List<Id> pfrIdList = new List<Id>();
        Map<Id,Boolean> userActiveMap = new Map<Id,Boolean>(); 
        try{
            //Ayush - getting PFR Id's in a list for quering relationship fields below
            for(flowInputs pfr : inputIdList){
                pfrIdList.add(pfr.pfrId);
            }
            if(!pfrIdList.isEmpty()){
                //Ayush - quering if createdby user of member user is active or is partner liscence reclaimed and storing in a map of PFRId to boolean.
                for(PartnerFundRequest pfrRecord : [SELECT Id, CreatedById, CreatedBy.IsActive, CreatedBy.Partner_License_Reclaimed__c, Core_MDF_Member_Acceptor_Id__c, Core_MDF_Member_Acceptor_Id__r.IsActive, Core_MDF_Member_Acceptor_Id__r.Partner_License_Reclaimed__c 
                                                    FROM PartnerFundRequest WHERE Id IN: pfrIdList ]){
                                                    
                                                    // Flatten nested IF statements for CreatedById user active check
                                                     //US - TWC702-14285: Flatten nested IFs (no logic change)
                                                    if(pfrRecord.CreatedById != null && !userActiveMap.containsKey(pfrRecord.CreatedById)){
                                                        Boolean isActive = pfrRecord.CreatedBy.IsActive || pfrRecord.CreatedBy.Partner_License_Reclaimed__c;
                                                        userActiveMap.put(pfrRecord.CreatedById, isActive);
                                                    }
                                                    
                                                    // Flatten nested IF statements for Core_MDF_Member_Acceptor_Id__c user active check
                                                     //US - TWC702-14285: Flatten nested IFs (no logic change)
                                                    if(pfrRecord.Core_MDF_Member_Acceptor_Id__c != null && !userActiveMap.containsKey(pfrRecord.Core_MDF_Member_Acceptor_Id__c)){
                                                        Boolean isActive = pfrRecord.Core_MDF_Member_Acceptor_Id__r.IsActive || pfrRecord.Core_MDF_Member_Acceptor_Id__r.Partner_License_Reclaimed__c;
                                                        userActiveMap.put(pfrRecord.Core_MDF_Member_Acceptor_Id__c, isActive);
                                                    }
                                                }
            }

            for(flowInputs pfr : inputIdList){    
                pfrIDSet.add(pfr.pfrId);
                if(pfr.program == 'Intel Partner Alliance' && pfr.proposalBasedIndicator == false && pfr.createdByExternal == true && pfr.pfrStatus == 'Revision Required'){
                    //Ayush - Added Activity's Created by user's active or is Manually Deactivated check for "Reclaiming SF Partner License" 
                    if(!userActiveMap.isEmpty() && userActiveMap.containsKey(pfr.createdById) && userActiveMap.get(pfr.createdById) == true){
                        pfrIdmemberIdMap.put(pfr.pfrId,pfr.createdById);    
                    }
                }
                else{
                    //Ayush - Added Activity's memberId's active or is Manually Deactivated check for "Reclaiming SF Partner License" 
                    if(pfr.memberId != null && pfr.memberId !='' && (!userActiveMap.isEmpty() && userActiveMap.containsKey(pfr.memberId) && userActiveMap.get(pfr.memberId) == true)){
                        pfrIdmemberIdMap.put(pfr.pfrId,pfr.memberId);
                    }
                }
            }
            
            for(ProcessInstance pi : [SELECT Id,TargetObjectId, Status, ProcessDefinitionId, (SELECT Id, StepStatus, Comments, ActorId, StepNodeId FROM Steps WHERE StepStatus = 'Rejected' Order By CreatedDate ASC Limit 1) FROM ProcessInstance 
                                      WHERE TargetObjectId IN :pfrIDSet order by createdDate desc]){
                                          if(!pfrIdProcessInstId.containsKey(pi.TargetObjectId)){
                                              pfrIdProcessInstId.put(pi.TargetObjectId, pi.Id);  
                                          }
                                          piAndListofPiStepMap.put(pi.Id,pi.Steps);
                                          processDefList.add(pi.ProcessDefinitionId);
                                      }
            if(processDefList != null && processDefList.size() > 0){
                for(ProcessNode pn : [Select Id,Name, ProcessDefinition.Description From ProcessNode Where ProcessDefinition.Id IN :processDefList]){
                    stepNodeIdStepNameMap.put(pn.Id, pn.Name);
                }
            }
             //US - TWC702-14285: Flatten nested IFs (no logic change)
            if (piAndListofPiStepMap == null || piAndListofPiStepMap.size() == 0) {
                return; // or continue with next operation
            }

            for (Id pfr : pfrIDSet) {
                PartnerFundRequest p = new PartnerFundRequest();
                p.Id = pfr;
                
                // Early exit if no process instance ID exists
                 //US - TWC702-14285: Flatten nested IFs (no logic change)
                if (!pfrIdProcessInstId.containsKey(p.Id) || pfrIdProcessInstId.get(p.Id) == null) {
                    continue;
                }
                
                Id processInstanceId = pfrIdProcessInstId.get(p.Id);
                
                // Early exit if no process instance steps exist
                 //US - TWC702-14285: Flatten nested IFs (no logic change)
                if (!piAndListofPiStepMap.containsKey(processInstanceId) || piAndListofPiStepMap.get(processInstanceId) == null) {
                    continue;
                }
                
                for (ProcessInstanceStep pistep : piAndListofPiStepMap.get(processInstanceId)) {
                    // Only process rejected steps
                     //US - TWC702-14285: Flatten nested IFs (no logic change)
                    if (pistep.StepStatus != 'Rejected') {
                        continue;
                    }
                    
                    String stepName = stepNodeIdStepNameMap.get(pistep.StepNodeId);
                    
                    // Handle non-Price Reviewer steps
                     //US - TWC702-14285: Flatten nested IFs (no logic change)
                    if (stepName != 'Price Reviewer') {
                        p.Core_MDF_Rejection_Comments_txt__c = pistep.Comments != null ? pistep.Comments : '';
                        pfrList.add(p);
                        continue;
                    }
                    
                    // Handle Price Reviewer steps
                     //US - TWC702-14285: Flatten nested IFs (no logic change)
                    if (priceReviewerFlag) {
                        p.Core_MDF_Rejection_Comments_txt__c = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_PCTApprover_GenericComment');
                    } else {
                        p.Core_MDF_Rejection_Comments_txt__c = pistep.Comments;
                    }
                    pfrList.add(p);
                }
            }
            List<PartnerFundRequest> activityList = [Select Id,ChannelPartnerId,Core_MDF_Approval_Step_Completed__c,Core_MDF_Fund_Request_Status__c,Core_MDF_Program__c,Core_MDF_Internal_Approval_Comment_txt__c,Core_MDF_Proposal_Based_Ind__c
                                                     FROM PartnerFundRequest 
                                                     WHERE Id IN:pfrIDSet];
            if(activityList!= null && activityList.size()>0){
                for(PartnerFundRequest pfr1 : activityList){
                    acctIdSet.add(pfr1.ChannelPartnerId);
                    if(pfr1.Core_MDF_Program__c =='Intel Partner Alliance' && pfr1.Core_MDF_Proposal_Based_Ind__c == false && pfr1.Core_MDF_Fund_Request_Status__c =='Pending Approval'){
                        ipaPFRList.add(pfr1);
                    }
                }
            }
            Database.update(pfrList,false);
            if(ipaPFRList != null){
                Core_MDF_ProcessCCP_PartnerFundRequest.notifyExternalReviewers(ipaPFRList,acctIdSet);
            }
            
            //Ayush - Added pfrIdmemberIdMap null checks 
            if(pfrIdmemberIdMap != null && !pfrIdmemberIdMap.isEmpty()){
                notifyExternalUsers(pfrIdmemberIdMap);
            }             
        }catch(Exception e){
            Core_MDF_CCP_UtilityClass.logError(e);
        }
    }
    
    @Invocablemethod(label='Get PFR records updated to Revision Required' category='PartnerFundRequest')
    public static void sendNotificationOnRRPA(List<notificationWrapperInput> inputIdList){
        List<flowInputs> flwInputList = new List<flowInputs>();
        if(inputIdList != NULL && inputIdList.Size() > 0){
            for(notificationWrapperInput notiWrap : inputIdList){
                for(Core_MDF_FlowInputWrapper flwImputWrap : notiWrap.flowInputWrapperList){
                    flowInputs flwInput = new flowInputs();
                    flwInput.pfrId = flwImputWrap.recordId;
                    flwInput.memberId = flwImputWrap.memberOfActivity;
                    flwInput.program = flwImputWrap.program;
                    flwInput.proposalBasedIndicator = flwImputWrap.proposalBasedIndicator;
                    flwInput.createdByExternal = flwImputWrap.createdByExternal;
                    flwInput.createdById = flwImputWrap.createdById;
                    flwInput.pfrStatus = flwImputWrap.status;
                    flwInputList.add(flwInput);
                }
            }
        }
        
        if(flwInputList != NULL && flwInputList.Size() > 0){
            getActivityRejectionComments(flwInputList);
        }
    }
    
    public static void notifyExternalUsers(Map<Id,Id> activityIdmemberIdMap){
        try{
            
            Id extUser;
            List<Core_MDF_GenericClassToSendMail.MailParams> inputList = new List<Core_MDF_GenericClassToSendMail.MailParams>();
            for(Id pfrId : activityIdmemberIdMap.keySet()){
                List<Id> extUserList = new List<Id>();
               
                extUser = activityIdmemberIdMap.get(pfrId);
                extUserList.add(extUser);
                
                Core_MDF_GenericClassToSendMail.MailParams sendEmailToExt = new Core_MDF_GenericClassToSendMail.MailParams();
                sendEmailToExt.recordId = pfrId;
               
                sendEmailToExt.templateName = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_NotifyRejectionComments_ExtUser');
                sendEmailToExt.userIdList = extUserList;
                sendEmailToExt.sendDiff = false;
                inputList.add(sendEmailToExt);
            }
            if(inputList != NULL && inputList.size() >0){
                Core_MDF_GenericClassToSendMail.sendEmailMethod(inputList);
            }
            
        }catch(Exception e){
            Core_MDF_CCP_UtilityClass.logError(e);
        }
    }
    
    public class notificationWrapperInput{
        @InvocableVariable
        public List<Core_MDF_FlowInputWrapper> flowInputWrapperList;
    }
    public class flowInputs{
        @InvocableVariable(label='PartnerFundRequest Id')
        public Id pfrId;
        
        @InvocableVariable(label='Member Activity Owner Id of PFR')
        public String memberId;
        
        @InvocableVariable(label='Program of PFR')
        public String program;
        
        @InvocableVariable
        public Boolean proposalBasedIndicator;
        
        @InvocableVariable
        public Boolean createdByExternal;
        
        @InvocableVariable
        public String createdById;
        
        @InvocableVariable
        public String pfrStatus;
    }
}