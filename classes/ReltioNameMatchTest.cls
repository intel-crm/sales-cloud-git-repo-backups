public class ReltioNameMatchTest {
    public static void testNameFieldMatch() {
        // Step 1: Build test payload for Reltio search
        List<UCD_GenericAcctSearch_SBR.fieldsetwrapper> testPayload = new List<UCD_GenericAcctSearch_SBR.fieldsetwrapper>();

        UCD_GenericAcctSearch_SBR.fieldsetwrapper f1 = new UCD_GenericAcctSearch_SBR.fieldsetwrapper();
        f1.fieldAPIName = 'BusinessOrganizationName';
        f1.fieldvalue = 'Infosys Limited'; //  Replace with a known value in your Reltio

        UCD_GenericAcctSearch_SBR.fieldsetwrapper f2 = new UCD_GenericAcctSearch_SBR.fieldsetwrapper();
        f2.fieldAPIName = 'Country';
        f2.fieldvalue = 'IN'; // Country code (2-letter ISO, e.g., US, IN, etc.)

        UCD_GenericAcctSearch_SBR.fieldsetwrapper f3 = new UCD_GenericAcctSearch_SBR.fieldsetwrapper();
        f3.fieldAPIName = 'State';
        f3.fieldvalue = 'KA'; // Use exact state code if required

        UCD_GenericAcctSearch_SBR.fieldsetwrapper f4 = new UCD_GenericAcctSearch_SBR.fieldsetwrapper();
        f4.fieldAPIName = 'ElectronicAddress';
        f4.fieldvalue = 'infosys.com'; //  Use real known domain

        testPayload.add(f1);
        testPayload.add(f2);
        testPayload.add(f3);
        testPayload.add(f4);

        // Log the payload for debug visibility
        System.debug('📤 Sending test payload to Reltio: ' + JSON.serializePretty(testPayload));

        try {
            // Step 2: Call your existing Reltio integration
            UCD_GenericAcctSearch_SBR.AccountSearchDataModelWithError result =
                UCD_GenericAcctSearch_SBR.getAcctResults(testPayload, '');

            // Step 3: Analyze the result
            if (result == null || result.accountSearchModel == null || result.accountSearchModel.isEmpty()) {
                System.debug('No match found. BusinessOrganizationName may not be indexed or data may not exist in Reltio.');
            } else {
                for (UCD_GenericAcctSearch_SBR.AccountSearchDataModel model : result.accountSearchModel) {
                    System.debug(' Match Found!');
                    System.debug(' Score: ' + model.score);
                    System.debug('Full Match Object: ' + JSON.serializePretty(model));
                }
            }

        } catch (Exception e) {
            System.debug(' Exception during Reltio call: ' + e.getMessage());
        }
    }
}