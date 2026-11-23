/**
* @description       : Making the class name with the object type and extends it with fflib_SObjectSelector
* @author            : Rakshitha BR
* @group             : Gravity
* @last modified on  : 03-28-2022
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class Pricing_Comments_Selector extends fflib_SObjectSelector {
    public static Pricing_Comments_Selector newInstance() {
        return (Pricing_Comments_Selector) Pricing_IQR_Application.selector.newInstance(Pricing_Comments__c.SObjectType);
    }
    
    /**
* @description getSObjectType to know the type of object
* @author Rakshitha Br | 03-18-2022 
* @return Schema.SObjectType 
**/
    public Schema.SObjectType getSObjectType(){
        return Pricing_Comments__c.sObjectType;
    }
    
    /**
* @description getSObjectFieldList to get the list of feilds
* @author Rakshitha BR | 03-18-2022 
* @return List<Schema.SObjectField> 
**/
    public List<Schema.SObjectField> getSObjectFieldList() {
        return null;
    }
    
    /**
* @description Add the Method type and its parameter
* @author Rakshitha BR | 03-18-2022 
* @param recId 
* @param recordTypeId 
* @return List<Pricing_Comments__c> 
**/
    public List<Pricing_Comments__c> selectByIdandRecordType(Id recId,Id recordTypeId){
        return  [SELECT Id, Name, Pricing_Question__c,CreatedBy.Name, CreatedDate,Pricing_Quote__r.Pricing_Program_Type_Nm__c,Pricing_Answer__c, Pricing_Quote__c, Pricing_Required_Ind__c
                 FROM Pricing_Comments__c WHERE Pricing_Quote__c = :recId and recordtypeid =:recordTypeId];      
    }
    
    public List<Pricing_Comments__c> selectByQuoteId(Id recId){
        return  [SELECT id,Pricing_Quote__c FROM Pricing_Comments__c where Pricing_Quote__c =: recId];
    }
    
    public List<Pricing_Comments__c> selectByIdsAndReq(Set<Id> recId,Id recordTypeId){
        return  [SELECT Id,Pricing_Quote__c,Pricing_Answer__c FROM Pricing_Comments__c WHERE Pricing_Quote__c IN: recId and Pricing_Required_Ind__c = true and recordtypeid =: recordTypeId];
    }
}