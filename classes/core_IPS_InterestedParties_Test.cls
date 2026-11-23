@istest
public class core_IPS_InterestedParties_Test {
    static testmethod void core_IPS_InterestedPartiesTestMethod() {
       Test.startTest(); 
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        
        User usr = new User(LastName = 'LIVESTON',
                           FirstName='JASON',
                           Alias = 'jliv',
                           Email = 'jason.liveston@asdf.com',
                           Username = 'jason.liveston@asdf.com',
                           ProfileId = profileId.id,
                           TimeZoneSidKey = 'GMT',
                           LanguageLocaleKey = 'en_US',
                           EmailEncodingKey = 'UTF-8',
                           LocaleSidKey = 'en_US'
                           );
          User usr1 = new User(LastName = 'LIVESTON',
                           FirstName='JASON',
                           Alias = 'jliv',
                           Email = 'jason.liveston@asdf.com',
                           Username = 'jason.liveston@asdf.com',
                           ProfileId = profileId.id,
                           TimeZoneSidKey = 'GMT',
                           LanguageLocaleKey = 'en_US',
                           EmailEncodingKey = 'UTF-8',
                           LocaleSidKey = 'en_US'
                           );                  
                         
         Core_IPS_Project__c pr = new Core_IPS_Project__c();
             pr.name = 'test';
             pr.Core_IPS_Enable_ISTasInterested_Parties__c = True;
             pr.Core_IPS_EnableMemberasInterestedParties__c =True;
          insert pr;   
          System.assert(pr.Id != null, 'Record not created');
        
         
         Core_IPS_Intel_Support_Team__c steam = new Core_IPS_Intel_Support_Team__c();
             steam.Core_IPS_Project__c = pr.id;   
             steam.Status__c='Active';
             steam.Core_IPS_User__c=usr.id;           
          insert steam;
          System.assert(steam.Id != null, 'Record not created');
        
        Map<Id,Core_IPS_Intel_Support_Team__c> mapTeam = new Map<Id,Core_IPS_Intel_Support_Team__c>();
           // mapTeam.put(id,pr.id);  
             
         List<Case> caselst = new List<Case>();
          
         Case cas = new Case();          
           cas.Core_IPS_Project_Case__c = pr.id;
           cas.status = 'open';   
           caselst.add(cas);
                    
         Case cas1 = new Case();          
           cas1.Core_IPS_Project_Case__c = pr.id;
           cas1.status = 'open';   
           caselst.add(cas1);
           
         insert caselst;  
         System.assert(caselst[0].Id != null, 'Record not created');
         
      List<Core_IPS_Case_Interested_Party__c> Iparty = new List<Core_IPS_Case_Interested_Party__c>(); 
          
         Core_IPS_Case_Interested_Party__c party = new Core_IPS_Case_Interested_Party__c();
             party.User__c = usr.id;
             party.Case__c = cas.id;
             Iparty.add(party);
           
         Core_IPS_Case_Interested_Party__c party1 = new Core_IPS_Case_Interested_Party__c();
             party1.User__c = usr.id;
             party1.Case__c = cas1.id;
             Iparty.add(party1);   
          insert Iparty;
          System.assert(Iparty[0].Id != null, 'Record not created');
         
            
           //core_IPS_InterestedParties.interestedParties_IntelSupportTeam(Iparty,);
       Test.StopTest();                   
    }
    
    static testmethod void core_IPS_InterestedPartiesTestMethod1() {
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        
        User usr = new User(LastName = 'LIVESTON',
                           FirstName='Rakesh',
                           Alias = 'jliv',
                           Email = 'jason.liveston@asdf.com',
                           Username = 'jason.liveston@asdf.com',
                           ProfileId = profileId.id,
                           TimeZoneSidKey = 'GMT',
                           LanguageLocaleKey = 'en_US',
                           EmailEncodingKey = 'UTF-8',
                           LocaleSidKey = 'en_US'
                           );
          User usr1 = new User(LastName = 'Rakesh Marka',
                           FirstName='JASON',
                           Alias = 'jliv',
                           Email = 'jason.liveston@asdf.com',
                           Username = 'jason.liveston@asdf.com',
                           ProfileId = profileId.id,
                           TimeZoneSidKey = 'GMT',
                           LanguageLocaleKey = 'en_US',
                           EmailEncodingKey = 'UTF-8',
                           LocaleSidKey = 'en_US'
                           );                  
      Test.startTest();                      
         Core_IPS_Project__c pr = new Core_IPS_Project__c();
             pr.name = 'test';
             pr.Core_IPS_Enable_ISTasInterested_Parties__c = True;
             pr.Core_IPS_EnableMemberasInterestedParties__c =True;
          insert pr;  
          System.assert(pr.Id != null, 'Record not created');
        
          
        Account newAccount = new Account (
            name='XYZ',
            Phone = '+49-12345',
            BillingStreet = 'Am Tierpark 16',
            BillingCity = 'Fremont',
            BillingPostalCode = '54321',
            BillingState = 'CA',
            BillingCountry = 'USA'
            );
        
      insert newAccount;        
      System.assert(newAccount.Id != null, 'Record not created');
             
    Contact cc = new Contact(  
     
                FirstName='Joe',
                LastName='Schmoe',
                Email='Joe.Schmoe@test.de',
                AccountId=newAccount.id,
                MailingStreet=newAccount.BillingStreet,
                MailingState = newAccount.BillingState,
                MailingCity=newAccount.BillingCity,
                MailingPostalCode=newAccount.BillingPostalCode,
                MailingCountry = newAccount.BillingCountry,
                Phone=newAccount.Phone);
                insert cc;
        System.assert(cc.Id != null, 'Record not created');
        
    Contact cc1 = new Contact(  
     
                FirstName='Joe1',
                LastName='Schmoe1',
                Email='Joe.Schmoe1@test.de',
                AccountId=newAccount.id,
                MailingStreet=newAccount.BillingStreet,
                MailingState = newAccount.BillingState,
                MailingCity=newAccount.BillingCity,
                MailingPostalCode=newAccount.BillingPostalCode,
                MailingCountry = newAccount.BillingCountry,
                Phone=newAccount.Phone);
                insert cc1;
				System.assert(cc1.Id != null, 'Record not created');
        
           
        List<Core_IPS_Project_Member__c> Pmem = new List<Core_IPS_Project_Member__c>();
         
         Core_IPS_Project_Member__c mem = new Core_IPS_Project_Member__c();
             mem.Core_IPS_Project__c = pr.id;
             mem.Core_User__c = usr.id;
             mem.Core_IPS_Contact__c = cc.id;
             Pmem.add(mem);
             
         Core_IPS_Project_Member__c mem1 = new Core_IPS_Project_Member__c();
             mem1.Core_IPS_Project__c = pr.id;
             mem1.Core_User__c = usr1.id;
             mem1.Core_IPS_Contact__c = cc.id;
             Pmem.add(mem1);  
               
        insert Pmem;
        System.assert(Pmem[0].Id != null, 'Record not created');
        
           
         List<Case> caselst = new List<Case>();
         
         Case cas = new Case();          
           cas.Core_IPS_Project_Case__c = pr.id;
           cas.status = 'open';   
           caselst.add(cas);
                    
         Case cas1 = new Case();          
           cas1.Core_IPS_Project_Case__c = pr.id;
           cas1.status = 'open';   
           caselst.add(cas1);
           
         insert caselst;  
        System.assert(caselst[0].Id != null, 'Record not created');
        
      List<Core_IPS_Case_Interested_Party__c> Iparty = new List<Core_IPS_Case_Interested_Party__c>(); 
          
         Core_IPS_Case_Interested_Party__c party = new Core_IPS_Case_Interested_Party__c();
             party.Contact__c = cc.id;
             party.Case__c = cas.id;
             Iparty.add(party);
           
         Core_IPS_Case_Interested_Party__c party1 = new Core_IPS_Case_Interested_Party__c();
             party1.Contact__c = cc1.id;
             party1.Case__c = cas.id;
             Iparty.add(party1);   
          insert Iparty;
           System.assert(Iparty[0].Id != null, 'Record not created');
                   
           
       Test.StopTest();                   
    }
    
    static testmethod void core_IPS_InterestedPartiesdeleteTestMethod() {
    
    
    Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        
        User usr = new User(LastName = 'LIVESTON',
                           FirstName='Rakesh',
                           Alias = 'jliv',
                           Email = 'jason.liveston@asdf.com',
                           Username = 'jason.liveston@asdf.com',
                           ProfileId = profileId.id,
                           TimeZoneSidKey = 'GMT',
                           LanguageLocaleKey = 'en_US',
                           EmailEncodingKey = 'UTF-8',
                           LocaleSidKey = 'en_US'
                           );
          User usr1 = new User(LastName = 'Rakesh Marka',
                           FirstName='JASON',
                           Alias = 'jliv',
                           Email = 'jason.liveston@asdf.com',
                           Username = 'jason.liveston@asdf.com',
                           ProfileId = profileId.id,
                           TimeZoneSidKey = 'GMT',
                           LanguageLocaleKey = 'en_US',
                           EmailEncodingKey = 'UTF-8',
                           LocaleSidKey = 'en_US'
                           );                  
      Test.startTest();                      
         Core_IPS_Project__c pr = new Core_IPS_Project__c();
             pr.name = 'test';
             pr.Core_IPS_Enable_ISTasInterested_Parties__c = False;
             pr.Core_IPS_EnableMemberasInterestedParties__c =False;
          insert pr;
          System.assert(pr.Id != null, 'Record not created');
        
    
        Account newAccount = new Account (
            name='XYZ',
            Phone = '+49-12345',
            BillingStreet = 'Am Tierpark 16',
            BillingCity = 'Fremont',
            BillingPostalCode = '54321',
            BillingState = 'CA',
            BillingCountry = 'USA'
            );
        
      insert newAccount;        
      System.assert(newAccount.Id != null, 'Record not created');
             
    Contact cc = new Contact(  
     
                FirstName='Joe',
                LastName='Schmoe',
                Email='Joe.Schmoe@test.de',
                AccountId=newAccount.id,
                MailingStreet=newAccount.BillingStreet,
                MailingState = newAccount.BillingState,
                MailingCity=newAccount.BillingCity,
                MailingPostalCode=newAccount.BillingPostalCode,
                MailingCountry = newAccount.BillingCountry,
                Phone=newAccount.Phone);
                insert cc;
            
            
            Case cas = new Case();          
               cas.Core_IPS_Project_Case__c = pr.id;
               cas.status = 'open';   
             insert cas;
             System.assert(cas.Id != null, 'Record not created');
        
            Core_IPS_Project_Member__c mem1 = new Core_IPS_Project_Member__c();
             mem1.Core_IPS_Project__c = pr.id;
             //mem1.Core_User__c = usr1.id;
             mem1.Core_IPS_Contact__c =cc.id;
             
          insert mem1; 
        	System.assert(mem1.Id != null, 'Record not created');
        
    List<Core_IPS_Case_Interested_Party__c> interestedPartiesList=new List<Core_IPS_Case_Interested_Party__c>();
    Core_IPS_Case_Interested_Party__c party = new Core_IPS_Case_Interested_Party__c();
             party.Contact__c = cc.id;
             party.Case__c = cas.id;
          insert party;
          System.assert(party.Id != null, 'Record not created');
        
    interestedPartiesList=[select id from Core_IPS_Case_Interested_Party__c where Case__c =:cas.id AND Contact__c =:cc.id];
    
    delete interestedPartiesList;
    
    }
    
}