/***************************************************************************************************
    Class Name: Core_IPS_Case_Escalation
    Class Type: Controller 
    Version     : 1.0 
    Created Date: Nov-12-2015
    Function    : This class is used to escalate the Case to Org Admin.
    Input Parameters: NA
    Output Parameters: NA
    Description: This class is used to escalate the Case to Org Admin. 
    Used in     : Case Detail Page
    Modification Log :
                   
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Abhishek Arya            11/12/2015                 Created
    ****************************************************************************************************/
public with sharing class Core_IPS_Case_Escalation{
  private ApexPages.StandardController controller;    
  public Case csRecord{get;set;}
  //public Boolean showCustomMessage{get;set;}
  public Core_IPS_Case_Escalation(ApexPages.StandardController controller){
    this.controller = controller;
    String csId;
    csId = ApexPages.currentPage().getParameters().get('id');
    if(Case.SObjectType.getDescribe().isAccessible()){
        csRecord = [select Id, Status, Core_IPS_Case_Escalated_Date__c, RecordTypeId,OwnerId, Core_IPS_Supported_Product__r.Core_Product_Organization__c from Case where Id =:csId];
    }
  }
  
  /***************************************************************************************************
    Method Name:  changeOwner
    Method Type: Action Method 
    Version     : 1.0 
    Created Date: Nov-12-2015
    Function    : This method set the Owner Id to Org Admin.
    Input Parameters: None
    Output Parameters: None
    Description: This method is called when user clicks on Escalate button on Case Detail Page. 
    Used in     : Case Detail Page
    Modification Log :
                   
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Abhishek Arya       11/12/2015                 Created
    ****************************************************************************************************/
  public pagereference changeOwner(){
      User u = [select Id, username,userType,profile.name from User where Id = :UserInfo.getUserId()];
      List<Id> orgAdminList;
      List<Id> orgIdList;
       List<Core_IPS_Product_Organization_Admin__c> cpoAdminList = new List<Core_IPS_Product_Organization_Admin__c>();
      Boolean isProfileAllowed = false;
      //showCustomMessage = false;
      for(String profileName:System.Label.Core_IPS_Escalate_Profile_List.split(';')){
          if(profileName == u.profile.name){
              isProfileAllowed = true;
          }
      }
      if(isProfileAllowed == true && csRecord <> null && csRecord.Core_IPS_Case_Escalated_Date__c == null && csRecord.Status == 'New' && !(String.valueOf(csRecord.OwnerId).startsWith('005')) && (csRecord.RecordTypeId == Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('IPS Case Create').getRecordTypeId() || csRecord.RecordTypeId == Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('IPS No Assigned Contact Case').getRecordTypeId()) && csRecord.Core_IPS_Supported_Product__r <> null && csRecord.Core_IPS_Supported_Product__r.Core_Product_Organization__c <> null){
          orgAdminList = new List<Id>();
            if(Core_IPS_Product_Organization_Admin__c.SObjectType.getDescribe().isAccessible()){
                cpoAdminList = [select Core_Admin__c,Core_Primary_Admin__c,Core_Product_Organization__c from Core_IPS_Product_Organization_Admin__c where Core_Product_Organization__c =:csRecord.Core_IPS_Supported_Product__r.Core_Product_Organization__c];
            }
          Map<Boolean,Id> primaryAdminMap = new Map<Boolean,Id>();
          for(Core_IPS_Product_Organization_Admin__c cpoAdminObj : cpoAdminList){
              if(cpoAdminObj.Core_Admin__c == csRecord.OwnerId){
                  ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Already Escalated to Org Admin.'));
                  return null;
              }
              primaryAdminMap.put(cpoAdminObj.Core_Primary_Admin__c,cpoAdminObj.Core_Admin__c);
          }              
          if(primaryAdminMap <> null && primaryAdminMap.size() > 0 && primaryAdminMap.get(true) <> null){
              csRecord.OwnerId = primaryAdminMap.get(true);
              csRecord.Core_IPS_Case_Escalated_Date__c = System.now();
          }else if(primaryAdminMap <> null && primaryAdminMap.size() > 0 && primaryAdminMap.get(false) <> null){
              csRecord.OwnerId = primaryAdminMap.get(false);
              csRecord.Core_IPS_Case_Escalated_Date__c = System.now();
          }else{
              //showCustomMessage = true;
              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Escalate issue failure. No Support Org Admin is assigned to this Support Organization'));
              return null;
          }
          update csRecord;
      }else if(isProfileAllowed == true && String.valueOf(csRecord.OwnerId).startsWith('005')){
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Owner is already an Agent.'));
          return null;
      }else{
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'You are not authorized to escalate.'));
          return null;
      }
                  
       return new pageReference('/'+csRecord.id);
  }
  
  /***************************************************************************************************
    Method Name:  CancelAction
    Method Type: Action Method 
    Version     : 1.0 
    Created Date: 14 Nov 2015
    Function    : used to return to the case tab
    Input Parameters: None 
    Output Parameters: None
    Description:   used to return to the case tab
    Used in     : Case Escalate
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Abhishek Arya              Nov/12/2015              Created
    ****************************************************************************************************/     
    public PageReference CancelAction(){
       PageReference pg = new PageReference('/'+csRecord.id); 
       pg.setRedirect(true);
       return pg;
    }

}