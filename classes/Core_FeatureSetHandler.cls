/**************************************************************************************
Apex Class Name:  Core_FeatureSetHandler
Version     : 1.0 
Created Date: 16 OCT 2014
Function    : Utility methods to handle Feature Set functions
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Srikant Joshi             10/16/2014              Original Version
*************************************************************************************/
public without sharing class Core_FeatureSetHandler{
    
    // Boolean variable used to check if the Triggers RUNS only once
    private static boolean bRunOnceFeatureSetTrigger = true;
    
    /*
    * Method name  : featureSetBeforeHandler
    * Description  : Trigger to check if the Display order option is checked or unchecked for a particular feature type and provide the same value for the new sobject
    * Return Type  : VOID
    * Parameter    :  Trigger.New and Trigger.Old
    */
    public static void featureSetBeforeHandler(Map<Id,Core_Feature_Set__c> mapOldsObject,Map<Id,Core_Feature_Set__c> mapNewsObject){
       //Declare/Initialize the Variables
       List<Id> lstFHRecordId = new List<Id>{};
       
       //Set the List & Map to collect the Feature Set records
       List<Core_Feature_Set__c> lstCoreFeature = new List<Core_Feature_Set__c>{};
       Map<String,Core_Feature_Set__c> mapOpprRecordId = new Map<String,Core_Feature_Set__c>{};
       
       if(bRunOnceFeatureSetTrigger()){
           // iterate over the new set of records  
           for(Core_Feature_Set__c sobjCoreOppFeature : mapNewsObject.Values()){
               lstFHRecordId.add(sobjCoreOppFeature.Core_Feature_Header__c);
               //lstFRecordId.add(sobjCoreOppFeature.Core_Feature_Type__c);
               mapOpprRecordId.put(sobjCoreOppFeature.Core_Feature_Type__c+sobjCoreOppFeature.Core_Feature_Header__c,sobjCoreOppFeature);
               //mapOppRecordId.put(sobjCoreOppFeature.Core_Feature_Header__c+String.Valueof(sobjCoreOppFeature.Core_Display_Order__c),sobjCoreOppFeature); 
           }
           // iterate over the set of feature set records from the database
           for(Core_Feature_Set__c sobjCoreOppFeature : [select id,Core_Feature_Type__c,Core_Feature_Header__c,Core_Display_Order__c from Core_Feature_Set__c where Core_Feature_Header__c in :lstFHRecordId]){
               // If the map contains the same feature type and feature header 
               if(mapOpprRecordId.keyset().contains(sobjCoreOppFeature.Core_Feature_Type__c+sobjCoreOppFeature.Core_Feature_Header__c)){
                   sobjCoreOppFeature.Core_Display_Order__c = mapOpprRecordId.get(sobjCoreOppFeature.Core_Feature_Type__c+sobjCoreOppFeature.Core_Feature_Header__c).Core_Display_Order__c;
                   lstCoreFeature.add(sobjCoreOppFeature);     
               }    
           }
           // Update the list of updated Feature records
           Database.SaveResult[] srList = Database.update(lstCoreFeature, false);
           for (Database.SaveResult sr : srList) {
                if (!sr.isSuccess()) {
                    Core_Feature_Set__c sobjCoreOppFeature =  new Core_Feature_Set__c(Id = sr.getId());
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        sobjCoreOppFeature.addError(err.getMessage());   
                    }
                }
           }
       }
   }
   
   /*
    * Method name  : bRunOnceFeatureSetTrigger
    * Description  : Checks if the trigger RUNS only once in the trigger
    * Return Type  : Boolean
    * Parameter    : NONE
    */
    public static boolean bRunOnceFeatureSetTrigger(){
        //Check if the Boolean is True
        if(bRunOnceFeatureSetTrigger){
            bRunOnceFeatureSetTrigger=false;
            return true;
        }
        else{//Check if the Boolean is False
            return bRunOnceFeatureSetTrigger;
        }
    }
}