/***************************************************************************************************************************************
Apex Class Name     : PRM_VXData_Report_Trigger 
Version             : 1.0
Created Date        : Sept 2020
Function            : PRM_VXData_Report_Trigger on PRM_Value_Exchange_Data__c.
Maximum Batch Size  : 
Modification Log    :
* Developer                         Date                           Description
* ------------------------------------------------------------------------------------------------------------------------------------
* Srishty                       15-Sept-2020                      US775505:Update Total Sales, Total Training.. Total Sales Units , reports with the partner role filter
**************************************************************************************************************************************/
trigger PRM_VXData_Report_Trigger on PRM_Value_Exchange_Data__c (before insert, before update,after update, after insert,after delete) {    
    // bypass added by Dinesh as part of IPA2.0 Refresh change
    if(!FeatureManagement.checkPermission('PCC_Bypass_Automation')){
        new PRM_VXData_Report_TriggerHandler().run();   
    }
    
}