/**
 * Test class for Core_ACM_CalloutService focused solely on config resolution:
 * getRequestConfig(String) and the private getIntegrationConfigRecord(String)
 * it delegates to.
 */
@isTest
public class Core_ACM_CalloutServiceTest {

    @isTest
    static void getRequestConfig_blankName_throws() {
        Boolean threw = false;
        try {
            Core_ACM_CalloutService.getRequestConfig('   ');
        } catch (CalloutException e) {
            threw = true;
            System.assertEquals('Integration name is required.', e.getMessage());
        }
        System.assert(threw, 'A CalloutException was expected for a blank integration name.');
    }

    @isTest
    static void getRequestConfig_nullName_throws() {
        Boolean threw = false;
        try {
            Core_ACM_CalloutService.getRequestConfig(null);
        } catch (CalloutException e) {
            threw = true;
            System.assertEquals('Integration name is required.', e.getMessage());
        }
        System.assert(threw, 'A CalloutException was expected for a null integration name.');
    }

    @isTest
    static void getRequestConfig_pim_resolvesActiveConfig() {
        // Exercises getIntegrationConfigRecord returning a matching active metadata record.
        Core_ACM_CalloutService.RequestConfig config =
            Core_ACM_CalloutService.getRequestConfig('PIM');

        System.assertNotEquals(null, config, 'A config should resolve for the ERPM integration.');
        System.assertEquals('callout:PIM_Api/pim/v1/services/', config.endpoint);
        System.assertEquals('GET', config.method);
        System.assertNotEquals(null, config.timeoutMs, 'Timeout should default when not configured.');
        System.assertNotEquals(null, config.contentType, 'Content type should default when not configured.');
    }

    @isTest
    static void getRequestConfig_unknownIntegration_throws() {
        // Exercises getIntegrationConfigRecord returning null (no matching record).
        Boolean threw = false;
        try {
            Core_ACM_CalloutService.getRequestConfig('NON_EXISTENT_INTEGRATION_XYZ');
        } catch (CalloutException e) {
            threw = true;
            System.assert(
                e.getMessage().contains('No callout configuration found'),
                'Unexpected message: ' + e.getMessage()
            );
        }
        System.assert(threw, 'A CalloutException was expected for an unknown integration.');
    }
}