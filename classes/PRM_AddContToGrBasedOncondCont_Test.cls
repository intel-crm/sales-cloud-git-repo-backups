/****************************************************************************************************************************
Apex Class Name     : PRM_AddContToGrBasedOncondCont_Test 
Version             : 1.0
Created Date        : 08 June 2020

Modification Log    :
* Developer                 Date                    Description
* --------------------------------------------------------------------------------------------------------------------------
* Sonali Mehetre       08 June 2020                Test class to cover PRM_AddContToGrBasedOncondController class

****************************************************************************************************************************/
@isTest()
public class PRM_AddContToGrBasedOncondCont_Test {
    
    static testmethod void handleASAMethod()
    {   
        PRM_Message__c msg = new PRM_Message__c();
        msg.PRM_Title_Txt__c = 'Tier to upgrade';
        insert msg;
            
        PRM_Contact_Group__c cntGr = new PRM_Contact_Group__c();
        cntGr.Name = 'IPA Contact Gr';
        insert cntGr;
        
        PRM_Contact_Group__c cntGr1 = new PRM_Contact_Group__c();
        cntGr1.Name = 'Test IPA ContGr';
        insert cntGr1;
        
        PRM_Message_Contact_Group_Association__c mCGARec = new PRM_Message_Contact_Group_Association__c();
        mCGARec.PRM_Contact_Group_Id__c = cntGr1.Id;
        mCGARec.PRM_Message_Id__c = msg.Id;
        insert mCGARec;
        
        Account testAcc = new Account();
        testAcc.Name='John Wick1';
        testAcc.Core_IPA_Partner_Role__c='Service Provider';
        testAcc.BillingCity='City';
        testAcc.BillingStreet='Beacker Street';
        testAcc.BillingCountry='India';
        testAcc.BillingPostalCode='Postal code1';
        testAcc.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        testAcc.Core_Intel_Partner_Alliance_PartnerGroup__c=true;
        insert testAcc;
        
        Contact cont = new Contact();  //Contact
        cont.AccountId=testAcc.Id;
        cont.lastName='Grill';
        cont.FirstName='Adam';
        cont.email='AdamGrill@rediff.com';
        cont.MailingCountry='USA';
        cont.Core_Job_Function__c='Branch Manager';
        cont.Core_eRPM_Language_Code__c='Eng';
        cont.Core_IPA_PartnerRole__c = 'Service Provider';
        cont.Core_Login_Id__c = 'abc';
        insert cont;
        
        ChannelProgram cp = new ChannelProgram(); //Channel Program
        cp.Name='Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        insert cp;
        
        PRM_ContactRelationships__c contRelation = new PRM_ContactRelationships__c();   //Contact Relationship
        contRelation.Name='Primary Contact';
        contRelation.PRM_Contact_Relationship_Cd__c ='RELTNPRCTC';
        contRelation.PRM_Channel_Program_Id__c = cp.Id;
        contRelation.PRM_Default_Relationship_Ind__c = true;
        insert contRelation;
        
        PRM_Account_Contact_Relationship__c acctContRel=new PRM_Account_Contact_Relationship__c(); //Account Contact Relationship
        acctContRel.PRM_Account_Id__c=testAcc.Id;
        acctContRel.PRM_Contact_Id__c=cont.Id;
        acctContRel.PRM_Relationship_Id__c=contRelation.Id;
        acctContRel.PRM_InActive_Ind__c=false;
        insert acctContRel;       
        
        
        Contact cont1 = new Contact();  //Contact
        cont1.AccountId=testAcc.Id;
        cont1.lastName='Corporation';
        cont1.FirstName='Acme';
        cont1.email='Acme@gmail.com';
        cont1.MailingCountry='USA';
        cont1.Core_Job_Function__c='Branch Manager';
        cont1.Core_eRPM_Language_Code__c='Eng';
        cont1.Core_IPA_PartnerRole__c = 'Service Provider';
        cont1.Core_Login_Id__c = 'abc';
        insert cont1;
        
        PRM_Account_Contact_Relationship__c acctContRel1=new PRM_Account_Contact_Relationship__c(); //Account Contact Relationship
        acctContRel1.PRM_Account_Id__c=testAcc.Id;
        acctContRel1.PRM_Contact_Id__c=cont1.Id;
        acctContRel1.PRM_Relationship_Id__c=contRelation.Id;
        acctContRel1.PRM_InActive_Ind__c=false;
        insert acctContRel1;
        
        List<PRM_Account_Contact_Relationship__c> lstOfSelContacts = new List<PRM_Account_Contact_Relationship__c>();
        lstOfSelContacts.add(acctContRel);
        lstOfSelContacts.add(acctContRel1);
        
        PRM_Specialty__c testspecialty = new PRM_Specialty__c();//Specialty
        testspecialty.Name = 'Addition Select Benefit';
        testspecialty.PRM_Description_Txt__c = 'Addition Select Benefit';
        testspecialty.PRM_Access_Level_Nm__c = 'public';
        testspecialty.PRM_Funding_BU_Nm__c = 'CCG Sales Group';
        testspecialty.PRM_Role_Nm__c = System.Label.PRM_Service_Provider;
        testspecialty.PRM_Tier_Nm__c = 'Gold';
        testspecialty.PRM_Start_Date_Dt__c = system.today()+7;
        insert testspecialty;
        
                
        PRM_Account_Specialty_Association__c asaRec = new PRM_Account_Specialty_Association__c();
        asaRec.PRM_Account_Id__c = testAcc.Id;
        asaRec.PRM_Specialty_Id__c = testspecialty.Id;
        asaRec.PRM_Partner_Role__c = 'Service Provider';
        asaRec.PRM_InActive_Ind__c = false;
        insert asaRec;
        
        PRM_Contact_Group_Contact_Association__c grContAss = new PRM_Contact_Group_Contact_Association__c();
        grContAss.PRM_Contact_Group_Id__c = cntGr.Id;
        grContAss.PRM_Contact_Id__c = cont1.Id;
        grContAss.PRM_InActive_Ind__c = false;
        insert grContAss;
        
        PRM_Contact_Group_Contact_Association__c grContAss1 = new PRM_Contact_Group_Contact_Association__c();
        grContAss1.PRM_Contact_Group_Id__c = cntGr.Id;
        grContAss1.PRM_Contact_Id__c = cont1.Id;
        grContAss1.PRM_InActive_Ind__c = True;
        insert grContAss1;     
        
        
        Test.startTest();  
        PRM_AddContToGrBasedOncondController.fetchContactGroups();
        PRM_AddContToGrBasedOncondController.fetchContacts(testspecialty.Id,cntGr.Id);
        List<PRM_Account_Contact_Relationship__c> lst = PRM_AddContToGrBasedOncondController.fetchContacts(testspecialty.Id,cntGr.Id);
        System.assert(lst.size() > 0, 'Error!!');
        PRM_AddContToGrBasedOncondController.insertContactGrContAssRecords(lstOfSelContacts,cntGr.Id);
        System.assert(PRM_AddContToGrBasedOncondController.insertContactGrContAssRecords(lstOfSelContacts,cntGr.Id).length() > 0, 'Error!!');
        Test.stopTest();        
    }
    
    static testmethod void methodToCoverFailedRec()
    {   
        Test.startTest(); 
        Account testAccount = new Account(); //Account
        testAccount.Name='Big Net';
        testAccount.Core_Intel_Partner_Alliance_PartnerGroup__c= true;
        testAccount.Core_Account_BU_Focus__c= 'CCG';
        testAccount.Core_IPA_Partner_Role__c='Service Provider';
        testAccount.BillingCity='City';
        testAccount.BillingStreet='Street';
        testAccount.BillingCountry='USA';
        testAccount.BillingCountryCode='USA';
        testAccount.BillingPostalCode='Postal code';
        testAccount.Core_Account_Tier__c = 'Tier1';
        insert testAccount;
        
        Contact cnt = new Contact();
        cnt.FirstName = 'Adrian';
        cnt.LastName =  'Contact1';
        cnt.Email  = 'adriancontact1@mailinator.com';
        cnt.AccountId = testAccount.Id;
        cnt.MailingCity = 'delhi';
        cnt.MailingCountry ='India';
        cnt.MailingPostalCode ='123456';
        cnt.Core_Login_Id__c = 'Bill243546';
        cnt.Core_IPA_PartnerRole__c = 'Service Provider';
        insert cnt;
        
        PRM_Specialty__c testspecialty = new PRM_Specialty__c();//Specialty
        testspecialty.Name = 'Addition Select Benefit';
        testspecialty.PRM_Description_Txt__c = 'Industrial Specialty';
        testspecialty.PRM_Access_Level_Nm__c = 'public';
        testspecialty.PRM_Funding_BU_Nm__c = 'CCG Sales Group';
        testspecialty.PRM_Role_Nm__c = System.Label.PRM_Service_Provider;
        testspecialty.PRM_Tier_Nm__c = 'Gold';
        testspecialty.PRM_Start_Date_Dt__c = system.today()+7;
        insert testspecialty;
        
        ChannelProgram cp = new ChannelProgram(); //Channel Program
        cp.Name='Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        insert cp;
        
        PRM_ContactRelationships__c contRelation = new PRM_ContactRelationships__c();   //Contact Relationship
        contRelation.Name='Primary Contact';
        contRelation.PRM_Contact_Relationship_Cd__c ='RELTNPRCTC';
        contRelation.PRM_Channel_Program_Id__c = cp.Id;
        contRelation.PRM_Default_Relationship_Ind__c = true;
        insert contRelation;
        
        PRM_Account_Contact_Relationship__c acctContRel=new PRM_Account_Contact_Relationship__c(); //Account Contact Relationship
        acctContRel.PRM_Account_Id__c=testAccount.Id;
        acctContRel.PRM_Contact_Id__c=cnt.Id;
        acctContRel.PRM_Relationship_Id__c=contRelation.Id;
        acctContRel.PRM_InActive_Ind__c=false;
        insert acctContRel;  
        
        Contact cont1 = new Contact();  //Contact
        cont1.AccountId=testAccount.Id;
        cont1.lastName='Corporation';
        cont1.FirstName='Acme';
        cont1.email='Acme@gmail.com';
        cont1.MailingCountry='USA';
        cont1.Core_Job_Function__c='Branch Manager';
        cont1.Core_eRPM_Language_Code__c='Eng';
        cont1.Core_IPA_PartnerRole__c = 'Service Provider';
        cont1.Core_Login_Id__c = 'abc';
        insert cont1;
        
        PRM_Account_Contact_Relationship__c acctContRel1=new PRM_Account_Contact_Relationship__c(); //Account Contact Relationship
        acctContRel1.PRM_Account_Id__c=testAccount.Id;
        acctContRel1.PRM_Contact_Id__c=cont1.Id;
        acctContRel1.PRM_Relationship_Id__c=contRelation.Id;
        acctContRel1.PRM_InActive_Ind__c=false;
        insert acctContRel1;  
        
        List<PRM_Account_Contact_Relationship__c> lstOfcotact = new List<PRM_Account_Contact_Relationship__c>();
        lstOfcotact.add(acctContRel);
        
        PRM_Contact_Group__c cntGr = new PRM_Contact_Group__c();
        cntGr.Name = 'IPA contact Group';
        cntGr.PRM_Description_Txt__c = 'New IPA Gr';
        insert cntGr;
        
        PRM_Contact_Group_Contact_Association__c cgcaObj = new PRM_Contact_Group_Contact_Association__c();
        cgcaObj.PRM_Contact_Id__c = acctContRel.PRM_Contact_Id__c;
        cgcaObj.PRM_Contact_Group_Id__c = cntGr.Id;
        cgcaObj.PRM_InActive_Ind__c = false;
        insert cgcaObj;
        
        PRM_AddContToGrBasedOncondController.fetchContacts(testspecialty.Id,cntGr.Id);  
        PRM_AddContToGrBasedOncondController.insertContactGrContAssRecords(lstOfcotact,cntGr.Id);
        System.assert(PRM_AddContToGrBasedOncondController.insertContactGrContAssRecords(lstOfcotact,cntGr.Id).length() > 0, 'Error!!');
            
        Test.stopTest();      
    }
    static testmethod void methodToCoverExistCGCARec()
    {   
        Test.startTest(); 
        Account testAccount = new Account(); //Account
        testAccount.Name='Big Net';
        testAccount.Core_Intel_Partner_Alliance_PartnerGroup__c= true;
        testAccount.Core_Account_BU_Focus__c= 'CCG';
        testAccount.Core_IPA_Partner_Role__c='Service Provider';
        testAccount.BillingCity='City';
        testAccount.BillingStreet='Street';
        testAccount.BillingCountry='USA';
        testAccount.BillingCountryCode='USA';
        testAccount.BillingPostalCode='Postal code';
        testAccount.Core_Account_Tier__c = 'Tier1';
        insert testAccount; 
        
        Contact cnt = new Contact();
        cnt.FirstName = 'Adrian';
        cnt.LastName =  'Contact1';
        cnt.Email  = 'adriancontact1@mailinator.com';
        cnt.AccountId = testAccount.Id;
        cnt.MailingCity = 'delhi';
        cnt.MailingCountry ='India';
        cnt.MailingPostalCode ='123456';
        cnt.Core_Login_Id__c = 'Bill243546';
        cnt.Core_IPA_PartnerRole__c = 'Service Provider';
        insert cnt;
        
        ChannelProgram cp = new ChannelProgram(); //Channel Program
        cp.Name='Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        insert cp;
        
        PRM_ContactRelationships__c contRelation = new PRM_ContactRelationships__c();   //Contact Relationship
        contRelation.Name='Primary Contact';
        contRelation.PRM_Contact_Relationship_Cd__c ='RELTNPRCTC';
        contRelation.PRM_Channel_Program_Id__c = cp.Id;
        contRelation.PRM_Default_Relationship_Ind__c = true;
        insert contRelation;
        
        PRM_Account_Contact_Relationship__c acctContRel=new PRM_Account_Contact_Relationship__c(); //Account Contact Relationship
        acctContRel.PRM_Account_Id__c=testAccount.Id;
        acctContRel.PRM_Contact_Id__c=cnt.Id;
        acctContRel.PRM_Relationship_Id__c=contRelation.Id;
        acctContRel.PRM_InActive_Ind__c=false;
        insert acctContRel;   
        
        List<PRM_Account_Contact_Relationship__c> lstOfcotact = new List<PRM_Account_Contact_Relationship__c>();
        lstOfcotact.add(acctContRel);
        
        PRM_Contact_Group__c cntGr = new PRM_Contact_Group__c();
        cntGr.Name = 'IPA contact Group';
        cntGr.PRM_Description_Txt__c = 'New IPA Gr';
        insert cntGr;
        
        PRM_Specialty__c testspecialty = new PRM_Specialty__c();//Specialty
        testspecialty.Name = 'Addition Select Benefit';
        testspecialty.PRM_Description_Txt__c = 'Addition Select Benefit';
        testspecialty.PRM_Access_Level_Nm__c = 'public';
        testspecialty.PRM_Funding_BU_Nm__c = 'CCG Sales Group';
        testspecialty.PRM_Role_Nm__c = System.Label.PRM_Service_Provider;
        testspecialty.PRM_Tier_Nm__c = 'Gold';
        testspecialty.PRM_Start_Date_Dt__c = system.today()+7;
        insert testspecialty;
        
        PRM_Contact_Group_Contact_Association__c cgcaObj = new PRM_Contact_Group_Contact_Association__c();
        cgcaObj.PRM_Contact_Id__c = acctContRel.PRM_Contact_Id__c;
        cgcaObj.PRM_Contact_Group_Id__c = cntGr.Id;
        cgcaObj.PRM_InActive_Ind__c = True;
        insert cgcaObj;
        
        PRM_AddContToGrBasedOncondController.fetchContacts(testspecialty.Id,cntGr.Id);   
        PRM_AddContToGrBasedOncondController.insertContactGrContAssRecords(lstOfcotact,cntGr.Id);
        System.assert(PRM_AddContToGrBasedOncondController.insertContactGrContAssRecords(lstOfcotact,cntGr.Id).length()> 0, 'Error!!');
        Test.stopTest();      
    }
    

}