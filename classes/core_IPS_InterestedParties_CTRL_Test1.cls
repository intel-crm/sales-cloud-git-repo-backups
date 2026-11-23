@isTest
public class core_IPS_InterestedParties_CTRL_Test1 {
    static testmethod void core_IPS_InterestedPartiesTestMethod() {
       Test.startTest(); 
        Core_IPS_Labels__c labels1 = new Core_IPS_Labels__c();
            labels1.name= 'IPS Standard Entitlement';
            labels1.value__c='IPS Standard Entitlement';
        	insert labels1;
        System.assert(labels1.Id != null, 'Record not created');

        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        //User userDetails =[select Id,FirstName, LastName, Email from User limit 1];
       
        User usr = new User(LastName = 'LIVESTON1',
                            FirstName='JASON1',
                            Alias = 'jliv1',
                            Email = 'jason1.livesto@example.com',
                            Username = 'jason1.liveston'+Crypto.getRandomLong()+'@asdf.com',
                            ProfileId = profileId.id,
                            TimeZoneSidKey = 'GMT',
                            LanguageLocaleKey = 'en_US',
                            EmailEncodingKey = 'UTF-8',
                            LocaleSidKey = 'en_US'
                           );
		insert usr;
        System.assert(usr.Id != null, 'Record not created');

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
          //  Core_IPS_Active__c=true,
            Core_IPS_Email_Opt_Out__c=false,
            MailingState = newAccount.BillingState,
            MailingCity=newAccount.BillingCity,
            MailingPostalCode=newAccount.BillingPostalCode,
            MailingCountry = newAccount.BillingCountry,
            Phone=newAccount.Phone);
        insert cc;
       System.assert(cc.Id != null, 'Record not created');

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
        cas.AccountId=newAccount.Id;
        caselst.add(cas);
        
        Case cas1 = new Case();          
       // cas1.Core_IPS_Project_Case__c = pr.id;
        cas1.status = 'open'; 
        cas1.AccountId=newAccount.Id;
        caselst.add(cas1);
        
        insert caselst;  
        System.assert(caselst[0].Id != null, 'Record not created');

        List<Core_IPS_Case_Interested_Party__c> Iparty = new List<Core_IPS_Case_Interested_Party__c>(); 
        
        Core_IPS_Case_Interested_Party__c party = new Core_IPS_Case_Interested_Party__c();
        party.User__c = usr.id;
        party.Case__c = cas.id;
        party.Contact__c=cc.id;
        party.Active__c= true ;
        party.Type__c= 'External';
        Iparty.add(party);
             
        Core_IPS_Case_Interested_Party__c party1 = new Core_IPS_Case_Interested_Party__c();
        party1.User__c = usr.id;
        party1.Case__c = cas1.id;
        party1.Contact__c=cc.id;
        Iparty.add(party1);   
        insert Iparty;
        System.assert(Iparty[0].Id != null, 'Record not created');

        List<Core_IPS_Project_Member__c> Pmem = new List<Core_IPS_Project_Member__c>();
                
        Core_IPS_Project_Member__c mem = new Core_IPS_Project_Member__c();
        mem.Core_IPS_Project__c = pr.id;
        mem.Core_User__c = usr.id;
        mem.Core_IPS_Contact__c = cc.id;
        mem.Core_Status__c='Active';
        mem.Core_IPS_Project__c=cas.Core_IPS_Project_Case__c;
        
        
        Pmem.add(mem);
        
        //Core_IPS_Project__c =: CaseObj.Core_IPS_Project_Case__c AND Core_Status__c = 'Active' 
        //AND Core_IPS_Contact__r.Core_IPS_Active__c = true AND Core_IPS_Contact__r.Core_IPS_Email_Opt_Out__c=false
        Core_IPS_Project_Member__c mem1 = new Core_IPS_Project_Member__c();
        mem1.Core_IPS_Project__c = cas.id;
        mem1.Core_User__c = usr.id;
        mem1.Core_IPS_Contact__c = cc.id;
        mem1.Core_Status__c='Active';
        mem1.Core_Status__c='Active';
        mem1.Core_IPS_Project__c=cas.Core_IPS_Project_Case__c;
        Pmem.add(mem1);  
        
        insert Pmem;
        System.assert(Pmem[0].Id != null, 'Record not created');

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

         Contact cc2 = new Contact(  
            
            FirstName='Joe2',
            LastName='Schmoe2',
            Email='Joe.Schmoe2@test.de',
            AccountId=newAccount.id,
            MailingStreet=newAccount.BillingStreet,
            MailingState = newAccount.BillingState,
            MailingCity=newAccount.BillingCity,
            MailingPostalCode=newAccount.BillingPostalCode,
            MailingCountry = newAccount.BillingCountry,
            Phone=newAccount.Phone);
        insert cc2;
        System.assert(cc2.Id != null, 'Record not created');

        Contact cc3 = new Contact(  
            
            FirstName='Joe3',
            LastName='Schmoe3',
            Email='Joe.Schmoe3@test.de',
            AccountId=newAccount.id,
            MailingStreet=newAccount.BillingStreet,
            MailingState = newAccount.BillingState,
            MailingCity=newAccount.BillingCity,
            MailingPostalCode=newAccount.BillingPostalCode,
            MailingCountry = newAccount.BillingCountry,
            Phone=newAccount.Phone);
        insert cc3;
        System.assert(cc3.Id != null, 'Record not created');

         List<Id> addIdList = new List<Id>();
        addIdList.add(cc1.Id);
        addIdList.add(cc2.Id);
        List<Id> removeIdList = new List<Id>();
        removeIdList.add(cc3.Id);
        List<Id> addIdList1 = new List<Id>();
        addIdList1.add(cc1.Id);
        addIdList1.add(cc2.Id);
        List<Id> removeIdList1 = new List<Id>();
        removeIdList1.add(cc3.Id);
        set<Id> removeIdList2 = new set<Id>();
        removeIdList2.add(cc3.Id);
        core_Ips_InterestedParties_CTRL.core_Ips_InterestedParties_CTRL1(caselst[0].id);
        core_Ips_InterestedParties_CTRL.core_Ips_InterestedParties_CTRL1(caselst[1].id);
        core_Ips_InterestedParties_CTRL.addOrRemovePartyMembers(addIdList, removeIdList, caselst[0].id);
        core_Ips_InterestedParties_CTRL.addOrRemovePartyMembers(removeIdList1,addIdList1, caselst[0].id);
        core_Ips_InterestedParties_CTRL.ContactDataRetrieve ccdr= new core_Ips_InterestedParties_CTRL.ContactDataRetrieve();
        ccdr.getActiveContactsNoSharing(removeIdList2,newAccount.id);
        ccdr.getActiveContactsNoSharing(removeIdList2,NULL);
        ccdr.getActiveContactsNoSharing(NULL,newAccount.id);
        
        //core_Ips_InterestedParties_CTRL Cipc=new core_Ips_InterestedParties_CTRL();
        
       // Cipc.simpleSort(caselst[0].id);
        core_Ips_InterestedParties_CTRL Cipc=new core_Ips_InterestedParties_CTRL();
        try{
        	Cipc.simpleSort(); 
            
        }catch(Exception e){
        }
        
        
        //core_IPS_InterestedParties.interestedParties_IntelSupportTeam(Iparty,);
        Test.StopTest();                   
    }
    
    static testmethod void core_IPS_InterestedPartiesTestMethod1() {
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
         User userDetails =[select Id,FirstName, LastName, Email from User limit 1];
      /*  User usr = new User(LastName = 'LIVESTON',
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
                            );   */               
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

         Contact cc2 = new Contact(  
            
            FirstName='Joe2',
            LastName='Schmoe2',
            Email='Joe.Schmoe2@test.de',
            AccountId=newAccount.id,
            MailingStreet=newAccount.BillingStreet,
            MailingState = newAccount.BillingState,
            MailingCity=newAccount.BillingCity,
            MailingPostalCode=newAccount.BillingPostalCode,
            MailingCountry = newAccount.BillingCountry,
            Phone=newAccount.Phone);
        insert cc2;
        System.assert(cc2.Id != null, 'Record not created');

        Contact cc3 = new Contact(  
            
            FirstName='Joe3',
            LastName='Schmoe3',
            Email='Joe.Schmoe3@test.de',
            AccountId=newAccount.id,
            MailingStreet=newAccount.BillingStreet,
            MailingState = newAccount.BillingState,
            MailingCity=newAccount.BillingCity,
            MailingPostalCode=newAccount.BillingPostalCode,
            MailingCountry = newAccount.BillingCountry,
            Phone=newAccount.Phone);
        insert cc3;
        System.assert(cc3.Id != null, 'Record not created');

        List<Core_IPS_Project_Member__c> Pmem = new List<Core_IPS_Project_Member__c>();
        
        Core_IPS_Project_Member__c mem = new Core_IPS_Project_Member__c();
        mem.Core_IPS_Project__c = pr.id;
        mem.Core_User__c = userDetails.id;
        mem.Core_IPS_Contact__c = cc.id;
        Pmem.add(mem);
        
        Core_IPS_Project_Member__c mem1 = new Core_IPS_Project_Member__c();
        mem1.Core_IPS_Project__c = pr.id;
        mem1.Core_User__c = userDetails.id;
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
       // party.User__c=usr.id;
        Iparty.add(party);
   //   Iparty.add();
        List<Id> addIdList = new List<Id>();
        addIdList.add(party.Id);
       // List<Core_IPS_Case_Interested_Party__c> SaveList = new List<Core_IPS_Case_Interested_Party__c>();
        //SaveList.add(party);
        //insert SaveList; 
           set<Id> addIdListc = new set<Id>();
        addIdListc.add(cc3.Id);
           
        //Core_IPS_Case_Interested_Party__c party1 = new Core_IPS_Case_Interested_Party__c();
        //party1.Contact__c = cc1.id;
       //party1.Case__c = cas.id;
       //party1.User__c=usr1.id;
       //Iparty.add(party1);   
        //insert Iparty;
        List<Id> removeIdList = new List<Id>();
        removeIdList.add(party.Id);
        core_Ips_InterestedParties_CTRL.core_Ips_InterestedParties_CTRL1(cas1.id);
        
        core_Ips_InterestedParties_CTRL Cipc=new core_Ips_InterestedParties_CTRL();
        try{
        	Cipc.simpleSort(); 
            
        }catch(Exception e){
        }
        
        
        //  Cipc.saveRecords(Iparty);
        List<String> sQuery = new List<String>();
        string sQuery1;
       // public  List<Contact> getRecords(String sQuery, Set<ID> ContactID,String searchableString,Set<ID> relatedConatactIDs, Set<ID> allActiveContactIds){            
   
       core_Ips_InterestedParties_CTRL.ContactDataRetrieve ccdr= new core_Ips_InterestedParties_CTRL.ContactDataRetrieve();
        ccdr.getRecords('SELECT Id, Name FROM Contact',addIdListc,'SELECT Name FROM Contact',addIdListc,addIdListc);
        //sQuery = [SELECT Id, FirstName, LastName, Name, Email, AccountId, Account.Name FROM Contact WHERE AccountID =: newAccount.id]; 
        ccdr.saveRecords(Iparty);
        ccdr.deleteRecords(Iparty);
        Set<Id> activeContactIds = new Set<Id>(); 
        activeContactIds.add(cc.id);
        ccdr.getActiveContactsNoSharing(activeContactIds,newAccount.id);
        ccdr.getActiveContactsNoSharing(activeContactIds,NULL);
        ccdr.getActiveContactsNoSharing(NULL,newAccount.id);
        //Cipc.IPWrapper(cc,usr1);   
        Test.StopTest();                   
    }
    
    
    static testmethod void core_IPS_InterestedPartiesTestMethod6() {
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User userDetails =[select Id,FirstName, LastName, Email from User limit 1];
        /*User usr = new User(LastName = 'LIVESTON',
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
                            );     */             
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

        List<Id> contactlst1 = new List<Id>();
        contactlst1.add(cc1.id);
        List<Core_IPS_Project_Member__c> Pmem = new List<Core_IPS_Project_Member__c>();
        
        Core_IPS_Project_Member__c mem = new Core_IPS_Project_Member__c();
        mem.Core_IPS_Project__c = pr.id;
        mem.Core_User__c = userDetails.id;
        mem.Core_IPS_Contact__c = cc.id;
        Pmem.add(mem);
        
        Core_IPS_Project_Member__c mem1 = new Core_IPS_Project_Member__c();
        mem1.Core_IPS_Project__c = pr.id;
        mem1.Core_User__c = userDetails.id;
		//Sowmya cc1 updated instead of cc - Start - 08/10/2024 - TWC745-6800 - Fix test coverage for all failed classes 
        mem1.Core_IPS_Contact__c = cc1.id;
        //Sowmya - End - 08/10/2024 - TWC745-6800 - Fix test coverage for all failed classes 
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
        cas1.ContactId=cc1.id;
        caselst.add(cas1);
        
        insert caselst;
        System.assert(caselst[0].Id != null, 'Record not created');

        List<Core_IPS_Case_Interested_Party__c> Iparty = new List<Core_IPS_Case_Interested_Party__c>(); 
        
        Core_IPS_Case_Interested_Party__c party = new Core_IPS_Case_Interested_Party__c();
        party.Contact__c = cc.id;
        party.Case__c = cas.id;
       // party.Core_IPS_Active_Flag__c=TRUE
        Iparty.add(party);
        List<Id> addIdList = new List<Id>();
        addIdList.add(party.Id);
         //  Select ID, Contact__c,Core_IPS_Account_Name__c, First_Name__c, Email__c, Last_Name__c, User__c, Active__c from Core_IPS_Case_Interested_Party__c
//                                     WHERE Case__c =: CaseId AND Contact__c != null  AND Type__c= 'External' AND Active__c = true
        Core_IPS_Case_Interested_Party__c party1 = new Core_IPS_Case_Interested_Party__c();
        party1.Contact__c = cc1.id;
        
        //Sowmya cas1 updated instead of cas - Start - 08/10/2024 - TWC745-6800 - Fix test coverage for all failed classes 
        party1.Case__c = cas1.id;
        //Sowmya cc1 updated instead of cc - end - 08/10/2024 - TWC745-6800 - Fix test coverage for all failed classes 
        
        // party.Core_IPS_Active_Flag__c=TRUE
        Iparty.add(party1);   
        insert Iparty;
        System.assert(Iparty[0].Id != null, 'Record not created');

        List<Id> removeIdList = new List<Id>();
        removeIdList.add(party1.Id);
     // core_Ips_InterestedParties_CTRL.addPartyMem(addIdList, cas1.id);
       try{
    		core_Ips_InterestedParties_CTRL.removePartyMem(contactlst1, cas1.id); 
         
        }catch(Exception e){
        }
        
       
        //core_Ips_InterestedParties_CTRL.core_Ips_InterestedParties_CTRL1(cas1.id);
        //core_Ips_InterestedParties_CTRL.addOrRemovePartyMembers(addIdList, removeIdList, cas1.id);
        //core_Ips_InterestedParties_CTRL Cipc=new core_Ips_InterestedParties_CTRL();
        //Cipc.simpleSort(); 
        
        //  Cipc.saveRecords(Iparty);
        //Cipc.ContactDataRetrieve();
        //Cipc.IPWrapper(cc,usr1);   
        Test.StopTest();                   
    }
    static testmethod void core_IPS_InterestedPartiesTestMethod7() {
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User userDetails =[select Id,FirstName, LastName, Email from User limit 1];
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
       // party.Core_IPS_Active_Flag__c=TRUE
        Iparty.add(party);
        List<Id> addIdList = new List<Id>();
        addIdList.add(cc.Id);
           
        Core_IPS_Case_Interested_Party__c party1 = new Core_IPS_Case_Interested_Party__c();
        party1.Contact__c = cc1.id;
        party1.Case__c = cas.id;
        // party.Core_IPS_Active_Flag__c=TRUE
        Iparty.add(party1);   
        insert Iparty;
        System.assert(Iparty[0].Id != null, 'Record not created');

        List<Id> removeIdList = new List<Id>();
        removeIdList.add(cc1.Id);
        try{
    		core_Ips_InterestedParties_CTRL.addPartyMem(addIdList, cas.id);
        }catch(Exception e){
        }
         // core_Ips_InterestedParties_CTRL.removePartyMem(removeIdList, cas1.id);
       
        //core_Ips_InterestedParties_CTRL.core_Ips_InterestedParties_CTRL1(cas1.id);
        //core_Ips_InterestedParties_CTRL.addOrRemovePartyMembers(addIdList, removeIdList, cas1.id);
        //core_Ips_InterestedParties_CTRL Cipc=new core_Ips_InterestedParties_CTRL();
        //Cipc.simpleSort(); 
        
        //  Cipc.saveRecords(Iparty);
        //Cipc.ContactDataRetrieve();
        //Cipc.IPWrapper(cc,usr1);   
        Test.StopTest();                   
    }
    
    static testmethod void core_IPS_InterestedPartiesdeleteTestMethod() {
        
        
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User userDetails =[select Id,FirstName,LastName,Account.Id,Contact.Id,Email from User limit 1];
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
            MailingCity= newAccount.BillingCity,
            MailingPostalCode=newAccount.BillingPostalCode,
            MailingCountry = newAccount.BillingCountry,
            Phone=newAccount.Phone);
        insert cc;
        System.assert(cc.Id != null, 'Record not created');

        
        Case cas = new Case();          
        cas.Core_IPS_Project_Case__c = pr.id;
        cas.status = 'open';   
        insert cas;
        System.assert(cas.Id != null, 'Record not created');

        Core_IPS_Project_Member__c mem1 = new Core_IPS_Project_Member__c();
        mem1.Core_IPS_Project__c = pr.id;
        mem1.Core_User__c = usr1.id;
        mem1.Core_IPS_Contact__c =cc.id;
        mem1.Core_Status__c = 'Active';
        insert mem1;     
        List<Core_IPS_Case_Interested_Party__c> interestedPartiesList=new List<Core_IPS_Case_Interested_Party__c>();
        Core_IPS_Case_Interested_Party__c party = new Core_IPS_Case_Interested_Party__c();
        party.Contact__c = cc.id;
        party.Case__c = cas.id;
        insert party;
        System.assert(party.Id != null, 'Record not created');

        interestedPartiesList=[select id from Core_IPS_Case_Interested_Party__c where Case__c =:cas.id AND Contact__c =:cc.id];
        
        delete interestedPartiesList;
        core_Ips_InterestedParties_CTRL.core_Ips_InterestedParties_CTRL1(cas.id);
         core_Ips_InterestedParties_CTRL.IPWrapper testwrapper=new  core_Ips_InterestedParties_CTRL.IPWrapper(cc,usr);
       // core_Ips_InterestedParties_CTRL.LinkedExtPartyWrapper testwrapper1=new   core_Ips_InterestedParties_CTRL.LinkedExtPartyWrapper(cc.Id,usr.Id,usr.FirstName,usr.LastName,usr.Email,newAccount.id,true,null,party);

        core_Ips_InterestedParties_CTRL.LinkedExtPartyWrapper testwrapper1=new   core_Ips_InterestedParties_CTRL.LinkedExtPartyWrapper(cc.Id,usr.Id,usr.FirstName,usr.LastName,usr.Email,newAccount.id,true,null,party);
	     // public LinkedExtPartyWrapper(Id conId ,Id usrId ,String fname ,String lname ,String emailId , Id recId ,Boolean isChecked,Contact conRec , Core_IPS_Case_Interested_Party__c ipRec){
        //      contactId = conId;            userId = usrId;            firstName = fname;            lastName = lname;            email = emailId;            recordId = recId;            isSelected = isChecked;            con = conRec;            ipRecord = ipRec;
         // }
        //core_Ips_InterestedParties_CTRL Cipc=new core_Ips_InterestedParties_CTRL();
       // Cipc.simpleSort(); 
        
        
        
    }
    @isTest
    public static void getcaseRecordsUnderprojectTest(){
       // User userDetails =[select Id,FirstName,LastName,Account.Id,Contact.Id,Email from User where Account.id != Null limit 1];
        account Acc=new account();
        Acc.Name='test';
        Acc.BillingCity='new york';
        Acc.BillingCountry='united states';
        Acc.BillingCountryCode='';
        Acc.BillingStreet='st 124563 louis street';
        insert Acc;
        System.assert(Acc.Id != null, 'Record not created');

        Contact con=new Contact();
        con.Firstname='test';
        con.lastname='test contact';
        con.Email='test@gmail.com';
        con.AccountId=Acc.Id;
        con.MailingCountry = 'India';
        con.Core_IPS_Email_Opt_Out__c = false;
       //con.Core_IPS_Active__c = True;
     	
        insert con;
        System.assert(con.Id != null, 'Record not created');

        
        Core_IPS_Project__c Project=new Core_IPS_Project__c();
        Project.Name='test project';
        Project.Core_Project_Description__c='test description';
        Project.Core_Status__c='Draft';
        insert Project;
        System.assert(Project.Id != null, 'Record not created');

        Core_IPS_Project_Member__c ProjectMember=new Core_IPS_Project_Member__c();
        ProjectMember.Core_IPS_Project__c=Project.id;
        ProjectMember.Core_Status__c='Active';
        ProjectMember.Core_IPS_Contact__c = con.id;
        insert ProjectMember;
        System.assert(ProjectMember.Id != null, 'Record not created');

        set<Id> lstId = new set<Id>();
        lstId.add(con.Id);   
        asset assetProduct=new asset();
        assetProduct.Name='TestAsset';
        assetProduct.Core_IPS_Project__c=Project.Id;
        insert assetProduct;
        System.assert(assetProduct.Id != null, 'Record not created');

        list<Id> AlstId = new list<Id>();
        AlstId.add(assetProduct.Id);
        Case CaseRec=new Case();
        CaseRec.Subject='Test Demo';
        CaseRec.Status='Open';
        CaseRec.Core_Sub_Status__c='Core_Sub_Status__c';
        CaseRec.Core_Severity__c='Low';
        CaseRec.Core_Severity_Reason__c='Testing case';
        CaseRec.Core_CaseType__c='Question';
        CaseRec.Description='case test description';
        CaseRec.Core_IPS_Restricted_Secret_Content__c=True;
        CaseRec.Core_IPS_Knowledge_Base_Link__c='Case knowledge test';
        CaseRec.Core_IPS_Product_name__c='Test product';
        insert CaseRec;
        System.assert(CaseRec.Id != null, 'Record not created');

       
        Core_IPS_Case_Interested_Party__c partiesObj = new Core_IPS_Case_Interested_Party__c();
        partiesObj.Active__c = true;
        partiesObj.Contact__c = con.Id;
        partiesObj.Case__c = CaseRec.Id;
        partiesObj.Type__c = 'External';
        insert partiesObj;
		System.assert(partiesObj.Id != null, 'Record not created');
        
         Set<Id> activeContactIds = new Set<Id>();
        Account acc1=new Account();
       // activeContactIds.add(userDetails.ContactId);
        ApexPages.currentPage().getparameters().put('id', CaseRec.Id);
        core_Ips_InterestedParties_CTRL.core_Ips_InterestedParties_CTRL1(CaseRec.id);
     //   core_Ips_InterestedParties_CTRL.externalPartiesData(CaseRec,'mip',CaseRec.Id );
        core_Ips_InterestedParties_CTRL.getActiveContacts(Null,Acc.Id);
        core_Ips_InterestedParties_CTRL.getActiveContacts(lstId,NULL);
        core_Ips_InterestedParties_CTRL.doSearch(CaseRec);
        //core_Ips_InterestedParties_CTRL Cipc=new core_Ips_InterestedParties_CTRL();
        //Cipc.simpleSort();
        
        
        
        
       
    }
    
}