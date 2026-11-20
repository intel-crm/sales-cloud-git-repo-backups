/******************************************************************************************************************************
Apex Class Name:  PRM_BenefitMatrix_Trigger
    Version     : 1.0
    Created Date: 15 FEB 2019
    Function    : Trigger for the object PRM_VXBnftMatrix__c
     *******************************************************************************************************************************/


trigger PRM_BenefitMatrix_Trigger on PRM_VXBnftMatrix__c (before insert,before update) {
    // bypass added by Dinesh as part of IPA2.0 Refresh change
    if(!FeatureManagement.checkPermission('PCC_Bypass_Automation')){
        new PRM_BenefitMatrix_Triggerhandler().run();
    }
    
}