public with sharing class SECFilteredService {
    
    public class FilingResponse {
        public Filings filings;
    }
    public class Filings {
        public Recent recent;
    }
    public class Recent {
        public List<String> accessionNumber;
        public List<String> form;
        public List<String> filingDate;
        public List<String> primaryDocument;
    }
    
    public class FilingResult {
        @AuraEnabled public String formType { get; set; }
        @AuraEnabled public String filingDate { get; set; }
        @AuraEnabled public String accession { get; set; }
        @AuraEnabled public String url { get; set; }
    }
    
    @AuraEnabled
    public static List<FilingResult> getMajorFilings(String cik) {
        String url = 'https://data.sec.gov/submissions/CIK' + cik + '.json';
        
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod('GET');
        req.setHeader('User-Agent', 'Navneet Kaur (navneet@example.com)');
        
        HttpResponse res = http.send(req);
        if (res.getStatusCode() != 200) {
            throw new CalloutException('Error: ' + res.getStatusCode() + ' ' + res.getBody());
        }
        
        FilingResponse data = (FilingResponse) JSON.deserialize(res.getBody(), FilingResponse.class);
        system.debug('line39'+data.filings.recent.form.size());
        List<FilingResult> results = new List<FilingResult>();
        
        for (Integer i = 0; i < data.filings.recent.form.size(); i++) {
            String formType = data.filings.recent.form[i];
            String filingDate = data.filings.recent.filingDate[i];

              if ((formType == '10-K' || formType == '10-Q' || formType == '8-K') && 
                filingDate != null && filingDate.startsWith('2025')) {
                FilingResult f = new FilingResult();
                f.formType = formType;
                f.filingDate = data.filings.recent.filingDate[i];
                f.accession = data.filings.recent.accessionNumber[i];
                
                // Build SEC filing URL
                String cikClean = String.valueOf(Integer.valueOf(cik)); // strip leading zeros
                String accClean = data.filings.recent.accessionNumber[i].replace('-', '');
                String doc = data.filings.recent.primaryDocument[i];
                f.url = 'https://www.sec.gov/Archives/edgar/data/' + cikClean + '/' + accClean + '/' + doc;
                
                results.add(f);
            }
            system.debug('line 57'+results);
        }
        
        return results;
    }
}