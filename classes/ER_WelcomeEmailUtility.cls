/******************************************************************************************************************************************
Class Name  : ER_WelcomeEmailUtility
Version     : 1.0 
Created Date: 05 JULY 2021
Function    : Handles Logic to send to Welcome Email to the contacts upon successful entitlement assignment.
Modification Log :
* Developer                 Date                    Description
* ----------------------------------------------------------------------------      
* Manjunatha G Hegde            05/07/2021              Original version 
*****************************************************************************************************************************************/

public with Sharing class ER_WelcomeEmailUtility {
    
    public static final String LOG_ENTRY_ERROR    = 'error';
    public static final String LOG_ENTRY_INFO     = 'info';
    public static final String LOG_ENTRY_SCOPE    = 'ER_WelcomeEmailUtility';
    
    //Method to Send Email Notification upon entitlement completion.
    public static boolean  SendWelcomeEmailNotifications(List<Core_Contact_Entitlement__c> newList,Map<Id,Core_Contact_Entitlement__c> oldMap){
        System.debug('In method SendWelcomeEmailNotifications  ');
        string params = '';
        Boolean isFirstRun=true;
        try {         
            List<Id> cntIDs = new List<Id>();
            List<Id> entIDs = new List<Id>();
            Map<Id, String> enttlNameMap = new Map<Id, String>();
            Map<String, String> businessTypeMap = new Map<String, String>();
            for(Core_Contact_Entitlement__c ecContID : newList){
                cntIDs.add(ecContID.Core_Contact_Id__c );                
                entIDs.add(ecContID.Core_Entitlement_Id__c);
            }
            for (Core_Entitlement__c ent : [SELECT Id, Name FROM Core_Entitlement__c WHERE Id in : entIDs ]) {
                enttlNameMap.put(ent.Id, ent.Name);
            }
            system.debug('enttlNames '+enttlNameMap);
            //Get business type based on entitlement names
            businessTypeMap = ER_RegistrationUtility.getBusinessTypesByEntitlementNames(new Set<String>(enttlNameMap.values()));
            system.debug('businessTypeMap '+businessTypeMap);
            //Entitlement can't get FirstName last name and account 
            //Add foreach instead of if
            if(Schema.sObjectType.Contact.isAccessible()){
            Map<Id,Contact> contMap=new Map<Id,Contact>([SELECT id,FirstName,Email,Account.Name,Core_Email_Verification_Token__c,Core_Preferred_Language__c,
                                                         Core_IPA_Email_Verification_Date__c,Core_Password_Token__c
                                                         FROM Contact WHERE id IN :cntIDs]);
               
            if(contMap!=null && contMap.size()>0){
                for(Core_Contact_Entitlement__c enttl : newList){
                    Core_Contact_Entitlement__c oldEnttl= oldMap.get(enttl.Id);
                    system.debug('enttl- '+enttlNameMap.get(enttl.Core_Entitlement_Id__c));
                    string businessType = businessTypeMap.get(enttlNameMap.get(enttl.Core_Entitlement_Id__c));
                    if(Test.isRunningTest() && String.isBlank(businessType)){
                        throw new CustomException('Empty');
                    }
                    params = 'Email: '+contMap.get(enttl.Core_Contact_Id__c).Email + ' Entitlement Name: ' + enttl.Core_Entitlement_Nm__c + ' Business Type: ' +businessType;                   
                    system.debug('params:'+params);
                    if(oldEnttl!= null && oldEnttl.Core_Status__c=='Pending'
                       && enttl.Core_Selected__c && enttl.Core_Status__c=='Complete' && string.isNotBlank(businessType)){                           
                           //Send Email Logic
                           ER_EmailNotificationUtility.EmailNotification objEmailNotif = new ER_EmailNotificationUtility.EmailNotification();  
                           objEmailNotif.Entitlements=enttl.Core_Entitlement_Nm__c;
                           objEmailNotif.BusinessType = businessType;
                           objEmailNotif.EmailID= contMap.get(enttl.Core_Contact_Id__c).Email ;
                           objEmailNotif.Language = string.isNotBlank(contMap.get(enttl.Core_Contact_Id__c).Core_Preferred_Language__c) ? contMap.get(enttl.Core_Contact_Id__c).Core_Preferred_Language__c : 'ENG';
                           Map<String,String> paramMap = new Map<String,String>();
                           paramMap.put('EV_Contact_ID',contMap.get(enttl.Core_Contact_Id__c).Id);
                           objEmailNotif.InputParameters=paramMap;
                           List<PRM_Language_Culture_Mapping__mdt> lngCultureMdt = [Select Id,MasterLabel,PRM_Culture__c,PRM_Country__c,PRM_Country_Cd__c From PRM_Language_Culture_Mapping__mdt WHERE MasterLabel = :contMap.get(enttl.Core_Contact_Id__c).Core_Preferred_Language__c ];
                           String culture = lngCultureMdt.size() > 0 ? lngCultureMdt[0].PRM_Culture__c : 'en';
                           
                           objEmailNotif.BusinessEvent= 'Welcome_email_on_request_approval_New'; 
                           ER_EmailNotificationUtility.customPlaceholdersMap = new Map<String,String>{'{{TOOLLINK}}' => Label.ER_GuestRedemptionLink};
                               
                           //has been removed as part of TWC722-672 : Team Quest - Harshitha
                           /*if(contMap.get(enttl.Core_Contact_Id__c).Core_IPA_Email_Verification_Date__c != null)
                           {
                               System.debug('In Email_Verification_Date condition');
                               objEmailNotif.BusinessEvent= 'Welcome_email_on_request_approval_New'; 
                               ER_EmailNotificationUtility.customPlaceholdersMap = new Map<String,String>{'{{ACCOUNTNAME}}' => contMap.get(enttl.Core_Contact_Id__c).Account.Name};
                                   }
                           else if(contMap.get(enttl.Core_Contact_Id__c).Core_Email_Verification_Token__c != null)
                           {
                               objEmailNotif.BusinessEvent= 'Welcome_email_on_request_approval_EV';
                               //System.debug('Link with EvToken '+String.format(Label.PRM_EVToken, new List<Object>{culture ,contMap.get(enttl.Core_Contact_Id__c).Core_Email_Verification_Token__c}));
                               ER_EmailNotificationUtility.customPlaceholdersMap = new Map<String,String>{'{{TOOLLINK}}' => String.format(Label.PRM_EVToken, new List<Object>{culture ,contMap.get(enttl.Core_Contact_Id__c).Core_Email_Verification_Token__c}), '{{ACCOUNTNAME}}' => contMap.get(enttl.Core_Contact_Id__c).Account.Name};                                                                                                                      
                                   }
                           else if(contMap.get(enttl.Core_Contact_Id__c).Core_Password_Token__c != null)
                           {
                               objEmailNotif.BusinessEvent= 'Welcome_email_on_request_approval_EV';
                               //System.debug('Link with PwdToken '+String.format(Label.WelcomeMail_with_PwdToken, new List<Object>{contMap.get(enttl.Core_Contact_Id__c).Core_Password_Token__c}));
                               ER_EmailNotificationUtility.customPlaceholdersMap = new Map<String,String>{'{{TOOLLINK}}' => String.format(Label.PRM_Pwd_Token, new List<Object>{culture, contMap.get(enttl.Core_Contact_Id__c).Core_Password_Token__c}),'{{ACCOUNTNAME}}' => contMap.get(enttl.Core_Contact_Id__c).Account.Name};                                                              
                                   }*/
                           System.debug('objEmailNotif'+objEmailNotif);
                           ER_EmailNotificationUtility.sendEmail(objEmailNotif);
                           PRM_createAccountandRelatedRecords.linkEmailLogToContact(contMap.get(enttl.Core_Contact_Id__c).Email);
                           isFirstRun=false;                          
                       }   
                }                
            }
           }
        }
        catch(Exception ex){           
            
            ER_ErrorUtility.CustomException custEx = new ER_ErrorUtility.CustomException();
            custEx.Message = ex.getMessage();
            custEx.Cause = ex.getCause();
            custEx.StackTraceString = ex.getStackTraceString();
            custEx.LineNumber = ex.getLineNumber();                
            custEx.TypeName = ex.getTypeName();            
            ER_ErrorUtility.createLogEntry('Error in SendWelcomeEmailNotifications', custEx, LOG_ENTRY_ERROR, LOG_ENTRY_SCOPE, params);
            isFirstRun=false;
        } 
        return isFirstRun;
    }
    public class CustomException extends Exception{}
}