public class CreateNewContactDemo {

    @AuraEnabled
    public static List<contact> createContacts(List<Contact> Conts,String loggedInUserId){
        String strIntelContactRecType = 'Intel Contact';
        List<User> lstLoggedInUser = [SELECT Id, ContactId, Contact.AccountId, Contact.Core_IPA_PartnerRole__c, Core_IPA_One_Partner_Id__c FROM User WHERE Id = : loggedInUserId];
        Id idIntelAccRecId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(strIntelContactRecType).getRecordTypeId();
        List<Contact> ConList=new List<Contact>();
        for(Contact contlist:Conts){
            Contact con=new contact();
            con.FirstName=contlist.FirstName;
            con.LastName=contlist.LastName;
            con.AccountId=lstLoggedInUser[0].Contact.AccountId;
            con.Email=contlist.Email;
            con.Core_Preferred_Language__c=contlist.Core_Preferred_Language__c;
            con.MailingCountry=contlist.MailingCountry;
            con.Core_IPA_PartnerRole__c = lstLoggedInUser[0].Contact.Core_IPA_PartnerRole__c;
            con.RecordTypeId = idIntelAccRecId;
            ConList.add(con);
        }
        try{
            List<Database.saveresult> sr = database.Insert(ConList);
            System.debug('Success'+sr);
        }
         catch (Exception e) {
            system.debug('error msg'+e);
         }
        System.debug(Conts);
        return Conts;
    }
}