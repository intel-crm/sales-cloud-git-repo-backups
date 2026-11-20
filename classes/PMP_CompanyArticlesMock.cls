public class PMP_CompanyArticlesMock implements HttpCalloutMock {
    
    public HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json'); 
        response.setStatusCode(200);
        if(request.getEndpoint().contains('/authorize')) {
            response.setBody('{"token_type":"Bearer","expires_in":2592000,"access_token":"access_tokene039ba2746b44"}');
        } else {
        response.setBody('{"data":[{"id":349312522,"hub_id":63774,"type":"docs","service":"uberflip","title":"Strategies","description":null,'+
                         '"seo_title":"Strategies","seo_description":null,"url":"https://www.insight.tech/","thumbnail_url":"https://content.cdntwrk.com/",'+
                         '"canonical_url":"https://www.insight.tech/","canonical_redirect":false,"mediaproxy_thumbnail_url":null,"avatar_url":null,'+
                         '"duration":null,"published":true,"hidden":false,"edited":true,"deleted":false,"content":{"published":"published","draft":null},'+
                         '"author":{"id":"123","first_name":"test","last_name":"author","full_name":"test author","username":"test@author.com",'+
                         '"email":"test@author.com","company":"test comp","bio":"bio","twitter_id":null,"avatar_url":null},"hide_publish_date":false,'+
                         '"external_created_at":"2017-06-21T13:25:37-0400","external_modified_at":"2020-08-13T10:35:49-0400","created_at":"2017-06-21T13:25:43-0400",'+
                         '"modified_at":"2020-08-13T10:49:42-0400","published_at":"2017-06-21T13:25:37-0400","stream":{"id":7405804,"title":"Abaco Systems",'+
                         '"ordinal":0,"featured":false}}],"meta":{"count":2,"limit":25,"total_pages":1}}'); 
        }
        return response;
    }
}