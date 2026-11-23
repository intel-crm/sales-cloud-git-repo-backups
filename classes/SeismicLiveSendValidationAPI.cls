// Setting up the Request URL
@RestResource(urlMapping='/SeismicLiveSendValidationAPI/*')
global with sharing class SeismicLiveSendValidationAPI {
    // POST Method
    @HTTPPost
    global static List<Map<String, String>> Validate(String documentId, List<String> emailAddresses) {
        // Initialize the response list
         List<Map<String, String>> responseMap = new List<Map<String, String>>();
        
        // Initialize Contact/Lead Lists and Maps 
         List<Contact> firstContactList = new List<Contact>();
         List<Lead> firstLeadList = new List<Lead>();
         Map<String,Contact> firstContactMap = new Map<String,Contact>();
         Map<String,Lead> firstLeadMap = new Map<String,Lead>();
        
        // Get the list of contacts and leads for the email addresses for the validation logic check
         firstContactList= [Select Id,Email,HasOptedOutOfEmail,Core_Sales_Do_Not_Contact_Ind__c,Core_Contact_Export_Compliance_Block__c 
                            from Contact where Email in :emailAddresses];
         firstLeadList= [Select Id,Email,HasOptedOutOfEmail,Core_Do_not_call__c from Lead where Email in :emailAddresses];
                for(Contact c : firstContactList)
                { 
                    firstContactMap.put(c.Email, c);
                }
                for(Lead l : firstLeadList)
                { 
                    firstLeadMap.put(l.Email, l);
                }
         System.debug('firstLeadMap'+firstLeadMap);
         System.debug('firstContactMap'+firstContactMap);     
        
        // Iterate thru the list of email addresses
        for(String email:emailAddresses){
            // Initializing the single response map for each email
            Map<String, String> responseSingleMap = new Map<String, String>();
            // Do validation checks here
            // -------------------------------------------------------------------
            // There is a match for a Contact for the email address and the HasOptedOutOfEmail field is checked
            if (firstContactMap.get(email)!=null && (firstContactMap.get(email).HasOptedOutOfEmail == true) )
            { responseSingleMap.put('status', 'Fail'); 
              responseSingleMap.put('message', 'Failed: Contact has Opt of Email Indicator checked'); 
            }
            // There is a match for a Contact for the email address and the Core_Sales_Do_Not_Contact_Ind__c field is checked
            else if (firstContactMap.get(email)!=null && (firstContactMap.get(email).Core_Sales_Do_Not_Contact_Ind__c == true) )
            { responseSingleMap.put('status', 'Fail');
              responseSingleMap.put('message', 'Failed: Contact has Do not Contact Indicator checked'); 
            }
            // There is a match for a Contact for the email address and the Core_Contact_Export_Compliance_Block__c field is checked
            else if (firstContactMap.get(email)!=null &&  (firstContactMap.get(email).Core_Contact_Export_Compliance_Block__c  == true) )
            { responseSingleMap.put('status', 'Fail');
              responseSingleMap.put('message', 'Failed: Contact has Export Compliance Block Indicator checked');
            }
            // There is a match for a Lead for the email address and the HasOptedOutOfEmail field is checked
            else if (firstLeadMap.get(email)!=null &&  (firstLeadMap.get(email).HasOptedOutOfEmail == true) )
            { responseSingleMap.put('status', 'Fail');
              responseSingleMap.put('message', 'Failed: Lead has Opt of Email Indicator checked');
            }
            // There is a match for a Lead for the email address and the Core_Do_not_call__c field is checked
            else if (firstLeadMap.get(email)!=null &&  (firstLeadMap.get(email).Core_Do_not_call__c == true) )
            { responseSingleMap.put('status', 'Fail');
              responseSingleMap.put('message', 'Failed: Lead has Do Not Call Indicator checked');
            }
           // There are no matching Contact or Lead for the email address
            else if (firstLeadMap.get(email)==null && firstContactMap.get(email)==null )
            { responseSingleMap.put('status', 'Success');
              responseSingleMap.put('message', 'No record match for Contact or Lead');
            }
            // All validations passes or no matching Contact or Lead found for email
            else{
                responseSingleMap.put('status', 'Success');
                responseSingleMap.put('message', 'Email Passed Validation');
            }
            
            // Add email address to return payload
             responseSingleMap.put('Email:', email);
            
           // ------------------------------------------------------------------- 
            // Add to return list of map for each email address
             responseMap.add(responseSingleMap);
        }
        
 // Logging of response payload is done here
 // Logging table: Core_Log_Entry__c
 // -------------------------------------------------------------------
   Core_RestAPI_Response response = new Core_RestAPI_Response();
   DateTime entryTime = DateTime.now();
   Core_RestAPI_LoggingUtil.logTransaction(entryTime, response);
        
        
 // ------------------------------------------------------------------- 
      
      return responseMap;
    }

}