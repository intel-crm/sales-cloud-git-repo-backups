public class SEL_Sales_License_Admin_Delegate extends fflib_SObjectSelector {
	/**
     * Creates a new instance of the selector via the application class. This is here to allow unit tests to override
	 * and inject a mock instead of this class or to switch out this class for a new version.
     *
     */
    public static SEL_Sales_License_Admin_Delegate newInstance() {
        return (SEL_Sales_License_Admin_Delegate) Sales_Application.selector.newInstance(Sales_License_Admin_Delegate__c.SObjectType);
    }
    
    public Schema.SObjectType getSObjectType(){
        return Sales_License_Admin_Delegate__c.sObjectType;
    }
    
    public List<Schema.SObjectField> getSObjectFieldList() {
        return null;
    }
    
    public List<Sales_License_Admin_Delegate__c> selectByContactIdsAndIsActive(Set<Id> contactIds){
        return [SELECT Id,Name,Sales_License_DlgAdmin_Contact__c,Sales_License_DlgAdmin_Contact__r.Name,Sales_License_DlgAdmin_Email_Txt__c, Sales_License_PrimaryAdmin_Contact__c,Sales_License_isActive__c 
                from Sales_License_Admin_Delegate__c where Sales_License_DlgAdmin_Contact__c in :contactIds and Sales_License_isActive__c=true];
    }

    public List<Sales_License_Admin_Delegate__c> selectByPrimaryContactId(Id primaryContactId){
        return [SELECT Id,Name,Sales_License_DlgAdmin_Contact__r.Name,Sales_License_isActive__c,Sales_License_DlgAdmin_FirstName_Txt__c,Sales_License_DlgAdmin_LastName_Txt__c,Sales_License_DlgAdmin_Email_Txt__c, Sales_License_PrimaryAdmin_Contact__c, Sales_License_DlgAdmin_Contact__c FROM Sales_License_Admin_Delegate__c
               Where Sales_License_PrimaryAdmin_Contact__c =:primaryContactId] ;
    }
    
    public List<Sales_License_Admin_Delegate__c> selectByPrimaryAndDelContactIds(Id fromPrimayAdmin, Id toPrimaryAdmin ){
        return [SELECT Id,Sales_License_PrimaryAdmin_Contact__c,Sales_License_DlgAdmin_Contact__c,Sales_License_isActive__c FROM Sales_License_Admin_Delegate__c 
               WHERE Sales_License_PrimaryAdmin_Contact__c=:fromPrimayAdmin AND Sales_License_DlgAdmin_Contact__c=:toPrimaryAdmin AND Sales_License_isActive__c=true];
    }
    
    public List<Sales_License_Admin_Delegate__c> selectByPrimaryIdsAndIsActive(Id fromPrimayAdmin){
        return  [SELECT Id,Sales_License_PrimaryAdmin_Contact__c,Sales_License_isActive__c FROM Sales_License_Admin_Delegate__c WHERE Sales_License_PrimaryAdmin_Contact__c=:fromPrimayAdmin AND Sales_License_isActive__c=true];
    }
}