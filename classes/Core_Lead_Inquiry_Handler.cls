/**************************************************************************************
Apex Class Name:  Core_Lead_Inquiry_Handler
Version     : 1.0 
Created Date: 21 May 2020
Function    : method to handle Lead Trigger functions
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Kavyashree H R            05/21/2020              Original Version
*************************************************************************************/

public without sharing class Core_Lead_Inquiry_Handler{
    //public static  boolean  sendEmailOnce=False;
    
    /*
    * Method name  : updateInquiryAccNameonLeadConversion
    * Description  : Method to update Account Name field of Inquiry records on lead conversion
    * Return Type  : void
    * Parameter    : Lead[]
    */
   /* public static void updateInquiryAccNameonLeadConversion(List<Lead> convLeads,Map<Id,Lead> oldMap)
    {       
        List<Id> convertedLeadIds = new List<Id>();
        map<Id, Lead> mapLeadAccountName = new map<Id, Lead>();
        List<Core_Inquiry__c> updatedInquiryAccountName = new List<Core_Inquiry__c>();
        
        //Add the converted lead to the list and map
        for(Lead leadRec: convLeads){
            if(leadRec.IsConverted && oldMap.get(leadRec.Id).IsConverted!=leadRec.IsConverted){
                convertedLeadIds.add(leadRec.Id);
                mapLeadAccountName.put(leadRec.Id, LeadRec);
            }
        }  
        //Populate the inquiry Account Name with converted lead's Account Name
        if(!convertedLeadIds.isEmpty()){              
            for(Core_Inquiry__c inquiryRec: [SELECT id,Core_AcccountName__c, Core_Lead_Inquiries__c FROM Core_Inquiry__c WHERE Core_Lead_Inquiries__c=: convertedLeadIds]){            
                if(mapLeadAccountName.containskey(inquiryRec.Core_Lead_Inquiries__c)){
                    inquiryRec.Core_AcccountName__c = mapLeadAccountName.get(inquiryRec.Core_Lead_Inquiries__c).ConvertedAccountId;
                    updatedInquiryAccountName.add(inquiryRec);
                }           
            } 
        }
        //Update the Inquiry list records with Account Name                               
        if(!updatedInquiryAccountName.isEmpty() && updatedInquiryAccountName.size()!=0){
            Database.update(updatedInquiryAccountName);        
        } 
    } */
    
    /*
    * Method name  : updateInquiryOwnerOnLeadOwnerUpdate
    * Description  : Method to update Owner field of Inquiry records on lead owner's update
    * Return Type  : void
    * Parameter    : List<Lead> newLeadList, Map<Id, Lead> oldMap
    */   
/*   public static void updateInquiryOwnerOnLeadOwnerUpdate(List<Lead> newLeadList, Map<Id, Lead> oldMap){
        List<Core_Inquiry__c> updatedInquiryOwner = new List<Core_Inquiry__c>();
        List<Core_Inquiry__c> updateInqOwnerList = new List<Core_Inquiry__c>();
        Set<Id> setLeadId = new Set<Id>();
        Set<Id> setRecTypId = new Set<Id>();
        Set<Id> inquiryIds = new Set<Id>();
        Id SalesLeadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Sales Lead').getRecordTypeId();
        Id LeadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Lead').getRecordTypeId();
    
        setRecTypId.add(SalesLeadRecordTypeId);
        setRecTypId.add(LeadRecordTypeId);
        
        for(Lead leadRec : newLeadList){
            if(leadRec.OwnerId != oldMap.get(leadRec.Id).OwnerId && setRecTypId.contains(leadRec.RecordTypeId)){            
                setLeadId.add(leadRec.Id);              
            }            
        }
        
        
        //Query all the inquiries for the owner updated lead
        if(!setLeadId.isEmpty() && setLeadId.size()!=0){
            updatedInquiryOwner = [SELECT id,Core_AcccountName__c, Core_Inquiry_Type_Pkt__c, Core_Lead_Inquiries__c, OwnerId, Core_Lead_Inquiries__r.OwnerId, Core_First_Name_Txt__c, Core_Last_Name_Txt__c, Core_Company_Txt__c, Core_Title_Txt__c, Core_Phone_Txt__c, Core_Email_Txt__c, Core_Lead_Source__c FROM Core_Inquiry__c WHERE Core_Lead_Inquiries__c=: setLeadId];
        }
        
        
        //Populate the Inquiry Owner with associated leads's owner
        for(Core_Inquiry__c inq : updatedInquiryOwner){
            if(inq.OwnerId == oldMap.get(inq.Core_Lead_Inquiries__c).OwnerId){
                inq.OwnerId = inq.Core_Lead_Inquiries__r.OwnerId ;
                updateInqOwnerList.add(inq);
            }
            inquiryIds.add(inq.id);
        }
        
        //Gireesh:US830838: The email for inquiry should only trigger when the lead owner changes from a queue to a user
        if(updatedInquiryOwner!=Null && !updatedInquiryOwner.isEmpty() && !sendEmailOnce){           
                sendEmailOnce=True;		            
                sendEmailNotifications(inquiryIds);
        }
        
        //Update the Inquiry list records with Lead's Owner   
        //Gireesh:Added null checks and removed size() methods                            
        if(updateInqOwnerList!=Null && !updateInqOwnerList.isEmpty()){
            Database.update(updateInqOwnerList);        
        }
    }*/
    
    
    /*
    * Method name  : sendEmailNotifications
    * Description  :Send Email for Inquiry on change of lead owner from queue to user aync
    * Return Type  : void
    * Parameter    : Set<ID> inquiryIds
    * User Story 	: Gireesh:US830838
    */ 
    /*@future
    public static void sendEmailNotifications(Set<ID> inquiryIds)
    {   
        List<Core_Inquiry__c> inquiryList = [SELECT id,Core_AcccountName__c, Core_Inquiry_Type_Pkt__c, Core_Lead_Inquiries__c, OwnerId, 
                                             Core_Lead_Inquiries__r.OwnerId, Core_First_Name_Txt__c, Core_Last_Name_Txt__c, Core_Company_Txt__c, 
                                             Core_Title_Txt__c, Core_Phone_Txt__c, Core_Email_Txt__c, Core_Lead_Source__c FROM
                                             Core_Inquiry__c WHERE ID IN:inquiryIds];
        Core_InquiryTrigger_Handler.SendInquiryEmailNotification(inquiryList);
    }*/
    
    
    /*
    * Method name  : updateCountryLabel
    * Description  : Method to update Country field based on CountryCode picklist field of Lead
    * Return Type  : void
    * Parameter    : List<Lead> leadIDs
    * User Story 	: US843354
    */  
    public static void updateCountryLabelOnLeadCountryChange(List<Lead> newLeadList){
        
        //Map to hold the Custom Setting Country Reference Value
        Map<String, Core_Country_Reference__c> countryRef = new Map<String, Core_Country_Reference__c>();
        List<Lead> leadtoBeUpdated = new List<Lead>();
        
        //put the country code values in a Map
        for(Core_Country_Reference__c countryRefRec : Core_Country_Reference__c.getall().values()){
            countryRef.put(countryRefRec.Core_ISO_Code__c,countryRefRec);
        }
        for(Lead leadRec : newLeadList){
            if(countryRef.containsKey(leadRec.CountryCode)){
                //Get the Label of the selected Country and assign to field
                leadRec.Core_CountryLabel__c = countryRef.get(leadRec.CountryCode).Name;
                
            }else{
                //Clearing the text field if Pickl;ist value is --None--
                leadRec.Core_CountryLabel__c='';
            }
        }   
    }
}