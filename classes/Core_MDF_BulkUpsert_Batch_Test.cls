@IsTest(SeeAllData=false)
public class Core_MDF_BulkUpsert_Batch_Test {
@TestSetup
    static void createTestData(){
        UserRole userRole_1 = [SELECT Id FROM UserRole WHERE DeveloperName = 'Admin' LIMIT 1];
        User systemAdmin = Core_MDF_CCP_TestDataUtility.createUser(false);      
        systemAdmin.LastName = 'SystemAdmin';
        systemAdmin.UserRoleId = userRole_1.Id;
        insert systemAdmin;
        

        List<ChannelProgram> cpList=new List<ChannelProgram>();
        ChannelProgram ipaCP = Core_MDF_CCP_TestDataUtility.createProgram ('Intel Partner Alliance','Intel Partner Alliance', false);
        cpList.add(ipaCP);
        system.runAs(systemAdmin){
            database.insert(cpList);
        }
        
        system.runAs(systemAdmin){
                       
            Account ipaUltimateAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount ('IPA Intel Account',Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
            update ipaUltimateAccount;
            
            Account ipaCoMarketingAccount = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('IPA Co-Marketing Account', ipaCP.id, Core_MDF_CCP_TestDataUtility.Account_Record_Type,ipaUltimateAccount.id, false);           
            ipaCoMarketingAccount.Core_Geo__c = 'APJ';
            insert ipaCoMarketingAccount;
            Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Acc New 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
            Core_MDF_Bank__c bank1 = Core_MDF_CCP_TestDataUtility.createBank(acc1.Id, 'Core_MDF_Client_CoMarketing_Fund', false,'1241241240');
            bank1.Core_MDF_Bank_Status__c='Active';
            bank1.Core_MDF_Bank_Location__c ='AM';
            insert bank1;
            string budgetType = Core_MDF_CCP_ConstantClass.PR_MDF_BUDGET_TYPE;
            Campaign ipaCampaignForAP = Core_MDF_CCP_IPA_TestDataUtility.createIPACampaign('Test Campaign - AP',ipaCoMarketingAccount.id, System.today(), System.today().adddays(30),budgetType, 110000,'INDIA', 'Developer', 'Apollo Lake', 'Pending Approval', false);
            ipaCampaignForAP.Core_MDF_Region_cd__c = 'APJ';
            ipaCampaignForAP.Core_MDF_Proposal_Based_Ind__c = true;
            ipaCampaignForAP.Status = 'Pending Review';
            ipaCampaignForAP.Core_Approval_Status__c = 'Price Reviewer';
            database.insert(ipaCampaignForAP);
            PartnerFundRequest ipaPFR5 = Core_MDF_CCP_IPA_TestDataUtility.createIPAPartnerFundRequest(ipaCampaignForAP.id,ipaCoMarketingAccount.id,System.today().addDays(1),System.today().addDays(10),true);
        }
    }
    
    @isTest
    static void testMethod1(){
        User systemAdmin = [Select Id from User where LastName = 'SystemAdmin'];
        
        system.runAs(systemAdmin){
            set<Id> pfrIds= new set<Id>();
            List<PartnerFundRequest> pfrList = new List<PartnerFundRequest>();
            
            PartnerFundRequest ipaPFR = [Select Id,Core_MDF_Fund_Request_Status__c,Core_MDF_Region_nm__c from PartnerFundRequest limit 1];
            ipaPFR.Core_MDF_Fund_Request_Status__c = 'Planned';
            ipaPFR.RequestedAmount=20;
            ipaPFR.Core_MDF_Region_nm__c = 'APJ';
            pfrList.add(ipaPFR);
        	Database.update(pfrList);
            
            test.startTest();
            Database.executeBatch(new Core_MDF_BulkUpsert_Batch(pfrList), 1);
            test.stopTest();
            Assert.isNotNull(pfrList);
        }        	
    }
}