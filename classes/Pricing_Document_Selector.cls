/**
 * @description       : Making the class name with the object type and extends it with fflib_SObjectSelector
 * @author            : Rakshitha BR
 * @group             : Gravity
 * @last modified on  : 03-28-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class Pricing_Document_Selector extends fflib_SObjectSelector
{
    public static Pricing_Document_Selector newInstance() {
        
        
        
        return (Pricing_Document_Selector) Pricing_IQR_Application.selector.newInstance(Pricing_Document__c.SObjectType);
    }
    
    /**
    * @description getSObjectType to know the type of object
    * @author Rakshitha BR | 03-18-2022 
    * @return Schema.SObjectType 
    **/
    public Schema.SObjectType getSObjectType(){
        return Pricing_Document__c.sObjectType;
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
    * @param quoteId 
    * @return List<Pricing_Document__c> 
    **/
    public List<Pricing_Document__c> selectByquoteId(Id quoteId){
        return [Select Id, Name, Pricing_Quote_Id__c from Pricing_Document__c where Pricing_Quote_Id__c=:quoteId];
    }
    
    public List<Document> selectByName(String name){
        return [SELECT Id, Name FROM Document where Name = : name LIMIT 1];
    }
}