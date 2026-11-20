/**************************************************************************************
Apex Class Name: Core_Contact_EmailChange_Handler_Test
Version     : 1.0 
Created Date: 20 Dec 2016
Description    : This class is Test class for Core_Contact_EmailChange_Handler
*************************************************************************************/
@isTest
public class Core_Contact_EmailChange_Handler_Test{
    static testMethod void contactStatusUpdate(){
       
        Profile itAdminPrf = [select id, name from Profile where name = 'System Administrator' Limit 1];
        
        User itAdminUser = new User(Alias = 'itAdmx2', 
                                    Email='itAdminTestx2@intel.com', 
                                    EmailEncodingKey='UTF-8',
                                    LastName='UnitTestAdmin',
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    ProfileId = itAdminPrf.Id, 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    UserName='salesRepTestx2@intel.com');
        insert itAdminUser;
        
        Profile aePrf = [select id, name from Profile where name = 'A&E User' Limit 1];
        
        User aeUser = new User(Alias = 'itAdmx22', 
                               Email='itAdminTestx22@intel.com', 
                               EmailEncodingKey='UTF-8',
                               LastName='UnitTestAdmin2',
                               LanguageLocaleKey='en_US', 
                               LocaleSidKey='en_US', 
                               ProfileId = aePrf.Id, 
                               TimeZoneSidKey='America/Los_Angeles',
                               UserName='salesRepTestx22@intel.com');
        insert aeUser;
        
        
        system.runas(aeUser){         
            //Creates a sample 'Account' record
            Account objAcc = new Account();
            objAcc.Name = 'test';
            objAcc.Core_Account_Type__c = 'Distributor';
            objAcc.Core_Sales_Group__c = 'Global Accounts';
            objAcc.Industry = 'Agriculture';
            objAcc.Core_Account_Legal_Name__c = 'abc1234account';
            objAcc.Core_CIM_ID__c = '11545156';
            objAcc.Core_GEO__c = 'ASMO';
            objAcc.Core_IBL_Flag__c = false;
            objAcc.BillingCity = 'folsom';
            objAcc.BillingCountry = 'GUY';
            objAcc.BillingStreet = '13254 E vookbrrok dfdsf';
            objAcc.Core_CNDA_Number__c = '123456';
            insert objAcc; 
            System.assertNotEquals(null, objAcc.Id);
            
            //Creates a sample 'Contact' record
            List<Contact> conlist = new List<Contact>();
            Contact objCon = new Contact();
            objCon.FirstName = 'TestCon'; 
            objCon.LastName = 'TestCon1'; 
            objCon.AccountId = objAcc.id;
            objCon.Email = 'testcontactx@test.com';
            conlist.add(objCon);
            Contact objCon2 = new Contact();
            objCon2.FirstName = 'TestCon2'; 
            objCon2.LastName = 'TestCon2'; 
            objCon2.AccountId = objAcc.id;
            objCon2.Email = 'testcontactx1@test.com';
            conlist.add(objCon2);
            insert conlist;
            System.assertNotEquals(null, objCon.Id);
            
            
            System.runAs(itAdminUser){          
                
                
                //Creats sample record with retrived profile name to 'Contact Access Profile' custom settings
                Core_Contact_Access_Profiles__c conAccess = new Core_Contact_Access_Profiles__c();
                conAccess.Name = aePrf.name;
                conAccess.Core_Profile_Name__c = aePrf.name;
                insert conAccess;
                System.assertNotEquals(null, conAccess.Id);
                
                //Put an entry in 'Trigger Executions' custom settings so the Contact trigger gets exectued
                Core_Trigger_Executions__c triggerExe = new Core_Trigger_Executions__c();
                triggerExe.Name = 'ContactEmailChangeUpdate';
                triggerExe.Core_Active__c = true;
                triggerExe.Core_Class_Name__c = 'Core_Contact_EmailChange_Handler';
                triggerExe.Core_Description__c = 'test description';
                triggerExe.Core_Object__c = 'Contact';
                triggerExe.Core_Trigger_Events__c = 'After Update';
                insert triggerExe;
                System.assertNotEquals(null, triggerExe.Id);
                
                //Put an entry in 'Trigger Executions' custom settings so the Contact trigger gets exectued
                Core_Trigger_Executions__c triggerExe2 = new Core_Trigger_Executions__c();
                triggerExe2.Name = 'contactJobFunction';
                triggerExe2.Core_Active__c = true;
                triggerExe2.Core_Class_Name__c = 'Core_ContactHandler';
                triggerExe2.Core_Description__c = 'test description';
                triggerExe2.Core_Object__c = 'Contact';
                triggerExe2.Core_Trigger_Events__c = 'After Insert After Update';
                insert triggerExe2;
                System.assertNotEquals(null, triggerExe2.Id);
            
                //Creates sample 'ERPM Engagement' record as it is required in Entitlement record
                Core_ERPM_Engagement__c objERPMEngmt = new Core_ERPM_Engagement__c();
                objERPMEngmt.name = 'TestErpmName';
                objERPMEngmt.Core_IsActive__c = true;
                insert objERPMEngmt;
                System.assertNotEquals(null, objERPMEngmt.Id);
                
                //Creates sample 'AGS role' record as it is required in Entitlement record 
                Core_AGS_Role__c objAGSRole = new Core_AGS_Role__c();
                objAGSRole.name= 'TestAGSRoleName';
                objAGSRole.Core_IsActive__c = true;
                insert objAGSRole;
                System.assertNotEquals(null, objAGSRole.Id);
                
                //Creates a sample 'Entitlement' record
                Core_Entitlement__c objEntitlement = new Core_Entitlement__c();
                objEntitlement.name = 'TestEntitlementName';
                objEntitlement.Core_Display_Name__c = 'TestEntitlementName';
                objEntitlement.Core_IsActive__c = true;
                objEntitlement.Core_AGS_Role_Id__c = objAGSRole.id;
                objEntitlement.Core_Category__c = 'Support';
                objEntitlement.Core_ERPM_Engagement_Id__c = objERPMEngmt.id;
                insert objEntitlement;
                System.assertNotEquals(null, objEntitlement.Id);
                
                Core_Entitlement__c objEntitlement1 = new Core_Entitlement__c();
                objEntitlement1.name = 'TestEntitlementName1';
                objEntitlement1.Core_Display_Name__c = 'TestEntitlementName1';
                objEntitlement1.Core_IsActive__c = true;
                objEntitlement1.Core_AGS_Role_Id__c = objAGSRole.id;
                objEntitlement1.Core_Category__c = 'Support';
                objEntitlement1.Core_ERPM_Engagement_Id__c = objERPMEngmt.id;
                insert objEntitlement1;
                System.assertNotEquals(null, objEntitlement1.Id);
                
                //Creates a sample 'Contact Entitlement' record
                
                List<Core_Contact_Entitlement__c> lstentitle = new List<Core_Contact_Entitlement__c>();
                Core_Contact_Entitlement__c objConEntitlement = new Core_Contact_Entitlement__c();
                objConEntitlement.Core_Contact_Id__c = objCon.id;
                objConEntitlement.Core_Entitlement_Id__c = objEntitlement.id;
                objConEntitlement.Core_Selected__c = false;
                insert objConEntitlement;
                
                lstentitle.add(objConEntitlement);
                
                Core_Contact_Entitlement__c objConEntitlement1 = new Core_Contact_Entitlement__c();
                objConEntitlement1.Core_Contact_Id__c = objCon.id;
                objConEntitlement1.Core_Entitlement_Id__c = objEntitlement1.id;
                objConEntitlement1.Core_Selected__c = true;
                insert objConEntitlement1;
                
                lstentitle.add(objConEntitlement1);
                 Test.StartTest();
                conlist[0].email='testcontact@domainchange.com';
                conlist[1].email='namechange@test.com';
                update conlist;
                Test.StopTest();
                //To make sure contact is updated 
                Contact objConRecord = [SELECT Id,Email,Core_ERPM_Integration_Status__c,Core_AGS_Integration_Status__c FROM Contact WHERE Id =: conlist[0].id];
                System.assertEquals('In-Progress',objConRecord.Core_ERPM_Integration_Status__c);
                
            }   
        }
        Core_Contact_EmailChange_Handler.sendSingleMail(
            [select id, email, owner.email, Core_IPS_Intel_Support_Owner__r.email,Core_ERPM_Integration_Status__c, Core_AGS_Integration_Status__c, 
             ownerid, Core_IPS_Intel_Support_Owner__c, account.ownerID, lastName from contact LIMIT 1], 
            [select Id, Name, Subject, HtmlValue, Body from EmailTemplate where Name =:System.Label.core_Account_EmailTemplate LIMIT 1], 
            [select Id from User where Profile.Name = 'System Administrator' Limit 1].Id, 'AllEntitlementName', 'testing@intel.com');
     
    }
}