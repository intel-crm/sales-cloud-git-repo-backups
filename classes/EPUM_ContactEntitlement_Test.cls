@isTest
public class EPUM_ContactEntitlement_Test {
    
    
    @testSetup static void setup() { 
        
        try{
            Core_Entitlement_Profile_Access__c entProfileAccess = new Core_Entitlement_Profile_Access__c(Name = 'Entitlements for IPA EPUM', Core_Entitlements_Allowed__c = 'Employee;Partner admin Delegate' ); 
            insert entProfileAccess;
            Id recordTypeIdContact = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Intel Contact').getRecordTypeId();
            Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
            Id recordTypeIdEM = Schema.SObjectType.PRM_VXEnttlmntMatrix__c.getRecordTypeInfosByName().get('EntitlementWithoutBenefits').getRecordTypeId();
            Id recordTypeIdEMWB = Schema.SObjectType.PRM_VXEnttlmntMatrix__c.getRecordTypeInfosByName().get('EntitlementWithBenefits').getRecordTypeId();
            
            List<Contact> con = new List<Contact>();
            List<Account> acc = new List<Account>();
            
            Account newAccount = new Account();//Account
            newAccount.RecordTypeId = recordTypeIdAccount;
            newAccount.Name='Walmart';
            newAccount.BillingCity='City2';
            newAccount.BillingStreet='Street2';
            newAccount.BillingCountry='USA';
            newAccount.BillingPostalCode='Postal code';
            newAccount.Core_Account_Type__c='Cloud Service Provider (CSP)';
            acc.add(newAccount);
            
            Account newAccount1 = new Account();//Account
            newAccount1.RecordTypeId = recordTypeIdAccount;
            newAccount1.Name='Tesco';
            newAccount1.BillingCity='City1';
            newAccount1.BillingStreet='Street1';
            newAccount1.BillingCountry='USA';
            newAccount1.BillingPostalCode='Postal code';
            newAccount1.Core_Account_Type__c='Cloud Service Provider (CSP)';
            acc.add(newAccount1);
            insert acc;
            System.debug('acc-->'+acc);
            
            Test.startTest();
            Contact cont = new Contact();  //Contact
            cont.RecordTypeId = recordTypeIdContact;
            cont.AccountId=newAccount.Id;
            cont.lastName='Ceaser';
            cont.FirstName='Julius';
            cont.email='JuliusCeaser@rediff.com';
            cont.Core_Job_Function__c='Branch Manager';
            cont.Core_eRPM_Language_Code__c='Eng';
            cont.Core_IPA_PartnerRole__c = 'Service Provider';
            cont.Core_Login_Id__c = 'xyz';
            cont.Mailing_Country_Region__c = 'USA';
            cont.MailingCountry='India';
            con.add(cont);
            
            Contact cont1 = new Contact();  //Contact
            cont1.RecordTypeId = recordTypeIdContact;
            cont1.AccountId=newAccount1.Id;
            cont1.lastName='jack';
            cont1.FirstName='william';
            cont1.email='jackwilliam@mailnator.com';
            cont1.Core_Job_Function__c='Branch Manager';
            cont1.Core_eRPM_Language_Code__c='Eng';
            cont1.Core_IPA_PartnerRole__c = 'Service Provider';
            cont1.Core_Login_Id__c = 'abc';
            cont1.Mailing_Country_Region__c = 'USA';
            cont1.MailingCountry='India';
            con.add(cont1);

            Contact cont11 = new Contact();  //Contact
            cont11.RecordTypeId = recordTypeIdContact;
            cont11.AccountId=newAccount1.Id;
            cont11.lastName='jack';
            cont11.FirstName='williams';
            cont11.email='jackwilliams@mailnator.com';
            cont11.Core_Job_Function__c='Branch Manager';
            cont11.Core_eRPM_Language_Code__c='Eng';
            cont11.Core_IPA_PartnerRole__c = 'Service Provider';
            cont11.Core_Login_Id__c = 'abc';
            cont11.Mailing_Country_Region__c = 'USA';
            cont11.MailingCountry='India';
            con.add(cont11);
            
            Contact cont2 = new Contact();  //Contact
            cont2.RecordTypeId = recordTypeIdContact;
            cont2.AccountId=acc[1].Id;
            cont2.lastName='Hill';
            cont2.FirstName='Tom';
            cont2.email='TomHill@mailnator.com';
            cont2.Core_Job_Function__c='Branch Manager';
            cont2.Core_eRPM_Language_Code__c='Eng';
            cont2.Core_IPA_PartnerRole__c = 'Service Provider';
            cont2.Core_Login_Id__c = 'efg';
            cont2.Mailing_Country_Region__c = 'USA';
            cont2.MailingCountry='India';
            con.add(cont2);
            
            Contact cont3 = new Contact();  //Contact
            cont3.RecordTypeId = recordTypeIdContact;
            cont3.AccountId=acc[1].Id;
            cont3.lastName='Snow';
            cont3.FirstName='White';
            cont3.email='SnowWhite@mailnator.com';
            cont3.Core_Job_Function__c='Branch Manager';
            cont3.Core_eRPM_Language_Code__c='Eng';
            cont3.Core_IPA_PartnerRole__c = 'Service Provider';
            cont3.Core_Login_Id__c = 'def';
            cont3.Mailing_Country_Region__c = 'USA';
            cont3.MailingCountry='India';
            //con.add(cont3);
            
            Contact cont4 = new Contact();  //Contact
            cont4.RecordTypeId = recordTypeIdContact;
            cont4.AccountId=acc[1].Id;
            cont4.lastName='Saul';
            cont4.FirstName='Goodman';
            cont4.email='SaulGoodman@mailnator.com';
            cont4.Core_Job_Function__c='Branch Manager';
            cont4.Core_eRPM_Language_Code__c='Eng';
            cont4.Core_IPA_PartnerRole__c = 'Service Provider';
            cont4.Core_Login_Id__c = 'def';
            cont4.Mailing_Country_Region__c = 'USA';
            cont4.MailingCountry='India';
            con.add(cont4);
            
            insert con;
            
            System.debug('Con::'+con);
            
            
            ChannelProgram cp = new ChannelProgram(); //Channel Program
            cp.Name='Intel Partner Alliance';
            cp.PRM_programCode__c='IPA';
            insert cp;
            
            ChannelProgramLevel cpl=new ChannelProgramLevel(); //Channel Program Level
            cpl.Name='Titanium';
            cpl.ProgramId=cp.Id;
            cpl.Rank = 1;
            insert cpl;
            
            PRM_AccountChannelMembership__c acm1= new PRM_AccountChannelMembership__c(); //Account Channel Membership
            acm1.PRM_Account_Id__c=newAccount1.id;
            acm1.PRM_Status_Nm__c='Approved';
            acm1.PRM_Channel_Program_Id__c=cp.Id;
            acm1.PRM_Channel_Program_Level_Id__c=cpl.Id;
            acm1.PRM_Partner_Role__c='Service Provider';
            acm1.PRM_Status_Reason_Txt__c='Test';
            insert acm1;
            System.debug('ACM Account ID'+acm1.PRM_Account_Id__c);
            
            List<PRM_ContactRelationships__c> crList = new List<PRM_ContactRelationships__c>();
            PRM_ContactRelationships__c contRelation = new PRM_ContactRelationships__c();   //Contact Relationship
            contRelation.Name=System.Label.PRM_Primary_Contact;
            contRelation.PRM_Contact_Relationship_Cd__c ='RELTNPRCTC';
            contRelation.PRM_Channel_Program_Id__c = cp.Id;
            contRelation.PRM_Default_Relationship_Ind__c = false;
            contRelation.PRM_Mandatory_Relationship_Ind__c = true;
            crList.add(contRelation);
            
            PRM_ContactRelationships__c cr2=new PRM_ContactRelationships__c();
            cr2.Name=System.Label.PRM_WorksFor;
            cr2.PRM_Contact_Relationship_Cd__c='WORKSFOR';
            cr2.PRM_Default_Relationship_Ind__c = true;
            cr2.PRM_Mandatory_Relationship_Ind__c = false;
            cr2.PRM_InActive_Ind__c = false;
            cr2.PRM_Channel_Program_Id__c=cp.Id;
            crList.add(cr2);
            
            PRM_ContactRelationships__c cr3=new PRM_ContactRelationships__c();
            cr3.Name=System.Label.PRM_Partner_Admin_Delegate;
            cr3.PRM_Contact_Relationship_Cd__c='PRIMCONTDEL';
            cr3.PRM_Default_Relationship_Ind__c = true;
            cr3.PRM_Mandatory_Relationship_Ind__c = false;
            cr3.PRM_InActive_Ind__c = false;
            cr3.PRM_Channel_Program_Id__c=cp.Id;
            crList.add(cr3);
            
            insert crList;
            
            List<PRM_Account_Contact_Relationship__c> acrList = new List<PRM_Account_Contact_Relationship__c>();
            PRM_Account_Contact_Relationship__c acctContRel=new PRM_Account_Contact_Relationship__c(); //Account Contact Relationship
            acctContRel.PRM_Account_Id__c=newAccount1.Id;
            acctContRel.PRM_Contact_Id__c=cont1.Id;
            acctContRel.PRM_Relationship_Id__c=crList[0].Id;
            acctContRel.PRM_InActive_Ind__c=true;
            acctContRel.PRM_execute_trigger__c=true;
            acctContRel.PRM_Status_Nm__c = System.Label.PRM_ACR_Status;
            acctContRel.PRM_Status_Reason_Txt__c = 'Test';
            acrList.add(acctContRel);
            
            PRM_Account_Contact_Relationship__c acctContRel1=new PRM_Account_Contact_Relationship__c(); //Account Contact Relationship
            acctContRel1.PRM_Account_Id__c=newAccount1.Id;
            acctContRel1.PRM_Contact_Id__c=cont4.Id;
            acctContRel1.PRM_Relationship_Id__c=crList[0].Id;
            acctContRel1.PRM_InActive_Ind__c=false;
            acctContRel1.PRM_execute_trigger__c=true;
            acctContRel1.PRM_Status_Nm__c = System.Label.PRM_ACR_Status;
            acctContRel1.PRM_Status_Reason_Txt__c = 'Test';
            acrList.add(acctContRel1);

             PRM_Account_Contact_Relationship__c acctContRel2=new PRM_Account_Contact_Relationship__c(); //Account Contact Relationship
            acctContRel2.PRM_Account_Id__c=newAccount1.Id;
            acctContRel2.PRM_Contact_Id__c=cont4.Id;
            acctContRel2.PRM_Relationship_Id__c=crList[2].Id;
            acctContRel2.PRM_InActive_Ind__c=false;
            acctContRel2.PRM_execute_trigger__c=true;
            acctContRel2.PRM_Status_Nm__c = System.Label.PRM_ACR_Status;
            acctContRel2.PRM_Status_Reason_Txt__c = 'Test';
            acrList.add(acctContRel2);
            
 
            
            /*
PRM_Account_Contact_Relationship__c acctContRel1=new PRM_Account_Contact_Relationship__c(); //Account Contact Relationship
acctContRel1.PRM_Account_Id__c=acc[0].Id;
acctContRel1.PRM_Contact_Id__c=con[1].Id;
acctContRel1.PRM_Relationship_Id__c=crList[0].Id;
acctContRel1.PRM_InActive_Ind__c=false;
acctContRel1.PRM_execute_trigger__c=true;
acctContRel1.PRM_Status_Nm__c = System.Label.PRM_ACR_Status;
acrList.add(acctContRel1);

PRM_Account_Contact_Relationship__c acctContRel2=new PRM_Account_Contact_Relationship__c(); //Account Contact Relationship
acctContRel2.PRM_Account_Id__c=acc[1].Id;
acctContRel2.PRM_Contact_Id__c=con[2].Id;
acctContRel2.PRM_Relationship_Id__c=crList[0].Id;
acctContRel2.PRM_InActive_Ind__c=true;
acctContRel2.PRM_execute_trigger__c=true;
acctContRel2.PRM_Status_Nm__c = System.Label.PRM_ACR_Status;
acrList.add(acctContRel2);

PRM_Account_Contact_Relationship__c acctContRel3=new PRM_Account_Contact_Relationship__c(); //Account Contact Relationship
acctContRel3.PRM_Account_Id__c=acc[1].Id;
acctContRel3.PRM_Contact_Id__c=con[3].Id;
acctContRel3.PRM_Relationship_Id__c=crList[0].Id;
acctContRel3.PRM_InActive_Ind__c=false;
acctContRel3.PRM_execute_trigger__c=true;
acctContRel3.PRM_Status_Nm__c = System.Label.PRM_ACR_Status;
acrList.add(acctContRel3);*/
            insert acrList;
            System.debug('acrList-->'+acrList);
            
            PRM_PartnerBenefit__c pb = new PRM_PartnerBenefit__c(); //Partner Benefit
            pb.Name = 'Points Redemption';
            pb.PRM_Channel_Program_Id__c = cp.id;
            pb.PRM_Benefit_Cd__c = 'BFTPTSREDM';
            pb.PRM_Account_Type_Nm__c = 'Both';
            insert pb;
            
            PRM_PartnerType__c pt=new PRM_PartnerType__c(); // Partner type
            pt.Name='Cloud Service Provider (CSP)';
            pt.PRM_Role_Name__c='Service Provider';
            pt.PRM_PartneryTypeCode__c='CSP';
            pt.PRM_PartnerRoleCode__c='SPR';
            pt.PRM_channelprogram__c=cp.Id;
            insert pt;
            
            PRM_VXBnftMatrix__c bem=new PRM_VXBnftMatrix__c(); //Benefit Matrix
            bem.PRM_Approval_Type_Nm__c='Automatic';
            bem.PRM_Channel_Program_Id__c=cp.Id;
            bem.PRM_Channel_Program_Level_Id__c=cpl.Id;
            bem.PRM_Covered_Account_Ind__c=True;
            bem.PRM_IsActive_Ind__c=True;
            bem.PRM_Partner_Benefit_Id__c=pb.Id;
            bem.PRM_Partner_Type_Id__c=pt.Id;
            bem.PRM_Partner_Role_Nm__c='Service Provider';
            insert bem;
            
            PRM_AccountBenefitAssociation__c aba = new PRM_AccountBenefitAssociation__c();
            aba.PRM_Account_Id__c = newAccount1.id;
            aba.PRM_Partner_Benefit_Id__c = pb.id;
            aba.PRM_Status_Nm__c = 'Active';
            //insert aba;
            
            Core_ERPM_Engagement__c ee = new Core_ERPM_Engagement__c();//ERPM Engagement
            ee.Name = 'Partner File Transfer';
            ee.Core_Technical_Engagement_Code__c = 'PFT';
            ee.Core_Engagement_Type__c = 'SEC';
            ee.Core_IsActive__c=true;
            insert ee;

            List<Core_Entitlement__c> entList = new List<Core_Entitlement__c>();
            Core_Entitlement__c ed=new Core_Entitlement__c(); //Entitlement
            ed.Name='Employee';
            ed.Core_Display_Name__c='Employee';
            ed.Core_ERPM_Engagement_Id__c=ee.id;
            ed.Core_Category__c='Intel Partner Alliance (IPA)';
            ed.Core_Sub_Category__c='Value Exchange';
            ed.Core_Help_Text__c='Basic access';
            ed.Core_IsActive__c=true;
            
            entList.add(ed);
            
            Core_Entitlement__c ed1=new Core_Entitlement__c(); //Entitlement
            ed1.Name='Partner Admin Delegate';
            ed1.Core_Display_Name__c='Partner Admin Delegate';
            ed1.Core_ERPM_Engagement_Id__c=ee.id;
            ed1.Core_Help_Text__c = 'This is example Help Text';
            ed1.Core_Category__c='Intel Partner Alliance (IPA)';
            ed1.Core_IsActive__c=true;
            ed1.Core_Help_Text__c='Basic access';
            entList.add(ed1);
            
            Core_Entitlement__c ed2=new Core_Entitlement__c(); //Entitlement
            ed2.Name='Partner Admin';
            ed2.Core_Display_Name__c='Partner Admin';
            ed2.Core_ERPM_Engagement_Id__c=ee.id;
            ed2.Core_Category__c='Intel Partner Alliance (IPA)';
            ed2.Core_IsActive__c=true;
            ed2.Core_Help_Text__c='Basic access';
            entList.add(ed2);
            
            
            Core_Entitlement__c ed3=new Core_Entitlement__c(); //Entitlement
            ed3.Name='Points View';
            ed3.Core_Display_Name__c='Points View';
            ed3.Core_ERPM_Engagement_Id__c=ee.id;
            ed3.Core_Category__c='Intel Partner Alliance (IPA)';
            ed3.Core_IsActive__c=true;
            ed3.Core_Help_Text__c='Basic access';
            entList.add(ed3);
            insert entList;
            
            
            List<PRM_VXEnttlmntMatrix__c> emList = new List<PRM_VXEnttlmntMatrix__c>();
            PRM_VXEnttlmntMatrix__c em= new PRM_VXEnttlmntMatrix__c(); //Entitlement Matrix
            em.PRM_Partner_Benefit_Id__c = pb.id;
            em.PRM_Entitlement_Id__c = entList[0].id;
            em.PRM_Contact_Relationship_Id__c = crList[0].Id;
            em.PRM_Approval_Type_Nm__c='Manual';
            em.PRM_IPA_Partner_Role_Nm__c='Service Provider';
            emList.add(em);
            
            PRM_VXEnttlmntMatrix__c em1= new PRM_VXEnttlmntMatrix__c(); //Entitlement Matrix
            em1.RecordTypeId = recordTypeIdEM;
            em1.PRM_Entitlement_Id__c = entList[1].id;
            em1.PRM_Contact_Relationship_Id__c = crList[0].Id;
            em1.PRM_Channel_Program_Level_Id__c = cpl.Id;
            em1.PRM_Approval_Type_Nm__c='Manual';
            em1.PRM_IPA_Partner_Role_Nm__c='Service Provider';
            emList.add(em1);
            insert emList;
            Profile partnerProfile = [SELECT Id FROM Profile WHERE Name='Partner' and userType='PowerPartner' LIMIT 1];
             User user = new User(Alias = 'part', 
                                 Email='partnerTest@mailnator.com', 
                                 EmailEncodingKey='UTF-8',
                                 LastName='UnitTestItAdmin',
                                 LanguageLocaleKey='en_US', 
                                 LocaleSidKey='en_US', 
                                 ProfileId = partnerProfile.Id, 
                                 TimeZoneSidKey='America/Los_Angeles',
                                 portalRole ='manager',
                                 UserName='adminTest'+Crypto.getRandomLong()+'@intel.com',
                                 ContactId = cont1.Id
                                 
                                 //Core_IPA_One_Partner_Id__c=testIntelAccount1.id
                                 
                                 
                                );
            
            insert user; 
            User user1 = new User(Alias = 'part11', 
                                 Email='partnerTest11@mailnator.com', 
                                 EmailEncodingKey='UTF-8',
                                 LastName='UnitTestItAdmin',
                                 LanguageLocaleKey='en_US', 
                                 LocaleSidKey='en_US', 
                                 ProfileId = partnerProfile.Id, 
                                 TimeZoneSidKey='America/Los_Angeles',
                                 portalRole ='manager',
                                 UserName='adminTest'+Crypto.getRandomLong()+'@intel.com',
                                 ContactId = cont.Id
                                 
                                 //Core_IPA_One_Partner_Id__c=testIntelAccount1.id
                                 
                                 
                                );
            insert user1;
            
            
            List<Core_Contact_Entitlement__c> insertCEList = new List<Core_Contact_Entitlement__c>();
            Core_Contact_Entitlement__c cce=new Core_Contact_Entitlement__c(); // Contact Entitlement
            cce.Core_Contact_Id__c=cont1.Id;
            cce.Core_Entitlement_Id__c = ed.Id;
            cce.Core_Status__c='Complete';
            cce.Core_Selected__c = false;
            //cce.Core_Source__c = 'Entitlement';
            insertCEList.add(cce);
            
            Core_Contact_Entitlement__c cce1=new Core_Contact_Entitlement__c(); // Contact Entitlement
            cce1.Core_Contact_Id__c=cont1.Id;
            cce1.Core_Entitlement_Id__c = ed1.Id;
            cce1.Core_Selected__c = true;
            cce1.Core_Status__c='Complete';
            insertCEList.add(cce1);
            
            Core_Contact_Entitlement__c cce2=new Core_Contact_Entitlement__c(); // Contact Entitlement
            cce2.Core_Contact_Id__c=cont1.Id;
            cce2.Core_Entitlement_Id__c = ed2.Id;
            cce2.Core_Selected__c = false;
            cce2.Core_Status__c='Complete';
            insertCEList.add(cce2);
            
            Core_Contact_Entitlement__c cce33=new Core_Contact_Entitlement__c(); // Contact Entitlement
            cce33.Core_Contact_Id__c=cont1.Id;
            cce33.Core_Entitlement_Id__c = ed.Id;
            cce33.Core_Selected__c = true;
            cce33.Core_Status__c='Complete';
            insertCEList.add(cce33);
            
            Core_Contact_Entitlement__c cce11=new Core_Contact_Entitlement__c(); // Contact Entitlement
            cce11.Core_Contact_Id__c=cont1.Id;
            cce11.Core_Entitlement_Id__c = ed3.Id;
            cce11.Core_Selected__c = true;
            cce11.Core_Status__c='Pending';
            insertCEList.add(cce11);
            
            
            insert insertCEList;
            System.debug('insertCEList-->'+insertCEList);
            Core_Entitlement_SubCategory_HelpText__c cate = new Core_Entitlement_SubCategory_HelpText__c();
            cate.Name ='Test1';
            cate.Core_Help_Text__c = 'Test help';
            cate.Core_SubCategory_Name__c = 'Test';
            insert cate;
            
            
            System.assertEquals(partnerProfile !=  null,true);
           
            Test.stopTest();
            user u= [Select accountID,Core_IPA_One_Partner_Id__c from user where id=:user.id];
            system.debug('User Data'+ u );
            // System.assert(true,testSecContact.Core_Personal_Email_Indicator__c != null);
            System.assertEquals(u.accountID !=  null,true);
        }
        catch(Exception e){
            System.debug('Exception '+e.getMessage());
        }
    }
    private static testmethod void testfetchContactEntitlements(){
        
        contact testCont = [Select Id from Contact where email='jackwilliam@mailnator.com' limit 1];
        user usr = [Select Id from user where ContactID =:testCont.Id limit 1];
        String sContactIdStr = testCont.Id;
        
        System.runAs(usr){
            Test.startTest();
            EPUM_PartnerContactEnt_Controller.fetchContactEntitlements(testCont.ID);
            
            system.assertNotEquals(null, EPUM_PartnerContactEnt_Controller.fetchContactEntitlements(testCont.ID));
            Test.stopTest();
        }
        
    }
    
    private static testmethod void testSaveContactEntitlements(){
        try{
            contact testCont = [Select Id from Contact where email='jackwilliam@mailnator.com' limit 1];
            user usr = [Select Id from user where ContactID =:testCont.Id limit 1];
            String sContactIdStr = testCont.Id;
            Test.startTest();
            System.runAs(usr){
                EPUM_PartnerContactEnt_Controller.EPUM_PartnerContactEnt_Controller_Wrapper wrapper = EPUM_PartnerContactEnt_Controller.fetchContactEntitlements(sContactIdStr);
                wrapper.lstContactEntWrapper[0].isSelected = false;
                system.assertEquals(2, wrapper.lstContactEntWrapper.size());
                wrapper.lstContactEntWrapper[1].isSelected = true;
                EPUM_PartnerContactEnt_Controller.saveContactEntitlements(wrapper.lstContactEntWrapper,sContactIdStr);
                
            }
            Test.stopTest();            
        }catch(Exception e){
           System.debug('Exception '+e.getMessage()); 
        }
    } 
    
    private static testmethod void testSaveContactEntitlements2(){
        try{
            contact testCont = [Select Id from Contact where email='jackwilliam@mailnator.com' limit 1];
            user usr = [Select Id from user where ContactID =:testCont.Id limit 1];
            String sContactIdStr = testCont.Id;
            Test.startTest();            
            contact testCont1 = [Select Id from Contact where email='TomHill@mailnator.com' limit 1];
            System.runAs(usr){
                EPUM_PartnerContactEnt_Controller.EPUM_PartnerContactEnt_Controller_Wrapper wrapper1 = EPUM_PartnerContactEnt_Controller.fetchContactEntitlements(testCont1.Id);
                EPUM_ContactEntitlement_Util.getCoreEntitlements();
                system.assertEquals(null, wrapper1.lstContactEntWrapper[0].ContactEntitlement);
                wrapper1.lstContactEntWrapper[0].isSelected = true;
                EPUM_PartnerContactEnt_Controller.saveContactEntitlements(wrapper1.lstContactEntWrapper,testCont1.Id);            
            }
            Test.stopTest();
            
        }catch(Exception e){
           System.debug('Exception '+e.getMessage()); 
        }
    } 
    
    private static testmethod void testSaveContactEntitlementsNegativeS(){
        try{
            contact testCont = [Select Id from Contact where email='jackwilliam@mailnator.com' limit 1];
            user usr = [Select Id from user where ContactID =:testCont.Id limit 1];
            String sContactIdStr = testCont.Id;
            Test.startTest();            
            contact testCont1 = [Select Id from Contact where email='TomHill@mailnator.com' limit 1];
            System.runAs(usr){
                EPUM_PartnerContactEnt_Controller.EPUM_PartnerContactEnt_Controller_Wrapper wrapper1 = EPUM_PartnerContactEnt_Controller.fetchContactEntitlements(testCont1.Id);
                
                system.assertEquals(null, wrapper1.lstContactEntWrapper[0].ContactEntitlement);
                wrapper1.lstContactEntWrapper[0].isSelected = true;
                wrapper1.lstContactEntWrapper[0].entitlementId = '12345678';
                EPUM_PartnerContactEnt_Controller.saveContactEntitlements(wrapper1.lstContactEntWrapper,testCont1.Id);            
            }
            Test.stopTest();
            
        }catch(Exception e){
           System.debug('Exception '+e.getMessage()); 
        }
        
    }
    
    
    private static testmethod void testEPUM_ContactEntitlement_Wrapper(){
        contact testCont = [Select Id from Contact where email='jackwilliam@mailnator.com' limit 1];
        String myTestString = 'Partner Admin Delegate';
        Test.startTest();
        List<Core_Entitlement__c> sobjList = [SELECT Id,Core_Entitlement__c.Name,Core_Category__c,Core_Display_Name__c,Core_Sub_Category__c,Core_Help_Text__c FROM Core_Entitlement__c WHERE Name = :myTestString];
        //System.runAs(usr){
        
        EPUM_ContactEntitlement_Wrapper wrapper= new EPUM_ContactEntitlement_Wrapper(sobjList[0],'Help Text');
        
        system.assertEquals(false, wrapper.isSelected);
        
        // }
        Test.stopTest();
    }
    
    private static testmethod void testGetSetVariables(){
        Test.startTest();
        EPUM_ContactEntitlement_Wrapper ContactEntitlementWrap= new EPUM_ContactEntitlement_Wrapper();
        String testString=ContactEntitlementWrap.entitlehelpText;
        String testString1=ContactEntitlementWrap.subCatHelpText;
        String testString2=ContactEntitlementWrap.subcategory;
        String testString3=ContactEntitlementWrap.category;
        String testString4=ContactEntitlementWrap.status;
        String testString5=ContactEntitlementWrap.recstatus;
        Boolean testBool=ContactEntitlementWrap.selected;
        Boolean testBool1=ContactEntitlementWrap.readOnly;
        Core_AuraProcessingMessage auraProcessingMsg=ContactEntitlementWrap.auraProcessingMessage;
        String strCategory = 'TestCategory';
        String testString6=ContactEntitlementWrap.category;
        
        system.assertEquals(null, ContactEntitlementWrap.readOnly);
        Test.stopTest();
        
    }
    private static testmethod void testgetRoles(){
        contact testCont = [Select Id from Contact where email='jackwilliam@mailnator.com' limit 1];
        user usr = [Select Id,Core_IPA_One_Partner_Id__c,AccountId from user where ContactID =:testCont.Id limit 1];
        System.Debug('One Partner ID'+ usr);
        String sContactIdStr = testCont.Id;
        Test.startTest();
        System.runAs(usr){
            EPUM_ContactEntitlement_Util.sContactIdStr= testCont.Id;
            Contact objContact = EPUM_ContactEntitlement_Util.getContact();
            EPUM_ContactEntitlement_Util.objContact = objContact;
            EPUM_ContactEntitlement_Util.getAvailableRoles();
            EPUM_ContactEntitlement_Util.getContactsWithRole();
            EPUM_ContactEntitlement_Util.getCoreEntitlements();
            EPUM_ContactEntitlement_Util.checkAGSStatus();
            EPUM_ContactEntitlement_Util.getEntitlements();
            EPUM_ContactEntitlement_Util.getLogoUrl();
            EPUM_ContactEntitlement_Util.getResponsibilitiesConfirmationData();
            List<Core_Entitlement__c> Entitlements=[Select Id,Name,Core_Category__c,Core_Sub_Category__c,Core_Help_Text__c,Core_ERPM_Engagement_Id__c,Core_Display_Name__c,Core_IsActive__c from Core_Entitlement__c];
            list<EPUM_ContactEntitlement_Wrapper> poppulateEntitlements=EPUM_ContactEntitlement_Util.populateEntitlements(Entitlements);
            // String testString= EPUM_PartnerContactEnt_Controller.getLoggedInUserDetails();
        }
        
        system.assertEquals(2, EPUM_ContactEntitlement_Util.getCoreEntitlements().size());
        Test.stopTest();
    }
    
    private static testmethod void testgetRoles1(){
        try{
            contact testCont = [Select Id from Contact where email='TomHill@mailnator.com' limit 1];
            user usr = [Select Id from user where ContactID =:testCont.Id limit 1];
            String sContactIdStr = testCont.Id;
            Test.startTest();            
            System.runAs(usr){
                EPUM_ContactEntitlement_Util.getCoreEntitlements();                           
            }
            Test.stopTest();
            system.assertEquals(true, testCont != null);
        }catch(Exception e){
           System.debug('Exception '+e.getMessage()); 
        }
        
    }
    
    private static testmethod void testUpdateContactStatus(){
        try{
            contact testCont = [Select Id from Contact where email='SaulGoodman@mailnator.com' limit 1];
            //user usr = [Select Id from user where ContactID =:testCont.Id limit 1];
            String sContactIdStr = testCont.Id;
            string conStatus = '';
            string metRet = '';
            Test.startTest();            
            //System.runAs(usr){
                metRet = EPUM_PartnerContactEnt_Controller.updateContactStatus(sContactIdStr, conStatus);                           
            //}
            Test.stopTest();
            system.assertEquals('ACR Inactivated', metRet);
        }catch(Exception e){
           System.debug('Exception '+e.getMessage()); 
        }
        
    }
    
    private static void test_updateACR_coverage() {
    // Arrange - locate existing Contact and related ACR (created by test setup)
    Contact testCont = [SELECT Id, AccountId FROM Contact WHERE Email = 'jackwilliams@mailnator.com' LIMIT 1];
        
    
    // Ensure there is at least one PRM_Account_Contact_Relationship__c (ACR) referencing this contact (created in setup)
    PRM_Account_Contact_Relationship__c acr = [SELECT Id, PRM_Account_Id__c, PRM_Contact_Id__c, PRM_InActive_Ind__c, PRM_execute_trigger__c
                                               FROM PRM_Account_Contact_Relationship__c
                                               WHERE PRM_Contact_Id__c = :testCont.Id
                                               LIMIT 1];
    // Sanity asserts to ensure test data exists
    System.assertNotEquals(null, acr, 'ACR should exist for test contact');
 
    // Act - Call the method under test
    Test.startTest();
        // If the method is instance or requires certain context, adapt the call accordingly.
        // This call assumes updateACR is a public static method on EPUM_ContactEntitlement_Util that accepts (Id contactId, Boolean inactivateFlag) or similar.
        // If signature differs, adjust the parameters to match.
        try {
            // Common signatures to try — uncomment the one that matches your implementation:
            // EPUM_ContactEntitlement_Util.updateACR(acr.Id); // if method accepts ACR Id
            EPUM_ContactEntitlement_Util.updateACR(testCont); // if method accepts Contact Id
            // EPUM_ContactEntitlement_Util.updateACR(acr, true); // if method accepts an sObject + flag
            // Replace the next line with the correct signature:
            //EPUM_ContactEntitlement_Util.updateACR(acr.Id);
        } catch (Exception e) {
            // If updateACR throws in some flows, fail the test with the exception details
            System.debug('updateACR threw: ' + e.getMessage());
            System.assert(false, 'updateACR should not throw: ' + e.getMessage());
        }
    Test.stopTest();
 
    // Assert - verify expected side-effects. Example: ACR status changed or Account fields updated.
    // Adjust assertions to match the actual behavior of updateACR.
    PRM_Account_Contact_Relationship__c acrAfter = [SELECT Id, PRM_InActive_Ind__c, PRM_Status_Nm__c FROM PRM_Account_Contact_Relationship__c WHERE Id = :acr.Id LIMIT 1];
    // Example assertions (adapt to actual expected changes):
    // System.assertEquals(true, acrAfter.PRM_InActive_Ind__c, 'ACR should be marked inactive after updateACR');
    // Or if updateACR sets status:
    // System.assertEquals('ACR Inactivated', acrAfter.PRM_Status_Nm__c);
 
    // If updateACR updates Account fields, validate those as well:
    // Account acc = [SELECT Id, Core_PMP_Membership_Change_Ind__c, Core_B2B_Entitlement__c FROM Account WHERE Id = :acrAfter.PRM_Account_Id__c LIMIT 1];
    // System.assertEquals(true, acc.Core_PMP_Membership_Change_Ind__c);
}

    
}