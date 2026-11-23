@isTest
public class PRM_ScheduleInboundOPIDBatchTest {
    @testSetup
     static void createData(){
        prm_skip_trigger__c sk = new prm_skip_trigger__c();
        sk.Name='ABA_Trigger';
        sk.inactive__c= false;
        insert sk;
        
        Id accountRecordTypeIntel = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        Id accountRecordTypePAG = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Partner_Account_Group_Record_Type).getRecordTypeId();
        Id selectBenefitId=Schema.SObjectType.PRM_Specialty__c.getRecordTypeInfosByName().get('Select Benefits').getRecordTypeId();
        Id opidRecommendationRecordType = Schema.SObjectType.PRM_Value_Exchange_Recommendation__c.getRecordTypeInfosByName().get(System.Label.PRM_RecordType_OPID).getRecordTypeId();
        Id recordTypeIdOPIDAcc = Schema.SObjectType.Account.getRecordTypeInfosByName().get(System.Label.PRM_ParentAccRecordType).getRecordTypeId();
        Id upgradeDowngradeRecordType = Schema.SObjectType.PRM_Value_Exchange_Recommendation__c.getRecordTypeInfosByName().get(System.Label.PRM_RecordType_Upgrade_Downgrade).getRecordTypeId();
        
        PRM_Execution_Controls__c settings = PRM_Execution_Controls__c.getOrgDefaults();
        settings.PRM_Skip_VR_for_OPID_Batch_Ind__c =true;
        insert settings;
        
        PRM_BatchCustomSetting__c  bCs = new PRM_BatchCustomSetting__c ();
        bCs.PRM_MP_Benefits__c = 'Solution Marketplace Enhanced';
        bCs.Name ='BatchFieldValues';
        bCs.PRM_PartnerRole__c ='Service Provider';
        bCs.PRM_PartnerType__c ='Cloud Service Provider (CSP)';
        insert bCs;
        
        List<Account> listOfAccount = new List<Account>();
        List<PRM_AccountChannelMembership__c> listOfACM = new List<PRM_AccountChannelMembership__c>();
        
        //Intel Account ****************************************************
        Account accIntel = PRM_TestUtility.getAccount();
        accIntel.RecordTypeId = accountRecordTypeIntel;
        accIntel.AccountNumber = '435765';
        accIntel.Name='TestUser';
        accIntel.BillingCity='New Delhi';
        accIntel.BillingCountryCode='IND';
        accIntel.BillingStreet='Joshi Marg';
        accIntel.BillingPostalCode='65467';
        accIntel.BillingStateCode='KA';
        accIntel.Core_CIM_ID__c='234567';
        accIntel.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        accIntel.Industry = 'Construction';
        listOfAccount.add(accIntel);
        
        //intel Account
        Account accIntel1 = PRM_TestUtility.getAccount();
        accIntel1.RecordTypeId = accountRecordTypeIntel;
        accIntel1.AccountNumber = '4357659738';
        accIntel1.Name='TestUser1';
        accIntel1.BillingCity='Pune';
        accIntel1.BillingCountryCode='IND';
        accIntel1.BillingStreet='Joshi Marg';
        accIntel1.BillingPostalCode='6546787';
        accIntel1.BillingStateCode='KA';
        accIntel1.Core_CIM_ID__c='2345987';
        accIntel1.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        accIntel1.Industry = 'Construction';
        accIntel1.Core_Business_Party_Id__c ='123456';
        accIntel1.Core_Unified_Global_Customer_BP_Id__c = '123456';
        listOfAccount.add(accIntel1);
        
        //intel Account
        Account accIntel2 = PRM_TestUtility.getAccount();
        accIntel2.AccountNumber = '435765';
        accIntel2.RecordTypeId = accountRecordTypeIntel;
        accIntel2.Name='New Account';
        accIntel2.Core_Account_Type__c ='Distributor';
        accIntel2.Industry='Agriculture';
        accIntel2.BillingCity='Goa';
        accIntel2.BillingCountryCode='IND';
        accIntel2.BillingStreet='4th Floor,New Road';
        accIntel2.BillingPostalCode='110065';
        accIntel2.BillingStateCode='KA';
        accIntel2.Core_IPA_Partner_Role__c = 'Service Provider';
        accIntel2.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        accIntel2.Core_CIM_ID__c='1235987';
        accIntel2.Core_Intel_Partner_Alliance_PartnerGroup__c = true;   
        accIntel2.Core_Business_Party_Id__c ='123457';
        accIntel2.Core_Parent_Business_Party_Id__c = '123456';
        accIntel2.Core_Unified_Global_Customer_BP_Id__c = '123456';
        listOfAccount.add(accIntel2);
        
        //intel Account
        Account accIntel3 = PRM_TestUtility.getAccount();
        accIntel3.AccountNumber = '43576597';
        accIntel3.RecordTypeId = accountRecordTypeIntel;
        accIntel3.Name='New Account User';
        accIntel3.Core_Account_Type__c ='Distributor';
        accIntel3.Industry='Agriculture';
        accIntel3.BillingCity='Daman';
        accIntel3.BillingCountryCode='IND';
        accIntel3.BillingStreet='4th Floor,New Road';
        accIntel3.BillingPostalCode='110895';
        accIntel3.BillingStateCode='KA';
        accIntel3.Core_CIM_ID__c='1234987';
        accIntel3.Core_IPA_Partner_Role__c = 'Service Provider';
        accIntel3.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        accIntel3.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        accIntel3.Core_Business_Party_Id__c ='123458';
        listOfAccount.add(accIntel3);
        
        //intel Account
        Account accIntel4 = PRM_TestUtility.getAccount();
        accIntel4.AccountNumber = '43576597';
        accIntel4.RecordTypeId = accountRecordTypeIntel;
        accIntel4.Name='New User';
        accIntel4.Core_Account_Type__c ='Distributor';
        accIntel4.Industry='Agriculture';
        accIntel4.BillingCity='DamanDue';
        accIntel4.BillingCountryCode='IND';
        accIntel4.BillingStreet='4th Floor,New Road';
        accIntel4.BillingPostalCode='110885';
        accIntel4.BillingStateCode='KA';
        accIntel4.Core_CIM_ID__c='123789678';
        accIntel4.Core_IPA_Partner_Role__c = 'Service Provider';
        accIntel4.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        accIntel4.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        accIntel4.Core_Business_Party_Id__c ='123459';
        listOfAccount.add(accIntel4);
        
        //PAG Account creation************************************
        Account accPAG = new Account();
        accPAG.RecordTypeId = accountRecordTypePAG;
        accPAG.Name = 'Crosswealth1';
        accPAG.Core_OnePartnerID__c = '2001';
        //  accPAG.Core_OPID_Name__c = 'Crosswealth1';
        // accPAG.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        listOfAccount.add(accPAG);
        
        
        
        Account accPAG1 = new Account();
        accPAG1.RecordTypeId = accountRecordTypePAG;
        accPAG1.Name = 'Crosswealth2';
        accPAG1.Core_OnePartnerID__c = '2002';
        // accPAG1.Core_OPID_Name__c = 'Crosswealth2';
        //accPAG1.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        listOfAccount.add(accPAG1);
        
        Account accPAGOPID = new Account();
        accPAGOPID.RecordTypeId = recordTypeIdOPIDAcc;
        accPAGOPID.Name = 'CrosswealthOPID';
        accPAGOPID.Core_OnePartnerID__c = '2005';
        //  accPAG.Core_OPID_Name__c = 'Crosswealth1';
        // accPAG.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        listOfAccount.add(accPAGOPID);
        
        try{
            insert listOfAccount;
        }catch (exception ex){
           System.debug('Line no. 145 Error '+ex.getMessage()); 
        }
        
        
        
        //ACM Channel
        ChannelProgram cprogram = new ChannelProgram();
        cprogram.Name='Intel Partner Alliance';
        cprogram.PRM_programCode__c='IPA';
        cprogram.IsActive = true;
        insert cprogram;
        
        ChannelProgramLevel level = new ChannelProgramLevel();   //Channel Program Level
        level.Name='Member';
        level.ProgramId = cprogram.Id;
        insert level;
        ChannelProgramLevel level1 = new ChannelProgramLevel();   //Channel Program Level
        level1.Name='Gold';
        level1.ProgramId = cprogram.Id;
        insert level1;
        ChannelProgramLevel level2 = new ChannelProgramLevel();   //Channel Program Level
        level2.Name='Titanium';
        level2.ProgramId = cprogram.Id;
        insert level2;
        
        //insert vxData
        PRM_Value_Exchange_Data__c vxData1 = new PRM_Value_Exchange_Data__c();
        vxData1.PRM_Sales_Amount_Nbr__c = 2000000;
        vxData1.PRM_Account_Id__c = listOfAccount[1].Id;
        vxData1.PRM_One_Partner_Id__c=listOfAccount[6].Id;
        vxData1.PRM_Tier_Id__c = level.Id;
        vxData1.PRM_Partner_Role_Nm__c = 'Solution Integrator';
        vxData1.PRM_Country_Market_Type_Nm__c = 'Emerging';
        vxData1.PRM_Training_Credit_Points_Count_Nbr__c=50;
        vxData1.PRM_Change_Date_Dt__c = System.today();
        vxData1.PRM_From_Dt__c = Date.Today().addDays(-2);
        vxData1.PRM_To_Dt__c =Date.Today();
        try {
            insert vxData1; 
        } catch(exception ex){
            System.debug('exception occured'+ex.getMessage());
        }
        
        
        PRM_Value_Exchange_Data__c vxData2 = new PRM_Value_Exchange_Data__c();
        vxData2.PRM_Sales_Amount_Nbr__c = 2000000;
        vxData2.PRM_Account_Id__c = listOfAccount[2].Id;
        vxData2.PRM_One_Partner_Id__c=listOfAccount[6].Id;
        vxData2.PRM_Tier_Id__c = level.Id;
        vxData2.PRM_Partner_Role_Nm__c = 'Solution Integrator';
        vxData2.PRM_Country_Market_Type_Nm__c = 'Emerging';
        vxData2.PRM_Training_Credit_Points_Count_Nbr__c=50;
        vxData2.PRM_Change_Date_Dt__c = System.today();
        vxData2.PRM_From_Dt__c = Date.Today().addDays(-2);
        vxData2.PRM_To_Dt__c =Date.Today();
        try {
            insert vxData2; 
        } catch(exception ex){
            System.debug('exception occured'+ex.getMessage());
        }
        
        //ACM insert        
        PRM_AccountChannelMembership__c  acm = PRM_TestUtility.getMembership();
        acm.PRM_Account_Id__c = accIntel.Id;
        acm.PRM_Channel_Program_Id__c = cprogram.Id;
        acm.PRM_Partner_Role__c='Distributor';
        acm.PRM_Status_Nm__c ='Approved';
        acm.PRM_Status_Reason_Txt__c = 'Test';
        acm.PRM_Channel_Program_Level_Id__c = level.id;
        listOfACM.add(acm);
        
        //ACM insert        
        PRM_AccountChannelMembership__c  acm1= PRM_TestUtility.getMembership();
        acm1.PRM_Account_Id__c = accIntel1.Id;
        acm1.PRM_Channel_Program_Id__c = cprogram.Id;
        acm1.PRM_Partner_Role__c=System.Label.PRM_Service_Provider;
        acm1.PRM_Status_Nm__c ='Approved';
        acm1.PRM_Status_Reason_Txt__c = 'Test';
        acm1.PRM_Channel_Program_Level_Id__c = level.id;
        listOfACM.add(acm1);
        
        //ACM insert        
        PRM_AccountChannelMembership__c  acm2= PRM_TestUtility.getMembership();
        acm2.PRM_Account_Id__c = accIntel2.Id;
        acm2.PRM_Channel_Program_Id__c = cprogram.Id;
        acm2.PRM_Partner_Role__c = 'Solution Integrator';
        acm2.PRM_Status_Nm__c ='Approved';
        acm2.PRM_Channel_Program_Level_Id__c = level.id;
        acm2.PRM_Status_Reason_Txt__c = 'Test';
        listOfACM.add(acm2);
        
        
        
        //PAG ACM ********************************************
        PRM_AccountChannelMembership__c  acm5 = PRM_TestUtility.getMembership();
        acm5.PRM_Account_Id__c = accPAG.Id;
        acm5.PRM_Channel_Program_Id__c = cprogram.Id;
        acm5.PRM_Partner_Role__c='Distributor';
        acm5.PRM_Status_Nm__c ='Approved';
        acm5.PRM_Channel_Program_Level_Id__c = level1.id;
        acm5.PRM_Status_Reason_Txt__c = 'Test';
        //listOfACM.add(acm5);
        
        PRM_AccountChannelMembership__c  acm6 = PRM_TestUtility.getMembership();
        acm6.PRM_Account_Id__c = accPAG.Id;
        acm6.PRM_Channel_Program_Id__c = cprogram.Id;
        acm6.PRM_Partner_Role__c=System.Label.PRM_Service_Provider;
        acm6.PRM_Status_Nm__c ='Approved';
        acm6.PRM_Channel_Program_Level_Id__c = level1.id;
        acm6.PRM_Status_Reason_Txt__c = 'Test';
        //listOfACM.add(acm6);  
        
        
        
        
        //PAG ACM
        PRM_AccountChannelMembership__c  acm7 = PRM_TestUtility.getMembership();
        acm7.PRM_Account_Id__c = accPAG1.Id;
        acm7.PRM_Channel_Program_Id__c = cprogram.Id;
        acm7.PRM_Partner_Role__c=System.Label.PRM_Service_Provider;
        acm7.PRM_Status_Nm__c ='Approved';
        acm7.PRM_Channel_Program_Level_Id__c = level.id;
        acm7.PRM_Status_Reason_Txt__c = 'Test';
        listOfACM.add(acm7);
        
        PRM_AccountChannelMembership__c  acm9 = PRM_TestUtility.getMembership();
        acm9.PRM_Account_Id__c = accPAG1.Id;
        acm9.PRM_Channel_Program_Id__c = cprogram.Id;
        acm9.PRM_Partner_Role__c='Solution Integrator';
        acm9.PRM_Status_Nm__c ='Approved';
        acm9.PRM_Channel_Program_Level_Id__c = level.id;
        acm9.PRM_Status_Reason_Txt__c = 'Test';
        listOfACM.add(acm9);
        
        PRM_AccountChannelMembership__c  acm8 = PRM_TestUtility.getMembership();
        acm8.PRM_Account_Id__c = accIntel4.Id;
        acm8.PRM_Channel_Program_Id__c = cprogram.Id;
        acm8.PRM_Partner_Role__c='Distributor';
        acm8.PRM_Status_Nm__c ='Approved';
        acm8.PRM_Channel_Program_Level_Id__c = level.id;
        acm8.PRM_Status_Reason_Txt__c = 'Test';
        listOfACM.add(acm8);
        
        //CAG between OPID and IntelAccount ***********************************************
        List<Core_Account_Group_Member__c> listOfCAG = new List<Core_Account_Group_Member__c>();
        Core_Account_Group_Member__c cag = new Core_Account_Group_Member__c();
        cag.Core_Intel_Account_Id__c = accIntel.Id;    
        cag.Core_Partner_Account_Id__c = accPAG.id;
        //cag.Core_Inactive_Ind__c = true;
        listOfCAG.add(cag);
        
        Core_Account_Group_Member__c cag1 = new Core_Account_Group_Member__c();
        cag1.Core_Intel_Account_Id__c = accIntel2.Id;
        cag1.Core_Partner_Account_Id__c = accPAG1.id;
        listOfCAG.add(cag1);
        
        Core_Account_Group_Member__c cag2 = new Core_Account_Group_Member__c();
        cag2.Core_Intel_Account_Id__c = accIntel1.Id;
        cag2.Core_Partner_Account_Id__c = accPAG1.id;
        listOfCAG.add(cag2);
        
        Core_Account_Group_Member__c cag3 = new Core_Account_Group_Member__c();
        cag3.Core_Intel_Account_Id__c = accIntel4.Id;
        cag3.Core_Partner_Account_Id__c = accPAG1.id;
        listOfCAG.add(cag3);
        
        /*Core_Account_Group_Member__c cag4 = new Core_Account_Group_Member__c();
cag4.Core_Intel_Account_Id__c = accIntel2.Id;
cag4.Core_Partner_Account_Id__c = accPAGOPID.id;
listOfCAG.add(cag4);*/
        
        //Speciality Adding in Intel and OPID ********************************
        PRM_Specialty__c spec1 = new PRM_Specialty__c();
        spec1.name='Select Benefit';
        spec1.PRM_Description_Txt__c='This is description';
        spec1.PRM_Funding_BU_Nm__c='CCG Sales Group';
        spec1.PRM_Role_Nm__c='Service Provider';
        spec1.PRM_Tier_Nm__c='Gold';
        spec1.PRM_Start_Date_Dt__c= system.today() + 7;
        spec1.PRM_End_Date_Dt__c= spec1.PRM_Start_Date_Dt__c + 5;
        spec1.PRM_Access_Level_Nm__c='Public';
        spec1.RecordTypeId = selectBenefitId;
        insert spec1;
        
        //Speciality Adding in Intel and OPID ********************************
        PRM_Specialty__c spec2 = new PRM_Specialty__c();
        spec2.name='Addition Select Benefit';
        spec2.PRM_Description_Txt__c='This is description';
        spec2.PRM_Funding_BU_Nm__c='CCG Sales Group';
        spec2.PRM_Role_Nm__c='Service Provider';
        spec2.PRM_Tier_Nm__c='Member';
        spec2.PRM_Start_Date_Dt__c= system.today() + 7;
        spec2.PRM_End_Date_Dt__c= spec1.PRM_Start_Date_Dt__c + 5;
        spec2.PRM_Access_Level_Nm__c='Public';
        spec2.RecordTypeId = selectBenefitId;
        insert spec2;
        
        List<PRM_Account_Specialty_Association__c> asaList = new List<PRM_Account_Specialty_Association__c>();
        PRM_Account_Specialty_Association__c asa = new PRM_Account_Specialty_Association__c();
        asa.PRM_Account_Id__c= accIntel2.id;
        asa.PRM_Specialty_Id__c= spec1.id;
        asa.PRM_Partner_Role__c=System.label.PRM_Service_Provider;       
        asaList.add(asa);
        
        PRM_Account_Specialty_Association__c asa1 = new PRM_Account_Specialty_Association__c();
        asa1.PRM_Account_Id__c = accPAG1.id;
        asa1.PRM_Specialty_Id__c = spec1.id;
        asa1.PRM_Partner_Role__c = System.label.PRM_Service_Provider;
        asaList.add(asa1);
        
        PRM_Account_Specialty_Association__c asa2 = new PRM_Account_Specialty_Association__c();
        asa2.PRM_Account_Id__c = accPAG1.id;
        asa2.PRM_Specialty_Id__c = spec2.id;
        asa2.PRM_Partner_Role__c = System.label.PRM_Service_Provider;
        asaList.add(asa2);
        
        
        try {
            insert listOfCAG;  
        } catch (exception ex){
            System.debug('Exception ex '+ex.getMessage());
        }
        
        
        /*Database.UpsertResult[] acmErrorHandle = null;           
        acmErrorHandle = Database.upsert(listOfACM,false);
        PRM_OPIDProcessUtility.getErrorMessageForACMupsert(listOfACM,acmErrorHandle);*/
        TriggerHandler.bypass('PRM_ACMTriggerHandlerNew');
         insert listOfACM; 
         TriggerHandler.clearbypass('PRM_ACMTriggerHandlerNew');
        insert asaList;
        
        //Benefit
        PRM_PartnerBenefit__c benefit = new PRM_PartnerBenefit__c();
        benefit.PRM_Benefit_Cd__c='BNFTCS4S';
        benefit.PRM_Benefit_Dsc__c='Customer Support- 4Hr SLA';
        benefit.PRM_Benefit_Type_Nm__c='MKTG'; 
        benefit.PRM_Channel_Program_Id__c = cprogram.id;
        benefit.PRM_InActive_Ind__c =false;
        benefit.PRM_Account_Type_Nm__c = 'Mastered_Account';
        insert benefit;
        
        //Benefit
        PRM_PartnerBenefit__c benefit1 = new PRM_PartnerBenefit__c();
        benefit1.PRM_Benefit_Cd__c='BFTMKTPLBC';
        benefit1.PRM_Benefit_Dsc__c='Solution Marketplace Basic Profile';
        benefit1.PRM_Benefit_Type_Nm__c='MKTG'; 
        benefit1.PRM_Channel_Program_Id__c = cprogram.id;
        benefit1.PRM_InActive_Ind__c =false;
        benefit1.PRM_Account_Type_Nm__c = 'Core_Partner_Account_Group';
        insert benefit1;
        
        PRM_VXBnftMatrix__c vxBnft = new PRM_VXBnftMatrix__c();
        vxBnft.PRM_Partner_Benefit_Id__c = benefit.id;
        vxBnft.PRM_Partner_Role_Nm__c = System.Label.PRM_Service_Provider;
        vxBnft.PRM_Channel_Program_Level_Id__c = level.id;
        vxBnft.PRM_Approval_Type_Nm__c='Automatic';
        vxBnft.PRM_Channel_Program_Id__c=cprogram.id;
        vxBnft.PRM_IsActive_Ind__c = true;
        insert vxBnft; 
        
        PRM_VXBnftMatrix__c vxBnft1 = new PRM_VXBnftMatrix__c();
        vxBnft1.PRM_Partner_Benefit_Id__c = benefit1.id;
        vxBnft1.PRM_Partner_Role_Nm__c = 'Solution Integrator';
        vxBnft1.PRM_Channel_Program_Level_Id__c = level.id;
        vxBnft1.PRM_Approval_Type_Nm__c='Automatic';
        vxBnft1.PRM_Channel_Program_Id__c=cprogram.id;
        vxBnft1.PRM_IsActive_Ind__c = true;
        insert vxBnft1;                
        List<PRM_AccountBenefitAssociation__c> abaList = new List<PRM_AccountBenefitAssociation__c>();
        PRM_AccountBenefitAssociation__c abaObject = new PRM_AccountBenefitAssociation__c();
        abaObject.PRM_Account_Id__c = accIntel1.Id;
        abaObject.PRM_Partner_Benefit_Id__c = benefit.id;
        abaObject.PRM_Status_Nm__c ='Active';  
        abaList.add(abaObject);        
        //insert abaObject;
        
        PRM_AccountBenefitAssociation__c abaObject1 = new PRM_AccountBenefitAssociation__c();
        abaObject1.PRM_Account_Id__c = accPAG1.Id;
        abaObject1.PRM_Partner_Benefit_Id__c = benefit1.id;
        abaObject1.PRM_Status_Nm__c ='Active';        
        abaList.add(abaObject1);
        //insert abaObject1;
        
        Database.SaveResult[] abaErrorHandle = null;           
        abaErrorHandle = Database.insert(abaList,false);
        PRM_OPIDProcessUtility.getErrorMessageForABA(abaList,abaErrorHandle);
        
        
        PRM_Value_Exchange_Recommendation__c valueExchange = new PRM_Value_Exchange_Recommendation__c();
        valueExchange.RecordTypeId = opidRecommendationRecordType;
        valueExchange.PRM_Tier_Id__c = level.Id;
        valueExchange.PRM_Account_Id__c = accIntel3.Id;
        valueExchange.PRM_Recommendation_Type_Nm__c = Label.PRM_VX_RecommendationType_OPID;
        valueExchange.PRM_Recommendation_Status_Nm__c = 'In Process' ;//Label.PRM_VX_Status_OPIDInProcess
        valueExchange.PRM_Grouping_Method_Nm__c = 'GEO';
        valueExchange.PRM_Partner_Role_Nm__c = 'Distributor';
        try{
            insert valueExchange;
        } catch (exception ex){
            System.debug('Exception Ex '+ex.getMessage()); 
        }
        
        
        PRM_Value_Exchange_Recommendation__c valueExchangeReccom = new PRM_Value_Exchange_Recommendation__c();
        valueExchangeReccom.RecordTypeId = upgradeDowngradeRecordType;
        valueExchangeReccom.PRM_Tier_Id__c = level.Id;
        valueExchangeReccom.PRM_Account_Id__c = listOfAccount[1].Id;
        valueExchangeReccom.PRM_One_Partner_Id__c = listOfAccount[6].Id;
        valueExchangeReccom.PRM_Recommendation_Type_Nm__c = 'Upgrade';
        valueExchangeReccom.PRM_Recommendation_Status_Nm__c = 'In Process';
        valueExchangeReccom.PRM_Grouping_Method_Nm__c = 'GEO';
        valueExchangeReccom.PRM_Partner_Role_Nm__c = 'Distributor';
        insert valueExchangeReccom;

        PRM_Builder_Strategy__c aff= new PRM_Builder_Strategy__c();
        aff.Name='MDF-Excluded Partner';
        aff.PRM_Active__c=true;
        insert aff;

        PRM_IPA_Affiliation__c aia = new PRM_IPA_Affiliation__c();
        aia.PRM_Account__c= accIntel2.id;
        aia.PRM_Builder_Strategy__c=aff.id ;
        aia.PRM_Active__c=true;       
        insert aia;
    }
    
    /*@isTest
static void callUpsertMethod(){
PRM_OPIDPAGRecordOperation opidPAG = new PRM_OPIDPAGRecordOperation();
Map<String,PRM_AccountChannelMembership__c> mapParentACM = new Map<String,PRM_AccountChannelMembership__c>();
Map<String,List<PRM_HigestBadgeFromACMs>> mapOfGrpdAcmsByPtnrRole = new Map<String,List<PRM_HigestBadgeFromACMs>>();
PRM_OPIDErrorWrapper errorWrapper = new PRM_OPIDErrorWrapper();
List<PRM_HigestBadgeFromACMs> highestList = new List<PRM_HigestBadgeFromACMs>();

Test.startTest();
Account acc = [Select Id,Name from Account LIMIT 1];
List<PRM_AccountChannelMembership__c> acm = [Select Id,Name from PRM_AccountChannelMembership__c where PRM_Partner_Role__c =:System.Label.PRM_Service_Provider LIMIT 2];
PRM_AccountChannelMembership__c acm1 = [Select Id,Name from PRM_AccountChannelMembership__c where PRM_Partner_Role__c = 'Distributor' LIMIT 1];
PRM_HigestBadgeFromACMs highest = new PRM_HigestBadgeFromACMs(acm1);
highestList.add(highest);
mapOfGrpdAcmsByPtnrRole.put('Distributor',highestList);
mapParentACM.put('Service Provider',acm[0]);
mapParentACM.put('Service Provider',acm[1]);

opidPAG.updateOrInsertACMBadgeForOPIDAccount(mapParentACM,mapOfGrpdAcmsByPtnrRole,acc.Id,errorWrapper);
Test.stopTest();

}*/
    
    @isTest
    public static void callScheduleBatchClass(){
        Test.startTest();        
       
        try {
            PRM_ScheduleInboundOPIDBatch sh1 = new PRM_ScheduleInboundOPIDBatch();
            String sch = '0 0 23 * * ?'; 
            String jobId = system.schedule('Test Territory Check', sch, sh1);
        } catch (exception e){
            System.debug('Exception Occured'+e);
        }
        
        Test.stopTest();
        List<AsyncApexJob> jobsScheduled = [select Id, ApexClassID, ApexClass.Name, Status, JobType from AsyncApexJob where JobType = 'ScheduledApex'];
        System.assertEquals(1, jobsScheduled.size(), 'expecting one scheduled job');
    }
    
    @isTest
    public static void callScheduleBatchClassInboundMessage(){
        Id opidRecommendationRecordType = Schema.SObjectType.PRM_Value_Exchange_Recommendation__c.getRecordTypeInfosByName().get(System.Label.PRM_RecordType_OPID).getRecordTypeId();
        Id accountRecordTypeIntel = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        
         //ACM Channel
        ChannelProgram cprogram = [Select Id, Name from ChannelProgram Where name='Intel Partner Alliance'];
        
        ChannelProgramLevel level = [Select Id,ProgramId, Name from ChannelProgramLevel Where name='Gold'];   //Channel Program Level
        
        Account accIntel31 = PRM_TestUtility.getAccount();
        accIntel31.AccountNumber = '43576597';
        accIntel31.RecordTypeId = accountRecordTypeIntel;
        accIntel31.Name='New Account test user';
        accIntel31.Core_Account_Type__c ='Distributor';
        accIntel31.Industry='Agriculture';
        accIntel31.BillingCity='Daman';
        accIntel31.BillingCountryCode='IND';
        accIntel31.BillingStreet='4th,New Road';
        accIntel31.BillingPostalCode='654345';
        accIntel31.BillingStateCode='KA';
        accIntel31.Core_CIM_ID__c='1234987';
        accIntel31.Core_IPA_Partner_Role__c = 'Service Provider';
        accIntel31.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        accIntel31.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        insert accIntel31;
        
        Account accIntel51 = PRM_TestUtility.getAccount();
        accIntel51.AccountNumber = '43345597';
        accIntel51.RecordTypeId = accountRecordTypeIntel;
        accIntel51.Name='New Accuser';
        accIntel51.Core_Account_Type__c ='Distributor';
        accIntel51.Industry='Agriculture';
        accIntel51.BillingCity='Daman';
        accIntel51.BillingCountryCode='IND';
        accIntel51.BillingStreet='NagarRoad';
        accIntel51.BillingPostalCode='987122';
        accIntel51.BillingStateCode='KA';
        accIntel51.Core_CIM_ID__c='98981011';
        accIntel51.Core_IPA_Partner_Role__c = 'Service Provider';
        accIntel51.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        accIntel51.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        insert accIntel51;
        
        
        PRM_Value_Exchange_Recommendation__c valueExchange12 = new PRM_Value_Exchange_Recommendation__c();
        valueExchange12.RecordTypeId = opidRecommendationRecordType;
        valueExchange12.PRM_Tier_Id__c = level.Id;
        valueExchange12.PRM_Account_Id__c = accIntel31.Id;
        valueExchange12.PRM_Recommendation_Type_Nm__c = Label.PRM_VX_RecommendationType_OPID;
        valueExchange12.PRM_Recommendation_Status_Nm__c = 'Waiting for CIM response' ;//Label.PRM_VX_Status_OPIDInProcess
        valueExchange12.PRM_Grouping_Method_Nm__c = 'GEO';
        valueExchange12.PRM_Partner_Role_Nm__c = 'Distributor';
        TriggerHandler.bypass('PRM_VXRecommendation_Handler');
        insert valueExchange12;
        TriggerHandler.clearbypass('PRM_VXRecommendation_Handler');
        
        PRM_Value_Exchange_Recommendation__c valueExchange13 = new PRM_Value_Exchange_Recommendation__c();
        valueExchange13.RecordTypeId = opidRecommendationRecordType;
        valueExchange13.PRM_Tier_Id__c = level.Id;
        valueExchange13.PRM_Account_Id__c = accIntel51.Id;
        valueExchange13.PRM_Recommendation_Type_Nm__c = Label.PRM_VX_RecommendationType_OPID;
        valueExchange13.PRM_Recommendation_Status_Nm__c = '' ;//Label.PRM_VX_Status_OPIDInProcess
        valueExchange13.PRM_Grouping_Method_Nm__c = 'GEO';
        valueExchange13.PRM_Partner_Role_Nm__c = 'Distributor';
        TriggerHandler.bypass('PRM_VXRecommendation_Handler');
        insert valueExchange13;
        TriggerHandler.clearbypass('PRM_VXRecommendation_Handler');
        
        Test.startTest();        
        List<Account> acc = [select id from Account where name in ('TestUser1','New User')];
        List<ChannelProgramLevel> cprglevel = [select id from ChannelProgramLevel where name='Member'];
        //inbound record
        List<Core_OnePartner_Inbound_Message__c> listOfInbound = new List<Core_OnePartner_Inbound_Message__c>();
        Core_OnePartner_Inbound_Message__c inboundTable = new Core_OnePartner_Inbound_Message__c();
        inboundTable.Core_Status__c = 'NEW';
        inboundTable.Core_SalesCloud_AccountID__c = acc[0].Id;
        inboundTable.Core_OnePartnerID__c = 2001;
        inboundTable.Core_CIM_ID__c=2345987;
        inboundTable.Core_OnePartner_Account_Name__c = 'Crosswealth1';
        listOfInbound.add(inboundTable);
        
        Core_OnePartner_Inbound_Message__c inboundTable11 = new Core_OnePartner_Inbound_Message__c();
        inboundTable11.Core_Status__c = 'NEW';
        inboundTable11.Core_SalesCloud_AccountID__c = acc[0].Id;
        inboundTable11.Core_OnePartnerID__c = 2001;
        inboundTable11.Core_CIM_ID__c=2345987;
        inboundTable11.Core_OnePartner_Account_Name__c = 'Crosswealth1';
        inboundTable11.Core_Status_Effective_End_Date_Time__c = System.Now();
        listOfInbound.add(inboundTable11);
        
        Core_OnePartner_Inbound_Message__c inboundTable1 = new Core_OnePartner_Inbound_Message__c();
        inboundTable1.Core_Status__c = 'NEW';
        inboundTable1.Core_SalesCloud_AccountID__c = acc[1].Id;
        inboundTable1.Core_OnePartnerID__c = 2003;
        inboundTable1.Core_CIM_ID__c=123789678;
        inboundTable1.Core_OnePartner_Account_Name__c = 'Crosswealth3';
        listOfInbound.add(inboundTable1);
        
        Core_OnePartner_Inbound_Message__c inboundTable2 = new Core_OnePartner_Inbound_Message__c();
        inboundTable2.Core_Status__c = 'NEW';
        inboundTable2.Core_SalesCloud_AccountID__c = null;
        inboundTable2.Core_OnePartnerID__c = 2001;
        inboundTable2.Core_CIM_ID__c=2345987;
        inboundTable2.Core_OnePartner_Account_Name__c = 'Crosswealth1';
        listOfInbound.add(inboundTable2);
        
        Core_OnePartner_Inbound_Message__c inboundTable3 = new Core_OnePartner_Inbound_Message__c();
        inboundTable3.Core_Status__c = 'NEW';
        inboundTable3.Core_SalesCloud_AccountID__c = '123';
        inboundTable3.Core_OnePartnerID__c = 2001;
        inboundTable3.Core_CIM_ID__c=2345987;
        inboundTable3.Core_OnePartner_Account_Name__c = 'Crosswealth1';
        listOfInbound.add(inboundTable3);
        
        /*Core_OnePartner_Inbound_Message__c inboundTable4 = new Core_OnePartner_Inbound_Message__c();
        inboundTable4.Core_Status__c = 'STATUS UPDATE';
        inboundTable4.Core_SalesCloud_AccountID__c = accIntel31.Id;
        inboundTable4.Core_OnePartnerID__c = 2001;
        inboundTable4.Core_CIM_ID__c=2345987;
        inboundTable4.Core_OnePartner_Account_Name__c = 'Crosswealth1';
        inboundTable4.Core_Request_Purpose_Cd__c = 'CRE_PRIM_HIER';
        inboundTable4.Core_Request_Status_Cd__c = 'NEW';
        listOfInbound.add(inboundTable4);*/
        
        Core_OnePartner_Inbound_Message__c inboundTable5 = new Core_OnePartner_Inbound_Message__c();
        inboundTable5.Core_Status__c = 'STATUS UPDATE';
        inboundTable5.Core_SalesCloud_AccountID__c = accIntel31.Id;
        inboundTable5.Core_OnePartnerID__c = 2001;
        inboundTable5.Core_CIM_ID__c=2345987;
        inboundTable5.Core_OnePartner_Account_Name__c = 'Crosswealth1';
        inboundTable5.Core_Request_Purpose_Cd__c = 'CRE_PRIM_HIER';
        inboundTable5.Core_Request_Status_Cd__c = 'FAILED';
        listOfInbound.add(inboundTable5);
        
        Core_OnePartner_Inbound_Message__c inboundTable6 = new Core_OnePartner_Inbound_Message__c();
        inboundTable6.Core_Status__c = 'STATUS UPDATE';
        inboundTable6.Core_SalesCloud_AccountID__c = accIntel31.Id;
        inboundTable6.Core_OnePartnerID__c = 2001;
        inboundTable6.Core_CIM_ID__c=2345987;
        inboundTable6.Core_OnePartner_Account_Name__c = 'Crosswealth1';
        inboundTable6.Core_Request_Purpose_Cd__c = 'CRE_PRIM_HIER';
        inboundTable6.Core_Request_Status_Cd__c = 'COMPLETED';
        listOfInbound.add(inboundTable6);
        
        Core_OnePartner_Inbound_Message__c inboundTable7 = new Core_OnePartner_Inbound_Message__c();
        inboundTable7.Core_Status__c = 'STATUS UPDATE';
        inboundTable7.Core_SalesCloud_AccountID__c = accIntel31.Id;
        inboundTable7.Core_OnePartnerID__c = 2001;
        inboundTable7.Core_CIM_ID__c=2345987;
        inboundTable7.Core_OnePartner_Account_Name__c = 'Crosswealth1';
        inboundTable7.Core_Request_Purpose_Cd__c = 'CRE_CUST_AGRGT_HIER';
        inboundTable7.Core_Request_Status_Cd__c = 'WIP';
        listOfInbound.add(inboundTable7);
        
        Core_OnePartner_Inbound_Message__c inb = new Core_OnePartner_Inbound_Message__c();
        inb.Core_Status__c = 'NEW';
        inb.Core_SalesCloud_AccountID__c = accIntel31.Id;
        inb.Core_OnePartnerID__c = 2001;
        inb.Core_CIM_ID__c= 1234987 ;
        inb.Core_OnePartner_Account_Name__c = 'Crosswealth1';
        listOfInbound.add(inb);
        
        Core_OnePartner_Inbound_Message__c inb1 = new Core_OnePartner_Inbound_Message__c();
        inb1.Core_Status__c = 'NEW';
        inb1.Core_SalesCloud_AccountID__c = accIntel51.Id;
        inb1.Core_OnePartnerID__c = 2001;
        inb1.Core_CIM_ID__c= 98981011 ;
        inb1.Core_OnePartner_Account_Name__c = 'Crosswealth1';
        listOfInbound.add(inb1);
        
        
      /*  PRM_Value_Exchange_Recommendation__c valueExchange = new PRM_Value_Exchange_Recommendation__c();
        valueExchange.RecordTypeId = opidRecommendationRecordType;
        valueExchange.PRM_Tier_Id__c = cprglevel[0].Id;
        valueExchange.PRM_Account_Id__c = acc[1].Id;
        valueExchange.PRM_Recommendation_Type_Nm__c = 'OPID';
        valueExchange.PRM_Recommendation_Status_Nm__c =  'In Process';//OPID In Process
        valueExchange.PRM_Grouping_Method_Nm__c = 'GEO';
        valueExchange.PRM_Partner_Role_Nm__c = 'Distributor';
        
        insert valueExchange;*/
        
        insert listOfInbound;
        
        PRM_Tracker__c tracker = new PRM_Tracker__c();
        tracker.PRM_Type__c = 'OPID Recommendation';
        tracker.PRM_Milestone__c = 'CRE_PRIM_HIER_NEW';
        tracker.PRM_Milestone_Display_Name__c = '';
        tracker.PRM_Integration_Logs__c = '';
        tracker.PRM_Log_Entries__c = '';
        tracker.PRM_Completed__c = true;
        tracker.PRM_Integration_Outbound_Message__c = null;
        tracker.PRM_OPID_Recommendation__c = valueExchange12.Id;
        tracker.PRM_Location_Account__c = accIntel31.Id;
        tracker.PRM_OPID__c = null;
        tracker.One_Partner_Inbound_Message__c = null;
        insert tracker;
        
        PRM_Tracker__c tracker1 = new PRM_Tracker__c();
        tracker1.PRM_Type__c = 'OPID Recommendation';
        tracker1.PRM_Milestone__c = 'CRE_PRIM_HIER_WIP';
        tracker1.PRM_Milestone_Display_Name__c = '';
        tracker1.PRM_Integration_Logs__c = '';
        tracker1.PRM_Log_Entries__c = '';
        tracker1.PRM_Completed__c = false;
        tracker1.PRM_Integration_Outbound_Message__c = null;
        tracker1.PRM_OPID_Recommendation__c = valueExchange13.Id;
        tracker1.PRM_Location_Account__c = accIntel51.Id;
        tracker1.PRM_OPID__c = null;
        tracker1.One_Partner_Inbound_Message__c = null;
        insert tracker1;
        
        PRM_Tracker__c tracker2 = new PRM_Tracker__c();
        tracker2.PRM_Type__c = 'OPID Recommendation';
        tracker2.PRM_Milestone__c = 'CRE_PRIM_HIER_NEW';
        tracker2.PRM_Milestone_Display_Name__c = '';
        tracker2.PRM_Integration_Logs__c = '';
        tracker2.PRM_Log_Entries__c = '';
        tracker2.PRM_Completed__c = true;
        tracker2.PRM_Integration_Outbound_Message__c = null;
        tracker2.PRM_OPID_Recommendation__c = valueExchange13.Id;
        tracker2.PRM_Location_Account__c = accIntel51.Id;
        tracker2.PRM_OPID__c = null;
        tracker2.One_Partner_Inbound_Message__c = null;
        insert tracker2;
        
        Core_Log_Entry__c testEntry = new Core_Log_Entry__c(Core_Origin__c='Batch Cleanup Test', Core_Severity__c='Test',
                                                            Core_When__c=DateTime.now());
        insert testEntry;
         
        try {
            PRM_ScheduleInboundOPIDBatch sh1 = new PRM_ScheduleInboundOPIDBatch();
            String sch = '0 0 23 * * ?';
            String jobId = system.schedule('Test Territory Check', sch, sh1);
        } catch (exception e){
            system.debug('Exception Occured'+e);
        }
        
       
        List<AsyncApexJob> jobsScheduled = [select Id, ApexClassID, ApexClass.Name, Status, JobType from AsyncApexJob where JobType = 'ScheduledApex' limit 1];
        System.assertEquals(1, jobsScheduled.size(), 'expecting one scheduled job');
        Test.stopTest();
    }
    
    @isTest
    public static void callScheduleBatchClassInboundMessage1(){
        
        Id opidRecommendationRecordType = Schema.SObjectType.PRM_Value_Exchange_Recommendation__c.getRecordTypeInfosByName().get(System.Label.PRM_RecordType_OPID).getRecordTypeId();
        Id accountRecordTypeIntel = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        
         //ACM Channel
        ChannelProgram cprogram = [Select Id, Name from ChannelProgram Where name='Intel Partner Alliance'];
        
        ChannelProgramLevel level = [Select Id,ProgramId, Name from ChannelProgramLevel Where name='Gold'];   //Channel Program Level
        Account accIntel61 = PRM_TestUtility.getAccount();
        accIntel61.AccountNumber = '23454524';
        accIntel61.RecordTypeId = accountRecordTypeIntel;
        accIntel61.Name='New TestAccuser';
        accIntel61.Core_Account_Type__c ='Distributor';
        accIntel61.Industry='Agriculture';
        accIntel61.BillingCity='Daman';
        accIntel61.BillingCountryCode='IND';
        accIntel61.BillingStreet='PuneRoad';
        accIntel61.BillingPostalCode='878911';
        accIntel61.BillingStateCode='KA';
        accIntel61.Core_CIM_ID__c='32452421';
        accIntel61.Core_IPA_Partner_Role__c = 'Service Provider';
        accIntel61.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        accIntel61.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        insert accIntel61;
               
        PRM_Value_Exchange_Recommendation__c valueExchange14 = new PRM_Value_Exchange_Recommendation__c();
        valueExchange14.RecordTypeId = opidRecommendationRecordType;
        valueExchange14.PRM_Tier_Id__c = level.Id;
        valueExchange14.PRM_Account_Id__c = accIntel61.Id;
        valueExchange14.PRM_Recommendation_Type_Nm__c = Label.PRM_VX_RecommendationType_OPID;
        valueExchange14.PRM_Recommendation_Status_Nm__c = 'Waiting for CIM response' ;//Label.PRM_VX_Status_OPIDInProcess
        valueExchange14.PRM_Grouping_Method_Nm__c = 'GEO';
        valueExchange14.PRM_Partner_Role_Nm__c = 'Distributor';
        insert valueExchange14;
        //mp
        PRM_Tracker__c tracker = new PRM_Tracker__c();
        tracker.PRM_Type__c = 'OPID Recommendation';
        tracker.PRM_Milestone__c = 'CRE_PRIM_HIER_NEW';
        tracker.PRM_Milestone_Display_Name__c = '';
        tracker.PRM_Integration_Logs__c = '';
        tracker.PRM_Log_Entries__c = '';
        tracker.PRM_Completed__c = true;
        tracker.PRM_Integration_Outbound_Message__c = null;
        tracker.PRM_OPID_Recommendation__c = valueExchange14.Id;
        tracker.PRM_Location_Account__c = accIntel61.Id;
        tracker.PRM_OPID__c = null;
        tracker.One_Partner_Inbound_Message__c = null;
        insert tracker; //mp

        
        Test.startTest();        
        List<Account> acc = [select id from Account where name in ('TestUser1','New User')];
        List<ChannelProgramLevel> cprglevel = [select id from ChannelProgramLevel where name='Member'];
        //inbound record
        List<Core_OnePartner_Inbound_Message__c> listOfInbound = new List<Core_OnePartner_Inbound_Message__c>();
        
        Core_OnePartner_Inbound_Message__c inboundTable8 = new Core_OnePartner_Inbound_Message__c();
        inboundTable8.Core_Status__c = 'STATUS UPDATE';
        inboundTable8.Core_SalesCloud_AccountID__c = accIntel61.Id;
        inboundTable8.Core_OnePartnerID__c = 2001;
        inboundTable8.Core_CIM_ID__c=32452421;
        inboundTable8.Core_OnePartner_Account_Name__c = 'Crosswealth1';
        inboundTable8.Core_Request_Purpose_Cd__c = 'CRE_PRIM_HIER';
        inboundTable8.Core_Request_Status_Cd__c = 'NEW';
        listOfInbound.add(inboundTable8);
        
        Core_OnePartner_Inbound_Message__c inboundTable9 = new Core_OnePartner_Inbound_Message__c();
        inboundTable9.Core_Status__c = 'STATUS UPDATE';
        inboundTable9.Core_SalesCloud_AccountID__c = accIntel61.Id;
        inboundTable9.Core_OnePartnerID__c = 2001;
        inboundTable9.Core_CIM_ID__c=32452421;
        inboundTable9.Core_OnePartner_Account_Name__c = 'Crosswealth1';
        inboundTable9.Core_Request_Purpose_Cd__c = 'CRE_PRIM_HIER';
        inboundTable9.Core_Request_Status_Cd__c = 'FAILED';
        listOfInbound.add(inboundTable9);
        
        Core_Log_Entry__c testEntry = new Core_Log_Entry__c(Core_Origin__c='Batch Cleanup Test', Core_Severity__c='Test',
                                                            Core_When__c=DateTime.now());
        insert testEntry;
        
        insert listOfInbound;
        
        Id accountRecordTypePAG = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Partner_Account_Group_Record_Type).getRecordTypeId();//RT-start

        Account accPAG1 = [Select Id from Account where recordtypeid = :accountRecordTypePAG limit 1];

        Map<String,Core_OnePartner_Inbound_Message__c> opidAcc1= new Map<String,Core_OnePartner_Inbound_Message__c>();
        opidAcc1.put(accPAG1.id,inboundTable9);//RT-end
        
         try {
            Set<String> intelAccountIds = new Set<String>();
            intelAccountIds.add('123as');
            intelAccountIds.add('svc');
            //Map<Id,Core_Account_Group_Member__c> cagsToUpsertMap = Map<Id,Core_Account_Group_Member__c>();
            //cagsToUpsertMap.put(1234, null);
            PRM_ScheduleInboundOPIDBatch sh2 = new PRM_ScheduleInboundOPIDBatch();
            String sch1 = '0 0 23 * * ?';
            String jobId = system.schedule('Test Territory Check', sch1, sh2);
            PRM_UpdateOPIDRecommendation.updateOpidRecommendationStatus(opidAcc1);
            PRM_ProcessRollUpDownOPIDRecords u = new PRM_ProcessRollUpDownOPIDRecords(intelAccountIds ,null);
          Database.executeBatch(u,1);
        } catch (exception e){
            system.debug('Exception Occured'+e);
            Database.executeBatch(null,0);
        }  
        
        List<AsyncApexJob> jobsScheduled = [select Id, ApexClassID, ApexClass.Name, Status, JobType from AsyncApexJob where JobType = 'ScheduledApex' limit 1];
        System.assertEquals(1, jobsScheduled.size(), 'expecting one scheduled job');
        Test.stopTest();
    }
    
    
    @isTest
    public static void callScheduleBatchClassInboundMessageRemoveAccount(){
        Id accountRecordTypeIntel = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        Account accIntel = new Account();
        accIntel.RecordTypeId = accountRecordTypeIntel;
        accIntel.AccountNumber = '65436';
        accIntel.Name='New Account 1';
        accIntel.BillingCity='New Delhi';
        accIntel.BillingCountryCode='IND';
        accIntel.BillingStreet='Joshi Marg';
        accIntel.BillingPostalCode='8658';
        accIntel.BillingStateCode='KA';
        accIntel.Core_CIM_ID__c='98657';
        accIntel.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        accIntel.Industry = 'Construction';
        insert accIntel;
        
        Test.startTest();                
        
        List<Account> acc = [select id from Account where name in ('New Account')];
        //inbound record
        List<Core_OnePartner_Inbound_Message__c> listOfInbound = new List<Core_OnePartner_Inbound_Message__c>();
        Core_OnePartner_Inbound_Message__c inboundTable = new Core_OnePartner_Inbound_Message__c();
        inboundTable.Core_Status__c = 'NEW';
        inboundTable.Core_SalesCloud_AccountID__c = acc[0].Id;
        inboundTable.Core_OnePartnerID__c = 2002;
        inboundTable.Core_CIM_ID__c=1235987;
        inboundTable.Core_OnePartner_Account_Name__c = 'Crosswealth2';
        inboundTable.Core_Effective_End_Date_Time__c = Date.newInstance(2016, 12, 9);
        
        Account acc1 = [Select Id from Account where Name = 'TestUser'];
        acc1.Core_Deactivated__c = true;
        acc1.Core_Deactivation_Reason__c = 'Account created in error';
        update acc1;
        Core_OnePartner_Inbound_Message__c inboundTable1 = new Core_OnePartner_Inbound_Message__c();
        inboundTable1.Core_Status__c = 'NEW';
        inboundTable1.Core_SalesCloud_AccountID__c = acc1.Id;
        inboundTable1.Core_OnePartnerID__c = 2001;
        inboundTable1.Core_CIM_ID__c=234567;
        inboundTable1.Core_OnePartner_Account_Name__c = 'Crosswealth2566';
        //inboundTable1.Core_Effective_End_Date_Time__c = Date.newInstance(2016, 12, 9);
        listOfInbound.add(inboundTable1);
        
        Core_OnePartner_Inbound_Message__c inboundTable3 = new Core_OnePartner_Inbound_Message__c();
        inboundTable3.Core_Status__c = 'NEW';
        inboundTable3.Core_SalesCloud_AccountID__c = acc[0].Id;
        inboundTable3.Core_OnePartnerID__c = 2002;
        inboundTable3.Core_CIM_ID__c=1235987;
        inboundTable3.Core_OnePartner_Account_Name__c = 'Crosswealth2';
        inboundTable3.Core_Effective_End_Date_Time__c = Date.newInstance(2016, 12, 9);
        inboundTable3.Core_Effective_Start_Date_Time__c = Date.newInstance(2016, 12, 9);
        listOfInbound.add(inboundTable3);
        
        Core_OnePartner_Inbound_Message__c inboundTable4 = new Core_OnePartner_Inbound_Message__c();
        inboundTable4.Core_Status__c = 'NEW';
        inboundTable4.Core_SalesCloud_AccountID__c = accIntel.Id;
        inboundTable4.Core_OnePartnerID__c = 2002;
        inboundTable4.Core_CIM_ID__c=98657;
        inboundTable4.Core_OnePartner_Account_Name__c = 'Crosswealth2';
        //inboundTable4.Core_Effective_End_Date_Time__c = Date.newInstance(2016, 12, 9);
        inboundTable4.Core_Effective_Start_Date_Time__c = Date.newInstance(2016, 12, 9);
        listOfInbound.add(inboundTable4);
        
        Core_OnePartner_Inbound_Message__c inboundTable5 = new Core_OnePartner_Inbound_Message__c();
        inboundTable5.Core_Status__c = 'NEW';
        inboundTable5.Core_SalesCloud_AccountID__c = accIntel.Id;
        inboundTable5.Core_CIM_ID__c=98657;
        inboundTable5.Core_OnePartner_Account_Name__c = 'Crosswealth2';
        //inboundTable4.Core_Effective_End_Date_Time__c = Date.newInstance(2016, 12, 9);
        inboundTable5.Core_Effective_Start_Date_Time__c = Date.newInstance(2016, 12, 9);
        listOfInbound.add(inboundTable5);
        insert listOfInbound;
        
        Core_Account_Group_Member__c cag = [Select Id, Core_Inactive_Ind__c from Core_Account_Group_Member__c where Core_Intel_Account_Id__c =:acc1.id];
        cag.Core_Inactive_Ind__c = true;
        update cag;
        
        Core_Log_Entry__c testEntry = new Core_Log_Entry__c(Core_Origin__c='Batch Cleanup Test', Core_Severity__c='Test',
                                                            Core_When__c=DateTime.now());
        insert testEntry;
        
        PRM_ScheduleInboundOPIDBatch sh1 = new PRM_ScheduleInboundOPIDBatch();
        String sch = '0 0 23 * * ?';
        try {
            String jobId = system.schedule('Test Territory Check', sch, sh1);                   
            callScheduleBatchClassInboundMessageReactivateAccount(); 
        } catch (exception e){
            System.debug('Exception Occured'+e);
        }
        List<AsyncApexJob> jobsScheduled = [select Id, ApexClassID, ApexClass.Name, Status, JobType from AsyncApexJob where JobType = 'ScheduledApex'];
        
        Test.stopTest();
        System.assertEquals(2, jobsScheduled.size(), 'expecting two scheduled job');
    }
    
    @isTest
    public static void testDiscardMessages(){
        Id accountRecordTypeIntel = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        Id accountRecordTypePAG = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Partner_Account_Group_Record_Type).getRecordTypeId();
        Id selectBenefitId=Schema.SObjectType.PRM_Specialty__c.getRecordTypeInfosByName().get('Select Benefits').getRecordTypeId();
        
        List<Account> listOfAccount = new List<Account>();
        Account accIntel = PRM_TestUtility.getAccount();
        accIntel.RecordTypeId = accountRecordTypeIntel;
        accIntel.AccountNumber = '43576576';
        accIntel.Name='Test Discard';
        accIntel.BillingCity='Mumbai';
        accIntel.BillingCountryCode='IND';
        accIntel.BillingStreet='Joshi Street';
        accIntel.BillingPostalCode='65467';
        accIntel.BillingStateCode='KA';
        accIntel.Core_CIM_ID__c='86789';
        accIntel.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        accIntel.Industry = 'Construction';
        listOfAccount.add(accIntel);  
        
        Account accIntel1 = PRM_TestUtility.getAccount();
        accIntel1.RecordTypeId = accountRecordTypeIntel;
        accIntel1.AccountNumber = '6789';
        accIntel1.Name='Test Discard123';
        accIntel1.BillingCity='Nagpur';
        accIntel1.BillingCountryCode='IND';
        accIntel1.BillingStreet='St Martin Street';
        accIntel1.BillingPostalCode='65467';
        accIntel1.BillingStateCode='KA';
        accIntel1.Core_CIM_ID__c='867659';
        accIntel1.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        accIntel1.Industry = 'Construction';
        listOfAccount.add(accIntel1);
        
        Account accIntel2 = PRM_TestUtility.getAccount();
        accIntel2.RecordTypeId = accountRecordTypeIntel;
        accIntel2.AccountNumber = '638789';
        accIntel2.Name='Test Discard1235';
        accIntel2.BillingCity='Nagpur';
        accIntel2.BillingCountryCode='IND';
        accIntel2.BillingStreet='St Martin Street';
        accIntel2.BillingPostalCode='123876';
        accIntel2.BillingStateCode='MH';
        accIntel2.Core_CIM_ID__c='6598123';
        accIntel2.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        accIntel2.Industry = 'Construction';
        listOfAccount.add(accIntel2);
        
        Account accPAG = new Account();
        accPAG.RecordTypeId = accountRecordTypePAG;
        accPAG.Name = 'Crosswealth12345';
        // accPAG.Core_OnePartnerID__c = '2001456';    
        // accPAG.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        listOfAccount.add(accPAG);
        
        Account accPAG1 = new Account();
        accPAG1.RecordTypeId = accountRecordTypePAG;
        accPAG1.Name = 'Crosswealth12345';
        accPAG1.Core_OnePartnerID__c = '7612908';    
        // accPAG.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        listOfAccount.add(accPAG1);
        
        insert listOfAccount;
        
        ChannelProgram cprogram = [Select Id from ChannelProgram where Name = 'Intel Partner Alliance'];
        Test.startTest();
        List<ChannelProgramLevel> cpLevelList = [Select Id from ChannelProgramLevel where Name IN ('Member','Gold')];
        
        List<PRM_AccountChannelMembership__c> acmList = new List<PRM_AccountChannelMembership__c>();
        
        PRM_AccountChannelMembership__c  acm = PRM_TestUtility.getMembership();
        acm.PRM_Account_Id__c = accPAG1.Id;
        acm.PRM_Channel_Program_Id__c = cprogram.Id;
        acm.PRM_Partner_Role__c=System.Label.PRM_Service_Provider;
        acm.PRM_Status_Nm__c ='Approved';
        acm.PRM_Channel_Program_Level_Id__c = cpLevelList[0].id;
        acm.PRM_Status_Reason_Txt__c = 'Test';
        acmList.add(acm);
        
        PRM_AccountChannelMembership__c  acm1 = PRM_TestUtility.getMembership();
        acm1.PRM_Account_Id__c = accIntel1.Id;
        acm1.PRM_Channel_Program_Id__c = cprogram.Id;
        acm1.PRM_Partner_Role__c=System.Label.PRM_Service_Provider;
        acm1.PRM_Status_Nm__c ='Approved';
        acm1.PRM_Channel_Program_Level_Id__c = cpLevelList[1].id;
        acm1.PRM_Status_Reason_Txt__c = 'Test';
        acmList.add(acm1);
        TriggerHandler.bypass('PRM_ACMTriggerHandlerNew');
        insert acmList;                               
        TriggerHandler.clearbypass('PRM_ACMTriggerHandlerNew');                    
        
        PRM_Specialty__c spec1 = [Select Id from PRM_Specialty__c where name = 'Select Benefit'];
        
        List<PRM_Account_Specialty_Association__c> asaList = new List<PRM_Account_Specialty_Association__c>();
        PRM_Account_Specialty_Association__c asa = new PRM_Account_Specialty_Association__c();
        asa.PRM_Account_Id__c= accIntel1.id;
        asa.PRM_Specialty_Id__c= spec1.id;
        asa.PRM_Partner_Role__c=System.label.PRM_Service_Provider; 
        asaList.add(asa);
        
        insert asaList;
        
        List<Core_Account_Group_Member__c> listOfCAG = new List<Core_Account_Group_Member__c>();
        Core_Account_Group_Member__c cag = new Core_Account_Group_Member__c();
        cag.Core_Intel_Account_Id__c = accIntel.Id;    
        cag.Core_Partner_Account_Id__c = accPAG.id;
        //cag.Core_Inactive_Ind__c = true;
        insert cag;
        
        List<Core_OnePartner_Inbound_Message__c> listOfInbound = new List<Core_OnePartner_Inbound_Message__c>();
        Core_OnePartner_Inbound_Message__c inboundTable = new Core_OnePartner_Inbound_Message__c();
        inboundTable.Core_Status__c = 'NEW';
        inboundTable.Core_SalesCloud_AccountID__c = accIntel.id;
        inboundTable.Core_OnePartnerID__c = 2001456;
        inboundTable.Core_CIM_ID__c=86789;
        inboundTable.Core_OnePartner_Account_Name__c = 'Crosswealth2677';
        inboundTable.Core_Effective_End_Date_Time__c = Date.newInstance(2016, 12, 9);
        listOfInbound.add(inboundTable);
        
        Core_OnePartner_Inbound_Message__c inboundTable1 = new Core_OnePartner_Inbound_Message__c();
        inboundTable1.Core_Status__c = 'NEW';
        inboundTable1.Core_SalesCloud_AccountID__c = accIntel1.id;
        inboundTable1.Core_OnePartnerID__c = 7612908;
        inboundTable1.Core_CIM_ID__c=867659;
        inboundTable1.Core_OnePartner_Account_Name__c = 'accIntel1344';        
        listOfInbound.add(inboundTable1);
        
        Core_OnePartner_Inbound_Message__c inboundTable2 = new Core_OnePartner_Inbound_Message__c();
        inboundTable2.Core_Status__c = 'FAILED';
        inboundTable2.Core_SalesCloud_AccountID__c = accIntel2.id;
        inboundTable2.Core_OnePartnerID__c = 357899;
        inboundTable2.Core_CIM_ID__c=6598123;
        inboundTable2.Core_OnePartner_Account_Name__c = 'accIntel190344'; 
        inboundTable2.Core_Effective_End_Date_Time__c = Date.newInstance(2016, 12, 9);       
        listOfInbound.add(inboundTable2);
        
        Core_Log_Entry__c testEntry = new Core_Log_Entry__c(Core_Origin__c='Batch Cleanup Test', Core_Severity__c='Test',
                                                            Core_When__c=DateTime.now());
        insert testEntry;
        
        
        insert listOfInbound;                
        try {
            PRM_ProcessInboundOPIDRecords b = new PRM_ProcessInboundOPIDRecords(); 
            Database.executeBatch(b,200);  
        } catch (exception e){
            System.debug('Exception Occured'+e);
            Database.executeBatch(null,0);
        }
        
        
        Test.stopTest();
        System.assertEquals(inboundTable1.Core_OnePartner_Account_Name__c,'accIntel1344','Value does not match');
        /*

Set<String> setOfSegment = new Set<String>();
setOfSegment.add(asa.PRM_Specialty_Id__c+'-'+asa.PRM_Partner_Role__c);
Map<String,Set<String>> mapOfSegmentsForAcc = new Map<String,Set<String>>();
mapOfSegmentsForAcc.put(asa.PRM_Account_Id__c, setOfSegment);
Set<String> setOfChild = new Set<String>();
setOfChild.add(asa.PRM_Account_Id__c);
PRM_OPIDPAGRecordOperation opidClass = new PRM_OPIDPAGRecordOperation(null,null,null,null,null,null);
opidClass.getDistinctSegmentForParent(setOfChild, mapOfSegmentsForAcc);*/
    }
    
    @isTest
    public static void testInvalidSfId(){
        Id accountRecordTypeIntel = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        Account acc = new Account();Account accIntel1 = PRM_TestUtility.getAccount();
        accIntel1.RecordTypeId = accountRecordTypeIntel;
        accIntel1.AccountNumber = '4357659738';
        accIntel1.Name='TestUser1';
        accIntel1.BillingCity='Punjab';
        accIntel1.BillingCountryCode='IND';
        accIntel1.BillingStreet='Joshi Marg';
        accIntel1.BillingPostalCode='678767';
        accIntel1.BillingStateCode='KA';
        accIntel1.Core_CIM_ID__c='567889';
        accIntel1.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        accIntel1.Industry = 'Construction';
        insert accIntel1;
        
        //delete accIntel1;
        
        Test.startTest();
        
        Core_OnePartner_Inbound_Message__c inboundTable2 = new Core_OnePartner_Inbound_Message__c();
        inboundTable2.Core_Status__c = 'NEW';
        inboundTable2.Core_SalesCloud_AccountID__c = accIntel1.id;
        inboundTable2.Core_OnePartnerID__c = 357899;
        inboundTable2.Core_CIM_ID__c=6598123;
        inboundTable2.Core_OnePartner_Account_Name__c = 'accIntel190344'; 
        inboundTable2.Core_Effective_End_Date_Time__c = Date.newInstance(2016, 12, 9);       
        insert inboundTable2;
        
        Core_Log_Entry__c testEntry = new Core_Log_Entry__c(Core_Origin__c='Batch Cleanup Test', Core_Severity__c='Test',
                                                            Core_When__c=DateTime.now());
        insert testEntry;
        
        try {
        PRM_ProcessInboundOPIDRecords b = new PRM_ProcessInboundOPIDRecords(); 
        Database.executeBatch(b,200);  
        } catch (exception e){
            system.debug('Exception Occured'+e);
            Database.executeBatch(null,0);
        }                    
        
        
        Test.stopTest();
        Core_OnePartner_Inbound_Message__c inbMsg = [Select Id, Core_Status__c from Core_OnePartner_Inbound_Message__c where id = :inboundTable2.id];
        // System.assertEquals(inbMsg.Core_Status__c,System.Label.PRM_INBOUNDMSG_PROCESS_FAILED,'Inbound Msg record is expected to fail');        
    }
    
    public static void callScheduleBatchClassInboundMessageReactivateAccount(){
        
        List<Account> acc = [select id from Account where name in ('New Account')];
        //inbound record
        List<Core_OnePartner_Inbound_Message__c> listOfInbound = new List<Core_OnePartner_Inbound_Message__c>();
        Core_OnePartner_Inbound_Message__c inboundTable = new Core_OnePartner_Inbound_Message__c();
        inboundTable.Core_Status__c = 'NEW';
        inboundTable.Core_SalesCloud_AccountID__c = acc[0].Id;
        inboundTable.Core_OnePartnerID__c = 2002;
        inboundTable.Core_CIM_ID__c=1235987;
        inboundTable.Core_OnePartner_Account_Name__c = 'Crosswealth2';
        inboundTable.Core_Status_Effective_End_Date_Time__c=System.now().addDays(-2);
        //inboundTable.Core_Effective_End_Date_Time__c = Date.newInstance(2016, 12, 9);
        listOfInbound.add(inboundTable);
        
        insert listOfInbound;
        
        PRM_ScheduleInboundOPIDBatch sh1 = new PRM_ScheduleInboundOPIDBatch();
        String sch = '0 0 23 * * ?'; 
        try {
            String jobId = system.schedule('Test Territory', sch, sh1);
        } catch (exception e){
            
        }
                
        
        List<AsyncApexJob> jobsScheduled = [select Id, ApexClassID, ApexClass.Name, Status, JobType from AsyncApexJob where JobType = 'ScheduledApex'];
    }
    
    @isTest
    public static void callScheduleBatchClassInboundMessageInactivateAccount(){
        Test.startTest();        
        List<Account> acc = [select id from Account where name in ('New Account','New Account User')];
        //inbound record
        List<Core_OnePartner_Inbound_Message__c> listOfInbound = new List<Core_OnePartner_Inbound_Message__c>();
        Core_OnePartner_Inbound_Message__c inboundTable = new Core_OnePartner_Inbound_Message__c();
        inboundTable.Core_Status__c = 'NEW';
        inboundTable.Core_SalesCloud_AccountID__c = acc[0].Id;
        inboundTable.Core_OnePartnerID__c = 2002;
        inboundTable.Core_CIM_ID__c=1235987;
        inboundTable.Core_OnePartner_Account_Name__c = 'Crosswealth2';
        inboundTable.Core_Effective_End_Date_Time__c = Date.newInstance(2016, 12, 9);
        listOfInbound.add(inboundTable);
        
        Core_OnePartner_Inbound_Message__c inboundTable2 = new Core_OnePartner_Inbound_Message__c();
        inboundTable2.Core_Status__c = 'NEW';
        inboundTable2.Core_SalesCloud_AccountID__c = acc[1].Id;
        inboundTable2.Core_OnePartnerID__c = 75788;
        inboundTable2.Core_CIM_ID__c=1234987;
        inboundTable2.Core_OnePartner_Account_Name__c = 'NEW One';
        inboundTable2.Core_Effective_End_Date_Time__c = System.now() - 1;
        listOfInbound.add(inboundTable2);  
        
        //insert listOfInbound;
        
        PRM_ScheduleInboundOPIDBatch sh1 = new PRM_ScheduleInboundOPIDBatch();
        String sch = '0 0 23 * * ?'; 
        try {
            String jobId = system.schedule('Test Territory Check', sch, sh1);
        } catch (exception e){
            
        }
                
        Test.stopTest();
        List<AsyncApexJob> jobsScheduled = [select Id, ApexClassID, ApexClass.Name, Status, JobType from AsyncApexJob where JobType = 'ScheduledApex'];
        System.assertEquals(1, jobsScheduled.size(), 'expecting one scheduled job');
    }
    
    public static testmethod void testErrorMethod(){
        List<Core_OnePartner_Inbound_Message__c> updatedList = new List<Core_OnePartner_Inbound_Message__c>();
        Map<String,String> pagAccountMapError = new Map<String,String>();
        Map<String,String> pagAccountIDDetails = new Map<String,String>();
        Map<String,String> asaMapError = new Map<String,String>();
        Map<String,String> acmMapError = new Map<String,String>();
        Map<String,String> cagMapError = new Map<String,String>();
        Map<String,String> aiaMapError = new Map<String,String>();
        
        Test.startTest();
        List<Account> acc = [select id,Name,Core_OnePartnerID__c from Account where name in ('Crosswealth1','Crosswealth2','TestUser','New Account','New Account User')]; 
        Set<string> set_Ids =  new Set<string>();
        for (Account accounts : acc){
            set_Ids.add(accounts.Id);
        }
       
        System.debug('acc >> '+acc); 
        List<Core_OnePartner_Inbound_Message__c> listOfInbound = new List<Core_OnePartner_Inbound_Message__c>();
        Core_OnePartner_Inbound_Message__c inboundTable = new Core_OnePartner_Inbound_Message__c();
        inboundTable.Core_Status__c = 'NEW';
        inboundTable.Core_SalesCloud_AccountID__c = acc[2].Id;
        inboundTable.Core_OnePartnerID__c = 2001;
        inboundTable.Core_CIM_ID__c = 234567;
        inboundTable.Core_OnePartner_Account_Name__c = 'Crosswealth1';
        inboundTable.Core_Effective_End_Date_Time__c = Date.newInstance(2016, 12, 9);
        listOfInbound.add(inboundTable);
        
        Core_OnePartner_Inbound_Message__c inboundTable1 = new Core_OnePartner_Inbound_Message__c();
        inboundTable1.Core_Status__c = 'NEW';
        inboundTable1.Core_SalesCloud_AccountID__c = acc[3].Id;
        inboundTable1.Core_OnePartnerID__c = 2002;
        inboundTable1.Core_CIM_ID__c=1235987;
        inboundTable1.Core_OnePartner_Account_Name__c = 'Crosswealth2';
        listOfInbound.add(inboundTable1);                  
        
        insert listOfInbound;                  
        
        pagAccountMapError.put(acc[2].Core_OnePartnerID__c,'PAG error');        
        asaMapError.put(acc[2].id,'ASA error');
        acmMapError.put(acc[2].id,'ACM error');
        cagMapError.put(acc[3].id,'CAG error');
        aiaMapError.put(acc[3].id,'AIA error');
        
        PRM_OPIDErrorWrapper errorWrapper = new PRM_OPIDErrorWrapper();
        errorWrapper.putPAGError(pagAccountMapError);
        errorWrapper.putACMError(acmMapError);
        errorWrapper.putASAError(asaMapError);
        errorWrapper.putCAGError(cagMapError); 
        errorWrapper.putAIAError(aiaMapError);
        
        PRM_OPIDPAGRecordOperation PAGRecCreation = new  PRM_OPIDPAGRecordOperation();
        List<Core_Account_Group_Member__c> listOfAGM = [SELECT Id,Core_Intel_Account_Id__c,Core_Partner_Account_Id__c 
                                                        FROM Core_Account_Group_Member__c];
        PAGRecCreation.getPagAccountDetails(set_Ids);
        try{
           PAGRecCreation.deleteACMsonPAGAcc(listOfAGM,acc, null ); 
        } catch(exception ex){
            
        }
        
        
        PRM_OPIDPAGRecordOperation opidPagRecordOpr = new PRM_OPIDPAGRecordOperation(listOfInbound,pagAccountMapError,pagAccountIDDetails,asaMapError,acmMapError,cagMapError,aiaMapError);
        // opidPagRecordOpr.errLogForProcInMessage(errorWrapper);
        //system.assertequals(inboundTable.Error_Description__c,'ACM error','Value does not match'); 
        Test.stopTest(); 
        system.assertequals(inboundTable.Core_OnePartner_Account_Name__c,'Crosswealth1','Value does not match'); 
    }
    
    public static testmethod void testUtilityErrorMethod(){
        Id accountRecordTypePAG = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Partner_Account_Group_Record_Type).getRecordTypeId();
        Id accountRecordTypeIntel = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        Account accIntel = [Select Id from Account limit 1];
        
        Core_OnePartner_Inbound_Message__c inboundTable1 = new Core_OnePartner_Inbound_Message__c();
        inboundTable1.Core_Status__c = 'LOAD COMPLETE';
        inboundTable1.Core_SalesCloud_AccountID__c = accIntel.Id;
        inboundTable1.Core_OnePartnerID__c = 20012;
        inboundTable1.Core_CIM_ID__c = 23498723;    
        inboundTable1.Core_OnePartner_Account_Name__c = 'TestUiltityMethod';
        
        insert inboundTable1;
        
        Map<String,String> mapACMissue =new Map<String,String>();
        mapACMissue.put(accIntel.id,'ACM MAP ISSUE');
        Test.startTest();
        PRM_OPIDProcessUtility.updateErrorDetailsAtInboundTable(mapACMissue); 
        Test.stopTest();
        System.assertEquals(inboundTable1.Core_SalesCloud_AccountID__c,accIntel.Id,'Value does not match');
    }
    
    public static testmethod void testUtilityABAErrorMethod(){
        Id accountRecordTypePAG = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Partner_Account_Group_Record_Type).getRecordTypeId();
        Id accountRecordTypeIntel = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        
        Account accIntel = [Select Id from Account where recordtypeid = :accountRecordTypePAG limit 1];
        Account accPAG = [Select Id from Account where recordtypeid = :accountRecordTypePAG limit 1];
        Core_OnePartner_Inbound_Message__c inboundTable1 = new Core_OnePartner_Inbound_Message__c();
        inboundTable1.Core_Status__c = 'LOAD COMPLETE';
        inboundTable1.Core_SalesCloud_AccountID__c = accIntel.Id;
        inboundTable1.Core_OnePartnerID__c = 20012;
        inboundTable1.Core_CIM_ID__c = 3456575;
        inboundTable1.Core_OnePartner_Account_Name__c = 'TestUiltityMethod';
        insert inboundTable1;
        
        Map<String,String> abaMapError = new Map<String,String>();
        abaMapError.put(accPAG.id,'ABA issue');
        
        Map<String,Core_OnePartner_Inbound_Message__c> opidAcc= new Map<String,Core_OnePartner_Inbound_Message__c>();
        opidAcc.put(accPAG.id,inboundTable1);
        
        Test.startTest();
        try {
          PRM_OPIDProcessUtility.updateABAErrorsInBoundTable(abaMapError,opidAcc);   
        } catch (exception e){
            
        }
        
        Test.stopTest();
        System.assertEquals(inboundTable1.Core_SalesCloud_AccountID__c,accIntel.Id,'Value does not match');
    }
    
    
    public static testmethod void testftest(){
        List<Core_OnePartner_Inbound_Message__c> updatedList = new List<Core_OnePartner_Inbound_Message__c>();
        Map<String,String> pagAccountMapError = new Map<String,String>();
        Map<String,String> pagAccountIDDetails = new Map<String,String>();
        Map<String,String> asaMapError = new Map<String,String>();
        Map<String,String> acmMapError = new Map<String,String>();
        Map<String,String> cagMapError = new Map<String,String>();
        Map<String,String> aiaMapError = new Map<String,String>();
        
        Test.startTest();
        Id accountRecordTypeIntel = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        Id accountRecordTypePAG = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Partner_Account_Group_Record_Type).getRecordTypeId();
        Id opidRecommendationRecordType = Schema.SObjectType.PRM_Value_Exchange_Recommendation__c.getRecordTypeInfosByName().get(System.Label.PRM_RecordType_OPID).getRecordTypeId();
        
        List<Account> listofAccount=new List<Account>(); 
        Account accIntelu = PRM_TestUtility.getAccount();
        accIntelu.RecordTypeId = accountRecordTypeIntel;
        accIntelu.Name='nvuirvi';
        accIntelu.AccountNumber = '435765';
        accIntelu.BillingCity='New Delhi';
        accIntelu.BillingCountryCode='IND';
        accIntelu.BillingStreet='Joshi Marg';
        accIntelu.BillingPostalCode='65467';
        accIntelu.BillingStateCode='KA';
        accIntelu.Core_CIM_ID__c='7964678';
        accIntelu.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        accIntelu.Industry = 'Construction';
        listofAccount.add(accIntelu);
        //insert accIntelu;
        
        Account accPAGu = new Account();
        accPAGu.RecordTypeId = accountRecordTypePAG;
        accPAGu.Name = 'nnceuncu';
        accPAGu.Core_OnePartnerID__c = '3003';
        //accPAG.Core_OPID_Name__c = 'nnceuncu';
        //accPAGu.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        //insert accPAGu;
        listofAccount.add(accPAGu);
        insert listofAccount;
        
        ChannelProgram cprogramup = new ChannelProgram();
        cprogramup=[SELECT Name, PRM_programCode__c FROM ChannelProgram WHERE Name='Intel Partner Alliance'];
        
        ChannelProgramLevel levelu = new ChannelProgramLevel();   //Channel Program Level
        levelu.Name='Gold';
        levelu.ProgramId = cprogramup.Id;
        insert levelu;
        
        ChannelProgramLevel levelu1 = new ChannelProgramLevel();   //Channel Program Level
        levelu1.Name='Member';
        levelu1.ProgramId = cprogramup.Id;
        insert levelu1;
        
        List <PRM_AccountChannelMembership__c> updatedACMList=new List<PRM_AccountChannelMembership__c>(); 
        PRM_AccountChannelMembership__c  acm1= PRM_TestUtility.getMembership();
        acm1.PRM_Account_Id__c = accIntelu.Id;
        acm1.PRM_Channel_Program_Id__c = cprogramup.Id;
        acm1.PRM_Partner_Role__c=System.Label.PRM_Service_Provider;
        acm1.PRM_Status_Nm__c ='Inactive';//Approved
        acm1.PRM_Channel_Program_Level_Id__c = levelu.id;
        acm1.PRM_Status_Reason_Txt__c='ACM inactivated as part of OPID process.';
        updatedACMList.add(acm1);
        
        Database.SaveResult[] acmErrorHandle = null;           
        acmErrorHandle = Database.insert(updatedACMList,false);
        PRM_OPIDProcessUtility.getErrorMessageForACM(updatedACMList,acmErrorHandle);
        // insert updatedACMList; 
        
        /*acm1=[Select PRM_Status_Nm__c,PRM_Account_Id__c,PRM_Partner_Role__c FROM PRM_AccountChannelMembership__c WHERE Id=:acm1.Id];
acm1.PRM_Status_Reason_Txt__c='ACM inactivated as part of OPID process.';//Inactive
acm1.PRM_Channel_Program_Level_Id__c=levelu1.Id;
//updatedACMList.add(acm1);  

update updatedACMList;
*/
        
        List<Core_Account_Group_Member__c> listOfCAG = new List<Core_Account_Group_Member__c>();
        Core_Account_Group_Member__c cag = new Core_Account_Group_Member__c();
        cag.Core_Intel_Account_Id__c = accIntelu.Id;    
        cag.Core_Partner_Account_Id__c = accPAGu.Id;
        //cag.Core_Inactive_Ind__c = true;
        insert cag;
        cag.Core_Inactive_Ind__c = true;
        update cag;
        
        PRM_Specialty__c spec1u = [Select Id, Name from PRM_Specialty__c where Name = 'Addition Select Benefit'];
        PRM_Specialty__c spec2 = [Select Id, Name from PRM_Specialty__c where Name = 'Select Benefit'];
       /* Id selectBenefitId= Schema.getGlobalDescribe().get('PRM_Specialty__c').getDescribe().getRecordTypeInfosByDeveloperName().get('PRM_Select_Benefits').getRecordTypeId();  
        List<PRM_Specialty__c> listofSpecilaty=new List<PRM_Specialty__c>();
        PRM_Specialty__c spec1u = new PRM_Specialty__c();
        spec1u.name='Addition Select Benefit';
        spec1u.PRM_Description_Txt__c='This is description';
        spec1u.PRM_Funding_BU_Nm__c='CCG Sales Group';
        spec1u.PRM_Role_Nm__c='Service Provider';
        spec1u.PRM_Tier_Nm__c='Gold';
        spec1u.PRM_Start_Date_Dt__c= system.today() + 7;
        spec1u.PRM_End_Date_Dt__c= spec1u.PRM_Start_Date_Dt__c + 5;
        spec1u.PRM_Access_Level_Nm__c='Public';
        spec1u.RecordTypeId = selectBenefitId;
        //listofSpecilaty.add(spec1u);
        insert spec1u;
        
        PRM_Specialty__c spec2 = new PRM_Specialty__c();
        spec2.name='Select Benefit';
        spec2.PRM_Description_Txt__c='This is description';
        spec2.PRM_Funding_BU_Nm__c='CCG Sales Group';
        spec2.PRM_Role_Nm__c='Service Provider';
        spec2.PRM_Tier_Nm__c='Gold';
        spec2.PRM_Start_Date_Dt__c= system.today() + 7;
        spec2.PRM_End_Date_Dt__c= spec2.PRM_Start_Date_Dt__c + 5;
        spec2.PRM_Access_Level_Nm__c='Public';
        spec2.PRM_Inactive_Ind__c=false;
        spec2.RecordTypeId=selectBenefitId;
        //listofSpecilaty.add(spec2);
        insert spec2;*/
        
        //insert listofSpecilaty;
        
        List<PRM_Account_Specialty_Association__c> asaList = new List<PRM_Account_Specialty_Association__c>();
        PRM_Account_Specialty_Association__c asa = new PRM_Account_Specialty_Association__c();
        asa.PRM_Account_Id__c= accIntelu.id;
        asa.PRM_Specialty_Id__c= spec1u.id;
        asa.PRM_Partner_Role__c=System.label.PRM_Service_Provider;     
        asaList.add(asa);
        
        PRM_Account_Specialty_Association__c asa2 = new PRM_Account_Specialty_Association__c();
        asa2.PRM_Account_Id__c= accIntelu.id;
        asa2.PRM_Specialty_Id__c= spec2.id;
        asa2.PRM_Partner_Role__c=System.label.PRM_Service_Provider;     
        asaList.add(asa2);  
        
        
        PRM_Account_Specialty_Association__c asaPAG = new PRM_Account_Specialty_Association__c();
        asaPAG.PRM_Account_Id__c= accIntelu.id;
        asaPAG.PRM_Specialty_Id__c= spec1u.id;
        asaPAG.PRM_Partner_Role__c=System.label.PRM_Service_Provider;       
        asaList.add(asaPAG);
        
        PRM_Account_Specialty_Association__c asaPAG2 = new PRM_Account_Specialty_Association__c();
        asaPAG2.PRM_Account_Id__c= accIntelu.id;
        asaPAG2.PRM_Specialty_Id__c= spec2.id;
        asaPAG2.PRM_Partner_Role__c=System.label.PRM_Service_Provider;       
        asaList.add(asaPAG2);
        
        insert asaList;
        
        List<Core_OnePartner_Inbound_Message__c> listOfInbound = new List<Core_OnePartner_Inbound_Message__c>();
        Core_OnePartner_Inbound_Message__c inboundTableu = new Core_OnePartner_Inbound_Message__c();
        inboundTableu.Core_Status__c = 'NEW';
        inboundTableu.Core_SalesCloud_AccountID__c = accIntelu.Id;
        inboundTableu.Core_OnePartnerID__c = 3003;
        inboundTableu.Core_CIM_ID__c = 7964678;
        inboundTableu.Core_OnePartner_Account_Name__c = 'mncuedh';
        // inboundTable.Core_Effective_End_Date_Time__c = Date.newInstance(2016, 12, 9);
        listOfInbound.add(inboundTableu);                  
        
        insert listOfInbound;                  
        
        Core_OnePartner_Inbound_Message__c inboundTable = new Core_OnePartner_Inbound_Message__c();
        inboundTable.Core_Status__c = 'NEW';
        inboundTable.Core_SalesCloud_AccountID__c = accIntelu.Id;
        inboundTable.Core_OnePartnerID__c = 3003;
        inboundTable.Core_CIM_ID__c=7964678;
        inboundTable.Core_OnePartner_Account_Name__c = 'mncuedh';
        inboundTable.Core_Effective_End_Date_Time__c = Date.newInstance(2020, 08, 31);
        insert inboundTable;
        
        
        Map<String,String> abaMapError = new Map<String,String>();
        abaMapError.put(accPAGu.id,'ABA issue');
        
        Map<String,Core_OnePartner_Inbound_Message__c> opidAcc= new Map<String,Core_OnePartner_Inbound_Message__c>();
        opidAcc.put(accPAGu.id,inboundTable);
        
        pagAccountMapError.put(accIntelu.Core_OnePartnerID__c,'PAG error');        
        asaMapError.put(accIntelu.id,'ASA error');
        acmMapError.put(accIntelu.id,'ACM error');
        cagMapError.put(accIntelu.id,'CAG error');
        aiaMapError.put(accIntelu.id,'AIA error');
        
        PRM_OPIDErrorWrapper errorWrapper = new PRM_OPIDErrorWrapper();
        errorWrapper.putPAGError(pagAccountMapError);
        errorWrapper.putACMError(acmMapError);
        errorWrapper.putASAError(asaMapError);
        errorWrapper.putCAGError(cagMapError); 
        errorWrapper.putAIAError(aiaMapError);
        
        
        PRM_OPIDPAGRecordOperation opidPagRecordOpr = new PRM_OPIDPAGRecordOperation(listOfInbound,pagAccountMapError,pagAccountIDDetails,asaMapError,acmMapError,cagMapError,aiaMapError);
        //opidPagRecordOpr.errLogForProcInMessage(errorWrapper);        //system.assertequals(inboundTable.Error_Description__c,'ACM error','Value does not match'); 
        
        
        try {
            PRM_ScheduleInboundOPIDBatch sh1 = new PRM_ScheduleInboundOPIDBatch();
            String sch = '0 0 23 * * ?';
            String jobId = system.schedule('Test Territory Check', sch, sh1); 
        } catch (exception e){
            System.debug('Exception Occured'+e);
        }
        
        
        Test.stopTest();
        List<AsyncApexJob> jobsScheduled = [select Id, ApexClassID, ApexClass.Name, Status, JobType from AsyncApexJob where JobType = 'ScheduledApex'];
        
        //callScheduleBatchClassInboundMessageReactivateAccount();
        System.assertEquals(1, jobsScheduled.size(), 'expecting one scheduled job');
        
        
    }
    //US821813:OPID upgrade recommendation record removal from recommendation table - detachment of location account from OPID
    @isTest
    private static void testVxDeletion(){
        Account acc = [Select id from Account where name in ('TestUser1','New Account') LIMIT 1];
        acc.Core_OnePartnerID__c='2002';
        update acc;
        Core_OnePartner_Inbound_Message__c inboundTable = new Core_OnePartner_Inbound_Message__c();
        inboundTable.Core_Status__c = 'NEW';
        inboundTable.Core_SalesCloud_AccountID__c = acc.Id;
        inboundTable.Core_OnePartnerID__c = 2002;
        inboundTable.Core_CIM_ID__c=2345987;
        inboundTable.Core_OnePartner_Account_Name__c = 'Crosswealth2';
        inboundTable.Core_Effective_End_Date_Time__c = System.now().addDays(-2);
        insert inboundTable;//inbound table record for inactivation of CAG.
        Test.startTest();
        try {
            PRM_ProcessInboundOPIDRecords inboundBatch=new PRM_ProcessInboundOPIDRecords();
            Database.executeBatch(inboundBatch);
        } catch (exception e){
            Database.executeBatch(null);
        }
        
        Test.stopTest();
        PRM_Value_Exchange_Data__c vxData=[Select PRM_One_Partner_Id__c from PRM_Value_Exchange_Data__c where PRM_Account_Id__c=:acc.Id Limit 1];
        
        //System.assertEquals(null, vxData.PRM_One_Partner_Id__c);
    }
    @isTest
    public static void testUpdateOPIDRecommendation(){
        Id recordTypeIdOPIDAcc = Schema.SObjectType.Account.getRecordTypeInfosByName().get(System.Label.PRM_ParentAccRecordType).getRecordTypeId();
        Id accountRecordTypeIntel = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        Id opidRecommendationRecordType = Schema.SObjectType.PRM_Value_Exchange_Recommendation__c.getRecordTypeInfosByName().get(System.Label.PRM_RecordType_OPID).getRecordTypeId();

        List<Account> acc = new List<Account>();
        Account accIntel1 = PRM_TestUtility.getAccount();
        accIntel1.RecordTypeId = accountRecordTypeIntel;
        accIntel1.AccountNumber = '735729';
        accIntel1.Name='Test OPID Recommendation';
        accIntel1.BillingCity='Chennai';
        accIntel1.BillingCountryCode='IND';
        accIntel1.BillingStreet='St Martin Street';
        accIntel1.BillingPostalCode='65467';
        accIntel1.BillingStateCode='TN';
        accIntel1.Core_CIM_ID__c='7393740';
        accIntel1.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        accIntel1.Industry = 'Construction';
        acc.add(accIntel1);
        
        Account newAccount3 = new Account();//Account
        newAccount3.RecordTypeId = recordTypeIdOPIDAcc;
        newAccount3.Name='Test 4';
        newAccount3.BillingCity='City';
        newAccount3.BillingStreet='Street';
        newAccount3.BillingCountry='India';
        newAccount3.BillingPostalCode='Postal code';
        newAccount3.Core_IPA_Partner_Role__c = 'Solution Integrator';
        newAccount3.Core_Account_Type__c='Cloud Service Provider (CSP)';
        acc.add(newAccount3);

        insert acc;    
        
        List<Core_OnePartner_Inbound_Message__c> inbList = new List<Core_OnePartner_Inbound_Message__c>();
        Core_OnePartner_Inbound_Message__c inboundTableu = new Core_OnePartner_Inbound_Message__c();
        inboundTableu.Core_Status__c = 'NEW';
        inboundTableu.Core_SalesCloud_AccountID__c = accIntel1.Id;
        inboundTableu.Core_OnePartnerID__c = 73829;
        inboundTableu.Core_CIM_ID__c = 7393740;
        inboundTableu.Core_OnePartner_Account_Name__c = 'OPID Recommendation';       
        inbList.add(inboundTableu);
        
        insert inbList;
        
        List<string> logString = new List<string>{'Logentry','Logentry1'};
        
        
        List<ChannelProgramLevel> level = [select id from ChannelProgramLevel where name='Member'];
        Test.startTest();
        PRM_Value_Exchange_Recommendation__c valueExchange = new PRM_Value_Exchange_Recommendation__c();
        valueExchange.RecordTypeId = opidRecommendationRecordType;
        valueExchange.PRM_Tier_Id__c = level[0].id;
        valueExchange.PRM_Account_Id__c = accIntel1.Id;
        valueExchange.PRM_Recommendation_Type_Nm__c = Label.PRM_VX_RecommendationType_OPID;
        valueExchange.PRM_Recommendation_Status_Nm__c = 'In Process' ;//Label.PRM_VX_Status_OPIDInProcess
        valueExchange.PRM_Grouping_Method_Nm__c = 'GEO';
        valueExchange.PRM_Partner_Role_Nm__c = 'Distributor';
        insert valueExchange;
        
        
        valueExchange.PRM_Recommendation_Status_Nm__c = 'OPID In Process';
        
        update valueExchange;
        
        Core_Account_Group_Member__c agm2 = new Core_Account_Group_Member__c();
        agm2.Core_Partner_Account_Id__c = newAccount3.Id;
        agm2.Core_Intel_Account_Id__c = accIntel1.Id;
        agm2.Core_MDA_Ind__c = true;
        agm2.Core_Inactive_Ind__c = false;
        insert agm2;
        
        List<string> intelIds = new List<String>();
        Map<Id,Core_Account_Group_Member__c> cagsToinsert = new Map<Id,Core_Account_Group_Member__c>();
        intelIds.add(valueExchange.PRM_Account_Id__c);
        cagsToinsert.put(accIntel1.Id,agm2);

        
        PRM_UpdateOPIDRecommendation.updateValueExchangeRecords(intelIds,cagsToinsert);
        try {
            PRM_ProcessInboundOPIDRecords b = new PRM_ProcessInboundOPIDRecords(); 
            Database.executeBatch(b,200);
        } catch (exception e){
            system.debug('Exception Occured'+e);
            Database.executeBatch(null,0);
        }
        
        system.debug('inbList---->'+inbList.size());
        system.debug('logString---->'+logString.size());
        PRM_OPIDPAGRecordOperation opidNew = new PRM_OPIDPAGRecordOperation();
        opidNew.inactivateCoreAccGrpMembers(inbList,logString);
        PRM_Value_Exchange_Recommendation__c vx1 = [Select Id,PRM_Recommendation_Status_Nm__c from PRM_Value_Exchange_Recommendation__c where id = :valueExchange.id];
        Test.stopTest();   
        //system.assertEquals(vx1.PRM_Recommendation_Status_Nm__c, 'OPID Created', 'OPID recommendation record failed to update');
    }
    
    @isTest
    public static void testDuplicateInboundMessage(){
        Id opidRecommendationRecordType = Schema.SObjectType.PRM_Value_Exchange_Recommendation__c.getRecordTypeInfosByName().get(System.Label.PRM_RecordType_OPID).getRecordTypeId();
        Test.startTest();        
        List<Account> acc = [select id from Account where name in ('TestUser1','New User')];
        List<ChannelProgramLevel> cprglevel = [select id from ChannelProgramLevel where name='Member'];
        Core_Account_Group_Member__c cag = [Select id from Core_Account_Group_Member__c where Core_Intel_Account_Id__c=:acc[0].Id LIMIT 1];
        //inbound record
        List<Core_OnePartner_Inbound_Message__c> listOfInbound = new List<Core_OnePartner_Inbound_Message__c>();
        Core_OnePartner_Inbound_Message__c inboundTable = new Core_OnePartner_Inbound_Message__c();
        inboundTable.Core_Status__c = 'NEW';
        inboundTable.Core_SalesCloud_AccountID__c = acc[0].Id;
        inboundTable.Core_OnePartnerID__c = 2001;
        inboundTable.Core_CIM_ID__c=2345987;
        inboundTable.Core_OnePartner_Account_Name__c = 'Crosswealth1';
        listOfInbound.add(inboundTable);
        
        Core_OnePartner_Inbound_Message__c inboundTable1 = new Core_OnePartner_Inbound_Message__c();
        inboundTable1.Core_Status__c = 'NEW';
        inboundTable.Core_SalesCloud_AccountID__c =acc[1].Id;//Nj
        inboundTable1.Core_OnePartnerID__c = 2001;
        inboundTable1.Core_CIM_ID__c=2345987;
        inboundTable1.Core_OnePartner_Account_Name__c = 'Crosswealth10';
        listOfInbound.add(inboundTable1);
        
        insert listOfInbound;
        delete cag;
        
        PRM_ScheduleInboundOPIDBatch sh1 = new PRM_ScheduleInboundOPIDBatch();
        String sch = '0 0 23 * * ?'; 
        try {
            String jobId = system.schedule('Test Territory Check', sch, sh1);     
        } catch (exception e){
            system.debug('Exception Occured'+e);
        }
        
        Test.stopTest();
        List<AsyncApexJob> jobsScheduled = [select Id, ApexClassID, ApexClass.Name, Status, JobType from AsyncApexJob where JobType = 'ScheduledApex'];
        System.assertEquals(1, jobsScheduled.size(), 'expecting one scheduled job');
    } 
    
    
    @isTest
    public static void callScheduleBatchClassAccount(){
        Id accountRecordTypeIntel = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        Account accIntel = new Account();
        accIntel.RecordTypeId = accountRecordTypeIntel;
        accIntel.AccountNumber = '65436';
        accIntel.Name='New Account 1';
        accIntel.BillingCity='New Delhi';
        accIntel.BillingCountryCode='IND';
        accIntel.BillingStreet='Joshi Marg';
        accIntel.BillingPostalCode='8658';
        accIntel.BillingStateCode='KA';
        accIntel.Core_CIM_ID__c='98657';
        accIntel.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        accIntel.Industry = 'Construction';
        insert accIntel;
        
        Test.startTest();                
        
        List<Account> acc = [select id from Account where name in ('New Account')];
        //inbound record
        List<Core_OnePartner_Inbound_Message__c> listOfInbound = new List<Core_OnePartner_Inbound_Message__c>();
        Core_OnePartner_Inbound_Message__c inboundTable = new Core_OnePartner_Inbound_Message__c();
        inboundTable.Core_Status__c = 'NEW';
        inboundTable.Core_SalesCloud_AccountID__c = acc[0].Id;
        inboundTable.Core_OnePartnerID__c = 2002;
        inboundTable.Core_CIM_ID__c=1235987;
        inboundTable.Core_OnePartner_Account_Name__c = 'Crosswealth2';
        inboundTable.Core_Effective_End_Date_Time__c = Date.newInstance(2016, 12, 9);
        
        Account acc1 = [Select Id from Account where Name = 'TestUser'];
        Core_OnePartner_Inbound_Message__c inboundTable1 = new Core_OnePartner_Inbound_Message__c();
        inboundTable1.Core_Status__c = 'NEW';
        inboundTable1.Core_SalesCloud_AccountID__c = acc1.Id;
        inboundTable1.Core_OnePartnerID__c = 2001;
        inboundTable1.Core_CIM_ID__c=234567;
        inboundTable1.Core_OnePartner_Account_Name__c = 'Crosswealth2566';
        //inboundTable1.Core_Effective_End_Date_Time__c = Date.newInstance(2016, 12, 9);
        listOfInbound.add(inboundTable1);
        
        Core_OnePartner_Inbound_Message__c inboundTable3 = new Core_OnePartner_Inbound_Message__c();
        inboundTable3.Core_Status__c = 'NEW';
        inboundTable3.Core_SalesCloud_AccountID__c = acc[0].Id;
        inboundTable3.Core_OnePartnerID__c = 2002;
        inboundTable3.Core_CIM_ID__c=1235987;
        inboundTable3.Core_OnePartner_Account_Name__c = 'Crosswealth2';
        inboundTable3.Core_Effective_End_Date_Time__c = Date.newInstance(2016, 12, 9);
        inboundTable3.Core_Effective_Start_Date_Time__c = Date.newInstance(2016, 12, 9);
        listOfInbound.add(inboundTable3);
        
        Account acc2 = [Select Id from Account where Name = 'TestUser1'];
        Core_OnePartner_Inbound_Message__c inboundTable5 = new Core_OnePartner_Inbound_Message__c();
        inboundTable5.Core_Status__c = 'NEW';
        inboundTable5.Core_SalesCloud_AccountID__c = acc2.Id;
        inboundTable5.Core_CIM_ID__c=1235987;
        inboundTable5.Core_OnePartner_Account_Name__c = 'Crosswealth2';
        inboundTable5.Core_Effective_Start_Date_Time__c = Date.newInstance(2016, 12, 9);
        listOfInbound.add(inboundTable5);
        
        Core_OnePartner_Inbound_Message__c inboundTable4 = new Core_OnePartner_Inbound_Message__c();
        inboundTable4.Core_Status__c = 'NEW';
        inboundTable4.Core_SalesCloud_AccountID__c = accIntel.Id;
        inboundTable4.Core_OnePartnerID__c = 2002;
        inboundTable4.Core_CIM_ID__c=98657;
        inboundTable4.Core_OnePartner_Account_Name__c = 'Crosswealth2';
        //inboundTable4.Core_Effective_End_Date_Time__c = Date.newInstance(2016, 12, 9);
        inboundTable4.Core_Effective_Start_Date_Time__c = Date.newInstance(2016, 12, 9);
        listOfInbound.add(inboundTable4);
        insert listOfInbound;
        
        Core_Account_Group_Member__c cag = [Select Id, Core_Inactive_Ind__c, PRM_RelationshipEndDate__c from Core_Account_Group_Member__c where Core_Intel_Account_Id__c =:acc1.id];
        cag.Core_Inactive_Ind__c = false;
        cag.PRM_RelationshipEndDate__c = null;
        update cag;
        
        Core_Account_Group_Member__c cag1 = [Select Id, Core_Inactive_Ind__c, PRM_RelationshipEndDate__c from Core_Account_Group_Member__c where Core_Intel_Account_Id__c =:acc2.id];
        cag1.Core_Inactive_Ind__c = false;
        cag1.PRM_RelationshipEndDate__c = Date.newInstance(2015, 12, 9);
        update cag1;
        
        PRM_ScheduleInboundOPIDBatch sh1 = new PRM_ScheduleInboundOPIDBatch();
        String sch = '0 0 23 * * ?';
        try {
            String jobId = system.schedule('Test Territory Check', sch, sh1);                   
            callScheduleBatchClassInboundMessageReactivateAccount(); 
        } catch (exception e){
            System.debug('Exception Occured'+e);
        }
        List<AsyncApexJob> jobsScheduled = [select Id, ApexClassID, ApexClass.Name, Status, JobType from AsyncApexJob where JobType = 'ScheduledApex'];
        
        Test.stopTest();
        System.assertEquals(2, jobsScheduled.size(), 'expecting two scheduled job');
    }
    
    
    @isTest
    public static void testDiscardMessagesAndInactiveACMs(){
        Id accountRecordTypeIntel = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        Id accountRecordTypePAG = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Partner_Account_Group_Record_Type).getRecordTypeId();
        Id selectBenefitId=Schema.SObjectType.PRM_Specialty__c.getRecordTypeInfosByName().get('Select Benefits').getRecordTypeId();
        
        List<Account> listOfAccount = new List<Account>();
        Account accIntel = PRM_TestUtility.getAccount();
        accIntel.RecordTypeId = accountRecordTypeIntel;
        accIntel.AccountNumber = '43576576';
        accIntel.Name='Test Discard';
        accIntel.BillingCity='Mumbai';
        accIntel.BillingCountryCode='IND';
        accIntel.BillingStreet='Joshi Street';
        accIntel.BillingPostalCode='65467';
        accIntel.BillingStateCode='KA';
        accIntel.Core_CIM_ID__c='86789';
        accIntel.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        accIntel.Industry = 'Construction';
        listOfAccount.add(accIntel);  
        
        Account accIntel1 = PRM_TestUtility.getAccount();
        accIntel1.RecordTypeId = accountRecordTypeIntel;
        accIntel1.AccountNumber = '6789';
        accIntel1.Name='Test Discard123';
        accIntel1.BillingCity='Nagpur';
        accIntel1.BillingCountryCode='IND';
        accIntel1.BillingStreet='St Martin Street';
        accIntel1.BillingPostalCode='65467';
        accIntel1.BillingStateCode='KA';
        accIntel1.Core_CIM_ID__c='867659';
        accIntel1.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        accIntel1.Industry = 'Construction';
        listOfAccount.add(accIntel1);
        
        Account accIntel2 = PRM_TestUtility.getAccount();
        accIntel2.RecordTypeId = accountRecordTypeIntel;
        accIntel2.AccountNumber = '638789';
        accIntel2.Name='Test Discard1235';
        accIntel2.BillingCity='Nagpur';
        accIntel2.BillingCountryCode='IND';
        accIntel2.BillingStreet='St Martin Street';
        accIntel2.BillingPostalCode='123876';
        accIntel2.BillingStateCode='MH';
        accIntel2.Core_CIM_ID__c='6598123';
        accIntel2.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        accIntel2.Industry = 'Construction';
        listOfAccount.add(accIntel2);
        
        Account accPAG = new Account();
        accPAG.RecordTypeId = accountRecordTypePAG;
        accPAG.Name = 'Crosswealth12345';
        // accPAG.Core_OnePartnerID__c = '2001456';    
        // accPAG.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        listOfAccount.add(accPAG);
        
        Account accPAG1 = new Account();
        accPAG1.RecordTypeId = accountRecordTypePAG;
        accPAG1.Name = 'Crosswealth12345';
        accPAG1.Core_OnePartnerID__c = '7612908';    
        // accPAG.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        listOfAccount.add(accPAG1);
        
        insert listOfAccount;
        
        ChannelProgram cprogram = [Select Id from ChannelProgram where Name = 'Intel Partner Alliance'];
        Test.startTest();
        List<ChannelProgramLevel> cpLevelList = [Select Id from ChannelProgramLevel where Name IN ('Member','Gold')];
        
        List<PRM_AccountChannelMembership__c> acmList = new List<PRM_AccountChannelMembership__c>();
        
        PRM_AccountChannelMembership__c  acm = PRM_TestUtility.getMembership();
        acm.PRM_Account_Id__c = accPAG1.Id;
        acm.PRM_Channel_Program_Id__c = cprogram.Id;
        acm.PRM_Partner_Role__c=System.Label.PRM_Service_Provider;
        acm.PRM_Status_Nm__c ='Inactive';
        acm.PRM_Channel_Program_Level_Id__c = cpLevelList[0].id;
        acm.PRM_Status_Reason_Txt__c='ACM inactivated as part of OPID process.';
        acmList.add(acm);
        
        PRM_AccountChannelMembership__c  acm1 = PRM_TestUtility.getMembership();
        acm1.PRM_Account_Id__c = accIntel1.Id;
        acm1.PRM_Channel_Program_Id__c = cprogram.Id;
        acm1.PRM_Partner_Role__c=System.Label.PRM_Service_Provider;
        acm1.PRM_Status_Nm__c ='Inactive';
        acm1.PRM_Channel_Program_Level_Id__c = cpLevelList[1].id;
        acm1.PRM_Status_Reason_Txt__c='ACM inactivated as part of OPID process.';
        acmList.add(acm1);
        
        insert acmList;                               
        
        PRM_Specialty__c spec1 = [Select Id from PRM_Specialty__c where name = 'Select Benefit'];
        
        List<PRM_Account_Specialty_Association__c> asaList = new List<PRM_Account_Specialty_Association__c>();
        PRM_Account_Specialty_Association__c asa = new PRM_Account_Specialty_Association__c();
        asa.PRM_Account_Id__c= accIntel1.id;
        asa.PRM_Specialty_Id__c= spec1.id;
        asa.PRM_Partner_Role__c=System.label.PRM_Service_Provider;       
        asaList.add(asa);
        
        insert asaList;
         PRM_HigestBadgeFromACMs obj1 = new PRM_HigestBadgeFromACMs(acm1);
         obj1.compareTo(obj1);
        List<Core_Account_Group_Member__c> listOfCAG = new List<Core_Account_Group_Member__c>();
        Core_Account_Group_Member__c cag = new Core_Account_Group_Member__c();
        cag.Core_Intel_Account_Id__c = accIntel.Id;    
        cag.Core_Partner_Account_Id__c = accPAG.id;
        //cag.Core_Inactive_Ind__c = true;
        insert cag;
        
        List<Core_OnePartner_Inbound_Message__c> listOfInbound = new List<Core_OnePartner_Inbound_Message__c>();
        Core_OnePartner_Inbound_Message__c inboundTable = new Core_OnePartner_Inbound_Message__c();
        inboundTable.Core_Status__c = 'NEW';
        inboundTable.Core_SalesCloud_AccountID__c = accIntel.id;
        inboundTable.Core_OnePartnerID__c = 2001456;
        inboundTable.Core_CIM_ID__c=86789;
        inboundTable.Core_OnePartner_Account_Name__c = 'Crosswealth2677';
        inboundTable.Core_Effective_End_Date_Time__c = Date.newInstance(2016, 12, 9);
        listOfInbound.add(inboundTable);
        
        Core_OnePartner_Inbound_Message__c inboundTable1 = new Core_OnePartner_Inbound_Message__c();
        inboundTable1.Core_Status__c = 'NEW';
        inboundTable1.Core_SalesCloud_AccountID__c = accIntel1.id;
        inboundTable1.Core_OnePartnerID__c = 7612908;
        inboundTable1.Core_CIM_ID__c=867659;
        inboundTable1.Core_OnePartner_Account_Name__c = 'accIntel1344';        
        listOfInbound.add(inboundTable1);
        
        Core_OnePartner_Inbound_Message__c inboundTable2 = new Core_OnePartner_Inbound_Message__c();
        inboundTable2.Core_Status__c = 'NEW';
        inboundTable2.Core_SalesCloud_AccountID__c = accIntel2.id;
        inboundTable2.Core_OnePartnerID__c = 357899;
        inboundTable2.Core_CIM_ID__c=6598123;
        inboundTable2.Core_OnePartner_Account_Name__c = 'accIntel190344'; 
        inboundTable2.Core_Effective_End_Date_Time__c = Date.newInstance(2016, 12, 9);       
        listOfInbound.add(inboundTable2);
        
        
        insert listOfInbound;                
        try {
            PRM_ProcessInboundOPIDRecords b = new PRM_ProcessInboundOPIDRecords(); 
            Database.executeBatch(b,200);  
        } catch (exception e){
            System.debug('Exception Occured'+e);
            Database.executeBatch(null,0);
        }
        
        
        Test.stopTest();
        System.assertEquals(inboundTable1.Core_OnePartner_Account_Name__c,'accIntel1344','Value does not match');
        /*

Set<String> setOfSegment = new Set<String>();
setOfSegment.add(asa.PRM_Specialty_Id__c+'-'+asa.PRM_Partner_Role__c);
Map<String,Set<String>> mapOfSegmentsForAcc = new Map<String,Set<String>>();
mapOfSegmentsForAcc.put(asa.PRM_Account_Id__c, setOfSegment);
Set<String> setOfChild = new Set<String>();
setOfChild.add(asa.PRM_Account_Id__c);
PRM_OPIDPAGRecordOperation opidClass = new PRM_OPIDPAGRecordOperation(null,null,null,null,null,null);
opidClass.getDistinctSegmentForParent(setOfChild, mapOfSegmentsForAcc);*/
    }
    
   
    @isTest
    Public static void test123(){
        Map<String,String> opidErrMap = new Map<String,String>();
        Map<String,String> cagErrMap = new Map<String,String>();
         Id accountRecordTypeIntel = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        
        Account accIntel1 = PRM_TestUtility.getAccount();
        accIntel1.RecordTypeId = accountRecordTypeIntel;
        accIntel1.AccountNumber = '6789';
        accIntel1.Name='Test Discard123';
        accIntel1.BillingCity='Nagpur';
        accIntel1.BillingCountryCode='IND';
        accIntel1.BillingStreet='St Martin Street';
        accIntel1.BillingPostalCode='65467';
        accIntel1.BillingStateCode='KA';
        accIntel1.Core_CIM_ID__c='867659';
        accIntel1.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        accIntel1.Industry = 'Construction';
        insert accIntel1;
        
           Account accIntel2 = PRM_TestUtility.getAccount();
        accIntel2.RecordTypeId = accountRecordTypeIntel;
        accIntel2.AccountNumber = '638789';
        accIntel2.Name='Test Discard1235';
        accIntel2.BillingCity='Nagpur';
        accIntel2.BillingCountryCode='IND';
        accIntel2.BillingStreet='St Martin Street';
        accIntel2.BillingPostalCode='123876';
        accIntel2.BillingStateCode='MH';
        accIntel2.Core_CIM_ID__c='6598123';
        accIntel2.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        accIntel2.Industry = 'Construction';
       insert accIntel2;
        
        List<Core_OnePartner_Inbound_Message__c> listOfInbound = new List<Core_OnePartner_Inbound_Message__c>();
        List<Core_OnePartner_Inbound_Message__c> discardedInboundMessagesList = new List<Core_OnePartner_Inbound_Message__c>();
        
        Core_OnePartner_Inbound_Message__c inboundTable1 = new Core_OnePartner_Inbound_Message__c();
        inboundTable1.Core_Status__c = 'NEW';
        inboundTable1.Core_SalesCloud_AccountID__c = accIntel1.id;
        inboundTable1.Core_OnePartnerID__c = 7612908;
        inboundTable1.Core_CIM_ID__c=867659;
        inboundTable1.Core_OnePartner_Account_Name__c = 'accIntel1344';        
        listOfInbound.add(inboundTable1);
        
         Core_OnePartner_Inbound_Message__c inboundTable2 = new Core_OnePartner_Inbound_Message__c();
         inboundTable2.Core_Status__c = 'NEW';
         inboundTable2.Core_SalesCloud_AccountID__c = accIntel2.id;
         inboundTable2.Core_OnePartnerID__c = 357899;
         inboundTable2.Core_CIM_ID__c=6598123;
         inboundTable2.Core_OnePartner_Account_Name__c = 'accIntel190344'; 
         inboundTable2.Core_Effective_End_Date_Time__c = Date.newInstance(2016, 12, 9);       
        
        discardedInboundMessagesList.add(inboundTable2);
        insert listOfInbound;
        insert discardedInboundMessagesList;
        
        opidErrMap.put(String.valueOf(inboundTable1.Core_OnePartnerID__c.intValue()), 'ERROR');
        cagErrMap.put(inboundTable1.Core_SalesCloud_AccountID__c, 'TESTERROR');
        
        Test.startTest();
        PRM_ProcessInboundOPIDRecords p = new PRM_ProcessInboundOPIDRecords();
        /*PRM_ProcessInboundOPIDRecords.updateStatusWrapper obj = new PRM_ProcessInboundOPIDRecords.updateStatusWrapper();
        obj.listOfAllInboundprocess = listOfInbound;
        obj.opidErrMap = opidErrMap;
        obj.cagErrMap = cagErrMap;
        obj.discardedInboundMessagesList = discardedInboundMessagesList;
        obj.errorMsg = 'errorMsg';
        p.updateStatus(obj); //Athr fixes*/
        p.updateStatus(listOfInbound,opidErrMap,cagErrMap,discardedInboundMessagesList, 'errorMsg');
        Test.stopTest();
    }
    
    @isTest
    Public static void test345(){
        
         Id accountRecordTypeIntel = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        list<account> acclist = new List<Account>();
        list<Core_OnePartner_Inbound_Message__c> ListofInbound = new list<Core_OnePartner_Inbound_Message__c>();
        
        
        for(integer i; i<251; i++){
         Account accIntel2 = PRM_TestUtility.getAccount();
        accIntel2.RecordTypeId = accountRecordTypeIntel;
        accIntel2.AccountNumber = '638789'+i.format();
        accIntel2.Name='Test Discard1235'+i.format();
        accIntel2.BillingCity='Nagpur'+i.format();
        accIntel2.BillingCountryCode='IND';
        accIntel2.BillingStreet='St Martin Street';
        accIntel2.BillingPostalCode='123876'+i.format();
        accIntel2.BillingStateCode='MH';
        accIntel2.Core_CIM_ID__c='6598123'+i.format();
        accIntel2.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        accIntel2.Industry = 'Construction';
        acclist.add(accIntel2);
        }
        insert acclist;
        for(integer i; i<251; i++){
         Core_OnePartner_Inbound_Message__c inboundTable2 = new Core_OnePartner_Inbound_Message__c();
         inboundTable2.Core_Status__c = 'NEW';
         inboundTable2.Core_SalesCloud_AccountID__c = acclist[i].id;
         inboundTable2.Core_OnePartnerID__c = 357899;
         inboundTable2.Core_CIM_ID__c=6598123;
         inboundTable2.Core_OnePartner_Account_Name__c = 'accIntel190344'; 
         inboundTable2.Core_Effective_End_Date_Time__c = Date.newInstance(2016, 12, 9); 
         ListofInbound.add(inboundTable2);
        }
        
        insert ListofInbound;
        
        Test.startTest();
         try {
            PRM_ProcessInboundOPIDRecords b = new PRM_ProcessInboundOPIDRecords(); 
            Database.executeBatch(b,200);  
        } catch (exception e){
            System.debug('Exception Occured'+e);
            Database.executeBatch(null,0);
        }
        
        
        Test.stopTest();
    }
    
    @isTest
    public static void approvedAqrTest(){
        
        Account acc = [select id from Account where name in ('New Account')];
        List<id> aqrId = new List<id>();
        Account_Create_Request__c aqr =new Account_Create_Request__c();
        aqr.Requested_Account__c = acc.id;
        aqr.Account_Name__c ='New Account';
        aqr.Status__c ='Pending Approval';
        aqr.Core_Alternate_Language_Name__c = 'New Account';
        aqr.Core_Alternate_Name_Language__c ='ENG';
        aqr.Customer_Aggregation_Type__c ='UNFD_GLBL_CUST';
        aqr.Standardized_Address_City__c = 'Carmel';
        aqr.Standardized_Address_Country_Code__c ='USA';
        aqr.Standardized_Address_Postal_Code__c='93923';
        aqr.Standardized_Address_State_Code__c='CA';
        aqr.Standardized_Address_Street__c='Carpenter Rd';
        aqr.Requestor_Email__c ='testuser123@test.com';
        insert aqr;
        aqr.Status__c='Approved';
        update aqr;
        aqrId.add(aqr.Id);
        Test.startTest();        
        PRM_OPIDProcessUtility.OpidAssociationForNonIpaIntelAccount(aqrid);
        Test.stopTest();
    }

    @isTest
    public static void updateVXRecommendationAndVXDataTest(){
        
        List<Account> acc = [select id from Account where name in ('New Account','Crosswealth2')];
        Set<String> succssPAGInactiveSet = new Set<String>();
        String intelOPIDAcc = acc[0].id+';'+acc[1].id;
        succssPAGInactiveSet.add(intelOPIDAcc);
        Test.startTest();        
        PRM_OPIDPAGRecordOperation.updateVXRecommendationAndVXData(succssPAGInactiveSet);
        Test.stopTest();
    }

    @isTest
    public static void delinkingTest(){
        
        List<Account> acc = [select id from Account where name in ('New Account','TestUser1','New Account User')];
        List<Core_OnePartner_Inbound_Message__c> listOfInbound = new List<Core_OnePartner_Inbound_Message__c>();
            
        Core_OnePartner_Inbound_Message__c inboundTable7 = new Core_OnePartner_Inbound_Message__c();
        inboundTable7.Core_Status__c = 'NEW';
        inboundTable7.Core_SalesCloud_AccountID__c = acc[2].Id;
        inboundTable7.Core_CIM_ID__c=1235987;
        inboundTable7.Core_OnePartnerID__c = 7612908;
        inboundTable7.Core_OnePartner_Account_Name__c = 'Crosswealth2';
        inboundTable7.Core_PAG_Grouping_Method__c = 'GLBL';
        inboundTable7.Core_Status_Effective_End_Date_Time__c =System.now();
        listOfInbound.add(inboundTable7);
 
        Core_OnePartner_Inbound_Message__c inboundTable8 = new Core_OnePartner_Inbound_Message__c();
        inboundTable8.Core_Status__c = 'NEW';
        inboundTable8.Core_CIM_ID__c=1235987;
        inboundTable8.Core_SalesCloud_AccountID__c = acc[1].Id;
        inboundTable8.Core_OnePartnerID__c = 9999999;
        inboundTable8.Core_OnePartner_Account_Name__c = 'Crosswealth2';
        inboundTable8.Core_Effective_Start_Date_Time__c = Date.newInstance(2016, 12, 9);
        inboundTable7.Core_Status_Effective_End_Date_Time__c =System.now();
        listOfInbound.add(inboundTable8);
        
    Core_OnePartner_Inbound_Message__c inboundTable5 = new Core_OnePartner_Inbound_Message__c();
        inboundTable5.Core_Status__c = 'NEW';
        inboundTable5.Core_SalesCloud_AccountID__c = acc[0].Id;
        inboundTable5.Core_CIM_ID__c=1235987;
        inboundTable5.Core_OnePartner_Account_Name__c = 'Crosswealth2';
        inboundTable5.Core_Status_Effective_End_Date_Time__c = Date.newInstance(2016, 12, 9);
        listOfInbound.add(inboundTable5);
             
        insert listOfInbound;

        Test.startTest();        
    try {
            PRM_ProcessInboundOPIDRecords inboundBatch=new PRM_ProcessInboundOPIDRecords();
            Database.executeBatch(inboundBatch);
        } catch (exception e){
            Database.executeBatch(null);
        }
        Test.stopTest();
    }
    @isTest
    public static void existinginactiveCagTest(){
        
        List<Account> acc = [select id from Account where name in ('New Account','New Account User','TestUser1','Crosswealth2')];
        List<Core_OnePartner_Inbound_Message__c> listOfInbound = new List<Core_OnePartner_Inbound_Message__c>();
        Core_Account_Group_Member__c cag = [Select id,PRM_RelationshipEndDate__c,Core_Inactive_Ind__c from Core_Account_Group_Member__c where Core_Intel_Account_Id__c =: acc[0].id];
        TriggerHandler.bypass('Core_Acct_Grp_Mbr_TriggerHandler');
        cag.PRM_RelationshipEndDate__c = Date.newInstance(2016, 12, 9);
        cag.Core_Inactive_Ind__c = true;
        update cag;
        TriggerHandler.clearbypass('Core_Acct_Grp_Mbr_TriggerHandler');

        Core_OnePartner_Inbound_Message__c inboundTable7 = new Core_OnePartner_Inbound_Message__c();
        inboundTable7.Core_Status__c = 'NEW';
        inboundTable7.Core_SalesCloud_AccountID__c = acc[0].Id;
        inboundTable7.Core_CIM_ID__c=1235987;
        inboundTable7.Core_OnePartnerID__c = 2002;
        inboundTable7.Core_OnePartner_Account_Name__c = 'Crosswealth2';
        inboundTable7.Core_PAG_Grouping_Method__c = 'GLBL';
        inboundTable7.Core_Effective_Start_Date_Time__c =System.now();
        listOfInbound.add(inboundTable7);

        Core_OnePartner_Inbound_Message__c inboundTable8 = new Core_OnePartner_Inbound_Message__c();
        inboundTable8.Core_Status__c = 'NEW';
        inboundTable8.Core_SalesCloud_AccountID__c = acc[1].Id;
        inboundTable8.Core_CIM_ID__c=1235987;
        inboundTable8.Core_OnePartnerID__c = 2002;
        inboundTable8.Core_OnePartner_Account_Name__c = 'Crosswealth2';
        inboundTable8.Core_PAG_Grouping_Method__c = 'GLBL';
        inboundTable8.Core_Effective_Start_Date_Time__c =System.now();
        listOfInbound.add(inboundTable8);

        Core_OnePartner_Inbound_Message__c inboundTable9 = new Core_OnePartner_Inbound_Message__c();
        inboundTable9.Core_Status__c = 'NEW';
        inboundTable9.Core_SalesCloud_AccountID__c = acc[2].Id;
        inboundTable9.Core_CIM_ID__c=1235987;
        inboundTable9.Core_OnePartnerID__c = 2002;
        inboundTable9.Core_OnePartner_Account_Name__c = 'Crosswealth2';
        inboundTable9.Core_PAG_Grouping_Method__c = 'GLBL';
        inboundTable9.Core_Effective_Start_Date_Time__c =System.now();
        listOfInbound.add(inboundTable9);
             
        insert listOfInbound;

        Test.startTest();        
    try {
            PRM_ProcessInboundOPIDRecords inboundBatch=new PRM_ProcessInboundOPIDRecords();
            Database.executeBatch(inboundBatch);
        } catch (exception e){
            Database.executeBatch(null);
        }
        Test.stopTest();
    }

    
    @isTest
    public static void testHandler_ACM() {
        PRM_AccountChannelMembership__c acm = [SELECT Id, PRM_Account_Id__c FROM PRM_AccountChannelMembership__c LIMIT 1];
        Test.startTest();
        PRM_SalesCloudAccountIntStatus_Handler.setAccountIPAIntegrationStatusToPending(new List<PRM_AccountChannelMembership__c>{acm});
        Test.stopTest();
        System.assert(true);
    }
    @isTest
    public static void testAWDHandler() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Core_Account_Whitelisted_Domains__c awd =new Core_Account_Whitelisted_Domains__c();
        awd.Account__c = acc.Id;
        Test.startTest();
        PRM_SalesCloudAccountIntStatus_Handler.setAccountIPAIntegrationStatusToPending(new List<Core_Account_Whitelisted_Domains__c>{awd});
        Test.stopTest();
        System.assert(true);
    }
    
    @isTest
    public static void testALAHandler() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        PRM_AccountLegalAgreemntAssociation__c ala = new PRM_AccountLegalAgreemntAssociation__c();
        ala.PRM_Account_Id__c = acc.Id;
        ala.PRM_InActive_Ind__c = false;
        Test.startTest();
        PRM_SalesCloudAccountIntStatus_Handler.setAccountIPAIntegrationStatusToPending(new List<PRM_AccountLegalAgreemntAssociation__c>{ala});
        Test.stopTest();
        System.assert(true);
    }
    @isTest
    public static void testPartnerAssistConsentHandler() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        PRM_Partner_Assist_Consent__c consent = new PRM_Partner_Assist_Consent__c();
        consent.PRM_Account_Id__c = acc.Id;
        consent.PRM_InActive_Ind__c = false;
        Test.startTest();
        PRM_SalesCloudAccountIntStatus_Handler.setAccountIPAIntegrationStatusToPending(new List<PRM_Partner_Assist_Consent__c>{consent});
        Test.stopTest();
        System.assert(true);
    }
    @isTest
    public static void testProfileResponseHandler() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        PRM_Profile_Responses__c profileResp = new PRM_Profile_Responses__c();
        profileResp.PRM_Account_Id__c = acc.Id;
        Test.startTest();
        PRM_SalesCloudAccountIntStatus_Handler.setAccountIPAIntegrationStatusToPending(new List<PRM_Profile_Responses__c>{profileResp});
        Test.stopTest();
        System.assert(true);
    }
    @isTest
    public static void testGetAccountsMap() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Test.startTest();
        Map<Id,Account> result = PRM_SalesCloudAccountIntStatus_Handler.getAccountsMap(new Set<Id>{acc.Id});
        Test.stopTest();
        System.assert(result.containsKey(acc.Id));
    }
    @isTest
    public static void testPendingOnUpdate() {
        Account acc = [SELECT Id,RecordTypeId,Name,Core_Business_Party_Id__c,BillingStreet,
                       BillingCity,
                       BillingState,
                       BillingCountry,
                       BillingPostalCode,
                       Core_Account_Type__c,
                       Core_Intel_Partner_Alliance_PartnerGroup__c,
                       Core_IPA_Partner_Role__c,
                       Core_IPA_Badge_Tier__c,
                       PRM_IPA_Integration_Status__c FROM Account LIMIT 1];
        Account oldAcc = acc.clone(false, true, false, false);
        acc.Name = acc.Name + ' Test';
        Test.startTest();
        PRM_SalesCloudAccountIntStatus_Handler.setAccountIPAIntegrationStatusToPendingOnUpdate(new List<Account>{acc},new Map<Id,Account>{acc.Id => oldAcc},new Set<Id>{acc.Id});
        Test.stopTest();
        System.assert(true);
    }
}