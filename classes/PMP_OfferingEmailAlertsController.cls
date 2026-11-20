@isTest
/****************************************************************************************************************************************
* Class Name  : PMP_OfferingEmailAlertsController 
* Version     : 1.0 
* Created Date: 07-12-2019
* Modification Log :
*
* Developer                           Date                          Description
* -------------------------------------------------------------------------------------------------------------------------------------------
* ONYX Team - Prakash                 07-12-2019                    Created for displaying email content for all POE related emails

  ONYX Team - Yashasvi Agg            12-10-2021
**********************************************************************************************************************************************/
public without sharing class PMP_OfferingEmailAlertsController {
    
//     public PMP_OfferingEmailAlertsController() {}
    
//     public String communityURL;
//     public String getCommunityURL() {
        
//         Network myNetwork;
        
        
//         myNetwork = [SELECT Id FROM Network WHERE Name = :PMP_Utility.getValue('Marketplace_Community_Name') ];
        
        
//         if(myNetwork!=Null){
//             communityURL = Network.getLoginUrl(myNetwork.Id);
//             //remove the word login from the communiyt URL and append with offering 
//             communityURL = communityURL.substringBeforeLast('/') ;
//         }
//         //Sandhya : we need to check if SFDC outofthe box method will return "/s" at the end         
//         if(!communityURL.endsWith('/s')){
//             communityURL = communityURL + '/s';
//         }    
        
//         communityURL  = communityURL + PMP_Utility.getValue('View_Offering_URL');
        
//         return communityURL;
//     }   
    
//     public String manageOfferingsURL;
//     public String getManageOfferingsURL() {
        
//         Network myNetwork;
        
        
//         myNetwork = [SELECT Id FROM Network WHERE Name = :PMP_Utility.getValue('Marketplace_Community_Name') ];
        
        
//         if(myNetwork!=Null){
//             manageOfferingsURL = Network.getLoginUrl(myNetwork.Id);
//             //remove the word login from the communiyt URL and append with offering 
//             manageOfferingsURL = manageOfferingsURL.substringBeforeLast('/') ;
//         }
                 
//         if(!manageOfferingsURL.endsWith('/s')){
//             manageOfferingsURL = manageOfferingsURL + '/s';
//         }    
        
//         manageOfferingsURL = manageOfferingsURL + '/pmp-partner-offering/PMP_Partner_Offering__c';
        
//         return manageOfferingsURL;
//     }   
    
//     public String createOfferingURL;
//     public String getCreateOfferingURL() {
        
//         Network myNetwork;
        
        
//         myNetwork = [SELECT Id FROM Network WHERE Name = :PMP_Utility.getValue('Marketplace_Community_Name') ];
        
        
//         if(myNetwork!=Null){
//             createOfferingURL = Network.getLoginUrl(myNetwork.Id);
            
//             createOfferingURL = createOfferingURL.substringBeforeLast('/');
//         }    
//         //Sandhya : we need to check if SFDC outofthe box method will return "/s" at the end         
//         if(!createOfferingURL.endsWith('/s')){
//             createOfferingURL = createOfferingURL + '/s';
//         }  
//         createOfferingURL = createOfferingURL + PMP_Utility.getValue('Create_Offering_URL');
//         return createOfferingURL ;
//     }
    
//     //Logic to access image from documents folder 
//     public String headerURL;  
//     public String getHeaderURL(){
        
//         String domainName;
//         String orgId;
//         Document document;
        
        
//         document = [select Id from Document where Name='IntelLogo' LIMIT 1];
        
        
//         //domainName = String.valueOf(URL.getSalesforceBaseUrl().toExternalForm());
//         //below line added as part of the logo issue in email template - by priyanka 
//         domainName=String.valueOf(System.Url.getOrgDomainUrl().toExternalForm());
//         //System.debug('....domainName.....'+domainName);
//         orgId = UserInfo.getOrganizationId();
        
//         if(document!=Null){
//             headerURL =domainName+'/servlet/servlet.ImageServer?id=' + document.Id + '&oid=' + orgId;
            
            
//         }
        
//         return headerURL;
//     }
    
//     public String bodyURL;
//     public String getBodyURL(){
        
//         /*bodyURL ='https://intel--c.na74.content.force.com/servlet/servlet.ImageServer?id=';
// Document document = [select Id from Document where Name='Marketplace Offering Submitted'];
// String orgId = UserInfo.getOrganizationId();
// bodyURL =bodyURL+document.Id+'&oid='+orgId;
// system.debug('###bodyURL:->'+bodyURL);*/
//         bodyURL = '';
//         return bodyURL;
        
//     }
    
//     public Id offeringId {get;set;}
//     public String publishedOfferingId {get;set;}
//     public String lang {get;set;} 
//     public List<PMP_Partner_Offering_Message__c> offMessageList {get;set;}  
//     public List<PMP_Partner_Offering_Message__c> offAllMessageList {get;set;}  
//     public List<PMP_Partner_Offering_Message__c> offAllUpdateRequiredMessageList {get;set;}  
//     public String offeringEndDate {get;set;}
//     public String offeringStartDate {get;set;}
//     public String headerMessage {get;set;}
//    public PMP_Partner_Offering__c offeringData;
//     private List<PMP_Partner_Offering__c> offeringDataToBeDisplayed = new List<PMP_Partner_Offering__c>();
    
//     //Method To fetch offering data to be displayed in email Template
//     public PMP_Partner_Offering__c getOfferingData() {
//         try {
//             offeringDataToBeDisplayed = [SELECT Id, Name, PMP_Category_nm__c, PMP_Partner_Offering_Nm__c,
//                                         PMP_Sub_Category_nm__c, LastModifiedBy.Name, Owner.Name,
//                                         CreatedDate, LastModifiedById, PMP_Partner_Offering_Start_Dt__c,
//                                         PMP_Partner_Offering_End_Dt__c, PMP_Company_Id__c, 
//                                         PMP_Company_Id__r.Name, PMP_Field_Application_Engineer_Id__c,
//                                         PMP_Intel_Admin_Nm__c, PMP_Offering_Submitter_UserId__c,
//                                         PMP_Offering_Submitter_UserId__r.IsActive, PMP_Published_Copy_Id_Txt__c
//                                         FROM PMP_Partner_Offering__c 
//                                         WHERE Id = :offeringId LIMIT 1];
//             if (!offeringDataToBeDisplayed.isEmpty()) {
//                 offeringEndDate = String.valueOf(Date.valueOf(offeringDataToBeDisplayed[0].PMP_Partner_Offering_End_Dt__c)); 
//                 Date startDate = (Date) offeringDataToBeDisplayed[0].PMP_Partner_Offering_Start_Dt__c;
//                 offeringStartDate = DateTime.newInstance(startDate.year(), startDate.month(), startDate.day())
//                                         .format('MMMM d, yyyy');
//               List<PMP_Partner_Offering__c> publishedOfferingData = [SELECT Id FROM PMP_Partner_Offering__c WHERE PMP_Working_Copy_Id__c = :offeringId LIMIT 1]; 
 //                offMessageList = new List<PMP_Partner_Offering_Message__c>();
 //                offAllMessageList = [SELECT Id, PMP_Message_Txt__c, PMP_Message_Type__c, CreatedDate, CreatedBy.Profile.Name 
   //                                  FROM PMP_Partner_Offering_Message__c 
//                                     WHERE PMP_Partner_Offering_Id__c = :offeringId 
//                                     ORDER BY CreatedDate DESC];
//                 processUpdateRequiredMessages();
//                 offeringData = offeringDataToBeDisplayed[0];
//                 companyName = offeringData.PMP_Company_Id__r.Name;
//                 lang = '?Lang=NA';
//                 if (!publishedOfferingData.isEmpty()) {
//                     publishedOfferingId = publishedOfferingData[0].Id + '?Lang=NA';
//                 }
//             } else {
//                 offeringData = new PMP_Partner_Offering__c();
//             }
//         } catch(Exception e) {
//             offeringData = new PMP_Partner_Offering__c(); 
//         }
//         return offeringData;
//     }
//     private void processUpdateRequiredMessages() {
//         for (PMP_Partner_Offering_Message__c allMsg : offAllMessageList) { 
//             if (allMsg.PMP_Message_Type__c != 'Status' && allMsg.CreatedBy.Profile.Name != 'Partner') {
//                 offAllUpdateRequiredMessageList.add(allMsg);
//             }
//             if (allMsg.PMP_Message_Type__c == 'Status' && allMsg.PMP_Message_Txt__c == 'Admin Review') {
//                 break;
//             }
//         }
//         if (!offAllUpdateRequiredMessageList.isEmpty()) {
//             for (Integer i = offAllUpdateRequiredMessageList.size() - 1; i >= 0; i--) {
//                 offMessageList.add(offAllUpdateRequiredMessageList[i]);
//             }
//         }
//     }

    
//     public String retiredOfferingURL;
//     public String getretiredOfferingURL() {
       
//         Network myNetwork;
       
//        
//         myNetwork = [SELECT Id FROM Network WHERE Name = :PMP_Utility.getValue('Marketplace_Community_Name') ];
        
        
//         if(myNetwork!=Null){
//             retiredOfferingURL = Network.getLoginUrl(myNetwork.Id);
            
//             retiredOfferingURL = retiredOfferingURL.substringBeforeLast('/');
//         }    
                
//        if(!retiredOfferingURL.endsWith('/s')){
//             retiredOfferingURL= retiredOfferingURL + '/s';
//         }  
//         retiredOfferingURL = retiredOfferingURL + '/offering/' + offeringId + '?viewChat=true&Lang=NA';
//         return retiredOfferingURL;
//     }
   
//     public String companyName {get;set;}
}