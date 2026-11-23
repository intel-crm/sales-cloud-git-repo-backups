/*********************************************************************************************************************
Class Name    : Sales_Selectors
Version       : 1.0
Created Date  : June 2021
Project       : SALES Project

Modification Log :
* Developer                 Date                    Description
* ----------------------------------------------------------------------------------------------------------------------------------------------------------------
* Shivam Vishwakarma        30.06.2021               Contains Selector Methods for different sObjects
*-----------------------------------------------------------------------------------------------------------------------------------------------------------------*/

public inherited sharing class Sales_Selectors extends fflib_SObjectSelector implements Sales_SelectorInterfaces{
    
    String allOrderItemFieldsQuery = 'SELECT Id, Product2Id, OrderId, PricebookEntryId, OriginalOrderItemId, AvailableQuantity, Quantity, UnitPrice, ListPrice, TotalPrice, ServiceDate, EndDate, Description, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, OrderItemNumber, Sales_License_Vendor_Txt__c, Sales_Contact__c, Sales_Available_for_TOE__c, Sales_SAP_LAC_Rule_Txt__c, Sales_RU_Guard_Id_Txt__c, Sales_New_RU_Guard_Id_Txt__c, Sales_Product_OPN__c, Sales_Net_Discount_Percent_Pct__c, Sales_Broken_Price_Amt__c, Sales_Order_Notes_Txt__c, Sales_First_Name_Txt__c, Sales_Last_Name_Txt__c, Core_PSG_Maint_Exp_Dt__c, Sales_Training_No_Txt__c, Sales_RU_Node_Id_Txt__c, Sales_Email_Address_Txt__c, Sales_Asset_Id_Txt__c, Sales_Customer_frght_collect_account__c, Sales_OPN__c, Sales_Parent_Order_Item_Id_Txt__c, UnitPriceForceOverride__c, Sales_Suggested_Resale_Price__c, Sales_QuoteId__c, Sales_Status__c, Sales_Due_Date_Dt__c, Product_Expiration_Duration__c, Sales_SAPLine_Nbr__c, Sales_Disti_cost__c, Sales_Cancelled_Quoteline_No__c, Sales_Column_resale_price__c, Sales_Maintenance_Expiration__c, Sales_IsRecalculated__c, Sales_Legacy_Order_Product_Id__c, SBQQ__Activated__c, SBQQ__Asset__c, SBQQ__BillingFrequency__c, SBQQ__BillingType__c, SBQQ__BlockPrice__c, SBQQ__BookingsIndicator__c, SBQQ__BundleRoot__c, SBQQ__ChargeType__c, SBQQ__ContractAction__c, SBQQ__Contract__c, SBQQ__Contracted__c, SBQQ__ContractingMethod__c, SBQQ__DefaultSubscriptionTerm__c, SBQQ__DimensionType__c, SBQQ__DiscountSchedule__c, SBQQ__OrderProductBookings__c, SBQQ__OrderedQuantity__c, SBQQ__PriceDimension__c, SBQQ__PriceSchedule__c, SBQQ__PricingMethod__c, SBQQ__ProductSubscriptionType__c, SBQQ__ProrateMultiplier__c, SBQQ__QuoteLine__c, SBQQ__QuotedListPrice__c, SBQQ__QuotedQuantity__c, SBQQ__RequiredBy__c, SBQQ__RevisedOrderProduct__c, SBQQ__SegmentIndex__c, SBQQ__SegmentKey__c, SBQQ__ShippingAccount__c, SBQQ__Status__c, SBQQ__SubscriptionPricing__c, SBQQ__SubscriptionTerm__c, SBQQ__SubscriptionType__c, SBQQ__Subscription__c, SBQQ__TaxAmount__c, SBQQ__TaxCode__c, SBQQ__TermDiscountSchedule__c, SBQQ__TerminatedDate__c, SBQQ__UnproratedNetPrice__c, SBQQ__UpgradedSubscription__c FROM OrderItem ';
    
    //Constructors
    public Sales_Selectors() {
        //This is calling the fflib_SObjectSelector classes constructor and setting 
        // @param includeFieldSetFields Set to true if the Selector queries are to include Fieldset fields as well 
        // @param enforceCRUD Enforce CRUD security
        // @param enforceFLS Enforce Field Level Security
        // @param sortSelectFields Set to false if selecting many columns to skip sorting select fields and improve performance
        super(false,true,true,false);
    }
    
    //Custom Exception class
    public class SalesSelectorsException extends Exception{}
    
    //Generic New Instance method
    public static Sales_SelectorInterfaces newInstance(){
        //Schema.SObjectType inputSObjectType = getSObjectType(sObjectAPIName);
        //if(inputSObjectType != null)
        return (Sales_SelectorInterfaces)Application.Selector.newInstance(OrderItem.SObjectType);
        /*else
		//throw an exception - Input sObject either doesn't exist or isn't defined in the getSObjectType() method present in this Selector Class.
		throw new SalesSelectorsException('Input sObject either does not exist or is not defined in the getSObjectType() method present in this Selector Class.');
		*/
    }
    
    //Method to return the SObjectType of the sobject whose name is passed as a param in the method.
    public static Schema.SObjectType getSObjectType(String sObjectAPIName) {
        Schema.SObjectType returnValue;
        switch on sObjectAPIName {
            when 'OrderItem' {
                returnValue = OrderItem.sObjectType;
            }
            when 'Order' {
                returnValue = Order.sObjectType;
            }
            when else {
                returnValue = null;
            }
        }
        return returnValue;
    }
    
    //Generates a Salesforce Id for the given SObjectType input
    public static Id generateSObjectId(Schema.SObjectType sobjectType){
        return fflib_IDGenerator.generate(sobjectType);
    }
    
    //Abstract Methods to be overridden
    public List<Schema.SObjectField> getSObjectFieldList() {
        return null;
    }
    
    public Schema.SObjectType getSObjectType() {
        return OrderItem.sObjectType;
    }     
    
    //OrderItem Selectors
    
    public List<OrderItem> selectOPWithOrderId(Id orderId){
        System.debug('Inside selectOPWithOrderId Selector -->');
        String finalQuery = allOrderItemFieldsQuery+'WHERE OrderId=\''+orderId+'\'';
        System.debug('Final Query --> '+finalQuery);
        return Database.query(finalQuery);
    }
    
    public List<OrderItem> selectOPWithRecordId(Id recordId){
        System.debug('Inside selectOPWithRecordId Selector -->');
        String finalQuery = allOrderItemFieldsQuery+'WHERE Id=\''+recordId+'\'';
        System.debug('Final Query --> '+finalQuery);
        return Database.query(finalQuery);
    }
    
    public List<OrderItem> selectOPWithSpecificFields(List<String> fieldsAPIList){
        System.debug('Inside selectOPWithSpecificFields Selector -->');
        String finalQuery;
        if(fieldsAPIList.contains('Id'))
            finalQuery = 'SELECT '+String.join(fieldsAPIList,',')+' FROM OrderItem';
        else
            finalQuery = 'SELECT Id,'+String.join(fieldsAPIList,',')+' FROM OrderItem';
        return Database.query(finalQuery);
    }
    
    public List<OrderItem> selectOPWithSpecificFieldsFromOrderIdSet(List<String> fieldsAPIList,Set<Id> orderIdSet){
        System.debug('Inside selectOPWithSpecificFieldsFromOrderIdSet Selector -->');
        String finalQuery;
        if(fieldsAPIList.contains('Id'))
            finalQuery = 'SELECT '+String.join(fieldsAPIList,',')+' FROM OrderItem WHERE OrderId IN :orderIdSet';
        else
            finalQuery = 'SELECT Id,'+String.join(fieldsAPIList,',')+' FROM OrderItem WHERE OrderId IN :orderIdSet';
        return Database.query(finalQuery);
    }
    
    public List<OrderItem> selectOPWithSpecificFieldsFromRecordIdSet(List<String> fieldsAPIList,Set<Id> recordIdSet){
        System.debug('Inside selectOPWithSpecificFieldsFromRecordIdSet Selector -->');
        String finalQuery;
        if(fieldsAPIList.contains('Id'))
            finalQuery = 'SELECT '+String.join(fieldsAPIList,',')+' FROM OrderItem WHERE Id IN :recordIdSet';
        else
            finalQuery = 'SELECT Id,'+String.join(fieldsAPIList,',')+' FROM OrderItem WHERE Id IN :recordIdSet';
        return Database.query(finalQuery);
    }    
    
    public List<OrderItem> selectOPInSpecificIdFieldSetWithFieldsFilterPredicateAND(Map<String,String> fieldAPIWithFilterValueMap , String IdSetFieldAPIName ,Set<Id> IdSet){
        System.debug('Inside selectOPWithSpecificFieldsFromRecordIdSet Selector -->');
        String finalQuery;
        //Framing the SELECT and FROM clauses
        if(fieldAPIWithFilterValueMap.keySet().contains('Id'))
            finalQuery = 'SELECT '+String.join(new List<String>(fieldAPIWithFilterValueMap.keySet()),',')+' FROM OrderItem ';
        else
            finalQuery = 'SELECT Id,'+String.join(new List<String>(fieldAPIWithFilterValueMap.keySet()),',')+' FROM OrderItem ';
        
        //Process Map to create the Where clause conditions
        List<String> whereClauseConditions = new List<String>();
        for(String fieldAPI: fieldAPIWithFilterValueMap.keySet()){
            whereClauseConditions.add( String.valueOf( fieldAPI+'='+fieldAPIWithFilterValueMap.get(fieldAPI) ) );
        }
        finalQuery += 'WHERE '+ String.join(whereClauseConditions,' AND ');
        
        if(IdSetFieldAPIName!=null && IdSetFieldAPIName!='' && IdSet!=null && IdSet.size()>0 ){
            finalQuery += ' AND '+ String.valueOf( IdSetFieldAPIName+' IN: IdSet' );
        }
        
        System.debug('Final Query --> '+finalQuery);
        return Database.query(finalQuery);
    }
    
}