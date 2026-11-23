public class Account_script_Tier {
    public static void scriptmethod(){
        Date fixedDate = Date.newInstance(2025, 10, 1);
        Date today = Date.today();
        String tierforTitanium = 'Partner';
        List<Account> accountsToUpdate = [SELECT Id,Core_IPA_Partner_Role__c, Core_IPA_Badge_Tier__c, PRM_IPA_Badge_Tier_Date__c 
                                          FROM Account
                                          WHERE id='0018A00000VQUmIQAX'];
        for (Account acc : accountsToUpdate) {
            
            if (acc.Core_IPA_Partner_Role__c != null) {
                
                if (acc.Core_IPA_Partner_Role__c == 'Manufacturer' || 
                    
                    acc.Core_IPA_Partner_Role__c == 'Original Equipment Manufacturer (OEM)') {
                        
                        acc.Core_IPA_Partner_Role__c = 'Builder';
                        
                    } else if (acc.Core_IPA_Partner_Role__c == 'Solution provider') {
                        
                        acc.Core_IPA_Partner_Role__c = 'Solution Integrator';
                        
                    }
                
            }
            
            if (acc.Core_IPA_Badge_Tier__c == 'Titanium') {
                
                acc.Core_IPA_Badge_Tier__c = 'Partner';
                
                acc.PRM_IPA_Badge_Tier_Date__c = fixedDate;
                
            } else if (acc.Core_IPA_Badge_Tier__c == 'Member' || 
                       
                       acc.Core_IPA_Badge_Tier__c == 'Gold') {
                           
                           acc.Core_IPA_Badge_Tier__c = 'Partner';
                           
                           acc.PRM_IPA_Badge_Tier_Date__c = acc.Core_IPA_Badge_Tier__c == 'Gold' ? fixedDate : today;
                           
                       } else {
                           
                           acc.PRM_IPA_Badge_Tier_Date__c = today;
                           
                       }
            
        }
        
        
        if (!accountsToUpdate.isEmpty()) {
            update accountsToUpdate;
            System.debug('Updated ' + accountsToUpdate.size() + ' Account records.');
        } else {
            System.debug('No matching Account records found.');
        }
        
    }
    public static void methodscript() {
    List<Contact> contactsToUpdate = [
        SELECT Id, Core_IPA_PartnerRole__c
        FROM Contact
        WHERE Id = '0038A00000R10qRQAR'
    ]; 

    for (Contact c : contactsToUpdate) {
        if (c.Core_IPA_PartnerRole__c == 'Manufacturer') {
            c.Core_IPA_PartnerRole__c = 'Builder';
        } else if (c.Core_IPA_PartnerRole__c == 'Solution provider') {
            c.Core_IPA_PartnerRole__c = 'Solution Integrator';
        }
    }

    if (!contactsToUpdate.isEmpty()) {
        update contactsToUpdate;
        System.debug('Updated contact(s): ' + contactsToUpdate);
    } else {
        System.debug('No contacts found.');
    }
}

 
}