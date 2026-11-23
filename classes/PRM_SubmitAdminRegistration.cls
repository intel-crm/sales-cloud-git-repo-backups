public with sharing class PRM_SubmitAdminRegistration {
    
    @InvocableMethod(label='Submit Admin Registration' description='Submits the admin registration request' category='Other')
    public static List<String> submitAdminRegistration(List<String> inputJson){
        System.debug('inputJson -->'+inputJson);
        // get country code
        Map<String, Schema.SObjectField> objFieldMap = Schema.getGlobalDescribe().get('Account').getDescribe().fields.getMap();
        Schema.SObjectField  countryCode = objFieldMap.get('billingcountrycode');
        Map<String,String> countryLabelValueMap = new Map<String,String>();

        for(Schema.PicklistEntry f :  countryCode.getDescribe().getPicklistValues()){
            countryLabelValueMap.put(f.getLabel(),f.getValue());
        }

        System.debug('countryLabelValueMap -->'+JSON.serialize(countryLabelValueMap));
        Map<String, Object> inputMap = (Map<String, Object>)JSON.deserializeUntyped(inputJson[0]);
        Map<String, String> inputMapString = new Map<String, String>();

        for(String key : inputMap.keySet()){
            Object obj = inputMap.get(key);
            if(key == 'ContactCountry'){
                inputMapString.put(key, countryLabelValueMap.get((String)obj));
            }else{
                inputMapString.put(key, (obj instanceof List<Object> || obj instanceof Map<String, String>)? JSON.serialize(obj) : (String) obj );
            }
            
        }
        
        // // Example of accessing the array
        // List<Object> accountAssociatedList = (List<Object>)inputMap.get('AccountAssociatedToExistingContact');
        // List<Object> duplicateContactList = (List<Object>)inputMap.get('DuplicateContactRecord');
        
        // Process the inputMap as needed
        Map<String, String> respMap = PRM_AdminRegistration.submitAdminRequestForm(inputMapString);
        
        return inputJson;
    }
}