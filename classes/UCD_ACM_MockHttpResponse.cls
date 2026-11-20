@isTest
global class UCD_ACM_MockHttpResponse implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest request) {
        String endPoint = 'https://apim.workato.com/oauth2/token';
        String accessToken = '';
        String authorizationToken ='';
        HttpResponse response = new HttpResponse();
        
        if(request.getEndpoint() == 'https://apim.workato.com/oauth2/token'){
            response.setBody('{"access_token": "' + accessToken + '","token_type":"bearer","expires_in":3600}');
            
        }else{
            response.setHeader('Content-Type', 'application/json');
            response.setHeader('Authorization', authorizationToken); 
            response.setHeader('API_Token', 'b8ceae45b0bf0279493806d734e79f5a38fb3044273e13b3fa3d4496d64039bb');
            response.setBody('{"list_items":[{"uri":"entities/0ESSMWe","relevance":"0.8500000000000001","Record_Label":"1000046357 &#124; Spain National Intelligence Center &#124;","BusinessOrganizationName":[{"BusinessOrganizationNm":"Spain National Intelligence Center","BusinessNameTypeCd":"SIMPLIFIED","LanguageCode":"English"}],"CustomerAggregationTypeCd":"Unified Intermediate Customer","WebsiteURL":"https://www.cni.es/","Addresses":"","CustomerProcessEngagement":"Direct Price Exception","AggregateParent":[{"label":"1000006111 &#124; Spain Government &#124;","relationshipLabel":", Unified Global Customer"}]},{"uri":"entities/13UK5RMK","relevance":"0.6","Record_Label":"1000046358 &#124; Spain National Intelligence Center &#124; Spain","BusinessOrganizationName":[{"BusinessOrganizationNm":"Spain National Intelligence Center","BusinessNameTypeCd":"SIMPLIFIED","LanguageCode":"English"}],"CustomerAggregationTypeCd":"Unified Country Customer","WebsiteURL":"","Addresses":"Spain","CustomerProcessEngagement":"Direct Price Exception","AggregateParent":[{"label":"1000046357 &#124; Spain National Intelligence Center &#124;","relationshipLabel":", Unified Intermediate Customer"}]}],"PotentialMatches":"2"}');
        }
        response.setStatusCode(200);
        return response; 
    }
}