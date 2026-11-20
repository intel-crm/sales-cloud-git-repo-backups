/***********************************************************************************************************************************************
Trigger Name:  PCC_DDRL5ProductMapping_Trigger
Created Date: 21 Aug 2023
Function    : Trigger for the PCC_DDR_L5_Product_Mapping__c Object

Modification Log :
* Developer                     Date                Description                                     TestClass
* -----------------------------------------------------------------------------------------------------------------------------------------------
* Shraddha More                 21/08/2023         Trigger for PCC_DDR_L5_Product_Mapping__c      PCC_DDRL5ProductMapping_TriggerHandler_Test
*************************************************************************************************************************************************/

trigger PCC_DDRL5ProductMapping_Trigger on PCC_DDR_L5_Product_Mapping__c (after insert) {
    if(LabelConfiguration__mdt.getInstance('BypassAutomationCP')==null || (LabelConfiguration__mdt.getInstance('BypassAutomationCP')!=null && (String)LabelConfiguration__mdt.getInstance('BypassAutomationCP').value__c !=null && !FeatureManagement.checkPermission((String)LabelConfiguration__mdt.getInstance('BypassAutomationCP').value__c))){
        new PCC_DDRL5ProductMapping_TriggerHandler().run();
    }
}