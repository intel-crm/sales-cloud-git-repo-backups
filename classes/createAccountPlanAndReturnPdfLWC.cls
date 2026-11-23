public with sharing class createAccountPlanAndReturnPdfLWC {

    // ===== Response class =====
    public class AccountPlanResponse {
        @AuraEnabled public String pdfBase64 { get; set; }
        @AuraEnabled public String htmlContent { get; set; }
    }

    // ===== Financials =====
    public class FullYearFinancial {
        public String period { get; set; }
        public String revenue { get; set; }
        public String currency_usd { get; set; }
        public String units { get; set; }
    }

    // ===== News Summary =====
    public class NewsSummary {
        public String title { get; set; }
        public String category { get; set; }
        public String recommended_next_actions { get; set; }
    }

    // ===== SEC filings helper =====
    @AuraEnabled
    public static List<SECFilteredService.FilingResult> fetchSECFilings(String cik) {
        try {
            List<SECFilteredService.FilingResult> allFilings = SECFilteredService.getMajorFilings(cik);
            // Filter for 2025 only
            List<SECFilteredService.FilingResult> filings2025 = new List<SECFilteredService.FilingResult>();
            for(SECFilteredService.FilingResult f : allFilings){
                if(f.filingDate != null && f.filingDate.startsWith('2025')){
                    filings2025.add(f);
                }
            }
            return filings2025;
        } catch (Exception e) {
            System.debug('Error fetching SEC filings: ' + e.getMessage());
            return new List<SECFilteredService.FilingResult>();
        }
    }

    @AuraEnabled
    public static AccountPlanResponse createAccountPlanAndReturnPdfLWC(Id accountId) {
        if (accountId == null) {
            throw new AuraHandledException('Account Id is required.');
        }

        try {
            // ===== Call External API for Financials & News =====
            String apiKey = 'e5004c1140d8f59407647937b59a6ce8';  // Replace with actual key
            String apiUrl = 'https://sandbox-api-intel-insighthub-unrival-net-dzgxf3bjavbxdmgv.eastus-01.azurewebsites.net/account/001o000000ORQ8AAAX/complete?news_time_period=7d';  // Replace with actual URL
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            req.setEndpoint(apiUrl);
            req.setMethod('GET');
            req.setHeader('accept', 'application/json');
            req.setHeader('X-API-Key', apiKey);
            HttpResponse res = http.send(req);
            if (res.getStatusCode() != 200) {
                throw new AuraHandledException('API Error: ' + res.getBody());
            }

            Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());

            // ===== Financials =====
            FullYearFinancial fy = new FullYearFinancial();
            Map<String, Object> financial = (Map<String, Object>) result.get('financial');
            Map<String, Object> fullYear = (Map<String, Object>) financial.get('full_year');
            if (fullYear != null) {
                fy.period = String.valueOf(fullYear.get('period'));
                fy.currency_usd = String.valueOf(fullYear.get('currency'));
                fy.units = String.valueOf(fullYear.get('units'));
                fy.revenue = String.valueOf(fullYear.get('revenue'));
            }

            // ===== News Summary =====
            Map<String, Object> newsData = (Map<String, Object>) result.get('news');

            // ===== Query Salesforce data =====
            Account acc = [
                SELECT Name, Industry, Owner.Name, Owner.ManagerId, Owner.Manager.Name, ParentId
                FROM Account WHERE Id ='001Df00000iaYQfIAM' LIMIT 1
            ];

            List<Opportunity> opps = [
                SELECT Name, Amount, Description 
                FROM Opportunity 
                WHERE AccountId ='001Df00000mEOirIAG' AND IsClosed = false limit 5
            ];

            // Owner hierarchy
            List<User> ownerHierarchy = new List<User>();
            Set<Id> seen = new Set<Id>();
            User current = acc.Owner;
            while (current != null && !seen.contains(current.Id)) {
                seen.add(current.Id);
                ownerHierarchy.add(current);
                if (current.ManagerId != null) {
                    current = [SELECT Id, Name, ManagerId, Manager.Name FROM User WHERE Id = :current.ManagerId LIMIT 1];
                } else {
                    break;
                }
            }

            // SEC filings
            List<SECFilteredService.FilingResult> secFilings = new List<SECFilteredService.FilingResult>();
            secFilings = fetchSECFilings('0000320193'); // Dummy CIK

            // ===== Build HTML =====
            String html = '';
            html += '<h2 style="text-align:left;">Account Plan Executive Summary</h2>';

            // Flex container
            html += '<div style="display:flex; gap:20px; align-items:stretch;">';

            // Left Box: Account Statistics + Financials
            html += '<div style="border:2px solid #000; padding:15px; width:50%; background-color:#f9f9f9;">';
            html += '<h3 style="text-align:center;">ACCOUNT Statistics / Snapshot</h3>';
            html += '<ul>';
            html += '<li><strong>Account Name:</strong>  Walmart' + '</li>'; //acc.Name
            html += '<li><strong>Industry:</strong> ' + acc.Industry + '</li>';
            html += '<li><strong>Owner:</strong> ' + acc.Owner.Name + '</li>';
            html += '<li><strong>Annual Revenue:</strong> ' + fy.period + ' - ' + fy.revenue + ' ' + fy.currency_usd + ' (' + fy.units + ')</li>';
            html += '</ul>';

            // News Summary
            if(newsData != null && newsData.containsKey('latest_news')) {
                html += '<h3>Recent Customer Announcements</h3><ul>';
                List<Object> newsList = (List<Object>) newsData.get('latest_news');
                for(Object obj : newsList) {
                    Map<String, Object> newsItem = (Map<String, Object>) obj;
                    String title = (String) newsItem.get('title');
                    String category = (String) newsItem.get('category');
                    html += '<li><strong>' + title + '</strong>';
                    if(category != null && category != '') html += ' - ' + category;
                    html += '</li>';
                }
                html += '</ul>';
            }

            html += '</div>'; // end left box

            // Right Box: Recommended Next Actions
            html += '<div style="border:2px solid #000; padding:15px; width:50%; background-color:#f0f0f0;">';
            html += '<h3>Recommended Next Actions</h3>';
            if(newsData != null && newsData.containsKey('latest_news')) {
                List<Object> newsList = (List<Object>) newsData.get('latest_news');
                html += '<ul>';
                for(Object obj : newsList) {
                    Map<String, Object> newsItem = (Map<String, Object>) obj;
                    if(newsItem.containsKey('recommended_next_actions') && newsItem.get('recommended_next_actions') instanceof List<Object>) {
                        List<Object> actions = (List<Object>) newsItem.get('recommended_next_actions');
                        for(Object actionObj : actions) {
                            if(actionObj != null) html += '<li>' + String.valueOf(actionObj) + '</li>';
                        }
                    }
                }
                html += '</ul>';
            }
            html += '</div>'; // end right box
            html += '</div>'; // end flex container

            // Owner Hierarchy as Table
            html += '<div style="margin-top:20px;"><h3>Owner Hierarchy</h3>';
            if(ownerHierarchy.isEmpty()) {
                html += '<p>Not available.</p>';
            } else {
                html += '<table border="1" cellpadding="6" style="border-collapse:collapse; width:50%; font-family:Arial, sans-serif;">';
                html += '<tr style="background-color:#eaeaea;"><th>Name</th></tr>';
                for(User u : ownerHierarchy) {
                    html += '<tr>';
                    html += '<td>' + u.Name + '</td>';
                    html += '</tr>';
                }
                html += '</table>';
            }
            html += '</div>';

            // Opportunities
            html += '<div style="margin-top:20px;"><h3>Opportunities</h3>';
            if(opps.isEmpty()) html += '<p>No open opportunities.</p>';
            else {
                html += '<table border="1" cellpadding="6" style="border-collapse:collapse; width:100%;">';
                html += '<tr style="background-color:#eaeaea;"><th>Name</th><th>Amount</th><th>Description</th></tr>';
                for(Opportunity o : opps) {
                    html += '<tr>';
                    html += '<td>' + o.Name + '</td>';
                    html += '<td>' + (o.Amount != null ? String.valueOf(o.Amount) : '-') + '</td>';
                    html += '<td>' + (o.Description != null ? o.Description : '-') + '</td>';
                    html += '</tr>';
                }
                html += '</table>';
            }
            html += '</div>';

            // SEC Filings (2025 only)
            html += '<div style="margin-top:20px;"><h3>Recent SEC Filings (2025)</h3>';
            if(secFilings.isEmpty()) html += '<p>No SEC filings found for 2025.</p>';
            else {
                html += '<table border="1" cellpadding="6" style="border-collapse:collapse; width:100%;">';
                html += '<tr style="background-color:#eaeaea;"><th>Form</th><th>Date</th><th>Accession</th><th>Link</th></tr>';
                for(SECFilteredService.FilingResult f : secFilings) {
                    html += '<tr>';
                    html += '<td>' + f.formType + '</td>';
                    html += '<td>' + f.filingDate + '</td>';
                    html += '<td>' + f.accession + '</td>';
                    html += '<td><a href="' + f.url + '" target="_blank">View</a></td>';
                    html += '</tr>';
                }
                html += '</table>';
            }
            // ===== Meeting Notes Section (Hardcoded) =====
            html += '<div style="margin-top:20px;"><h3>Meeting Notes</h3>';
            html += '<table border="1" cellpadding="6" style="border-collapse:collapse; width:100%; font-family:Arial, sans-serif;">';
            html += '<tr style="background-color:#eaeaea;"><th>Date</th><th>Attendees</th><th>Agenda</th><th>Notes</th></tr>';
            
            // Example dummy meeting notes
            html += '<tr>';
            html += '<td>18-Sep-2025</td>';
            html += '<td>Navneet Kaur, John Smith,Rajesh Kumar</td>';
            html += '<td>Review Q3 performance, Upcoming opportunities</td>';
            html += '<td>Q3 revenue slightly below forecast. Follow-up on Cloud Migration Project by John Smith. Executive briefing scheduled 25-Sep.</td>';
            html += '</tr>';
            
            html += '<tr>';
            html += '<td>20-Sep-2025</td>';
            html += '<td>Navneet Kaur, John Smith</td>';
            html += '<td>Account strategy discussion</td>';
            html += '<td>Prioritize Q4 initiatives. Risk: vendor delays escalated to procurement. Next meeting 25-Sep.</td>';
            html += '</tr>';
            
            html += '</table>';
            html += '</div>';
            html += '</div>';

            // Build response
            AccountPlanResponse response = new AccountPlanResponse();
            response.htmlContent = html;
            // TODO: Generate PDF if needed
            // response.pdfBase64 = EncodingUtil.base64Encode(pdfBlob);

            return response;

        } catch(Exception e) {
            throw new AuraHandledException('Error generating Account Plan: ' + e.getMessage());
        }
    }
}