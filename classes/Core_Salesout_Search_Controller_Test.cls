/***************************************************************************************************************************************************************************************************
Apex Class Name:  Core_Salesout_Search_Controller_Test 
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
public class Core_Salesout_Search_Controller_Test {
    static testMethod void salesoutSearchCoverageTest() { 

       User currentUser = [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];

        List<Account> acclist = Core_Test_Utility.Core_Account(20);
        for (Account acc : acclist)
            acc.Owner = currentUser;        
        insert accList;

        List<Core_Channel_Salesout__c> lstSalesout = Core_Test_Utility.Core_Channel_Salesout(20);
        for (Integer i=0; i < lstSalesout.size(); i++)
            lstSalesout[i].Core_Account_Name__c = accList[i].Id;
        insert lstSalesout;

        List<Core_Channel_Membership__c> lstMembership = Core_Test_Utility.Core_Channel_Membership(20);
        for (Integer i=0; i < lstMembership.size(); i++)
            lstMembership[i].Core_Account_Name__c = accList[i].Id;
        insert lstMembership;
        
        List<Contact> conlist = Core_Test_Utility.createContacts(20);
        for(Integer i = 0; i <acclist.size(); i++)
            conlist[i].AccountId = acclist[i].id;        
        insert conlist;
        
        List<Campaign> camplist = Core_Test_Utility.createCampaign(1);
        insert camplist;
        
        campaignMember cm = new campaignMember(campaignId=camplist[0].Id, contactId=conlist[0].Id );
        insert cm;
        
        ApexPages.StandardController ctrlStandard  = new ApexPages.StandardController(cm);
        Core_Salesout_Search_Controller ctrlSalesout = new Core_Salesout_Search_Controller(ctrlStandard);

        // START Test
        test.StartTest();

        ctrlSalesout.iNoOfPages   = 100;
        ctrlSalesout.iPageNumber  = 1;
        ctrlSalesout.bMoreRecords = true;
        ctrlSalesout.sColumnSize  = '100%';

        // This first call throws exceptions in QueryByPageAndOffset
        List<SelectOption> lstDefaultField1             = ctrlSalesout.lstDefaultField1;
        ctrlSalesout.lstDefaultField1                   = lstDefaultField1;
        
        List<SelectOption> lstComparisonOperators       = ctrlSalesout.lstComparisonOperators;
        ctrlSalesout.lstComparisonOperators             = lstComparisonOperators;

        List<SelectOption> lstDateOperators             = ctrlSalesout.lstDateOperators;
        ctrlSalesout.lstDateOperators                   = lstDateOperators; 

        List<SelectOption> lstSalesOutFields            = ctrlSalesout.lstSalesOutFields;
        ctrlSalesout.lstSalesOutFields                  = lstSalesOutFields;
        
        List<SelectOption> lstProgramMembershipFields   = ctrlSalesout.lstProgramMembershipFields;
        ctrlSalesout.lstProgramMembershipFields         = lstProgramMembershipFields;
        
        List<SelectOption> lstAccountFields             = ctrlSalesout.lstAccountFields;
        ctrlSalesout.lstAccountFields                   = lstAccountFields;

        String strlabel = ctrlSalesout.getLabelFromValue(lstAccountFields, '');        
        System.AssertEquals(strLabel, Core_Salesout_Search_Controller.NONE_SELECTED);
        
        strlabel        = ctrlSalesout.getLabelFromValue(lstAccountFields, 'BAD VALUE');        
        System.AssertEquals(strLabel, '');
        
        Boolean isMulti = ctrlSalesout.isMultiPicklist('Core_Account_Name__r.Core_Sales_Segment__c');
        System.AssertEquals(isMulti, true);
        
        isMulti = ctrlSalesout.isMultiPicklist('Core_Account_Name__r.Core_Account_Type__c');
        System.AssertEquals(isMulti, true);
        
        isMulti = ctrlSalesout.isMultiPicklist('Name');
        System.AssertEquals(isMulti, false);
        
                
        ctrlSalesout.acField1 = 'Core_Account_Name__r.Name';
        ctrlSalesout.acField2 = 'Core_Account_Name__r.Core_Covered_Account__c';
        ctrlSalesout.acField3 = 'Core_Account_Name__r.Core_Account_Type__c';
        ctrlSalesout.search();

        ctrlSalesout.acOp1 = 'e';
        ctrlSalesout.acOp2 = 'n';
        ctrlSalesout.acOp3 = 's';
        ctrlSalesout.search();

        ctrlSalesout.acValue1 = 'DELL';
        ctrlSalesout.acValue2 = 'true';
        ctrlSalesout.acValue3 = 'other';
        ctrlSalesout.search();

        ctrlSalesout.acOp3 = 'k';
        ctrlSalesout.search();

        ctrlSalesout.acValue2 = 'BAD BOOLEAN';
        ctrlSalesout.search();


        ctrlSalesout.acOp1 = 'c';
        ctrlSalesout.acOp2 = 'k';
        ctrlSalesout.acOp3 = 'l';

        ctrlSalesout.acValue2 = 'false';


        // Use default for soField1
        ctrlSalesout.soField2 = 'Core_Product_Level_3__c';
        ctrlSalesout.soField3 = 'Core_Business_Geo__c';
        ctrlSalesout.search();


        ctrlSalesout.soOp2 = 'n';
        ctrlSalesout.soOp3 = 'l';
        ctrlSalesout.search();


        ctrlSalesout.acOp1 = 'g';
        ctrlSalesout.acOp2 = 'm';
        ctrlSalesout.acOp3 = 'h';

        ctrlSalesout.soValue2 = 'Intel I5';
        ctrlSalesout.soValue3 = 'ASMO-NA';
        ctrlSalesout.search();

        ctrlSalesout.soOp1 = 'n';
        ctrlSalesout.search();

        ctrlSalesout.soOp1 = 'l';
        ctrlSalesout.search();

        ctrlSalesout.soOp1 = 'g';
        ctrlSalesout.search();

        ctrlSalesout.soOp1 = '*';
        ctrlSalesout.search();

        String soWhereClause = ctrlSalesout.getSalesoutWhereClause();

        ctrlSalesout.acOp3 = 'e';  // Need to have valid operator for multi-select list.

        ctrlSalesout.pmField1 = Core_Salesout_Search_Controller.ITP_MEMBERSHIP_TIER_FIELD;
        ctrlSalesout.pmField2 = Core_Salesout_Search_Controller.TRAINING_CREDITS_FIELD;
        ctrlSalesout.pmField3 = Core_Salesout_Search_Controller.TOTAL_EARNED_POINTS_FIELD;
        ctrlSalesout.search();

        ctrlSalesout.pmOp1 = 'e';
        ctrlSalesout.pmOp2 = 'n';
        ctrlSalesout.pmOp3 = 's';
        ctrlSalesout.search();

        ctrlSalesout.pmValue1 = 'PLATINUM';
        ctrlSalesout.pmValue2 = '1';
        ctrlSalesout.pmValue3 = '1';
        ctrlSalesout.search();


        ctrlSalesout.pmField1 = Core_Salesout_Search_Controller.TRAINING_CREDITS_FIELD;
        ctrlSalesout.pmField2 = Core_Salesout_Search_Controller.TOTAL_EARNED_POINTS_FIELD;
        ctrlSalesout.pmField3 = Core_Salesout_Search_Controller.ITP_MEMBERSHIP_TIER_FIELD;

        ctrlSalesout.pmOp1 = 'n';
        ctrlSalesout.pmOp2 = 's';
        ctrlSalesout.pmOp3 = 'e';

        ctrlSalesout.pmValue1 = '1';
        ctrlSalesout.pmValue2 = '1';
        ctrlSalesout.pmValue3 = 'PLATINUM';
        ctrlSalesout.search();


        ctrlSalesout.pmField1 = Core_Salesout_Search_Controller.TOTAL_EARNED_POINTS_FIELD;
        ctrlSalesout.pmField2 = Core_Salesout_Search_Controller.ITP_MEMBERSHIP_TIER_FIELD;
        ctrlSalesout.pmField3 = Core_Salesout_Search_Controller.TRAINING_CREDITS_FIELD;

        ctrlSalesout.pmOp1 = 's';
        ctrlSalesout.pmOp2 = 'e';
        ctrlSalesout.pmOp3 = 'n';

        ctrlSalesout.pmValue1 = '1';
        ctrlSalesout.pmValue2 = 'PLATINUM';
        ctrlSalesout.pmValue3 = '1';
        ctrlSalesout.search();


        ctrlSalesout.acField1 = '';
        ctrlSalesout.acField2 = '';
        ctrlSalesout.acField3 = '';

        ctrlSalesout.acOp1 = '';
        ctrlSalesout.acOp2 = '';
        ctrlSalesout.acOp3 = '';
        ctrlSalesout.search();

        ctrlSalesout.acValue1 = '';
        ctrlSalesout.acValue2 = '';
        ctrlSalesout.acValue3 = '';
        ctrlSalesout.search();

        // Use default for soField1
        ctrlSalesout.soField2 = '';
        ctrlSalesout.soField3 = '';
        ctrlSalesout.search();

        ctrlSalesout.soOp2 = '';
        ctrlSalesout.soOp3 = '';
        ctrlSalesout.search();

        ctrlSalesout.pmField1 = Core_Salesout_Search_Controller.ITP_MEMBERSHIP_TIER_FIELD;
        ctrlSalesout.pmField2 = Core_Salesout_Search_Controller.TOTAL_EARNED_POINTS_FIELD;
        ctrlSalesout.pmField3 = '';

        ctrlSalesout.pmOp1 = 'e';
        ctrlSalesout.pmOp2 = 'e';
        ctrlSalesout.pmOp3 = '';

        ctrlSalesout.pmValue1 = 'PLATINUM';
        ctrlSalesout.pmValue2 = '1';
        ctrlSalesout.pmValue3 = '';
        ctrlSalesout.search();

        ctrlSalesout.acField1 = 'Core_Account_Name__r.Name';
        ctrlSalesout.acField2 = 'Core_Account_Name__r.Core_Covered_Account__c';
        ctrlSalesout.acField3 = 'Core_Account_Name__r.Core_Account_Type__c';

        String strWhereClause;
        strWhereClause = ctrlSalesout.addCriteria('', '', '', strWhereClause);
        strWhereClause = ctrlSalesout.addCriteria('Core_Account_Name__r.Name', 's', 'DELL', strWhereClause);
        strWhereClause = ctrlSalesout.addCriteria('Core_Account_Name__r.Name', 'c', 'DELL', strWhereClause);
        strWhereClause = ctrlSalesout.addCriteria('Core_Account_Name__r.Core_Account_Type__c', 'c', 'DELL', strWhereClause);
        strWhereClause = ctrlSalesout.addCriteria('Core_Account_Name__r.Name', 'k', 'DELL', strWhereClause);
        strWhereClause = ctrlSalesout.addCriteria('Core_Account_Name__r.Name', 'm', 'DELL', strWhereClause);
        strWhereClause = ctrlSalesout.addCriteria('Core_Account_Name__r.Name', 'h', 'DELL', strWhereClause);

        // Don't know why the lstAccount Fields is needed, but it's included in the call
        strWhereClause = ctrlSalesout.addNumericCriteria('', '', '', strWhereClause, lstAccountFields);
        strWhereClause = ctrlSalesout.addNumericCriteria('Core_Salesout_Search_Controller.TRAINING_CREDITS_FIELD', 'e', 'true', '', lstAccountFields);
        strWhereClause = ctrlSalesout.addNumericCriteria('Core_Salesout_Search_Controller.TRAINING_CREDITS_FIELD', 'e', '1', '', lstAccountFields);
        strWhereClause = ctrlSalesout.addNumericCriteria('Core_Salesout_Search_Controller.TRAINING_CREDITS_FIELD', 's', '1', '', lstAccountFields);
        strWhereClause = ctrlSalesout.addNumericCriteria('Core_Salesout_Search_Controller.TRAINING_CREDITS_FIELD', 'l', '1', '', lstAccountFields);
        strWhereClause = ctrlSalesout.addNumericCriteria('Core_Salesout_Search_Controller.TRAINING_CREDITS_FIELD', 'g', '1', '', lstAccountFields);
        strWhereClause = ctrlSalesout.addNumericCriteria('Core_Salesout_Search_Controller.TRAINING_CREDITS_FIELD', 'm', '1', '', lstAccountFields);
        strWhereClause = ctrlSalesout.addNumericCriteria('Core_Salesout_Search_Controller.TRAINING_CREDITS_FIELD', 'h', '1', '', lstAccountFields);
        strWhereClause = ctrlSalesout.addNumericCriteria('Core_Salesout_Search_Controller.TRAINING_CREDITS_FIELD', '*', '1', '', lstAccountFields);

        ctrlSalesout.clearFilters();

        // STOP Test
        test.stopTest();
    
    }
}