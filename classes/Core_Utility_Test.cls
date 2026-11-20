/**************************************************************************************
Apex Class Name:  Core_Utility_Test 
Version     : 1.0 
Created Date: 24 OCT 2014
Function    : Test Class for the Core_Utility
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* kunal mehta         10/24/2014              Original Version
*************************************************************************************/@isTest
public class Core_Utility_Test {

    /*
    * Method name  : testWebserviceUtility
    * Description  : Method to setup test data ( WebServiceUtility)
    * Return Type  : None
    * Parameter    : None
    */
   /** static testMethod void testUtilitymethods() {
    
        //Declare/Initialize the Variables
        List<Lead> lstLead = new List<Lead>();
        List<Core_Prospect__c> lstPros = new List<Core_Prospect__c>();
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
        
        Core_Utility.getcurrentUser();
        Core_Utility.getAllFields('Account');
        Core_Utility.replaceSpecialCharacWithUnderscore('Entry EPP$%');
        Core_Utility.buildQuery('Account',new List<String>{'Name'});
              
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
            system.assertEquals('Lead Conversion', sobjNew.Name);
                
            Core_Trigger_Executions__c sobjPros = new Core_Trigger_Executions__c();
            sobjPros.Name = 'prospectObjectBeforeHandler';
            sobjPros.Core_Object__c= 'Core_Prospect__c';
            sobjPros.Core_Description__c= 'Used for Prospect trigger';
            sobjPros.Core_Class_Name__c= 'Core_Prospect__c';
            sobjPros.Core_Trigger_Events__c = 'before insert,before update';
            sobjPros.Core_Active__c=True;
            insert sobjPros;
            

            
            // Construct the Lead instances        
            lstLead = Core_Test_Utility.createLead(210);
            
            Core_Prospect__c pros = new Core_Prospect__c();
            pros.Core_URLElectronicAddressTxt__c = 'Test';
            pros.Core_Country_Pkt__c = 'USA';
            pros.Core_Source_Pkt__c = 'Sales AI';
            lstPros.add(pros);
            insert lstPros;
            system.assertEquals(210, lstLead.size());
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
    **/
    static testMethod void testUtilitymethods3() {
    
        //Declare/Initialize the Variables
        List<Lead> lstLead = new List<Lead>();
        List<Core_Prospect__c> lstPros = new List<Core_Prospect__c>();
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
        
        Core_Utility.getcurrentUser();
        Core_Utility.getAllFields('Account');
        Core_Utility.replaceSpecialCharacWithUnderscore('Entry EPP$%');
        Core_Utility.buildQuery('Account',new List<String>{'Name'});
              
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
           
            
           
            

            
            // Construct the Lead instances        
            //lstLead = Core_Test_Utility.createLead(210);
            
           Core_Prospect__c pros = new Core_Prospect__c();
                pros.Core_URLElectronicAddressTxt__c = 'Test';
                pros.Core_Country_Pkt__c = 'USA';
                pros.Core_Source_Pkt__c = 'Sales AI';
                pros.Core_Status_Pkt__c = 'New';
                lstPros.add(pros);
            
                  
            
            User StandardUser = lstUser[1];
            
            //Run as Standard User
            System.runAs(StandardUser){
                
                // Insert the intialized Leads
                insert lstCS;
               
                 // Insert the prospect
                insert lstPros;
                // insert lstPros;
            Lead leadRec = new Lead();
            leadRec.Phone = '(555) 555-5555';
            leadRec.email = 'test@0.com';
            leadRec.leadSource = 'Sales AI';
            leadRec.Country = 'United States';
            leadRec.Company = 'Test Company';
            leadRec.Core_Prospect__c = lstPros[0].Id;
            leadRec.FirstName = 'Test FN';
            leadRec.lastName = 'Test LN';
            leadRec.status = 'Tele Accepted Lead';
            leadRec.Core_Lead_State__c = 'In Pursuit'; 
            lstLead.add(leadRec);
                
            Lead leadRec1 = new Lead();
            leadRec1.Phone = '(555) 555-5555';
            leadRec1.email = 'test@0.com';
            leadRec1.leadSource = 'Sales AI';
            leadRec1.Country = 'United States';
            leadRec1.CountryCode ='USA';
            leadRec1.Company = 'Test Company';
            leadRec1.FirstName = 'Test FN1';
            leadRec1.lastName = 'Test LN1';
            leadRec1.status = 'Tele Accepted Lead';
            leadRec1.Core_Lead_State__c = 'In Pursuit';
            lstLead.add(leadRec1);
            insert lstLead; 
                
            
                
            } 
        }
        catch(Exception e){
          System.debug(System.Label.Core_Exception+e.getMessage());
        }    
    }
    
    
     static testMethod void testUtilitymethods1() {
         List<Core_Prospect__c> lstPros = new List<Core_Prospect__c>();
          List<User> lstUser = new List<User>();
       
         Profile p = [SELECT Id FROM Profile WHERE Name=:System.label.Core_IntegrationUser]; 

        lstUser = Core_Test_Utility.Core_User(2);
        lstUser[0].Profileid = p.id;
         
         Core_Country_Reference__c sobjCS=new Core_Country_Reference__c();
                sobjCS.Name='India';
                sobjCS.Core_Geo__c='APJ';
                sobjCS.Core_Has_States__c=true;
                sobjCS.Core_ISO_Code__c='IND';
                sobjCS.Core_Sub_Geo__c='India';
         insert sobjCS;
         system.assertEquals('India', sobjCS.Name);
            
         Core_Trigger_Executions__c sobjPros = new Core_Trigger_Executions__c();
            sobjPros.Name = 'prospectObjectBeforeHandler';
            sobjPros.Core_Object__c= 'Core_Prospect__c';
            sobjPros.Core_Description__c= 'Used for Prospect trigger';
            sobjPros.Core_Class_Name__c= 'Core_Prospect__c';
            sobjPros.Core_Trigger_Events__c = 'before insert,before update';
            sobjPros.Core_Active__c=True;
            insert sobjPros;
         system.assertEquals('prospectObjectBeforeHandler', sobjPros.Name);
         
         List <Core_Prospect__c> prosList = new List <Core_Prospect__c> ();
        for (integer i = 0; i <100; i++) {
            Core_Prospect__c  prosInstance= new Core_Prospect__c();
            prosInstance.Core_Country_Pkt__c = 'USA';
            prosInstance.Core_Source_Pkt__c='Sales AI';
            prosInstance.Core_URLElectronicAddressTxt__c='google.com';
            prosList.add(prosInstance);

        }
         if(prosList.size() > 0){
              system.runAs(lstUser[0]){
        insert prosList;
            }
         }
         
         
     }
    public static testmethod void Core_Utility_SOSLQueryStringValidator(){
    
        String s ='select id from case?&|!{}[]()^~*+#;-""/';
        Core_Utility.SOSLQueryStringValidator(s);
    
    }
    public static testmethod void Core_Utility_replaceSpecialChar(){
    
        String S ='select id from case?&|!@$%&{}[]()^~*+#;-""/';
        Core_Utility.replaceSpecialChar(S);
    
    }
    public static testmethod void Core_Utility_replaceHtmlTagsCase(){
    
        String S ='select id from case?&|!@$%&{}[]()^~*+#;-""/';
        Core_Utility.replaceHtmlTagsCase(S);
    
    }
    public static testmethod void Core_Utility_replaceHtmlTags(){
    
        String S ='select id from case?&|!@$%&{}[]()^~*+#;-""/';
        Core_Utility.replaceHtmlTags(S);
    
    }
    
    public static testmethod void Core_Utility_idsToString(){
        List<SelectOption> options = new List<SelectOption>();
        SelectOption option1 = new SelectOption('A','A');
        options.add(option1);
        SelectOption option2 = new SelectOption('C','C');
        options.add(option2);
        SelectOption option3 = new SelectOption('B','B');
        options.add(option3);
        SelectOption option4 = new SelectOption('D','D');
        options.add(option4);
        Core_Utility.FieldToSort sortField=null;
         List<string>  str = new List<string>();
         str.add('00eo0000000f7Gd');
          str.add('00eo0000000f7GT');
           str.add('00eo0000000TVVi');
        String userId = '00eo0000000TVVi';
        Core_Utility.getPartnerUserType(userId);
        Core_Utility.isSupOrgAdmPermUser(userId);
        Core_Utility.stripandunescapeHtmlTags(userId);
        Core_Utility.doSort(options,sortField,'');
        Core_Utility.removeImageTag('<img[^>]+>');
        //Core_Utility.getPicklistValuesSet('Opportunity' , 'Core_Solution_Detail__c');
        Core_Utility.idsToString(str);
    }
   
   public static testmethod void Core_Utility_substituteHTMLTags(){
      String Str = 'select id from case?&|!@$%&{}[]()^~*+#;-""/';
      Core_Utility.substituteHTMLTags(Str);
   }
    public static testmethod void Core_Utility_addBreaktags(){
      String Str = 'select id from case?&|!@$%&{}[]()^~*+#;-""/';
      Core_Utility.addBreaktags(Str);
   }
   public static testmethod void Core_Utility_executeQuery(){
        List<string>  oldids = new List<string>();
        List<string>  newids = new List<string>();
        oldids.add('00eo0000000f7Gd');
        newids.add('00eo0000000TVVi');
        Core_Utility.executeQuery(newids ,oldids);
       
       
   }
   public static testmethod void Core_Utility_sendEmail(){
     set<String> toAddress = new set<String>();
      id templateId;
     Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
      Account testAccount=TestUtilities.getAccount();
            insert testAccount;
     Contact testContact = new Contact(FirstName='testFirstName123', LastName='testLastName', Email='test12345@testing.com.testsetup',MailingCountry = 'USA',
                                     AccountId=testAccount.id,Core_Personal_Email_Indicator__c = true,Core_Enterprise_Id__c='12345',Core_AGS_Integration_Status__c='Successful');
     insert testContact;
       system.assertEquals('testFirstName123', testContact.FirstName);
     Core_Utility.sendEmail(toAddress,templateId);
   }
  
}