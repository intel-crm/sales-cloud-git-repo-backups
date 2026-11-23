global with sharing class IPS_Agent_AddComment {

    global class Request {

        @InvocableVariable(required=true)
        global String caseNumber;

        @InvocableVariable(required=true)
        global String comment;
    }

    global class Response {
        @InvocableVariable global Boolean success;
        @InvocableVariable global String message;
    }

    @InvocableMethod
    global static List<Response> execute(List<Request> requests) {

        List<Response> results = new List<Response>();

        for(Request req : requests){

            Response res = new Response();

            try{

                IPS_Agent_CaseService.addComment(
                    req.caseNumber,
                    req.comment
                );

                res.success = true;
                res.message = 'Comment added';

            } catch(Exception ex){

                res.success = false;
                res.message = ex.getMessage();
            }

            results.add(res);
        }

        return results;
    }
}