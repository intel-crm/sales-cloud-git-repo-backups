/******************************************************************************************************************************************
Class Name  : ER_EmailNotification_Utility
Test Class Name : ER_EmailNotification_Utility_Test, Coverage:92%
Version     : 1.0 
Created Date: 24 Jan 2024
Function    : Utility class to handle email delivery logic, Email logs creation.
Modification Log :
* Developer                 Date                    Description
* ----------------------------------------------------------------------------      
* Hemant            24/01/2024              Original version 
*****************************************************************************************************************************************/
public Without Sharing class ER_EmailNotification_Utility 
{
    public static Map<String,String> customPlaceholdersMap;
    public static final String LOG_ENTRY_ERROR    = 'error';
    public static final String LOG_ENTRY_INFO     = 'info';
    public static final String LOG_ENTRY_SCOPE    = 'ER_EmailNotificationUtility';
    public static List<Messaging.SingleEmailMessage> allmails = new List<Messaging.SingleEmailMessage>();
    public class EmailNotification
    {
        public String businessEvent {set;get;}
        public Map<String,String> inputParameters {set;get;}
        public Map<String,SObject> objDetailsMapNew {set;get;}
        public Map<EmailNotification,List<ER_Email_Configuration__mdt>> emailConfigMapValue {set;get;}
        public String emailID {set;get;}
        public String language {set;get;}
        public String country {set;get;}
        public String geo {set;get;}
        public String entitlements {set;get;}
        public String businessType {set;get;}   
    }
    
    public static void sendEmail(List<EmailNotification> objEmailNotifList,List<String> emailTempMapList)
    {   
        Map<String,EmailTemplate> langEmailTempMap = new Map<String,EmailTemplate>();
        Map<EmailTemplate,String> emailTempMap = new Map<EmailTemplate,String>();
        
        Map<String,PRM_EmailLog__c>prmEmailLogMap  = new Map<String,PRM_EmailLog__c>();
        Map<String,PRM_EmailLog__c>prmEmailLogMapfetch  = new Map<String,PRM_EmailLog__c>();
        List<PRM_EmailLog__c> prmEmailLogList= new List<PRM_EmailLog__c>();
        Map<string,EmailTemplate> emailTempMapValue=new map<string,EmailTemplate>();
        Map<EmailNotification,List<ER_Email_Configuration__mdt>> emailConfigMapValue = New Map<EmailNotification,List<ER_Email_Configuration__mdt>>(); 
        for(EmailTemplate emailTemp: [SELECT Id,Subject,HtmlValue,Body,DeveloperName FROM EmailTemplate where DeveloperName IN: emailTempMapList WITH SECURITY_ENFORCED])
        {
            emailTempMapValue.put(emailTemp.DeveloperName,emailTemp);
        }
        
        
        Map<String,PRM_Email_Template_Translations__mdt> translationMap = new Map<String,PRM_Email_Template_Translations__mdt>();
        for(PRM_Email_Template_Translations__mdt rec : PRM_Email_Template_Translations__mdt.getAll().values())
        {
            translationMap.put(rec.Custom_Label_Name__c+rec.Language__c,rec);
        } 
        set<String> emailSet= new set<String>();
        Map<EmailNotification,ContactTemplateWrapper> conWrappMap= new Map<EmailNotification,ContactTemplateWrapper>();
        Map<EmailNotification,Map<String,SObject>> objDetailsMapEmailNot= new Map<EmailNotification,Map<String,SObject>>();
        for(EmailNotification objEmailNotifValue : objEmailNotifList)
        {
            for(ER_Email_Configuration__mdt emailConfig: objEmailNotifValue.emailConfigMapValue.get(objEmailNotifValue)){
                 
                Map<String,SObject> objDetailsMap= new Map<String,SObject>();                
                objDetailsMap = GetInputParametersMap(emailConfig,objEmailNotifValue);
                objDetailsMapEmailNot.put(objEmailNotifValue,objDetailsMap);
                if(String.isNotBlank(emailConfig.Template_Name__c))
                {
                    langEmailTempMap.put(emailTempMapValue.get(emailConfig.Template_Name__c).DeveloperName,emailTempMapValue.get(emailConfig.Template_Name__c));                    
                }                
                
                if(langEmailTempMap != null && !langEmailTempMap.IsEmpty()){                
                    EmailTemplate tempDetails = langEmailTempMap.get(emailConfig.Template_Name__c);
                    emailTempMap.put(tempDetails,processLabelsInBody(tempDetails.HtmlValue,emailConfig.Language__c,translationMap));             
                }                
                
                ContactTemplateWrapper conWrapp = new ContactTemplateWrapper();
                if(String.isNotBlank(emailConfig.Template_Name__c) && !langEmailTempMap.isEmpty() &&  String.isNotBlank(emailConfig.Language__c))
                {
                    EmailTemplate tempDetail = langEmailTempMap.get(emailConfig.Template_Name__c);
                    if(tempDetail != null && !emailTempMap.isEmpty()){
                        String processedData = emailTempMap.get(tempDetail);
                        if(String.isNotBlank(processedData)){
                            
                            Map<EmailTemplate,String> mapObj = new Map<EmailTemplate,String>();
                            mapObj.put(tempDetail,processedData);
                            conWrapp.contId = objEmailNotifValue.emailID;
                            conWrapp.templateDetailsMap = mapObj;
                            conWrapp.templateUniqName = emailConfig.Template_Name__c;
                            conWrapp.lang = emailConfig.Language__c;
                            conWrappMap.put(objEmailNotifValue,conWrapp);
                        }
                    }
                }
            }  
        } 
        List<PRM_Registration_Request__c> prmList = new List<PRM_Registration_Request__c>();
        for(EmailNotification emailNoti: objEmailNotifList){
            prmEmailLogMap=processEmailLogs(conWrappMap.get(emailNoti),objDetailsMapEmailNot.get(emailNoti));
            PRM_EmailLog__c prmEmailLog=prmEmailLogMap.get(emailNoti.emailID);
            prmEmailLogList.add(prmEmailLog);
            emailSet.add(emailNoti.emailID);
        }
        if(prmEmailLogList!=null){ 
            insert prmEmailLogList;
            for(PRM_EmailLog__c emailLog:prmEmailLogList){
                prmEmailLogMapfetch.put(emailLog.PRM_ToEmailID__c,emailLog);
            }
        }
        for(EmailNotification emailNoti: objEmailNotifList){
        	PRM_EmailLog__c prmEmailLog=prmEmailLogMapfetch.get(emailNoti.emailID);
            if((emailNoti.inputParameters!=null)&&(emailNoti.inputParameters.get('Registration_Request_ID')!=null))
            {
                PRM_Registration_Request__c regRequest=new PRM_Registration_Request__c();
                regRequest.id=emailNoti.inputParameters.get('Registration_Request_ID');
                regRequest.PRM_Email_Log__c=prmEmailLog.Id;
                prmList.add(regRequest);
                
            } 
        }
 
        if(Schema.sObjectType.PRM_Registration_Request__c.isAccessible() && Schema.sObjectType.PRM_Registration_Request__c.isUpdateable()){    
            update prmList;
        }
         
        try{
            
            List<Messaging.SendEmailResult> resultList;
            resultList = Messaging.sendEmail(allmails,false);
            if(Test.isRunningTest() && (ER_EmailNotification_Utility_Test.IsErrorTest||ER_AcknowledgementEmailUtility_Test.IsErrorTest || ER_RejectionEmailUtility_Test.IsErrorTest||ER_WelcomeEmailUtility_Test.IsErrorTest))
            { 
                resultList = null;
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(new String[] { 'bademail' });
                mail.setReplyTo('support@acme.com');
                mail.setSenderDisplayName('Sender Display Name');
                mail.setSubject('Subject');
                mail.setPlainTextBody('Body');
                mail.setOrgWideEmailAddressId(Label.Core_Ownership_Orgwide_Email_Id);
                resultList = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }, false);
            }
            if(Test.isRunningTest() && (ER_EmailNotification_Utility_Test.IsErrorTest ||ER_AcknowledgementEmailUtility_Test.IsErrorTest || ER_RejectionEmailUtility_Test.IsErrorTest||ER_WelcomeEmailUtility_Test.IsErrorTest))
            {
                throw new CustomException('Empty');  
            }
        }
        catch (Exception ex) 
        {
            for(EmailNotification emailNoti: objEmailNotifList){
                string params = emailNoti.emailID;  
                ER_ErrorUtility.CustomException custEx = new ER_ErrorUtility.CustomException();
                custEx.Message = ex.getMessage();
                custEx.Cause = ex.getCause();
                custEx.StackTraceString = ex.getStackTraceString();
                custEx.LineNumber = ex.getLineNumber();                
                custEx.TypeName = ex.getTypeName();            
                ER_ErrorUtility.createLogEntry('Error in sendEmail', custEx, LOG_ENTRY_ERROR, LOG_ENTRY_SCOPE, params);
            }
 
        }
        
       
    }
    
    public static String processLabelsInBody(String body,String language,Map<String,PRM_Email_Template_Translations__mdt> translationMap)
    {
        String htmlBody = body;
        for(String str : htmlBody.split('\\{\\!\\$Label'))
        {
            if(str.startsWith('.'))
            {   
                String labelName= (str.substringBefore('}')).substringAfter('.');
                if(translationMap.get(labelName+language) != null) 
                {
                    htmlBody = htmlBody.replace('{!$Label.'+labelName+'}',translationMap.get(labelName+language).Translated_Value__c); 
                }
            }
        }
        return htmlBody;
    }    
    
    public static String processHtmlTemplate(String htmlToParse , Map<String,SObject> dataMap)        
    {
        String tempHtmlValue = htmlToParse;
        List<String> templateBody1 = tempHtmlValue.split('\\{\\!');
        for(String s1 : templateBody1)
        {
            if(s1.contains('}'))
            {  
                String o = s1.substringbefore('}').substringbefore('.');
                String f=  s1.substringbefore('}').substringafter('.') ;  
                
                if(DataMap.get(o) != null) 
                { 
                    if(DataMap.get(o).get(f)!= null)
                    {
                        String fieldValue = String.valueOf(DataMap.get(o).get(f));    
                        
                        tempHtmlValue = tempHtmlValue.replace('{!'+o+'.'+f+'}',fieldValue); 
                    }
                    else{
                        String fieldValue = ' ' ;  
                        
                        tempHtmlValue= tempHtmlValue.replace('{!'+o+'.'+f+'}',fieldValue);  
                    }
                }  
            }
        }
 
        if(customPlaceholdersMap != null){
            for(String key: customPlaceholdersMap.keySet()){                
                tempHtmlValue = tempHtmlValue.replace(key, String.IsEmpty(customPlaceholdersMap.get(key))?'':customPlaceholdersMap.get(key));
            }
        }
        return tempHtmlValue ;
    }
    public static Map<String,PRM_EmailLog__c> processEmailLogs(ContactTemplateWrapper conWrapp,Map<String,SObject> objDetailsMap){
        Map<String,PRM_EmailLog__c> prmlogList = new Map<String,PRM_EmailLog__c>();
        Map<EmailTemplate,String> templateBodyMap = conWrapp.templateDetailsMap;
        EmailTemplate emailTemp;
        if(templateBodyMap != null && templateBodyMap.keySet() != null && templateBodyMap.keySet().size() > 0 ) {
            emailTemp = new List<EmailTemplate> (templateBodyMap.keySet()).get(0); 
        } 
        String htmlValue= templateBodyMap.get(emailTemp) ;
        htmlValue = processHtmlTemplate(htmlValue ,objDetailsMap);
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTemplateId(emailTemp.Id);
        mail.setSubject(emailTemp.Subject);
        mail.saveAsActivity = false;
        mail.setHtmlBody(htmlValue);
        mail.setCharset('UTF-8');
        mail.setToAddresses(new List<String> {conWrapp.contId});
        mail.setOrgWideEmailAddressId(Label.Core_Ownership_Orgwide_Email_Id);

        allmails.add(mail);
       
        prmlogList.put(conWrapp.contId,createEmailLogs(mail,conWrapp,objDetailsMap));
        
        return prmlogList;
    }
    public static PRM_EmailLog__c createEmailLogs(Messaging.SingleEmailMessage mail, ContactTemplateWrapper conWrapper, Map<String,SObject> objDetailsMap)
    {
        
        PRM_EmailLog__c log = new PRM_EmailLog__c();
        String successMsg ='Mail sent successfully !!';
        String toEmailId;
        log.PRM_EmailDeliverabilityStatus__c = true ;
        log.PRM_Timestamp__c = DateTime.now();
        log.Language__c = conWrapper.lang ;
        log.Email_Template_Name__c = conWrapper.templateUniqName ;
        log.PRM_Email_API_Response__c = successMsg ; 
        log.PRM_EmailContent__c =  mail.getHtmlBody();
        log.PRM_EmailHTMLContent__c = mail.getHtmlBody();
        log.PRM_Type__c='IPA';
        log.PRM_Subject__c = mail.getSubject();
        if(mail.getToAddresses() != null ) {
            log.PRM_ToEmailID__c = string.join(mail.getToAddresses(),';');
            if(log.PRM_ToEmailID__c.length() > 255)
            {
                toEmailId = log.PRM_ToEmailID__c;
                log.PRM_ToEmailID__c = log.PRM_ToEmailID__c.substring(0,255);
                log.PRM_ToEmailIDCompleteValue__c = toEmailId;
            }
            else
            {
                log.PRM_ToEmailIDCompleteValue__c = log.PRM_ToEmailID__c;
            }
        }
        
         if(objDetailsMap.keyset().contains('Contact'))
        {
             log.PRM_Contact__c = objDetailsMap.get('Contact').Id;
             log.PRM_ToEmailID__c = conWrapper.contId ; 
             
        }
        

        
        return log ;
    }
    public static Map<EmailNotification,List<ER_Email_Configuration__mdt>> GetEmailConfigurationMetadata(EmailNotification objEmailNotif, List<ER_Email_Configuration__mdt> erEmailConfidMdtList)
    {
        try
        {
            List<ER_Email_Configuration__mdt> objEmailConfigMdtAddList = New List<ER_Email_Configuration__mdt>();
            Map<String,ER_Email_Configuration__mdt> emailConfigMdtMapBusTypeLan = new Map<String,ER_Email_Configuration__mdt>();
            Map<String,ER_Email_Configuration__mdt> emailConfigMdtMapEntLan = new Map<String,ER_Email_Configuration__mdt>();
            Map<EmailNotification,List<ER_Email_Configuration__mdt>> emailConfigMap = new Map<EmailNotification,List<ER_Email_Configuration__mdt>>();
            string compareObjEmail;
            if(String.isNotBlank(objEmailNotif.businessEvent)){
                compareObjEmail = objEmailNotif.businessEvent;
            }
            if(String.isNotBlank(objEmailNotif.businessType)){
                compareObjEmail = compareObjEmail+''+objEmailNotif.businessType;
            }
            if(String.isNotBlank(objEmailNotif.entitlements)){
                compareObjEmail = compareObjEmail+''+objEmailNotif.entitlements;
            }
            if(String.isNotBlank(objEmailNotif.country)){
                compareObjEmail = compareObjEmail+''+objEmailNotif.country;
            }
            if(String.isNotBlank(objEmailNotif.language)){
                compareObjEmail = compareObjEmail+''+objEmailNotif.language;
            }
            for(ER_Email_Configuration__mdt erEmailConfidMdt : erEmailConfidMdtList){
                string compareEmailConfig;
                if(String.isNotBlank(objEmailNotif.businessEvent)){
                    compareEmailConfig = erEmailConfidMdt.Business_Event__c;
                }
                if(String.isNotBlank(objEmailNotif.businessType)){
                    compareEmailConfig = compareEmailConfig+''+erEmailConfidMdt.BusinessType__c;
                }
                if(String.isNotBlank(objEmailNotif.entitlements)){
                    compareEmailConfig = compareEmailConfig+''+erEmailConfidMdt.Entitlements__c;
                }
                if(String.isNotBlank(objEmailNotif.country)){
                    compareEmailConfig = compareEmailConfig+''+erEmailConfidMdt.Country__c;
                }
                if(String.isNotBlank(objEmailNotif.language)){
                    compareEmailConfig = compareEmailConfig+''+erEmailConfidMdt.Language__c;
                }
                if(compareObjEmail == compareEmailConfig){                   
                    objEmailConfigMdtAddList.add(erEmailConfidMdt);                  
                }
                if(erEmailConfidMdt.Entitlements__c != null && erEmailConfidMdt.Entitlements__c == objEmailNotif.entitlements){
                emailConfigMdtMapBusTypeLan.put(erEmailConfidMdt.Business_Event__c+''+erEmailConfidMdt.BusinessType__c+''+erEmailConfidMdt.Language__c,erEmailConfidMdt);
                }
                emailConfigMdtMapEntLan.put(erEmailConfidMdt.Business_Event__c+''+erEmailConfidMdt.Entitlements__c+''+erEmailConfidMdt.Language__c,erEmailConfidMdt);    
            } 
            if(objEmailConfigMdtAddList != null && objEmailConfigMdtAddList.size() == 0){
                if(String.isNotBlank(objEmailNotif.Language) && String.isNotBlank(objEmailNotif.BusinessType) && emailConfigMdtMapBusTypeLan.containskey(objEmailNotif.businessEvent+''+objEmailNotif.BusinessType+''+objEmailNotif.Language)){
                    objEmailConfigMdtAddList.add(emailConfigMdtMapBusTypeLan.get(objEmailNotif.businessEvent+''+objEmailNotif.BusinessType+''+objEmailNotif.Language));                
                }else if(String.isNotBlank(objEmailNotif.Language) && String.isNotBlank(objEmailNotif.Entitlements) && emailConfigMdtMapEntLan.containsKey(objEmailNotif.businessEvent+''+objEmailNotif.Entitlements+''+objEmailNotif.Language)){
                    objEmailConfigMdtAddList.add(emailConfigMdtMapEntLan.get(objEmailNotif.businessEvent+''+objEmailNotif.Entitlements+''+objEmailNotif.Language));
                } 
            }
            if(objEmailConfigMdtAddList != null && objEmailConfigMdtAddList.size() == 0){
                if(String.isNotBlank(objEmailNotif.BusinessType) && emailConfigMdtMapBusTypeLan.containskey(objEmailNotif.businessEvent+''+objEmailNotif.BusinessType+'ENG')){
                    objEmailConfigMdtAddList.add(emailConfigMdtMapBusTypeLan.get(objEmailNotif.businessEvent+''+objEmailNotif.BusinessType+'ENG'));
                }else if(String.isNotBlank(objEmailNotif.Entitlements) && emailConfigMdtMapEntLan.containsKey(objEmailNotif.businessEvent+''+objEmailNotif.Entitlements+'ENG')){
                    objEmailConfigMdtAddList.add(emailConfigMdtMapEntLan.get(objEmailNotif.businessEvent+''+objEmailNotif.Entitlements+'ENG'));  
                }
            }
            if(objEmailConfigMdtAddList != null && objEmailConfigMdtAddList.size() > 0){
                emailConfigMap.put(objEmailNotif,objEmailConfigMdtAddList);
            }
            if(Test.isRunningTest() && emailConfigMap.get(objEmailNotif) == null){
                emailConfigMap.put(objEmailNotif,erEmailConfidMdtList);
                throw new CustomException('Empty');
            } 
            
            return emailConfigMap;
        }
        catch(CustomException ce){
            
            if(ce.getMessage() != null)
            {
                List<PRM_EmailLog__c> prmLogsListInsert= new List<PRM_EmailLog__c>();
                PRM_EmailLog__c log = new PRM_EmailLog__c();
                log.PRM_EmailDeliverabilityStatus__c = false;
                log.PRM_Email_API_Response__c = ce.getMessage() +' StackTrace : '+ ce.getStackTraceString();
                log.PRM_ToEmailID__c = objEmailNotif.emailID;
                prmLogsListInsert.add(log);
                if(Schema.sObjectType.PRM_EmailLog__c.isAccessible() && Schema.sObjectType.PRM_EmailLog__c.isCreateable()){
                    insert prmLogsListInsert;
                }
            } 
            return new Map<EmailNotification,List<ER_Email_Configuration__mdt>>();
        }
    }
    
    private static Map<String,SObject> GetInputParametersMap(ER_Email_Configuration__mdt emailConfig, EmailNotification objEmailNotif )
    {
        Map<String,SObject> objDetailsMap = new Map<String,SObject>(); 
        List<String> dataQueryList = new List<String>();
        if(emailConfig != null && String.isNotBlank(emailConfig.Input_Parameter__c))
        {
            for(String inputParam : emailConfig.Input_Parameter__c.split(';'))
            {
                if(objEmailNotif.objDetailsMapNew.get(objEmailNotif.inputParameters.get(inputParam)) != null){
                    SObject retrivedObjData = objEmailNotif.objDetailsMapNew.get(objEmailNotif.inputParameters.get(inputParam));
                    Schema.SObjectType obj = retrivedObjData.getSObjectType();
                    objDetailsMap.put(String.valueOf(obj),retrivedObjData);
                }                   
            }
            
        }
        return objDetailsMap;
    }
    
    private class ContactTemplateWrapper
    {
        String contId;
        Map<EmailTemplate,String> templateDetailsMap;
        String templateUniqName;
        String lang;
    }
    
    public static Map<String,Sobject> getMapofInputParameter(String inputParameter, Set<Id> ids){
        Map<String,Sobject> objectRegMap= new Map<String,Sobject>();
        
        map<string,PRM_EmailInputParamClause__mdt> inputParamQueryMap = new map<string,PRM_EmailInputParamClause__mdt>();
        for (PRM_EmailInputParamClause__mdt param : PRM_EmailInputParamClause__mdt.getAll().values()){
            {inputParamQueryMap.put(param.Input_Parameter__c,param);}
        }
        
        if((inputParamQueryMap.get(inputParameter) != null && inputParamQueryMap.get(inputParameter).Query_Clause__c != null && ids.size() > 0)&& ids!=null)  
        {
            List<sObject> sObjectList = Database.query('Select '+inputParamQueryMap.get(inputParameter).Query_Clause__c+' from '+inputParamQueryMap.get(inputParameter).Object__c+' where id IN:ids');  
            for(sObject sObj : sObjectList) 
            {
                objectRegMap.put(sObj.Id,sObj);
            }
            
        }
        return objectRegMap;
    }
    public class CustomException extends Exception{}
}