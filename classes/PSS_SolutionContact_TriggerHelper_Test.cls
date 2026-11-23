/*IPA2.0: US-TWC729-7976*/
@isTest
public class PSS_SolutionContact_TriggerHelper_Test {
   
    /*@isTest
    public static void shareSolutionToContactTest(){
         User adminUser = [Select Id, UserRoleId From User Where Profile.Name='System Administrator'  AND isActive=true Limit 1];
        UserRole role = [Select id from UserRole where DeveloperName = 'Admin' limit 1]; 
        adminUser.userRoleId = role.id;
        update adminUser;
        System.runAs(adminUser){
        Account intelAccount;
        Contact conObj;
        User poeUser;
        string intelAccountRecTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();            
        intelAccount = PMP_TestDataUtility.createIntelAccount('Intel Account10B',intelAccountRecTypeId,true);
        conObj = PMP_TestDataUtility.createContact(intelAccount.id,true);
        Profile prf2=[SELECT Id  FROM Profile WHERE name='Partner' limit 1];
        
        poeUser = new User(Alias = String.valueOf(datetime.now()).substring(0,8), Email='testUsercoreMDF@intel.com',
                           EmailEncodingKey='UTF-8', LastName='User'+String.valueOf(date.today()), LanguageLocaleKey='en_US',
                           LocaleSidKey='en_US', ProfileId = prf2.Id,
                           TimeZoneSidKey='America/Los_Angeles', UserName='testUser'+String.valueOf(Math.random())+'@CoreMDF.com',
                           FirstName='Test'                       
                          );
        poeUser.ContactId=conObj.Id;
        poeUser.isActive=true;
        insert poeUser;
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name='PMP_External_Partner_Admin'];
        PermissionSetAssignment psa = new PermissionSetAssignment(
            AssigneeId = poeUser.Id,
            PermissionSetId = ps.Id
        );
        insert psa;
        
         Id partnerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
            
            Account testAccount = PMP_TestDataUtility.createAccount('PartnerAccount',partnerRecordTypeId,true);
            PMP_Company__c companyInfo = new PMP_Company__c(Name='TestCompany1',PMP_Account_Industry__c='Others',
                                                            PMP_Account_Id__c=testAccount.Id);
            companyInfo.PMP_Partner_Benefit_Type__c='Solutions Marketplace Basic Profile';
            insert companyInfo;
        ArdiraSurvey__Survey__c survey = new ArdiraSurvey__Survey__c();
            survey.Name='test proposal';
            insert survey;
        ArdiraSurvey__Survey_Result__c surveyResult2=new ArdiraSurvey__Survey_Result__c();
            surveyResult2.ArdiraSurvey__Assessment_Result__c='test2';
            surveyResult2.ArdiraSurvey__Assigned_To_User__c=poeUser.Id;
            surveyResult2.ArdiraSurvey__Survey__c=survey.Id;
            surveyResult2.PSS_Solution_Submitter_UserId_Id__c=poeUser.Id;
            surveyResult2.PSS_Company_Id__c=companyInfo.Id;
            surveyResult2.PSS_Proposal_Name_Txt__c   ='test proposal2';
            surveyResult2.PSS_Partner_Solution_Lifecycle_Status_Nm__c='Draft';
            
            
            insert surveyResult2;
        
        List<PSS_Solution_Contact_Association__c> conAssList= new List<PSS_Solution_Contact_Association__c>();
        PSS_Solution_Contact_Association__c conAss= new PSS_Solution_Contact_Association__c();
        conAss.PSS_Active__c=true;
        conAss.PSS_Assigned_User__c=poeUser.Id;
        conAss.PSS_Assigned_Contact__c=poeUser.ContactId;
        conAss.PSS_Solution_Name__c=surveyResult2.Id;
        conAssList.add(conAss);
        insert conAssList;
         system.assertEquals(true,conAss.PSS_Active__c);  
        
        PSS_SolutionContact_TriggerHelper.shareSolutionToContact(conAssList);
            
        }
    }*/
    
}