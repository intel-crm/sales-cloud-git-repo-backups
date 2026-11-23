/**************************************************************************************
Apex Class Name:  Core_MDF_SchBatch_UpdateCampaignSts_Test 
Version     : 1.0 
Created Date: 25 07 2018
Function    : Test class for the scheduler class for completing the campaign if claim window passed.
Author      : Ealisha Chatterjee
Modification Log :
* Change#           Author                   Date                   Description
* ----------------------------------------------------------------------------                 
* Core MDF Rel1   Ealisha Chatterjee          25/07/2018              Original Version
*
*************************************************************************************/
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
         ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram ('Client Co-Marketing Fund','Client CoMarketing Fund', true);
       
       // Creating IntelAccount with utility class
             Account intacc = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Test Intel Account', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
             intacc.Core_Account_Type__c = 'Reseller';
             intacc.Core_Sales_Groups__c = 'Automotive Sales Group';
             intacc.Industry = 'Food & Beverage';
             insert intacc;
             
             // Creating Co-marketing Account with utility class
             Account acc = Core_MDF_CCP_TestDataUtility.createAccount ('Test Account', cp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
             acc.Core_MDF_Parent_Fund_Account__c = intacc.Id;
             insert acc;
            
      // Creating Budget 2018 with utility class  
        // PartnerMarketingBudget pmbccf2018 = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget 1',Core_MDF_CCP_TestDataUtility.Budget_Record_Type, acc.Id, cp.Id, 30000, Date.newInstance(2018,7,18), Date.newInstance(2018,12,31), true);
        
      // Creating Priority with utility class   
       //  Core_MDF_Priority__c priority =  Core_MDF_CCP_TestDataUtility.createPriority(cp.Id, true); 
        Datetime dtTime=System.now();
        date startdtForCompleteCamp= date.newinstance(dtTime.year(), dtTime.month(), (dtTime.day()));
        date enddtForCompleteCamp= date.newinstance(dtTime.year(), dtTime.month(), (dtTime.day()));
        date startdtForInProgressCamp= date.newinstance(dtTime.year(), dtTime.month(), (dtTime.day()));
        date startdtInPastForInProgressCamp= date.newinstance(dtTime.year(), dtTime.month(), (dtTime.day()-2));
        date enddtForInProgressCamp= date.newinstance(dtTime.year(), dtTime.month(), (dtTime.day()+1));
        date enddtForInProgressCampInPastDate= date.newinstance(dtTime.year(), dtTime.month(), (dtTime.day()-1));
      
            // Creating Campaign with utility class      
         //Campaign campcx1 = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 2','Gaming','Intel® Core™ i7 Processor', Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', startdtForCompleteCamp, enddtForCompleteCamp, 3000, 'Unite', acc.Id, true);
           Campaign campcx2 = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 2','Gaming','Intel® Core™ i7 Processor', Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', startdtForInProgressCamp, enddtForInProgressCamp, 3000, 'Unite', acc.Id,'Desktop',true);           
           Campaign campcx3 = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 2','Gaming','Intel® Core™ i7 Processor', Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', startdtInPastForInProgressCamp, enddtForInProgressCamp, 3000, 'Unite', acc.Id,'Desktop',true);           
		   Campaign campcx4 = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 2','Gaming','Intel® Core™ i7 Processor', Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', startdtInPastForInProgressCamp, enddtForInProgressCampInPastDate, 3000, 'Unite', acc.Id,'Desktop',true);           
		   Campaign campcx5 = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 2','Gaming','Intel® Core™ i7 Processor', Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', startdtInPastForInProgressCamp, enddtForInProgressCampInPastDate, 3000, 'Unite', acc.Id,'Desktop',true);
           campcx5.Core_MDF_Second_Year_Budget_Amount__c = 25;
            
            List<Campaign> testCamp = new List<Campaign>();
            //testCamp.add(campcx1);
            testCamp.add(campcx2); 
            testCamp.add(campcx3); 
            testCamp.add(campcx4);
            testCamp.add(campcx5);
            
            System.runAs(usr){
            Test.startTest();
            Core_MDF_Batch_UpdateCampaignSts batchProcess=new Core_MDF_Batch_UpdateCampaignSts();
            batchProcess.execute(null,testCamp);
            Test.stopTest();
            system.debug('Into Assert for schedular test method1 :');           
            List<Campaign> cmp =  [SELECT Id, Status from Campaign WHERE Id in :testCamp];  
            system.debug('cmp:'+cmp);
                /*for(Campaign camp:cmp)
                {
                	System.assertEquals('In Progress',camp.Status);
                }*/
        }
            
        }    
    }
   @isTest static void testSchedulerMethod(){  
        Profile systemAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1];
         // Creating User with utility class 
         User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
         usr.profileId = systemAdminProfile.Id;
         insert usr;
       
         Datetime dtTime=System.now();
         date startdtForInProgressCamp= date.newinstance(dtTime.year(), dtTime.month(), (dtTime.day()));
         date startdtInPastForInProgressCamp= date.newinstance(dtTime.year(), dtTime.month(), (dtTime.day()-2));        
         date enddtForInProgressCamp= date.newinstance(dtTime.year(), dtTime.month(), (dtTime.day()+1));
       	 date enddtForInProgressCampInPastDate= date.newinstance(dtTime.year(), dtTime.month(), (dtTime.day()-1));
         
        System.runAs(usr){
        Test.startTest();
          // Creating channel program with utility class
         ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram ('Client Co-Marketing Fund','Client CoMarketing Fund', true);
       
          // Creating IntelAccount with utility class
             Account intacc = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Test Intel Account', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
             intacc.Core_Account_Type__c = 'Reseller';
             intacc.Core_Sales_Groups__c = 'Automotive Sales Group';
             intacc.Industry = 'Food & Beverage';
             insert intacc;
             
             // Creating Co-marketing Account with utility class
             Account acc = Core_MDF_CCP_TestDataUtility.createAccount ('Test Account', cp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
             acc.Core_MDF_Parent_Fund_Account__c = intacc.Id;
             insert acc;
            
            Campaign cmpToBeUpdatedToInProgress1 = Core_MDF_CCP_TestDataUtility.createCampaign('Test cmp To Be Updated To InProgress','Gaming','Intel® Core™ i7 Processor', Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', startdtForInProgressCamp, enddtForInProgressCamp, 3000, 'Unite', acc.Id,'Desktop',true);                      
            Campaign cmpToBeUpdatedToInProgress2 = Core_MDF_CCP_TestDataUtility.createCampaign('Test cmp To Be Updated To InProgress','Gaming','Intel® Core™ i7 Processor', Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', startdtInPastForInProgressCamp, enddtForInProgressCamp, 3000, 'Unite', acc.Id,'Desktop',true);                      
            Campaign cmpToBeUpdatedToInProgress3 = Core_MDF_CCP_TestDataUtility.createCampaign('Test cmp To Be Updated To InProgress','Gaming','Intel® Core™ i7 Processor', Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', startdtInPastForInProgressCamp, enddtForInProgressCampInPastDate, 3000, 'Unite', acc.Id,'Desktop',true);   
            List<Campaign> testCamp = new List<Campaign>();
            
            testCamp.add(cmpToBeUpdatedToInProgress1); 
            testCamp.add(cmpToBeUpdatedToInProgress2);
            testCamp.add(cmpToBeUpdatedToInProgress3);
            Core_MDF_SchBatch_UpdateCampaignSts scheduleReprocess = new Core_MDF_SchBatch_UpdateCampaignSts();
            String sch = '0 0 6 * * ? ';
            System.schedule('Test Batch Status Check', sch, scheduleReprocess);
            Test.stopTest();
            List<Campaign> cmpUpdatedToInProgress =  [SELECT Id, Status from Campaign WHERE Id in :testCamp];  
            system.debug('cmpUpdatedToInProgress:' + cmpUpdatedToInProgress);
            for(Campaign camp:cmpUpdatedToInProgress){
            System.assertEquals('In Progress',camp.Status); 
            }
        }
        
    }
}