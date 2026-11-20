/****************************************************************************************************************************
Apex Class Name     : PRM_VXRecommendation_Handler 
Version             : 1.0
Created Date        : Mar 2020

Modification Log    :
* Developer                 Date                    Description
* --------------------------------------------------------------------------------------------------------------------------
* Srishty Sharma      18-Mar-2020                   Added a new method vxRecommnedationUpdateCheck to restrict update on vsRecommendation records without specifying grouping method 

****************************************************************************************************************************/
public class PRM_VXRecommendation_Handler extends TriggerHandler{
    //TWC729-6800 EOL activities--Start
    Id recordTypeOPID= Schema.SObjectType.PRM_Value_Exchange_Recommendation__c.getRecordTypeInfosByName().get(System.Label.PRM_RecordType_OPID).getRecordTypeId();
    public static String CimPrimeEol=System.label.PRM_CIM_PRIME_Switch;// TWC729-6990 : CIM Prime EOL – Code changes switch set up for regression testing
    //Method sends the List of records and its record type while updating for validation.
    public override void beforeUpdate() { 
        if(CimPrimeEol!='TRUE' || test.isrunningtest()){ // TWC729-6990 : CIM Prime EOL – Code changes switch set up for regression testing
        if(isActive('PRM_VXRecommendation_Switch')) {
            if(!System.isBatch() || Test.isRunningTest()) {    
                PRM_VXRecommendation_Utility.vxRecommnedationUpdateCheck(Trigger.new,recordTypeOPID);
                PRM_VXRecommendation_Utility.duplicateRecommendationcheck(Trigger.new,(Map<Id,PRM_Value_Exchange_Recommendation__c>)Trigger.OldMap,recordTypeOPID);
            }
            PRM_VXRecommendation_Utility.updateDuration(Trigger.new,(Map<Id,PRM_Value_Exchange_Recommendation__c>)Trigger.OldMap, true);
            
        }
        }}
    public override void beforeinsert() {
        if(CimPrimeEol!='TRUE' || test.isrunningtest()){ // TWC729-6990 : CIM Prime EOL – Code changes switch set up for regression testing
        if(isActive('PRM_VXRecommendation_Switch')) {
            if(!System.isBatch()) {    
                PRM_VXRecommendation_Utility.vxRecommnedationUpdateCheck(Trigger.new,recordTypeOPID);
                PRM_VXRecommendation_Utility.duplicateRecommendationcheck(Trigger.new,(Map<Id,PRM_Value_Exchange_Recommendation__c>)Trigger.OldMap,recordTypeOPID);
            }
            PRM_VXRecommendation_Utility.updateDuration(Trigger.new, null, false);
            
        }
        }}
    
    
    public override void afterUpdate(){
        if(CimPrimeEol!='TRUE'  || test.isrunningtest()){ // TWC729-6990 : CIM Prime EOL – Code changes switch set up for regression testing
        // System.debug('VXREc after update trigger entered');
        PRM_VXRecommendation_Utility.updateOrCreateACM(Trigger.new,(Map<Id,PRM_Value_Exchange_Recommendation__c>)Trigger.OldMap);
        PRM_VXRecommendation_Utility.opidOutboundMssg(Trigger.new,(Map<Id,PRM_Value_Exchange_Recommendation__c>)Trigger.OldMap);
        PRM_VXRecommendation_Utility.updateTierOnVxData(Trigger.new,(Map<Id,PRM_Value_Exchange_Recommendation__c>)Trigger.OldMap);
        }
    }
    
     public override void afterInsert(){
         if(CimPrimeEol!='TRUE'  || test.isrunningtest()){ // TWC729-6990 : CIM Prime EOL – Code changes switch set up for regression testing
         // System.debug('VXREc after Insert trigger entered');
     
   		 PRM_VXRecommendation_Utility.opidOutboundMssg(Trigger.new,null);
         }} //TWC729-6800 EOL activities--End
}