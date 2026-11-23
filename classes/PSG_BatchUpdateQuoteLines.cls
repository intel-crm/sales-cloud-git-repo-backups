@isTest
/****************************************************************************************************
Apex Class Name : PSG_BatchUpdateQuoteLines
Version         : 1.0 
Created Date    : 4/8/2021
Function        : This class updates quotelines in batches during PRID revision
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Vijaykanth                  4/8/2021               Created
*****************************************************************************************************/
/*
global class PSG_BatchUpdateQuoteLines implements Database.Batchable<sObject>, Database.Stateful{
    public DateTime dtWhen;
    global integer resursiveCounter;
    public Map<String,Set<String>> refreshUnderlyingQuoteMap = new Map<String,Set<String>>(); 
    public Set<Id> quoteLinesToIgnoreUpdateSet;
    public Boolean onlyDollarChangeUpdate;
    public Boolean quoteLineInitiated;
    public List<SBQQ__QuoteLine__c> quoteLineListToProcess=new List<SBQQ__QuoteLine__c>();
    public Map<String,String> quoteLineApiToPridApiMap = new Map<String,String>();
    public Map<String,String> pridApiToQuoteLineApiMap = new Map<String,String>();
    public static Map<String,Set<String>> revisionTriggerQLFieldMap = new Map<String,Set<String>>();
    public static Map<String,Set<String>> updationFieldQLMap = new Map<String,Set<String>>();
    public static Map<String,Set<String>> revisionFieldsQLMap = new Map<String,Set<String>>();
    
    public static Map<String,Set<String>> revisionTriggerPridFieldMap = new Map<String,Set<String>>();
    public static Map<String,Set<String>> updationFieldPridMap = new Map<String,Set<String>>();
    public static Map<String,Set<String>> revisionFieldsPridMap = new Map<String,Set<String>>();
    
    
    public PSG_BatchUpdateQuoteLines(){
        dtWhen = system.now();
        for(PSG_PRID_Mapping__mdt pridRec :[SELECT Id,PSG_PRID_Type__c,psg_revision_trigger_field_prid__c,psg_cpq_revision_trigger_field_ql__c,
                                            core_cpq_updation_trigger_field_prid__c,psg_updation_trigger_field_ql__c,psg_revision_fields_QL__c,
                                            psg_revision_fields_prid__c from PSG_PRID_Mapping__mdt where PSG_Active__c = true]){
            if(String.isNotBlank(pridRec.psg_cpq_revision_trigger_field_ql__c)){
                revisionTriggerQLFieldMap.put(pridRec.PSG_PRID_Type__c,new Set<String>((pridRec.psg_cpq_revision_trigger_field_ql__c).split(':')));   
            }else{
                revisionTriggerQLFieldMap.put(pridRec.PSG_PRID_Type__c,new Set<String>());
            }
            if(String.isNotBlank(pridRec.psg_updation_trigger_field_ql__c)){
                updationFieldQLMap.put(pridRec.PSG_PRID_Type__c,new Set<String>((pridRec.psg_updation_trigger_field_ql__c).split(':')));
            }else{
                updationFieldQLMap.put(pridRec.PSG_PRID_Type__c,new Set<String>());
            } 
            if(String.isNotBlank(pridRec.psg_revision_fields_QL__c)){
                revisionFieldsQLMap.put(pridRec.PSG_PRID_Type__c,new Set<String>((pridRec.psg_revision_fields_QL__c).split(':')));
            }else{
                revisionFieldsQLMap.put(pridRec.PSG_PRID_Type__c,new Set<String>());
            } 
            if(String.isNotBlank(pridRec.psg_revision_trigger_field_prid__c)){
                revisionTriggerPridFieldMap.put(pridRec.PSG_PRID_Type__c,new Set<String>((pridRec.psg_revision_trigger_field_prid__c).split(':'))); 
            }else{
                revisionTriggerPridFieldMap.put(pridRec.PSG_PRID_Type__c,new Set<String>()); 
            }  
            if(String.isNotBlank(pridRec.core_cpq_updation_trigger_field_prid__c)){
                updationFieldPridMap.put(pridRec.PSG_PRID_Type__c,new Set<String>((pridRec.core_cpq_updation_trigger_field_prid__c).split(':'))); 
            }else{
                updationFieldPridMap.put(pridRec.PSG_PRID_Type__c,new Set<String>()); 
            }  
            if(String.isNotBlank(pridRec.psg_revision_fields_prid__c)){
                revisionFieldsPridMap.put(pridRec.PSG_PRID_Type__c,new Set<String>((pridRec.psg_revision_fields_prid__c).split(':'))); 
            }else{
                revisionFieldsPridMap.put(pridRec.PSG_PRID_Type__c,new Set<String>()); 
            } 
        }
    }
    /*public Database.querylocator start(Database.BatchableContext bc){
        return Database.getQueryLocator([SELECT Id,core_cpq_dollar_change_flag_cb__c,price_suggested_resale_amt__c,core_cpq_quote_line_type_txt__c,
                                        core_cpq_PRID__r.price_amt__c,core_cpq_PRID__r.core_cpq_lower_bound_qty_nbr__c,
                                        core_cpq_PRID__r.core_cpq_upper_bound_qty_nbr__c,core_cpq_PRID__r.core_cpq_quantity_eau_nbr__c,core_cpq_PRID__r.core_cpq_quoteline__c 
                                        FROM SBQQ__QuoteLine__c WHERE core_cpq_PRID__r.core_cpq_update_underlying_quotelines_cb__c = true 
                                        and core_cpq_PRID__c != null and core_cpq_PRID__r.core_cpq_active_cb__c = true 
                                        and core_cpq_quote_line_type_txt__c != null]);
    }*/
    /*
    public Iterable<SObject> start(Database.BatchableContext bc){
        return quoteLineListToProcess;
    }
    /****************************************************************************************************************
    * Method Name:execute
    * Date: 4/8/2021
    * Description: Method to updateUnderlying quotelines.
    ***************************************************************************************************************************/
    /*
    public void execute(Database.BatchableContext bc, List<sObject> scope){
    try{	SBQQ.TriggerControl.disable();
            PRIDBusinessLogic.updateUnderlyingQL(quoteLineApiToPridApiMap,quoteLinesToIgnoreUpdateSet,scope,onlyDollarChangeUpdate,quoteLineInitiated,pridApiToQuoteLineApiMap);
        }catch(exception ex){

        }
    }
    public void finish(Database.BatchableContext bc){
        SBQQ.TriggerControl.enable();
        List<Core_Log_Entry__c> lstLogEntryRecords = createLogEntryRecords();
        List<Database.SaveResult> resultsCreateLogRecords = Database.insert(lstLogEntryRecords, false);
    }
    /****************************************************************************************************************
    * Method Name:createLogEntryRecords
    * Date: 4/8/2021
    * Description: Method to create and assign log Entries.
    ***************************************************************************************************************************/
    /*private List<Core_Log_Entry__c> createLogEntryRecords(){
        List<Core_Log_Entry__c> lstLogEntry = new List<Core_Log_Entry__c>();
        DateTime dtnow = system.now();
        decimal duration = ((dtnow.getTime())/1000) - ((dtWhen.getTime())/1000);
        Core_Log_Entry__c addLogEntry = new Core_Log_Entry__c ();
        addLogEntry.Core_Origin__c = 'PSG_BatchUpdatePRIDQuoteLines/Batch for Processing PRID Updates';
        addLogEntry.Core_Project__c = 'PSG Quote Request (PSG)';
        addLogEntry.Core_Scope__c = 'PSG Inbound Processing';
        addLogEntry.Core_Severity__c = 'Information';
        addLogEntry.Core_Message__c = 'Batch for Processing PRID Updates';
        addLogEntry.Core_When__c = dtWhen;
        addLogEntry.Core_Details__c = 'Duration: ' + duration+' for processing batch';
        lstLogEntry.add(addLogEntry);        
        return(lstLogEntry);
    }
}
*/

public class PSG_BatchUpdateQuoteLines{

}