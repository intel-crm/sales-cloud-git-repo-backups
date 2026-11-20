public without sharing class Core_OppEmailAlertController {
    public Id oppId {get;set;}   
    private List<Opportunity> oppDataToBeDisplayed = new List<Opportunity>();
    private List<OpportunityLineItem> oppProdDataToBeDisplayed = new List<OpportunityLineItem>();
    public Opportunity oppData; 
    public List<OpportunityLineItem> oppProdData; 
    public String headerURL;
    public String rejectionComment;    
    
    public String getHeaderURL(){
        String domainName;
        String orgId;
        
        Document document;            
        document = [select Id from Document where Name=:Label.Pricing_IQR_Intel_Logo LIMIT 1];
        domainName = String.valueOf(System.Url.getOrgDomainUrl());
        domainName = domainName.split('=')[1].split(']')[0];
        orgId = UserInfo.getOrganizationId();
        headerURL = domainName + '/servlet/servlet.ImageServer?id=' + document.Id + '&oid=' + orgId;
        return headerURL;
    }
    
    public String getDomainName(){
        String domainName;
        domainName =  String.valueOf(System.Url.getOrgDomainUrl());
        domainName = domainName.split('=')[1].split(']')[0];
        return domainName;
    }
    
    public String getDealRegExternalDomainName(){
        String dealRegExternalDomainName;          
        Network site = [Select id from Network where Name =: Label.Pricing_DealReg_Community_Name];
        dealRegExternalDomainName = Network.getLoginUrl(site.Id);
        dealRegExternalDomainName = dealRegExternalDomainName.removeEnd('/login');
        return dealRegExternalDomainName;
    }
    
    public Opportunity getOppData() {
        oppDataToBeDisplayed = oppDataToBeDisplayed.isEmpty() ? new List<Opportunity>([SELECT Id,Name,CreatedDate, CloseDate, Account.Name,Core_Technical_Owner__r.Contact.Account.Name,
                                                                                       Core_External_ID__c,Core_Technical_Owner__r.Name,Owner.Name 
                                                                                       FROM Opportunity 
                                                           WHERE Id =:oppId LIMIT 1]) : oppDataToBeDisplayed;
        
        if(!oppDataToBeDisplayed.isEmpty()){
            oppData = oppDataToBeDisplayed[0];
        }else {
            oppData = new Opportunity();
        }
        return oppData;
    }
    
    public String getRejectionComment(){
        // Query to retrieve the rejection comment for a specific record
        List<ProcessInstanceStep> steps = [SELECT StepStatus, Comments FROM ProcessInstanceStep 
                                           WHERE ProcessInstance.TargetObjectId = :oppId 
                                           AND StepStatus = 'Rejected' ORDER BY CreatedDate DESC LIMIT 1];
        if (!steps.isEmpty()) {
            rejectionComment = String.valueOf(steps[0].Comments);
        }
        return rejectionComment;
    }
    
    public List<OpportunityLineItem> getOppProdData() {
        oppProdDataToBeDisplayed = oppProdDataToBeDisplayed.isEmpty() ? new List<OpportunityLineItem>([SELECT Id,Name,Quantity,Core_Status__c  FROM OpportunityLineItem where OpportunityId =:oppId AND Core_Status__c = 'Pending']) : oppProdDataToBeDisplayed;
        if(!oppProdDataToBeDisplayed.isEmpty()){
            oppProdData = oppProdDataToBeDisplayed;
        }else {
            oppProdData = new List<OpportunityLineItem>();
        }
        return oppProdData;
    }
}