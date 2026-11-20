@isTest
public class CRM_SetupAuditTrailMock implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('[{"Id":"1","Action":"Test Action 1","CreatedDate":"2023-01-01T00:00:00.000Z","CreatedBy":{"Name":"Test User"},"Section":"Apex Trigger","Display":"Test Display 1","DelegateUser":"Test Delegate User 1"},{"Id":"2","Action":"Test Action 2","CreatedDate":"2023-01-01T00:00:00.000Z","CreatedBy":{"Name":"Test User"},"Section":"Flows","Display":"Test Display 2","DelegateUser":"Test Delegate User 2"}]');
        res.setStatusCode(200);
        return res;
    }
}