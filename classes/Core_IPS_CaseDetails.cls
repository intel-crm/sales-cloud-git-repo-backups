@RestResource(urlMapping='/v2.0/Cases/*')
global with sharing class Core_IPS_CaseDetails {
    @HttpGet
    global static CaseWrapperCount get_Case(){   
        List<Case> newCount=[SELECT id FROM Case WHERE status='new']; 
        List<Case> openCount=[SELECT id FROM Case WHERE status='open'];
        Integer newCountSize = newCount.size();
        Integer openCountSize = openCount.size();
        Integer openNewCount = newCountSize + openCountSize ; 
        List<CaseWrapper> wlist = new List<CaseWrapper>();
        // Niyaz for(Case cas:[SELECT id,Contact.id,Account.id,Description,Product.id,CaseNumber,Status,CreatedDate,Core_IPS_Last_Update__c FROM Case LIMIT 100]){
        // AFTER — scoped to portal-visible cases for the calling user
        //Niyaz -- 12/06/2025 --- added as part of vulnerability fix.
        for(Case cas:[SELECT id,Contact.id,Account.id,Description,Product.id,
                      CaseNumber,Status,CreatedDate,Core_IPS_Last_Update__c 
                      FROM Case 
                      WHERE Core_IPS_Customer_Visible__c = true
                      LIMIT 100]){
                          CaseWrapper casWrap=new CaseWrapper();
                          casWrap.ContactId = cas.Contact.id;
                          casWrap.AccountId = cas.Account.id;
                          casWrap.description=cas.Description; 
                          casWrap.product=cas.Product.id;
                          casWrap.requestNumber = cas.CaseNumber; 
                          casWrap.status=cas.Status;
                          casWrap.dateCreated=cas.CreatedDate;
                          casWrap.lastUpdated=cas.Core_IPS_Last_Update__c; 
                          wlist.add(casWrap); 
                      }  
        CaseWrapperCount casWrapCount=new CaseWrapperCount();
        casWrapCount.caseList=wlist;
        casWrapCount.countNew=newCountSize;
        casWrapCount.countOpen=openCountSize; 
        casWrapCount.countOpenNew=openNewCount;
        return casWrapCount ;
    }
    
    global class CaseWrapper{
        public Id ContactId {set;get;}
        public Id AccountId {set;get;}
        public String description {set;get;}
        public Id product {set;get;}
        public String requestNumber {set;get;}
        public String status {set;get;}
        public DateTime dateCreated {set;get;}
        public Decimal lastUpdated {set;get;} 
    }
    
    global class CaseWrapperCount{
        public List<CaseWrapper> caseList{set;get;}
        public Integer countNew {set;get;}
        public Integer countOpen {set;get;}
        public Integer countOpenNew {set;get;}
    }
}