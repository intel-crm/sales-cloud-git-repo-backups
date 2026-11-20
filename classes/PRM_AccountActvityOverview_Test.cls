@isTest

private class PRM_AccountActvityOverview_Test{
    
    @isTest 
    static void testPointsWrapper(){
        
        PRM_AccountActvityOverview.responseWrapper wrap = new PRM_AccountActvityOverview.responseWrapper();
        
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Id recordTypeIdPagAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
 
        
        Account newPagAccount = new Account();//Account
        newPagAccount.RecordTypeId = recordTypeIdPagAccount;
        newPagAccount.Name='Greg Thomas';
        newPagAccount.BillingCity='City';
        newPagAccount.BillingStreet='Street';
        newPagAccount.BillingCountry='India';
        newPagAccount.AccountNumber = '1231222132';
        newPagAccount.BillingPostalCode='Postal code';
        newPagAccount.Core_Account_Type__c='Intel Authorized Distributor (IAD);Intel Approved Device Supplier (IADS)';
        insert newPagAccount;
        
         Account newAccount = new Account();//Account
        newAccount.RecordTypeId = recordTypeIdAccount;
        newAccount.Name='Greg Thomas222';
        newAccount.BillingCity='City2';
        newAccount.BillingStreet='Street2';
        newAccount.BillingCountry='India';
        newAccount.AccountNumber = '3123123123';
        newAccount.BillingPostalCode='123456';
        newAccount.Core_Account_Type__c='Intel Authorized Distributor (IAD);Intel Approved Device Supplier (IADS)';
        newAccount.Core_OnePartnerID__c=newPagAccount.Id;
        insert newAccount;
        
        PRM_Points_Data__c pd = new PRM_Points_Data__c();
        pd.PRM_Total_Points_Available_Nbr__c = 200;
        pd.PRM_Total_Points_Earned_Nbr__c = 100;
        pd.PRM_Total_Points_Expired_Nbr__c = 70;
        pd.PRM_Total_Points_Redeemed_Nbr__c = 30;
        pd.PRM_Points_Balance__c=40;
        pd.PRM_Account_Id__c = newAccount.id;
        pd.PRM_One_Partner_Id__c = newPagAccount.id;
        insert pd;
        
        ChannelProgram cp = new ChannelProgram(); //Channel Program
        cp.Name='Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        insert cp;
        //Test Data for Program
        List<ChannelProgramLevel> cplList =new List<ChannelProgramLevel>();
        ChannelProgramLevel cpl=new ChannelProgramLevel(); //Channel Program Level
        cpl.Name='Partner';//'Member';
        cpl.ProgramId=cp.Id;
        cplList.add(cpl);
        
        ChannelProgramLevel cpl2=new ChannelProgramLevel(); //Channel Program Level
        cpl2.Name='Partner';//'Gold';
        cpl2.ProgramId=cp.Id;
        cplList.add(cpl2);
        
        ChannelProgramLevel cpl3=new ChannelProgramLevel(); //Channel Program Level
        cpl3.Name='Prestige';
        cpl3.ProgramId=cp.Id;
        cplList.add(cpl3);
        
        insert cplList;
        PMP_Company__c company1=new PMP_Company__c();
        company1.Name='TestCompany12';
        company1.PMP_Benefit_Update_Ind__c=False;
        company1.PMP_Partner_Inactive_Ind__c = False;
        company1.PMP_Company_Lifecycle_Status_Nm__c =PMP_StaticConstants_Partner.Published;
        company1.PMP_Partner_Benefit_Type__c = 'Solutions Marketplace Basic Profile';
        company1.PMP_Is_Published_Ind__c=true;
        insert company1;
        
        PMP_OPID_MPI_Rel__c jun1= new PMP_OPID_MPI_Rel__c();
        jun1.PMP_One_Partner_ID__c= newAccount.Id;
        jun1.PMP_Marketing_Profile_Id__c= company1.Id;
        jun1.Is_Active__c=true;     
        insert jun1;
        
        PRM_Value_Exchange_Data__c vxData = new PRM_Value_Exchange_Data__c();
        vxData.PRM_Sales_Amount_Report_Nbr__c = 12000;
        vxData.PRM_Training_Credit_Points_Report_Nbr__c = 20000;
        vxData.PRM_Account_Id__c = newAccount.id;
        vxData.PRM_One_Partner_Id__c = newPagAccount.id;
        vxData.PRM_Change_Date_Dt__c = System.today();
        vxData.PRM_Country_Market_Type_Nm__c = 'Emerging';
        vxData.PRM_From_Dt__c = Date.Today().addYears(-3);
        vxData.PRM_Partner_Role_Nm__c = 'Solution Integrator';
        vxData.PRM_Tier_Id__c = cplList[0].Id;
        vxData.PRM_To_Dt__c = Date.Today().addYears(-2);
        vxData.PRM_Sales_Calculation_Group_Txt__c = 'Component';
        vxData.PRM_Training_Credit_Points_Count_Nbr__c = 100;
        vxData.PRM_TimePeriod_Nm__c=system.Label.PRM_Previous_Measurement_Period;
        vxData.PRM_Sales_Amount_Nbr__c=10000;
        insert vxData;
        
        PRM_Value_Exchange_Data__c vxData1 = new PRM_Value_Exchange_Data__c();
        vxData1.PRM_Sales_Amount_Report_Nbr__c = 12000;
        vxData1.PRM_Training_Credit_Points_Report_Nbr__c = 20000;
        vxData1.PRM_Account_Id__c = newAccount.id;
        vxData1.PRM_One_Partner_Id__c = newPagAccount.id;
        vxData1.PRM_Change_Date_Dt__c = System.today();
        vxData1.PRM_Country_Market_Type_Nm__c = 'Emerging';
        vxData1.PRM_From_Dt__c = Date.Today().addYears(-4);
        vxData1.PRM_Partner_Role_Nm__c = 'Solution Integrator';
        vxData1.PRM_Tier_Id__c = cplList[0].Id;
        vxData1.PRM_To_Dt__c = Date.Today().addYears(-3);
        vxData1.PRM_Sales_Calculation_Group_Txt__c = 'Component1';
        vxData1.PRM_Training_Credit_Points_Count_Nbr__c = 1000;
        vxData1.PRM_TimePeriod_Nm__c=System.label.PRM_Current_measurement_period;
        vxData1.PRM_Sales_Amount_Nbr__c=20000;
        insert vxData1;
        
        PRM_Warranty_Data__c uxData=new PRM_Warranty_Data__c();
        uxData.PRM_Number_Of_AWR_Remaining_Nbr__c=100;
        uxData.PRM_Number_Of_AWR_Used_Nbr__c=200;
        uxData.PRM_Account_Id__c = newAccount.id;
        uxData.PRM_One_Partner_Id__c=newPagAccount.id;
        uxData.PRM_As_of_Date_Dt__c=Date.Today();
        insert uxData;   
        
        Core_Account_Group_Member__c cag = new Core_Account_Group_Member__c();
        cag.Core_Intel_Account_Id__c = newAccount.id;
        cag.Core_Partner_Account_Id__c = newPagAccount.Id;
        insert cag;
        
        PMP_Company__c mpiRecord1 = new PMP_Company__c(Name = 'MPI of Partner Account 1', PMP_Account_Id__c = newPagAccount.Core_IPA_One_Partner_Id__c, PMP_Company_Lifecycle_Status_Nm__c = 'Draft', PMP_Is_Published_Ind__c = true, PMP_Is_Working_Copy_Ind__c = true,PMP_Partner_Benefit_Type__c = 'Solutions Marketplace Enhanced');
        insert mpiRecord1;
        PMP_OPID_MPI_Rel__c opidMPIRelationship1 = new PMP_OPID_MPI_Rel__c(PMP_Marketing_Profile_Id__c = mpiRecord1.Id, PMP_One_Partner_ID__c = newPagAccount.Id, Is_Active__c = true);
        insert opidMPIRelationship1;
             
        Id locId = newAccount.Id;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
      //system.debug('locId-->'+locId);
        PRM_AccountActvityOverview.displayPointsData(locId);  
        PRM_AccountActvityOverview.displayPointsData(newPagAccount.Id);
        
        List<PRM_Points_Data__c> pointsDataList = new List<PRM_Points_Data__c>();
        for(PRM_Points_Data__c point : [Select Id from PRM_Points_Data__c]){
            point.PRM_Business_Id__c = null;
            point.PRM_Total_Points_Due_to_Expire_Nbr__c = null;
            point.PRM_Points_Balance__c = null;
            point.DQ_Flag__c = true;
            pointsDataList.add(point); 
        }
        
      	update pointsDataList;
        Test.stopTest();
        PRM_AccountActvityOverview.displayPointsData(locId);
        PRM_AccountActvityOverview.displayPointsData(newPagAccount.Id);
        //String accId = PRM_AccountActvityOverview.getAccountId();
        
        
    }
    @isTest static void createSyncReqMethodPointsData(){
        
        
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Id recordTypeIdPagAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
        //Account acc = [SELECT id,Core_OnePartnerID__c FROM Account WHERE BillingStreet ='Mock' LIMIT 1];
        
        Account newPagAccount = new Account();//Account
        newPagAccount.RecordTypeId = recordTypeIdPagAccount;
        newPagAccount.Name='testpointopid99';
        newPagAccount.BillingCity='test new City9';
        newPagAccount.BillingStreet='test new Street9';
        newPagAccount.BillingCountry='India';
        newPagAccount.BillingPostalCode='999986';
        insert newPagAccount;
         
        Account newAccount = new Account();//Account
        newAccount.RecordTypeId = recordTypeIdAccount;
        newAccount.Name='testPointIntel84';
        newAccount.BillingCity='new City27';
        newAccount.BillingStreet='new Street27';
        newAccount.BillingCountry='India';
        newAccount.BillingPostalCode='657851';
        newAccount.Core_OnePartnerID__c=newPagAccount.Id;
        insert newAccount;
        
        Contact cont = new Contact();  //Contact
        cont.AccountId=newAccount.Id;
        cont.lastName='Grill';
        cont.FirstName='Adam';
        cont.email='AdamGrill@rediff.com';
        cont.Core_Job_Function__c='Branch Manager';
        //cont.Core_Profession__c='Sales';
        cont.Core_IPA_PartnerRole__c='Service Provider';
        cont.Core_eRPM_Language_Code__c='Eng';
        cont.MailingCountryCode = 'USA';
        insert cont;
        
        String replacedjson = '<bizid>30000005712</bizid><current_balance>0</current_balance><qtr_due_to_expire_points>0</qtr_due_to_expire_points><opening_balance>0</opening_balance><data_correctness>1</data_correctness><function>getMemberBalance12</function><requestid>21639128631289632</requestid>'+
        '<bizid>30000009272</bizid><current_balance>500</current_balance><qtr_due_to_expire_points>0</qtr_due_to_expire_points><opening_balance>500</opening_balance><data_correctness>1</data_correctness><function>getMemberBalance12</function><requestid>21639128631289632</requestid>';
        
            //Profile communityUsrProfile = [SELECT id FROM Profile WHERE Name='Partner'];
            //UserRole r = [Select Id From UserRole Where PortalType = 'Partner' Limit 1];
            //system.debug('role-->'+r);
            //system.debug('communityUsrProfile-->'+communityUsrProfile);
            /*User partnerUser = new User(FirstName='MrTest',LastName='User',alias='t2user',Email='mrtestuser@mailinator.com',
                                        UserName='test2usr@xyz.com', ContactId=cont.Id,ProfileId=communityUsrProfile.Id,IsActive = true,
                                        emailencodingkey='UTF-8', languagelocalekey='en_US', localesidkey='en_US',timezonesidkey='Europe/London');//, UserRoleId = r.id);*/
            test.startTest();
            //insert partnerUser;
            createPortalUser(cont.Id, 'XYZ');
            test.stopTest();
            User u = [select id,IsPortalEnabled from user where email = 'XYZmrtestuser99@mailinator.com' LIMIT 1];
          //system.debug('partnerUser-->'+u.IsPortalEnabled);
            System.runAs(u){
            
            //partnerUser.IsPortalEnabled = true;
            //update partnerUser;
            //system.debug('partnerUserrole1-->'+partnerUser.UserRoleId);
            //system.debug('partnerUser1-->'+partnerUser.IsPortalEnabled);
            //System.runAs(partnerUser){
            
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorCIMData()); 
            PRM_AccountActvityOverview.createRealTimePointDataRecord(replacedjson,newAccount);  
            PRM_AccountActvityOverview.createRealTimePointDataRecord(replacedjson,null);  
            
            }
            
        //}
    }
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            if (req.getEndpoint().endsWith('token')) {
                HttpResponse res = new HttpResponse();
              res.setHeader('Content-Type', 'application/json');
              res.setBody('{"access_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImtpZCI6Im5Pbz","token_type": "Bearer","expires_in": "3599","ext_expires_in": "3599"}');
              res.setStatusCode(200);
              return res;
            }
            else{
                HttpResponse res = new HttpResponse();
              res.setHeader('Content-Type', 'application/json');
                res.setBody('<?xml version="1.0" encoding="UTF-8"?> <response><bizid>30000009272</bizid><current_balance>500</current_balance><qtr_due_to_expire_points>0</qtr_due_to_expire_points><opening_balance>500</opening_balance><data_correctness>1</data_correctness><function>getMemberBalance12</function><requestid>21639128631289632</requestid></response>');
              res.setStatusCode(200);
                return res;
            }
        }
    }
        
    @isTest static void createSyncReqMethod1(){
     
     Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
     Id recordTypeIdPagAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
     //Account acc = [SELECT id,AccountNumber,Core_OnePartnerID__c FROM Account WHERE name ='Greg Thomas222' LIMIT 1]; 
     
        ChannelProgram cp = new ChannelProgram(); //Channel Program
        cp.Name='Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        insert cp;
        //Test Data for Program
        List<ChannelProgramLevel> cplList =new List<ChannelProgramLevel>();
        ChannelProgramLevel cpl=new ChannelProgramLevel(); //Channel Program Level
        cpl.Name='Partner';
        cpl.ProgramId=cp.Id;
        cplList.add(cpl);
        insert cplList;
     Account newPagAccount = new Account();//Account
     newPagAccount.RecordTypeId = recordTypeIdPagAccount;
     newPagAccount.Name='testpointopid';
     newPagAccount.BillingCity='test new City';
     newPagAccount.BillingStreet='test new Street';
     newPagAccount.BillingCountry='India';
     newPagAccount.BillingPostalCode='999987';
     insert newPagAccount;
     
     Account newAccount = new Account();//Account
     newAccount.RecordTypeId = recordTypeIdAccount;
     newAccount.Name='testPointIntel';
     newAccount.BillingCity='new City2';
     newAccount.BillingStreet='new Street2';
     newAccount.BillingCountry='India';
     newAccount.BillingPostalCode='657854';
     newAccount.Core_OnePartnerID__c=newPagAccount.Id;
     insert newAccount;
        
     PRM_Value_Exchange_Data__c vxData1 = new PRM_Value_Exchange_Data__c();
        vxData1.PRM_Sales_Amount_Report_Nbr__c = 12000;
        vxData1.PRM_Training_Credit_Points_Report_Nbr__c = 20000;
        vxData1.PRM_Account_Id__c = newAccount.id;
        vxData1.PRM_One_Partner_Id__c = newPagAccount.id;
        vxData1.PRM_Change_Date_Dt__c = System.today();
        vxData1.PRM_Country_Market_Type_Nm__c = 'Emerging';
        vxData1.PRM_From_Dt__c = Date.Today().addYears(-4);
        vxData1.PRM_Partner_Role_Nm__c = 'Solution Integrator';
        vxData1.PRM_Tier_Id__c = cplList[0].Id;
        vxData1.PRM_To_Dt__c = Date.Today().addYears(-3);
        vxData1.PRM_Sales_Calculation_Group_Txt__c = 'Component1';
        vxData1.PRM_Training_Credit_Points_Count_Nbr__c = 1000;
        vxData1.PRM_TimePeriod_Nm__c=Label.PRM_Current_measurement_period;
        vxData1.PRM_Sales_Amount_Nbr__c=20000;
        insert vxData1;
     PRM_RealTimePointsData__c rtpd = new PRM_RealTimePointsData__c();
     rtpd.PRM_AccountBizId__c = newAccount.AccountNumber;
     rtpd.PRM_AccountId__c = newAccount.Id;
     rtpd.PRM_Response__c = '';
     rtpd.PRM_Status__c = 'Success';
     insert rtpd;
     
     Contact cont = new Contact();  //Contact
        cont.AccountId=newAccount.Id;
        cont.lastName='Grill99';
        cont.FirstName='Adam3';
        cont.email='testAdamGrill9@rediff.com';
        cont.Core_Job_Function__c='Branch Manager';
        //cont.Core_Profession__c='Sales';
        cont.Core_IPA_PartnerRole__c='Service Provider';
        cont.Core_eRPM_Language_Code__c='Eng';
        cont.MailingCountry='USA';
        cont.MailingCountryCode = 'USA';
        insert cont;
        
        //UserRole r = new UserRole(DeveloperName = 'SalesPartnerPartnerUser', Name = 'Sales Partner Sales Partner Partner User');
        
        //Profile communityUsrProfile = [SELECT id FROM Profile WHERE Name='Partner'];
        /*User partnerUser = new User(FirstName='MrTest99',LastName='User99',alias='t2user99',Email='mrtestuser99@mailinator.com',
                                    UserName='test2usr99@xyz.com', ContactId=cont.Id,ProfileId=communityUsrProfile.Id,IsActive = true,
                                    emailencodingkey='UTF-8', languagelocalekey='en_US', localesidkey='en_US',timezonesidkey='Europe/London');//, UserRoleId = r.id);*/
        
        //insert partnerUser;
        //partnerUser.IsPortalEnabled = true;
        test.startTest();
        //update partnerUser;
       //system.debug('partnerUser2-->'+partnerUser.IsPortalEnabled);       
     //system.debug('newAccount-->'+newAccount);
       createPortalUser(cont.Id, 'abc');
       Test.Stoptest();
       Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator1());
       User portalUser = [select id,IsPortalEnabled, UserRole.PortalType, UserRole.PortalRole from user where email = 'abcmrtestuser99@mailinator.com' LIMIT 1];
     //system.debug('partnerUser2-->'+portalUser.IsPortalEnabled);
       System.runAs(portalUser){
           
           PRM_AccountActvityOverview.getAccountId();
           PRM_AccountActvityOverview.displayPointsData(newPagAccount.Id);
           PRM_AccountActvityOverview.displayPointsData(newAccount.Id);
           PRM_AccountActvityOverview.displayPointsData(null);
          
       }
           
    }
    @isTest static void createSyncReqMethod2(){
       
       Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
       Id recordTypeIdPagAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
       Account newPagAccount = new Account();//Account
         newPagAccount.RecordTypeId = recordTypeIdPagAccount;
         newPagAccount.Name='testpointopid77';
         newPagAccount.BillingCity='test new City77';
         newPagAccount.BillingStreet='test new Street77';
         newPagAccount.BillingCountry='India';
         newPagAccount.BillingPostalCode='954987';
         insert newPagAccount;
         
         Account newAccount = new Account();//Account
         newAccount.RecordTypeId = recordTypeIdAccount;
         newAccount.Name='testPointInte34';
         newAccount.BillingCity='new City34';
         newAccount.BillingStreet='new Street34';
         newAccount.BillingCountry='India';
         newAccount.BillingPostalCode='656654';
         newAccount.Core_OnePartnerID__c=newPagAccount.Id;
         insert newAccount;
       //Account acc = [SELECT id,Core_OnePartnerID__c FROM Account LIMIT 1]; 
        test.startTest();
       Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator1());
     //system.debug('newAccount-->'+newAccount);
       PRM_AccountActvityOverview.displayPointsData(newAccount.Id);
       test.stopTest();
    }
    public class MockHttpResponseGeneratorCIMData implements HttpCalloutMock {
        
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            if (req.getEndpoint().endsWith('token')) {//one-partner-id
              HttpResponse res = new HttpResponse();
              res.setHeader('Content-Type', 'application/xml');
              res.setBody('{"access_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImtpZCI6Im5Pbz","token_type": "Bearer","expires_in": "3599","ext_expires_in": "3599"}');
              res.setStatusCode(200);
              return res;
            }
            else{
                HttpResponse res = new HttpResponse();
                res.setHeader('Content-Type', 'application/xml');
                res.setBody('<bizid>30000009272</bizid><current_balance>500</current_balance><qtr_due_to_expire_points>0</qtr_due_to_expire_points><opening_balance>500</opening_balance><data_correctness>1</data_correctness><function>getMemberBalance12</function><requestid>21639128631289632</requestid>');
                res.setStatusCode(200);
                return res;
            }
        }
    }
    public class MockHttpResponseGenerator1 implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            if(req.getEndpoint().endsWith('auth/token')){
                HttpResponse res = new HttpResponse();
                res.setHeader('Content-Type', 'application/xml');
                res.setBody('{"access_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImtpZCI6Im5Pbz","token_type": "Bearer","expires_in": "3599","ext_expires_in": "3599"}');
                res.setStatusCode(200);
                return res;
            }else{
                HttpResponse res = new HttpResponse();
                res.setHeader('Content-Type', 'application/xml');
                res.setBody('{"access_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImtpZCI6Im5Pbz","token_type": "Bearer","expires_in": "3599","ext_expires_in": "3599"}');
                res.setStatusCode(401);
                return res;
            }
            
        }
    }
    @future
    public static void createPortalUser(Id conId, String uniquekey){
        String accId = [Select id,AccountId from Contact where Id =: conId].AccountId;
        //UserRole r = [Select Id From UserRole Where PortalType = 'Partner' and PortalRole = 'Worker' and PortalAccountId =: accId limit 1];
        Profile communityUsrProfile = [SELECT id FROM Profile WHERE Name='Partner'];
        User partnerUser = new User(FirstName='MrTest99',LastName='User99',alias='t2user99',Email=uniquekey+'mrtestuser99@mailinator.com',
                                    UserName=uniquekey+'test2usr99@xyz.com', ContactId=conId,ProfileId=communityUsrProfile.Id,IsActive = true,//UserRoleId = r.Id,
                                    emailencodingkey='UTF-8', languagelocalekey='en_US', localesidkey='en_US',timezonesidkey='Europe/London');
        
        insert partnerUser;
    }
}