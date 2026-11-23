/**
* Apex class used to query external Case object (Case__x) and make REST HTTP requests
* to GET and POST feed elements as an external user.
* 
*/
public with sharing class CaseChatterFeed2 {
    
    
    /**
	* Takes a Sales Cloud record Id and returns the corresponding
	* Service Cloud ExternalId from Case__x using an SOQL query.  
	*/
    @AuraEnabled(cacheable=true)
    public static Id getExternalID(Id recordId) {
        Case__x cf;
        cf = [
            select ExternalId
            from Case__x
            where Id = :recordId];
        return cf.ExternalId;
    }
    
    /**
	* Takes a Service Cloud record Id and returns a Map
	* Makes an HTTPRequest callout to the Service Cloud Chatter API
	* and converts the JSON into a Map representing a feed element object
	* !!Currently limited to the 25 most recent elements!!
	* !!All rich text formatting currently gets removed!!
	*/
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getFeedElements(Id recordId) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Service_Cloud_Chatter_API/feeds/record/' + recordId + '/feed-elements');
        req.setMethod('GET');
        Http http = new Http();
        HTTPResponse res = http.send(req);
        System.debug('### ' + res.getBody());
        String jsonString = res.getBody();
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
        return m; 
    }
    
    /**
	* Takes a Service Cloud record Id, a String for the body of the post,
	* and a String for the visibility of the post.
	* Makes an HTTPRequest callout to Service Cloud Chatter API to 
	* makes a new post based on the passed in data
	* !!All rich text formatting currently gets removed!!
	*/
    @AuraEnabled(cacheable=true)
    public static void postToFeed(Id recordId, String postText, String vis) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Service_Cloud_Chatter_API/feed-elements');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json;charset=UTF-8');
        req.setBody('{ ' +
                    '   "body" : {' +
                    '      "messageSegments" : [' +
                    '         {' +
                    '        	 "type" : "Text",' +
                    '            "text" : "' + postText + '"' +          
                    '         }]' +
                    '       },' +
                    '   "feedElementType" : "FeedItem",' +
                    '   "visibility" : "' + vis +'", ' +
                    '   "subjectId" : "' + recordId + '"' +
                    '}');
        System.debug('### Request body: ' + req.getBody());
        Http http = new Http();
        HTTPResponse res = http.send(req);
        System.debug('### Response body: ' + res.getBody());
        String jsonString = res.getBody();
    }     
}