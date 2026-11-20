/****************************************************************************************************************************************
* Class Name  : Core_WebQuotesController 
* Version     : 1.0 
* Created Date: 02-Aug-2023
* Modification Log :
* Developer                        Date                Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Hira Khan(Accenture - Unicorn)   02-Aug-2023         Controller Class for Core_WebQuotes LWC(TWC3123-4860)
*****************************************************************************************************************************************/
public class Core_WebQuotesController {
    
/***********************************************
* Method name  : pullWebQuotes
* Description  : Method to pull WebQuotes Data
* Return Type  : WebQuoteData
* Parameter    : Id oppId
************************************************/     
    @AuraEnabled(cacheable=true) 
    public static WebQuoteData pullWebQuotes(Id OppId)
    {
        String jsonStr;
        
        // Only pull quotes if we haven't yet pulled them (a full page refresh is needed to call the web service again)        
        List<WebQuote> quotes = new List<WebQuote> {};
            List<WebQuote> webQuotes = new List<WebQuote>();
        WebQuoteData WebQuoteDataWrap=new WebQuoteData();
        try{
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:SalesCRM_Apigee' + '/p2d/webquote/v1/quotes?sf_id='+OppId);
            req.setMethod('GET');
            req.setHeader('Content-Type' , 'application/json');  
            HttpResponse resp = new Http().send(req);
            if(resp.getStatus() == 'SUCCESS' || resp.getStatus() == 'OK'){
                jsonStr = resp.getBody();
            }
            
            // Display an error message if we're not getting an OK response
            if (resp.getStatusCode() != 200) {
                WebQuoteDataWrap.bQuotesErrorFlag = true;
                WebQuoteDataWrap.bQuotesErrorMessage=System.Label.Core_Exception;
            }
            
            System.JSONParser parser = JSON.createParser(jsonStr);
            while (parser.nextToken() != null) {
                // Start at the array of webquotes.
                if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
                    while (parser.nextToken() != null) {
                        // Advance to the start object marker to
                        //  find next webquote object.
                        if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                            // Read entire webquote object
                            webQuotes.add((WebQuote)parser.readValueAs(WebQuote.class));
                            
                            //Skip the child start array and start object markers.
                            parser.skipChildren();
                        }
                    }
                }
            }
            for(WebQuote wb:webQuotes){
                wb.quote_link = Label.Web_Quote_Link + wb.quote_name.substringBefore('.');
            }
            if(!webQuotes.isEmpty()){ 
                quotes = webQuotes;  
            }
        }
        catch (Exception e) {
            PMP_Utility.logError(e, 'Core_WebQuotesController.pullWebQuotes');
            WebQuoteDataWrap.bQuotesErrorFlag = true;
            WebQuoteDataWrap.bQuotesErrorMessage=System.Label.Core_Exception + e.getmessage();
            
        }
        WebQuoteDataWrap.WebQuoteList=webQuotes;
        return WebQuoteDataWrap;
    }
    //Wrapper Class/Apex Object to hold WebQuotes JSON response
    public class WebQuote {
        @AuraEnabled
        public string quote_name { get; set; }
        @AuraEnabled
        public string creator{ get; set; }
        @AuraEnabled
        public date cre_dt{ get; set; }
        @AuraEnabled
        public string quote_type{ get; set; }
        @AuraEnabled
        public string quote_status { get; set; }
        @AuraEnabled
        public string prd_dsc{ get; set; }
        @AuraEnabled
        public double disti_cost{ get; set; }
        @AuraEnabled
        public double intel_prc{ get; set; }
        @AuraEnabled
        public double aprv_prc{ get; set; }
        @AuraEnabled
        public Integer approved_quantity{ get; set; }
        @AuraEnabled
        public date dpa_vld_fr_dt{ get; set; }
        @AuraEnabled
        public date dpa_expr_dt{ get; set; }
        @AuraEnabled
        public Integer dpa_number{ get; set; }
        @AuraEnabled
        public string quote_link { get; set; }
        @AuraEnabled
        public double intel_prc_sdc{ get; set; }
        @AuraEnabled
        public string creation_type{ get; set; }
    }  
    public class WebQuoteData {
        @AuraEnabled
        public List<WebQuote> WebQuoteList{get;set;}
        @AuraEnabled
        public Boolean bQuotesErrorFlag{get; set; }
        @AuraEnabled
        public String bQuotesErrorMessage{get; set; }
    }
}