/*********************************************************************************************************************
Trigger Name    : Sales_LicenseAdminDelegateTrigger
Version       : 1.0
Created Date  : May 2021
Function      :  

Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Shivam Vishwakarma        28-May-2021             Sales_LicenseAdminDelegate Trigger  
* *********************************************************************************************************************/
trigger Sales_LicenseAdminDelegateTrigger on Sales_License_Admin_Delegate__c (before insert, after insert, before update, after update, before delete, after delete) {
	//new Sales_LicenseAdminDelegateHandler().run();
}