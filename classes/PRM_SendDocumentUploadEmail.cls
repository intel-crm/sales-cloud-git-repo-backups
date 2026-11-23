/*********************************************************************************************************************
Apex Class Name  : PRM_SendDocumentUploadEmail
Version       : 1.0
Created Date  : Oct 2025
Function      : Class to send email to Partner user for uploading document

Modification Log :
* Developer                 Date                    Description
* --------------------------------------------------------------------------------------------------------------------
* Saba                  23/10/2025               Class to send email to Partner user for uploading document

*********************************************************************************************************************/
public class PRM_SendDocumentUploadEmail {
    
    public static final String IPA_Registration_Request_Upload_Document_Email = 'IPA_Registration_Request_Upload_Document_Email';  
    public static final String PRM_Intel_Partner_Alliance = 'Intel Partner Alliance';
    public static Final String ORIGIN  = 'PRM_SendDocumentUploadEmail';
    public static Final String SEVERITY  = 'Error';
    public static Final String PROJECT  = 'IPA';
    public static final String SCOPE    = 'PRM_SendDocumentUploadEmail';  
    public static final boolean bypassStatusChangeValidation = true;
    /**
    * @description      : It gets the registration requests and sends email to Partner User for uploading document when 
    *                     IPA Admin clicks on Send Email button on Reg Request Page
    * @name             : sendDocumentUploadEmailToPartner
    * @param            : List<PRM_Registration_Request__c>
    * @throws exception : NONE
    **/
    
    @InvocableMethod
    public static List<boolean> sendDocumentUploadEmailToPartner(/*List<List<PRM_Registration_Request__c>> regRequestList*/List<initialInputs> processInput){
        List<boolean> isEmailSentSuccess = new List<boolean>{true};
         List<PRM_Registration_Request__c> regRequestListNew = new List<PRM_Registration_Request__c>();
         Boolean isEmailRemaider=false;
        if(processInput!=null){
            for(initialInputs inputs : processInput){
                if(inputs.regRequestList !=null){
                    regRequestListNew.addAll(inputs.regRequestList);
                }
                isEmailRemaider = inputs.isRemainderEmail;
            }
        }
        if(regRequestListNew != null && !regRequestListNew.IsEmpty()){   
            try{                                               
                List<OrgWideEmailAddress> oweaList = [select Id from OrgWideEmailAddress where Address = 'intel_partner_alliance_ops@intel.com'];
                List<Messaging.SingleEmailMessage> allmailsToSendToPartnerUser = new List<Messaging.SingleEmailMessage>();
                Map<String, PRM_EmailLog__c> emailLogMap = new Map<String, PRM_EmailLog__c>();
                Map<String, Id> regRequesttoUpdateMap = new Map<String, Id>();
                Map<String, Id> indiaToRegRequestMap = new Map<String, Id>();
                Set<String> indSet = new Set<String>{'IN', 'IND', 'India'};
                
                for(PRM_Registration_Request__c regRequest: regRequestListNew){
                    if(indSet.contains(regRequest.PRM_Country__c)){
                        indiaToRegRequestMap.put('India',regRequest.Id);
                    }
                }
                Map<String, EmailTemplate> languageEmailTemplateMap = new Map<String, EmailTemplate>();
                if(isEmailRemaider){
                    if(indiaToRegRequestMap!=null && indiaToRegRequestMap.size()>0 && indiaToRegRequestMap.containskey('India')){
                        for(EmailTemplate temp : [select id, developername, name,HtmlValue,Body,Subject from EmailTemplate where developername = 'PRM_IPA_Document_Upload_Remainder_India']){
                			languageEmailTemplateMap.put('India', temp);	    
                		} 
                    }else{
                        for(EmailTemplate temp : [select id, developername, name,HtmlValue,Body,Subject from EmailTemplate where developername Like 'PRM_IPA_Document_Upload_Remainder_Email_%']){
                			languageEmailTemplateMap.put(temp.developername.substringAfterLast('_'), temp);	    
                		}
                    }
                    
                }else{
                   if(indiaToRegRequestMap!=null && indiaToRegRequestMap.size()>0 && indiaToRegRequestMap.containskey('India')){
                        for(EmailTemplate temp : [select id, developername, name,HtmlValue,Body,Subject from EmailTemplate where developername = 'PRM_IPA_Document_Upload_India']){
                			languageEmailTemplateMap.put('India', temp);	    
                		} 
                    }else{
                        for(EmailTemplate temp : [select id, developername, name,HtmlValue,Body,Subject from EmailTemplate where developername Like 'PRM_IPA_Document_Upload_Email_%']){
                			languageEmailTemplateMap.put(temp.developername.substringAfterLast('_'), temp);	    
                		}
                    }
                }
                
                //For each reg request, create an email record and a email log record.               
                for(PRM_Registration_Request__c regRequest: regRequestListNew){
                    EmailTemplate emailTemp;
                    if(indSet.contains(regRequest.PRM_Country__c)){ 
						emailTemp = (languageEmailTemplateMap.containskey('India') && languageEmailTemplateMap.get('India') != null) ? languageEmailTemplateMap.get('India'): languageEmailTemplateMap.get(regRequest.PRM_Preferred_Language__c);                         
                    }else{
                        emailTemp = languageEmailTemplateMap.get(regRequest.PRM_Preferred_Language__c) != null? languageEmailTemplateMap.get(regRequest.PRM_Preferred_Language__c): languageEmailTemplateMap.get('ENG');
                    }                                       
                    Messaging.SingleEmailMessage mail = createEmailRecord(emailTemp, new List<String>{regRequest.PRM_Email_ID__c}, 'intel_partner_alliance_ops@intel.com');
                    if (oweaList.size() > 0 ){
                        mail.setOrgWideEmailAddressId(oweaList.get(0).Id);
                    }
                    allmailsToSendToPartnerUser.add(mail); 
                    emailLogMap.put(regRequest.PRM_Email_ID__c, createEmailLog(mail, regRequest.id));
                    regRequesttoUpdateMap.put(regRequest.PRM_Email_ID__c, regRequest.id);
                }
                               
                if(!allmailsToSendToPartnerUser.isEmpty()){
                    //Send email messages and parse through results to check for any errors and 
                    //update corresponding email log record with appropriate status
                    Messaging.SendEmailResult[] resultsList = Messaging.sendEmail(allmailsToSendToPartnerUser);
                    for (Integer i = 0; i < resultsList.size(); i++){
                        Messaging.SendEmailResult result = resultsList[i];                    
                        if(!result.isSuccess()){
                            PRM_EmailLog__c log = emailLogMap.get(allmailsToSendToPartnerUser[i].getToAddresses()[0]);
                            if(log != null){
                                log.PRM_Email_API_Response__c = String.valueOf(result.getErrors());
                                log.PRM_EmailDeliverabilityStatus__c = false;                                
                            }
                            //if email is failed for any email address, remove reg request from the list to prevent updating status
                            if(regRequesttoUpdateMap.containskey(allmailsToSendToPartnerUser[i].getToAddresses()[0])){
                                regRequesttoUpdateMap.remove(allmailsToSendToPartnerUser[i].getToAddresses()[0]); 
                                isEmailSentSuccess[0] = false;
                            }
                            Core_Log_Entry.logEntryWithDetails(ORIGIN, PROJECT, SCOPE, SEVERITY,'', String.valueOf(result.getErrors()) ,'' ,'PRM_SendDocumentUploadEmail' ,'');                                                          
                        }
                    }
                }
                
                if(!emailLogMap.isEmpty()){
                    PRM_DMLUtility.doinsert(emailLogMap.values(),'PRM_EmailLog__c', 'PRM_SendDocumentUploadEmail.sendDocumentUploadEmailToPartner');                                            
                }
                
                //Update the status on reg request to indicate email is sent to Partner for file upload
                List<PRM_Registration_Request__c> requestsToUpdate = new List<PRM_Registration_Request__c>();
                for(Id regRequestId : regRequesttoUpdateMap.values()){
                    PRM_Registration_Request__c regRequest = new PRM_Registration_Request__c();
                    regRequest.id = regRequestId;
                    regRequest.PRM_Status__c = 'PendingwithPartner';
                    requestsToUpdate.add(regRequest);
                }
                         
                if(!requestsToUpdate.isEmpty()){                    
                    PRM_DMLUtility.doupdate(requestsToUpdate,'PRM_Registration_Request__c','PRM_SendDocumentUploadEmail.sendDocumentUploadEmailToPartner');                  
                }
                                 
            }catch(Exception e){
                Core_Log_Entry.logEntryWithException(ORIGIN, PROJECT, SCOPE, SEVERITY,'', e.getMessage() ,'' ,'PRM_SendDocumentUploadEmail' ,'' ,e);        
                isEmailSentSuccess[0] = false;
            }
        }
        
        return isEmailSentSuccess;
    }
    
    /**
    * @description      : Create instance for Email log record for each email sent
    * @name             : createEmailLog
    * @param            : Messaging.SingleEmailMessage, id of reg request
    * @throws exception : NONE
    **/
    public static PRM_EmailLog__c createEmailLog(Messaging.SingleEmailMessage mail, id regRequestId){
        PRM_EmailLog__c log = new PRM_EmailLog__c();
        log.PRM_EmailDeliverabilityStatus__c = true ;            
        log.PRM_Timestamp__c = DateTime.now();
        log.PRM_ToEmailID__c = String.join(mail.getToAddresses(), ', ');
        log.Email_Template_Name__c = mail.getTemplateName();        
        log.PRM_EmailContent__c =  mail.getHtmlBody();
        log.PRM_EmailHTMLContent__c = mail.getHtmlBody();
        log.PRM_Subject__c = mail.getSubject();
        log.PRM_Type__c = 'IPA';
        log.PRM_IPA_Registration_Request__c = regRequestId;
        log.PRM_Email_API_Response__c = 'Email sent successfully';
        log.PRM_EmailDeliverabilityStatus__c = true;
        
        return log;
    }
    
    public static Messaging.SingleEmailMessage createEmailRecord(EmailTemplate emailTemp, List<String> toAddresses, String replyTo){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTemplateId(emailTemp.Id);
        mail.setSubject(emailTemp.Subject);
        mail.setHtmlBody(emailTemp.HtmlValue);       
        mail.setToAddresses(toAddresses);
        if(String.isNotBlank(replyTo)){
            mail.setReplyTo(replyTo);
        }
        return mail;
    }
    //Added by Aswin as part of WW12.4 citrus changes
    public class InitialInputs {
    @InvocableVariable(label='Is Remainder Email')
    public Boolean isRemainderEmail;

    @InvocableVariable(label='regRequestList')
    public List<PRM_Registration_Request__c> regRequestList;
    
    }
}