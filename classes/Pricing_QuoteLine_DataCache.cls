/**
 * @description Lazy-loads a mapping from record Id to record & Stores the mapping in a static 
 *              variable so that it doesn't have to query every time.
 * @author      Rohit K
 * 
**/
public class Pricing_QuoteLine_DataCache {
    
    /***********************************************************************************************
    *
    * Private Variables
    *
    ***********************************************************************************************/

    private static Map<Id, SBQQ__QuoteLine__c> staticObjectMap;

    /***********************************************************************************************
    *
    * Public Methods
    *
    ***********************************************************************************************/

    /**
     *
     * 
     *  Lazy-loads a mapping from record Id to record
     *  Stores the mapping in a static variable so that it doesn't have to query every time.
     *
     */
    public static Map<Id, SBQQ__QuoteLine__c> getMap(Set<Id> recordIds) {


        Map<Id, SBQQ__QuoteLine__c> newObjectMap = new Map<Id, SBQQ__QuoteLine__c>();

        // Lazy-load records
        Map<Id, SBQQ__QuoteLine__c> objectMap = loadMap(recordIds);
 
        for (Id recordId : recordIds) {
            
            if(objectMap.containsKey(recordId)){ 
                newObjectMap.put(recordId, objectMap.get(recordId));
            }
        }

        return newObjectMap;
 
    }  

    /***********************************************************************************************
    *
    * Private Methods
    *
    ***********************************************************************************************/
  
    private static Map<Id, SBQQ__QuoteLine__c> loadMap(Set<Id> recordIds) {

        if (staticObjectMap == null) {
            staticObjectMap = new Map<Id, SBQQ__QuoteLine__c>();
        }

        if(recordIds==null || recordIds.isEmpty()){
            return staticObjectMap;
        }

        // Gather Ids we haven't loaded yet
        Set<Id> nonLoadedIds = new Set<Id>();

        for (Id recordId : recordIds) {

            if (!staticObjectMap.containsKey(recordId)) {
                nonLoadedIds.add(recordId);
            }

        }

        // If there are some non-loaded ids, load them
        if (!nonLoadedIds.isEmpty()) {

            staticObjectMap.putAll(
                [SELECT Id, Name, 
                Pricing_Status_Nm__c,Pricing_Integration_Status_Nm__c,Pricing_Deal_RFQ_Status_Nm__c,RecordTypeId,
                Pricing_Program_Type_Nm__c
                From SBQQ__QuoteLine__c
                WHERE   Id IN :nonLoadedIds]);
        }

        return staticObjectMap;
    }

}