/*********************************************
* Name : IPS_APIGEE_Backend_CaseComments 
* Author : Karthik Bandla
* Date Created : 21/06/2021
* Description : This class is called from IPS_APIGEE_Case_Comments_Queueable class whenever a caseComment is created or updated with relevant changes inorder to sent details to JIRA,HSD,RTC.
* Test Class : 
*   
************************************************/

public without sharing class IPS_APIGEE_Backend_CaseComments implements System.Queueable, Database.AllowsCallouts{
    set<Id> caseCommentIds= new set<Id>();
    
    public IPS_APIGEE_Backend_CaseComments(set<Id> ids){
        caseCommentIds= ids ;
    } 
    
    public void execute(System.QueueableContext ctx) {
        string xmlbody;
        final string endPointUrl;
        string strDetails;     
        List<Core_IPS_Case_Comments__c> CaseCommentsToProcess;
        //TWC745-6310-Implement Privileged Access Management (PAM)-custom setting to Named credential change
       
        
        endPointUrl= 'callout:Core_IPS_Case_Create_Update_Comment_Attachment_Promote_Depromote'+'?action=attachmentupdate';
        CaseCommentsToProcess =[SELECT Id,Core_IPS_Case__c FROM Core_IPS_Case_Comments__c where id IN:caseCommentIds];
        
        for(Core_IPS_Case_Comments__c cc :CaseCommentsToProcess ){
            try{
                //TWC745-6310-Implement Privileged Access Management (PAM)-custom setting to Named credential change 
                //Preparing XML body
                xmlbody=generateCaseComments(cc.Id,cc.Core_IPS_Case__c);
                //Sending HttpRequest
                sendXMLRequest(xmlbody,endPointUrl); 
            }
            catch(System.CalloutException ex){
                strDetails += '\n A callout Exception Occurred While sending request \n';
                Core_Log_Entry.logEntryWithException('SFDC','IPS',null,'warn','IPS JIRA,HSD,RTC Integration issue',strDetails,null,'CaseComment',null,ex);
            }
        }
        
    }
    
/*************************************************
* Description : Helper Method to Generate XML Body
* Author : Karthik Bandla
**************************************************/
    private static string generateXml(String body){
        String xml='<?xml version="1.0" encoding="UTF-8"?>';
        xml+='<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">';
        xml+='<soapenv:Body>';
        xml+='<notifications xmlns="http://soap.sforce.com/2005/09/outbound">';
        xml+=body;
        xml+='</notifications>';
        xml+=' </soapenv:Body>';
        xml+='</soapenv:Envelope>';
        return xml;
    } 
    
    
/*************************************************
* Description : Helper Method to Generate XML body
* Author : Karthik Bandla
**************************************************/
    private static String generateCaseComments(String recordId,String cs){
        Id OrgId = UserInfo.getOrganizationId();
        String xml='<OrganizationId>'+orgId+'</OrganizationId>';
        xml+='<ActionId>04kq00000008Oq2AAE</ActionId>';
        xml+='<SessionId xsi:nil="true"/>';
        xml+='<EnterpriseUrl>https://intel--CRMSB14.cs21.my.salesforce.com/services/Soap/c/34.0/00Dq0000000BTwP</EnterpriseUrl>';
        xml+='<PartnerUrl>https://intel--CRMSB14.cs21.my.salesforce.com/services/Soap/u/34.0/00Dq0000000BTwP</PartnerUrl>';
        xml+='<Notification>';
        xml+='<Id>04lq000000518PkAAI</Id>';
        xml+='<sObject xsi:type="sf:Core_IPS_Case_Comments__c" xmlns:sf="urn:sobject.enterprise.soap.sforce.com">'; 
        xml+='<sf:Id>'+recordId+'</sf:Id>';
        xml+='<sf:Core_IPS_Case__c>'+cs+'</sf:Core_IPS_Case__c>';
        xml+='</sObject>';
        xml+='</Notification>';
        return generateXml(xml);
    }
    
/**************************************************
* Description : Helper method to Send XMl request when cases are created or updated with relevant changes.
*               We are Making a call to Apigee for token generation.
*               And after Token availability , making one request to APIGEE to post JIRA,HSD,RTC integrations with XML we have. 
* Author : Karthik Bandla
***************************************************/
    private static void sendXMLRequest(String body,string endPointUrl){//TWC745-6310-Implement Privileged Access Management (PAM)-custom setting to Named credential change
        //added By Hassan for Authorization issue Fix.
        String ipsAuthorization = System.Label.IPS_Authorization;           
        try{
            
            //Sending XML request
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endPointUrl);
            req.setMethod('POST');
            req.setHeader('Content-Type','application/xml');
            
            req.setBody(body);
            HTTPResponse response =  new Http().send(req);
            
            // If error occured creating log 
            if(response.getStatusCode()!=200){
                String strDetails= 'Call out Service Name : '+'IPS_APIGEE_Backend_CaseComments'+'\n Trace Information : '+'STATUS:'+ response.getStatus() + '\nSTATUS_CODE:' + response.getStatusCode() + '\n Message:' + response.toString()+ '\n CaseComment Ids ';
                Core_Log_Entry.logEntryWithDetails('SFDC','IPS',null,'error','IPS JIRA,HSD,RTC Integration issue',strDetails,null,'CaseComment',null);
            }
        }
        catch(System.CalloutException ex){
            
            String strDetails ='Exception Occured,Unable to connect to APIGEE';
            Core_Log_Entry.logEntryWithDetails('SFDC','IPS',null,'warn','IPS JIRA,HSD,RTC Integration issue',strDetails,null,'CaseComment',null);
        }
    }
    
}