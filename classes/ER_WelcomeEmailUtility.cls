/******************************************************************************************************************************************
Class Name  : ER_WelcomeEmailUtility
Test Class Name : ER_WelcomeEmailUtility_Test, Coverage:100%
Version     : 1.0 
Created Date: 05 JULY 2021
Function    : Handles Logic to send to Welcome Email to the contacts upon successful entitlement assignment.
Modification Log :
* Developer                 Date                    Description
* ----------------------------------------------------------------------------      
* Manjunatha G Hegde            05/07/2021              Original version
* Narahari						20/01/2024				Updated (Bulkification)
*	****************************************************************************************************************************************/

public with sharing class ER_WelcomeEmailUtility {
    
    public static final String LOG_ENTRY_ERROR    = 'error';
    public static final String LOG_ENTRY_INFO     = 'info';
    public static final String LOG_ENTRY_SCOPE    = 'ER_WelcomeEmailUtility';
    
    //Method to Send Email Notification upon entitlement completion.
    public static boolean  SendWelcomeEmailNotifications(List<Core_Contact_Entitlement__c> newList,Map<Id,Core_Contact_Entitlement__c> oldMap){
        
        string params = '';
        Boolean isFirstRun=true;
        try {         
            set<Id> cntIDs = new set<Id>();
            set<Id> accIDs = new set<Id>();
           List<Id> entIDs = new List<Id>();
            Map<Id, String> enttlNameMap = new Map<Id, String>();
            List<String> emailTempMapList = New List<String>();
            List<String> dataQueryList = new List<String>();
            Map<String,Sobject> objectRegMapCon = new Map<String,Sobject>(); 
            Map<String,Sobject> objectRegMapAcc = new Map<String,Sobject>();
            Map<Id,Map<string,Sobject>> objectReqMapofMap = New Map<Id,Map<string,Sobject>>();
            Map<String,PRM_Language_Culture_Mapping__mdt> lngCultureMdtMap= new Map<String,PRM_Language_Culture_Mapping__mdt>();
            for(PRM_Language_Culture_Mapping__mdt prmMdt:PRM_Language_Culture_Mapping__mdt.getAll().values()){
                lngCultureMdtMap.put(prmMdt.MasterLabel,prmMdt);
            }
            Map<String, String> businessTypeMap = new Map<String, String>();
            map<string,PRM_EmailInputParamClause__mdt> inputParamQueryMap = new map<string,PRM_EmailInputParamClause__mdt>();
            for (PRM_EmailInputParamClause__mdt param : PRM_EmailInputParamClause__mdt.getAll().values()){
                {inputParamQueryMap.put(param.Input_Parameter__c,param);}
            }
            for(Core_Contact_Entitlement__c ecContID : newList){
                Core_Contact_Entitlement__c oldEnttl= oldMap.get(ecContID.Id);
                if(oldEnttl!= null && oldEnttl.Core_Status__c=='Pending'
                   && ecContID.Core_Selected__c && ecContID.Core_Status__c=='Complete'){                           
                       cntIDs.add(ecContID.Core_Contact_Id__c ); 
                       accIDs.add(ecContID.ER_Account_Id__c);         
                       entIDs.add(ecContID.Core_Entitlement_Id__c);
                   }
                }
            objectRegMapCon = ER_EmailNotification_Utility.getMapofInputParameter('EV_Contact_ID',cntIDs);
            objectRegMapAcc = ER_EmailNotification_Utility.getMapofInputParameter('Account_ID',accIDs);
            
            for (Core_Entitlement__c ent : [SELECT Id, Name FROM Core_Entitlement__c WHERE Id in : entIDs ]) {
                enttlNameMap.put(ent.Id, ent.Name);
            }
           
            //Get business type based on entitlement names
            businessTypeMap = ER_RegistrationUtility.getBusinessTypesByEntitlementNames(new Set<String>(enttlNameMap.values()));
            List<ER_Email_Configuration__mdt> emailConfigMdtList = [SELECT id,Business_Event__c,BusinessType__c, 
                                                                    Country__c,Entitlements__c,Geo__c,
                                                                    Input_Parameter__c,Language__c, Template_Name__c 
                                                                    FROM ER_Email_Configuration__mdt 
                                                                    where Business_Event__c = 'Welcome_email_on_request_approval_New'];
          
            //Entitlement can't get FirstName last name and account 
            //Add foreach instead of if
            if(Schema.sObjectType.Contact.isAccessible()){
            Map<Id,Contact> contMap=new Map<Id,Contact>([SELECT id,FirstName,Email,Account.Name,AccountId,Core_Email_Verification_Token__c,Core_Preferred_Language__c,
                                                         Core_IPA_Email_Verification_Date__c,Core_Password_Token__c
                                                         FROM Contact WHERE id IN :cntIDs]);
               
            if(contMap!=null && contMap.size()>0){
               // Bulkified as part of TWC722-1818 - Team Quest --> start
                List<ER_EmailNotification_Utility.EmailNotification> objEmailNotifList=new List<ER_EmailNotification_Utility.EmailNotification> ();                  
                for(Core_Contact_Entitlement__c enttl : newList){
                    Core_Contact_Entitlement__c oldEnttl= oldMap.get(enttl.Id);
                    string businessType = businessTypeMap.get(enttlNameMap.get(enttl.Core_Entitlement_Id__c));
                    if(Test.isRunningTest() && enttlNameMap.get(enttl.Core_Entitlement_Id__c) == 'Resource & Design Center for Secure Content1'){
                        throw new CustomException('Empty');
                    }
                    params = 'Email: '+contMap.get(enttl.Core_Contact_Id__c).Email + ' Entitlement Name: ' + enttl.Core_Entitlement_Nm__c + ' Business Type: ' +businessType;                   
                    if(oldEnttl!= null && oldEnttl.Core_Status__c=='Pending'
                       && enttl.Core_Selected__c && enttl.Core_Status__c=='Complete' && string.isNotBlank(businessType)){                           
                           //Send Email Logic
                           ER_EmailNotification_Utility.EmailNotification objEmailNotif = new ER_EmailNotification_Utility.EmailNotification();  
                           objEmailNotif.Entitlements=enttl.Core_Entitlement_Nm__c;
                           objEmailNotif.BusinessType = businessType;
                           objEmailNotif.EmailID= contMap.get(enttl.Core_Contact_Id__c).Email ;
                           objEmailNotif.Language = string.isNotBlank(contMap.get(enttl.Core_Contact_Id__c).Core_Preferred_Language__c) ? contMap.get(enttl.Core_Contact_Id__c).Core_Preferred_Language__c : 'ENG';
                           Map<String,String> paramMap = new Map<String,String>();
                           Map<String,sObject> paramMapobj = new Map<String,sObject>();
                           paramMap.put('EV_Contact_ID',contMap.get(enttl.Core_Contact_Id__c).Id);
                           paramMap.put('Account_ID',contMap.get(enttl.Core_Contact_Id__c).AccountId);
                           paramMapobj.put(enttl.Core_Contact_Id__c,objectRegMapCon.get(enttl.Core_Contact_Id__c));
                           paramMapobj.put(enttl.ER_Account_Id__c,objectRegMapAcc.get(enttl.ER_Account_Id__c));
                           objEmailNotif.InputParameters=paramMap;
                           objEmailNotif.objDetailsMapNew=paramMapobj;
                           String culture = lngCultureMdtMap.get(contMap.get(enttl.Core_Contact_Id__c).Core_Preferred_Language__c) !=null ? lngCultureMdtMap.get(contMap.get(enttl.Core_Contact_Id__c).Core_Preferred_Language__c).PRM_Culture__c : 'en';
                           objEmailNotif.BusinessEvent= 'Welcome_email_on_request_approval_New'; 
                           ER_EmailNotification_Utility.customPlaceholdersMap = new Map<String,String>{'{{TOOLLINK}}' => Label.ER_GuestRedemptionLink};
                               
                           //has been removed as part of TWC722-672 : Team Quest - Harshitha
                           /*if(contMap.get(enttl.Core_Contact_Id__c).Core_IPA_Email_Verification_Date__c != null)
                           {
                              
                               objEmailNotif.BusinessEvent= 'Welcome_email_on_request_approval_New'; 
                               ER_EmailNotificationUtility.customPlaceholdersMap = new Map<String,String>{'{{ACCOUNTNAME}}' => contMap.get(enttl.Core_Contact_Id__c).Account.Name};
                                   }
                           else if(contMap.get(enttl.Core_Contact_Id__c).Core_Email_Verification_Token__c != null)
                           {
                               objEmailNotif.BusinessEvent= 'Welcome_email_on_request_approval_EV';
                               
                               ER_EmailNotificationUtility.customPlaceholdersMap = new Map<String,String>{'{{TOOLLINK}}' => String.format(Label.PRM_EVToken, new List<Object>{culture ,contMap.get(enttl.Core_Contact_Id__c).Core_Email_Verification_Token__c}), '{{ACCOUNTNAME}}' => contMap.get(enttl.Core_Contact_Id__c).Account.Name};                                                                                                                      
                                   }
                           else if(contMap.get(enttl.Core_Contact_Id__c).Core_Password_Token__c != null)
                           {
                               objEmailNotif.BusinessEvent= 'Welcome_email_on_request_approval_EV';
                              
                               ER_EmailNotificationUtility.customPlaceholdersMap = new Map<String,String>{'{{TOOLLINK}}' => String.format(Label.PRM_Pwd_Token, new List<Object>{culture, contMap.get(enttl.Core_Contact_Id__c).Core_Password_Token__c}),'{{ACCOUNTNAME}}' => contMap.get(enttl.Core_Contact_Id__c).Account.Name};                                                              
                                   }*/
                           //Moved logic to specific utility class to bulkify.
                           Map<ER_EmailNotification_Utility.EmailNotification,List<ER_Email_Configuration__mdt>> emailConfigMapValue = ER_EmailNotification_Utility.GetEmailConfigurationMetadata(objEmailNotif,emailConfigMdtList);
                           if(emailConfigMapValue!=Null && !emailConfigMapValue.isEmpty()){
                               for(ER_Email_Configuration__mdt emailconfig1value: emailConfigMapValue.get(objEmailNotif)){
                                   emailTempMapList.add(emailconfig1value.Template_Name__c);
                               }
                           }
                           objEmailNotif.emailConfigMapValue = emailConfigMapValue;
                           objEmailNotifList.add(objEmailNotif);
                           PRM_createAccountandRelatedRecords.linkEmailLogToContact(contMap.get(enttl.Core_Contact_Id__c).Email);
                           isFirstRun=false;                           
                       }   
                }
                if(!objEmailNotifList.isEmpty()){ 
                    // calling sendEmail method for more than one request..
                    ER_EmailNotification_Utility.sendEmail(objEmailNotifList,emailTempMapList);
                }     // Bulkified as part of TWC722-1818 - Team Quest --------->End             
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