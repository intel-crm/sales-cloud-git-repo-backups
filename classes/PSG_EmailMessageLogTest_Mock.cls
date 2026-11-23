@isTest
global class PSG_EmailMessageLogTest_Mock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req){
        HttpResponse res = new HttpResponse();
        String endPoint = req.getEndpoint();
        if(endPoint.contains('/services/data/v47.0/tooling/query/')){
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"size":1,"totalSize":1,"done":true,"queryLocator":null,"entityTypeName":"WorkflowAlert","records":[{"attributes":{"type":"WorkflowAlert","url":"/services/data/v47.0/tooling/sobjects/WorkflowAlert/01W2D0000008jISUAY"},"Id":"01W2D0000008jISUAY","SenderType":"OrgWideEmailAddress","TemplateId":"2343413241324"}]}');
            res.setStatusCode(200);
            return res;
        }
        EmailTemplate validEmailTemplate = new EmailTemplate();
        validEmailTemplate.isActive = true;
        validEmailTemplate.Name = 'name';
        validEmailTemplate.DeveloperName = 'unique_name_added';
        validEmailTemplate.TemplateType = 'text';
        validEmailTemplate.FolderId = UserInfo.getUserId();
        insert validEmailTemplate;
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"attributes":{"type":"WorkflowAlert","url":"/services/data/v41.0/tooling/sobjects/WorkflowAlert/01W2D0000008jISUAY"},"Id":"01W2D0000008jISUAY","TemplateId":"'+validEmailTemplate.Id+'","CcEmails":null,"Description":"EmailTesting","DeveloperName":"test_email_alert","SenderType":"OrgWideEmailAddress","ManageableState":"unmanaged","NamespacePrefix":null,"CreatedDate":"2021-06-29T04:31:55.000+0000","CreatedById":"0052D000005IA6PQAW","LastModifiedDate":"2021-06-29T04:31:55.000+0000","LastModifiedById":"0052D000005IA6PQAW","EntityDefinitionId":"01I2D000000NKZl","Metadata":{"ccEmails":["cmquotes@intel.com"],"description":"Emailtesting","protected":false,"recipients":[{"field":null,"recipient":"239873236@intel.com.crm","type_z":"user"},{"field":"core_cpq_requestor_nm__c","recipient":null,"type_z":"userLookup"},{"field":null,"recipient":null,"type":"owner"}],"senderAddress":"wsm-postmaster@intel.com","senderType":"OrgWideEmailAddress","template":"PSG_Email_Templates/test_email_alert","urls":null},"FullName":"sOBject.test_email_alert"}');
        res.setStatusCode(200);
        return res;
    }
}