/****************************************************************************************************
Apex Class Name : ApprovalTriggerHandler
Version         : 1.0 
Created Date    : 01/05/2021
Function        : Trigger Handler for Approval Trigger.
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Hema                     01/05/2021               Created
*****************************************************************************************************/
public without sharing class ApprovalTriggerHandler extends TriggerHandler{
    public List<sbaa__Approval__c> psgTriggerNewList = new List<sbaa__Approval__c>();
    public List<sbaa__Approval__c> psgTriggerOldList = new List<sbaa__Approval__c>();
    public Map<Id,sbaa__Approval__c> psgTriggerOldMap = new Map<Id,sbaa__Approval__c>();
    public Map<Id,sbaa__Approval__c> psgTriggerNewMap = new Map<Id,sbaa__Approval__c>();
    
    public List<sbaa__Approval__c> psgCPTriggerNewList = new List<sbaa__Approval__c>();
    public List<sbaa__Approval__c> psgCPTriggerOldList = new List<sbaa__Approval__c>();
    public Map<Id,sbaa__Approval__c> psgCPTriggerOldMap = new Map<Id,sbaa__Approval__c>();
    public Map<Id,sbaa__Approval__c> psgCPTriggerNewMap = new Map<Id,sbaa__Approval__c>();
    
    // Added by Priyanka Mishra for Software Business Logic
    public List<sbaa__Approval__c> swTriggerNewList = new List<sbaa__Approval__c>();
    public List<sbaa__Approval__c> swTriggerOldList = new List<sbaa__Approval__c>();
    public Map<Id,sbaa__Approval__c> swTriggerOldMap = new Map<Id,sbaa__Approval__c>();
    public Map<Id,sbaa__Approval__c> swTriggerNewMap = new Map<Id,sbaa__Approval__c>();
    
    //Changes made for TWC3133-4176 - Bishal Singh
    public static Boolean isFutureExecuted = false;
    public static Set<String> quoteIds=new Set<String>();
    public ApprovalTriggerHandler(){
        Set<Id> quoteIdSet=new Set<Id>();
       
        for(sbaa__Approval__c appr :(List<sbaa__Approval__c>) Trigger.new ){
            if(appr.Quote__c != null)
                quoteIdSet.add(appr.Quote__c);
        }
        Map<Id,SBQQ__Quote__c> quoteIdToQuoteMap=new Map<Id,SBQQ__Quote__c>([SELECT id,core_cpq_quote_type_nm__c,Pricing_Quote_Program_Nm__c from SBQQ__Quote__c where id in :quoteIdSet ]);
        if(Trigger.new != null){
            for(sbaa__Approval__c appr : (List<sbaa__Approval__c>)Trigger.new){
                if(quoteIdToQuoteMap.containsKey(appr.Quote__c) && quoteIdToQuoteMap.get(appr.Quote__c).Pricing_Quote_Program_Nm__c == Label.Pricing_Program_Code_PSG && quoteIdToQuoteMap.get(appr.Quote__c).core_cpq_quote_type_nm__c !=  'Contract Pricing'){
                    psgTriggerNewList.add(appr);
                } 
                if(quoteIdToQuoteMap.containsKey(appr.Quote__c) && quoteIdToQuoteMap.get(appr.Quote__c).Pricing_Quote_Program_Nm__c == Label.Pricing_Program_Code_PSG && quoteIdToQuoteMap.get(appr.Quote__c).core_cpq_quote_type_nm__c ==  'Contract Pricing'){
                    psgCPTriggerNewList.add(appr);
                } 
                
                if(Trigger.newMap != null){
                    if(quoteIdToQuoteMap.containsKey(appr.Quote__c) && quoteIdToQuoteMap.get(appr.Quote__c).Pricing_Quote_Program_Nm__c == Label.Pricing_Program_Code_PSG && quoteIdToQuoteMap.get(appr.Quote__c).core_cpq_quote_type_nm__c !=  'Contract Pricing'){
                        psgTriggerNewMap.put(appr.Id,appr);
                    }
                    if(quoteIdToQuoteMap.containsKey(appr.Quote__c) && quoteIdToQuoteMap.get(appr.Quote__c).Pricing_Quote_Program_Nm__c == Label.Pricing_Program_Code_PSG && quoteIdToQuoteMap.get(appr.Quote__c).core_cpq_quote_type_nm__c ==  'Contract Pricing'){
                        psgCPTriggerNewMap.put(appr.Id,appr);
                    }
                }
                // Added by Priyanka Mishra for Software Business Logic
                if(quoteIdToQuoteMap.containsKey(appr.Quote__c) && quoteIdToQuoteMap.get(appr.Quote__c).Pricing_Quote_Program_Nm__c == Label.Pricing_Program_Code_Software){
                    swTriggerNewList.add(appr);
                } 
                
            }
        }
        if(Trigger.old != null){
            for(sbaa__Approval__c appr : (List<sbaa__Approval__c>)Trigger.new){
                sbaa__Approval__c oldAppr=(sbaa__Approval__c) trigger.oldMap.get(appr.Id);
                if(quoteIdToQuoteMap.containsKey(appr.Quote__c) && quoteIdToQuoteMap.get(appr.Quote__c).Pricing_Quote_Program_Nm__c == Label.Pricing_Program_Code_PSG && quoteIdToQuoteMap.get(appr.Quote__c).core_cpq_quote_type_nm__c !=  'Contract Pricing'){
                    psgTriggerOldList.add(oldAppr);
                    psgTriggerOldMap.put(appr.Id,oldAppr);
                }else if(quoteIdToQuoteMap.containsKey(appr.Quote__c) && quoteIdToQuoteMap.get(appr.Quote__c).Pricing_Quote_Program_Nm__c == Label.Pricing_Program_Code_PSG && quoteIdToQuoteMap.get(appr.Quote__c).core_cpq_quote_type_nm__c ==  'Contract Pricing'){
                    psgCPTriggerOldList.add(oldAppr);
                    psgCPTriggerOldMap.put(appr.Id,oldAppr);
                }
                //Changes made for TWC3133-4176 - Bishal Singh
                if(quoteIdToQuoteMap.containsKey(appr.Quote__c) && quoteIdToQuoteMap.get(appr.Quote__c).Pricing_Quote_Program_Nm__c == Label.Pricing_Program_Code_PSG && oldAppr.sbaa__Status__c != appr.sbaa__Status__c && appr.sbaa__Status__c =='Approved'){
                    quoteIds.add(appr.Quote__c);
                }
                
                if(quoteIdToQuoteMap.containsKey(appr.Quote__c) && quoteIdToQuoteMap.get(appr.Quote__c).Pricing_Quote_Program_Nm__c == Label.Pricing_Program_Code_Software){
                    swTriggerOldMap.put(appr.Id,oldAppr); // // Added by Priyanka Mishra for Software Business Logic
                }
            }
        } 
    }
    
    public override void afterInsert(){
        if(!psgTriggerNewList.isEmpty() && isActive('PSG_Approval_After_Insert')){
            PSG_ApprovalBusinessLogic.afterInsertUpdateOperations(psgTriggerNewList,Trigger.isInsert,null,false);
        }
        if(!psgCPTriggerNewList.isEmpty() && isActive('PSG_Approval_After_Insert')){
            PSG_ApprovalBusinessLogic.afterInsertUpdateOperations(psgCPTriggerNewList,Trigger.isInsert,null,true);
        }
        // Added by Priyanka Mishra for Software Business Logic
        if(swTriggerNewList.size() > 0 && isActive('Pricing_SW_ApprovaAfterInsert')){
           Pricing_SW_ApprovalBusinessLogic.afterInsertUpdateApprovalComments(swTriggerNewList,swTriggerOldMap);    
        } 
    }
    public override void beforeInsert(){
        if(!psgTriggerNewList.isEmpty() && isActive('PSG_Approval_Before_Insert')){
            PSG_ApprovalBusinessLogic.beforeInsertUpdateOperations(psgTriggerNewList,Trigger.isInsert,null);
        }
    }
    public override void afterUpdate(){
        if(!psgTriggerNewList.isEmpty() && isActive('PSG_Approval_After_Update')){ 
            PSG_ApprovalBusinessLogic.afterInsertUpdateOperations(psgTriggerNewList,Trigger.isInsert,psgTriggerOldMap,false);
        }
        if(!psgCPTriggerNewList.isEmpty() && isActive('PSG_Approval_After_Update')){
            PSG_ApprovalBusinessLogic.afterInsertUpdateOperations(psgCPTriggerNewList,Trigger.isInsert,psgCPTriggerOldMap,true);
        }
        //Changes made for TWC3133-4176 - Bishal Singh
        if(!quoteIds.isEmpty() && isActive('PSG_Approval_After_Update') && !isFutureExecuted){
            PSG_QuoteHistoryTracking.updateApprovalHistory(quoteIds);
            isFutureExecuted = true;
        }
        // Added by Priyanka Mishra for Software Business Logic
        if(swTriggerNewList.size() > 0 && isActive('Pricing_SW_ApprovalAfterUpdate')){
           Pricing_SW_ApprovalBusinessLogic.afterInsertUpdateApprovalComments(swTriggerNewList,swTriggerOldMap);   
        } 
    }
    public override void beforeUpdate() {
        if(!psgTriggerNewList.isEmpty() && isActive('PSG_Approval_Before_Update')){
            PSG_ApprovalBusinessLogic.beforeInsertUpdateOperations(psgTriggerNewList,Trigger.isInsert,psgTriggerOldMap);
        }
    }  
}