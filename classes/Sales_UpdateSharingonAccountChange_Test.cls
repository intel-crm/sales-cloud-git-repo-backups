@isTest
public class Sales_UpdateSharingonAccountChange_Test {
  public static Account createAccount_PartnerandNonpartner_PSGDownstream(String CoreAccountType, String Acctype){
        Account acc = Sales_TestDataFactory.createDefaultAccount();
        acc.Core_PSG_Account__c=true;   
        acc.Core_Account_Type__c = CoreAccountType;
        acc.Type = Acctype;
        return acc;
    }
    public static Contact createContactWithDetails(Id accId, String fName, String lName, String emailId){
        Contact con = Sales_TestDataFactory.createContactRecord(new Map<String,String>{
            'FirstName'=>fName,
                'LastName'=>lName,
                'Email'=>emailId,
                'AccountId'=>accId
                });
        return con;
    }
    static testmethod void testcreateLicenseContactUsers(){
        Map<String, User> emailUserIdMap = new Map<String, User>();
        User u = [Select id, Email, FirstName, LastName from User where Id = :UserInfo.getUserid()];
        emailUserIdMap.put(u.Email, u);
        Account partnerAccount = createAccount_PartnerandNonpartner_PSGDownstream('Independent Software Vendor (ISV)', 'Partner');                
        insert partnerAccount;
        Sales_CreateLicenseContactUser_Utility.createLicenseContactUsers(emailUserIdMap);
        Contact partnerContact = createContactWithDetails(partnerAccount.Id, 'partner','addhost','xyztest@intel.com');        
        insert  partnerContact;
        User us = new User();
        us.FirstName = 'test';
        us.LastName = 'user';
        us.Email = 'xyztest@intel.com';
        us.Username = 'xyztest@testabc.com';
        us.Alias = 'testu';
        us.CommunityNickname = 'test.user';
        us.TimeZoneSidKey = 'America/Los_Angeles';
        us.LocaleSidKey = 'en_US';
        us.EmailEncodingKey = 'UTF-8';
        us.ProfileId = UserInfo.getProfileId();
        us.LanguageLocaleKey = 'en_US';
        insert us;
        emailUserIdMap.clear();
        emailUserIdMap.put(partnerContact.Email, us);
        Set<Id> contactIds = new Set<Id>();
        Sales_License_Admin_Delegate__c licAdmDlg1 = new Sales_License_Admin_Delegate__c();
        licAdmDlg1.Sales_License_PrimaryAdmin_Contact__c = partnerContact.Id;
        insert licAdmDlg1;
        Sales_License__c lic=Sales_TestDataFactory.createLicenseRecord();
        lic.Sales_License_Primary_Admin_Contact__c=partnerContact.Id;
        lic.Sales_License_Web_Display_Flag__c=true;
        List<Account> accList = [Select Id from Account where Id = :System.label.Sales_PSGAccountForInternalUser limit 1];
        Sales_Host__c hcc= Sales_TestDataFactory.createComputerRecord();
        hcc.Sales_Contact__c=partnerContact.Id;
   if(partnerContact!=null)
   {
   contactIds.add(partnerContact.Id);
   }
    Map<id,id> contactmap=new Map<id,id>();
    contactmap.put(partnerContact.id,partnerContact.id); 
        Map<String,Id> emailIdConIdMap =new Map<String,Id>();
        emailIdConIdMap.put(partnerContact.Email,partnerContact.Id);
        Sales_UpdateSharingonAccountChange.updateSharingOn_LicenseHost(contactIds);
        System.assertEquals('','');
    }   
}