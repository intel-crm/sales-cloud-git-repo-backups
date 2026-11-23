global with sharing class IPS_Agent_UpdateCaseStatus {

    global class Request {

        @InvocableVariable(required=true)
        global String caseNumber;

        @InvocableVariable(required=true)
        global String status;
    }

    global class Response {
        @InvocableVariable global Boolean success;
        @InvocableVariable global String message;
    }

    @InvocableMethod
    global static List<Response> execute(
        List<Request> requests
    ) {

        List<Response> results = new List<Response>();

        for(Request req : requests){

            Response res = new Response();

            try {

                IPS_Agent_CaseService.updateCaseStatus(
                    req.caseNumber,
                    req.status
                );

                res.success = true;
                res.message = 'Status updated';

            } catch(Exception ex){

                res.success = false;
                res.message = ex.getMessage();
            }

            results.add(res);
        }

        return results;
    }
}