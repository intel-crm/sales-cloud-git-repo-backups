global with sharing class IPS_Agent_GetCaseComments {

    global class Request {
        @InvocableVariable(required=true)
        global String caseNumber;
    }

    global class Response {

        @InvocableVariable global Boolean success;
        @InvocableVariable global String message;

        @InvocableVariable global String comment;
        @InvocableVariable global Datetime createdDate;
    }

    @InvocableMethod
    global static List<Response> execute(List<Request> requests) {

        List<Response> results = new List<Response>();

        for(Request req : requests){

            try {

                Case c =
                    IPS_Agent_CaseSelector.getCaseByNumber(
                        req.caseNumber
                    );

                for(Core_IPS_Case_Comments__c comment :
                    IPS_Agent_CaseSelector.getCaseComments(c.Id)){

                    Response res = new Response();

                    res.success = true;
                    res.message = 'Success';
                    res.comment = comment.Core_IPS_Comment__c;
                    res.createdDate = comment.CreatedDate;

                    results.add(res);
                }

            } catch(Exception ex){

                Response res = new Response();
                res.success = false;
                res.message = ex.getMessage();

                results.add(res);
            }
        }

        return results;
    }
}