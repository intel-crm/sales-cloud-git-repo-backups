/************************************************
* Name : IPS_APIGEE_Case_Backend_System 
* Author : Karthik Bandla
* Date Created : 21/06/2021
* Description : This class is called from IPS_APIGEE_Case_Queueable class whenever a case is created or updated with relevant changes inorder to sent details to JIRA,HSD,RTC.
* Test Class : 
************************************************/
public without sharing class IPS_APIGEE_Case_Backend_System implements System.Queueable, Database.AllowsCallouts{ // 'without sharing' added by Tushar
    
    set<Id> caseIds= new set<Id>();
    
    public IPS_APIGEE_Case_Backend_System(set<Id> ids){
        if(ids!=null)
            caseIds= ids ;
    } 
    
    public String profileName;
    public void execute(System.QueueableContext ctx) {
        string xmlbody;
        final string endPointUrl1;
        final string endPointUrl2;
        final string endPointUrl3;
        string strDetails;
        
        List<Case> CaseToProcess;
        
        Id profileId= userinfo.getProfileId();
        profileName=[Select Id,Name from Profile where Id=:profileId].Name;
        String userName = UserInfo.getName();
        
        //TWC745-6310-Implement Privileged Access Management (PAM)-custom setting to Named credential change -begin
        //endPointUrl1 = Core_IPS_System_Credentails_Apigee__c.getInstance('Core_IPS_Case_Promote').Core_IPS_EndPointURL__c;
        //endPointUrl2 = Core_IPS_System_Credentails_Apigee__c.getInstance('Core_IPS_Case_DePromote').Core_IPS_EndPointURL__c;
        //endPointUrl3 = Core_IPS_System_Credentails_Apigee__c.getInstance('Core_IPS_Case_FieldUpdate').Core_IPS_EndPointURL__c;
		endPointUrl1= 'callout:Core_IPS_Case_Create_Update_Comment_Attachment_Promote_Depromote'+'?action=promote'; 
		endPointUrl2= 'callout:Core_IPS_Case_Create_Update_Comment_Attachment_Promote_Depromote'+'?action=depromote';
		endPointUrl3= 'callout:Core_IPS_Case_Create_Update_Comment_Attachment_Promote_Depromote'+'?action=casefieldupdate'; //TWC745-6310- End
		
        
        if(Case.SObjectType.getDescribe().isAccessible()){
        CaseToProcess =[SELECT Id,CaseNumber,Status,Core_IPS_Backend_Previous_Status__c,Core_IPS_Backend_ID__c,Core_Sub_Status__c,Core_IPS_Backend_System__c,Core_IPS_GEC_Status__c,Core_Promote_Status__c,
                        Core_IPS_Backend_System__r.Core_IPS_Backend_Connection_String__c,Core_IPS_Backend_System__r.Core_IPS_Deactivated__c,Core_IPS_BK_Flds_UpdatedAt__c,Core_IPS_BK_Flds_UpdatedAt_PreVal__c
                        FROM Case where id IN:caseIds];
        }
        if(CaseToProcess!=null)
        {
            for(Case cs :CaseToProcess ){
                try{
                    
                    //Case Promote
                    if(((profileName !='Integration' &&  profileName !='IPS Data Migration')||(userName.CONTAINS('ips.file.integrationuser'))) && 
                       cs.Core_IPS_Backend_ID__c == null && cs.Core_IPS_Backend_System__c !=null && cs.Core_Promote_Status__c == 'In Progress' && 
                       cs.Status != 'Closed' && (cs.Core_IPS_GEC_Status__c == null || cs.Core_IPS_GEC_Status__c == 'Approved' || cs.Core_IPS_GEC_Status__c == 'Approved with Guardrails'))
                    {
                    	//string promoteIntegrationName = Core_IPS_System_Credentails_Apigee__c.getInstance('Core_IPS_Case_Promote').Name; 
                        //Generating access token
                    	//string accesstoken1 = Core_IPS_APIGEE_Utility.generateAccessToken1(promoteIntegrationName);
                        //Preparing XML body
                        xmlbody=generateCasepromote(cs.Id,cs.CaseNumber,cs.Core_IPS_Backend_ID__c);
                        //Sending HttpRequest
                    	sendXMLRequest(xmlbody,endPointUrl1); //TWC745-6310-Implement Privileged Access Management (PAM)-custom setting to Named credential change
                    }
                
          
                    //Case Depromote      
                    else if(cs.Core_IPS_Backend_Previous_Status__c.CONTAINS('disassociate') && ((profileName !='Integration' &&  profileName !='IPS Data Migration') || (userName.CONTAINS('ips.file.integrationuser'))))
                    {
                    	//string depromoteIntegrationName = Core_IPS_System_Credentails_Apigee__c.getInstance('Core_IPS_Case_DePromote').Name;
                        //Generating access token
                    	//string accesstoken2 = Core_IPS_APIGEE_Utility.generateAccessToken1(depromoteIntegrationName);                
                        //Preparing XML body
                        xmlbody=generateCaseDepromote(cs.Id,cs.CaseNumber,cs.Core_IPS_Backend_Previous_Status__c);
                        //Sending HttpRequest
                    	sendXMLRequest(xmlbody,endPointUrl2);//TWC745-6310-Implement Privileged Access Management (PAM)-custom setting to Named credential change
                        
                    }
                    
                    //Case field update
                    else if((cs.Core_IPS_Backend_System__c !=null && cs.Core_IPS_Backend_ID__c != null && cs.Core_IPS_Backend_System__r.Core_IPS_Backend_Connection_String__c != null &&
                             !(cs.Core_IPS_Backend_System__r.Core_IPS_Deactivated__c) && (cs.Core_IPS_BK_Flds_UpdatedAt__c != cs.Core_IPS_BK_Flds_UpdatedAt_PreVal__c) && cs.Status != 'Closed' && profileName !='Integration' &&  profileName !='IPS Data Migration'))
                    {
                    	//string fieldupdateIntegrationName = Core_IPS_System_Credentails_Apigee__c.getInstance('Core_IPS_Case_FieldUpdate').Name;
                        //Generating access token
                    	//string accesstoken3 = Core_IPS_APIGEE_Utility.generateAccessToken1(fieldupdateIntegrationName);
                        //Preparing XML body
                        xmlbody=generateCaseFieldUpdate(cs.Id,cs.CaseNumber,cs.Core_IPS_Backend_ID__c); 
                        //Sending HttpRequest
                    	sendXMLRequest(xmlbody,endPointUrl3); //TWC745-6310-Implement Privileged Access Management (PAM)-custom setting to Named credential change 
                    }
                    
                }
                catch(System.CalloutException ex){
                    strDetails += '\n A callout Exception Occurred While sending request \n';
                    Core_Log_Entry.logEntryWithException('SFDC','IPS',null,'warn','IPS JIRA,HSD,RTC Integration issue',strDetails,null,'Case',null,ex);
                    
                }
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
    
/***************************************************************
* Description : Helper Method to Generate XML for Case promote
* Author : Karthik Bandla
***************************************************************/
    //generating case xml vary with respect to case fields for (depromote backend outmsg,case status update outmsg)
    private static String generateCasepromote(String recordId,String CaseNumber,String backendId ){
        Id OrgId = UserInfo.getOrganizationId();
        String xml='<OrganizationId>'+OrgId+'</OrganizationId>';
        xml+='<ActionId>04kq00000008Oq2AAE</ActionId>';
        xml+='<SessionId xsi:nil="true"/>';
        xml+='<EnterpriseUrl>https://intel--CRMSB14.cs21.my.salesforce.com/services/Soap/c/34.0/00Dq0000000BTwP</EnterpriseUrl>';
        xml+='<PartnerUrl>https://intel--CRMSB14.cs21.my.salesforce.com/services/Soap/u/34.0/00Dq0000000BTwP</PartnerUrl>';
        xml+='<Notification>';
        xml+='<Id>04lq000000518PkAAI</Id>';
        xml+='<sObject xsi:type="sf:Case" xmlns:sf="urn:sobject.enterprise.soap.sforce.com">';              
        xml+='<sf:Id>'+recordId+'</sf:Id>';
        xml+='<sf:CaseNumber>'+CaseNumber+'</sf:CaseNumber>';
        xml+='<sf:Core_IPS_Backend_ID__c>'+backendId+'</sf:Core_IPS_Backend_ID__c>';
        xml+='</sObject>';
        xml+='</Notification>';
        return generateXml(xml);
    }
    
/***************************************************************
* Description : Helper Method to Generate XML for Case Depromote
* Author : Karthik Bandla
***************************************************************/
    //generating case xml vary with respect to case fields for (depromote backend outmsg,case status update outmsg)
    private static String generateCaseDepromote(String recordId,String CaseNumber,String previousState ){
        Id OrgId = UserInfo.getOrganizationId();
        String xml='<OrganizationId>'+OrgId+'</OrganizationId>';
        xml+='<ActionId>04kq00000008Oq2AAE</ActionId>';
        xml+='<SessionId xsi:nil="true"/>';
        xml+='<EnterpriseUrl>https://intel--CRMSB14.cs21.my.salesforce.com/services/Soap/c/34.0/00Dq0000000BTwP</EnterpriseUrl>';
        xml+='<PartnerUrl>https://intel--CRMSB14.cs21.my.salesforce.com/services/Soap/u/34.0/00Dq0000000BTwP</PartnerUrl>';
        xml+='<Notification>';
        xml+='<Id>04lq000000518PkAAI</Id>';
        xml+='<sObject xsi:type="sf:Case" xmlns:sf="urn:sobject.enterprise.soap.sforce.com">';              
        xml+='<sf:Id>'+recordId+'</sf:Id>';
        xml+='<sf:CaseNumber>'+CaseNumber+'</sf:CaseNumber>';
        xml+='<sf:Core_IPS_Backend_Previous_Status__c>'+previousState+'</sf:Core_IPS_Backend_Previous_Status__c>';
        xml+='</sObject>';
        xml+='</Notification>';
        return generateXml(xml);
    }
    
/**************************************************************
* Description : Helper Method to Generate XML for Field Update
* Author : Karthik Bandla
**************************************************************/
    //generating case xml vary with respect to case fields for (depromote backend outmsg,case status update outmsg)
    private static String generateCaseFieldUpdate(String recordId,String CaseNumber,String backendId ){
        Id OrgId = UserInfo.getOrganizationId();
        String xml='<OrganizationId>'+orgId+'</OrganizationId>';
        xml+='<ActionId>04kq00000008Oq2AAE</ActionId>';
        xml+='<SessionId xsi:nil="true"/>';
        xml+='<EnterpriseUrl>https://intel--CRMSB14.cs21.my.salesforce.com/services/Soap/c/34.0/00Dq0000000BTwP</EnterpriseUrl>';
        xml+='<PartnerUrl>https://intel--CRMSB14.cs21.my.salesforce.com/services/Soap/u/34.0/00Dq0000000BTwP</PartnerUrl>';
        xml+='<Notification>';
        xml+='<Id>04lq000000518PkAAI</Id>';
        xml+='<sObject xsi:type="sf:Case" xmlns:sf="urn:sobject.enterprise.soap.sforce.com">';
        xml+='<sf:Id>'+recordId+'</sf:Id>';
        xml+='<sf:CaseNumber>'+CaseNumber+'</sf:CaseNumber>';
        xml+='<sf:Core_IPS_Backend_ID__c>'+backendId+'</sf:Core_IPS_Backend_ID__c>';
        xml+='</sObject>';
        xml+='</Notification>';
        return generateXml(xml);
    }
    
/*************************************************
* Description : Helper Method to Generate XML
* Author : Karthik Bandla
**************************************************/
    
    private static void sendXMLRequest(String body,String endPointUrl){
        //added By Hassan for Authorization issue Fix.
        String ipsAuthorization = System.Label.IPS_Authorization; 
        try{
            //Sending XML request
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endPointUrl);
            req.setMethod('POST');
            req.setHeader('Content-Type','application/xml');
            //req.setHeader(ipsAuthorization, 'Bearer ' + accesstoken);          
            req.setBody(body);
            HTTPResponse response =  new Http().send(req);
            // If error occured creating log 
            if(response.getStatusCode()!=200){
                String strDetails= 'Call out Service Name : '+'IPS_APIGEE_Case_Backend_System'+'\n Trace Information : '+'STATUS:'+ response.getStatus() + '\nSTATUS_CODE:' + response.getStatusCode() + '\n Message:' + response.toString()+ '\n Case Ids ';
                Core_Log_Entry.logEntryWithDetails('SFDC','IPS',null,'error','IPS JIRA,HSD,RTC Integration issue',strDetails,null,'Case',null);
            }
        }
        catch(System.CalloutException ex){            
            String strDetails ='Exception Occured,Unable to connect to APIGEE';
            Core_Log_Entry.logEntryWithDetails('SFDC','IPS',null,'warn','IPS JIRA,HSD,RTC Integration issue',strDetails,null,'Case',null);
        }
    }
    
}