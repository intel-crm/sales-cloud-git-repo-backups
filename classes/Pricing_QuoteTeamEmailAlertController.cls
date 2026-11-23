public without sharing class Pricing_QuoteTeamEmailAlertController {
    //Logic to access image from documents folder
    public Id qtmId {get;set;}
    public String agsFilter {set;get;}
    public Pricing_Quote_Team__c qtmData;  
    public Pricing_Quote_Team_Role_Access_Mapping__mdt roleMap {set;get;}
    public String headerURL; 
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
    //Method to get the domain name
    public String getDomainName(){
        String domainName;          
       // domainName = String.valueOf(URL.getSalesforceBaseUrl().toExternalForm());
        domainName =  String.valueOf(System.Url.getOrgDomainUrl());
        domainName = domainName.split('=')[1].split(']')[0];
        return domainName;
    }
    
    //Method To fetch Quote data to be displayed in email Template
    public Pricing_Quote_Team__c getQtmData() {
        
        Pricing_Quote_Team__c quoteTeam = [SELECT id,Pricing_Role_Nm__c,Pricing_Quote_Team_Member_Id__r.Name,LastModifiedBy.Name,
                                            Pricing_Quote_Id__c,Pricing_Quote_Id__r.Name,Pricing_Quote_Id__r.Pricing_Customer_Nm__c,
                                            Pricing_Quote_Id__r.Pricing_Project_Name_Nm__c,Pricing_Quote_Id__r.Pricing_Bid_Dt__c,Pricing_Grant_Access_Ind__c 
                                         	FROM Pricing_Quote_Team__c WHERE Id= :qtmId LIMIT 1];                                                                              
        
        system.debug('quoteTeam==>'+quoteTeam);
        if(quoteTeam==null){
            quoteTeam = new Pricing_Quote_Team__c();
        }else {
           roleMap = [SELECT AGS_Role_Filter_Txt__c FROM Pricing_Quote_Team_Role_Access_Mapping__mdt WHERE Pricing_IsActive_Ind__c=True AND Pricing_Role_Nm__c=: quoteTeam.Pricing_Role_Nm__c LIMIT 1];
           agsFilter = roleMap?.AGS_Role_Filter_Txt__c;  
           agsFilter = String.isEmpty(agsFilter)?'IQR':agsFilter;
        }
        return quoteTeam;                                        
    }

}