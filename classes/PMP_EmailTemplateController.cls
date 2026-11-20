/*******************************************************************************************************************************************************************************************************
* Class Name  : PMP_EmailTemplateController
* Description : Contains the methods that are used for Partner Email Templates
* Version     : 1.0 
* Created Date: 07-Jun-2019
* Modification Log :
* Created By  : Tanzanite Team (Infosys)
********************************************************************************************************************************************************************************************************/
public with sharing class PMP_EmailTemplateController extends PMP_SearchWrapperStore { 
    
    
    //public String communityURL;
    //public String outputLinkURL;
    public Id partnerId {get;set;}
    public String headerMessage {get;set;}
    public PMP_Company__c partnerData;
    public String communityURL; //variable to hold the community URL
    public List<PMP_Company__c> partnerDataToBeDisplayed = new List<PMP_Company__c>();
    public PMP_EmailTemplateController(){}

    /***commented since we are using custom labels ***/
    /* public  String getCommunityURL() {
Network myNetwork = [SELECT Id FROM Network WHERE Name = :PMP_Utility.getValue('Marketplace_Community_Name') ];
communityURL = Network.getLoginUrl(myNetwork.Id);
communityURL = communityURL.substringBeforeLast('/') + '/partner/'; //remove the word login from the communiyt URL and append with offering 
return communityURL ;
}
public  String getcreateOfferingURL() {
Network myNetwork = [SELECT Id FROM Network WHERE Name = :PMP_Utility.getValue('Marketplace_Community_Name') ];
outputLinkURL = Network.getLoginUrl(myNetwork.Id);
outputLinkURL = outputLinkURL.substringBeforeLast('/') + '/pmp-partner-offering/PMP_Partner_Offering__c/Recent';
return outputLinkURL ;
}*/
    //returns the community URL
    public String getCommunityURL(){
        String communityURL;
        Network myNetwork;
        myNetwork = [SELECT Id FROM Network WHERE Name = :PMP_Utility.getValue('Marketplace_Community_Name') ];
        
        if(myNetwork!=Null){
            communityURL = Network.getLoginUrl(myNetwork.Id);
            //remove the word login from the communiyt URL and append with offering 
            communityURL = communityURL.substringBeforeLast('/') ;
        }
        //we need to check if SFDC outofthe box method will return "/s" at the end         
        if(!communityURL.endsWith('/s')){
            communityURL = communityURL + '/s';
        }    
        
        return communityURL;
    }

    public PMP_Company__c getPartnerData() {
        partnerDataToBeDisplayed = [select Id,Name,PMP_Published_Copy_Id__r.Name,PMP_Published_Copy_Id__c,PMP_Partner_Submitter_UserId__c,PMP_Partner_Submitter_UserId__r.IsActive,PMP_Partner_Submitter_UserId__r.Partner_License_Reclaimed__c from PMP_Company__c WHERE Id =:partnerId  LIMIT 1];//PMP_Partner_Submitter_UserId__c,PMP_Partner_Submitter_UserId__r.IsActive is added as part of the email story US847712
        // System.debug('getPartnerData'+partnerDataToBeDisplayed);
        if(!partnerDataToBeDisplayed.isEmpty()){
            partnerData = partnerDataToBeDisplayed[0];
        }
        else{
            partnerData = new PMP_Company__c();
        } 
        return partnerData;  
        
    }
       
}