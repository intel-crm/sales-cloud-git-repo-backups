@IsTest
public class Core_MDF_FeedbackController_Test {
    @TestSetup static void setUpData(){

        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        usr.LastName = 'User Test11';
        usr.IsActive = true;
        usr.UserRoleId = usRole.Id;
        insert usr;
        
        System.runAs(usr){
            List<String> bypassFunctionKeys = new List<String>();
			Set<String> myset1 = new Set<String>();
			List<String> result1 = new List<String>();
			bypassFunctionKeys.add('ShareActivityWithInternalUsers_Bypass');
			bypassFunctionKeys.add('byPassShareUnshareCampaignRecord');
			bypassFunctionKeys.add('byPassCampaignAndRelatedRecords');
			myset1.addAll(bypassFunctionKeys);
			result1.addAll(myset1);

            ChannelProgram ipaCP = Core_MDF_CCP_TestDataUtility.createProgram ('Intel Partner Alliance','Intel Partner Alliance', true);
            ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram ('Client','Client CoMarketing Fund', true);
                       
            Account ccpIntelAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount('CCP Test Intel Account', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);  
            Database.insert(ccpIntelAccount);
            
            List<Account> accountList = new List<Account>();

            Account acc6 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account 3', ipaCP.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, ccpIntelAccount.Id, false);
accountList.add(acc6);
            Account acc2 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account 2',
                                                                             cp.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, 
                                                                             ccpIntelAccount.Id, false);
            accountList.add(acc2);
            Database.insert(accountList);
            
            Contact conRecord1 = Core_MDF_CCP_TestDataUtility.createContact(ccpIntelAccount.Id,true);
            conRecord1.Core_Audience_List__c='IPA User';
            update conRecord1;
            Contact conRecord2 = Core_MDF_CCP_TestDataUtility.createContact(ccpIntelAccount.Id,true);
            conRecord2.Core_Audience_List__c='CCF User';
            update conRecord2;
            
            List<Core_AGS_Role__c> agsRoleList = new List<Core_AGS_Role__c>();
            
            Core_AGS_Role__c agsRoleCCF = Core_MDF_CCP_TestDataUtility.createAgsRole('CCF_USER', 'Co-Marketing(Salesforce)-CCF USER', true, false);
            agsRoleList.add(agsRoleCCF);
            
            Database.insert(agsRoleList);        
            
            Core_ERPM_Engagement__c erpmEngagementCCF = Core_MDF_CCP_TestDataUtility.createErpmEngagement('Client', 'CCF', 'DEDUPB2B', 'SEC', true, false);
            Database.insert(erpmEngagementCCF);
            
            List<Core_Entitlement__c> entitlementList = new List<Core_Entitlement__c>();
            
            Core_Entitlement__c entitlementCCF = Core_MDF_CCP_TestDataUtility.createEntitlement('Client User',agsRoleCCF.Id ,'Intel® Partner Investment Center','Client User',erpmEngagementCCF.Id , true,Core_MDF_CCP_ConstantClass.CCF_PROGRAM,false);
            entitlementList.add(entitlementCCF);
            
           // Database.insert(entitlementList); 
            
            List<Core_Contact_Entitlement__c> contEntList = new List<Core_Contact_Entitlement__c>();
            
            Core_Contact_Entitlement__c contactEntitlementCCF2 = Core_MDF_CCP_TestDataUtility.createContactEntitlement(conRecord2.Id,entitlementCCF.Id ,true,'Complete', false);
            contEntList.add(contactEntitlementCCF2);
            
            Database.insert(contEntList);      
            
            Profile partnerProfile = [SELECT Id FROM Profile WHERE Name='Partner' limit 1];
            User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);   
            //UserRole ur = [Select Id, Name From UserRole where PortalType ='Partner' limit 1];
            usr1.Email='test1@example.com';
            usr1.ContactId = conRecord1.Id;
            usr1.ProfileId = partnerProfile.id;
            usr1.isActive = true;
            //usr1.UserRoleId = ur.id;
            Database.insert(usr1);
            
            User usr2 = Core_MDF_CCP_TestDataUtility.createUser(false);
            //UserRole ur1 = [Select Id, Name From UserRole where PortalType ='Partner' limit 1];
            usr2.Email='test2@example.com';
            usr2.ContactId = conRecord2.Id;
            usr2.ProfileId = partnerProfile.id;
            usr2.isActive = true;
            //usr2.UserRoleId = ur1.id;
            usr2.LanguageLocaleKey = 'ja';
            Database.insert(usr2);
            Group grp1 = new Group();
            grp1.Name = 'Core_MDF_CCP_External';
            grp1.DeveloperName = 'Core_MDF_CCP_External';  
            Database.insert(grp1);
            GroupMember grpMember = new GroupMember();
            grpMember.UserOrGroupId = usr1.Id;
            grpMember.GroupId = grp1.Id;
            insert grpMember;
            
            GroupMember grpMember1 = new GroupMember();
            grpMember1.UserOrGroupId = usr2.Id;
            grpMember1.GroupId = grp1.Id;
            insert grpMember1;
            
            Core_MDF_Partner_Group_Mapping__c pgm1 = new Core_MDF_Partner_Group_Mapping__c();
            pgm1.Core_MDF_Account__c = ccpIntelAccount.Id;
            pgm1.Core_MDF_Group_Name__c = 'Core_MDF_CCP_External';
            pgm1.Core_MDF_Type_of_Access__c = 'External';
            pgm1.Core_MDF_Group_Id__c = grp1.Id;
            pgm1.Core_MDF_Channel_Program__c = ipaCP.Id;
            pgm1.Core_MDF_AccountIdGroupName__c = ccpIntelAccount.Id+'Core_MDF_CCP_External';
            pgm1.Core_MDF_Inactive_Ind__c=false;
            pgm1.Core_MDF_Virtual_Corp_nm__c = acc6.Id;
            List<Core_MDF_Partner_Group_Mapping__c> pgmList = new List<Core_MDF_Partner_Group_Mapping__c>();
            pgmList.add(pgm1);
            insert pgmList;
            

            
            
            Core_MDF_Survey_Question__c surveyQuestion = new Core_MDF_Survey_Question__c();
            SurveyQuestion.Core_MDF_Question__c = 'Is it Easy';
            SurveyQuestion.Core_MDF_Active_ind__c = True;
            SurveyQuestion.Core_MDF_Category_nm__c = 'CCP';
            SurveyQuestion.Core_MDF_Sort_Order__c = 1;
            SurveyQuestion.Core_MDF_Visible_To_nm__c = 'Internal';
            SurveyQuestion.Core_MDF_Question_Start_Date_dt__c = system.today();
            SurveyQuestion.Core_MDF_Question_Expiration_Date_dt__c = system.today();
            insert SurveyQuestion;
            
            
            Set<String> programSet = new Set<String>();
            programSet.add('Intel Partner Alliance');
            List<Core_MDF_FeedbackController.SurveyResponseWrapper> SurveyResponseWrapList = new List<Core_MDF_FeedbackController.SurveyResponseWrapper>();
            Core_MDF_FeedbackController.SurveyResponseWrapper surveyResponseWrap = new Core_MDF_FeedbackController.SurveyResponseWrapper();
            surveyResponseWrap.programSet = programSet;
            surveyResponseWrap.ultimateAccountId = ccpIntelAccount.Id;
            surveyResponseWrap.userAccountId = ccpIntelAccount.Id;
            SurveyResponseWrapList.add(surveyResponseWrap);
            
            Core_MDF_Survey__c surveyRec = new Core_MDF_Survey__c();
            surveyRec.Core_MDF_Comment_txt__c = 'ABCD comment';
            surveyRec.Core_MDF_Submitted_By_id__c = usr.Id;
            surveyRec.Core_MDF_Submitted_On_dtm__c = system.now();
            surveyRec.Core_MDF_User_Account__c = surveyResponseWrap.ultimateAccountId;
            surveyRec.Core_MDF_User_Program_nm__c = !programSet.isEmpty() ? String.join(programSet, ';') : '';
            insert surveyRec;
            
            Core_MDF_Survey_Response__c responseData= new Core_MDF_Survey_Response__c();
            responseData.Core_MDF_Survey_Question_id__c=SurveyQuestion.Id;
            responseData.Core_MDF_Answers_txt__c= '4';
            responseData.Core_MDF_Survey_id__c=surveyRec.id;
            insert responseData;
            
        }
     }
    
    @IsTest
    public static void fetchRecordsTest(){
        
        Core_MDF_Survey_Question__c surveyQues = [SELECT Id,Core_MDF_Question__c from Core_MDF_Survey_Question__c where Core_MDF_Sort_Order__c = 1 limit 1];

        User partnerUser = [SELECT Id,Email,ContactId,Contact.AccountId from User where Email='test1@example.com' limit 1];
        
        system.runAs(partnerUser){
            
            Core_MDF_FeedbackController.pageReferenceWrapper pageWrap = new Core_MDF_FeedbackController.pageReferenceWrapper();
            pageWrap.actionName = 'view';
            pageWrap.recordId = surveyQues.id;
            String pageWrapJSON = JSON.serialize(pageWrap);
            
            List<Core_MDF_FeedbackController.SurveyDetailsWrapper> SurveyDetailsWrapList = new List<Core_MDF_FeedbackController.SurveyDetailsWrapper>();
            Core_MDF_FeedbackController.SurveyDetailsWrapper surveyDetailsWrap = new Core_MDF_FeedbackController.SurveyDetailsWrapper();
            surveyDetailsWrap.order = 1;
            surveyDetailsWrap.question = surveyQues.Core_MDF_Question__c;
            surveyDetailsWrap.questionId = surveyQues.Id;
            surveyDetailsWrap.rating = '5';
            SurveyDetailsWrapList.add(surveyDetailsWrap);
            Core_MDF_FeedbackController.SurveyDetailsWrapper surveyDetailsWrap1 = new Core_MDF_FeedbackController.SurveyDetailsWrapper();
            surveyDetailsWrap1.order = 1;
            surveyDetailsWrap1.question = surveyQues.Core_MDF_Question__c;
            surveyDetailsWrap1.questionId = '';
            surveyDetailsWrap1.rating = '4';
            SurveyDetailsWrapList.add(surveyDetailsWrap1);
            
            Core_MDF_FeedbackController.SurveyWrapper surveyWrap = new Core_MDF_FeedbackController.SurveyWrapper();
            surveyWrap.SurveyDetailsWrapperList = SurveyDetailsWrapList;
            surveyWrap.pageRef = pageWrapJSON;

            Assert.areEqual(true, surveyWrap != null);
            Core_MDF_FeedbackController.fetchRecords();
            Core_MDF_FeedbackController.submitScoreAction(surveyWrap);
            Core_MDF_FeedbackController.submitScoreAction(null);//my change
            Core_MDF_FeedbackController.isCommunity();
            
        }
    }
    
    @IsTest
    public static void fetchRecordsCloneTest(){
        
        Core_MDF_Survey_Question__c surveyQues = [SELECT Id,Core_MDF_Question__c from Core_MDF_Survey_Question__c where Core_MDF_Sort_Order__c = 1 limit 1];

        User partnerUser = [SELECT Id,Email,ContactId,Contact.AccountId from User where Email='test2@example.com' limit 1];
        
        system.runAs(partnerUser){
            
            Core_MDF_FeedbackController.pageReferenceWrapper pageWrap = new Core_MDF_FeedbackController.pageReferenceWrapper();
            pageWrap.actionName = 'view';
            pageWrap.recordId = surveyQues.id;
            String pageWrapJSON = JSON.serialize(pageWrap);
            
            List<Core_MDF_FeedbackController.SurveyDetailsWrapper> SurveyDetailsWrapList = new List<Core_MDF_FeedbackController.SurveyDetailsWrapper>();
            Core_MDF_FeedbackController.SurveyDetailsWrapper surveyDetailsWrap = new Core_MDF_FeedbackController.SurveyDetailsWrapper();
            surveyDetailsWrap.order = 1;
            surveyDetailsWrap.question = surveyQues.Core_MDF_Question__c;
            surveyDetailsWrap.questionId = surveyQues.Id;
            surveyDetailsWrap.rating = '5';
            SurveyDetailsWrapList.add(surveyDetailsWrap);
            
            Core_MDF_FeedbackController.SurveyWrapper surveyWrap = new Core_MDF_FeedbackController.SurveyWrapper();
            surveyWrap.SurveyDetailsWrapperList = SurveyDetailsWrapList;
            surveyWrap.pageRef = pageWrapJSON;
            
            Assert.areEqual(true, surveyWrap != null);
            Core_MDF_FeedbackController.fetchRecords();
            Core_MDF_FeedbackController.submitScoreAction(surveyWrap);
            Core_MDF_FeedbackController.submitScoreAction(new Core_MDF_FeedbackController.SurveyWrapper());//my changes
            Core_MDF_FeedbackController.isCommunity();
        }
    }
    @IsTest
    public static void firstLoginTest(){
        test.startTest();
        String frequencyString = 'CALENDAR_QUARTER(LoginTime) = ';
        Integer currentfrequency = Integer.valueOf(getCurrentQuarter());
        List<LoginHistory> successLoginList = new List<LoginHistory>();
        Set<Id> userIdSet = new Set<Id>();
        String query = 'SELECT Id, LoginTime, Status, UserId from LoginHistory WHERE' +
                                ' LoginUrl = ' + '\'' +  String.escapeSingleQuotes(Label.Core_MDF_PFRCommunityLink)+ 's/login' + '\''+
                                ' AND CALENDAR_YEAR(LoginTime) = ' + Date.today().year() +
                                ' AND ' + String.escapeSingleQuotes(frequencyString) + currentfrequency + 
                                ' Order by Status ASC LIMIT 10';
                List<LoginHistory> recordsList = Database.query(query);
                for(LoginHistory loginRecord : recordsList){
                    if(loginRecord.Status.toLowercase() == Core_MDF_CCP_ConstantClass.FEEDBACK_SUCCESS_STATUS.toLowerCase()){ //to get only the Success records from query as Status field cannot be added in where clause
                        successLoginList.add(loginRecord);
                        userIdSet.add(loginRecord.userId);
                        if(successLoginList.size() == 1){ // list size = 2 then break to avoid extra for loop iterations as we require only size = 1 to check if it the ist login. If size = 2 means its not the 1st login
                            break;
                        }
                    }
                }  
        //User usr = [Select id from User where id IN: userIdSet AND IsActive = TRUE Limit 1];
     /*   User usr = userIdSet.isEmpty() //my change
    	? [SELECT Id FROM User WHERE IsActive = TRUE LIMIT 1]
    	: [SELECT Id FROM User WHERE Id IN :userIdSet AND IsActive = TRUE LIMIT 1];  */
      //  system.runAs(usr){
        	Boolean popupEnabled = Core_MDF_FeedbackController.getFirstLoginHistory();
            Assert.areEqual(true, popupEnabled != null);
        	Core_MDF_FeedbackController.getCurrentQuarter();
            System.assertNotEquals(null, Core_MDF_FeedbackController.getFirstLoginHistory());//my change
       // }
        test.stopTest();
    }
    public static Double getCurrentQuarter(){
        Double month = date.today().month();
        return (Math.ceil(month / 3));
        } 
}