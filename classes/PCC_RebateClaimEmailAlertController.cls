public without sharing class PCC_RebateClaimEmailAlertController { 
    public List<PCC_Rebate_Claim_Line_Item__c> rebateClaimLineData;    
    public String headerURL;
    public String rejectionComment;
    public Id rebateClaimId {get;set;} 
    public PCC_Rebate_Claim__c  rebateClaimData; 
    private List<PCC_Rebate_Claim__c> rebateDataToBeDisplayed = new List<PCC_Rebate_Claim__c >();
    private List<PCC_Rebate_Claim_Line_Item__c> rebateLineDataToBeDisplayed = new List<PCC_Rebate_Claim_Line_Item__c >();
    
    public String getHeaderURL(){
        String domainName;
        String orgId;        
        Document document; 
        try
        {
            document = [select Id from Document where Name=: Label.Pricing_IQR_Intel_Logo LIMIT 1];
            domainName = String.valueOf(System.Url.getOrgDomainUrl());
            domainName = domainName.split('=')[1].split(']')[0];
            orgId = UserInfo.getOrganizationId();
            headerURL = domainName + '/servlet/servlet.ImageServer?id=' + document.Id + '&oid=' + orgId; 
        }
        catch(Exception e)
        { }
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
    
    public PCC_Rebate_Claim__c getRebateClaimData() {   
        rebateDataToBeDisplayed = rebateDataToBeDisplayed.isEmpty() ?  new List<PCC_Rebate_Claim__c>([SELECT Id, name, PCC_Claim_Status__c, PCC_Submission_Date__c, PCC_Submitted_By__r.Name, PCC_Total_Claimed_Rebate__c, PCC_Partner__r.Name, PCC_Approved_By__c, PCC_Approved_By__r.Name, PCC_Approval_Date__c, PCC_Total_Approved_Rebate__c, PCC_Partner__r.Core_Account_Owner_Email__c,PCC_Payment_Ref_Id__c, PCC_Total_Rejected_Rebate__c FROM PCC_Rebate_Claim__c WHERE Id =:rebateClaimId LIMIT 1]) : rebateDataToBeDisplayed;
        if(!rebateDataToBeDisplayed.isEmpty()){
            rebateClaimData = rebateDataToBeDisplayed[0];
        }else {
            rebateClaimData = new PCC_Rebate_Claim__c();
        }     
        return rebateClaimData;
    }
    
    public List<PCC_Rebate_Claim_Line_Item__c>  getRebateClaimLineData() {
        
        rebateLineDataToBeDisplayed = rebateLineDataToBeDisplayed.isEmpty() ?  new List<PCC_Rebate_Claim_Line_Item__c>([SELECT Id,   
                                                                                                                        PCC_Quantity__c, PCC_Invoice__c, PCC_Invoice_Date__c ,PCC_Opportunity__r.name, PCC_Quote_Line_Number__r.name, PCC_Product__r.name
                                                                                                                        from PCC_Rebate_Claim_Line_Item__c  WHERE PCC_Rebate_Claim__c  = :rebateClaimId ]): rebateLineDataToBeDisplayed ;        
        if (!rebateLineDataToBeDisplayed.isEmpty() &&  rebateLineDataToBeDisplayed.size()>0){          
            rebateClaimLineData  = rebateLineDataToBeDisplayed;
        }
        else{           
            rebateClaimLineData  = new List<PCC_Rebate_Claim_Line_Item__c>();
        }
        return rebateClaimLineData;
    }
}