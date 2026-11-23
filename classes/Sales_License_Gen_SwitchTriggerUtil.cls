/***************************************************************************
Class Name    : Sales_License_Gen_SwitchTriggerUtil
Version       : 1.0
Created Date  : May 2021
Function      : Blocking to delete the license Switch which are associated to License group
Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Mohammad Dilshad           13-May-2021              Switch Trigger Handler Util
* *********************************************************************************************************************/
@isTest
public without sharing class Sales_License_Gen_SwitchTriggerUtil {
    /*public static Void blockLicenseSwitchDeletion(List<Sales_License_Generator_Switch__c> switchList){
        //list<Sales_License_Generator_Switch__c> relatedSwitchList = new list<Sales_License_Generator_Switch__c>();--Unused variable
        Map<Id,Sales_License_Generator_Switch__c> switchLicGeneratorMap = new Map<Id,Sales_License_Generator_Switch__c>();		
        if(switchList.size()>0){
            for(Sales_License_Generator_Switch__c salesLicenseSwitch :switchList){
                if(salesLicenseSwitch.Sales_License_Generator__c!=null){
                    switchLicGeneratorMap.put(salesLicenseSwitch.Id, salesLicenseSwitch);
                }
            } 
            for(Sales_License_Group_Switch_config__c switchConfig : [SELECT Id, Sales_License_Generator_Switch__c, Sales_License_Group__c 
                                                                     FROM Sales_License_Group_Switch_config__c WHERE Sales_License_Generator_Switch__c=:switchLicGeneratorMap.keySet() and Sales_License_Group__c!=null]){                                                                         
                (switchLicGeneratorMap.get(switchConfig.Sales_License_Generator_Switch__c)).addError('You cannot Delete this Switch as it is associated to License group');
            } 
        } 
    }*/
}