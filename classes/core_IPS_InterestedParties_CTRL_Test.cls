@isTest
public class core_IPS_InterestedParties_CTRL_Test {
    static testmethod void core_IPS_InterestedPartiesTestMethod() {
     /*  Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        
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
        Set<Id> activeContactIds = new Set<Id>();
        activeContactIds.add(cc2.Id);
        
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
        List<Core_IPS_Case_Interested_Party__c> Iparty = new List<Core_IPS_Case_Interested_Party__c>(); 
        
        Core_IPS_Case_Interested_Party__c party = new Core_IPS_Case_Interested_Party__c();
        party.Contact__c = cc.id;
        party.Case__c = cas.id;
        //party.User__c=usr.id;
        Iparty.add(party);
        List<Id> addIdList = new List<Id>();
        addIdList.add(party.Id);
           
        Core_IPS_Case_Interested_Party__c party1 = new Core_IPS_Case_Interested_Party__c();
        party1.Contact__c = cc1.id;
        party1.Case__c = cas.id;
        //party1.User__c=usr1.id;
        Iparty.add(party1);   
        insert Iparty;
        List<Id> removeIdList = new List<Id>();
        removeIdList.add(party.Id);
        core_Ips_InterestedParties_CTRL.core_Ips_InterestedParties_CTRL1(cas1.id);
        core_Ips_InterestedParties_CTRL.addOrRemovePartyMembers(addIdList, removeIdList, cas1.id);
        core_Ips_InterestedParties_CTRL Cipc=new core_Ips_InterestedParties_CTRL();
        core_Ips_InterestedParties_CTRL.IPWrapper testwrapper=new  core_Ips_InterestedParties_CTRL.IPWrapper(cc,usr);
        core_Ips_InterestedParties_CTRL.LinkedExtPartyWrapper testwrapper1=new   core_Ips_InterestedParties_CTRL.LinkedExtPartyWrapper(cc.Id,usr.Id,usr.FirstName,usr.LastName,usr.Email,newAccount.id,true,null,party);
        core_Ips_InterestedParties_CTRL.ContactDataRetrieve ccdr= new core_Ips_InterestedParties_CTRL.ContactDataRetrieve();
        ccdr.saveRecords(Iparty);
        ccdr.deleteRecords(Iparty);
        core_Ips_InterestedParties_CTRL.externalPartiesData(cas1,'mip',cas1.Id );
        core_Ips_InterestedParties_CTRL.getActiveContacts(activeContactIds, newAccount.Id);
		core_Ips_InterestedParties_CTRL.addPartyMem(addIdList, cas1.id);
       	core_Ips_InterestedParties_CTRL.removePartyMem(removeIdList, cas1.id); 
        try{
        	Cipc.simpleSort(); 
            
        }catch(Exception e){
            System.debug('Exception '+e);
        }
        
       // List<String> sQuery = new List<String>();
       //core_Ips_InterestedParties_CTRL.ContactDataRetrieve ccdr= new core_Ips_InterestedParties_CTRL.ContactDataRetrieve();
        //sQuery = [SELECT Id, FirstName, LastName, Name, Email, AccountId, Account.Name FROM Contact WHERE AccountID =: newAccount.id]; 
        //ccdr.saveRecords(Iparty);
        //ccdr.deleteRecords(Iparty);
      //  ccdr.getActiveContactsNoSharing(addIdList,newAccount.id);
        //Cipc.IPWrapper(cc,usr1);   
        Test.StopTest();   */
          Case cas = new Case(Status ='New', Priority = 'Medium', Origin = 'Email'); 
        insert cas;
		
		// Set the parameter id with the created case id.
        ApexPages.currentPage().getparameters().put('id', cas.Id);
        core_Ips_InterestedParties_CTRL.core_Ips_InterestedParties_CTRL1(cas.id);
        

}
}