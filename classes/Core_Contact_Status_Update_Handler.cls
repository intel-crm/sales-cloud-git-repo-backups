/**************************************************************************************
Apex Class Name:  Core_Contact_Status_Update_Handler
Version     : 1.0 
Created Date: 05 Dec 2016
Description    : This class is called from the Core_Contact trigger.
Change History:
Pooja Khanna - 05/25/2017 -- commented the code as this class is not used anywhere.
This class is Code is moved to Core_Contact_EmailChange_Handler. and this class need to be deleted.
*************************************************************************************/
public class Core_Contact_Status_Update_Handler{

 public Core_Contact_Status_Update_Handler(){
    }
  /*  private static final String UPDATE_REASON_EMAIL_CHANGE = 'Email Change';
    
//This method is called when account is changed on the contact. This method retrives cases and accounts related to the contact and sending updateAssetsToCase method
    public static String updateAssets(List<Contact> lstNewContacts){
        system.debug('===updateAssets.lstNewContacts==>'+lstNewContacts);
        set<Id> stAccId = new set<Id>();
        Map<Id,Id> mapConId = new Map<Id,id>();
        String strReturnMsg;
        List<Case> lstCases = new List<Case>();
        
        Profile userProfileName = [Select Name from Profile where Id = : UserInfo.getProfileId() limit 1];
        
        for(Contact objConRef : lstNewContacts){
            staccId.add(objConRef.AccountId);
            mapConId.put(objConRef.id,objConRef.AccountId);
        }
        System.debug('===staccId==>'+staccId);
        Set<String> stGECStatus = new Set<String>{'On Hold - GEC Review in Progress','On Hold - Government Authorization Needed '};
        system.debug('==userProfileName.Name==>'+userProfileName.Name);
        
        //Check if logged in user profile is eligible to update closed case or not
        Boolean blnEligible = false;
        if(Label.Core_Closed_Case_Access_Profiles.contains(',')){
         List<String> lstProfiles = Label.Core_Closed_Case_Access_Profiles.split(',');
            system.debug(lstProfiles);
            for(String strProfile : lstProfiles){
                if(strProfile == userProfileName.Name){
                   blnEligible = true; 
                }
            }
        }else if(Label.Core_Closed_Case_Access_Profiles == userProfileName.Name){
            blnEligible = true; 
        }
        
        if(blnEligible){
          lstCases = [SELECT id,Productid,Product.name,Contactid,contact.Accountid,Core_IPS_Project_Case__c,AccountId,Core_IPS_Product_Org1__c,Core_IPS_Supported_Product__c,Core_IPS_GEC_Status__c,asset.status,Core_IPS_Supported_Product__r.Core_Supported_Product_Name__c,Core_IPS_Supported_Product__r.Core_Product__c,Core_IPS_Supported_Product__r.Core_Supported_Product_Alias__c FROM Case WHERE Contactid IN : mapConId.keyset() AND Core_IPS_GEC_Status__c NOT IN :stGECStatus];
        }else{
          lstCases = [SELECT id,Product.name,Contactid,contact.Accountid,Core_IPS_Project_Case__c,AccountId,Core_IPS_Product_Org1__c,Core_IPS_Supported_Product__c,Core_IPS_GEC_Status__c,asset.status,Core_IPS_Supported_Product__r.Core_Supported_Product_Name__c,Core_IPS_Supported_Product__r.Core_Product__c,Core_IPS_Supported_Product__r.Core_Supported_Product_Alias__c FROM Case WHERE Contactid IN : mapConId.keyset() AND Status != 'Closed' AND Core_IPS_GEC_Status__c NOT IN :stGECStatus];
        }
        
        System.debug('Core_Contact_Status_Update_Handler.updateAssets==lstCases==>'+lstCases);
        
        
       return strReturnMsg;
    }

 
    //This method is to update ContactEntittlement Status & send mail to owner of contact when contact email 
    public static void UpdateEntitlementStatus(Map<ID,Boolean> updatedContactEmail,Map<ID,Contact> oldContact){ 
        Set <ID> contactIds = new Set<ID>();
        contactIds = updatedContactEmail.keySet();
      
        for(Id contactId:contactIds){
            sendEntitlementList(contactId,updatedContactEmail.get(contactId),oldContact.get(contactId).email);
        }
    }   
    public static void sendEntitlementList(ID contactId,Boolean updateEntitlement, String fromEmail){
        EmailTemplate template=[select Id, Name, Subject, HtmlValue, Body from EmailTemplate where Name =:System.Label.core_Account_EmailTemplate];

        String templateId=template.id;
        Boolean blnRemovedAccess = false;
        Boolean blnProfileAccess = true;
        
            //AGS Integration Status update Based On profile
            Boolean blnRemoveAccess = false;
            Map <String, Core_Contact_Access_Profiles__c> mapContactAcessProfiles = Core_Contact_Access_Profiles__c.getAll();

            Profile userProfileName = [Select Name from Profile where Id = : UserInfo.getProfileId() limit 1];

            System.debug('==='+userProfileName.Name);
            System.debug('==='+mapContactAcessProfiles.keyset());

            if(!mapContactAcessProfiles.isEmpty() && mapContactAcessProfiles.containsKey(userProfileName.Name)){
                blnProfileAccess = false;
            }  

           

        Contact c=[select id, email, owner.email, Core_IPS_Intel_Support_Owner__r.email,Core_ERPM_Integration_Status__c, Core_AGS_Integration_Status__c, ownerid, Core_IPS_Intel_Support_Owner__c, account.ownerID, lastName from contact where Id=:contactId];

            String AllEntitlementName='<table>';

             List<Core_Contact_Entitlement__c> ceList=[select Id, Name,Core_Entitlement_Id__r.name,Core_Entitlement_Id__r.Core_Display_Name__c, Core_Entitlement_Id__r.Core_IsActive__c,Core_Status__c,Core_Selected__c from Core_Contact_Entitlement__c where Core_Contact_Id__c=:c.id];
            
            // Contact Entitlement List with active status and active entitlement
            List<Core_Contact_Entitlement__c> updatedceList=new List<Core_Contact_Entitlement__c>();
            //updating entitlement when email domain change
            if(updateEntitlement && blnProfileAccess){
                for(Core_Contact_Entitlement__c ceObject:ceList){
                   if(ceObject.Core_Entitlement_Id__r.Core_IsActive__c){
                        if(ceObject.Core_Selected__c){
                            ceObject.Core_Selected__c=false;
                            ceObject.Core_Status__c='Pending';
                            blnRemovedAccess = true;
                            ceObject.Core_Update_Reason__c = UPDATE_REASON_EMAIL_CHANGE;
                        }
                        updatedceList.add(ceObject);
                    }
                }
                update ceList;
            }else{
                for(Core_Contact_Entitlement__c ceObject:ceList){
                    if(ceObject.Core_Entitlement_Id__r.Core_IsActive__c){
                        updatedceList.add(ceObject);
                    }
                }
            }
            
            for(Core_Contact_Entitlement__c ceObject:updatedceList){
                String activecheck=(ceObject.Core_Selected__c)?' Active':' InActive';
               // String entitlementactivecheck=(ceObject.Core_Entitlement_Id__r.Core_IsActive__c)?' Active ':' InActive '; //<td> '+entitlementactivecheck+'</td>
                    AllEntitlementName+='<tr><td> '+ceObject.Core_Entitlement_Id__r.Core_Display_Name__c+'</td><td> '+activecheck+'</td></tr>';
            }
            AllEntitlementName+='</table>';
            Contact con=new Contact();
            con.id=c.id;
            con.Core_ERPM_Integration_Status__c = 'Pending';
         
            // AGS Integration Status Updated when any entitlement removed.
            if(blnRemovedAccess){
                con.Core_AGS_Integration_Status__c = 'Pending'; 
            }
            update con;
       
            system.debug('AllEntitlementName : '+AllEntitlementName);

            String excludedIds=System.Label.core_accountMailExcludedIds;
            Set<String> excludedIdsSet=new set<String>(excludedIds.split(','));
            system.debug('ISO '+c.Core_IPS_Intel_Support_Owner__c+':');

            String targetObjectID=(!excludedIdsSet.contains((c.ownerID+'').substring(0,15)))?c.ownerID:((c.Core_IPS_Intel_Support_Owner__c != null))?c.Core_IPS_Intel_Support_Owner__c:(!excludedIdsSet.contains((c.account.ownerID+'').substring(0,15)))?c.account.ownerID:null;
           
            system.debug('targetObjectID '+targetObjectID);
            
            system.debug('Email : : '+fromEmail+'::'+c.email);
                if(targetObjectID!=null){
                   List<User> user=[Select id from user where id=:targetObjectID and profileID IN (select id from profile where name IN:(Label.Core_Send_Mail_Profile_List).split(',')) ];
                    if(user.size()>0){
                        sendSingleMail(c,templateId,targetObjectID,AllEntitlementName,fromEmail);
                    }
                    system.debug('Success');
                }
     }
//This method is to send email to contact owner
    public static void sendSingleMail(Contact contactObj, Id templateId, String targetObjectID, String AllEntitlementName, String fromEmail){
     System.debug('==in sendSingleMail===');
    //Contact contactObj=c;
        EmailTemplate emailTemplate = [select Id, Subject, HtmlValue, Body from EmailTemplate where Id =: templateId];

        String subject = emailTemplate.Subject;
        subject = subject.replace('{!Contact.Email}', fromEmail);

        String htmlBody = emailTemplate.HtmlValue;
        htmlBody = htmlBody.replace('{!fromEmail}', fromEmail);
        htmlBody = htmlBody.replace('{!toEmail}', contactObj.email);
        htmlBody = htmlBody.replace('{!Contact.LastName}', contactObj.LastName);
        htmlBody = htmlBody.replace('{!myCustomString}', AllEntitlementName);

        String plainBody = emailTemplate.Body;
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
    }   */
}