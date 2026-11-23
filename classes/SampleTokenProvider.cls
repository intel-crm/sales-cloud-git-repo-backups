/**
 * Return a static sample configuration with pre-configured value for the sample organization.
 */
//--global with sharing class SampleTokenProvider implements ITokenProvider {
  /**
   * @see `ITokenProvider.getHeadlessConfiguration`.
   */
 /*--    @AuraEnabled(cacheable=false) //CRGA upgrade changes - Begin -gangadhar
  public static String getHeadlessConfiguration() {
        String token =  Core_IPS_CoveoPageCtrl_LWC.generateToken();
      Map<String, String> headlessConfiguration = new Map<String, String>();
        headlessConfiguration.put('organizationId', 'intelcorporationproductione78n25s6'); 
        headlessConfiguration.put('accessToken', token);
        headlessConfiguration.put('platformUrl', 'https://platform.cloud.coveo.com'); //CRGA upgrade changes - End -gangadhar
        return JSON.serialize(headlessConfiguration);
    }
} --*/
/**
 * Return a static sample configuration with pre-configured value for the sample organization.
 */
/**Updated: Implementation of Coveo CRGA changes on IPS portal SBS page-TWC745-9525-Gangadhar**/
global with sharing class SampleTokenProvider implements ITokenProvider {
  /**
   * @see `ITokenProvider.getHeadlessConfiguration`.
   */
  @AuraEnabled(cacheable=false) 
  public static String getHeadlessConfiguration() {
        //String organizationId = 'intelcorporationproductione78n25s6';
        String organizationId = 'intelcorporationnonproduction2ybdyblf7';
        String token = Core_IPS_CoveoPageCtrl_LWC.generateToken();
        
        // Change Map value type to Object to support the nested organizationEndpoints map structure
        Map<String, Object> headlessConfiguration = new Map<String, Object>();
        headlessConfiguration.put('organizationId', organizationId); 
        headlessConfiguration.put('accessToken', token);
        
        // Define the mandatory organization endpoints configuration map block
        Map<String, String> organizationEndpoints = new Map<String, String>();
        organizationEndpoints.put('search', 'https://' + organizationId + '.org.coveo.com');
        organizationEndpoints.put('analytics', 'https://' + organizationId + '.analytics.org.coveo.com');
        organizationEndpoints.put('platform', 'https://' + organizationId + '.platform.org.coveo.com');
        
        // Add endpoints into configuration payload
        headlessConfiguration.put('organizationEndpoints', organizationEndpoints);
        
        return JSON.serialize(headlessConfiguration);
    }
}