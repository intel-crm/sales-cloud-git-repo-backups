public without sharing class Core_OpportunityDataFetcher {
    
    public class OpportunityWrapper implements Pricing_RestAPI_SuccessContent {
        public Id oppId;
        public String oppUrl;
        public Date closedDate;
        public String name;
        public String description;
        public String riskReason;
        public String statusUpdate;
        public String stage;
        public String type;
        //public String productSegment;
        public Decimal amount;
        public Decimal lostAmount;
        public String opportunityURL;
        public boolean isSparseOpp;
        public List<ProductWrapper> products;
        public List<PartnerWrapper> partners;
        public List<ChatterFeed> chatter;
        public List<TaskList> tasks;
        
        public OpportunityWrapper() {
            products = new List<ProductWrapper>();
            
            partners = new List<PartnerWrapper>();
            
            chatter = new List<ChatterFeed>();
            
            tasks = new List<TaskList>();
        }
        
    }
    
    public class ChatterFeed {
        public Id feedId;
        public String Body;
        public Date CreatedDate;
        public String CreatedByName; // Additional field based on product name conditions
    }
    
    public class TaskList {
        public Id taskId;
        public String Subject;
        public String Description;
        public Date CreatedDate; // Additional field based on product name conditions
    }
    
    public class ProductWrapper {
        public String productName;
        public Decimal productAmount;
        public Decimal productQuantity;
        public String Core_Product_Segment;
        public String competitor;
        public String competitor_product;
        public String other_competitor;
        public String loss_cancel_details;
        public String loss_cancel_reason;
        public String risk_category;
        public String risk_details;
        // Additional field based on product name conditions
    }
    public class PartnerWrapper {
        public Id partnerId;
        public String partnerAccountName;
        public String partnerRole;
        public String partnerType;
        
        // Constructor, getters, and setters can be added as needed
    }
    public static List<OpportunityWrapper> getOpportunityData(id accountID) {
        List<String> Core_Opportunity_Type = new List<String>();
        Core_Opportunity_Type.add('Deal: Sell-to');
        List<Opportunity> opportunities = [
            SELECT Id,CRM_Opportunity_URL__c, CloseDate, Name, Description, StageName, Type, Amount, 
            Decision_Date__c,Core_Product_Segment__c,NextStep, Core_Status_Update__c, Account.Name,
            (SELECT Quantity, UnitPrice, TotalPrice,Core_BU_Short_Name__c , Product2.Name, Product2.Id ,Core_BU_Mapping_record__c,Core_BU_Mapping_record__r.Core_BU_Segment__c
             FROM OpportunityLineItems 
             WHERE  Core_Status__c NOT IN ('Delete In Progress (<15 min)','Cancelled','Lost')),
            (SELECT Id, Core_UCD_Partner_Account_Name__c, Core_Partner_Role__c, Core_Partner_Type__c 
             FROM Opportunity_Partners__r)
            FROM Opportunity WHERE AccountId =: accountID and 
            Decision_Date__c = LAST_FISCAL_YEAR  limit 30
        ];//and ID NOT IN : OppId limit 5
        integer TotSpareCount = 0;
        List<OpportunityWrapper> wrappedOpportunities = new List<OpportunityWrapper>();
        for (Opportunity opp : opportunities) {
            string checkDis_St_Nt = (opp.NextStep != null ? opp.NextStep : '') +
                (opp.Core_Status_Update__c != null ? opp.Core_Status_Update__c : '') +
                (opp.Description != null ? opp.Description : '');
            //if(checkDis_St_Nt.length() > 160){
                OpportunityWrapper wrappedOpp = new OpportunityWrapper();
                wrappedOpp.oppId = opp.Id;
                wrappedOpp.closedDate = opp.CloseDate;
                wrappedOpp.name = opp.Name;
                wrappedOpp.statusUpdate = opp.Core_Status_Update__c;
                wrappedOpp.description = opp.Description;
                wrappedOpp.stage = opp.StageName;
                wrappedOpp.type = opp.Type;
                wrappedOpp.amount = opp.Amount;
                wrappedOpp.oppUrl = opp.CRM_Opportunity_URL__c;
                
                for (OpportunityLineItem oli : opp.OpportunityLineItems) {
                    ProductWrapper wrappedProduct = new ProductWrapper();
                    wrappedProduct.productName = oli.Product2.Name;
                    wrappedProduct.productAmount = oli.TotalPrice;
                    wrappedProduct.productQuantity = oli.Quantity;
                    if(oli.Core_BU_Mapping_record__c != null){
                        wrappedProduct.Core_Product_Segment = oli.Core_BU_Mapping_record__r.Core_BU_Segment__c != null ? determineProSeg(oli.Core_BU_Mapping_record__r.Core_BU_Segment__c): determineProSeg(opp.Core_Product_Segment__c);
                    }
                    else 
                        wrappedProduct.Core_Product_Segment = determineProSeg(oli.Product2.Name);
                    
                    wrappedOpp.products.add(wrappedProduct);
                }
                for (Core_Opportunity_Partner__c partner : opp.Opportunity_Partners__r) {
                    PartnerWrapper wrappedPartner = new PartnerWrapper();
                    wrappedPartner.partnerId = partner.Id;
                    wrappedPartner.partnerAccountName = partner.Core_UCD_Partner_Account_Name__c;
                    wrappedPartner.partnerRole = partner.Core_Partner_Role__c;
                    wrappedPartner.partnerType = partner.Core_Partner_Type__c;
                    
                    wrappedOpp.partners.add(wrappedPartner);
                }
                wrappedOpportunities.add(wrappedOpp);
            //}
            //else
            //    TotSpareCount += 1;
        }
        //String wrappedOpp = JSON.serializePretty(wrappedOpportunities);
        return wrappedOpportunities;
    }
    
    
    public static Map<Id,Opportunity> getOpportunityData(String sellerName,String accountId,String methodName){
        Map<Id,Opportunity> oppList = new Map<Id,Opportunity>();
        
        String queryForUser = 'SELECT id from User where name LIKE \'%' + String.escapeSingleQuotes(sellerName) + '%\' LIMIT 1';
        List<User> users = Database.query(queryForUser);
        String userId = users[0].Id;
        
        String query = 'SELECT Id, StageName,Name, Description, Core_Risk_Reason__c, Core_Status_Update__c, ' +
                       '(SELECT Quantity, UnitPrice, TotalPrice, Core_BU_Short_Name__c, Product2.Name, Product2.Id, ' +
                       'Core_Competitor__c, Core_Competitor_Product__c, Core_OtherCompetitor_Product_Txt__c,Core_Loss_Cancel_Details__c, Core_Loss_Cancel_Reason__c,Core_Risk_Category__c, Core_Risk_Detail__c '+           
                       'FROM OpportunityLineItems ' +
                       'WHERE Core_Status__c NOT IN (\'Delete In Progress (<15 min)\', \'Cancelled\', \'Lost\')), ' +
                       '(SELECT Id, Core_UCD_Partner_Account_Name__c, Core_Partner_Role__c, Core_Partner_Type__c ' +
                       'FROM Opportunity_Partners__r) ' +
                       'FROM Opportunity ';

        if (methodName == 'getStagnentOpp') {
            query += 'WHERE Core_Days_in_Current_Stage__c > 30 AND OwnerId = :userId AND AccountId = :accountId ' +
                     'ORDER BY CreatedDate DESC';
        }
        else if (methodName == 'getOpenOpp') {
            query += 'WHERE StageName IN (\'Qualify\', \'Define\', \'Design\', \'Develop\') AND OwnerId = :userId AND AccountId = :accountId ' +
                     'ORDER BY CreatedDate DESC';
        }
        else if (methodName == 'getOppInfo') {
            query += 'WHERE StageName IN (\'Qualify\', \'Define\', \'Design\', \'Develop\') AND AccountId = :accountId ' +
                     'ORDER BY CreatedDate DESC'; 
        }
        else if (methodName == 'getAllInfo'){
            query += 'WHERE AccountId = :accountId AND (CreatedDate >= LAST_N_YEARS:2 OR LastModifiedDate >= LAST_N_YEARS:2)' +
                     'ORDER BY CreatedDate DESC'; 
        }
        List<Opportunity> opportunities = Database.query(query);
        for(Opportunity opportunity : opportunities){
                oppList.put(opportunity.Id,opportunity);
            }
        
        return oppList;
    }
    
    public static Map<Id,List<Task>> getTasks(Map<Id,Opportunity> oppList){
        Map<Id,List<Task>> taskList = new Map<Id,List<Task>>();
        for(Task t:[SELECT Id, Subject, Description, CreatedDate,WhatId FROM Task
            WHERE WhatId in : oppList.keySet()]){
                List<Task> tsk = new List<Task>();
                if(taskList.containsKey(t.WhatId)){
                    tsk = taskList.get(t.WhatId);
                    tsk.add(t);
                }
                else{
                    tsk.add(t);
                }
                taskList.put(t.WhatId,tsk);
            }
        return taskList;
    }
    
        public static Map<Id,List<FeedItem>> getChatterFeeds(Map<Id,Opportunity> oppList){
        Map<Id,List<FeedItem>> feedList = new Map<Id,List<FeedItem>>();
        for(FeedItem f:[SELECT Id, Body, CreatedDate, CreatedBy.Name,ParentId FROM FeedItem WHERE ParentId in : oppList.keySet()]){
            if(f.Body != null){
                List<FeedItem> fitem = new List<FeedItem>();
                if(feedList.containsKey(f.ParentId)){
                    fitem = feedList.get(f.ParentId);
                    fitem.add(f);
                }
                else{
                    fitem.add(f);
                }
                feedList.put(f.ParentId,fitem);
            }
        }
        return feedList;
    }
    
    public static List<OpportunityWrapper> getWrappedOppData(Map<Id,Opportunity> oppList,Map<Id,List<Task>> taskList,Map<Id,List<FeedItem>> feedList){
        List<OpportunityWrapper> wrappedOpportunities = new List<OpportunityWrapper>();
        for (Id oppId : oppList.keySet()) {
            
            Opportunity opp = oppList.get(oppId);
            List<Task> tList = taskList.get(oppId);
            List<FeedItem> fList = feedList.get(oppId);
                OpportunityWrapper wrappedOpp = new OpportunityWrapper();
                wrappedOpp.oppId = opp.Id;
                wrappedOpp.name = opp.Name;
                wrappedOpp.statusUpdate = opp.Core_Status_Update__c;
                wrappedOpp.riskReason = opp.Core_Risk_Reason__c;
                wrappedOpp.description = opp.Description;
                wrappedOpp.stage = opp.StageName;
                
                for (OpportunityLineItem oli : opp.OpportunityLineItems) {
                    ProductWrapper wrappedProduct = new ProductWrapper();
                    wrappedProduct.productName = oli.Product2.Name;
                    wrappedProduct.productAmount = oli.TotalPrice;
                    wrappedProduct.productQuantity = oli.Quantity;
                    
                    wrappedProduct.competitor = oli.Core_Competitor__c;
                    wrappedProduct.competitor_product = oli.Core_Competitor_Product__c;
                    wrappedProduct.other_competitor = oli.Core_OtherCompetitor_Product_Txt__c;
                    wrappedProduct.loss_cancel_details = oli.Core_Loss_Cancel_Details__c;
                    wrappedProduct.loss_cancel_reason = oli.Core_Loss_Cancel_Reason__c;
                    wrappedProduct.risk_category = oli.Core_Risk_Category__c;
                    wrappedProduct.risk_details = oli.Core_Risk_Detail__c;
                  
                    
                    wrappedOpp.products.add(wrappedProduct);
                }
                for (Core_Opportunity_Partner__c partner : opp.Opportunity_Partners__r) {
                    PartnerWrapper wrappedPartner = new PartnerWrapper();
                    wrappedPartner.partnerId = partner.Id;
                    wrappedPartner.partnerAccountName = partner.Core_UCD_Partner_Account_Name__c;
                    wrappedPartner.partnerRole = partner.Core_Partner_Role__c;
                    wrappedPartner.partnerType = partner.Core_Partner_Type__c;
                    
                    wrappedOpp.partners.add(wrappedPartner);
                }
            if(tList !=null && tList.size() >0){
                for (Task t : tList) {
                    TaskList wrappedTasks = new TaskList();
                    wrappedTasks.taskId = t.Id;
                    wrappedTasks.Subject = t.Subject;
                    wrappedTasks.Description = t.Description;
                    //wrappedTasks.CreatedDate = t.CreatedDate;
                    
                    wrappedOpp.tasks.add(wrappedTasks);
                }
            }
            
            if(fList!=null && fList.size()>0){
                for (FeedItem f : fList) {
                    ChatterFeed wrappedChatterFeed = new ChatterFeed();
                    wrappedChatterFeed.feedId = f.Id;
                    wrappedChatterFeed.Body = f.Body;
                    wrappedChatterFeed.CreatedByName = f.CreatedBy.Name;
                    
                    wrappedOpp.chatter.add(wrappedChatterFeed);
                }
            }
                wrappedOpportunities.add(wrappedOpp);
        }
        return wrappedOpportunities;
    }
    
    public static List<OpportunityWrapper> getSparseOpportunity(String sellerName,String accountId){
        Map<Id,Opportunity> oppList = new Map<Id,Opportunity>();
        Map<Id,List<Task>> taskList = new Map<Id,List<Task>>();
        Map<Id,List<FeedItem>> feedList = new Map<Id,List<FeedItem>>();
        List<OpportunityWrapper> wrappedOpportunities = new List<OpportunityWrapper>();
        
        oppList = getOpportunityData(sellerName,accountId,'getStagnentOpp');
        taskList = getTasks(oppList);
        feedList = getChatterFeeds(oppList);
        
        wrappedOpportunities = getWrappedOppData(oppList,taskList,feedList);
        return wrappedOpportunities;
    }
    
    public static List<OpportunityWrapper> getOpportunityInfo(String sellerName,String accountId){
        Map<Id,Opportunity> oppList = new Map<Id,Opportunity>();
        Map<Id,List<Task>> taskList = new Map<Id,List<Task>>();
        Map<Id,List<FeedItem>> feedList = new Map<Id,List<FeedItem>>();
        List<OpportunityWrapper> wrappedOpportunities = new List<OpportunityWrapper>();
        
        oppList = getOpportunityData(sellerName,accountId,'getOppInfo');
        taskList = getTasks(oppList);
        feedList = getChatterFeeds(oppList);
        wrappedOpportunities = getWrappedOppData(oppList,taskList,feedList);
        //wrappedOpportunities = getOpportunityData(accountId);
        return wrappedOpportunities;
    }
    
    public static List<OpportunityWrapper> getOpenOpportunity(String sellerName,String accountId){
        Map<Id,Opportunity> oppList = new Map<Id,Opportunity>();
        Map<Id,List<Task>> taskList = new Map<Id,List<Task>>();
        Map<Id,List<FeedItem>> feedList = new Map<Id,List<FeedItem>>();
        List<OpportunityWrapper> wrappedOpportunities = new List<OpportunityWrapper>();
        
        oppList = getOpportunityData(sellerName,accountId,'getOpenOpp');
        taskList = getTasks(oppList);
        feedList = getChatterFeeds(oppList);
        wrappedOpportunities = getWrappedOppData(oppList,taskList,feedList);
        return wrappedOpportunities;
    }
    
    public static List<OpportunityWrapper> getAllOpportunityInfo(String sellerName,String accountId){
        Map<Id,Opportunity> oppList = new Map<Id,Opportunity>();
        Map<Id,List<Task>> taskList = new Map<Id,List<Task>>();
        Map<Id,List<FeedItem>> feedList = new Map<Id,List<FeedItem>>();
        List<OpportunityWrapper> wrappedOpportunities = new List<OpportunityWrapper>();
        
        oppList = getOpportunityData(sellerName,accountId,'getAllInfo');
        taskList = getTasks(oppList);
        feedList = getChatterFeeds(oppList);
        wrappedOpportunities = getWrappedOppData(oppList,taskList,feedList);
        return wrappedOpportunities;
    }
    
    
    public static List<OpportunityWrapper> getOpportunity(id oppID) {
        List<String> Core_Opportunity_Type = new List<String>();
        Core_Opportunity_Type.add('Deal: Sell-to');
        List<Opportunity> opportunities = [
            SELECT Id, CloseDate, Name, Description, StageName, Type, Amount, 
            Decision_Date__c,Core_Product_Segment__c,NextStep, Core_Status_Update__c, Account.Name,
            (SELECT Quantity, UnitPrice, TotalPrice,Core_BU_Short_Name__c , Product2.Name, Product2.Id ,Core_BU_Mapping_record__c,Core_BU_Mapping_record__r.Core_BU_Segment__c
             FROM OpportunityLineItems 
             WHERE  Core_Status__c NOT IN ('Delete In Progress (<15 min)','Cancelled','Lost')),
            (SELECT Id, Core_UCD_Partner_Account_Name__c, Core_Partner_Role__c, Core_Partner_Type__c 
             FROM Opportunity_Partners__r)
            FROM Opportunity WHERE Id =: oppID 
        ];//and ID NOT IN : OppId limit 5
        integer TotSpareCount = 0;
        List<OpportunityWrapper> wrappedOpportunities = new List<OpportunityWrapper>();
        for (Opportunity opp : opportunities) {
            string checkDis_St_Nt = (opp.NextStep != null ? opp.NextStep : '') +
                (opp.Core_Status_Update__c != null ? opp.Core_Status_Update__c : '') +
                (opp.Description != null ? opp.Description : '');
            //if(checkDis_St_Nt.length() > 160){
                OpportunityWrapper wrappedOpp = new OpportunityWrapper();
                wrappedOpp.oppId = opp.Id;
                wrappedOpp.closedDate = opp.CloseDate;
                wrappedOpp.name = opp.Name;
                wrappedOpp.statusUpdate = opp.Core_Status_Update__c;
                wrappedOpp.description = opp.Description;
                wrappedOpp.stage = opp.StageName;
                wrappedOpp.type = opp.Type;
                wrappedOpp.amount = opp.Amount;
                
                for (OpportunityLineItem oli : opp.OpportunityLineItems) {
                    ProductWrapper wrappedProduct = new ProductWrapper();
                    wrappedProduct.productName = oli.Product2.Name;
                    wrappedProduct.productAmount = oli.TotalPrice;
                    wrappedProduct.productQuantity = oli.Quantity;
                    if(oli.Core_BU_Mapping_record__c != null){
                        wrappedProduct.Core_Product_Segment = oli.Core_BU_Mapping_record__r.Core_BU_Segment__c != null ? determineProSeg(oli.Core_BU_Mapping_record__r.Core_BU_Segment__c): determineProSeg(opp.Core_Product_Segment__c);
                    }
                    else 
                        wrappedProduct.Core_Product_Segment = determineProSeg(oli.Product2.Name);
                    
                    wrappedOpp.products.add(wrappedProduct);
                }
                for (Core_Opportunity_Partner__c partner : opp.Opportunity_Partners__r) {
                    PartnerWrapper wrappedPartner = new PartnerWrapper();
                    wrappedPartner.partnerId = partner.Id;
                    wrappedPartner.partnerAccountName = partner.Core_UCD_Partner_Account_Name__c;
                    wrappedPartner.partnerRole = partner.Core_Partner_Role__c;
                    wrappedPartner.partnerType = partner.Core_Partner_Type__c;
                    
                    wrappedOpp.partners.add(wrappedPartner);
                }
                wrappedOpportunities.add(wrappedOpp);
            //}
            //else
              //  TotSpareCount += 1;
        }
        //String wrappedOpp = JSON.serializePretty(wrappedOpportunities);
        return wrappedOpportunities;
    }
    
    
    private static String determineProSeg(String productName) {  
        //string productName = productNameToSg;
        if (productName.contains('Emerald Rapids') || productName.contains('DCAI') || productName.contains('Gaudi2')
            || productName.contains('Granite Rapids AP 2S') || productName.contains('Public Cloud with 4th Gen Intel® Xeon®') 
            || productName.contains('Public Cloud with Intel® Xeon®') || productName.contains('Sapphire Rapids SP CPU')
            || productName.contains('Sierra Forest SP 1S')  || productName.contains('data') 
            || productName.contains('DCAI') ) {
                return 'DCAI';
            } 
        else if (productName.contains('Granulate™') || productName.contains('Intel® Developer Cloud') ||
                 productName.contains('One Edge') || productName.contains('Project Amber') ) {
                     return 'Software';
                 }
        else if (productName.contains('Intel vPro® Platform') || productName.contains('Intel® Active Management Technology (Intel® AMT)')
                 || productName.contains('CCG') || productName.contains('client')) {
                     return 'CCG';
                 }
        else if (productName.contains('NEX') || productName.contains('embedded')
                 || productName.contains('networking')) {
                     return 'NEX';
                 }
        return null; // Default case if none of the conditions match
    }
   
    
}