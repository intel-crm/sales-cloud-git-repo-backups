/***************************************************************************************************************************************************************************************************
Apex Class Name:  Core_OpportunityKPICallout 
Version     : 1.0 
Created Date: 25 JAN 2021
Function    : Callout- Azure for Opportunity KPI
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sanket Mahajan             01/25/2021              Original Version

*****************************************************************************************************************************************************************************************************/

public class Core_OpportunityKPICallout {
    public static Core_OpportunityJSON.returnWr AuthCallout(String reqBody, id oppId,Core_OpportunityJSON.returnWr retWr ){
        Core_OpportunityJSON.returnWr retWrp = new Core_OpportunityJSON.returnWr();
        retWrp = retWr; 
        try{
            HttpRequest req = new HttpRequest();
            req.setEndpoint(System.Label.Core_Opportunity_KPI_Azure_Endpoint_URL);
            req.setMethod('POST');
            String authorizationHeader = GetSASToken(System.Label.Core_Opportunity_KPI_URI, System.Label.Core_Opportunity_KPI_Access_Policy_Name,System.Label.Core_Opportunity_KPI_Access_Policy_Key);
            String contentType = System.Label.Core_Opportunity_KPI_Content_Type;
            String host = System.Label.Core_Opportunity_KPI_Host;
            req.setHeader(System.Label.Core_AuthHeader, authorizationHeader);
            req.setHeader('Content-Type', contentType);
            req.setHeader('Host', host);
            
            req.setBody(reqBody);            
           
           
            Http http = new Http();
            HTTPResponse res = http.send(req);            
            
           
            
            /*string[] headerkeys = res.getHeaderKeys();
            //create an object to store your header key-value pairs
            Map<string, string> headers = new map<string, string>();
            //iterate through they keys, and populate your map
            for(string s : headerkeys){
               headers.put(s,res.getHeader(s));
               
            }*/
           
            //retWrp.ListlogEntry retWrp = new List<Core_Log_Entry__c>();
            retWr.ListlogEntry = new List<Core_Log_Entry__c>();
            if(res.getStatusCode() == 200 || res.getStatusCode() == 201){
                Core_Log_Entry__c logEntry = new Core_Log_Entry__c();
                
                logEntry.Core_Details__c = req.getBody();
                logEntry.Core_sObjectId__c = oppId;
                logEntry.Core_sObjectType__c = 'Opportunity';
                logEntry.Core_Origin__c = 'Delta Load';
                logEntry.Core_Severity__c = 'Low';
                logEntry.Core_When__c = system.now();
                logEntry.Core_Project__c = 'Sales';
                if(!String.IsEmpty (res.getBody())){
                    logEntry.Core_Message__c = 'Success - '+res.getBody().substring(0,150) ;
                }
                else{
                    logEntry.Core_Message__c = 'Success';
                }
                retWrp.ListlogEntry.add(logEntry);
                //retWr.ListlogEntry.add(logEntry);
            }
            else {
                Core_Log_Entry__c logEntry = new Core_Log_Entry__c();
        
                logEntry.Core_Details__c = req.getBody();
                logEntry.Core_sObjectId__c = oppId;
                logEntry.Core_sObjectType__c = 'Opportunity';
                logEntry.Core_Origin__c = 'Delta Load';
                logEntry.Core_Severity__c = 'High';
                logEntry.Core_When__c = system.now();
                logEntry.Core_Project__c = 'Sales';
                if(!String.IsEmpty (res.getBody())){
                    logEntry.Core_Message__c = 'Failed - '+res.getBody().substring(0,150) ;
                }
                else{
                    logEntry.Core_Message__c = 'Failed';
                }
                retWrp.ListlogEntry.add(logEntry);
                //retWr.ListlogEntry.add(logEntry);
            }
            
        }
        catch(exception e){
                      
              Core_Log_Entry__c logEntry = new Core_Log_Entry__c();
                
                logEntry.Core_sObjectType__c = 'Opportunity';
                logEntry.Core_Origin__c = 'Delta Load';
                logEntry.Core_Severity__c = 'High';
                logEntry.Core_When__c = system.now();
                logEntry.Core_Project__c = 'Sales';
              
                logEntry.Core_Message__c = 'Failed line number '+e.getLineNumber() ;
                logEntry.Core_Details__c = 'Req Body ' + reqBody +  'Error Message '+e.getStackTraceString();
                
                retWrp.ListlogEntry.add(logEntry);
        }
        return retWrp;
        //return retWr;
    }
    private static String GetSASToken(String resourceUri, String keyName, String key){
        long epoch = System.currentTimeMillis()/1000L;
        integer week = 60*60*24*7;
        String expiry = String.valueof(epoch + week);
        
        String sasToken = '';
        try {
            String stringToSign = EncodingUtil.urlEncode(resourceUri, 'UTF-8') + '\n' + expiry;
            String signature = getHMAC256(key, stringToSign);
            sasToken = 'SharedAccessSignature sr=' + EncodingUtil.urlEncode(resourceUri, 'UTF-8') +'&sig=' +
                EncodingUtil.urlEncode(signature, 'UTF-8') + '&se=' + expiry + '&skn=' + keyName;
        } catch (exception e) {  PMP_Utility.logError(e, 'Core_OpportunityKPICallout.GetSASToken');
       
        }
        return sasToken;
    }
    
    public static String getHMAC256(String key, String input) {
        String hash = '';
        String algorithmName = 'HmacSHA256';
            Blob mac = Crypto.generateMac(algorithmName, Blob.valueOf(input), Blob.valueOf(key));
            hash = EncodingUtil.base64Encode(mac);
        return hash;
    }
}