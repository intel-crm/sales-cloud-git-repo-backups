/**
* @description       : This Apex class controller manages the retrieval of values and variables for generating various email notifications in Salesforce.
* @author            : Prasad
* @group             : Software & Services
* @last modified on  : 08-19-2024
* @last modified by  : Prasad
**/
public without sharing class Pricing_SW_QuoteEmailAlertController {    
    public Id quoteId{get;set;}
    public Id quoteApprovalId{get;set;}
    private SBQQ__Quote__c quoteData;
    private sbaa__Approval__c approvalData;

    private String headerURL;
    private String headerDomain;
    
    
    public String getHeaderURL(){
        String domainName;
        String orgId;
        
        Document document;            
        document = [select Id from Document where Name=:Label.Pricing_SW_Intel_Logo LIMIT 1];
        domainName = String.valueOf(System.Url.getOrgDomainUrl());
        //domainName = domainName.split('=')[1].split(']')[0];
        domainName = domainName.substring(domainName.indexOf('https://') + 'https://'.length());        
        orgId = UserInfo.getOrganizationId();
        headerURL = 'https://' + domainName + '/servlet/servlet.ImageServer?id=' + document.Id + '&oid=' + orgId;
        return headerURL;
    }
        
    //Method To fetch Quote data to be displayed in email Template SBQQ__NetAmount__c, SBQQ__TotalCustomerDiscountAmount__c 
    public SBQQ__Quote__c getQuoteData() {
        List<SBQQ__Quote__c> quoteDataToBeDisplayed;
        quoteDataToBeDisplayed = new List<SBQQ__Quote__c>([SELECT Id,Name,Owner.Name,LastModifiedBy.Name,Pricing_Account_Executive_Nm__c,SBQQ__PrimaryContact__r.Name,SBQQ__PrimaryContact__c,
                                                           Pricing_Intel_Account_Exec_Email_Txt__c,Pricing_Customer_Nm__c,Pricing_End_Customer_Name__c,SBQQ__Opportunity2__c,SBQQ__Opportunity2__r.Name,
                                                           Pricing_Project_Name_Nm__c,Pricing_Bid_Dt__c,Pricing_Customer_Reference_Id__c,SBQQ__Status__c, Pricing_SW_Account_Name__c, 
                                                           SBQQ__ListAmount__c,  SBQQ__AverageCustomerDiscount__c,  SBQQ__TotalCustomerDiscountAmount__c, SBQQ__NetAmount__c,Pricing_SW_Approval_Comments__c
                                                           FROM SBQQ__Quote__c WHERE Id =:quoteId LIMIT 1]);
        if(!quoteDataToBeDisplayed.isEmpty()){
            quoteData = quoteDataToBeDisplayed[0];
        }else {
            quoteData = new SBQQ__Quote__c();
        }
        return quoteData;                                        
    }
    
    public sbaa__Approval__c getApprovalData() {
        List<sbaa__Approval__c> quoteApprovalData;
        quoteApprovalData = new List<sbaa__Approval__c>([SELECT ID, Name FROM sbaa__Approval__c WHERE Id =:quoteApprovalId LIMIT 1]);
        if(!quoteApprovalData.isEmpty()){
            approvalData = quoteApprovalData[0];
        }else {
            approvalData = new sbaa__Approval__c();
        }
        return approvalData;
    }
    
    //Method to get the domain name
    public String getDomainName(){
        String domainName;
        domainName = URL.getOrgDomainURL().toExternalForm();
        return domainName;
    }    
}