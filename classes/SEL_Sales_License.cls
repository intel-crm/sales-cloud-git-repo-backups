public class SEL_Sales_License extends fflib_SObjectSelector {
	/**
     * Creates a new instance of the selector via the application class. This is here to allow unit tests to override
	 * and inject a mock instead of this class or to switch out this class for a new version.
     *
     */
    public static SEL_Sales_License newInstance() {
        return (SEL_Sales_License) Sales_Application.selector.newInstance(Sales_License__c.SObjectType);
    }
    
    public Schema.SObjectType getSObjectType(){
        return Sales_License__c.sObjectType;
    }
    
    public List<Schema.SObjectField> getSObjectFieldList() {
        return null;
    }
    
    public List<Sales_License__c> selectByIds(Set<Id> salesLicenceOrderIds) {
        return [Select Id,Sales_License_Activation_Code__c,Sales_License_Order__c,Sales_License_Quantity__c,Sales_License_Avbl_Qty_Nbr__c,Sales_License_Type__c,Sales_License_Status__c, Sales_License_Product__c,
                Sales_License_Avbl_Rehost_Nbr__c,Sales_License_Host_Node_Id__c from Sales_License__c where Sales_License_Order__c IN: salesLicenceOrderIds ];
    }
    
    public List<Sales_License__c> selectByRecordIdString(String recordId){
        return [Select Id,Sales_License_Lic_User_Contact_ID__c,Sales_Lic_User_Contact_Txt__c from Sales_License__c where Id=:recordId limit 1];
    }
    
    public List<Sales_License__c> selectByContractIds(Set<Id> contractIdsSet){
        return [Select Id,Sales_License_Type__c, Sales_License_Order__c, Sales_License_Status__c,Sales_License_Order_Product__c,Sales_License_Expiration_Date_Dt__c,Sales_License_Maintenance_Exp_Dt__c,Sales_License_Contract__c,
               Sales_License_Product__c,Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Type_Nm__c,Sales_License_Avbl_Qty_Nbr__c, Sales_License_Quantity__c 
               from Sales_License__c where Sales_License_Order_Product__r.SBQQ__Contract__c IN: contractIdsSet and Sales_License_Type__c = 'Original' and Sales_License_Status__c != 'Cancelled'];
    }
    
    public List<Sales_License__c> selectByContactIdForRenewal(Set<Id> contactId, Set<Id> prodId, List<Id> delMapValues){
        return [SELECT Id, Name, Sales_License_Account__c,Sales_License_Status__c, Sales_License_Expiration_Date_Dt__c,Sales_License_Maintenance_Exp_Dt__c,
                                    Sales_License_Primary_Admin_Contact__c,Sales_License_Type__c,Sales_License_Lic_User_Contact_ID__c, Sales_License_Avbl_Qty_Nbr__c,
                                    Sales_License_Product__c,Sales_License_Quantity__c,Sales_License_Order_Product__r.OrderItemNumber,Sales_License_Order_Product__c, Sales_Tool_License_Type__c,Sales_License_Product__r.Name  
                                    from Sales_License__c 
                                    where  Sales_License_Product__c IN:prodId  
                                    AND (Sales_License_Primary_Admin_Contact__c IN:contactId OR Sales_License_Lic_User_Contact_ID__c IN:contactId
                                         OR(Sales_License_Primary_Admin_Contact__c IN : delMapValues))
                                    AND(Sales_License_Type__c ='Renewal') AND (Sales_License_Status__c != 'Cancelled')
                                    AND Sales_License_Avbl_Qty_Nbr__c > 0 AND (Sales_License_Maintenance_Exp_Dt__c = null OR (Sales_License_Maintenance_Exp_Dt__c > :Date.Today()))];
    }
    
    public List<Sales_License__c> selectByContactIdForOriginalLicense(Set<Id> foundProdIdSet, Set<Id> contactId, List<Id> delMapValues, String LICENSE_TYPE_ORIGINAL){
        return [SELECT Id, Name, Sales_License_Account__c,Sales_License_Status__c, Sales_License_Expiration_Date_Dt__c,Sales_License_Maintenance_Exp_Dt__c,
                                         Sales_License_Primary_Admin_Contact__c,Sales_License_Type__c,Sales_License_Lic_User_Contact_ID__c,
                                         Sales_License_Product__c,Sales_License_Quantity__c,Sales_License_Order_Product__r.OrderItemNumber,Sales_License_Order_Product__c, Sales_Tool_License_Type__c 
                                         FROM Sales_License__c where
                                         Sales_License_Product__c IN:foundProdIdSet 
                                         AND (Sales_License_Primary_Admin_Contact__c IN:contactId OR Sales_License_Lic_User_Contact_ID__c IN:contactId
                                              OR(Sales_License_Primary_Admin_Contact__c IN : delMapValues))
                                         AND (Sales_License_Type__c =: LICENSE_TYPE_ORIGINAL) AND (Sales_License_Status__c != 'Cancelled')];
    }
    
    public List<Sales_License__c> selectByOrderItem (List<OrderItem> orderItmMapValues){
        return [Select id, Sales_License_Order_Product__c, Sales_License_Order__r.Status, Sales_License_Type__c, Sales_Distributed_Quantity__c from Sales_License__c where Sales_License_Order_Product__c IN: orderItmMapValues];
    }
    
    public List<Sales_License__c> selectByParentLicense(Set<Id> licId){
        return [Select Id,Sales_License_Maintenance_Exp_Dt__c, Sales_Parent_License__r.Sales_License_Maintenance_Exp_Dt__c, Sales_Parent_License__c,Sales_Parent_License__r.Sales_License_Status__c,Sales_Parent_License__r.Sales_License_Expiration_Date_Dt__c,Sales_Parent_License__r.Sales_License_Contract__c 
                from Sales_License__c where Sales_Parent_License__c IN: licId];
    }
    
    public List<Sales_License__c> selectByHostIds (Set<Id> hostIds){
        return [SELECT Id, Sales_License_Product__c, Sales_Tool_License_Type__c, Sales_License_Host_Node_Id__c,Sales_License_Avbl_Rehost_Nbr__c,Sales_License_Activation_Code__c,Sales_License_Status__c from Sales_License__c where Sales_License_Host_Node_Id__c IN : hostIds];
    }
    
    public List<Sales_License__c> selectByLicIdTypeAndStatus(List<Sales_License__c> baselicensesList){
        return [SELECT Id, Name, Sales_License_Account__c,Sales_License_Status__c, Sales_License_Expiration_Date_Dt__c,Sales_License_Maintenance_Exp_Dt__c,
               Sales_License_Primary_Admin_Contact__c,Sales_License_Type__c,Sales_License_Lic_User_Contact_ID__c,Sales_License_Avbl_Qty_Nbr__c,Sales_License_Product__c,Sales_License_Quantity__c,Sales_License_Order_Product__r.OrderItemNumber,Sales_License_Order_Product__c, Sales_Tool_License_Type__c,Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Prod_Max_Rehost_Cnt__c,Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Prod_Expiration_Duration_Nbr__c,
               Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Renewal_Period_Nbr__c,Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Prod_Temporary_Lic_Allowed_Ind__c,Sales_License_Product__r.SBQQ__SubscriptionTerm__c,Sales_License_Host_Node_Id__c 
               FROM Sales_License__c where Id IN : baselicensesList AND Sales_License_Type__c != 'Evaluation' AND Sales_License_Status__c ='Licensed' ];
    }
    
    public List<Sales_License__c> selectByPrimaryContactId(Id fromPrimayAdmin){
        return [SELECT Id,Name,Sales_License_Primary_Admin_Contact__c FROM Sales_License__c WHERE Sales_License_Primary_Admin_Contact__c=:fromPrimayAdmin];
    }
  
}