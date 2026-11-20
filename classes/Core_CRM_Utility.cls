/***************************************************************************************************
Class Name:  Core_CRM_Utility
Class Type: Utility Class 
Version     : 1.0
Created Date: 06 June 2023
Test class Name: Core_CRM_Utility_Test
Function    : This class contains generic methods used for CRM 
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Areefa banu              06/06/2023              Created
****************************************************************************************************/   
public without sharing class Core_CRM_Utility {
    // Static variable to store Opp Lock validation status
    public static Boolean oppLockValidationPerformed = false;
    public static String getCRMLabel(String name){
        Core_CRM_Labels__c crmLabel = Core_CRM_Labels__c.getValues(name);
        
        if(crmLabel!=null){
            return crmLabel.Value__c;
        }else{
            return '';
        }
    }
    //TWC4767-3431 - implementation of UCD and CIM logic switch
    public static boolean isUCDSwitchOn() {
        Map<String, CRM_UCD_CIM_switch__c> logicSwitch = CRM_UCD_CIM_switch__c.getall();
        boolean switchCheck = logicSwitch.containsKey('UCD_switch') && logicSwitch.get('UCD_switch').Active__c;
        return switchCheck;
    }
    //TWC3123-5659 - Devashish
    //Common Method to be called to check if PCC opportunity's associated QLs are in PFIR. If so, return true and throw error
    public static boolean lockOpportunity(List<Opportunity> OpptyList){
        oppLockValidationPerformed = true;
        Boolean toLock = false;
        List<Opportunity> PCCOpptyList = new List<Opportunity>();
        for(Opportunity oppty: OpptyList) {
            if(oppty.Core_Opportunity_Coverage_Nm__c =='Partner-Led Opportunity' && oppty.Core_Coverage_Type_Nm__c =='Deal Registration'){
                PCCOpptyList.add(oppty);
            }
        }
        if(PCCOpptyList.size()>0){
            List<SBQQ__QuoteLine__c> QuoteLineList = [select Id, Name, Pricing_Status_Nm__c, Pricing_Change_Request_cb__c, SBQQ__Quote__c,SBQQ__Quote__r.SBQQ__Opportunity2__c,Pricing_Quote_Program_Nm__c, Pricing_Program_Type_Nm__c 
                                                      from SBQQ__QuoteLine__c
                                                      where SBQQ__Quote__r.SBQQ__Opportunity2__c in: PCCOpptyList
                                                      AND Pricing_Status_Nm__c = 'Pending Further Intel Review'
                                                      AND Pricing_Change_Request_cb__c = false];
            if(QuoteLineList.size()>0){
                for(Opportunity opp:PCCOpptyList){
                    for(SBQQ__QuoteLine__c QL:QuoteLineList){
                        if(QL.SBQQ__Quote__r.SBQQ__Opportunity2__c == opp.Id){
                            toLock= true;
                        }
                    }
                }
            }
        }
        
        return toLock;
    } 
    
    /*
* TWC3123-5794    if(!oppProductList.isEmpty()){
* Common Method to return boolean value for atRisk Aura cmp and Opportunity Solution LWC Controllers; 
* return - False if PCC DEAL REG have all FI Products, True for Intel-Led and PCC design and deal REG if atleast one product is non-FI
*/
    public static boolean PCCDealReg_showTab(Id recordId) {
        Boolean showTab= false;       
        try {
            
            List<OpportunityLineItem> oliList= [select Id, Core_IsPCCOpportunity_cb__c,  Core_Financial_Incentive_Eligible_cb__c from OpportunityLineItem where OpportunityId = :recordId];
            if( !oliList.isEmpty() && oliList.size()>0) {                
                for(OpportunityLineItem oli : oliList) {
                    if(oli.Core_IsPCCOpportunity_cb__c == true && oli.Core_Financial_Incentive_Eligible_cb__c == false) {
                        showTab= true;
                    }
                    else if(oli.Core_IsPCCOpportunity_cb__c == false){
                        showTab= true;
                    }
                }              
            }
            else{
                showTab= true; 
            }
        }
        catch(Exception e) {PMP_Utility.logError(e, 'Core_CRM_Utility.PCCDealReg_showTab'); }
        return showTab;
    }
    // Jahnavi - TWC3123-5764 : KIIT: [DEV]: Sales Group LOV value API Name change 
    public static String getSalesGroupAPI(){
        
        List<Schema.PicklistEntry> entries = Account.Core_Sales_Groups__c.getDescribe().getPickListValues();
        String value = '';
        for(Schema.PicklistEntry ple  :entries ){
            if(ple.isActive()){
                value = ple.getValue();
                break;                
            }else
                continue;
        }
        return value;
        
    }
    
    @AuraEnabled(cacheable=true)
    public static List<SelectOption> getOppItemPickListValues(String fieldApiName){
        system.debug('fieldApiName'+fieldApiName);
        List<SelectOption> pickListValuesList= new List<SelectOption>();
        if(string.isNotBlank(fieldApiName)){
            // Map<String, Schema.SObjectField> fieldsMap= OpportunityLineItem.getSobjectType().getDescribe().fields.getMap();
            if(fieldApiName.contains('Competitor')){
            List<Schema.PicklistEntry> ple = OpportunityLineItem.Core_Competitor__c.getDescribe().getPicklistValues();
            
            system.debug('ple---'+ple);
            for(Schema.PicklistEntry pickListVal : ple){
                pickListValuesList.add(new SelectOption(pickListVal.getLabel(),pickListVal.getValue()));
            }
            }
        }
        system.debug('pickListValuesList'+pickListValuesList);
        return pickListValuesList;
    }
    
    
    public class SelectOption{
        @AuraEnabled
        public string label{get;set;}
        @AuraEnabled
        public string value{get; set;	}
        
        public SelectOption(String label , String value){
            this.label = label;
            this.value = value;
            
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<SelectOption> getDependantPickListValues(String controllingValue){
        
        return getDependentLOV ('OpportunityLineItem','Core_Competitor_Product__c',controllingValue,OpportunityLineItem.Core_Competitor__c) ;        
    }
    
    
    public static List<SelectOption> getDependentLOV(String ObjectName, String dependentField, String controllingValue, Schema.sObjectField ControllingField){
        Map<String,List<SelectOption>> dependentPicklistValues = new Map<String,List<SelectOption>>();
        String staticLabel = 'Picklist';
        try {
            //List<PCC_Wrapper.PCC_PicklistWrapper> pickListWrpList = new List<PCC_Wrapper.PCC_PicklistWrapper>();
            List<Schema.PicklistEntry> dependentEntries = Schema.getGlobalDescribe().get(ObjectName).getDescribe().fields.getMap().get(dependentField).getDescribe().getPicklistValues();
            List<Schema.PicklistEntry> controlEntries = ControllingField.getDescribe().getPicklistValues();
            String base64map = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
            if(controlEntries.size() > 0 && dependentEntries.size()>0){
                for (Schema.PicklistEntry entry : dependentEntries) {
                    //checks whether the picklist value is active and whether it has a corresponding valid bit set
                    if (String.isNotEmpty(String.valueOf(((Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')))) {
                        
                        //splits the validFor attribute in base64chars list by assigning the result of JSON.serialize method on the 'validFor' attribute of entry to a string
                        List<String> base64chars = String.valueOf(((Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')).split('');
                        
                        for (Integer index = 0; index < controlEntries.size() ; index++) {
                            //assigns a controlValue variable as either the value at the given index of controlEntries, or a default of "null" if this value is not active
                            Object controlValue = controlEntries == null ? (Object)(index == 1) : controlEntries[index].getValue();
                            if(controlValue == controllingValue){
                                Integer bitIndex = index / 6;
                                if (bitIndex > base64chars.size() - 1) {
                                    break;
                                }
                                Integer bitShift = 5 - Math.mod(index, 6);
                                
                                //performs a bitwise AND operation on the character from base64chars and a shifted binary digit based on the value of bitShift.
                                if  (controlValue == null || (base64map.indexOf( base64chars[ bitIndex ] ) & (1 << bitShift)) == 0){
                                    continue;
                                }
                                if (!dependentPicklistValues.containsKey(staticLabel)) {
                                    dependentPicklistValues.put(staticLabel, new List<SelectOption>());
                                }
                                
                                dependentPicklistValues.get(staticLabel).add(new SelectOption(entry.getLabel(),entry.getValue()) );
                            } 
                        }
                    }
                }
            }
        } catch (Exception ex) { System.debug('error');
                               }
        
        return dependentPicklistValues.get(staticLabel);
    }
    
    @AuraEnabled
    public static String updateCompetitorData( String competitor , String competitorProduct, String textvalue, Id recordID)
    {
        List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
        oliList = [Select id,Core_Competitor__c, Core_Competitor_Product__c, OpportunityId from OpportunityLineItem where Core_Status__c IN ( 'Pending' ,'Production Win Approved','On Hold','Win Approved','Production Win' ) and Core_Competitor_Product__c = null  and OpportunityId =: recordID];
        List<Core_Log_Entry__c> failedData = new List<Core_Log_Entry__c>();
        Database.SaveResult[] srList = null;
        if(!oliList.isEmpty()){
            for(OpportunityLineItem oliS : oliList){
                oliS.Core_Competitor__c = competitor;
                oliS.Core_Competitor_Product__c = competitorProduct;
                oliS.Core_OtherCompetitor_Product_Txt__c = textvalue;
            }
            srList =  Database.update(oliList,false);
        }
        
        if(!srList.isEmpty()){
            for (Database.SaveResult sr : srList) {
                if (!sr.isSuccess()) {
                    for (Database.Error e  : sr.getErrors()) {	                    
                        failedData.add(new Core_Log_Entry__c(Core_Details__c = e.getMessage() , Core_Message__c = 'Error from  Core_CRM_Utility updating Competitor data', Core_Severity__c = 'Info', Core_Origin__c = 'Updating data error', Core_When__c = System.now()));
                    }
                }
            }
            
            if(!failedData.isEmpty()){
                return JSON.serialize(failedData); 
            }else{
                
                return 'Success' ;   
            }
            
        }
        return 'Info: Compaetitor Data already available';
        
    }
    
        @AuraEnabled(cacheable=true)
        public static Map<String, Object> getTagsWithCount(Integer limitSize, Integer offsetSize, String searchKey) {
            try {
                String filterSearchKey = '';
                String coreQuery = System.Label.CRM_getTagsDetailsQuery;
                String filterQuery = System.Label.CRM_showTagsFilter;
                String orderByQuery = System.Label.CRM_tagsOrderByQuery;
                String recordQuery='';
                String countQuery ='';
                
                String key = '%' + searchKey + '%';
                filterSearchKey = 'Name LIKE :key';
                
                String whereClause = '';
                if (String.isNotBlank(searchKey) || filterQuery.length() > 1) {
                    List<String> conditions = new List<String>();
                    if (String.isNotBlank(searchKey)) conditions.add(filterSearchKey);
                    if (filterQuery.length() > 1) conditions.add(filterQuery);
                    whereClause = ' WHERE ' + String.join(conditions, ' AND ');
                }
                
                recordQuery = coreQuery + whereClause + ' ' + orderByQuery;
                countQuery = 'SELECT COUNT() FROM UniTag__Tag__c' + whereClause;
                
                List<UniTag__Tag__c> tags = Database.query(recordQuery);
                Integer totalCount = Database.countQuery(countQuery);
                
                return new Map<String, Object>{
                    'tags' => tags,
                    'totalCount' => totalCount
                };
                
            } catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
            }
        }
    
    
    // Areefa: Bulkified method to check if Opportunities are low touch and if the current user has a specific custom permission
    /*public static Map<Id, Boolean> checkLowTouchOpptsWithPermission(List<Opportunity> oppties , String customPermissionAPIName) { //
Map<Id, Boolean> results = new Map<Id, Boolean>();
Id designRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Design Opportunity').getRecordTypeId();
Boolean hasCustomPermission = FeatureManagement.checkPermission(customPermissionAPIName);

for (Opportunity oppty : oppties) {
Boolean isLowTouch = oppty.Core_Opportunity_Coverage_Nm__c == 'Partner-Led Opportunity' &&
oppty.Core_Coverage_Type_Nm__c == 'Disti Design Registration Low' &&
oppty.RecordTypeId == designRecordTypeId;
// Combine the low touch check with the custom permission check
results.put(oppty.Id, isLowTouch && hasCustomPermission); // 
}

return results;
}*/
    
}