@isTest(SeeAllData=false)
public class CustomerDisclaimer_Test {
    @TestSetup public static void setUpData(){
        
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        //Creating User with utility class 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test';
        usr.UserRoleId = usRole.Id;
        Database.insert(usr);
        User usr1;
        System.runAs(usr){
            Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Test Account 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, 
                                                                            false);
            acc1.Core_MDF_CoMarketingAgency__c = TRUE;
            acc1.Core_Geo__c = 'EMEA';
            Database.insert(acc1);
            
            Contact con = Core_MDF_CCP_TestDataUtility.createContact (acc1.Id, false);
            con.RecordTypeId = Core_MDF_CCP_TestDataUtility.Intel_Contact_Record_Type;
            Database.insert(con);
            
            Profile partnerProfile = [SELECT Id FROM Profile WHERE Name='Partner' LIMIT 1];
            
            // Creating User with utility class 
            usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr1.LastName = 'User Test1';
            usr1.ProfileId = partnerProfile.Id;
            usr1.ContactId = con.Id;
            Database.insert(usr1);
            
            ChannelProgram retailCp = Core_MDF_CCP_TestDataUtility.createProgram ('Retail Marketing Funds','Retail Marketing Funds', true);
            
            Terms_and_Conditions__c tnc = new Terms_and_Conditions__c();
            tnc.Name = 'RMFCustomerDisclaimer_ENG';
            tnc.Channel_Program_id__c = retailCp.Id;
            tnc.Content_Language_nm__c ='English:en_US';
            tnc.Site_URL_txt__c = 'https://crmdevccp-intelcloudcrm.cs17.force.com/s/';
            tnc.Active_Indicator_ind__c = true;
            tnc.Custom_Permission_txt__c='Core_MDF_RMF_USER';
            tnc.Validity_in_mnths_nbr__c=12;
            tnc.NDA_Updated_Date_dt__c = System.Today();
            Database.insert(tnc);            
            
            PermissionSet retailPermissionSet = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_Retail_USER' LIMIT 1];
            
            Id cpId = [select Id from CustomPermission where DeveloperName = 'Core_MDF_RMF_USER'][0].Id;
            system.debug('cpId:'+cpId);
            if(cpId != null){
				SetupEntityAccess[] seaId = [Select id from SetupEntityAccess where SetupEntityId =:cpId limit 1]; 
					if(seaId.size() == 0){
					SetupEntityAccess sea = new SetupEntityAccess();
					sea.ParentId = retailPermissionSet.Id;
					sea.SetupEntityId = [select Id from CustomPermission where DeveloperName = 'Core_MDF_RMF_USER'][0].Id;
					insert sea;
				}
            }            
            PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = retailPermissionSet.Id, AssigneeId = usr1.Id);
            Database.insert(psa);
            
            
			ContentVersion cv = new ContentVersion();
			cv.Title = 'Test Document';
			cv.PathOnClient = 'TestDocument.html';
			cv.VersionData = Blob.valueOf('Test Content');
			cv.IsMajorVersion = true;
			Database.insert(cv);

			Terms_and_Conditions__c tc = [Select Id, Channel_Program_id__c,NDA_Updated_Date_dt__c,Validity_in_mnths_nbr__c, Custom_Permission_txt__c from Terms_and_Conditions__c Limit 1];    
			List<contentdocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
			System.assert(documents[0] != NULL);

			//create ContentDocumentLink  record 
			ContentDocumentLink cdl = new ContentDocumentLink();
			cdl.LinkedEntityId = tc.id;
			cdl.ContentDocumentId = documents[0].Id;
			cdl.Visibility ='AllUsers';
			Database.insert(cdl);
        }
	}
	@isTest
	public static void loginToCommunity(){
       
		User admUser = [SELECT Id FROM User WHERE LastName = 'User Test'];       
		Test.startTest();
		Terms_and_Conditions__c tc = [Select Id, Channel_Program_id__c,NDA_Updated_Date_dt__c,Validity_in_mnths_nbr__c, Custom_Permission_txt__c from Terms_and_Conditions__c Limit 1];    
		User user = [SELECT Id FROM User WHERE LastName = 'User Test1'];
        System.assert(tc!=null);
		System.runAs(user){
			List<Customer_Disclaimer__c> cd = new List<Customer_Disclaimer__c>();
			Map<Id,String> tncToURLMap = new Map<Id,String>();
			tncToURLMap.put(tc.Id,'https://crmdevccp-intelcloudcrm.cs17.force.com/s/');  
			Test.setMock(HttpCalloutMock.class, new Core_MDF_CustomerDisclaimer_Mock());
			
			CustomerDisclaimer.redirect('https://crmdevccp-intelcloudcrm.cs17.force.com/s/');
			CustomerDisclaimer.getResourceName('https://crmdevccp-intelcloudcrm.cs17.force.com/s/');
			CustomerDisclaimer.agreementSave(tncToURLMap);
			CustomerDisclaimer.redirect('Test');
			//To cover exception
			CustomerDisclaimer.getResourceName(NULL);
			cd = new List<Customer_Disclaimer__c>();
			CustomerDisclaimer.agreementSave(tncToURLMap);

			Map<Id,Datetime> tncToAcceptedDate = new Map<Id,Datetime>{};
			tncToAcceptedDate.put(tc.Id,system.today());

			Boolean toBeRedirected1 = CustomerDisclaimer.checkNDAValidity(cd,tc,tncToAcceptedDate);
			Test.stoptest();
       }
	}
    
    @isTest
    public static void testRedirect(){
		User admUser = [SELECT Id FROM User WHERE LastName = 'User Test'];       
		Terms_and_Conditions__c tc = [Select Id, Channel_Program_id__c,NDA_Updated_Date_dt__c,Validity_in_mnths_nbr__c, Custom_Permission_txt__c from Terms_and_Conditions__c Limit 1];    
		User user = [SELECT Id FROM User WHERE LastName = 'User Test1'];
        tc.NDA_Updated_Date_dt__c = null;
        update tc;
		Datetime dt =System.now()-366;

		Customer_Disclaimer__c cd = new Customer_Disclaimer__c();
		cd.Terms_and_Conditions_id__c = tc.Id;
		cd.User_id__c  = user.Id;
		cd.NDA_Acceptance_Date_dtm__c = dt;
		cd.Site_URL_txt__c  = 'https://crmdevccp-intelcloudcrm.cs17.force.com/s/';
		Database.insert(cd);
        Test.startTest();
		List<Customer_Disclaimer__c> cd1 = [Select Id,Name, Program_txt__c, NDA_Acceptance_Date_dtm__c, Terms_and_Conditions_id__c,User_id__c from Customer_Disclaimer__c where User_id__c =: user.Id Limit 1]; 
		System.assert(cd1 != NULL);
           
		tc.NDA_Updated_Date_dt__c = null;
		Database.update(tc);
		System.runAs(user){
			Map<Id,Datetime> tncToAcceptedDate = new Map<Id,Datetime>{};
			tncToAcceptedDate.put(tc.Id,system.today());
			Test.setMock(HttpCalloutMock.class, new Core_MDF_CustomerDisclaimer_Mock());  
			CustomerDisclaimer.redirect('https://crmdevccp-intelcloudcrm.cs17.force.com/s/');
			CustomerDisclaimer.redirect('Test');
			Boolean toBeRedirected2 = CustomerDisclaimer.checkNDAValidity(cd1,tc,tncToAcceptedDate);
			test.stopTest();
		}  
    }
}