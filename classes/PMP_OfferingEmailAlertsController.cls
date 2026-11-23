/****************************************************************************************************************************************
* Class Name  : PMP_OfferingEmailAlertsController 
* Version     : 1.0 
* Created Date: 07-12-2019
* Modification Log :
*
* Developer                           Date                          Description
* -------------------------------------------------------------------------------------------------------------------------------------------
* ONYX Team - Prakash                 07-12-2019                    Created for displaying email content for all POE related emails
**********************************************************************************************************************************************/
public with sharing class PMP_OfferingEmailAlertsController {
    
    public PMP_OfferingEmailAlertsController() {}
    
    public String communityURL;
    public String getCommunityURL() {
     
        Network myNetwork = [SELECT Id FROM Network WHERE Name = :PMP_Utility.getValue('Marketplace_Community_Name') ];
        communityURL = Network.getLoginUrl(myNetwork.Id);
        
        system.debug('communityURL:->' +communityURL);
        
         //remove the word login from the communiyt URL and append with offering 
        communityURL = communityURL.substringBeforeLast('/') ;
        
        //Sandhya : we need to check if SFDC outofthe box method will return "/s" at the end         
        if(!communityURL.endsWith('/s')){
            communityURL = communityURL + '/s';
        }    
       
            communityURL  = communityURL + PMP_Utility.getValue('View_Offering_URL');
        
        return communityURL;
    }   
    
    public String createOfferingURL;
    public String getCreateOfferingURL() {
      
        Network myNetwork = [SELECT Id FROM Network WHERE Name = :PMP_Utility.getValue('Marketplace_Community_Name') ];
        createOfferingURL = Network.getLoginUrl(myNetwork.Id);
              
        createOfferingURL = createOfferingURL.substringBeforeLast('/');
        //Sandhya : we need to check if SFDC outofthe box method will return "/s" at the end         
        if(!createOfferingURL.endsWith('/s')){
            createOfferingURL = createOfferingURL + '/s';
        }  
        createOfferingURL = createOfferingURL + PMP_Utility.getValue('Create_Offering_URL');
        return createOfferingURL ;
    }
    
    //Logic to access image from documents folder 
    public String headerURL;  
    public String getHeaderURL(){
       
            String domainName;
            String orgId;
            Document document;
            
            document = [select Id from Document where Name='IntelLogo' LIMIT 1];
            domainName = String.valueOf(URL.getSalesforceBaseUrl().toExternalForm());
            orgId = UserInfo.getOrganizationId();
            headerURL = domainName + '/servlet/servlet.ImageServer?id=' + document.Id + '&oid=' + orgId;
       
        
        return headerURL;
    }
    
    public String bodyURL;
    public String getBodyURL(){
        
        /*bodyURL ='https://intel--c.na74.content.force.com/servlet/servlet.ImageServer?id=';
        Document document = [select Id from Document where Name='Marketplace Offering Submitted'];
        String orgId = UserInfo.getOrganizationId();
        bodyURL =bodyURL+document.Id+'&oid='+orgId;
        system.debug('###bodyURL:->'+bodyURL);*/
        bodyURL = '';
        return bodyURL;
        
    }
    
    public Id offeringId {get;set;}
    public String headerMessage {get;set;}
    public PMP_Partner_Offering__c offeringData;
    private List<PMP_Partner_Offering__c> offeringDataToBeDisplayed = new List<PMP_Partner_Offering__c>();
    
    //Method To fetch offering data to be displayed in email Template
    public PMP_Partner_Offering__c getOfferingData() {
        try{
        offeringDataToBeDisplayed = [SELECT Id,Name,PMP_Category_nm__c,PMP_Partner_Offering_Nm__c,
                                            PMP_Sub_Category_nm__c,
                                            LastModifiedBy.Name,
                                            Owner.Name,CreatedDate,LastModifiedById,
                                            PMP_Partner_Offering_Start_Dt__c,
                                            PMP_Company_Id__c,PMP_Company_Id__r.Name,
                                            PMP_Field_Application_Engineer_Id__c,PMP_Intel_Admin_Nm__c
                                            FROM PMP_Partner_Offering__c 
                                            WHERE Id =:offeringId LIMIT 1];
        if(!offeringDataToBeDisplayed.isEmpty()){
            offeringData = offeringDataToBeDisplayed[0];
            companyName = offeringData.PMP_Company_Id__r.Name;
        }else {
            offeringData = new PMP_Partner_Offering__c();
        }
        }catch(Exception e){
           offeringData = new PMP_Partner_Offering__c(); 
        }
        return offeringData;                                        
    }
    
    public String companyName {get;set;}
}