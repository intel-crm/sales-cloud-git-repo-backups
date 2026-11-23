/**
* @Name       		 : Prm_emailOptOutCtrl
* @Description 		 : This class is used in Prm_emailOptOut LWC
* @author            : DINESH 
* @group             : 
* @last modified on  : 019-06-2023
* @last modified by  : 
**/
public With sharing class Prm_emailOptOutCtrl {
    
    public static final String ORIGIN  = 'Prm_emailOptOutCtrl';
    public static final String SEVERITY  = 'Critical';
    public static final String PROJECT  = 'DDR';
    
    // Method to get picklist field values based on object and field API names
    @AuraEnabled(Cacheable = true)
    public static List<OptionWrapper> getPicklistValues(String objectApiName, String fieldApiName)
    {
        List<OptionWrapper> options = new List<OptionWrapper>();
        try{
            // Retrieve field metadata using Schema class
            Schema.DescribeFieldResult fieldResult = Schema.getGlobalDescribe().get(objectApiName).getDescribe().fields.getMap().get(fieldApiName).getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            options.add(new OptionWrapper('-None-', '-None-'));
            
            // Iterate over picklist values and add them to the options list
            for( Schema.PicklistEntry entry : ple)
            {
                options.add(new OptionWrapper(entry.getValue(),entry.getLabel()));
            }       
        }catch(Exception ex){Core_Log_Entry.logEntryWithDetails(ORIGIN, PROJECT,'Message', SEVERITY, ex.getMessage(), '', null, null, null);                        
        }
        return options;
    }
    
    // Method to update contact and user records based on the provided responses
    @AuraEnabled
    public static boolean updateContact(String responses) {
        System.debug('response -->' + responses);
        try{
            // Deserialize the JSON response string into a map
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(responses);
            
            // Extract the 'response' map from the response map
            Map<String, Object> response = (Map<String, Object>) responseMap.get('response');
            
            // Extract the values from the 'response' map
            Id contactId = (Id)response.get('contactId');
            Boolean tradeComplianceValue = (Boolean)response.get('tradeComplianceValue');
            String selectedTimeZone = (String) response.get('selectedTimeZone');
            String selectedCountry = (String) response.get('selectedCountry');
            Boolean emailOptOut = (Boolean) response.get('emailOptOut');
            
            List<Sobject> sobjectsForUpsert = new List<SObject>();
            
            // Example: Retrieve the existing contact record based on the contactId
            Contact contact = new Contact();
            if(!test.isRunningTest()) contact= [SELECT Id, Core_Country_Region__c, Core_MINDS__c, Core_IPS_Email_Opt_Out__c FROM Contact where id = :contactId  LIMIT 1];
            
            // Update contact fields based on the extracted values
            contact.Id = contactId;
            contact.Core_Country_Region__c = selectedCountry;    
            contact.Core_MINDS__c = tradeComplianceValue;
            contact.Core_IPS_Email_Opt_Out__c = emailOptOut;
            sobjectsForUpsert.add(contact);
            
            // Update user record (current user) with the selected time zone
            User usr = new User();
            usr.Id = UserInfo.getUserId();
            usr.TimeZoneSidKey = selectedTimeZone;
            sobjectsForUpsert.add(usr);
            
            // Upsert the modified records
            DDR_DMLOprationsCtrl.upsertData(sobjectsForUpsert);
            return true;
            
        }catch(Exception ex){Core_Log_Entry.logEntryWithDetails(ORIGIN, PROJECT,'Message', SEVERITY, ex.getMessage(), '', null, null, null);                        }
        return  false;
    }
    
    // Method to get details of the current user
    @AuraEnabled(Cacheable = true)
    public static User getCurrentUserDetails(){
        try{
            // Retrieve the current user details including associated contact, email opt-out, trade compliance, country, and time zone
            return [SELECT ContactId, Contact.Name, Contact.Core_IPS_Email_Opt_Out__c, Contact.Core_MINDS__c, Contact.Core_Country_Region__c, TimeZoneSidKey FROM User WHERE id = :UserInfo.getUserId()];
        }catch(Exception ex){Core_Log_Entry.logEntryWithDetails(ORIGIN, PROJECT,'Message', SEVERITY, ex.getMessage(), '', null, null, null);                        
        }
        return null;
    }
    
    // Wrapper class to hold picklist option values
    public class OptionWrapper {
        @AuraEnabled
        public String value;
        @AuraEnabled
        public String label;
        
        public OptionWrapper(String value, String label) {
            this.value = value;
            this.label = label;
        }
    }
}