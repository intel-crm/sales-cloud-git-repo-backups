/*********************************************************************************************************************
Class Name    : Sales_LicenseOrderProductTriggerHandler
Version       : 1.0
Created Date  : Apr 2021
Function      :  
Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Saba Husain          24-Apr-2021              
* *********************************************************************************************************************/
public class Sales_LicenseOrderProductTriggerHandler extends TriggerHandler {
    public override void beforeInsert() {
      	  Sales_LicenseOrderProductTriggerUtility.updateExpiryDate((List<Sales_License_Order_Product__c>)Trigger.new);
    }
}