/***************************************************************************************************************************************
Apex Class Name     : PRM_PartnerDealOpportunitySharing_Test 
Version             : 1.0
Created Date        : August 2026
Function            : Test class to to validate the logic written in PRM_PartnerDealOpportunitySharingService
Modification Log    : 
* Developer                         Date                           Description
   Utkarsh                         
***********************************************/

@IsTest
private class PRM_PartnerDealOpportunitySharing_Test {

    @TestSetup
    static void setupTestData() {
        
        //Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Intel Account').getRecordTypeId();
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
        Id recordTypeIdOPIDAcc = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
        Id IntelrecordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get(System.Label.PRM_Intel_Account_Record_Type).getRecordTypeId();
        //Test Data for Accounts
        List<Account> acc = new List<Account>();
        Account newAccount = new Account();//Account
        newAccount.RecordTypeId = IntelrecordTypeIdAccount;
        newAccount.Core_Intel_Partner_Alliance_PartnerGroup__c=true;
        newAccount.Name='John Rick';
        newAccount.BillingCity='City';
        newAccount.BillingStreet='Street';
        newAccount.BillingCountry='India';
        newAccount.BillingPostalCode='Postal code';
        newAccount.Core_IPA_Partner_Role__c = 'Builder';
        newAccount.Core_CNDA_Number__c='';
        newAccount.Core_Account_Type__c='Cloud Service Provider (CSP)';
        newAccount.Core_IPA_Badge_Tier__c='Partner';
        newAccount.Industry='Agriculture';
        newAccount.Core_Sub_Industry__c= 'Crop Production';
        newAccount.Core_Sales_Groups__c='Americas US Sales Group';
        acc.add(newAccount);
        
        Account newAccount1 = new Account();//Account
        
        newAccount1.RecordTypeId = IntelrecordTypeIdAccount;
        newAccount1.Core_Intel_Partner_Alliance_PartnerGroup__c=true;
        newAccount1.Name='Test 2';
        newAccount1.BillingCity='City';
        newAccount1.BillingStreet='Street';
        newAccount1.BillingCountry='India';
        newAccount1.BillingPostalCode='Postal code';
        newAccount1.Core_IPA_Partner_Role__c = 'Builder';
        newAccount1.Core_CNDA_Number__c='676875764539878';
        newAccount1.Core_Account_Type__c='Cloud Service Provider (CSP)';
        newAccount1.Core_IPA_Badge_Tier__c='Partner';
        acc.add(newAccount1);
        
        Account newAccount2 = new Account();//OPID Account
        newAccount2.RecordTypeId = IntelrecordTypeIdAccount;
        newAccount2.Core_Intel_Partner_Alliance_PartnerGroup__c=true;
        newAccount2.Name='Test 3';
        newAccount2.BillingCity='City';
        newAccount2.BillingStreet='Street';
        newAccount2.BillingCountry='India';
        newAccount2.BillingPostalCode='Postal code';
        newAccount2.Core_IPA_Partner_Role__c = 'Builder';
        newAccount2.Core_Account_Type__c='Cloud Service Provider (CSP)';
        newAccount2.Core_IPA_Badge_Tier__c='Partner';
        acc.add(newAccount2);
        
        insert acc;

        // Create a User who will be added to Account Team
        Profile p = [
            SELECT Id
            FROM Profile
            WHERE Name = 'System Administrator'
            LIMIT 1
        ];

        User teamMember = new User(
            FirstName = 'Test',
            LastName = 'TeamMember',
            Alias = 'tteam',
            Email = 'test.teammember' + System.currentTimeMillis() + '@example.com',
            Username = 'test.teammember' + System.currentTimeMillis() + '@example.com',
            ProfileId = p.Id,
            TimeZoneSidKey = 'Asia/Kolkata',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert teamMember;

        // Create another User who should NOT receive access
        User nonTeamMember = new User(
            FirstName = 'Non',
            LastName = 'TeamMember',
            Alias = 'nteamm',
            Email = 'test.nonteammember' + System.currentTimeMillis() + '@example.com',
            Username = 'test.nonteammember' + System.currentTimeMillis() + '@example.com',
            ProfileId = p.Id,
            TimeZoneSidKey = 'Asia/Kolkata',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert nonTeamMember;
        
        User adminUser = new User(
            FirstName = 'Admin',
            LastName = 'Member',
            Alias = 'tteam',
            Email = 'test.teammember' + System.currentTimeMillis() + '@example.com',
            Username = 'test.teammember' + System.currentTimeMillis() + '@example.com',
            ProfileId = p.Id,
            TimeZoneSidKey = 'Asia/Kolkata',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert adminUser;
        
        System.runAs(adminUser) {
            // Create PDO where Partner Account = partnerAccount
             
        
            PRM_Partner_Deal_Opportunity__c partnerPDO =
                new PRM_Partner_Deal_Opportunity__c(
                    Name = 'Test Partner PDO',
                    PRM_Partner_Account__c = newAccount.Id
                );

            // Create PDO where End Customer Account = endCustomerAccount
            PRM_Partner_Deal_Opportunity__c endCustomerPDO =
                new PRM_Partner_Deal_Opportunity__c(
                    Name = 'Test End Customer PDO',
                    PRM_End_Customer_Account__c = newAccount1.Id
                );

            // Create PDO where both lookups are populated
            PRM_Partner_Deal_Opportunity__c bothAccountsPDO =
                new PRM_Partner_Deal_Opportunity__c(
                    Name = 'Test Both Accounts PDO',
                    PRM_Partner_Account__c = newAccount.Id,
                    PRM_End_Customer_Account__c = newAccount1.Id
                );

            insert new List<PRM_Partner_Deal_Opportunity__c>{
                partnerPDO,
                endCustomerPDO,
                bothAccountsPDO
            };
        }
    }


    @IsTest
    static void testAccountTeamMemberCreatesPDOAccess() {
        List<AccountTeamMember> atmList = New List<AccountTeamMember>();
        Account partnerAccount = [SELECT Id FROM Account WHERE Name = 'John Rick' LIMIT 1];
        User teamMember = [SELECT Id FROM User WHERE Alias = 'tteam' LIMIT 1];

        Test.startTest();

        AccountTeamMember atm = new AccountTeamMember(
        AccountId = partnerAccount.Id,
            UserId = teamMember.Id,
            AccountAccessLevel = 'Read'
        );

        insert atm;

        
        List<PRM_Partner_Deal_Opportunity__Share> shares = [SELECT Id,ParentId,UserOrGroupId,AccessLevel,RowCause FROM PRM_Partner_Deal_Opportunity__Share WHERE UserOrGroupId = :teamMember.Id AND RowCause = 'Account_Team_Access__c'];
        
        
        Test.stopTest();

        //System.assert(shares.size() > 0,'Expected PDO sharing records to be created.');

    }


    @IsTest
    static void testRevokePDOSharingWhenAccountTeamMemberRemoved() {

        List<AccountTeamMember> atmList = New List<AccountTeamMember>();
        List<PRM_Partner_Deal_Opportunity__c> pdoList = New List<PRM_Partner_Deal_Opportunity__c>();
        Account partnerAccount = [SELECT Id FROM Account WHERE Name = 'John Rick' LIMIT 1];
        User teamMember = [SELECT Id FROM User WHERE Alias = 'tteam' LIMIT 1];
        PRM_Partner_Deal_Opportunity__c partnerPDO = [ SELECT Id,PRM_Partner_Account__c,PRM_End_Customer_Account__c FROM PRM_Partner_Deal_Opportunity__c WHERE Name = 'Test Partner PDO' LIMIT 1 ];
        pdoList.add(partnerPDO);
        
        AccountTeamMember atm = new AccountTeamMember(
        AccountId = partnerAccount.Id,
            UserId = teamMember.Id,
            AccountAccessLevel = 'Read'
        );
        atmList.add(atm);
        insert atmList;
        PRM_PartnerDealOpportunitySharingService.removeShares(atmList);
        //PRM_PartnerDealOpportunitySharingService.createSharesForNewOpportunities(pdoList);
    }
    @IsTest
    static void testAasignSharingToPDO() {
        Id newOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_Design_Opportunity' limit 1][0].Id;
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get(System.Label.PRM_Intel_Account_Record_Type).getRecordTypeId();
        Map<Id,PRM_Partner_Deal_Opportunity__c> pdoMap = New Map<Id,PRM_Partner_Deal_Opportunity__c>();
        List<AccountTeamMember> atmList = New List<AccountTeamMember>();
        List<Opportunity> oppList = new List<Opportunity>();
        List<PRM_Partner_Deal_Opportunity__c> pdoList = New List<PRM_Partner_Deal_Opportunity__c>();
        List<PRM_Partner_Deal_Opportunity__c> otherPdoList = New List<PRM_Partner_Deal_Opportunity__c>();
        set<Id> opptyId = New Set<Id>();
        Profile pf = [select Id from Profile where Name = 'IT Admin'];
        User OSOOwner = new User(Alias = 'OSOOwner', Email='OSOOwner@apttus.com',
                               EmailEncodingKey='UTF-8', LastName='TTest', LanguageLocaleKey='en_US',
                               LocaleSidKey='en_US', ProfileId = pf.Id,
                               TimeZoneSidKey='America/Los_Angeles', UserName='OSOOwner@mail.com', Department='OSC', Core_User_Geo__c = 'PRC');
        insert OSOOwner;
        Account partnerAccount = [SELECT Id FROM Account WHERE Name = 'John Rick' LIMIT 1];
        Account endCustomerAccount = [SELECT Id FROM Account WHERE Name = 'Test 2' LIMIT 1];
        User teamMember = [SELECT Id FROM User WHERE Alias = 'tteam' LIMIT 1];
        Opportunity opp = new Opportunity(Name = 'Test Opportunity1', RecordTypeId = newOppRecTypeId,
                                                  AccountId = partnerAccount.Id, StageName = 'Qualify', CloseDate = System.Date.today().addYears(1),Opportunity_Focus__c='Core',Core_Opportunity_Type__c = 'Design: Software-enable');
                                                  
        Opportunity opp1 = new Opportunity(Name = 'Test Opportunity2', RecordTypeId = newOppRecTypeId,
                                                  AccountId = partnerAccount.Id, StageName = 'Qualify', CloseDate = System.Date.today().addYears(1),Opportunity_Focus__c='Core',Core_Opportunity_Type__c = 'Design: Software-enable');
        
        oppList.add(opp);
        oppList.add(opp1);
        insert oppList;
        for( Opportunity op :oppList){
            opptyId.add(op.Id);
        }
        
        
        AccountTeamMember atm = new AccountTeamMember(
        AccountId = partnerAccount.Id,
            UserId = teamMember.Id,
            AccountAccessLevel = 'Read'
        );
        AccountTeamMember atm1 = new AccountTeamMember(
        AccountId = endCustomerAccount.Id,
            UserId = OSOOwner.Id,
            AccountAccessLevel = 'Read'
        );
        atmList.add(atm);
        atmList.add(atm1);
        insert atmList;
        
        
        // Create a User who will be added to Account Team
        Profile p = [
            SELECT Id
            FROM Profile
            WHERE Name = 'System Administrator'
            LIMIT 1
        ];
        User adminUser = new User(
            FirstName = 'Admin',
            LastName = 'Member',
            Alias = 'tteam',
            Email = 'test.teammember' + System.currentTimeMillis() + '@example.com',
            Username = 'test.teammember' + System.currentTimeMillis() + '@example.com',
            ProfileId = p.Id,
            TimeZoneSidKey = 'Asia/Kolkata',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert adminUser;
        
        System.runAs(adminUser) {
            PRM_Partner_Deal_Opportunity__c partnerPDO =
                new PRM_Partner_Deal_Opportunity__c(
                    Name = 'Test Partner PDO',
                    PRM_Partner_Account__c = partnerAccount.Id,
                    PRM_End_Customer_Account__c = endCustomerAccount.Id,
                    PRM_Sales_Opportunity__c = oppList[0].Id
                    
                );
            //pdoMap.put(partnerPDO.Id,partnerPDO);
            //partnerPDO.PRM_Sales_Opportunity__c = oppList[0].Id;
            insert new List<PRM_Partner_Deal_Opportunity__c>{
                partnerPDO
            };
            pdoMap.put(partnerPDO.Id,partnerPDO);
            partnerPDO.PRM_Sales_Opportunity__c = oppList[1].Id;
            partnerPDO.PRM_End_Customer_Account__c = null;
            update partnerPDO;
            pdoList.add(partnerPDO);
            otherPdoList.add(partnerPDO);
            partnerAccount.OwnerId =  OSOOwner.Id;
            update partnerAccount;
            
        }
        PRM_PartnerDealOpportunitySharingService.createSharesForNewOpportunities(pdoList);
        PRM_PartnerDealOpportunitySharingService.shareWithOpportunityOwner(pdoList,pdoMap);
        PRM_PartnerDealOpportunitySharingService.updateOpportunityOwnerSharing(opptyId);
        PRM_PartnerDealOpportunitySharingService.handleEndCustomerAccountChange(pdoList,pdoMap);
    }
}