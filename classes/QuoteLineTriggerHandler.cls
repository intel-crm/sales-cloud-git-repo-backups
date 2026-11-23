/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 04-01-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class QuoteLineTriggerHandler extends TriggerHandler {
    //IQR Context Variables
    public List<SBQQ__QuoteLine__c> iqrTriggerNewList = new List<SBQQ__QuoteLine__c>();
    public List<SBQQ__QuoteLine__c> iqrTriggerOldList = new List<SBQQ__QuoteLine__c>();
    public Map<Id,SBQQ__QuoteLine__c> iqrTriggerOldMap = new Map<Id,SBQQ__QuoteLine__c>();
    public Map<Id,SBQQ__QuoteLine__c> iqrTriggerNewMap = new Map<Id,SBQQ__QuoteLine__c>();
    
    //Financial Incentive Context Variables
    public List<SBQQ__QuoteLine__c> FITriggerNewList = new List<SBQQ__QuoteLine__c>();
    public List<SBQQ__QuoteLine__c> FITriggerOldList = new List<SBQQ__QuoteLine__c>();
    public Map<Id,SBQQ__QuoteLine__c> FITriggerOldMap = new Map<Id,SBQQ__QuoteLine__c>();
    public Map<Id,SBQQ__QuoteLine__c> FITriggerNewMap = new Map<Id,SBQQ__QuoteLine__c>();

    //PSG Congtext Variables
    public List<SBQQ__QuoteLine__c> psgTriggerNewList = new List<SBQQ__QuoteLine__c>();
    public List<SBQQ__QuoteLine__c> psgTriggerOldList = new List<SBQQ__QuoteLine__c>();
    public Map<Id,SBQQ__QuoteLine__c> psgTriggerOldMap = new Map<Id,SBQQ__QuoteLine__c>();
    public Map<Id,SBQQ__QuoteLine__c> psgTriggerNewMap = new Map<Id,SBQQ__QuoteLine__c>();
    
    //PSG CP Variables
    public List<SBQQ__QuoteLine__c>  psgTriggerCPNewList = new List<SBQQ__QuoteLine__c>();
    public List<SBQQ__QuoteLine__c>  psgTriggerCPOldList = new List<SBQQ__QuoteLine__c>();
    public Map<Id,SBQQ__QuoteLine__c> psgTriggerCPOldMap = new Map<Id,SBQQ__QuoteLine__c>();
    public Map<Id,SBQQ__QuoteLine__c> psgTriggerCPNewMap = new Map<Id,SBQQ__QuoteLine__c>();
    public Map<Id,String> recordTypeMap = new Map<Id, String>();
    
    //Context Variable For software & Services
    public List<SBQQ__QuoteLine__c> swTriggerNewList = new List<SBQQ__QuoteLine__c>();
    public List<SBQQ__QuoteLine__c> swTriggerOldList = new List<SBQQ__QuoteLine__c>();
    public Map<Id,SBQQ__QuoteLine__c> swTriggerOldMap = new Map<Id,SBQQ__QuoteLine__c>();
    public Map<Id,SBQQ__QuoteLine__c> swTriggerNewMap = new Map<Id,SBQQ__QuoteLine__c>();
    public QuoteLineTriggerHandler(){
        Map<Id,String> recordTypeMap = new Map<Id, String>();
        //All IQR Record Types
        Set<String> allIQRRecordTypes = new Set<String>((Label.Pricing_Quote_Line_All_Record_Type).split(':'));
        //All PSG Record Types
        Set<String> allPSGRecordTypes = new Set<String>((Label.PSG_Quoteline_Record_Types).split(':'));
        
        //recordTypeMap = buildMapOfRecordTypes('SBQQ__QuoteLine__c');
        
        //recordTypeMap.put(PSG_Utility.getRecordTypeId('SBQQ__QuoteLine__c','PSG_Quote_Line_Create'),'PSG_Quote_Line_Create');
        //recordTypeMap.put(PSG_Utility.getRecordTypeId('SBQQ__QuoteLine__c','PSG_Quote_Line_Submitted'),'PSG_Quote_Line_Submitted');
        //recordTypeMap.put(PSG_Utility.getRecordTypeId('SBQQ__QuoteLine__c','PSG_Quote_Line_Read_Only'),'PSG_Quote_Line_Read_Only');
        
          
        Id cpRecordType = Schema.SObjectType.SBQQ__QuoteLine__c.getRecordTypeInfosByDeveloperName().get('psg_cp_quote_line').getRecordTypeId();
        
        if(Trigger.new != null){
            for(SBQQ__QuoteLine__c quoteLine : (List<SBQQ__QuoteLine__c>)Trigger.new){ 
                if(quoteLine.Pricing_Quote_Program_Nm__c == Label.Pricing_Program_Code_Tender ){
                    iqrTriggerNewList.add(quoteLine);
                }else if(allPSGRecordTypes.contains(recordTypeMap.get(quoteLine.RecordTypeId))){
                    psgTriggerNewList.add(quoteLine);
                }else if(quoteLine.RecordTypeId == cpRecordType){
                    psgTriggerCPNewList.add(quoteLine);
                }else if(quoteLine.Pricing_Quote_Program_Nm__c == Label.Pricing_Tender_FinancialIncentive_Quote ){
                    FITriggerNewList.add(quoteLine);
                }
                else if(quoteLine.Pricing_Quote_Program_Nm__c == Label.Pricing_Program_Code_Software){
                    swTriggerNewList.add(quoteLine);
                }
                if(Trigger.newMap != null){
                    if(quoteLine.Pricing_Quote_Program_Nm__c == Label.Pricing_Program_Code_Tender ){
                        iqrTriggerNewMap.put(quoteLine.Id,quoteLine);
                    }else if(allPSGRecordTypes.contains(recordTypeMap.get(quoteLine.RecordTypeId))){
                        psgTriggerNewMap.put(quoteLine.Id,quoteLine);
                    }else if(quoteLine.RecordTypeId == cpRecordType){
                        psgTriggerCPNewMap.put(quoteLine.Id,quoteLine);
                    }else if(quoteLine.Pricing_Quote_Program_Nm__c == Label.Pricing_Tender_FinancialIncentive_Quote ){
                        FITriggerNewMap.put(quoteLine.Id,quoteLine);
                    }
                }
            }
        }
        if(Trigger.old != null){
            for(SBQQ__QuoteLine__c quoteLine : (List<SBQQ__QuoteLine__c>)Trigger.new){
                SBQQ__QuoteLine__c oldQLI = (SBQQ__QuoteLine__c) trigger.oldMap.get(quoteLine.Id);
                if(quoteLine.Pricing_Quote_Program_Nm__c == Label.Pricing_Program_Code_Tender){
                    iqrTriggerOldList.add(oldQLI);
                    iqrTriggerOldMap.put(quoteLine.Id,oldQLI);
                }else if(allPSGRecordTypes.contains(recordTypeMap.get(quoteLine.RecordTypeId))){
                    psgTriggerOldList.add(oldQLI);
                    psgTriggerOldMap.put(quoteLine.Id,oldQLI);
                }else if(quoteLine.Pricing_Quote_Program_Nm__c == Label.Pricing_Program_Code_PSG && quoteLine.RecordTypeId == cpRecordType){
                    //psgTriggerCPNewMap.add(psgTriggerCPNewMap);
                    psgTriggerCPOldList.add(oldQLI);
                    psgTriggerCPOldMap.put(quoteLine.Id,oldQLI);
                }else if(quoteLine.Pricing_Quote_Program_Nm__c == Label.Pricing_Tender_FinancialIncentive_Quote ){
                    FITriggerOldList.add(oldQLI);
                    FITriggerOldMap.put(quoteLine.Id,oldQLI);
                }
                else if(quoteLine.Pricing_Quote_Program_Nm__c == Label.Pricing_Program_Code_Software){
                    swTriggerOldList.add(oldQLI);
                    swTriggerOldMap.put(quoteLine.Id,oldQLI);
                }
            }
        } 
    }
    
    public override void afterInsert() {
        system.debug('PSGQuoteLine afterInsert Start 108 ***NARA*** '+Limits.getCpuTime());
        QuoteLineBusinessLogic.hasRunOnce = Test.isRunningTest();
        if(!QuoteLineBusinessLogic.isStopTriggerFromFlow && isActive('CreateQuoteLineStatusAgeRecord') && iqrTriggerNewList.size() > 0){            
            QuoteLineBusinessLogic.CreateQuoteLineStatusAgeRecord(iqrTriggerNewList,Trigger.isInsert);
        } 
        if(isActive('CreateFIQuoteLineStatusAgeRecord') && FITriggerNewList.size() > 0){            
            QuoteLineBusinessLogic.CreateQuoteLineStatusAgeRecord(FITriggerNewList,Trigger.isInsert);
        } 
        //  }
        if(isActive('PSG_QuoteLine_After_Insert') && psgTriggerNewList.size() > 0 ){
        	//PSG_QuoteLineBusinessLogic.afterInsertUpdateOperations(psgTriggerNewList,Trigger.isInsert,psgTriggerOldMap,psgTriggerNewMap);    
        }
        if(isActive('PSG_CPQuoteLine_After_Insert')&& psgTriggerCPNewList.size() > 0 ){ 
            //PSG_CPQuoteLinesBusinessLogic.afterInsertUpdateOperations(psgTriggerCPNewList,Trigger.isInsert,psgTriggerCPOldMap,psgTriggerNewMap);
        }
        system.debug('PSGQuoteLine afterInsert End 125 ***NARA*** '+Limits.getCpuTime());
         //Citrus changes - AI Integration for Pricing Application
        if(isActive('Pricing_Application_AI_Integration') && iqrTriggerNewList.size() > 0){
             system.debug('INSIDE QUOTELINETRIGGERHANDLER INSERT handleAIIntegrationForPricing METHOD CALL'+iqrTriggerNewList);
            QuoteLineBusinessLogic.handleAIIntegrationForPricing(iqrTriggerNewList, iqrTriggerOldMap,Trigger.isInsert);
        }
    }
    public override void beforeInsert() {
        system.debug('PSGQuoteLine BeforeInsert Start 128 ***NARA*** '+Limits.getCpuTime());
        if(!QuoteLineBusinessLogic.isStopTriggerFromFlow && isActive('Update_QuoteLine_Number')  && iqrTriggerNewList.size() > 0){
            QuoteLineBusinessLogic.updateQuoteLineNumber(iqrTriggerNewList);
        }
        if(isActive('Pricing_Update_FI_QuoteLine_Number')  && FITriggerNewList.size() > 0){
            QuoteLineBusinessLogic.updateQuoteLineNumber(FITriggerNewList);
        }
        if(!QuoteLineBusinessLogic.isStopTriggerFromFlow && isActive('Update_QuoteLine_Details') && iqrTriggerNewList.size() > 0){
            QuoteLineBusinessLogic.updateQuoteLineDetails(iqrTriggerNewList,Trigger.isInsert,iqrTriggerOldMap);
        }
        if(isActive('Pricing_Update_FI_QuoteLine_Details') && FITriggerNewList.size() > 0){
            QuoteLineBusinessLogic.updateQuoteLineDetails(FITriggerNewList,Trigger.isInsert,FITriggerOldMap);
        }
        if(!QuoteLineBusinessLogic.isStopTriggerFromFlow && isActive('Pricing_Validate_Product_Mismatch') && iqrTriggerNewList.size() > 0) {
            QuoteLineBusinessLogic.validateProductMismatch(iqrTriggerNewList,Trigger.isInsert,iqrTriggerOldMap);
        }

        if(isActive('PSG_QuoteLine_Before_Insert') && psgTriggerNewList.size() > 0 ){
            //PSG_QuoteLineBusinessLogic.beforeInsertUpdateOperations(psgTriggerNewList,Trigger.isInsert,null);     
        }
        //added
        if(isActive('PSG_CPQuoteLine_Before_Insert') && psgTriggerCPNewList.size() > 0 ){
            //PSG_CPQuoteLinesBusinessLogic.beforeInsertUpdateOperations(psgTriggerCPNewList,Trigger.isInsert, psgTriggerCPOldMap);     
        }   
	if(isActive('Pricing_SW_QuoteLineBeforeInsert') && swTriggerNewList.size() > 0){
		Pricing_SW_QuoteLineBusinessLogic.isCloneBeforeInsertUpdateoperation(swTriggerNewList,swTriggerOldMap,Trigger.isInsert);    
        }  
        system.debug('PSGQuoteLine BeforeInsert End 155 ***NARA*** '+Limits.getCpuTime());
    }
    public override void afterUpdate() {
        system.debug('PSGQuoteLine afterUpdate Start 158 ***NARA*** '+Limits.getCpuTime());
        QuoteLineBusinessLogic.hasRunOnce = Test.isRunningTest();
        if(!QuoteLineBusinessLogic.isStopTriggerFromFlow && isActive('update_Quote_Status') && iqrTriggerNewList.size() > 0){
            QuoteLineBusinessLogic.updateQuoteStatus(iqrTriggerNewList,iqrTriggerOldMap);
        } 
        if(isActive('Pricing_update_FI_Quote_Status') && FITriggerNewList.size() > 0){
            QuoteLineBusinessLogic.updateQuoteStatus(FITriggerNewList,FITriggerOldMap);
        } 
        if(!QuoteLineBusinessLogic.isStopTriggerFromFlow && isActive('Generate_Quote_Letter') && iqrTriggerNewList.size() > 0){
            QuoteLineBusinessLogic.generateQuoteLetter(iqrTriggerNewList,iqrTriggerOldMap);
        }
        if(isActive('Pricing_Generate_FI_Quote_Letter') && FITriggerNewList.size() > 0){
            QuoteLineBusinessLogic.generateQuoteLetter(FITriggerNewList,FITriggerOldMap);
        }
        if(!QuoteLineBusinessLogic.isStopTriggerFromFlow && isActive('UpdateQuoteLineStatusAgeRecord') && iqrTriggerNewList.size() > 0){
            QuoteLineBusinessLogic.UpdateQuoteLineStatusAgeRecord(iqrTriggerNewList,iqrTriggerOldMap,Trigger.isInsert,false,null,null,null,null);
        }
	 if(isActive('UpdateFIQuoteLineStatusAgeRecord') && FITriggerNewList.size() > 0){
            QuoteLineBusinessLogic.UpdateQuoteLineStatusAgeRecord(FITriggerNewList,FITriggerOldMap,Trigger.isInsert,false,null,null,null,null);
        }
        if(isActive('PSG_QuoteLine_After_Update') && psgTriggerNewList.size() > 0 ){
        	//PSG_QuoteLineBusinessLogic.afterInsertUpdateOperations(psgTriggerNewList,Trigger.isInsert,psgTriggerOldMap,psgTriggerNewMap);
        }
        //Citrus changes - AI Integration for Pricing Application
        if(isActive('Pricing_Application_AI_Integration') && iqrTriggerNewList.size() > 0){
            QuoteLineBusinessLogic.handleAIIntegrationForPricing(iqrTriggerNewList, iqrTriggerOldMap,Trigger.isInsert);
        }
        //Citrus changes end
        
	/*if(isActive('Sales_QuoteLine_After_Update')&& psgTriggerNewList.size() > 0){
            Sales_PriceChangeWarning.priceMismatchCheck(psgTriggerNewList,psgTriggerOldMap);
        }*/ 
        system.debug('PSGQuoteLine afterUpdate End 184 ***NARA*** '+Limits.getCpuTime());
    }
    public override void beforeUpdate() {
        system.debug('PSGQuoteLine BeforeUpdate Start 187 ***NARA*** '+Limits.getCpuTime());
        // if(!QuoteLineBusinessLogic.hasRunOnce){            
        if(!QuoteLineBusinessLogic.isStopTriggerFromFlow && isActive('Validate_Change_Request_Edit') && iqrTriggerNewList.size() > 0){
            QuoteLineBusinessLogic.validateChangeRequestEdit(iqrTriggerNewList,Trigger.isInsert,iqrTriggerOldMap);
        } 
        if(isActive('Pricing_Validate_FI_Change_Request_Edit') && FITriggerNewList.size() > 0){
            QuoteLineBusinessLogic.validateChangeRequestEdit(FITriggerNewList,Trigger.isInsert,FITriggerOldMap);
        } 
        
        if(!QuoteLineBusinessLogic.isStopTriggerFromFlow && isActive('Validate_QL_PFIR_Edit_Not_RPM') && iqrTriggerNewList.size() > 0){
            QuoteLineBusinessLogic.validateQLEditWithPFIRNotRPM(iqrTriggerNewList,iqrTriggerOldMap);
        }
        
        if(!QuoteLineBusinessLogic.isStopTriggerFromFlow && isActive('Update_QuoteLine_Details_Before_Update') && iqrTriggerNewList.size() > 0){
            QuoteLineBusinessLogic.updateQuoteLineDetails(iqrTriggerNewList,Trigger.isInsert,iqrTriggerOldMap);
        }
        if(isActive('Update_FIQuoteLine_Details_Before_Update') && FITriggerNewList.size() > 0){
            QuoteLineBusinessLogic.updateQuoteLineDetails(FITriggerNewList,Trigger.isInsert,FITriggerOldMap);
        }

        if(!QuoteLineBusinessLogic.isStopTriggerFromFlow && isActive('Pricing_Validate_Product_Mismatch') && iqrTriggerNewList.size() > 0) {
            QuoteLineBusinessLogic.validateProductMismatch(iqrTriggerNewList,Trigger.isInsert,iqrTriggerOldMap);
        }
        
        if(isActive('PSG_QuoteLine_Before_Update' ) && psgTriggerNewList.size() > 0 ){ 
            //PSG_QuoteLineBusinessLogic.beforeInsertUpdateOperations(psgTriggerNewList,Trigger.isInsert,(Map<Id, SBQQ__QuoteLine__c>) psgTriggerOldMap);
        }
        if(isActive('PSG_CPQuoteLine_Before_Update') && psgTriggerCPNewList.size() > 0 ){ 
            //PSG_CPQuoteLinesBusinessLogic.beforeInsertUpdateOperations(psgTriggerCPNewList,Trigger.isInsert,(Map<Id, SBQQ__QuoteLine__c>) psgTriggerCPOldMap);
        }
        //  }
	        if(isActive('Pricing_SW_QuoteLineBeforeUpdate') && swTriggerNewList.size() > 0){
		    Pricing_SW_QuoteLineBusinessLogic.isCloneBeforeInsertUpdateoperation(swTriggerNewList,swTriggerOldMap,Trigger.isInsert);    
        } 
        system.debug('PSGQuoteLine BeforeUpdate End 221 ***NARA*** '+Limits.getCpuTime());
    }
}