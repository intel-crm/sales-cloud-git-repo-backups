/*************************************************************************************************************************************************************************
* Class Name  : PMP_UpdateAllCategoriesOnOfferings
* Version     : 1.0 
* Created Date: 09/01/2020 
* Modification Log :
*
* Developer         Modification Log                Date                               Description
* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Shahrukh         M-01    : Original version                       Batch class to update all the categories in one field on offering
**************************************************************************************************************************************************************************/
global class PMP_UpdateAllCategoriesOnOfferings implements Database.Batchable<sObject> {
    //Start - Method
    global Database.QueryLocator start(Database.BatchableContext bC) {
        
                
        // String query = PMP_Utility.queryAllFields('PMP_Partner_Offering__c',true);
        
        // //WHERE clause - which retrieves the offerings having status = Approved & Published offerings
        // query = query + ' where PMP_Partner_Offering_Lifecycle_Status_Nm__c=\'Approved\' OR PMP_Partner_Offering_Lifecycle_Status_Nm__c=\'Published\'';
            
        return Database.getQueryLocator('SELECT ID FROM USER LIMIT 1');
    }
    //Exceute - Method
    global void execute(Database.BatchableContext bC,List<PMP_Partner_Offering__c> offObjList) {
        
        //Initialise variables
        // List<PMP_Partner_Offering__c> updateOfferingList = new List<PMP_Partner_Offering__c>();
        // Set<Id> offIdsSet = new Set<Id>();
        // Map<String,String> offeringCategoryMap = new Map<String,String>();
        // //try - block
        // try{
        //     //Iterating on the list of offerings - which we got from the SOQL
        //     for(PMP_Partner_Offering__c offObj : offObjList){ 
        //         offIdsSet.add(offObj.Id);      
        //     }
            
        //     for(PMP_Partner_Offering_Category__c offCat: [select id,PMP_Category_Id__c,PMP_Ancestor_Category_Cd__c,PMP_Offering_Id__c,
        //                                                   PMP_Category_Id__r.PMP_Partner_Product_Category_Cd__c,PMP_Category_Id__r.Name 
        //                                                   from PMP_Partner_Offering_Category__c where PMP_Offering_Id__c IN:offIdsSet 
        //                                                   and PMP_Ancestor_Category_Cd__c Like '%NPP_01_TYPE%']){
        //         offeringCategoryMap.put(offCat.PMP_Offering_Id__c+'_'+string.valueOf(offCat.PMP_Ancestor_Category_Cd__c.countMatches('|')),offCat.PMP_Category_Id__r.Name+'|'+offCat.PMP_Category_Id__r.Id);    
        //     }
            
            
        //     for(PMP_Partner_Offering__c offObj : offObjList){
        //         string allCategories = '';
        //         for(Integer i = 0;i<5;i++){
        //             if(offeringCategoryMap.containsKey(offObj.Id+'_'+string.valueOf(i))){
        //                 allCategories = allCategories==''? offeringCategoryMap.get(offObj.Id+'_'+string.valueOf(i)) : allCategories+';'+offeringCategoryMap.get(offObj.Id+'_'+string.valueOf(i)); 
        //             }
        //         }
        //         offObj.PMP_All_Categories_Txt__c = allCategories;
        //         updateOfferingList.add(offObj);
        //     }

        //     if(!updateOfferingList.isEmpty()){
        //        update updateOfferingList;
        //     }
            
        // }
        // //Catch - block
        // catch(Exception e){
        //     System.debug('Error occured from batch class due to '+e.getMessage()+''+e.getlinenumber());
        //     //Throw exception if any
        //     throw e;
        // }
    }
    //Finish - Method
     global void finish(Database.BatchableContext bC) {   
            
    }    
}