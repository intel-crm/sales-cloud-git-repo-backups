/**************************************************************************************
Apex Class Name:  Core_MDF_BudgetTransfer_Test 
Version     : 1.0 
Created Date: 02 08 2018
Function    : Test class for the Core_MDF_BudgetTransfer used for Budget Transfer.
Author      : Sarah Manuel
Modification Log :
* Change#           Author                   Date                   Description
* ----------------------------------------------------------------------------                 
* Core MDF Rel1   Sarah Manuel         02/08/2018              Original Version
*
*************************************************************************************/
@isTest(SeeAllData=false) 
public class Core_MDF_Budget_Utility_Test {
    
    
    @isTest static void validateTransferAllocationAmountForPendingReviewBudget(){
        List<Account> toBeUpdated = new List<Account>();
        
        // Creating channel program with utility class
        ChannelProgram cp1 = Core_MDF_CCP_TestDataUtility.createProgram ('Client Co-Marketing Fund','Client CoMarketing Fund', true);
        ChannelProgram cp2 = Core_MDF_CCP_TestDataUtility.createProgram ('Data Center Co-Marketing Fund','Data Center CoMarketing Fund', true);
        
        // Creating Account with utility class
        Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Account 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
        
        Account acc2 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account 2', cp1.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc1.Id, true);
        
        Account acc3 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account 3', cp1.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc2.Id, true);
        
        // Updating Accounts 
        acc1.isPartner = true;
        acc2.isPartner = true;
        acc3.isPartner = true;
        toBeUpdated.add(acc1);
        toBeUpdated.add(acc2);
        toBeUpdated.add(acc3);
        Database.update(toBeUpdated);
        test.startTest();
        PartnerMarketingBudget pbm1 = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget 1', Core_MDF_CCP_TestDataUtility.Budget_Record_Type, acc2.Id, cp1.Id, 3000, System.today().addDays(-50),System.today().addDays(-40), true);
        
        pbm1.Core_MDF_Budget_Status__c = 'Approved';
        update pbm1;
        
        pbm1.Core_MDF_Budget_Status__c = 'Released';
        update pbm1;
        
        Profile systemAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator' limit 1];
        
        // Creating User with utility class 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.profileId = systemAdminProfile.Id;
        Database.insert(usr);
        
        System.runAs(usr){
            
            
            List<PartnerMarketingBudget> pmbLst1 = new List<PartnerMarketingBudget>();
            pmbLst1.add(pbm1);
            Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
            req.setComments('Approving request.');
            req.setAction('Approve');
            req.setNextApproverIds(new Id[] {UserInfo.getUserId()});
            //Getting Work Item Id
            ProcessInstanceWorkitem pItem = [Select Id from ProcessInstanceWorkitem 
                                             where ProcessInstance.TargetObjectId =: pbm1.id];
            req.setWorkitemId(pItem.Id);
            Approval.ProcessResult result = Approval.process(req);
            
            
            string response1 = Core_MDF_BudgetTransfer.TransferAllocationAmount((string)acc2.Id, (string)acc3.Id, (string)pbm1.Id, 500.00,Label.Core_MDF_Budget_Transfer_Type_Manual);
            System.assertEquals('Success', response1);
            
            pbm1.Core_MDF_Decrease_Budget_Amount_Amt__c = 1000;
            update pbm1;
            
            List<PartnerMarketingBudget> pmbLst = new List<PartnerMarketingBudget>();
            PartnerMarketingBudget pmb = new PartnerMarketingBudget();
            pmbLst.add(pbm1);
            try{
                Core_MDF_Budget_Utility.unlockBudget(pmbLst);
                pmbLst.add(pmb);
                Core_MDF_Budget_Utility.unlockBudget(pmbLst);  
            }
            catch(Exception e){
                System.debug(e);
            }
            test.stopTest();
        }
    }
}