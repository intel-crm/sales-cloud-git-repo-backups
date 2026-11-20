/***************************************************************************************************************************************************************************************************
Apex Class Name:  Core_Campaign_Member_Creator_Test 
Version     : 1.0 
Created Date: 04 SEP 2015
Function    : 
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Kalpana Choudhary         09/04/15    
* Brian Matthews            11/16/15         
*****************************************************************************************************************************************************************************************************/
@isTest
public class Core_Campaign_Member_Creator_Test {
    static testMethod void campaignMemberCreationTest() { 

        User currentUser = [SELECT Id, Name, FirstName, LastName FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];

        List<Account> acclist = Core_Test_Utility.Core_Account(2);
        for (Account acc : acclist)
            acc.Owner = currentUser;
        
        insert accList;

        // Loading STATIC variable on Class
        for (Account acc : acclist)
            Core_Campaign_Member_Creator.setTargetId.add(acc.Id);

        // Loading STATIC variable on Class
        Core_Campaign_Member_Creator.soStaticWhereClause = '';
                
        List<Core_Channel_Salesout__c> lstSalesout = Core_Test_Utility.Core_Channel_Salesout(20);
        for (Integer i=0; i < 10; i++)
            lstSalesout[i].Core_Account_Name__c = accList[0].Id;
            
        for (Integer i=10; i < lstSalesout.size(); i++)
            lstSalesout[i].Core_Account_Name__c = accList[1].Id;
            
        insert lstSalesout;
        
        List<Contact> conlist = Core_Test_Utility.createContacts(20);
        for(Integer i = 0; i <acclist.size(); i++)
            conlist[i].AccountId = acclist[0].id;        
        insert conlist;
        
        List<Campaign> camplist = Core_Test_Utility.createCampaign(1);
        insert camplist;
        
        campaignMember cm = new campaignMember(campaignId=camplist[0].Id, contactId=conlist[0].Id );
        insert cm;
        
        ApexPages.CurrentPage().getParameters().put('Id',cm.id);
        ApexPages.StandardController ld  = new ApexPages.StandardController(cm);
        Core_Campaign_Member_Creator memberCreator = new Core_Campaign_Member_Creator (ld);

        // START Test
        test.StartTest();

        // This first call throws exceptions in QueryByPageAndOffset
        memberCreator.initialLoadTargetAccounts();
        
        memberCreator.sortHeader.sortExpression = 'Name';
        memberCreator.sortHeader.sortDirection  = Core_SortedGrid_ColumnHeader.ASCENDING_TEXT;
        memberCreator.initialLoadTargetAccounts();

        memberCreator.sortHeader.sortExpression = 'components';
        memberCreator.AccountOnlySearch(false);

        memberCreator.sortHeader.sortExpression = 'membershipTier';
        memberCreator.simplesort();

        memberCreator.sortHeader.sortExpression = 'components';
        memberCreator.sortPersistentTargetId();

        memberCreator.sortHeader.sortExpression = 'componentsUnitCosts';
        memberCreator.sortPersistentTargetId();

        // Hit the empty campaign case.
        memberCreator.campaignMember1();

        // Hit the bad campaign ID
        memberCreator.uCampaignId.campaignId = cm.Id;
        memberCreator.campaignMember1();

        memberCreator.uCampaignId.campaignId = camplist[0].Id;
        memberCreator.campaignMember1();

        memberCreator.loadTargetList();
        
        memberCreator.selectedAccountId = acclist[0].Id;
        memberCreator.channelSalesData();

        memberCreator.lstTargetAccountDisplay = new List<Core_Test_Utility.TargetAccountRecord>();
        for (Integer idx=0; idx < acclist.size(); idx++) 
            memberCreator.lstTargetAccountDisplay.add(new Core_Test_Utility.TargetAccountRecord(acclist[idx], memberCreator.sortHeader.sortExpression, memberCreator.sortHeader.sortDirection));
        memberCreator.lstTargetAccountDisplay[0].isSelected = true;            
        memberCreator.deleteRecord();

        memberCreator.returnToSearchPage();
        memberCreator.returntoSearchResults();
        memberCreator.exportCSV();
        memberCreator.exportTargetList();
        memberCreator.next();
        memberCreator.previous();
        memberCreator.first();
        memberCreator.last();
        
        memberCreator.displaySummary();
        memberCreator.displayDetail();
        
        //memberCreator.exportToReports();

        // STOP Test
        test.stopTest();
    
    }
}