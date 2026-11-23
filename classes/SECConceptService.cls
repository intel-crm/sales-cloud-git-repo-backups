public with sharing class SECConceptService {
      // Inner class must be PUBLIC so it’s accessible outside
       
    public class Filing {
        public String accessionNumber { get; set; }
        public String form { get; set; }
        public String filingDate { get; set; }
        public String primaryDocument { get; set; }
        public String filingUrl { get; set; }
    }
    
    @AuraEnabled
    public static List<Filing> getMajorFilings(String cik) {
        String url = 'https://data.sec.gov/submissions/CIK' + cik + '.json';
        
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod('GET');
        req.setHeader('User-Agent', 'Navneet Kaur (navneet@example.com)');
        req.setHeader('Accept', 'application/json');
        
        HttpResponse res = http.send(req);
        
        if (res.getStatusCode() == 200) {
            Map<String, Object> root = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            Map<String, Object> filings = (Map<String, Object>) ((Map<String, Object>) root.get('filings')).get('recent');
            
            List<Object> accessionNumbers = (List<Object>) filings.get('accessionNumber');
            List<Object> forms           = (List<Object>) filings.get('form');
            List<Object> filingDates     = (List<Object>) filings.get('filingDate');
            List<Object> primaryDocs     = (List<Object>) filings.get('primaryDocument');
            
            List<Filing> results = new List<Filing>();
            
            for (Integer i = 0; i < forms.size(); i++) {
                String formType = String.valueOf(forms[i]);
                String filingDate = String.valueOf(filingDates[i]);
                
                if ((formType == '10-K' || formType == '10-Q' || formType == '8-K') 
                    && filingDate.startsWith('2025')) {
                    
                    Filing f = new Filing();
                    f.form = formType;
                    f.filingDate = filingDate;
                    f.accessionNumber = String.valueOf(accessionNumbers[i]);
                    f.primaryDocument = String.valueOf(primaryDocs[i]);
                    
                    // Build SEC URL
                    String accNoNoHyphens = f.accessionNumber.replace('-', '');
                    f.filingUrl = 'https://www.sec.gov/Archives/edgar/data/' + 
                                   Integer.valueOf(cik) + '/' + accNoNoHyphens + '/' + f.primaryDocument;
                    
                    results.add(f);
                }
            }
            
            return results;
        } else {
            throw new CalloutException('Error: ' + res.getStatusCode() + ' ' + res.getBody());
        }
    }
  
}