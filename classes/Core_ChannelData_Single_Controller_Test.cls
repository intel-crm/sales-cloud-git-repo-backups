/***************************************************************************************************************************************************************************************************
* Apex Class Name:  Core_Salesout_Search_Controller_Test 
* Created Date: 11/16/15
* Modification Log:
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Brian Matthews            11/16/15         
*****************************************************************************************************************************************************************************************************/
@isTest
public class Core_ChannelData_Single_Controller_Test {
    /*static testMethod void channelDataSingleCoverageTest() { 

        User currentUser = [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];

        List<Account> acclist = Core_Test_Utility.Core_Account(2);
        for (Account acc : acclist)
            acc.Owner = currentUser;        
        insert accList;

        List<Core_Channel_Salesout__c> lstSalesout = Core_Test_Utility.Core_Channel_Salesout(20);
        for (Integer i=0; i < 10; i++)
            lstSalesout[i].Core_Account_Name__c = accList[0].Id;
            
        for (Integer i=10; i < lstSalesout.size(); i++)
            lstSalesout[i].Core_Account_Name__c = accList[1].Id;
            
        insert lstSalesout;

        List<Core_Channel_Membership__c> lstMembership = Core_Test_Utility.Core_Channel_Membership(20);
        for (Integer i=0; i < lstMembership.size(); i++)
            lstMembership[i].Core_Account_Name__c = accList[0].Id;
        insert lstMembership;
        
        List<Contact> conlist = Core_Test_Utility.createContacts(20);
        for(Integer i = 0; i <acclist.size(); i++)
            conlist[i].AccountId = acclist[0].id;        
        insert conlist;
                
        ApexPages.StandardController ctrlStandard = new ApexPages.StandardController(accList[0]);


        // START Test
        test.StartTest();

        Core_ChannelData_Single_Controller ctrlChannelData;
        ctrlChannelData = new Core_ChannelData_Single_Controller(ctrlStandard);

        ApexPages.currentPage().getParameters().put('Id', accList[0].Id);
        ctrlChannelData = new Core_ChannelData_Single_Controller(ctrlStandard);

        ctrlChannelData.DisplaySummary();
        ctrlChannelData.exportSummary();
        
        ctrlChannelData.DisplayDetail();
        
        ctrlChannelData.returnToAccount();
        ctrlChannelData.exportCSV();

        // STOP Test
        test.stopTest();
    
    }*/
    
     static testMethod void testEmptyClass() {
        Test.startTest();
        Core_ChannelData_Single_Controller utility = new Core_ChannelData_Single_Controller();
		Core_Role_Hierarchy_Accessor utility1 = new Core_Role_Hierarchy_Accessor();
		FetchAssetContent utility2 = new FetchAssetContent();
        Test.stopTest();
    }
}