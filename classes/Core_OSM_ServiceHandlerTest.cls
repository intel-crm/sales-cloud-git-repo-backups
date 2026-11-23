@isTest
public class Core_OSM_ServiceHandlerTest {
    
    @isTest
    static void testDeterminecountofAprovers() {
        // Create test data
        /*Profile pro = [SELECT id, Name FROM Profile WHERE Name='CCP - Core Access'];
        User us1 = new User();
        us1.FirstName = 'test1';
        us1.LastName = 'user';
        us1.Email = 'testuser1@intel.com';
        us1.Username = 'testinguser1@inteltest.com';
        us1.Alias = 'testu1';
        us1.CommunityNickname = 'test.userqwert1';
        us1.TimeZoneSidKey = 'America/Los_Angeles';
        us1.LocaleSidKey = 'en_US';
        us1.EmailEncodingKey = 'UTF-8';
        us1.ProfileId = pro.Id;
        us1.LanguageLocaleKey = 'en_US';
        INSERT us1;*/
        Profile pro = [SELECT id, Name FROM Profile WHERE Name='Sales Rep-BB'];
        User us1 = new User();
        us1.FirstName = 'test1';
        us1.LastName = 'user';
        us1.Email = 'testuser1@intel.com';
        us1.Username = 'testinguser1@inteltest.com';
        us1.Alias = 'testu1';
        us1.CommunityNickname = 'test.userqwert1';
        us1.TimeZoneSidKey = 'America/Los_Angeles';
        us1.LocaleSidKey = 'en_US';
        us1.EmailEncodingKey = 'UTF-8';
        us1.ProfileId = pro.Id;
        us1.LanguageLocaleKey = 'en_US';
        INSERT us1;
        User us2 = new User();
        us2.FirstName = 'test12';
        us2.LastName = 'user2';
        us2.Email = 'testuser12@intel.com';
        us2.Username = 'testinguser12@inteltest.com';
        us2.Alias = 'testu12';
        us2.CommunityNickname = 'test.userqwert12';
        us2.TimeZoneSidKey = 'America/Los_Angeles';
        us2.LocaleSidKey = 'en_US';
        us2.EmailEncodingKey = 'UTF-8';
        us2.ProfileId = pro.Id;
        us2.LanguageLocaleKey = 'en_US';
        INSERT us2;
            /*System.runAs (us1) {
    PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = '0PSDf000001B1dZOAS', AssigneeId = us1.Id);
    insert psa;
    }*/
        Core_Trigger_Executions__c triggerExecution = new Core_Trigger_Executions__c(
            Name = 'checkDuplicateOSM',
            Core_Class_Name__c = 'Core_OpptySupportMappingTriggerHandler',
            Core_Description__c = 'test',
            Core_Object__c = 'Core_Opportunity_Support_Mapping__c',
            Core_Trigger_Events__c = 'before insert, before Update',
            Core_Active__c = true
        );
        insert triggerExecution;
        Map<string,List<Core_Opportunity_Support_Mapping__c>> keyForOSM_CSA = new Map<String,List<Core_Opportunity_Support_Mapping__c>>();
        Map<string,List<Core_Opportunity_Support_Mapping__c>>  keyForOSM_TSS = new Map<string,List<Core_Opportunity_Support_Mapping__c>> ();
        Map<string,List<Core_Opportunity_Support_Mapping__c>>  keyForOSM_COE = new Map<string,List<Core_Opportunity_Support_Mapping__c>> ();
        
        List<Core_Opportunity_Support_Mapping__c> oppmappingLst = new List<Core_Opportunity_Support_Mapping__c>();
        
        Core_Opportunity_Support_Mapping__c oppmapping = new Core_Opportunity_Support_Mapping__c();
        oppmapping.Geo_Region__c='APJ';
        oppmapping.Core_OSM_Record_Type__c='CSA';
        oppmapping.User__c=us1.id;
        oppmapping.Core_Opportunity_Support_Is_Active__c=true;
        oppmappingLst.add(oppmapping);
        
        Core_Opportunity_Support_Mapping__c oppmapping2 = new Core_Opportunity_Support_Mapping__c();
        oppmapping2.Geo_Region__c='ASMO';
        oppmapping2.Core_OSM_Record_Type__c='CSA';
        oppmapping2.User__c=us2.id;
        oppmapping2.Core_Opportunity_Support_Is_Active__c=true;
        oppmappingLst.add(oppmapping2);
        Core_Opportunity_Support_Mapping__c oppmapping3 = new Core_Opportunity_Support_Mapping__c();
        
        oppmapping3.Core_OSM_Record_Type__c='TSS';
        oppmapping3.Geo_Region__c='ASMO';
        oppmapping3.Core_BU__c ='DCAI TSS Support';
        oppmapping3.User__c=us1.id;
        oppmapping3.Core_Opportunity_Support_Is_Active__c=true;
        
        oppmappingLst.add(oppmapping3);
        Core_Opportunity_Support_Mapping__c oppmapping6 = new Core_Opportunity_Support_Mapping__c();
        
        oppmapping6.Core_OSM_Record_Type__c='TSS';
        oppmapping6.Geo_Region__c='APJ';
        oppmapping6.Core_BU__c ='DCAI TSS Support';
        oppmapping6.User__c=us2.id;
        oppmapping6.Core_Opportunity_Support_Is_Active__c=true;
        oppmappingLst.add(oppmapping6);
        Core_Opportunity_Support_Mapping__c oppmapping4 = new Core_Opportunity_Support_Mapping__c();
        
        oppmapping4.Core_OSM_Record_Type__c='COE';
        oppmapping4.Core_Opp_Center_of_Excellence__c ='Artificial Intelligence (AI)';
        oppmapping4.User__c=us1.id;
        oppmapping4.Core_Opportunity_Support_Is_Active__c=true;
        oppmappingLst.add(oppmapping4);
        Core_Opportunity_Support_Mapping__c oppmapping5 = new Core_Opportunity_Support_Mapping__c();
        
        oppmapping5.Core_OSM_Record_Type__c='COE';
        oppmapping5.Core_Opp_Center_of_Excellence__c ='Government';
        oppmapping5.User__c=us2.id;
        oppmapping5.Core_Opportunity_Support_Is_Active__c=false;
        oppmappingLst.add(oppmapping5);
        
        insert oppmappingLst;
        oppmapping5.Core_Opportunity_Support_Is_Active__c=false;
        update oppmapping5;
        for(Core_Opportunity_Support_Mapping__c rec :oppmappingLst)
        {
            if (rec.Core_OSM_Record_Type__c == 'CSA'){
                if(keyForOSM_CSA.containskey(rec.Core_OSM_Record_Type__c+'_'+rec.Geo_Region__c))
                {
                    keyForOSM_CSA.get(rec.Core_OSM_Record_Type__c+'_'+rec.Geo_Region__c).add(rec);
                }
                else{
                    keyForOSM_CSA.put(rec.Core_OSM_Record_Type__c+'_'+rec.Geo_Region__c,new List<Core_Opportunity_Support_Mapping__c>{rec}); 
                }
            }
            else if(rec.Core_OSM_Record_Type__c == 'COE')
            {
                
                if(keyForOSM_COE.containskey(rec.Core_OSM_Record_Type__c+'_'+rec.Core_Opp_Center_of_Excellence__c))
                {
                    keyForOSM_COE.get(rec.Core_OSM_Record_Type__c+'_'+rec.Core_Opp_Center_of_Excellence__c).add(rec);
                }
                else{
                    keyForOSM_COE.put (rec.Core_OSM_Record_Type__c+'_'+rec.Core_Opp_Center_of_Excellence__c,new List<Core_Opportunity_Support_Mapping__c>{rec});
                }
            }
            else if(rec.Core_OSM_Record_Type__c == 'TSS')
            {
                if(keyForOSM_TSS.containskey(rec.Core_OSM_Record_Type__c +'_'+rec.Geo_Region__c+'_'+rec.Core_BU__c))
                {
                    keyForOSM_TSS.get(rec.Core_OSM_Record_Type__c +'_'+rec.Geo_Region__c+'_'+rec.Core_BU__c).add(rec);
                }
                else{
                    keyForOSM_TSS.put(rec.Core_OSM_Record_Type__c +'_'+rec.Geo_Region__c+'_'+rec.Core_BU__c,new List<Core_Opportunity_Support_Mapping__c>{rec});
                }
            }
            
        }
        // Call the method you want to test
        Test.startTest();
        Core_OpptyMappingSupportServiceHandler.determinecountofAprovers(oppmappingLst);
        Test.stopTest();
        
        // Perform assertions to verify the behavior
        // For example, assert that errors were added as expected
        // Use System.assertEquals or System.assert statements
    }    
}