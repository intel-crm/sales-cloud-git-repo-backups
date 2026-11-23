/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-15-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class Pricing_QuoteTeam_SharingController_Test {
    @testSetup
    public static void setUpData(){
        List<User> lstUsers = Pricing_Test_Utility.createAdminUser();
        system.runAs(lstUsers[0]){
            Pricing_Test_Utility.createPriceBook();
            Account acc = Pricing_Test_Utility.createAccount();
            Contact con = Pricing_Test_Utility.createPrimaryContactWithParam(acc.Id,'Quote_Team_Sahring_Controller_Test');
            Pricing_Test_Utility.createTemplate(lstUsers[0].id);
            List<User> accountExecutiveUserList = Pricing_Test_Utility.createAEUser();
            List<User> salesRepUserList = Pricing_Test_Utility.createSalesRepUser();
            salesRepUserList.addAll(Pricing_Test_Utility.createFSEUser());
            List<AccountTeamMember> accTeam = new List<AccountTeamMember>();
            AccountTeamMember act1 =  new AccountTeamMember(AccountId = acc.Id,
                                                            TeamMemberRole = 'Technical Sales',UserId = salesRepUserList[0].Id);
            AccountTeamMember act2 =  new AccountTeamMember(AccountId = acc.Id,
                                                            TeamMemberRole = 'Technical Sales',UserId = salesRepUserList[1].Id);
            accTeam.add(act1);
            accTeam.add(act2);
            insert accTeam;
            Test.startTest();
            List<SBQQ__Quote__c> lstquote = Pricing_Test_Utility.createQuoteWithParam(acc.Id, con.Id, 2,salesRepUserList[0].Email,accountExecutiveUserList[0].Email); 
            List<SBQQ__QuoteLine__c> lstquoteLines = Pricing_Test_Utility.createQuoteLines(lstquote[0].id, 1);
            
            List<User> userList = new List<User>();
            Set<String> profileNameSet=new Set<String>{Label.Pricing_Tender_Profiles_SalesRepBB};
                PermissionSet aePermissionSet = [SELECT Id FROM PermissionSet WHERE Name =: Label.Pricing_Tender_PermissionSets_TenderAccountExecutive];
            PermissionSet cpqPermissionRec = [SELECT Id, Name FROM PermissionSet where Name=:Label.Pricing_CPQ_Managed_License_User Limit 1];
            Set<Id> userProfileIdSet=new Set<Id>();
            for(Profile proId : [SELECT id , Name  FROM Profile  WHERE Name IN: profileNameSet]){
                userProfileIdSet.add(proId.Id);
            }
            
            for(Id profileId : userProfileIdSet){
                User u1 = new User(Alias = 'newUser', Email= 'firstAE@intel.com',
                                   EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                                   LocaleSidKey='en_US', ProfileId = profileId,IsActive = true,
                                   TimeZoneSidKey='America/Los_Angeles', UserName = 'FirstAE@Intel.com' + Math.floor(Math.random() * 1000));
                
                userList.add(u1);
                User u2 = new User(Alias = 'newUser', Email= 'secondAE@intel.com',
                                   EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                                   LocaleSidKey='en_US', ProfileId = profileId,IsActive = true,
                                   TimeZoneSidKey='America/Los_Angeles', UserName = 'secondITS@Intel.com' + Math.floor(Math.random() * 1000));
                
                userList.add(u2);
            }   
            insert userList;
            
            List<PermissionSetAssignment> permissionList = new List<PermissionSetAssignment>();
            for(user userId : userList){
                permissionList.add(new PermissionSetAssignment(AssigneeId = userId.Id, PermissionSetId = cpqPermissionRec.Id));
                permissionList.add(new PermissionSetAssignment(AssigneeId = userId.Id, PermissionSetId = aePermissionSet.Id));
            }
            insert permissionList; 

            ChannelProgram cp = new ChannelProgram();
            cp.Name = 'Intel Quote Request';
            cp.IsActive = true;
            insert cp;

            Group grp = new Group();
            grp.Name = 'Test_Group1';
            grp.Type = 'Regular'; 
            insert grp;

            GroupMember grpMember = new GroupMember();
            grpMember.GroupId = grp.Id;
            grpMember.UserOrGroupId = salesRepUserList[0].Id;
            insert grpMember;

            Core_MDF_Partner_Group_Mapping__c partnerGroup = new Core_MDF_Partner_Group_Mapping__c();
            partnerGroup.Core_MDF_Account__c = acc.Id;
            partnerGroup.Core_MDF_Group_Id__c = grp.Id;
            partnerGroup.Core_MDF_Group_Name__c = grp.Name;
            partnerGroup.Core_MDF_Type_of_Access__c = 'Internal';
            partnerGroup.Core_MDF_Channel_Program__c = cp.Id;
            insert partnerGroup; 
            Test.stopTest();
        }
    }
    
    @isTest
    public static void testQuoteTeamSharingControllerTest(){
        List<SBQQ__Quote__c> lstquote = [SELECT Id,Name,Owner.Name,LastModifiedBy.Name,Pricing_Account_Executive_Nm__c,
                                         Pricing_Intel_Account_Exec_Email_Txt__c,Pricing_Customer_Nm__c,Pricing_Project_Name_Nm__c,Pricing_Bid_Dt__c FROM SBQQ__Quote__c];        
        List<SBQQ__QuoteLine__c> lstquoteLines = [SELECT Id,Name,SBQQ__Quote__r.Id,SBQQ__Quote__r.Name,SBQQ__Quote__r.Owner.Name,Pricing_pm_approval_comments_nm__c,
                                                  SBQQ__Quote__r.SBQQ__SalesRep__r.Name 
                                                  FROM SBQQ__QuoteLine__c LIMIT 1]; 
        Test.startTest();
        Pricing_Quote_Team__c qtm=Pricing_QuoteTeam_SharingController.createQuoteTeamMember('firstAE@intel.com',lstquote[0].Id,'Account Executive',false);
        List<Pricing_QuoteTeam_SharingController.QuoteTeamMember> qtmList=Pricing_QuoteTeam_SharingController.getQuoteTeam(lstquote[0].Id);
        List<String> teamMemberName = new List<String>();
        List<Pricing_Quote_Team__c> qtmList1 = [Select id,Pricing_Quote_Team_Member_Id__r.Email from Pricing_Quote_Team__c where Pricing_Quote_Team_Member_Id__r.Email='firstAE@intel.com' Limit 1 ];
        teamMemberName.add(qtmList1[0].Pricing_Quote_Team_Member_Id__c);
        Boolean isInternal = Pricing_QuoteTeam_SharingController.isInternal();
        Boolean isDPM = Pricing_QuoteTeam_SharingController.isDPMLegalFinanceUser();
        List<User> findRecords = Pricing_QuoteTeam_SharingController.findRecords('User');
        Pricing_QuoteTeam_SharingController.MessageOutput msgOutput = Pricing_QuoteTeam_SharingController.removeQuoteTeamMember(teamMemberName, lstquote[0].Id);
        System.assertEquals(msgOutput.isSuccess, true);
        Test.stopTest();
    }
    
    @isTest
    public static void testValidateFSE(){
        Test.startTest();
        List<SBQQ__Quote__c> lstquote = [SELECT Id,SBQQ__Account__c,Pricing_Intel_Sales_Rep_Email_Txt__c from SBQQ__Quote__c];
        List<User> salesRepUser = [SELECT Id,Email from User where Email IN ('firstNameSalesRep@intel.com' , 'firstNameFSE@intel.com')];
        List<Id> salesRepIds = New List<Id>();
        salesRepIds.add(salesRepUser[0].Id);
        salesRepIds.add(salesRepUser[1].Id);
        Set<Id> salesRepIdSet = New Set<Id>();
        salesRepIds.add(salesRepUser[0].Id);
        salesRepIds.add(salesRepUser[1].Id);
        Boolean isValidFSE = Pricing_QuoteTeam_SharingController.validateFSE('firstAE@intel.com',lstquote[0].Id);
        Boolean isValidAccountTeamFSE = Pricing_QuoteTeam_SharingController.validateFSE('firstNameSalesRep@intel.com',lstquote[0].Id);
        Pricing_QuoteTeam_SharingController.createQuoteTeamMember('firstNameSalesRep@intel.com',lstquote[0].Id,Label.Pricing_Quote_Team_Role_FSE,false);
        Pricing_QuoteTeam_SharingController.createQuoteTeamMember('firstAE@intel.com',lstquote[0].Id,Label.Pricing_Quote_Team_Role_FSE,false);
        //Pricing_QuoteTeam_SharingController.removeQuoteTeamMember(salesRepIds,lstquote[0].Id);
        List<Pricing_Quote_Team__c> qtm = new List<Pricing_Quote_Team__c>();
        Pricing_Quote_Team__c qtmObj = new Pricing_Quote_Team__c();
        qtmObj.Pricing_Quote_Team_Member_Id__c = salesRepUser[0].Id;
        qtmObj.Pricing_Quote_Id__c = lstquote[0].Id;
        qtmObj.Pricing_Role_Nm__c = Label.Pricing_Quote_Team_Role_FSE;
        insert qtmObj;
        qtm.add(qtmObj);
        List<Id> singleIdList = new List<Id>();
        singleIdList.add(qtm[0].Pricing_Quote_Team_Member_Id__c);
        Pricing_QuoteTeam_SharingController.removeQuoteTeamMember(singleIdList,lstquote[0].Id);
        Pricing_QuoteTeam_SharingController.getValidFSEUserIdSet(salesRepIdSet,lstquote[0].SBQQ__Account__c);
        Pricing_QuoteTeam_SharingController.getCurrentQuoteName(lstquote[0].Id);
        System.assertEquals(Pricing_QuoteTeam_SharingController.getCurrentQuoteName(lstquote[0].Id) != null, true);
        Test.stopTest();
    }
    
     @isTest
    public static void testRemoveQTMError(){
        Test.startTest();
        List<SBQQ__Quote__c> lstquote = [SELECT Id,SBQQ__Account__c,Pricing_Intel_Sales_Rep_Email_Txt__c from SBQQ__Quote__c];
        Pricing_Quote_Team__c qtm=Pricing_QuoteTeam_SharingController.createQuoteTeamMember('firstAE@intel.com',lstquote[0].Id,'Account Executive',false);
        try{
            Pricing_QuoteTeam_SharingController.removeQuoteTeamMember(new List<String>{'firstAE@intel.com'},'');
        }catch(Exception e){
            String msg = e.getMessage();
        }
        //System.assertEquals(Pricing_QuoteTeam_SharingController.getCurrentQuoteName(lstquote[0].Id) != null, true);
        Test.stopTest();
    }
    
    @isTest
    public static void testFSEtoGroupadd(){
        Test.startTest();
        List<SBQQ__Quote__c> lstquote = [SELECT Id,SBQQ__Account__c,Pricing_Intel_Sales_Rep_Email_Txt__c,SBQQ__SalesRep__c from SBQQ__Quote__c];
        List<User> salesRepUser = [SELECT Id,Email from User where Email IN ('firstNameSalesRep@intel.com' , 'firstNameFSE@intel.com')];
        List<Id> quoteIds = new List<Id>();

        Map<String, String> errorList1 = Pricing_QuoteTeam_SharingController.getQuoteFSEUsers(quoteIds);
        System.assertEquals(errorList1.get('type'), 'error');

        quoteIds.add(lstquote[0].Id);
        quoteIds.add(lstquote[1].Id);
        Map<String, String> errorList2 = Pricing_QuoteTeam_SharingController.getQuoteFSEUsers(quoteIds);
        System.assertEquals(errorList2.get('type'), 'info');

        Test.stopTest();
    }

    @isTest
    public static void testFSEtoGroupadd2(){
        User admUser = [SELECT Id,Email FROM User WHERE Email = 'firstName@intel.com'];
        Test.startTest();
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        List<User> salesRepUser = [SELECT Id,Email from User where Email = 'firstNameFSE@intel.com'];
        List<SBQQ__Quote__c> lstquote = Pricing_Test_Utility.createQuoteWithParam(acc.Id, con.Id, 2,salesRepUser[0].Email,'');
        //SBQQ__Quote__c quote = [SELECT Id FROM SBQQ__Quote__c WHERE Pricing_Intel_Sales_Rep_Email_Txt__c = 'firstNameSalesRep@intel.com' LIMIT 1];

        List<Id> quoteIds = new List<Id>();
        for(SBQQ__Quote__c qRec: lstquote){
            quoteIds.add(qRec.Id);
        }
        System.runAs(admUser){
            Map<String, String> errorList1 = Pricing_QuoteTeam_SharingController.getQuoteFSEUsers(quoteIds);
            System.assertEquals(errorList1.get('type'), 'success');
        }

        Test.stopTest();
    }
    
}