public with sharing class PRM_AdminRegistrationFlowCntrl {
    
    @InvocableMethod(label='Get Duplicate Account and Contact Details'
                     description='Returns the list of account and Contact.'
                     category='Other')
    public static List<accountContactList> getDuplicateAccountContact(List<AccountDetailsWrapper> input) {
        List<accountContactList> results = new List<accountContactList>();
        
        try{
            if (input != null && !input.isEmpty()) {
                AccountDetailsWrapper wrapper = input[0];
                
                // Serialize and deserialize to dynamic map
                String jsonString = JSON.serialize(wrapper);
                Map<String, Object> wrapperMap = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
                
                Map<String, String> inputMap = new Map<String, String>();
                for (String key : wrapperMap.keySet()) {
                    Object value = wrapperMap.get(key);
                    inputMap.put(key, value != null ? String.valueOf(value) : null);
                }
                
                System.debug('Dynamic Input Map : ' + JSON.serialize(inputMap));
                PRM_AdminRegistrationDuplicateDetails.accountContactList duplicateResult = PRM_AdminRegistrationDuplicateDetails.showAccountsContacts(inputMap);
                PRM_AdminRegistrationFlowCntrl.accountContactList localWrapper = (PRM_AdminRegistrationFlowCntrl.accountContactList) JSON.deserialize(JSON.serialize(duplicateResult), PRM_AdminRegistrationFlowCntrl.accountContactList.class);
                
                System.debug('localWrapper -->'+JSON.serialize(localWrapper));
                results.add(localWrapper); 
            }
        }catch(Exception ex){
            System.debug(ex.getMessage());
        }
        
        
        return results;
    }
    
    public class AccountDetailsWrapper {
        @InvocableVariable public String AccountID;
        @InvocableVariable public String AccountName;
        @InvocableVariable public String PartnerRole;
        @InvocableVariable public String AddressLine1;
        @InvocableVariable public String AddressLine2;
        @InvocableVariable public String Country;
        @InvocableVariable public String State;
        @InvocableVariable public String City;
        @InvocableVariable public String PostalCode;
        @InvocableVariable public String Website;
        @InvocableVariable public String ContactFirstName;
        @InvocableVariable public String ContactLastName;
        @InvocableVariable public String ContactEmail;
        @InvocableVariable public String PreferredLanguage;
        @InvocableVariable public String ContactCountry;
        @InvocableVariable public String DuplicateInfo;
        @InvocableVariable public String SelectedRow;
        @InvocableVariable public String AccountDuplicateStatus;
        @InvocableVariable public String ContactDuplicateStatus;
        @InvocableVariable public String accountAssociatedToExistingContact;
        @InvocableVariable public String duplicateContactRecord;
        @InvocableVariable public String associatedAccountIsIPA;
        @InvocableVariable public String SuppressEmail;
    }
    
    public class accountContactList {
        @InvocableVariable public List<MatchingAccWrapper> accountList = new List<MatchingAccWrapper>();@InvocableVariable public List<Contact> contactList = new List<Contact>();
        @InvocableVariable public String contactDupStatus;
        @InvocableVariable public Account accountAssociatedToExistingContact;
        @InvocableVariable public Contact duplicateContactRecord;
        @InvocableVariable public Boolean associatedAccountIsIPA;
        @InvocableVariable public Boolean displayRequestedAccount;
    }
}