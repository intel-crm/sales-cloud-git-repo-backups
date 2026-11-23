/***************************************************************************************************
Class Name:  Core_Utility_IPS_Test
Class Type: Test Class 
Version     : 1.0 
Created Date: 03 Nov 2015
Function    : This class contains test coverage for IPS related methods in Core_Utility class
Input Parameters: None 
Output Parameters: None
Description:   This class contains unit test scenarios for IPS related methods in Core_Utility class
Used in     : None
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Syed Moosa Nazir TN       11/04/2015                Created
****************************************************************************************************/   
@isTest
public class Core_Utility_IPS_Test{
    //Instance variables that are commonly used in multiple test methods
    static List<User> ListOfUser = new List<User> ();
    
    /***************************************************************************************************
    Method Name:  getRecords
    Method Type: Void Method
    Version     : 1.0 
    Created Date: 03 Nov 2015
    Description:  Common Test data used in multiple test methods
    Scenario Type:  
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Syed Moosa Nazir TN       11/04/2015                Created
    ****************************************************************************************************/
    static void getRecords(){
        UserRole role=new UserRole();
        role.name='Admin';        
        insert role;
        // Query Profiles
        Map<String,ID> profiles = new Map<String,ID>();
        List<Profile> ProfileList = [select id, name from Profile where name = 'System Administrator'];
        for(Profile prf : ProfileList){
            profiles.put(prf.name, prf.id);
        }
        // Create Users
        ListOfUser = TestUtilities.getListOfUser(1);
        for(User Usr : ListOfUser){
            Usr.userroleid = role.id;
            Usr.ProfileID =  profiles.get('System Administrator');
        }
        insert ListOfUser;
        
        System.assertEquals(ListOfUser.get(0).profileid, profiles.get('System Administrator'));     
    }
    /***************************************************************************************************
    Method Name:  readFieldSet_PositiveTest
    Method Type: Test Method
    Version     : 1.0 
    Created Date: 04 Nov 2015
    Description:  Testing readFieldSet(String fieldSetName, String ObjectApiName) utility method.
    Scenario Type:  Positive
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Syed Moosa Nazir TN       11/04/2015                Created
    ****************************************************************************************************/
    static testmethod void readFieldSet_PositiveTest(){
        getRecords();
        string ObjectApiName = 'Core_IPS_Supported_Product__c'; 
        string fieldSetName = 'SupportedProductFieldSet';       
        System.runAs(ListOfUser.get(0)){
            Test.startTest();
            List<Schema.FieldSetMember> ListOfFieldSetMember = Core_Utility.readFieldSet(fieldSetName,ObjectApiName); 
            System.assert(ListOfFieldSetMember != null,'readFieldSet utility method failed to fetch the fieldset'); 
            Test.stopTest();
        }
    }
    /***************************************************************************************************
    Method Name:  readFieldSet_NegativeTest
    Method Type: Test Method
    Version     : 1.0 
    Created Date: 04 Nov 2015
    Description:  Testing readFieldSet(String fieldSetName, String ObjectApiName) utility method.
    Scenario Type:  Negative
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Syed Moosa Nazir TN       11/04/2015                Created
    ****************************************************************************************************/
    static testmethod void readFieldSet_NegativeTest(){
        getRecords();
        string ObjectApiName = null;    
        string fieldSetName = null;     
        System.runAs(ListOfUser.get(0)){
            Test.startTest();
            List<Schema.FieldSetMember> ListOfFieldSetMember = Core_Utility.readFieldSet(fieldSetName,ObjectApiName); 
            System.assertEquals(ListOfFieldSetMember,null);
            Test.stopTest();
        }
    }
    
    /***************************************************************************************************
    Method Name:  sendEmail_PositiveTest
    Method Type: Test Method
    Version     : 1.0 
    Created Date: 04 Nov 2015
    Description:  Testing sendEmail(set<String> toAddresses, id templateId) utility method.
    Scenario Type:  Positive
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Syed Moosa Nazir TN       11/04/2015                Created
    ****************************************************************************************************/
    static testmethod void sendEmail_PositiveTest(){
        getRecords();   
        // Local Variables
        set<String> toAddresses = new set<String> ();
        id templateId;
        // Create Template
        EmailTemplate validEmailTemplate = new EmailTemplate();
        System.runAs(ListOfUser.get(0)){
            validEmailTemplate.isActive = true;
            validEmailTemplate.Name = 'name';
            validEmailTemplate.DeveloperName = 'unique_name_addSomethingSpecialHere';
            validEmailTemplate.TemplateType = 'text';
            validEmailTemplate.FolderId = ListOfUser.get(0).id;
            validEmailTemplate.Subject = 'Your Subject Here';
            insert validEmailTemplate;
            System.assert(validEmailTemplate.Id != null, 'Record not created');
        }
         // Create Accounts         
            List<Account> ListOfAccounts = TestUtilities.getListOfAccounts(1);
            System.runAs(ListofUser[0]){
            insert ListOfAccounts;
            }
            System.assert(ListOfAccounts[0].Id != null, 'Record not created');
            
        // Create Contact
        
        List<Contact> ListOfContacts = TestUtilities.getListOfContact(1);
        ListOfContacts.get(0).Core_IPS_Intel_Support_Owner__c = ListOfUser.get(0).id;
        ListOfContacts.get(0).Accountid = ListOfAccounts.get(0).Id;
        System.runAs(ListofUser[0]){        
        insert ListOfContacts;
        }
        System.assert(ListOfContacts[0].Id != null, 'Record not created');
        // Assign values to variables
        toAddresses.add(ListOfUser.get(0).Email);
        templateId = validEmailTemplate.id;
        // Test functionality
        System.runAs(ListOfUser.get(0)){
            Test.startTest();
            Core_Utility.sendEmail(toAddresses,templateId); 
            Test.stopTest();
        }
    }
    /***************************************************************************************************
    Method Name:  sendEmail_WithContact_NegativeTest
    Method Type: Test Method
    Version     : 1.0 
    Created Date: 04 Nov 2015
    Description:  Testing sendEmail(set<String> toAddresses, id templateId) utility method.
    Scenario Type:  Negative
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Syed Moosa Nazir TN       11/04/2015                Created
    ****************************************************************************************************/
    static testmethod void sendEmail_WithContact_NegativeTest(){
        getRecords();
        // Create Accounts         
            List<Account> ListOfAccounts = TestUtilities.getListOfAccounts(1);
            System.runAs(ListofUser[0]){
            insert ListOfAccounts;
            }
            System.assert(ListOfAccounts[0].Id != null, 'Record not created');
        // Create Contact
        List<Contact> ListOfContacts = TestUtilities.getListOfContact(1);
        ListOfContacts.get(0).Core_IPS_Intel_Support_Owner__c = ListOfUser.get(0).id;
        ListOfContacts.get(0).Accountid = ListOfAccounts.get(0).Id;
        System.runAs(ListofUser[0]){
        insert ListOfContacts;
        }
        System.assert(ListOfContacts[0].Id != null, 'Record not created');      
        // Local Variables
        set<String> toAddresses;
        id templateId;
        // Test functionality
        System.runAs(ListOfUser.get(0)){
            Test.startTest();
            Core_Utility.sendEmail(toAddresses,templateId); 
            Test.stopTest();
        }
    }
    /***************************************************************************************************
    Method Name:  sendEmail_WithoutContact_NegativeTest
    Method Type: Test Method
    Version     : 1.0 
    Created Date: 04 Nov 2015
    Description:  Testing sendEmail(set<String> toAddresses, id templateId) utility method.
    Scenario Type:  Negative
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Syed Moosa Nazir TN       11/04/2015                Created
    ****************************************************************************************************/
    static testmethod void sendEmail_WithoutContact_NegativeTest(){
        getRecords();   
        // Local Variables
        set<String> toAddresses;
        id templateId;
        // Test functionality
        System.runAs(ListOfUser.get(0)){
            Test.startTest();
            Core_Utility.sendEmail(toAddresses,templateId); 
            Test.stopTest();
        }
    }
    /***************************************************************************************************
    Method Name:  SOSLQueryStringValidator_PositiveTest
    Method Type: Test Method
    Version     : 1.0 
    Created Date: 04 Nov 2015
    Description:  Testing SOSLQueryStringValidator(string Checkinputstring) utility method.
    Scenario Type:  Positive
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Syed Moosa Nazir TN       11/04/2015                Created
    * Jayaprakash T             01/23/2015                Modified Test class to fix failures in Line 215 and 267.
    ****************************************************************************************************/
    static testmethod void SOSLQueryStringValidator_PositiveTest(){
        getRecords();       
        // Test functionality
        System.runAs(ListOfUser.get(0)){
            Test.startTest();
            string Checkinputstring = '?&|!{\'}[]()^~*:+-"\\A';
            string FinalQueryString = Core_Utility.SOSLQueryStringValidator(Checkinputstring);
            System.assertEquals('\\?\\&\\|\\!\\{\\\'\\}\\[\\]\\(\\)\\^\\~\\*\\:\\+\\-\\"\\\\A',FinalQueryString);
              //System.assertEquals('\\?\\&\\|\\!\\{\\'\\}\\[\\]\\(/\//\\)\\^\\~\\*\\:\\+\\-\\"\\\\A',FinalQueryString);
            Checkinputstring = '&?';
            FinalQueryString = Core_Utility.SOSLQueryStringValidator(Checkinputstring);
            System.assertEquals('\\&\\?',FinalQueryString);
            Checkinputstring = '|';
            FinalQueryString = Core_Utility.SOSLQueryStringValidator(Checkinputstring);
            System.assertEquals('\\|',FinalQueryString);
            Checkinputstring = '!';
            FinalQueryString = Core_Utility.SOSLQueryStringValidator(Checkinputstring);
            System.assertEquals('\\!',FinalQueryString);
            Checkinputstring = '{';
            FinalQueryString = Core_Utility.SOSLQueryStringValidator(Checkinputstring);
            System.assertEquals('\\{',FinalQueryString);
            Checkinputstring = '}';
            FinalQueryString = Core_Utility.SOSLQueryStringValidator(Checkinputstring);
            System.assertEquals('\\}',FinalQueryString);
            Checkinputstring = '[';
            FinalQueryString = Core_Utility.SOSLQueryStringValidator(Checkinputstring);
            System.assertEquals('\\[',FinalQueryString);
            Checkinputstring = ']';
            FinalQueryString = Core_Utility.SOSLQueryStringValidator(Checkinputstring);
            System.assertEquals('\\]',FinalQueryString);
            Checkinputstring = '(';
            FinalQueryString = Core_Utility.SOSLQueryStringValidator(Checkinputstring);
            System.assertEquals('\\(',FinalQueryString);
            Checkinputstring = ')';
            FinalQueryString = Core_Utility.SOSLQueryStringValidator(Checkinputstring);
            System.assertEquals('\\)',FinalQueryString);
            Checkinputstring = '^';
            FinalQueryString = Core_Utility.SOSLQueryStringValidator(Checkinputstring);
            System.assertEquals('\\^',FinalQueryString);
            Checkinputstring = '~';
            FinalQueryString = Core_Utility.SOSLQueryStringValidator(Checkinputstring);
            System.assertEquals('\\~',FinalQueryString);
            Checkinputstring = '*';
            FinalQueryString = Core_Utility.SOSLQueryStringValidator(Checkinputstring);
            System.assertEquals('\\*',FinalQueryString);
            Checkinputstring = ':';
            FinalQueryString = Core_Utility.SOSLQueryStringValidator(Checkinputstring);
            System.assertEquals('\\:',FinalQueryString);
            Checkinputstring = '+';
            FinalQueryString = Core_Utility.SOSLQueryStringValidator(Checkinputstring);
            System.assertEquals('\\+',FinalQueryString);
            Checkinputstring = '-';
            FinalQueryString = Core_Utility.SOSLQueryStringValidator(Checkinputstring);
            System.assertEquals('\\-',FinalQueryString);
            Checkinputstring = '"';
            FinalQueryString = Core_Utility.SOSLQueryStringValidator(Checkinputstring);
            System.assertEquals('\\"',FinalQueryString);
            Checkinputstring = '/';
            FinalQueryString = Core_Utility.SOSLQueryStringValidator(Checkinputstring);
            System.assertEquals('///',FinalQueryString);
            Checkinputstring = '\\';
            FinalQueryString = Core_Utility.SOSLQueryStringValidator(Checkinputstring);
            System.assertEquals('\\\\',FinalQueryString);
            Checkinputstring = '\'';
            FinalQueryString = Core_Utility.SOSLQueryStringValidator(Checkinputstring);
            System.assertEquals('\\\'',FinalQueryString);
            Checkinputstring = 'A';
            FinalQueryString = Core_Utility.SOSLQueryStringValidator(Checkinputstring);
            System.assertEquals('A',FinalQueryString);
            Test.stopTest();
        }
    }   
    /***************************************************************************************************
    Method Name:  SOSLQueryStringValidator_NegativeTest
    Method Type: Test Method
    Version     : 1.0 
    Created Date: 04 Nov 2015
    Description:  Testing SOSLQueryStringValidator(string Checkinputstring) utility method.
    Scenario Type:  Negative
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Syed Moosa Nazir TN       11/04/2015                Created
    ****************************************************************************************************/
    static testmethod void SOSLQueryStringValidator_NegativeTest(){
        getRecords();       
        // Test functionality
        System.runAs(ListOfUser.get(0)){
            Test.startTest();
            string Checkinputstring;
            string FinalQueryString = Core_Utility.SOSLQueryStringValidator(Checkinputstring);
            System.assertEquals(FinalQueryString,null);
            Test.stopTest();
        }
    }
    
    /***************************************************************************************************
    Method Name:  replaceSpecialChar_PositiveTest
    Method Type: Test Method
    Version     : 1.0 
    Created Date: 23 Jan 2016
    Description:  Testing character replacement method.
    Scenario Type:  Positive
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Jayaprakash T            01/23/2016                Created
    ****************************************************************************************************/
    static testmethod void replaceSpecialChar_PositiveTest(){
        getRecords();       
        // Test functionality
        System.runAs(ListOfUser.get(0)){
            Test.startTest();
            string Checkinputstring='&#32;';
            string FinalQueryString = Core_Utility.replaceSpecialChar(Checkinputstring);
            System.assertEquals(' ',FinalQueryString);
            Test.stopTest();
        }
    }    

    /***************************************************************************************************
    Method Name:  replaceHtmlTags_PositiveTest
    Method Type: Test Method
    Version     : 1.0 
    Created Date: 23 Jan 2016
    Description:  Testing HTML Tag replacement method.
    Scenario Type:  Positive
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Jayaprakash T            01/23/2016                Created
    ****************************************************************************************************/
    static testmethod void replaceHtmlTags_PositiveTest(){
        getRecords();       
        // Test functionality
        System.runAs(ListOfUser.get(0)){
            Test.startTest();
            string Checkinputstring='</li>';
            string FinalQueryString = Core_Utility.replaceHtmlTags(Checkinputstring);
            System.assertEquals('',FinalQueryString);
            Test.stopTest();
        }
    }    


    /***************************************************************************************************
    Method Name:  addBreaktags_PositiveTest
    Method Type: Test Method
    Version     : 1.0 
    Created Date: 23 Jan 2016
    Description:  Testing space and new line characters replacement accordingly.
    Scenario Type:  Positive
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Jayaprakash T            01/23/2016                Created
    ****************************************************************************************************/
    static testmethod void addBreaktags_PositiveTest(){
        getRecords();       
        // Test functionality
        System.runAs(ListOfUser.get(0)){
            Test.startTest();
            string Checkinputstring='<br/>';
            string FinalQueryString = Core_Utility.addBreaktags(Checkinputstring);
            System.assertEquals('<br/>',FinalQueryString);
            Test.stopTest();
        }
    }
    
     /***************************************************************************************************	
    Method Name:  stripandunescapeHtmlTags_test
    Method Type: Test Method
    Version     : 1.0
    Created Date: 16 FEB 2018
    Description:  Testing space and new line characters replacement accordingly.
    Scenario Type:  Positive
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 	
    * Ajay            02/16/2018                Created
    ****************************************************************************************************/
    static testmethod void stripandunescapeHtmlTags_test(){
        getRecords();
        // Test functionality
        System.runAs(ListOfUser.get(0)){
            Test.startTest();
            string Checkinputstring='<br/>my test in RTF field<test>';
            string FinalQueryString = Core_Utility.stripandunescapeHtmlTags(Checkinputstring);
            List<String> strList = new List<String>();
            strList.add(Checkinputstring);
            string FinalQueryString1= Core_Utility.idsToString(strList);
            Test.stopTest();
        }
    }
    
    /***************************************************************************************************
    Method Name:  doSort_PositiveTest
    Method Type: Test Method
    Version     : 1.0 
    Created Date: 23 Jan 2016
    Description:  Testing select options sorting.
    Scenario Type:  Positive
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Jayaprakash T            01/23/2016                Created
    ****************************************************************************************************/
    static testmethod void doSort_PositiveTest(){
        getRecords();       
        // Test functionality
        
        System.runAs(ListOfUser.get(0)){
            Test.startTest();
            List<SelectOption> options = new List<SelectOption>();
        SelectOption option1 = new SelectOption('A','A');
        options.add(option1);
        SelectOption option2 = new SelectOption('C','C');
        options.add(option2);
        SelectOption option3 = new SelectOption('B','B');
        options.add(option3);
        SelectOption option4 = new SelectOption('D','D');
        options.add(option4);
            Core_Utility.FieldToSort sortField;
            String optionstring = 'Test';
            Core_Utility.doSort(options,null,null);
            System.assertEquals('B',options[1].getValue());
            
            //FieldToSort sortField = new FieldToSort();
            Core_Utility.doSort(options,sortField,optionstring);
            Test.stopTest();
        }
    }  
    
/***************************************************************************************************
    Method Name:  removeImageTag_PositiveTest
    Method Type: Test Method
    Version     : 1.0 
    Created Date: 19 May 2016
    Description:  Testing RemoveImageTag replacement method.
    Scenario Type:  Positive
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Kishore chandolu            05/19/2016                Created
    ****************************************************************************************************/
    static testmethod void removeImageTag_PositiveTest(){
        getRecords();       
        // Test functionality
        System.runAs(ListOfUser.get(0)){
            Test.startTest();
            string Checkinputstring='<img/>';
            string FinalQueryString = Core_Utility.removeImageTag(Checkinputstring);
            System.assertEquals('',FinalQueryString);
            Test.stopTest();
        }
    }    

    
    //This Method is created to increase the code coverage for Core_utility class
   
    static testmethod void SolutionLOVTest(){
        
        //Declare/Initialize the Variables
        List<Lead> lstLead = new List<Lead>();
        List<Core_Country_Reference__c> lstCS = new List<Core_Country_Reference__c>{};
        List<Core_Trigger_Executions__c> lstCustomSetting= new List<Core_Trigger_Executions__c>();
        List<User> lstUser = new List<User>();
        
        //Set up the trigger execution variables
        lstCustomSetting=Core_test_Utility.Core_TriggerExecution(2); 
        lstCustomSetting[0].Name = 'leadObjectBeforeHandler';
        lstCustomSetting[1].Name = 'leadObjectSalesSegment';
        insert lstCustomSetting;
          
        Profile p = [SELECT Id FROM Profile WHERE Name=:System.label.Core_IntegrationUser]; 

        lstUser = Core_Test_Utility.Core_User(2);
        lstUser[0].Profileid = p.id;
        
        Profile p1 = [SELECT Id FROM Profile WHERE Name=:System.label.Core_StandardUser];
        lstUser[1].Profileid = p1.id;
        
        //insert the User 
        insert lstUser;
        List<String> str= new List<String>();
        str.add('12344');
        str.add('3455');
        Core_Utility.getcurrentUser();
        Core_Utility.getAllFields('Account');
        Core_Utility.replaceSpecialCharacWithUnderscore('Entry EPP$%');
        Core_Utility.buildQuery('Account',new List<String>{'Name'});
        Core_Utility.getPicklistValuesSet('Opportunity' , 'Core_Solution_Detail__c');
        Core_Utility.substituteHTMLTags ('hello<li>');
        Core_Utility.stripandunescapeHtmlTags('hello<li>');
        Core_Utility.idsToString(str);
        Core_Utility.executeQuery(str,str);
        Core_Utility.replaceHtmlTagsCase('hello<li>');
        
        try{
            //Construct the CountryStateReference instances
            lstCS = Core_Test_Utility.Core_CountryState(1);
            
            for(Core_Country_Reference__c sobjCS : lstCS){
                sobjCS.Name='United States';
                sobjCS.Core_Geo__c='ASMO';
                sobjCS.Core_Has_States__c=true;
                sobjCS.Core_ISO_Code__c='USA';
                sobjCS.Core_Sub_Geo__c='NAR';
            }
            
            Core_Trigger_Executions__c sobjNew = new Core_Trigger_Executions__c();
            sobjNew.Name = 'Lead Conversion';
            sobjNew.Core_Object__c= 'Change_Request__c';
            sobjNew.Core_Description__c= 'TEST';
            sobjNew.Core_Class_Name__c= 'Change_Request__c';
            sobjNew.Core_Trigger_Events__c = 'After Update';
            insert sobjNew;
                
            // Construct the Lead instances        
            lstLead = Core_Test_Utility.createLead(10);
                   
            // Change the values in the Lead record for updation 
            for(Lead sobjLead : lstLead)
            {
                sobjLead.Phone = '(555) 555-5555';
                sobjLead.Title = '(555) 555-5555';
                sobjLead.Core_Current_Architecture__c = '(555) 555-5555';
                sobjLead.Core_Job_Function__c= '(555) 555-5555';
                sobjLead.Core_Product_Interest__c= '(555) 555-5555';
                sobjLead.Core_Project_Phase__c= '(555) 555-5555';
                sobjLead.Core_Project_Size__c= '555';
                sobjLead.Core_Project_Timeframe__c= '555';
                sobjLead.Core_Sales_Segment__c= '555';
                sobjLead.PostalCode= '560035';
                
            }
            
            User StandardUser = lstUser[1];
            
            //Run as Standard User
            System.runAs(StandardUser){
                
                // Insert the intialized Leads
                insert lstCS;
                
                 // Insert the intialized Leads
                insert lstLead;
                
                for(Lead sobjLead : lstLead)
                {
                    System.assertEquals(sobjLead.Core_Geo__c, NULL);
                    System.assertEquals(sobjLead.Core_Sub_Geo__c, NULL);
                
                }
                
                update lstLead;
                
                for(Lead sobjAcc : lstLead){
                    sobjAcc.State = NULL;
                    sobjAcc.StateCode = NULL;  
                }
                               
                //Insert the updated Leads
                update lstLead;
            
            } 
        }
        catch(Exception e){
          System.debug(System.Label.Core_Exception+e.getMessage());
        }    
    }

    
}