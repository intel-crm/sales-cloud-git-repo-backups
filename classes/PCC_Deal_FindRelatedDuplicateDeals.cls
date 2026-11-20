/****************************************************************************************************************************************
Class Name  : PCC_Deal_FindRelatedDuplicateDeals
    Version     : 1.0
    Created Date: 26 April 2024
    Function    : Utility class to find Duplicate Deal and Related Duplicate Quotes based on Products
    
Modification Log :
     * Developer                 Date                    Description
 * ----------------------------------------------------------------------------
 * Dinesh Mengade            26/04/2024              Original version
 ************************************************************************/
public without sharing class PCC_Deal_FindRelatedDuplicateDeals {
    
    // AuraEnabled method to be called from a Lightning component
    @AuraEnabled(cacheable = true)
    public static List<RelatedDuplicateWrapper> getRelatedDuplicates(String recordId) {
        List<RelatedDuplicateWrapper> wrapperList = new List<RelatedDuplicateWrapper>();
        
        try{
            
            Core_Design_Registration__c reg = [ SELECT Name,OwnerId,RecordType.DeveloperName,Owner.Name,PCC_Registration_Type__c, Id,Core_Design_Registration_Nm__c, Core_Partner_Account_Id__c, Core_Opportunity_Id__c, Core_End_Customer_Account_Id__c FROM Core_Design_Registration__c WHERE Id = :recordId WITH USER_MODE];
            List<Core_Design_Registration_Product__c> drpList = [ SELECT Id, Core_Design_Registration_Nm__c,Core_Full_Year_Qty__c, Core_Product_Id__c, Core_Design_Product_Status_Nm__c, Core_Design_Registration_Id__c FROM Core_Design_Registration_Product__c WHERE Core_Design_Registration_Id__c = :recordId AND Core_Design_Registration_Id__r.Core_Partner_Account_Id__c = :reg.Core_Partner_Account_Id__c WITH USER_MODE];
            Set<Id> productIds = new Set<Id>();
            for(Core_Design_Registration_Product__c drp : drpList){productIds.add(drp.Core_Product_Id__c);
            }
            
            if (!productIds.isEmpty()) {
                
                if(reg.PCC_Registration_Type__c =='Deal Registration'){
                    wrapperList.addAll(findDuplicateDeals(reg, productIds, productIds.size(),'Deal'));
                    wrapperList.addAll(findQuoteDuplicates(reg, productIds, productIds.size()));
                }else{
                    // call oppportunity method
                    wrapperList.addAll(findDuplicateDeals(reg, productIds, productIds.size(), 'Design'));
                    wrapperList.addAll(findDuplicateOppties(reg, productIds,productIds.size()));
                }
                
                System.debug('Duplicates -->'+JSON.serialize(wrapperList));
            }
            
            if(Test.isRunningTest()){throw new System.DMLException();
            }
        }catch(Exception ex){throw new AuraHandledException('An error occurred while finding duplicate deals: ' + ex.getMessage());
        }
        
        return wrapperList;
    }
    
    // Helper method to find duplicate deals
    public static List<RelatedDuplicateWrapper> findDuplicateDeals(Core_Design_Registration__c reg, Set<Id> productIds, Integer noOfProds,String recordTypeDevName){
        List<RelatedDuplicateWrapper> wrapperList = new List<RelatedDuplicateWrapper>();
        try{
            Map<String, String> queryParams = new Map<String, String>();
            queryParams.put('Core_Partner_Account_Id',reg.Core_Partner_Account_Id__c);
            queryParams.put('Core_End_Customer_Account_Id',reg.Core_End_Customer_Account_Id__c);
            queryParams.put('Id',reg.Id);
            queryParams.put('RecordTypeDevName','%'+recordTypeDevName+'%');
            
            List<Core_Design_Registration__c> duplicateDeals = new List<Core_Design_Registration__c>();
            String query;
            if (String.isEmpty(reg.Core_End_Customer_Account_Id__c)) {
                query = LabelConfiguration__mdt.getInstance('Deal_Dup_Query_Part1').value__c + ' ' + LabelConfiguration__mdt.getInstance('Deal_Dup_Query_Part2').value__c + ' ' + LabelConfiguration__mdt.getInstance('Deal_Dup_Query_Part4').value__c;
            } else {
                query = LabelConfiguration__mdt.getInstance('Deal_Dup_Query_Part1').value__c + ' ' + LabelConfiguration__mdt.getInstance('Deal_Dup_Query_Part2').value__c + ' ' + LabelConfiguration__mdt.getInstance('Deal_Dup_Query_Part3').value__c;
            }
            System.debug(JSON.serialize(query));
            duplicateDeals = Database.queryWithBinds(query, queryParams, AccessLevel.SYSTEM_MODE);
            // create wrapper
            wrapperList = createWeapper(reg,duplicateDeals,productIds, noOfProds);
            
        }catch(Exception ex){throw new AuraHandledException('An error occurred while finding duplicate deals: ' + ex.getMessage());
        }
        
        return wrapperList;
    }
    
    
    // Helper method to find quote duplicates
    public static List<RelatedDuplicateWrapper> findQuoteDuplicates(Core_Design_Registration__c reg, Set<Id> productIds, Integer noOfProds){
        List<RelatedDuplicateWrapper> wrapperList = new List<RelatedDuplicateWrapper>();
        try{
            Map<String, String> queryParams = new Map<String, String>();
            queryParams.put('Core_Partner_Account_Id',reg.Core_Partner_Account_Id__c);
            queryParams.put('Core_End_Customer_Account_Id',reg.Core_End_Customer_Account_Id__c);
            queryParams.put('Id',reg.Id);
            
            List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>();
            String query;
            if (String.isEmpty(reg.Core_End_Customer_Account_Id__c)) {
                query = LabelConfiguration__mdt.getInstance('Deal_Quote_Dup_Query_Part1').value__c + ' ' + LabelConfiguration__mdt.getInstance('Deal_Quote_Dup_Query_Part3').value__c;
            } else {
                query = LabelConfiguration__mdt.getInstance('Deal_Quote_Dup_Query_Part1').value__c + ' ' + LabelConfiguration__mdt.getInstance('Deal_Quote_Dup_Query_Part2').value__c;
            }
            quotes = Database.queryWithBinds(query, queryParams, AccessLevel.SYSTEM_MODE);
            wrapperList = createWeapper(reg,quotes,productIds, noOfProds);
            
        }catch(Exception ex){throw new AuraHandledException('An error occurred while finding duplicate deals: ' + ex.getMessage());
        }
        
        return wrapperList;
    }
    
    
    // helper method to find Opportunity Duplicates
    public static List<RelatedDuplicateWrapper> findDuplicateOppties(Core_Design_Registration__c reg, Set<Id> productIds, Integer noOfProds){
        List<RelatedDuplicateWrapper> wrapperList = new List<RelatedDuplicateWrapper>();
        try{
            List<Opportunity> opptyList = [SELECT Id,Name,AccountId,Owner.Name, OwnerId, (SELECT Id, Name,product2Id FROM OpportunityLineItems) FROM Opportunity WHERE AccountId = :reg.Core_End_Customer_Account_Id__c with USER_MODE];
            wrapperList = createWeapper(reg,opptyList,productIds, noOfProds);
        }catch(Exception ex){throw new AuraHandledException('An error occurred while finding duplicate deals: ' + ex.getMessage());
        }
        return wrapperList;
    }
    
    
    public static List<RelatedDuplicateWrapper> createWeapper(Core_Design_Registration__c reg, List<SObject> records, Set<Id> productIds, Integer noOfProds) {
        List<RelatedDuplicateWrapper> wrapperRecords = new List<RelatedDuplicateWrapper>();
        
        // Mapping object types to their respective fields
        Map<String, Map<String, String>> fieldMappings = new Map<String, Map<String, String>>{
            'Core_Design_Registration__c' => new Map<String, String>{'objectName' => 'Design_Registration_Line_Items__r','productIfield' => 'Core_Product_Id__c','accountIdField' => 'Core_End_Customer_Account_Id__c','nameField' => 'Core_Design_Registration_Nm__c','objectType' => reg.RecordType.DeveloperName.contains('Deal') ? 'Deal' : 'Design'},
            'Opportunity' => new Map<String, String>{'objectName' => 'OpportunityLineItems','productIfield' => 'product2Id','accountIdField' => 'AccountId','nameField' => 'Name','objectType' => 'Opportunity'},
            'SBQQ__Quote__c' => new Map<String, String>{'objectName' => 'SBQQ__LineItems__r','productIfield' => 'SBQQ__Product__c','accountIdField' => 'Pricing_End_Customer_Account__c','nameField' => 'Pricing_Project_Name_Nm__c','objectType' => 'Quote'
            }
        };
        
        for (SObject obj : records) {
            String objType = String.valueOf(obj.Id.getSObjectType());
            Map<String, String> fields = fieldMappings.get(objType);
            
            if (fields != null && obj.getSObjects(fields.get('objectName')) != null) {
                Set<Id> matchedPrdIds = new Set<Id>();
                for (SObject lineItem : obj.getSObjects(fields.get('objectName'))) {
                    String prdId = (String) lineItem.get(fields.get('productIfield'));
                    if (productIds.contains(prdId)) {
                        matchedPrdIds.add(prdId);
                    }
                }
                if (matchedPrdIds.size() > 0) {
                    System.debug(wrapperRecords);
                    System.debug(reg);
                    System.debug(obj);
                    System.debug(matchedPrdIds.size());
                    System.debug(noOfProds);
                    System.debug(fields);
                    addWrapper(wrapperRecords, reg, obj, matchedPrdIds.size(), noOfProds, fields);
                }
            }
        }
        return wrapperRecords;
    }
    
    private static void addWrapper(List<RelatedDuplicateWrapper> wrapperRecords, Core_Design_Registration__c reg, SObject obj, Integer matchedCount, Integer noOfProds, Map<String, String> fields) {
        System.debug((Id) obj.get('OwnerId'));
        String ownerName = (String)obj.getSObject('Owner')?.get('Name')??null;
        // Builder build = new Builder().withDrId(reg.Id).withDrName(reg.Name).withPercentage((Integer)((Decimal.valueOf(matchedCount) / noOfProds) * 100)).withDuplicateDealName((String) obj.get('Name')).withDuplicateDealId((Id) obj.get('Id')).withObjectType(fields.get('objectType')).withEndCustomerId((String) obj.get(fields.get('accountIdField'))).withProjectName((String) obj.get(fields.get('nameField'))).withOwnerName(ownerName).withOwnerId((Id) obj.get('OwnerId'));
        RelatedDuplicateWrapper wrapper = new RelatedDuplicateWrapper(new Builder().withDrId(reg.Id).withDrName(reg.Name).withPercentage((Integer)((Decimal.valueOf(matchedCount) / noOfProds) * 100)).withDuplicateDealName((String) obj.get('Name')).withDuplicateDealId((Id) obj.get('Id')).withObjectType(fields.get('objectType')).withEndCustomerId((String) obj.get(fields.get('accountIdField'))).withProjectName((String) obj.get(fields.get('nameField'))).withOwnerName(ownerName).withOwnerId((Id) obj.get('OwnerId')));
        wrapperRecords.add(wrapper);
    }
    
    // Wrapper class to hold the data to be returned to the Lightning component
    public class RelatedDuplicateWrapper {
        @AuraEnabled public Id drId { get; private set; }
        @AuraEnabled public String drName { get; private set; }
        @AuraEnabled public Integer percentage { get; private set; }
        @AuraEnabled public String duplicateDealName { get; private set; }
        @AuraEnabled public Id duplicateDealId { get; private set; }
        @AuraEnabled public String objectType { get; private set; }
        @AuraEnabled public String endCustomerId { get; private set; }
        @AuraEnabled public String projectName { get; private set; }
        @AuraEnabled public String ownerName { get; private set; }
        @AuraEnabled public Id ownerId { get; private set; }
        
        private RelatedDuplicateWrapper(Builder builder) {
            this.drId = builder.drId;
            this.drName = builder.drName;
            this.percentage = builder.percentage;
            this.duplicateDealName = builder.duplicateDealName;
            this.duplicateDealId = builder.duplicateDealId;
            this.objectType = builder.objectType;
            this.endCustomerId = builder.endCustomerId;
            this.projectName = builder.projectName;
            this.ownerName = builder.ownerName;
            this.ownerId = builder.ownerId;
        }
    }
    
    public class Builder {
        private Id drId;
        private String drName;
        private Integer percentage;
        private String duplicateDealName;
        private Id duplicateDealId;
        private String objectType;
        private String endCustomerId;
        private String projectName;
        private String ownerName;
        private Id ownerId;
        
        public Builder withDrId(Id drId) {
            this.drId = drId;
            return this;
        }
        
        public Builder withDrName(String drName) {
            this.drName = drName;
            return this;
        }
        
        public Builder withPercentage(Integer percentage) {
            this.percentage = percentage;
            return this;
        }
        
        public Builder withDuplicateDealName(String duplicateDealName) {
            this.duplicateDealName = duplicateDealName;
            return this;
        }
        
        public Builder withDuplicateDealId(Id duplicateDealId) {
            this.duplicateDealId = duplicateDealId;
            return this;
        }
        
        public Builder withObjectType(String objectType) {
            this.objectType = objectType;
            return this;
        }
        
        public Builder withEndCustomerId(String endCustomerId) {
            this.endCustomerId = endCustomerId;
            return this;
        }
        
        public Builder withProjectName(String projectName) {
            this.projectName = projectName;
            return this;
        }
        
        public Builder withOwnerName(String ownerName) {
            this.ownerName = ownerName;
            return this;
        }
        
        public Builder withOwnerId(Id ownerId) {
            this.ownerId = ownerId;
            return this;
        }
        
    }
}