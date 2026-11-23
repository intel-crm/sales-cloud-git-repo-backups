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
    public List<PMP_Company__c> partnerDataToBeDisplayed = new List<PMP_Company__c>();
    public PMP_EmailTemplateController(){}
    /*public String getCommunityURL()
    {
        communityURL = 'https://crmqa2-intelcloudcrm.cs93.force.com//imp/s/partner/';
        return communityURL ;
    }*/
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
    public PMP_Company__c getPartnerData() 
    {
            
            partnerDataToBeDisplayed = [select Id,Name,PMP_Published_Copy_Id__c from PMP_Company__c WHERE Id =:partnerId LIMIT 1];
            System.debug('getPartnerData'+partnerDataToBeDisplayed);
           
            if(!partnerDataToBeDisplayed.isEmpty())
            {
                partnerData = partnerDataToBeDisplayed[0];
                
            }
            else 
            {
                partnerData = new PMP_Company__c();
            } 
           
        
        /*partnerData = new PMP_Company__c();
        if(String.isNotEmpty(partnerId)){
            partnerDataToBeDisplayed = [select Id,Name,PMP_Published_Copy_Id__c from PMP_Company__c WHERE Id =:partnerId LIMIT 1];
            if(!partnerDataToBeDisplayed.isEmpty()){
                partnerData = partnerDataToBeDisplayed[0];
                
            }
        }*/
   
        return partnerData;  
       
    }
    /*public UserDetails fetchUser(){      
        UserDetails user=new UserDetails();
        User user1 = new User();
        Contact con = new Contact();
        Account acc = new Account();
        if(Schema.sObjectType.User.isAccessible()){
        user1 = [Select id,ContactId from User where id=: userInfo.getUserId()];
        }
         System.debug( '---------------------');
        
                     System.debug( 'user1.ContactId---------------------'+user1  +'------'+user1.ContactId );
        //System.debug( '---------------------'+System.currentPageReference().getHeaders().get('Referer')  );
        //user1 = [Select id,ContactId from User where id='0050n000002JCLd'];
        if(user1!=null && (!String.isBlank(user1.ContactId))) {
            if(Schema.sObjectType.Contact.isAccessible()){
            con = [select id,AccountId, FirstName, LastName, Email,Phone,Title,Core_Job_Function__c,MailingCountry,MailingState  from Contact where id=: user1.ContactId]; 
            system.debug('contact Info'+con);
                
            }if(con!=null && (!String.isBlank(con.AccountId))){
                if(Schema.sObjectType.Account.isAccessible()){
                acc= [select id,Name,Core_Account_State_Province__c,Core_Account_Country__c from Account where id=: con.AccountId];
                }
            }
        }
        
        user.firstName = con.FirstName;
        user.lastName = con.LastName;
        user.jobTitle = con.Core_Job_Function__c ;
        user.companyName = acc.Name;
       // user.country = acc.Core_Account_Country__c;
       // user.state = acc.Core_Account_State_Province__c;
        user.country = con.MailingCountry;
        user.state = con.MailingState;
        user.phone = con.Phone;
        user.email = con.Email;
        user.preferredContact = PMP_StaticConstants_Partner.PreferredContact_CTA;
        system.debug('user'+user);
        return user;
    }*/
}