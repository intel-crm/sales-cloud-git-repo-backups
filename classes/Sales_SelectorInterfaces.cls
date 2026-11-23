/*********************************************************************************************************************
Interface Name    : Sales_SelectorInterfaces
Version           : 1.0
Created Date      : June 2021
Project           : SALES Project

Modification Log :
* Developer                 Date                    Description
* ----------------------------------------------------------------------------------------------------------------------------------------------------------------
* Shivam Vishwakarma        30.06.2021               Contains Interface Methods for different sObjects Selectors
*-----------------------------------------------------------------------------------------------------------------------------------------------------------------*/

public interface Sales_SelectorInterfaces extends fflib_ISObjectSelector{
    
    //OrderItem Selectors
    List<OrderItem> selectOPWithOrderId(Id orderId);
    List<OrderItem> selectOPWithRecordId(Id recordId);
    List<OrderItem> selectOPWithSpecificFields(List<String> fieldsAPIList);
    List<OrderItem> selectOPWithSpecificFieldsFromOrderIdSet(List<String> fieldsAPIList,Set<Id> orderIdSet);
    List<OrderItem> selectOPWithSpecificFieldsFromRecordIdSet(List<String> fieldsAPIList,Set<Id> recordIdSet);
    List<OrderItem> selectOPInSpecificIdFieldSetWithFieldsFilterPredicateAND(Map<String,String> fieldAPIWithFilterValueMap , String IdSetFieldAPIName ,Set<Id> IdSet);

}