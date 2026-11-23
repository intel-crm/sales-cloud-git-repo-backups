/**************************************************************************************
Apex Class Name:  Core_MDF_BudgetTransferHandler_EXT_Test 
Version     : 1.0 
Created Date: 17 08 2018
Function    : Test class for the Core_MDF_BudgetTransferHandler_EXT used for Budget Transfer.
Author      : Sarah Manuel
Modification Log :
* Change#           Author                   Date                   Description
* ----------------------------------------------------------------------------                 
* Core MDF Rel1   Sarah Manuel         17/08/2018              Original Version
*
*************************************************************************************/
@isTest(SeeAllData=false) 
public class Core_MDF_BudgetTransferHandler_EXT_Test {
    
    // test method to validate TransferAllocationAmount
    @isTest static void validateTransferAllocationAmount(){
        
        // Creating channel program with utility class
        ChannelProgram cp1 = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.CCF_PROGRAM,'Client CoMarketing Fund', true);
        ChannelProgram cp2 = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.DCF_PROGRAM,'Data Center CoMarketing Fund', true);
        
        // Creating Account with utility class
        Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Account 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
        
        Account acc2 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account 2', cp1.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc1.Id, true);
        
        Account acc3 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account 3', cp1.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc2.Id, true);
        
        acc1.isPartner = true;
        acc2.isPartner = true;
        acc3.isPartner = true;
        
        List<Account> accList = new List<Account>();
        accList.add(acc1);
        accList.add(acc2);
        accList.add(acc3);
        Database.update(accList);
        
        //adding bypass feature to bypass access validation
			List<String> bypassFunctionKeys = new List<String>();
            bypassFunctionKeys.add('Bypass_MDF_Budget_Access_Validation');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Status_Validation');
            
            Set<String> myset1 = new Set<String>();
            List<String> result1 = new List<String>();
            myset1.addAll(bypassFunctionKeys);
            result1.addAll(myset1);
            
            List<Core_Trigger_Executions__c> bypassfunctinalitylist1 = Core_MDF_CCP_TestDataUtility.byPassFeature(result1,true,true);
        
        PartnerMarketingBudget pbm1 = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget 1', Core_MDF_CCP_TestDataUtility.Budget_Record_Type, acc2.Id, cp1.Id, 3000, Date.newInstance(2019,01,01), Date.newInstance(2019,12,31), false);
        pbm1.Core_MDF_Budget_Type_Txt__c='OEM CMP';
        insert pbm1;
        Profile systemAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator' limit 1];
        
        // Creating User with utility class 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.profileId = systemAdminProfile.Id;
        Database.insert(usr);
        
        
        System.runAs(usr){
            
            
            //pbm1.Core_MDF_Budget_Status__c = 'Approved';
            //Database.update(pbm1);
            
            pbm1.Core_MDF_Budget_Status__c = 'Released';
            Database.update(pbm1);
            
            Test.startTest();
            string response1 = Core_MDF_BudgetTransferHandler_EXT.TransferAllocationAmount((string)acc2.Id, (string)acc3.Id, (string)pbm1.Id, 500.00, Label.Core_MDF_Budget_Transfer_Type_Manual);
            Test.stopTest();
            System.assertEquals('Success', response1);
        }
    }
    @isTest static void validateTransferAllocationAmountForPendingReviewBudget(){
        //adding bypass feature to bypass access validation
			List<String> bypassFunctionKeys = new List<String>();
            bypassFunctionKeys.add('Bypass_MDF_Budget_Access_Validation');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Status_Validation');
            
            Set<String> myset1 = new Set<String>();
            List<String> result1 = new List<String>();
            myset1.addAll(bypassFunctionKeys);
            result1.addAll(myset1);
            
            List<Core_Trigger_Executions__c> bypassfunctinalitylist1 = Core_MDF_CCP_TestDataUtility.byPassFeature(result1,true,true);
        
       // Creating channel program with utility class
        ChannelProgram cp1 = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.CCF_PROGRAM,'Client CoMarketing Fund', true);
        ChannelProgram cp2 = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.DCF_PROGRAM,'Data Center CoMarketing Fund', true);
        
        // Creating Account with utility class
        Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Account 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
        
        Account acc2 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account 2', cp1.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc1.Id, true);
        
        Account acc3 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account 3', cp1.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc2.Id, true);
        
        acc1.isPartner = true;
        acc2.isPartner = true;
        acc3.isPartner = true;
        
        List<Account> accList = new List<Account>();
        accList.add(acc1);
        accList.add(acc2);
        accList.add(acc3);
        Database.update(accList);
        
        
        PartnerMarketingBudget pbm1 = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget 1', Core_MDF_CCP_TestDataUtility.Budget_Record_Type, acc2.Id, cp1.Id, 3000, Date.newInstance(2019,01,01), Date.newInstance(2019,12,31), false);
        pbm1.Core_MDF_Budget_Type_Txt__c='OEM CMP';
        insert pbm1;
        Profile systemAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator' limit 1];
        
        // Creating User with utility class 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.profileId = systemAdminProfile.Id;
        Database.insert(usr);
        
        System.runAs(usr){
            PartnerFundAllocation pfaRecord = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test PFA', pbm1, acc2, 1000, true);
            PartnerFundAllocation pfaRecord2 = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test PFA', pbm1, acc3, 300, true);
            Test.startTest();
            string response1 = Core_MDF_BudgetTransferHandler_EXT.TransferAllocationAmount((string)acc2.Id, (string)acc3.Id, (string)pbm1.Id, 500.00, Label.Core_MDF_Budget_Transfer_Type_Manual);
            List<PartnerFundAllocation> pfaList = new List<PartnerFundAllocation>();
            pfaList.add(pfaRecord);
            pfaList.add(pfaRecord2);
            Core_MDF_PFA_ServiceHandler.invokeAllocationShareRecordToGeoGroup(pfaList);
            Core_MDF_PFA_ServiceHandler.checkUpdatedAllocations(null,null);
            Test.stopTest();
            System.assertEquals('Success', response1);
        }
    }
}