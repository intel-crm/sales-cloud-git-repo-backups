/**
 * Return a static sample configuration with pre-configured value for the sample organization.
 */

global with sharing class SampleTokenProvider implements ITokenProvider {
    /**
     * @see `ITokenProvider.getHeadlessConfiguration`. 
     */ 
    //     public static String token;
    //  static{
    //      System.debug('Inside the static block of SampleTokenProvider');
    //     token =  Core_IPS_CoveoPageCtrl_LWC.generateToken();
    //     System.debug('Token>>>>>'+ token);
    //  }
  

     @AuraEnabled(cacheable=false)
    public static String getHeadlessConfiguration() {

        String token =  Core_IPS_CoveoPageCtrl_LWC.generateToken();
        
        Map<String, String> headlessConfiguration = new Map<String,String>();
        headlessConfiguration.put('organizationId', 'intelcorporationproductione78n25s6');
        headlessConfiguration.put('accessToken', token);
        headlessConfiguration.put('platformUrl', 'https://platform.cloud.coveo.com');
        return JSON.serialize(headlessConfiguration);
    }
}