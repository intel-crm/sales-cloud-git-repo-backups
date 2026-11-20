/****************************************************************************************************
Apex Class Name : core_S2S_CaseExternalFeedController
Version         : 1.0 
Test Class      : core_S2S_CaseExternalFeedControllerTest
Created Date    : 2022-09-19
Function        : Apex class used to query external Case object (Case__x) and make REST HTTP requests to GET and POST feed elements as an external user.
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Bishal Singh               2024-07-19                Modified
*****************************************************************************************************/
public without sharing class core_S2S_CaseExternalFeedController {
    
    public static Id contactExternalId = null;
	
    /************************************************************************************************************
    *Method Name : getExternalID
    *Created Date: 2024-07-19
    *Modified By : Bishal Singh
    *Description : Method to get the Service Cloud ExternalId from Case__x using Sales Cloud record Id.
    ************************************************************************************************************/
    @AuraEnabled(cacheable=false)
    public static Id getExternalID(Id recordId) {
        return ([SELECT ExternalId FROM Case__x WHERE Id = :recordId]?.ExternalId);
    }
    
    /************************************************************************************************************
    *Method Name : getContactID
    *Created Date: 2024-07-19
    *Modified By : Bishal Singh
    *Description : Method to get the Service Cloud Contact ExternalId from Contact__x using current logged in user email.
    ************************************************************************************************************/
    public static Id getContactID() {
        return ([SELECT Id,ExternalId FROM Contact__x WHERE Email__c =:UserInfo.getUserEmail()]?.ExternalId);
    }
    
    /************************************************************************************************************
    *Method Name : getFeedElements
    *Created Date: 2024-07-19
    *Modified By : Bishal Singh
    *Description : Method to get the feed elements from the service cloud based on Case__x recordId.
    ************************************************************************************************************/
    @AuraEnabled(cacheable=false)
    public static Map<String, Object> getFeedElements(Id recordId) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Service_Cloud_Chatter_API/feeds/record/' + recordId + '/feed-elements');
        req.setMethod('GET');
        Http http = new Http();
        HTTPResponse res = http.send(req);
        return (Map<String, Object>) JSON.deserializeUntyped(res.getBody()); 
    }
    
    /**
	* Takes a Service Cloud record Id, a String for the body of the post,
	* and a String for the visibility of the post.
	* Makes an HTTPRequest callout to Service Cloud Chatter API to 
	* makes a new post based on the passed in data
	* !!All rich text formatting currently gets removed!!
	*  req.setBody('{ ' +
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
	*
	*/
    
    /************************************************************************************************************
    * Method Name : postToChatter
    * Created Date: 2024-07-19
    * Modified By : Bishal Singh
    * Description : Method to post feed on service cloud Case__x using integration user on behalf of users.
    *               It can post either a feed item or a comment based on the parameters provided.
    ************************************************************************************************************/
    @AuraEnabled(cacheable=false)
    public static Integer postToChatter(Id recordId, String postText, Boolean isComment) {
        HttpRequest req = new HttpRequest();
        String endpoint = 'callout:Service_Cloud_Chatter_API/feed-elements';
        contactExternalId = getContactID();        
        if (isComment) {
            endpoint += '/' + recordId + '/capabilities/comments/items';
        }
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json;charset=UTF-8');
        if(contactExternalId == null){
            return 0;
        }
        req.setBody(constructRequestBody(recordId, postText, isComment));
        Http http = new Http();
        HTTPResponse res = http.send(req);
        return (res.getStatusCode());
    }
    
    /************************************************************************************************************
    * Method Name : constructRequestBody
    * Created Date: 2024-07-19
    * Modified By : Bishal Singh
    * Description : Method to construt request body based from where the post is getting posted.
    ************************************************************************************************************/
    public static String constructRequestBody(Id recordId, String postText, Boolean isComment) {
        String messageSegments = 
            '   "body" : {' +
            '       "messageSegments" : [' ;
        messageSegments += getOwnerDetail(recordId);
        messageSegments += 
            '          { '+
            '            "markupType" : "Paragraph", ' +
            '            "type" : "MarkupBegin" ' +
            '          },{ ' +
            '             "type" : "text",' +
            '            "text" : "On behalf of "' +
            '          },{' +
            '             "type" : "EntityLink",' +
            '            "EntityId" : "' + contactExternalId + '"' +
            '          },{' +
            '            "markupType" : "Paragraph", ' +
            '            "type" : "MarkupEnd" ' +
            '          },{' +
            '            "markupType" : "Paragraph", ' +
            '            "type" : "MarkupBegin" ' +
            '          },{ ' +
            '             "type" : "text",' + 
            '             "text" : "&nbsp;\\n"' +
            '         },{' +
            '            "markupType" : "Paragraph", ' +
            '            "type" : "MarkupEnd" ' +
            '          },' + postText + ']' +
            '    }';
        if (isComment) {
            return '{' + messageSegments + '}';
        } else {
            return '{' +
                messageSegments + ',' +
                '   "feedElementType" : "FeedItem",' +
                '   "visibility" : "InternalUsers", ' +
                '   "subjectId" : "' + recordId + '"' +
                '}';
        }
    }

    /************************************************************************************************************
    *Method Name : getLabel
    *Created Date: 2024-07-19
    *Author      : Bishal Singh
    *Description : Method to get label from ICS Labels.
    ************************************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static List<core_S2S_ICS_Label__c> getLabel() {
        return [SELECT Name,Value__c FROM core_S2S_ICS_Label__c];
    }
    
    /************************************************************************************************************
    *Method Name : searchUsers
    *Created Date: 2024-08-14
    *Author      : Bishal Singh
    *Description : Method to searh mention user in chatter.
    ************************************************************************************************************/
    @AuraEnabled(cacheable=false)
    public static List<User__x> searchUsers(String searchTerm) {
        return [SELECT Id, Name__c, Email__c,ExternalId FROM User__x WHERE Name__c LIKE :('%' + searchTerm + '%') OR Email__c LIKE :('%' + searchTerm + '%') WITH SECURITY_ENFORCED LIMIT 10 ];
    }
    
    /************************************************************************************************************
    *Method Name : getOwnerDetail
    *Created Date: 2024-07-19
    *Author      : Bishal Singh
    *Description : Method to get label from ICS Labels.
    ************************************************************************************************************/
    public static String getOwnerDetail(String recordId) {
        List<Case__x> caseList = [SELECT Status__c, OwnerId__c FROM Case__x WHERE Id = :recordId];
        if (caseList.isEmpty()) {
            return '';
        }
        Case__x caseDetail = caseList[0];
        Id ownerId = caseDetail.OwnerId__c;
        String objType = String.valueOf(ownerId.getSObjectType());
        if (caseDetail.Status__c != 'New' && objType != 'Group') {
            String mentionSegment = 
                '  { ' +
                '    "type": "Mention", ' +
                '    "id": "' + caseDetail.OwnerId__c + '"' +
                '  },';
            return mentionSegment;
        }
        return '';
    }
}