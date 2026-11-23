public class Core_GetSalesSupportOrderDetails {
    
    public map<String,Core_System_Credentials__c> mapStringToCS = new map<String,Core_System_Credentials__c>();
    boolean openSeeds;
    boolean openSamples;
    
    public boolean toSelectApiCall( string APIName,String sOppId){
        for(Core_System_Credentials__c sobjCS : Core_System_Credentials__c.getAll().Values())
            mapStringToCS.put(sobjCS.Name, sobjCS);
        System.debug('mapStringToCS::'+mapStringToCS);

        if(APIName=='Sample' && String.isNotEmpty(sOppId)){
            pullSamples(sOppId);
            return Null;
        }else if(APIName=='Seed' && String.isNotEmpty(sOppId)){
            
            pullSeeds(sOppId);
            return Null;
        }else{
            return Null;
        }
        
    }
    
    public void pullSeeds(String sOppId) {
        System.debug('##### entered pullSeeds');    
        // Intialize the declared variables
        list<seedWebserviceWrapper> lstSeeds = new List<seedWebserviceWrapper> {};
                    try {
                        // Make the callout to the service
                        HTTPResponse httpResp = new HTTPResponse();
                      /*   
                        httpResp = Core_WebServiceUtility.restServiceCallout('', mapStringToCS.get(System.Label.Core_SeedsWebservice).Core_End_Point_URL__c +
                                                                             System.Label.Core_SeedsURLOpp + sOppId+'/ALL', 'Get', System.Label.Core_TimeOut,
                                                                             System.Label.Core_SeedsWebservice);  
                                 */                                          
                           httpResp = Core_WebServiceUtility.restServiceCallout('', 'callout:SalesCRM_Apigee' +
                                                                             System.Label.Core_SeedsURLOpp + sOppId+'/ALL', 'Get', System.Label.Core_TimeOut,
                                                                             System.Label.Core_SeedsWebservice);
                                                                         
                                                                                           
                        // Display an error message if we're not getting an OK response
                        if (httpResp.getStatusCode() != 200) {
                            System.debug(System.Label.Core_Exception);
                            return;
                        }else{
                            
                            // Use the parser to get the response as JSONParser type
                            system.debug('Request Body- '+httpResp.getbody());
                            system.JSONParser parser = JSON.createParser(httpResp.getbody());
                            
                            while (parser.nextToken() != NULL) {
                                // Start at the array of Records.
                                if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
                                    while (parser.nextToken() != NULL) {
                                        // Advance to the start object marker to find the next seed object
                                        if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                                            // Read entire seed object, including its array of line items
                                            seedWebserviceWrapper seed  = (seedWebserviceWrapper) parser.readValueAs(seedWebserviceWrapper.class);
                                            // Add the record to the list of Apex Objects
                                            lstSeeds.add(seed);
                                            parser.skipChildren();
                                        }
                                    }
                                }
                            }
                        }
                        // If the list of the Apex Object records to be rendered isn't empty, pull the opportunity & account IDs in them
                        if (!lstSeeds.isEmpty()) {
                            for (seedWebserviceWrapper seed : lstSeeds) {
                                system.debug('Result Seeds:'+seed);
                                //Business Logic.
                            }                
                        }
                    }
        catch(Exception e){
            System.debug('Exception msg ##########'+e.getmessage());
        }
    }
    
    /*
* Method name  : pullSamples
* Description  : Calls the REST web service to get a list of samples wrapper objects from the JSON response
*/  
    public void pullSamples(String sOppId) {
        System.debug('##### entered pullSamples');
        List<sampleWebserviceWrapper>   lstSamples = new List<sampleWebserviceWrapper>();
        try {
            // Make the callout to the service
            HTTPResponse httpResp = new HTTPResponse();
          // httpResp = Core_WebServiceUtility.restServiceCallout('', mapStringToCS.get('My Samples Service').Core_End_Point_URL__c +'/opportunity/' + sOppId, 'Get', System.Label.Core_TimeOut, 'My Samples Service');            // Display an error message if we're not getting an OK response
           
            httpResp = Core_WebServiceUtility.restServiceCallout('', 'callout:SalesCRM_Apigee' +'/opportunity/' + sOppId, 'Get', System.Label.Core_TimeOut, 'My Samples Service');     
           

           
            if (httpResp.getStatusCode() != 200) {
                System.debug(System.Label.Core_Exception);
                System.debug('##### httpResp.getBody = ' + httpResp.getbody());
                return;
            }
            // Use the parser to get the response as JSONParser type
            system.JSONParser parser = JSON.createParser(httpResp.getbody());
            while (parser.nextToken() != NULL) {
                // Start at the array of Records.
                if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
                    while (parser.nextToken() != NULL) {
                        // Advance to the start object marker to find the next sample object
                        if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                            // Read entire object
                            SampleWebserviceWrapper sample  = (SampleWebserviceWrapper) parser.readValueAs(SampleWebserviceWrapper.class);
                            // Add the record to the list of Apex Objects
                            lstSamples.add(sample);
                            parser.skipChildren();
                        }
                    }
                }
            }
            if (!lstSamples.isEmpty()) {
                for (SampleWebserviceWrapper sample : lstSamples) {
                    system.debug('Result Sample:'+sample.RequestID+' Status:'+sample.Status);
                    for (SampleOpportunityAssociation oppAssoc : sample.Opportunity) {
                        // Business logic.
                    }
                }
            }
        }
        catch (Exception e) {
            System.debug('Exception msg ##########'+e.getmessage());
        }
    }
    
    // Wrapper Class/Apex Object to hold seeds JSON response
    public class SeedWebserviceWrapper {
        
        public String AccountID { get; set; }
        public String AccountName { get; set; }
        
        public String OpportunityID { get; set; }
        public String OpportunityName { get; set; }
        
        public Integer OrderNumber { get; set; }
        public String OrderStatus { get; set; }
        
        public String RequestedDeliveryDate { get; set; }
        public String ReturnPickupDate { get; set; }
        
        public String Requestor { get; set; }
        public String Submitter { get; set; }
        
        public String ProductCode { get; set; }
        public String LineItemStatus { get; set; }
        public String ProductName { get; set; }
        
        public String EstimatedShipDate { get; set; }
        public String ActualShipDate { get; set; }
        
        public Integer RequestedQty { get; set; }
        public Integer ShippedQty { get; set; }
        
        public String ProductDesc { get; set; }
        public String ProductListDesc { get; set; }
        
        public String CompanyName { get; set; }
        
        public String StreetAddress1 { get; set; }
        public String StreetAddress2 { get; set; }
        public String MailStop { get; set; }
        public String City { get; set; }
        public String State { get; set; }
        public String ZipCode { get; set; }
        public String Country { get; set; }
        
        public String AttentionName { get; set; }
        public String AttentionNumber { get; set; }
        
        public String Notes { get; set; }
        
        public String Status { get; set; }
        
        public String Message { get; set; }
        
        public Boolean bRenderCSection { get; set; }
        
        public SeedWebserviceWrapper parse(String json) {
            
            //Deserialize the specified JSON string into an Apex object of the specified type.
            return (SeedWebserviceWrapper) System.JSON.deserialize(json, SeedWebserviceWrapper.class);
        }
    }
    
    // Wrapper class to hold samples JSON response
    public class SampleWebserviceWrapper{
        
        public String RequestProductID { get; set; }
        public String RequestID { get; set; }
        public String RDD { get; set; }
        public String Line { get; set; }
        public String RequestedMM { get; set; }
        public String RequestedEPMName { get; set; }
        public String ApprovedMM { get; set; }
        public String ApprovedEPMName { get; set; }
        public String Requester { get; set; }
        public String RequestQty { get; set; }
        public String ApprovedQty { get; set; }
        public String OBO { get; set; }
        public String ApproverName { get; set; }
        public String ApproverEmail { get; set; }
        public String Status { get; set; }
        public String Socket { get; set; }
        public String Media { get; set; }
        public String Stepping { get; set; }
        public String QDF { get; set; }
        public String BoxQuantity { get; set; }
        public String Contact { get; set; }
        public String CustomerName { get; set; }
        public String CustomerCMFID { get; set; }
        public String ShiptoCustomerName { get; set; }
        public String ShipToCustomerCMFID { get; set; }
        public String StreetAddress1 { get; set; }
        public String StreetAddress2 { get; set; }
        public String City { get; set; }
        public String StateName { get; set; }
        public String ZipCode { get; set; }
        public String Country { get; set; }
        public String ActualShipDtm { get; set; }
        public String TrackingIdForCarrier1Txt { get; set; }
        public String TrackingIdForCarrier2Txt { get; set; }
        public String CustomerCIMID { get; set; }
        public String DefaultCIM { get; set; }
        public String DefaultCIMID { get; set; }
        
        public List<SampleOpportunityAssociation> Opportunity { get; set; }
        
        public String GridViewAccountName { get; set; }
        public String GridViewOpportunityName { get; set; }
        public String GridViewOpportunityStage { get; set; }
        
        public String DetailViewCIMIDs { get; set; }
        public String DetailViewOppIDs { get; set; }
        
        //public String Message { get; set; }
        
        public Boolean bRenderCSection { get; set; }
        
        public SampleWebserviceWrapper parse(String json) {
            //Deserialize the specified JSON string into an Apex object of the specified type.
            return (SampleWebserviceWrapper) System.JSON.deserialize(json, SampleWebserviceWrapper.class);
        }
    }
    
    private class SampleOpportunityAssociation {
        private String AccountId;
        private String AccountName;
        private String AccountCIMID;
        private String OpportunityId;
        private String OpportunityName;
        private String OpportunityStage;
    }
}