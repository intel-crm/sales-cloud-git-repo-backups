@isTest
public class Tooling_UnusedFieldsMockClass implements HttpCalloutMock{
    
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"records": [{"RefMetadataComponentId": "001xx0000012345", "RefMetadataComponentName": "Field1", "CreatedBy.Name": "User1", "MetadataComponentType": "CustomField", "EntityDefinition": {"DeveloperName": "Object1"}}]}');
        res.setStatusCode(200);
        return res;
    }

}