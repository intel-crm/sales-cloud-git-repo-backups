@isTest
public class PCC_RC_EmailAlertController_Test {
    
    public static User usr = new User();
    
    @isTest
    public static void testRCEmailAlert(){
        
        Test.StartTest();
        List<PCC_Rebate_Claim__c> lstPCC_Rebate_Claim = [SELECT Id FROM PCC_Rebate_Claim__c  LIMIT 1];
        PCC_RebateClaimEmailAlertController p1 = new PCC_RebateClaimEmailAlertController();
        if (lstPCC_Rebate_Claim.size()>0)
        {
            p1.rebateClaimId = lstPCC_Rebate_Claim[0].Id;
        }
        Test.StopTest();
    }
    
    @testSetup
    public static void setUpData(){
        List<User> lstUsers2 = Pricing_Test_Utility.createAdminUser();  
        insert (new SBQQ__QuoteTemplate__c(Name = 'IQR Quote Template'));        
        System.runAs(lstUsers2[0])
        {
            
            Pricing_Test_Utility.createPriceBook();            
            Account acc = Pricing_Test_Utility.createAccount();           
            Contact con = Pricing_Test_Utility.createPrimaryContact(acc.Id);
            Pricing_Test_Utility.createTemplate(lstUsers2[0].id);          
            List<User> accountExecutiveUserList = Pricing_Test_Utility.createAEUser();
            List<User> salesRepUserList = Pricing_Test_Utility.createSalesRepUser();
            AccountTeamMember accTeam = new AccountTeamMember(AccountId = acc.Id,
                                                              TeamMemberRole = 'Technical Sales',UserId = salesRepUserList[0].Id);
            insert accTeam;
            Test.StartTest();  
            List<SBQQ__Quote__c> lstquote = Pricing_Test_Utility.createQuoteWithParam(acc.Id, con.Id, 1,salesRepUserList[0].Email,accountExecutiveUserList[0].Email);
            List<SBQQ__QuoteLine__c> lstquoteline = Pricing_Test_Utility.createQuoteLines(lstquote[0].id, 1);
            Test.StopTest();  
            User partnerUser = Pricing_Test_Utility.createPartnerUser(acc.Id);
            
            
            //List<Account> accList = [Select id from Account where id=:lstquote[0].SBQQ__Account__c LIMIT 1];
            List<AccountTeamMember> teamList = new List<AccountTeamMember>();
            AccountTeamMember accountTeamMember=new AccountTeamMember(AccountId=acc.Id,TeamMemberRole = 'Technical Sales',UserId = lstUsers2[0].id);
            insert accountTeamMember;
            teamList.add(accountTeamMember);
            
            Group grp = Pricing_Test_Utility.createGroupRecord();
            
            //Create Group Member
            GroupMember grpMem1 = new GroupMember();
            grpMem1.UserOrGroupId = lstUsers2[0].id;
            grpMem1.GroupId = grp.Id;
            Insert grpMem1;         
        }
    }
    @isTest
    public static void testOppEmailAlert(){
        Core_Opp_Bypass_Validation_Rule__c rec = new Core_Opp_Bypass_Validation_Rule__c();
        rec.Bypass__c = true;
        insert rec;  
        Profile pr = [SELECT id, Name FROM Profile WHERE Name='IT Admin'];
        usr = [SELECT id, Name, email, isActive FROM User WHERE ProfileId = :pr.Id AND isActive = true LIMIT 1];  
        
        
        Product2 p = new Product2(Name = 'TestPro05-26-2024');
        insert p;
        PricebookEntry pbe = new PricebookEntry(Product2Id = p.Id, Pricebook2Id = Test.getStandardPricebookId(),
                                                UnitPrice = 10, IsActive = true);
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert pbe;
        }
        List<Account> acc= [select Id from Account limit 1];
        Opportunity opportunityInstance = new Opportunity();
        opportunityInstance.CloseDate = System.Today().addDays(24);
        opportunityInstance.StageName = 'Qualify';
        opportunityInstance.Name = 'TestRE1';
        opportunityInstance.Core_External_User__c=true;
        opportunityInstance.AccountId = acc[0].id;
        opportunityInstance.Core_Product_Segment__c='Client Computing';
        opportunityInstance.Core_Consumption_Market__c = 'Education';
        opportunityInstance.Core_Product_Application__c ='Business Mobility';
        opportunityInstance.Core_Opportunity_Type__c = 'Design: Original';
        opportunityInstance.Core_Opportunity_Coverage_Nm__c = 'Intel-Led Opportunity';
        opportunityInstance.Description = 'test';
        opportunityInstance.Core_IsClone__c = False;
        opportunityInstance.OwnerId= UserInfo.getUserId();
        insert opportunityInstance;
      
        List<SBQQ__QuoteLine__c> lstquoteLines = new List<SBQQ__QuoteLine__c>([select id,Pricing_Quote_Line_Number__c from SBQQ__QuoteLine__c limit 1]);     
        Test.StartTest();  
        PCC_Rebate_Claim__c rcInstance = new PCC_Rebate_Claim__c();
        rcInstance.PCC_Claim_Status__c = 'Draft';       
        rcInstance.PCC_Partner__c  = acc[0].Id;
        insert rcInstance; 
        PCC_Rebate_Claim_Line_Item__c rc_line = new PCC_Rebate_Claim_Line_Item__c();
        rc_line.PCC_Rebate_Claim__c = rcInstance.Id;
        rc_line.PCC_Quote_Line_Number__c = 	lstquoteLines[0].Id;
        rc_line.PCC_Opportunity__c= opportunityInstance.Id;
        rc_line.PCC_Product__c= p.Id;        
        rc_line.PCC_Quantity__c= 100;
        rc_line.PCC_Invoice__c= '2000'; 
        rc_line.PCC_OEM_Name__c = 'DELL';
        
        rc_line.PCC_Status__c = 'Submitted';
        rc_line.PCC_Invoice_Date__c = System.today();
        rc_line.PCC_Claimed_Rebate_Amount__c = 50000;
        insert rc_line;
        
        rcInstance.PCC_Claim_Status__c = 'Claim Submitted';
        rcInstance.PCC_Submitted_By__c = usr.Id;
        update rcInstance; 
        
        PCC_RebateClaimEmailAlertController rcEmailNotification =new PCC_RebateClaimEmailAlertController();
        System.runAs(Core_Test_Utility.systemAdminUser){
            rcEmailNotification.getDomainName();
            rcEmailNotification.getDealRegExternalDomainName();
            string headerURL = rcEmailNotification.getHeaderURL(); 
        }
        
        rcEmailNotification.rebateClaimId= rcInstance.Id;
        rcEmailNotification.getRebateClaimData();
        List<PCC_Rebate_Claim_Line_Item__c> data= new List<PCC_Rebate_Claim_Line_Item__c>();
        
        data= rcEmailNotification.getRebateClaimLineData();
        
        //Negative testing 
        rcEmailNotification.rebateClaimId= '0012D00000OmHaeQAF';
        rcEmailNotification.getRebateClaimData();
        data= rcEmailNotification.getRebateClaimLineData();
       
        Test.StopTest();
    }
    
}