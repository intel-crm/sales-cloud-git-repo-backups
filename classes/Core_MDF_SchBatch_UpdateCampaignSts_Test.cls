@isTest(SeeAllData=false) 
public class Core_MDF_SchBatch_UpdateCampaignSts_Test {
    
    
    @isTest static void createCampaignRecords(){
        Profile systemAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1];
        // Creating User with utility class 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.profileId = systemAdminProfile.Id;
        insert usr;
        
        System.runAs(usr){
            // Creating channel program with utility class
            ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.CCF_PROGRAM,'Client CoMarketing Fund', true);
            ChannelProgram ipaCP = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.IPA_PROGRAM,'Intel Partner Alliance', true);
            
            // Creating IntelAccount with utility class
            Account intacc = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Test Intel Account', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
            
            // Creating Co-marketing Account with utility class
            Account acc = Core_MDF_CCP_TestDataUtility.createAccount ('Test Account', cp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            acc.Core_MDF_Parent_Fund_Account__c = intacc.Id;
            insert acc;
            
            insert new Core_MDF_BudgetType_Benefit_Mappings__c(Name = 'Business Client Acceleration - MDF', Core_MDF_IsActive__c = true, Core_MDF_Is_IUPGM_Monitor_Applicable_Ind__c = true, Core_MDF_Partner_Benefit__c = 'Business Client Acceleration - MDF', Core_MDF_Record_Developer_Nm__c = 'Core_MDF_Intel_Partner_Alliance_Proposal_Based', Core_MDF_Budget_Type__c = 'Proposal I MDF', Core_MDF_Program_Nm__c = 'Intel Partner Alliance', Core_MDF_RecordType__c = 'Proposal Based');
            Account ipaCoMarketingAccount = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('IPA Co-Marketing Account', ipaCP.id, Core_MDF_CCP_TestDataUtility.Account_Record_Type,intacc.id, true);
            string budgetType = Core_MDF_CCP_IPA_TestDataUtility.createBenefit(ipaCoMarketingAccount); 

            // Creating Campaign with utility class      
            List<Campaign> campList = new List<Campaign>();
            Campaign campcx1 = Core_MDF_CCP_TestDataUtility.createCampaign('Completed Campaign 1','Gaming','Intel® Core™ i7 Processor','Yes', Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', System.today()-30, System.today()-1, 3000, 'Unite', acc.Id,'Desktop',false); 
            campcx1.Core_MDF_Opal_Budget_Type_Txt__c = 'OEM CMP';
            Campaign campcx2 = Core_MDF_CCP_TestDataUtility.createCampaign('Completed Campaign 2','Gaming','Intel® Core™ i7 Processor','Yes', Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', System.today()-30, System.today()-1, 3000, 'Unite', acc.Id,'Desktop',false); 
            campcx2.Core_MDF_Opal_Budget_Type_Txt__c = 'OEM CMP';
            //Campaign ipaCamp = Core_MDF_CCP_IPA_TestDataUtility.createIPACampaign('Completed IPA Campaign',ipaCoMarketingAccount.id, System.today()-30, System.today()-1,budgetType, 110000,'INDIA', 'Business Owners', 'Apollo Lake', 'In Progress', false);
            Campaign campcx3 = Core_MDF_CCP_TestDataUtility.createCampaign('In Progress Campaign 1','Gaming','Intel® Core™ i7 Processor','Yes', Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', System.today()-30, System.today().addDays(20), 3000, 'Unite', acc.Id,'Desktop',false);
            campcx3.Core_MDF_Opal_Budget_Type_Txt__c = 'OEM CMP';
            Campaign campcx4 = Core_MDF_CCP_TestDataUtility.createCampaign('In Progress Campaign 2','Gaming','Intel® Core™ i7 Processor','Yes', Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', System.today()-30, System.today().addDays(20), 3000, 'Unite', acc.Id,'Desktop',false);
            campcx4.Core_MDF_Opal_Budget_Type_Txt__c = 'OEM CMP';
            campList.add(campcx1);campList.add(campcx2);campList.add(campcx3);campList.add(campcx4);
            //campList.add(ipaCamp);
            Database.insert(campList);
            
            System.runAs(usr){
                
                
                Test.startTest();
                Core_MDF_Batch_UpdateCampaignSts ex = new Core_MDF_Batch_UpdateCampaignSts();
				Id JobId = database.executeBatch(ex);
                Test.stopTest();
                List<Campaign> assertCampList =  [SELECT Id, Status,Name from Campaign];          
                
                for(Campaign camp:assertCampList)
                {
                    if(camp.Name.contains('Completed')){
                        System.assertEquals('Completed',camp.Status);}
                    else{
                        System.assertEquals('In Progress',camp.Status);
                    }
                }
            }
            
        }    
    }
    
    @isTest
    static void testScheduledClass() {
        Test.startTest();
        
        // Schedule the job
        String jobName = 'TestJob';
        String cronExpression = '0 0 12 * * ?';
        System.schedule(jobName, cronExpression, new Core_MDF_SchBatch_UpdateCampaignSts());
        Test.stopTest();
    }
    
}