@isTest
private class PRM_DisplayTrackerCtrlTest {
    @testSetup static void setup() {
        Account acc = new Account();//Account
        acc.Name='John Rick';
        acc.BillingCity='City';
        acc.BillingStreet='Street';
        acc.BillingCountry='India';
        acc.BillingPostalCode='Postal code';
        acc.Core_Account_Type__c='Cloud Service Provider (CSP)';
        insert acc;
        

        ChannelProgram cprogram = new ChannelProgram();
        cprogram.Name='Intel Partner Alliance';
        cprogram.PRM_programCode__c='IPA';
        cprogram.IsActive = true;
        insert cprogram;
        
        ChannelProgramLevel level = new ChannelProgramLevel();   //Channel Program Level
        level.Name='Member';
        level.ProgramId = cprogram.Id;
        insert level;

        PRM_Value_Exchange_Recommendation__c valueExchange = new PRM_Value_Exchange_Recommendation__c();
        valueExchange.RecordTypeId = Schema.SObjectType.PRM_Value_Exchange_Recommendation__c.getRecordTypeInfosByDeveloperName().get('PRM_OPID_Recommendation').getRecordTypeId();
        valueExchange.PRM_Tier_Id__c = level.Id;
        valueExchange.PRM_Account_Id__c = acc.Id;
        valueExchange.PRM_Recommendation_Type_Nm__c = Label.PRM_VX_RecommendationType_OPID;
        valueExchange.PRM_Recommendation_Status_Nm__c = 'In Process' ;//Label.PRM_VX_Status_OPIDInProcess
        valueExchange.PRM_Grouping_Method_Nm__c = 'GEO';
        valueExchange.PRM_Partner_Role_Nm__c = 'Distributor';
        insert valueExchange;
    }

    @isTest static void displayTrackerTest() {
        PRM_Value_Exchange_Recommendation__c opidRecommendation = [Select Id,PRM_Account_Id__c FROM PRM_Value_Exchange_Recommendation__c LIMIT 1];
        List<Core_CustomMetadata_Object__c> custMetaList = new List<Core_CustomMetadata_Object__c>();
        Core_CustomMetadata_Object__c meta = new Core_CustomMetadata_Object__c();
        meta.Field_7__c ='PRM_Type__c';
        meta.DeveloperName__c = 'DeveloperName';
        meta.Field_1__c = 'PRM_Active__c';
        meta.Field_2__c = 'PRM_Conditional_Display__c';
        meta.Field_3__c ='PRM_Failed_Step__c';
        meta.Field_4__c ='PRM_Milestone_Display_Name__c';
        meta.Field_5__c ='PRM_Order__c';
        meta.Field_6__c ='PRM_Skippable_step__c';
        meta.Metadata_Name__c ='PRM_Tracker_steps__mdt';
        meta.MasterLabel__c='MasterLabel';
        insert meta;
        Core_CustomMetadata_Object__c meta1 = new Core_CustomMetadata_Object__c();
        meta1.Field_7__c = 'OPID Recommendation';
        meta1.DeveloperName__c = 'IN_PRGS';
        meta1.Field_1__c = 'TRUE';
        meta1.Field_2__c = 'FALSE';
        meta1.Field_3__c ='FASLE';
        meta1.Field_4__c ='In Progress';
        meta1.Field_5__c ='1';
        meta1.Field_6__c = 'FASLE';
        meta1.Metadata_Name__c ='PRM_Tracker_steps__mdt';
        meta1.Header_row__c = meta.id;
        custMetaList.add(meta1);
        Core_CustomMetadata_Object__c meta2 = new Core_CustomMetadata_Object__c();
        meta2.Field_7__c = 'OPID Recommendation';
        meta2.DeveloperName__c = 'OPID_SUBMITTED';
        meta2.Field_1__c = 'TRUE';
        meta2.Field_2__c = 'FALSE';
        meta2.Field_3__c ='FASLE';
        meta2.Field_4__c ='Submitted for OPID';
        meta2.Field_5__c ='2';
        meta2.Field_6__c = 'FASLE';
        meta2.Metadata_Name__c ='PRM_Tracker_steps__mdt';
        meta2.Header_row__c = meta.id;
        custMetaList.add(meta2);
        Core_CustomMetadata_Object__c meta3 = new Core_CustomMetadata_Object__c();
        meta3.Field_7__c = 'OPID Updates 1PID';
        meta3.DeveloperName__c = 'OPID_ASSOCIATED';
        meta3.Field_1__c = 'TRUE';
        meta3.Field_2__c = 'FALSE';
        meta3.Field_3__c ='FASLE';
        meta3.Field_4__c ='Location account associated Link(PRM_LOC_account_name__c,PRM_Location_Account__c)';
        meta3.Field_5__c ='1';
        meta3.Field_6__c = 'FASLE';
        meta3.Metadata_Name__c ='PRM_Tracker_steps__mdt';
        meta3.Header_row__c = meta.id;
        custMetaList.add(meta3);
        Core_CustomMetadata_Object__c meta4 = new Core_CustomMetadata_Object__c();
        meta4.Field_7__c = 'OPID Updates';
        meta4.DeveloperName__c = 'OPID_ASSOCIATED';
        meta4.Field_1__c = 'TRUE';
        meta4.Field_2__c = 'FALSE';
        meta4.Field_3__c ='FASLE';
        meta4.Field_4__c ='OPID AssociatedLink(PRM_OPID_account_name__c,PRM_OPID__c)';
        meta4.Field_5__c ='1';
        meta4.Field_6__c = 'FASLE';
        meta4.Metadata_Name__c ='PRM_Tracker_steps__mdt';
        meta4.Header_row__c = meta.id;
        custMetaList.add(meta4);
        insert custMetaList;
        
        List<PRM_Tracker__c> trList = new List<PRM_Tracker__c>();
        PRM_Tracker__c tracker = new PRM_Tracker__c();
        tracker.PRM_Type__c = 'OPID Recommendation';
        tracker.PRM_Milestone__c = 'IN_PRGS';
        tracker.PRM_OPID_Recommendation__c = opidRecommendation.Id;
        tracker.PRM_Completed__c = true;
        trList.add(tracker);

        PRM_Tracker__c tracker1 = new PRM_Tracker__c();
        tracker1.PRM_Type__c = 'OPID Recommendation';
        tracker1.PRM_Milestone__c = 'OPID_SUBMITTED';
        tracker1.PRM_OPID_Recommendation__c = opidRecommendation.Id;
        tracker1.PRM_Completed__c = false;
        trList.add(tracker1);

        PRM_Tracker__c tracker2 = new PRM_Tracker__c();
        tracker2.PRM_Type__c = 'OPID Updates';
        tracker2.PRM_Milestone__c = 'OPID_ASSOCIATED';
        tracker2.PRM_Location_Account__c = opidRecommendation.PRM_Account_Id__c;
        tracker2.PRM_Completed__c = true;
        tracker2.PRM_OPID__c = opidRecommendation.PRM_Account_Id__c;
        trList.add(tracker2);
        
        PRM_Tracker__c tracker3 = new PRM_Tracker__c();
        tracker3.PRM_Type__c = 'OPID Updates 1PID';
        tracker3.PRM_Milestone__c = 'LOC_ASSC';
        tracker3.PRM_Location_Account__c = opidRecommendation.PRM_Account_Id__c;
        tracker3.PRM_Completed__c = true;
        tracker3.PRM_OPID__c = opidRecommendation.PRM_Account_Id__c;
        tracker3.PRM_Milestone_Display_Name__c = 'Location account associated Link(PRM_LOC_account_name__c,PRM_Location_Account__c)';
        trList.add(tracker3);

        insert trList;
        
        Test.startTest();

        PRM_DisplayTrackerCtrl.getTrackerSteps(opidRecommendation.Id, 'OPID Recommendation', 'PRM_OPID_Recommendation__c');

        PRM_DisplayTrackerCtrl.getTrackerSteps(opidRecommendation.PRM_Account_Id__c, 'OPID Updates', 'PRM_Location_Account__c');
      
        PRM_DisplayTrackerCtrl.getTrackerSteps(opidRecommendation.PRM_Account_Id__c, 'OPID Updates 1PID', 'PRM_OPID__c');
        
        Test.stopTest();
        system.assertEquals(trList.size(),4);
    }
}