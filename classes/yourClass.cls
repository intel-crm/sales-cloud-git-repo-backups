global class yourClass implements Site.UrlRewriter {
    global PageReference mapRequestUrl(PageReference
            yourFriendlyUrl){
            System.debug('UrlRewriterClass.mapRequestUrl: ' + yourFriendlyUrl);
             return null;
            }
    global PageReference[] generateUrlFor(PageReference[]
            yourSalesforceUrls){
             return null;
            }
}