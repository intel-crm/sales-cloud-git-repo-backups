/****************************************************************************************************
Apex Class Name : PSG_QuoteCloneController
Version         : 1.0 
Created Date    : 08/13/2021
Function        : This class is controller for Quote Clone and Revision process.
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Pooja                    08/13/2021                Created
*****************************************************************************************************/
public without sharing class PSG_QuoteCloneController {
    
    /************************************************************************************************************
    *Method Name : getAllRequiredFields
    *Created Date: 08/13/2021
    *Author: Pooja
    *Description : Returns new Quote object instance.
    ************************************************************************************************************/
    @AuraEnabled
    public static SBQQ__Quote__c initiateQuote(){
        return new SBQQ__Quote__c();
    }
    
    /************************************************************************************************************
    *Method Name : doClone
    *Created Date: 08/13/2021
    *Author: Pooja
    *Description : Method clone the quote and quote lines and create new quote.
    ************************************************************************************************************/
    @AuraEnabled
    public static GlobalVariables doClone (String sObjectId,String action,String quoteTypeTochange){  
        String quoteId=String.escapeSingleQuotes(sObjectId);
        String actionType=String.escapeSingleQuotes(action);
        String newQuoteType=String.escapeSingleQuotes(quoteTypeTochange);
        GlobalVariables globalVar = new GlobalVariables();
        List<SBQQ__Quote__c> parentSObjects;
        SBQQ__Quote__c parent;
        String query;
        id userId = UserInfo.getUserId();     
        Id cpRecordType = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get('PSG_Quote_Contract_Pricing').getRecordTypeId();
        List<PermissionSetAssignment> currentuserPermissionList =new List<PermissionSetAssignment>([SELECT Id, PermissionSet.Name, AssigneeId
                                                                                                    FROM PermissionSetAssignment
                                                                                                    WHERE AssigneeId =: userId]);
        Boolean allowClone = false;
        Boolean allowRevision = false; 
        Boolean allowRevisionBasedOnStatus = false;
        String errorMsg = '';
        Set<String> cloneOrReviseEnabledPermissionSet = new Set<String>(Label.PSG_Quote_PermissionSets.split(':'));
        for (PermissionSetAssignment psa : currentuserPermissionList) {
            if(cloneOrReviseEnabledPermissionSet.contains(psa.PermissionSet.Name)){
                if(actionType == 'clone'){
                    allowClone = true;
                }else if(actionType == 'revision'){
                    allowRevision = true;
                }
                break;
            }
        }
        try {
            SBQQ.TriggerControl.disable();
            query = String.format(
                'SELECT {0} FROM {1} WHERE Id = \'\'{2}\'\'',
                new String[] {
                        String.join(new List<String>(SBQQ__Quote__c.SObjectType.getDescribe().fields.getMap().keySet()),','),
                        String.valueOf(SBQQ__Quote__c.SObjectType),
                        quoteId
                        }
            );
            parentSObjects = Database.query(query);
            String parentId = parentSObjects[0].Id;
            if(parentSObjects[0].core_cpq_ultimate_parent_quote__c != null){
                parentId = parentSObjects[0].core_cpq_ultimate_parent_quote__c;
            }
            List<SBQQ__Quote__c> duplicateCPQuotes = [select id, Name from SBQQ__Quote__c where core_cpq_ultimate_parent_quote__c = :parentId and core_cpq_Process_flag__c = false 
                                                      and core_cpq_active_cb__c = true and core_cpq_ultimate_parent_quote__c!= null and core_cpq_quote_type_nm__c = 'Contract Pricing'];
            Set<String> reviseQuoteStatusSet = new Set<String>(Label.PSG_Revise_Quote_Status.split(':'));
            Id oppId = parentSObjects[0].SBQQ__Opportunity2__c;
            Set<Id> existingOPNForDesignWinSet = new Set<Id>();
            if(oppId != null && newQuoteType == 'Design Win'){
                existingOPNForDesignWinSet = validateOPNForDesignWin(oppId,quoteId);
            }
            
            if(parentSObjects[0].core_cpq_quote_type_nm__c != 'Contract Pricing') {
                if(actionType == 'revision' && (parentSObjects[0].core_cpq_quote_type_nm__c == 'Budgetary') && (newQuoteType != 'Budgetary' && newQuoteType != 'Design Win')){
                    errorMsg = 'Quote cannot be revised to '+newQuoteType+ ' quote type';   
                }else if(actionType == 'revision' && (parentSObjects[0].core_cpq_quote_type_nm__c == 'Design Win') && (newQuoteType != 'Design Win')){
                    errorMsg = 'Quote cannot be revised to '+newQuoteType+ ' quote type';
                }else if(actionType == 'revision' && (parentSObjects[0].core_cpq_quote_type_nm__c == 'Transfer Pricing') && (newQuoteType != 'Transfer Pricing')){
                    errorMsg = 'Quote cannot be revised to '+newQuoteType+ ' quote type';
                }else if(actionType == 'revision' && (parentSObjects[0].core_cpq_quote_type_nm__c == 'Tools') && (newQuoteType != 'Tools')){
                    errorMsg = Label.PSG_Tools_Type_Onrevison_Error;
                }else if(actionType == 'revision' && (reviseQuoteStatusSet.contains(parentSObjects[0].SBQQ__Status__c)) && (parentSObjects[0].core_cpq_active_cb__c) && !(parentSObjects[0].core_cpq_quote_revised_cb__c)){
                    allowRevisionBasedOnStatus = true;                        
                }else if(actionType == 'revision' && !(reviseQuoteStatusSet.contains(parentSObjects[0].SBQQ__Status__c)) && !(parentSObjects[0].core_cpq_active_cb__c)){
                    errorMsg = Label.PSG_InActiveQuote_Error_Message + ' and ' + Label.PSG_Revision_Error_Message;
                }else if(actionType == 'revision' &&!(parentSObjects[0].core_cpq_active_cb__c)){
                    errorMsg = Label.PSG_InActiveQuote_Error_Message;                        
                }else if (actionType == 'revision' && !(reviseQuoteStatusSet.contains(parentSObjects[0].SBQQ__Status__c))){
                    errorMsg = Label.PSG_Revision_Error_Message;
                }else if (actionType == 'revision' && (parentSObjects[0].core_cpq_active_cb__c) && (parentSObjects[0].core_cpq_quote_revised_cb__c)){ 
                    errorMsg = Label.PSG_Re_revising_Quote_Error_Message;
                } 
            }else{
                allowRevisionBasedOnStatus = true; 
                if(actionType == 'revision'  && (parentSObjects[0].core_cpq_quote_type_nm__c == 'Contract Pricing') && (duplicateCPQuotes.size() > 0) ){
                    allowRevision = false;
                    errorMsg = 'There exists an active Contract Pricing Quote ' +duplicateCPQuotes[0].Name+' . Please inactivate prior to revising the Quote.';
                }  
            }
            
            if(allowClone || (allowRevision && allowRevisionBasedOnStatus)){
                parent = parentSObjects[0].clone(false, true, false, false);
                parent.core_cpq_invalid_opn_ta__c = '';
                parent.core_cpq_invalid_opns_dup__c= '';
                if(parentSObjects[0].RecordTypeId == cpRecordType){
                    parent.RecordTypeId = cpRecordType;
                }else{
                    parent.RecordTypeId = PSG_Utility.getRecordTypeId('SBQQ__Quote__c', 'PSG_Quote_New');
                }
                parent.core_cpq_status_txt__c = 'Draft';
                parent.core_cpq_quote_type_nm__c = newQuoteType;
                parent.SBQQ__Status__c = 'Draft';
                if(actionType=='clone'){
                    for(String fieldName : (Label.PSG_QuoteFieldsNull).split(':')){
                        parent.put(fieldName,null);
                    }
                    for(String fieldName : (Label.PSG_QuoteFieldsNullNewl).split(':')){
                        parent.put(fieldName,null);
                    }
                    
                    if(parentSObjects[0].RecordTypeId == cpRecordType){
                        for(String fieldName : (Label.PSG_CP_Quote_FieldsNull).split(':')){
                            parent.put(fieldName,null);
                        }
                    }                    
                    for(String fieldName : (Label.PSG_clone_quote_boolean_to_false).split(':')){
                        parent.put(fieldName,false);
                    }
                } 
                /*parent.core_cpq_original_quote__c = parentSObjects[0].Id;
                if(parentSObjects[0].core_cpq_ultimate_parent_quote__c ==  null){
                    parent.core_cpq_ultimate_parent_quote__c = parentSObjects[0].Id;
                    parent.core_cpq_ultimate_quote_number_nbr__c = parentSObjects[0].Name;
                }else{
                    parent.core_cpq_ultimate_parent_quote__c = parentSObjects[0].core_cpq_ultimate_parent_quote__c;
                    parent.core_cpq_ultimate_quote_number_nbr__c = parentSObjects[0].core_cpq_ultimate_quote_number_nbr__c;
                } */   //Changes for TWC3133-3817
                if(actionType == 'revision'){
                    
                    for(String fieldName : (Label.PSG_rev_Quote_fields_toNull).split(':')){
                        parent.put(fieldName,null);
                        
                        if(parentSObjects[0].RecordTypeId == cpRecordType){
                            parentSObjects[0].core_cpq_active_cb__c = true;
                        }
                        
                        if(parentSObjects[0].RecordTypeId != cpRecordType){
                            parentSObjects[0].core_cpq_active_cb__c = false;
                        }                    
                    }
                    
                    for(String fieldName : (Label.PSG_rev_quote_Boolean_to_false).split(':')){
                        parent.put(fieldName,false);
                    }
                    parent.core_cpq_original_quote__c = parentSObjects[0].Id;
                    parentSObjects[0].core_cpq_quote_revised_cb__c = true;
                    if(parentSObjects[0].core_cpq_revision_nbr__c == 1){
                        parent.core_cpq_ultimate_parent_quote__c = parentSObjects[0].Id;
                        parent.core_cpq_ultimate_quote_number_nbr__c = parentSObjects[0].Name;
                    }else{
                        parent.core_cpq_ultimate_parent_quote__c = parentSObjects[0].core_cpq_ultimate_parent_quote__c;
                        parent.core_cpq_ultimate_quote_number_nbr__c = parentSObjects[0].core_cpq_ultimate_quote_number_nbr__c;
                    }                
                    parent.core_cpq_status_txt__c = 'In Progress';
                    parent.SBQQ__Status__c = 'In Progress';
                    parent.core_cpq_assigned_by_nm__c = null;
                    parent.core_cpq_assigned_on__c = null;
                    parent.core_cpq_assigned_to_nm__c = null;
                   // Revison on PSG Queue Owner quote will change quote owner to user who did Revision
                   Id Ownerid=parentSObjects[0].OwnerId;
                   String objType = String.valueOf(Ownerid.getsObjectType());
                    if(objType=='Group'){
                    parent.ownerId = userinfo.getUserId(); 
                    }
                    
                    if(parentSObjects[0].core_cpq_revision_nbr__c != null){
                        parent.core_cpq_revision_nbr__c = parentSObjects[0].core_cpq_revision_nbr__c + 1;
                    }else{
                        parent.core_cpq_revision_nbr__c = 1;
                    }                        
                }else if(actionType == 'clone'){
                    parent.core_cpq_revision_nbr__c = 1;
                    parent.core_cpq_active_cb__c = true;
                    parent.core_cpq_status_txt__c = 'In Progress';
                    parent.SBQQ__Status__c = 'In Progress';
                    parent.core_cpq_quote_revised_cb__c = false;
                    parent.core_cpq_original_quote__c=null;
                    parent.ownerId = userinfo.getUserId();
                    if(parent.core_cpq_quote_type_nm__c=='Tools'){
                        parent.SBQQ__StartDate__c=parentSObjects[0].SBQQ__StartDate__c;
                        parent.SBQQ__EndDate__c=parentSObjects[0].SBQQ__EndDate__c;
                    }               
                        /*if(parentSObjects[0].core_cpq_ultimate_parent_quote__c == null){
                        parent.core_cpq_ultimate_parent_quote__c = parentSObjects[0].Id;
                        parent.core_cpq_ultimate_quote_number_nbr__c = parentSObjects[0].Name;
                    }else{
                        parent.core_cpq_ultimate_parent_quote__c = parentSObjects[0].core_cpq_ultimate_parent_quote__c;
                        parent.core_cpq_ultimate_quote_number_nbr__c = parentSObjects[0].core_cpq_ultimate_quote_number_nbr__c;
                    } */                              
                }
               
                if(actionType == 'Revision'){
                    update parentSObjects[0];
                }
	        Database.insert(parent);
                SBQQ__Quote__c quote = [Select Name from SBQQ__Quote__c where Id =: parent.Id LIMIT 1];
		
            if(actionType == 'Revision'){
                parentSObjects[0].core_cpq_Revised_Quote__c=parent.Id;
                        update parentSObjects[0];
                    }
                    
                if(System.isBatch()){
                    PSG_QuoteCloneFuture.copyQuoteChildRecords(quoteId, parent.Id, actionType, existingOPNForDesignWinSet);
                }else{
                    PSG_QuoteCloneFuture.copyQuoteChildRecordsFuture(quoteId, parent.Id, actionType, existingOPNForDesignWinSet);
                }                
                if(actionType == 'clone'){
                    globalVar.messageResult = Label.PSG_Quote_Clone_Success_Message;
                }else{                                   
                    globalVar.messageResult = Label.PSG_Quote_Revise_Success_Message;
                }
                
                globalVar.isSuccess = true;
                globalVar.quoteId = parent.Id;
                globalVar.quoteName = quote.Name;
            }else{
                if(String.isNotBlank(errorMsg)){
                    globalVar.messageResult = errorMsg;
                }else{
                    globalVar.messageResult = Label.PSG_No_Access_Error_Message;
                }
                globalVar.isSuccess = false;
                globalVar.quoteId = null;
                globalVar.quoteName = null;
            }
        }catch (Exception error){
            if(error.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')){
                globalVar.messageResult =error.getDmlMessage(0);
                PSG_Utility.logError(error);
            }else if(error.getMessage().contains('CANNOT_EXECUTE_FLOW_TRIGGER')){
	    	globalVar.messageResult =JSON.serialize('Error occured during flow execution');
	        //PSG_Utility.logError(error);
	    }else if(error.getMessage().contains('EXCEPTION,')){
                String Errmsg =JSON.serialize(error.getMessage());
                String[] errmsg1= Errmsg.split('EXCEPTION,');
                globalVar.messageResult =JSON.serialize(errmsg1[1]);
                //globalVar.messageResult =JSON.serialize(error.getMessage());
                //PSG_Utility.logError(error);
            }else{
                globalVar.messageResult =JSON.serialize(error.getMessage());
                //PSG_Utility.logError(error);
            }
            globalVar.quoteId = null;
            globalVar.isSuccess = false;
            globalVar.quoteName = null;
            return globalVar;
        }finally{
            SBQQ.TriggerControl.enable();
        }
        return globalVar;
    }
    
    /************************************************************************************************************
    *Method Name : validateOPNForDesignWin
    *Created Date: 08/13/2021
    *Author: Pooja
    *Description : Returns all the valid OPN's.
    ************************************************************************************************************/
    public static Set<Id> validateOPNForDesignWin(Id oppId,Id quoteIdToExclude){
        Set<Id> productIdSet = new Set<Id>();
        for(SBQQ__QuoteLine__c quoteLine : [SELECT Id,core_cpq_product_nm__c,SBQQ__Product__c from SBQQ__QuoteLine__c 
                                            where SBQQ__Quote__r.SBQQ__Opportunity2__c =: oppId and SBQQ__Quote__c !=: quoteIdToExclude and 
                                            SBQQ__Quote__r.core_cpq_quote_type_nm__c = 'Design Win' and SBQQ__Quote__r.core_cpq_active_cb__c = true]){
            if(quoteLine.SBQQ__Product__c != null){
                productIdSet.add(quoteLine.SBQQ__Product__c);
            }
        }
        return productIdSet;
    }
    
    /***********************************WRAPPER CLASS*************************************/
    public class GlobalVariables{
        @AuraEnabled public String messageResult {get;set;} 
        @AuraEnabled public Id quoteId {get;set;} 
        @AuraEnabled public Boolean isSuccess {get;set;}
        @AuraEnabled public String quoteName {get;set;}
    }  
    
}