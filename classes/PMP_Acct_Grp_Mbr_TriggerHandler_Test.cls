@isTest
public class PMP_Acct_Grp_Mbr_TriggerHandler_Test {
    
    @isTest
    public static void  partnerAccGroupMemtestMethod ()
    { 
        Id accountRTPartnerAccountGroup = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('Core_Partner_Account_Group').getRecordTypeId(); 
        //String partnerAccRecTypeId = System.Label.PMP_Partner_Account_Record_Type_Id;
        
        Core_Trigger_Executions__c cs = new Core_Trigger_Executions__c (Name = 'PAG_mem_handler',
                                                                        Core_Active__c = true,
                                                                        Core_Class_Name__c = 'Core_Acct_Grp_Mbr_TriggerHandler',
                                                                        Core_Object__c = 'Core_Account_Group_Member__c',
                                                                        Core_Trigger_Events__c = 'After Insert, After Update, Before Delet',
                                                                        Core_Description__c = 'Update the related MDA Partner info when ever Account updated.');
        insert cs;
        List<Account> accts = new List<Account>();        
        Account partnerAccount = new Account(Name ='PartnerAccount',Core_Account_Type__c = 'Distributor',Core_Sales_Groups__c= 'CCG Sales Group',
                                             Industry='Agriculture', BillingCity='delhi',BillingCountry='Ind',BillingStreet='abc chowk delhi',RecordTypeId=accountRTPartnerAccountGroup);
        System.debug('partnerAccount ='+partnerAccount.IsPartner);
        accts.add(partnerAccount);
        Account intelAccount = new Account(Name ='IntelAccount',Core_Account_Type__c = 'Distributor',Core_Sales_Groups__c= 'CCG Sales Group',
                                           Industry='Agriculture', BillingCity='delhi',BillingCountry='Ind',BillingStreet='cbc chowk delhi');
        
        accts.add(intelAccount);
        Insert accts ;
        
        List<Account> intelAccId = [SELECT ID,Name FROM Account where Name ='IntelAccount'];
        List<Account> partnerAccountIdVar = [SELECT ID,Name FROM Account where Name ='PartnerAccount'];
        List<Account>accToUpdate = new List<Account>();
        For(Account acc:accts){
            acc.IsPartner = true;
            accToUpdate.add(acc);
        }
        Update accToUpdate ;
        System.debug('accToUpdate ='+accToUpdate);
        List<Core_Account_Group_Member__c> accGroupMemlist = new List<Core_Account_Group_Member__c>();
        Core_Account_Group_Member__c  accGroupMem= new Core_Account_Group_Member__c(Core_Partner_Account_Id__c =partnerAccountIdVar[0].Id,Core_Intel_Account_Id__c =intelAccId[0].Id);
        accGroupMemlist.add(accGroupMem);
        Insert accGroupMemlist ;
        
		/*        List<Core_Account_Group_Member__c> gupdate=new List<Core_Account_Group_Member__c>();
        List<Core_Account_Group_Member__c> gl=[Select Core_MDA_Ind__c from Core_Account_Group_Member__c];
        For(Core_Account_Group_Member__c g : gl)
        {
            g.Core_MDA_Ind__c=False;
            gupdate.add(g);
        }
        
        Update gupdate ; */
        Core_Trigger_Executions__c executions1 = new Core_Trigger_Executions__c(Name='UpdateJobFunctionAndCode',Core_Active__c=true,Core_Class_Name__c='Core_ContactHandler',Core_Description__c='testcase',Core_Object__c='Contact',Core_Trigger_Events__c='Before Insert Before Update');
        			insert executions1;
        Contact contact1 = new Contact(firstname='Partner', 
                                       lastname='Contact1', accountId=intelAccId[0].id,Email='dellco1234@dell.com');
        //for update
        
        
        Insert contact1;
        
        
        //for update 
        List<Contact> ccupdate=new List<Contact>();
        List<Contact> cl=[Select firstname,lastname from Contact];
        For(Contact c : cl)
        {
            c.firstname='Partner1';
            ccupdate.add(c);
        }
        Update ccupdate ;
        
        Test.startTest(); 
        List<Core_ERPM_Engagement__c> erp = new List<Core_ERPM_Engagement__c>();
        Core_ERPM_Engagement__c ee1 = new Core_ERPM_Engagement__c(Name='Access and Entitlements for Marketplace');
        
        Insert ee1 ;
        
        List<Core_Entitlement__c> ent = new List<Core_Entitlement__c>();
        Core_Entitlement__c de1 = new Core_Entitlement__c(Name='Partner Admin',Core_Display_Name__c='Partner Admin',Core_ERPM_Engagement_Id__c=ee1.id);
        
        Insert de1 ;
        
        List<Core_Entitlement__c> cnupdate=new List<Core_Entitlement__c>();
        List<Core_Entitlement__c> cn=[Select Core_Display_Name__c from  Core_Entitlement__c];
        for(Core_Entitlement__c cn1:cn)
        {
            cn1.Core_Display_Name__c ='Employee';
            cnupdate.add(cn1);
        }
        Update cnupdate ;
        
        
        
        List<Core_Contact_Entitlement__c> newlstentitle = new List<Core_Contact_Entitlement__c>();
        Core_Contact_Entitlement__c ce1 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=contact1.Id,Core_Entitlement_Id__c = de1.id, Core_Selected__c=true);
        newlstentitle.add(ce1);
        Insert newlstentitle ;
        
        
        List<Core_Contact_Entitlement__c> ccnupdate=new List<Core_Contact_Entitlement__c>();
        List<Core_Contact_Entitlement__c> ccn=[Select Core_Selected__c from  Core_Contact_Entitlement__c];
        for(Core_Contact_Entitlement__c ccn1:ccn)
        {
            ccn1.Core_Selected__c =true;
            ccnupdate.add(ccn1);
        }
        Update ccnupdate ;
        Test.stopTest();
        
        
        User currentUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        List<User> userList = new List<User>();
        System.debug('currentUser ='+currentUser);
        
        System.runAs (currentUser) {
          //  UserRole userRole = [Select PortalType, PortalAccountId From UserRole where PortalType ='Partner' limit 1];
            Profile profile = [select Id,name from Profile where Name ='Partner'];
            User newUser = new User(
            //    UserRoleId = userRole.Id,
                profileId = profile.id, 
                username = 'testUser'+String.valueOf(Math.random())+'@CoreMD.com', 
                email = 'pb@ff.com', 
                emailencodingkey = 'UTF-8', 
                localesidkey = 'en_US', 
                languagelocalekey = 'en_US', 
                timezonesidkey = 'America/Los_Angeles', 
                alias='nuser', 
                lastname='lastname', 
                contactId = contact1.id
            );
            userList.add(newUser);
            insert userList ;
            
        }
        System.debug('userList ='+userList);
        
        try{
            
            
            
            delete accGroupMemlist;           
            
        }Catch (DMLException e){
            
            System.assert(e.getMessage().contains('Service Agreement cannot be deleted.'), 'Service Agreement cannot be deleted.');
        }
        
        
        
        
    }
    
    @isTest
    public static void  partnerAccGroupMemtestMethod1 ()
    { 
        Id accountRTPartnerAccountGroup = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('Core_Partner_Account_Group').getRecordTypeId();
        
        //String partnerAccRecTypeId = System.Label.PMP_Partner_Account_Record_Type_Id;
        List<Account> accts1 = new List<Account>();        
        Account partnerAccount1 = new Account(Name ='PartnerAccount',Core_Account_Type__c = 'Distributor',Core_Sales_Groups__c= 'CCG Sales Group',
                                              Industry='Agriculture', BillingCity='delhi',BillingCountry='Ind',BillingStreet='abc chowk delhi',RecordTypeId=accountRTPartnerAccountGroup);
        System.debug('partnerAccount ='+partnerAccount1.IsPartner);
        accts1.add(partnerAccount1);
        Account intelAccount1 = new Account(Name ='IntelAccount',Core_Account_Type__c = 'Distributor',Core_Sales_Groups__c= 'CCG Sales Group',
                                            Industry='Agriculture', BillingCity='delhi',BillingCountry='Ind',BillingStreet='cbc chowk delhi');
        
        accts1.add(intelAccount1);
        Insert accts1 ;
        
        List<Account> intelAccId1 = [SELECT ID,Name FROM Account where Name ='IntelAccount'];
        List<Account> partnerAccountIdVar1 = [SELECT ID,Name FROM Account where Name ='PartnerAccount'];
        List<Account>accToUpdate1 = new List<Account>();
        For(Account acc1:accts1){
            acc1.IsPartner = true;
            accToUpdate1.add(acc1);
        }
        Update accToUpdate1 ;
        System.debug('accToUpdate ='+accToUpdate1);
        List<Core_Account_Group_Member__c> accGroupMemlist1 = new List<Core_Account_Group_Member__c>();
        Core_Account_Group_Member__c  accGroupMem1= new Core_Account_Group_Member__c(Core_Partner_Account_Id__c =partnerAccountIdVar1[0].Id,Core_Intel_Account_Id__c =intelAccId1[0].Id);
        accGroupMemlist1.add(accGroupMem1);
        Insert accGroupMemlist1 ;
        
        List<Core_Account_Group_Member__c> gupdate1=new List<Core_Account_Group_Member__c>();
        List<Core_Account_Group_Member__c> gl1=[Select Core_MDA_Ind__c from Core_Account_Group_Member__c];
        For(Core_Account_Group_Member__c g1 : gl1)
        {
            g1.Core_MDA_Ind__c=False;
            gupdate1.add(g1);
        }
        
        
        Contact contact11 = new Contact(firstname='Partner', 
                                        lastname='Contact1', accountId=intelAccId1[0].id,Email='dellco1234@dell.com');
        //for update
        
        
        Insert contact11;
        
        
        //for update 
        List<Contact> ccupdate1=new List<Contact>();
        List<Contact> cl1=[Select firstname,lastname from Contact];
        For(Contact c1 : cl1)
        {
            c1.firstname='Partner1';
            ccupdate1.add(c1);
        }
        Update ccupdate1 ;
        
        Test.startTest();
        List<Core_ERPM_Engagement__c> erp1 = new List<Core_ERPM_Engagement__c>();
        Core_ERPM_Engagement__c ee11 = new Core_ERPM_Engagement__c(Name='Access and Entitlements for Marketplace');
        
        Insert ee11 ;
        
        List<Core_Entitlement__c> ent1 = new List<Core_Entitlement__c>();
        Core_Entitlement__c de11 = new Core_Entitlement__c(Name='Partner Admin',Core_Display_Name__c='Partner Admin',Core_ERPM_Engagement_Id__c=ee11.id);
        
        Insert de11 ;
        
        List<Core_Entitlement__c> cnupdate1=new List<Core_Entitlement__c>();
        List<Core_Entitlement__c> cn1=[Select Core_Display_Name__c from  Core_Entitlement__c];
        for(Core_Entitlement__c cn11:cn1)
        {
            cn11.Core_Display_Name__c ='Employee';
            cnupdate1.add(cn11);
        }
        Update cnupdate1 ;
        
        
        
        List<Core_Contact_Entitlement__c> newlstentitle = new List<Core_Contact_Entitlement__c>();
        Core_Contact_Entitlement__c ce1 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=contact11.Id,Core_Entitlement_Id__c = de11.id, Core_Selected__c=true);
        newlstentitle.add(ce1);
        Insert newlstentitle ;
        
        
        List<Core_Contact_Entitlement__c> ccnupdate1=new List<Core_Contact_Entitlement__c>();
        List<Core_Contact_Entitlement__c> ccn1=[Select Core_Selected__c from  Core_Contact_Entitlement__c];
        for(Core_Contact_Entitlement__c ccn11:ccn1)
        {
            ccn11.Core_Selected__c =true;
            ccnupdate1.add(ccn11);
        }
        Update ccnupdate1 ;
        Test.stopTest();
        
        
        User currentUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        List<User> userList = new List<User>();
        System.debug('currentUser ='+currentUser);
        
        System.runAs (currentUser) {
         //   UserRole userRole = [Select PortalType, PortalAccountId From UserRole where PortalType ='Partner' limit 1];
            Profile profile = [select Id,name from Profile where Name ='Partner'];
            User newUser = new User(
           //     UserRoleId = userRole.Id,
                profileId = profile.id, 
                username = 'testUser'+String.valueOf(Math.random())+'@CoreMD.com', 
                email = 'pb@ff.com', 
                emailencodingkey = 'UTF-8', 
                localesidkey = 'en_US', 
                languagelocalekey = 'en_US', 
                timezonesidkey = 'America/Los_Angeles', 
                alias='nuser', 
                lastname='lastname', 
                contactId = contact11.id
            );
            userList.add(newUser);
            insert userList ;
            
        }
        System.debug('userList ='+userList);
        
     /*   try{

            Update gupdate1 ;

        }Catch (DMLException e){
            
            System.assert(e.getMessage().contains('Service Agreement cannot be deleted.'), 'Service Agreement cannot be deleted.');
        }  */
        
        
        
        
    }
    
    static testMethod void pagTestMethod(){
        Test.startTest();
        Id accountRecordTypeIntel = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        Id accountRTPartnerAccountGroup = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('Core_Partner_Account_Group').getRecordTypeId();
        
        List<Account> accList = new List<Account>();
        List<Core_Account_Group_Member__c> agmList = new List<Core_Account_Group_Member__c>();
        Account a = new Account();
        a.RecordTypeId = accountRTPartnerAccountGroup;
        a.Name='Amazon';
        a.Core_Account_Type__c ='Distributor';
        a.Industry='Agriculture';
        a.BillingCity='New Delhi';
        a.BillingCountryCode='IND';
        a.BillingStreet='4th Floor,New Road';
        a.BillingPostalCode='110037';
        a.BillingStateCode='KA';
        accList.add(a);
        
        Account ac = new Account();
        ac.RecordTypeId = accountRTPartnerAccountGroup;
        ac.Name='Amazon India';
        ac.Core_Account_Type__c ='Distributor';
        ac.Industry='Agriculture';
        ac.BillingCity='New Delhi';
        ac.BillingCountryCode='IND';
        ac.BillingStreet='4th Floor,New Road';
        ac.BillingPostalCode='110037';
        ac.BillingStateCode='KA';
        accList.add(ac);
        
        Account acc = new Account();
        acc.RecordTypeId = accountRecordTypeIntel;
        acc.Name='Walmart';
        acc.Core_Account_Type__c ='Distributor';
        acc.Industry='Agriculture';
        acc.BillingCity='New Delhi';
        acc.BillingCountryCode='IND';
        acc.BillingStreet='4th Floor,New Road';
        acc.BillingPostalCode='110037';
        acc.BillingStateCode='KA';
        acc.Core_Is_PAG_Member_Ind__c = false;
        accList.add(acc);
        
        Account acct = new Account();
        acct.RecordTypeId = accountRecordTypeIntel;
        acct.Name='Tesco';
        acct.Core_Account_Type__c ='Distributor';
        acct.Industry='Agriculture';
        acct.BillingCity='New Delhi';
        acct.BillingCountryCode='IND';
        acct.BillingStreet='4th Floor,New Road';
        acct.BillingPostalCode='110037';
        acct.BillingStateCode='KA';
        acct.Core_Is_PAG_Member_Ind__c = false;
        accList.add(acct);
        
        Account accnt = new Account();
        accnt.RecordTypeId = accountRecordTypeIntel;
        accnt.Name='Tesla';
        accnt.Core_Account_Type__c ='Distributor';
        accnt.Industry='Agriculture';
        accnt.BillingCity='New Delhi';
        accnt.BillingCountryCode='IND';
        accnt.BillingStreet='4th Floor,New Road';
        accnt.BillingPostalCode='110037';
        accnt.BillingStateCode='KA';
        accnt.Core_Is_PAG_Member_Ind__c = false;
        accList.add(accnt);
        
        Account accnts = new Account();
        accnts.RecordTypeId = accountRecordTypeIntel;
        accnts.Name='Texon Corp';
        accnts.Core_Account_Type__c ='Distributor';
        accnts.Industry='Agriculture';
        accnts.BillingCity='New Delhi';
        accnts.BillingCountryCode='IND';
        accnts.BillingStreet='4th Floor,New Road';
        accnts.BillingPostalCode='110037';
        accnts.BillingStateCode='KA';
        accnts.Core_Is_PAG_Member_Ind__c = false;
        accList.add(accnts);
        insert accList;
        
        Contact contact11 = new Contact(firstname='Partner', 
                                        lastname='Contact1', accountId=accList[5].id,Email='dellco1234@dell.com');
        
        Core_Account_Group_Member__c agm = new Core_Account_Group_Member__c();
        agm.Core_Partner_Account_Id__c = a.Id;
        agm.Core_Intel_Account_Id__c = acc.Id;
        agm.Core_MDA_Ind__c = true;
        agm.Core_Inactive_Ind__c = false;
        agmList.add(agm);
        
        Core_Account_Group_Member__c agm1 = new Core_Account_Group_Member__c();
        agm1.Core_Partner_Account_Id__c = a.Id;
        agm1.Core_Intel_Account_Id__c = accnt.Id;
        agm1.Core_MDA_Ind__c = false;
        agm1.Core_Inactive_Ind__c = false;
        agmList.add(agm1);
        
        Core_Account_Group_Member__c agm2 = new Core_Account_Group_Member__c();
        agm2.Core_Partner_Account_Id__c = ac.Id;
        agm2.Core_Intel_Account_Id__c = accnts.Id;
        agm2.Core_MDA_Ind__c = true;
        agm2.Core_Inactive_Ind__c = false;
        agmList.add(agm2);
        insert agmList;
        
        try{
            acc.Core_Is_PAG_Member_Ind__c = true;
            update acc;
            
            agm.Core_Intel_Account_Id__c = acct.Id;
            agm.Core_Inactive_Ind__c = true;
            update agm;
            
            agm.Core_Inactive_Ind__c = false;
            update agm;
            
            agm1.Core_Inactive_Ind__c = true;
            update agm1;
            
            Core_Account_Group_Member__c agm3 = new Core_Account_Group_Member__c();
        	agm3.Core_Partner_Account_Id__c = ac.Id;
        	agm3.Core_Intel_Account_Id__c = accnt.Id;
        	agm3.Core_MDA_Ind__c = false;
        	agm3.Core_Inactive_Ind__c = false;
        	insert agm3;
            
            agm1.Core_Inactive_Ind__c = false;
            agm1.Core_MDA_Ind__c = true;
            update agm1;
            
            agm2.Core_MDA_Ind__c = false;
            agm2.Core_Intel_Account_Id__c = accnt.Id;
            update agm2;
            
            acc.Core_Is_PAG_Member_Ind__c = false;
            update acc;
            
            acct.Core_Is_PAG_Member_Ind__c = true;
            update acct;    
            
            acct.Core_Is_PAG_Member_Ind__c = false;
            update acct;
        }
        catch(Exception e){
        }
        Test.stopTest();
     //   System.assertEquals(acct.Core_Is_PAG_Member_Ind__c,false,'match');
    }
    
    static testMethod void pagTestMethod1(){
        Test.startTest();
        Id accountRecordTypeIntel = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        Id accountRTPartnerAccountGroup = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('Core_Partner_Account_Group').getRecordTypeId();
        
        Account a = new Account();
        a.RecordTypeId = accountRTPartnerAccountGroup;
        a.Name='Amazon';
        a.Core_Account_Type__c ='Distributor';
        a.Industry='Agriculture';
        a.BillingCity='New Delhi';
        a.BillingCountryCode='IND';
        a.BillingStreet='4th Floor,New Road';
        a.BillingPostalCode='110037';
        a.BillingStateCode='KA';
        insert a;
        
        Account acc = new Account();
        acc.RecordTypeId = accountRecordTypeIntel;
        acc.Name='Walmart';
        acc.Core_Account_Type__c ='Distributor';
        acc.Industry='Agriculture';
        acc.BillingCity='New Delhi';
        acc.BillingCountryCode='IND';
        acc.BillingStreet='4th Floor,New Road';
        acc.BillingPostalCode='110037';
        acc.BillingStateCode='KA';
        acc.Core_Is_PAG_Member_Ind__c = false;
        insert acc;
        
        Account acct = new Account();
        acct.RecordTypeId = accountRecordTypeIntel;
        acct.Name='Tesco';
        acct.Core_Account_Type__c ='Distributor';
        acct.Industry='Agriculture';
        acct.BillingCity='New Delhi';
        acct.BillingCountryCode='IND';
        acct.BillingStreet='4th Floor,New Road';
        acct.BillingPostalCode='110037';
        acct.BillingStateCode='KA';
        acct.Core_Is_PAG_Member_Ind__c = false;
        insert acct;
        
        Core_Account_Group_Member__c agm = new Core_Account_Group_Member__c();
        agm.Core_Partner_Account_Id__c = a.Id;
        agm.Core_Intel_Account_Id__c = acc.Id;
        agm.Core_MDA_Ind__c = true;
        agm.Core_Inactive_Ind__c = false;
        insert agm;
        
        try{
            acc.Core_Is_PAG_Member_Ind__c = true;
            update acc;
            
            agm.Core_Intel_Account_Id__c = acct.Id;
            agm.Core_Inactive_Ind__c = true;
            update agm;
            
            acc.Core_Is_PAG_Member_Ind__c = false;
            update acc;
            
            acct.Core_Is_PAG_Member_Ind__c = true;
            update acct;
            
            agm.Core_MDA_Ind__c = false;
            update agm;
            
            acct.Core_Is_PAG_Member_Ind__c = false;
            update acct;
        }
        catch(Exception e){
        }
        Test.stopTest();
     //   System.assertEquals(acct.Core_Is_PAG_Member_Ind__c,false,'match');
    }
}