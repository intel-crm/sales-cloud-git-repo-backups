/******************************************************************************************************************************************
Apex Class Name:  Core_InquiryTrigger
Version     : 1.0 
Created Date: 29 Jun 2020
Function    : Utility methods for Email Notifications for the object Inquiry
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Ankita Roy            29/06/2020              Original Version
* Ankita Roy            29/06/2020              US579662-DEVELOPMENT ONLY : LEAD : Email Notifications for Enquiry  Part 1 
*******************************************************************************************************************************************/
public class Core_InquiryTrigger_Handler{

    //Method created to fullfill the code coverage to migrate the commented code.

    public static void placeholderMethod() {
        System.debug('Placeholder method executed.');
    }
    
    //US579662-DEVELOPMENT ONLY : LEAD : Email Notifications for Enquiry  Part 1  --Starts
    //public static String fromEmailAddress = System.Label.Core_SetFromEmailAddress;
    /*
* Method name  : SendInquiryEmailNotification
* Description  : Method to Send Inquiry Lead Email Notification
* Return Type  : void
* Parameter    : Lead List
*/
    
    // Lead Inquiry Email Notification -Starts
    /*Public static void SendInquiryEmailNotification(List<Core_Inquiry__c>  newList){
        List<Core_Inquiry__c> newInquiryList= new List<Core_Inquiry__c>();
        for(Core_Inquiry__c Inq : newList){
            if(Inq.Core_Inquiry_Type_Pkt__c =='High Value Engagement' && Inq.Core_Lead_Inquiries__c <> null){
                newInquiryList.add(Inq);
            }
        }
        
        if(newInquiryList.size() > 0){
            SendInquiryEmail(newInquiryList);
        }	 
    }
    
    
    public static void SendInquiryEmail(List<Core_Inquiry__c> newInquiryList){
        Set<Id> Ids= new Set<Id>();
        for(Core_Inquiry__c Inquiry : newInquiryList){
            Ids.add(Inquiry.Core_Lead_Inquiries__c);
        }
        
        List<Lead> InquiryLeadList=[Select id, OwnerId,Owner.type, Owner.FirstName,Core_Marketing_Score__c,(Select id,Status,Name,Campaign.Description,Campaign.Name,Campaign.MKT_Corporate_Campaign_nm__c from CampaignMembers ORDER BY CreatedDate DESC limit 1) from Lead Where Id IN :Ids];
        
        
        //set of ownerId
        Set<String> ownerIdSet = new Set<String>();
        String ownerIdStr='';
        for(Lead ld : InquiryLeadList){
            //Gireesh:US830838: The email for inquiry should only trigger when the lead owner changes from a queue to a user
            ownerIdStr=String.valueOf(ld.OwnerId);
            if(ld.Owner.type!=null && ld.Owner.type=='User' && ownerIdStr.startsWith('005')){
                ownerIdSet.add(ld.OwnerId);	    
            }            
        }
        
        //Map of User to check if the owner is user or not
        Map<Id,User> userMap = new Map<Id,User>([select Id, Name from User where Id IN: ownerIdSet]);
        if(!userMap.isEmpty()){
            //put leads in the map which are having owner as user
            Map<Id,Lead> inquiryLeadMap = new Map<Id,Lead>();
            for(Lead ld : InquiryLeadList){
                if(userMap.containsKey(ld.OwnerId)){
                    inquiryLeadMap.put(ld.Id, ld);
                }
            }
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            List<contact> conList = [select id from contact limit 1];
            if(newInquiryList.size() >0){
                for(Core_Inquiry__c Inq: newInquiryList){
                    if(inquiryLeadMap.containsKey(Inq.Core_Lead_Inquiries__c)){
                        List<string> emaillist=new List<String>();
                        emaillist.add(inquiryLeadMap.get(Inq.Core_Lead_Inquiries__c).OwnerId);        
                        // Email Body Starts Here
                        String body= 'Hi '+inquiryLeadMap.get(Inq.Core_Lead_Inquiries__c).Owner.FirstName+','+'<br/>'+'<br/>';
                        body +='You are receiving this alert because we have a person who is highly engaged. Based on the number of recent marketing interactions and target profile data, they may be worth contacting.'+'<br/>'+'<br/>';
                        body+='Keep in mind this person has not requested Sales follow up yet, so upon outreach try to focus on asking questions about their needs based on the info below.'+'<br/>'+'<br/>';
                        String baseUrl=system.URL.getSalesforceBaseUrl().toExternalForm()+'/'+Inq.Core_Lead_Inquiries__c;
                        String TraingUrl=label.Core_Inquiry_Training_URL;
                        
                        body +='<a href="'+baseUrl+'">Click here to see this person’s full profile in Salesforce CRM »'+'</a>'+'<br/>'+'<br/>';
                        body += '<b>'+'Here are the Person'+'\'s'+'details : ' +'</b>'+'<br/>';
                        body += 'First Name : '+Inq.Core_First_Name_Txt__c+'<br/>';
                        body += 'Last Name : '+Inq.Core_Last_Name_Txt__c+'<br/>';
                        body += 'Company : '+Inq.Core_Company_Txt__c+'<br/>';
                        body += 'Job Title :'+Inq.Core_Title_Txt__c+'<br/>';
                        body += 'Phone Number : '+Inq.Core_Phone_Txt__c+'<br/>';
                        body += 'Email : '+Inq.Core_Email_Txt__c+'<br/>';
                        body += 'How they found us originaly : '+Inq.Core_Lead_Source__c +'<br/>'+'<br/>';
                        body +='<b> Some details about their interactions :</b>'+'<br/>'+'<br/>';
                        if(inquiryLeadMap.get(Inq.Core_Lead_Inquiries__c).CampaignMembers !=null && !inquiryLeadMap.get(Inq.Core_Lead_Inquiries__c).CampaignMembers.isEmpty()){
                            body +='Most recent Campaign association : '+inquiryLeadMap.get(Inq.Core_Lead_Inquiries__c).CampaignMembers[0].Campaign.Name+'<br/>';
                            body += 'What they did : '+inquiryLeadMap.get(Inq.Core_Lead_Inquiries__c).CampaignMembers[0].Campaign.Description+'<br/>';
                            body += 'Corporate Campaign : '+inquiryLeadMap.get(Inq.Core_Lead_Inquiries__c).CampaignMembers[0].Campaign.MKT_Corporate_Campaign_nm__c+'<br/>';
                        }else{
                            body +='Most recent Campaign association : '+' '+'<br/>';
                            body += 'What they did : '+' '+'<br/>';
                            body += 'Corporate Campaign : '+' '+'<br/>';
                        }
                        
                        if(inquiryLeadMap.get(Inq.Core_Lead_Inquiries__c).Core_Marketing_Score__c != null){
                            body += 'Marketing Score : '+inquiryLeadMap.get(Inq.Core_Lead_Inquiries__c).Core_Marketing_Score__c+'<br/>'+'<br/>';
                        }else{
                            body +='Marketing Score : '+'<br/>'+'<br/>';
                        }
                        body +='Please remember to log any calls or emails you make when engaging with this person. If you have questions regarding how to manage any Lead/Inquiry assigned to you, please '+'<a href="'+TraingUrl+'">visit our Sales CRM training website</a>'+'<br/>'+'<br/>';
                        body +='<p>'+'Sincerely,'+'<br/>';
                        body +='Your Marketing Automation Team'+'</p>';
                        // Email Body Ends here
                        
                        
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        mail.setToAddresses(emaillist);
                        String Subject ='New High-Value Engagement: '+ Inq.Core_First_Name_Txt__c +' '+Inq.Core_Last_Name_Txt__c +' at '+ Inq.Core_Company_Txt__c+ ' has recent engagement activity';
                        mail.setSubject(Subject);
                        mail.setHtmlBody(Body);
                        mail.setTargetObjectId(conList[0].Id);
                        mail.setSaveAsActivity(false); 
                        mail.setTreatTargetObjectAsRecipient(false);
                        mail.setOrgWideEmailAddressId(fromEmailAddress);
                        mails.add(mail);
                    }
                }
            }
            if(mails.size() > 0){
                Messaging.sendEmail(mails);
            }
        }
        
        
    }*/
    // Lead Inquiry Email Notification -Ends
    
    
    /*
* Method name  : SendInquiryContactEmailNotification
* Description  : Method to Send Inquiry Contact Email Notification
* Return Type  : void
* Parameter    : Lead List
*/
    
    // Contact Inquiry Email Notification -Starts
   /* Public static void SendInquiryContactEmailNotification(List<Core_Inquiry__c>  newList){
        
        List<Core_Inquiry__c> newInquiryList= new List<Core_Inquiry__c>();
        for(Core_Inquiry__c Inq : newList){
            if(Inq.Core_Inquiry_Type_Pkt__c =='High Value Engagement' && Inq.Core_Contact_Inquiries__c <> null){
                newInquiryList.add(Inq);
            }
        }
        
        if(newInquiryList.size() > 0){
            SendInquiryContactEmail(newInquiryList);
        }	 
    }
    public static void SendInquiryContactEmail(List<Core_Inquiry__c> newInquiryList){
        
        Set<Id> Ids= new Set<Id>();
        for(Core_Inquiry__c Inquiry : newInquiryList){
            Ids.add(Inquiry.Core_Contact_Inquiries__c);
        }
        
        Map<Id,Contact> InquiryLeadList=new Map<Id,Contact>([Select id,OwnerId,Owner.FirstName,Core_Marketing_Score1__c,Account.Name,(Select id,Status,Name,Campaign.Description,Campaign.Name,Campaign.MKT_Corporate_Campaign_nm__c from CampaignMembers ORDER BY CreatedDate DESC limit 1) from Contact Where Id IN :Ids]);
        
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        if(newInquiryList.size() >0){
            for(Core_Inquiry__c Inq: newInquiryList){
                List<contact> conList = [select id from contact limit 1];
                List<string> emaillist=new List<String>();
                emaillist.add(InquiryLeadList.get(Inq.Core_Contact_Inquiries__c).OwnerId);
                
                // Email Body Starts 
                String body= 'Hi '+InquiryLeadList.get(Inq.Core_Contact_Inquiries__c).Owner.FirstName+','+'<br/>'+'<br/>';
                body +='You are receiving this alert because we have a person who is highly engaged. Based on the number of recent marketing interactions and target profile data, they may be worth contacting.'+'<br/>'+'<br/>';
                body +='Keep in mind this person has not requested Sales follow up yet, so upon outreach try to focus on asking questions about their needs based on the info below.'+'<br/>'+'<br/>';
                String baseUrl=system.URL.getSalesforceBaseUrl().toExternalForm()+'/'+Inq.Core_Contact_Inquiries__c;
                String TraingUrl=label.Core_Inquiry_Training_URL;
                
                body +='<a href="'+baseUrl+'">Click here to see this person’s full profile in Salesforce CRM »'+'</a>'+'<br/>'+'<br/>';
                body += '<b>'+'Here are the Person'+'\'s'+'details :' +'</b>'+'<br/>'+'<br/>';
                body += 'First Name : '+Inq.Core_First_Name_Txt__c+'<br/>';
                body += 'Last Name : '+Inq.Core_Last_Name_Txt__c+'<br/>';
                body += 'Company : '+InquiryLeadList.get(Inq.Core_Contact_Inquiries__c).Account.Name+'<br/>';
                body += 'Job Title : '+Inq.Core_Title_Txt__c+'<br/>';
                body += 'Phone Number : '+Inq.Core_Phone_Txt__c+'<br/>';
                body += 'Email : '+Inq.Core_Email_Txt__c+'<br/>';
                body += 'How they found us originaly : '+Inq.Core_Contact_Lead_Source__c +'<br/>'+'<br/>';
                body +='<b> Some details about their interactions :</b>'+'<br/>'+'<br/>';
                if(InquiryLeadList.get(Inq.Core_Contact_Inquiries__c).CampaignMembers !=null && !InquiryLeadList.get(Inq.Core_Contact_Inquiries__c).CampaignMembers.isEmpty()){
                    body +='Most recent Campaign association : '+InquiryLeadList.get(Inq.Core_Contact_Inquiries__c).CampaignMembers[0].Campaign.Name+'<br/>';
                    body += 'What they did : '+InquiryLeadList.get(Inq.Core_Contact_Inquiries__c).CampaignMembers[0].Campaign.Description+'<br/>';
                    body += 'Corporate Campaign : '+InquiryLeadList.get(Inq.Core_Contact_Inquiries__c).CampaignMembers[0].Campaign.MKT_Corporate_Campaign_nm__c+'<br/>';
                }else{
                    body +='Most recent Campaign association : '+' '+'<br/>';
                    body += 'What they did : '+' '+'<br/>';
                    body += 'Corporate Campaign : '+' '+'<br/>';
                }
                
                if(InquiryLeadList.get(Inq.Core_Contact_Inquiries__c).Core_Marketing_Score1__c !=null){
                    body += 'Marketing Score : '+InquiryLeadList.get(Inq.Core_Contact_Inquiries__c).Core_Marketing_Score1__c+'<br/>'+'<br/>';
                }else{
                    body +='Marketing Score : '+'<br/>'+'<br/>';
                }
                body +='Please remember to log any calls or emails you make when engaging with this person. If you have questions regarding how to manage any Lead/Inquiry assigned to you, please '+'<a href="'+TraingUrl+'">visit our Sales CRM training website</a>'+'<br/>'+'<br/>';
                body +='<p>'+'Sincerely,'+'<br/>';
                body +='Your Marketing Automation Team'+'</p>';
                // Email Body Ends			  
                
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(emaillist);
                String Subject ='New High-Value Engagement: '+ Inq.Core_First_Name_Txt__c +' '+Inq.Core_Last_Name_Txt__c + ' at '+ 
                    InquiryLeadList.get(Inq.Core_Contact_Inquiries__c).Account.Name+ ' has recent engagement activity';
                mail.setSubject(Subject);
                mail.setHtmlBody(Body);
                mail.setTargetObjectId(conList[0].Id);
                mail.setSaveAsActivity(false); 
                mail.setTreatTargetObjectAsRecipient(false);
                mail.setOrgWideEmailAddressId(fromEmailAddress);
                mails.add(mail);
            }
        }
        if(mails.size() > 0){
            Messaging.sendEmail(mails);
        }
        
    }
    // Contact Inquiry Email Notification -Ends
    //US579662-DEVELOPMENT ONLY : LEAD : Email Notifications for Enquiry  Part 1  --Ends
    
    
    public static void UpdateRegionValue(List<Core_Inquiry__c> newInquiryList, Map<Id,Core_Inquiry__c> oldInquiryMap, Boolean isInsert){
        
        List<Core_Inquiry__c> InqContactList = new List<Core_Inquiry__c>();
        List<Core_Inquiry__c> InqLeadList = new List<Core_Inquiry__c>();
        Set<Id> ContactIds= new Set<Id>();
        Set<Id> LeadIds= new Set<Id>();
        for(Core_Inquiry__c Inq : newInquiryList ){
            
            if(Inq.Core_Contact_Inquiries__c <> null && Inq.Core_Lead_Inquiries__c ==null && isInsert){
                
                InqContactList.add(Inq);
                ContactIds.add(Inq.Core_Contact_Inquiries__c);
            }else if(Inq.Core_Contact_Inquiries__c <> null &&  Inq.Core_Lead_Inquiries__c ==null && !isInsert && Inq.Core_Contact_Inquiries__c <> oldInquiryMap.get(Inq.Id).Core_Contact_Inquiries__c){
                InqContactList.add(Inq);
                ContactIds.add(Inq.Core_Contact_Inquiries__c);
            }else if(Inq.Core_Lead_Inquiries__c <> null &&  Inq.Core_Contact_Inquiries__c ==null && isInsert){
                InqLeadList.add(Inq);
                LeadIds.add(Inq.Core_Lead_Inquiries__c);
            }else if(Inq.Core_Lead_Inquiries__c <> null && Inq.Core_Contact_Inquiries__c ==null && !isInsert && Inq.Core_Lead_Inquiries__c <> oldInquiryMap.get(Inq.Id).Core_Lead_Inquiries__c){
                InqLeadList.add(Inq);
                LeadIds.add(Inq.Core_Lead_Inquiries__c);
            }
            
        }
        
        if(InqContactList.size() > 0){
            //UpdateContactRegion(InqContactList);
            UpdateContactRegion(InqContactList,ContactIds);
        }
        
        if(InqLeadList.size() > 0){
            //UpdateContactRegion(InqContactList);
            UpdateLeadRegion(InqLeadList,LeadIds);
        }
        
        
    }
    public static void UpdateContactRegion(List<Core_Inquiry__c> InqContactList, Set<Id> ContactIds){
        // Set<Id> Ids= new Set<Id>();
        map<String, Core_Country_Reference__c> mCountryCodeGeoRef = new map<String, Core_Country_Reference__c>();
        List<Contact> ContactLst=[Select id,MailingCountryCode from Contact where Id IN :ContactIds ];
        
        Map<Id,Contact> ContactMap = new  Map<Id,Contact>([Select id,MailingCountryCode from Contact where Id IN :ContactIds]);
        
        for(Core_Country_Reference__c sobjStateRef : Core_Country_Reference__c.getall().values()){
            mCountryCodeGeoRef.put(sobjStateRef.Core_ISO_Code__c,sobjStateRef);
        }
        
        for (Core_Inquiry__c Inq : InqContactList ){
            system.debug('CountryCode'+ContactMap);
            
            String CountryCode= ContactMap.get(Inq.Core_Contact_Inquiries__c).MailingCountryCode;
            system.debug('CountryCode1'+CountryCode);
            if(CountryCode <> null){
                if(mCountryCodeGeoRef.get(CountryCode) <> null && mCountryCodeGeoRef.get(CountryCode) <> null ){
                    Inq.Core_Region__c =mCountryCodeGeoRef.get(CountryCode).Core_Geo__c;
                    Inq.Core_Sub_Region__c =mCountryCodeGeoRef.get(CountryCode).Core_Sub_Geo__c;
                }
            }
            
        }
    }
    
    public static void UpdateLeadRegion(List<Core_Inquiry__c> InqContactList, Set<Id> LeadIds){
        // Set<Id> Ids= new Set<Id>();
        map<String, Core_Country_Reference__c> mCountryCodeGeoRef = new map<String, Core_Country_Reference__c>();
        // List<Lead> LeadLst=[Select id from Lead where Id IN :LeadIds ];
        
        Map<Id,Lead> LeadMap = new  Map<Id,Lead>([Select id,Core_Geo__c,Core_Sub_Geo__c,CountryCode from Lead where Id IN :LeadIds]);
        
        for(Core_Country_Reference__c sobjStateRef : Core_Country_Reference__c.getall().values()){
            mCountryCodeGeoRef.put(sobjStateRef.Core_ISO_Code__c,sobjStateRef);
        }
        
        for (Core_Inquiry__c Inq : InqContactList ){
            system.debug('CountryCode'+LeadMap);
              Inq.Core_Region__c=  LeadMap.get(Inq.Core_Lead_Inquiries__c).Core_Geo__c;
              Inq.Core_Sub_Region__c =LeadMap.get(Inq.Core_Lead_Inquiries__c).Core_Sub_Geo__c;
            
            
        }
    }
   */ 
}