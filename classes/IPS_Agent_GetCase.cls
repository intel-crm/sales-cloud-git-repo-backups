global with sharing class IPS_Agent_GetCase {

    global class Request {
        @InvocableVariable(required=true)
        global String caseNumber;
    }

    global class Response {
        @InvocableVariable global Boolean success;
        @InvocableVariable global String message;
        @InvocableVariable global String caseNumber;
        @InvocableVariable global String subject;
        @InvocableVariable global String status;
        @InvocableVariable global String priority;
        @InvocableVariable global String description;
        @InvocableVariable global String productName;
        @InvocableVariable global String resolution;
        @InvocableVariable global Datetime createdDate;
        @InvocableVariable global Datetime closedDate;
        @InvocableVariable global String comments;
        @InvocableVariable global String issueDescription;
        @InvocableVariable global String closureComment;
        @InvocableVariable global String ownerName;
        @InvocableVariable global String ownerEmail;
        @InvocableVariable global String internalNote;
        @InvocableVariable global String problemStatement;
        @InvocableVariable global String knowledgeBaseLink;
        @InvocableVariable global String projectCase;      
    }

    @InvocableMethod
    global static List<Response> execute(
        List<Request> requests
    ) {

        List<Response> responses = new List<Response>();

        for(Request req : requests){

            Response res = new Response();

            try{

                Case c =
                    IPS_Agent_CaseSelector.getCaseByNumber(
                        req.caseNumber
                    );

                res.success = true;
                res.message = 'Success';
                res.caseNumber = c.CaseNumber;
                res.subject = c.Subject;
                res.status = c.Status;
                res.priority = c.Priority;
                res.description = c.Description;
                res.productName = c.Core_IPS_Product_name__c;
                res.resolution = c.Core_IPS_Resolution__c;
                res.CreatedDate = c.CreatedDate;
                res.ClosedDate = c.ClosedDate;
                res.issueDescription = c.Core_Issue_Description__c;
                res.Comments = c.Comments;
                res.closureComment = c.Core_Closure_Comment__c;
                res.ownerName = c.Core_IPS_Case_Owner_Name__c;
                res.ownerEmail = c.Core_IPS_Case_Owner_Email__c;
                res.internalNote = c.Core_IPS_Internal_Note__c;
                res.problemStatement = c.Core_IPS_Problem_Statement__c;
                res.knowledgeBaseLink = c.Core_IPS_Knowledge_Base_Link__c;
                res.projectCase = c.Core_IPS_Project_Case__c;      
            } catch(Exception ex){

                res.success = false;
                res.message = ex.getMessage();
            }

            responses.add(res);
        }

        return responses;
    }
}