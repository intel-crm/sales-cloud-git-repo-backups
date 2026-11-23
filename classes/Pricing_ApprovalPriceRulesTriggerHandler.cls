/**
* @description       : 
* @author            : ChangeMeIn@UserSettingsUnder.SFDoc
* @group             : 
* @last modified on  : 06-27-2025
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class Pricing_ApprovalPriceRulesTriggerHandler extends TriggerHandler {
    public List<Pricing_Approval_Price_Rules__c> priceRulesTriggerNewList = new List<Pricing_Approval_Price_Rules__c>();
    public Map<Id,Pricing_Approval_Price_Rules__c> priceRulesTriggerOldMap = new Map<Id,Pricing_Approval_Price_Rules__c>();
    public static Map<Id, String> ruleIdToStatusMap = new Map<Id, String>();
    
    public Pricing_ApprovalPriceRulesTriggerHandler() {
        if(Trigger.new != null){
            for(Pricing_Approval_Price_Rules__c rule : (List<Pricing_Approval_Price_Rules__c>)Trigger.new){
                priceRulesTriggerNewList.add(rule);
            }
        }
        if(Trigger.old != null){
            for(Pricing_Approval_Price_Rules__c rule : (List<Pricing_Approval_Price_Rules__c>)Trigger.old){
                if(Trigger.oldMap != null){
                    priceRulesTriggerOldMap.put(rule.Id,rule);
                }
            }
        }
    }
    
    public override void beforeInsert(){
        if(!priceRulesTriggerNewList.isEmpty()){
           updatePriceRuleBefore(priceRulesTriggerNewList,Trigger.isInsert,priceRulesTriggerOldMap); 
        }
    }
    public override void afterUpdate(){
        if(!priceRulesTriggerNewList.isEmpty()){
            updateApprovalPriceRules(priceRulesTriggerNewList,Trigger.isInsert,priceRulesTriggerOldMap);
        }
    }
    
    public override void beforeUpdate(){
        if(!priceRulesTriggerNewList.isEmpty()){
            updateRecordTypes(priceRulesTriggerNewList,Trigger.isInsert,priceRulesTriggerOldMap);
        }
    }
    
    public static void updatePriceRuleBefore(List<Pricing_Approval_Price_Rules__c> lstPriceRules, Boolean isInsert, Map<Id,Pricing_Approval_Price_Rules__c> oldMap){
        try{
            if(lstPriceRules.size() > 0){
                if(isInsert){

                    for(Pricing_Approval_Price_Rules__c rule : lstPriceRules){

                        if(rule.Pricing_Rule_Start_Date__c == null){
                            rule.Pricing_Rule_Start_Date__c = Date.today();
                        }
                        if(rule.Pricing_Rule_End_Date__c == null){
                        rule.Pricing_Rule_End_Date__c = Date.today().addMonths(12); 
                        }
                    }
                }
            }
        }
        catch(Exception e){
            Pricing_Tender_Utility.logError(e);
        } 
    }
    
    /**
    * @description : Method called from After insert and After update
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 05-16-2025 
    * @param lstPriceRules 
    * @param isInsert 
    * @param oldMap 
    **/
    public static void updateApprovalPriceRules(List<Pricing_Approval_Price_Rules__c> lstPriceRules, Boolean isInsert,Map<Id,Pricing_Approval_Price_Rules__c> oldMap){
        try{
            if(lstPriceRules.size() > 0){

                if(!isInsert){
                    //update starts
                    Set<Id> approveRejectIds = new Set<Id>();
                    Id ruleId;
                    String errormsg;
                    Map<Id, String> ruleIdToApprovalComments = new Map<Id, String>();
                    List<Pricing_Approval_Price_Rules__c> priceRulesList = new List<Pricing_Approval_Price_Rules__c>();
                    for(Pricing_Approval_Price_Rules__c rule : lstPriceRules){
                        if(oldMap.get(rule.Id).Pricing_Approval_Status__c == Label.Pricing_Tender_Quote_Status_Submitted && (rule.Pricing_Approval_Status__c == Label.Pricing_Tender_Quote_Status_Approved || rule.Pricing_Approval_Status__c == Label.Pricing_Tender_Quote_Status_Rejected)){ 
                            
                            approveRejectIds.add(rule.Id);
                            ruleIdToStatusMap.put(rule.Id,rule.Pricing_Approval_Status__c == Label.Pricing_Tender_Quote_Status_Approved ? 'Approve' : rule.Pricing_Approval_Status__c == Label.Pricing_Tender_Quote_Status_Rejected ? 'Reject' : null );
                        }
                        
                        //update status to pending if any field value is changed
                        if((rule.Pricing_Quote_Type__c != oldMap.get(rule.Id).Pricing_Quote_Type__c || rule.Pricing_Server_Deal_Type_Nm__c != oldMap.get(rule.Id).Pricing_Server_Deal_Type_Nm__c || rule.Pricing_Account__c != oldMap.get(rule.Id).Pricing_Account__c || rule.Pricing_End_Customer_Country__c != oldMap.get(rule.Id).Pricing_End_Customer_Country__c|| rule.Pricing_Form_Factor__c != oldMap.get(rule.Id).Pricing_Form_Factor__c
                            || rule.Pricing_Intel_Account_Exec_Email_Txt__c != oldMap.get(rule.Id).Pricing_Intel_Account_Exec_Email_Txt__c || rule.Pricing_Intel_Sales_Rep_Email_Txt__c != oldMap.get(rule.Id).Pricing_Intel_Sales_Rep_Email_Txt__c || rule.Pricing_Market_Segment_values_Nm__c != oldMap.get(rule.Id).Pricing_Market_Segment_values_Nm__c || rule.Pricing_Maximum_Quantity__c != oldMap.get(rule.Id).Pricing_Maximum_Quantity__c
                            || rule.Pricing_Minimum_Quantity__c != oldMap.get(rule.Id).Pricing_Minimum_Quantity__c || rule.Pricing_Maximum_Requested_Unit_Price__c != oldMap.get(rule.Id).Pricing_Maximum_Requested_Unit_Price__c || rule.Pricing_Minimum_Requested_Unit_Price__c != oldMap.get(rule.Id).Pricing_Minimum_Requested_Unit_Price__c || rule.Pricing_End_Date__c != oldMap.get(rule.Id).Pricing_End_Date__c 
                            || rule.Pricing_Rule_Start_Date__c != oldMap.get(rule.Id).Pricing_Rule_Start_Date__c || rule.Pricing_Rule_End_Date__c != oldMap.get(rule.Id).Pricing_Rule_End_Date__c || rule.Pricing_Region_Nm__c != oldMap.get(rule.Id).Pricing_Region_Nm__c) && (rule.Pricing_Approval_Status__c == Label.Pricing_Tender_Quote_Status_Approved || rule.Pricing_Approval_Status__c == Label.Pricing_Tender_Quote_Status_Rejected)){
                            Pricing_Approval_Price_Rules__c ruleToUpdate = new Pricing_Approval_Price_Rules__c(Id = rule.Id,Pricing_Approval_Status__c = Label.Pricing_Tender_Quote_Status_Draft);
                            priceRulesList.add(ruleToUpdate);
                        }

                        if(oldMap.get(rule.Id).Pricing_Approval_Status__c == rule.Pricing_Approval_Status__c && rule.Pricing_Approval_Status__c == 'Approved' && rule.Pricing_Is_Enabled__c == true){
                            ruleId = rule.Id;
                        }   
                    }
                    
                    if(ruleId != null){
                        Pricing_QuoteLine_AutoApprovalController.isCalledFromTrigger = true;
                        List<String> errormsgList = Pricing_QuoteLine_AutoApprovalController.isOverlapApprovalPriceRule(ruleId);
                        errormsg = String.join(errormsgList, ',');
                        Pricing_QuoteLine_AutoApprovalController.isCalledFromTrigger = false;
                    }

                    for(Pricing_Approval_Price_Rules__c rule : lstPriceRules){
                        if(String.isNotBlank(errormsg) && !errormsg.contains('Success')){
                            rule.addError(Label.Pricing_ApprovalPriceRule_Overlap_Msg + errormsg);   
                        }
                    }
                    if(approveRejectIds.size() >0){
                        //Method to update all other approval records to Approve or reject based on user action
                        updatePendingApprovalRecords(approveRejectIds);
                        
                        //updating approval comments on price rule record
                        updateCommentsOnRule(approveRejectIds,ruleIdToApprovalComments);
                    }
                    
                    update priceRulesList;
                    
                    //creating Approval records to DPM users for Price Rules when editing any field of rule
                }
                
            }
        }
        catch(Exception e){
            Pricing_Tender_Utility.logError(e);
        } 
    }

     @future
    public static void updateCommentsOnRule(Set<Id> approveRejectIds,Map<Id, String> ruleIdToApprovalComments){
        List<Pricing_Approval_Price_Rules__c> priceRulesList = new List<Pricing_Approval_Price_Rules__c>();
        List<ProcessInstanceStep> proInstanceSteps = [SELECT Comments, StepStatus, CreatedDate,ProcessInstance.TargetObjectId FROM ProcessInstanceStep WHERE 
                                                                      ProcessInstance.TargetObjectId =: approveRejectIds AND StepStatus in ('Approved','Rejected') and Comments != null ORDER BY CreatedDate DESC limit 1];
            if (proInstanceSteps.size() > 0) {
                //priceRulesList = [select Id,Pricing_Approval_Rejection_Comments__c from Pricing_Approval_Price_Rules__c where Id =:approveRejectIds ]
                ruleIdToApprovalComments.put(proInstanceSteps[0].ProcessInstance.TargetObjectId, proInstanceSteps[0].Comments);
                for(Pricing_Approval_Price_Rules__c rule : [select Id,Pricing_Approval_Rejection_Comments__c from Pricing_Approval_Price_Rules__c where Id =:approveRejectIds ]){
                rule.Pricing_Approval_Rejection_Comments__c = ruleIdToApprovalComments.containsKey(rule.Id) ? ruleIdToApprovalComments.get(rule.Id) : null;
                priceRulesList.add(rule);
            }
        }
        
        update priceRulesList;
    }
    
    /**
    * @description : Method to Approve/Reject other Approval Records if any one user Approve/reject  
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 05-16-2025 
    * @param approveRejectIds 
    * @param ruleIdToApprovalComments 
    **/
    public static void updatePendingApprovalRecords(Set<Id> approveRejectIds){
        List<Approval.ProcessWorkitemRequest> approvalRequestList = new List<Approval.ProcessWorkitemRequest>();
        Map<Id,List<ProcessInstanceWorkitem>> rulePWItemMap = getProcessInstanceWorkItems(approveRejectIds);
        for(Id ruleId : rulePWItemMap.keySet()){
            for(ProcessInstanceWorkitem workItem : rulePWItemMap.get(ruleId)){
                String action = ruleIdToStatusMap.get(ruleId);
                if(workItem.ActorId == UserInfo.getUserId()){
                    //String actionComments = qliIdtoCommentMap.get(qliId);
                    //approvalRequestList.add(createProcessWorkItemRequest(workItem.Id, action, actionComments));
                }
                else
                {
                    approvalRequestList.add(createProcessWorkItemRequest(workItem.Id, action, null)); 
                }
            }
        }
        if(approvalRequestList.size() > 0){
            Approval.process(approvalRequestList);
        }
    }
     /**
    * @description : Method called from Before update and to Assign Record Types according to Approval Status
    * @author ChangeMeIn@UserSettingsUnder.SFDoc
    * @param lstPriceRules 
    * @param isInsert 
    * @param oldMap 
    **/
    public static void updateRecordTypes(List<Pricing_Approval_Price_Rules__c> lstPriceRules, Boolean isInsert,Map<Id,Pricing_Approval_Price_Rules__c> oldMap){
        if(lstPriceRules.size() > 0){

             Id SubmittedIdApprovalPriceRule = Pricing_Tender_Utility.getRecordTypeId('Pricing_Approval_Price_Rules__c',Label.Pricing_Tender_ApprovalPriceRule_RecordType_ReadOnly);
             Id EditIdApprovalPriceRule = Pricing_Tender_Utility.getRecordTypeId('Pricing_Approval_Price_Rules__c',Label.Pricing_Tender_ApprovalPriceRule_RecordType_Edit);

             for(Pricing_Approval_Price_Rules__c rule : lstPriceRules){
                    if(oldMap.get(rule.Id).Pricing_Approval_Status__c != rule.Pricing_Approval_Status__c && oldMap.get(rule.Id).Pricing_Approval_Status__c == Label.Pricing_Tender_Quote_Status_Draft && rule.Pricing_Approval_Status__c == Label.Pricing_Tender_Quote_Status_Submitted){
			                     rule.RecordTypeId = SubmittedIdApprovalPriceRule;
                    }
                    else{
                            rule.RecordTypeId = EditIdApprovalPriceRule;
                    }
                    
                }
            }
    }                     

        
    
    private static Approval.ProcessWorkitemRequest createProcessWorkItemRequest(Id approvalStepId, String approvalAction, String commentFromApprover){
        Approval.ProcessWorkitemRequest result = new Approval.ProcessWorkitemRequest();
        result.setComments(commentFromApprover);
        result.setAction(approvalAction);
        result.setWorkitemId(approvalStepId);        
        return result;
    }
    
    private static Map<Id,List<ProcessInstanceWorkitem>> getProcessInstanceWorkItems(Set<Id> objectIds) {
        Map<Id,List<ProcessInstanceWorkitem>> qliPWItem = new Map<Id,List<ProcessInstanceWorkitem>>();
        for(ProcessInstanceWorkitem witem : [SELECT Id,ActorId,ProcessInstance.TargetObjectId,OriginalActorId,ProcessInstance.Status FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId IN :objectIds AND (ProcessInstance.Status IN ('Pending','Reassigned'))]){
            if(qliPWItem.containsKey(witem.ProcessInstance.TargetObjectId)){
                qliPWItem.get(witem.ProcessInstance.TargetObjectId).add(witem); 
            }else{
                qliPWItem.put(witem.ProcessInstance.TargetObjectId, new List<ProcessInstanceWorkitem>{witem});
            }
        }
        return qliPWItem;
    }

    /**
    * @description Method to create Approval Records for Business admin users of this label Pricing_ApprovalPriceRule_Approvers.
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 06-24-2025 
    * @param ruleIdToPresentRecordMap 
    **/
    public static void approvalRecordsCreation(Map<Id,Pricing_Approval_Price_Rules__c> ruleIdToPresentRecordMap){
        Set<Id> businessAdminIds = new Set<Id>();
                PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Pricing_Tender_Business_User_Admin' LIMIT 1];
                for(PermissionSetAssignment dpmAssignments : [SELECT AssigneeId FROM PermissionSetAssignment WHERE Assignee.Name In: Label.Pricing_ApprovalPriceRule_Approvers.split(',') And PermissionSetId = :ps.Id]){
                    businessAdminIds.add(dpmAssignments.AssigneeId);
                }
            
        List<Approval.ProcessSubmitRequest> approvalRequestList = new List<Approval.ProcessSubmitRequest>();
        for(Pricing_Approval_Price_Rules__c rule : ruleIdToPresentRecordMap.values()){
            for(Id dpmId : businessAdminIds){
                if(rule.Pricing_Approval_Status__c == 'Submitted'){
                    Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                    req.setObjectId(rule.Id);
                    req.setSubmitterId(UserInfo.getUserId()); // or another user
                    req.setComments('Submitting for approval to DPM users');
                    req.setNextApproverIds(new List<Id>{dpmId});// only one allowed here, unless you use a queue
                    req.setSkipEntryCriteria(false); // make sure criteria are evaluated
                    approvalRequestList.add(req);
                    //Approval.ProcessResult result = Approval.process(req);
                    
                }
            }
        }
        if(approvalRequestList.size() > 0){
            Approval.process(approvalRequestList);
        }
    }
}