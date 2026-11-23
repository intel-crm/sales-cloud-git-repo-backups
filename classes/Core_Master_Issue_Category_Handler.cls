public class Core_Master_Issue_Category_Handler{
    public static void updateCaseCategoriesStatus(map<ID, Core_IPS_Master_Issue_Category__c> trgOldMap, map<ID, Core_IPS_Master_Issue_Category__c> trgNewMap){
        List<Id> listOfCoreMasIssCatId = new List<Id> ();
        List<Id> listOfCoreMasIssSubCatId = new List<Id> ();
        List<Core_IPS_Product_Issue_Category__c> listOfCaseCategoryToUpdate = new List<Core_IPS_Product_Issue_Category__c>  ();
        for(Id CoreMasIssCatId : trgNewMap.keyset()){
            if(trgOldMap.get(CoreMasIssCatId).Core_Status__c != trgNewMap.get(CoreMasIssCatId).Core_Status__c){
                if(trgNewMap.get(CoreMasIssCatId).Core_Type__c == 'Case Category'){
                    listOfCoreMasIssCatId.add(CoreMasIssCatId);
                }
                else if(trgNewMap.get(CoreMasIssCatId).Core_Type__c == 'Case Subcategory'){
                    listOfCoreMasIssSubCatId.add(CoreMasIssCatId);
                }
            }
        }
        // Iterating and assigning Status value for the "Case Category" and its "Case SubCategory" records based on the "Master Case Category - (Case Category)"
        for(Core_IPS_Product_Issue_Category__c CaseCategory : [SELECT Id, Core_Issue_Category_Name__c, Core_Status__c, Core_Type__c, (SELECT Id, Core_Issue_Category_Name__c, Core_Status__c, Core_Type__c FROM Product_Issue_Sub_Categories__r WHERE Core_Type__c = 'Case Subcategory') FROM Core_IPS_Product_Issue_Category__c WHERE Core_Issue_Category_Name__c IN: listOfCoreMasIssCatId AND Core_Type__c = 'Case Category']){
            CaseCategory.Core_Status__c = trgNewMap.get(CaseCategory.Core_Issue_Category_Name__c).Core_Status__c;
            listOfCaseCategoryToUpdate.add(CaseCategory);
            for(Core_IPS_Product_Issue_Category__c CaseSubCategory : CaseCategory.Product_Issue_Sub_Categories__r){
                CaseSubCategory.Core_Status__c = CaseCategory.Core_Status__c;
                listOfCaseCategoryToUpdate.add(CaseSubCategory);
            }
        }
        // Iterating and assigning Status value for the "Case SubCategory" records based on the "Master Case Category - (Case SubCategory)" 
        for(Core_IPS_Product_Issue_Category__c CaseSubCategory : [SELECT Id, Core_Issue_Sub_Category_Name__c, Core_Status__c, Core_Type__c FROM Core_IPS_Product_Issue_Category__c WHERE Core_Issue_Sub_Category_Name__c IN: listOfCoreMasIssSubCatId AND Core_Type__c = 'Case Subcategory']){
            CaseSubCategory.Core_Status__c = trgNewMap.get(CaseSubCategory.Core_Issue_Sub_Category_Name__c).Core_Status__c;
            listOfCaseCategoryToUpdate.add(CaseSubCategory);
        }
        // Updating Core_IPS_Product_Issue_Category__c Records - "Case Category" and "Case SubCategory".
        if(!listOfCaseCategoryToUpdate.isEmpty()){
            update listOfCaseCategoryToUpdate;
        }
    }

}