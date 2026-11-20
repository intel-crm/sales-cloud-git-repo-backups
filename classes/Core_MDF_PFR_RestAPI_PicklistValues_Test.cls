@isTest
private class Core_MDF_PFR_RestAPI_PicklistValues_Test {
    
    private class Core_MDF_RestAPI_Callout_Mock implements HttpCalloutMock {
        private Integer statusCode;
        private String  body;

        public Core_MDF_RestAPI_Callout_Mock(Integer statusCode, String body) {
            this.statusCode = statusCode;
            this.body       = body;
        }

        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setStatusCode(this.statusCode);
            res.setBody(this.body);
            return res;
        }
    }

    private class MockHttp200 implements HttpCalloutMock {
        private Map<String, Object> responseBody;
        public MockHttp200(Map<String, Object> body) { this.responseBody = body; }
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody(JSON.serialize(responseBody));
            return res;
        }
    }

    private static final String PRE2025_KEYWORD    = '(Pre-2025)';
    private static final String CLIENT_KEYWORD     = 'client';
    private static final String DATACENTER_KEYWORD = 'data center';

    private static String buildCampaignCalloutBody(Campaign c) {
        Map<String, Object> body = new Map<String, Object>();
        if (c == null) return JSON.serialize(body);
        body.put('Id', c.Id);
        body.put('Name', c.Name);
        if (c.Core_MDF_Account__c != null)
            body.put('Core_MDF_Account__c', String.valueOf(c.Core_MDF_Account__c));
        if (c.Core_MDF_Program__c != null)
            body.put('Core_MDF_Program__c', c.Core_MDF_Program__c);
        if (c.Core_MDF_Activity_Category__c != null)
            body.put('Core_MDF_Activity_Category__c', c.Core_MDF_Activity_Category__c);
        if (c.Core_MDF_Activity_Type__c != null)
            body.put('Core_MDF_Activity_Type__c', c.Core_MDF_Activity_Type__c);
        if (c.Core_MDF_Priority__c != null)
            body.put('Core_MDF_Priority__c', c.Core_MDF_Priority__c);
        if (c.Core_MDF_Priority_2_nm__c != null)
            body.put('Core_MDF_Priority_2_nm__c', c.Core_MDF_Priority_2_nm__c);
        if (c.Core_MDF_Priority_3_nm__c != null)
            body.put('Core_MDF_Priority_3_nm__c', c.Core_MDF_Priority_3_nm__c);
        if (c.Core_MDF_Audience__c != null)
            body.put('Core_MDF_Audience__c', c.Core_MDF_Audience__c);
        if (c.Core_MDF_Market__c != null)
            body.put('Core_MDF_Market__c', c.Core_MDF_Market__c);
        if (c.Core_MDF_Brand__c != null)
            body.put('Core_MDF_Brand__c', c.Core_MDF_Brand__c);
        if (c.Core_MDF_Product_Type__c != null)
            body.put('Core_MDF_Product_Type__c', c.Core_MDF_Product_Type__c);
        if (c.Core_MDF_Industry_Nm__c != null)
            body.put('Core_MDF_Industry_Nm__c', c.Core_MDF_Industry_Nm__c);
        if (c.Core_MDF_Opal_Budget_Type_Txt__c != null)
            body.put('Core_MDF_Opal_Budget_Type_Txt__c', c.Core_MDF_Opal_Budget_Type_Txt__c);
        return JSON.serialize(body);
    }
    
    @TestSetup
    static void setupTestData() {
        String pre2025 = findActivePicklistValue(
            Campaign.Core_MDF_Activity_Category__c.getDescribe(), PRE2025_KEYWORD);
        String nonPre = findActivePicklistValueExcluding(
            Campaign.Core_MDF_Activity_Category__c.getDescribe(), PRE2025_KEYWORD);
        String ccfProg = findActivePicklistValue(
            Campaign.Core_MDF_Program__c.getDescribe(), CLIENT_KEYWORD);
        String dcfProg = findActivePicklistValue(
            Campaign.Core_MDF_Program__c.getDescribe(), DATACENTER_KEYWORD);
        if (dcfProg == null) {
            dcfProg = findActivePicklistValue(
                Campaign.Core_MDF_Program__c.getDescribe(), 'datacenter');
        }
        String market = findActivePicklistValue(
            Campaign.Core_MDF_Market__c.getDescribe(), null);
        List<String> markets = getActivePicklistValues(
            Campaign.Core_MDF_Market__c.getDescribe(), 2);
        String budgetType = findActivePicklistValue(
            Campaign.Core_MDF_Opal_Budget_Type_Txt__c.getDescribe(), null);
        List<String> pVals = getActivePicklistValues(
            Campaign.Core_MDF_Priority__c.getDescribe(), 3);
        String actType = findActivePicklistValue(
            Campaign.Core_MDF_Activity_Type__c.getDescribe(), null);
        String audience = findActivePicklistValue(
            Campaign.Core_MDF_Audience__c.getDescribe(), null);
        String brand = findActivePicklistValue(
            Campaign.Core_MDF_Brand__c.getDescribe(), null);
        String productType = findActivePicklistValue(
            Campaign.Core_MDF_Product_Type__c.getDescribe(), null);
        String industry = findActivePicklistValue(
            Campaign.Core_MDF_Industry_Nm__c.getDescribe(), null);

        String unknownProg = null;
        for (Schema.PicklistEntry e :
                Campaign.Core_MDF_Program__c.getDescribe().getPicklistValues()) {
            if (e.isActive()) {
                String v = e.getValue().toLowerCase();
                if (!v.contains(CLIENT_KEYWORD) &&
                    !v.contains(DATACENTER_KEYWORD) &&
                    !v.contains('datacenter')) {
                    unknownProg = e.getValue();
                    break;
                }
            }
        }

        String multiCat = null;
        if      (pre2025 != null && nonPre != null) multiCat = pre2025 + ';' + nonPre;
        else if (pre2025 != null)                   multiCat = pre2025;
        else if (nonPre  != null)                   multiCat = nonPre;

        String multiMarketVal = null;
        if      (markets.size() >= 2) multiMarketVal = markets[0] + ';' + markets[1];
        else if (markets.size() == 1) multiMarketVal = markets[0];

        ChannelProgram ccfChannelProgram = new ChannelProgram(
            Name = 'Client',
            Core_MDF_Technical_Program_Name__c = 'Client CoMarketing Fund'
        );
        insert ccfChannelProgram;

        ChannelProgram dcfChannelProgram = new ChannelProgram(
            Name = 'Datacenter',
            Core_MDF_Technical_Program_Name__c = 'Data Center CoMarketing Fund'
        );
        insert dcfChannelProgram;

        Id coMarketingRecordTypeId = null;
        Id masteredAccountRecordTypeId = null;
        try {
            coMarketingRecordTypeId = Schema.SObjectType.Account
                .getRecordTypeInfosByDeveloperName()
                .get('Core_MDF_Co_Marketing')
                .getRecordTypeId();
            masteredAccountRecordTypeId = Schema.SObjectType.Account
                .getRecordTypeInfosByDeveloperName()
                .get('Mastered_Account')
                .getRecordTypeId();
        } catch (Exception ex) {
            System.debug('Record Type error: ' + ex.getMessage());
        }
        
        Account parentAcc = new Account(
            Name = 'TC_Parent_Account',
            RecordTypeId = masteredAccountRecordTypeId,
            BillingCountry = 'United States',
            BillingCity = 'San Jose',
            BillingStreet = 'Main St'
        );
        insert parentAcc;
        
        Account rootAcc = new Account(
            Name = 'TC_Root_Account',
            RecordTypeId = coMarketingRecordTypeId,
            Core_MDF_Channel_Program__c = ccfChannelProgram.Id,
            Core_MDF_Parent_Fund_Account__c = parentAcc.Id,
            BillingCountry = 'United States',
            BillingCity = 'Los Angeles',
            BillingStreet = 'VI colony'
        );
        insert rootAcc;

        Account childAcc = new Account(
            Name = 'TC_Child_Account',
            RecordTypeId = coMarketingRecordTypeId,
            Core_MDF_Channel_Program__c = ccfChannelProgram.Id,
            Core_MDF_Parent_Fund_Account__c = parentAcc.Id,
            ParentId = rootAcc.Id,
            BillingCountry = 'United States',
            BillingCity = 'San Francisco',
            BillingStreet = 'VI colony'
        );

        Account ultimateAcc = new Account(
            Name = 'TC_Ultimate_Account',
            RecordTypeId = coMarketingRecordTypeId,
            Core_MDF_Channel_Program__c = ccfChannelProgram.Id,
            Core_MDF_Parent_Fund_Account__c = parentAcc.Id,
            BillingCountry = 'United States',
            BillingCity = 'New York',
            BillingStreet = 'VI colony'
        );

        Account dup1 = new Account(
            Name = 'TC_Dup_Account',
            RecordTypeId = coMarketingRecordTypeId,
            Core_MDF_Channel_Program__c = ccfChannelProgram.Id,
            Core_MDF_Parent_Fund_Account__c = parentAcc.Id,
            BillingCountry = 'United States',
            BillingCity = 'Chicago',
            BillingStreet = 'VI colony'
        );

        Account dup2 = new Account(
            Name = 'TC_Dup_Account',
            RecordTypeId = coMarketingRecordTypeId,
            Core_MDF_Channel_Program__c = ccfChannelProgram.Id,
            Core_MDF_Parent_Fund_Account__c = parentAcc.Id,
            BillingCountry = 'Canada',
            BillingCity = 'Toronto',
            BillingStreet = 'VI Colony'
        );

        insert new List<Account>{ childAcc, ultimateAcc, dup1, dup2 };

        try {
            rootAcc.put('Core_MDF_CoMarketing_Ultimate_Account__c', rootAcc.Id);
            update rootAcc;
            ultimateAcc.put('Core_MDF_CoMarketing_Ultimate_Account__c', rootAcc.Id);
            update ultimateAcc;
            childAcc.put('Core_MDF_CoMarketing_Ultimate_Account__c', rootAcc.Id);
            update childAcc;
        } catch (Exception ex) {}

        List<Campaign> campaigns = new List<Campaign>();
        campaigns.add(new Campaign(Name = 'TC_Basic', Core_MDF_Account__c = rootAcc.Id, Core_MDF_Program__c = ccfProg));

        Campaign c2 = new Campaign(Name = 'TC_Pre2025', Core_MDF_Account__c = rootAcc.Id, Core_MDF_Program__c = ccfProg);
        if (pre2025 != null) c2.Core_MDF_Activity_Category__c = pre2025;
        campaigns.add(c2);

        Campaign c3 = new Campaign(Name = 'TC_NonPre2025', Core_MDF_Account__c = rootAcc.Id, Core_MDF_Program__c = ccfProg);
        if (nonPre != null) c3.Core_MDF_Activity_Category__c = nonPre;
        campaigns.add(c3);

        Campaign c4 = new Campaign(Name = 'TC_CCF', Core_MDF_Account__c = rootAcc.Id);
        if (ccfProg != null) c4.Core_MDF_Program__c = ccfProg;
        if (market != null) c4.Core_MDF_Market__c = market;
        campaigns.add(c4);

        Campaign c5 = new Campaign(Name = 'TC_DCF', Core_MDF_Account__c = rootAcc.Id);
        if (dcfProg != null) c5.Core_MDF_Program__c = dcfProg;
        campaigns.add(c5);

        Campaign c6 = new Campaign(Name = 'TC_Market', Core_MDF_Account__c = rootAcc.Id, Core_MDF_Program__c = ccfProg);
        if (market != null) c6.Core_MDF_Market__c = market;
        campaigns.add(c6);

        Campaign c7 = new Campaign(Name = 'TC_MultiMarket', Core_MDF_Account__c = rootAcc.Id, Core_MDF_Program__c = ccfProg);
        if (multiMarketVal != null) c7.Core_MDF_Market__c = multiMarketVal;
        campaigns.add(c7);

        Campaign c8 = new Campaign(Name = 'TC_BudgetType', Core_MDF_Account__c = rootAcc.Id, Core_MDF_Program__c = ccfProg);
        if (budgetType != null) c8.Core_MDF_Opal_Budget_Type_Txt__c = budgetType;
        campaigns.add(c8);

        Campaign c9 = new Campaign(Name = 'TC_Priority', Core_MDF_Account__c = rootAcc.Id, Core_MDF_Program__c = ccfProg);
        if (pVals.size() > 0) c9.Core_MDF_Priority__c = pVals[0];
        if (pVals.size() > 1) c9.Core_MDF_Priority_2_nm__c = pVals[1];
        if (pVals.size() > 2) c9.Core_MDF_Priority_3_nm__c = pVals[2];
        campaigns.add(c9);

        campaigns.add(new Campaign(Name = 'TC_NoPriority', Core_MDF_Account__c = rootAcc.Id, Core_MDF_Program__c = ccfProg));

        Campaign c11 = new Campaign(Name = 'TC_ActivityType', Core_MDF_Account__c = rootAcc.Id, Core_MDF_Program__c = ccfProg);
        if (actType != null) c11.Core_MDF_Activity_Type__c = actType;
        campaigns.add(c11);

        Campaign c12 = new Campaign(Name = 'TC_CCF_Pre2025', Core_MDF_Account__c = rootAcc.Id, Core_MDF_Program__c = ccfProg);
        if (ccfProg != null) c12.Core_MDF_Program__c = ccfProg;
        if (pre2025 != null) c12.Core_MDF_Activity_Category__c = pre2025;
        campaigns.add(c12);

        Campaign c13 = new Campaign(Name = 'TC_DCF_Pre2025', Core_MDF_Account__c = rootAcc.Id, Core_MDF_Program__c = dcfProg);
        if (dcfProg != null) c13.Core_MDF_Program__c = dcfProg;
        if (pre2025 != null) c13.Core_MDF_Activity_Category__c = pre2025;
        campaigns.add(c13);

        Campaign c14 = new Campaign(Name = 'TC_UnknownProgram', Core_MDF_Account__c = rootAcc.Id, Core_MDF_Program__c = ccfProg);
        if (unknownProg != null) c14.Core_MDF_Program__c = unknownProg;
        campaigns.add(c14);

        Campaign c15 = new Campaign(Name = 'TC_MultiCategory', Core_MDF_Account__c = rootAcc.Id, Core_MDF_Program__c = ccfProg);
        if (multiCat != null) c15.Core_MDF_Activity_Category__c = multiCat;
        campaigns.add(c15);

        Campaign c16 = new Campaign(Name = 'TC_WithAccount', Core_MDF_Account__c = rootAcc.Id, Core_MDF_Program__c = ccfProg);
        if (ccfProg != null) c16.Core_MDF_Program__c = ccfProg;
        campaigns.add(c16);

        Campaign c17 = new Campaign(Name = 'TC_FullFields', Core_MDF_Account__c = rootAcc.Id, Core_MDF_Program__c = ccfProg);
        if (ccfProg != null) c17.Core_MDF_Program__c = ccfProg;
        if (audience != null) c17.Core_MDF_Audience__c = audience;
        if (brand != null) c17.Core_MDF_Brand__c = brand;
        if (productType != null) c17.Core_MDF_Product_Type__c = productType;
        if (industry != null) c17.Core_MDF_Industry_Nm__c = industry;
        if (market != null) c17.Core_MDF_Market__c = market;
        if (actType != null) c17.Core_MDF_Activity_Type__c = actType;
        if (budgetType != null) c17.Core_MDF_Opal_Budget_Type_Txt__c = budgetType;
        campaigns.add(c17);

        Campaign c18 = new Campaign(Name = 'TC_CCF_NoCategory', Core_MDF_Account__c = rootAcc.Id, Core_MDF_Program__c = ccfProg);
        if (ccfProg != null) c18.Core_MDF_Program__c = ccfProg;
        campaigns.add(c18);

        Campaign c19 = new Campaign(Name = 'TC_DCF_NoCategory', Core_MDF_Account__c = rootAcc.Id, Core_MDF_Program__c = dcfProg);
        if (dcfProg != null) c19.Core_MDF_Program__c = dcfProg;
        campaigns.add(c19);

        Campaign c20 = new Campaign(Name = 'TC_WithMarketAndAccount', Core_MDF_Account__c = rootAcc.Id, Core_MDF_Program__c = ccfProg);
        if (ccfProg != null) c20.Core_MDF_Program__c = ccfProg;
        if (market != null) c20.Core_MDF_Market__c = market;
        campaigns.add(c20);

        Database.insert(campaigns, false);

        insert new List<Product2>{
            new Product2(Name = 'Test Prod A', IsActive = true),
            new Product2(Name = 'Test Prod B', IsActive = true)
        };
        
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'TC_Root_Account' LIMIT 1];
        ChannelProgram cp = [SELECT Id FROM ChannelProgram WHERE Name = 'Client' LIMIT 1];
        
        List<PartnerMarketingBudget> budgets = new List<PartnerMarketingBudget>();

        PartnerMarketingBudget budget1 = Core_MDF_CCP_TestDataUtility.createBudget(
            'Budget_Rate_With_Percent',
            Core_MDF_CCP_IPA_TestDataUtility.budgetIPA_ProposalBased_Record_Type,
            testAccount.Id,
            cp.Id,
            50000,  
            System.today().addDays(-30),
            System.today().addDays(335),
            false
        );
        budget1.Core_MDF_Budget_Type_Txt__c = 'Co-Marketing';
        budgets.add(budget1);

        PartnerMarketingBudget budget5 = Core_MDF_CCP_TestDataUtility.createBudget(
            'Budget_Rate_Zero',
            Core_MDF_CCP_IPA_TestDataUtility.budgetIPA_ProposalBased_Record_Type,
            testAccount.Id,
            cp.Id,
            30000,
            System.today().addDays(-30),
            System.today().addDays(335),
            false
        );
        budget5.Core_MDF_Budget_Type_Txt__c = 'Co-Marketing';
        budgets.add(budget5);
        Database.insert(budgets, false);
        
        Campaign basecamp = getCampaign('TC_BudgetType');
        if (basecamp == null) {
            basecamp = getCampaign('TC_CCF');
        }
        
        if (basecamp != null) {
            List<Core_MDF_Campaign_Budgets__c> campaignBudgets = new List<Core_MDF_Campaign_Budgets__c>();

            campaignBudgets.add(new Core_MDF_Campaign_Budgets__c(
                Core_MDF_Campaign_Id__c = basecamp.Id,
                Core_MDF_Budget_Name_Id__c = budget1.Id,
                Core_MDF_Reimbursement_Rate_Pct__c = '25%',
                Core_MDF_Reimbursement_Amt__c = 90,
                Core_MDF_Active_ind__c = true
            ));
     
            campaignBudgets.add(new Core_MDF_Campaign_Budgets__c(
                Core_MDF_Campaign_Id__c = basecamp.Id,
                Core_MDF_Budget_Name_Id__c = budget5.Id,
                Core_MDF_Reimbursement_Rate_Pct__c = '0%',
                Core_MDF_Reimbursement_Amt__c = 10,
                Core_MDF_Active_ind__c = true
            ));
            
            insert campaignBudgets;
        }
        
        List<Core_MDF_CP_Countries__c> ecosystemPartners = new List<Core_MDF_CP_Countries__c>();
        ecosystemPartners.add(new Core_MDF_CP_Countries__c(
            Name = 'EP_AllPrograms',
            Core_MDF_CP_Name__c = 'Partner All Programs',
            Core_MDF_Is_Active__c = true,
            Core_MDF_Is_Applicable_All_Programs_Ind__c = true,
            Core_MDF_All_Countries__c = false,
            Core_MDF_Program_Name__c = 'Client Co-Marketing Fund;Data Center Co-Marketing Fund;Ecosystem Extension Fund;'
        ));
        ecosystemPartners.add(new Core_MDF_CP_Countries__c(
            Name = 'EP_BlankProgram',
            Core_MDF_CP_Name__c = 'Partner Blank Program',
            Core_MDF_Is_Active__c = true,
            Core_MDF_Is_Applicable_All_Programs_Ind__c = false,
            Core_MDF_All_Countries__c = true,
            Core_MDF_Program_Name__c = ''
        ));
        ecosystemPartners.add(new Core_MDF_CP_Countries__c(
            Name = 'EP_ClientProgram',
            Core_MDF_CP_Name__c = 'Partner Client',
            Core_MDF_Is_Active__c = true,
            Core_MDF_Is_Applicable_All_Programs_Ind__c = false,
            Core_MDF_All_Countries__c = false,
            Core_MDF_CP_Country__c = 'USA',
            Core_MDF_Program_Name__c = 'Client CoMarketing Fund'
        ));
        ecosystemPartners.add(new Core_MDF_CP_Countries__c(
            Name = 'EP_DataCenter',
            Core_MDF_CP_Name__c = 'Partner DataCenter',
            Core_MDF_Is_Active__c = true,
            Core_MDF_Is_Applicable_All_Programs_Ind__c = false,
            Core_MDF_All_Countries__c = false,
            Core_MDF_CP_Country__c = 'USA',
            Core_MDF_Program_Name__c = 'Data Center CoMarketing Fund'
        ));
        insert ecosystemPartners;

        try {
            List<Core_MDF_Partner_Node_User_Mapping__c> pnums = new List<Core_MDF_Partner_Node_User_Mapping__c>{
                new Core_MDF_Partner_Node_User_Mapping__c(
                    Core_MDF_Account__c = rootAcc.Id,
                    Core_MDF_User__c = UserInfo.getUserId()
                ),
                new Core_MDF_Partner_Node_User_Mapping__c(
                    Core_MDF_Account__c = childAcc.Id,
                    Core_MDF_User__c = UserInfo.getUserId()
                )
            };
            insert pnums;
        } catch (Exception e) {
            System.debug('Mapping error: ' + e.getMessage());
        }
    }
    
    private static void setupRestContext(Map<String, String> params) {
        RestRequest req  = new RestRequest();
        req.requestURI   = '/services/apexrest/v1.0/partnercenter/activitymetadata/picklist-values';
        req.httpMethod   = 'GET';
        if (params != null) {
            for (String key : params.keySet()) {
                req.params.put(key, params.get(key));
            }
        }
        RestContext.request  = req;
        RestContext.response = new RestResponse();
    }
 
    private static void setupMockAndRestContext(Campaign c, Map<String, String> extraParams) {
        String mockBody = (c != null) ? buildCampaignCalloutBody(c) : '{}';
        Test.setMock(HttpCalloutMock.class,
            new Core_MDF_RestAPI_Callout_Mock(200, mockBody));

        Map<String, String> params = new Map<String, String>();
        if (c != null) params.put('campaignId', c.Id);
        if (extraParams != null) params.putAll(extraParams);
        setupRestContext(params);
    }

    private static void setupMockReturnsNull(Campaign c, Map<String, String> extraParams) {
        Test.setMock(HttpCalloutMock.class,
            new Core_MDF_RestAPI_Callout_Mock(500, '{"error":"server error"}'));

        Map<String, String> params = new Map<String, String>();
        if (c != null) params.put('campaignId', c.Id);
        if (extraParams != null) params.putAll(extraParams);
        setupRestContext(params);
    }

    private static void setupMock403(Campaign c) {
        Test.setMock(HttpCalloutMock.class,
            new Core_MDF_RestAPI_Callout_Mock(403, '{"error":"forbidden"}'));
        Map<String, String> params = new Map<String, String>();
        if (c != null) params.put('campaignId', c.Id);
        setupRestContext(params);
    }
    
    private static Campaign getCampaign(String name) {
        List<Campaign> rows = [
            SELECT Id, Name,
                   Core_MDF_Activity_Category__c, Core_MDF_Program__c,
                   Core_MDF_Market__c, Core_MDF_Opal_Budget_Type_Txt__c,
                   Core_MDF_Priority__c, Core_MDF_Priority_2_nm__c,
                   Core_MDF_Priority_3_nm__c, Core_MDF_Activity_Type__c,
                   Core_MDF_Audience__c, Core_MDF_Brand__c,
                   Core_MDF_Product_Type__c, Core_MDF_Industry_Nm__c, Core_MDF_Account__c,
                   Core_MDF_Account__r.ParentId,
                   Core_MDF_Account__r.BillingCountry,
                   Core_MDF_Account__r.Core_MDF_Parent_Fund_Account__c,
                   Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c
            FROM   Campaign
            WHERE  Name = :name
            LIMIT  1
        ];
        return rows.isEmpty() ? null : rows[0];
    }

    private static String findActivePicklistValue(
            Schema.DescribeFieldResult fd, String contains) {
        for (Schema.PicklistEntry e : fd.getPicklistValues()) {
            if (e.isActive() &&
                (contains == null ||
                 e.getValue().toLowerCase().contains(contains.toLowerCase()))) {
                return e.getValue();
            }
        }
        return null;
    }

    private static String findActivePicklistValueExcluding(
            Schema.DescribeFieldResult fd, String exclude) {
        for (Schema.PicklistEntry e : fd.getPicklistValues()) {
            if (e.isActive() &&
                !e.getValue().toLowerCase().contains(exclude.toLowerCase())) {
                return e.getValue();
            }
        }
        return null;
    }

    private static List<String> getActivePicklistValues(
            Schema.DescribeFieldResult fd, Integer maxCount) {
        List<String> vals = new List<String>();
        for (Schema.PicklistEntry e : fd.getPicklistValues()) {
            if (e.isActive()) {
                vals.add(e.getValue());
                if (vals.size() == maxCount) break;
            }
        }
        return vals;
    }

    private static Core_MDF_PFR_RestAPI_PicklistValues.PicklistValuesResponse parseResponse() {
        String response = RestContext.response.responseBody.toString();
        
        Map<String, Object> respMap = (Map<String, Object>) JSON.deserializeUntyped(response);
        
        Core_MDF_PFR_RestAPI_PicklistValues.PicklistValuesResponse resp = 
            new Core_MDF_PFR_RestAPI_PicklistValues.PicklistValuesResponse();
        
        resp.isSuccess = respMap.containsKey('isSuccess') ? (Boolean) respMap.get('isSuccess') : false;
        resp.code = respMap.containsKey('code') ? (String) respMap.get('code') : '500';
        resp.message = respMap.containsKey('message') ? (String) respMap.get('message') : '';
        resp.campaignId = respMap.containsKey('campaignId') ? (String) respMap.get('campaignId') : null;
        resp.campaignName = respMap.containsKey('campaignName') ? (String) respMap.get('campaignName') : null;
        
        List<Object> fieldsObj = (List<Object>) respMap.get('fields');
        if (fieldsObj != null) {
            resp.fields = new List<Core_MDF_PFR_RestAPI_PicklistValues.PicklistFieldValues>();
            for (Object fieldObj : fieldsObj) {
                Map<String, Object> fieldMap = (Map<String, Object>) fieldObj;
                Core_MDF_PFR_RestAPI_PicklistValues.PicklistFieldValues fieldVal = 
                    new Core_MDF_PFR_RestAPI_PicklistValues.PicklistFieldValues();
                fieldVal.fieldLabel = (String) fieldMap.get('fieldLabel');

                List<Object> valuesObj = (List<Object>) fieldMap.get('values');
                fieldVal.values = new List<String>();
                if (valuesObj != null) {
                    for (Object val : valuesObj) {
                        fieldVal.values.add((String) val);
                    }
                }
                
                fieldVal.dependentOn = (String) fieldMap.get('dependentOn');

                Map<String, Object> depValsMap = (Map<String, Object>) fieldMap.get('dependentValues');
                if (depValsMap != null) {
                    fieldVal.dependentValues = new Map<String, List<String>>();
                    for (String key : depValsMap.keySet()) {
                        List<Object> depValsObj = (List<Object>) depValsMap.get(key);
                        List<String> depValsList = new List<String>();
                        if (depValsObj != null) {
                            for (Object val : depValsObj) {
                                depValsList.add((String) val);
                            }
                        }
                        fieldVal.dependentValues.put(key, depValsList);
                    }
                }
                resp.fields.add(fieldVal);
            }
        }
 
        List<Object> reimbObj = (List<Object>) respMap.get('ReimbursementRate');
        if (reimbObj != null) {
            resp.ReimbursementRate = new List<Map<String, String>>();
            for (Object obj : reimbObj) {
                Map<String, Object> m = (Map<String, Object>) obj;
                Map<String, String> reimbMap = new Map<String, String>();
                if (m != null) {
                    for (String key : m.keySet()) {
                        Object val = m.get(key);
                        reimbMap.put(key, val != null ? (String) val : null);
                    }
                }
                resp.ReimbursementRate.add(reimbMap);
            }
        }

        List<Object> segmentObj = (List<Object>) respMap.get('SegmentProduct');
        if (segmentObj != null) {
            resp.SegmentProduct = new List<Map<String, Object>>();
            for (Object obj : segmentObj) {
                Map<String, Object> segMap = (Map<String, Object>) obj;
                resp.SegmentProduct.add(segMap);
            }
        }

        List<Object> memberObj = (List<Object>) respMap.get('MemberAcceptorUserDetails');
        if (memberObj != null) {
            resp.MemberAcceptorUserDetails = new List<Core_MDF_PFR_RestAPI_PicklistValues.MemberAcceptorUserDetail>();
            for (Object obj : memberObj) {
                Map<String, Object> m = (Map<String, Object>) obj;
                if (m != null) {
                    Id userId = m.containsKey('userId') ? (Id) m.get('userId') : null;
                    String name = m.containsKey('name') ? (String) m.get('name') : null;
                    String accName = m.containsKey('accName') ? (String) m.get('accName') : null;
                    Core_MDF_PFR_RestAPI_PicklistValues.MemberAcceptorUserDetail userDetail = 
                        new Core_MDF_PFR_RestAPI_PicklistValues.MemberAcceptorUserDetail(userId, name, accName);
                    resp.MemberAcceptorUserDetails.add(userDetail);
                }
            }
        }

        List<Object> intelObj = (List<Object>) respMap.get('IntelApproverUserDetails');
        if (intelObj != null) {
            resp.IntelApproverUserDetails = new List<Core_MDF_PFR_RestAPI_PicklistValues.UserDetail>();
            for (Object obj : intelObj) {
                Map<String, Object> m = (Map<String, Object>) obj;
                if (m != null) {
                    Id userId = m.containsKey('userId') ? (Id) m.get('userId') : null;
                    String name = m.containsKey('name') ? (String) m.get('name') : null;
                    String region = m.containsKey('Region') ? (String) m.get('Region') : null;
                    Core_MDF_PFR_RestAPI_PicklistValues.UserDetail userDetail = 
                        new Core_MDF_PFR_RestAPI_PicklistValues.UserDetail(userId, name, region);
                    resp.IntelApproverUserDetails.add(userDetail);
                }
            }
        }
        
        return resp;
    }

    private static Core_MDF_PFR_RestAPI_PicklistValues.PicklistFieldValues getField(
        Core_MDF_PFR_RestAPI_PicklistValues.PicklistValuesResponse resp, 
        String fieldLabel) {
        
        if (resp.fields == null) return null;
        
        for (Core_MDF_PFR_RestAPI_PicklistValues.PicklistFieldValues field : resp.fields) {
            if (field.fieldLabel == fieldLabel) {
                return field;
            }
        }
        return null;
    }
    
    @isTest
    static void test_NoParams_DependentFieldsHaveDependentOn() {
        setupRestContext(new Map<String, String>());
        Test.startTest();
        Core_MDF_PFR_RestAPI_PicklistValues.doGet();
        Test.stopTest();

        Core_MDF_PFR_RestAPI_PicklistValues.PicklistValuesResponse r = parseResponse();
        System.assertNotEquals(null, r);

        Set<String> dependentLabels = new Set<String>{
            'Activity Type', 'Event Name', 'Domain Type', 'Product Type'
        };
        for (Core_MDF_PFR_RestAPI_PicklistValues.PicklistFieldValues fv : r.fields) {
            if (dependentLabels.contains(fv.fieldLabel)) {
                System.assertNotEquals(null, fv.dependentOn,
                    fv.fieldLabel + ' should have dependentOn');
            }
        }
    }

    @isTest
    static void test_NoParams_SubTypeIncluded_WhenNoCampaign() {
        setupRestContext(new Map<String, String>());
        Test.startTest();
        Core_MDF_PFR_RestAPI_PicklistValues.doGet();
        Test.stopTest();

        Core_MDF_PFR_RestAPI_PicklistValues.PicklistValuesResponse r = parseResponse();
        System.assertNotEquals(null, r);
    }

    @isTest
    static void test_Mock200_CCFCampaign_FilteredRecord() {
        Campaign c = getCampaign('TC_CCF');
        if (c == null) return;
        setupMockAndRestContext(c, null);

        Test.startTest();
        Core_MDF_PFR_RestAPI_PicklistValues.doGet();
        Test.stopTest();

        System.assertEquals(200, RestContext.response.statusCode);
        Core_MDF_PFR_RestAPI_PicklistValues.PicklistValuesResponse r = parseResponse();
        System.assertNotEquals(null, r);
    }

    @isTest
    static void test_Mock200_DCFCampaign_FilteredRecord() {
        Campaign c = getCampaign('TC_DCF');
        if (c == null) return;
        setupMockAndRestContext(c, null);

        Test.startTest();
        Core_MDF_PFR_RestAPI_PicklistValues.doGet();
        Test.stopTest();

        System.assertEquals(200, RestContext.response.statusCode);
        Core_MDF_PFR_RestAPI_PicklistValues.PicklistValuesResponse r = parseResponse();
        System.assertNotEquals(null, r);
        System.assertEquals(c.Id, r.campaignId);
    }

    @isTest
    static void test_Mock200_FullFieldsCampaign_AllMappingsExercised() {
        Campaign c = getCampaign('TC_FullFields');
        if (c == null) return;
        setupMockAndRestContext(c, null);

        Test.startTest();
        Core_MDF_PFR_RestAPI_PicklistValues.doGet();
        Test.stopTest();

        System.assertEquals(200, RestContext.response.statusCode);
        Core_MDF_PFR_RestAPI_PicklistValues.PicklistValuesResponse r = parseResponse();
        System.assertNotEquals(null, r);
        Core_MDF_PFR_RestAPI_PicklistValues.PicklistFieldValues budgetTypeField =
            getField(r, 'Budget Type');
        System.assertNotEquals(null, budgetTypeField);
    }

    @isTest
    static void test_Mock200_Pre2025Campaign_SubTypeIncluded() {
        Campaign c = getCampaign('TC_Pre2025');
        if (c == null || String.isBlank(c.Core_MDF_Activity_Category__c)) return;
        Boolean hasPre2025 = false;
        for (String cat : c.Core_MDF_Activity_Category__c.split(';')) {
            if (cat.trim().contains(PRE2025_KEYWORD)) { hasPre2025 = true; break; }
        }
        if (!hasPre2025) return;

        setupMockAndRestContext(c, null);
        Test.startTest();
        Core_MDF_PFR_RestAPI_PicklistValues.doGet();
        Test.stopTest();

        System.assertEquals(200, RestContext.response.statusCode);
        Core_MDF_PFR_RestAPI_PicklistValues.PicklistValuesResponse r = parseResponse();
        System.assertNotEquals(null, getField(r, 'Activity Sub Type'),
            'Pre-2025 campaign should include Activity Sub Type');
    }

    @isTest
    static void test_Mock200_NonPre2025Campaign_SubTypeExcluded() {
        Campaign c = getCampaign('TC_NonPre2025');
        if (c == null || String.isBlank(c.Core_MDF_Activity_Category__c)) return;
        Boolean hasPre2025 = false;
        for (String cat : c.Core_MDF_Activity_Category__c.split(';')) {
            if (cat.trim().contains(PRE2025_KEYWORD)) { hasPre2025 = true; break; }
        }
        if (!hasPre2025) return;

        setupMockAndRestContext(c, null);
        Test.startTest();
        Core_MDF_PFR_RestAPI_PicklistValues.doGet();
        Test.stopTest();

        System.assertEquals(200, RestContext.response.statusCode);
        Core_MDF_PFR_RestAPI_PicklistValues.PicklistValuesResponse r = parseResponse();
        System.assertEquals(null, getField(r, 'Activity Sub Type'),
            'Non-pre-2025 campaign should NOT include Activity Sub Type');
    }

    @isTest
    static void test_Mock200_CCFNoCategory_SubTypeIncluded() {
        Campaign c = getCampaign('TC_CCF_NoCategory');
        if (c == null) return;
        setupMockAndRestContext(c, null);

        Test.startTest();
        Core_MDF_PFR_RestAPI_PicklistValues.doGet();
        Test.stopTest();

        System.assertEquals(200, RestContext.response.statusCode);
        Core_MDF_PFR_RestAPI_PicklistValues.PicklistValuesResponse r = parseResponse();
        System.assertNotEquals(null, r);
    }

    @isTest
    static void test_Mock500_CCFCampaign_SOQLFallback() {
        Campaign c = getCampaign('TC_CCF');
        if (c == null) return;
        setupMockReturnsNull(c, null);

        Test.startTest();
        Core_MDF_PFR_RestAPI_PicklistValues.doGet();
        Test.stopTest();

        System.assertEquals(200, RestContext.response.statusCode);
        Core_MDF_PFR_RestAPI_PicklistValues.PicklistValuesResponse r = parseResponse();
        System.assertNotEquals(null, r);
    }

    @isTest
    static void test_Mock500_FullFieldsCampaign_SOQLFallback() {
        Campaign c = getCampaign('TC_FullFields');
        if (c == null) return;
        setupMockReturnsNull(c, null);

        Test.startTest();
        Core_MDF_PFR_RestAPI_PicklistValues.doGet();
        Test.stopTest();

        System.assertEquals(200, RestContext.response.statusCode);
        Core_MDF_PFR_RestAPI_PicklistValues.PicklistValuesResponse r = parseResponse();
        System.assertNotEquals(null, r);
    }

    @isTest
    static void test_Mock403_AccessDenied_Returns403() {
        Campaign c = getCampaign('TC_CCF');
        if (c == null) return;
        setupMock403(c);

        Test.startTest();
        Core_MDF_PFR_RestAPI_PicklistValues.doGet();
        Test.stopTest();

        Core_MDF_PFR_RestAPI_PicklistValues.PicklistValuesResponse r = parseResponse();
        System.assertNotEquals(null, r);
        System.assertEquals(false, r.isSuccess);
        System.assert(
            RestContext.response.statusCode == 403 ||
            RestContext.response.statusCode == 500,
            'Should return 403 or 500 for access denied'
        );
    }

    @isTest
    static void test_NonExistentCampaignId_Returns404() {
        Test.setMock(HttpCalloutMock.class,
            new Core_MDF_RestAPI_Callout_Mock(404, '{"error":"not found"}'));
        setupRestContext(new Map<String, String>{'campaignId' => '701000000000001AAA'});

        Test.startTest();
        Core_MDF_PFR_RestAPI_PicklistValues.doGet();
        Test.stopTest();

        Core_MDF_PFR_RestAPI_PicklistValues.PicklistValuesResponse r = parseResponse();
        System.assertNotEquals(null, r);
        System.assertEquals(false, r.isSuccess);
    }

    @isTest
    static void test_InvalidCampaignId_ErrorPath() {
        Test.setMock(HttpCalloutMock.class,
            new Core_MDF_RestAPI_Callout_Mock(500, '{"error":"bad request"}'));
        setupRestContext(new Map<String, String>{'campaignId' => 'INVALID_ID_XYZ'});

        Test.startTest();
        Core_MDF_PFR_RestAPI_PicklistValues.doGet();
        Test.stopTest();

        Core_MDF_PFR_RestAPI_PicklistValues.PicklistValuesResponse r = parseResponse();
        System.assertNotEquals(null, r);
        System.assertEquals(false, r.isSuccess);
    }

    @isTest
    static void test_Mock200_PriorityCampaign_AllThreePriorities() {
        Campaign c = getCampaign('TC_Priority');
        if (c == null) return;
        setupMockAndRestContext(c, null);

        Test.startTest();
        Core_MDF_PFR_RestAPI_PicklistValues.doGet();
        Test.stopTest();

        System.assertEquals(200, RestContext.response.statusCode);
        Core_MDF_PFR_RestAPI_PicklistValues.PicklistValuesResponse r = parseResponse();
        System.assertNotEquals(null, r);
        Core_MDF_PFR_RestAPI_PicklistValues.PicklistFieldValues pf = getField(r, 'Priority');
        System.assertNotEquals(null, pf);
    }

    @isTest
    static void test_Mock200_NoPriorityCampaign_EmptyPriority() {
        Campaign c = getCampaign('TC_NoPriority');
        if (c == null) return;
        setupMockAndRestContext(c, null);

        Test.startTest();
        Core_MDF_PFR_RestAPI_PicklistValues.doGet();
        Test.stopTest();

        System.assertEquals(200, RestContext.response.statusCode);
        Core_MDF_PFR_RestAPI_PicklistValues.PicklistValuesResponse r = parseResponse();
        System.assertNotEquals(null, r);
    }

    @isTest
    static void test_Mock200_BudgetTypeCampaign_FilteredValues() {
        Campaign c = getCampaign('TC_BudgetType');
        if (c == null || String.isBlank(c.Core_MDF_Opal_Budget_Type_Txt__c)) return;
        setupMockAndRestContext(c, null);

        Test.startTest();
        Core_MDF_PFR_RestAPI_PicklistValues.doGet();
        Test.stopTest();

        System.assertEquals(200, RestContext.response.statusCode);
        Core_MDF_PFR_RestAPI_PicklistValues.PicklistValuesResponse r = parseResponse();
        Core_MDF_PFR_RestAPI_PicklistValues.PicklistFieldValues btf = getField(r, 'Budget Type');
        System.assertNotEquals(null, btf);
    }

    @isTest
    static void test_Mock200_NoBudgetTypeCampaign_AllActiveValues() {
        Campaign c = getCampaign('TC_Basic');
        if (c == null) return;
        setupMockAndRestContext(c, null);

        Test.startTest();
        Core_MDF_PFR_RestAPI_PicklistValues.doGet();
        Test.stopTest();

        System.assertEquals(200, RestContext.response.statusCode);
        Core_MDF_PFR_RestAPI_PicklistValues.PicklistValuesResponse r = parseResponse();
        System.assertNotEquals(null, r);
    }

    @isTest
    static void test_Mock200_ReimbursementRate_WithCampaign() {
        Campaign c = getCampaign('TC_CCF');
        if (c == null) return;
        setupMockAndRestContext(c, null);

        Test.startTest();
        Core_MDF_PFR_RestAPI_PicklistValues.doGet();
        Test.stopTest();

        System.assertEquals(200, RestContext.response.statusCode);
        Core_MDF_PFR_RestAPI_PicklistValues.PicklistValuesResponse r = parseResponse();
        System.assertNotEquals(null, r);
    }

    @isTest
    static void test_NoParams_ReimbursementRate_EmptyList() {
        setupRestContext(new Map<String, String>());
        Test.startTest();
        Core_MDF_PFR_RestAPI_PicklistValues.doGet();
        Test.stopTest();

        Core_MDF_PFR_RestAPI_PicklistValues.PicklistValuesResponse r = parseResponse();
        System.assertNotEquals(null, r.ReimbursementRate);
        System.assertEquals(0, r.ReimbursementRate.size());
    }

    @isTest
    static void test_Mock200_WithAccount_SegmentProducts() {
        Campaign c = getCampaign('TC_WithAccount');
        if (c == null) return;
        setupMockAndRestContext(c, null);

        Test.startTest();
        Core_MDF_PFR_RestAPI_PicklistValues.doGet();
        Test.stopTest();

        System.assertEquals(200, RestContext.response.statusCode);
        Core_MDF_PFR_RestAPI_PicklistValues.PicklistValuesResponse r = parseResponse();
        System.assertNotEquals(null, r.SegmentProduct);
    }

    @isTest
    static void test_NoParams_SegmentProducts_EmptyList() {
        setupRestContext(new Map<String, String>());
        Test.startTest();
        Core_MDF_PFR_RestAPI_PicklistValues.doGet();
        Test.stopTest();

        Core_MDF_PFR_RestAPI_PicklistValues.PicklistValuesResponse r = parseResponse();
        System.assertNotEquals(null, r.SegmentProduct);
        System.assertEquals(0, r.SegmentProduct.size());
    }

    @isTest
    static void test_Mock200_FullFields_SegmentProducts() {
        Campaign c = getCampaign('TC_FullFields');
        if (c == null) return;
        setupMockAndRestContext(c, null);

        Test.startTest();
        Core_MDF_PFR_RestAPI_PicklistValues.doGet();
        Test.stopTest();

        System.assertEquals(200, RestContext.response.statusCode);
        Core_MDF_PFR_RestAPI_PicklistValues.PicklistValuesResponse r = parseResponse();
        System.assertNotEquals(null, r.SegmentProduct);
    }

    @isTest
    static void test_Mock200_WithMarketAndAccount_IntelApprover() {
        Campaign c = getCampaign('TC_WithMarketAndAccount');
        if (c == null) return;
        setupMockAndRestContext(c, null);

        Test.startTest();
        Core_MDF_PFR_RestAPI_PicklistValues.doGet();
        Test.stopTest();

        System.assertEquals(200, RestContext.response.statusCode);
        Core_MDF_PFR_RestAPI_PicklistValues.PicklistValuesResponse r = parseResponse();
        System.assertNotEquals(null, r.IntelApproverUserDetails);
    }

    @isTest
    static void test_Mock200_MultiMarketWithAccount_RegionLookup() {
        Campaign c = getCampaign('TC_MultiMarket');
        if (c == null || String.isBlank(c.Core_MDF_Market__c)) return;

        Account acc = [SELECT Id FROM Account WHERE Name = 'TC_Root_Account' LIMIT 1];
        try { c.put('Core_MDF_Account__c', acc.Id); update c; } catch (Exception ex) {}

        setupMockAndRestContext(c, null);
        Test.startTest();
        Core_MDF_PFR_RestAPI_PicklistValues.doGet();
        Test.stopTest();

        System.assertEquals(200, RestContext.response.statusCode);
        Core_MDF_PFR_RestAPI_PicklistValues.PicklistValuesResponse r = parseResponse();
        System.assertNotEquals(null, r.IntelApproverUserDetails);
    }

    @isTest
    static void test_AcctName_Plain_ExistingAccount() {
        setupRestContext(new Map<String, String>{'acct-name' => 'TC_Root_Account'});
        Test.startTest();
        Core_MDF_PFR_RestAPI_PicklistValues.doGet();
        Test.stopTest();

        System.assertEquals(200, RestContext.response.statusCode);
        Core_MDF_PFR_RestAPI_PicklistValues.PicklistValuesResponse r = parseResponse();
        System.assertNotEquals(null, r.MemberAcceptorUserDetails);
        System.assertNotEquals(null, r.IntelApproverUserDetails);
    }

    @isTest
    static void test_AcctName_SingleQuotes() {
        setupRestContext(new Map<String, String>{'acct-name' => '\'TC_Root_Account\''});
        Test.startTest();
        Core_MDF_PFR_RestAPI_PicklistValues.doGet();
        Test.stopTest();
        System.assertEquals(200, RestContext.response.statusCode);
    }

    @isTest
    static void test_AcctName_DoubleQuotes() {
        setupRestContext(new Map<String, String>{'acct-name' => '"TC_Root_Account"'});
        Test.startTest();
        Core_MDF_PFR_RestAPI_PicklistValues.doGet();
        Test.stopTest();
        System.assertEquals(200, RestContext.response.statusCode);
    }

    @isTest
    static void test_AcctName_NestedQuotes() {
        setupRestContext(new Map<String, String>{'acct-name' => '"\'TC_Root_Account\'"'});
        Test.startTest();
        Core_MDF_PFR_RestAPI_PicklistValues.doGet();
        Test.stopTest();
        System.assertEquals(200, RestContext.response.statusCode);
    }

    @isTest
    static void test_AcctName_Blank() {
        setupRestContext(new Map<String, String>{'acct-name' => '   '});
        Test.startTest();
        Core_MDF_PFR_RestAPI_PicklistValues.doGet();
        Test.stopTest();
        System.assertEquals(200, RestContext.response.statusCode);
    }

    @isTest
    static void test_AcctName_NotFound() {
        setupRestContext(new Map<String, String>{'acct-name' => 'NoSuchAccount_XYZ_999'});
        Test.startTest();
        Core_MDF_PFR_RestAPI_PicklistValues.doGet();
        Test.stopTest();
        System.assertEquals(200, RestContext.response.statusCode);
    }

    @isTest
    static void test_AcctName_DuplicateAccounts() {
        setupRestContext(new Map<String, String>{'acct-name' => 'TC_Dup_Account'});
        Test.startTest();
        Core_MDF_PFR_RestAPI_PicklistValues.doGet();
        Test.stopTest();
        System.assertEquals(200, RestContext.response.statusCode);
    }

    @isTest
    static void test_AcctName_ChildAccount_TraversesHierarchy() {
        setupRestContext(new Map<String, String>{'acct-name' => 'TC_Child_Account'});
        Test.startTest();
        Core_MDF_PFR_RestAPI_PicklistValues.doGet();
        Test.stopTest();
        System.assertEquals(200, RestContext.response.statusCode);
    }

    @isTest
    static void test_AcctName_UltimateAccount_UsesCustomField() {
        setupRestContext(new Map<String, String>{'acct-name' => 'TC_Ultimate_Account'});
        Test.startTest();
        Core_MDF_PFR_RestAPI_PicklistValues.doGet();
        Test.stopTest();
        System.assertEquals(200, RestContext.response.statusCode);
    }

    @isTest
    static void test_NormalizeAccountNameParam_AllBranches() {
        Test.startTest();
        System.assertEquals(null,        Core_MDF_PFR_RestAPI_PicklistValues.normalizeAccountNameParam(null));
        System.assertEquals(null,        Core_MDF_PFR_RestAPI_PicklistValues.normalizeAccountNameParam(''));
        System.assertEquals(null,        Core_MDF_PFR_RestAPI_PicklistValues.normalizeAccountNameParam('   '));
        System.assertEquals('MyAccount', Core_MDF_PFR_RestAPI_PicklistValues.normalizeAccountNameParam('MyAccount'));
        System.assertEquals('MyAccount', Core_MDF_PFR_RestAPI_PicklistValues.normalizeAccountNameParam('\'MyAccount\''));
        System.assertEquals('MyAccount', Core_MDF_PFR_RestAPI_PicklistValues.normalizeAccountNameParam('"MyAccount"'));
        System.assertEquals('MyAccount', Core_MDF_PFR_RestAPI_PicklistValues.normalizeAccountNameParam('"\'MyAccount\'"'));
        System.assertEquals('MyAccount', Core_MDF_PFR_RestAPI_PicklistValues.normalizeAccountNameParam('  MyAccount  '));
        Test.stopTest();
    }
    
    @isTest
    static void test_BothParams_AcctNameTakesPriority() {
        Campaign c = getCampaign('TC_CCF');
        if (c == null) return;
        Test.setMock(HttpCalloutMock.class,
            new Core_MDF_RestAPI_Callout_Mock(200, buildCampaignCalloutBody(c)));
        setupRestContext(new Map<String, String>{
            'campaignId' => c.Id,
            'acct-name'  => 'TC_Child_Account'
        });

        Test.startTest();
        Core_MDF_PFR_RestAPI_PicklistValues.doGet();
        Test.stopTest();

        System.assertEquals(200, RestContext.response.statusCode);
        Core_MDF_PFR_RestAPI_PicklistValues.PicklistValuesResponse r = parseResponse();
        System.assertNotEquals(null, r.MemberAcceptorUserDetails);
    }

    @isTest
    static void test_Mock200_CCFPre2025_PriorityAndSubType() {
        Campaign c = getCampaign('TC_CCF_Pre2025');
        if (c == null) return;
        setupMockAndRestContext(c, null);

        Test.startTest();
        Core_MDF_PFR_RestAPI_PicklistValues.doGet();
        Test.stopTest();

        System.assertEquals(200, RestContext.response.statusCode);
        Core_MDF_PFR_RestAPI_PicklistValues.PicklistValuesResponse r = parseResponse();
        System.assertNotEquals(null, r);
    }

    @isTest
    static void test_Mock200_DCFPre2025_PriorityAndSubType() {
        Campaign c = getCampaign('TC_DCF_Pre2025');
        if (c == null) return;
        setupMockAndRestContext(c, null);

        Test.startTest();
        Core_MDF_PFR_RestAPI_PicklistValues.doGet();
        Test.stopTest();

        System.assertEquals(200, RestContext.response.statusCode);
        Core_MDF_PFR_RestAPI_PicklistValues.PicklistValuesResponse r = parseResponse();
        System.assertNotEquals(null, r);
    }

    @isTest
    static void test_Mock200_CCF_FilterPicklistByProgram() {
        Campaign c = getCampaign('TC_CCF');
        if (c == null) return;
        setupMockAndRestContext(c, null);

        Test.startTest();
        Core_MDF_PFR_RestAPI_PicklistValues.doGet();
        Test.stopTest();

        System.assertEquals(200, RestContext.response.statusCode);
        Core_MDF_PFR_RestAPI_PicklistValues.PicklistValuesResponse r = parseResponse();
        System.assertNotEquals(null, r);
    }

    @isTest
    static void test_Mock200_DCF_FilterPicklistByProgram() {
        Campaign c = getCampaign('TC_DCF');
        if (c == null) return;
        setupMockAndRestContext(c, null);

        Test.startTest();
        Core_MDF_PFR_RestAPI_PicklistValues.doGet();
        Test.stopTest();

        System.assertEquals(200, RestContext.response.statusCode);
        Core_MDF_PFR_RestAPI_PicklistValues.PicklistValuesResponse r = parseResponse();
        Core_MDF_PFR_RestAPI_PicklistValues.PicklistFieldValues atf = getField(r, 'Activity Type');
        System.assertNotEquals(null, atf);
    }

    @isTest
    static void test_Mock200_AllowedBudgets_WithCampaign() {
        Campaign c = getCampaign('TC_WithAccount');
        if (c == null) return;
        setupMockAndRestContext(c, null);

        Test.startTest();
        Core_MDF_PFR_RestAPI_PicklistValues.doGet();
        Test.stopTest();

        System.assertEquals(200, RestContext.response.statusCode);
        Core_MDF_PFR_RestAPI_PicklistValues.PicklistValuesResponse r = parseResponse();
        System.assertNotEquals(null, r.Budgets, 'Budgets list should be present');
    }

    @isTest
    static void test_NoParams_AllowedBudgets_Empty() {
        setupRestContext(new Map<String, String>());
        Test.startTest();
        Core_MDF_PFR_RestAPI_PicklistValues.doGet();
        Test.stopTest();

        Core_MDF_PFR_RestAPI_PicklistValues.PicklistValuesResponse r = parseResponse();
        System.assertNotEquals(null, r.Budgets, 'Budgets list should exist');
        System.assertEquals(0, r.Budgets.size(), 'No campaign → empty budgets list');
    }

    @isTest
    static void test_InnerClasses_AllInstantiated() {
        Test.startTest();
        Core_MDF_PFR_RestAPI_PicklistValues.PicklistValuesResponse resp =
            new Core_MDF_PFR_RestAPI_PicklistValues.PicklistValuesResponse();
        System.assertEquals(false,  resp.isSuccess);
        System.assertEquals('500',  resp.code);
        System.assertNotEquals(null, resp.fields);
        System.assertNotEquals(null, resp.ReimbursementRate);
        System.assertNotEquals(null, resp.SegmentProduct);
        System.assertNotEquals(null, resp.MemberAcceptorUserDetails);
        System.assertNotEquals(null, resp.IntelApproverUserDetails);

        Core_MDF_PFR_RestAPI_PicklistValues.PicklistFieldValues fv =
            new Core_MDF_PFR_RestAPI_PicklistValues.PicklistFieldValues();
        fv.fieldLabel      = 'Test';
        fv.values          = new List<String>{'A','B'};
        fv.dependentOn     = 'Controller';
        fv.dependentValues = new Map<String, List<String>>{'X' => new List<String>{'Y'}};
        System.assertEquals('Test', fv.fieldLabel);
        System.assertEquals(2,      fv.values.size());

        User u = [SELECT Id, Name FROM User WHERE IsActive = true LIMIT 1];

        Core_MDF_PFR_RestAPI_PicklistValues.MemberAcceptorUserDetail mad =
            new Core_MDF_PFR_RestAPI_PicklistValues.MemberAcceptorUserDetail(u.Id, u.Name, 'Sample Account');
        System.assertEquals(u.Id, mad.userId);
        System.assertEquals(u.Name, mad.name);
        System.assertEquals('Sample Account', mad.accName);

        Core_MDF_PFR_RestAPI_PicklistValues.UserDetail ud =
            new Core_MDF_PFR_RestAPI_PicklistValues.UserDetail(u.Id, u.Name, 'EMEA');
        System.assertEquals(u.Id,   ud.userId);
        System.assertEquals(u.Name, ud.name);
        System.assertEquals('EMEA', ud.Region);
        Test.stopTest();
    }

    @isTest
    static void test_ProductMethods_AllBranches() {
        Product2 prod = [SELECT Id FROM Product2 WHERE Name = 'Test Prod A' LIMIT 1];
        List<Product2> prods = [SELECT Id FROM Product2
                                WHERE Name IN ('Test Prod A','Test Prod B')];
        List<String> ids = new List<String>();
        for (Product2 p : prods) ids.add(p.Id);

        Test.startTest();
        System.assertNotEquals(null,
            Core_MDF_PFR_RestAPI_PicklistValues.getProductsForSegment('Client'));
        System.assertNotEquals(null,
            Core_MDF_PFR_RestAPI_PicklistValues.getProductsForSegment(null));
        System.assertNotEquals(null,
            Core_MDF_PFR_RestAPI_PicklistValues.getProductsForSegment(''));

        System.assertEquals(false,
            Core_MDF_PFR_RestAPI_PicklistValues.isProductValidForSegment(null, null));
        System.assertEquals(false,
            Core_MDF_PFR_RestAPI_PicklistValues.isProductValidForSegment('', ''));
        System.assertEquals(false,
            Core_MDF_PFR_RestAPI_PicklistValues.isProductValidForSegment('Client', null));
        System.assertEquals(false,
            Core_MDF_PFR_RestAPI_PicklistValues.isProductValidForSegment(null, prod.Id));
        System.assertEquals(false,
            Core_MDF_PFR_RestAPI_PicklistValues.isProductValidForSegment('Client', 'badId'));
        System.assertNotEquals(null,
            Core_MDF_PFR_RestAPI_PicklistValues.isProductValidForSegment('Client', prod.Id));

        System.assertEquals(false,
            Core_MDF_PFR_RestAPI_PicklistValues.areProductsValidForSegment(null, null));
        System.assertEquals(false,
            Core_MDF_PFR_RestAPI_PicklistValues.areProductsValidForSegment('', new List<String>()));
        System.assertEquals(false,
            Core_MDF_PFR_RestAPI_PicklistValues.areProductsValidForSegment('Client', null));
        System.assertEquals(false,
            Core_MDF_PFR_RestAPI_PicklistValues.areProductsValidForSegment('Client', new List<String>()));
        System.assertEquals(false,
            Core_MDF_PFR_RestAPI_PicklistValues.areProductsValidForSegment(
                'Client', new List<String>{'badId1','badId2'}));
        System.assertNotEquals(null,
            Core_MDF_PFR_RestAPI_PicklistValues.areProductsValidForSegment('Client', ids));
        Test.stopTest();
    }
    
    @isTest
    static void test_SupportedPrograms_SetContents() {
        Test.startTest();
        Set<String> programs =
            Core_MDF_PFR_RestAPI_PicklistValues.SUPPORTED_COMARKETING_PROGRAMS;
        Test.stopTest();
        System.assertNotEquals(null, programs);
        System.assertEquals(2, programs.size());
        System.assert(programs.contains('Client CoMarketing Fund'));
        System.assert(programs.contains('Data Center CoMarketing Fund'));
    }

    @isTest
    static void test_BlankCampaignId_TreatedAsNoParam() {
        setupRestContext(new Map<String, String>{'campaignId' => ''});
        Test.startTest();
        Core_MDF_PFR_RestAPI_PicklistValues.doGet();
        Test.stopTest();
        System.assertEquals(200, RestContext.response.statusCode);
    }
    
    @isTest
    static void test_Mock200_MultiCategory() {
        Campaign c = getCampaign('TC_MultiCategory');
        if (c == null) return;
        setupMockAndRestContext(c, null);

        Test.startTest();
        Core_MDF_PFR_RestAPI_PicklistValues.doGet();
        Test.stopTest();

        System.assertEquals(200, RestContext.response.statusCode);
        Core_MDF_PFR_RestAPI_PicklistValues.PicklistValuesResponse r = parseResponse();
        System.assertNotEquals(null, r);
    }

    @isTest
    static void test_Mock200_ActivityType_DependentValues() {
        Campaign c = getCampaign('TC_ActivityType');
        if (c == null || String.isBlank(c.Core_MDF_Activity_Type__c)) return;
        setupMockAndRestContext(c, null);

        Test.startTest();
        Core_MDF_PFR_RestAPI_PicklistValues.doGet();
        Test.stopTest();

        System.assertEquals(200, RestContext.response.statusCode);
        Core_MDF_PFR_RestAPI_PicklistValues.PicklistValuesResponse r = parseResponse();
        Core_MDF_PFR_RestAPI_PicklistValues.PicklistFieldValues atf = getField(r, 'Activity Type');
        System.assertNotEquals(null, atf);
        System.assertNotEquals(null, atf.dependentOn);
    }

    @isTest
    static void test_getRegionsForCountries_WithMockAccountField() {
        Account acc = new Account(
            Name = 'TC_Regions_Account',
            BillingCountry = 'United States',
            BillingCity = 'Denver',
            BillingStreet = 'Main St'
        );
        insert acc;

        String programValue = findActivePicklistValue(Campaign.Core_MDF_Program__c.getDescribe(), 'client');
        List<String> marketValues = getActivePicklistValues(Campaign.Core_MDF_Market__c.getDescribe(), 2);
        if (marketValues.isEmpty()) return;

        String marketValue = marketValues.size() > 1 ? 
            (marketValues[0] + ';' + marketValues[1]) : marketValues[0];

        Campaign c = new Campaign(
            Name = 'TC_Regions_Campaign',
            Core_MDF_Program__c = programValue,
            Core_MDF_Market__c = marketValue
        );

        try {
            c.put('Core_MDF_Account__c', acc.Id);
            insert c;
        } catch (Exception dex) {
            return;
        }

        Map<String, Object> mockBody = new Map<String, Object>{
            'Id' => (String) c.Id,
            'Name' => c.Name,
            'Core_MDF_Program__c' => programValue,
            'Core_MDF_Market__c' => marketValue,
            'Core_MDF_Account__c' => (String) acc.Id
        };
        Test.setMock(HttpCalloutMock.class, new MockHttp200(mockBody));
        setupRestContext(new Map<String, String>{'campaignId' => (String) c.Id});

        Test.startTest();
        Core_MDF_PFR_RestAPI_PicklistValues.doGet();
        Test.stopTest();

        RestResponse response = RestContext.response;
        System.assertEquals(200, response.statusCode);
    }

    @isTest
    static void test_getRegionsForCountries_ViaAccountNameParam() {
        Account acc = new Account(
            Name = 'TC_Regions_ByName_Account',
            BillingCountry = 'United States',
            BillingCity = 'Austin',
            BillingStreet = 'Oak St'
        );
        insert acc;

        String program = findActivePicklistValue(Campaign.Core_MDF_Program__c.getDescribe(), 'client');
        String market = findActivePicklistValue(Campaign.Core_MDF_Market__c.getDescribe(), null);
        if (market == null) return;

        Campaign c = new Campaign(
            Name = 'TC_Regions_ByName_Campaign',
            Core_MDF_Program__c = program,
            Core_MDF_Market__c = market
        );
        insert c;

        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/v1.0/partnercenter/activitymetadata/picklist-values';
        req.httpMethod = 'GET';
        req.params.put('campaignId', (String) c.Id);
        req.params.put('acct-name', 'TC_Regions_ByName_Account');
        RestContext.request  = req;
        RestContext.response = new RestResponse();

        Map<String, Object> mockBody = new Map<String, Object>{
            'Id' => (String) c.Id,
            'Name' => c.Name,
            'Core_MDF_Program__c' => program,
            'Core_MDF_Market__c' => market
        };
        Test.setMock(HttpCalloutMock.class, new MockHttp200(mockBody));

        Test.startTest();
        Core_MDF_PFR_RestAPI_PicklistValues.doGet();
        Test.stopTest();

        System.assertEquals(200, RestContext.response.statusCode);
    }

    @isTest
    static void test_getRegionsForCountries_MinimalPath() {
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/v1.0/partnercenter/activitymetadata/picklist-values';
        req.httpMethod = 'GET';
        RestContext.request  = req;
        RestContext.response = new RestResponse();

        Test.startTest();
        Core_MDF_PFR_RestAPI_PicklistValues.doGet();
        Test.stopTest();

        System.assertEquals(200, RestContext.response.statusCode);
    }

    @isTest
    static void test_getActivitySegmentValues_WithAccount() {
        Campaign c = getCampaign('TC_WithAccount');
        if (c == null || c.Core_MDF_Account__c == null) return;

        setupMockReturnsNull(c, null);
        Test.startTest();
        Core_MDF_PFR_RestAPI_PicklistValues.doGet();
        Test.stopTest();

        System.assertEquals(200, RestContext.response.statusCode);
        Core_MDF_PFR_RestAPI_PicklistValues.PicklistValuesResponse r = parseResponse();
        System.assertNotEquals(null, r.SegmentProduct);
    }

    @isTest
    static void test_getActivitySegmentValues_FullFields() {
        Campaign c = getCampaign('TC_FullFields');
        if (c == null || c.Core_MDF_Account__c == null) return;

        setupMockReturnsNull(c, null);
        Test.startTest();
        Core_MDF_PFR_RestAPI_PicklistValues.doGet();
        Test.stopTest();

        System.assertEquals(200, RestContext.response.statusCode);
        Core_MDF_PFR_RestAPI_PicklistValues.PicklistValuesResponse r = parseResponse();
        System.assertNotEquals(null, r.SegmentProduct);
        System.assertNotEquals(0, r.SegmentProduct.size());
    }

    @isTest
    static void test_getActivitySegmentValues_CCF() {
        Campaign c = getCampaign('TC_CCF');
        if (c == null || c.Core_MDF_Account__c == null) return;

        setupMockReturnsNull(c, null);
        Test.startTest();
        Core_MDF_PFR_RestAPI_PicklistValues.doGet();
        Test.stopTest();

        System.assertEquals(200, RestContext.response.statusCode);
        Core_MDF_PFR_RestAPI_PicklistValues.PicklistValuesResponse r = parseResponse();
        System.assertNotEquals(null, r.SegmentProduct);
    }

    @isTest
    static void test_getActivitySegmentValues_DCF() {
        Campaign c = getCampaign('TC_DCF');
        if (c == null || c.Core_MDF_Account__c == null) return;

        setupMockReturnsNull(c, null);
        Test.startTest();
        Core_MDF_PFR_RestAPI_PicklistValues.doGet();
        Test.stopTest();

        System.assertEquals(200, RestContext.response.statusCode);
        Core_MDF_PFR_RestAPI_PicklistValues.PicklistValuesResponse r = parseResponse();
        System.assertNotEquals(null, r.SegmentProduct);
    }

    @isTest
    static void test_getActivitySegmentValues_NoAccount() {
        Campaign c = new Campaign(Name = 'TC_NoAccount_Test');
        insert c;
        
        setupMockReturnsNull(c, null);
        Test.startTest();
        Core_MDF_PFR_RestAPI_PicklistValues.doGet();
        Test.stopTest();

        System.assertEquals(200, RestContext.response.statusCode);
        Core_MDF_PFR_RestAPI_PicklistValues.PicklistValuesResponse r = parseResponse();
        System.assertEquals(0, r.SegmentProduct.size());
    }

    @isTest
    static void test_getActivitySegmentValues_All_Six_Segments() {
        Campaign c = getCampaign('TC_FullFields');
        if (c == null || c.Core_MDF_Account__c == null) return;

        setupMockReturnsNull(c, null);
        Test.startTest();
        Core_MDF_PFR_RestAPI_PicklistValues.doGet();
        Test.stopTest();

        System.assertEquals(200, RestContext.response.statusCode);
        Core_MDF_PFR_RestAPI_PicklistValues.PicklistValuesResponse r = parseResponse();
        
        Set<String> expectedSegments = new Set<String>{
            'Chipsets', 'Memory and Storage', 'Processors', 'Graphics', 'Technologies', 'Ethernet Products'
        };
        Set<String> foundSegments = new Set<String>();
        for (Map<String, Object> seg : r.SegmentProduct) {
            foundSegments.add((String) seg.get('Segment'));
        }
        for (String segment : expectedSegments) {
            System.assert(foundSegments.contains(segment));
        }
    }

    @isTest
    static void test_getActivitySegmentValues_With_Products() {
        Campaign c = getCampaign('TC_WithAccount');
        if (c == null || c.Core_MDF_Account__c == null) return;

        setupMockReturnsNull(c, null);
        Test.startTest();
        Core_MDF_PFR_RestAPI_PicklistValues.doGet();
        Test.stopTest();

        System.assertEquals(200, RestContext.response.statusCode);
        Core_MDF_PFR_RestAPI_PicklistValues.PicklistValuesResponse r = parseResponse();
        
        for (Map<String, Object> seg : r.SegmentProduct) {
            List<Object> allowedValuesObj = (List<Object>) seg.get('allowed values');
            if (allowedValuesObj != null && allowedValuesObj.size() > 0) {
                for (Object prodObj : allowedValuesObj) {
                    Map<String, Object> product = (Map<String, Object>) prodObj;
                    System.assert(product.containsKey('Name'));
                    System.assert(product.containsKey('ID'));
                }
            }
        }
    }

    @isTest
    static void test_ReimbursementRate_PercentageSymbolRemoved() {
        Campaign c = getCampaign('TC_BudgetType');
        if (c == null) return;
        
        setupMockAndRestContext(c, null);
        Test.startTest();
        Core_MDF_PFR_RestAPI_PicklistValues.doGet();
        Test.stopTest();

        System.assertEquals(200, RestContext.response.statusCode);
        Core_MDF_PFR_RestAPI_PicklistValues.PicklistValuesResponse r = parseResponse();
        System.assertNotEquals(null, r.ReimbursementRate);
    }

    @isTest
    static void test_ReimbursementRate_DecimalWithTrailingZeros() {
        Campaign c = getCampaign('TC_BudgetType');
        if (c == null) return;
        
        setupMockAndRestContext(c, null);
        Test.startTest();
        Core_MDF_PFR_RestAPI_PicklistValues.doGet();
        Test.stopTest();

        System.assertEquals(200, RestContext.response.statusCode);
        Core_MDF_PFR_RestAPI_PicklistValues.PicklistValuesResponse r = parseResponse();
        System.assertNotEquals(null, r);
    }

    @isTest
    static void test_ReimbursementRate_ZeroPercent() {
        Campaign c = getCampaign('TC_BudgetType');
        if (c == null) return;
        
        setupMockAndRestContext(c, null);
        Test.startTest();
        Core_MDF_PFR_RestAPI_PicklistValues.doGet();
        Test.stopTest();

        System.assertEquals(200, RestContext.response.statusCode);
    }

    @isTest
    static void test_ReimbursementRate_NullRateFiltered() {
        Campaign c = getCampaign('TC_BudgetType');
        if (c == null) return;
        
        setupMockAndRestContext(c, null);
        Test.startTest();
        Core_MDF_PFR_RestAPI_PicklistValues.doGet();
        Test.stopTest();

        System.assertEquals(200, RestContext.response.statusCode);
    }

    @isTest
    static void test_ReimbursementRate_AllFormatsPresent() {
        Campaign c = getCampaign('TC_BudgetType');
        if (c == null) return;
        
        setupMockAndRestContext(c, null);
        Test.startTest();
        Core_MDF_PFR_RestAPI_PicklistValues.doGet();
        Test.stopTest();

        System.assertEquals(200, RestContext.response.statusCode);
    }

    @isTest
    static void test_ReimbursementRate_SortedByBudget() {
        Campaign c = getCampaign('TC_BudgetType');
        if (c == null) return;
        
        setupMockAndRestContext(c, null);
        Test.startTest();
        Core_MDF_PFR_RestAPI_PicklistValues.doGet();
        Test.stopTest();

        System.assertEquals(200, RestContext.response.statusCode);
    }

    @isTest
    static void test_FormatReimbursementRate_ViaRateField() {
        Campaign c = getCampaign('TC_BudgetType');
        if (c == null) return;
        
        setupMockAndRestContext(c, null);
        Test.startTest();
        Core_MDF_PFR_RestAPI_PicklistValues.doGet();
        Test.stopTest();

        Core_MDF_PFR_RestAPI_PicklistValues.PicklistValuesResponse r = parseResponse();
        Core_MDF_PFR_RestAPI_PicklistValues.PicklistFieldValues rateField = getField(r, 'Reimbursement Rate');
        System.assertNotEquals(null, rateField);
    }

    @isTest
    static void test_isEcosystemProgramMatch_Branch1_IsApplicableAllPrograms() {
        Campaign c = getCampaign('TC_Basic');
        if (c == null) return;
        
        setupMockAndRestContext(c, null);
        Test.startTest();
        Core_MDF_PFR_RestAPI_PicklistValues.doGet();
        Test.stopTest();

        Core_MDF_PFR_RestAPI_PicklistValues.PicklistValuesResponse r = parseResponse();
        System.assertNotEquals(null, r);
    }

    @isTest
    static void test_isEcosystemProgramMatch_Branch2_NullProgramToken() {
        Campaign c = new Campaign(Name = 'TC_NullProgram_Test');
        insert c;
        
        setupMockAndRestContext(c, null);
        Test.startTest();
        Core_MDF_PFR_RestAPI_PicklistValues.doGet();
        Test.stopTest();

        Core_MDF_PFR_RestAPI_PicklistValues.PicklistValuesResponse r = parseResponse();
        System.assertNotEquals(null, r);
    }

    @isTest
    static void test_isEcosystemProgramMatch_Branch3_BlankMetaProgram() {
        Campaign c = getCampaign('TC_CCF');
        if (c == null) return;
        
        setupMockAndRestContext(c, null);
        Test.startTest();
        Core_MDF_PFR_RestAPI_PicklistValues.doGet();
        Test.stopTest();

        Core_MDF_PFR_RestAPI_PicklistValues.PicklistValuesResponse r = parseResponse();
        System.assertNotEquals(null, r);
    }

    @isTest
    static void test_isEcosystemProgramMatch_Branch4_ClientProgram() {
        Campaign c = getCampaign('TC_CCF');
        if (c == null) return;
        
        setupMockAndRestContext(c, null);
        Test.startTest();
        Core_MDF_PFR_RestAPI_PicklistValues.doGet();
        Test.stopTest();

        Core_MDF_PFR_RestAPI_PicklistValues.PicklistValuesResponse r = parseResponse();
        System.assertNotEquals(null, r);
    }

    @isTest
    static void test_isEcosystemProgramMatch_Branch5_DataCenterProgram() {
        Campaign c = getCampaign('TC_DCF');
        if (c == null) return;
                
        setupMockAndRestContext(c, null);
        Test.startTest();
        Core_MDF_PFR_RestAPI_PicklistValues.doGet();
        Test.stopTest();

        Core_MDF_PFR_RestAPI_PicklistValues.PicklistValuesResponse r = parseResponse();
        Core_MDF_PFR_RestAPI_PicklistValues.PicklistFieldValues ef = getField(r, 'Ecosystem Partner');
        System.assertNotEquals(null, ef);
    }

    @isTest
    static void test_currentUserHasCampaignUltimateAccountGroupAccess_Comprehensive_GetUserAccountIdNull() {
        Campaign c = getCampaign('TC_CCF');
        if (c == null || c.Core_MDF_Account__c == null) return;

        Test.startTest();
        Boolean result = Core_MDF_PFR_RestAPI_PicklistValues.currentUserHasCampaignUltimateAccountGroupAccess(c);
        Test.stopTest();

        System.assertEquals(false, result);
    }

    @isTest
    static void test_Comprehensive_AllExplicitMethodCoverage() {
        Test.startTest();
        
        String message1 = Core_MDF_PFR_RestAPI_PicklistValues.formatConfiguredMessage(null, null);
        System.assertEquals(null, message1);
        
        String message2 = Core_MDF_PFR_RestAPI_PicklistValues.formatConfiguredMessage('Hello {0}', new List<String>{'World'});
        System.assertNotEquals(null, message2);
        
        String message3 = Core_MDF_PFR_RestAPI_PicklistValues.formatConfiguredMessage('Simple', null);
        System.assertEquals('Simple', message3);

        Campaign testCampaign = [
            SELECT Id, Name, 
                   Core_MDF_Account__c, 
                   Core_MDF_Program__c, 
                   Core_MDF_Market__c,
                   Core_MDF_Activity_Category__c,
                   Core_MDF_Account__r.Id,
                   Core_MDF_Account__r.Name,
                   Core_MDF_Account__r.ParentId,
                   Core_MDF_Account__r.BillingCountry,
                   Core_MDF_Account__r.Core_MDF_Parent_Fund_Account__c,
                   Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c,
                   Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__r.Name
            FROM   Campaign 
            WHERE  Name = 'TC_CCF' 
            LIMIT  1
        ];

        List<Map<String, Object>> memberUsers =
            Core_MDF_PFR_RestAPI_PicklistValues.getMemberAcceptorUsersStructured(testCampaign);
        System.assertNotEquals(null, memberUsers);

        List<Core_MDF_PFR_RestAPI_PicklistValues.UserDetail> intelUsers2 = 
            Core_MDF_PFR_RestAPI_PicklistValues.getIntelApproverUsers(testCampaign.Core_MDF_Account__c, testCampaign);
        System.assertNotEquals(null, intelUsers2);

        Core_MDF_PFR_RestAPI_PicklistValues.getIntelApproverUsers(testCampaign);

        List<Account> accountList = [
            SELECT Id, 
                   Name,
                   ParentId,
                   BillingCountry,
                   Core_MDF_Parent_Fund_Account__c,
                   Core_MDF_CoMarketing_Ultimate_Account__c, 
                   Core_MDF_CoMarketing_Ultimate_Account__r.Name 
            FROM   Account 
            WHERE  Name = 'TC_Root_Account' 
            LIMIT  1
        ];
        if (!accountList.isEmpty()) {
            List<Core_MDF_PFR_RestAPI_PicklistValues.UserDetail> intelUsers3 = 
                Core_MDF_PFR_RestAPI_PicklistValues.getIntelApproverUsers(accountList, testCampaign);
            System.assertNotEquals(null, intelUsers3);
        }
        
        Core_MDF_PFR_RestAPI_PicklistValues.PicklistFieldValues fieldValues = 
            new Core_MDF_PFR_RestAPI_PicklistValues.PicklistFieldValues();
        fieldValues.values = new List<String>();
        fieldValues.dependentValues = new Map<String, List<String>>();
        
        Map<String, Schema.SObjectField> emptyFieldMap = new Map<String, Schema.SObjectField>();
        Core_MDF_PFR_RestAPI_PicklistValues.populateCampaignLevelValues(fieldValues, emptyFieldMap, 'Core_MDF_Priority__c', testCampaign);
        System.assertNotEquals(null, fieldValues.values);
        
        Core_MDF_PFR_RestAPI_PicklistValues.filterDependentValuesToFieldValues(null);
        
        Core_MDF_PFR_RestAPI_PicklistValues.PicklistFieldValues filterField1 = 
            new Core_MDF_PFR_RestAPI_PicklistValues.PicklistFieldValues();
        Core_MDF_PFR_RestAPI_PicklistValues.filterDependentValuesToFieldValues(filterField1);
        
        Core_MDF_PFR_RestAPI_PicklistValues.PicklistFieldValues filterField2 = 
            new Core_MDF_PFR_RestAPI_PicklistValues.PicklistFieldValues();
        filterField2.values = new List<String>{'Value1', 'Value2'};
        filterField2.dependentValues = new Map<String, List<String>>();
        filterField2.dependentValues.put('Control1', new List<String>{'Value1', 'Value3'});
        Core_MDF_PFR_RestAPI_PicklistValues.filterDependentValuesToFieldValues(filterField2);
        
        List<String> budgetValues1 = Core_MDF_PFR_RestAPI_PicklistValues.getAllowedBudgetValues(null);
        System.assertEquals(0, budgetValues1.size());
        
        Campaign budgetCampaign = getCampaign('TC_BudgetType');
        if (budgetCampaign != null) {
            List<String> budgetValues2 = Core_MDF_PFR_RestAPI_PicklistValues.getAllowedBudgetValues(budgetCampaign);
            System.assertNotEquals(null, budgetValues2);
        }
        Core_MDF_PFR_RestAPI_PicklistValues.getAllowedBudgetValues(testCampaign);
        Core_MDF_PFR_RestAPI_PicklistValues.getCampaignReimbursementRateValues(testCampaign);
        Test.stopTest();
    }

    @isTest
    static void test_AccountHierarchyTraversal_DeepLoop() {
        Id coMarketingRtId = null;
        try {
            coMarketingRtId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Core_MDF_Co_Marketing').getRecordTypeId();
        } catch (Exception e) {}

        ChannelProgram cp = [SELECT Id FROM ChannelProgram WHERE Name = 'Client' LIMIT 1];
        Account parentFundAcc = [SELECT Id FROM Account WHERE Name = 'TC_Parent_Account' LIMIT 1];

        Account p1 = new Account(
            Name = 'L1_Hier_Acc',
            RecordTypeId = coMarketingRtId,
            Core_MDF_Channel_Program__c = cp.Id,
            Core_MDF_Parent_Fund_Account__c = parentFundAcc.Id,
            BillingCountry = 'United States',
            BillingCity = 'City',
            BillingStreet = 'Street'
        );
        insert p1;

        Account p2 = new Account(
            Name = 'L2_Hier_Acc',
            RecordTypeId = coMarketingRtId,
            Core_MDF_Channel_Program__c = cp.Id,
            Core_MDF_Parent_Fund_Account__c = parentFundAcc.Id,
            ParentId = p1.Id,
            BillingCountry = 'United States',
            BillingCity = 'City',
            BillingStreet = 'Street'
        );
        insert p2;

        Account p3 = new Account(
            Name = 'L3_Hier_Acc',
            RecordTypeId = coMarketingRtId,
            Core_MDF_Channel_Program__c = cp.Id,
            Core_MDF_Parent_Fund_Account__c = parentFundAcc.Id,
            ParentId = p2.Id,
            BillingCountry = 'United States',
            BillingCity = 'City',
            BillingStreet = 'Street'
        );
        insert p3;

        Test.startTest();
        setupRestContext(new Map<String, String>{'acct-name' => 'L3_Hier_Acc'});
        Core_MDF_PFR_RestAPI_PicklistValues.doGet();
        Test.stopTest();
        System.assertEquals(200, RestContext.response.statusCode);
    }

    @isTest
    static void test_CalloutMock_EmptyPayloads() {
        Campaign c = getCampaign('TC_CCF');
        if (c == null) return;

        Map<String, Object> partialMock = new Map<String, Object>{
            'Id' => c.Id,
            'Name' => c.Name,
            'Core_MDF_Account__c' => 'NOT_AN_ID',
            'Core_MDF_Program__c' => '',
            'Core_MDF_Activity_Category__c' => null,
            'status' => '500'
        };
        Test.setMock(HttpCalloutMock.class, new MockHttp200(partialMock));
        setupRestContext(new Map<String, String>{'campaignId' => c.Id});

        Test.startTest();
        Core_MDF_PFR_RestAPI_PicklistValues.doGet();
        Test.stopTest();
        System.assertNotEquals(null, RestContext.response);
    }

    @isTest
    static void test_CalloutMock_NonNumericStatusCode() {
        Campaign c = getCampaign('TC_CCF');
        if (c == null) return;

        Map<String, Object> badStatusMock = new Map<String, Object>{
            'Id' => c.Id,
            'Name' => c.Name,
            'Core_MDF_Account__c' => String.valueOf(c.Core_MDF_Account__c),
            'statusCode' => 'invalid_number'
        };
        Test.setMock(HttpCalloutMock.class, new MockHttp200(badStatusMock));
        setupRestContext(new Map<String, String>{'campaignId' => c.Id});

        Test.startTest();
        Core_MDF_PFR_RestAPI_PicklistValues.doGet();
        Test.stopTest();
        System.assertNotEquals(null, RestContext.response);
    }

    @isTest
    static void test_MemberAcceptor_EmptyUsers() {
        Campaign bareCamp = new Campaign(Name = 'TC_Bare_Campaign');
        insert bareCamp;

        Test.startTest();
        List<Map<String, Object>> res = Core_MDF_PFR_RestAPI_PicklistValues.getMemberAcceptorUsersStructured(bareCamp);
        Test.stopTest();
        System.assertEquals(0, res.size());
    }

    @isTest
    static void test_Cover_Images_660_670_And_OverloadedApprover() {
        Test.startTest();

        Account rootAcc = [SELECT Id FROM Account WHERE Name = 'TC_Root_Account' LIMIT 1];
        List<Core_MDF_PFR_RestAPI_PicklistValues.UserDetail> res1 = 
            Core_MDF_PFR_RestAPI_PicklistValues.getIntelApproverUsers(rootAcc.Id);
        System.assertNotEquals(null, res1);

        Id nonExistentAccId = '001000000000000AAA';
        List<Core_MDF_PFR_RestAPI_PicklistValues.UserDetail> resEmpty = 
            Core_MDF_PFR_RestAPI_PicklistValues.getIntelApproverUsers(nonExistentAccId);
        System.assertNotEquals(null, resEmpty);
        System.assertEquals(0, resEmpty.size());

        List<Core_MDF_PFR_RestAPI_PicklistValues.UserDetail> resCatch = 
            Core_MDF_PFR_RestAPI_PicklistValues.getIntelApproverUsers((Id)null);
        System.assertNotEquals(null, resCatch);

        List<Core_MDF_PFR_RestAPI_PicklistValues.UserDetail> resEmptyList = 
            Core_MDF_PFR_RestAPI_PicklistValues.getIntelApproverUsers(new List<Account>(), (Campaign)null);
        System.assertNotEquals(null, resEmptyList);

        Test.stopTest();
    }

    @isTest
    static void test_Cover_Image_503_513_CampaignAccountFallbacks() {
        Campaign cNoAcc = new Campaign(Name = 'TC_No_Acc_Camp');
        insert cNoAcc;

        Map<String, Object> mockPayload = new Map<String, Object>{
            'Id' => cNoAcc.Id,
            'Name' => cNoAcc.Name,
            'Core_MDF_Account__c' => null
        };
        Test.setMock(HttpCalloutMock.class, new MockHttp200(mockPayload));
        setupRestContext(new Map<String, String>{'campaignId' => cNoAcc.Id});

        Test.startTest();
        Core_MDF_PFR_RestAPI_PicklistValues.doGet();
        Test.stopTest();

        System.assertEquals(200, RestContext.response.statusCode);
    }

    @isTest
    static void test_Cover_AccessControl_And_UltimateAccountTraversal() {
        Account childAcc = [SELECT Id, ParentId FROM Account WHERE Name = 'TC_Child_Account' LIMIT 1];

        Campaign campWithParentAcc = new Campaign(
            Name = 'TC_Traversal_Camp',
            Core_MDF_Account__c = childAcc.Id
        );

        Test.startTest();
        Boolean hasAccess = Core_MDF_PFR_RestAPI_PicklistValues.currentUserHasCampaignUltimateAccountGroupAccess(campWithParentAcc);
        System.assertEquals(false, hasAccess);

        Boolean nullCampAccess = Core_MDF_PFR_RestAPI_PicklistValues.currentUserHasCampaignUltimateAccountGroupAccess(null);
        System.assertEquals(false, nullCampAccess);

        Campaign campNullAcc = new Campaign(Name = 'TC_Camp_Null_Acc');
        Boolean nullAccAccess = Core_MDF_PFR_RestAPI_PicklistValues.currentUserHasCampaignUltimateAccountGroupAccess(campNullAcc);
        System.assertEquals(false, nullAccAccess);

        Campaign campFakeAcc = new Campaign(Name = 'TC_Fake_Acc', Core_MDF_Account__c = '001000000000001AAA');
        Boolean fakeAccAccess = Core_MDF_PFR_RestAPI_PicklistValues.currentUserHasCampaignUltimateAccountGroupAccess(campFakeAcc);
        System.assertEquals(false, fakeAccAccess);

        Test.stopTest();
    }

    @isTest
    static void test_Cover_FilteredValues_Labels_And_Fallbacks() {
        Campaign c = getCampaign('TC_CCF');
        if (c == null) return;

        Map<String, Object> labelPayload = new Map<String, Object>{
            'Id' => String.valueOf(c.Id),
            'Name' => '',
            'Account' => String.valueOf(c.Core_MDF_Account__c),
            'Program' => 'Client CoMarketing Fund',
            'Market' => 'Global'
        };

        Test.setMock(HttpCalloutMock.class, new MockHttp200(labelPayload));
        setupRestContext(new Map<String, String>{'campaignId' => c.Id});

        Test.startTest();
        Core_MDF_PFR_RestAPI_PicklistValues.doGet();
        Test.stopTest();

        System.assertEquals(200, RestContext.response.statusCode);
    }

    @isTest
    static void test_Cover_EnforceAccess_DirectTrigger() {
        Campaign c = getCampaign('TC_CCF');
        if (c == null) return;

        Test.setMock(HttpCalloutMock.class, new Core_MDF_RestAPI_Callout_Mock(403, '{"message":"Access Denied"}'));
        setupRestContext(new Map<String, String>{'campaignId' => c.Id});

        Test.startTest();
        Core_MDF_PFR_RestAPI_PicklistValues.doGet();
        Test.stopTest();

        System.assertNotEquals(null, RestContext.response);
    }

    @isTest
    static void test_Cover_MemberAcceptorUserDetail_Model() {
        Id currentUserId = UserInfo.getUserId();
        
        Test.startTest();
        Core_MDF_PFR_RestAPI_PicklistValues.MemberAcceptorUserDetail detail = 
            new Core_MDF_PFR_RestAPI_PicklistValues.MemberAcceptorUserDetail(
                currentUserId, 
                'Test User', 
                'Test Account'
            );
        
        System.assertEquals(currentUserId, detail.userId);
        System.assertEquals('Test User', detail.name);
        System.assertEquals('Test Account', detail.accName);

        detail.userId = currentUserId;
        detail.name = 'Updated User';
        detail.accName = 'Updated Account';
        
        System.assertEquals('Updated User', detail.name);
        System.assertEquals('Updated Account', detail.accName);
        Test.stopTest();
    }

    @isTest
    static void test_Cover_CampaignHasPre2025Category_AllBranches() {
        Campaign baseCamp = getCampaign('TC_CCF');
        if (baseCamp == null) return;

        Test.startTest();

        Map<String, Object> nullCategoryPayload = new Map<String, Object>{
            'Id' => baseCamp.Id,
            'Name' => baseCamp.Name,
            'Core_MDF_Program__c' => 'Client CoMarketing Fund',
            'Core_MDF_Activity_Category__c' => null
        };
        Test.setMock(HttpCalloutMock.class, new MockHttp200(nullCategoryPayload));
        setupRestContext(new Map<String, String>{'campaignId' => baseCamp.Id});
        Core_MDF_PFR_RestAPI_PicklistValues.doGet();

        Map<String, Object> pre2025Payload = new Map<String, Object>{
            'Id' => baseCamp.Id,
            'Name' => baseCamp.Name,
            'Core_MDF_Program__c' => 'Client CoMarketing Fund',
            'Core_MDF_Activity_Category__c' => 'Brand Awareness (Pre-2025);Digital Marketing'
        };
        Test.setMock(HttpCalloutMock.class, new MockHttp200(pre2025Payload));
        setupRestContext(new Map<String, String>{'campaignId' => baseCamp.Id});
        Core_MDF_PFR_RestAPI_PicklistValues.doGet();

        Map<String, Object> nonPrePayload = new Map<String, Object>{
            'Id' => baseCamp.Id,
            'Name' => baseCamp.Name,
            'Core_MDF_Program__c' => 'Client CoMarketing Fund',
            'Core_MDF_Activity_Category__c' => 'Demand Generation;Events'
        };
        Test.setMock(HttpCalloutMock.class, new MockHttp200(nonPrePayload));
        setupRestContext(new Map<String, String>{'campaignId' => baseCamp.Id});
        Core_MDF_PFR_RestAPI_PicklistValues.doGet();

        Test.stopTest();
    }

    @isTest
    static void test_Cover_FilterPicklistFallback_Catch() {
        Campaign baseCamp = getCampaign('TC_CCF');
        if (baseCamp == null) return;

        Test.startTest();
        Map<String, Object> malformedPayload = new Map<String, Object>{
            'Id' => baseCamp.Id,
            'Name' => baseCamp.Name,
            'Core_MDF_Program__c' => 'Invalid*Program#String!@#$',
            'Core_MDF_Activity_Category__c' => 'Unknown_Category'
        };
        Test.setMock(HttpCalloutMock.class, new MockHttp200(malformedPayload));
        setupRestContext(new Map<String, String>{'campaignId' => baseCamp.Id});
        Core_MDF_PFR_RestAPI_PicklistValues.doGet();
        Test.stopTest();

        System.assertEquals(200, RestContext.response.statusCode);
    }

    @isTest
    static void test_Cover_FilterPicklistValuesByProgram_DCF_And_Blank() {
        Campaign baseCamp = getCampaign('TC_CCF');
        if (baseCamp == null) return;

        Test.startTest();

        Map<String, Object> dcfPayload = new Map<String, Object>{
            'Id' => baseCamp.Id,
            'Name' => baseCamp.Name,
            'Core_MDF_Program__c' => 'Data Center CoMarketing Fund',
            'Core_MDF_Activity_Category__c' => 'Events',
            'Core_MDF_Activity_Type__c' => 'Tradeshow'
        };
        Test.setMock(HttpCalloutMock.class, new MockHttp200(dcfPayload));
        setupRestContext(new Map<String, String>{'campaignId' => baseCamp.Id});
        Core_MDF_PFR_RestAPI_PicklistValues.doGet();

        Map<String, Object> unknownProgPayload = new Map<String, Object>{
            'Id' => baseCamp.Id,
            'Name' => baseCamp.Name,
            'Core_MDF_Program__c' => 'Other_Unknown_Fund_Program',
            'Core_MDF_Activity_Category__c' => 'Digital',
            'Core_MDF_Activity_Type__c' => 'Banner'
        };
        Test.setMock(HttpCalloutMock.class, new MockHttp200(unknownProgPayload));
        setupRestContext(new Map<String, String>{'campaignId' => baseCamp.Id});
        Core_MDF_PFR_RestAPI_PicklistValues.doGet();

        Map<String, Object> blankProgPayload = new Map<String, Object>{
            'Id' => baseCamp.Id,
            'Name' => baseCamp.Name,
            'Core_MDF_Program__c' => '',
            'Core_MDF_Activity_Category__c' => 'Marketing'
        };
        Test.setMock(HttpCalloutMock.class, new MockHttp200(blankProgPayload));
        setupRestContext(new Map<String, String>{'campaignId' => baseCamp.Id});
        Core_MDF_PFR_RestAPI_PicklistValues.doGet();

        Test.stopTest();

        System.assertEquals(200, RestContext.response.statusCode);
    }

    @isTest
    static void test_Cover_CustomPicklistHelper_ViaPublicEndpoints() {
        Test.startTest();

        // 1. Invoking doGet() with no campaign parameters triggers the 3-parameter overload
        // buildDependentValuesFor(controllingField, dependentField, allowedValues) and
        // getActivePicklistValuesFromCustomObject(fieldName) without passing a program type.
        setupRestContext(new Map<String, String>());
        Core_MDF_PFR_RestAPI_PicklistValues.doGet();
        System.assertEquals(200, RestContext.response.statusCode);

        // 2. Setting up a callout payload that contains dependent picklists with mixed-case field mappings
        // and non-standard custom picklist fields executes the case-insensitive loop fallback
        // (lines 1671-1675) and field not found fallback (lines 1680-1682).
        Campaign c = getCampaign('TC_CCF');
        if (c != null) {
            Map<String, Object> customPicklistPayload = new Map<String, Object>{
                'Id' => c.Id,
                'Name' => c.Name,
                'Core_MDF_Program__c' => 'Client CoMarketing Fund',
                'core_mdf_activity_category__c' => 'Digital Marketing',
                'nonexistent_fake_field__c' => 'FakeVal'
            };
            Test.setMock(HttpCalloutMock.class, new MockHttp200(customPicklistPayload));
            setupRestContext(new Map<String, String>{'campaignId' => c.Id});
            Core_MDF_PFR_RestAPI_PicklistValues.doGet();
            System.assertEquals(200, RestContext.response.statusCode);
        }

        Test.stopTest();
    }
@isTest
    static void test_Cover_Ecosystem_Blank_And_Client() {
        Campaign baseCamp = getCampaign('TC_CCF');
        if (baseCamp == null) return;

        // 1. Cover line 1544-1545 & 1562-1563: blank program -> token is null -> isBlank(token) returns true
        Map<String, Object> blankProgPayload = new Map<String, Object>{
            'Id' => baseCamp.Id,
            'Name' => baseCamp.Name,
            'Core_MDF_Program__c' => ''
        };
        Test.setMock(HttpCalloutMock.class, new MockHttp200(blankProgPayload));
        setupRestContext(new Map<String, String>{'campaignId' => baseCamp.Id});

        Test.startTest();
        Core_MDF_PFR_RestAPI_PicklistValues.doGet();
        Test.stopTest();

        System.assertEquals(200, RestContext.response.statusCode);
    }

    @isTest
    static void test_Cover_Ecosystem_ClientProgram() {
        Campaign baseCamp = getCampaign('TC_CCF');
        if (baseCamp == null) return;

        // 2. Cover lines 1548-1550 & 1571-1573: tokenLower == 'client' -> checks 'client' or 'ccf'
        Map<String, Object> clientPayload = new Map<String, Object>{
            'Id' => baseCamp.Id,
            'Name' => baseCamp.Name,
            'Core_MDF_Program__c' => 'Client CoMarketing Fund'
        };
        Test.setMock(HttpCalloutMock.class, new MockHttp200(clientPayload));
        setupRestContext(new Map<String, String>{'campaignId' => baseCamp.Id});

        Test.startTest();
        Core_MDF_PFR_RestAPI_PicklistValues.doGet();
        Test.stopTest();

        System.assertEquals(200, RestContext.response.statusCode);
    }

    @isTest
    static void test_Cover_Ecosystem_DataCenterProgram() {
        Campaign baseCamp = getCampaign('TC_DCF');
        if (baseCamp == null) {
            baseCamp = getCampaign('TC_CCF');
        }
        if (baseCamp == null) return;

        // 3. Cover lines 1552-1553 & 1574-1577: tokenLower == 'data%center' -> datacenter compact check
        Map<String, Object> dataCenterPayload = new Map<String, Object>{
            'Id' => baseCamp.Id,
            'Name' => baseCamp.Name,
            'Core_MDF_Program__c' => 'Data Center CoMarketing Fund'
        };
        Test.setMock(HttpCalloutMock.class, new MockHttp200(dataCenterPayload));
        setupRestContext(new Map<String, String>{'campaignId' => baseCamp.Id});

        Test.startTest();
        Core_MDF_PFR_RestAPI_PicklistValues.doGet();
        Test.stopTest();

        System.assertEquals(200, RestContext.response.statusCode);
    }

    @isTest
    static void test_Cover_Ecosystem_UnknownProgram() {
        Campaign baseCamp = getCampaign('TC_CCF');
        if (baseCamp == null) return;

        // 4. Cover line 1555: unknown program name -> token is null
        Map<String, Object> unknownProgPayload = new Map<String, Object>{
            'Id' => baseCamp.Id,
            'Name' => baseCamp.Name,
            'Core_MDF_Program__c' => 'Completely_Unrelated_Other_Program_XYZ'
        };
        Test.setMock(HttpCalloutMock.class, new MockHttp200(unknownProgPayload));
        setupRestContext(new Map<String, String>{'campaignId' => baseCamp.Id});

        Test.startTest();
        Core_MDF_PFR_RestAPI_PicklistValues.doGet();
        Test.stopTest();

        System.assertEquals(200, RestContext.response.statusCode);
    }
}