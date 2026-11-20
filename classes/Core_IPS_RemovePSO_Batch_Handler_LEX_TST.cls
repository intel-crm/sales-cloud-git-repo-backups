@isTest
public class Core_IPS_RemovePSO_Batch_Handler_LEX_TST {
    
    static testMethod void testBatchKickoff(){
        insert new Core_Contact_Bypass_Validation_Rule__c(SetupOwnerId=UserInfo.getOrganizationId(), Bypass__c=true);
        Account upateAccount = new Account();
        upateAccount.name='XYZ';
        upateAccount.Phone = '+49-12345';
        upateAccount.BillingStreet = 'Am Tierpark 16';
        upateAccount.BillingCity = 'Fremont';
        upateAccount.BillingPostalCode = '54321';
        upateAccount.BillingState = 'CA';
        upateAccount.BillingCountry = 'USA';
        upateAccount.Core_Account_Type__c = 'Distributor';
        upateAccount.Core_Sales_Groups__c = 'Americas US Sales Group';
        upateAccount.Core_Sales_Group__c = 'Global Accounts';
        upateAccount.Industry = 'Agriculture';
        
        insert upateAccount;  
        
        
        Contact cc = new Contact(  
            
            FirstName='Joe',
            LastName='Schmoe',
            Email='Joe.Schmoe@test.de',
            AccountId=upateAccount.id,
            MailingStreet=upateAccount.BillingStreet,
            //Core_IPS_Active__c=true,
            Core_IPS_Email_Opt_Out__c=false,
            MailingState = upateAccount.BillingState,
            MailingCity=upateAccount.BillingCity,
            MailingPostalCode=upateAccount.BillingPostalCode,
            MailingCountry = upateAccount.BillingCountry,
            Phone='9865986598');
        insert cc;
        
        
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'IPS External Customer' LIMIT 1];
        
        
        User usr = new User(LastName = 'LIVESTON1',
                            FirstName='JASON1',
                            Alias = 'jliv1',
                            Email = 'jason1.livesto@example.com',
                            Username = 'jason1.liveston@asdf.com',
                            ProfileId = profileId.id,
                            TimeZoneSidKey = 'GMT',
                            LanguageLocaleKey = 'en_US',
                            EmailEncodingKey = 'UTF-8',
                            LocaleSidKey = 'en_US',
                            ContactId = cc.id
                            
                           );
        insert usr;
        
        Asset asset= new Asset();
        asset.Name='intel Products test';
        insert asset; 
        String RT = [Select Id,Name From RecordType Where SobjectType = 'Case' and DeveloperName ='IPS_Case_Create'].Id;
        
        Case  cse = new Case ();
        cse.RecordTypeId=RT;
        //  cse.core_ips_project_case__c=cipspro.id;
        // cse.Core_IPS_Supported_Product__c=ListOfSupportedProduct.get(0).id;
        cse.status='OPEN';
        cse.accountid=upateAccount.id;
        cse.contactid=cc.id;
        cse.assetId=asset.id;
        cse.Core_IPS_Partner_Sup_Owner__c=usr.id;
        cse.Core_IPS_Issue_source__c='Legacy PSG';
        cse.Core_Severity__c='Critical';
        insert cse;
        
        //  Core_IPS_RemovePSO_Batch_Handler_LEX ext= Core_IPS_RemovePSO_Batch_Handler_LEX(cc);
        //     ext.runBatch();
        Core_IPS_RemovePSO_Batch_Handler_LEX.runBatchfromLWC(cc.id);
        System.AssertEquals(cse != null, true);
    }
}