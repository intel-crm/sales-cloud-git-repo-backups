@isTest
public  class Core_CustomSetController_Test{

public static testMethod void testmethod1()
{
   List<String> cols=new List<String>();
   
   Core_CustomSetController customercont=new Core_CustomSetController('test',cols,true,true,'testdata');
   customercont.searchString='testdata';
   customercont.searchColumnName='testdata1';
   
    
    customercont.getSearchCondition();
   // customercont.getRecords();
   // customercont.getSelectedSobjectRecords();
    
    //Account acc=[select Name from Account] ;
   Account  sobj =TestUtilities.getAccount();
   insert sobj;
   
   Core_CustomSetController.Wrapper corecust=new Core_CustomSetController.Wrapper(sobj);
   Core_CustomSetController.Wrapper corecust1=new Core_CustomSetController.Wrapper(sobj,true);
   
   
//   List <Account> lstAccount = new List<Account>();
 
//  Account testAccount = new Account();
//  testAccount.Name='Test Account' ;
//  lstAccount.add(testAccount);
//  Account testAccount1 = new Account();
//  testAccount1.Name='Test Account1' ;
//  lstAccount.add(testAccount1);

//  insert  lstAccount;
 
//  List<Account> accList=new List<Account>();
//  accList=[SELECT Name,Id FROM Account];
 
 Test.startTest();
/*  Test.setCurrentPage(Page.Core_ExternalUser_IPS_Project);
  ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(lstAccount);
  stdSetController.setSelected(lstAccount);
  Core_CustomSetController ext = new Core_CustomSetController(stdSetController); */
  
 /* PageReference pageRef = Page.Core_ExternalUser_IPS_Project;
    pageRef.getParameters().put('Id',cocr.Opportunity__c);
    Test.setCurrentPageReference(pageRef);

    // load the extension
    opportunityContactEntryExtension oCEE = new OpportunityContactEntryExtension(new ApexPages.StandardSetController(cocr.Opportunity__c)); */
  
 /* List<Account> lstAccn = [select id,Name from Account limit 10];
ApexPages.StandardSetController con = new ApexPages.StandardSetController(Database.getQueryLocator( lstAccn ));
stdSetController.setSelected(lstAccn);
Core_ExternalUser_IPS_Project_Controller ext = new Core_ExternalUser_IPS_Project_Controller(con); */

  
 Test.stopTest();
}

}