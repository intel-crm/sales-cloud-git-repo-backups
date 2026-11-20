@isTest
public class Core_Integ_Additional_Attributes_Test {   
    
    @testSetup static void TestDataSetup(){
        Test.startTest();
        TestSetupMethod(42);     
        Test.stopTest();
    }       
    
    private static Core_ERPM_Engagement__c newERPMEngagement(String enggCode) {
        return new Core_ERPM_Engagement__c(Name=enggCode, Core_IsActive__c=true, Core_Engagement_Type__c='SMP',
                                           Core_Technical_Engagement_Code__c=enggCode, Core_Description__c=enggCode);
    }
    
    @isTest static void SetProfileResponses_ValidData(){              
        system.debug('////-----SetProfileResponses_ValidData-----////');
        Account newAccount = GetAccount('UnitTestCasesAccount42');
        Contact cont = GetContact('silam.munusamy@test42.com');
        ChannelProgram cp = GetChannelProgram('IPA');
        //Validate Program Code
        //system.debug('Before Validating Channel Program');
        system.debug('Valid Channel Program Code Scenario');            
        System.assertEquals(true,new Core_Integration_Additional_Attributes(newAccount.Id,cont.id,cp.PRM_programCode__c, null,null,null,null,null,null).IsProgramCodeValid(),'Valid Program Code');
        system.debug('InValid Channel Program Code Scenario');
        System.assertEquals(false,new Core_Integration_Additional_Attributes(newAccount.Id,cont.id,cp.PRM_programCode__c +'Test', null,null,null,null,null,null).IsProgramCodeValid(),'Invalid Program Code');
        
        List<Core_IntegrationUtility.eRPM_Profile_Response> erpmProfileResponses = new List<Core_IntegrationUtility.eRPM_Profile_Response>();
        Core_IntegrationUtility.eRPM_Profile_Response ePR = new Core_IntegrationUtility.eRPM_Profile_Response();
        ePR.eRPM_QuestionCode ='PQ-000010';
        ePR.eRPM_ResponseCode ='PA-000010';
        ePR.eRPM_ResponseText ='test Response';
        erpmProfileResponses.add(ePR);
        system.debug('erpmProfileResponses   :: ' + erpmProfileResponses);   
        
        ePR = new Core_IntegrationUtility.eRPM_Profile_Response();
        ePR.eRPM_QuestionCode ='PQ-000010';
        ePR.eRPM_ResponseCode ='PA-000011';
        ePR.eRPM_ResponseText ='Service Department';
        erpmProfileResponses.add(ePR);
        system.debug('erpmProfileResponses   :: ' + erpmProfileResponses);   
        
        ePR = new Core_IntegrationUtility.eRPM_Profile_Response();
        ePR.eRPM_QuestionCode ='PQ-000011';
        ePR.eRPM_ResponseCode ='PA-000012';
        ePR.eRPM_ResponseText ='Bare Metal-as-a-Service';
        erpmProfileResponses.add(ePR);
        system.debug('erpmProfileResponses   :: ' + erpmProfileResponses);   
        
        ePR = new Core_IntegrationUtility.eRPM_Profile_Response();
        ePR.eRPM_QuestionCode ='PQ-000011';
        ePR.eRPM_ResponseCode ='PA-000013';
        ePR.eRPM_ResponseText='test Response -AI -as-a-Service';
        erpmProfileResponses.add(ePR);
        system.debug('erpmProfileResponses   :: ' + erpmProfileResponses);
        
        system.debug('NullOrEmptyProfileResponses Scenario');
        System.assertEquals(false, new Core_Integration_Additional_Attributes(newAccount.Id,cont.Id,cp.PRM_programCode__c,null,null,null,null,null,null).SetProfileResponses(new List<Core_IntegrationUtility.eRPM_Profile_Response>()));
        
        system.debug('---Valid  Scenario ---');
        system.debug('Valid  Set Profile Responses Scenario');
        System.assertEquals(true, new Core_Integration_Additional_Attributes(newAccount.Id,cont.Id,cp.PRM_programCode__c,null,null,null,null,null,null).SetProfileResponses(erpmProfileResponses));        
        
        erpmProfileResponses = new List<Core_IntegrationUtility.eRPM_Profile_Response>();
        ePR = new Core_IntegrationUtility.eRPM_Profile_Response();
        ePR.eRPM_QuestionCode ='PQ-000010';
        ePR.eRPM_ResponseCode ='PA-000010';
        ePR.eRPM_ResponseText ='test Response';
        erpmProfileResponses.add(ePR);
        system.debug('erpmProfileResponses   :: ' + erpmProfileResponses);   
        
        ePR = new Core_IntegrationUtility.eRPM_Profile_Response();
        ePR.eRPM_QuestionCode ='PQ-000010';
        ePR.eRPM_ResponseCode ='PA-000011';
        ePR.eRPM_ResponseText ='Service Department';
        erpmProfileResponses.add(ePR);
        system.debug('erpmProfileResponses   :: ' + erpmProfileResponses);   
        
        ePR = new Core_IntegrationUtility.eRPM_Profile_Response();
        ePR.eRPM_QuestionCode ='PQ-000011';
        ePR.eRPM_ResponseCode ='PA-000012';
        ePR.eRPM_ResponseText ='Bare Metal-as-a-Service';
        erpmProfileResponses.add(ePR);
        system.debug('erpmProfileResponses   :: ' + erpmProfileResponses); 
        
        System.assertEquals(false, new Core_Integration_Additional_Attributes(newAccount.Id,cont.Id,cp.PRM_programCode__c,null,null,null,null,null,null).SetProfileResponses(erpmProfileResponses));
        
    }
    
    @isTest static void SetProfileResponses_TextQuestionType(){              
        system.debug('////-----SetProfileResponses_ValidData-----////');
        Account newAccount = GetAccount('UnitTestCasesAccount42');
        Contact cont = GetContact('silam.munusamy@test42.com');
        ChannelProgram cp = GetChannelProgram('IPA');
        //Validate Program Code
        //system.debug('Before Validating Channel Program');
        List<PRM_Profile_Questions__c> profileQstns = new List<PRM_Profile_Questions__c>();
        profileQstns = [SELECT ID FROM PRM_Profile_Questions__C where PRM_Question_Cd__c ='PQ-000010'];
        List<PRM_Profile_Answer__c> profileResepGet = [SELECT ID FROM PRM_Profile_Answer__c where PRM_Answer_Cd__c IN ('PA-000010','PA-000011')];
        system.debug('-----Test method ---- profileQstns ----- ::: '+ profileQstns);
        system.debug('-----Test method ---- profileResepGet.size ----- ::: '+ profileResepGet.size());        
        system.debug('-----Test method ---- profileQstns.size ----- ::: '+ profileQstns.size());
        
        List<PRM_Profile_Responses__c> ProfileResponses = new List<PRM_Profile_Responses__c>();
        PRM_Profile_Responses__c ProfileResponse = new PRM_Profile_Responses__c(
            PRM_Account_Id__c = newAccount.Id,
            PRM_Contact_Id__c = cont.id,
            PRM_Profile_Questions_Id__c = profileQstns[0].id,
            PRM_Profile_Answer_Id__c = [SELECT Id from PRM_Profile_Answer__c where PRM_Answer_Cd__c = 'PA-000010' AND PRM_Profile_Questions_Id__c =: profileQstns[0].id].id,
            PRM_Response_Txt__c = 'test Response',
            PRM_InActive_Ind__c = false);
        ProfileResponses.add(ProfileResponse);
        
        ProfileResponse = new PRM_Profile_Responses__c(
            PRM_Account_Id__c = newAccount.Id,
            PRM_Contact_Id__c = cont.id,
            PRM_Profile_Questions_Id__c = profileQstns[0].id,
            PRM_Profile_Answer_Id__c = [SELECT Id from PRM_Profile_Answer__c where PRM_Answer_Cd__c = 'PA-000011' AND PRM_Profile_Questions_Id__c =: profileQstns[0].id].id,
            PRM_Response_Txt__c = 'test Response',
            PRM_InActive_Ind__c = false);
        ProfileResponses.add(ProfileResponse);
        insert ProfileResponses;
        
        List<PRM_Profile_Responses__c> ProfileResponsesa = [select PRM_Contact_Id__c,PRM_Account_Id__c,PRM_Profile_Questions_Id__c,PRM_Profile_Answer_Id__c,PRM_Response_Txt__c,PRM_InActive_Ind__c from PRM_Profile_Responses__c where PRM_Account_Id__c=:newAccount.Id];
        System.debug('ProfileResponses First Round ::: '+ProfileResponsesa.size());
        
        List<Core_IntegrationUtility.eRPM_Profile_Response> erpmProfileResponses = new List<Core_IntegrationUtility.eRPM_Profile_Response>();
        Core_IntegrationUtility.eRPM_Profile_Response ePR = new Core_IntegrationUtility.eRPM_Profile_Response(); 
        ePR = new Core_IntegrationUtility.eRPM_Profile_Response();
        ePR.eRPM_QuestionCode ='PQ-000010';
        ePR.eRPM_ResponseCode ='PA-000010';
        ePR.eRPM_ResponseText ='test Response';
        erpmProfileResponses.add(ePR);
        system.debug('erpmProfileResponses   :: ' + erpmProfileResponses); 
        
        ePR = new Core_IntegrationUtility.eRPM_Profile_Response();
        ePR.eRPM_QuestionCode ='PQ-000010';
        ePR.eRPM_ResponseCode ='PA-000011';
        ePR.eRPM_ResponseText ='test Response';
        erpmProfileResponses.add(ePR);
        system.debug('erpmProfileResponses   :: ' + erpmProfileResponses);               
        system.debug('Valid  Set Profile Responses Scenario');
        System.assertEquals(false, new Core_Integration_Additional_Attributes(newAccount.Id,cont.Id,cp.PRM_programCode__c,null,null,null,null,null,null).SetProfileResponses(erpmProfileResponses));
        
        List<PRM_Profile_Responses__c> ProfileResponsesList = [select PRM_Contact_Id__c,PRM_Account_Id__c,PRM_Profile_Questions_Id__c,PRM_Profile_Answer_Id__c,PRM_Response_Txt__c,PRM_InActive_Ind__c from PRM_Profile_Responses__c 
                                                               where PRM_Account_Id__c=:newAccount.Id];
        System.debug('ProfileResponsesList ' + ProfileResponsesList.size());
        //System.debug('ProfileResponsesList ' + ProfileResponsesList);
        System.assertEquals(2, ProfileResponsesList.size());        
    }
    
    @isTest static void SetProfileResponses_PicklistQuestionType(){              
        system.debug('////-----SetProfileResponses_ValidData-----////');
        Account newAccount = GetAccount('UnitTestCasesAccount42');
        Contact cont = GetContact('silam.munusamy@test42.com');
        ChannelProgram cp = GetChannelProgram('IPA');
        //Validate Program Code
        //system.debug('Before Validating Channel Program');
        List<PRM_Profile_Questions__c> profileQstns = CreateProfileQuestions(cp.id,new List<string>{'PQ-000020', 'PQ-000021'});                 
        profileQstns[0].PRM_Question_Type_Nm__c = 'Picklist';
        profileQstns[1].PRM_Question_Type_Nm__c = 'Picklist';
        update profileQstns;
        CreateProfileAnswers(profileQstns[0].Id, new List<string> { 'PA-000021','PA-000022'});
        CreateProfileAnswers(profileQstns[1].Id, new List<string> { 'PA-000023','PA-000024'});               
        system.debug('-----Test method ---- profileQstns ----- ::: '+ profileQstns);             
        system.debug('-----Test method ---- profileQstns.size ----- ::: '+ profileQstns.size());
        List<PRM_Profile_Answer__c> PAs = [SELECT Id,PRM_Answer_Cd__c,PRM_Profile_Questions_Id__r.PRM_Question_Cd__c from PRM_Profile_Answer__c where PRM_Answer_Cd__c In ('PA-000021','PA-000022', 'PA-000023','PA-000024') ORDER BY PRM_Answer_Cd__c ASC];
        system.debug('----- PAs ------' + PAs);
        
        system.debug('----- PAs[0] + PRM_Answer_Cd__c  ------' + PAs[0].PRM_Answer_Cd__c + ' :: PRM_Profile_Questions_Id__r.PRM_Question_Cd__c :: ' + PAs[0].PRM_Profile_Questions_Id__r.PRM_Question_Cd__c);
        system.debug('----- PAs[1] + PRM_Answer_Cd__c  ------' + PAs[1].PRM_Answer_Cd__c + ' :: PRM_Profile_Questions_Id__r.PRM_Question_Cd__c :: ' + PAs[1].PRM_Profile_Questions_Id__r.PRM_Question_Cd__c);
        system.debug('----- PAs[2] + PRM_Answer_Cd__c  ------' + PAs[2].PRM_Answer_Cd__c + ' :: PRM_Profile_Questions_Id__r.PRM_Question_Cd__c :: ' + PAs[2].PRM_Profile_Questions_Id__r.PRM_Question_Cd__c);
        system.debug('----- PAs[3] + PRM_Answer_Cd__c  ------' + PAs[3].PRM_Answer_Cd__c + ' :: PRM_Profile_Questions_Id__r.PRM_Question_Cd__c :: ' + PAs[3].PRM_Profile_Questions_Id__r.PRM_Question_Cd__c);
        system.debug('----- PAs Size ------' + PAs.size());
        
        List<PRM_Profile_Responses__c> ProfileResponses = new List<PRM_Profile_Responses__c>();
        PRM_Profile_Responses__c ProfileResponse = new PRM_Profile_Responses__c(
            PRM_Account_Id__c = newAccount.Id,
            PRM_Contact_Id__c = cont.id,
            PRM_Profile_Questions_Id__c = profileQstns[0].id,
            PRM_Profile_Answer_Id__c = [SELECT Id from PRM_Profile_Answer__c where PRM_Answer_Cd__c = 'PA-000021' LIMIT 1].id,
            //PRM_Response_Txt__c = 'test Response',
            PRM_InActive_Ind__c = false);
        ProfileResponses.add(ProfileResponse);
        system.debug('-----ProfileResponses ----' + ProfileResponses);
        ProfileResponse = new PRM_Profile_Responses__c(
            PRM_Account_Id__c = newAccount.Id,
            PRM_Contact_Id__c = cont.id,
            PRM_Profile_Questions_Id__c = profileQstns[1].id,
            PRM_Profile_Answer_Id__c = [SELECT Id from PRM_Profile_Answer__c where PRM_Answer_Cd__c = 'PA-000023' LIMIT 1].Id,
            //PRM_Response_Txt__c = 'test Response',
            PRM_InActive_Ind__c = false);                
        
        ProfileResponses.add(ProfileResponse);        
        insert ProfileResponses;
        system.debug('-----After Insert ProfileResponses ----' + ProfileResponses);
        List<PRM_Profile_Responses__c> ProfileResponsesList = [select PRM_Contact_Id__c,PRM_Account_Id__c,PRM_Profile_Questions_Id__c, PRM_Profile_Questions_Id__r.PRM_Question_Cd__c,PRM_Profile_Answer_Id__r.PRM_Answer_Cd__c, PRM_Profile_Answer_Id__c,PRM_Response_Txt__c,PRM_InActive_Ind__c from PRM_Profile_Responses__c 
                                                               where PRM_Account_Id__c=:newAccount.Id];
        System.debug('ProfileResponsesList ' + ProfileResponsesList.size());       
        //System.debug('ProfileResponsesList ' + ProfileResponsesList);
        System.assertEquals(2, ProfileResponsesList.size());      
        System.assertEquals('PQ-000020', ProfileResponsesList[0].PRM_Profile_Questions_Id__r.PRM_Question_Cd__c);
        System.assertEquals('PQ-000021', ProfileResponsesList[1].PRM_Profile_Questions_Id__r.PRM_Question_Cd__c);
        System.assertEquals('PA-000021', ProfileResponsesList[0].PRM_Profile_Answer_Id__r.PRM_Answer_Cd__c);
        System.assertEquals('PA-000023', ProfileResponsesList[1].PRM_Profile_Answer_Id__r.PRM_Answer_Cd__c);
        
        List<Core_IntegrationUtility.eRPM_Profile_Response> erpmProfileResponses = new List<Core_IntegrationUtility.eRPM_Profile_Response>();
        Core_IntegrationUtility.eRPM_Profile_Response ePR = new Core_IntegrationUtility.eRPM_Profile_Response(); 
        ePR = new Core_IntegrationUtility.eRPM_Profile_Response();
        ePR.eRPM_QuestionCode ='PQ-000020';
        ePR.eRPM_ResponseCode ='PA-000022';
        //ePR.eRPM_ResponseText ='test Response';
        erpmProfileResponses.add(ePR);
        //system.debug('erpmProfileResponses   :: ' + erpmProfileResponses); 
        
        ePR = new Core_IntegrationUtility.eRPM_Profile_Response();
        ePR.eRPM_QuestionCode ='PQ-000021';
        ePR.eRPM_ResponseCode ='PA-000024';
        // ePR.eRPM_ResponseText ='test Response';
        erpmProfileResponses.add(ePR);
        
        system.debug('------ erpmProfileResponses   :: ' + erpmProfileResponses);        
        System.assertEquals(true, new Core_Integration_Additional_Attributes(newAccount.Id,cont.Id,cp.PRM_programCode__c,null,null,null,null,null,null).SetProfileResponses(erpmProfileResponses));
        
        List<PRM_Profile_Responses__c> ProfileResponsesListUpdate = [select PRM_Contact_Id__c,PRM_Account_Id__c,PRM_Profile_Questions_Id__r.PRM_Question_Cd__c,PRM_Profile_Answer_Id__r.PRM_Answer_Cd__c, PRM_InActive_Ind__c from PRM_Profile_Responses__c 
                                                                     where PRM_Account_Id__c=:newAccount.Id];
        System.debug('ProfileResponsesListUpdate ' + ProfileResponsesListUpdate.size());       
        //System.debug('ProfileResponsesList ' + ProfileResponsesList);
        System.assertEquals(2, ProfileResponsesList.size());      
        System.assertEquals('PQ-000020', ProfileResponsesListUpdate[0].PRM_Profile_Questions_Id__r.PRM_Question_Cd__c);
        System.assertEquals('PQ-000021', ProfileResponsesListUpdate[1].PRM_Profile_Questions_Id__r.PRM_Question_Cd__c);
        System.assertEquals('PA-000022', ProfileResponsesListUpdate[0].PRM_Profile_Answer_Id__r.PRM_Answer_Cd__c);
        System.assertEquals('PA-000024', ProfileResponsesListUpdate[1].PRM_Profile_Answer_Id__r.PRM_Answer_Cd__c);
    }
    
    @isTest static void SetProfileResponses_BooleanQuestionType(){              
        system.debug('////-----SetProfileResponses_ValidData-----////');
        Account newAccount = GetAccount('UnitTestCasesAccount42');
        Contact cont = GetContact('silam.munusamy@test42.com');
        ChannelProgram cp = GetChannelProgram('IPA');
        //Validate Program Code
        //system.debug('Before Validating Channel Program');
        List<PRM_Profile_Questions__c> profileQstns = CreateProfileQuestions(cp.id,new List<string>{'PQ-000020', 'PQ-000021'});                 
        profileQstns[0].PRM_Question_Type_Nm__c = 'Boolean';
        profileQstns[1].PRM_Question_Type_Nm__c = 'Boolean';
        update profileQstns;
        CreateProfileAnswers(profileQstns[0].Id, new List<string> { 'PA-000021','PA-000022'});
        CreateProfileAnswers(profileQstns[1].Id, new List<string> { 'PA-000023','PA-000024'});               
        system.debug('-----Test method ---- profileQstns ----- ::: '+ profileQstns);             
        system.debug('-----Test method ---- profileQstns.size ----- ::: '+ profileQstns.size());
        List<PRM_Profile_Answer__c> PAs = [SELECT Id,PRM_Answer_Cd__c,PRM_Profile_Questions_Id__r.PRM_Question_Cd__c from PRM_Profile_Answer__c where PRM_Answer_Cd__c In ('PA-000021','PA-000022', 'PA-000023','PA-000024') ORDER BY PRM_Answer_Cd__c ASC];
        system.debug('----- PAs ------' + PAs);
        
        system.debug('----- PAs[0] + PRM_Answer_Cd__c  ------' + PAs[0].PRM_Answer_Cd__c + ' :: PRM_Profile_Questions_Id__r.PRM_Question_Cd__c :: ' + PAs[0].PRM_Profile_Questions_Id__r.PRM_Question_Cd__c);
        system.debug('----- PAs[1] + PRM_Answer_Cd__c  ------' + PAs[1].PRM_Answer_Cd__c + ' :: PRM_Profile_Questions_Id__r.PRM_Question_Cd__c :: ' + PAs[1].PRM_Profile_Questions_Id__r.PRM_Question_Cd__c);
        system.debug('----- PAs[2] + PRM_Answer_Cd__c  ------' + PAs[2].PRM_Answer_Cd__c + ' :: PRM_Profile_Questions_Id__r.PRM_Question_Cd__c :: ' + PAs[2].PRM_Profile_Questions_Id__r.PRM_Question_Cd__c);
        system.debug('----- PAs[3] + PRM_Answer_Cd__c  ------' + PAs[3].PRM_Answer_Cd__c + ' :: PRM_Profile_Questions_Id__r.PRM_Question_Cd__c :: ' + PAs[3].PRM_Profile_Questions_Id__r.PRM_Question_Cd__c);
        system.debug('----- PAs Size ------' + PAs.size());
        
        List<PRM_Profile_Responses__c> ProfileResponses = new List<PRM_Profile_Responses__c>();
        PRM_Profile_Responses__c ProfileResponse = new PRM_Profile_Responses__c(
            PRM_Account_Id__c = newAccount.Id,
            PRM_Contact_Id__c = cont.id,
            PRM_Profile_Questions_Id__c = profileQstns[0].id,
            PRM_Profile_Answer_Id__c = [SELECT Id from PRM_Profile_Answer__c where PRM_Answer_Cd__c = 'PA-000021' LIMIT 1].id,
            //PRM_Response_Txt__c = 'test Response',
            PRM_InActive_Ind__c = false);
        ProfileResponses.add(ProfileResponse);
        system.debug('-----ProfileResponses ----' + ProfileResponses);
        ProfileResponse = new PRM_Profile_Responses__c(
            PRM_Account_Id__c = newAccount.Id,
            PRM_Contact_Id__c = cont.id,
            PRM_Profile_Questions_Id__c = profileQstns[1].id,
            PRM_Profile_Answer_Id__c = [SELECT Id from PRM_Profile_Answer__c where PRM_Answer_Cd__c = 'PA-000023' LIMIT 1].Id,
            //PRM_Response_Txt__c = 'test Response',
            PRM_InActive_Ind__c = false);                
        
        ProfileResponses.add(ProfileResponse);        
        insert ProfileResponses;
        system.debug('-----After Insert ProfileResponses ----' + ProfileResponses);
        List<PRM_Profile_Responses__c> ProfileResponsesList = [select PRM_Contact_Id__c,PRM_Account_Id__c,PRM_Profile_Questions_Id__c, PRM_Profile_Questions_Id__r.PRM_Question_Cd__c,PRM_Profile_Answer_Id__r.PRM_Answer_Cd__c, PRM_Profile_Answer_Id__c,PRM_Response_Txt__c,PRM_InActive_Ind__c from PRM_Profile_Responses__c 
                                                               where PRM_Account_Id__c=:newAccount.Id];
        System.debug('ProfileResponsesList ' + ProfileResponsesList.size());       
        //System.debug('ProfileResponsesList ' + ProfileResponsesList);
        System.assertEquals(2, ProfileResponsesList.size());      
        System.assertEquals('PQ-000020', ProfileResponsesList[0].PRM_Profile_Questions_Id__r.PRM_Question_Cd__c);
        System.assertEquals('PQ-000021', ProfileResponsesList[1].PRM_Profile_Questions_Id__r.PRM_Question_Cd__c);
        System.assertEquals('PA-000021', ProfileResponsesList[0].PRM_Profile_Answer_Id__r.PRM_Answer_Cd__c);
        System.assertEquals('PA-000023', ProfileResponsesList[1].PRM_Profile_Answer_Id__r.PRM_Answer_Cd__c);
        
        List<Core_IntegrationUtility.eRPM_Profile_Response> erpmProfileResponses = new List<Core_IntegrationUtility.eRPM_Profile_Response>();
        Core_IntegrationUtility.eRPM_Profile_Response ePR = new Core_IntegrationUtility.eRPM_Profile_Response(); 
        ePR = new Core_IntegrationUtility.eRPM_Profile_Response();
        ePR.eRPM_QuestionCode ='PQ-000020';
        ePR.eRPM_ResponseCode ='PA-000022';
        //ePR.eRPM_ResponseText ='test Response';
        erpmProfileResponses.add(ePR);
        //system.debug('erpmProfileResponses   :: ' + erpmProfileResponses); 
        
        ePR = new Core_IntegrationUtility.eRPM_Profile_Response();
        ePR.eRPM_QuestionCode ='PQ-000021';
        ePR.eRPM_ResponseCode ='PA-000024';
        // ePR.eRPM_ResponseText ='test Response';
        erpmProfileResponses.add(ePR);
        
        system.debug('------ erpmProfileResponses   :: ' + erpmProfileResponses);        
        System.assertEquals(true, new Core_Integration_Additional_Attributes(newAccount.Id,cont.Id,cp.PRM_programCode__c,null,null,null,null,null,null).SetProfileResponses(erpmProfileResponses));
        
        List<PRM_Profile_Responses__c> ProfileResponsesListUpdate = [select PRM_Contact_Id__c,PRM_Account_Id__c,PRM_Profile_Questions_Id__r.PRM_Question_Cd__c,PRM_Profile_Answer_Id__r.PRM_Answer_Cd__c, PRM_InActive_Ind__c from PRM_Profile_Responses__c 
                                                                     where PRM_Account_Id__c=:newAccount.Id];
        System.debug('ProfileResponsesListUpdate ' + ProfileResponsesListUpdate.size());       
        //System.debug('ProfileResponsesList ' + ProfileResponsesList);
        System.assertEquals(2, ProfileResponsesList.size());      
        System.assertEquals('PQ-000020', ProfileResponsesListUpdate[0].PRM_Profile_Questions_Id__r.PRM_Question_Cd__c);
        System.assertEquals('PQ-000021', ProfileResponsesListUpdate[1].PRM_Profile_Questions_Id__r.PRM_Question_Cd__c);
        System.assertEquals('PA-000022', ProfileResponsesListUpdate[0].PRM_Profile_Answer_Id__r.PRM_Answer_Cd__c);
        System.assertEquals('PA-000024', ProfileResponsesListUpdate[1].PRM_Profile_Answer_Id__r.PRM_Answer_Cd__c);
    }
    
    @isTest static void SetProfileResponses_BooleanPickListQuestionTypes(){              
        system.debug('////-----SetProfileResponses_ValidData-----////');
        Account newAccount = GetAccount('UnitTestCasesAccount42');
        Contact cont = GetContact('silam.munusamy@test42.com');
        ChannelProgram cp = GetChannelProgram('IPA');
        //Validate Program Code
        //system.debug('Before Validating Channel Program');
        List<PRM_Profile_Questions__c> profileQstns = CreateProfileQuestions(cp.id,new List<string>{'PQ-000020', 'PQ-000021'});                 
        profileQstns[0].PRM_Question_Type_Nm__c = 'Boolean';
        profileQstns[1].PRM_Question_Type_Nm__c = 'Picklist';
        update profileQstns;
        CreateProfileAnswers(profileQstns[0].Id, new List<string> { 'PA-000021','PA-000022'});
        CreateProfileAnswers(profileQstns[1].Id, new List<string> { 'PA-000023','PA-000024'});               
        system.debug('-----Test method ---- profileQstns ----- ::: '+ profileQstns);             
        system.debug('-----Test method ---- profileQstns.size ----- ::: '+ profileQstns.size());
        List<PRM_Profile_Answer__c> PAs = [SELECT Id,PRM_Answer_Cd__c,PRM_Profile_Questions_Id__r.PRM_Question_Cd__c from PRM_Profile_Answer__c where PRM_Answer_Cd__c In ('PA-000021','PA-000022', 'PA-000023','PA-000024') ORDER BY PRM_Answer_Cd__c ASC];
        system.debug('----- PAs ------' + PAs);
        
        system.debug('----- PAs[0] + PRM_Answer_Cd__c  ------' + PAs[0].PRM_Answer_Cd__c + ' :: PRM_Profile_Questions_Id__r.PRM_Question_Cd__c :: ' + PAs[0].PRM_Profile_Questions_Id__r.PRM_Question_Cd__c);
        system.debug('----- PAs[1] + PRM_Answer_Cd__c  ------' + PAs[1].PRM_Answer_Cd__c + ' :: PRM_Profile_Questions_Id__r.PRM_Question_Cd__c :: ' + PAs[1].PRM_Profile_Questions_Id__r.PRM_Question_Cd__c);
        system.debug('----- PAs[2] + PRM_Answer_Cd__c  ------' + PAs[2].PRM_Answer_Cd__c + ' :: PRM_Profile_Questions_Id__r.PRM_Question_Cd__c :: ' + PAs[2].PRM_Profile_Questions_Id__r.PRM_Question_Cd__c);
        system.debug('----- PAs[3] + PRM_Answer_Cd__c  ------' + PAs[3].PRM_Answer_Cd__c + ' :: PRM_Profile_Questions_Id__r.PRM_Question_Cd__c :: ' + PAs[3].PRM_Profile_Questions_Id__r.PRM_Question_Cd__c);
        system.debug('----- PAs Size ------' + PAs.size());
        
        List<PRM_Profile_Responses__c> ProfileResponses = new List<PRM_Profile_Responses__c>();
        PRM_Profile_Responses__c ProfileResponse = new PRM_Profile_Responses__c(
            PRM_Account_Id__c = newAccount.Id,
            PRM_Contact_Id__c = cont.id,
            PRM_Profile_Questions_Id__c = profileQstns[0].id,
            PRM_Profile_Answer_Id__c = [SELECT Id from PRM_Profile_Answer__c where PRM_Answer_Cd__c = 'PA-000021' LIMIT 1].id,
            //PRM_Response_Txt__c = 'test Response',
            PRM_InActive_Ind__c = false);
        ProfileResponses.add(ProfileResponse);
        system.debug('-----ProfileResponses ----' + ProfileResponses);
        ProfileResponse = new PRM_Profile_Responses__c(
            PRM_Account_Id__c = newAccount.Id,
            PRM_Contact_Id__c = cont.id,
            PRM_Profile_Questions_Id__c = profileQstns[1].id,
            PRM_Profile_Answer_Id__c = [SELECT Id from PRM_Profile_Answer__c where PRM_Answer_Cd__c = 'PA-000023' LIMIT 1].Id,
            //PRM_Response_Txt__c = 'test Response',
            PRM_InActive_Ind__c = false);                
        
        ProfileResponses.add(ProfileResponse);        
        insert ProfileResponses;
        system.debug('-----After Insert ProfileResponses ----' + ProfileResponses);
        List<PRM_Profile_Responses__c> ProfileResponsesList = [select PRM_Contact_Id__c,PRM_Account_Id__c,PRM_Profile_Questions_Id__c, PRM_Profile_Questions_Id__r.PRM_Question_Cd__c,PRM_Profile_Answer_Id__r.PRM_Answer_Cd__c, PRM_Profile_Answer_Id__c,PRM_Response_Txt__c,PRM_InActive_Ind__c from PRM_Profile_Responses__c 
                                                               where PRM_Account_Id__c=:newAccount.Id];
        System.debug('ProfileResponsesList ' + ProfileResponsesList.size());       
        //System.debug('ProfileResponsesList ' + ProfileResponsesList);
        System.assertEquals(2, ProfileResponsesList.size());      
        System.assertEquals('PQ-000020', ProfileResponsesList[0].PRM_Profile_Questions_Id__r.PRM_Question_Cd__c);
        System.assertEquals('PQ-000021', ProfileResponsesList[1].PRM_Profile_Questions_Id__r.PRM_Question_Cd__c);
        System.assertEquals('PA-000021', ProfileResponsesList[0].PRM_Profile_Answer_Id__r.PRM_Answer_Cd__c);
        System.assertEquals('PA-000023', ProfileResponsesList[1].PRM_Profile_Answer_Id__r.PRM_Answer_Cd__c);
        
        List<Core_IntegrationUtility.eRPM_Profile_Response> erpmProfileResponses = new List<Core_IntegrationUtility.eRPM_Profile_Response>();
        Core_IntegrationUtility.eRPM_Profile_Response ePR = new Core_IntegrationUtility.eRPM_Profile_Response(); 
        ePR = new Core_IntegrationUtility.eRPM_Profile_Response();
        ePR.eRPM_QuestionCode ='PQ-000020';
        ePR.eRPM_ResponseCode ='PA-000022';
        //ePR.eRPM_ResponseText ='test Response';
        erpmProfileResponses.add(ePR);
        //system.debug('erpmProfileResponses   :: ' + erpmProfileResponses); 
        
        ePR = new Core_IntegrationUtility.eRPM_Profile_Response();
        ePR.eRPM_QuestionCode ='PQ-000021';
        ePR.eRPM_ResponseCode ='PA-000024';
        // ePR.eRPM_ResponseText ='test Response';
        erpmProfileResponses.add(ePR);
        
        system.debug('------ erpmProfileResponses   :: ' + erpmProfileResponses);        
        System.assertEquals(true, new Core_Integration_Additional_Attributes(newAccount.Id,cont.Id,cp.PRM_programCode__c,null,null,null,null,null,null).SetProfileResponses(erpmProfileResponses));
        
        List<PRM_Profile_Responses__c> ProfileResponsesListUpdate = [select PRM_Contact_Id__c,PRM_Account_Id__c,PRM_Profile_Questions_Id__r.PRM_Question_Cd__c,PRM_Profile_Answer_Id__r.PRM_Answer_Cd__c, PRM_InActive_Ind__c from PRM_Profile_Responses__c 
                                                                     where PRM_Account_Id__c=:newAccount.Id];
        System.debug('ProfileResponsesListUpdate ' + ProfileResponsesListUpdate.size());       
        //System.debug('ProfileResponsesList ' + ProfileResponsesList);
        System.assertEquals(2, ProfileResponsesList.size());      
        System.assertEquals('PQ-000020', ProfileResponsesListUpdate[0].PRM_Profile_Questions_Id__r.PRM_Question_Cd__c);
        System.assertEquals('PQ-000021', ProfileResponsesListUpdate[1].PRM_Profile_Questions_Id__r.PRM_Question_Cd__c);
        System.assertEquals('PA-000022', ProfileResponsesListUpdate[0].PRM_Profile_Answer_Id__r.PRM_Answer_Cd__c);
        System.assertEquals('PA-000024', ProfileResponsesListUpdate[1].PRM_Profile_Answer_Id__r.PRM_Answer_Cd__c);
    }
    
    @isTest static void SetProfileResponses_MultiSelectQuestionType_Add(){              
        system.debug('////-----SetProfileResponses_ValidData-----////');
        Account newAccount = GetAccount('UnitTestCasesAccount42');
        Contact cont = GetContact('silam.munusamy@test42.com');
        ChannelProgram cp = GetChannelProgram('IPA');
        //Validate Program Code
        //system.debug('Before Validating Channel Program');
        List<PRM_Profile_Questions__c> profileQstns = CreateProfileQuestions(cp.id,new List<string>{'PQ-000020', 'PQ-000021'});                 
        profileQstns[0].PRM_Question_Type_Nm__c = 'Multiselect';
        profileQstns[1].PRM_Question_Type_Nm__c = 'Multiselect';
        update profileQstns;
        CreateProfileAnswers(profileQstns[0].Id, new List<string> { 'PA-000021','PA-000022', 'PA-000023','PA-000024'});
        CreateProfileAnswers(profileQstns[1].Id, new List<string> { 'PA-000021','PA-000022', 'PA-000023','PA-000024'});               
        system.debug('-----Test method ---- profileQstns ----- ::: '+ profileQstns);             
        system.debug('-----Test method ---- profileQstns.size ----- ::: '+ profileQstns.size());
        
        List<PRM_Profile_Responses__c> ProfileResponses = new List<PRM_Profile_Responses__c>();
        
        PRM_Profile_Responses__c ProfileResponse = new PRM_Profile_Responses__c(
            PRM_Account_Id__c = newAccount.Id,
            PRM_Contact_Id__c = cont.id,
            PRM_Profile_Questions_Id__c = profileQstns[0].id,
            PRM_Profile_Answer_Id__c = [SELECT Id from PRM_Profile_Answer__c where PRM_Answer_Cd__c = 'PA-000021' LIMIT 1].id,
            //PRM_Response_Txt__c = 'test Response',
            PRM_InActive_Ind__c = false);
        ProfileResponses.add(ProfileResponse);       
        ProfileResponse = new PRM_Profile_Responses__c(
            PRM_Account_Id__c = newAccount.Id,
            PRM_Contact_Id__c = cont.id,
            PRM_Profile_Questions_Id__c = profileQstns[0].id,
            PRM_Profile_Answer_Id__c = [SELECT Id from PRM_Profile_Answer__c where PRM_Answer_Cd__c = 'PA-000022' LIMIT 1].Id,
            //PRM_Response_Txt__c = 'test Response',
            PRM_InActive_Ind__c = false);                             
        ProfileResponses.add(ProfileResponse);                             
        ProfileResponse = new PRM_Profile_Responses__c(
            PRM_Account_Id__c = newAccount.Id,
            PRM_Contact_Id__c = cont.id,
            PRM_Profile_Questions_Id__c = profileQstns[1].id,
            PRM_Profile_Answer_Id__c = [SELECT Id from PRM_Profile_Answer__c where PRM_Answer_Cd__c = 'PA-000023' LIMIT 1].Id,
            //PRM_Response_Txt__c = 'test Response',
            PRM_InActive_Ind__c = false);
        ProfileResponses.add(ProfileResponse);
        ProfileResponse = new PRM_Profile_Responses__c(
            PRM_Account_Id__c = newAccount.Id,
            PRM_Contact_Id__c = cont.id,
            PRM_Profile_Questions_Id__c = profileQstns[1].id,
            PRM_Profile_Answer_Id__c = [SELECT Id from PRM_Profile_Answer__c where PRM_Answer_Cd__c = 'PA-000024' LIMIT 1].Id,
            //PRM_Response_Txt__c = 'test Response',
            PRM_InActive_Ind__c = false);        
        ProfileResponses.add(ProfileResponse); 
        system.debug('-----Before Insert ProfileResponses ----' + ProfileResponses.size());
        insert ProfileResponses;
        system.debug('-----After Insert ProfileResponses ----' + ProfileResponses.size());
        List<PRM_Profile_Responses__c> ProfileResponsesList = [select PRM_Contact_Id__c,PRM_Account_Id__c,PRM_Profile_Questions_Id__c, PRM_Profile_Questions_Id__r.PRM_Question_Cd__c,PRM_Profile_Answer_Id__r.PRM_Answer_Cd__c, PRM_Profile_Answer_Id__c,PRM_Response_Txt__c,PRM_InActive_Ind__c from PRM_Profile_Responses__c 
                                                               where PRM_Account_Id__c=:newAccount.Id ORDER BY PRM_Profile_Questions_Id__r.PRM_Question_Cd__c ASC];
        System.debug('ProfileResponsesList ' + ProfileResponsesList.size());  
        System.debug('ProfileResponsesList ' + ProfileResponsesList[0]);
        System.debug('ProfileResponsesList ' + ProfileResponsesList[1]);
        System.debug('ProfileResponsesList ' + ProfileResponsesList[2]);
        //System.debug('ProfileResponsesList ' + ProfileResponsesList[3]);
        //System.debug('ProfileResponsesList ' + ProfileResponsesList);
        
        System.assertEquals('PQ-000020', ProfileResponsesList[0].PRM_Profile_Questions_Id__r.PRM_Question_Cd__c);        
        System.assertEquals('PA-000021', ProfileResponsesList[0].PRM_Profile_Answer_Id__r.PRM_Answer_Cd__c);
        System.assertEquals('PA-000022', ProfileResponsesList[1].PRM_Profile_Answer_Id__r.PRM_Answer_Cd__c);
        
        System.assertEquals('PQ-000021', ProfileResponsesList[2].PRM_Profile_Questions_Id__r.PRM_Question_Cd__c);
        System.assertEquals('PA-000023', ProfileResponsesList[2].PRM_Profile_Answer_Id__r.PRM_Answer_Cd__c);
        System.assertEquals('PA-000024', ProfileResponsesList[3].PRM_Profile_Answer_Id__r.PRM_Answer_Cd__c);
        
        List<Core_IntegrationUtility.eRPM_Profile_Response> erpmProfileResponses = new List<Core_IntegrationUtility.eRPM_Profile_Response>();
        Core_IntegrationUtility.eRPM_Profile_Response ePR = new Core_IntegrationUtility.eRPM_Profile_Response(); 
        ePR = new Core_IntegrationUtility.eRPM_Profile_Response();
        ePR.eRPM_QuestionCode ='PQ-000020';
        ePR.eRPM_ResponseCode ='PA-000023';
        //ePR.eRPM_ResponseText ='test Response';
        erpmProfileResponses.add(ePR);
        
        ePR = new Core_IntegrationUtility.eRPM_Profile_Response();
        ePR.eRPM_QuestionCode ='PQ-000020';
        ePR.eRPM_ResponseCode ='PA-000024';
        //ePR.eRPM_ResponseText ='test Response';
        erpmProfileResponses.add(ePR);
        
        //system.debug('erpmProfileResponses   :: ' + erpmProfileResponses); 
        
        ePR = new Core_IntegrationUtility.eRPM_Profile_Response();
        ePR.eRPM_QuestionCode ='PQ-000021';
        ePR.eRPM_ResponseCode ='PA-000021';
        // ePR.eRPM_ResponseText ='test Response';
        erpmProfileResponses.add(ePR);
        
        ePR = new Core_IntegrationUtility.eRPM_Profile_Response();
        ePR.eRPM_QuestionCode ='PQ-000021';
        ePR.eRPM_ResponseCode ='PA-000022';
        // ePR.eRPM_ResponseText ='test Response';
        erpmProfileResponses.add(ePR);
        
        system.debug('------ erpmProfileResponses   :: ' + erpmProfileResponses);        
        System.assertEquals(true, new Core_Integration_Additional_Attributes(newAccount.Id,cont.Id,cp.PRM_programCode__c,null,null,null,null,null,null).SetProfileResponses(erpmProfileResponses));
        
        List<PRM_Profile_Responses__c> ProfileResponsesListUpdate = [select PRM_Contact_Id__c,PRM_Account_Id__c,PRM_Profile_Questions_Id__r.PRM_Question_Cd__c,PRM_Profile_Answer_Id__r.PRM_Answer_Cd__c, PRM_InActive_Ind__c from PRM_Profile_Responses__c 
                                                                     where PRM_Account_Id__c=:newAccount.Id ORDER BY PRM_Profile_Questions_Id__r.PRM_Question_Cd__c ASC];
        System.debug('ProfileResponsesListUpdate ' + ProfileResponsesListUpdate.size());       
        //System.debug('ProfileResponsesList ' + ProfileResponsesList);
        System.assertEquals(8, ProfileResponsesListUpdate.size());        
    }
    
    @isTest static void SetProfileResponses_MultiSelectQuestionType_Remove(){              
        system.debug('////-----SetProfileResponses_ValidData-----////');
        Account newAccount = GetAccount('UnitTestCasesAccount42');
        Contact cont = GetContact('silam.munusamy@test42.com');
        ChannelProgram cp = GetChannelProgram('IPA');
        //Validate Program Code
        //system.debug('Before Validating Channel Program');
        List<PRM_Profile_Questions__c> profileQstns = CreateProfileQuestions(cp.id,new List<string>{'PQ-000020', 'PQ-000021'});                 
        profileQstns[0].PRM_Question_Type_Nm__c = 'Multiselect';
        profileQstns[1].PRM_Question_Type_Nm__c = 'Multiselect';
        update profileQstns;
        CreateProfileAnswers(profileQstns[0].Id, new List<string> { 'PA-000021','PA-000022', 'PA-000023','PA-000024'});
        CreateProfileAnswers(profileQstns[1].Id, new List<string> { 'PA-000021','PA-000022', 'PA-000023','PA-000024'});               
        system.debug('-----Test method ---- profileQstns ----- ::: '+ profileQstns);             
        system.debug('-----Test method ---- profileQstns.size ----- ::: '+ profileQstns.size());
        
        List<PRM_Profile_Responses__c> ProfileResponses = new List<PRM_Profile_Responses__c>();
        
        PRM_Profile_Responses__c ProfileResponse = new PRM_Profile_Responses__c(
            PRM_Account_Id__c = newAccount.Id,
            PRM_Contact_Id__c = cont.id,
            PRM_Profile_Questions_Id__c = profileQstns[0].id,
            PRM_Profile_Answer_Id__c = [SELECT Id from PRM_Profile_Answer__c where PRM_Answer_Cd__c = 'PA-000021' LIMIT 1].id,
            //PRM_Response_Txt__c = 'test Response',
            PRM_InActive_Ind__c = false);
        ProfileResponses.add(ProfileResponse);       
        ProfileResponse = new PRM_Profile_Responses__c(
            PRM_Account_Id__c = newAccount.Id,
            PRM_Contact_Id__c = cont.id,
            PRM_Profile_Questions_Id__c = profileQstns[0].id,
            PRM_Profile_Answer_Id__c = [SELECT Id from PRM_Profile_Answer__c where PRM_Answer_Cd__c = 'PA-000022' LIMIT 1].Id,
            //PRM_Response_Txt__c = 'test Response',
            PRM_InActive_Ind__c = false);                             
        ProfileResponses.add(ProfileResponse);             
        
        ProfileResponse = new PRM_Profile_Responses__c(
            PRM_Account_Id__c = newAccount.Id,
            PRM_Contact_Id__c = cont.id,
            PRM_Profile_Questions_Id__c = profileQstns[1].id,
            PRM_Profile_Answer_Id__c = [SELECT Id from PRM_Profile_Answer__c where PRM_Answer_Cd__c = 'PA-000023' LIMIT 1].Id,
            //PRM_Response_Txt__c = 'test Response',
            PRM_InActive_Ind__c = false);
        ProfileResponses.add(ProfileResponse);
        ProfileResponse = new PRM_Profile_Responses__c(
            PRM_Account_Id__c = newAccount.Id,
            PRM_Contact_Id__c = cont.id,
            PRM_Profile_Questions_Id__c = profileQstns[1].id,
            PRM_Profile_Answer_Id__c = [SELECT Id from PRM_Profile_Answer__c where PRM_Answer_Cd__c = 'PA-000024' LIMIT 1].Id,
            //PRM_Response_Txt__c = 'test Response',
            PRM_InActive_Ind__c = false);        
        ProfileResponses.add(ProfileResponse); 
        system.debug('-----Before Insert ProfileResponses ----' + ProfileResponses.size());
        insert ProfileResponses;
        system.debug('-----After Insert ProfileResponses ----' + ProfileResponses.size());
        List<PRM_Profile_Responses__c> ProfileResponsesList = [select PRM_Contact_Id__c,PRM_Account_Id__c,PRM_Profile_Questions_Id__c, PRM_Profile_Questions_Id__r.PRM_Question_Cd__c,PRM_Profile_Answer_Id__r.PRM_Answer_Cd__c, PRM_Profile_Answer_Id__c,PRM_Response_Txt__c,PRM_InActive_Ind__c from PRM_Profile_Responses__c 
                                                               where PRM_Account_Id__c=:newAccount.Id ORDER BY PRM_Profile_Questions_Id__r.PRM_Question_Cd__c ASC];
        System.debug('ProfileResponsesList ' + ProfileResponsesList.size());  
        System.debug('ProfileResponsesList ' + ProfileResponsesList[0]);
        System.debug('ProfileResponsesList ' + ProfileResponsesList[1]);
        System.debug('ProfileResponsesList ' + ProfileResponsesList[2]);
        System.assertEquals(4, ProfileResponsesList.size());
        
        List<Core_IntegrationUtility.eRPM_Profile_Response> erpmProfileResponses = new List<Core_IntegrationUtility.eRPM_Profile_Response>();
        Core_IntegrationUtility.eRPM_Profile_Response ePR = new Core_IntegrationUtility.eRPM_Profile_Response(); 
        ePR = new Core_IntegrationUtility.eRPM_Profile_Response();
        ePR.eRPM_QuestionCode ='PQ-000020';
        ePR.eRPM_ResponseCode ='PA-000023';
        //ePR.eRPM_ResponseText ='test Response';
        erpmProfileResponses.add(ePR);
        
        ePR = new Core_IntegrationUtility.eRPM_Profile_Response();
        ePR.eRPM_QuestionCode ='PQ-000020';
        ePR.eRPM_ResponseCode ='PA-000024';
        //ePR.eRPM_ResponseText ='test Response';
        erpmProfileResponses.add(ePR);
        
        //system.debug('erpmProfileResponses   :: ' + erpmProfileResponses); 
        
        ePR = new Core_IntegrationUtility.eRPM_Profile_Response();
        ePR.eRPM_QuestionCode ='PQ-000021';
        ePR.eRPM_ResponseCode ='PA-000021';
        // ePR.eRPM_ResponseText ='test Response';
        erpmProfileResponses.add(ePR);
        
        ePR = new Core_IntegrationUtility.eRPM_Profile_Response();
        ePR.eRPM_QuestionCode ='PQ-000021';
        ePR.eRPM_ResponseCode ='PA-000022';
        // ePR.eRPM_ResponseText ='test Response';
        erpmProfileResponses.add(ePR);
        
        system.debug('------ erpmProfileResponses   :: ' + erpmProfileResponses);        
        System.assertEquals(true, new Core_Integration_Additional_Attributes(newAccount.Id,cont.Id,cp.PRM_programCode__c,null,null,null,null,null,null).SetProfileResponses(erpmProfileResponses));
        
        List<PRM_Profile_Responses__c> ProfileResponsesListUpdate = [select PRM_Contact_Id__c,PRM_Account_Id__c,PRM_Profile_Questions_Id__r.PRM_Question_Cd__c,PRM_Profile_Answer_Id__r.PRM_Answer_Cd__c, PRM_InActive_Ind__c from PRM_Profile_Responses__c 
                                                                     where PRM_Account_Id__c=:newAccount.Id ORDER BY PRM_Profile_Questions_Id__r.PRM_Question_Cd__c, PRM_Profile_Answer_Id__r.PRM_Answer_Cd__c ASC];
        System.debug('ProfileResponsesListUpdate ' + ProfileResponsesListUpdate.size());       
        //System.debug('ProfileResponsesList ' + ProfileResponsesList);
        for(PRM_Profile_Responses__c PPR : ProfileResponsesListUpdate){
            System.debug('-------- PPR :::: Question Code :::  ' + PPR.PRM_Profile_Questions_Id__r.PRM_Question_Cd__c + ' :: Answer Code ::: ' + PPR.PRM_Profile_Answer_Id__r.PRM_Answer_Cd__c + ' :::: InActive Indicator ::: ' + PPR.PRM_InActive_Ind__c);
        }
        System.assertEquals(8, ProfileResponsesListUpdate.size());       
    }
    
    @isTest static void SetProfileResponses_CheckLimits() {
        Account newAccount = GetAccount('UnitTestCasesAccount42');
        Contact cont = GetContact('silam.munusamy@test42.com');
        ChannelProgram cp = GetChannelProgram('IPA');
        
        PRM_Profile_Questions__c profileQstn = [SELECT Id FROM  PRM_Profile_Questions__c
                                                WHERE PRM_Question_Cd__c ='PQ-000010' LIMIT 1];
        CreateBulkProfileAnswers(profileQstn.Id,'PA-000010-Bulk', 100);
        System.debug('Bulk responses added');
        List<Core_IntegrationUtility.eRPM_Profile_Response> erpmProfileResponses = new List<Core_IntegrationUtility.eRPM_Profile_Response>();
        for(integer i=1;i<=100;i++ ){
            Core_IntegrationUtility.eRPM_Profile_Response ePR = new Core_IntegrationUtility.eRPM_Profile_Response();
            ePR.eRPM_QuestionCode ='PQ-000010';
            ePR.eRPM_ResponseCode ='PA-000010-Bulk' +i ;
            ePR.eRPM_ResponseText ='test Response';
            erpmProfileResponses.add(ePR);
        }
        system.debug('erpmProfileResponses   :: ' + erpmProfileResponses[0]);  
        system.debug('erpmProfileResponses   :: ' + erpmProfileResponses[50]); 
        system.debug('erpmProfileResponses   :: ' + erpmProfileResponses[99]);
        
        System.assertEquals(true, new Core_Integration_Additional_Attributes(newAccount.Id,cont.Id,cp.PRM_programCode__c,null,null,null,null,null,null).SetProfileResponses(erpmProfileResponses)); 
        List<PRM_Profile_Responses__c> prflResponses = [SELECT Id FROM PRM_Profile_Responses__c
                                                        WHERE PRM_Profile_Questions_Id__r.PRM_Question_Cd__c = 'PQ-000010'];
        System.debug('prflResponses size :'+prflResponses.size());
        System.assertEquals(100,prflResponses.size());
    }
    
    @isTest static void SetProfileResponses_Exception(){              
        system.debug('////-----SetProfileResponses_Exception-----////');
        Account newAccount = GetAccount('UnitTestCasesAccount42');
        Contact cont = GetContact('silam.munusamy@test42.com');
        ChannelProgram cp = GetChannelProgram('IPA');
        //Validate Program Code
        //system.debug('Before Validating Channel Program');       
        List<Core_IntegrationUtility.eRPM_Profile_Response> erpmProfileResponses = new List<Core_IntegrationUtility.eRPM_Profile_Response>();
        Core_IntegrationUtility.eRPM_Profile_Response ePR = new Core_IntegrationUtility.eRPM_Profile_Response();
        //ePR.eRPM_QuestionCode ='PQ-000010';
        //ePR.eRPM_ResponseCode ='PA-000010';
        ePR.eRPM_ResponseText ='test Response';
        erpmProfileResponses.add(ePR);
        system.debug('erpmProfileResponses   :: ' + erpmProfileResponses);   
        
        ePR = new Core_IntegrationUtility.eRPM_Profile_Response();
        //ePR.eRPM_QuestionCode ='PQ-000010';
        //ePR.eRPM_ResponseCode ='PA-000011';
        ePR.eRPM_ResponseText ='Service Department';
        erpmProfileResponses.add(ePR);
        system.debug('erpmProfileResponses   :: ' + erpmProfileResponses);                          
        
        system.debug('---Exception  Scenario ---');
        System.assertEquals(false, new Core_Integration_Additional_Attributes(newAccount.Id,cont.Id,cp.PRM_programCode__c,null,null,null,null,null,null).SetProfileResponses(erpmProfileResponses));        
    }
    
    @isTest static void SetProfileResponses_ValidAndInValidData(){              
        List<Core_IntegrationUtility.eRPM_Profile_Response> erpmProfileResponses = new List<Core_IntegrationUtility.eRPM_Profile_Response>();
        Core_IntegrationUtility.eRPM_Profile_Response ePR = new Core_IntegrationUtility.eRPM_Profile_Response();
        ePR.eRPM_QuestionCode ='PQ-000010xx'; //Invalid Question code
        ePR.eRPM_ResponseCode ='PA-000010';   //Valid Response
        ePR.eRPM_ResponseText ='test Response';
        erpmProfileResponses.add(ePR);
        system.debug('erpmProfileResponses   :: ' + erpmProfileResponses);   
        
        ePR = new Core_IntegrationUtility.eRPM_Profile_Response();
        ePR.eRPM_QuestionCode ='PQ-000010';  //Valid 
        ePR.eRPM_ResponseCode ='PA-000011xxx'; //Invalid Answer Code
        ePR.eRPM_ResponseText ='Service Department';
        erpmProfileResponses.add(ePR);
        system.debug('erpmProfileResponses   :: ' + erpmProfileResponses);   
        
        ePR = new Core_IntegrationUtility.eRPM_Profile_Response();
        ePR.eRPM_QuestionCode ='PQ-000011x'; //Invalid Question code
        ePR.eRPM_ResponseCode ='PA-000012x'; //Invalid Answer Code
        ePR.eRPM_ResponseText ='Bare Metal-as-a-Service';
        erpmProfileResponses.add(ePR);
        system.debug('erpmProfileResponses   :: ' + erpmProfileResponses);   
        
        //Both Valid Inputs
        ePR = new Core_IntegrationUtility.eRPM_Profile_Response();
        ePR.eRPM_QuestionCode ='PQ-000010';  //Valid Question Code
        ePR.eRPM_ResponseCode ='PA-000011'; //Valid Answer Code
        ePR.eRPM_ResponseText ='Service Department';
        erpmProfileResponses.add(ePR);
        system.debug('erpmProfileResponses   :: ' + erpmProfileResponses);   
        
        Account newAccount = GetAccount('UnitTestCasesAccount42');
        Contact cont = GetContact('silam.munusamy@test42.com');
        ChannelProgram cp = GetChannelProgram('IPA');
        system.debug('InValid  Set Profile Responses Scenario');
        System.assertEquals(true, new Core_Integration_Additional_Attributes(newAccount.Id,cont.Id,cp.PRM_programCode__c,null,null,null,null,null,null).SetProfileResponses(erpmProfileResponses));        
    }
    
    @isTest static void SetAccountContactRelationships(){               
        system.debug('NullOrEmptyPersonAccountRelationships Scenario'); 
        Account newAccount = GetAccount('UnitTestCasesAccount42');
        Contact cont = GetContact('silam.munusamy@test42.com');
        ChannelProgram cp = GetChannelProgram('IPA');
        System.assertEquals(false, new Core_Integration_Additional_Attributes(newAccount.Id,cont.Id,cp.PRM_programCode__c,null,null,null,null,null,null).SetPersonAccountRelationships(new List<Core_IntegrationUtility.ERPM_Person_Account_Relation>()));            
        
        List<Core_IntegrationUtility.ERPM_Person_Account_Relation> personAcctReltns = new List<Core_IntegrationUtility.ERPM_Person_Account_Relation>();
        Core_IntegrationUtility.ERPM_Person_Account_Relation reltn = new Core_IntegrationUtility.ERPM_Person_Account_Relation();
        reltn.relationCode ='RELTNWRKFR';
        reltn.inactiveIndicator = false;
        reltn.engagementCode = 'CSPx2';
        personAcctReltns.add(reltn);
        reltn = new Core_IntegrationUtility.ERPM_Person_Account_Relation();
        reltn.relationCode ='RELTNPRCTC';
        reltn.inactiveIndicator = false;
        reltn.engagementCode = 'CSPx2';
        personAcctReltns.add(reltn);
        reltn = new Core_IntegrationUtility.ERPM_Person_Account_Relation();
        reltn.relationCode ='RELTNACTAD';
        reltn.inactiveIndicator = false;
        reltn.engagementCode = 'CSPx2';
        personAcctReltns.add(reltn);
        
         List<PRM_Account_Contact_Relationship__c> acctContReltnbefore = [SELECT Id, PRM_Relationship_Id__r.PRM_Contact_Relationship_Cd__c , PRM_InActive_Ind__c
                                                                    FROM PRM_Account_Contact_Relationship__c
                                                                    WHERE PRM_Account_Id__c =:newAccount.Id AND PRM_Contact_Id__c =:cont.Id
                                                                    ORDER BY PRM_Relationship_Id__r.PRM_Contact_Relationship_Cd__c ASC];  
        system.debug('acctContReltnbefore'+acctContReltnbefore);
        
        system.debug('---Valid  Scenario ---');           
        System.assertEquals(true, new Core_Integration_Additional_Attributes(newAccount.Id,cont.Id,cp.PRM_programCode__c,null,null,null,null,null,null).SetPersonAccountRelationships(personAcctReltns));
        List<PRM_Account_Contact_Relationship__c> acctContReltns = [SELECT Id, PRM_Relationship_Id__r.PRM_Contact_Relationship_Cd__c , PRM_InActive_Ind__c,PRM_Contact_Id__c
                                                                    FROM PRM_Account_Contact_Relationship__c
                                                                    WHERE PRM_Account_Id__c =:newAccount.Id AND PRM_Contact_Id__c =:cont.Id
                                                                    ORDER BY PRM_Relationship_Id__r.PRM_Contact_Relationship_Cd__c ASC];    
        
        System.Debug('acctContReltns'+acctContReltns);
        System.assertEquals(2, acctContReltns.size());
        System.assertEquals(false, acctContReltns[0].PRM_InActive_Ind__c);
        System.assertEquals('PRIMARY', acctContReltns[0].PRM_Relationship_Id__r.PRM_Contact_Relationship_Cd__c);
        System.assertEquals(false, acctContReltns[1].PRM_InActive_Ind__c);
        System.assertEquals('WORKSFOR', acctContReltns[1].PRM_Relationship_Id__r.PRM_Contact_Relationship_Cd__c);
        system.debug('---Valid  Scenario ---');        
    }
    
    @isTest static void SetContactEntitlements_ISA(){        
        system.debug('SetContactEntitlements_ISA Scenario'); 
        Account newAccount = GetAccount('UnitTestCasesAccount42');
        Contact cont = GetContact('silam.munusamy@test42.com');
        ChannelProgram cp = GetChannelProgram('IPA');
        
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        
        
        
        //UserLicense ul = [SELECT Id FROM UserLicense WHERE Name = 'Partner Community' LIMIT 1];
               
        //Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Partner' AND UserLicenseId =: ul.Id LIMIT 1];
        //UserRole ur = new UserRole(Name = 'Admin');
        //insert ur;
        
        
        System.runAs(thisUser){
            
        UserRole ur = [Select PortalType, PortalAccountId From UserRole where PortalType =:'CustomerPortal' limit 1];
        UserLicense ul = [SELECT Id FROM UserLicense WHERE Name = 'Partner Community' LIMIT 1];
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Partner' AND UserLicenseId =: ul.Id LIMIT 1];
        
        User usr = new User(LastName = 'LIVESTON',
                           FirstName='JASON',
                           UserRoleId = ur.Id,
                           Alias = 'jliv',
                           Email = 'silam.munusamy@test42.com',
                           Username = 'silam.munusamy@test42.com',
                           ProfileId = profileId.id,
                           TimeZoneSidKey = 'GMT',
                           LanguageLocaleKey = 'en_US',
                           EmailEncodingKey = 'UTF-8',
                           LocaleSidKey = 'en_US',
                            contactId = cont.Id
                            
                           );
            
            
        System.assertEquals(false, new Core_Integration_Additional_Attributes(newAccount.Id,cont.Id,cp.PRM_programCode__c,null,null,null,null,null,null).SetContactEntitlements(new List<Core_IntegrationUtility.ERPM_Person_Account>()));            
        
        List<Core_IntegrationUtility.ERPM_Person_Account_Relation> personAcctReltns = new List<Core_IntegrationUtility.ERPM_Person_Account_Relation>();
        Core_IntegrationUtility.ERPM_Person_Account_Relation reltn = new Core_IntegrationUtility.ERPM_Person_Account_Relation();
        reltn.relationCode ='RELTNWRKFR';//--Employee
        reltn.inactiveIndicator = false;
        reltn.engagementCode = 'ISA';
        personAcctReltns.add(reltn);
        reltn = new Core_IntegrationUtility.ERPM_Person_Account_Relation();
        reltn.relationCode ='RELTNPRCTC'; //--Partner Admin
        reltn.inactiveIndicator = false;
        reltn.engagementCode = 'ISA';
        personAcctReltns.add(reltn);
        reltn = new Core_IntegrationUtility.ERPM_Person_Account_Relation();
        reltn.relationCode ='RELTNACTAD';//--Partner Admin
        reltn.inactiveIndicator = false;
        reltn.engagementCode = 'ISA';
        personAcctReltns.add(reltn);
        system.debug('-------- Test Class ---personAcctReltns  ---' + personAcctReltns);  
        system.debug('---Valid  Scenario ---');  
        
       List<Core_IntegrationUtility.ERPM_Person_Account> eRPM_PersonAccounts = new List<Core_IntegrationUtility.ERPM_Person_Account>();
        Core_IntegrationUtility.ERPM_Person_Account prsnacct = new Core_IntegrationUtility.ERPM_Person_Account();
    prsnacct.erpmAccountNumber = '245467865';
    prsnacct.cimId             = '567345';
    prsnacct.accountName       = 'George Pvt Ltd';
    prsnacct.personAccountRelations=personAcctReltns;
        eRPM_PersonAccounts.add(prsnacct);
        
        //System.assertEquals(true, new Core_Integration_Additional_Attributes(newAccount.Id,cont.Id,cp.PRM_programCode__c,null,null,null,null,null,eRPM_PersonAccounts).SetContactEntitlements(eRPM_PersonAccounts));
        
        
        List<Core_Contact_Entitlement__c> contactEntitlements = [SELECT Core_Entitlement_Id__r.Name, Core_Selected__c, Core_Status__c
                                                                 FROM Core_Contact_Entitlement__c                                                                     
                                                                 WHERE Core_Contact_Id__c =: cont.Id
                                                                 ORDER BY Core_Entitlement_Id__r.Name ASC];
        
        system.debug('-------- Test Class successs ---contactEntitlements  ---' + contactEntitlements);        
       // System.assertEquals('Employee', contactEntitlements[0].Core_Entitlement_Id__r.Name);        
        //System.assertEquals('Partner Admin', contactEntitlements[1].Core_Entitlement_Id__r.Name);
        }
        }
    
    @isTest static void SetContactEntitlements_RemoveOrUpdate_ISA(){
        
        system.debug('SetContactEntitlements_ISA Scenario'); 
        Account newAccount = GetAccount('UnitTestCasesAccount42');
        Contact cont = GetContact('silam.munusamy@test42.com');        
        ChannelProgram cp = GetChannelProgram('IPA');        
        List<Core_IntegrationUtility.ERPM_Person_Account_Relation> personAcctReltns = new List<Core_IntegrationUtility.ERPM_Person_Account_Relation>();
        Core_IntegrationUtility.ERPM_Person_Account_Relation reltn = new Core_IntegrationUtility.ERPM_Person_Account_Relation();
        reltn.relationCode ='RELTNWRKFR';//--Employee        
        reltn.engagementCode = 'ISA';
        personAcctReltns.add(reltn);
        reltn = new Core_IntegrationUtility.ERPM_Person_Account_Relation();
        reltn.relationCode ='RELTNPRCTC'; //--Partner Admin       
        reltn.engagementCode = 'ISA';
        personAcctReltns.add(reltn);
      /*  reltn = new Core_IntegrationUtility.ERPM_Person_Account_Relation();
        reltn.relationCode ='RELTNACTAD';//--Partner Admin       
        reltn.engagementCode = 'ISA';
        personAcctReltns.add(reltn);*/
        system.debug('-------- Test Class ---personAcctReltns  ---' + personAcctReltns);  
        system.debug('---Valid  Scenario ---');           
         
        List<Core_IntegrationUtility.ERPM_Person_Account> eRPM_PersonAccounts = new List<Core_IntegrationUtility.ERPM_Person_Account>();
        Core_IntegrationUtility.ERPM_Person_Account prsnacct = new Core_IntegrationUtility.ERPM_Person_Account();
    prsnacct.erpmAccountNumber = '245467865';
    prsnacct.cimId             = '567345';
    prsnacct.accountName       = 'George Pvt Ltd';
    prsnacct.personAccountRelations=personAcctReltns;
        eRPM_PersonAccounts.add(prsnacct);
         
        System.assertEquals(true, new Core_Integration_Additional_Attributes(newAccount.Id,cont.Id,cp.PRM_programCode__c,null,null,null,null,null,eRPM_PersonAccounts).SetContactEntitlements(eRPM_PersonAccounts));
        
         List<Core_Contact_Entitlement__c> contactEntitlements = [SELECT Core_Entitlement_Id__r.Name, Core_Selected__c, Core_Status__c
                                                                 FROM Core_Contact_Entitlement__c                                                                     
                                                                 WHERE Core_Contact_Id__c =: cont.Id
                                                                 ORDER BY Core_Entitlement_Id__r.Name ASC];
        Test.startTest();
        system.debug('-------- Test Class successs ---contactEntitlements  ---' + contactEntitlements);        
        //System.assertEquals('Employee', contactEntitlements[0].Core_Entitlement_Id__r.Name);        
        //System.assertEquals('Partner Admin', contactEntitlements[1].Core_Entitlement_Id__r.Name);
        
        //Update Scenario --
        personAcctReltns = new List<Core_IntegrationUtility.ERPM_Person_Account_Relation>();
        reltn = new Core_IntegrationUtility.ERPM_Person_Account_Relation();
        reltn.relationCode ='RELTNWRKFR';//--Employee
        reltn.inactiveIndicator = false;
        reltn.engagementCode = 'ISA'; 
        personAcctReltns.add(reltn);        
        reltn = new Core_IntegrationUtility.ERPM_Person_Account_Relation();
        reltn.relationCode ='RELTNPRCTC';//--Partner Admin 
        reltn.inactiveIndicator = true;
        reltn.engagementCode = 'ISA';
        personAcctReltns.add(reltn);
        reltn = new Core_IntegrationUtility.ERPM_Person_Account_Relation();
        reltn.relationCode ='RELTNACTAD';//--Partner Admin       
        reltn.engagementCode = 'ISA';
        reltn.inactiveIndicator = true;
        personAcctReltns.add(reltn);
        system.debug('-------- Test Class ---personAcctReltns  ---' + personAcctReltns);  
        system.debug('---Valid  Scenario ---');         
        
    prsnacct.erpmAccountNumber = '245467864';
    prsnacct.cimId             = '567342';
    prsnacct.accountName       = 'George Pvt Ltd.';
    prsnacct.personAccountRelations=personAcctReltns;
        eRPM_PersonAccounts.add(prsnacct);
        
        System.assertEquals(true, new Core_Integration_Additional_Attributes(newAccount.Id,cont.Id,cp.PRM_programCode__c,null,null,null,null,null,eRPM_PersonAccounts).SetContactEntitlements(eRPM_PersonAccounts));
           Test.stopTest();
        List<Core_Contact_Entitlement__c> contactEntitlements1 = [SELECT Core_Entitlement_Id__r.Name, Core_Selected__c, Core_Status__c
                                                                  FROM Core_Contact_Entitlement__c                                                                     
                                                                  WHERE Core_Contact_Id__c =: cont.Id
                                                                  ORDER BY Core_Entitlement_Id__r.Name ASC];
        
       /* system.debug('-------- Test Class successs ---contactEntitlements1  ---' + contactEntitlements1);        
        System.assertEquals('Employee', contactEntitlements1[0].Core_Entitlement_Id__r.Name); 
        System.assertEquals(true, contactEntitlements1[0].Core_Selected__c);
        System.assertEquals('Partner Admin', contactEntitlements1[1].Core_Entitlement_Id__r.Name); 
        System.assertEquals(false, contactEntitlements1[1].Core_Selected__c);*/
    }        
    
    @isTest static void SetContactEntitlements_ITPISA(){
        
        system.debug('SetContactEntitlements_ISA Scenario'); 
        Account newAccount = GetAccount('UnitTestCasesAccount42');
        Contact cont = GetContact('silam.munusamy@test42.com');        
        ChannelProgram cp = GetChannelProgram('IPA');        
        //ISA + ITP relationship combination
        List<Core_IntegrationUtility.ERPM_Person_Account_Relation> personAcctReltns = new List<Core_IntegrationUtility.ERPM_Person_Account_Relation>();
        Core_IntegrationUtility.ERPM_Person_Account_Relation reltn = new Core_IntegrationUtility.ERPM_Person_Account_Relation();
        reltn.relationCode ='RELTNWRKFR';//--Employee        
        reltn.engagementCode = 'ITP';
        personAcctReltns.add(reltn);
        reltn = new Core_IntegrationUtility.ERPM_Person_Account_Relation();
        reltn.relationCode ='RELTNPRCTC'; //--Partner Admin       
        reltn.engagementCode = 'ISA';
        personAcctReltns.add(reltn);
        reltn = new Core_IntegrationUtility.ERPM_Person_Account_Relation();
        reltn.relationCode ='RELTNACTAD';//--Partner Admin       
        reltn.engagementCode = 'ITP';
        personAcctReltns.add(reltn);
        system.debug('-------- Test Class ---personAcctReltns  ---' + personAcctReltns);  
        system.debug('---Valid  Scenario ---');           
        
       List<Core_IntegrationUtility.ERPM_Person_Account> eRPM_PersonAccounts = new List<Core_IntegrationUtility.ERPM_Person_Account>();
        Core_IntegrationUtility.ERPM_Person_Account prsnacct = new Core_IntegrationUtility.ERPM_Person_Account();
    prsnacct.erpmAccountNumber = '245467865';
    prsnacct.cimId             = '567345';
    prsnacct.accountName       = 'George Pvt Ltd';
    prsnacct.personAccountRelations=personAcctReltns;
        eRPM_PersonAccounts.add(prsnacct);
        
        System.assertEquals(true, new Core_Integration_Additional_Attributes(newAccount.Id,cont.Id,cp.PRM_programCode__c,null,null,null,null,null,eRPM_PersonAccounts).SetContactEntitlements(eRPM_PersonAccounts));
        
        
        List<Core_Contact_Entitlement__c> contactEntitlements = [SELECT Core_Entitlement_Id__r.Name, Core_Selected__c, Core_Status__c
                                                                 FROM Core_Contact_Entitlement__c                                                                     
                                                                 WHERE Core_Contact_Id__c =: cont.Id
                                                                 ORDER BY Core_Entitlement_Id__r.Name ASC];
        
        system.debug('-------- Test Class successs ---contactEntitlements  ---' + contactEntitlements);        
        //System.assertEquals('Employee', contactEntitlements[0].Core_Entitlement_Id__r.Name);        
        //System.assertEquals(0, contactEntitlements.size());              
        
    }
    
    @isTest static void SetContactEntitlements_ISA_InvalidEntilements(){
        
        system.debug('SetContactEntitlements_ISA Scenario'); 
        Account newAccount = GetAccount('UnitTestCasesAccount42');
        Contact cont = GetContact('silam.munusamy@test42.com');        
        ChannelProgram cp = GetChannelProgram('IPA');        
        //ISA + ITP relationship combination
        List<Core_IntegrationUtility.ERPM_Person_Account_Relation> personAcctReltns = new List<Core_IntegrationUtility.ERPM_Person_Account_Relation>();
        Core_IntegrationUtility.ERPM_Person_Account_Relation reltn = new Core_IntegrationUtility.ERPM_Person_Account_Relation();
        reltn.relationCode ='RELTNWRKFR11';//--Employee        
        reltn.engagementCode = 'ISA';
        personAcctReltns.add(reltn);
        reltn = new Core_IntegrationUtility.ERPM_Person_Account_Relation();
        reltn.relationCode ='RELTNPRCTC112'; //--Partner Admin       
        reltn.engagementCode = 'ISA';
        personAcctReltns.add(reltn);
        reltn = new Core_IntegrationUtility.ERPM_Person_Account_Relation();
        reltn.relationCode ='RELTNACTAD23';//--Partner Admin       
        reltn.engagementCode = 'ISA';
        personAcctReltns.add(reltn);
        system.debug('-------- Test Class ---personAcctReltns  ---' + personAcctReltns);  
        system.debug('---Valid  Scenario ---');           
         
        List<Core_IntegrationUtility.ERPM_Person_Account> eRPM_PersonAccounts = new List<Core_IntegrationUtility.ERPM_Person_Account>();
        Core_IntegrationUtility.ERPM_Person_Account prsnacct = new Core_IntegrationUtility.ERPM_Person_Account();
    prsnacct.erpmAccountNumber = '245467865';
    prsnacct.cimId             = '567345';
    prsnacct.accountName       = 'George Pvt Ltd';
    prsnacct.personAccountRelations=personAcctReltns;
        eRPM_PersonAccounts.add(prsnacct);
        
       // System.assertEquals(true, new Core_Integration_Additional_Attributes(newAccount.Id,cont.Id,cp.PRM_programCode__c,null,null,null,null,null,eRPM_PersonAccounts).SetContactEntitlements(eRPM_PersonAccounts));
        
        
        List<Core_Contact_Entitlement__c> contactEntitlements = [SELECT Core_Entitlement_Id__r.Name, Core_Selected__c, Core_Status__c
                                                                 FROM Core_Contact_Entitlement__c                                                                     
                                                                 WHERE Core_Contact_Id__c =: cont.Id
                                                                 ORDER BY Core_Entitlement_Id__r.Name ASC];
        
        system.debug('-------- Test Class successs ---contactEntitlements  ---' + contactEntitlements);        
        System.assertEquals(0, contactEntitlements.size());        
        //System.assertEquals('Partner Admin', contactEntitlements[1].Core_Entitlement_Id__r.Name);               
    }
    
    @isTest static void SetContactEntitlements_ISA_ValidAndInvalidEntilements(){
        
        system.debug('SetContactEntitlements_ISA Scenario'); 
        Account newAccount = GetAccount('UnitTestCasesAccount42');
        Contact cont = GetContact('silam.munusamy@test42.com');        
        ChannelProgram cp = GetChannelProgram('IPA');       
        //ISA + ITP relationship combination
        List<Core_IntegrationUtility.ERPM_Person_Account_Relation> personAcctReltns = new List<Core_IntegrationUtility.ERPM_Person_Account_Relation>();
        Core_IntegrationUtility.ERPM_Person_Account_Relation reltn = new Core_IntegrationUtility.ERPM_Person_Account_Relation();
        reltn.relationCode ='RELTNWRKFR';//--Employee        
        reltn.engagementCode = 'ISA';
        personAcctReltns.add(reltn);
        reltn = new Core_IntegrationUtility.ERPM_Person_Account_Relation();
        reltn.relationCode ='RELTNPRCTC112'; //--Partner Admin       
        reltn.engagementCode = 'ISA';
        personAcctReltns.add(reltn);
        reltn = new Core_IntegrationUtility.ERPM_Person_Account_Relation();
        reltn.relationCode ='RELTNACTAD23';//--Partner Admin       
        reltn.engagementCode = 'ISA';
        personAcctReltns.add(reltn);
        system.debug('-------- Test Class ---personAcctReltns  ---' + personAcctReltns);  
        system.debug('---Valid  Scenario ---');           
        
        List<Core_IntegrationUtility.ERPM_Engagement> personAccountEngmts = new List<Core_IntegrationUtility.ERPM_Engagement>();
    Core_IntegrationUtility.ERPM_Engagement erpmeng = new Core_IntegrationUtility.ERPM_Engagement();
    erpmeng.engagementCode       = 'General';       
        erpmeng.effectiveTierCode    = 'ISA';
    personAccountEngmts.add(erpmeng);   
        
        List<Core_IntegrationUtility.ERPM_Person_Account> eRPM_PersonAccounts = new List<Core_IntegrationUtility.ERPM_Person_Account>();
        Core_IntegrationUtility.ERPM_Person_Account prsnacct = new Core_IntegrationUtility.ERPM_Person_Account();
    prsnacct.erpmAccountNumber = '245467865';
    prsnacct.cimId             = '567345';
    prsnacct.accountName       = 'George Pvt Ltd';
    prsnacct.personAccountRelations=personAcctReltns;
        prsnacct.personAccountEngagements=personAccountEngmts;
        eRPM_PersonAccounts.add(prsnacct);
        
        
        System.assertEquals(true, new Core_Integration_Additional_Attributes(newAccount.Id,cont.Id,cp.PRM_programCode__c,null,null,null,null,null,eRPM_PersonAccounts).SetContactEntitlements(eRPM_PersonAccounts));
        
        
        List<Core_Contact_Entitlement__c> contactEntitlements = [SELECT Core_Entitlement_Id__r.Name, Core_Selected__c, Core_Status__c
                                                                 FROM Core_Contact_Entitlement__c                                                                     
                                                                 WHERE Core_Contact_Id__c =: cont.Id
                                                                 ORDER BY Core_Entitlement_Id__r.Name ASC];
        
        system.debug('-------- Test Class successs ---contactEntitlements  ---' + contactEntitlements);        
        //System.assertEquals(0, contactEntitlements.size());        
        System.assertEquals('Employee', contactEntitlements[0].Core_Entitlement_Id__r.Name);
        //System.assertEquals('IPA-MP User', contactEntitlements[1].Core_Entitlement_Id__r.Name); 
    }
    
    @isTest static void SetAccountContactRelationships_ISA(){               
        system.debug('NullOrEmptyPersonAccountRelationships Scenario'); 
        Account newAccount = GetAccount('UnitTestCasesAccount42');
        Contact cont = GetContact('silam.munusamy@test42.com');
        ChannelProgram cp = GetChannelProgram('IPA');               
        List<Core_IntegrationUtility.ERPM_Person_Account_Relation> personAcctReltns = new List<Core_IntegrationUtility.ERPM_Person_Account_Relation>();
        Core_IntegrationUtility.ERPM_Person_Account_Relation reltn = new Core_IntegrationUtility.ERPM_Person_Account_Relation();
        reltn.relationCode ='RELTNWRKFR';
        reltn.inactiveIndicator = false;
        reltn.engagementCode = 'ISA';
        personAcctReltns.add(reltn);
        reltn = new Core_IntegrationUtility.ERPM_Person_Account_Relation();
        reltn.relationCode ='RELTNPRCTC';
        reltn.inactiveIndicator = false;
        reltn.engagementCode = 'ISA';
        personAcctReltns.add(reltn);
        reltn = new Core_IntegrationUtility.ERPM_Person_Account_Relation();
        reltn.relationCode ='RELTNACTAD';
        reltn.inactiveIndicator = false;
        reltn.engagementCode = 'ISA';
        personAcctReltns.add(reltn);
        
        system.debug('---Valid  Scenario ---');           
        System.assertEquals(true, new Core_Integration_Additional_Attributes(newAccount.Id,cont.Id,cp.PRM_programCode__c,null,null,null,null,null,null).SetPersonAccountRelationships(personAcctReltns));
        List<PRM_Account_Contact_Relationship__c> acctContReltns = [SELECT Id, PRM_Relationship_Id__r.PRM_Contact_Relationship_Cd__c , PRM_InActive_Ind__c
                                                                    FROM PRM_Account_Contact_Relationship__c
                                                                    WHERE PRM_Account_Id__c =:newAccount.Id AND PRM_Contact_Id__c =:cont.Id
                                                                    ORDER BY PRM_Relationship_Id__r.PRM_Contact_Relationship_Cd__c ASC];    
        System.assertEquals(2, acctContReltns.size());
        System.assertEquals(false, acctContReltns[0].PRM_InActive_Ind__c);
        System.assertEquals('PRIMARY', acctContReltns[0].PRM_Relationship_Id__r.PRM_Contact_Relationship_Cd__c);
        System.assertEquals(false, acctContReltns[1].PRM_InActive_Ind__c);
        System.assertEquals('WORKSFOR', acctContReltns[1].PRM_Relationship_Id__r.PRM_Contact_Relationship_Cd__c);
        system.debug('---Valid  Scenario ---');        
    }
    
    @isTest static void SetAccountContactRelationships_OnlyOneWFISA(){               
        system.debug('NullOrEmptyPersonAccountRelationships Scenario'); 
        Account newAccount = GetAccount('UnitTestCasesAccount42');
        Contact cont = GetContact('silam.munusamy@test42.com');
        ChannelProgram cp = GetChannelProgram('IPA');               
        List<Core_IntegrationUtility.ERPM_Person_Account_Relation> personAcctReltns = new List<Core_IntegrationUtility.ERPM_Person_Account_Relation>();
        Core_IntegrationUtility.ERPM_Person_Account_Relation reltn = new Core_IntegrationUtility.ERPM_Person_Account_Relation();
        reltn.relationCode ='RELTNWRKFR';
        reltn.inactiveIndicator = false;
        reltn.engagementCode = 'ISA';
        personAcctReltns.add(reltn);
        
        
        system.debug('---Valid  Scenario ---');           
        System.assertEquals(true, new Core_Integration_Additional_Attributes(newAccount.Id,cont.Id,cp.PRM_programCode__c,null,null,null,null,null,null).SetPersonAccountRelationships(personAcctReltns));
        List<PRM_Account_Contact_Relationship__c> acctContReltns = [SELECT Id, PRM_Relationship_Id__r.PRM_Contact_Relationship_Cd__c , PRM_InActive_Ind__c
                                                                    FROM PRM_Account_Contact_Relationship__c
                                                                    WHERE PRM_Account_Id__c =:newAccount.Id AND PRM_Contact_Id__c =:cont.Id
                                                                    ORDER BY PRM_Relationship_Id__r.PRM_Contact_Relationship_Cd__c ASC];    
        System.assertEquals(1, acctContReltns.size());        
        System.assertEquals(false, acctContReltns[0].PRM_InActive_Ind__c);
        System.assertEquals('WORKSFOR', acctContReltns[0].PRM_Relationship_Id__r.PRM_Contact_Relationship_Cd__c);
        system.debug('---Valid  Scenario ---');        
    }
    
    @isTest static void SetAccountContactRelationships_ITP_ISA(){               
        system.debug('NullOrEmptyPersonAccountRelationships Scenario'); 
        Account newAccount = GetAccount('UnitTestCasesAccount42');
        Contact cont = GetContact('silam.munusamy@test42.com');
        ChannelProgram cp = GetChannelProgram('IPA');               
        List<Core_IntegrationUtility.ERPM_Person_Account_Relation> personAcctReltns = new List<Core_IntegrationUtility.ERPM_Person_Account_Relation>();
        Core_IntegrationUtility.ERPM_Person_Account_Relation reltn = new Core_IntegrationUtility.ERPM_Person_Account_Relation();
        reltn.relationCode ='RELTNACTAD';
        reltn.inactiveIndicator = false;
        reltn.engagementCode = 'ITP';
        personAcctReltns.add(reltn);
        reltn = new Core_IntegrationUtility.ERPM_Person_Account_Relation();
        reltn.relationCode ='RELTNPRCTC';
        reltn.inactiveIndicator = false;
        reltn.engagementCode = 'ITP';
        personAcctReltns.add(reltn);
        reltn = new Core_IntegrationUtility.ERPM_Person_Account_Relation();
        reltn.relationCode ='RELTNTRNFR';
        reltn.inactiveIndicator = false;
        reltn.engagementCode = 'ITP';
        personAcctReltns.add(reltn);
        reltn = new Core_IntegrationUtility.ERPM_Person_Account_Relation();
        reltn.relationCode ='RELTNWRKFR';
        reltn.inactiveIndicator = false;
        reltn.engagementCode = 'ISA';
        personAcctReltns.add(reltn);
        
        system.debug('---Valid  Scenario ---');           
        System.assertEquals(true, new Core_Integration_Additional_Attributes(newAccount.Id,cont.Id,cp.PRM_programCode__c,null,null,null,null,null,null).SetPersonAccountRelationships(personAcctReltns));
        List<PRM_Account_Contact_Relationship__c> acctContReltns = [SELECT Id, PRM_Relationship_Id__r.PRM_Contact_Relationship_Cd__c , PRM_InActive_Ind__c
                                                                    FROM PRM_Account_Contact_Relationship__c
                                                                    WHERE PRM_Account_Id__c =:newAccount.Id AND PRM_Contact_Id__c =:cont.Id
                                                                    ORDER BY PRM_Relationship_Id__r.PRM_Contact_Relationship_Cd__c ASC];    
        System.assertEquals(2, acctContReltns.size());
        System.assertEquals(false, acctContReltns[0].PRM_InActive_Ind__c);
        System.assertEquals('PRIMARY', acctContReltns[0].PRM_Relationship_Id__r.PRM_Contact_Relationship_Cd__c);
        System.assertEquals(false, acctContReltns[1].PRM_InActive_Ind__c);
        System.assertEquals('WORKSFOR', acctContReltns[1].PRM_Relationship_Id__r.PRM_Contact_Relationship_Cd__c);
        system.debug('---Valid  Scenario ---');        
    }
    
    @isTest static void SetAccountContactRelationships_Update(){               
        Account newAccount = GetAccount('UnitTestCasesAccount42');
        Contact cont = GetContact('silam.munusamy@test42.com');
        Contact cont1 = GetContact('silam.munusamy@test43.com');
        ChannelProgram cp = GetChannelProgram('IPA');           
        
        List<Core_IntegrationUtility.ERPM_Person_Account_Relation> personAcctReltns = new List<Core_IntegrationUtility.ERPM_Person_Account_Relation>();
        Core_IntegrationUtility.ERPM_Person_Account_Relation reltn = new Core_IntegrationUtility.ERPM_Person_Account_Relation();
        reltn.relationCode ='RELTNWRKFR';
        reltn.inactiveIndicator = false;
        reltn.engagementCode = 'CSPx2';
        personAcctReltns.add(reltn);
        reltn = new Core_IntegrationUtility.ERPM_Person_Account_Relation();
        reltn.relationCode ='RELTNPRCTC';
        reltn.engagementCode = 'CSPx2';
        reltn.inactiveIndicator = false;
        personAcctReltns.add(reltn);
        
        system.debug('---Valid  Scenario ---');           
        System.assertEquals(true, new Core_Integration_Additional_Attributes(newAccount.Id,cont.Id,cp.PRM_programCode__c,null,null,null,null,null,null).SetPersonAccountRelationships(personAcctReltns));
        List<PRM_Account_Contact_Relationship__c> acctContReltnsOld = [SELECT Id, PRM_Relationship_Id__r.PRM_Contact_Relationship_Cd__c , PRM_InActive_Ind__c
                                                                       FROM PRM_Account_Contact_Relationship__c
                                                                       WHERE PRM_Account_Id__c =:newAccount.Id AND PRM_Contact_Id__c =:cont.Id
                                                                       ORDER BY PRM_Relationship_Id__r.PRM_Contact_Relationship_Cd__c ASC]; 
        System.assertEquals(false, acctContReltnsOld[0].PRM_InActive_Ind__c);
        System.assertEquals(false, acctContReltnsOld[1].PRM_InActive_Ind__c);    
        
        system.debug('---Inactivve Scenario ---');
        
        personAcctReltns = new List<Core_IntegrationUtility.ERPM_Person_Account_Relation>();
        reltn = new Core_IntegrationUtility.ERPM_Person_Account_Relation();
        reltn.relationCode ='RELTNPRCTC';
        reltn.inactiveIndicator = true;
        reltn.engagementCode = 'CSPx2';
        reltn.status = 'Complete';
        personAcctReltns.add(reltn);
        System.assertEquals(true, new Core_Integration_Additional_Attributes(newAccount.Id,cont1.Id,cp.PRM_programCode__c,null,null,null,null,null,null).SetPersonAccountRelationships(personAcctReltns));
        
        List<PRM_Account_Contact_Relationship__c> acctContReltns = [SELECT Id, PRM_Relationship_Id__r.PRM_Contact_Relationship_Cd__c , PRM_InActive_Ind__c
                                                                    FROM PRM_Account_Contact_Relationship__c
                                                                    WHERE PRM_Account_Id__c =:newAccount.Id AND PRM_Contact_Id__c =:cont1.Id
                                                                    ORDER BY PRM_Relationship_Id__r.PRM_Contact_Relationship_Cd__c ASC];
        
        system.debug('--TestClass-- ::: acctContReltns ::: ' + acctContReltns);       
        System.assertEquals('PRIMARY', acctContReltns[0].PRM_Relationship_Id__r.PRM_Contact_Relationship_Cd__c);
        System.assertEquals(true, acctContReltns[0].PRM_InActive_Ind__c);        
    }
    
    @isTest static void SetSubscriptions_NullAndEmptyPayLoad(){
        //Null payload                
        System.assertEquals(false, new Core_Integration_Additional_Attributes(null,null,null,null,null,null,null,null,null).SetSubscriptions(null)); 
        
        //Empty payload
        System.assertEquals(false, new Core_Integration_Additional_Attributes(null,null,null,null,null,null,null,null,null).SetSubscriptions(new List<Core_IntegrationUtility.eRPM_Subscription>()));
    }
    
    @isTest static void SetSubscriptions_InvalidSubscriptions(){
        List<Core_IntegrationUtility.eRPM_Subscription> eRPMSubscriptions = new List<Core_IntegrationUtility.eRPM_Subscription>();
        
        Core_IntegrationUtility.eRPM_Subscription subscr = new Core_IntegrationUtility.eRPM_Subscription();        
        subscr.eRPM_SubscriptionCode='COMKTGFUND123';
        subscr.eRPM_SubscriptionStatusCode ='';
        eRPMSubscriptions.add(subscr);
        
        Contact con = GetContact('silam.munusamy@test42.com');
        System.assertEquals(false, new Core_Integration_Additional_Attributes(null,con.Id,'IPA',null,null,null,null,null,null).SetSubscriptions(eRPMSubscriptions)); 
    }
    
    @isTest static void SetSubscriptions_NewValidSubscription(){
        List<Core_IntegrationUtility.eRPM_Subscription> eRPMSubscriptions = new List<Core_IntegrationUtility.eRPM_Subscription>();
        
        Core_IntegrationUtility.eRPM_Subscription subscr = new Core_IntegrationUtility.eRPM_Subscription();        
        subscr.eRPM_SubscriptionCode='Gold';
        subscr.eRPM_SubscriptionStatusCode ='Active';
        eRPMSubscriptions.add(subscr);
        
        subscr = new Core_IntegrationUtility.eRPM_Subscription();        
        subscr.eRPM_SubscriptionCode='Platinum';
        subscr.eRPM_SubscriptionStatusCode ='Active';
        eRPMSubscriptions.add(subscr);
        
        Contact con = GetContact('silam.munusamy@test42.com');
        System.assertEquals(true, new Core_Integration_Additional_Attributes(null,con.Id,'IPA',null,null,null,null,null,null).SetSubscriptions(eRPMSubscriptions));                   
    }
    
    @isTest static void SetSubscriptions_UpdateValidSubscriptions(){
        List<Core_IntegrationUtility.eRPM_Subscription> eRPMSubscriptions = new List<Core_IntegrationUtility.eRPM_Subscription>();
        
        Core_IntegrationUtility.eRPM_Subscription subscr = new Core_IntegrationUtility.eRPM_Subscription();        
        subscr.eRPM_SubscriptionCode='Gold';
        subscr.eRPM_SubscriptionStatusCode ='Active';
        eRPMSubscriptions.add(subscr);
        
        subscr = new Core_IntegrationUtility.eRPM_Subscription();        
        subscr.eRPM_SubscriptionCode='Platinum';
        subscr.eRPM_SubscriptionStatusCode ='Active';
        eRPMSubscriptions.add(subscr);
        
        Contact con = GetContact('silam.munusamy@test42.com');
        
        System.assertEquals(true, new Core_Integration_Additional_Attributes(null,con.Id,'IPA',null,null,null,null,null,null).SetSubscriptions(eRPMSubscriptions));
        
        //De-activate and add new Subscription
        eRPMSubscriptions = new List<Core_IntegrationUtility.eRPM_Subscription>();
        
        subscr = new Core_IntegrationUtility.eRPM_Subscription();        
        subscr.eRPM_SubscriptionCode='Gold';
        subscr.eRPM_SubscriptionStatusCode ='Active';
        eRPMSubscriptions.add(subscr);
        
        subscr = new Core_IntegrationUtility.eRPM_Subscription();        
        subscr.eRPM_SubscriptionCode='Platinum';
        subscr.eRPM_SubscriptionStatusCode ='Inactive';       
        eRPMSubscriptions.add(subscr);
        
        subscr = new Core_IntegrationUtility.eRPM_Subscription();        
        subscr.eRPM_SubscriptionCode='Silver';
        subscr.eRPM_SubscriptionStatusCode ='Active';
        eRPMSubscriptions.add(subscr);  
        
        System.assertEquals(true, new Core_Integration_Additional_Attributes(null,con.Id,'IPA',null,null,null,null,null,null).SetSubscriptions(eRPMSubscriptions));
    }
    
    @isTest static void SetSubscription_Update_Inactive_ValidSubscriptions(){
        List<Core_IntegrationUtility.eRPM_Subscription> eRPMSubscriptions = new List<Core_IntegrationUtility.eRPM_Subscription>();
        
        Core_IntegrationUtility.eRPM_Subscription subscr = new Core_IntegrationUtility.eRPM_Subscription();        
        subscr = new Core_IntegrationUtility.eRPM_Subscription();        
        subscr.eRPM_SubscriptionCode='Platinum';
        subscr.eRPM_SubscriptionStatusCode ='Inactive';
        
        eRPMSubscriptions.add(subscr);
        
        subscr = new Core_IntegrationUtility.eRPM_Subscription();        
        subscr.eRPM_SubscriptionCode='Gold';
        subscr.eRPM_SubscriptionStatusCode ='Inactive';
        //subscr.eRPM_SubscriptionReasonText = 'Test Subscription';
        eRPMSubscriptions.add(subscr);
        
        subscr = new Core_IntegrationUtility.eRPM_Subscription();        
        subscr.eRPM_SubscriptionCode='Silver';
        subscr.eRPM_SubscriptionStatusCode ='Inactive';
        //subscr.eRPM_SubscriptionReasonText = 'Test Subscription';
        eRPMSubscriptions.add(subscr);
        
        Contact con = GetContact('silam.munusamy@test42.com');
        
        System.assertEquals(true, new Core_Integration_Additional_Attributes(null,con.Id,'IPA',null,null,null,null,null,null).SetSubscriptions(eRPMSubscriptions));
    }
    
    @isTest static void SetSubscriptions_Valid_Invalid_Subscription(){
        List<Core_IntegrationUtility.eRPM_Subscription> eRPMSubscriptions = new List<Core_IntegrationUtility.eRPM_Subscription>();
        
        Core_IntegrationUtility.eRPM_Subscription subscr = new Core_IntegrationUtility.eRPM_Subscription();        
        subscr.eRPM_SubscriptionCode='Gold';
        subscr.eRPM_SubscriptionStatusCode ='Active';
        eRPMSubscriptions.add(subscr);
        
        subscr = new Core_IntegrationUtility.eRPM_Subscription();        
        subscr.eRPM_SubscriptionCode='COMKTGFUND123';
        subscr.eRPM_SubscriptionStatusCode ='Active';
        eRPMSubscriptions.add(subscr);
        
        Contact con = GetContact('silam.munusamy@test42.com');
        System.assertEquals(true, new Core_Integration_Additional_Attributes(null,con.Id,'IPA',null,null,null,null,null,null).SetSubscriptions(eRPMSubscriptions));                   
    } 
    
    @isTest static void SetSubscription_Update_Exception(){
        List<Core_IntegrationUtility.eRPM_Subscription> eRPMSubscriptions = new List<Core_IntegrationUtility.eRPM_Subscription>();
        
        Core_IntegrationUtility.eRPM_Subscription subscr = new Core_IntegrationUtility.eRPM_Subscription();        
        subscr = new Core_IntegrationUtility.eRPM_Subscription();        
        subscr.eRPM_SubscriptionCode='Platinum';
        //subscr.eRPM_SubscriptionStatusCode ='Inactive';
        //subscr.eRPM_SubscriptionReasonText = 'Test Subscription';
        eRPMSubscriptions.add(subscr);        
        
        Contact con = GetContact('silam.munusamy@test42.com');
        
        System.assertEquals(false, new Core_Integration_Additional_Attributes(null,con.Id,'IPA',null,null,null,null,null,null).SetSubscriptions(eRPMSubscriptions));
    }          
    
    public static account CreateAccount(integer count){
        //Account Object
        Account newAccount = new Account(
            Name='UnitTestCasesAccount' + count, 
            BillingCity='Bangalore'+Count,
            BillingStreet='Test BGA',
            BillingCountry='India',
            BillingPostalCode='142421',
            Core_CIM_ID__c = 'CIM' + count,
            Core_Account_Type__c = 'Cloud Service Provider (CSP)');
        
        insert newAccount;
        System.debug('Account -->'+newAccount);
        
        return newAccount;
    }
    
    public static Account GetAccount(string name){
        return database.Query('SELECT ID FROM ACCOUNT WHERE Name =:name LIMIT 1');      
    }
    
    public static Contact GetContact(string email){
        return database.Query('SELECT ID FROM Contact WHERE Email =:email LIMIT 1');      
    }
    
    public static ChannelProgram GetChannelProgram(string code){
        return database.Query('SELECT ID, PRM_programCode__c FROM ChannelProgram WHERE PRM_programCode__c =:code LIMIT 1');      
    }
    
    public static String generateRandomString(Integer len) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < len) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx+1);
        }
        return randStr; 
    }
    
    public static contact CreateContact(Id accountId, integer count){       
        //Contact Object
        Contact cont = new Contact(
            AccountId=accountId,
            lastName= generateRandomString(5),
            FirstName=generateRandomString(5), 
            email='silam.munusamy@test'+count+'.com',            
            RecordTypeId= [select Id from RecordType where sObjectType='Contact' and Name=:Label.ERPM_Intel_Contact].Id
        );
        
        insert cont;
        
        System.debug('Contact -->'+cont);        
        return cont;        
    }
    
    public static ChannelProgram CreateChannelProgram(string chnlProgName, string progCode){
        ChannelProgram cp = new ChannelProgram();//Channel Program
        cp.Name=chnlProgName;
        cp.PRM_programCode__c=progCode;
        
        insert cp;
        
        System.debug('ChannelProgram -->'+cp);
        return cp;
    }
    
    public static List<ChannelProgramLevel> CreateChannelProgramLevel(Id chnlPrgId){
        List<ChannelProgramLevel> cpls=new List<ChannelProgramLevel>(); //Channel Program Level
        ChannelProgramLevel cpl = new ChannelProgramLevel();
        cpl.Name='Titanium';
        cpl.ProgramId=chnlPrgId;
        cpl.PRM_programlevelcode__c = 'Titanium';
        cpls.add(cpl);
        
        cpl = new ChannelProgramLevel();
        cpl.Name='Member';
        cpl.ProgramId=chnlPrgId;
        cpl.PRM_programlevelcode__c = 'Member';
        cpls.add(cpl);
        
        insert cpls;
        
        
        system.debug('ChannelProgramLevel --->' + cpls);  
        return cpls;
    }
    
    public static PRM_AccountChannelMembership__c CreateAccountChannelMembership(Id accountId, Id ChnlPrgId, Id ChnlPrgLvlId, String partnerRole){
        PRM_AccountChannelMembership__c acm = new PRM_AccountChannelMembership__c(); // Account Channel Membership association
        acm.PRM_Account_Id__c=accountId;
        acm.PRM_Status_Nm__c='Approved';
        acm.PRM_Channel_Program_Id__c=ChnlPrgId;
        acm.PRM_Channel_Program_Level_Id__c=ChnlPrgLvlId;
        acm.PRM_Partner_Role__c = partnerRole;//'Service Provider'
        
        insert acm;
        
        system.debug('PRM_AccountChannelMembership__c --->' + acm);
        return acm;
    }
    
    public static PRM_PartnerType__c CreatePartnerType(Id ChnlPrgId){
        PRM_PartnerType__c partnrType = new PRM_PartnerType__c(); //Partner Type
        partnrType.Name ='Cloud Service Provider (CSP)';
        partnrType.PRM_PartneryTypeCode__c ='CSP';         
        partnrType.PRM_Role_Name__c ='Service Provider';
        partnrType.PRM_PartnerRoleCode__c ='SPR'; 
        partnrType.PRM_inactind__c =false;
        partnrType.PRM_channelprogram__c =ChnlPrgId;
        
        insert partnrType;
        
        system.debug('partnrTypLookUp  --->' + partnrType);
        return partnrType;
    }
    
    public static PRM_PartnerType__c CreatePartnerType_ITP(Id ChnlPrgId){
        PRM_PartnerType__c partnrType = new PRM_PartnerType__c(); //Partner Type
        partnrType.Name ='Intel Technology Provider (ITP)';
        partnrType.PRM_PartneryTypeCode__c ='ITP';         
        partnrType.PRM_Role_Name__c ='Service Provider';
        partnrType.PRM_PartnerRoleCode__c ='SPR'; 
        partnrType.PRM_inactind__c = false;
        partnrType.PRM_channelprogram__c =ChnlPrgId;
        
        insert partnrType;
        
        system.debug('partnrTypLookUp  --->' + partnrType);
        return partnrType;
    }
    
    public static PRM_Profile_Questions__c CreateProfileQuestion(Id ChnlPrgId, String PartnrTypeRole, string questionCode){
        PRM_Profile_Questions__c profQuestion = new PRM_Profile_Questions__c();
        profQuestion.PRM_Question_Cd__c = questionCode;
        profQuestion.PRM_Channel_Program_Id__c = ChnlPrgId;
        //profQuestion.PRM_Partner_Type_Id__c = PartnrTypeId;
        //profQuestion.PRM_Partner_Role__c = PartnrTypeRole;
        profQuestion.PRM_Display_Order_Nbr__c = 123;
        profQuestion.PRM_InActive_Ind__c = false;        
        profQuestion.PRM_Question_Display_Txt__c = questionCode +'-IntegrationTest';
        //profQuestion.PRM_Partner_Type_Id__c = 'Text';
        
        insert profQuestion;       
        
        system.debug('profQuestion  ---> ' + profQuestion.Id); 
        return profQuestion;            
    }
    
    public static List<PRM_Profile_Questions__c> CreateProfileQuestions(Id ChnlPrgId, List<string> questionCodes){
        
        List<PRM_Profile_Questions__c> profileQuestions = new List<PRM_Profile_Questions__c>();
        for(string questionCode : questionCodes){
            PRM_Profile_Questions__c profQuestion = new PRM_Profile_Questions__c();
            profQuestion.PRM_Question_Cd__c = questionCode;
            profQuestion.PRM_Channel_Program_Id__c = ChnlPrgId;
            //profQuestion.PRM_Partner_Type_Id__c = PartnrTypeId;
            //profQuestion.PRM_Partner_Role__c = PartnrTypeRole;
            profQuestion.PRM_Display_Order_Nbr__c = 123;
            profQuestion.PRM_InActive_Ind__c = false;        
            profQuestion.PRM_Question_Display_Txt__c = questionCode +'-IntegrationTest';
            profQuestion.PRM_Question_Type_Nm__c = 'Text';
            profileQuestions.add(profQuestion);
        }
        insert profileQuestions;        
        system.debug('profileQuestions  ---> ' + profileQuestions); 
        return profileQuestions;            
    }
    
    public static void CreateProfileAnswers(Id questionId, string answerCode){
        PRM_Profile_Answer__c profAnswer = new PRM_Profile_Answer__c();
        profAnswer.PRM_Answer_Cd__c = answerCode;
        profAnswer.PRM_Answer_Display_Txt__c = answerCode+'-IntegrationTest';
        profAnswer.PRM_Display_Order_Nbr__c = 1242;
        profAnswer.PRM_InActive_Ind__c = false;
        profAnswer.PRM_Profile_Questions_Id__c = questionId;
        
        insert profAnswer;
        
        system.debug('profAnswer   ---> ' + profAnswer.Id);         
    }
    
    public static void CreateProfileAnswers(Id questionId, List<string> answerCodes){
        List<PRM_Profile_Answer__c> profAnswers = new List<PRM_Profile_Answer__c>();
        for(string answerCode :answerCodes){
            PRM_Profile_Answer__c profAnswer = new PRM_Profile_Answer__c();
            profAnswer.PRM_Answer_Cd__c = answerCode;
            profAnswer.PRM_Answer_Display_Txt__c = answerCode+'-IntegrationTest';
            profAnswer.PRM_Display_Order_Nbr__c = 1242;
            profAnswer.PRM_InActive_Ind__c = false;
            profAnswer.PRM_Profile_Questions_Id__c = questionId;
            profAnswers.add(profAnswer);
        }
        insert profAnswers;
        
        system.debug('profAnswers   ---> ' + profAnswers);         
    }
    
    public static void CreateBulkProfileAnswers(Id questionId, string answerCode, integer count){
        List<PRM_Profile_Answer__c> profileAnswers = new List<PRM_Profile_Answer__c>();
        for(integer i =1 ;i<=count;i++){
            PRM_Profile_Answer__c profAnswer = new PRM_Profile_Answer__c();
            profAnswer.PRM_Answer_Cd__c = answerCode+i;
            profAnswer.PRM_Answer_Display_Txt__c = answerCode+'-IntegrationTest-' +i;
            profAnswer.PRM_Display_Order_Nbr__c = 1242+i;
            profAnswer.PRM_InActive_Ind__c = false;
            profAnswer.PRM_Profile_Questions_Id__c = questionId;
            profileAnswers.add(profAnswer);
        }
        Test.startTest();
        insert profileAnswers;
        Test.stopTest();
        
        //system.debug('profileAnswers   ---> ' + profileAnswers);        
    }
    
    public static void TestSetupMethod(integer count)
    {
        //Account Object
        Account newAccount = CreateAccount(count);            
        //Contact Object
        Contact cont = CreateContact(newAccount.Id, count);
        //Below Contact is needed for the Set account Contact relationship Updates test method
        Contact cont1 = CreateContact(newAccount.Id, count+1);        
        //Channel Program
        ChannelProgram cp = CreateChannelProgram('Intel Partner Alliance','IPA');            
        //Channel Program Level
        List<ChannelProgramLevel> cpl = CreateChannelProgramLevel(cp.Id); 
        //Account Channel Membership association
        PRM_AccountChannelMembership__c acm = CreateAccountChannelMembership(newAccount.Id, cp.Id, cpl[0].Id, 'Service Provider');
        //Partner Type
        //PRM_PartnerType__c partnrType = CreatePartnerType(cp.Id); 
        //Profile Question 
        List<PRM_Profile_Questions__c> profileQstns = CreateProfileQuestions(cp.Id, new List<string> { 'PQ-000010', 'PQ-000011'}); 
        //Profile Answers        
        CreateProfileAnswers(profileQstns[0].Id, new List<string> { 'PA-000010' , 'PA-000011'});       
        //Profile Answers
        CreateProfileAnswers(profileQstns[1].Id, new List<string> { 'PA-000012' , 'PA-000013'});        
        //Contact Relationships
        List<PRM_ContactRelationships__c> contactReltns = new List<PRM_ContactRelationships__c>();
        PRM_ContactRelationships__c contactReltn = new PRM_ContactRelationships__c();
        contactReltn.PRM_Contact_Relationship_Cd__c ='PRIMARY';
        contactReltn.Name ='Primary Contact';
        contactReltn.PRM_Mandatory_Relationship_Ind__c = true;
        contactReltn.PRM_InActive_Ind__c= false;
        contactReltn.PRM_Channel_Program_Id__c = cp.Id;
        contactReltns.add(contactReltn);
        //insert contactReltn;        
        contactReltn = new PRM_ContactRelationships__c();
        contactReltn.PRM_Contact_Relationship_Cd__c ='WORKSFOR';
        contactReltn.Name ='Employee';
        contactReltn.PRM_Default_Relationship_Ind__c = true;
        contactReltn.PRM_InActive_Ind__c= false;
        contactReltn.PRM_Channel_Program_Id__c = cp.Id;
        contactReltns.add(contactReltn);
        insert contactReltns;
        system.debug('contactReltns --->> ' + contactReltns);       
        
        //Below Contact is needed for the Set account Contact relationship Updates test method
        PRM_Account_Contact_Relationship__c acr = new PRM_Account_Contact_Relationship__c();
        acr.PRM_Account_Id__c = newAccount.Id;
        acr.PRM_Contact_Id__c = cont1.Id;
        acr.PRM_Relationship_Id__c = contactReltns[0].Id;
        acr.PRM_InActive_Ind__c = false;
        insert acr;    
        
        List<PRM_Partner_Subscription__c> partnerSubscriptions = new List<PRM_Partner_Subscription__c>();
        PRM_Partner_Subscription__c ps = new PRM_Partner_Subscription__c();
        ps.name = 'NewsletterGold - CIP';
        ps.PRM_Subscription_Cd__c = 'Gold';
        ps.PRM_InActive_Ind__c = false;
        ps.PRM_Subscription_Type_Nm__c = 'Newsletters - Distributor for Intel Technology Provider';
        partnerSubscriptions.add(ps);
        
        ps = new PRM_Partner_Subscription__c();
        ps.name = 'NewsletterPlatinum - CIP';
        ps.PRM_Subscription_Cd__c = 'Platinum';
        ps.PRM_InActive_Ind__c= false;
        ps.PRM_Subscription_Type_Nm__c = 'Newsletters - Distributor for Intel Technology Provider';
        partnerSubscriptions.add(ps);
        
        ps = new PRM_Partner_Subscription__c();
        ps.name = 'NewsletterSilver - CIP';
        ps.PRM_Subscription_Cd__c = 'Silver';
        ps.PRM_InActive_Ind__c= false;
        ps.PRM_Subscription_Type_Nm__c = 'Newsletters - Distributor for Intel Technology Provider';
        partnerSubscriptions.add(ps);
        
        insert partnerSubscriptions;        
        system.debug('partnerSubscriptions - '+partnerSubscriptions);         
        
        // ERPM Engagements
        List<Core_ERPM_Engagement__c> testERPMEnggs = new List<Core_ERPM_Engagement__c>();
        testERPMEnggs.add(newERPMEngagement('AE1'));
        testERPMEnggs.add(newERPMEngagement('AE2'));        
        insert testERPMEnggs;
        system.debug('----after testERPMEnggs ----' + testERPMEnggs); 
        //Core_IntegrationTestUtility.insertMissingEngagementsEntitlements(testERPMEnggs,enggCode);
        
        // Entitlements
        List<Core_Entitlement__c> testEntitlements = new List<Core_Entitlement__c>();
        testEntitlements.add(new Core_Entitlement__c(Core_ERPM_Engagement_Id__c=testERPMEnggs[0].Id, Core_IsActive__c=false,
                                                     Name='Marketing Specialist', Core_Display_Name__c='Marketing Specialist'));
        testEntitlements.add(new Core_Entitlement__c(Core_ERPM_Engagement_Id__c=testERPMEnggs[1].Id, Core_IsActive__c=false,
                                                     Name='Employee', Core_Display_Name__c='Employee'));
        testEntitlements.add(new Core_Entitlement__c(Core_ERPM_Engagement_Id__c=testERPMEnggs[0].Id, Core_IsActive__c=false,
                                                     Name='Lead Development Representative', Core_Display_Name__c='Lead Development Representative'));
        testEntitlements.add(new Core_Entitlement__c(Core_ERPM_Engagement_Id__c=testERPMEnggs[1].Id, Core_IsActive__c=false,
                                                     Name='Offering Editor', Core_Display_Name__c='Offering Editor'));
        testEntitlements.add(new Core_Entitlement__c(Core_ERPM_Engagement_Id__c=testERPMEnggs[1].Id, Core_IsActive__c=false,
                                                     Name='Partner Admin', Core_Display_Name__c='Partner Admin'));               
        insert testEntitlements;
        system.debug('----after testEntitlements ----' + testEntitlements);  
        
        system.debug('////-----Test Data Setup is Completed -----//// - ');
    }    
}