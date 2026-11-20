/*********************************************************************************************************************
Apex Class Name  : PRM_MockEmptyHttpResponse 
Version          : 1.0
Created Date     : MAR 2020
Function         : Mock response class

Modification Log :
* Developer                 Date                    Description
* --------------------------------------------------------------------------------------------------------------------
* Prasant Sahu              02/03/2020              Mock response class

*********************************************************************************************************************/
public class PRM_MockEmptyHttpResponse implements HttpCalloutMock {
	    // Implement this interface method
    public HTTPResponse respond(HTTPRequest request) {
        // Create a fake response         
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setbody('');
        res.setStatuscode(200);
        return res;
    }
}