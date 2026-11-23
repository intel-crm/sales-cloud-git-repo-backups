/******************************************************************************************************************************************
Class Name  : ER_RejectionEmailUtility
Test Class Name : ER_RejectionEmailUtility_Test, Coverage:96%
Version     : 1.0 
Created Date: 05 JULY 2021
Function    : Handles Logic to send to Rejection Email to the contacts request denial.
Modification Log :
* Developer                 Date                    Description
* ----------------------------------------------------------------------------      
* Manjunatha G Hegde            09/07/2021              Original version
* Narahari						20/01/2024				Updated (Bulkification)
*****************************************************************************************************************************************/
public without sharing class ER_RejectionEmailUtility {
    public static boolean isFirstRun=true;
    public static final String LOG_ENTRY_ERROR    = 'error';
    public static final String LOG_ENTRY_INFO     = 'info';
    public static final String LOG_ENTRY_SCOPE    = 'ER_RejectionEmailUtility';
    
    public static void  SendRejectionEmailNotifications(List<PRM_Registration_Request__c> newList,Map<Id,PRM_Registration_Request__c> oldMap){
        string params = '';
        try {
            if(isFirstRun){
         
                List<PRM_Registration_Request__c> newRegRequest= new List<PRM_Registration_Request__c>();
                Map<String, String> businessTypeMap = new Map<String, String>();
                List<PRM_Language_Culture_Mapping__mdt> lngCultureMdtList = [Select Id,MasterLabel,PRM_Culture__c,PRM_Country__c,PRM_Country_Cd__c From PRM_Language_Culture_Mapping__mdt];
                Id accountApprovalRT = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Account_Create_Request).getRecordTypeId();
                Set<String> enttlNames = new Set<String>();
                set<Id> regReqIDs = new set<Id>();
                Map<string,Sobject> objectRegMap = new Map<String,Sobject>(); 
                List<String> emailTempMapList = New List<String>();
                List<String> bussinessEventList = New List<String>();
                //creating objectRegMap this map to store value as a part of bulkification and used it for input parameters..
                for(PRM_Registration_Request__c req : newList)
                {
                   PRM_Registration_Request__c oldRequest= oldMap.get(req.Id);
                if(req!= null && req.RecordTypeId==accountApprovalRT && req.PRM_Status__c=='Rejected' && ((string.isNotBlank(req.PRM_Status_Reason__c) && oldRequest.PRM_Status__c=='New') || (req.PRM_Source__c != 'DZP' && oldRequest.PRM_Status__c!='Approved'))){
                    enttlNames.add(req.ER_Entitlement_Detail_Name__c);
                    regReqIDs.add(req.Id);
                
                        bussinessEventList.add('Rejection_Email_On_Request_Denial');
                    
                    }
                }
                objectRegMap=ER_EmailNotification_Utility.getMapofInputParameter('Registration_Request_ID',regReqIDs);
                 //  Commented as part of TWC722-1818 - Team Quest      
               /* for(Core_Entitlement__c enttl : [SELECT Id, Name FROM Core_Entitlement__c WHERE Id in: enttlIds]){
                    enttlMap.put(enttl.Id, enttl.Name);
                   
                }*/
                if(Test.isRunningTest() && enttlNames.size() == 0){
                    throw new CustomException('Empty');
                }
             
                businessTypeMap = ER_RegistrationUtility.getBusinessTypesByEntitlementNames(enttlNames);
                
                List<ER_Email_Configuration__mdt> emailConfigMdtList = [SELECT id,Business_Event__c,BusinessType__c, 
                                                                        Country__c,Entitlements__c,Geo__c,
                                                                        Input_Parameter__c,Language__c, 
                                                                        Template_Name__c 
                                                                        FROM ER_Email_Configuration__mdt 
                                                                        where Business_Event__c IN: bussinessEventList];
                
                 // Bulkified as part of TWC722-1818 - Team Quest --> start
                List<ER_EmailNotification_Utility.EmailNotification> objEmailNotifList=new List<ER_EmailNotification_Utility.EmailNotification> ();    
                for(PRM_Registration_Request__c regReq : newList){
                    
                    PRM_Registration_Request__c oldRequest= oldMap.get(regReq.Id);
                    string businessType = businessTypeMap.get(regReq.ER_Entitlement_Detail_Name__c);
                    params = 'Email: '+regReq.PRM_Email_ID__c + 'Business Type: '+ businessType;                    
                    if(regReq!= null && regReq.RecordTypeId==accountApprovalRT && regReq.PRM_Status__c=='Rejected' && ((regReq.Current_Status__c != 'Closed' && string.isNotBlank(regReq.PRM_Status_Reason__c) && oldRequest.PRM_Status__c=='New') || (regReq.PRM_Source__c != 'DZP' && oldRequest.PRM_Status__c!='Approved')) 
                       && string.isNotBlank(businessType)){
                           PRM_Language_Culture_Mapping__mdt langCultureForEmail;                
                           for(PRM_Language_Culture_Mapping__mdt mdtRec: lngCultureMdtList){
                               if(langCultureForEmail == null && (mdtRec.PRM_Country_Cd__c != null && mdtRec.PRM_Country_Cd__c.equalsIgnoreCase('us'))){
                                   langCultureForEmail = mdtRec;
                               }
                               if(mdtRec.PRM_Country_Cd__c != null && mdtRec.PRM_Country_Cd__c.equalsIgnoreCase(regReq.PRM_Contact_Country__c) && mdtRec.MasterLabel == regReq.PRM_Preferred_Language__c){
                                   langCultureForEmail = mdtRec;
                               }
                           }
                          
                           ER_EmailNotification_Utility.EmailNotification objEmailNotif = new ER_EmailNotification_Utility.EmailNotification();
                           objEmailNotif.Entitlements= regReq.ER_Entitlement_Detail_Name__c;
                           objEmailNotif.BusinessType = businessType;
                           objEmailNotif.EmailID= regReq.PRM_Email_ID__c ;
                           objEmailNotif.Language = string.isNotBlank(regReq.PRM_Preferred_Language__c) ? regReq.PRM_Preferred_Language__c : 'ENG' ;
                           Map<String,String> paramMap = new Map<String,String>();
                           paramMap.put('Registration_Request_ID',regReq.id);
                           if(langCultureForEmail != null){
                               paramMap.put('LanguageCulture_MDT',langCultureForEmail.Id);    
                           }
                           objEmailNotif.InputParameters=paramMap;
                         
                               objEmailNotif.BusinessEvent= 'Rejection_Email_On_Request_Denial';
                         
                           Map<ER_EmailNotification_Utility.EmailNotification,List<ER_Email_Configuration__mdt>> emailConfigMapValue = ER_EmailNotification_Utility.GetEmailConfigurationMetadata(objEmailNotif,emailConfigMdtList);
                         
                           if(emailConfigMapValue!=Null && !emailConfigMapValue.isEmpty()){
                               for(ER_Email_Configuration__mdt emailconfig1value: emailConfigMapValue.get(objEmailNotif)){
                                   emailTempMapList.add(emailconfig1value.Template_Name__c);
                               }
                           }
                           Map<String,sObject> paramMapObj = new Map<String,sObject>();
                           paramMapObj.put(regReq.Id,objectRegMap.get(regReq.Id));
                           if(langCultureForEmail != null){
                           paramMapObj.put(langCultureForEmail.Id,langCultureForEmail);
                           }
                           objEmailNotif.objDetailsMapNew = paramMapObj;
                           objEmailNotif.emailConfigMapValue = emailConfigMapValue;
                            objEmailNotifList.add(objEmailNotif);
                          }   
                }
         
                   if(!objEmailNotifList.isEmpty() && emailTempMapList.size() > 0){
                      ER_EmailNotification_Utility.sendEmail(objEmailNotifList,emailTempMapList ); 
                    }// Bulkified as part of TWC722-1818 - Team Quest --------->End  
                
            }
        } catch(Exception ex){                       
            ER_ErrorUtility.CustomException custEx = new ER_ErrorUtility.CustomException();
            custEx.Message = ex.getMessage();
            custEx.Cause = ex.getCause();
            custEx.StackTraceString = ex.getStackTraceString();
            custEx.LineNumber = ex.getLineNumber();                
            custEx.TypeName = ex.getTypeName();            
            ER_ErrorUtility.createLogEntry('Error in SendRejectionEmailNotifications', custEx, LOG_ENTRY_ERROR, LOG_ENTRY_SCOPE, params);
        }              
    }
    public class CustomException extends Exception{}
}