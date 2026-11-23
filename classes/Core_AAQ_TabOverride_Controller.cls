/**************************************************************************************
Apex Class Name:  Core_AAQ_TabOverride_Controller
Version     : 1.0 
Created Date: 20 Jan 2017
Description    : This is controller class for Core_AAQ_TabOverride Visualforce Page
*************************************************************************************/

public with sharing class Core_AAQ_TabOverride_Controller{
    public List<Core_AAQ_Profile_Handler__c> categoryColumn{get;set;}
    public Core_AAQ_TabOverride_Controller(){}
    public void onLoadPage(){
         categoryColumn  = [Select Name, Core_Profile_Url__c,Core_Active__c, Core_Description__c,Core_Description2__c,Core_Profile_Image__c,Core_Order__c FROM Core_AAQ_Profile_Handler__c where Core_Active__c=true ORDER BY Core_Order__c ];
    }
}