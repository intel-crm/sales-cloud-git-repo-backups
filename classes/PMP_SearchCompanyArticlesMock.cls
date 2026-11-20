@isTest
global class PMP_SearchCompanyArticlesMock implements HttpCalloutMock {
	global HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('<rss xmlns:media="http://search.yahoo.com/mrss/" xmlns:dc="http://purl.org/dc/elements/1.1/" version="2.0"> <channel> <item><title>Digital Experiments Prove Smart Factory Solutions</title><link>...</link><pubDate>Tue, 28 May 2019 16:54:00 -0400</pubDate></item><item><title>Digital Experiments Prove Smart Factory Solutions</title><link>...</link><pubDate>Tue, 28 May 2019 16:54:00 -0400</pubDate></item><item><title>Digital Experiments Prove Smart Factory Solutions</title><link>...</link><pubDate>Tue, 28 May 2019 16:54:00 -0400</pubDate></item><item><title>Digital Experiments Prove Smart Factory Solutions</title><link>...</link><pubDate>Tue, 28 May 2019 16:54:00 -0400</pubDate></item><item><title>Digital Experiments Prove Smart Factory Solutions</title><link>...</link><pubDate>Tue, 28 May 2019 16:54:00 -0400</pubDate></item><item><title>Digital Experiments Prove Smart Factory Solutions</title><link>...</link><pubDate>Tue, 28 May 2019 16:54:00 -0400</pubDate></item> </channel> </rss> ');
        response.setStatusCode(200);
        return response;
    }
}