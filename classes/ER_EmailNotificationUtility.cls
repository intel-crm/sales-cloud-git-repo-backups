public class ER_EmailNotificationUtility 
{
    public static Map<String,String> customPlaceholdersMap;
    public static final String LOG_ENTRY_ERROR    = 'error';
    public static final String LOG_ENTRY_INFO     = 'info';
    public static final String LOG_ENTRY_SCOPE    = 'ER_EmailNotificationUtility';
    
    public class EmailNotification
    {
        public String BusinessEvent {set;get;}
        public Map<String,String> InputParameters {set;get;}
        public String EmailID {set;get;}
        public String Language {set;get;}
        public String Country {set;get;}
        public String Geo {set;get;}
        public String Entitlements {set;get;}
        public String BusinessType {set;get;}
        
        /*public EmailNotification(String busEvent,Map<String,String> inputParam, String emailId, String lang, String ctry,String geo, String entitlements)
{
this.BusinessEvent = busEvent;
this.InputParameters = inputParam;
this.EmailID = emailId;
this.Language = lang;
this.Country = ctry;
this.Geo = geo;
this.Entitlements = entitlements;

}*/
        
    }
    
    public static void sendEmail(EmailNotification objEmailNotif)
    {   
        System.debug(objEmailNotif);
        string params = objEmailNotif.EmailID;
        Map<String,EmailTemplate> langEmailTempMap = new Map<String,EmailTemplate>();
        Map<EmailTemplate,String> emailTempMap = new Map<EmailTemplate,String>();
        List<Messaging.SingleEmailMessage> allmails = new List<Messaging.SingleEmailMessage>();
        List<PRM_EmailLog__c> logList = new List<PRM_EmailLog__c>();
        //Get all records from PRM_EmailInputParamClause__mdt and populate a map
        map<string,PRM_EmailInputParamClause__mdt> inputParamQueryMap = new map<string,PRM_EmailInputParamClause__mdt>();
        for (PRM_EmailInputParamClause__mdt param : [select id,Query_Clause__c,Input_Parameter__c,Object__c from PRM_EmailInputParamClause__mdt]){
            if(param != null) {inputParamQueryMap.put(param.Input_Parameter__c,param); }
        }
        Map<String,PRM_Email_Template_Translations__mdt> translationMap = new Map<String,PRM_Email_Template_Translations__mdt>();
        for(PRM_Email_Template_Translations__mdt rec : [Select id,Custom_Label_Name__c,Language__c,Translated_Value__c from PRM_Email_Template_Translations__mdt])
        {
            translationMap.put(rec.Custom_Label_Name__c+rec.Language__c,rec);
        } 
        System.debug('Label Map:-->'+translationMap);
        
        List<OrgWideEmailAddress> fromEmail = [select Id from OrgWideEmailAddress where Address =: Label.PRM_wsm_postmaster_intel_com];
        
        for(ER_Email_Configuration__mdt emailConfig : GetEmailConfigurationMetadata(objEmailNotif))
        {
            system.debug('For metadata record-->'+emailConfig);
            //Get the record details to pass info in EmailTemplate using inputParams and inputParamQueryMap    
            Map<String,SObject> objDetailsMap = GetInputParametersMap(emailConfig,objEmailNotif,inputParamQueryMap);
            
            if(String.isNotBlank(emailConfig.Template_Name__c))
            {
                for(EmailTemplate emailTemp: [SELECT Id,Subject,HtmlValue,Body,DeveloperName FROM EmailTemplate WHERE DeveloperName =:emailConfig.Template_Name__c]){
                    langEmailTempMap.put(emailTemp.DeveloperName,emailTemp);
                }
            }
            
            //Generate template body map
            //emailTempMap
            System.debug('langEmailTempMap >>> '+langEmailTempMap);
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
                    System.debug('HTML processedData : '+processedData);
                    if(String.isNotBlank(processedData)){
                        
                        Map<EmailTemplate,String> mapObj = new Map<EmailTemplate,String>();
                        mapObj.put(tempDetail,processedData);
                        conWrapp.contId = objEmailNotif.EmailID;
                        conWrapp.templateDetailsMap = mapObj;
                        conWrapp.templateUniqName = emailConfig.Template_Name__c;
                        conWrapp.lang = emailConfig.Language__c;
                    }
                }
            }
            
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
            //set from adress and display name from OrgWide address
            if ( fromEmail.size() > 0 ) {
                mail.setOrgWideEmailAddressId(fromEmail.get(0).Id);
            } 
            mail.saveAsActivity = false;
            mail.setHtmlBody(htmlValue);
            mail.setCharset('UTF-8');
            system.debug('BODY after processing1--->'+htmlValue);  
            mail.setToAddresses(new List<String> {conWrapp.contId});
            
            allmails.add(mail);
            //create log data for each mail entry assuming status as success
            logList= createEmailLogs(mail,logList,conWrapp.contId,conWrapp.lang,conWrapp.templateUniqName);
            system.debug('Total Mails-->'+allmails.size());
            System.debug('logList -->'+logList);
        }
        
        //send mail and check the result obtained -- modify the log entry according to the results obtained 
        try{
            system.debug('Mail sent--'+'Mail list size--'+allmails.size());
            List<Messaging.SendEmailResult> resultList;
            //system.debug('before if Template Name---'+PRM_EmailUtility.templateName);
            
            system.debug('inside if ---');            
            resultList = Messaging.sendEmail(allmails,false);
            system.debug('resultList--->'+resultList);
            
            if(Test.isRunningTest() && ER_EmailNotificationUtility_Test.IsErrorTest)
            { 
                resultList = null;
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(new String[] { 'bademail' });
                mail.setReplyTo('support@acme.com');
                mail.setSenderDisplayName('Sender Display Name');
                mail.setSubject('Subject');
                mail.setPlainTextBody('Body');
                resultList = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }, false);
            }
            
            //create a Map for targetId and log
            Map<String,PRM_EmailLog__c> targetIdLog = new Map<String,PRM_EmailLog__c>();
            for(PRM_EmailLog__c l : logList)
            {
                if(l.PRM_Contact__c != null) 
                {
                    targetIdLog.put(l.PRM_Contact__c,l); 
                }
                else if(l.PRM_User__c !=  null) 
                { 
                    targetIdLog.put(l.PRM_User__c,l);
                }
                if(Test.isRunningTest() && ER_EmailNotificationUtility_Test.IsErrorTest)
                { 
                    targetIdLog.put(l.PRM_ToEmailIDCompleteValue__c,l);
                }
            }
            System.debug('targetIdLog : '+targetIdLog);
            
            for(Messaging.SendEmailResult result : resultList)
            {
                System.debug('Messaging.SendEmailError: '+result.getErrors());
                if(! result.isSuccess())
                {
                    for( Messaging.SendEmailError error : result.getErrors()) {
                        //in case of targetObjectId received  
                        String targetId= error.getTargetObjectId();
                        if(Test.isRunningTest() && ER_EmailNotificationUtility_Test.IsErrorTest && String.isBlank(targetId))
                        {
                            targetId = objEmailNotif.EmailID;
                        }
                        String errorMsg= error.getMessage();
                        System.debug('targetId : '+targetId);
                        if(targetId !=  null && targetIdLog.get(targetId) != null)
                        {
                            PRM_EmailLog__c log = targetIdLog.get(targetId);
                            log.PRM_EmailDeliverabilityStatus__c = false;
                            log.PRM_Email_API_Response__c = errorMsg ;
                        }
                    } 
                } 
            }   
            System.debug('Start of Method \nUsed -->'+limits.getQueries()+'Limit -->'+limits.getLimitQueries());
            
        }
        catch (Exception ex) 
        {
            ER_ErrorUtility.CustomException custEx = new ER_ErrorUtility.CustomException();
            custEx.Message = ex.getMessage();
            custEx.Cause = ex.getCause();
            custEx.StackTraceString = ex.getStackTraceString();
            custEx.LineNumber = ex.getLineNumber();                
            custEx.TypeName = ex.getTypeName();            
            ER_ErrorUtility.createLogEntry('Error in sendEmail', custEx, LOG_ENTRY_ERROR, LOG_ENTRY_SCOPE, params);
        }
        
        system.debug('Total queries executed--->'+Limits.getQueries());    
        
        if(logList != null && logList.size()>0) { 
            insert logList; 
            
            // if email notif has registration request as one of the parameters,then update the registration request with email log id.
            if((objEmailNotif.InputParameters!=null)&&(objEmailNotif.InputParameters.get('Registration_Request_ID')!=null))
            {
                PRM_Registration_Request__c regRequest=new PRM_Registration_Request__c();
                regRequest.id=objEmailNotif.InputParameters.get('Registration_Request_ID');
                regRequest.PRM_Email_Log__c=logList[0].Id;
                update regRequest;
            } 
        }
    }
    
    public static String processLabelsInBody(String body,String language,Map<String,PRM_Email_Template_Translations__mdt> translationMap)
    {
        system.debug('Body'+body);
        system.debug('language'+language);
        system.debug('mdt'+translationMap);
        String htmlBody = body;
        system.debug(htmlBody.contains('{!$Label'));
        //List<String> templateBody1 = ;
        for(String str : htmlBody.split('\\{\\!\\$Label'))
        {
            if(str.startsWith('.'))
            {   
                String labelName= (str.substringBefore('}')).substringAfter('.');
                system.debug('Label--'+labelName);
                system.debug('Value--'+labelName+language);
                //system.debug('Value replaced--'+translationMap.get(labelName+language).Translated_Value__c);
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
        system.debug(templateBody1.size());//retrivedObjList
        for(String s1 : templateBody1)
        {
            if(s1.contains('}'))
            {  
                String o = s1.substringbefore('}').substringbefore('.');
                String f=  s1.substringbefore('}').substringafter('.') ;  
                system.debug(o+f);
                system.debug('MAP--'+DataMap); 
                /*if(iterator != null)
{
if(DataMap.get(iterator) != null) 
{
if(DataMap.get(iterator).get(f)!= null)
{
String fieldValue = String.valueOf(DataMap.get(iterator).get(f));    
system.debug(o+'.'+f+'--->'+fieldValue); 
tempHtmlValue= tempHtmlValue.replace('{!'+o+'.'+f+'}',fieldValue);     
}//replace the value of field with blank space if no value is present in record
else 
{
String fieldValue = ' ' ;  
system.debug(o+'.'+f+'--->'+fieldValue); 
tempHtmlValue= tempHtmlValue.replace('{!'+o+'.'+f+'}',fieldValue);     
}
}
}
else
{*/
                if(DataMap.get(o) != null) 
                { 
                    if(DataMap.get(o).get(f)!= null)
                    {
                        String fieldValue = String.valueOf(DataMap.get(o).get(f));    
                        system.debug(o+'.'+f+'--->'+fieldValue); 
                        tempHtmlValue = tempHtmlValue.replace('{!'+o+'.'+f+'}',fieldValue); 
                    }//replace the value of field with blank space if no value is present in record
                    else{
                        String fieldValue = ' ' ;  
                        system.debug(o+'.'+f+'--->'+fieldValue); 
                        tempHtmlValue= tempHtmlValue.replace('{!'+o+'.'+f+'}',fieldValue);  
                    }
                }    
                //}
            }
        }
        
        //Added to Embed values for Custom Placeholders in the email.
        //system.debug('customPlaceholdersMap------->'+customPlaceholdersMap);
        if(customPlaceholdersMap != null){
            for(String key: customPlaceholdersMap.keySet()){                
                tempHtmlValue = tempHtmlValue.replace(key, String.IsEmpty(customPlaceholdersMap.get(key))?'':customPlaceholdersMap.get(key));
            }
        }
        System.debug('tempHtmlValue'+tempHtmlValue);
        return tempHtmlValue ;
    }
    
    public static List<PRM_EmailLog__c> createEmailLogs(Messaging.SingleEmailMessage mail,List<PRM_EmailLog__c> logList, String emailID,String lang,String templateName)
    {
        //apend values in below fields and create record in EmailLogs Object using obtained status  
        PRM_EmailLog__c log = new PRM_EmailLog__c();
        String successMsg ='Mail sent successfully !!';
        String toEmailId;
        log.PRM_EmailDeliverabilityStatus__c = true ;
        log.PRM_Timestamp__c = DateTime.now();
        log.Language__c = lang ;
        log.Email_Template_Name__c = templateName ;
        log.PRM_Email_API_Response__c = successMsg ; 
        log.PRM_EmailContent__c =  mail.getHtmlBody();
        log.PRM_EmailHTMLContent__c = mail.getHtmlBody();
        log.PRM_Type__c='IPA';
        //system.debug('emailBodyTempl -->' +emailBodyTempl) ;
        //log.PRM_EmailContent__c =emailBodyTempl;
        log.PRM_Subject__c = mail.getSubject();
        if(mail.getToAddresses() != null ) {
            log.PRM_ToEmailID__c = string.join(mail.getToAddresses(),';');
            //Added this if-else as part of US-618183
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
        if(mail.getTargetObjectId() != null)
        {
            String objType = String.valueof(mail.getTargetObjectId().getSObjectType());
            if(objType == 'Contact')
            { log.PRM_Contact__c = mail.getTargetObjectId() ;
             log.PRM_ToEmailID__c = emailID ;             
            }
        }
        logList.add(log);
        system.debug('Email Logs-->'+ logList);
        return logList ;
    }
    
    private static List<ER_Email_Configuration__mdt> GetEmailConfigurationMetadata(EmailNotification objEmailNotif)
    {
        string whereCondition=' ';
        string queryForTemplateDetails='SELECT id,Business_Event__c,BusinessType__c, Country__c,Entitlements__c,Geo__c,Input_Parameter__c,Language__c, Template_Name__c FROM ER_Email_Configuration__mdt where Business_Event__c= \''+String.escapeSingleQuotes(objEmailNotif.BusinessEvent)+'\'';
        if(String.isNotBlank(objEmailNotif.BusinessType)){
            whereCondition += ' and BusinessType__c = \''+String.escapeSingleQuotes(objEmailNotif.BusinessType)+'\'' ;
        }
        if(String.isNotBlank(objEmailNotif.Entitlements)){
            whereCondition += ' and Entitlements__c = \''+String.escapeSingleQuotes(objEmailNotif.Entitlements)+'\'' ;
        }
        if(String.isNotBlank(objEmailNotif.Geo)){
            whereCondition += ' and Geo__c = \''+String.escapeSingleQuotes(objEmailNotif.Geo)+'\'' ;
        }
        if(String.isNotBlank(objEmailNotif.Country)){
            whereCondition += ' and Country__c = \''+String.escapeSingleQuotes(objEmailNotif.Country)+'\'' ;
        }
        if(String.isNotBlank(objEmailNotif.Language)){
            whereCondition += ' and Language__c = \''+String.escapeSingleQuotes(objEmailNotif.Language)+'\'' ;
        }
        if(whereCondition != null && whereCondition.length() > 0) {queryForTemplateDetails += whereCondition;}
        system.debug('Metadata Query-->'+queryForTemplateDetails);
        try
        {
            //query list of metadata records present with the info provided
            List<ER_Email_Configuration__mdt> emailConfigList = database.query(queryForTemplateDetails);
            
            System.debug('emailConfigList : '+emailConfigList);
            System.debug('emailConfigList size : '+emailConfigList.size());
            
            if(emailConfigList != null && emailConfigList.size() == 0)
            {
                if(String.isNotBlank(objEmailNotif.Language) && String.isNotBlank(objEmailNotif.BusinessType))
                {                
                    emailConfigList = [SELECT id,Business_Event__c,BusinessType__c, Country__c,Entitlements__c,
                                       Geo__c,Input_Parameter__c,Language__c, Template_Name__c
                                       FROM ER_Email_Configuration__mdt
                                       WHERE Business_Event__c =: objEmailNotif.BusinessEvent AND
                                       BusinessType__c =: objEmailNotif.BusinessType
                                       AND Language__c =: objEmailNotif.Language LIMIT 1];
                    system.debug('emailConfigListbt1 '+emailConfigList);
                }
                else if(String.isNotBlank(objEmailNotif.Language) && String.isNotBlank(objEmailNotif.Entitlements))
                {
                    emailConfigList = [SELECT id,Business_Event__c,BusinessType__c, Country__c,Entitlements__c,
                                       Geo__c,Input_Parameter__c,Language__c, Template_Name__c
                                       FROM ER_Email_Configuration__mdt
                                       WHERE Business_Event__c =: objEmailNotif.BusinessEvent AND
                                       Entitlements__c =: objEmailNotif.Entitlements
                                       AND Language__c =: objEmailNotif.Language LIMIT 1];
                    system.debug('emailConfigListet1 '+emailConfigList);
                }
                
                if(emailConfigList != null && emailConfigList.size() == 0)
                {
                    if(String.isNotBlank(objEmailNotif.BusinessType))
                    {
                        emailConfigList = [SELECT id,Business_Event__c,BusinessType__c, Country__c,Entitlements__c,
                                           Geo__c,Input_Parameter__c,Language__c, Template_Name__c
                                           FROM ER_Email_Configuration__mdt
                                           WHERE Business_Event__c =: objEmailNotif.BusinessEvent AND
                                           BusinessType__c =: objEmailNotif.BusinessType
                                           AND Language__c = 'ENG' LIMIT 1];
                        system.debug('emailConfigListbt2 '+emailConfigList);
                    }
                    else if(String.isNotBlank(objEmailNotif.Entitlements))
                    {
                        emailConfigList = [SELECT id,Business_Event__c,BusinessType__c, Country__c,Entitlements__c,
                                           Geo__c,Input_Parameter__c,Language__c, Template_Name__c
                                           FROM ER_Email_Configuration__mdt
                                           WHERE Business_Event__c =: objEmailNotif.BusinessEvent AND
                                           Entitlements__c =: objEmailNotif.Entitlements
                                           AND Language__c = 'ENG' LIMIT 1];
                        system.debug('emailConfigListet2 '+emailConfigList);
                    }
                }  
                
                if(emailConfigList != null && emailConfigList.size() == 0)
                {
                    throw new CustomException('Template Does not exist for this combination');
                }
                
            }
            System.debug('emailConfigList : '+emailConfigList);
            return emailConfigList;
        }
        catch(CustomException ce){
            
            if(ce.getMessage() != null)
            {
                PRM_EmailLog__c log = new PRM_EmailLog__c();
                log.PRM_EmailDeliverabilityStatus__c = false;
                log.PRM_Email_API_Response__c = ce.getMessage() +' StackTrace : '+ ce.getStackTraceString();
                log.PRM_ToEmailID__c = objEmailNotif.EmailID;
                insert log;
            } 
            return new List<ER_Email_Configuration__mdt>();
        }
    }
    
    private static Map<String,SObject> GetInputParametersMap(ER_Email_Configuration__mdt emailConfig, EmailNotification objEmailNotif, Map<string,PRM_EmailInputParamClause__mdt> inputParamQueryMap)
    {
        Map<String,SObject> objDetailsMap = new Map<String,SObject>(); 
        List<String> dataQueryList = new List<String>();
        if(emailConfig != null && String.isNotBlank(emailConfig.Input_Parameter__c))
        {
            //Input_Parameter__c - Registration_Request_ID;LanguageCulture_MDT
            for(String inputParam : emailConfig.Input_Parameter__c.split(';'))
            {       
                if(inputParamQueryMap.get(inputParam) != null && inputParamQueryMap.get(inputParam).Query_Clause__c != null && objEmailNotif.InputParameters.get(inputParam) != null)  
                {
                    dataQueryList.add('Select '+inputParamQueryMap.get(inputParam).Query_Clause__c+' from '+inputParamQueryMap.get(inputParam).Object__c+' where id= \''+String.escapeSingleQuotes(objEmailNotif.InputParameters.get(inputParam))+'\'');  
                }                    
            }
            system.debug('dataQueryList -'+dataQueryList);
            for(String qry : dataQueryList) 
            {
                //TODO Exception handling
                SObject retrivedObj = Database.query(qry);  
                System.debug('###sd'+retrivedObj);
                Schema.SObjectType obj = retrivedObj.getSObjectType();
                objDetailsMap.put(String.valueOf(obj),retrivedObj); 
            }
            system.debug('DataMap-->'+objDetailsMap);
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
    
    public class CustomException extends Exception{}
}