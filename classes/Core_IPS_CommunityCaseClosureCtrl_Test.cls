@isTest
public class Core_IPS_CommunityCaseClosureCtrl_Test{
        
    /***************************************************************************************************
    Method Name:  getRecords
    Method Type: Void Method
    Version     : 1.0 
    Created Date: Jan 04 2015
    Description:  Common Test data used in multiple test methods
    Scenario Type:  
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Abhishek Arya            11/04/2015                Created
    ****************************************************************************************************/
    static TestMethod void Test_RequestCaseClosure_Positive(){
        
        // Prep data
        
        Case caseObj = TestUtilities.getCase();
        insert caseObj;
        System.assert(caseObj.Id != null, 'Record not created');

        //Added by Sowmya - Start - 18/10/2024 - TWC745-6800 - Fix test coverage for all failed classes 
        List<Core_IPS_Labels__c> ipsLabels = new List<Core_IPS_Labels__c>();
        Core_IPS_Labels__c ipsLabel = new Core_IPS_Labels__c(Name='PUBLIC_TO_CUSTOMERS',Value__c='Public to Customers');
        Core_IPS_Labels__c ipsLabel1 = new Core_IPS_Labels__c(Name='PRIVATE_TO_PARTNERS',Value__c='Private to Partner');
        Core_IPS_Labels__c ipsLabel2 = new Core_IPS_Labels__c(Name='PRIVATE_TO_INTEL',Value__c='Private to Intel');
        Core_IPS_Labels__c ipsLabel3 = new Core_IPS_Labels__c(Name='Agent',Value__c='Agent');
        Core_IPS_Labels__c ipsLabel4 = new Core_IPS_Labels__c(Name='FAE',Value__c='FAE');
        Core_IPS_Labels__c ipsLabel5 = new Core_IPS_Labels__c(Name='Data Migration',Value__c='Data Migration');
        Core_IPS_Labels__c ipsLabel6 = new Core_IPS_Labels__c(Name='Backend Integration',Value__c='Backend Integration');
        Core_IPS_Labels__c ipsLabel7 = new Core_IPS_Labels__c(Name='Partner - Agent',Value__c='Partner - Agent');
        Core_IPS_Labels__c ipsLabel8 = new Core_IPS_Labels__c(Name='Customer',Value__c='Customer');
        Core_IPS_Labels__c ipsLabel9 = new Core_IPS_Labels__c(Name='Partner',Value__c='Partner');
        Core_IPS_Labels__c ipsLabel10 = new Core_IPS_Labels__c(Name='Case_RT_Name_IPS_NoAssignedContact',Value__c='IPS No Assigned Contact Case');
        Core_IPS_Labels__c ipsLabel11 = new Core_IPS_Labels__c(Name='Comment Source - Email',Value__c='Email');
        Core_IPS_Labels__c ipsLabel12 = new Core_IPS_Labels__c(Name='Comment Source - Backend System',Value__c='Backend System');
        Core_IPS_Labels__c ipsLabel13 = new Core_IPS_Labels__c(Name='Comment Source - Data Migration',Value__c='Data Migration');
		Core_IPS_Labels__c ipsLabel14 = new Core_IPS_Labels__c(Name='Comment Source - Internal',Value__c='Internal Portal');
        Core_IPS_Labels__c ipsLabel15 = new Core_IPS_Labels__c(Name='Comment Source - Customer',Value__c='Customer Portal');
        Core_IPS_Labels__c ipsLabel16 = new Core_IPS_Labels__c(Name='Comment Source - N/A',Value__c='N/A');
        Core_IPS_Labels__c ipsLabel17 = new Core_IPS_Labels__c(Name='Partner - DFAE',Value__c='Partner - DFAE');
        
        ipsLabels.add(ipsLabel);
        ipsLabels.add(ipsLabel1);
        ipsLabels.add(ipsLabel2);
        ipsLabels.add(ipsLabel3);
        ipsLabels.add(ipsLabel4);
        ipsLabels.add(ipsLabel5);
        ipsLabels.add(ipsLabel6);
        ipsLabels.add(ipsLabel7);
        ipsLabels.add(ipsLabel8);
        ipsLabels.add(ipsLabel9);
        ipsLabels.add(ipsLabel10);
        ipsLabels.add(ipsLabel11);
        ipsLabels.add(ipsLabel12);
        ipsLabels.add(ipsLabel13);
        ipsLabels.add(ipsLabel14);
        ipsLabels.add(ipsLabel15);
        ipsLabels.add(ipsLabel16);
        ipsLabels.add(ipsLabel17);
        Insert ipsLabels;
        System.assert(ipsLabels[0].Id != null, 'Record not created');

        
    //Sowmya - end - 18/10/2024 - TWC745-6800 - Fix test coverage for all failed classes 
  
        // Pass the case id to page        
        PageReference pageRef = Page.CommunityCaseClosure;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', caseObj.Id);
        system.debug('caseObj'+caseObj);
        CommunityCaseClosureController commObj = new CommunityCaseClosureController(new ApexPages.StandardController(caseObj));
        Test.startTest();
        //commObj.setClosureComments('foo');
        //String c = commObj.getClosureComments();
        //commObj.setnewcase(caseObj);
        //Case c = commObj.getnewcase();
        commObj.RequestCaseClosure(); 
        //Added by Sowmya - Start - 18/10/2024 - TWC745-6800 - Fix test coverage for all failed classes 
        commObj.CancelOperation();
        // Sowmya - end - 18/10/2024 - TWC745-6800 - Fix test coverage for all failed classes 
		Test.stopTest();        
    }
    
  
}