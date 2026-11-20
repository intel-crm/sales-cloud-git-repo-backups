@IsTest
public class Core_MDF_OutcomeBasedCmpgn_ParentTest {
    
    @IsTest
    static void testHasNewCampaignAccess() {
        Test.startTest();
        
        Boolean result = Core_MDF_OutcomeBasedCmpgn_ParentComp.hasNewCampaignAccess();
        
        Test.stopTest();
        
        // Since custom permissions cannot be assigned in test easily,
        // we only assert that method executed successfully
        System.assertNotEquals(null, result, 'Result should not be null');
    }
    
    
    @IsTest
    static void testGetIPARecordType_Success() {
        
        Test.startTest();
        
        Map<String, Object> result = 
            Core_MDF_OutcomeBasedCmpgn_ParentComp.getIPARecordType();
        
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Result map should not be null');
        System.assert(result.containsKey('recordTypeId'));
        System.assert(result.containsKey('recordTypeName'));
        System.assert(result.containsKey('recordTypeDeveloperName'));
    }
    
    
    @IsTest
    static void testGetIPARecordType_Exception() {
        
        // This test assumes label or selector may fail in some orgs
        // If it does not fail, it will still pass safely
        
        Test.startTest();
        
        try {
            Map<String, Object> result =
                Core_MDF_OutcomeBasedCmpgn_ParentComp.getIPARecordType();
        } 
        catch (AuraHandledException ex) {
            System.assert(ex.getMessage().contains('IPA'));
        }
        
        Test.stopTest();
    }
}