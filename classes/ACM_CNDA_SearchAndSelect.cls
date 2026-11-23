public without sharing class ACM_CNDA_SearchAndSelect 
{
    @AuraEnabled
    public static MyReturnWrapper ExecuteAPI(Id AcctID,String Name,Boolean multiParam) {
        try 
        {            
            UCD_ACM_Logger.information('ACM_CNDA_SearchAndSelect', 'ExecuteAPI', 'Account ID fetched through Current Reference Page : '+ AcctID, 'CNDA');
            
            // Check if the user has any of the allowed profiles
        	
                Account acct = [Select Name,Core_CNDA_Number__c from Account where Id =: AcctID WITH SECURITY_ENFORCED LIMIT 1];    
                if(String.isNotBlank(Name))
                {
                    return new MyReturnWrapper(getCNDAforName(Name,multiParam),acct.Core_CNDA_Number__c);
                }
                
                return new MyReturnWrapper(getCNDAforName(acct.Name,multiParam),acct.Core_CNDA_Number__c);
            
        }
        catch(Exception ex)
        {
            UCD_ACM_Logger.error('ACM_CNDA_SearchAndSelect','ExecuteAPI','Message: '+ex.getMessage()+'. StackTrace: '+ex.getStackTraceString(),NULL);
            throw ex;
        }
        finally
        {
            UCD_ACM_Logger.setLogDetails();
        }
    }
    
    @AuraEnabled
    public static String getCNDAforName(String Name,Boolean multiParam){
            HttpRequest httpReq = new HttpRequest();
            HttpResponse response = new HttpResponse();
            String AccountName = EncodingUtil.urlEncode(Name, 'UTF-8').replace('+', '%20');
        	String params ='';
        	if(!multiParam)
            {
            	params = '/lawmas/v1/general-access-contracts?query=counterparty_name~='+'\''+AccountName+'\''+'&field=counterparty_name&field=intel_contact_name&field=contract_number&field=contract_type0&field=contract_subtype&field=counterparty_country&field=counterparty_state_province&field=counterparty_city&field=counterparty_address_line_1&field=counterparty_address_line_2&field=counterparty_zip_or_postal_code';
            }
        	else
            {
                params = '/lawmas/v1/general-access-contracts?query=contract_number%3D'+'\''+AccountName+'\''+'%7C%7Ccounterparty_name~='+'\''+AccountName+'\''+'&field=counterparty_name&field=intel_contact_name&field=contract_number&field=contract_type0&field=contract_subtype&field=counterparty_country&field=counterparty_state_province&field=counterparty_city&field=counterparty_address_line_1&field=counterparty_address_line_2&field=counterparty_zip_or_postal_code';
            }
            httpReq.setEndpoint('callout:SalesCRM_Apigee'+params);
            httpReq.setMethod('POST');
            httpReq.setTimeout(60000);
            httpReq.setHeader('Content-Type','application/json');  
            httpReq.setHeader('Content-Length', '0');
            
            ClassForEmptyBody classForEmptyBodyObject = new ClassForEmptyBody();
            String jsonBody = json.serializePretty(classForEmptyBodyObject , true);
            httpReq.setBody(jsonBody);
            
        try{
            response = new Http().send(httpReq);           
            UCD_ACM_Logger.information('ACM_CNDA_SearchAndSelect', 'getCNDAforName', 'Response from LAWMAS API : '+ response.getBody(), 'CNDA');
            
            String strResponse = response.getBody(); 
            return strResponse;
        }
        catch(Exception ex)
        {
            UCD_ACM_Logger.error('ACM_CNDA_SearchAndSelect','ExecuteAPI','Message: '+ex.getMessage()+'. StackTrace: '+ex.getStackTraceString(),NULL);
            throw ex;
        }
        finally
        {
            UCD_ACM_Logger.setLogDetails();
        }
    }
    
    @AuraEnabled
    // Method to append text to an existing string field of an Account
    public static Boolean appendToAccountField(Id accountId, String textToAppend,List<String> preselectedRows) {
        // Query the Account record to retrieve the existing field value
        Account acc = [SELECT Id, Core_CNDA_Number__c FROM Account WHERE Id = :accountId WITH SECURITY_ENFORCED LIMIT 1];
        
        List<String> values = String.isBlank(acc.Core_CNDA_Number__c)? null : acc.Core_CNDA_Number__c.split('[;,/ ]');
        List<String> selectedRows = String.isBlank(textToAppend)? new List<String>() : textToAppend.split(';');
        
        
        // Convert preselectedRows and selectedRows to sets for faster lookup
        Set<String> preselectedSet = new Set<String>(preselectedRows);
        Set<String> selectedSet = new Set<String>(selectedRows);
        
        // Create a new list to store the values from 'values' that are not in preselectedRows or selectedRows
        List<String> result = new List<String>();
        
        // Iterate through the values list and add values not in preselectedSet or selectedSet
        if(values!=null && !values.isEmpty())
        {
            for (String value : values) {
                if (!preselectedSet.contains(value) && !selectedSet.contains(value)) {
                    result.add(value);
                }
            }
        }
        
        result.addAll(selectedSet);
        
        
        Set<String> finalSet = new Set<String>(result);
        
        // Join the List into a semicolon-separated string
        String finalResult = (finalSet.size() > 0) ? String.join(finalSet, ';') : null;
        // Ensure the string ends with a semicolon
        if(String.isNotBlank(finalResult) && !finalResult.endsWith(';'))
        {
			finalResult += ';';
        }
        
        
        acc.Core_CNDA_Number__c = finalResult;
    
        try 
        {
            if(Schema.sObjectType.Account.isUpdateable()){
            update acc; // Update the Account record
            return true;  // Return true if update is successful
            }
            return false;
            
        } catch (DmlException e) 
        {
            // If there's an error during the update, log the error and return false
            return false;
    	}
    }

    public class MyReturnWrapper {
        @AuraEnabled public String jsonResponse;
        @AuraEnabled public String cndaList; 

        public MyReturnWrapper(String str, String cnda) {
            jsonResponse = str;
            cndaList = cnda;
        }
    }
    
    class ClassForEmptyBody{
    }
    
}