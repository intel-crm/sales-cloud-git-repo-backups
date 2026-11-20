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
        
        // Pass the case id to page        
        PageReference pageRef = Page.CommunityCaseClosure;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', caseObj.Id);
        CommunityCaseClosureController commObj = new CommunityCaseClosureController(new ApexPages.StandardController(caseObj));
        Test.startTest();
        //commObj.setClosureComments('foo');
        //String c = commObj.getClosureComments();
        //commObj.setnewcase(caseObj);
        //Case c = commObj.getnewcase();
        commObj.RequestCaseClosure(); 
        Test.stopTest();        
    }
}