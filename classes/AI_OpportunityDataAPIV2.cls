@RestResource(urlMapping='/OpportunityAIDataV2')
global with sharing class AI_OpportunityDataAPIV2 {
    
    @HttpPost
    global static Pricing_RestAPI_Response getOpportunityData() {
        // Fetching the opportunity ID or account ID from the request
        RestRequest req = RestContext.request;
        
        // Parse the JSON payload
        String jsonString = req.requestBody.toString();
        // String jsonString = '{\'AccountName\': \'\', \'AccountId\': \'0011J000017f0U0QAI\', \'AccountIndustry\': \'Healthcare\', \'AccountCategory\': \'\', \'SalesGroup\': \'\', \'OpportunityId\': \'\', \'OpportunityOwnerId\': \'\', \'OpportunityManagerId\': \'\', \'Product\': \'Lunar Lake\', \'DecisionDate\': \'\', \'DecisionYear\': 2023, \'DecisionQtr\': 0, \'DecisionMonth\': 0, \'VerticalMarket\': \'\', \'IntelMarket\': \'\', \'Stage\': \'\', \'Query\': \'How is GE Healthcare Europe account with id 0011J000017f0U0QAI doing for its healthcare industry opportunities? Also help me in listing down the opens/roadblocks in closing its opportunities with decision year as 2023.\'}';
        Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
        
        // Extract values from the JSON map
        String accountId = (String) jsonMap.get('AccountId');
        String accountIndustry = (String) jsonMap.get('AccountIndustry');
        String accountCategory = (String) jsonMap.get('AccountCategory');
        String salesGroup = (String) jsonMap.get('SalesGroup');
        String accountBizOrgType = (String) jsonMap.get('AccountBizOrgType');
        String accountBUFocus = (String) jsonMap.get('AccountBUFocus');
        String opportunityId = (String) jsonMap.get('OpportunityId');
        String opportunityOwnerId = (String) jsonMap.get('OpportunityOwnerId');
        String opportunityManagerId = (String) jsonMap.get('OpportunityManagerId');
        String productName = (String) jsonMap.get('Product');
        String verticalMarket = (String) jsonMap.get('VerticalMarket');
        String productSegment = (String) jsonMap.get('ProductSegment');
        String opportunityType = (String) jsonMap.get('OpportunityType');
        String intelMarket = (String) jsonMap.get('IntelMarket');
        String stage = (String) jsonMap.get('Stage');
        String accountCreatedStartDateStr = (String) jsonMap.get('AccountCreatedStartDate');
        String accountCreatedEndDateStr = (String) jsonMap.get('AccountCreatedEndDate');
        String accountModifiedStartDateStr = (String) jsonMap.get('AccountModifiedStartDate');
        String accountModifiedEndDateStr = (String) jsonMap.get('AccountModifiedEndDate');
        String opportunityCreatedStartDateStr = (String) jsonMap.get('OpportunityCreatedStartDate');
        String opportunityCreatedEndDateStr = (String) jsonMap.get('OpportunityCreatedEndDate');
        String opportunityModifiedStartDateStr = (String) jsonMap.get('OpportunityModifiedStartDate');
        String opportunityModifiedEndDateStr = (String) jsonMap.get('OpportunityModifiedEndDate');
        String closeStartDateStr = (String) jsonMap.get('CloseStartDate');
        String closeEndDateStr = (String) jsonMap.get('CloseEndDate');
        String revenueCondition = (String) jsonMap.get('RevenueCondition');
        Decimal revenueValue = (Decimal) jsonMap.get('RevenueValue');
        //String aggregationField = (String) jsonMap.get('AggregationField');
        //String aggregationFunction = (String) jsonMap.get('AggregationFunction');
        String limitField = (String) jsonMap.get('LimitField');
        Integer limitValue = (Integer) jsonMap.get('Limit');
        
        // Convert date strings to Date objects
        Date accountCreatedStartDate = (accountCreatedStartDateStr != null && accountCreatedStartDateStr != '') ? Date.valueOf(accountCreatedStartDateStr) : null;
        Date accountCreatedEndDate = (accountCreatedEndDateStr != null && accountCreatedEndDateStr != '') ? Date.valueOf(accountCreatedEndDateStr) : null;
        Date accountModifiedStartDate = (accountModifiedStartDateStr != null && accountModifiedStartDateStr != '') ? Date.valueOf(accountModifiedStartDateStr) : null;
        Date accountModifiedEndDate = (accountModifiedEndDateStr != null && accountModifiedEndDateStr != '') ? Date.valueOf(accountModifiedEndDateStr) : null;
        Date opportunityCreatedStartDate = (opportunityCreatedStartDateStr != null && opportunityCreatedStartDateStr != '') ? Date.valueOf(opportunityCreatedStartDateStr) : null;
        Date opportunityCreatedEndDate = (opportunityCreatedEndDateStr != null && opportunityCreatedEndDateStr != '') ? Date.valueOf(opportunityCreatedEndDateStr) : null;
        Date opportunityModifiedStartDate = (opportunityModifiedStartDateStr != null && opportunityModifiedStartDateStr != '') ? Date.valueOf(opportunityModifiedStartDateStr) : null;
        Date opportunityModifiedEndDate = (opportunityModifiedEndDateStr != null && opportunityModifiedEndDateStr != '') ? Date.valueOf(opportunityModifiedEndDateStr) : null;
        Date closeStartDate = (closeStartDateStr != null && closeStartDateStr != '') ? Date.valueOf(closeStartDateStr) : null;
        Date closeEndDate = (closeEndDateStr != null && closeEndDateStr != '') ? Date.valueOf(closeEndDateStr) : null;
        
        Pricing_RestAPI_Response restResponse = new Pricing_RestAPI_Response();
        // Create a wrapper to return the response
        AI_OpportunityDataWrapper.OpportunityWrapper responseWrapper = new AI_OpportunityDataWrapper.OpportunityWrapper();
        List<AI_OpportunityDataWrapper.OpportunityWrapper> wrappedOpportunities = new List<AI_OpportunityDataWrapper.OpportunityWrapper>();
		String soql = '';
        // Build the dynamic SOQL query  
        soql = Label.SMG_1AI_Opportunity_Query;
        Boolean fullDetails = false;
        
        if (accountId != null && accountId != '') {
            soql += ' AND AccountId = :accountId';
            fullDetails = true;
        }
        if (accountIndustry != null && accountIndustry != '') {
            List<String> accountIndustryList = accountIndustry.split(',');
            soql += ' AND (' + buildLikeClause(new List<String>{'Account.Industry'}, accountIndustryList) + ')';
        }
        
        if (accountCategory != null && accountCategory != '') {
            List<String> accountCategoryList = accountCategory.split(',');
            soql += ' AND (' + buildLikeClause(new List<String>{'Account.Core_Account_Category__c'}, accountCategoryList) + ')';
        }
        if (salesGroup != null && salesGroup != '') {
            List<String> salesGroupList = salesGroup.split(',');
            soql += ' AND (' + buildLikeClause(new List<String>{'Core_Sales_Groups__c'}, salesGroupList) + ')';
        }
        if (accountBUFocus != null && accountBUFocus != '') {
            List<String> accountBUFocusList = accountBUFocus.split(',');
            soql += ' AND (' + buildInClause(new List<String>{'Account.Core_Account_BU_Focus__c'}, accountBUFocusList) + ')';
        }
        if (productSegment != null && productSegment != '') {
            List<String> productSegmentList = productSegment.split(',');
            soql += ' AND (' + buildInClause(new List<String>{'Core_Product_Segment__c'}, productSegmentList) + ')';
        }
        if (opportunityType != null && opportunityType != '') {
            List<String> opportunityTypeList = opportunityType.split(',');
            soql += ' AND (' + buildInClause(new List<String>{'Core_Opportunity_Type__c'}, opportunityTypeList) + ')';
        }
        if (accountBizOrgType != null && accountBizOrgType != '') {
            List<String> accountBizOrgTypeList = accountBizOrgType.split(',');
            soql += ' AND (' + buildInClause(new List<String>{'Account.Core_Account_Type__c'}, accountBizOrgTypeList) + ')';
        }
        if (opportunityId != null && opportunityId != '') {
            soql += ' AND Id = :opportunityId';
        }        
        if (opportunityOwnerId != null && opportunityOwnerId != '') {
            List<String> opportunityOwnerIdList = opportunityOwnerId.split(',');
            soql += ' AND (' + buildInClause(new List<String>{'OwnerId'}, opportunityOwnerIdList) + ')';
            fullDetails = true;
        }
        if (opportunityManagerId != null && opportunityManagerId != '') {
            List<String> opportunityManagerIdList = opportunityManagerId.split(',');
            soql += ' AND (' + buildInClause(new List<String>{'Owner.ManagerId'}, opportunityManagerIdList) + ')';
            fullDetails = true;
        }
        if (productName != null && productName != '') {
            List<String> productNameList = productName.split(',');
            soql += ' AND Id IN (SELECT OpportunityId FROM OpportunityLineItem WHERE (' + buildLikeClause(new List<String>{'Core_Normalized_Product_Name__c','Product2.Name', 'Product2.Core_Platform_Name__c','Product2.Core_Product_Family__c'}, productNameList) + '))';
            fullDetails = true;
        }
        if (accountCreatedStartDate != null) {
            soql += ' AND Account.CreatedDate >= :accountCreatedStartDate';
        }
        if (accountCreatedEndDate != null) {
            soql += ' AND Account.CreatedDate <= :accountCreatedEndDate';
        }
        if (accountModifiedStartDate != null) {
            soql += ' AND Account.LastModifiedDate >= :accountModifiedStartDate';
        }
        if (accountModifiedEndDate != null) {
            soql += ' AND Account.LastModifiedDate <= :accountModifiedEndDate';
        }
        if (opportunityCreatedStartDate != null) {
            soql += ' AND CreatedDate >= :opportunityCreatedStartDate';
        }
        if (opportunityCreatedEndDate != null) {
            soql += ' AND CreatedDate <= :opportunityCreatedEndDate';
        }
        if (opportunityModifiedStartDate != null) {
            soql += ' AND LastModifiedDate >= :opportunityModifiedStartDate';
        }
        if (opportunityModifiedEndDate != null) {
            soql += ' AND LastModifiedDate <= :opportunityModifiedEndDate';
        }
        if (closeStartDate != null) {
            soql += ' AND CloseDate >= :closeStartDate';
        }
        if (closeEndDate != null) {
            soql += ' AND CloseDate <= :closeEndDate';
        }
		if (revenueCondition != null && revenueCondition != '' && revenueValue != null) {
            soql += ' AND Amount ' + revenueCondition + ' :revenueValue';
        }        
        if (verticalMarket != null && verticalMarket != '') {
            List<String> verticalMarketList = verticalMarket.split(',');
            soql += ' AND (' + buildLikeClause(new List<String>{'Core_Consumption_Market__c'}, verticalMarketList) + ')';
        }
        if (intelMarket != null && intelMarket != '') {
            List<String> intelMarketList = intelMarket.split(',');
            soql += ' AND (' + buildLikeClause(new List<String>{'Core_Intel_Platform__c'}, intelMarketList) + ')';
        }

        if (stage != null && stage != '') {
			List<String> stageList = stage.split(',');
            soql += ' AND (' + buildInClause(new List<String>{'StageName'}, stageList) + ')';
        }

        soql += ' '+ Label.SMG_1AI_Opportunity_Limit_Query; 
        // Execute the dynamic SOQL query
		//system.debug('###soql'+ soql);
        List<Opportunity> opps = Database.query(soql);
        Integer opportunityCount = opps.size();
        // Fetch related data for all opportunities in a single query using relationship queries
        List<Core_Opportunity_Partner__c> opptyPartner = new List<Core_Opportunity_Partner__c>();
        List<FeedItem> oppFeeds = new List<FeedItem>();
        List<Task> oppTasks = new List<Task>();
        Map<Id, List<OpportunityLineItem>> oppLineItems = new Map<Id, List<OpportunityLineItem>>();
        Map<Id, List<Core_Opportunity_Partner__c>> oppPartners = new Map<Id, List<Core_Opportunity_Partner__c>>();
        Map<Id, List<FeedItem>> oppChatter = new Map<Id, List<FeedItem>>();
        Map<Id, List<Task>> oppTaskItems = new Map<Id, List<Task>>();
        List<OpportunityLineItem> oppProducts = new List<OpportunityLineItem>();
        
        Integer recordLimit = Integer.valueOf(Label.SMG_1AI_Opportunity_Limit_Partial_Query);
        Integer recordCounter = 0;
        if(fullDetails){
            oppProducts = [SELECT OpportunityId,Opportunity.Name,Opportunity.AccountId, Opportunity.Account.Name,Product2.Name, 
                           Core_Status__c,Quantity, UnitPrice, TotalPrice,Core_BU_Short_Name__c ,Core_BU_Mapping_record__r.Core_BU_Segment__c,
                           Core_Competitor__c, Core_Competitor_Product__c,Core_OtherCompetitor_Product_Txt__c, Core_Loss_Cancel_Reason__c, Core_Loss_Cancel_Details__c, 
                           Core_Risk_Category__c, Core_Risk_Detail__c,  CreatedDate,CreatedBy.Name FROM OpportunityLineItem WHERE OpportunityId IN :opps];
            
            
            for (OpportunityLineItem lineItem : oppProducts) {
                if (!oppLineItems.containsKey(lineItem.OpportunityId)) {
                    oppLineItems.put(lineItem.OpportunityId, new List<OpportunityLineItem>());
                }
                oppLineItems.get(lineItem.OpportunityId).add(lineItem);
            }
            
            
            opptyPartner = [SELECT Core_Opportunity__c,Core_Opportunity__r.Name,Core_Opportunity__r.AccountId, Core_Opportunity__r.Account.Name, Core_UCD_Partner_Account_Name__c,
                            Core_Partner_Role__c, Core_Partner_Type__c, CreatedDate,CreatedBy.Name FROM Core_Opportunity_Partner__c  WHERE Core_Opportunity__c  IN :opps];
            for (Core_Opportunity_Partner__c partner : opptyPartner) {
                if (!oppPartners.containsKey(partner.Core_Opportunity__c)) {
                    oppPartners.put(partner.Core_Opportunity__c, new List<Core_Opportunity_Partner__c>());
                }
                oppPartners.get(partner.Core_Opportunity__c).add(partner);
            }
            /*oppFeeds = [SELECT ParentId,Parent.Name, CreatedBy.Name, CreatedDate, Body FROM FeedItem WHERE ParentId  IN :opps AND HasContent = true];
            for (FeedItem feed : oppFeeds) {
                if (!oppChatter.containsKey(feed.ParentId)) {
                    oppChatter.put(feed.ParentId, new List<FeedItem>());
                }
                oppChatter.get(feed.ParentId).add(feed);
            }
            oppTasks = [SELECT WhatId,What.Name, Subject,Description, Status, Priority, CreatedDate,CreatedBy.Name,Account.Name,AccountId 
                        FROM Task WHERE WhatId IN :opps AND (NOT Subject LIKE '6QPS Approval Request%')];
            for (Task task : oppTasks) {
                if (!oppTaskItems.containsKey(task.WhatId)) {
                    oppTaskItems.put(task.WhatId, new List<Task>());
                }
                oppTaskItems.get(task.WhatId).add(task);
            }*/
        }
        
        // Loop through each opportunity and fetch related data (products, partners, chatter, tasks)
        for (Opportunity opp : opps) {
            if (!fullDetails && recordCounter >= recordLimit) {
                break; // Exit the loop if the limit is reached
            }
            AI_OpportunityDataWrapper.Opportunity oppWrapper = new AI_OpportunityDataWrapper.Opportunity();
            oppWrapper.opportunityId = opp.Id;
            oppWrapper.opportunityName = opp.Name;
            oppWrapper.accountId = opp.AccountId;
            oppWrapper.accountName = opp.Account.Name;
            oppWrapper.sellerName = opp.Owner.Name;
            oppWrapper.closedDate = opp.CloseDate;
            oppWrapper.riskReason = opp.Core_Risk_Reason__c;
            
            oppWrapper.quantity = opp.TotalOpportunityQuantity;
            oppWrapper.productApplication = opp.Core_Product_Application__c;
            oppWrapper.competitiveArchitecture = opp.Core_Competitive_Architecture__c;
            oppWrapper.intelPlatform = opp.Core_Intel_Platform__c;
            oppWrapper.ownerGeo = opp.Core_Opportunity_Owner_Geo__c;
            
            oppWrapper.Stage = opp.StageName;
            oppWrapper.opportunityStatus = opp.IsClosed ? 'Closed' : 'Open';
            oppWrapper.opportunityType = opp.Core_Opportunity_Type__c;
            oppWrapper.WinAmount = opp.Amount;
            oppWrapper.lostAmount = opp.Core_Oppty_Lost_Total_Price__c;
            oppWrapper.createdDate = opp.CreatedDate;
            oppWrapper.createdByName = opp.CreatedBy.Name;
            
            responseWrapper.opportunities.add(oppWrapper);
            // Increment the counter
    		recordCounter++;
            if (oppLineItems.containsKey(opp.Id)) {
                for (OpportunityLineItem oppProduct : oppLineItems.get(opp.Id)) {
                    AI_OpportunityDataWrapper.OpportunityProducts product = new AI_OpportunityDataWrapper.OpportunityProducts();
                    product.opportunityId = oppProduct.OpportunityId;
                    product.opportunityName = oppProduct.Opportunity.Name;
                    product.accountId = oppProduct.Opportunity.AccountId;
                    product.accountName = oppProduct.Opportunity.Account.Name;
                    product.opportunityProductName = oppProduct.Product2.Name;
                    product.opportunityProductStatus = oppProduct.Core_Status__c;
                    product.opportunityProductSalesPrice = oppProduct.UnitPrice;
                    product.opportunityProductQuantity = oppProduct.Quantity;
                    product.opportunityProductTotalPrice = oppProduct.TotalPrice;
                    product.opportunityProductBU = oppProduct.Core_BU_Short_Name__c;
                    product.opportunityProductSegment = oppProduct.Core_BU_Mapping_record__r.Core_BU_Segment__c;
                    product.competitor = oppProduct.Core_Competitor__c;                
                    product.competitorProduct = oppProduct.Core_Competitor_Product__c;
                    product.otherCompetitor = oppProduct.Core_OtherCompetitor_Product_Txt__c;
                    product.lossCancelDetails = oppProduct.Core_Loss_Cancel_Details__c;
                    product.lossCancelReason = oppProduct.Core_Loss_Cancel_Reason__c;
                    product.riskCategory = oppProduct.Core_Risk_Category__c;
                    product.riskDetails = oppProduct.Core_Risk_Detail__c;
                    product.createdDate = oppProduct.CreatedDate;
                    product.createdByName = oppProduct.CreatedBy.Name;
                    
                    // Add to the wrapper list
                    responseWrapper.opportunityProducts.add(product);
                }
            }
            
            if (oppPartners.containsKey(opp.Id)) {
                for (Core_Opportunity_Partner__c oppPartner : oppPartners.get(opp.Id)) {
                    AI_OpportunityDataWrapper.OpportunityPartners partner = new AI_OpportunityDataWrapper.OpportunityPartners();
                    partner.opportunityId = oppPartner.Core_Opportunity__c;
                    partner.opportunityName = oppPartner.Core_Opportunity__r.Name;
                    partner.accountId = oppPartner.Core_Opportunity__r.AccountId;
                    partner.accountName = oppPartner.Core_Opportunity__r.Account.Name;
                    partner.partnerAccountName = oppPartner.Core_UCD_Partner_Account_Name__c;
                    partner.partnerRole = oppPartner.Core_Partner_Role__c;
                    partner.partnerType = oppPartner.Core_Partner_Type__c;
                    partner.createdDate = oppPartner.CreatedDate;
                    partner.createdByName = oppPartner.CreatedBy.Name;
                    
                    // Add to the wrapper list
                    responseWrapper.opportunityPartners.add(partner);
                }
            }
            
            
            /*if (oppChatter.containsKey(opp.Id)) {
                for (FeedItem oppFeed : oppChatter.get(opp.Id)) {
                    AI_OpportunityDataWrapper.OpportunityChatter feed = new AI_OpportunityDataWrapper.OpportunityChatter();
                    feed.opportunityId = oppFeed.ParentId;
                    feed.opportunityName = oppFeed.Parent.Name;
                    feed.body = oppFeed.Body;
                    feed.createdDate = oppFeed.CreatedDate;
                    feed.createdByName = oppFeed.CreatedBy.Name;
                    
                    // Add to the wrapper list
                    responseWrapper.opportunityChatter.add(feed);
                } 
            }
            
            
            if (oppTaskItems.containsKey(opp.Id)) {
                for (Task oppTask : oppTaskItems.get(opp.Id)) {
                    if(oppTask.Description != null){
                        AI_OpportunityDataWrapper.OpportunityTasks task = new AI_OpportunityDataWrapper.OpportunityTasks();
                        task.opportunityId = oppTask.WhatId;
                        task.opportunityName = oppTask.What.Name;
                        task.accountId = oppTask.AccountId;
                        task.accountName = oppTask.Account.Name;
                        task.subject = oppTask.Subject;
                        task.description = oppTask.Description;
                        task.status = oppTask.Status;
                        task.priority = oppTask.Priority;
                        task.createdDate = oppTask.CreatedDate;
                        task.createdByName = oppTask.CreatedBy.Name;
                        
                        // Add to the wrapper list
                        responseWrapper.opportunityTasks.add(task);
                    }
                }
            }*/
            
        }
        wrappedOpportunities.add(responseWrapper);
        restResponse.successContent = wrappedOpportunities;
        restResponse.totalRecords = opportunityCount;
        // Return the wrapper containing the data
        return restResponse;//JSON.serialize(responseWrapper);
    }
    private static String buildLikeClause(List<String> fieldNames, List<String> values) {
        List<String> likeClauses = new List<String>();
        for (String fieldName : fieldNames) {
            for (String value : values) {
                likeClauses.add(fieldName + ' LIKE \'%' + String.escapeSingleQuotes(value.trim()) + '%\'');
            }
        }
        return String.join(likeClauses, ' OR ');
    }
    
    private static String buildInClause(List<String> fieldNames, List<String> values) {
        List<String> inClauses = new List<String>();
        // Loop through each field name
        for (String fieldName : fieldNames) {
            String inClause = fieldName + ' IN (';
            for (Integer i = 0; i < values.size(); i++) {
                inClause += '\'' + String.escapeSingleQuotes(values[i].trim()) + '\'';
                if (i < values.size() - 1) {
                    inClause += ', ';
                }
            }
            inClause += ')';
            inClauses.add(inClause);
        }
        return String.join(inClauses, ' OR ');
    }
}