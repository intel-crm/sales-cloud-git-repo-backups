global with sharing class IPS_Agent_CloseCase {

    global class Request {

        @InvocableVariable(required=true)
        global String caseNumber;

        @InvocableVariable
        global String resolution;

        @InvocableVariable
        global String closureComment;
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

            try {

                IPS_Agent_CaseService.closeCase(
                    req.caseNumber,
                    req.resolution,
                    req.closureComment
                );

                res.success = true;
                res.message = 'Case closed';

            } catch(Exception ex){

                res.success = false;
                res.message = ex.getMessage();
            }

            results.add(res);
        }

        return results;
    }
}