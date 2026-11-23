/**
 * @description       : Making the class name with the object type and extends it with fflib_SObjectSelector
 * @author            : Rakshitha BR
 * @group             : Gravity
 * @last modified on  : 04-13-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class Pricing_Quote_Selector extends fflib_SObjectSelector {
	/**
     * Creates a new instance of the selector via the application class. This is here to allow unit tests to override
	 * and inject a mock instead of this class or to switch out this class for a new version.
     *
     */
    public static Pricing_Quote_Selector newInstance() {
        
        
        return (Pricing_Quote_Selector) Pricing_IQR_Application.selector.newInstance(SBQQ__Quote__c.SObjectType);
    }
    
    /**
    * @description getSObjectType to know the type of object
    * @author Rakshitha BR | 03-28-2022 
    * @return Schema.SObjectType 
    **/
    public Schema.SObjectType getSObjectType(){
        return SBQQ__Quote__c.sObjectType;
    }
    
    /**
    * @description getSObjectFieldList to get the list of feilds
    * @author Rakshitha BR | 03-28-2022 
    * @return List<Schema.SObjectField> 
    **/
    public List<Schema.SObjectField> getSObjectFieldList() {
        return null;
    }
    
    /**
    * @description Add the Method type and its parameter
    * @author Rakshitha BR | 03-28-2022 
    * @param quoteIds 
    * @return List<SBQQ__Quote__c> 
    **/
    public  List<SBQQ__Quote__c> selectByIds(Set<Id> quoteIds) {

        return [select id,SBQQ__Status__c,name,SBQQ__Ordered__c,core_cpq_end_customer_nm__c,SBQQ__Account__c,SBQQ__Account__r.Type, 
                SBQQ__StartDate__c, SBQQ__Account__r.Name, Pricing_Project_Name_Nm__c, Pricing_End_Customer_Country_Nm__c, 
                Pricing_Customer_Nm__c, Pricing_ShipmentEndDate_Dt__c, Pricing_Server_Deal_Type_Nm__c, SBQQ__SalesRep__c, 
                Pricing_Region_Nm__c,Pricing_Program_Type_Nm__c,CreatedbyId,SBQQ__PrimaryContact__c,OwnerId,Pricing_ShipmentStDate_Dt__c 
                from SBQQ__Quote__c where id in:quoteIds];
    }
    
    public  List<SBQQ__Quote__c> selectByQuoteLetter(Set<Id> quoteIds) {

        return [SELECT id FROM SBQQ__Quote__c WHERE Pricing_Auto_generate_Quote_Letter__c=TRUE AND Id IN :quoteIds];
    }
}