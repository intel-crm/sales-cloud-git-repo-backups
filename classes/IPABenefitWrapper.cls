/*********************************************************************************************************************
Apex Class Name  : IPABenefitUtilityWrapper
Version       : 1.0
Created Date  : June 2020
Function      : Utility class containing structure to stored data of Partner Benefits

Modification Log :
* Developer                 Date                    Description
* --------------------------------------------------------------------------------------------------------------------
* Anish/Grishma/Jasmine               June 2020              Utility class containing structure to stored data of Partner Benefits

*********************************************************************************************************************/
public class IPABenefitWrapper {
    //return data for user profile in structure format
    public class UserProfile{
        @AuraEnabled public string userId{get; set;}
        @AuraEnabled public string contactId{get; set;}
        @AuraEnabled public string onePartnerId{get; set;}
        @AuraEnabled public string companyProfileId{get; set;}
        @AuraEnabled public string  marqueeTitle{get; set;}
        @AuraEnabled public companyProfile companyProfileLink {get; set; }
        @AuraEnabled public dashboardProfileLink dashboardLink {get; set; }
        @AuraEnabled public mProfileLink myProfileLink {get; set; }    
        @AuraEnabled public string name{get; set;}
        @AuraEnabled public string title { get; set; } 
        @AuraEnabled public string responsibility { get; set; } 
        @AuraEnabled public string phone{get; set;}
        @AuraEnabled public string email{get; set;}
        @AuraEnabled public string faIcon{get; set;}
        @AuraEnabled public string tier{get; set;}
        @AuraEnabled public string benefitDescription{get; set;}
        @AuraEnabled public string userLanguage{get; set;}
        @AuraEnabled public string UserEmail{get; set;}
        

    }
    public class CompanyProfile {
        @AuraEnabled public string label{get; set;}
        @AuraEnabled public string externalUrl{get; set;}
        @AuraEnabled public string communityPage{get; set;}
        @AuraEnabled public string objectPage{get; set;}
        @AuraEnabled public string recordId{get; set;}    
    }
    public class DashboardProfileLink {
        @AuraEnabled public string label{get; set;}
        @AuraEnabled public string externalUrl{get; set;}
        @AuraEnabled public string communityPage{get; set;}
        @AuraEnabled public string objectPage{get; set;}
        @AuraEnabled public string recordId{get; set;}  
    }
    public class MProfileLink {
        @AuraEnabled public string label{get; set;}
        @AuraEnabled public string externalUrl{get; set;}
        @AuraEnabled public string communityPage{get; set;}
        @AuraEnabled public string objectPage{get; set;}
        @AuraEnabled public string recordId{get; set;}  
    }
    //return data in structure format for blades
    
    public class BenefitDetails {
         @AuraEnabled public string checkAgreementBnft{get; set;}
        @AuraEnabled public string summaryDescription{get; set;}
        @AuraEnabled public List<UserBenefitInfo> benefitInfo{get; set;}  
        @AuraEnabled public string isUserSubscribedAll{get;set;}
    }
    
    public class UserBenefitInfo
    {
        @AuraEnabled public Id id {get; set;}
        @AuraEnabled public String title {get; set;}
        @AuraEnabled public String faIcon {get; set;}
        @AuraEnabled public String description {get; set;} 
        @AuraEnabled public List<Alerts> alerts{get; set;} 
        @AuraEnabled public List<AdhocAlerts> adhocAlerts{get; set;}
        @AuraEnabled public List<Metrics> metrics{get; set;} 
        @AuraEnabled public List<Link> links{get; set;} 
        @AuraEnabled public Contactdata contacts{get; set;}    
       
    }
    public class Contactdata 
    {
        @AuraEnabled public List<Contact> contacts{get; set;}  
        @AuraEnabled public string label { get; set; }  
    }
    
    public class Contact{
        @AuraEnabled public string id { get; set; }
        @AuraEnabled public string name { get; set; }
        @AuraEnabled public string title{ get; set; }
        @AuraEnabled public string phone{ get; set; }
        @AuraEnabled public string email{ get; set; }
        @AuraEnabled public string faIcon{ get; set; }
        @AuraEnabled public string role{ get; set; }
        @AuraEnabled public string iconUrl{ get; set; }
    }
    
    public class Alerts 
    {
        @AuraEnabled public string label { get; set; }
    }
    
    public class AdhocAlerts 
    {
        @AuraEnabled public string uniqueId {get; set; }
        @AuraEnabled public string label { get; set; }
        @AuraEnabled public string adcDescription { get; set; }
    }
    
    public class Metrics
    {
        @AuraEnabled public string label { get; set; }
        // @AuraEnabled public List<Link> link { get; set; } 
        @AuraEnabled public Link link { get; set; }
        @AuraEnabled public string value { get; set; }
        @AuraEnabled public string unit { get; set; }
        @AuraEnabled public string description { get; set; }   
    }
    
    public class Link
    {
        @AuraEnabled public string label { get; set; }
        @AuraEnabled public string externalUrl { get; set; }
    } 
    // Structure for user notification
    public class UserNotificationInfo{
        @AuraEnabled public string title{get; set;}
        @AuraEnabled public List<message> messages{get; set;} 
        @AuraEnabled public viewLink viewAllLink{get; set;}
        
    }
    public class ViewLink{
        
        @AuraEnabled public string label{get; set;}  //'View All Messages',
        @AuraEnabled public string externalUrl{get; set;} // '#',
        @AuraEnabled public string communityPage{get; set;} 
        @AuraEnabled public string objectPage{get; set;}
        @AuraEnabled public string recordId{get; set;}
        
    }
    public class Message implements Comparable{
        @AuraEnabled public string messageId{get; set;}
        @AuraEnabled public string type{get; set;}
        @AuraEnabled public String iconType{get; set;}
        @AuraEnabled public List<Fields> fields{get; set;}
        @AuraEnabled public date msgDate{ get; set; } 
        @AuraEnabled public string subject{get; set;}
        @AuraEnabled public string body{get; set; } 
        @AuraEnabled public boolean read {get; set; }
        @AuraEnabled public  ReplyLink replyLink{ get; set; }
        
        public Integer compareTo(Object objToCompare) {
            message that = (message)objToCompare;
            if(this.msgDate == that.msgDate){
                return 0;
            } else if(this.msgDate > that.msgDate){
                return -1;
            } else {
                return 1;
            }
            
        } 
        
    }
    
   public class Fields 
    {
        @AuraEnabled public string label { get; set; }
        @AuraEnabled public string value { get; set; }
    }
    
    public class ReplyLink{
        @AuraEnabled public string label { get; set; } //'Reply Link'
        @AuraEnabled public string externalUrl { get; set; } //'#ReplyLink',
        @AuraEnabled public string communityPage { get; set; }
        @AuraEnabled public string objectPage { get; set; }
        @AuraEnabled public string recordId { get; set; }
    }
    
    //Wrapper class for Quick links Section
    public class PartnerQuickLinkInfo
    {
        @AuraEnabled public String title {get; set;}
        @AuraEnabled public List<Cards> cards{get; set;}     
    }
    
    public class Cards 
    {
        @AuraEnabled public string icon {get; set;}
        @AuraEnabled public string imageUrl {get; set;}
        @AuraEnabled public string svgIconUrl {get; set;}
        @AuraEnabled public string sfIcon {get; set;}
        @AuraEnabled public string title {get; set;}
        @AuraEnabled public string description {get; set;}
        @AuraEnabled public LinkData linkData {get; set;} 
    }
    
    public class LinkData
    {
        @AuraEnabled public string label {get; set;} 
        @AuraEnabled public string externalUrl {get; set;} 
        @AuraEnabled public string communityPage {get; set;} 
        @AuraEnabled public string objectPage {get; set;} 
        @AuraEnabled public string recordId {get; set;} 
    }
}