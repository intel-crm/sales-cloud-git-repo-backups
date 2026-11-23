@isTest
public with sharing class UCD_AccountDeactivation_Test {
    //Start date greater than end date
    @isTest static void GetDeactivateAccts_Test_a()
    {
        String sDate = '2020-09-25 00:00:00';
        String eDate = '2020-09-22 00:00:00';
        DateTime startDate = DateTime.valueOf(sDate); 
        DateTime endDate = DateTime.valueOf(eDate); 
        List<Account> accts = UCD_AccountDeactivation.GetDeactivateAccts(startDate, endDate);
        System.assertEquals(0, accts.size());
    }

    //Insert 2 accounts withoin the date range
    @isTest static void GetDeactivateAccts_Test_b()
    {
        
        DateTime startDate = DateTime.Now().AddDays(-2);
        DateTime endDate = DateTime.Now().AddDays(1);
        List<Account> accts = UCD_AccountDeactivation.GetDeactivateAccts(startDate, endDate);
        Integer countBefore = accts.size();
        Integer insertCount=2;
        Id intelAccountRecordType = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        
        User u = [Select id from User where alias =: System.Label.PRM_UncoveredAccount];
        // insert 2 new Accounts within date range
        List<Account> accs = new List<Account>();
                
        for (Integer i = 0; i < insertCount; i++) {
            Account a = new Account();
            a.Name = 'Test Account'+i;  
            a.Core_PSG_Account__c = false;
            a.Core_Intel_Partner_Alliance_PartnerGroup__c = false;
            a.BillingStreet = 'Test street';
            a.BillingCity = 'Bengaluru';
            a.BillingCountry = 'IND';
            a.RecordTypeId = intelAccountRecordType;
            if(u != null) { a.OwnerId  = u.id ; }
            accs.add(a);
        }
        insert accs;
        accts = UCD_AccountDeactivation.GetDeactivateAccts(startDate, endDate);
        System.assertEquals(countBefore+insertCount, accts.size());
        
    
    }

    //Add note to account
    @isTest static void GetDeactivateAccts_Test_c()
    {
        DateTime startDate = DateTime.Now().AddDays(-2);
        DateTime endDate = DateTime.Now().AddDays(1);
        List<Account> accts = UCD_AccountDeactivation.GetDeactivateAccts(startDate, endDate);
        Integer countBefore = accts.size();
        Id intelAccountRecordType = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        
        User u = [Select id from User where alias =: System.Label.PRM_UncoveredAccount];

        Account a = new Account();
        a.Name = 'Test Account CSK';  
        a.Core_PSG_Account__c = false;
        a.Core_Intel_Partner_Alliance_PartnerGroup__c = false;
        a.BillingStreet = 'Test street';
        a.BillingCity = 'Bengaluru';
        a.BillingCountry = 'IND';
        a.RecordTypeId = intelAccountRecordType;
        if(u != null) { a.OwnerId  = u.id ; }
        insert a;

        ContentNote conNote = new ContentNote(
           Title = 'TheBlogReaders.com',
           Content = Blob.valueOf('TheBlogReaders.com')
         );
        insert conNote;
        ContentDocumentLink conDocLink = New ContentDocumentLink();
        conDocLink.LinkedEntityId = a.id;
        conDocLink.ContentDocumentId = conNote.Id;
        conDocLink.shareType = 'V';
        insert conDocLink;
        accts = UCD_AccountDeactivation.GetDeactivateAccts(startDate, endDate);
        System.assertEquals(countBefore, accts.size());
    } 

    //Add event to account
    @isTest static void GetDeactivateAccts_Test_d()
    {
       
        DateTime startDate = DateTime.Now().AddDays(-2);
        DateTime endDate = DateTime.Now().AddDays(1);
        List<Account> accts = UCD_AccountDeactivation.GetDeactivateAccts(startDate, endDate);
        Integer countBefore = accts.size();
        Id intelAccountRecordType = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        
        User u = [Select id from User where alias =: System.Label.PRM_UncoveredAccount];

        Account a = new Account();
        a.Name = 'Test Account CSK';  
        a.Core_PSG_Account__c = false;
        a.Core_Intel_Partner_Alliance_PartnerGroup__c = false;
        a.BillingStreet = 'Test street';
        a.BillingCity = 'Bengaluru';
        a.BillingCountry = 'IND';
        a.RecordTypeId = intelAccountRecordType;
        if(u != null) { a.OwnerId  = u.id ; }
        insert a;

        Event event = new Event();
        if(u != null) { event.OwnerId  = u.id ; }
        event.WhatId = a.Id;
        event.StartDateTime = startDate;
        event.EndDateTime = endDate;
        event.ActivityDateTime = startDate;
        event.Subject = 'Test Event';
        insert event;

        accts = UCD_AccountDeactivation.GetDeactivateAccts(startDate, endDate);
        System.assertEquals(countBefore, accts.size());   
           
    } 

    //Deactivate single account
    @isTest static void DeactivateSingleAcct_Test_a()
    {
        Id intelAccountRecordType = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        User u = [Select id from User where alias =: System.Label.PRM_UncoveredAccount];
        Account a = new Account();
        a.Name = 'Test Account CSK';  
        a.Core_PSG_Account__c = false;
        a.Core_Intel_Partner_Alliance_PartnerGroup__c = false;
        a.BillingStreet = 'Test street';
        a.BillingCity = 'Bengaluru';
        a.BillingCountry = 'USA';
        a.RecordTypeId = intelAccountRecordType;
        if(u != null) { a.OwnerId  = u.id ; }
        insert a;
        UCD_AccountDeactivation.DeactivateSingleAcct(a.Id);
        Boolean isAccountDeactivated = [SELECT Id,Core_Deactivated__c FROM Account WHERE Id =: a.Id].Core_Deactivated__c;
        System.assertEquals(isAccountDeactivated, true);
    }

    //Deactivate single account with exception
    @isTest static void DeactivateSingleAcct_Test_b()
    {
        try 
        {
            Account a = new Account();
            UCD_AccountDeactivation.DeactivateSingleAcct(a.Id);
        } catch (Exception e) {
            System.assertEquals(e.getMessage(),'Script-thrown exception');
        }
    }

    //Deactivate 2 accounts
    @isTest static void DeactivateSelectedAccts_Test_a()
    {
        Id intelAccountRecordType = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        User u = [Select id from User where alias =: System.Label.PRM_UncoveredAccount];
        List<Account> accs = new List<Account>();                
        for (Integer i = 0; i < 2; i++) {
            Account a = new Account();
            a.Name = 'Test Account'+i;  
            a.Core_PSG_Account__c = false;
            a.Core_Intel_Partner_Alliance_PartnerGroup__c = false;
            a.BillingStreet = 'Test street';
            a.BillingCity = 'Bengaluru';
            a.BillingCountry = 'IND';
            a.RecordTypeId = intelAccountRecordType;
            if(u != null) { a.OwnerId  = u.id ; }
            accs.add(a);
        }
        insert accs;

        UCD_AccountDeactivation.DeactivateSelectedAccts(accs);
        List<Account> accountsDeactivated = [SELECT Id,Core_Deactivated__c FROM Account WHERE Id IN : accs AND Core_Deactivated__c=false];
        System.assertEquals(0, accountsDeactivated.size());
    }

    //Deactivate accounts with exception
    @isTest static void DeactivateSelectedAccts_Test_b()
    {
        try 
        {
            List<Account> accs = new List<Account>();                
            for (Integer i = 0; i < 2; i++) {
                Account a = new Account();
                accs.add(a);
            }
            UCD_AccountDeactivation.DeactivateSelectedAccts(accs);
        } catch (Exception e) {
            System.assertEquals(e.getMessage(), 'Script-thrown exception');
        }        
    }
}