public class ACM_CNDAStatusBatch implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts {
    public String query;
    public Map<Id,List<String>> acctRemoveCNDAList = new Map<Id,List<String>>();
    Map<Id,String> acctAndAcctOwnerMap = new Map<Id, String>(); // Map of Account Id and that account's owner

    // Constructor to initialize the query
    public ACM_CNDAStatusBatch() {
        query = 'Select Id,Core_CNDA_Number__c,Owner.Email FROM Account Where Core_Account_Record_Type__c = \'Intel Account\' and Core_CNDA_Number__c != null';
    }
    
    public ACM_CNDAStatusBatch(String query) {
        this.query = query;
    }

    // Start method - used to define the records to process
    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }
    // Execute method - processes records in chunks
    public void execute(Database.BatchableContext BC, List<Account> scope) {
        
        Map<Id,String> acctCNDAmap = new Map<Id,String>(); // Map of Acct Id and CNDA list of that Account in query format
        Map<Id,List<String>> acctCNDAExistingList = new Map<Id,List<String>>();
        
        for(Account acc : scope)
        {
            // Step 1: Split the string by semicolon
			List<String> values = String.isBlank(acc.Core_CNDA_Number__c)? null : acc.Core_CNDA_Number__c.split(';');

			// Step 2: Trim each value in the list
			for (Integer i = 0; i < values.size(); i++) {
    			values[i] = values[i].trim(); // Trim leading and trailing whitespace
			}
            
            acctCNDAExistingList.put(acc.Id,values);
            
            // Initialize the resulting string
            String result = '';
            
            // Loop through the contract numbers and build the string
            for (Integer i = 0; i < values.size(); i++) {
                result += '\'contract_number\'=' + values[i];
                
                // Add '%7C%7C' separator unless it's the last element
                if (i < values.size() - 1) {
                    result += '%7C%7C';
                }
            }
            
            // Output the result
            System.debug(result);

			acctCNDAmap.put(acc.Id, result);
            
            acctAndAcctOwnerMap.put(acc.Id,acc.Owner.Email);
            
        }
        
        UCD_ACM_Logger.information('ACM_CNDAStatusBatch', 'Batch Execute', 'List of Ids runin this batch : '+acctCNDAmap.keySet(), 'Batch CNDA');
        
        // Instantiate Http and HttpRequest objects
        Http http = new Http();
        
        // Loop through each Account in the scope
        for (Id acctId : acctCNDAmap.keySet()) {
            // Create a new HttpRequest for each account
            HttpRequest request = new HttpRequest();
            String params = '/lawmasrestricted/v2/general-access-contracts?query='+acctCNDAmap.get(acctId)+'&field=counterparty_name&field=contract_number&field=wfstate';

            // Set the request method (GET, POST, etc.)
            request.setEndpoint('callout:SalesCRM_Apigee'+params);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('Content-Length', '0');
            
            ClassForEmptyBody classForEmptyBodyObject = new ClassForEmptyBody();
            String jsonBody = json.serializePretty(classForEmptyBodyObject , true);
            
            request.setBody(jsonBody);

            // Perform the API callout
            try {
                HttpResponse response = http.send(request);

                // Handle the response (optional)
                if (response.getStatusCode() == 200) {
                    // Successful response handling
                    System.debug('API Response for Account ' + acctId + ': ' + response.getBody());
                    String strResponse = response.getBody(); 
                    
                    Map<String, Object> meta = (Map<String, Object>) JSON.deserializeUntyped(strResponse);
                    List<Object> myMapObjects = (List<Object>) meta.get('result');
                    List<String> nonactiveCNDAs = new List<String>();
                    for (Object obj : myMapObjects) 
                    {
                        System.debug('Object :'+obj);
                        String jsonString = JSON.serialize(obj);
                        Map<String, Object> parsed = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
                        String status = JSON.serialize(parsed.get('wfstate')).replace('"','');
                        
                            if(status != 'Active')
                            {
                                nonactiveCNDAs.add(JSON.serialize(parsed.get('contract_number')).replace('"',''));
                            }
                    }
                    
                    System.debug('CNDAList : '+nonactiveCNDAs);    
                    
                    if(nonactiveCNDAs.size() > 0)
                    {
                        acctRemoveCNDAList.put(acctId,nonactiveCNDAs);
                    }
                    
                } 
                else {
                    // Error handling if the response is not successful
                    System.debug('API Error for Account ' + acctId + ': ' + response.getStatusCode());
                    UCD_ACM_Logger.information('ACM_CNDAStatusBatch', 'Batch Execute', 'API Error for Account ' + acctId + ': '+ response.getBody(), 'Batch CNDA');
                }
            } catch (Exception e) {
                // Handle exceptions (e.g., API timeout, unreachable server, etc.)
                System.debug('Exception calling API for Account ' + acctId + ': ' + e.getMessage());
                UCD_ACM_Logger.error('ACM_CNDAStatusBatch','Batch Execute','Exception calling API for Account ' + acctId + ': ' +'Message: '+e.getMessage()+'. StackTrace: '+e.getStackTraceString(),NULL);
            }
        }
        
        /*// Loop through acctRemoveCNDAList and remove values from acctCNDAExistingList
        for (Id key : acctRemoveCNDAList.keySet()) {
            if (acctCNDAExistingList.containsKey(key)) {
                // Get the list of strings in map2 for the current key
                List<String> valuesToRemove = acctRemoveCNDAList.get(key);
                
                // Remove the matching values from map1 for the current key
                List<String> map1Values = acctCNDAExistingList.get(key);
                ACM_CNDAStatusBatch.removeAll(map1Values,valuesToRemove);
                
                // Update acctCNDAExistingList with the new list after removal
                acctCNDAExistingList.put(key, map1Values);
            }
        }   
        
        try
        {
            List<Account> accountsToUpdate = [SELECT Id,Core_CNDA_Number__c FROM Account WHERE Id IN :acctCNDAExistingList.keySet()];
            
            for(Account acct : accountsToUpdate)
            {
                // Join the List into a semicolon-separated string
                String result = String.join(acctCNDAExistingList.get(acct.Id), ';');
                // Ensure the string ends with a semicolon
                result += ';';
                acct.Core_CNDA_Number__c = result;
            }
            
            update accountsToUpdate;
        }
        catch(Exception ex)
        {
            UCD_ACM_Logger.error('ACM_CNDAStatusBatch','Batch class','Message: '+ex.getMessage()+'. StackTrace: '+ex.getStackTraceString(),NULL);
            throw ex;            
        } */     
        
    }

    // Finish method - used to perform any post-processing tasks
    public void finish(Database.BatchableContext BC) {
        System.debug('Batch Process Completed');
        String contentBody ='';
        List<NDAAccountWrapper> ndaAccountTable = new List<NDAAccountWrapper>();
        for(Id acctId : acctRemoveCNDAList.keySet())
        {
            //ACM_EmailManager em = new ACM_EmailManager();
            //em.sendMail(new List<String>{acctAndAcctOwnerMap.get(acctId)}, 'Remove Inactive CNDA', 'These NDA values '+acctRemoveCNDAList.get(acctId) +'have to be removed from Account - '+acctId);
            // Create a new NDAAccountWrapper object and add it to the list
            NDAAccountWrapper newRow = new NDAAccountWrapper(acctRemoveCNDAList.get(acctId), acctId);
            ndaAccountTable.add(newRow);
        }
        ACM_EmailManager em = new ACM_EmailManager();
        em.sendEmailHTML(ndaAccountTable);
        
    }
    
    public static void removeAll(List<String> originalList, List<String> itemsToRemove) {
        // Iterate through the original list and create a new list to hold the filtered items
        List<String> resultList = new List<String>();

        // Loop through each item in the original list
        for (String item : originalList) {
            // If the item is not in the itemsToRemove list, add it to the resultList
            if (!itemsToRemove.contains(item)) {
                resultList.add(item);
            }
        }

        // Clear the original list and add the filtered items back
        originalList.clear();
        originalList.addAll(resultList);
    }
    
    class ClassForEmptyBody{
    }
    
    public class NDAAccountWrapper {
    public List<String> ndaList;  // Store NDA information
    public String accountId;  // Store Account ID

    // Constructor
    public NDAAccountWrapper(List<String> ndaList, String accountId) {
        this.ndaList = ndaList;
        this.accountId = accountId;
    }
	}
}