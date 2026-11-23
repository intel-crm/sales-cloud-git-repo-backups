@isTest
public class PRM_CreateFileAndAttachToRecordTest {
    static List<Account> lstAct = new List<Account>();
    static List<Contact> lstContact = new List<Contact>();
    static Profile p;
    static List<User> uList = new List<User>();
    public static List<k_v_f_detail_value_exchange_sfdcs__x> sales = new List<k_v_f_detail_value_exchange_sfdcs__x>();
    public static List<k_v_f_training_detail_sfdcs__x> training = new List<k_v_f_training_detail_sfdcs__x>();
	@isTest static void executeTest(){
        
        SchedulableContext sc = null;
        Test.startTest();
        Account opidAct = new Account();
        opidAct.name = 'OPIDTestAct1';
        opidAct.AccountNumber = '00023456780';
        opidAct.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
        insert opidAct;
        
        Account act1 = new Account();
        act1.name = 'TestAct1';
        act1.AccountNumber = '23456780';
        act1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        act1.Core_IPA_One_Partner_Id__c = opidAct.Id;
        act1.Core_Account_Type__c = 'Distributor';
        act1.Industry = 'Manufacturing';
        act1.Core_Sub_Industry__c = 'Appliance and Electrical Equipment';
        act1.BillingCity='City';
        act1.BillingStreet='Street';
        act1.BillingCountry='India';
        act1.BillingPostalCode='Postal code';
        
        Account act2 = new Account();
        act2.name = 'TestAct2';
        act2.AccountNumber = '23457080';
        act2.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        act2.Core_IPA_One_Partner_Id__c = opidAct.Id;
        act2.Core_Account_Type__c = 'Distributor';
        act2.Industry = 'Manufacturing';
        act2.Core_Sub_Industry__c = 'Appliance and Electrical Equipment';
        act2.BillingCity='City';
        act2.BillingStreet='Street';
        act2.BillingCountry='India';
        act2.BillingPostalCode='Postal code';
        lstAct.add(act2);
        lstAct.add(act1);
        insert lstAct;

        Contact c1 = new Contact();
        c1.FirstName ='Test1';
        c1.LastName = 'COntact';
        c1.AccountId = opidAct.Id;
        c1.email='Test1.COntact@intel.com';
        c1.Core_Job_Function__c='External Partner Admin';
        c1.Core_eRPM_Language_Code__c='Eng';
        c1.Core_IPA_PartnerRole__c = 'Service Provider';
        c1.Core_Login_Id__c = 'Test1';
        insert c1;
        lstContact.add(c1);
    
        Contact c2 = new Contact();
        c2.FirstName ='Test2';
        c2.LastName = 'COntact';
        c2.AccountId = act1.Id;
        c2.email='Test2.COntact@intel.com';
        c2.Core_Job_Function__c='External Partner Admin';
        c2.Core_eRPM_Language_Code__c='Eng';
        c2.Core_IPA_PartnerRole__c = 'Service Provider';
        c2.Core_Login_Id__c = 'Test2';
        lstContact.add(c2);
        insert c2;
        
        PRM_Sales_Calculation_Group__c scg = new PRM_Sales_Calculation_Group__c();
        scg.PRM_Revenue_Source_Nm__c = 'ODM Purchases';
        scg.PRM_Sales_Calculation_Group_Nm__c = 'ChAMP';
        insert scg;
        
        k_v_f_detail_value_exchange_sfdcs__x salesRec1 = new k_v_f_detail_value_exchange_sfdcs__x();
        salesRec1.business_organization_party_id__c = act1.Id;
        salesRec1.disti_nm__c ='TestActDistributor1';
        salesRec1.form_factor_txt__c = '';
        salesRec1.invoice_nbr__c = 'qwer1234';
        salesRec1.invoice_dt__c = '05-11-2020';
        salesRec1.sales_type_cd__c = 'Champ';
        salesRec1.value_exchange_period_txt__c=Label.PRM_Current_measurement_period;
        salesRec1.start_dt__c='2020-11-01';
        salesRec1.end_dt__c='2021-08-05';

    
        k_v_f_detail_value_exchange_sfdcs__x salesRec2 = new k_v_f_detail_value_exchange_sfdcs__x();
        salesRec2.business_organization_party_id__c = act1.Id;
        salesRec2.disti_nm__c ='TestActDistributor2';
        salesRec2.form_factor_txt__c = '';
        salesRec2.invoice_nbr__c = 'qwer12345';
        salesRec2.invoice_dt__c = '05-11-2020';
        salesRec2.sales_type_cd__c = 'Champ';
        salesRec2.value_exchange_period_txt__c=Label.PRM_Current_measurement_period;
        salesRec2.start_dt__c='2021-11-01';
        salesRec2.end_dt__c='2022-08-05';
        //salesRec2.start_dt__c=string.valueof(system.today().year()-2);
        //salesRec2.end_dt__c=string.valueof(system.today().year()-1);
       
        sales.add(salesRec1);
        sales.add(salesRec2);
        PRM_External_Objects_Data.salesMocked.addAll(sales);
        
        List<k_v_f_training_detail_sfdcs__x> training = new List<k_v_f_training_detail_sfdcs__x>();
        k_v_f_training_detail_sfdcs__x tr1 = new k_v_f_training_detail_sfdcs__x();
        tr1.business_person_id__c = c1.Id;
        tr1.business_organization_party_id__c = act1.Id;
        tr1.training_id__c ='qwer123';
        tr1.training_credit_qty__c =5;
        tr1.training_nm__c ='SFDC';
        tr1.training_complete_dt__c = '2020-11-05';
        tr1.value_exchange_period_txt__c=Label.PRM_Current_measurement_period;
        tr1.start_dt__c='2020-11-01';
        tr1.end_dt__c='2021-08-05';
        
        k_v_f_training_detail_sfdcs__x tr2 = new k_v_f_training_detail_sfdcs__x();
        tr2.business_person_id__c = c1.Id;
        tr2.business_organization_party_id__c = act1.Id;
        tr2.training_id__c ='qwer123';
        tr2.training_credit_qty__c =5;
        tr2.training_nm__c ='SFDC';
        tr2.training_complete_dt__c = '2020-11-05';
        tr2.value_exchange_period_txt__c=Label.PRM_Current_measurement_period;
        tr2.start_dt__c='2020-11-01';
        tr2.end_dt__c='2021-08-05';    
        
        k_v_f_training_detail_sfdcs__x tr3 = new k_v_f_training_detail_sfdcs__x();
        tr3.business_person_id__c = c1.Id;
        tr3.business_organization_party_id__c = act2.Id;
        tr3.training_id__c ='qwer123';
        tr3.training_credit_qty__c =5;
        tr3.training_nm__c ='SFDC';
        tr3.training_complete_dt__c = '2020-11-05';
        tr3.value_exchange_period_txt__c=Label.PRM_Current_measurement_period;
        tr3.start_dt__c='2020-11-01';
        tr3.end_dt__c='2021-08-05';
        
        k_v_f_training_detail_sfdcs__x tr4 = new k_v_f_training_detail_sfdcs__x();
        tr4.business_person_id__c = c1.Id;
        tr4.business_organization_party_id__c = act2.Id;
        tr4.training_id__c ='qwer123';
        tr4.training_credit_qty__c =5;
        tr4.training_nm__c ='SFDC';
        tr4.training_complete_dt__c = '2020-11-05';
        tr4.value_exchange_period_txt__c=Label.PRM_Current_measurement_period;
        tr4.start_dt__c='2021-11-01';
        tr4.end_dt__c='2022-08-05';
        
        training.add(tr1);
        training.add(tr2);
        training.add(tr3);
        training.add(tr4);
        
        PRM_External_Objects_Data.trainingMocked.addAll(training);
        system.debug('>>training data' + training);
        system.debug('>>training data' +  PRM_External_Objects_Data.trainingMocked);
    
        p = [select id from Profile where name='System Administrator'];
        User u1 = new User(alias = 'Test1', email='Test1.COntact@intel.com',
                           emailencodingkey='UTF-8', firstName='Test1', lastname='COntact', languagelocalekey='en_US',
                           localesidkey='en_US', profileid = p.id,
                           timezonesidkey='Europe/London', username='Test1.COntact@gmail.com');
        insert u1;
        User u2 = new User(alias = 'Test2', email='Test2.COntact@intel.com',
                           emailencodingkey='UTF-8', firstName='Test2', lastname='COntact', languagelocalekey='en_US',
                           localesidkey='en_US', profileid = p.id,
                           timezonesidkey='Europe/London', username='Test2.COntact@gmail.com');
        insert u2;        
        uList.add(u1);
        uList.add(u2);
        String userId = u1.id;
        
        List<String> columnNamesCSVList = new List<String>();
        columnNamesCSVList.add('report');
        
        List<PRM_External_Objects_Data.PRM_WrapperForSalesgDetails> wrapSalesList = new List<PRM_External_Objects_Data.PRM_WrapperForSalesgDetails>();

        PRM_External_Objects_Data.PRM_WrapperForSalesgDetails wrapSales = new PRM_External_Objects_Data.PRM_WrapperForSalesgDetails();
        wrapSales.invoice_number = '762398';
        wrapSalesList.add(wrapSales);
        
        List<PRM_External_Objects_Data.PRM_WrapperForTrainingDetails> wrapTrainingList = new List<PRM_External_Objects_Data.PRM_WrapperForTrainingDetails>();

        PRM_External_Objects_Data.PRM_WrapperForTrainingDetails wrapTrain = new PRM_External_Objects_Data.PRM_WrapperForTrainingDetails();
        wrapTrain.account_number = '7623958';
        wrapTrainingList.add(wrapTrain);

        
        Map<Integer, List<PRM_External_Objects_Data.PRM_WrapperForSalesgDetails>> mapSales = new Map<Integer, List<PRM_External_Objects_Data.PRM_WrapperForSalesgDetails>>();
        mapSales.put(0,wrapSalesList); 
        
        Map<Integer, List<PRM_External_Objects_Data.PRM_WrapperForTrainingDetails>> mapTrain = new Map<Integer, List<PRM_External_Objects_Data.PRM_WrapperForTrainingDetails>>();
        mapTrain.put(0,wrapTrainingList); 
        
        PRM_External_Objects_Data.getExtSalesDetails1('', salesRec1.invoice_nbr__c,'', '',200, '', '', true,false);// from inv
        CreateFileAndAttachToRecord salesContr = new CreateFileAndAttachToRecord(columnNamesCSVList,mapSales,'report',userId, 'salesData');
        CreateFileAndAttachToRecord trainingContr = new CreateFileAndAttachToRecord(columnNamesCSVList,mapTrain,'report',userId, 'trainingsData');
      	CreateFileAndAttachToRecord trainingContr1 = new CreateFileAndAttachToRecord(columnNamesCSVList,mapTrain,'report',userId, 'opidTrainingsData');
      	
        CreateFileAndAttachToRecord.createFile('tfhh','ghvh',userId);
        salesContr.createDataString(wrapSalesList,'ghvh');
        salesContr.createDataString(wrapSalesList,'');
        trainingContr.createDataString(wrapTrainingList, 'ghvh');
        trainingContr.createDataString(wrapTrainingList, '');
        trainingContr1.createDataString(wrapTrainingList, 'ghvh');
        
        //CreateFileAndAttachToRecord instancevar = new CreateFileAndAttachToRecord();
		ID batchprocessid = Database.executeBatch(salesContr);
        ID batchprocessid1 = Database.executeBatch(trainingContr);
        ID batchprocessid2 = Database.executeBatch(trainingContr1);
        
       	Test.stopTest();
        
    	}
        //CreateFileAndAttachToRecord.CreateFileAndAttachToRecord tsc = new CreateFileAndAttachToRecord.CreateFileAndAttachToRecord();
        //tsc.execute(sc);
         
    }