@isTest(SeeAllData=false)
public class CustomerDisclaimer_Test {
    @TestSetup public static void setUpData(){
        
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        //Creating User with utility class 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test';
        usr.UserRoleId = usRole.Id;
        Database.insert(usr);
        List<User> usrList = new List<User>();
        System.runAs(usr){
            Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Test Account 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, 
                                                                            false);
            acc1.Core_MDF_CoMarketingAgency__c = false;
            acc1.Core_Geo__c = 'EMEA';
            Database.insert(acc1);
            
            List<Contact> conList = new List<Contact>();
            Contact con1 = Core_MDF_CCP_TestDataUtility.createContact (acc1.Id, false);
            con1.RecordTypeId = Core_MDF_CCP_TestDataUtility.Intel_Contact_Record_Type;
            conList.add(con1);
            Contact con2 = Core_MDF_CCP_TestDataUtility.createContact (acc1.Id, false);
            con2.RecordTypeId = Core_MDF_CCP_TestDataUtility.Intel_Contact_Record_Type;
            conList.add(con2);
            
            Database.insert(conList);
            
            Profile partnerProfile = [SELECT Id FROM Profile WHERE Name='Partner' LIMIT 1];
            
            // Creating User with utility class 
            User usr1 = new User();
            User usr2 = new User();
            usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr1.LastName = 'RetailUser Test1';
            usr1.ProfileId = partnerProfile.Id;
            usr1.ContactId = con1.Id;
            usrList.add(usr1);
            usr2 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr2.LastName = 'ccfdcfUser Test1';
            usr2.ProfileId = partnerProfile.Id;
            usr2.ContactId = con2.Id;
            usrList.add(usr2);
            Database.insert(usrList);
            List<NetworkMember> membership = [SELECT network.name,network.UrlPathPrefix, networkId, memberID FROM NetworkMember WHERE memberID = :usr1.id];
            ChannelProgram retailCp = Core_MDF_CCP_TestDataUtility.createProgram ('Retail Marketing Funds','Retail Marketing Funds', true);
            ChannelProgram ccfCp = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.CCF_PROGRAM,'Client CoMarketing Fund', true);
            ChannelProgram dcfCp = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.DCF_PROGRAM,'Data Center CoMarketing Fund', true);

            List<Terms_and_Conditions__c> tncList = new List<Terms_and_Conditions__c>();
            Terms_and_Conditions__c tnc = new Terms_and_Conditions__c();
            tnc.Name = 'RMFCustomerDisclaimer_ENG';
            tnc.Channel_Program_id__c = retailCp.Id;
            tnc.Content_Language_nm__c ='English:en_US';
            tnc.Site_URL_txt__c = 'https://crmdevccp-intelcloudcrm.cs17.force.com/s/';
            tnc.Active_Indicator_ind__c = true;
            tnc.Custom_Permission_txt__c='Core_MDF_RMF_USER';
            tnc.Validity_in_mnths_nbr__c=12;
            tnc.NDA_Updated_Date_dt__c = System.Today();
            //tnc.Core_MDF_Role_Access_txt__c = '';
            tncList.add(tnc);
            
            Terms_and_Conditions__c tnc2 = new Terms_and_Conditions__c();
            tnc2.Name = 'CCFCustomerDisclaimer_ENG';
            tnc2.Channel_Program_id__c = ccfCp.Id;
            tnc2.Content_Language_nm__c ='English:en_US';
            tnc2.Site_URL_txt__c = 'https://crmdevccp-intelcloudcrm.cs17.force.com/s/';
            tnc2.Active_Indicator_ind__c = true;
            tnc2.Custom_Permission_txt__c='Core_MDF_CCF_USER';
            tnc2.Validity_in_mnths_nbr__c=12;
            tnc2.NDA_Updated_Date_dt__c = System.Today();
            //tnc2.Core_MDF_Role_Access_txt__c = 'Core_MDF_CCP_Budget_Administrator';
            tncList.add(tnc2);
            
            Terms_and_Conditions__c tnc3 = new Terms_and_Conditions__c();
            tnc3.Name = 'DCFCustomerDisclaimer_ENG';
            tnc3.Channel_Program_id__c = dcfCp.Id;
            tnc3.Content_Language_nm__c ='English:en_US';
            tnc3.Site_URL_txt__c = 'https://crmdevccp-intelcloudcrm.cs17.force.com/s/';
            tnc3.Active_Indicator_ind__c = true;
            tnc3.Custom_Permission_txt__c='Core_MDF_DCF_USER';
            tnc3.Validity_in_mnths_nbr__c=12;
            tnc3.NDA_Updated_Date_dt__c = System.Today(); 
            //tnc3.Core_MDF_Role_Access_txt__c = 'Core_MDF_CCP_Budget_Administrator';
            tncList.add(tnc3);
            
            Database.insert(tncList);            
            
            PermissionSet retailPermissionSet = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_Retail_USER' LIMIT 1];
            PermissionSet ccfPermissionSet = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCF_USER' LIMIT 1];
            PermissionSet dcfPermissionSet = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_DCF_USER' LIMIT 1];
            PermissionSet budgetAdminPermissionSet = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_External_Account_Budget_Administrator' LIMIT 1];
            
            Id retailcpId = [select Id from CustomPermission where DeveloperName = 'Core_MDF_RMF_USER'][0].Id;
            Id ccfcpId = [select Id from CustomPermission where DeveloperName = 'Core_MDF_CCF_USER'][0].Id;
            Id dcfcpId = [select Id from CustomPermission where DeveloperName = 'Core_MDF_DCF_USER'][0].Id;
            Id budgetAdmincpId = [select Id from CustomPermission where DeveloperName = 'Core_MDF_CCP_Budget_Administrator'][0].Id;
            
            List<SetupEntityAccess> seaList = new List<SetupEntityAccess>();
            if(retailcpId != null){
                SetupEntityAccess[] retailseaId = [Select id from SetupEntityAccess where SetupEntityId =:retailcpId limit 1]; 
                    if(retailseaId.size() == 0){
                    SetupEntityAccess sea1 = new SetupEntityAccess();
                    sea1.ParentId = retailPermissionSet.Id;
                    sea1.SetupEntityId = [select Id from CustomPermission where DeveloperName = 'Core_MDF_RMF_USER'][0].Id;
                    seaList.add(sea1);
                }
            }  
            
            if(ccfcpId != null){
                SetupEntityAccess[] ccfseaId = [Select id from SetupEntityAccess where SetupEntityId =:ccfcpId limit 1]; 
                    if(ccfseaId.size() == 0){
                    SetupEntityAccess sea2 = new SetupEntityAccess();
                    sea2.ParentId = ccfPermissionSet.Id;
                    sea2.SetupEntityId = [select Id from CustomPermission where DeveloperName = 'Core_MDF_CCF_USER'][0].Id;
                    seaList.add(sea2);
                }
            }  
            
            if(dcfcpId != null){
                SetupEntityAccess[] dcfseaId = [Select id from SetupEntityAccess where SetupEntityId =:dcfcpId limit 1]; 
                    if(dcfseaId.size() == 0){
                    SetupEntityAccess sea3 = new SetupEntityAccess();
                    sea3.ParentId = dcfPermissionSet.Id;
                    sea3.SetupEntityId = [select Id from CustomPermission where DeveloperName = 'Core_MDF_DCF_USER'][0].Id;
                    seaList.add(sea3);
                }
            } 
            
            if(budgetAdmincpId != null){
                SetupEntityAccess[] budgetAdminseaId = [Select id from SetupEntityAccess where SetupEntityId =:budgetAdmincpId limit 1]; 
                    if(budgetAdminseaId.size() == 0){
                    SetupEntityAccess sea4 = new SetupEntityAccess();
                    sea4.ParentId = budgetAdminPermissionSet.Id;
                    sea4.SetupEntityId = [select Id from CustomPermission where DeveloperName = 'Core_MDF_CCP_Budget_Administrator'][0].Id;
                    seaList.add(sea4);
                }
            } 
            Database.insert(seaList);
            
            List<PermissionSetAssignment> psList = new List<PermissionSetAssignment>();
            PermissionSetAssignment psa1 = new PermissionSetAssignment(PermissionSetId = retailPermissionSet.Id, AssigneeId = usr1.Id);
            psList.add(psa1);
            PermissionSetAssignment psa2 = new PermissionSetAssignment(PermissionSetId = ccfPermissionSet.Id, AssigneeId = usr2.Id);
            psList.add(psa2);
            PermissionSetAssignment psa3 = new PermissionSetAssignment(PermissionSetId = dcfPermissionSet.Id, AssigneeId = usr2.Id);
            psList.add(psa3);
            PermissionSetAssignment psa4 = new PermissionSetAssignment(PermissionSetId = budgetAdminPermissionSet.Id, AssigneeId = usr2.Id);
            psList.add(psa4);
            
            Database.insert(psList);
            
            
            Group grp = new Group();
            grp.Name = 'PGM_TEST';
            //grp.DeveloperName = 'Core_CCP_CCF_External';
            Group grp1 = new Group();
            grp1.Name = 'PGM_TESTT';
            //grp1.DeveloperName = 'Core_CCP_DCF_External';
            
            List<Group> lstGroup = new List<Group>();
            lstGroup.add(grp);
            lstGroup.add(grp1);
            Database.insert(lstGroup);
            
            GroupMember grpMember = new GroupMember();
            grpMember.UserOrGroupId = usr2.Id;
            grpMember.GroupId = grp.Id;
                        
            GroupMember grpMember1 = new GroupMember();
            grpMember1.UserOrGroupId = usr2.Id;
            grpMember1.GroupId = grp1.Id;
            List<GroupMember> lstGrpMember = new List<GroupMember>();
            lstGrpMember.add(grpMember);
            lstGrpMember.add(grpMember1);
            Database.insert(lstGrpMember);
            
            List<Core_MDF_Partner_Group_Mapping__c> pgmList = new List<Core_MDF_Partner_Group_Mapping__c>();
            // Creating Partner Group Mapping
            Core_MDF_Partner_Group_Mapping__c pgm = new Core_MDF_Partner_Group_Mapping__c();
            pgm.Core_MDF_Account__c = acc1.Id;
            pgm.Core_MDF_Group_Name__c = 'PGM_TEST';
            pgm.Core_MDF_Type_of_Access__c = 'External';
            pgm.Core_MDF_Group_Id__c = grp.Id;                
            pgm.Core_MDF_Channel_Program__c = ccfCp.Id;
            pgm.Core_MDF_AccountIdGroupName__c = acc1.Id+'PGM_TEST';
            pgmList.add(pgm);
            
            Core_MDF_Partner_Group_Mapping__c pgm1 = new Core_MDF_Partner_Group_Mapping__c();
            pgm1.Core_MDF_Account__c = acc1.Id;
            pgm1.Core_MDF_Group_Name__c = 'PGM_TESTT';
            pgm1.Core_MDF_Type_of_Access__c = 'External';
            pgm1.Core_MDF_Group_Id__c = grp1.Id;                
            pgm1.Core_MDF_Channel_Program__c = dcfCp.Id;
            pgm1.Core_MDF_AccountIdGroupName__c = acc1.Id+'PGM_TESTT';
            pgmList.add(pgm1);
            Database.insert(pgmList);
            
            ContentVersion cv = new ContentVersion();
            cv.Title = 'Test Document';
            cv.PathOnClient = 'TestDocument.html';
            cv.VersionData = Blob.valueOf('Test Content');
            cv.IsMajorVersion = true;
            Database.insert(cv);

            Map<String,Id> custPermToTncId  = new Map<String,Id>();
            for(Terms_and_Conditions__c tc : [Select Id, Channel_Program_id__c,NDA_Updated_Date_dt__c,Validity_in_mnths_nbr__c, Custom_Permission_txt__c from Terms_and_Conditions__c Limit 3]){
                custPermToTncId.put(tc.Custom_Permission_txt__c,tc.Id);
            }    
            List<contentdocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument limit 3];
            System.assert(documents[0] != NULL);

            List<ContentDocumentLink> cdList = new List<ContentDocumentLink>();
            //create ContentDocumentLink  record for retail
            ContentDocumentLink cdl1 = new ContentDocumentLink();
            cdl1.LinkedEntityId = custPermToTncId.get('Core_MDF_RMF_USER');
            cdl1.ContentDocumentId = documents[0].Id;
            cdl1.Visibility ='AllUsers';
            cdList.add(cdl1);
            //create ContentDocumentLink  record for ccf
            ContentDocumentLink cdl2 = new ContentDocumentLink();
            cdl2.LinkedEntityId = custPermToTncId.get('Core_MDF_CCF_USER');
            cdl2.ContentDocumentId = documents[0].Id;
            cdl2.Visibility ='AllUsers';
            cdList.add(cdl2);
            //create ContentDocumentLink  record for dcf
            ContentDocumentLink cdl3 = new ContentDocumentLink();
            cdl3.LinkedEntityId = custPermToTncId.get('Core_MDF_DCF_USER');
            cdl3.ContentDocumentId = documents[0].Id;
            cdl3.Visibility ='AllUsers';
            cdList.add(cdl3);
            Database.insert(cdList);
        }
    }
    @isTest
    public static void loginToCommunity(){
       
        User admUser = [SELECT Id FROM User WHERE LastName = 'User Test' limit 1]; 
        ChannelProgram cp = [select id from channelprogram where Core_MDF_Technical_Program_Name__c='Retail Marketing Funds'];
        Test.startTest();
        Terms_and_Conditions__c tc = [Select Id, Channel_Program_id__c,NDA_Updated_Date_dt__c,Validity_in_mnths_nbr__c, Custom_Permission_txt__c from Terms_and_Conditions__c
                                      where Channel_Program_id__c =: cp.Id Limit 1];    
        User user = [SELECT Id FROM User WHERE LastName = 'RetailUser Test1' limit 1];
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
    public static void testCCFDCFRedirect(){
        List<Id> cpIdList = new List<Id>();
        for(ChannelProgram cp : [select id from channelprogram where Core_MDF_Technical_Program_Name__c in ('Client CoMarketing Fund','Data Center CoMarketing Fund')]){
            cpIdList.add(cp.Id);
        }
        User admUser = [SELECT Id FROM User WHERE LastName = 'User Test' limit 1];       
        Test.startTest();
        List<Terms_and_Conditions__c> tc = [Select Id, Channel_Program_id__c,NDA_Updated_Date_dt__c,Validity_in_mnths_nbr__c, Custom_Permission_txt__c from Terms_and_Conditions__c
                                      where Channel_Program_id__c in :cpIdList Limit 2];    
        User user = [SELECT Id FROM User WHERE LastName = 'ccfdcfUser Test1' limit 1];
        System.assert(tc!=null);
        System.runAs(user){
       // CustomerDisclaimer.checkForInitialRedirect();
        CustomerDisclaimer.redirect('https://crmdevccp-intelcloudcrm.cs17.force.com/s/');
        CustomerDisclaimer.getResourceName('https://crmdevccp-intelcloudcrm.cs17.force.com/s/');
        Test.stoptest();
        }
    }
    
    
    @isTest
    public static void testRedirect(){
        User admUser = [SELECT Id FROM User WHERE LastName = 'User Test' limit 1];
        ChannelProgram cp = [select id from channelprogram where Core_MDF_Technical_Program_Name__c='Retail Marketing Funds'];
        Terms_and_Conditions__c tc = [Select Id, Channel_Program_id__c,NDA_Updated_Date_dt__c,Validity_in_mnths_nbr__c, Custom_Permission_txt__c from Terms_and_Conditions__c
                                      where Channel_Program_id__c =: cp.Id Limit 1];    
        User user = [SELECT Id FROM User WHERE LastName = 'RetailUser Test1' limit 1];
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