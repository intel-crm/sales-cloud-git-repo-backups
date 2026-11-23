/**
 * @description Lazy-loads a mapping from record Id to record & Stores the mapping in a static 
 *              variable so that it doesn't have to query every time.
 * @author      Rohit K
 * 
**/
public class Pricing_Quote_DataCache {
    
    /***********************************************************************************************
    *
    * Private Variables
    *
    ***********************************************************************************************/

    private static Map<Id, SBQQ__Quote__c> staticObjectMap;

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
    public static Map<Id, SBQQ__Quote__c> getMap(Set<Id> recordIds) {


        Map<Id, SBQQ__Quote__c> newObjectMap = new Map<Id, SBQQ__Quote__c>();

        // Lazy-load records
        Map<Id, SBQQ__Quote__c> objectMap = loadMap(recordIds);
 
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
  
    private static Map<Id, SBQQ__Quote__c> loadMap(Set<Id> recordIds) {

        if (staticObjectMap == null) {
            staticObjectMap = new Map<Id, SBQQ__Quote__c>();
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
                Pricing_Account_Division_Nm__c,Pricing_Account_Executive_Nm__c,Pricing_Account_Name__c,Pricing_Additional_Components_Nm__c,Pricing_AdditionalRecipients__c,Pricing_Auto_generate_Quote_Letter__c,Pricing_Bid_Dt__c,Pricing_Created_Date__c,Pricing_Customer_Nm__c,Pricing_Customer_Reference_Id__c,Pricing_Deal_Type_Nm__c,Pricing_End_Customer__c,Pricing_End_Customer_Country_Nm__c,Pricing_End_Customer_Lookup__c,Pricing_End_Customer_Name__c,
                Pricing_End_Customer_Opportunity_Nm__c,Pricing_End_Customer_Opportunity_Txt__c,Pricing_Folio_ID_Nm__c,Pricing_Group_Nm__c,Pricing_Intel_Account_Exec_Email_Txt__c,Pricing_Intel_Response_Requested_By_Date__c,Pricing_Intel_Sales_Rep_Email_Txt__c,Pricing_Is_Sanctioned__c,Pricing_IsUnifiedCustomer__c,Pricing_My_Deals_Folio_Name_Nm__c,
                Pricing_Other_Component_Nm__c,Pricing_Overall_Quote_Quantity__c,Pricing_Program_Type_Nm__c,Pricing_Project_Name_Nm__c,Pricing_Quote_Program_Nm__c,Pricing_QuoteField__c,Pricing_Region_Nm__c,Pricing_SecondaryContact_Nm__c,Pricing_Server_Deal_Type_Nm__c,Pricing_ShipmentEndDate_Dt__c,Pricing_ShipmentStDate_Dt__c,Pricing_Status_Precedence_Number__c,Pricing_Unified_Global_End_Customer_Nm__c FROM    SBQQ__Quote__c
                WHERE   Id IN :nonLoadedIds]);
        }

        return staticObjectMap;
    }

}