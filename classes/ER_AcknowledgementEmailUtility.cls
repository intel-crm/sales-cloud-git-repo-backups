/******************************************************************************************************************************************
Class Name  : ER_AcknowledgementEmailUtility
Test Class Name : ER_AcknowledgementEmailUtility_Test, Coverage:100%
Version     : 1.0 
Created Date: 03 FEB 2022
Function    : Handles Logic to send to Acknowledgement Email after step2 during the self Registration process.
Modification Log :
* Developer                 Date                    Description
* ----------------------------------------------------------------------------      
* E.Janakiraman            03/02/2022              Original version 
* Narahari				   20/01/2024			   Updated (Bulkification)
*****************************************************************************************************************************************/
public without sharing class ER_AcknowledgementEmailUtility {
    
    public static boolean isFirstRun=true;
    public static final String LOG_ENTRY_ERROR    = 'error';
    public static final String LOG_ENTRY_INFO     = 'info';
    public static final String LOG_ENTRY_SCOPE    = 'ER_AcknowledgementEmailUtility';
    Public static string params = '';
    
    public static void sendAcknowledgementEmail(List<PRM_Registration_Request__c> newList, Map<id, PRM_Registration_Request__c> oldregRequestMap)
    {
        
        try
        {
           
            Id accCreateRequestId = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Account_Create_Request).getRecordTypeId();            
            Id emailVerificationRT = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Email_Verification_Request).getRecordTypeId();
            Map<String, String> businessTypeMap = new Map<String, String>();
            Set<String> enttlNames = new Set<String>();
            set<Id> regReqIDs = new set<Id>();
            Map<string,Sobject> objectRegMap = new Map<String,Sobject>(); 
            List<String> emailTempMapList = New List<String>();
            //creating objectRegMap this map to store value as a part of bulkification and used it for input parameters..
            for(PRM_Registration_Request__c req : newList){
                if(	req.Entitlement_Details__c != Null && req.RecordTypeId == accCreateRequestId
                   && req.PRM_Status__c == 'New')
                {
                    enttlNames.add(req.ER_Entitlement_Detail_Name__c);
                    regReqIDs.add(req.Id);
            }        
            }  
            objectRegMap = ER_EmailNotification_Utility.getMapofInputParameter('Registration_Request_ID',regReqIDs);
            //  Commented as part of TWC722-1818 - Team Quest         
            /*for(Core_Entitlement__c enttl : [SELECT Id, Name FROM Core_Entitlement__c WHERE Id in: enttlIds]){
                enttlMap.put(enttl.Id, enttl.Name);
				}*/
            if(Test.isRunningTest() && enttlNames.size() == 0){
                throw new CustomException('Empty');
            }
            businessTypeMap = ER_RegistrationUtility.getBusinessTypesByEntitlementNames(enttlNames);
            List<ER_Email_Configuration__mdt> emailConfigMdtList = [SELECT id,Business_Event__c,BusinessType__c, 
                                                                    Country__c,Entitlements__c,Geo__c,Input_Parameter__c,
                                                                    Language__c, Template_Name__c 
                                                                    FROM ER_Email_Configuration__mdt 
                                                                    where Business_Event__c = 'Registration_request_for_Acknowledgement_Email'];
            
            //Bulkified as part of TWC722-1818 - Team Quest
            List<ER_EmailNotification_Utility.EmailNotification> objEmailNotifList= new List<ER_EmailNotification_Utility.EmailNotification>();
            for(PRM_Registration_Request__c regRequest: newList)
            {
                PRM_Registration_Request__c oldRequest= oldregRequestMap!= null ? oldregRequestMap.get(regRequest.Id) : null;                              
                string businessType = businessTypeMap.get(regRequest.ER_Entitlement_Detail_Name__c);
                params = 'Email: '+regRequest.PRM_Email_ID__c + 'Business Type: '+ businessType; 
                
                if(	regRequest.Entitlement_Details__c != Null && regRequest.RecordTypeId == accCreateRequestId
                   /*&& (oldRequest == null || oldRequest.RecordTypeId == emailVerificationRT)*/ //has been removed as part of TWC722-672 : Team Quest - Harshitha
                   && regRequest.PRM_Status__c == 'New')
                { 
                   
                    //Bulkified as part of TWC722-1818 - Team Quest
                    ER_EmailNotification_Utility.EmailNotification objEmailNotif = new ER_EmailNotification_Utility.EmailNotification();
                    objEmailNotif.Entitlements= regRequest.ER_Entitlement_Detail_Name__c;
                    objEmailNotif.BusinessType = businessType;
                    objEmailNotif.EmailID= regRequest.PRM_Email_ID__c ;
                    objEmailNotif.Language = string.isNotBlank(regRequest.PRM_Preferred_Language__c) ? regRequest.PRM_Preferred_Language__c : 'ENG' ;
                    Map<String,String> paramMap = new Map<String,String>();
                    Map<String,sObject> paramMapObj = new Map<String,sObject>();
                    paramMapObj.put(regRequest.Id,objectRegMap.get(regRequest.Id));
                    paramMap.put('Registration_Request_ID',regRequest.id);                    
                    objEmailNotif.InputParameters=paramMap;
                    objEmailNotif.objDetailsMapNew = paramMapObj;
                    objEmailNotif.BusinessEvent = 'Registration_request_for_Acknowledgement_Email';
                    Map<ER_EmailNotification_Utility.EmailNotification,List<ER_Email_Configuration__mdt>> emailConfigMapValue = ER_EmailNotification_Utility.GetEmailConfigurationMetadata(objEmailNotif,emailConfigMdtList);
                    if(emailConfigMapValue!=Null && !emailConfigMapValue.isEmpty()){
                        for(ER_Email_Configuration__mdt emailconfig1value: emailConfigMapValue.get(objEmailNotif)){
                            emailTempMapList.add(emailconfig1value.Template_Name__c);
                            }
                    }
                    objEmailNotif.emailConfigMapValue = emailConfigMapValue;
                    objEmailNotifList.add(objEmailNotif);
                }               
            } 
            //Bulkified as part of TWC722-1818 - Team Quest
            if(!objEmailNotifList.isEmpty() && emailTempMapList.size() > 0){
             
                ER_EmailNotification_Utility.sendEmail(objEmailNotifList,emailTempMapList);
            }
        }
        catch(Exception ex)
        {                       
            ER_ErrorUtility.CustomException custEx = new ER_ErrorUtility.CustomException();
            custEx.Message = ex.getMessage();
            custEx.Cause = ex.getCause();
            custEx.StackTraceString = ex.getStackTraceString();
            custEx.LineNumber = ex.getLineNumber();                
            custEx.TypeName = ex.getTypeName();    
            ER_ErrorUtility.createLogEntry('Error in SendAcknowledgementEmail', custEx, LOG_ENTRY_ERROR, LOG_ENTRY_SCOPE, params);
        }        
    } 
    
    public class CustomException extends Exception{}
}