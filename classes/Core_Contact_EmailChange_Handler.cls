/**************************************************************************************
Apex Class Name:  Core_Contact_EmailChange_Handler
Version     : 1.0 
Created Date: 05 Dec 2016
Description    : This class is called from the Core_Contact trigger.
Modification Log :
* Developer                 Date                    Description
* ----------------------------------------------------------------------------
* Popcornapps                5/28/2017             Bulkified email change code
* Popcornapps              6/05/2017               Fixed the bug -- Dataops not able to change email address in production if there is no entitlement associated with contact
* Team Draco                 22/12/2022            Added logic to stop call to AGS due to ERPM By-pass logic upon Email change
*************************************************************************************/
public without sharing class Core_Contact_EmailChange_Handler{
    private static final String UPDATE_REASON_EMAIL_CHANGE = 'Email Change';
    public static boolean initiatedAsEmailChange = false; //Team Draco Change [22/12/2022]
    
    /*This method is to update ContactEntittlement Status & send mail to owner of contact when contact email */
    public static void UpdateEntitlementStatus(Map<ID,Boolean> updatedContactEmail,Map<ID,Contact> oldContact){ 
        Set <ID> contactIds = updatedContactEmail.keySet();
        List<Core_Contact_Entitlement__c> ceList = new List<Core_Contact_Entitlement__c>();
        Map<Id,List<Core_Contact_Entitlement__c>> mapContactConEnt = new Map<Id,List<Core_Contact_Entitlement__c>>();
        List<Core_Contact_Entitlement__c> lstToUpdateConEnt = new List<Core_Contact_Entitlement__c>();
        List<Contact> lstConToUpdate = new List<Contact>();
        Map<Id,String> mapConIDTargetId =  new Map<Id,String>();
        EmailTemplate template = new EmailTemplate();
        Boolean blnProfileAccess = true;
        Map<Id,String> mapAllEntitlements = new Map<Id,String>();

        template=[select Id, Name, Subject, HtmlValue, Body from EmailTemplate where Name =:System.Label.core_Account_EmailTemplate];
        //AGS Integration Status update Based On profile
        Boolean blnRemoveAccess = false;
        Map <String, Core_Contact_Access_Profiles__c> mapContactAcessProfiles = Core_Contact_Access_Profiles__c.getAll();

        Profile userProfileName = [Select Name from Profile where Id = : UserInfo.getProfileId() limit 1];

        if(!mapContactAcessProfiles.isEmpty() && mapContactAcessProfiles.containsKey(userProfileName.Name)){
            blnProfileAccess = false;
        }  
        Map<Id,Contact> mapConIdConObj = new Map<Id,Contact>([select id, email, owner.email, Core_IPS_Intel_Support_Owner__r.email,Core_ERPM_Integration_Status__c, Core_AGS_Integration_Status__c, ownerid, Core_IPS_Intel_Support_Owner__c, account.ownerID, lastName from contact where Id IN :contactIds]);

        ceList=[select Id, Name,Core_Entitlement_Id__r.name,Core_Contact_Id__c,Core_Entitlement_Id__r.Core_Display_Name__c, Core_Entitlement_Id__r.Core_IsActive__c,Core_Selected__c,Core_Status__c from Core_Contact_Entitlement__c where Core_Contact_Id__c IN :contactIds AND Core_Entitlement_Id__r.Core_IsActive__c = true];

        for(Core_Contact_Entitlement__c conEntRef : ceList){
            if(mapContactConEnt.get(conEntRef.Core_Contact_Id__c)!=null){
                mapContactConEnt.get(conEntRef.Core_Contact_Id__c).add(conEntRef);
            }else{
                mapContactConEnt.put(conEntRef.Core_Contact_Id__c,new List<Core_Contact_Entitlement__c>{conEntRef});
            }
        }

        String excludedIds=System.Label.core_accountMailExcludedIds;
        Set<ID> excludedIdsSet=new set<ID>((List<ID>)(excludedIds.split(',')));
        for(Id conId : mapContactConEnt.keyset()){
            Boolean blnRemovedAccess = false;
            String AllEntitlementName='<table>';
            
            for(Core_Contact_Entitlement__c ceObject : mapContactConEnt.get(conId)){
                    if(updatedContactEmail.get(conId) && blnProfileAccess){
                        if(ceObject.Core_Selected__c){
                            ceObject.Core_Selected__c=false;    
                            ceObject.Core_Status__c = 'Pending';
                            ceObject.Core_Update_Reason__c = UPDATE_REASON_EMAIL_CHANGE;
                            ceObject.Core_Status_of_Assignment_Failure__c = 'Pending Removal';
                            blnRemovedAccess = true;
                            lstToUpdateConEnt.add(ceObject);
                        }
                    }
                
               String activecheck=(ceObject.Core_Selected__c)?' Active':' InActive';
               AllEntitlementName+='<tr><td> '+ceObject.Core_Entitlement_Id__r.Core_Display_Name__c+'</td><td> '+activecheck+'</td></tr>';
            }
            AllEntitlementName+='</table>';
            mapAllEntitlements.put(conId,AllEntitlementName);
            Contact con = new Contact();
            con.id=conId;
            //eRPM - trigger logic - atb
            //con.Core_ERPM_Integration_Status__c = 'Pending';
            
            // AGS Integration Status Updated when any entitlement removed.
            //if(blnRemovedAccess){
           //     con.Core_AGS_Integration_Status__c = 'Pending'; 
           // }
            lstConToUpdate.add(con);
            Contact c = mapConIdConObj.get(conId);
            String targetObjectID=(!excludedIdsSet.contains(c.ownerID))?c.ownerID:((c.Core_IPS_Intel_Support_Owner__c != null))?c.Core_IPS_Intel_Support_Owner__c:(!excludedIdsSet.contains(c.account.ownerID))?c.account.ownerID:null;
            // Update Id with 18digit ID type
            
            
            if(targetObjectID!=null){
                mapConIDTargetId.put(conId,targetObjectID);
            }
        }

        if(lstToUpdateConEnt.size()>0){
            initiatedAsEmailChange = true; //Team Draco Change [22/12/2022]
            update lstToUpdateConEnt;
        } 
        if(lstConToUpdate.size()>0){
            //update lstConToUpdate;
            //eRPM - trigger logic - atb
            Core_ERPM_Outbound_Integration.evaluateAndSetERPMOutboundIntegrationStatus(lstConToUpdate, null, true);
        }
       
        Set<String> stUsers = new Set<String>(mapConIDTargetId.values());
        List <String> sProfile = (Label.Core_Send_Mail_Profile_List).split(',');
        String  sQuery = 'Select id from user where id = : stUsers';
        if (Boolean.valueOf(Label.Core_Send_Mail_Profile_Based))
            sQuery = sQuery + ' and profileID IN (select id from profile where name IN : sProfile)';
        Map<Id,User> lstUser = new Map<Id,User>();
        for (User u: (Database.query(sQuery)))
        {
             lstUser.put(u.Id,u);
        }
        for(Contact newCons : mapConIdConObj.values()){
            if(lstUser.get(mapConIDTargetId.get(newCons.id))!=null){
                sendSingleMail(newCons,template,mapConIDTargetId.get(newCons.id),mapAllEntitlements.get(newCons.id),oldContact.get(newCons.id).Email);
              }
         }
       
    }   
   
/*This method is to send email to contact owner*/
    public static void sendSingleMail(Contact contactObj, EmailTemplate emailTemplateRec, String targetObjectID, String AllEntitlementName, String fromEmail){
        String subject = emailTemplateRec.Subject;
        subject = subject.replace('{!Contact.Email}', fromEmail);

        String htmlBody = emailTemplateRec.HtmlValue;
        htmlBody = htmlBody.replace('{!fromEmail}', fromEmail);
        htmlBody = htmlBody.replace('{!toEmail}', contactObj.email);
        htmlBody = htmlBody.replace('{!Contact.LastName}', contactObj.LastName);
        htmlBody = htmlBody.replace('{!myCustomString}', AllEntitlementName);

        String plainBody = emailTemplateRec.Body;
        plainBody = plainBody.replace('{!fromEmail}', fromEmail);
        plainBody = plainBody.replace('{!toEmail}', contactObj.email);
        plainBody = plainBody.replace('{!Contact.LastName}', contactObj.LastName);
        plainBody = plainBody.replace('{!myCustomString}', AllEntitlementName);

        //build the email message
        Messaging.Singleemailmessage email = new Messaging.Singleemailmessage();

       // email.setSenderDisplayName(targetObjectID);
        email.setTargetObjectId(targetObjectID);
        email.setSaveAsActivity(false);

        email.setSubject(subject);
        email.setHtmlBody(htmlBody);
        email.setPlainTextBody(plainBody);

        Messaging.sendEmail(new Messaging.SingleEmailmessage[] {email});
    }   
}