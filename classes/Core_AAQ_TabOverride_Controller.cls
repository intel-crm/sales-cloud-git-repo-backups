/****************************************************************************************************
Apex Class Name : Core_AAQ_TabOverride_Controller
Version         : 1.0 
Test Class      : 
Created Date    : 2017-01-20
Function        : This is controller class for Core_AAQ_TabOverride Visualforce Page/LWC
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Bishal Singh               2024-07-19                Modified
*****************************************************************************************************/
public with sharing class Core_AAQ_TabOverride_Controller{
    public List<Core_AAQ_Profile_Handler__c> categoryColumn{get;set;}
    public Core_AAQ_TabOverride_Controller(){}
   
    public void onLoadPage(){
        categoryColumn  = [Select Name, Core_Profile_Url__c,Core_Active__c, Core_Description__c,Core_Description2__c,Core_Profile_Image__c,Core_Order__c,Core_Run_As_Flow__c FROM Core_AAQ_Profile_Handler__c WHERE Core_Active__c=true ORDER BY Core_Order__c];
    }
    
    /************************************************************************************************************
    *Method Name : onLoadLWC
    *Created Date: 2024-07-19
    *Author      : Bishal Singh
    *Description : Method to get the values from Core_AAQ_Profile_Handler__c custom setting.
    ************************************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static List<Core_AAQ_Profile_Handler__c> onLoadLWC(){
        return ([SELECT Name, Core_Profile_Url__c,Core_Active__c, Core_Description__c,Core_Description2__c,Core_Profile_Image__c,Core_Order__c,Core_Run_As_Flow__c FROM Core_AAQ_Profile_Handler__c WHERE Core_Active__c=true WITH SECURITY_ENFORCED ORDER BY Core_Order__c]);
    }
}