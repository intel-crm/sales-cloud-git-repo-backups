public class Core_ProductAtRisk_Ctrl {
    
    public static Opportunity getOppRecord(String oppId){
        return [select Id, Core_At_Risk__c, Core_At_Risk_Created_Date__c, Core_Support_Requested__c from Opportunity where Id =: oppId];
    }

    public static List<Core_Product_Risk__c> getAllProductRisk(String oppId){
        return [select Id, Core_Opportunity_Product__c, Core_Opportunity_Product__r.Product2.Name, Core_Opportunity_Product__r.Core_BU_Short_Name__c, Core_At_Risk__c, Core_Risk_Reason__c, Core_Risk_Priority__c, Core_Risk_Status__c, Core_Created_Date__c, Core_End_Date__c, Core_Product_Risk_Owner__c from Core_Product_Risk__c where Core_Opportunity_Product__r.OpportunityId =: oppId order by Core_Opportunity_Product__r.Product2.Name asc];
    }
    
    @auraEnabled
    public static List<String> getPicklistValues(String objName, string fld) {
        List<String> allOpts = new List<String>();
        Schema.sObjectType objType = Schema.getGlobalDescribe().get(objName);
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
        list<Schema.PicklistEntry> values = fieldMap.get(fld).getDescribe().getPickListValues();
        for (Schema.PicklistEntry a : values){
            allOpts.add(a.getValue());
        }
        allOpts.sort();
        return allOpts;
    }
    
    @auraEnabled
    public static List<productRiskWrapper> initializeProductRisk(String oppId){
        List<Core_Product_Risk__c> prodRiskList = getAllProductRisk(oppId);
        if(!prodRiskList.isEmpty()){
            List<productRiskWrapper> productRiskWrapList = new List<productRiskWrapper>();
            Map<String, List<Core_Product_Risk__c>> productWiseRiskMap = new Map<String, List<Core_Product_Risk__c>>();
            List<Core_Product_Risk__c> tempList;
            for(Core_Product_Risk__c prodRisk : prodRiskList){
                if(productWiseRiskMap.containsKey(prodRisk.Core_Opportunity_Product__c)){
                    tempList = productWiseRiskMap.get(prodRisk.Core_Opportunity_Product__c);
                }else{
                    tempList = new List<Core_Product_Risk__c>();
                }
                tempList.add(prodRisk);
                productWiseRiskMap.put(prodRisk.Core_Opportunity_Product__c, tempList);
            }
            for(String prodId : productWiseRiskMap.keyset()){
                productRiskWrapper prodRiskWrap = new productRiskWrapper();
                List<Core_Product_Risk__c> riskList = productWiseRiskMap.get(prodId);
                prodRiskWrap.productName = riskList[0].Core_Opportunity_Product__r.Product2.Name;
                prodRiskWrap.productId = prodId;
                prodRiskWrap.buShortName = riskList[0].Core_Opportunity_Product__r.Core_BU_Short_Name__c;
                prodRiskWrap.productRiskList = riskList;
                prodRiskWrap.riskCount = riskList.size() + 1;
                productRiskWrapList.add(prodRiskWrap);
            }
            return productRiskWrapList;
        }else{
            return null;
        }
    }
    
    public class productRiskWrapper {
        @auraEnabled
        public String productName{get;set;}
        @auraEnabled
        public String productId{get;set;}
        @auraEnabled
        public String buShortName{get;set;}
        @auraEnabled
        public Boolean atRisk1{get;set;}
        @auraEnabled
        public String riskReason1{get;set;}
        @auraEnabled
        public String riskPriority1{get;set;}
        @auraEnabled
        public String riskStatus1{get;set;}
        @auraEnabled
        public Date createDate1{get;set;}
        @auraEnabled
        public Date endDate1{get;set;}
        @auraEnabled
        public String prodRiskOwner1{get;set;}
        @auraEnabled
        public List<Core_Product_Risk__c> productRiskList{get;set;}
        @auraEnabled
        public Integer riskCount{get;set;}
    }
}