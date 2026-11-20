@RestResource(urlMapping='/productdetails/*')
global with sharing class OpportunityDataProcessor {
    // Wrapper class to hold the grouped data
    global class AccountOpportunityData {
        public String accountId { get; set; }
        public String accountName { get; set; }
        public Decimal accountTotalRevenueAmount { get; set; }
        public Integer openOpportunitiesCount { get; set; }
        public Decimal openOpportunitiesRevenue { get; set; }
        public Integer closedWonOpportunitiesCount { get; set; }
        public Decimal closedWonOpportunitiesRevenue { get; set; }
        public Integer closedLostOpportunitiesCount { get; set; }
        public Decimal closedLostOpportunitiesRevenue { get; set; }
        public List<OpportunityLineItemData> opportunityLineItems { get; set; }
		public Decimal ProductRevenue{get;set;}
        public Decimal productRevenueInPercentage { get; set; } // New field

        public AccountOpportunityData() {
            opportunityLineItems = new List<OpportunityLineItemData>();
            openOpportunitiesCount = 0;
            openOpportunitiesRevenue = 0;
            closedWonOpportunitiesCount = 0;
            closedWonOpportunitiesRevenue = 0;
            closedLostOpportunitiesCount = 0;
            closedLostOpportunitiesRevenue = 0;
	    ProductRevenue = 0;
            productRevenueInPercentage = 0; // Initialize the new field
        }
    }
    
    global class OpportunityLineItemData {
        public String opportunityId { get; set; }
        public String opportunityName { get; set; }
        public String stageName { get; set; }
        public Decimal sumUnitPrice { get; set; }
        public Decimal quantity { get; set; }
        public Decimal productTotalAmount { get; set; }
    }

    @HttpGet
    global static void getAccountOpportunityData() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        try {
            String productId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
            // Query the data
            String query = 'SELECT Opportunity.Name, MAX(OpportunityId) OppId, MAX(Opportunity.StageName) StageName,'+
                            ' MAX(Core_Account_Name__c) AccountName, MAX(Opportunity.AccountId) AccountId, '+ 
                            'MAX(Opportunity.Account.Core_Total_Approved_Revenue_Amount__c) AccountTotalRevenueAmount, '+
                            'SUM(UnitPrice) sumUnitPrice, SUM(Quantity) Quantity,  SUM(Core_Total_Amount__c) ProductTotalAmount '+
                            'FROM OpportunityLineItem WHERE Product2.Id = :productId '+
                            ' AND Opportunity.CloseDate = LAST_N_MONTHS:12 GROUP BY Opportunity.Name ORDER BY SUM(Core_Total_Amount__c) DESC';

            List<AggregateResult> results = Database.query(query);

            // Process the data and group by Account
            Map<String, AccountOpportunityData> accountDataMap = new Map<String, AccountOpportunityData>();

            for (AggregateResult result : results) {
                String accountId = (String) result.get('AccountId');
                String accountName = (String) result.get('AccountName');
                String opportunityId = (String) result.get('OppId');
                String opportunityName = (String) result.get('Name');
                String stageName = (String) result.get('StageName');
                Decimal accountTotalRevenueAmount = (Decimal) result.get('AccountTotalRevenueAmount');
                Decimal sumUnitPrice = (Decimal) result.get('sumUnitPrice');
                Decimal quantity = (Decimal) result.get('Quantity');
                Decimal productTotalAmount = (Decimal) result.get('ProductTotalAmount');

                if (!accountDataMap.containsKey(accountId)) {
                    AccountOpportunityData accountData = new AccountOpportunityData();
                    accountData.accountId = accountId;
                    accountData.accountName = accountName;
                    accountData.accountTotalRevenueAmount = accountTotalRevenueAmount;
                    accountDataMap.put(accountId, accountData);
                }

                OpportunityLineItemData lineItemData = new OpportunityLineItemData();
                lineItemData.opportunityId = opportunityId;
                lineItemData.stageName = stageName;
                lineItemData.sumUnitPrice = sumUnitPrice;
                lineItemData.quantity = quantity;
                lineItemData.productTotalAmount = productTotalAmount;
                lineItemData.opportunityName = opportunityName;

                AccountOpportunityData accountData = accountDataMap.get(accountId);
                accountData.opportunityLineItems.add(lineItemData);

                // Count and sum revenue based on stage
                if (stageName == 'Qualify' || stageName == 'Define' || stageName == 'Develop' || stageName == 'Design') {
                    accountData.openOpportunitiesCount++;
                    accountData.openOpportunitiesRevenue += productTotalAmount;
                } else if (stageName == 'Design Win' || stageName == 'Production Win') {
                    accountData.closedWonOpportunitiesCount++;
                    accountData.closedWonOpportunitiesRevenue += productTotalAmount;
                } else if (stageName == 'Lost' || stageName == 'Cancelled' || stageName == 'Production Lost' || stageName == 'Production Cancelled') {
                    accountData.closedLostOpportunitiesCount++;
                    accountData.closedLostOpportunitiesRevenue += productTotalAmount;
                }
            }

            // Calculate productRevenueInPercentage for each account
            for (AccountOpportunityData accountData : accountDataMap.values()) {
                Decimal totalRevenue = accountData.openOpportunitiesRevenue + accountData.closedWonOpportunitiesRevenue;
				accountData.ProductRevenue = totalRevenue;
                if (accountData.accountTotalRevenueAmount != null && accountData.accountTotalRevenueAmount > 0) {
                    accountData.productRevenueInPercentage = (totalRevenue / accountData.accountTotalRevenueAmount) * 100;
                } else {
                    accountData.productRevenueInPercentage = 0;
                }
            }

            String jsonResponse = JSON.serialize(accountDataMap.values());

            // Set the response 
            res.statusCode = 200;
            res.addHeader('Content-Type', 'application/json');
            res.responseBody = Blob.valueOf(jsonResponse);
        } catch (Exception e) {
            res.statusCode = 500;
            res.addHeader('Content-Type', 'application/json');
            res.responseBody = Blob.valueOf('{"error": "' + e.getMessage() + '"}');
        }
    }
}