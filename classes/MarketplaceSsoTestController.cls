public with sharing class MarketplaceSsoTestController {
    public MarketplaceSsoTestController() {
    }

    public String getSSOUrl() {
      String communityUrl = 'https://intel--crmdevipa.sandbox.my.site.com/imp';
      String startUrl = '/s';
      Auth.AuthConfiguration authConfig = new Auth.AuthConfiguration(communityUrl, startUrl);


      return 'SSO Test';
    }
}