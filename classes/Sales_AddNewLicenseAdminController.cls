public with sharing class Sales_AddNewLicenseAdminController {
    @AuraEnabled
    public static Id createNewLicenseAdmDelegate(Sales_License_Admin_Delegate__c licAdmDelegate) {
        Sales_License_Admin_Delegate__c licAdmDelegateToInsert = new Sales_License_Admin_Delegate__c();
        try{
            if(licAdmDelegate != null){
                List<Contact> existingContactList = [Select Id, FirstName, LastName, Email from Contact where Email = :licAdmDelegate.Sales_License_DlgAdmin_Email_Txt__c WITH SECURITY_ENFORCED];
                Contact con;
                if(existingContactList.isEmpty()){ 
                    con = new Contact();   
                    Account acc = [Select Id,BillingCountry from Account where id = :System.label.PSG_Licensing_Account_Id ];
                    con.AccountId = acc.Id;
                    con.FirstName = licAdmDelegate.Sales_License_DlgAdmin_FirstName_Txt__c;
                    con.LastName = licAdmDelegate.Sales_License_DlgAdmin_LastName_Txt__c;
                    con.Email = licAdmDelegate.Sales_License_DlgAdmin_Email_Txt__c;
                    con.MailingCountry = acc.BillingCountry;
                    insert con;
                }else{
                    con = existingContactList[0];
                }                
                Contact primaryAdmContact;    
                if(licAdmDelegate.Sales_License_PrimaryAdmin_Contact__c == null){
                    Id primaryAdmUserId = userinfo.getuserid();
                    User primaryAdmUsr = [select id, contactId, contact.Email, contact.firstname, contact.lastname from User where id = : primaryAdmUserId WITH SECURITY_ENFORCED ];
                    primaryAdmContact = new Contact();
                    primaryAdmContact.id = primaryAdmUsr.contactid;
                    primaryAdmContact.LastName = primaryAdmUsr.contact.lastname;
                    primaryAdmContact.Email = primaryAdmUsr.contact.Email;                
                }else{
                    primaryAdmContact = [Select Id, FirstName, LastName, Email from Contact where Id = :licAdmDelegate.Sales_License_PrimaryAdmin_Contact__c WITH SECURITY_ENFORCED ];    
                }
                licAdmDelegateToInsert.Sales_License_DlgAdmin_Contact__c = con.id;
                licAdmDelegateToInsert.Sales_License_DlgAdmin_Email_Txt__c = con.Email;
                licAdmDelegateToInsert.Sales_License_DlgAdmin_FirstName_Txt__c = con.FirstName;
                licAdmDelegateToInsert.Sales_License_DlgAdmin_LastName_Txt__c = con.LastName;
                licAdmDelegateToInsert.Sales_License_PrimaryAdmin_Contact__c = primaryAdmContact.id;  
                licAdmDelegateToInsert.Sales_License_PrimaryAdmin_Email_Txt__c = primaryAdmContact.Email;
                licAdmDelegateToInsert.Sales_License_PrimaryAdmin_FirstName_Txt__c =  primaryAdmContact.firstname;      
                licAdmDelegateToInsert.Sales_License_PrimaryAdmin_LastName_Txt__c =  primaryAdmContact.lastname;
                insert licAdmDelegateToInsert;
            }
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        return licAdmDelegateToInsert.id;
    }
    
    @AuraEnabled
    public static boolean isCommunity(){
        Id siteId = Site.getSiteId(); 
        return siteId!=null?false:true;
         
    }    
}