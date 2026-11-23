@isTest
public class Sales_UpdateAccountDetails_Test {
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
    @isTest
    static void updateAccountNameTest(){
        List<Account> AccountList= new List<Account>();
        Account partnerAccount = createAccount_PartnerandNonpartner_PSGDownstream('Independent Software Vendor (ISV)', 'Partner');                
        insert partnerAccount;
        Sales_License__c testLicense = Sales_TestDataFactory.createLicenseRecord();
        testLicense.Sales_License_Account__c=partnerAccount.id;
        insert testLicense;
        partnerAccount.name='testAccountUpdateOnLicense';
        update partnerAccount;
        test.startTest();
        AccountList.add(partnerAccount);
        Sales_UpdateAccountDetails.updateAccountDetails_License(AccountList);
        test.stopTest();
        System.assertEquals('','');
    }
}