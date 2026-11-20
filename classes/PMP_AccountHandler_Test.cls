@istest
public class PMP_AccountHandler_Test {
  
    static testMethod void updatePartnerInfotest(){
		test.startTest();
        List<Account> accList = new List<Account>();
        Id intelacc_rectypeid = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
        Account acc = new Account(Name ='IntelAccount1', RecordTypeId = intelacc_rectypeid,
                                            Core_Sales_Group_New__c= 'CCG Sales Group',
                                          Industry='Agriculture', BillingCity='delhi',BillingCountry='Ind',
                                            BillingStreet='cbc chowk delhi',Core_Account_Type__c='Original Design Manufacturer (ODM)');
       
        
        Id recordTypeIdPAGAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
        
        Account parentAccount = new Account();//Account
        parentAccount.RecordTypeId = recordTypeIdPAGAccount;
        parentAccount.Name='Tesco';
        parentAccount.BillingCity='City';
        parentAccount.BillingStreet='Street';
        parentAccount.BillingCountry='India';
        parentAccount.BillingPostalCode='Postal code';
        parentAccount.Core_Account_Type__c='Cloud Service Provider (CSP)';
        parentAccount.Core_IPA_Partner_Role__c = 'Solution Integrator';
        accList.add(parentAccount);
        system.assertEquals('Tesco', parentAccount.Name);
       
            
        Account childAccount = new Account();//Account
        childAccount.RecordTypeId = recordTypeIdPAGAccount;
        childAccount.Name='Amazon';
        childAccount.BillingCity='City';
        childAccount.BillingStreet='Street';
        childAccount.BillingCountry='India';
        childAccount.BillingPostalCode='Postal code';
        childAccount.Core_Account_Type__c='Cloud Service Provider (CSP)';
        childAccount.Core_IPA_Partner_Role__c='Solution Integrator';
        accList.add(childAccount);
        accList.add(acc);
        insert accList;
         Map<id,Account> oldMap=New map<Id,Account>{accList[0].id=>accList[0]};
        accList[1].Core_Account_Type__c='Value Added Reseller (VAR)';
        update accList[1];
        
		Map<id,Account> oldMap1=New map<Id,Account>{accList[2].id=>accList[2]};
        
        PMP_SearchTestDataFactory.createCompanyInformation(parentAccount.Name, parentAccount.Id, true);
        List<Contact> conLIst= new List<Contact>();
        Contact cont1 = new Contact();  //Contact
        cont1.AccountId=accList[1].Id;
        cont1.lastName='thomas';
        cont1.FirstName='Jack';
        cont1.email='jackthomas@malinator.com';
        cont1.Core_Job_Function__c='Branch Manager';
        cont1.Core_eRPM_Language_Code__c='Eng';
        cont1.Core_IPA_PartnerRole__c = 'Solution Integrator';
        cont1.Core_Login_Id__c = 'xyz';
        cont1.Core_Do_Not_Contact__c = false;
        cont1.MailingCountry = 'India';
        conLIst.add(cont1);
        insert conLIst;
        
        Core_Account_Group_Member__c coreAccnt = new Core_Account_Group_Member__c();
        coreAccnt.Core_Partner_Account_Id__c = accList[0].id;
        coreAccnt.Core_Intel_Account_Id__c = accList[1].id;
        insert coreAccnt;
        
        ChannelProgram cp = new ChannelProgram(); //Channel Program
        cp.Name='Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        insert cp;
        
        PRM_ContactRelationships__c cr1=new PRM_ContactRelationships__c();
        cr1.Name='Partner Admin';
        cr1.PRM_Contact_Relationship_Cd__c='RELTNPRCTC';
        cr1.PRM_Default_Relationship_Ind__c = false;
        cr1.PRM_Mandatory_Relationship_Ind__c = true;
        cr1.PRM_Channel_Program_Id__c=cp.Id;
        cr1.PRM_InActive_Ind__c = false;
        insert cr1;
        
        
        PRM_Account_Contact_Relationship__c acr=new PRM_Account_Contact_Relationship__c();//Account Contact Relationship
        acr.PRM_InActive_Ind__c= false;
        acr.PRM_Account_Id__c=accList[1].Id;
        acr.PRM_Relationship_Id__c = cr1.Id;
        acr.PRM_Contact_Id__c=cont1.Id;
        acr.PRM_Start_Date_Dt__c= system.today()-2; 
        acr.PRM_Status_Nm__c = 'Complete';
        insert acr;
        // System.debug('acr-->'+acr);
        
        List<ChannelProgramLevel> chlPrgmLelList= new List<ChannelProgramLevel>();
        ChannelProgramLevel cpl=new ChannelProgramLevel(); //Channel Program Level
        cpl.Name='Member';
        cpl.ProgramId=cp.Id;
        chlPrgmLelList.add(cpl);
        
        ChannelProgramLevel cpl1=new ChannelProgramLevel(); //Channel Program Level
        cpl1.Name='Gold';
        cpl1.ProgramId=cp.Id;
        chlPrgmLelList.add(cpl1);
        
        ChannelProgramLevel level2 = new ChannelProgramLevel();   //Channel Program Level
        level2.Name='Titanium';
        level2.ProgramId = cp.Id;
        chlPrgmLelList.add(level2);
        insert chlPrgmLelList;
        // system.debug('^^Prgm 1=='+chlPrgmLelList);
        //List<PRM_AccountChannelMembership__c> achalMemList = new List<PRM_AccountChannelMembership__c>();
        
        
        PRM_AccountChannelMembership__c pagAccntACM = new PRM_AccountChannelMembership__c(); //Account Channel Membership
        pagAccntACM.PRM_Account_Id__c= parentAccount.id;
        pagAccntACM.PRM_Status_Nm__c='Approved';
        pagAccntACM.PRM_Channel_Program_Id__c=cp.Id;
        pagAccntACM.PRM_Channel_Program_Level_Id__c=chlPrgmLelList[1].Id;
        pagAccntACM.PRM_Partner_Role__c='Distributor';
        insert pagAccntACM;
     
        PRM_AccountChannelMembership__c childAccntACM = new PRM_AccountChannelMembership__c(); //Account Channel Membership
        childAccntACM.PRM_Account_Id__c= childAccount.id;
        childAccntACM.PRM_Status_Nm__c='Approved';
        childAccntACM.PRM_Channel_Program_Id__c=cp.Id;
        childAccntACM.PRM_Channel_Program_Level_Id__c=chlPrgmLelList[0].Id;
        childAccntACM.PRM_Partner_Role__c='Solution Integrator';
        insert childAccntACM;
        
        List<PRM_AccountChannelMembership__c> acmList = new List<PRM_AccountChannelMembership__c>();
        //List<PRM_AccountChannelMembership__c> updatedACMList = new List<PRM_AccountChannelMembership__c>();
        acmList.add(pagAccntACM);
        List<Account> newAccList=[select id,Name,RecordTypeId,Core_IPA_Partner_Segment__c,Core_Account_Type__c from Account where Name ='Tesco' LIMIT 1];
     	newAccList[0].Core_Account_Type__c='Intel Approved Component Supplier (IACS);Intel Approved Device Supplier (IADS);';
        newAccList[0].Core_IPA_Partner_Segment__c='Client Computing';
        update newAccList[0];
        Map<id,Account> newMap=New map<Id,Account>{newAccList[0].id=>newAccList[0]};
            List<Account> newAccList1=[select id,Name,RecordTypeId,Core_IPA_Partner_Segment__c,Core_Account_Type__c from Account where Name ='IntelAccount1' LIMIT 1];
     	test.stopTest();
        newAccList1[0].Core_Account_Type__c='Intel Approved Component Supplier (IACS);Intel Approved Device Supplier (IADS);';
        newAccList1[0].Core_IPA_Partner_Segment__c='Client Computing';
        update newAccList1[0];
        Map<id,Account> newMap1=New map<Id,Account>{newAccList1[0].id=>newAccList1[0]};
        
        
        PMP_AccountHandler.updatePartnerInfo(newAccList,newMap,oldMap);
         PMP_AccountHandler.updatePartnerInfo(newAccList1,newMap1,oldMap1);
        PMP_AccountHandler.filterDistiBizOrgs(newAccList[0].Core_Account_Type__c);
        
   }
    static testMethod void updatePartnerInfotest1(){
        Id recordTypeIdPAGAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
         List<Account> accList = new List<Account>();
        Account parentAccount = new Account();//Account
        parentAccount.RecordTypeId = recordTypeIdPAGAccount;
        parentAccount.Name='Tesco';
        parentAccount.BillingCity='City';
        parentAccount.BillingStreet='Street';
        parentAccount.BillingCountry='India';
        parentAccount.BillingPostalCode='Postal code';
        parentAccount.Core_Account_Type__c='Cloud Service Provider (CSP)';
        parentAccount.Core_IPA_Partner_Role__c = 'Solution Integrator';
        //insert parentAccount;
        accList.add(parentAccount);
        Map<id,Account> oldMap=New map<Id,Account>{parentAccount.id=>parentAccount};
        Account childAccount = new Account();//Account    
        childAccount.RecordTypeId = recordTypeIdPAGAccount;
        childAccount.Name='Amazon';
        childAccount.BillingCity='City';
        childAccount.BillingStreet='Street';
        childAccount.BillingCountry='India';
        childAccount.BillingPostalCode='Postal code';
        childAccount.Core_Account_Type__c='Cloud Service Provider (CSP)';
        childAccount.Core_IPA_Partner_Role__c='Solution Integrator';
        accList.add(childAccount);
        insert accList;
        
        childAccount.Core_Account_Type__c='Value Added Reseller (VAR)';
        update childAccount;

        
        PMP_SearchTestDataFactory.createCompanyInformation(parentAccount.Name, parentAccount.Id, true);
        
        List<Contact> conList = new List<Contact>();
        Contact cont1 = new Contact();  //Contact
        cont1.AccountId=childAccount.Id;
        cont1.lastName='thomas';
        cont1.FirstName='Jack';
        cont1.email='jackthomas@malinator.com';
        cont1.Core_Job_Function__c='Branch Manager';
        cont1.Core_eRPM_Language_Code__c='Eng';
        cont1.Core_IPA_PartnerRole__c = 'Solution Integrator';
        cont1.Core_Login_Id__c = 'xyz';
        cont1.Core_Do_Not_Contact__c = false;
        cont1.MailingCountry ='India';
       // insert cont1;
        conList.add(cont1);
        insert conList;
        
        Core_Account_Group_Member__c coreAccnt = new Core_Account_Group_Member__c();
        coreAccnt.Core_Partner_Account_Id__c = accList[0].id;
        coreAccnt.Core_Intel_Account_Id__c = accList[1].id;
        insert coreAccnt;
        
        ChannelProgram cp = new ChannelProgram(); //Channel Program
        cp.Name='Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        insert cp;
        
        PRM_ContactRelationships__c cr1=new PRM_ContactRelationships__c();
        cr1.Name='Partner Admin';
        cr1.PRM_Contact_Relationship_Cd__c='RELTNPRCTC';
        cr1.PRM_Default_Relationship_Ind__c = false;
        cr1.PRM_Mandatory_Relationship_Ind__c = true;
        cr1.PRM_Channel_Program_Id__c=cp.Id;
        cr1.PRM_InActive_Ind__c = false;
        insert cr1;
        
        
        PRM_Account_Contact_Relationship__c acr=new PRM_Account_Contact_Relationship__c();//Account Contact Relationship
        acr.PRM_InActive_Ind__c= false;
        acr.PRM_Account_Id__c=childAccount.Id;
        acr.PRM_Relationship_Id__c = cr1.Id;
        acr.PRM_Contact_Id__c=conList[0].Id;
        //acr.PRM_execute_trigger__c=true;
        acr.PRM_Start_Date_Dt__c= system.today()-2; 
        //acr.PRM_End_Date_Dt__c= acr.PRM_Start_Date_Dt__c+1;  
        acr.PRM_Status_Nm__c = 'Complete';
        insert acr;
        // System.debug('acr-->'+acr);
        
        List<ChannelProgramLevel> cplList= new List<ChannelProgramLevel>();
        ChannelProgramLevel cpl=new ChannelProgramLevel(); //Channel Program Level
        cpl.Name='Member';
        cpl.ProgramId=cp.Id;
        cplList.add(cpl);
        //insert cpl;
        
        ChannelProgramLevel cpl1=new ChannelProgramLevel(); //Channel Program Level
        cpl1.Name='Gold';
        cpl1.ProgramId=cp.Id;
        cplList.add(cpl1);
        //insert cpl1;
        
        ChannelProgramLevel level2 = new ChannelProgramLevel();   //Channel Program Level
        level2.Name='Titanium';
        level2.ProgramId = cp.Id;
        cplList.add(level2);
        insert cplList;
        system.assertEquals('Titanium', level2.Name);  
        
        //List<PRM_AccountChannelMembership__c> accChalMebList = new List<PRM_AccountChannelMembership__c>();
        PRM_AccountChannelMembership__c pagAccntACM = new PRM_AccountChannelMembership__c(); //Account Channel Membership
        pagAccntACM.PRM_Account_Id__c= parentAccount.id;
        pagAccntACM.PRM_Status_Nm__c='Approved';
        pagAccntACM.PRM_Channel_Program_Id__c=cp.Id;
        pagAccntACM.PRM_Channel_Program_Level_Id__c=cplList[1].Id;
        pagAccntACM.PRM_Partner_Role__c='Solution Integrator';
        insert pagAccntACM;
        
     	test.startTest();
        PRM_AccountChannelMembership__c childAccntACM = new PRM_AccountChannelMembership__c(); //Account Channel Membership
        childAccntACM.PRM_Account_Id__c= childAccount.id;
        childAccntACM.PRM_Status_Nm__c='Approved';
        childAccntACM.PRM_Channel_Program_Id__c=cp.Id;
        childAccntACM.PRM_Channel_Program_Level_Id__c=cplList[0].Id;
        childAccntACM.PRM_Partner_Role__c='Solution Integrator';
        insert childAccntACM;
        //accChalMebList.add(childAccntACM);
        //insert accChalMebList;
		        
        List<PRM_AccountChannelMembership__c> acmList = new List<PRM_AccountChannelMembership__c>();
        //List<PRM_AccountChannelMembership__c> updatedACMList = new List<PRM_AccountChannelMembership__c>();
        acmList.add(pagAccntACM);
        List<Account> newAccList=[select id,Name,RecordTypeId,Core_IPA_Partner_Segment__c,Core_Account_Type__c from Account where Name ='Tesco' LIMIT 1];
     	test.stopTest();
        newAccList[0].Core_Account_Type__c='Intel Approved Component Supplier (IACS);Intel Approved Device Supplier (IADS);';
        newAccList[0].Core_IPA_Partner_Segment__c='Client Computing';
        update newAccList[0];
        Map<id,Account> newMap=New map<Id,Account>{newAccList[0].id=>newAccList[0]};
        
        PMP_AccountHandler.updatePartnerInfo(newAccList,newMap,oldMap);
        PMP_AccountHandler.filterDistiBizOrgs(newAccList[0].Core_Account_Type__c);
    }
    static testMethod void updatePartnerInfotest2(){

        List<Account> accList = new List<Account>();
        Id recordTypeIdPAGAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
        
        Account parentAccount = new Account();//Account
        parentAccount.RecordTypeId = recordTypeIdPAGAccount;
        parentAccount.Name='Tesco';
        parentAccount.BillingCity='City';
        parentAccount.BillingStreet='Street';
        parentAccount.BillingCountry='India';
        parentAccount.BillingPostalCode='Postal code';
        parentAccount.Core_Account_Type__c='Cloud Service Provider (CSP)';
        parentAccount.Core_IPA_Partner_Role__c = 'Solution Integrator';
        accList.add(parentAccount);
        system.assertEquals('Tesco', parentAccount.Name);
       
            
        Account childAccount = new Account();//Account
        childAccount.RecordTypeId = recordTypeIdPAGAccount;
        childAccount.Name='Amazon';
        childAccount.BillingCity='City';
        childAccount.BillingStreet='Street';
        childAccount.BillingCountry='India';
        childAccount.BillingPostalCode='Postal code';
        childAccount.Core_Account_Type__c='Cloud Service Provider (CSP)';
        childAccount.Core_IPA_Partner_Role__c='Solution Integrator';
        accList.add(childAccount);
        insert accList;
         Map<id,Account> oldMap=New map<Id,Account>{accList[0].id=>accList[0]};
        accList[1].Core_Account_Type__c='Value Added Reseller (VAR)';
        update accList[1];

        
        PMP_SearchTestDataFactory.createCompanyInformation(parentAccount.Name, parentAccount.Id, true);
        List<Contact> conLIst= new List<Contact>();
        Contact cont1 = new Contact();  //Contact
        cont1.AccountId=accList[1].Id;
        cont1.lastName='thomas';
        cont1.FirstName='Jack';
        cont1.email='jackthomas@malinator.com';
        cont1.Core_Job_Function__c='Branch Manager';
        cont1.Core_eRPM_Language_Code__c='Eng';
        cont1.Core_IPA_PartnerRole__c = 'Solution Integrator';
        cont1.Core_Login_Id__c = 'xyz';
        cont1.Core_Do_Not_Contact__c = false;
        cont1.MailingCountry = 'India';
        conLIst.add(cont1);
        insert conLIst;
        
        Core_Account_Group_Member__c coreAccnt = new Core_Account_Group_Member__c();
        coreAccnt.Core_Partner_Account_Id__c = accList[0].id;
        coreAccnt.Core_Intel_Account_Id__c = accList[1].id;
        insert coreAccnt;
        
        ChannelProgram cp = new ChannelProgram(); //Channel Program
        cp.Name='Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        insert cp;
        
        PRM_ContactRelationships__c cr1=new PRM_ContactRelationships__c();
        cr1.Name='Partner Admin';
        cr1.PRM_Contact_Relationship_Cd__c='RELTNPRCTC';
        cr1.PRM_Default_Relationship_Ind__c = false;
        cr1.PRM_Mandatory_Relationship_Ind__c = true;
        cr1.PRM_Channel_Program_Id__c=cp.Id;
        cr1.PRM_InActive_Ind__c = false;
        insert cr1;
        
        
        PRM_Account_Contact_Relationship__c acr=new PRM_Account_Contact_Relationship__c();//Account Contact Relationship
        acr.PRM_InActive_Ind__c= false;
        acr.PRM_Account_Id__c=accList[1].Id;
        acr.PRM_Relationship_Id__c = cr1.Id;
        acr.PRM_Contact_Id__c=cont1.Id;
        acr.PRM_Start_Date_Dt__c= system.today()-2; 
        acr.PRM_Status_Nm__c = 'Complete';
        insert acr;
        // System.debug('acr-->'+acr);
        
        List<ChannelProgramLevel> chlPrgmLelList= new List<ChannelProgramLevel>();
        ChannelProgramLevel cpl=new ChannelProgramLevel(); //Channel Program Level
        cpl.Name='Member';
        cpl.ProgramId=cp.Id;
        chlPrgmLelList.add(cpl);
        
        ChannelProgramLevel cpl1=new ChannelProgramLevel(); //Channel Program Level
        cpl1.Name='Gold';
        cpl1.ProgramId=cp.Id;
        chlPrgmLelList.add(cpl1);
        
        ChannelProgramLevel level2 = new ChannelProgramLevel();   //Channel Program Level
        level2.Name='Titanium';
        level2.ProgramId = cp.Id;
        chlPrgmLelList.add(level2);
        insert chlPrgmLelList;
        
        //List<PRM_AccountChannelMembership__c> achalMemList = new List<PRM_AccountChannelMembership__c>();
        
        PRM_AccountChannelMembership__c pagAccntACM = new PRM_AccountChannelMembership__c(); //Account Channel Membership
        pagAccntACM.PRM_Account_Id__c= parentAccount.id;
        pagAccntACM.PRM_Status_Nm__c='Approved';
        pagAccntACM.PRM_Channel_Program_Id__c=cp.Id;
        pagAccntACM.PRM_Channel_Program_Level_Id__c=chlPrgmLelList[1].Id;
        pagAccntACM.PRM_Partner_Role__c='Solution Integrator';
        insert pagAccntACM;
        
     
        PRM_AccountChannelMembership__c childAccntACM = new PRM_AccountChannelMembership__c(); //Account Channel Membership
        childAccntACM.PRM_Account_Id__c= childAccount.id;
        childAccntACM.PRM_Status_Nm__c='Approved';
        childAccntACM.PRM_Channel_Program_Id__c=cp.Id;
        childAccntACM.PRM_Channel_Program_Level_Id__c=chlPrgmLelList[0].Id;
        childAccntACM.PRM_Partner_Role__c='Solution Integrator';
        //achalMemList.add(childAccntACM);
        //system.assertEquals('Solution Integrator', childAccntACM.PRM_Partner_Role__c);
        insert childAccntACM;
        
        List<PRM_AccountChannelMembership__c> acmList = new List<PRM_AccountChannelMembership__c>();
        //List<PRM_AccountChannelMembership__c> updatedACMList = new List<PRM_AccountChannelMembership__c>();
        acmList.add(pagAccntACM);
        List<Account> newAccList=[select id,Name,RecordTypeId,Core_IPA_Partner_Segment__c,Core_Account_Type__c from Account where Name ='Tesco' LIMIT 1];
     
        newAccList[0].Core_Account_Type__c='Intel Approved Component Supplier (IACS);Intel Approved Device Supplier (IADS);IoT Solution Aggregator';
        newAccList[0].Core_IPA_Partner_Segment__c='Client Computing';
        update newAccList[0];
        Map<id,Account> newMap=New map<Id,Account>{newAccList[0].id=>newAccList[0]};
        
        PMP_AccountHandler.updatePartnerInfo(newAccList,newMap,oldMap);
        PMP_AccountHandler.filterDistiBizOrgs(newAccList[0].Core_Account_Type__c);
        
   }
    
}