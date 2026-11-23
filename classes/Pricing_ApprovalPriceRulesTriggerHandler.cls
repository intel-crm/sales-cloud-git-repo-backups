/**
* @description       : 
* @author            : ChangeMeIn@UserSettingsUnder.SFDoc
* @group             : 
* @last modified on  : 06-17-2026
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
                            //rule.Pricing_Minimum_Requested_Unit_Price__c = 1;
                            //rule.Pricing_Minimum_Quantity__c = 1;
                            
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


    @AuraEnabled
    public static String processRecords(String base64Data, String objectName, String recordId){
        Map<String, Pricing_Product_Floor_Price__c> floorPriceMap = New Map<String, Pricing_Product_Floor_Price__c>();
        objectName=(objectName==null?objectName:String.escapeSingleQuotes(objectName));
        String data =JSON.deserializeUntyped(base64Data).toString();
        data=String.escapeSingleQuotes(data);
        List<String> lstCSVLines = data.split('\n');
        Map<String,Id> prodNameToIdMap = new Map<String,Id>();
        Map<Id,String> prodIdToNameMap = new Map<Id,String>();
        Set<String> productNames = new Set<String>();
        integer errorRow = 0;
        try{
            for (Integer i=1;i<lstCSVLines.size();i++){
                String input = lstCSVLines[i];
                if(input.contains('"')){
                    List<String> parts = input.split('"');
                    // Safety check
                    if (parts.size() == 3 && parts[1] != null) {
                        productNames.add(parts[1]);
                        }
                }else {
                    productNames.add(input.split(',')[0]);
                }       
            }
            if(productNames.size() > 0){
                List<String> lobValuesList = Label.Pricing_LOB_Values.split(',');
                for(Product2 prod : [Select Id,Name from Product2 where Name In: productNames and (IsActive = true AND Core_Product_Org__c = 'Sales' AND Core_Sales_Visible_Flag__c = true AND Core_Hierarchy_ID__c = '43' AND Core_Processor_Number_Nm__c != null AND ((Core_VerticalSegment__c in ('Mobile','Desktop','Workstation','Embedded') OR Core_Cross_Selling_Product_Type_Nm__c = 'Client') OR(
                                        Core_Product_Type__c in ('Processors','Partnered Products') AND (Core_Line_of_Business__c IN : lobValuesList OR Name Like '%Intel® Xeon®%')  AND Core_Product_Group_EPM_ID__c = null )))]){
                    prodNameToIdMap.put(prod.Name,prod.Id);
                    prodIdToNameMap.put(prod.Id,prod.Name);
                }
            }
            for (Integer i=1;i<lstCSVLines.size();i++){
                errorRow = i;
                String input = lstCSVLines[i];
                list<String> columnValues = new list<String>(splitValues(input));
                Pricing_Product_Floor_Price__c floorPrice = New Pricing_Product_Floor_Price__c();
                if(prodNameToIdMap.size() > 0 && prodNameToIdMap.containsKey(((columnValues[0]).replace('"','')))){
                    floorPrice.Pricing_Product__c = prodNameToIdMap.get((columnValues[0]).replace('"',''));
                }
                
                floorPrice.Pricing_Approved_ECAP_Price__c = String.isBlank((columnValues[1]).replace('"',''))? Null : Decimal.valueOf((columnValues[1]).replace('"',''));
                String isActive = columnValues[2].replace('"','').trim().toLowerCase();
                floorPrice.Pricing_Active__c = String.isBlank(isActive) ? false : Boolean.valueOf(isActive);
                if((columnValues[0]).replace('"','').trim() != null && (columnValues[0]).replace('"','').trim() != '' ){
                    floorPriceMap.put((columnValues[0]).replace('"','').trim(),floorPrice);
                }
               
            }
           Pricing_BulkProductFloorPriceBatch bulkProductFloorPrice = new Pricing_BulkProductFloorPriceBatch(floorPriceMap, recordId, prodIdToNameMap);
           Database.executeBatch(bulkProductFloorPrice, Integer.valueOf(Label.Pricing_Bulk_Comp_Product_Price_BatchSize));
        } catch (Exception e) {
            errorRow = errorRow +1;
            return 'Error while uploading File - On Row: '+errorRow+' - '+e;
        }        
        return 'Operation Completed';  
    }

    public static List<String> splitValues(String input){
        list<String> columnValues = new list<String>();
        boolean isReplaceComma = input.contains('"');
                if(isReplaceComma){
                    List<String> parts = input.split('"');
                    String updatedString = '';
                    // Safety check
                    if (parts.size() == 3) {
                        String quotedPart = parts[1];       // product name is will have
                        String remainingData = parts[2]; // Everything after the quoted part, starts with comma like : ,55,TRUE
                        quotedPart = quotedPart.contains(',') ? quotedPart.replaceAll(',','#') : quotedPart;
                        updatedString = quotedPart+remainingData;
                    }
                    columnValues = updatedString.split(',');
                    columnValues[0]=columnValues[0].replaceAll('#',',');
                }else{
                    columnValues = input.split(',');
                }
                return columnValues;
    }


    public static Map<String, String> validateProductFloorPrice(List<Pricing_Product_Floor_Price__c> ProductFloorPriceList,String recordId,  Map<Id,String> prodIdToNameMap,Map<String, Pricing_Product_Floor_Price__c> prodNameToRuleRecordMap ){
        Map<String,Pricing_Product_Floor_Price__c> ProductIdtoRuleRecordMap = new Map<String, Pricing_Product_Floor_Price__c>();
        List<Pricing_Product_Floor_Price__c> productFloorPricetoInsert = new List<Pricing_Product_Floor_Price__c>();
        List<Pricing_Product_Floor_Price__c> productFloorPricetoUpdate = new List<Pricing_Product_Floor_Price__c>();
        Map<String, String> productFloorPriceSuccessErrorMap = new Map<String, String>();
        String errorMsg = '';
        String resMsg = '';
        String prodFloorPriceName = '';
        Decimal ecapPrice;
        Boolean active;
        Set<Id> existingProdIdsSet = new Set<Id>();
        Map<Id,Pricing_Product_Floor_Price__c> existingProdIdToRecMap = new Map<Id,Pricing_Product_Floor_Price__c>();
        String prodFloorPriceId;
        String ruleStatus;
        
        try{
            for(Pricing_Product_Floor_Price__c rec : [Select Pricing_Product__c,Pricing_Product__r.Name,Pricing_Approval_Price_Rules__r.Pricing_Approval_Status__c from Pricing_Product_Floor_Price__c where Pricing_Approval_Price_Rules__c =: recordId ]){
                existingProdIdsSet.add(rec.Pricing_Product__c);
                existingProdIdToRecMap.put(rec.Pricing_Product__c,rec);
                ruleStatus = rec.Pricing_Approval_Price_Rules__r.Pricing_Approval_Status__c;
            }
            for(Pricing_Product_Floor_Price__c productFloorPrice : ProductFloorPriceList){
                if(productFloorPrice.Pricing_Product__c != null){
                ProductIdtoRuleRecordMap.put(productFloorPrice.Pricing_Product__c, productFloorPrice);
                }
            }  
            //all products are blank or invalid 
            if(ProductIdtoRuleRecordMap.isEmpty()){
                for(String prodName : prodNameToRuleRecordMap.keyset()){
                    errorMsg += 'Product is a required field. Please select a valid Product and try again. ; '; 
                    resMsg = prodFloorPriceId + ',' + prodName + ',' + prodNameToRuleRecordMap.get(prodName).Pricing_Approved_ECAP_Price__c + ',' + prodNameToRuleRecordMap.get(prodName).Pricing_Active__c + ',' + errorMsg.replace(',','');
                    productFloorPriceSuccessErrorMap.put('Error:'+prodName, resMsg);
                    errorMsg = '';
                }      
            }else{
                for(String productId : ProductIdtoRuleRecordMap.keySet()){
                    //Check if Ecap is blank
                    if(ProductIdtoRuleRecordMap.get(productId).Pricing_Approved_ECAP_Price__c == null){
                        errorMsg += 'Approved Ecap is a required field. Please give a number and try again. ; ';                                      
                    }

                    //Check Ecap Price greater than zero
                    if(ProductIdtoRuleRecordMap.get(productId).Pricing_Approved_ECAP_Price__c != null && ProductIdtoRuleRecordMap.get(productId).Pricing_Approved_ECAP_Price__c<=0){
                        errorMsg += 'Approved Ecap Price should always be greater than zero. ; ';                                      
                    }

                    if(ruleStatus == 'Submitted'){
                        errorMsg += 'Product Floor Price cannot be created or updated when the price rule is in the Submitted state. ;';
                    }
                    
                    prodFloorPriceName = prodIdToNameMap.get(productId);
                    ecapPrice = ProductIdtoRuleRecordMap.get(productId).Pricing_Approved_ECAP_Price__c == null ? null : ProductIdtoRuleRecordMap.get(productId).Pricing_Approved_ECAP_Price__c;
                    active = ProductIdtoRuleRecordMap.get(productId).Pricing_Active__c == null ? false : ProductIdtoRuleRecordMap.get(productId).Pricing_Active__c;
                    
                    
                    if(String.isBlank(errorMsg)){
                        if(!existingProdIdsSet.contains(productId)){
                            //resMsg = '';
                            Pricing_Product_Floor_Price__c floorPriceToInsert = new Pricing_Product_Floor_Price__c();
                            floorPriceToInsert.Pricing_Product__c = ProductIdtoRuleRecordMap.get(productId).Pricing_Product__c;
                            floorPriceToInsert.Pricing_Approved_ECAP_Price__c = ProductIdtoRuleRecordMap.get(productId).Pricing_Approved_ECAP_Price__c;
                            floorPriceToInsert.Pricing_Active__c = ProductIdtoRuleRecordMap.get(productId).Pricing_Active__c;
                            floorPriceToInsert.Pricing_Approval_Price_Rules__c = recordId;
                            productFloorPricetoInsert.add(floorPriceToInsert);
                        // resMsg = 'Success';
                       }
                        if(existingProdIdsSet.contains(productId)){
                            Pricing_Product_Floor_Price__c floorPriceToUpdate = new Pricing_Product_Floor_Price__c();
                            floorPriceToUpdate.Pricing_Approved_ECAP_Price__c = ProductIdtoRuleRecordMap.get(productId).Pricing_Approved_ECAP_Price__c;
                            floorPriceToUpdate.Pricing_Active__c = ProductIdtoRuleRecordMap.get(productId).Pricing_Active__c;
                            floorPriceToUpdate.Id = existingProdIdToRecMap.get(productId).Id;
                            productFloorPricetoUpdate.add(floorPriceToUpdate);
                        }
                    }
                    else{
                        resMsg = prodFloorPriceId + ',' + prodFloorPriceName.replace(',','') + ',' + ecapPrice + ',' + active + ',' + errorMsg.replace(',','');
                        productFloorPriceSuccessErrorMap.put(prodIdToNameMap.get(productId), resMsg);
                    } 
                    errorMsg = '';   
                }  
            } 
            Set<Id> successIds = new Set<Id>();                  
            if(productFloorPricetoInsert.size() > 0){
                database.saveresult[] result = Database.insert(productFloorPricetoInsert, false);
                for (Database.SaveResult sr : result) {
                    if(sr.isSuccess() && sr.getId()!=null){
                            successIds.add(sr.getId());
                        }
                }
                //insert productFloorPricetoInsert;
            } 
            if(productFloorPricetoUpdate.size() > 0){
                database.saveresult[] result = Database.update(productFloorPricetoUpdate, false);
                for (Database.SaveResult sr : result) {
                    if(sr.isSuccess() && sr.getId()!=null){
                            successIds.add(sr.getId());
                        }
                }
            }
            
            if(successIds.size() > 0){
                for(String prodId : ProductIdtoRuleRecordMap.keySet()){
                    if(!productFloorPriceSuccessErrorMap.containskey(prodIdToNameMap.get(prodId))){
                        for(Pricing_Product_Floor_Price__c ProdInserted: productFloorPricetoInsert){
                            prodFloorPriceId = String.isBlank(ProdInserted.Id) ? String.valueOf('') : ProdInserted.Id;
                            prodFloorPriceName =  prodIdToNameMap.get(prodId);
                            ecapPrice = (ProductIdtoRuleRecordMap.get(prodId).Pricing_Approved_ECAP_Price__c == null) ? null : ProductIdtoRuleRecordMap.get(prodId).Pricing_Approved_ECAP_Price__c;
                            active = ProductIdtoRuleRecordMap.get(prodId).Pricing_Active__c == null ? null : ProductIdtoRuleRecordMap.get(prodId).Pricing_Active__c;
                    
                            resMsg = prodFloorPriceId + ',' + prodFloorPriceName.replace(',','') + ',' + ecapPrice + ',' + active + ',' ;
                            resMsg += 'Success';
                        }
                        productFloorPriceSuccessErrorMap.put(prodIdToNameMap.get(prodId), resMsg);
                        //update
                        for(Pricing_Product_Floor_Price__c ProdUpdated: productFloorPricetoUpdate){
                            prodFloorPriceId = String.isBlank(ProdUpdated.Id) ? String.valueOf('') : ProdUpdated.Id;
                            prodFloorPriceName =  prodIdToNameMap.get(prodId);
                            ecapPrice = (ProductIdtoRuleRecordMap.get(prodId).Pricing_Approved_ECAP_Price__c == null) ? null : ProductIdtoRuleRecordMap.get(prodId).Pricing_Approved_ECAP_Price__c;
                            active = ProductIdtoRuleRecordMap.get(prodId).Pricing_Active__c == null ? null : ProductIdtoRuleRecordMap.get(prodId).Pricing_Active__c;
                    
                            resMsg = prodFloorPriceId + ',' + prodFloorPriceName.replace(',','') + ',' + ecapPrice + ',' + active + ',' ;
                            resMsg += 'Success';
                        }
                        productFloorPriceSuccessErrorMap.put(prodIdToNameMap.get(prodId), resMsg);
                    }
                }
            } 
        }  
        
        catch(Exception e){
            Pricing_Tender_Utility.logError(e); 
        }
        return productFloorPriceSuccessErrorMap;
    }
    
}