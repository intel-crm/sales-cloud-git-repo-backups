/***************************************************************************************************
Class Name      : Core_IPS_Core_Question_Handler_Test
Class Type      : Test Class 
Version         : 1.0 
Created Date    : 28 Dec 2017
Function        : This class contains test coverage for Core_IPS_Core_Question_Handler class.
Input Parameters  : None  
Output Parameters  : None
Description      : This class contains unit test scenarios for Core_IPS_Core_Question_Handler class.
Used in         : None
Modification Log   :  
Developer                 Date                   Description
----------------------------------------------------------------------------                 
Yogesh Sharma           28/12/2015             Created
****************************************************************************************************/   

@isTest
public class Core_IPS_Core_Question_Handler_Test {
  /***************************************************************************************************
  Method Name      : updateAssignedEnvironmentVariablesFromCoreQuestionTest
  Method Type      : void
  Version         : 1.0 
  Created Date    : 05 Nov 2015
  Description      : This method is used for cover the updateAssignedEnvironmentVariablesFromCoreQuestion method of Core_IPS_Core_Question_Handler class.
  Scenario Type:  
  Modification Log   :
  * Developer                   Date                   Description
  * ----------------------------------------------------------------------------                 
  * Yogesh Sharma             28/12/2017             Created
  ****************************************************************************************************/
  public static testmethod void updateAssignedEnvironmentVariablesFromCoreQuestionTest(){
    Test.startTest();
      Map<String,ID> profiles = new Map<String,ID>();
            List<String> strProf = new List<String>();
            strProf.add('System Administrator');
            strProf.add('IPS Data Migration');
            List<Profile> ProfileList = [select id, name from Profile where name IN : strProf];
            
            for(Profile prf : ProfileList){
                profiles.put(prf.name, prf.id); 
            }
            
            //Create Users
            List<User> ListOfUser = new List<User>();
            ListOfUser = TestUtilities.getListOfUser(1); 
            ListOfUser.get(0).ProfileId =  profiles.get('System Administrator');
            insert ListOfUser.get(0);
      
          //Get intelSupportOwner Id (User Id)
            Id intelSupportOwner = ListOfUser.get(0).id;
            System.runAs(ListOfUser.get(0)){
              
              //Create Custom Setting - Trigger Executions
            Core_Trigger_Executions__c  TriggerExecution = new Core_Trigger_Executions__c();
            TriggerExecution.Name = 'updateAssignedEnvironmentVarFromEDQ';
            TriggerExecution.Core_Active__c = true;
            TriggerExecution.Core_Class_Name__c ='Core_IPS_Core_Question_Handler';
            TriggerExecution.Core_Description__c = 'This method takes a list of Core_IPS_Question__c records whose status field is changed and then update the child object Core_Assigned_Environment_Variables__c record status field value accordingly as per parent object status value.';
            TriggerExecution.Core_Object__c = 'Core_IPS_Question__c';
            TriggerExecution.Core_Trigger_Events__c = 'After Update';
            insert TriggerExecution; 
            System.assert(TriggerExecution.id != null);
            
            //Create Support Org
            List<Core_IPS_Product_Organization__c> ListOfSupportOrg  = TestUtilities.getListOfSupportOrg(2);
            insert ListOfSupportOrg;
            
            System.assert(ListOfSupportOrg != null, 'Record not created');
            
            //Create Accounts
              List<Account> ListOfAccounts = TestUtilities.getListOfAccounts(2);
              insert ListOfAccounts;
              System.assert(ListOfAccounts[0].Id != null, 'Record not created');
              
              //Create Contacts
              List<Contact> ListOfContacts = TestUtilities.getListOfContact(1);
              for(Contact ContactRec : ListOfContacts){
                  ContactRec.Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
                  ContactRec.core_ips_Active__c=true;
                  ContactRec.Accountid = ListOfAccounts.get(0).Id; 
              }
              insert ListOfContacts;
              System.assert(ListOfContacts[0].Id != null, 'Record not created');
              
              
              //Create Products
              Integer counter = 0;
              
              List<Product2> ListOfProducts = TestUtilities.getListOfProduct(2);
              for(Product2 Product : ListOfProducts){
                  if(counter==0){
                      Product.Core_Hierarchy_ID__c = '43';
                      Product.Core_Hierarchy_Name__c = 'ProdHierarchyName';
                      Product.Core_Unique_ID__c = 'Product12345';
                      Product.Core_Code_Name__c = 'ProductCoreCodeName';
                  }else{
                      Product.Core_Hierarchy_ID__c = '59';
                      Product.Core_Hierarchy_Name__c = 'ProdHierarchyName59';
                      Product.Core_Unique_ID__c = 'Product59';
                      Product.Core_Code_Name__c = 'ProductCoreCodeName59';
                      
                  }
                  counter++;
              }
              insert ListOfProducts;
              System.assert(ListOfProducts[0].id != null,'Record created or not.');
              
              
              //Create Supported products
              counter = 0;
              List<Core_IPS_Supported_Product__c> ListOfSupportedProduct = TestUtilities.getListOfSupportedProduct(2);
              for(Core_IPS_Supported_Product__c SupportedProduct : ListOfSupportedProduct){
                  if(counter==0){
                      SupportedProduct.Core_Product__c = ListOfProducts.get(0).id;
                      SupportedProduct.Core_Product_Organization__c = ListOfSupportOrg.get(0).id;
                  }else{
                      SupportedProduct.Core_Product__c = ListOfProducts.get(1).id;
                      SupportedProduct.Core_Product_Organization__c = ListOfSupportOrg.get(1).id;
                  }
                  counter++;
              }
              insert ListOfSupportedProduct;
              System.assert(ListOfSupportedProduct[0].id != null,'Record created or not.');
  
            //Get Record Type
            Id edqRecordTypeId = Schema.SObjectType.Core_IPS_Question__c.getRecordTypeInfosByName().get('Environment Detail Question').getRecordTypeId();
            
            //Create Core Question
            Core_IPS_Question__c cq = new Core_IPS_Question__c();
            cq.recordTypeId = edqRecordTypeId;
            cq.Core_IPS_Datatype__c = 'Picklist';
            //cq.Core_IPS_Order_No__c = 1;
            cq.Core_IPS_Parent_Question__c = null;
            cq.Core_IPS_Product_Organization__c = ListOfSupportOrg.get(0).Id; 
            cq.Core_IPS_Question__c = 'Test';
            cq.Core_IPS_Required__c = false;
            cq.Core_IPS_Status__c = 'Active';
            
            insert cq;
            
            //Create Environmental Detail Operational
            List<Core_IPS_Assigned_Environment_Variables__c> listOfEnvDetailsOperational = TestUtilities.getListOfEnvDetailsOperational(2);
            listOfEnvDetailsOperational.get(0).Core_IPS_Question__c = cq.Id;
            listOfEnvDetailsOperational.get(0).Core_Supported_Product__c = ListOfSupportedProduct[0].id;
            insert listOfEnvDetailsOperational.get(0);
            
            //Update Core Question
            cq.Core_IPS_Status__c = 'Inactive';
            
            update cq;   
            
            }
        Test.stopTest();  
        
  }
  
  /***************************************************************************************************
  Method Name      : preventToDeletetheEnvironmentalDetailQuestionTest
  Method Type      : void
  Version         : 1.0 
  Created Date    : 05 Nov 2015
  Description      : This method is used for cover the preventToDeletetheEnvironmentalDetailQuestion method of Core_IPS_Core_Question_Handler class.
  Scenario Type:  
  Modification Log   :
  * Developer                   Date                   Description
  * ----------------------------------------------------------------------------                 
  * Yogesh Sharma             1/2/2018             Created
  ****************************************************************************************************/
  public static testmethod void preventToDeletetheEnvironmentalDetailQuestionTest(){
    Test.startTest();
      Map<String,ID> profiles = new Map<String,ID>();
            List<String> strProf = new List<String>();
            strProf.add('System Administrator');
            strProf.add('IPS Data Migration');
            List<Profile> ProfileList = [select id, name from Profile where name IN : strProf];
            
            for(Profile prf : ProfileList){
                profiles.put(prf.name, prf.id); 
            }
            
            //Create Users
            List<User> ListOfUser = new List<User>();
            ListOfUser = TestUtilities.getListOfUser(1); 
            ListOfUser.get(0).ProfileId =  profiles.get('System Administrator');
            insert ListOfUser.get(0);
      
          //Get intelSupportOwner Id (User Id)
            Id intelSupportOwner = ListOfUser.get(0).id;
            System.runAs(ListOfUser.get(0)){
            
        //Create Custom Setting - Trigger Executions
            Core_Trigger_Executions__c  TriggerExecution = new Core_Trigger_Executions__c();
            TriggerExecution.Name = 'preventToDeletetheEDQ';
            TriggerExecution.Core_Active__c = true;
            TriggerExecution.Core_Class_Name__c ='Core_IPS_Core_Question_Handler';
            TriggerExecution.Core_Description__c = 'This method is used Prevent the deletion of Core_IPS_Question__c object Record if Record used in any Core_IPS_Response__c Object Record.';
            TriggerExecution.Core_Object__c = 'Core_IPS_Question__c';
            TriggerExecution.Core_Trigger_Events__c = 'Before Delete';
            insert TriggerExecution; 
            System.assert(TriggerExecution.id != null);
            
                //start added by Aayushi US95468 06/04/2018
                //Create Custom Setting - Trigger Executions
            Core_Trigger_Executions__c  TriggerExecution1 = new Core_Trigger_Executions__c();
            TriggerExecution1.Name = 'updateEDQfilteringFieldOnCase';
            TriggerExecution1.Core_Active__c = true;
            TriggerExecution1.Core_Class_Name__c ='Core_IPS_Core_Question_Handler';
            TriggerExecution1.Core_Description__c = 'This method will populate the two EDQ filtering fields on Case with the Response QuestionsReporting Name and the Response Answer text';
            TriggerExecution1.Core_Object__c = 'Core_IPS_Response__c';
            TriggerExecution1.Core_Trigger_Events__c = 'After Insert,Update';
            insert TriggerExecution1; 
            System.assert(TriggerExecution1.id != null);
                //end
                
            //Create Support Org
            List<Core_IPS_Product_Organization__c> ListOfSupportOrg  = TestUtilities.getListOfSupportOrg(2);
            insert ListOfSupportOrg;
            
            System.assert(ListOfSupportOrg != null, 'Record not created');
            
            //Create Accounts
              List<Account> ListOfAccounts = TestUtilities.getListOfAccounts(2);
              insert ListOfAccounts;
              System.assert(ListOfAccounts[0].Id != null, 'Record not created');
              
              //Create Contacts
              List<Contact> ListOfContacts = TestUtilities.getListOfContact(1);
              for(Contact ContactRec : ListOfContacts){
                  ContactRec.Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
                  ContactRec.core_ips_Active__c=true;
                  ContactRec.Accountid = ListOfAccounts.get(0).Id; 
              }
              insert ListOfContacts;
              System.assert(ListOfContacts[0].Id != null, 'Record not created');
              
            //Create Case
            Case c1 = TestUtilities.getListOfCases(2).get(0);
                c1.accountId = ListOfAccounts.get(0).Id;
                c1.ContactId = ListOfContacts.get(0).id;
                c1.Core_IPS_Customer_Visible__c = false;
                insert c1;
                
            //Get Record Type
            Id edqRecordTypeId = Schema.SObjectType.Core_IPS_Question__c.getRecordTypeInfosByName().get('Environment Detail Question').getRecordTypeId();
            
            //Create Core Question
            Core_IPS_Question__c cq = new Core_IPS_Question__c();
            cq.recordTypeId = edqRecordTypeId;
            cq.Core_IPS_Datatype__c = 'Picklist';
            cq.Core_IPS_Order_No__c = 1;
            cq.Core_IPS_Parent_Question__c = null;
            cq.Core_IPS_Product_Organization__c = ListOfSupportOrg.get(0).Id; 
            cq.Core_IPS_Question__c = 'Test';
            cq.Core_IPS_Required__c = false;
            cq.Core_IPS_Status__c = 'Active';
            
            insert cq;
            
            
            //Create Core Response
            Core_IPS_Response__c res = new Core_IPS_Response__c();
            res.Core_IPS_Question_Master__c = cq.Id;
            res.Core_IPS_Case__c = c1.Id;
            insert res; 
               
                //start added by Aayushi US95468 06/04/2018
            cq.Core_IPS_Add_to_Reporting__c=true;
                cq.Core_IPS_Reporting_Name__c='test';
                update cq;
                //end
                
            //Delete Core Question
            try{
              delete cq;  
            }
            catch(Exception e){
            }
            } 
    Test.stopTest();  
  }
  
  /***************************************************************************************************
  Method Name      : copyOwnerFromSupportOrgToEnvironmentalDetailQuestionTest
  Method Type      : void
  Version         : 1.0 
  Created Date    : 05 Nov 2015
  Description      : This method is used for cover the copyOwnerFromSupportOrgToEnvironmentalDetailQuestion method of Core_IPS_Core_Question_Handler class.
  Scenario Type:  
  Modification Log   :
  * Developer                   Date                   Description
  * ----------------------------------------------------------------------------                 
  * Yogesh Sharma             1/2/2018             Created
  ****************************************************************************************************/
  public static testmethod void copyOwnerFromSupportOrgToEnvironmentalDetailQuestionTest(){
    Test.startTest();
      Map<String,ID> profiles = new Map<String,ID>();
            List<String> strProf = new List<String>();
            strProf.add('System Administrator');
            strProf.add('IPS Data Migration');
            List<Profile> ProfileList = [select id, name from Profile where name IN : strProf];
            
            for(Profile prf : ProfileList){
                profiles.put(prf.name, prf.id); 
            }
            
            //Create Users
            List<User> ListOfUser = new List<User>();
            ListOfUser = TestUtilities.getListOfUser(1); 
            ListOfUser.get(0).ProfileId =  profiles.get('System Administrator');
            insert ListOfUser.get(0);
      
          //Get intelSupportOwner Id (User Id)
            Id intelSupportOwner = ListOfUser.get(0).id;
            System.runAs(ListOfUser.get(0)){
            
        //Create Custom Setting - Trigger Executions
            Core_Trigger_Executions__c  TriggerExecution = new Core_Trigger_Executions__c();
            TriggerExecution.Name = 'copyOwnerFromSupportOrgToEDQ';
            TriggerExecution.Core_Active__c = true;
            TriggerExecution.Core_Class_Name__c ='Core_IPS_Core_Question_Handler';
            TriggerExecution.Core_Description__c = 'This method is used copy the owner from Support org to Environmental Detail Question Object.';
            TriggerExecution.Core_Object__c = 'Core_IPS_Question__c';
            TriggerExecution.Core_Trigger_Events__c = 'Before Insert';
            insert TriggerExecution; 
            System.assert(TriggerExecution.id != null);
            
            //Create Support Org
            List<Core_IPS_Product_Organization__c> ListOfSupportOrg  = TestUtilities.getListOfSupportOrg(2);
            insert ListOfSupportOrg;
            
            System.assert(ListOfSupportOrg != null, 'Record not created');
            
            //Create Accounts
              List<Account> ListOfAccounts = TestUtilities.getListOfAccounts(2);
              insert ListOfAccounts;
              System.assert(ListOfAccounts[0].Id != null, 'Record not created');
              
              //Create Contacts
              List<Contact> ListOfContacts = TestUtilities.getListOfContact(1);
              for(Contact ContactRec : ListOfContacts){
                  ContactRec.Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
                  ContactRec.core_ips_Active__c=true;
                  ContactRec.Accountid = ListOfAccounts.get(0).Id; 
              }
              insert ListOfContacts;
              System.assert(ListOfContacts[0].Id != null, 'Record not created');
              
            //Create Case
            Case c1 = TestUtilities.getListOfCases(2).get(0);
                c1.accountId = ListOfAccounts.get(0).Id;
                c1.ContactId = ListOfContacts.get(0).id;
                c1.Core_IPS_Customer_Visible__c = false;
                insert c1;
                
            //Get Record Type
            Id edqRecordTypeId = Schema.SObjectType.Core_IPS_Question__c.getRecordTypeInfosByName().get('Environment Detail Question').getRecordTypeId();
            
            //Create Core Question
            Core_IPS_Question__c cq = new Core_IPS_Question__c();
            cq.recordTypeId = edqRecordTypeId;
            cq.Core_IPS_Datatype__c = 'Picklist';
            cq.Core_IPS_Order_No__c = 1;
            cq.Core_IPS_Parent_Question__c = null;
            cq.Core_IPS_Product_Organization__c = ListOfSupportOrg.get(0).Id; 
            cq.Core_IPS_Question__c = 'Test';
            cq.Core_IPS_Required__c = false;
            cq.Core_IPS_Status__c = 'Active';
            
            insert cq;
        } 
    Test.stopTest();  
  }
  
  /***************************************************************************************************
  Method Name      : preventToCreateEnvironmentalDetailQuestionTest
  Method Type      : void
  Version         : 1.0 
  Created Date    : 05 Nov 2015
  Description      : This method is used for cover the preventToCreateEnvironmentalDetailQuestion method of Core_IPS_Core_Question_Handler class.
  Scenario Type:  
  Modification Log   :
  * Developer                   Date                   Description
  * ----------------------------------------------------------------------------                 
  * Yogesh Sharma             1/2/2018             Created
  ****************************************************************************************************/
  public static testmethod void preventToCreateEnvironmentalDetailQuestionTest(){
    Test.startTest();
      Map<String,ID> profiles = new Map<String,ID>();
            List<String> strProf = new List<String>();
            strProf.add('System Administrator');
            strProf.add('IPS Data Migration');
            List<Profile> ProfileList = [select id, name from Profile where name IN : strProf];
            
            for(Profile prf : ProfileList){
                profiles.put(prf.name, prf.id); 
            }
            
            //Create Users
            List<User> ListOfUser = new List<User>();
            ListOfUser = TestUtilities.getListOfUser(1); 
            ListOfUser.get(0).ProfileId =  profiles.get('System Administrator');
            insert ListOfUser.get(0);
      
          //Get intelSupportOwner Id (User Id)
            Id intelSupportOwner = ListOfUser.get(0).id;
            System.runAs(ListOfUser.get(0)){
            
        //Create Custom Setting - Trigger Executions
            Core_Trigger_Executions__c  TriggerExecution = new Core_Trigger_Executions__c();
            TriggerExecution.Name = 'preventToCreateEDQ';
            TriggerExecution.Core_Active__c = true;
            TriggerExecution.Core_Class_Name__c ='Core_IPS_Core_Question_Handler';
            TriggerExecution.Core_Description__c = 'This method is used to prevent the create Environmental Detail Question Record if user not have write access on Support org.';
            TriggerExecution.Core_Object__c = 'Core_IPS_Question__c';
            TriggerExecution.Core_Trigger_Events__c = 'Before Insert';
            insert TriggerExecution; 
            System.assert(TriggerExecution.id != null);
                
            //Create Support Org
            List<Core_IPS_Product_Organization__c> ListOfSupportOrg  = TestUtilities.getListOfSupportOrg(2);
            insert ListOfSupportOrg;
            
            System.assert(ListOfSupportOrg != null, 'Record not created');
            
            //Create Accounts
              List<Account> ListOfAccounts = TestUtilities.getListOfAccounts(2);
              insert ListOfAccounts;
              System.assert(ListOfAccounts[0].Id != null, 'Record not created');
              
              //Create Contacts
              List<Contact> ListOfContacts = TestUtilities.getListOfContact(1);
              for(Contact ContactRec : ListOfContacts){
                  ContactRec.Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
                  ContactRec.core_ips_Active__c=true;
                  ContactRec.Accountid = ListOfAccounts.get(0).Id; 
              }
              insert ListOfContacts;
              System.assert(ListOfContacts[0].Id != null, 'Record not created');
              
            //Create Case
            Case c1 = TestUtilities.getListOfCases(2).get(0);
                c1.accountId = ListOfAccounts.get(0).Id;
                c1.ContactId = ListOfContacts.get(0).id;
                c1.Core_IPS_Customer_Visible__c = false;
                insert c1;
                
            //Get Record Type
            Id edqRecordTypeId = Schema.SObjectType.Core_IPS_Question__c.getRecordTypeInfosByName().get('Environment Detail Question').getRecordTypeId();
            
            //Create Core Question
            Core_IPS_Question__c cq = new Core_IPS_Question__c();
            cq.recordTypeId = edqRecordTypeId;
            cq.Core_IPS_Datatype__c = 'Picklist';
            //Commented by karthick as part of US146475 
            //cq.Core_IPS_Order_No__c = 1;
            cq.Core_IPS_Parent_Question__c = null;
            cq.Core_IPS_Product_Organization__c = ListOfSupportOrg.get(0).Id; 
            cq.Core_IPS_Question__c = 'Test';
            cq.Core_IPS_Required__c = false;
            cq.Core_IPS_Status__c = 'Active';
            
            insert cq;
            
                
                
        } 
    Test.stopTest();  
  }
  
  public static testmethod void preventToUpdateParentEDQDataTypeTest(){
    Test.startTest();
        Map<String,ID> profiles = new Map<String,ID>();
        List<String> strProf = new List<String>();
        strProf.add('System Administrator');
        strProf.add('IPS Data Migration');
        List<Profile> ProfileList = [select id, name from Profile where name IN : strProf];
        
        for(Profile prf : ProfileList){
            profiles.put(prf.name, prf.id); 
        }
        
        //Create Users
        List<User> ListOfUser = new List<User>();
        ListOfUser = TestUtilities.getListOfUser(1); 
        ListOfUser.get(0).ProfileId =  profiles.get('System Administrator');
        insert ListOfUser.get(0);
  
        //Get intelSupportOwner Id (User Id)
        Id intelSupportOwner = ListOfUser.get(0).id;
        System.runAs(ListOfUser.get(0)){
            
        //Create Custom Setting - Trigger Executions
            Core_Trigger_Executions__c  TriggerExecution = new Core_Trigger_Executions__c();
            TriggerExecution.Name = 'preventToDeletetheEDQ';
            TriggerExecution.Core_Active__c = true;
            TriggerExecution.Core_Class_Name__c ='Core_IPS_Core_Question_Handler';
            TriggerExecution.Core_Description__c = 'This method is used Prevent the deletion of Core_IPS_Question__c object Record if Record used in any Core_IPS_Response__c Object Record.';
            TriggerExecution.Core_Object__c = 'Core_IPS_Question__c';
            TriggerExecution.Core_Trigger_Events__c = 'Before Delete';
            insert TriggerExecution; 
            System.assert(TriggerExecution.id != null);
            
                //start added by Aayushi US95468 06/04/2018
                //Create Custom Setting - Trigger Executions
            Core_Trigger_Executions__c  TriggerExecution1 = new Core_Trigger_Executions__c();
            TriggerExecution1.Name = 'updateEDQfilteringFieldOnCase';
            TriggerExecution1.Core_Active__c = true;
            TriggerExecution1.Core_Class_Name__c ='Core_IPS_Core_Question_Handler';
            TriggerExecution1.Core_Description__c = 'This method will populate the two EDQ filtering fields on Case with the Response QuestionsReporting Name and the Response Answer text';
            TriggerExecution1.Core_Object__c = 'Core_IPS_Response__c';
            TriggerExecution1.Core_Trigger_Events__c = 'After Insert,Update';
            insert TriggerExecution1; 
            System.assert(TriggerExecution1.id != null);
            
            Core_Trigger_Executions__c  TriggerExecution2 = new Core_Trigger_Executions__c();
            TriggerExecution2.Name = 'preventToUpdateParentEDQDataType';
            TriggerExecution2.Core_Active__c = true;
            TriggerExecution2.Core_Class_Name__c ='Core_IPS_Core_Question_Handler';
            TriggerExecution2.Core_Description__c = 'This method is used Prevent the update on Parent EDQ Questions Datatype.';
            TriggerExecution2.Core_Object__c = 'Core_IPS_Question__c';
            TriggerExecution2.Core_Trigger_Events__c = 'Before Update';
            insert TriggerExecution2; 
            
            Core_Trigger_Executions__c  TriggerExecution3 = new Core_Trigger_Executions__c();
            TriggerExecution3.Name = 'preventToCreateGrandChildEDQ';
            TriggerExecution3.Core_Active__c = true;
            TriggerExecution3.Core_Class_Name__c ='Core_IPS_Core_Question_Handler';
            TriggerExecution3.Core_Description__c = 'This method is used to restrict the creation of GrandChild EDQs.';
            TriggerExecution3.Core_Object__c = 'Core_IPS_Question__c';
            TriggerExecution3.Core_Trigger_Events__c = 'Before Insert,Update';
            insert TriggerExecution3; 
            
            Core_Trigger_Executions__c  TriggerExecution4 = new Core_Trigger_Executions__c();
            TriggerExecution4.Name = 'preventToCreateThousandEDQ';
            TriggerExecution4.Core_Active__c = true;
            TriggerExecution4.Core_Class_Name__c ='Core_IPS_Core_Question_Handler';
            TriggerExecution4.Core_Description__c = 'This method is used to restrict to create 1000 edq for support org.';
            TriggerExecution4.Core_Object__c = 'Core_IPS_Question__c';
            TriggerExecution4.Core_Trigger_Events__c = 'Before insert,Update';
            insert TriggerExecution4;

            Core_IPS_Labels__c label1= new Core_IPS_Labels__c();
            label1.name= 'Core_IPS_Support_Org_Edq_Count';
            label1.value__c= '999';
            insert label1;

            
                //end
                
            //Create Support Org
            List<Core_IPS_Product_Organization__c> ListOfSupportOrg  = TestUtilities.getListOfSupportOrg(2);
            insert ListOfSupportOrg;
            
            System.assert(ListOfSupportOrg != null, 'Record not created');
            
            //Create Accounts
              List<Account> ListOfAccounts = TestUtilities.getListOfAccounts(2);
              insert ListOfAccounts;
              System.assert(ListOfAccounts[0].Id != null, 'Record not created');
              
              //Create Contacts
              List<Contact> ListOfContacts = TestUtilities.getListOfContact(1);
              for(Contact ContactRec : ListOfContacts){
                  ContactRec.Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
                  ContactRec.core_ips_Active__c=true;
                  ContactRec.Accountid = ListOfAccounts.get(0).Id; 
              }
              insert ListOfContacts;
              System.assert(ListOfContacts[0].Id != null, 'Record not created');
              
            //Create Case
            Case c1 = TestUtilities.getListOfCases(2).get(0);
                c1.accountId = ListOfAccounts.get(0).Id;
                c1.ContactId = ListOfContacts.get(0).id;
                c1.Core_IPS_Customer_Visible__c = false;
                insert c1;
                
            //Get Record Type
            Id edqRecordTypeId = Schema.SObjectType.Core_IPS_Question__c.getRecordTypeInfosByName().get('Environment Detail Question').getRecordTypeId();
            
            //Create Core Question
            Core_IPS_Question__c cq = new Core_IPS_Question__c();
            cq.recordTypeId = edqRecordTypeId;
            cq.Core_IPS_Datatype__c = 'Picklist';
            //cq.Core_IPS_Order_No__c = 1;
            cq.Core_IPS_Parent_Question__c = null;
            cq.Core_IPS_Product_Organization__c = ListOfSupportOrg.get(0).Id; 
            cq.Core_IPS_Question__c = 'Test';
            cq.Core_IPS_Required__c = false;
            cq.Core_IPS_Status__c = 'Active';
            
            insert cq;
            
            
            //Create Child Question - Added by Karthick - 23/04/2018
            //Create Core Question
            Core_IPS_Question__c cq1 = new Core_IPS_Question__c();
            cq1.recordTypeId = edqRecordTypeId;
            cq1.Core_IPS_Datatype__c = 'Picklist';
            //cq1.Core_IPS_Order_No__c = 1;
            cq1.Core_IPS_Parent_Question__c = cq.Id;
            cq1.Core_IPS_Product_Organization__c = ListOfSupportOrg.get(0).Id; 
            cq1.Core_IPS_Question__c = 'Test child questions';
            cq1.Core_IPS_Required__c = false;
            cq1.Core_IPS_Status__c = 'Active';
            
            insert cq1;
            
            //Update Parent Question DataType 
            Core_IPS_Question__c parentQuestion = [select id,Core_IPS_Datatype__c from Core_IPS_Question__c where id=:cq.Id];
            try{
                parentQuestion.Core_IPS_Datatype__c = 'Text';
                update parentQuestion;
            }catch(Exception e){
            }
            
            try{
                //Create second level child Question
                Core_IPS_Question__c cq2 = new Core_IPS_Question__c();
                cq2.recordTypeId = edqRecordTypeId;
                cq2.Core_IPS_Datatype__c = 'Picklist';
                cq2.Core_IPS_Order_No__c = 1;
                cq2.Core_IPS_Parent_Question__c = cq1.Id;
                cq2.Core_IPS_Product_Organization__c = ListOfSupportOrg.get(0).Id; 
                cq2.Core_IPS_Question__c = 'Test child questions';
                cq2.Core_IPS_Required__c = false;
                cq2.Core_IPS_Status__c = 'Active';
                
                insert cq2;
                
                Core_IPS_Question__c cq3 = new Core_IPS_Question__c();
                cq3.recordTypeId = edqRecordTypeId;
                cq3.Core_IPS_Datatype__c = 'Picklist';
                //cq.Core_IPS_Order_No__c = 1;
                cq3.Core_IPS_Parent_Question__c = null;
                cq3.Core_IPS_Product_Organization__c = ListOfSupportOrg.get(1).Id; 
                cq3.Core_IPS_Question__c = 'Test';
                cq3.Core_IPS_Status__c = 'Active';
                
                insert cq3;
                
                List<Core_IPS_Question__c> questionList = new List<Core_IPS_Question__c>();
                for(Integer i=0;i<1000;i++){
                    
                    Core_IPS_Question__c question = new Core_IPS_Question__c();
                    question.recordTypeId = edqRecordTypeId;
                    question.Core_IPS_Datatype__c = 'Text';
                    question.Core_IPS_Order_No__c = i;
                    question.Core_IPS_Product_Organization__c = ListOfSupportOrg.get(0).Id; 
                    question.Core_IPS_Question__c = 'Test Questions'+i;
                    question.Core_IPS_Status__c = 'Active';
                    questionList.add(question);
                }
                
                
                
                insert questionList;
                
                Core_IPS_Question__c ques = [select id,Core_IPS_Product_Organization__c  from Core_IPS_Question__c where Core_IPS_Product_Organization__c = :ListOfSupportOrg.get(1).Id  ];
                ques.Core_IPS_Product_Organization__c  = ListOfSupportOrg.get(0).Id; 
                update ques;
                
            }catch(Exception e){
            }
            
           
        } 
    Test.stopTest();  
  }
  
    
    public static testmethod void preventToCreateThousandEDQTest(){
    Test.startTest();
        Map<String,ID> profiles = new Map<String,ID>();
        List<String> strProf = new List<String>();
        strProf.add('System Administrator');
        strProf.add('IPS Data Migration');
        List<Profile> ProfileList = [select id, name from Profile where name IN : strProf];
        
        for(Profile prf : ProfileList){
            profiles.put(prf.name, prf.id); 
        }
        
        //Create Users
        List<User> ListOfUser = new List<User>();
        ListOfUser = TestUtilities.getListOfUser(1); 
        ListOfUser.get(0).ProfileId =  profiles.get('System Administrator');
        insert ListOfUser.get(0);
  
        //Get intelSupportOwner Id (User Id)
        Id intelSupportOwner = ListOfUser.get(0).id;
        System.runAs(ListOfUser.get(0)){
            
        //Create Custom Setting - Trigger Executions
        Core_Trigger_Executions__c  TriggerExecution = new Core_Trigger_Executions__c();
        TriggerExecution.Name = 'preventToDeletetheEDQ';
        TriggerExecution.Core_Active__c = true;
        TriggerExecution.Core_Class_Name__c ='Core_IPS_Core_Question_Handler';
        TriggerExecution.Core_Description__c = 'This method is used Prevent the deletion of Core_IPS_Question__c object Record if Record used in any Core_IPS_Response__c Object Record.';
        TriggerExecution.Core_Object__c = 'Core_IPS_Question__c';
        TriggerExecution.Core_Trigger_Events__c = 'Before Delete';
        insert TriggerExecution; 
        System.assert(TriggerExecution.id != null);
            
        //start added by Aayushi US95468 06/04/2018
        //Create Custom Setting - Trigger Executions
        Core_Trigger_Executions__c  TriggerExecution1 = new Core_Trigger_Executions__c();
        TriggerExecution1.Name = 'updateEDQfilteringFieldOnCase';
        TriggerExecution1.Core_Active__c = true;
        TriggerExecution1.Core_Class_Name__c ='Core_IPS_Core_Question_Handler';
        TriggerExecution1.Core_Description__c = 'This method will populate the two EDQ filtering fields on Case with the Response QuestionsReporting Name and the Response Answer text';
        TriggerExecution1.Core_Object__c = 'Core_IPS_Response__c';
        TriggerExecution1.Core_Trigger_Events__c = 'After Insert,Update';
        insert TriggerExecution1; 
        System.assert(TriggerExecution1.id != null);
            
        Core_Trigger_Executions__c  TriggerExecution2 = new Core_Trigger_Executions__c();
        TriggerExecution2.Name = 'preventToUpdateParentEDQDataType';
        TriggerExecution2.Core_Active__c = true;
        TriggerExecution2.Core_Class_Name__c ='Core_IPS_Core_Question_Handler';
        TriggerExecution2.Core_Description__c = 'This method is used Prevent the update on Parent EDQ Questions Datatype.';
        TriggerExecution2.Core_Object__c = 'Core_IPS_Question__c';
        TriggerExecution2.Core_Trigger_Events__c = 'Before Update';
        insert TriggerExecution2; 
        
        Core_Trigger_Executions__c  TriggerExecution3 = new Core_Trigger_Executions__c();
        TriggerExecution3.Name = 'preventToCreateGrandChildEDQ';
        TriggerExecution3.Core_Active__c = true;
        TriggerExecution3.Core_Class_Name__c ='Core_IPS_Core_Question_Handler';
        TriggerExecution3.Core_Description__c = 'This method is used to restrict the creation of GrandChild EDQs.';
        TriggerExecution3.Core_Object__c = 'Core_IPS_Question__c';
        TriggerExecution3.Core_Trigger_Events__c = 'Before Insert,Update';
        insert TriggerExecution3; 
        
        Core_Trigger_Executions__c  TriggerExecution4 = new Core_Trigger_Executions__c();
        TriggerExecution4.Name = 'preventToCreateThousandEDQ';
        TriggerExecution4.Core_Active__c = true;
        TriggerExecution4.Core_Class_Name__c ='Core_IPS_Core_Question_Handler';
        TriggerExecution4.Core_Description__c = 'This method is used to restrict to create 1000 edq for support org.';
        TriggerExecution4.Core_Object__c = 'Core_IPS_Question__c';
        TriggerExecution4.Core_Trigger_Events__c = 'Before insert,Update';
        insert TriggerExecution4;

        Core_IPS_Labels__c label1= new Core_IPS_Labels__c();
        label1.name= 'Core_IPS_Support_Org_Edq_Count';
        label1.value__c= '999';
        insert label1;

            
        //end
                
        //Create Support Org
        List<Core_IPS_Product_Organization__c> ListOfSupportOrg  = TestUtilities.getListOfSupportOrg(4);
        insert ListOfSupportOrg;
        
        System.assert(ListOfSupportOrg != null, 'Record not created');
            
        //Create Accounts
        List<Account> ListOfAccounts = TestUtilities.getListOfAccounts(2);
        insert ListOfAccounts;
        System.assert(ListOfAccounts[0].Id != null, 'Record not created');
              
          //Create Contacts
          List<Contact> ListOfContacts = TestUtilities.getListOfContact(1);
          for(Contact ContactRec : ListOfContacts){
              ContactRec.Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
              ContactRec.core_ips_Active__c=true;
              ContactRec.Accountid = ListOfAccounts.get(0).Id; 
          }
          insert ListOfContacts;
          System.assert(ListOfContacts[0].Id != null, 'Record not created');
              
        //Create Case
            Case c1 = TestUtilities.getListOfCases(2).get(0);
            c1.accountId = ListOfAccounts.get(0).Id;
            c1.ContactId = ListOfContacts.get(0).id;
            c1.Core_IPS_Customer_Visible__c = false;
            insert c1;
                
            //Get Record Type
            Id edqRecordTypeId = Schema.SObjectType.Core_IPS_Question__c.getRecordTypeInfosByName().get('Environment Detail Question').getRecordTypeId();
            
            //Create Core Question
            Core_IPS_Question__c cq = new Core_IPS_Question__c();
            cq.recordTypeId = edqRecordTypeId;
            cq.Core_IPS_Datatype__c = 'Text';
            cq.Core_IPS_Parent_Question__c = null;
            cq.Core_IPS_Product_Organization__c = ListOfSupportOrg.get(0).Id; 
            cq.Core_IPS_Question__c = 'Test';
            cq.Core_IPS_Required__c = false;
            cq.Core_IPS_Status__c = 'Active';            
            insert cq;
            
            Core_IPS_Question__c cq2 = new Core_IPS_Question__c();
            cq2.recordTypeId = edqRecordTypeId;
            cq2.Core_IPS_Datatype__c = 'Text';
            cq2.Core_IPS_Parent_Question__c = null;
            cq2.Core_IPS_Product_Organization__c = ListOfSupportOrg.get(1).Id; 
            cq2.Core_IPS_Question__c = 'Test';
            cq2.Core_IPS_Required__c = false;
            cq2.Core_IPS_Status__c = 'Active';            
            insert cq2;
            
            Core_IPS_Question__c cq3 = new Core_IPS_Question__c();
            cq3.recordTypeId = edqRecordTypeId;
            cq3.Core_IPS_Datatype__c = 'Text';
            cq3.Core_IPS_Parent_Question__c = null;
            cq3.Core_IPS_Product_Organization__c = ListOfSupportOrg.get(2).Id; 
            cq3.Core_IPS_Question__c = 'Test';
            cq3.Core_IPS_Required__c = false;
            cq3.Core_IPS_Status__c = 'Active';            
            insert cq3;
            
            Core_IPS_Question__c cq4 = new Core_IPS_Question__c();
            cq4.recordTypeId = edqRecordTypeId;
            cq4.Core_IPS_Datatype__c = 'Text';
            cq4.Core_IPS_Parent_Question__c = null;
            cq4.Core_IPS_Product_Organization__c = ListOfSupportOrg.get(0).Id; 
            cq4.Core_IPS_Question__c = 'Test';
            cq4.Core_IPS_Required__c = false;
            cq4.Core_IPS_Status__c = 'Active';            
            insert cq4;
            
            cq2.Core_IPS_Product_Organization__c = ListOfSupportOrg.get(0).Id; 
            update cq2;
            
            cq3.Core_IPS_Product_Organization__c = ListOfSupportOrg.get(0).Id; 
            update cq3;
           
        } 
    Test.stopTest();  
  }
    
}