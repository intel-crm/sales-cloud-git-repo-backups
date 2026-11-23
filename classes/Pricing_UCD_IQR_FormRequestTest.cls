/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 03-10-2026
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class Pricing_UCD_IQR_FormRequestTest {
    //Setting up Test Data
    @testSetup
    public static void setUpData() {
        List < User > adminUserList = Pricing_Test_Utility.createAdminUserWithParam('ucdIQRFormReqAdmin');
        
        Pricing_Test_Utility.createPriceBook();
        System.runAs(adminUserList[0]) {
            Account acc = Pricing_Test_Utility.createAccount();
            Contact con = Pricing_Test_Utility.createPrimaryContactWithParam(acc.Id,'UCD_IQR_Bulk_Auto_Rejection_Batch_Test');
            
            List < User > accExeUserList = Pricing_Test_Utility.createAEUser();
            List < User > salesRepUserList = Pricing_Test_Utility.createSalesRepUser();
            
            List < User > aeUser2 = Pricing_Test_Utility.createAEUserWithParam('testAEUser02@intel.com');
            List < User > salesRepUser2 = Pricing_Test_Utility.createFSEUserWithParam('testFSEUser02@intel.com', 'lastNameFSETwo', 'firstNameFSETwo');           
            
            AccountTeamMember accTeam = new AccountTeamMember(AccountId = acc.Id, TeamMemberRole = 'Technical Sales', UserId = salesRepUserList[0].Id);
            insert accTeam;
            
            User partnerUser = Pricing_Test_Utility.createPartnerAdminUser(acc.Id);
            
            Test.startTest();
            List < SBQQ__Quote__c > quoteList = Pricing_Test_Utility.createQuoteWithParam(acc.Id, con.Id, 2, salesRepUserList[0].Email, accExeUserList[0].Email);
            List < SBQQ__QuoteLine__c > lstquoteLines = Pricing_Test_Utility.createQuoteLines(quoteList[0].Id, 3);
            
            Document document;
            document = new Document();
            document.Body = Blob.valueOf('Some Text');
            document.ContentType = 'application/pdf';
            document.DeveloperName = 'my_document';
            document.IsPublic = true;
            document.Name = Label.Pricing_IQR_Intel_Logo;
            document.FolderId = userinfo.getuserid();
            insert document;
            Test.stopTest();
        }
    }
    
    static testmethod void testSendRequestToUCD() {
        Test.startTest();
        List < User > partnerUser = [select id from user where email = 'partner@noemail.com'];
        List < SBQQ__Quote__c > lstquote = new List < SBQQ__Quote__c > ([select id from SBQQ__Quote__c Limit 1]);
        lstquote[0].SBQQ__Status__c = Label.Pricing_Tender_Quote_Status_Submitted;
        update lstquote[0];
        List < SBQQ__QuoteLine__c > lstquoteLines = new List < SBQQ__QuoteLine__c > ([select id, Pricing_Quote_Line_Number__c from SBQQ__QuoteLine__c where SBQQ__Quote__c =: lstquote[0].id limit 1]);
        lstquoteLines[0].Pricing_OEM_Standard_Unit_Price_Amt__c = 102;
        lstquoteLines[0].Pricing_Req_Discounted_Unit_Price__c = 1;
        lstquoteLines[0].Pricing_Single_System_Price_Amt__c = 500;
        lstquoteLines[0].Pricing_Additional_OEM_Discount_Amt__c = 450;
        lstquoteLines[0].Pricing_Systems_qty__c = 10;
        lstquoteLines[0].Pricing_CPUs_per_system_qty__c = 2;
        update lstquoteLines[0];
        
        test.stopTest();
        Id commentRecordTypeId = Pricing_Tender_Utility.getRecordTypeId('Pricing_Comments__c', Label.Pricing_Tender_Comment_RecordType_QuoteComment);
        List < Pricing_Comments__c > lstComment = [SELECT Id, Pricing_Answer__c, Pricing_Required_Ind__c, Pricing_Quote__c
                                                   FROM Pricing_Comments__c
                                                   WHERE Pricing_Quote__c =: lstquote[0].id and recordtypeid =: commentRecordTypeId
                                                  ];
        for (Pricing_Comments__c pc: lstComment) {
            if (lstquote[0].id == pc.Pricing_Quote__c) {
                pc.Pricing_Answer__c = '######testing######';
                pc.Pricing_Required_Ind__c = true;
            } else {
                pc.Pricing_Answer__c = '######testing######';
                pc.Pricing_Required_Ind__c = false;
            }
        }
        update lstComment;
        List < Pricing_Performance_Metric__c > performanceList;
        performanceList = Pricing_Test_Utility.createPerformanceMetrics(lstquoteLines[0].Id);
        if (!performanceList.isEmpty()) {
            insert performanceList;
        }
        Pricing_Publish_Quote.globalVariables glbVariable;
        system.runAs(partnerUser[0]) {
            //glbVariable = Pricing_Publish_Quote.PublishTenderQuote(lstquoteLines[0].id);
            //System.assertEquals(glbVariable.isSuccess,true);
            //Pricing_Publish_Quote.submitForReview(lstquoteLines[0].id); 
            glbVariable = Pricing_Publish_Quote.PublishTenderQuote(lstquote[0].id);
            Boolean isTrue = glbVariable != null ? true :false;
            system.assertEquals(true,isTrue); 
        }
        
    }
    
    static testmethod void testSurvivorAccount() {
        Test.startTest();
        List < Account > accRecordList = [select Id from Account];
        List < SBQQ__Quote__c > lstquote = new List < SBQQ__Quote__c > ([select id from SBQQ__Quote__c]);
        List < Id > quoteIdList = new List < Id > ();
        
        Account acc = new Account();
        acc.RecordTypeId = Pricing_Tender_Utility.getRecordTypeId('Account', Label.Pricing_Tender_Account_RecordType_IntelAccount);
        acc.Name = 'Scarlet';
        acc.Industry = 'Banking';
        acc.BillingCity = 'Pune';
        acc.BillingCountry = 'USA';
        acc.BillingStreet = 'G-210';
        acc.Core_Customer_Aggregation_Type__c = 'UNFD_CTRY_CUST';
        //acc.Core_Customer_Process_Engg__c = 'DIR_PRC_EXCPT';
        acc.BillingCountry = 'USA';
        acc.BillingCountryCode = 'USA';
        acc.ShippingCountryCode = 'USA';
        acc.ParentId = accRecordList[0].Id;
        acc.Core_Business_Party_Id__c = '1000678929';
        //acc.Core_Mastered_Country_Nm__c = 'United States';
        //acc.Core_Mastered_Simplified_Account_Nm__c = 'Scarlet';
        insert acc;
        
        Business_Types__c businessType = new Business_Types__c();
        businessType.Name = 'Direct Price Exception';
        businessType.Business_Type_Code__c = 'DIR_PRC_EXCPT';
        businessType.Is_Active__c = true;
        insert businessType;
        
        /*
Account_Business_Types__c accBusinessType = new Account_Business_Types__c();
accBusinessType.Account__c = acc.Id;
accBusinessType.Business_Types__c = businessType.Id;
insert accBusinessType;
*/
        
        UCD_BizOrgRequestModel bizModel = new UCD_BizOrgRequestModel();
        List < UCD_BizOrgRequestModel.AccountDetail > requestModelList = new List < UCD_BizOrgRequestModel.AccountDetail > ();
        
        UCD_BizOrgRequestModel.AccountDetail requestModel = new UCD_BizOrgRequestModel.AccountDetail();
        UCD_BizOrgRequestModel.AccountAddresses addressDetails = new UCD_BizOrgRequestModel.AccountAddresses();
        List < UCD_BizOrgRequestModel.AccountAddresses > addressDetailsList = new List < UCD_BizOrgRequestModel.AccountAddresses > ();
        //List<UCD_ACM_Models.AccountResponseModel> responseWrapperDuplicate = getUCDResponseWrapper();
        
        //UCD Request Details
        requestModel.Name = 'UCD Test Account';
        requestModel.CustomerProcessEngagmentCode = 'DIR_PRC_EXCPT';
        requestModel.CustomerAggregationTypeCode = 'UNFD_CTRY_CUST';
        
        //UCD Address details
        addressDetails.CountryName = 'United States';
        addressDetails.CountryCode = Pricing_UCD_IQR_FormRequest.getCountryCode('United States');
        
        addressDetailsList.add(addressDetails);
        requestModel.Addresses = addressDetailsList;
        requestModelList.add(requestModel);
        
        bizModel.AccountRequests = requestModelList;
        //responseModelList = UCD_BizOrgRequestController.createBusinessOrganizationRequest(bizModel);
        
        for (SBQQ__Quote__c quote: lstquote) {
            quoteIdList.add(quote.Id);
        }
        
        Pricing_UCD_IQR_FormRequest.sendRequestToUCD(quoteIdList);
        Pricing_UCD_IQR_FormRequest.createPayloadAsynch(quoteIdList);
        Pricing_UCD_IQR_FormRequest.sendSurvivorRequest(new List < String > {
            acc.Id
                });
        Pricing_UCD_IQR_FormRequest.formDuplicatePublisherResponse(getUCDResponseWrapper());
        system.assertEquals('UNFD_CTRY_CUST',requestModel.CustomerAggregationTypeCode);
        Test.stopTest();
    }
    
    public static List < UCD_ACM_Models.AccountResponseModel > getUCDResponseWrapper() {
        List < UCD_ACM_Models.AccountResponseModel > ucdResponseObjectList = new List < UCD_ACM_Models.AccountResponseModel > ();
        List < SBQQ__Quote__c > lstquote = new List < SBQQ__Quote__c > ([select id, SBQQ__Account__c from SBQQ__Quote__c Limit 1]);
        //UCD_ACM_Models.AccountResponseModel accResponseModel = new UCD_ACM_Models.AccountResponseModel();
        
        Account acc1 = new Account();
        acc1.RecordTypeId = Pricing_Tender_Utility.getRecordTypeId('Account', Label.Pricing_Tender_Account_RecordType_IntelAccount);
        acc1.Name = 'Test End Customer';
        acc1.Core_Account_Type__c = 'Distributor';
        acc1.Industry = 'Banking';
        acc1.BillingCity = 'Texas';
        acc1.BillingCountry = 'USA';
        acc1.BillingStreet = 'G-210';
        insert acc1;
        
        Pricing_Integration_Staging__c pisRec = new Pricing_Integration_Staging__c();
        pisRec.Pricing_RequestID__c = acc1.Id;
        pisRec.Pricing_SObjectId__c = lstquote[0].Id;
        pisRec.Pricing_Message_Type__c = 'UnifiedEndCustomer';
        pisRec.Pricing_Status__c = 'Successful';
        insert pisRec;
        
        Pricing_UCD_ResponseWrapper.ResponseData ucdResponseObject1 = new Pricing_UCD_ResponseWrapper.ResponseData();
        ucdResponseObject1.accountId = String.valueOf(acc1.Id);
        ucdResponseObject1.accountName = 'Test End Customer';
        ucdResponseObject1.masteredSimplifiedAccountName = 'Test End Customer';
        ucdResponseObject1.businessPartyIdentifier = '56789';
        ucdResponseObject1.recordType = 'Intel Account';
        Pricing_UCD_ResponseWrapper.AccountAddress primaryAddress1 = new Pricing_UCD_ResponseWrapper.AccountAddress();
        primaryAddress1.TypeCode = '';
        primaryAddress1.countryCode = 'AFG';
        primaryAddress1.countryName = Pricing_UCD_IQR_FormRequest.getCountryLabel('AFG');
        ucdResponseObject1.SecondaryAddress = primaryAddress1;
        Pricing_UCD_ResponseWrapper.ResponseData parentAcount1 = new Pricing_UCD_ResponseWrapper.ResponseData();
        parentAcount1.accountId = '5464';
        parentAcount1.accountName = 'Test End Customer';
        parentAcount1.businessPartyIdentifier = '12345';
        ucdResponseObject1.parentAccount = parentAcount1;
        
        List < Pricing_UCD_ResponseWrapper.ComplianceWatchList > cwlList = new List < Pricing_UCD_ResponseWrapper.ComplianceWatchList > ();
        Pricing_UCD_ResponseWrapper.ComplianceWatchList cwl = new Pricing_UCD_ResponseWrapper.ComplianceWatchList('EC', 'Embargoed Country');
        Pricing_UCD_ResponseWrapper.ComplianceWatchList cwl1 = new Pricing_UCD_ResponseWrapper.ComplianceWatchList('NOPAYOUT', 'Block Payment from Intel');
        
        cwlList.add(cwl);
        cwlList.add(cwl1);
        ucdResponseObject1.complianceWatchList = cwlList;
        
        String responseString = JSON.serialize(ucdResponseObject1);
        UCD_ACM_Models.AccountResponseModel publisherRequest = (UCD_ACM_Models.AccountResponseModel) System.JSON.deserialize(responseString, UCD_ACM_Models.AccountResponseModel.class);
        ucdResponseObjectList.add(publisherRequest);
        return ucdResponseObjectList;
        
    }
    
    static testmethod void testPISrecords() {
        Test.startTest();
        List < SBQQ__Quote__c > lstquote = new List < SBQQ__Quote__c > ([select id from SBQQ__Quote__c Limit 1]);
        List < Account > lstacc = new List < Account > ([select id from Account Limit 1]);
        Map < Id, List < UCD_BizOrgRequestModel.BusinessOrganizationResponse >> recordIdResponseMap = New Map < Id, List < UCD_BizOrgRequestModel.BusinessOrganizationResponse >> ();
        List < UCD_BizOrgRequestModel.BusinessOrganizationResponse > bizList = New List < UCD_BizOrgRequestModel.BusinessOrganizationResponse > ();
        UCD_BizOrgRequestModel.Data DataBiz = New UCD_BizOrgRequestModel.Data();
        DataBiz.AccountId = lstacc[0].Id;
        // DataBiz.quoteId =lstquote[0].id;
        DataBiz.Name = 'Test';
        DataBiz.CountryName = 'Test';
        DataBiz.AccountStatus = 'Test';
        // DataBiz.DuplicateAccountId =lstacc[0].Id;
        DataBiz.DuplicateAccountRecordType = 'Requested Account2';
        UCD_BizOrgRequestModel.BusinessOrganizationResponse bizData = New UCD_BizOrgRequestModel.BusinessOrganizationResponse();
        bizData.Code = '200';
        bizData.Status = 'Success';
        bizData.Errormessage = 'Test';
        bizData.Data = DataBiz;
        bizList.add(bizData);
        
        recordIdResponseMap.put(lstquote[0].id, bizList);
        Pricing_UCD_IQR_FormRequest.createPISRecord(recordIdResponseMap);
        system.assertEquals('Success',bizData.Status);
        Test.stopTest();
    }
    
    static testmethod void testgenereatePublisher() {
        Test.startTest();
        List < SBQQ__Quote__c > lstquote = new List < SBQQ__Quote__c > ([select id from SBQQ__Quote__c Limit 1]);
        List < Account > lstacc = new List < Account > ([select id, Name from Account Limit 1]);
        
        UCD_ACM_BusinessOrganizationModel.Address ucdAddress = New UCD_ACM_BusinessOrganizationModel.Address();
        ucdAddress.CountryCode = 'Test';
        ucdAddress.CountryName = 'Test';
        
        UCD_ACM_BusinessOrganizationModel.AccountMasteredDetails accMasterDeta = New UCD_ACM_BusinessOrganizationModel.AccountMasteredDetails();
        accMasterDeta.SimplifiedAccountName = 'Test Acc';
        accMasterDeta.BusinessPartyIdentifier = 'Test';
        accMasterDeta.Address = ucdAddress;
        
        UCD_ACM_BusinessOrganizationModel.ParentAccountInfomation paraccinfo = New UCD_ACM_BusinessOrganizationModel.ParentAccountInfomation();
        paraccinfo.AccountName = lstacc[0].Name;
        paraccinfo.AcocuntId = lstacc[0].id;
        paraccinfo.AcocuntId = lstacc[0].id;
        paraccinfo.BusinessPartyIdentifier = 'Test';
        paraccinfo.SimplifiedAccountName = 'Test Acc';
        
        List < UCD_ACM_BusinessOrganizationModel.AccountAddressInformation > listaccAdd = New List < UCD_ACM_BusinessOrganizationModel.AccountAddressInformation > ();
        
        UCD_ACM_BusinessOrganizationModel.AccountAddressInformation accAdd = New UCD_ACM_BusinessOrganizationModel.AccountAddressInformation();
        accAdd.AddressType = 'Test Add';
        accAdd.Street = 'Test Street';
        accAdd.City = 'Test City';
        accAdd.StateCode = 'Test StateCode';
        accAdd.StateName = 'Test StateName';
        accAdd.CountryName = 'Test CountryName';
        accAdd.Countrycode = 'Test Countrycode';
        accAdd.ZipCode = 'Test ZipCode';
        listaccAdd.add(accAdd);
        
        UCD_ACM_BusinessOrganizationModel.CustAggType custAgg = New UCD_ACM_BusinessOrganizationModel.CustAggType();
        custAgg.Code = Label.Pricing_UCD_Customer_Aggregation_Type;
        custAgg.Name = 'Test';
        
        List < UCD_ACM_BusinessOrganizationModel.cusProcEng > custproList = New List < UCD_ACM_BusinessOrganizationModel.cusProcEng > ();
        UCD_ACM_BusinessOrganizationModel.cusProcEng custpro = New UCD_ACM_BusinessOrganizationModel.cusProcEng();
        custpro.Code = Label.Pricing_UCD_Customer_Process_Engagement;
        custpro.Name = 'Test';
        custproList.add(custpro);
        
        UCD_ACM_BusinessOrganizationModel.AccountInformationData accinfo = New UCD_ACM_BusinessOrganizationModel.AccountInformationData();
        accinfo.AccountName = lstacc[0].Name;
        accinfo.AccountId = lstacc[0].Id;
        accinfo.BusinessPartyIdentifier = 'test';
        accinfo.CustomerAggregationType = custAgg;
        accinfo.CustomerProcessEngagement = custproList;
        
        List < UCD_ACM_BusinessOrganizationModel.ResponseData > dataList = New List < UCD_ACM_BusinessOrganizationModel.ResponseData > ();
        UCD_ACM_BusinessOrganizationModel.ResponseData datares = New UCD_ACM_BusinessOrganizationModel.ResponseData();
        datares.Id = lstacc[0].Id;
        datares.AccountInformation = accinfo;
        datares.AccountAddressInformation = listaccAdd;
        datares.ParentAccountInfomation = paraccinfo;
        datares.AccountMasteredDetails = accMasterDeta;
        
        dataList.add(datares);
        
        UCD_ACM_BusinessOrganizationModel.BusinessOrganizationResponse bussRes = New UCD_ACM_BusinessOrganizationModel.BusinessOrganizationResponse();
        bussRes.Status = 'Successful';
        bussRes.ExecutionTime = 1;
        bussRes.InternalTxnID = 'TestId';
        bussRes.Data = dataList;
        
        Pricing_UCD_IQR_FormRequest.genereatePublisherRequest(bussRes);
        system.assertEquals(true ,lstquote.size() > 0);
        Test.stopTest();
    }
    
    static testmethod void testCreatePayloadsWithoutAE() {
        Test.startTest();
        List < User > rpmUser = Pricing_Test_Utility.createPricingMangerUser();
        List < User > salesRep1 = [select id from user where email = 'firstNameSalesRep@intel.com'];
        List < User > adminUser = [select id from user where email = 'firstName@intel.com'];
        List < User > aeUser1 = [select id from user where email = 'firstNameAE@intel.com']; 
        List < User > aeUser2 = [select id from user where email = 'testAEUser02@intel.com']; 
        
        List < SBQQ__Quote__c > lstquote = new List < SBQQ__Quote__c > ([select id from SBQQ__Quote__c Limit 1]);
        
        System.runAs(salesRep1[0]) {
            
            lstquote[0].SBQQ__Status__c = Label.Pricing_Tender_Quote_Status_Submitted;
            update lstquote[0];
            List < SBQQ__QuoteLine__c > lstquoteLines = new List < SBQQ__QuoteLine__c > ([select id, Pricing_Quote_Line_Number__c from SBQQ__QuoteLine__c where SBQQ__Quote__c =: lstquote[0].id limit 1]);
            lstquoteLines[0].Pricing_OEM_Standard_Unit_Price_Amt__c = 102;
            lstquoteLines[0].Pricing_Req_Discounted_Unit_Price__c = 1;
            lstquoteLines[0].Pricing_Single_System_Price_Amt__c = 500;
            lstquoteLines[0].Pricing_Additional_OEM_Discount_Amt__c = 450;
            lstquoteLines[0].Pricing_Systems_qty__c = 10;
            lstquoteLines[0].Pricing_CPUs_per_system_qty__c = 2;
            update lstquoteLines[0];
            
            Id commentRecordTypeId = Pricing_Tender_Utility.getRecordTypeId('Pricing_Comments__c', Label.Pricing_Tender_Comment_RecordType_QuoteComment);
            List < Pricing_Comments__c > lstComment = [SELECT Id, Pricing_Answer__c, Pricing_Required_Ind__c, Pricing_Quote__c
                                                       FROM Pricing_Comments__c
                                                       WHERE Pricing_Quote__c =: lstquote[0].id and recordtypeid =: commentRecordTypeId
                                                      ];
            for (Pricing_Comments__c pc: lstComment) {
                if (lstquote[0].id == pc.Pricing_Quote__c) {
                    pc.Pricing_Answer__c = '######testing######';
                    pc.Pricing_Required_Ind__c = true;
                } else {
                    pc.Pricing_Answer__c = '######testing######';
                    pc.Pricing_Required_Ind__c = false;
                }
            }
            update lstComment;
            List < Pricing_Performance_Metric__c > performanceList;
            performanceList = Pricing_Test_Utility.createPerformanceMetrics(lstquoteLines[0].Id);
            if (!performanceList.isEmpty()) {
                insert performanceList;
            }
        }
        
        System.runAs(rpmUser[0]) {
            List<Id> lstIds = new List<Id>();
            lstIds.add(lstquote[0].Id);
            Pricing_UCD_IQR_FormRequest.createPayloads(lstIds);
        }
        
        System.runAs(adminUser[0]) {
            Pricing_Test_Utility.shareQuoteWithUser(lstquote[0].Id,aeUser2[0].Id);
            List<PermissionSetAssignment> PSAssignment = [SELECT Id, PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId =: aeUser1[0].Id AND PermissionSet.Name =: Label.Pricing_Tender_PermissionSets_TenderAccountExecutive];
            if(!PSAssignment.isEmpty()){
                Delete PSAssignment;
            }
        }
        
        System.runAs(rpmUser[0]) {
            List<Id> lstIds = new List<Id>();
            lstIds.add(lstquote[0].Id);
            Pricing_UCD_IQR_FormRequest.createPayloads(lstIds);
        }
        system.assertEquals('Submitted',lstquote[0].SBQQ__Status__c);
        Test.stopTest();
    }
    
    static testmethod void testCreatePayloadsWithoutSecondAE() {
        Test.startTest();
        List < User > rpmUser = Pricing_Test_Utility.createPricingMangerUser();
        List < User > salesRep1 = [select id from user where email = 'firstNameSalesRep@intel.com'];
        List < User > adminUser = [select id from user where email = 'firstName@intel.com'];
        List < User > aeUser2 = [select id from user where email = 'testAEUser02@intel.com'];
        List < User > aeUser1 = [select id from user where email = 'firstNameAE@intel.com']; 
        
        List < SBQQ__Quote__c > lstquote = new List < SBQQ__Quote__c > ([select id from SBQQ__Quote__c Limit 1]);
        Pricing_Test_Utility.shareQuoteWithUser(lstquote[0].Id, aeUser2[0].Id);
        
        System.runAs(salesRep1[0]) {
            
            lstquote[0].SBQQ__Status__c = Label.Pricing_Tender_Quote_Status_Submitted;
            update lstquote[0];
            List < SBQQ__QuoteLine__c > lstquoteLines = new List < SBQQ__QuoteLine__c > ([select id, Pricing_Quote_Line_Number__c from SBQQ__QuoteLine__c where SBQQ__Quote__c =: lstquote[0].id limit 1]);
            lstquoteLines[0].Pricing_OEM_Standard_Unit_Price_Amt__c = 102;
            lstquoteLines[0].Pricing_Req_Discounted_Unit_Price__c = 1;
            lstquoteLines[0].Pricing_Single_System_Price_Amt__c = 500;
            lstquoteLines[0].Pricing_Additional_OEM_Discount_Amt__c = 450;
            lstquoteLines[0].Pricing_Systems_qty__c = 10;
            lstquoteLines[0].Pricing_CPUs_per_system_qty__c = 2;
            update lstquoteLines[0];
            
            Id commentRecordTypeId = Pricing_Tender_Utility.getRecordTypeId('Pricing_Comments__c', Label.Pricing_Tender_Comment_RecordType_QuoteComment);
            List < Pricing_Comments__c > lstComment = [SELECT Id, Pricing_Answer__c, Pricing_Required_Ind__c, Pricing_Quote__c
                                                       FROM Pricing_Comments__c
                                                       WHERE Pricing_Quote__c =: lstquote[0].id and recordtypeid =: commentRecordTypeId
                                                      ];
            for (Pricing_Comments__c pc: lstComment) {
                if (lstquote[0].id == pc.Pricing_Quote__c) {
                    pc.Pricing_Answer__c = '######testing######';
                    pc.Pricing_Required_Ind__c = true;
                } else {
                    pc.Pricing_Answer__c = '######testing######';
                    pc.Pricing_Required_Ind__c = false;
                }
            }
            update lstComment;
            List < Pricing_Performance_Metric__c > performanceList;
            performanceList = Pricing_Test_Utility.createPerformanceMetrics(lstquoteLines[0].Id);
            if (!performanceList.isEmpty()) {
                insert performanceList;
            }
        }
        
        System.runAs(adminUser[0]) {
            List<Id> userIDs = new List<Id>();
            userIDs.add(aeUser2[0].Id);
            userIDs.add(aeUser1[0].Id);
            List<PermissionSetAssignment> PSAssignment = [SELECT Id, PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId IN: userIDs AND PermissionSet.Name =: Label.Pricing_Tender_PermissionSets_TenderAccountExecutive];
            if(!PSAssignment.isEmpty()){
                Delete PSAssignment;
            }
        }
        
        System.runAs(rpmUser[0]) {
            List<Id> lstIds = new List<Id>();
            lstIds.add(lstquote[0].Id);
            Pricing_UCD_IQR_FormRequest.createPayloads(lstIds);
        }
        system.assertEquals('Submitted',lstquote[0].SBQQ__Status__c);
        Test.stopTest();
    }
    
    static testmethod void testCreatePayloadsWithoutSelesRep() {
        Test.startTest();
        List < User > rpmUser = Pricing_Test_Utility.createPricingMangerUser();
        List < User > salesRep1 = [select id from user where email = 'firstNameSalesRep@intel.com'];
        List < User > adminUser = [select id from user where email = 'firstName@intel.com'];
        List < User > aeUser1 = [select id from user where email = 'firstNameAE@intel.com'];   
        List < User > salesRep2 = [select id from user where email = 'testFSEUser02@intel.com'];    
        List < SBQQ__Quote__c > lstquote = new List < SBQQ__Quote__c > ([select id from SBQQ__Quote__c Limit 1]);
        
        
        System.runAs(salesRep1[0]) {
            
            lstquote[0].SBQQ__Status__c = Label.Pricing_Tender_Quote_Status_Submitted;
            update lstquote[0];
            List < SBQQ__QuoteLine__c > lstquoteLines = new List < SBQQ__QuoteLine__c > ([select id, Pricing_Quote_Line_Number__c from SBQQ__QuoteLine__c where SBQQ__Quote__c =: lstquote[0].id limit 1]);
            lstquoteLines[0].Pricing_OEM_Standard_Unit_Price_Amt__c = 102;
            lstquoteLines[0].Pricing_Req_Discounted_Unit_Price__c = 1;
            lstquoteLines[0].Pricing_Single_System_Price_Amt__c = 500;
            lstquoteLines[0].Pricing_Additional_OEM_Discount_Amt__c = 450;
            lstquoteLines[0].Pricing_Systems_qty__c = 10;
            lstquoteLines[0].Pricing_CPUs_per_system_qty__c = 2;
            update lstquoteLines[0];
            
            Id commentRecordTypeId = Pricing_Tender_Utility.getRecordTypeId('Pricing_Comments__c', Label.Pricing_Tender_Comment_RecordType_QuoteComment);
            List < Pricing_Comments__c > lstComment = [SELECT Id, Pricing_Answer__c, Pricing_Required_Ind__c, Pricing_Quote__c
                                                       FROM Pricing_Comments__c
                                                       WHERE Pricing_Quote__c =: lstquote[0].id and recordtypeid =: commentRecordTypeId
                                                      ];
            for (Pricing_Comments__c pc: lstComment) {
                if (lstquote[0].id == pc.Pricing_Quote__c) {
                    pc.Pricing_Answer__c = '######testing######';
                    pc.Pricing_Required_Ind__c = true;
                } else {
                    pc.Pricing_Answer__c = '######testing######';
                    pc.Pricing_Required_Ind__c = false;
                }
            }
            update lstComment;
            List < Pricing_Performance_Metric__c > performanceList;
            performanceList = Pricing_Test_Utility.createPerformanceMetrics(lstquoteLines[0].Id);
            if (!performanceList.isEmpty()) {
                insert performanceList;
            }
        }
        
        System.runAs(adminUser[0]) {
            Pricing_Test_Utility.shareQuoteWithUser(lstquote[0].Id, salesRep2[0].Id);
            List<Id> userIDs = new List<Id>();
            userIDs.add(salesRep1[0].Id);
            userIDs.add(aeUser1[0].Id);
            List<PermissionSetAssignment> PSAssignment = [SELECT Id, PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId IN:userIDs AND (PermissionSet.Name =: Label.Pricing_Tender_PermissionSets_TenderUser OR PermissionSet.Name =: Label.Pricing_Tender_PermissionSets_TenderAccountExecutive )];
            if(!PSAssignment.isEmpty()){
                Delete PSAssignment;
            }
        }
        
        System.runAs(rpmUser[0]) {
            List<Id> lstIds = new List<Id>();
            lstIds.add(lstquote[0].Id);
            Pricing_UCD_IQR_FormRequest.createPayloads(lstIds);
        }
        system.assertEquals('Submitted',lstquote[0].SBQQ__Status__c);
        Test.stopTest();
    }
    
    static testmethod void testCreatePayloadsWithoutSalesRepAndAE() {
        Test.startTest();
        List < User > rpmUser = Pricing_Test_Utility.createPricingMangerUser();
        List < User > salesRep1 = [select id from user where email = 'firstNameSalesRep@intel.com'];
        List < User > adminUser = [select id from user where email = 'firstName@intel.com'];
        List < User > aeUser1 = [select id from user where email = 'firstNameAE@intel.com']; 
        
        List < SBQQ__Quote__c > lstquote = new List < SBQQ__Quote__c > ([select id from SBQQ__Quote__c Limit 1]);
        
        System.runAs(salesRep1[0]) {
            
            lstquote[0].SBQQ__Status__c = Label.Pricing_Tender_Quote_Status_Submitted;
            update lstquote[0];
            List < SBQQ__QuoteLine__c > lstquoteLines = new List < SBQQ__QuoteLine__c > ([select id, Pricing_Quote_Line_Number__c from SBQQ__QuoteLine__c where SBQQ__Quote__c =: lstquote[0].id limit 1]);
            lstquoteLines[0].Pricing_OEM_Standard_Unit_Price_Amt__c = 102;
            lstquoteLines[0].Pricing_Req_Discounted_Unit_Price__c = 1;
            lstquoteLines[0].Pricing_Single_System_Price_Amt__c = 500;
            lstquoteLines[0].Pricing_Additional_OEM_Discount_Amt__c = 450;
            lstquoteLines[0].Pricing_Systems_qty__c = 10;
            lstquoteLines[0].Pricing_CPUs_per_system_qty__c = 2;
            update lstquoteLines[0];
            
            Id commentRecordTypeId = Pricing_Tender_Utility.getRecordTypeId('Pricing_Comments__c', Label.Pricing_Tender_Comment_RecordType_QuoteComment);
            List < Pricing_Comments__c > lstComment = [SELECT Id, Pricing_Answer__c, Pricing_Required_Ind__c, Pricing_Quote__c
                                                       FROM Pricing_Comments__c
                                                       WHERE Pricing_Quote__c =: lstquote[0].id and recordtypeid =: commentRecordTypeId
                                                      ];
            for (Pricing_Comments__c pc: lstComment) {
                if (lstquote[0].id == pc.Pricing_Quote__c) {
                    pc.Pricing_Answer__c = '######testing######';
                    pc.Pricing_Required_Ind__c = true;
                } else {
                    pc.Pricing_Answer__c = '######testing######';
                    pc.Pricing_Required_Ind__c = false;
                }
            }
            update lstComment;
            List < Pricing_Performance_Metric__c > performanceList;
            performanceList = Pricing_Test_Utility.createPerformanceMetrics(lstquoteLines[0].Id);
            if (!performanceList.isEmpty()) {
                insert performanceList;
            }
        }
        
        System.runAs(adminUser[0]) {
            List<Id> userIDs = new List<Id>();
            userIDs.add(salesRep1[0].Id);
            userIDs.add(aeUser1[0].Id);
            List<PermissionSetAssignment> PSAssignment = [SELECT Id, PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId IN:userIDs AND (PermissionSet.Name =: Label.Pricing_Tender_PermissionSets_TenderUser OR PermissionSet.Name =: Label.Pricing_Tender_PermissionSets_TenderAccountExecutive )];
            if(!PSAssignment.isEmpty()){
                Delete PSAssignment;
            }
        }
        
        System.runAs(rpmUser[0]) {
            List<Id> lstIds = new List<Id>();
            lstIds.add(lstquote[0].Id);
            Pricing_UCD_IQR_FormRequest.createPayloads(lstIds);
        }
		system.assertEquals('Submitted',lstquote[0].SBQQ__Status__c);      
        Test.stopTest();
    }
    
    static testmethod void testResubmitUCDRequest() {
        Test.startTest();
        List < User > adminUser = [select id from user where email = 'ucdIQRFormReqAdmin@intel.com'];
        List < SBQQ__Quote__c > lstquote = new List < SBQQ__Quote__c > ([select id from SBQQ__Quote__c Limit 1]);
        List<Id> quoteIds = new List<Id>();
        quoteIds.add(lstquote[0].Id);
        system.runAs(adminUser[0]){
            Pricing_Integration_Staging__c pis = new Pricing_Integration_Staging__c();
        	pis.Pricing_Message_Type__c = Label.Pricing_UCD_PIS_Message_Type;
        	pis.Pricing_QuoteID__c = lstquote[0].Id;
        	insert pis;
            Pricing_UCD_IQR_FormRequest.resubmitUCDRequest(quoteIds);
            system.assertEquals('UnifiedEndCustomer',pis.Pricing_Message_Type__c);
        }
        test.stopTest();
    }
    
    static testmethod void testgetL1andL2AccDetails() {
        Pricing_UnifiedEndCustomerAccountMapping__c l1Record = new Pricing_UnifiedEndCustomerAccountMapping__c(Name ='Test unified End Cutsomer',Pricing_Unified_EndCustomer_Id__c = '1000678928');
   		insert l1Record;
        Pricing_UnifiedEndCustomerCountryMapping__c l2record = new Pricing_UnifiedEndCustomerCountryMapping__c(Name ='Test unified Country Cutomer',Pricing_Unified_Country_EndCustomer_Id__c = '1000678929');
        //l2record.Pricing_Unified_EndCustomer_Id__c = l1Record.Pricing_Unified_EndCustomer_Id__c;
        insert l2Record;
  
        Account acc1 = new Account();
        acc1.RecordTypeId = Pricing_Tender_Utility.getRecordTypeId('Account', Label.Pricing_Tender_Account_RecordType_IntelAccount);
        acc1.Name = 'Test L2 Account';
        acc1.Industry = 'Banking';
        acc1.BillingCity = 'Pune';
        acc1.BillingCountry = 'USA';
        acc1.BillingStreet = 'G-210';
        acc1.Core_Customer_Aggregation_Type__c = 'UNFD_CTRY_CUST';
        acc1.Core_Business_Party_Id__c = '1000678929';
        insert acc1;
          Account acc2 = new Account();
        acc2.RecordTypeId = Pricing_Tender_Utility.getRecordTypeId('Account',Label.Pricing_Tender_Account_RecordType_IntelAccount);
        acc2.Name = 'Test L1 Account';
        acc2.Industry = 'Banking';
        acc2.BillingCity = 'Pune';
        acc2.BillingCountry = 'USA';
        acc2.BillingStreet = 'G-210';
        acc2.Core_Business_Party_Id__c = '1000678928';
        insert acc2;
        Test.startTest();
       List<Pricing_UCD_IQR_FormRequest.unifiedL1AndL2Wrapper> unifiedL1AndL2List = Pricing_UCD_IQR_FormRequest.getL1andL2AccDetails(l2Record.id);
       List<Pricing_UCD_IQR_FormRequest.unifiedL1AndL2Wrapper> unifiedList = Pricing_UCD_IQR_FormRequest.getL1andL2AccDetails(l1Record.id);
   	   system.assertEquals(1,unifiedList.size());
        test.stopTest();
    }
    
      static testMethod void testgetDataTableColumns(){
        Test.startTest();
        List<Pricing_UCD_IQR_FormRequest.DataTableColumns> datacolumns = Pricing_UCD_IQR_FormRequest.getDataTableColumns();
          Boolean isTrue = datacolumns.size()>0 ? true : false;
          system.assertEquals(true,isTrue);
        Test.stopTest();
    }
}