@isTest
public without sharing class PSG_QuoteDocumentEmailController {

    /*@AuraEnabled
    public static Map<String,Object> getInitDetails(String recordId){
        Map<String,Object> responseMap=new Map<String,Object>();
        List<ContactWrapper> contactWrapper = new List<ContactWrapper>();
        try{
            List<SBQQ__QuoteDocument__c> documentList= [SELECT SBQQ__Quote__r.Id,SBQQ__Quote__r.OwnerId,SBQQ__Quote__r.Owner.Name,SBQQ__Quote__r.Owner.Email,SBQQ__Quote__r.core_cpq_requestor_nm__r.Email, SBQQ__Quote__r.core_cpq_requestor_nm__c, 
                                                   SBQQ__Quote__r.core_cpq_requestor_nm__r.Name FROM SBQQ__QuoteDocument__c where Id=:recordId];
            for(SBQQ__QuoteDocument__c quoteDocument : documentList){
                Id Ownerid=quoteDocument.SBQQ__Quote__r.OwnerId;
                String objType = String.valueOf(Ownerid.getsObjectType());
                if(objType != 'Group'){
                    contactWrapper.add(new ContactWrapper(quoteDocument.SBQQ__Quote__r.OwnerId,quoteDocument.SBQQ__Quote__r.Owner.Email,quoteDocument.SBQQ__Quote__r.Owner.Name));
                }
                if(quoteDocument.SBQQ__Quote__r?.core_cpq_requestor_nm__c != null && OwnerId != quoteDocument.SBQQ__Quote__r?.core_cpq_requestor_nm__c){
                    contactWrapper.add(new ContactWrapper(quoteDocument.SBQQ__Quote__r.core_cpq_requestor_nm__c,quoteDocument.SBQQ__Quote__r.core_cpq_requestor_nm__r.Email,quoteDocument.SBQQ__Quote__r.core_cpq_requestor_nm__r.Name));                    
                }
                if(Ownerid != Userinfo.getUserId()){
                    contactWrapper.add(new ContactWrapper(Userinfo.getUserId(),Userinfo.getUserEmail(),'currentPresent ' + Userinfo.getName()));
                }
            }
            responseMap.put('contactWrapper',contactWrapper);
            responseMap.put('emailDetails',getBodySubject(recordId));
            responseMap.put('availableContact', getAvailableContact());
            return responseMap;
        }catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static List<ContactWrapper> getAvailableContact() {
        try {
            List<ContactWrapper> contactWrapper = new List<ContactWrapper>();
            List<Contact> getRecentContact = [SELECT Id,Name,Email from Contact WHERE LastViewedDate !=null ORDER BY LastViewedDate DESC limit 25];
            if(Test.isRunningTest()){
                getRecentContact = [SELECT Id,Name,Email from Contact limit 25];
            }
            for (Contact currContact : getRecentContact) {
                contactWrapper.add(new ContactWrapper(currContact.Id,currContact.Email,currContact.Name));
            }
            return contactWrapper;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static List<ContactWrapper> searchContactOrUser(String searchString, String objectName) {
        try {
            List<ContactWrapper> contactWrapper = new List<ContactWrapper>();
            Map<String,String> getEmailOfPeople = new Map<String,String>();
            Map<String,Id> mapIdEmailForPeople = new Map<String,Id>();
            searchString=searchString!=null?String.escapeSingleQuotes(searchString):'';
            objectName=objectName!=null?String.escapeSingleQuotes(objectName):'';
            if(searchString != null){
                String searchTerm='\'%' + searchString + '%\'';
                String searchObject = 'SELECT Id, Name, Email from ' + objectName + ' WHERE Name LIKE ' +searchTerm+ ' OR Email LIKE ' +searchTerm+ ' LIMIT 25';
                List<SObject> searchResult = Database.query(searchObject);
                if(!(searchResult.isEmpty())){
                    for(SObject obj: searchResult){
                        getEmailOfPeople.put((String)obj.get('Email'),(String)obj.get('Name'));
                        mapIdEmailForPeople.put((String)obj.get('Email'),(Id)obj.get('Id'));
                    }
                }
                if(!(getEmailOfPeople.isEmpty())){
                    for(String mapKey : getEmailOfPeople.keySet()){
                        contactWrapper.add(new ContactWrapper(mapIdEmailForPeople.get(mapKey),mapKey,getEmailOfPeople.get(mapKey)));
                    }
                }
            }
            return contactWrapper;
        }catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static Map<String,String> getBodySubject(String recordId){
        try{
            List<SBQQ__QuoteDocument__c> document= [SELECT Id,Name,SBQQ__Quote__c,SBQQ__DocumentId__c from SBQQ__QuoteDocument__c where Id=:recordId];
            EmailTemplate template = [Select Id,Subject,HtmlValue,Markup,DeveloperName,Body from EmailTemplate where DeveloperName = 'PSG_Quote_Document_Notification'];
            Map<String,String> emailBody = new Map<String,String>();  
            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
            for(SBQQ__QuoteDocument__c doc : document){
                Savepoint sp = Database.setSavepoint();
                Messaging.SingleEmailMessage getEmail = Messaging.renderStoredEmailTemplate(template.Id, null, doc.SBQQ__Quote__c);
                getEmail.setToAddresses(new List<String>{Userinfo.getUserEmail()});
                getEmail.setSaveAsActivity(false);
                emails.add(getEmail);
                Database.rollback(sp);
                emailBody.put(getEmail.getSubject(),getEmail.getHtmlBody());
            } 
            return emailBody;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static void sendEmailController(String recordId, List<String> getToRecipientList,List<String> getCcRecipientList,List<String> getBccRecipientList){
        try{
            List<SBQQ__QuoteDocument__c> document= [SELECT Id,Name,SBQQ__Quote__c,SBQQ__DocumentId__c from SBQQ__QuoteDocument__c where Id=:recordId];
            EmailTemplate template = [Select Id,Subject,HtmlValue,Markup,DeveloperName,Body from EmailTemplate where DeveloperName = 'PSG_Quote_Document_Notification'];
            OrgWideEmailAddress orgWideEmailAdd = [SELECT Id, Address,DisplayName from OrgWideEmailAddress where Address='wsm-postmaster@intel.com'];
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            for(SBQQ__QuoteDocument__c doc : document){
                Messaging.SingleEmailMessage sendEmail = Messaging.renderStoredEmailTemplate(template.Id, null, doc.SBQQ__Quote__c);
                sendEmail.setSaveAsActivity(true);
                sendEmail.setOrgWideEmailAddressId(orgWideEmailAdd.Id);
                sendEmail.setEntityAttachments(new String[]{doc.SBQQ__DocumentId__c});
                sendEmail.setToAddresses(getToRecipientList);
                if(!getccRecipientList.isEmpty()){
                    sendEmail.setCcAddresses(getccRecipientList);
                }
                if(!getbccRecipientList.isEmpty()){
                    sendEmail.setBccAddresses(getBccRecipientList);
                }                
                mails.add(sendEmail);
            }
            if(!Test.isRunningTest()){
                Messaging.sendEmail(mails);
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    public class ContactWrapper {
        @AuraEnabled
        public Id peopleId;
        @AuraEnabled
        public String email;
        @AuraEnabled
        public String name;

        public ContactWrapper(Id peopleId,String email,String name){
            this.peopleId=peopleId;
            this.email=email;
            this.name=name;
        }
    }*/
    
}