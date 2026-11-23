/*********************************************************************************************************************
Class Name    : Sales_LicenseAdminDelegateHandler
Version       : 1.0
Created Date  : May 2021
Function      :  
Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Shivam Vishwakarma            28-May-2021         License Admin Delegate Handler  
* *********************************************************************************************************************/
public class Sales_LicenseAdminDelegateHandler extends TriggerHandler {
    public override void afterInsert(){    
        if(isActive('Sales_License_Adm_Dlg_After_Trigger' )){
            Sales_LicenseAdminDelegateUtility.shareRecordsWithDelegates((List<Sales_License_Admin_Delegate__c>)Trigger.new, null);
            if(isActive('Sales_Primary_DelegateNames')){
                Sales_Primary_DelegateNames_Utility.OnPrimaryAdmDlgAdmInsertUpdate((Map<Id,Sales_License_Admin_Delegate__c>) Trigger.newMap, null);
            }
        }
    }
    public override void afterUpdate(){
        if(isActive('Sales_License_Adm_Dlg_After_Trigger') && Sales_UpdateContactDetails.BypassTriggerForContactUpdate==false){
            Sales_LicenseAdminDelegateUtility.shareRecordsWithDelegates((List<Sales_License_Admin_Delegate__c>)Trigger.new, (Map<Id,Sales_License_Admin_Delegate__c>) Trigger.oldMap);  
           } 
            if(isActive('Sales_Primary_DelegateNames')){
                Sales_Primary_DelegateNames_Utility.OnPrimaryAdmDlgAdmInsertUpdate((Map<Id,Sales_License_Admin_Delegate__c>) Trigger.newMap, (Map<Id,Sales_License_Admin_Delegate__c>) Trigger.oldMap);
            }
    }
    public override void beforeDelete(){
        if(isActive('Sales_License_Adm_Dlg_Before_Trigger')){
            Sales_LicenseAdminDelegateUtility.revokeRecordsOnDlgAdminDelete((List<Sales_License_Admin_Delegate__c>) Trigger.old);            
        }
    }
    public override void afterDelete(){
        if(isActive('Sales_License_Adm_Dlg_After_Trigger')){
            Sales_Primary_DelegateNames_Utility.OnPrimaryAdmDlgAdmDelete((Map<Id,Sales_License_Admin_Delegate__c>) Trigger.oldMap);
        }
    }
}