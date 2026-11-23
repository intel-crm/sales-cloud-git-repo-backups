// NOT being used in the commission Project
public class CPT_QuotaSetup_Set_Default_Value{

    // This class represents the input data the Flow will send to our Apex method.
    public class UpdateRequest {
        @InvocableVariable(label='Record to Update' description='The record that will be updated.' required=true)
        public SObject record;

        @InvocableVariable(label='Field API Name' description='The API name of the field to set.' required=true)
        public String fieldName;

        @InvocableVariable(label='Field Value' description='The value to assign to the field.' required=true)
        public String fieldValue; // Changed from Decimal to String
    }

    /**
     * Sales Incentives - Commission Project 
     * @description This invocable method receives a list of requests from a Flow,
     *              dynamically sets a field on an object using a text value, and returns the modified object.
     * @param requests A list of UpdateRequest objects from the Flow.
     * @return A list of the updated SObjects.
     */
    @InvocableMethod(label='Set Default % Dynamically' description='Sets a default % value on a specified field of an Quoat Setup object dynamically.' category='Quota Setup')
    public static List<SObject> setField(List<UpdateRequest> requests) {
        List<SObject> updatedRecords = new List<SObject>();

        for (UpdateRequest req : requests) {
            SObject recordToUpdate = req.record;
            String field = req.fieldName;
            String value = req.fieldValue; // Using the String value directly

            try {
                // Simple, direct logic: Put the text value into the specified field.
                recordToUpdate.put(field, value);
                updatedRecords.add(recordToUpdate);

            } catch (Exception e) {
                // This catch block handles any errors (e.g., invalid field name or a value that is not valid for a restricted picklist).
                AuraHandledException flowException = new AuraHandledException('Error setting field "' + field + '" with value "' + value + '": ' + e.getMessage());
                flowException.initCause(e);
                throw flowException;
            }
        }
        return updatedRecords;
    }
}