@isTest
public class Core_IPS_Interested_Party_LEX_Test {
    static testmethod void create(){ 
       
        //Added by Sowmya - Start - 28/10/2024 - TWC745-6800 - Fix test coverage for all failed classes 
        List<Core_IPS_Labels__c> ipslabels = new List<Core_IPS_Labels__c>();
        ipslabels.add(new Core_IPS_Labels__c(Name='Case_RT_Name_IPS_NoAssignedContact',Value__c='IPS No Assigned Contact Case'));
        ipslabels.add(new Core_IPS_Labels__c(Name='RowCause_Team',Value__c='Team'));
        ipslabels.add(new Core_IPS_Labels__c(Name='Rowcause_Owner',Value__c='Owner'));
        ipslabels.add(new Core_IPS_Labels__c(Name='AccessLevel_Read',Value__c='Read'));
        ipslabels.add(new Core_IPS_Labels__c(Name='AccessLevel_Edit',Value__c='Edit'));
        insert ipslabels;
        System.assert(ipslabels[0].Id != null, 'Record not created');
        
       // Sowmya - End - 28/10/2024 - TWC745-6800 - Fix test coverage for all failed classes 
        
        List<Case> caselst = new List<Case>();
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
        
        Core_IPS_Project__c pr = new Core_IPS_Project__c();
        pr.name = 'test';
        pr.Core_IPS_Enable_ISTasInterested_Parties__c = True;
        pr.Core_IPS_EnableMemberasInterestedParties__c =True;
        insert pr;  
        System.assert(pr.Id != null, 'Record not created');
        
        Case cas1 = new Case();          
        cas1.Core_IPS_Project_Case__c = pr.id;
        cas1.status = 'open';   
        cas1.Subject ='Testing with testclass';
        cas1.AccountId = newAccount.Id;
        caselst.add(cas1);
        
        insert caselst;  
        System.assert(caselst[0].Id != null, 'Record not created');
        
        Core_IPS_Case_Interested_Party__c party1 = new Core_IPS_Case_Interested_Party__c();
        party1.Contact__c = cc.id;
        party1.Case__c = caselst[0].id;
        party1.Type__c='Internal';
        insert party1;
        System.assert(party1.Id != null, 'Record not created');
        
        List<Id>userId = new list<id>(); //[select id from user where id =:UserInfo.getUserId()];
        userId.add(UserInfo.getUserId());
        String query  ='Select id from case where Subject =\'Testing with testclass\' limit 1'; 
        Core_IPS_Interested_Party_LEX.getQueryResult(query);
        Core_IPS_Interested_Party_LEX.getUserDetailsBasedOnSearch('test',caselst[0].id );
        Core_IPS_Interested_Party_LEX.saveInternalInterestedParty(userId,caselst[0].id,cc.id);
        //Core_IPS_Interested_Party_LEX.saveInternalInterestedParty(userId,caselst[0].id,cc.id);
        Core_IPS_Interested_Party_LEX.saveInternalInterestedParty(userId,caselst[0].id,''); 
        // covering for controller class
        
    }
    static testmethod void vf(){
        Case cas1 = new Case();          
        //cas1.Core_IPS_Project_Case__c = pr.id;
        cas1.status = 'open';   
        cas1.Subject ='Testing with testclass';
        insert cas1;
        System.assert(cas1.Id != null, 'Record not created');
        
        list<case> caselst = new list<case>{cas1};
        ApexPages.StandardsetController stdsetController = new ApexPages.StandardsetController(caselst);
        PageReference pp= page.Core_IPS_InterestedParty_LEX;
        pp.getParameters().put('id',String.valueOf(cas1.id));
        
        Core_IPS_Interested_Party_Controller test = new Core_IPS_Interested_Party_Controller(stdsetController);
        }
       


    }