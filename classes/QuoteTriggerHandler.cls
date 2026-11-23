/**
 * @description       : 
 * @author            : Mahesh Biradar
 * @group             : 
 * @last modified on  : 03-11-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class QuoteTriggerHandler extends TriggerHandler {
    //IQR Context Variables
    public List<SBQQ__Quote__c> iqrTriggerNewList = new List<SBQQ__Quote__c>();
    public List<SBQQ__Quote__c> iqrTriggerOldList = new List<SBQQ__Quote__c>();
    
    public Map<Id,SBQQ__Quote__c> iqrTriggerOldMap = new Map<Id,SBQQ__Quote__c>();
    public Map<Id,SBQQ__Quote__c> iqrTriggerNewMap = new Map<Id,SBQQ__Quote__c>();
    
    //Financial Incentive Context Variables
    public List<SBQQ__Quote__c> FITriggerNewList = new List<SBQQ__Quote__c>();
    public List<SBQQ__Quote__c> FITriggerOldList = new List<SBQQ__Quote__c>();
    
    public Map<Id,SBQQ__Quote__c> FITriggerOldMap = new Map<Id,SBQQ__Quote__c>();
    public Map<Id,SBQQ__Quote__c> FITriggerNewMap = new Map<Id,SBQQ__Quote__c>();
    
    //PSG Context Variables
    public List<SBQQ__Quote__c> psgTriggerNewList = new List<SBQQ__Quote__c>();
    public List<SBQQ__Quote__c> psgTriggerOldList = new List<SBQQ__Quote__c>();
    public Map<Id,SBQQ__Quote__c> psgTriggerOldMap = new Map<Id,SBQQ__Quote__c>();
    public Map<Id,SBQQ__Quote__c> psgTriggerNewMap = new Map<Id,SBQQ__Quote__c>();
    
    //PSG Context Variables for CP quotes
    public List<SBQQ__Quote__c> psgCpTriggerNewList = new List<SBQQ__Quote__c>();
    public List<SBQQ__Quote__c> psgCpTriggerOldList = new List<SBQQ__Quote__c>();
    public Map<Id,SBQQ__Quote__c> psgCpTriggerOldMap = new Map<Id,SBQQ__Quote__c>();
    public Map<Id,SBQQ__Quote__c> psgCpTriggerNewMap = new Map<Id,SBQQ__Quote__c>();
    
  //Retails Context Variables//added by Retail team
   /* public List<SBQQ__Quote__c> retailTriggerNewList = new List<SBQQ__Quote__c>();
    public List<SBQQ__Quote__c> retailTriggerOldList = new List<SBQQ__Quote__c>();
    public Map<Id,SBQQ__Quote__c> retailTriggerOldMap = new Map<Id,SBQQ__Quote__c>();
    public Map<Id,SBQQ__Quote__c> retailTriggerNewMap = new Map<Id,SBQQ__Quote__c>();*/
  
    //SW Context Variables
    public List<SBQQ__Quote__c> swTriggerNewList = new List<SBQQ__Quote__c>();
    public List<SBQQ__Quote__c> swTriggerOldList = new List<SBQQ__Quote__c>();
    public Map<Id,SBQQ__Quote__c> swTriggerOldMap = new Map<Id,SBQQ__Quote__c>();
    public Map<Id,SBQQ__Quote__c> swTriggerNewMap = new Map<Id,SBQQ__Quote__c>();
  
    Id CPRecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get('PSG_Quote_Contract_Pricing').getRecordTypeId();
    
    public QuoteTriggerHandler(){
        if(Trigger.new != null){
            for(SBQQ__Quote__c quote : (List<SBQQ__Quote__c>)Trigger.new){
                system.debug('quotprogram:'+quote.Pricing_Quote_Program_Nm__c);
                if(quote.Pricing_Quote_Program_Nm__c == Label.Pricing_Program_Code_Tender ){
                    iqrTriggerNewList.add(quote);
                }else if(quote.Pricing_Quote_Program_Nm__c == Label.Pricing_Program_Code_PSG && quote.RecordTypeId != CPRecordTypeId && quote.core_cpq_quote_type_nm__c != 'Contract Pricing'){
                    psgTriggerNewList.add(quote);
                }
                else if(quote.Pricing_Quote_Program_Nm__c == Label.Pricing_Program_Code_PSG && (quote.RecordTypeId == CPRecordTypeId || quote.core_cpq_quote_type_nm__c == 'Contract Pricing')){
                    psgCpTriggerNewList.add(quote);
                }
                else if(quote.Pricing_Quote_Program_Nm__c == Label.Pricing_Tender_FinancialIncentive_Quote){
                    FITriggerNewList.add(quote);
                }
                /*else if(quote.Pricing_Quote_Program_Nm__c == Label.Pricing_Program_Code_Retail){//added by Retail team
                    retailTriggerNewList.add(quote);
                }*/
                else if(quote.Pricing_Quote_Program_Nm__c == Label.Pricing_Program_Code_Software){
                    swTriggerNewList.add(quote);
                }
        
                if(Trigger.newMap != null){
                    if(quote.Pricing_Quote_Program_Nm__c == Label.Pricing_Program_Code_Tender ){
                        iqrTriggerNewMap.put(quote.Id,quote);
                    }else if(quote.Pricing_Quote_Program_Nm__c == Label.Pricing_Program_Code_PSG && quote.RecordTypeId != CPRecordTypeId && quote.core_cpq_quote_type_nm__c != 'Contract Pricing'){
                        psgTriggerNewMap.put(quote.Id,quote);
                    }
                    else if(quote.Pricing_Quote_Program_Nm__c == Label.Pricing_Program_Code_PSG && (quote.RecordTypeId == CPRecordTypeId || quote.core_cpq_quote_type_nm__c == 'Contract Pricing')){
                        psgCpTriggerNewMap.put(quote.Id,quote);
                    }
                    else if(quote.Pricing_Quote_Program_Nm__c == Label.Pricing_Tender_FinancialIncentive_Quote){
                        FITriggerNewMap.put(quote.Id,quote);
                    }
                    /*else if(quote.Pricing_Quote_Program_Nm__c ==  Label.Pricing_Program_Code_Retail){//added by Retail team
                        retailTriggerNewMap.put(quote.Id,quote);
                    }*/
                    else if(quote.Pricing_Quote_Program_Nm__c == Label.Pricing_Program_Code_Software){
                        swTriggerNewMap.put(quote.ID,quote);
                    }
                }
            }
        }
        if(Trigger.old != null){
            for(SBQQ__Quote__c quote : (List<SBQQ__Quote__c>)Trigger.old){
                if(quote.Pricing_Quote_Program_Nm__c == Label.Pricing_Program_Code_Tender ){
                  iqrTriggerOldList.add(quote);
                }else if(quote.Pricing_Quote_Program_Nm__c == Label.Pricing_Program_Code_PSG ){
                  psgTriggerOldList.add(quote);
                }
                if(Trigger.oldMap != null){
                    if(quote.Pricing_Quote_Program_Nm__c == Label.Pricing_Program_Code_Tender ){
                      iqrTriggerOldMap.put(quote.Id,quote);
                    }else if(quote.Pricing_Quote_Program_Nm__c == Label.Pricing_Program_Code_PSG ){
                      psgTriggerOldMap.put(quote.Id,quote);
                    }
                }
            }
            
            for(SBQQ__Quote__c quote : (List<SBQQ__Quote__c>)Trigger.new){
                SBQQ__Quote__c oldQuote = (SBQQ__Quote__c) trigger.oldMap.get(quote.Id);
                if(quote.Pricing_Quote_Program_Nm__c == Label.Pricing_Program_Code_Tender ){
                    iqrTriggerOldList.add(oldQuote);
                    iqrTriggerOldMap.put(quote.Id,oldQuote);
                }else if(quote.Pricing_Quote_Program_Nm__c == Label.Pricing_Program_Code_PSG && quote.RecordTypeId != CPRecordTypeId && quote.core_cpq_quote_type_nm__c != 'Contract Pricing'){
                    psgTriggerOldList.add(oldQuote);
                    psgTriggerOldMap.put(quote.Id,oldQuote);
                }
                else if(quote.Pricing_Quote_Program_Nm__c == Label.Pricing_Program_Code_PSG && (quote.RecordTypeId == CPRecordTypeId || quote.core_cpq_quote_type_nm__c == 'Contract Pricing')){
                    psgCpTriggerOldList.add(oldQuote);
                    psgCpTriggerOldMap.put(quote.Id,oldQuote);
                }
                else if(quote.Pricing_Quote_Program_Nm__c == Label.Pricing_Tender_FinancialIncentive_Quote){
                    FITriggerOldList.add(oldQuote);
                    FITriggerOldMap.put(quote.Id,oldQuote);
                }
        /*else if(quote.Pricing_Quote_Program_Nm__c == Label.Pricing_Program_Code_Retail ){//added by Retail team
                    retailTriggerOldList.add(oldQuote);
                    retailTriggerOldMap.put(quote.Id,oldQuote);
                }*/
                else if(quote.Pricing_Quote_Program_Nm__c == Label.Pricing_Program_Code_Software){
                    swTriggerOldList.add(oldQuote);
                    swTriggerOldMap.put(quote.Id,oldQuote);
                }
            }
        } 
    }
    
    public override void afterInsert() {
        if(isActive('Update_Quote_Comments') && iqrTriggerNewList.size() > 0){
            //Create Comments for the Quote
            QuoteBusinessLogic.updateQuoteCommnents(iqrTriggerNewList);
            QuoteBusinessLogic.insertDocumentShareOnQuote(iqrTriggerNewList);
        }
        if(isActive('Pricing_Update_FI_Quote_Document') && FITriggerNewList.size() > 0){
            QuoteBusinessLogic.insertDocumentShareOnQuote(FITriggerNewList);
        }
        
        if(isActive('check_Change_In_Primary_Contact') && iqrTriggerNewList.size() > 0){
            //Check if the Primary Contact is valid and update the owner with the OEM user
            QuoteBusinessLogic.checkChangeInPrimaryContact(iqrTriggerNewList,Trigger.isInsert,iqrTriggerOldMap);
        }
        
        if(isActive('Share_Quote_and_Comments') && iqrTriggerNewList.size() > 0){
            //Share Quote and Comment Records using Batch Execution
            QuoteBusinessLogic.publishIQR(iqrTriggerNewMap.keySet(),Label.Pricing_IQR_Event_Action_Quote_Share);
        }
        if(isActive('PSG_Quote_After_Insert') && psgTriggerNewList.size() > 0 && !Sales_ContractTriggerUtility.byPassQuoteTriggersOnContractRenewal){ 
            PSG_QuoteBusinessLogic.afterInsertUpdateOperations(psgTriggerNewList,psgTriggerOldMap,Trigger.isInsert);
        }
        if(isActive('PSG_CPQuote_After_Insert') && psgCpTriggerNewList.size() > 0 && !Sales_ContractTriggerUtility.byPassQuoteTriggersOnContractRenewal){ 
            PSG_CPQuoteBusinessLogic.afterInsertUpdateOperations(psgCpTriggerNewList,psgCpTriggerOldMap,Trigger.isInsert);
        }
        /*if(retailTriggerNewList.size() > 0){ //added by retails team
            Retail_CPQ_QuoteBusinessLogic.afterInsertUpdateOperations(retailTriggerNewList,retailTriggerOldMap,Trigger.isInsert);
        }*/
        if(isActive('Pricing_SW_QuoteAfterInsert') && swTriggerNewList.size() > 0){
            //Pricing_SW_QuoteBusinessLogic.updateCRMSWFlagOnOpportunity(swTriggerNewList);            
            Pricing_SW_QuoteBusinessLogic.updateCRMSWOnOpportunity(swTriggerNewList);
        }
        
    }
    public override void beforeInsert(){
        if(isActive('Update_Quote_Details') && iqrTriggerNewList.size() > 0){
            QuoteBusinessLogic.updateQuoteDetails(iqrTriggerNewList,Trigger.isInsert,iqrTriggerOldMap);
        }
        if(isActive('Pricing_Update_FI_Quote_Details') && FITriggerNewList.size() > 0){
            QuoteBusinessLogic.updateQuoteDetails(FITriggerNewList,Trigger.isInsert,FITriggerOldMap);
        }
        if(isActive('PSG_Quote_Before_Insert') && psgTriggerNewList.size() > 0){          
            PSG_QuoteBusinessLogic.beforeInsertUpdateOperations(psgTriggerNewList,psgTriggerOldMap,Trigger.isInsert);
        }
        if(isActive('PSG_CPQuote_Before_Insert') && psgCpTriggerNewList.size() > 0){        
            PSG_CPQuoteBusinessLogic.beforeInsertUpdateOperations(psgCpTriggerNewList,psgCpTriggerOldMap,Trigger.isInsert);
        }
    /*if(retailTriggerNewList.size() > 0){     //added by retails team   
            Retail_CPQ_QuoteBusinessLogic.beforeInsertUpdateOperations(retailTriggerNewList,retailTriggerOldMap,Trigger.isInsert);
        }*/
        if(isActive('Pricing_SW_QuoteBeforeInsert') && swTriggerNewList.size() > 0){
            Pricing_SW_QuoteBusinessLogic.updateRecordtypebyStatusandApprovalStatus(swTriggerNewList,swTriggerOldMap,Trigger.isInsert);    
        }  
         
    }
    public override void afterUpdate(){
        if(isActive('check_Change_In_Contact_after_update') && iqrTriggerNewList.size() > 0){
            //check if Primary Contact Changes and update the owner with the new OEM user               
            QuoteBusinessLogic.checkChangeInPrimaryContact(iqrTriggerNewList,Trigger.isInsert,iqrTriggerOldMap);
        }
        if(isActive('PSG_Quote_After_Update') && psgTriggerNewList.size() > 0 && !Sales_ContractTriggerUtility.byPassQuoteTriggersOnContractRenewal){
            PSG_QuoteBusinessLogic.afterInsertUpdateOperations(psgTriggerNewList,psgTriggerOldMap,Trigger.isInsert);
            if(psgTriggerNewList.size()>0){
                Sales_QuoteUtility.afterUpdateQuoteOperation(psgTriggerNewList);
            } 
        }
        if(isActive('PSG_CPQuote_After_Update') && psgCpTriggerNewList.size() > 0 && !Sales_ContractTriggerUtility.byPassQuoteTriggersOnContractRenewal){
            PSG_CPQuoteBusinessLogic.afterInsertUpdateOperations(psgCpTriggerNewList,psgCpTriggerOldMap,Trigger.isInsert);
        }
    /*if(retailTriggerNewList.size() > 0){
      Retail_CPQ_QuoteBusinessLogic.afterInsertUpdateOperations(retailTriggerNewList,retailTriggerOldMap,Trigger.isInsert);//added by Retail team
        }*/
    }
    public override void beforeUpdate() {
       
        if(isActive('Update_CPQ_Opportunity_before_Update') && iqrTriggerNewList.size() > 0 ){
            QuoteBusinessLogic.updateCPQOpportunityField(iqrTriggerNewList,iqrTriggerOldMap);
        }
        if (isActive('Update_Quote_Details_Before_Update') && iqrTriggerNewList.size() > 0) {
            QuoteBusinessLogic.updateQuoteDetails(iqrTriggerNewList,Trigger.isInsert,iqrTriggerOldMap);
        }
        if (isActive('Update_FI_Quote_Details_Before_Update') && FITriggerNewList.size() > 0) {
            QuoteBusinessLogic.updateQuoteDetails(FITriggerNewList,Trigger.isInsert,FITriggerOldMap);
        }
        if(isActive('PSG_Quote_Before_Update') && psgTriggerNewList.size() > 0 && !Sales_ContractTriggerUtility.byPassQuoteTriggersOnContractRenewal) { 
            PSG_QuoteBusinessLogic.beforeInsertUpdateOperations(psgTriggerNewList,psgTriggerOldMap,Trigger.isInsert); 
        }
        
        if(isActive('PSG_CPQuote_Before_Update') && psgCpTriggerNewList.size() > 0 && !Sales_ContractTriggerUtility.byPassQuoteTriggersOnContractRenewal) { 
            PSG_CPQuoteBusinessLogic.beforeInsertUpdateOperations(psgCpTriggerNewList,psgCpTriggerOldMap,Trigger.isInsert); 
        }
        /*if(isActive('Update_CPQ_Opportunity_before_Update') && iqrTriggerNewList.size() > 0 ){
            QuoteBusinessLogic.updateCPQOpportunityField(iqrTriggerNewList,iqrTriggerOldMap);
        }*/
        /*if(retailTriggerNewList.size() > 0) { //added by Retail team
            Retail_CPQ_QuoteBusinessLogic.beforeInsertUpdateOperations(retailTriggerNewList,retailTriggerOldMap,Trigger.isInsert); 
        }*/
         if(isActive('Pricing_SW_QuoteBeforeUpdate') && swTriggerNewList.size() > 0){
            Pricing_SW_QuoteBusinessLogic.updateRecordtypebyStatusandApprovalStatus(swTriggerNewList,swTriggerOldMap,Trigger.isInsert);
             
        } 
        
        
    }    
}