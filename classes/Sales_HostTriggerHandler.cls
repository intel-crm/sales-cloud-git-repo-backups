/*********************************************************************************************************************
Class Name    : Sales_HostTriggerHandler
Version       : 1.0
Created Date  : Apr 2021
Function      :  
Modification Log:
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Shivam Vishwakarma            21-Apr-2021             Host Information Handler  
* ********************************************************************************************************************/
@isTest
public without sharing class Sales_HostTriggerHandler extends TriggerHandler {
    /*public override void beforeInsert(){
        if(isActive('Sales_Host_Before_Trigger')){
            Sales_HostTriggerUtilityhostInfoCheck.hostinfoCheck(null,(List<Sales_Host__c>)Trigger.new,null);
        }
    }
    public override void beforeUpdate(){
        Map<Id, Sales_Host__c> oldHostMap = (Map<Id, Sales_Host__c>)Trigger.oldMap;
        List<Sales_Host__c> hostList=new List<Sales_Host__c>();
        Set<Id> hostSet=new Set<Id>();
        List<Sales_License__c> licenseList= new List<Sales_License__c>();
        if(isActive('Sales_Host_Before_Trigger') ){
            for(Sales_Host__c host: (List<Sales_Host__c>) Trigger.new){
                if((host.Name != null && !(oldHostMap.get(host.Id).Name.Equals(host.Name))) || (host.Sales_Computer_Name_Txt__c!=null && oldHostMap.get(host.Id).Sales_Computer_Name_Txt__c != host.Sales_Computer_Name_Txt__c)){
                    hostList.add(host);  
                }
                if(host.Sales_Contact__c!=oldHostMap.get(host.Id).Sales_Contact__c && host.Sales_Contact__c!=null){
                    hostSet.add(host.id);
                }
            }
            if(hostList!=null && !hostList.isempty())
            {
                Sales_HostTriggerUtilityhostInfoCheck.hostinfoCheck((Map<Id,Sales_Host__c>)Trigger.oldMap,hostList,null);}  
            if(Sales_HostTriggerUtilityhostInfoCheck.duplicateCheck==false && Sales_HostTriggerUtility.Check==false){
                Sales_HostTriggerUtility.validateUpdateOnHost((Map<Id, Sales_Host__c>)Trigger.newMap,(Map<Id,Sales_Host__c>)Trigger.oldMap);
            }
            Set<Id> finalhostSet=new Set<Id>();
            if(hostSet!=null && !hostSet.isempty()){
                licenseList= [select id,Sales_License_Host_Node_Id__c,Sales_License_Primary_Admin_Contact__c,Sales_License_Lic_User_Contact_ID__c,Sales_License_Host_Node_Id__r.Sales_Contact__c from Sales_License__c where Sales_License_Host_Node_Id__c in :hostSet];
                for(Sales_License__c licList:licenseList) {
                    finalhostSet.add(licList.Sales_License_Host_Node_Id__c);
                }
                if(licenseList!=null && !licenseList.isempty() && Sales_TransferPrimaryAdmin.ByPassingAddErrorOfHost==false){
                    Sales_HostTriggerUtility.validatePrimaryAdminContactOnHost(licenseList,finalhostSet,(Map<Id, Sales_Host__c>)Trigger.newMap);
                }
            }
        }
    }
    public override void afterInsert(){
        if(isActive('Sales_Host_After_Trigger')){
            Sales_HostTriggerUtility.shareHostRecordsWithDelegates((List<Sales_Host__c>)Trigger.new, null);
        }
    }
    public override void afterUpdate(){
        if(isActive('Sales_Host_After_Trigger')){
            Sales_HostTriggerUtility.shareHostRecordsWithDelegates((List<Sales_Host__c>)Trigger.new, (Map<Id,Sales_Host__c>)Trigger.oldMap);
        }
    }*/
}