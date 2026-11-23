/*******************************************************************************************************************************************************************************************************
* Class Name  : PMP_SendEmailAlertsForExpiryOfferings
* Description : Stores the logic for sending the email for expiry offering email scenarios.
* Version     : 1.0 
* Created Date: 3-Feb-2021
* Modification Log :
* Created By  : Yashasvi Aggarwal
********************************************************************************************************************************************************************************************************/

public without sharing class PMP_SendEmailAlertsForExpiryOfferings {
     //wrapper which holds the offerings and template details
//      public class SendOfferingExipryEmailRequestWrapper {
//         @InvocableVariable(label='Offering Id' description='Offering Id Captured here' required=true)
//         public Id offeringId;
//         @InvocableVariable(label='Template Name' description='Template Name is Captured here' required=true)
//         Public String templateName;
//     }

// /*******************************************************************************************************************************************************************************************************
// * Method Name : sendOfferingExpiryEmailNotifications
// * Description : This method will send the email for expiry offering email scenarios and it is invoked by flow - PMP Offering Expiry Reminders
// * Params	  : 
// * Version     : 1.0 
// * Created Date: 3-Feb-2021
// * Modification Log :
// * Created By  : Yashasvi Aggarwal
// ********************************************************************************************************************************************************************************************************/
    
//     @InvocableMethod(label='Send Emails Reminders for Expiry Offerings' description='Sends the email to all PA and POE offering')
//     public static void sendOfferingExpiryEmailNotifications(List<SendOfferingExipryEmailRequestWrapper> offeringAndTemplateDetails) {

//         //map to store offering id with user ids
//         Map<String,Set<Id>> offeringUsersMap= new Map<String,Set<Id>>();

//         Map<Id,List<PMP_Company__c>> partnerIdAndPartnerMap= new Map<Id,List<PMP_Company__c>>();

//         Map<Id,Id> userPartnerMap = new Map<Id,Id>();

//         //get the Email-Template Name
//         String templateName=offeringAndTemplateDetails[0].templateName;
        
//         //All offering Ids recieved from flow
//         List<Id> offeringIds=new List<Id>();

//         List<Id> partnerIds=new List<Id>();

//         List<String> accountIds = new List<String>();
//         List<string> allowedPermissionSets = new List<string>();
//         allowedPermissionSets.add('PMP_External_Partner_Admin');
//         allowedPermissionSets.add('PMP_External_Offering_Editor');
//         //form  the userWhatId map (user, offeringId)
//         for(SendOfferingExipryEmailRequestWrapper req: offeringAndTemplateDetails){
//             offeringIds.add(req.offeringId);
//         }

//         List<PMP_Partner_Offering__c> offeringList= new List<PMP_Partner_Offering__c>();
//         if(PMP_Partner_Offering__c.SObjectType.getDescribe().isAccessible()){
//             offeringList=[SELECT Id, PMP_Offering_Submitter_UserId__c,PMP_Company_Id__c FROM PMP_Partner_Offering__c WHERE Id IN:offeringIds];
//         }
//         for(PMP_Partner_Offering__c offering: offeringList){
//             partnerIds.add(offering.PMP_Company_Id__r.Id);
//         }
//         List<PMP_Company__c> partnersList= new List<PMP_Company__c>();
//         if(PMP_Company__c.SObjectType.getDescribe().isAccessible()){
//              partnersList=[SELECT id,PMP_Partner_Submitter_UserId__c,PMP_Account_Id__c from PMP_Company__c  WHERE Id IN:partnerIds ];
//             }
//         for(PMP_Company__c partner:partnersList){
//                     List<PMP_Company__c> partnerList= new List<PMP_Company__c>();
//                     partnerList.add(partner);
//                     partnerIdAndPartnerMap.put(partner.Id, partnerList);
//                     partnerList = new List<PMP_Company__c>();
//             }
//         for(PMP_Partner_Offering__c offering: offeringList){
//             if(partnerIdAndPartnerMap.containsKey(offering.PMP_Company_Id__r.Id))
//             {
//                 userPartnerMap = PMP_Utility.fetchUsersMapFromPagMember(partnerIdAndPartnerMap.get(offering.PMP_Company_Id__r.Id),allowedPermissionSets);
//             }
//             offeringUsersMap.put(offering.id,userPartnerMap.keySet());        
//         }
       
//     }
}