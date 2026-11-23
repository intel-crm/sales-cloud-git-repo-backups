// NOT being used in the commission Project
@isTest
public class CPT_QuotaSetup_Set_Default_Value_Test {

    // Test the simple success path: setting a text field.
    @isTest
    static void testSetField_Success() {
        // We'll use the Account's Description field as a simple text field for this test.
        Account testAccount = new Account(Name = 'Test Corp');
        String fieldToUpdate = 'Description';
        String newValue = '50%'; // The exact kind of text value you are using.

        CPT_QuotaSetup_Set_Default_Value.UpdateRequest request = new CPT_QuotaSetup_Set_Default_Value.UpdateRequest();
        request.record = testAccount;
        request.fieldName = fieldToUpdate;
        request.fieldValue = newValue;

        List<CPT_QuotaSetup_Set_Default_Value.UpdateRequest> requests = new List<CPT_QuotaSetup_Set_Default_Value.UpdateRequest>{ request };

        Test.startTest();
        List<SObject> updatedRecords = CPT_QuotaSetup_Set_Default_Value.setField(requests);
        Test.stopTest();

        // Verify the Description field was set correctly.
        System.assertEquals(1, updatedRecords.size());
        String updatedValue = (String)updatedRecords[0].get(fieldToUpdate);
        System.assertEquals(newValue, updatedValue, 'The text field was not updated correctly.');
    }

    // This error handling test remains important.
    @isTest
    static void testSetField_Error_InvalidFieldName() {
        Account testAccount = new Account(Name = 'Test Corp');
        String invalidFieldName = 'ThisFieldDoesNotExist__c';
        String value = '50%';

        CPT_QuotaSetup_Set_Default_Value.UpdateRequest request = new CPT_QuotaSetup_Set_Default_Value.UpdateRequest();
        request.record = testAccount;
        request.fieldName = invalidFieldName;
        request.fieldValue = value;
        List<CPT_QuotaSetup_Set_Default_Value.UpdateRequest> requests = new List<CPT_QuotaSetup_Set_Default_Value.UpdateRequest>{ request };
        
        Exception caughtException = null;

        Test.startTest();
        try {
            CPT_QuotaSetup_Set_Default_Value.setField(requests);
        } catch (Exception e) {
            caughtException = e;
        }
        Test.stopTest();

        // Verify an exception was thrown.
        System.assertNotEquals(null, caughtException, 'An exception should have been thrown.');
        System.assert(caughtException instanceof AuraHandledException);
    }
}