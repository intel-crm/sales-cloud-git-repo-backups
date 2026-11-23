/**
* @description       : All domain classes should utilize inherited sharing so that the caller determines whether it //should operate in system context or not. The should
also extend the fflib_SObjectDomain class
* @author            : Rakshitha BR
* @group             : Gravity
* @last modified on  : 03-28-2022
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/

public inherited sharing class Pricing_Comments_Const extends fflib_SObjectDomain{
    
    public Pricing_Comments_Const(List<Pricing_Comments__c> sObjectList){
        super(sObjectList, Schema.Pricing_Comments__c.SObjectType);
    }
    
    public static Pricing_Comments_Const newInstance(List<Pricing_Comments__c> recordList){
        
        return (Pricing_Comments_Const) Pricing_IQR_Application.Domain.newInstance(recordList);
    }
    //The name of this inner class must always be Constructor to work appropriately. This acts 
    //as a way to use the concept of reflection when initializing
    //this class, despite the fact apex still does not support it.
    public class Constructor implements fflib_IDomainConstructor{
        public fflib_SObjects construct(List<Object> objectList){
            return new Pricing_Comments_Const((List<SObject>) objectList);
        }
    }
}