/******************************************************************************************************************************************
Trigger Name:  Core_Solution_Area_ControllerTest
Version     : 1.0 
Function    : Test Class to update long text with multiple picklists
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Gaurav Kurwade             18/11/2022              Original Version
*****************************************************************************************************************************************/

@isTest
public class Core_Solution_Area_Ctrl_Test {

    static testMethod void addSolAreaTest(){
        
        
        Id newOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_New_Opportunity' limit 1][0].Id;
        
        // Create an account
        Account acct = new Account(Name = 'TestAccount', BillingStreet = '123 Fake St',
                                   BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',Industry='Agriculture',Core_Sub_Industry__c= 'Crop Production',
                                   BillingPostalCode = '12345', Core_Business_Party_Id__c = '8675309',Core_Sales_Groups__c='Americas Brazil Sales Group');
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert acct;
        }
        
        Opportunity opps = new Opportunity(Name = 'Opportunity to Lose 03-24-2015', RecordTypeId = newOppRecTypeId,
                                           AccountId = acct.Id,
                                           StageName = 'Qualifying', CloseDate = System.Date.today().addYears(1));
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert opps;
        }
        
        List<Core_Solution_Areas__c> SAList= new List<Core_Solution_Areas__c>();
        Map<Id, Core_Solution_Areas__c> SAMap= new Map<Id, Core_Solution_Areas__c>();
        Core_Solution_Areas__c cSA = new Core_Solution_Areas__c();
        cSA.Name = 'Test1'+ (Math.random() * 10);
        cSA.Core_Version__c = 'Test1.0';
        cSA.Core_End_Customer_Solution__c = 'Yes';
        
      
            cSA.Core_Solution_Type__c = 'S1: Product';
           
            cSA.Core_Design_Visible__c = true;
         cSA.Core_Deal_Visible__c = true;
         
            cSA.Core_Status__c = 'Active';
            
            cSA.Core_Industry_Use_Case__c='Visual Cloud-CDN/vCDN';
           cSA.Core_Application_Workload__c='AI Training';
         cSA.Core_Technology_Enabled__c='AMT';
         cSA.Core_Solution_Description__c ='Desc...';
         
         cSA.Core_Solution_owner_email__c ='wwwwwasfdasdf@test.com';
         cSA.Core_Region_of_availability__c = 'PRC';
        
        
        insert cSA;
        SAMap.put(cSA.Id, cSA);
        
        System.runAs(Core_Test_Utility.systemAdminUser) {
            List<Core_Trigger_Executions__c> triggerExecList = new List<Core_Trigger_Executions__c>();
            triggerExecList.add(new Core_Trigger_Executions__c(Name='updateJSONSolutionArea', Core_Class_Name__c='updateJSONSolutionArea', Core_Object__c='OpportunitySolutionArea', Core_Trigger_Events__c='After Insert before Delete', Core_Active__c=true, Core_Description__c = 'blah blah'));
            insert triggerExecList;
            List<Opportunity_Solution_Area__c> oSAList= new List<Opportunity_Solution_Area__c>();
            Opportunity_Solution_Area__c oSA= new Opportunity_Solution_Area__c();
            oSA.Core_Opportunity__c = opps.id;
            oSA.Core_Solution_Areas__c =cSA.id;
            insert oSA;
            oSAList.add(oSA);
            Test.startTest();
            update cSA;
            SAList.add(cSA);
            Core_Solution_Area_Controller.updatedValuesToSolution(SAList, SAMap);
            Test.stopTest();
        }
        
    }
  
    static testMethod void updateSolAreaTest(){
        
        
        Id newOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_New_Opportunity' limit 1][0].Id;
        
        // Create an account
        Account acct = new Account(Name = 'TestAccountss', BillingStreet = '123 Fake St',
                                   BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',Industry='Agriculture',Core_Sub_Industry__c= 'Crop Production',
                                   BillingPostalCode = '12345', Core_Business_Party_Id__c = '8675309',Core_Sales_Groups__c='Americas Brazil Sales Group');
        
            insert acct;
        
        
        Opportunity opps = new Opportunity(Name = 'Opportunity to Lose 03-24-2015', RecordTypeId = newOppRecTypeId,
                                           AccountId = acct.Id,
                                           StageName = 'Qualifying', CloseDate = System.Date.today().addYears(1));
        
            insert opps;
        
        
        List<Core_Solution_Areas__c> SAList= new List<Core_Solution_Areas__c>();
        Map<Id, Core_Solution_Areas__c> SAMap= new Map<Id, Core_Solution_Areas__c>();
        Core_Solution_Areas__c cSA = new Core_Solution_Areas__c();
        cSA.Name = 'Test1';
        cSA.Core_Version__c = 'Test1.0';
        cSA.Core_End_Customer_Solution__c = 'Yes';
            cSA.Core_Solution_Type__c = 'S1: Product';
           
            cSA.Core_Design_Visible__c = true;
         cSA.Core_Deal_Visible__c = true;
         
            cSA.Core_Status__c = 'Active';
            
            cSA.Core_Industry_Use_Case__c='Visual Cloud-CDN/vCDN';
           cSA.Core_Application_Workload__c='AI Training';
         cSA.Core_Technology_Enabled__c='AMT';
         cSA.Core_Solution_Description__c ='Desc...';
         
         cSA.Core_Solution_owner_email__c ='wwwwwasfdasdf@test.com';
         cSA.Core_Region_of_availability__c = 'PRC';
        
        
        insert cSA;
        SAMap.put(cSA.Id, cSA);
        
        
            List<Core_Trigger_Executions__c> triggerExecList = new List<Core_Trigger_Executions__c>();
            triggerExecList.add(new Core_Trigger_Executions__c(Name='updateJSONSolutionArea', Core_Class_Name__c='updateJSONSolutionArea', Core_Object__c='OpportunitySolutionArea', Core_Trigger_Events__c='After Insert before Delete', Core_Active__c=true, Core_Description__c = 'blah blah'));
            insert triggerExecList;
            List<Core_Trigger_Executions__c> triggerExecList1 = new List<Core_Trigger_Executions__c>();
            triggerExecList1.add(new Core_Trigger_Executions__c(Name='addSolutionRelatedRecords', Core_Class_Name__c='addSolutionRelatedRecords', Core_Object__c='Solutions', Core_Trigger_Events__c='After Insert', Core_Active__c=true, Core_Description__c = 'blah blah'));
            insert triggerExecList1;
            List<Opportunity_Solution_Area__c> oSAList= new List<Opportunity_Solution_Area__c>();
            Opportunity_Solution_Area__c oSA= new Opportunity_Solution_Area__c();
            oSA.Core_Opportunity__c = opps.id;
            oSA.Core_Solution_Areas__c =cSA.id;
            insert oSA;
            oSAList.add(oSA);
            Test.startTest();
            
        cSA.Core_End_Customer_Solution__c = 'No';
            update cSA;
            SAList.add(cSA);
            Core_Solution_Area_Controller.addValuesToSolution(SAList);
            Test.stopTest();
        }
        
    
    static testMethod void restrictSolAreaTest(){
        
        
        Id newOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_New_Opportunity' limit 1][0].Id;
        
        // Create an account
        Account acct = new Account(Name = 'TestAccounts', BillingStreet = '123 Fake St',
                                   BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',Industry='Agriculture',Core_Sub_Industry__c= 'Crop Production',
                                   BillingPostalCode = '12345', Core_Business_Party_Id__c = '8675309',Core_Sales_Groups__c='Americas Brazil Sales Group');
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert acct;
        }
        
        Opportunity opps = new Opportunity(Name = 'Opportunity to Lose 03-24-2015', RecordTypeId = newOppRecTypeId,
                                           AccountId = acct.Id,
                                           StageName = 'Qualifying', CloseDate = System.Date.today().addYears(1));
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert opps;
        }
        
        List<Core_Solution_Areas__c> SAList= new List<Core_Solution_Areas__c>();
        Map<Id, Core_Solution_Areas__c> SAMap= new Map<Id, Core_Solution_Areas__c>();
        Core_Solution_Areas__c cSA = new Core_Solution_Areas__c();
        cSA.Name = 'Test1'+ (Math.random() * 10);
        cSA.Core_Version__c = 'Test1.0';
        cSA.Core_End_Customer_Solution__c = 'Yes';
        insert cSA;
        SAMap.put(cSA.Id, cSA);
        
        System.runAs(Core_Test_Utility.systemAdminUser) {
            List<Core_Trigger_Executions__c> triggerExecList = new List<Core_Trigger_Executions__c>();
            triggerExecList.add(new Core_Trigger_Executions__c(Name='updateJSONSolutionArea', Core_Class_Name__c='updateJSONSolutionArea', Core_Object__c='OpportunitySolutionArea', Core_Trigger_Events__c='After Insert before Delete', Core_Active__c=true, Core_Description__c = 'blah blah'));
            insert triggerExecList;
            List<Opportunity_Solution_Area__c> oSAList= new List<Opportunity_Solution_Area__c>();
            Opportunity_Solution_Area__c oSA= new Opportunity_Solution_Area__c();
            oSA.Core_Opportunity__c = opps.id;
            oSA.Core_Solution_Areas__c =cSA.id;
            insert oSA;
            oSAList.add(oSA);
            Test.startTest();
            
            cSA.Core_End_Customer_Solution__c = 'No';            
            cSA.Core_Solution_Type__c = 'S1: Product';
            cSA.Core_End_Customer_Solution__c = 'Yes';
            cSA.Core_Design_Visible__c = true;
            cSA.Core_Status__c = 'Active';
           
            update cSA;
            SAList.add(cSA);
            Core_Solution_Area_Controller.restrictPicklists(SAList, SAMap);
            Core_Solution_Area_Controller.updatedValuesToSolution(SAList, SAMap);
            Test.stopTest();
        }
        
    }
    static testMethod void restrict2SolAreaTest(){
        
        
        Id newOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_New_Opportunity' limit 1][0].Id;
        
         User usr = [select id, name, profile.name,IsActive, userrole.name from user where profile.name = 'Data Ops' AND IsActive =true Limit 1];                   

        // Create an account
        Account acct = new Account(Name = 'TestAccounts', BillingStreet = '123 Fake St',
                                   BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',Industry='Agriculture',Core_Sub_Industry__c= 'Crop Production',
                                   BillingPostalCode = '12345', Core_Business_Party_Id__c = '8675309',Core_Sales_Groups__c='Americas Brazil Sales Group');
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert acct;
        }
        
        Opportunity opps = new Opportunity(Name = 'Opportunity to Lose 03-24-2015', RecordTypeId = newOppRecTypeId,
                                           AccountId = acct.Id,
                                           StageName = 'Qualifying', CloseDate = System.Date.today().addYears(1));
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert opps;
        }
        
        List<Core_Solution_Areas__c> SAList= new List<Core_Solution_Areas__c>();
        Map<Id, Core_Solution_Areas__c> SAMap= new Map<Id, Core_Solution_Areas__c>();
        Core_Solution_Areas__c cSA = new Core_Solution_Areas__c();
        cSA.Name = 'Test1';
        cSA.Core_Version__c = 'Test1.0';
        cSA.Core_End_Customer_Solution__c = 'Yes';
        insert cSA;
        SAMap.put(cSA.Id, cSA);
        
        
            List<Core_Trigger_Executions__c> triggerExecList = new List<Core_Trigger_Executions__c>();
            triggerExecList.add(new Core_Trigger_Executions__c(Name='updateJSONSolutionArea', Core_Class_Name__c='updateJSONSolutionArea', Core_Object__c='OpportunitySolutionArea', Core_Trigger_Events__c='After Insert before Delete', Core_Active__c=true, Core_Description__c = 'blah blah'));
            insert triggerExecList;
            List<Opportunity_Solution_Area__c> oSAList= new List<Opportunity_Solution_Area__c>();
            Opportunity_Solution_Area__c oSA= new Opportunity_Solution_Area__c();
            oSA.Core_Opportunity__c = opps.id;
            oSA.Core_Solution_Areas__c =cSA.id;
            insert oSA;
            oSAList.add(oSA);
            Test.startTest();
            
        cSA.Core_End_Customer_Solution__c = 'No';
            update cSA;
            SAList.add(cSA);
        System.runAs(usr) {
            Core_Solution_Area_Controller.restrictPicklists(SAList, SAMap);
              Core_Solution_Area_Controller.updatedValuesToSolution(SAList, SAMap);
        }Test.stopTest();
        
    }
    
    
     public static testmethod void addValuesToSolution(){
    
         List<Core_Solution_Areas__c> solutionArea = new List<Core_Solution_Areas__c>();
        Core_Solution_Areas__c solStor = new Core_Solution_Areas__c();
            solStor.Name='Test Solution 1111';
            solStor.Core_Solution_Type__c = 'S1: Product';
            solStor.Core_End_Customer_Solution__c = 'Yes';
            solStor.Core_Design_Visible__c = true;
            solStor.Core_Status__c = 'Active';            
            solStor.Core_Version__c ='1';
            insert solStor;
          solutionArea.add(solStor);
         
        List<String> saPickval = new List<String>();      
          Test.StartTest();
        for(Core_Solution_Areas__c saPick: solutionArea){
             Integer SolnCnt = [SELECT count() from Core_Solution_Areas__c where Core_Version__c = :saPick.Core_Version__c and name= :saPick.Name];
            if ( SolnCnt <= 0)
            {
                if(saPick.Core_Application_Workload__c != null || saPick.Core_Industry_Use_Case__c!= null || saPick.Core_Region_of_availability__c!= null || saPick.Core_Technology_Enabled__c!= null || saPick.Core_Industry__c!= null || saPick.Core_Solution_owner_email__c != null || saPick.Core_Solution_Type__c != null){
                    saPick.Core_Solution_Long__c = saPick.Core_Application_Workload__c+';'+saPick.Core_Industry_Use_Case__c+';'+saPick.Core_Region_of_availability__c+';'+saPick.Core_Technology_Enabled__c+';'+saPick.Core_Industry__c+';'+saPick.Core_Solution_owner_email__c+';'+saPick.Core_End_Customer_Solution__c+';'+saPick.Core_Solution_Type__c+';'+saPick.Core_Content_Link__c;
                       DateTime dT = System.now();                          
                    saPick.Core_Most_Recent_Status_Change_Date__c = date.newinstance(dT.year(), dT.month(), dT.day());
                    update saPick;
                }
            }
           else
            {
              
                   saPick.addError(Label.Core_Solution_exist);
            }
        }
         
           Test.StopTest();
    }
    
    public static testmethod void updatedValuesToSolution(){
         List<Core_Solution_Areas__c> SAList= new List<Core_Solution_Areas__c>();
        Map<Id, Core_Solution_Areas__c> SAMap= new Map<Id, Core_Solution_Areas__c>();
        Core_Solution_Areas__c cSA = new Core_Solution_Areas__c();
        cSA.Name = 'Test1'+ (Math.random() * 10);
        cSA.Core_Version__c = 'Test1.0';
         cSA.Core_Solution_Type__c = 'S1: Product';
            cSA.Core_End_Customer_Solution__c = 'Yes';
            cSA.Core_Design_Visible__c = true;
            cSA.Core_Status__c = 'Active';
        
        insert cSA;
        SAMap.put(cSA.Id, cSA);
          Test.startTest();
            update cSA;
            SAList.add(cSA);
            Core_Solution_Area_Controller.updatedValuesToSolution(SAList, SAMap);
        
        
        
         
           
        
         List<Core_Solution_Areas__c> newSolutionArea= new  List<Core_Solution_Areas__c>();
            
         List<Core_Solution_Areas__c> oldSolutionArea= new List<Core_Solution_Areas__c>();
        
        Core_Solution_Areas__c solStor = new Core_Solution_Areas__c();
            solStor.Name='Test Solution 1111';
            solStor.Core_Solution_Type__c = 'S1: Product';
            solStor.Core_End_Customer_Solution__c = 'Yes';
            solStor.Core_Design_Visible__c = true;
            solStor.Core_Status__c = 'Active';
            solStor.Core_Version__c ='1';
            //solStor.Id='12345';
            insert solStor;
                
           
          newSolutionArea.add(solStor);
          oldSolutionArea.add(solStor);
        
          
     
          String usrProfileName = [select Profile.Name from User where id = :Userinfo.getUserId()].Profile.Name;
        List<String> saPickval = new List<String>();
        for(Core_Solution_Areas__c saPick: newSolutionArea){
            
            if(newSolutionArea.size()>0){
                for(Core_Solution_Areas__c OppSA: newSolutionArea){
                   
                    if (OppSA.Core_Status__c!= 'EOL' )
                     {
                      if (saPick.Core_Status__c!= 'EOL')
                        {
                      
                            OppSA.Core_Solution_Long__c = OppSA.Core_Region_of_availability__c+';'+OppSA.Core_Industry__c+';'+OppSA.Core_Solution_owner_email__c+';'+OppSA.Core_End_Customer_Solution__c+';'+OppSA.Core_Solution_Type__c+';'+OppSA.Core_Content_Link__c;
                          
                        }
                        else
                        {
                             OppSA.Core_Solution_Long__c =null;
                               DateTime dT = System.now();                          
                            OppSA.Core_Most_Recent_Status_Change_Date__c = date.newinstance(dT.year(), dT.month(), dT.day());
                        }
                    }
                    else if (saPick.Core_Status__c== 'EOL' )
                    {
                       
                          OppSA.Core_Solution_Long__c = null;
                           DateTime dT = System.now();                          
                            OppSA.Core_Most_Recent_Status_Change_Date__c = date.newinstance(dT.year(), dT.month(), dT.day());
                    }
                    update OppSA;
                  
                }
            }
        }
            solStor.Core_Version__c ='1.122';
            solStor.Name='Test Solution 1111211';
           
        
            Integer SolnCnt = [SELECT count() from Core_Solution_Areas__c where Core_Version__c = :solStor.Core_Version__c and name= :solStor.Name];
            if ( SolnCnt <= 0)
            {
                 update solStor;
            }
        

            solStor.Core_Status__c = 'EOL';             
            solStor.Core_Solution_Long__c =null;
           DateTime dT = System.now();                          
            solStor.Core_Most_Recent_Status_Change_Date__c = date.newinstance(dT.year(), dT.month(), dT.day());
            update solStor; 
        
         SolnCnt = [SELECT count() from Core_Solution_Areas__c where Core_Version__c = :solStor.Core_Version__c and name= :solStor.Name];
          
        
        if (solStor.Core_Status__c == 'EOL'&&  SolnCnt>0 )
        {
            solStor.addError('Cannot edit EOL solutions');
            
        }
        else
        {
            solStor.Core_Solution_Long__c ='Test';
            update solStor; 
            update solStor; 
        }
         Test.StopTest();
    }
    
    
     public static testmethod void updatedValuesToSolution1(){
          Test.StartTest();
           Core_Solution_Areas__c cSA1= new Core_Solution_Areas__c();
            cSA1.Name='Product';
            cSA1.Core_Solution_Type__c = 'S1: Product';
            cSA1.Core_End_Customer_Solution__c = 'Yes';
            cSA1.Core_Design_Visible__c = true;
          cSA1.Core_Deal_Visible__c = true;
            cSA1.Core_Status__c = 'Active';
            cSA1.Core_Version__c ='1';
            cSA1.Core_Industry_Use_Case__c='Visual Cloud-CDN/vCDN';
           cSA1.Core_Application_Workload__c='AI Training';
         cSA1.Core_Technology_Enabled__c='AMT';
         cSA1.Core_Solution_Description__c ='Desc';
         
         cSA1.Core_Solution_owner_email__c ='wwwwwasfdasdf@test.com';
         cSA1.Core_Region_of_availability__c = 'PRC';
             
        insert cSA1;
         //A1= new Core_Solution_Areas__c();
            cSA1.Name='Product1';
            cSA1.Core_Solution_Type__c = 'S1: Product';
            cSA1.Core_End_Customer_Solution__c = 'Yes';
            cSA1.Core_Design_Visible__c = true;
         cSA1.Core_Deal_Visible__c = true;
         
            cSA1.Core_Status__c = 'Active';
            cSA1.Core_Version__c ='1.1';
            cSA1.Core_Industry_Use_Case__c='Visual Cloud-CDN/vCDN';
           cSA1.Core_Application_Workload__c='AI Training';
         cSA1.Core_Technology_Enabled__c='AMT';
         cSA1.Core_Solution_Description__c ='Desc...';
         
         cSA1.Core_Solution_owner_email__c ='wwwwwasfdasdf@test.com';
         cSA1.Core_Region_of_availability__c = 'PRC';
         
         update cSA1;
       list <Core_Solution_Areas__c>  solutionArea=new list <Core_Solution_Areas__c>();
         solutionArea.add(cSA1);
          for(Core_Solution_Areas__c saPick: solutionArea){
             Integer SolnCnt = [SELECT count() from Core_Solution_Areas__c where Core_Version__c = :saPick.Core_Version__c and name= :saPick.Name];
            if ( SolnCnt <= 0)
            {
                if(saPick.Core_Application_Workload__c != null || saPick.Core_Industry_Use_Case__c!= null || saPick.Core_Region_of_availability__c!= null || saPick.Core_Technology_Enabled__c!= null || saPick.Core_Industry__c!= null || saPick.Core_Solution_owner_email__c != null || saPick.Core_Solution_Type__c != null){
                    saPick.Core_Solution_Long__c = saPick.Core_Application_Workload__c+';'+saPick.Core_Industry_Use_Case__c+';'+saPick.Core_Region_of_availability__c+';'+saPick.Core_Technology_Enabled__c+';'+saPick.Core_Industry__c+';'+saPick.Core_Solution_owner_email__c+';'+saPick.Core_End_Customer_Solution__c+';'+saPick.Core_Solution_Type__c+';'+saPick.Core_Content_Link__c;
                        
                }
            }
           else
            {
              
                   saPick.addError(Label.Core_Solution_exist);
            }
                if (saPick.Core_Status__c== 'EOL' )
                    {
                       // this is for IT admin...update while disabling the Validation rule
                         saPick.Core_Solution_Long__c = null;
                            DateTime dT = System.now();                         
                        saPick.Core_Most_Recent_Status_Change_Date__c = date.newinstance(dT.year(), dT.month(), dT.day());
                        
                        
                    }
          }
         
            cSA1.Name='Product1';
            cSA1.Core_Solution_Type__c = 'S1: Product';
            cSA1.Core_End_Customer_Solution__c = 'Yes';
            cSA1.Core_Design_Visible__c = true;
         cSA1.Core_Deal_Visible__c = true;
         
            cSA1.Core_Status__c = 'EOL';
            cSA1.Core_Version__c ='1.1';
            cSA1.Core_Industry_Use_Case__c='Visual Cloud-CDN/vCDN';
           cSA1.Core_Application_Workload__c='AI Training';
         cSA1.Core_Technology_Enabled__c='AMT';
         cSA1.Core_Solution_Description__c ='Desc...';
         
         cSA1.Core_Solution_owner_email__c ='wwwwwasfdasdf@test.com';
         cSA1.Core_Region_of_availability__c = 'PRC';
         DateTime dT = System.now();                            
          cSA1.Core_Most_Recent_Status_Change_Date__c = date.newinstance(dT.year(), dT.month(), dT.day());
                        
         update cSA1;  
         
     List<Core_Solution_Areas__c> newSolutionArea= new List<Core_Solution_Areas__c>();
        Map<Id, Core_Solution_Areas__c> oldSolutionArea= new Map<Id, Core_Solution_Areas__c>();
        Core_Solution_Areas__c cSA = new Core_Solution_Areas__c();
        cSA.Name = 'Test1zzzz';
      
            cSA.Core_Solution_Type__c = 'S1: Product';
            cSA.Core_End_Customer_Solution__c = 'Yes';
            cSA.Core_Design_Visible__c = true;
            cSA.Core_Status__c = 'Active';
            cSA.Core_Version__c ='1';
            cSA.Core_Industry_Use_Case__c='Visual Cloud-CDN/vCDN';
            newSolutionArea.add(cSA);
          Core_Solution_Area_Controller.addValuesToSolution(newSolutionArea);
 
            cSA.Core_Design_Visible__c = false;
         newSolutionArea= new List<Core_Solution_Areas__c>();
         newSolutionArea.add(cSA);
              Core_Solution_Area_Controller.addValuesToSolution(newSolutionArea);     
        insert cSA;
        oldSolutionArea.put(cSA.Id, cSA);
         
         String usrProfileName = [select Profile.Name from User where id = :Userinfo.getUserId()].Profile.Name;
            Integer usrPermissionsetCnt = [SELECT count() FROM PermissionSetAssignment WHERE AssigneeId = :Userinfo.getUserId() AND PermissionSet.Name = 'Core_CRM_Special_Access'];
        
            
            if(oldSolutionArea.size()>0){
                for(Core_Solution_Areas__c OppSA: newSolutionArea){
                
                    cSA.Core_Version__c ='1.19';
                    
                    update cSA;
                    if(usrProfileName != 'IT Admin' && (OppSA.Core_Industry_Use_Case__c != oldSolutionArea.get(OppSA.Id).Core_Industry_Use_Case__c || OppSA.Core_Application_Workload__c != oldSolutionArea.get(OppSA.Id).Core_Application_Workload__c || OppSA.Core_Technology_Enabled__c != oldSolutionArea.get(OppSA.Id).Core_Technology_Enabled__c || OppSA.Core_Version__c != oldSolutionArea.get(OppSA.Id).Core_Version__c)){
                        System.debug('IN::Pick');
                        OppSA.addError(Label.restrictPicklists_for_Solutions);                               
                    }
                    cSA.Name ='1.110000';
                    cSA.Core_Version__c ='1.188';
                    update cSA;
                         if(usrProfileName != 'IT Admin' && usrProfileName != 'Data Ops' && usrPermissionsetCnt == 0 &&  (OppSA.Name != oldSolutionArea.get(OppSA.Id).Name || OppSA.OwnerId != oldSolutionArea.get(OppSA.Id).OwnerId)){
                            System.debug('in name it');
                            OppSA.addError('Cannot edit Solution Name/Owner');
                        } 
                    if(oldSolutionArea.get(OppSA.Id).Core_Status__c == 'EOL')
                    {
                     
                    cSA.Core_Solution_Long__c = cSA.Core_Application_Workload__c+';'+cSA.Core_Industry_Use_Case__c+';'+cSA.Core_Region_of_availability__c+';'+cSA.Core_Technology_Enabled__c+';'+cSA.Core_Industry__c+';'+cSA.Core_Solution_owner_email__c+';'+cSA.Core_End_Customer_Solution__c+';'+cSA.Core_Solution_Type__c+';'+cSA.Core_Content_Link__c;                        
                      cSA.Core_Most_Recent_Status_Change_Date__c = date.newinstance(dT.year(), dT.month(), dT.day());
                        update cSA;
                    }
                   
                    
            if(OppSA.Name != oldSolutionArea.get(OppSA.Id).Name  || OppSA.Core_Version__c != oldSolutionArea.get(OppSA.Id).Core_Version__c)
            {
                    Integer SolnCnt = [SELECT count() from Core_Solution_Areas__c where Core_Version__c = :OppSA.Core_Version__c and name= :OppSA.Name];
                    if ( SolnCnt > 0)
                    {
                           OppSA.addError(Label.Core_Solution_exist);
                    }
            }
                }
            }

          Test.StopTest();
     }
    
    static testMethod void addSolutionAreaTest(){
        
        Test.startTest();
        Id newOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_New_Opportunity' limit 1][0].Id;
        
        // Create an account
        Account acct = new Account(Name = 'TestAccount', BillingStreet = '123 Fake St',
                                   BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',Industry='Agriculture',Core_Sub_Industry__c= 'Crop Production',
                                   BillingPostalCode = '12345', Core_Business_Party_Id__c = '8675309',Core_Sales_Groups__c='Americas Brazil Sales Group');
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert acct;
        }
        
        Opportunity opps = new Opportunity(Name = 'Opportunity to Lose 03-24-2015', RecordTypeId = newOppRecTypeId,
                                           AccountId = acct.Id,
                                           StageName = 'Qualifying', CloseDate = System.Date.today().addYears(1));
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert opps;
        }
        
        List<Core_Solution_Areas__c> SAList= new List<Core_Solution_Areas__c>();
        Map<Id, Core_Solution_Areas__c> SAMap= new Map<Id, Core_Solution_Areas__c>();
        Core_Solution_Areas__c cSA = new Core_Solution_Areas__c();
        cSA.Name = 'Test1'+ (Math.random() * 10);
        cSA.Core_Version__c = 'Test1.0';
        cSA.Core_End_Customer_Solution__c = 'Yes';
        
      
            cSA.Core_Solution_Type__c = 'S1: Product';
           
            cSA.Core_Design_Visible__c = true;
         cSA.Core_Deal_Visible__c = true;
         
            cSA.Core_Status__c = 'Active';
            
            cSA.Core_Industry_Use_Case__c='Visual Cloud-CDN/vCDN';
           cSA.Core_Application_Workload__c='AI Training';
         cSA.Core_Technology_Enabled__c='AMT';
         cSA.Core_Solution_Description__c ='Desc...';
         
         cSA.Core_Solution_owner_email__c ='wwwwwasfdasdf@test.com';
         cSA.Core_Region_of_availability__c = 'PRC';
        
        
        insert cSA;
        SAMap.put(cSA.Id, cSA);
        
        System.runAs(Core_Test_Utility.systemAdminUser) {
            List<Core_Trigger_Executions__c> triggerExecList = new List<Core_Trigger_Executions__c>();
            triggerExecList.add(new Core_Trigger_Executions__c(Name='updateOpportunitySolutionArea', Core_Class_Name__c='updateOpportunitySolutionArea', Core_Object__c='OpportunitySolutionArea', Core_Trigger_Events__c='After Insert before Delete', Core_Active__c=true, Core_Description__c = 'blah blah'));
            insert triggerExecList;
            List<Opportunity_Solution_Area__c> oSAList= new List<Opportunity_Solution_Area__c>();
            Opportunity_Solution_Area__c oSA= new Opportunity_Solution_Area__c();
            oSA.Core_Opportunity__c = opps.id;
            oSA.Core_Solution_Areas__c =cSA.id;
            insert oSA;
            oSAList.add(oSA);
            
            update cSA;
            SAList.add(cSA);
            Core_Solution_Area_Controller.updateOpportunitySolutionArea(SAList, SAMap);
           
        }
         Test.stopTest();
    }
    
    
      public static testmethod void updateOpportunitySolutionArea()
      {
          List<Core_Trigger_Executions__c> triggerExecList = new List<Core_Trigger_Executions__c>();
          triggerExecList.add(new Core_Trigger_Executions__c(Name='addSolutionRelatedRecords', Core_Class_Name__c='addSolutionRelatedRecords', Core_Object__c='OpportunitySolutionArea', Core_Trigger_Events__c='After insert, After update', Core_Active__c=true, Core_Description__c = 'blah blah'));
          insert triggerExecList;
        System.debug('Inside OppoHandler updateOpportunitySolutionArea');
        Test.StartTest();
        List<Core_Solution_Areas__c> newSolutionArea = new List<Core_Solution_Areas__c>();            
        Map<Id, Core_Solution_Areas__c> oldSolutionArea = new Map<Id, Core_Solution_Areas__c>();
        Core_Solution_Areas__c cSA = new Core_Solution_Areas__c();
        cSA.Name = 'Test1zzzz';
        cSA.Core_Solution_Type__c = 'S1: Product';
        cSA.Core_End_Customer_Solution__c = 'Yes';
        cSA.Core_Design_Visible__c = true;
        cSA.Core_Status__c = 'Active';
        cSA.Core_Version__c ='1';
        cSA.Core_Industry_Use_Case__c='Visual Cloud-CDN/vCDN';
        cSA.Core_Design_Visible__c = false;
        cSA.Core_Region_of_availability__c = 'PRC';
        newSolutionArea.add(cSA);
        insert cSA;
        oldSolutionArea.put(cSA.Id, cSA); 
          
      /*  cSA.Core_Region_of_availability__c = 'APJ'; 
        cSA.Core_Industry__c= 'Automotive;Cloud Service Providers';
        cSA.Core_Technology_Enabled__c= 'AMT;CNDP';
        update cSA;*/
       
        Core_Solution_Areas__c cSA1 = new Core_Solution_Areas__c();
        cSA1.Name = 'Test1z';
        cSA1.Core_Solution_Type__c = 'S1: Product';
        cSA1.Core_End_Customer_Solution__c = 'Yes';
        cSA1.Core_Design_Visible__c = true;
        cSA1.Core_Status__c = 'Active';
        cSA1.Core_Version__c ='1.1';
        cSA1.Core_Industry_Use_Case__c='Visual Cloud-CDN/vCDN';
        cSA1.Core_Design_Visible__c = false;
        cSA1.Core_Region_of_availability__c = 'PRC;APJ';
        newSolutionArea.add(cSA1);
        insert cSA1;
        oldSolutionArea.put(cSA1.Id, cSA1);  
          
        cSA1.Core_Region_of_availability__c = 'APJ'; 
        update cSA1;
       
        List<String> oppId = new List<String>();
        Set<Id> saIds = new Set<Id>();
        List<Opportunity_Solution_Area__c> getOppSA= new List<Opportunity_Solution_Area__c>();
          
        // Create an account
        Account acct = new Account(Name = 'TestAccount', BillingStreet = '123 Fake St',
                                   BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',Industry='Agriculture',Core_Sub_Industry__c= 'Crop Production',
                                   BillingPostalCode = '12345', Core_Business_Party_Id__c = '8675309',Core_Sales_Groups__c='Americas Brazil Sales Group');
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert acct;
        }
         Id newOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_New_Opportunity' limit 1][0].Id;  
        Opportunity opps = new Opportunity(Name = 'Opportunity1 to Lose 09-24-2015', RecordTypeId = newOppRecTypeId,
                                           AccountId = acct.Id,
                                           StageName = 'Qualifying', CloseDate = System.Date.today().addYears(1));
      
         insert opps;
          
         Opportunity_Solution_Area__c OSA = new Opportunity_Solution_Area__c();          
         OSA.Core_Solution_Areas__c=cSA.Id;  
          /*
         OSA.Core_Technology_Enabled__c='AMT';
         OSA.Core_Region_of_availability__c= 'APJ'; 
         OSA.Core_Industry_Use_Case_s__c='Visual Cloud-CDN/vCDN1';         
         OSA.Core_Application_Workload__c ='AI Training';
*/
         OSA.Core_Opportunity__c = opps.id;
         getOppSA.add(OSA);        
         insert OSA;
         //Core_Solution_Area_Controller.updateOpportunitySolutionArea(newSolutionArea, oldSolutionArea);         

          
        OSA.Core_Technology_Enabled__c = cSA1.Core_Technology_Enabled__c;
        OSA.Core_Region_of_availability__c = cSA1.Core_Region_of_availability__c;
        OSA.Core_Industry_Use_Case_s__c = cSA1.Core_Industry_Use_Case__c;
        OSA.Core_Industry__c = cSA1.Core_Industry__c;
        OSA.Core_Application_Workload__c = cSA1.Core_Application_Workload__c;
        update OSA; 
      Core_Solution_Area_Controller.updateOpportunitySolutionArea(newSolutionArea, oldSolutionArea);
        Opportunity_Solution_Area__c OSAupdated = [Select Id, Core_Solution_Areas__c from Opportunity_Solution_Area__c where Core_Solution_Areas__c =:cSA.Id];
          System.debug('OSAupdated '+OSAupdated);
          
          cSA.Core_Region_of_availability__c = 'APJ'; 
        cSA.Core_Industry__c= 'Automotive;Cloud Service Providers';
        cSA.Core_Technology_Enabled__c= 'AMT;CNDP';
        update cSA;
          
        try{
              if(newSolutionArea.size()>0){
                for(Core_Solution_Areas__c OppSA: newSolutionArea){
                    if(OppSA.Core_Industry_Use_Case__c != oldSolutionArea.get(OppSA.Id).Core_Industry_Use_Case__c || 
                       OppSA.Core_Application_Workload__c != oldSolutionArea.get(OppSA.Id).Core_Application_Workload__c ||
                       OppSA.Core_Technology_Enabled__c != oldSolutionArea.get(OppSA.Id).Core_Technology_Enabled__c ||
                        OppSA.Core_Industry__c != oldSolutionArea.get(OppSA.Id).Core_Industry__c ||
                        OppSA.Core_Region_of_availability__c != oldSolutionArea.get(OppSA.Id).Core_Region_of_availability__c   )                 
                      {
                         saIds.add(OppSA.Id); 
                      }
                }
                
                if(saIds.size()>0){                      
                
                getOppSA = [Select Id, Core_Solution_Areas__c, Core_Technology_Enabled__c, Core_Region_of_availability__c ,Core_Industry_Use_Case_s__c, Core_Industry__c, Core_Application_Workload__c from Opportunity_Solution_Area__c where Core_Solution_Areas__c = :saIds]; 
                List<Core_Solution_Areas__c> SolnArea= new List<Core_Solution_Areas__c>();
                SolnArea = [Select Id, Core_Solution_Areas__c, tolabel( Core_Technology_Enabled__c), tolabel(Core_Region_of_availability__c) ,tolabel(Core_Industry_Use_Case__c),  tolabel(Core_Industry__c), tolabel( Core_Application_Workload__c) from Core_Solution_Areas__c where Id = :saIds]; 
                    // update Opportunity_Solution_Area__c                  
                          if(getOppSA.size()>0){
                   
                           for(Opportunity_Solution_Area__c oSolArea : getOppSA){
                                for(Core_Solution_Areas__c Sol : SolnArea){
                                    if (Sol.Id==oSolArea.Core_Solution_Areas__c)
                                    {
                                        oSolArea.Core_Technology_Enabled__c = Sol.Core_Technology_Enabled__c;
                                        oSolArea.Core_Region_of_availability__c = Sol.Core_Region_of_availability__c;
                                        oSolArea.Core_Industry_Use_Case_s__c = Sol.Core_Industry_Use_Case__c;
                                        oSolArea.Core_Industry__c = Sol.Core_Industry__c;
                                        oSolArea.Core_Application_Workload__c = Sol.Core_Application_Workload__c;
                                        update oSolArea;
                                        System.debug('Inside  updateOpportunitySolutionArea -- record updated');
                                    }
                                }
                          }
                        
                    }
                }   
            }
           
        }Catch(Exception ex){
            System.debug('Exception after updating OPTY Solns:::'+ex);
        }
          Test.StopTest();
    }
}