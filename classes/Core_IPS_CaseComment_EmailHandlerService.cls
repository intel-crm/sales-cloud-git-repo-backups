/***************************************************************************************************
Apex Class Name:  Core_IPS_CaseComment_EmailHandlerService
Version     : 1.0 
Created Date: 30 Oct 2017
Function    : Email Handler service class for Case Comment creation through email and processing exception email 
Used By     : Core_IPS_CaseComment_EmailHandler
Test Class  : Core_IPS_CaseComment_EmailHandler_Test 
Modification Log :
* Developer                    Date                    Description
* ----------------------------------------------------------------------------                 
* Gourav Anand                 30/10/2017              Created
* Karthick                     02/02/2018              Modified - Handled email exception
* Sumukh                       06/06/2018              Modified - Handled logic for comment source field I-12, R-4.3, US-105428 
****************************************************************************************************/

public without sharing class Core_IPS_CaseComment_EmailHandlerService {

    public static Core_IPS_Case_Comments__c createCaseComment(String htmlComment, String caseCommentType,String authorType, User usr, Id caseId){
        Core_IPS_Case_Comments__c comment = new Core_IPS_Case_Comments__c();
        comment.Core_IPS_Case__c =  caseId; 
        comment.Core_IPS_Case_Comment_Type__c = caseCommentType;
        comment.Core_IPS_Rich_Comment__c = (htmlComment.length()>131000)? htmlComment.subString(0,131000):htmlComment;
        comment.Core_IPS_Comment_Author_Type__c = authorType;
        comment.Core_IPS_Case_Comment_Source__c = Core_IPS_Labels__c.getValues('Comment Source - Email').value__c; // Added by sumukh for comment source for US 105428
        comment.CreatedById = usr.Id;
        comment.LastModifiedById = usr.Id;
        insert comment;  
        return comment;
    }
    
    public static Core_IPS_Case_Comments__c processBinaryAttachment(Messaging.InboundEmail email, Core_IPS_Case_Comments__c comment){
        String richTextComment = '';
        Map< String, Attachment > mapAttachments = new Map< String, Attachment >(); 
        Map< String, Attachment > mapEmailAttachments = new Map< String, Attachment >(); 
        List<Attachment> attachmentList = new List<Attachment>();
        String replacedHeaderVal='';
        for(Messaging.InboundEmail.BinaryAttachment bA : email.binaryAttachments) {
           
            for(integer i = 0; i < bA.headers.size(); i++) {
              
                //Header Value
                String headerValue = bA.headers[i].value;
                
                //if(headerValue.startsWith('< image')|| headerValue.startsWith('<image') || headerValue.startsWith('<ii') || headerValue.startsWith('<_wpsmail')) {
                if(headerValue.startsWith('<') && headerValue.endsWith('>') ) {
                    headerValue = headerValue.replaceAll('<', '').replaceAll('>', '');
                    mapAttachments.put(headerValue, new Attachment(Name = bA.fileName, body = bA.body, 
                                                    ParentId = comment.Id, ContentType = bA.mimeTypeSubType));
                }
            }
        }
        //Insert attachment
        try{            
            insert mapAttachments.values();
        }catch(Exception ex){
        }
        
        //Process inline images and update the HTML Body
        for(String headerValue : mapAttachments.keySet()) {
            //Reference Link
            String refLink = System.Label.Core_IPS_Salesforce_Org_URL+'/servlet/servlet.FileDownload?file=' + mapAttachments.get(headerValue).Id;
            comment.Core_IPS_Rich_Comment__c = comment.Core_IPS_Rich_Comment__c.replaceAll('cid:' + headerValue, refLink);
            
            comment.Core_IPS_Rich_Comment__c = (comment.Core_IPS_Rich_Comment__c.length()>131000)? comment.Core_IPS_Rich_Comment__c.subString(0,131000):comment.Core_IPS_Rich_Comment__c;
            
        }
        update comment;
        return comment;
    }
    
    
    //Process exception email.
    public static void sendExceptionEmailUpdate(String fromAdd, Case mailCase) {
        System.debug('Email reply Exception check >>>>>1'+fromAdd);
        List<OrgWideEmailAddress> orgWideEmailList = new List<OrgWideEmailAddress>();
        //FLS check added-Venugopal
        if(OrgWideEmailAddress.SObjectType.getDescribe().isAccessible()){
            orgWideEmailList = [select id, address from OrgWideEmailAddress where displayname = :'Intel Premier Support QA' limit 1]; //EmailRelay change -Gangadhar
            System.debug('Email reply Exception check >>>>>2'+orgWideEmailList);
        }
        String orgWideEmailId = (orgWideEmailList!=null && orgWideEmailList.size()>0) ? orgWideEmailList[0].id : '';
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        EmailTemplate et = [SELECT Id,Body,HtmlValue,Subject FROM EmailTemplate WHERE DeveloperName ='Core_IPS_Case_Comment_Exception_Email'];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<String> sendTo = new List<String>();
        sendTo.add(fromAdd);  
        System.debug('Email reply Exception check >>>>>3'+orgWideEmailId);
        mail = Messaging.renderStoredEmailTemplate(et.Id, null , mailCase.Id==null ? null : mailCase.Id);
        
        if(String.isNotBlank(orgWideEmailId)) {
            mail.setOrgWideEmailAddressId(orgWideEmailId);       
        } else {
          mail.setReplyTo('ips_do_not_reply@intel.com'); 
          mail.setSenderDisplayName('IPS Do Not Reply'); 
        }
        mail.setToAddresses(sendTo);
        mail.setSaveAsActivity(false);
        mail.setUseSignature(false);
        mails.add(mail);
        
        Messaging.sendEmail(mails);
     }
     
     // handling sky high encryption
     /* public static String encryptCaseComment(String commentString){
        //if(1=1){}  
        List<Skyh_Class> lskyh= new List<Skyh_Class>();
        List<List<Skyh_Class>> allObjects = new List<List<Skyh_Class>>();
        lskyh.clear();
        lskyh.add( new Skyh_Class('Core_IPS_Rich_Comment__c', commentString));
        allObjects.add(new List<Skyh_Class>(lskyh));

        String finalJSON = '{\"Core_IPS_Case_Comments__c\": ' + JSON.serialize(allObjects) + '}';

        // Value:https://encapicrm.intelqa.shnpoc.net/encryption/2/encrypt
        String endpoint = Label.EAAS_EndPoint_URL2 ;
        //-- Encryption code
        HttpRequest req = new HttpRequest();
        //Value: EAASCertificate
        string certName = Label.EAASCertificate_Name;

        req.setBody(finalJSON);
        req.setHeader('Content-Type', 'application/json'); 
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        if (certName != null) {
            req.setClientCertificateName(certName);
        }
        // Create a new http object to send the request object 
        // A response object is generated as a result of the request   
        Http http = new Http(); 
        if(!test.isrunningtest()){
            HTTPResponse res = http.send(req);
            if(res.getStatus()=='OK'){
                return res.getBody();
            }else
                return 'Encryption Failed';
        }else{    
            return commentString;
        }    
    }
    */
    
    /*public class Skyh_class {
        public String property = '';
        public String value = '';
        public Skyh_class(String prop, String val) {
            property  = prop;
            value = val;
        }
    } */
}