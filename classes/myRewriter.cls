global with sharing class myRewriter implements Site.UrlRewriter {
   public PageReference[] generateUrlFor(PageReference[] salesforceUrls) {
        // Implement logic to map Salesforce URLs to user-friendly URLs
        // For example, /IPS/s/001D000000Q0PcN could be mapped to /IPS/blog-entry-1
        System.debug('Minhaj salesforceURLs ' + salesforceUrls );
		System.debug('Minhaj Site.getCurrentSiteUrl' + ApexPages.currentPage().getUrl());
        // Return a list of user-friendly URLs 
        return salesforceUrls;
    }
    public PageReference mapRequestUrl(PageReference userFriendlyUrl) {
        // Implement logic to map user-friendly URLs to Salesforce URLs
        // For example, /IPS/blog-entry-1 could be mapped to /IPS/s/001D000000Q0PcN
        // Check if the user-friendly URL contains '/IPS/' and does not contain '/IPS/s'
        System.debug('Minhaj ' + userFriendlyUrl);
        if (userFriendlyUrl.getUrl().contains('/IPS/') && !userFriendlyUrl.getUrl().contains('/IPS/s')) {
            System.debug('Minhaj inside if' + userFriendlyUrl.getUrl() );
            // Redirect the user to '/IPS/s' relative path
            return new PageReference('/IPS/s');
        }
        // Return the Salesforce URL
        return userFriendlyUrl;
    }
}