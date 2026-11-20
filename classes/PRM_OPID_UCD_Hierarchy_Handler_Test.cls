@isTest
public class PRM_OPID_UCD_Hierarchy_Handler_Test{
    @testSetup
    public static void setUpData(){
        Id accountRecordTypeIntel = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        Id accountRecordTypePAG = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Partner_Account_Group_Record_Type).getRecordTypeId();
        List<Account> accList = new List<Account>();
        List<Core_Account_Group_Member__c> cagList = new List<Core_Account_Group_Member__c>();
        
        Account acc1 = new Account();
        acc1.RecordTypeId=accountRecordTypeIntel;      
        acc1.Name = ' Parent Test End Customer';
        acc1.Core_Data_Simplified_Account_Nm__c = 'Parent Test End Customer';
        acc1.Industry = 'Banking';
        acc1.BillingCity = 'Pune';
        acc1.BillingCountry = 'USA';
        acc1.BillingStreet = 'G-210';
        acc1.Core_Customer_Aggregation_Type__c = 'UNFD_GLBL_CUST';
        acc1.BillingCountry = 'USA';
        acc1.BillingCountryCode = 'USA';
        acc1.ShippingCountryCode = 'USA';
        acc1.Core_Business_Party_Id__c = '1000678929';
        insert acc1;

        Account acc2 = new Account();
        acc2.RecordTypeId=accountRecordTypeIntel;      
        acc2.Name = 'Test End Customer';
        acc2.Core_Data_Simplified_Account_Nm__c = 'Test End Customer';
        acc2.Industry = 'Banking';
        acc2.BillingCity = 'Pune';
        acc2.BillingCountry = 'USA';
        acc2.BillingStreet = 'G-210';
        acc2.Core_Customer_Aggregation_Type__c = 'UNFD_CTRY_CUST';
        acc2.BillingCountry = 'USA';
        acc2.BillingCountryCode = 'USA';
        acc2.ShippingCountryCode = 'USA';
        acc2.ParentId = acc1.Id;
        acc2.Core_Business_Party_Id__c = '1000678930';
        acc2.Core_Parent_Business_Party_Id__c = '1000678929';
        acc2.Core_Unified_Global_Customer_BP_Id__c = '1000678929';
        acc2.Core_Unified_Global_Customer_Name__c = 'Parent Test End Customer';
        acc2.Core_Parent_Data_Simplified_Account_Nm__c = 'Parent Test End Customer';
        accList.add(acc2);
        
        Account acc3 = new Account();
        acc3.RecordTypeId=accountRecordTypeIntel;      
        acc3.Name = 'Parent Test End Customer 1';
        acc3.Core_Data_Simplified_Account_Nm__c = 'Parent Test End Customer 1';
        acc3.Industry = 'Banking';
        acc3.BillingCity = 'Pune';
        acc3.BillingCountry = 'GBR';
        acc3.BillingStreet = 'G-210';
        acc3.Core_Customer_Aggregation_Type__c = 'UNFD_GLBL_CUST';
        acc3.BillingCountry = 'GBR';
        acc3.BillingCountryCode = 'GBR';
        acc3.ShippingCountryCode = 'GBR';
        acc3.Core_Business_Party_Id__c = '1000678931';
        insert acc3;

        Account acc4 = new Account();
        acc4.RecordTypeId=accountRecordTypeIntel;      
        acc4.Name = 'Test End Customer 1';
        acc4.Core_Data_Simplified_Account_Nm__c = 'Test End Customer 1';
        acc4.Industry = 'Banking';
        acc4.BillingCity = 'Pune';
        acc4.BillingCountry = 'GBR';
        acc4.BillingStreet = 'G-210';
        acc4.Core_Customer_Aggregation_Type__c = 'UNFD_INTRMD_CUST';
        acc4.BillingCountry = 'GBR';
        acc4.BillingCountryCode = 'GBR';
        acc4.ShippingCountryCode = 'GBR';
        acc4.ParentId = acc3.Id;
        acc4.Core_Business_Party_Id__c = '1000678932';
        acc4.Core_Parent_Business_Party_Id__c = '1000678931';
        acc4.Core_Unified_Global_Customer_BP_Id__c = '1000678931';
        acc4.Core_Unified_Global_Customer_Name__c = 'Parent Test End Customer 1';
        acc4.Core_Parent_Data_Simplified_Account_Nm__c = 'Parent Test End Customer 1';
        accList.add(acc4);
        
        Account acc5 = new Account();
        acc5.RecordTypeId=accountRecordTypeIntel;      
        acc5.Name = 'Gloabl Customer';
        acc5.Core_Data_Simplified_Account_Nm__c = 'Gloabl Customer';
        acc5.Industry = 'Banking';
        acc5.BillingCity = 'Chennai';
        acc5.BillingCountry = 'GBR';
        acc5.BillingStreet = 'G-210';
        acc5.Core_Customer_Aggregation_Type__c = 'UNFD_GLBL_CUST';
        acc5.BillingCountry = 'GBR';
        acc5.BillingCountryCode = 'GBR';
        acc5.ShippingCountryCode = 'GBR';
        acc5.Core_Business_Party_Id__c = '1000678933';
        accList.add(acc5);

        Account acc6 = new Account();
        acc6.RecordTypeId=accountRecordTypeIntel;      
        acc6.Name = 'Gloabl Customer 12';
        acc6.Core_Data_Simplified_Account_Nm__c = 'Gloabl Customer 12';
        acc6.Industry = 'Banking';
        acc6.BillingCity = 'Madras';
        acc6.BillingCountry = 'GBR';
        acc6.BillingStreet = 'G-210';
        acc6.Core_Customer_Aggregation_Type__c = 'UNFD_GLBL_CUST';
        acc6.BillingCountry = 'GBR';
        acc6.BillingCountryCode = 'GBR';
        acc6.ShippingCountryCode = 'GBR';
        acc6.Core_Business_Party_Id__c = '1000678934';
        accList.add(acc6);

        Account acc7 = new Account();
        acc7.RecordTypeId=accountRecordTypeIntel;      
        acc7.Name = 'Intrmd Customer 22';
        acc7.Core_Data_Simplified_Account_Nm__c = 'Intrmd Customer 22';
        acc7.Industry = 'Banking';
        acc7.BillingCity = 'Madre';
        acc7.BillingCountry = 'GBR';
        acc7.BillingStreet = 'G-210';
        acc7.Core_Customer_Aggregation_Type__c = 'UNFD_INTRMD_CUST';
        acc7.BillingCountry = 'GBR';
        acc7.BillingCountryCode = 'GBR';
        acc7.ShippingCountryCode = 'GBR';
        acc7.Core_Business_Party_Id__c = '1000678935';
        accList.add(acc7);

        Account acc8 = new Account();
        acc8.RecordTypeId=accountRecordTypeIntel;      
        acc8.Name = 'Cntry Customer 22';
        acc8.Core_Data_Simplified_Account_Nm__c = 'Cntry Customer 22';
        acc8.Industry = 'Banking';
        acc8.BillingCity = 'Madre';
        acc8.BillingCountry = 'GBR';
        acc8.BillingStreet = 'G-210';
        acc8.Core_Customer_Aggregation_Type__c = 'UNFD_CTRY_CUST';
        acc8.BillingCountry = 'GBR';
        acc8.BillingCountryCode = 'GBR';
        acc8.ShippingCountryCode = 'GBR';
        acc8.Core_Business_Party_Id__c = '1000678936';
        accList.add(acc8);

        Account acc9 = new Account();
        acc9.RecordTypeId=accountRecordTypeIntel;      
        acc9.Name = 'Loc Customer 22';
        acc9.Core_Data_Simplified_Account_Nm__c = 'Loc Customer 22';
        acc9.Industry = 'Banking';
        acc9.BillingCity = 'Madre';
        acc9.BillingCountry = 'GBR';
        acc9.BillingStreet = 'G-210';
        acc9.Core_Customer_Aggregation_Type__c = 'UNFD_LOC_CUST';
        acc9.BillingCountry = 'GBR';
        acc9.BillingCountryCode = 'GBR';
        acc9.ShippingCountryCode = 'GBR';
        acc9.Core_Business_Party_Id__c = '1000678937';
        accList.add(acc9);

        Account opidAcc1 = new Account();
        opidAcc1.RecordTypeId= accountRecordTypePAG;
        opidAcc1.Name = 'Test OPID';
        opidAcc1.Core_OnePartnerID__c = '2001';
        accList.add(opidAcc1);

        Account opidAcc2 = new Account();
        opidAcc2.RecordTypeId= accountRecordTypePAG;
        opidAcc2.Name = 'Test OPID1';
        opidAcc2.Core_OnePartnerID__c = '2002';
        accList.add(opidAcc2);
        
        Account opidAcc3 = new Account();
        opidAcc3.RecordTypeId= accountRecordTypePAG;
        opidAcc3.Name = 'Test OPID2';
        opidAcc3.Core_OnePartnerID__c = '2003';
        accList.add(opidAcc3);
        
        Account opidAcc4 = new Account();
        opidAcc4.RecordTypeId= accountRecordTypePAG;
        opidAcc4.Name = 'Test OPID3';
        opidAcc4.Core_OnePartnerID__c = '2004';
        accList.add(opidAcc4);

        Account opidAcc5 = new Account();
        opidAcc5.RecordTypeId= accountRecordTypePAG;
        opidAcc5.Name = 'Test OPID4';
        opidAcc5.Core_OnePartnerID__c = '2005';
        opidAcc5.Core_PAG_Grouping_Method__c='LINEOFBUSNS';
        accList.add(opidAcc5);

        Account opidAcc6 = new Account();
        opidAcc6.RecordTypeId= accountRecordTypePAG;
        opidAcc6.Name = 'Test OPID5';
        opidAcc6.Core_OnePartnerID__c = '2006';
        opidAcc6.Core_PAG_Grouping_Method__c='GLBL';
        accList.add(opidAcc6);

        Account opidAcc7 = new Account();
        opidAcc7.RecordTypeId= accountRecordTypePAG;
        opidAcc7.Name = 'Test OPID6';
        opidAcc7.Core_OnePartnerID__c = '2007';
        opidAcc7.Core_PAG_Grouping_Method__c='GLBL';
        accList.add(opidAcc7);

        insert accList;

        Core_Account_Group_Member__c cag1 = new Core_Account_Group_Member__c();
        cag1.Core_Intel_Account_Id__c = acc1.Id;    
        cag1.Core_Partner_Account_Id__c = opidAcc1.id;
        cagList.add(cag1);

        Core_Account_Group_Member__c cag2 = new Core_Account_Group_Member__c();
        cag2.Core_Intel_Account_Id__c = acc2.Id;    
        cag2.Core_Partner_Account_Id__c = opidAcc2.id;
        cagList.add(cag2);
        
        Core_Account_Group_Member__c cag3 = new Core_Account_Group_Member__c();
        cag3.Core_Intel_Account_Id__c = acc3.Id;    
        cag3.Core_Partner_Account_Id__c = opidAcc3.id;
        cagList.add(cag3);
        Core_Account_Group_Member__c cag4 = new Core_Account_Group_Member__c();
        cag4.Core_Intel_Account_Id__c = acc4.Id;    
        cag4.Core_Partner_Account_Id__c = opidAcc3.id;
        cagList.add(cag4);
        
        Core_Account_Group_Member__c cag5 = new Core_Account_Group_Member__c();
        cag5.Core_Intel_Account_Id__c = acc5.Id;    
        cag5.Core_Partner_Account_Id__c = opidAcc4.id;
        cagList.add(cag5);

        Core_Account_Group_Member__c cag6 = new Core_Account_Group_Member__c();
        cag6.Core_Intel_Account_Id__c = acc6.Id;    
        cag6.Core_Partner_Account_Id__c = opidAcc5.id;
        cag6.Primary_Account__c=true;
        cagList.add(cag6);

        Core_Account_Group_Member__c cag7 = new Core_Account_Group_Member__c();
        cag7.Core_Intel_Account_Id__c = acc7.Id;    
        cag7.Core_Partner_Account_Id__c = opidAcc6.id;
        cag7.Primary_Account__c=true;
        cagList.add(cag7);

        Core_Account_Group_Member__c cag8 = new Core_Account_Group_Member__c();
        cag8.Core_Intel_Account_Id__c = acc8.Id;    
        cag8.Core_Partner_Account_Id__c = opidAcc7.id;
        cag8.Primary_Account__c=true;
        cagList.add(cag8);

        Core_Account_Group_Member__c cag9 = new Core_Account_Group_Member__c();
        cag9.Core_Intel_Account_Id__c = acc9.Id;    
        cag9.Core_Partner_Account_Id__c = opidAcc7.id;
        cagList.add(cag9);
        
        TriggerHandler.bypass('Core_Acct_Grp_Mbr_TriggerHandler');
        insert cagList;
        TriggerHandler.clearBypass('Core_Acct_Grp_Mbr_TriggerHandler');
        
        Core_OnePartner_Inbound_Message__c  inboundOnePartner = new Core_OnePartner_Inbound_Message__c  () ;
        inboundOnePartner.Core_OnePartnerID__c  = 2003;
        inboundOnePartner.Core_OnePartner_Account_Name__c = 'Test OPID2';
        inboundOnePartner.Core_SalesCloud_AccountID__c = acc3.id ;
        inboundOnePartner.Core_Status__c = 'NEW';  
        inboundOnePartner.Core_PAG_Grouping_Method__c = 'GLBL' ; 
        inboundOnePartner.Core_CIM_ID__c  = 1000678931; 
        inboundOnePartner.Core_Effective_End_Date_Time__c = System.now();
        inboundOnePartner.Comments__c='Delinking since UCD Hierarchy changed.';
        insert inboundOnePartner;

        List<ACM_Integration_Message_Queue__c> integMessQueue = new List<ACM_Integration_Message_Queue__c>();
        List<ACM_Integration_Message_Queue__c> imsList = new List<ACM_Integration_Message_Queue__c>();
        List<Account_Create_Request__c> aqrList = new List<Account_Create_Request__c>();

        ACM_Integration_Message_Queue__c integrationMessage = new ACM_Integration_Message_Queue__c();
        integrationMessage.Message_Status__c = 'New';
        integrationMessage.Content_Type__c = 'AccountId';
        integrationMessage.Content__c = acc2.Id;
        integrationMessage.Custom_Filter__c = acc2.Id;
        integrationMessage.Module_Name__c = 'ACM';
        integrationMessage.Queue_Type__c = 'Outbound';
        integrationMessage.Retry_Count__c = 0;
        integrationMessage.Source_System__c = 'Reltio';        
        integMessQueue.add(integrationMessage) ;
        
        ACM_Integration_Message_Queue__c integrationMessage2 = new ACM_Integration_Message_Queue__c();
        integrationMessage2.Message_Status__c = 'New';
        integrationMessage2.Content_Type__c = 'AccountId';
        integrationMessage2.Content__c = acc4.Id;
        integrationMessage2.Custom_Filter__c = acc4.Id;
        integrationMessage2.Module_Name__c = 'ACM';
        integrationMessage2.Queue_Type__c = 'Outbound';
        integrationMessage2.Retry_Count__c = 0;
        integrationMessage2.Source_System__c = 'Reltio';        
        integMessQueue.add(integrationMessage2);
        
        ACM_Integration_Message_Queue__c integrationMessage3 = new ACM_Integration_Message_Queue__c();
        integrationMessage3.Message_Status__c = 'New';
        integrationMessage3.Content_Type__c = 'AccountId';
        integrationMessage3.Content__c = acc5.Id;
        integrationMessage3.Custom_Filter__c = acc5.Id;
        integrationMessage3.Module_Name__c = 'ACM';
        integrationMessage3.Queue_Type__c = 'Outbound';
        integrationMessage3.Retry_Count__c = 0;
        integrationMessage3.Source_System__c = 'Reltio';        
        integMessQueue.add(integrationMessage3);

        ACM_Integration_Message_Queue__c integrationMessage4 = new ACM_Integration_Message_Queue__c();
        integrationMessage4.Message_Status__c = 'New';
        integrationMessage4.Content_Type__c = 'AccountId';
        integrationMessage4.Content__c = acc6.Id;
        integrationMessage4.Custom_Filter__c = acc6.Id;
        integrationMessage4.Module_Name__c = 'ACM';
        integrationMessage4.Queue_Type__c = 'Outbound';
        integrationMessage4.Retry_Count__c = 0;
        integrationMessage4.Source_System__c = 'Reltio';        
        integMessQueue.add(integrationMessage4);

        ACM_Integration_Message_Queue__c integrationMessage5 = new ACM_Integration_Message_Queue__c();
        integrationMessage5.Message_Status__c = 'New';
        integrationMessage5.Content_Type__c = 'AccountId';
        integrationMessage5.Content__c = acc7.Id;
        integrationMessage5.Custom_Filter__c = acc7.Id;
        integrationMessage5.Module_Name__c = 'ACM';
        integrationMessage5.Queue_Type__c = 'Outbound';
        integrationMessage5.Retry_Count__c = 0;
        integrationMessage5.Source_System__c = 'Reltio';        
        integMessQueue.add(integrationMessage5);
        
        ACM_Integration_Message_Queue__c integrationMessage6 = new ACM_Integration_Message_Queue__c();
        integrationMessage6.Message_Status__c = 'New';
        integrationMessage6.Content_Type__c = 'AccountId';
        integrationMessage6.Content__c = acc8.Id;
        integrationMessage6.Custom_Filter__c = acc8.Id;
        integrationMessage6.Module_Name__c = 'ACM';
        integrationMessage6.Queue_Type__c = 'Outbound';
        integrationMessage6.Retry_Count__c = 0;
        integrationMessage6.Source_System__c = 'Reltio';        
        integMessQueue.add(integrationMessage6);

        ACM_Integration_Message_Queue__c integrationMessage7 = new ACM_Integration_Message_Queue__c();
        integrationMessage7.Message_Status__c = 'New';
        integrationMessage7.Content_Type__c = 'AccountId';
        integrationMessage7.Content__c = acc9.Id;
        integrationMessage7.Custom_Filter__c = acc9.Id;
        integrationMessage7.Module_Name__c = 'ACM';
        integrationMessage7.Queue_Type__c = 'Outbound';
        integrationMessage7.Retry_Count__c = 0;
        integrationMessage7.Source_System__c = 'Reltio';        
        integMessQueue.add(integrationMessage7);

        insert integMessQueue;

        Account_Create_Request__c req = new Account_Create_Request__c();
        req.Account_Name__c = 'Test End Customer';
        req.Process_Type__c = 'Partner';
        req.Requestor_Name__c = UserInfo.getName();
        req.Requestor_Email__c = UserInfo.getUserEmail()+'.invalid';
        req.Status__c = 'Pending Approval';
        req.Core_Account_Reference_Source_Name__c = 'Partner'; 
        req.Address__City__s = 'Test';
        req.Address__CountryCode__s = 'IND';
        req.Address__Street__s = 'Test';
        aqrList.add(req);   
		
        Account_Create_Request__c req2 = new Account_Create_Request__c();
        req2.Account_Name__c = 'Test End Customer 1';
        req2.Process_Type__c = 'Partner';
        req2.Requestor_Name__c = UserInfo.getName();
        req2.Requestor_Email__c = UserInfo.getUserEmail()+'.invalid';
        req2.Status__c = 'Pending Approval';
        req2.Core_Account_Reference_Source_Name__c = 'Partner'; 
        req2.Address__City__s = 'Test';
        req2.Address__CountryCode__s = 'IND';
        req2.Address__Street__s = 'Test';
        aqrList.add(req2);
        
        Account_Create_Request__c req3 = new Account_Create_Request__c();
        req3.Account_Name__c = 'Gloabl Customer';
        req3.Process_Type__c = 'Partner';
        req3.Requestor_Name__c = UserInfo.getName();
        req3.Requestor_Email__c = UserInfo.getUserEmail()+'.invalid';
        req3.Status__c = 'Pending Approval';
        req3.Core_Account_Reference_Source_Name__c = 'Partner'; 
        req3.Address__City__s = 'Test';
        req3.Address__CountryCode__s = 'IND';
        req3.Address__Street__s = 'Test';
        aqrList.add(req3);

        Account_Create_Request__c req4 = new Account_Create_Request__c();
        req4.Account_Name__c = 'Gloabl Customer 12';
        req4.Process_Type__c = 'Partner';
        req4.Requestor_Name__c = UserInfo.getName();
        req4.Requestor_Email__c = UserInfo.getUserEmail()+'.invalid';
        req4.Status__c = 'Pending Approval';
        req4.Core_Account_Reference_Source_Name__c = 'Partner'; 
        req4.Address__City__s = 'Test';
        req4.Address__CountryCode__s = 'IND';
        req4.Address__Street__s = 'Test';
        aqrList.add(req4);

        Account_Create_Request__c req5 = new Account_Create_Request__c();
        req5.Account_Name__c = 'Intrmd Customer 22';
        req5.Process_Type__c = 'Partner';
        req5.Requestor_Name__c = UserInfo.getName();
        req5.Requestor_Email__c = UserInfo.getUserEmail()+'.invalid';
        req5.Status__c = 'Pending Approval';
        req5.Core_Account_Reference_Source_Name__c = 'Partner'; 
        req5.Address__City__s = 'Test';
        req5.Address__CountryCode__s = 'IND';
        req5.Address__Street__s = 'Test';
        aqrList.add(req5);

        Account_Create_Request__c req6 = new Account_Create_Request__c();
        req6.Account_Name__c = 'Cntry Customer 22';
        req6.Process_Type__c = 'Partner';
        req6.Requestor_Name__c = UserInfo.getName();
        req6.Requestor_Email__c = UserInfo.getUserEmail()+'.invalid';
        req6.Status__c = 'Pending Approval';
        req6.Core_Account_Reference_Source_Name__c = 'Partner'; 
        req6.Address__City__s = 'Test';
        req6.Address__CountryCode__s = 'IND';
        req6.Address__Street__s = 'Test';
        aqrList.add(req6);

        Account_Create_Request__c req7 = new Account_Create_Request__c();
        req7.Account_Name__c = 'Loc Customer 22';
        req7.Process_Type__c = 'Partner';
        req7.Requestor_Name__c = UserInfo.getName();
        req7.Requestor_Email__c = UserInfo.getUserEmail()+'.invalid';
        req7.Status__c = 'Pending Approval';
        req7.Core_Account_Reference_Source_Name__c = 'Partner'; 
        req7.Address__City__s = 'Test';
        req7.Address__CountryCode__s = 'IND';
        req7.Address__Street__s = 'Test';
        aqrList.add(req7);

        insert aqrList;
        
        ACM_Integration_Message_Queue__c im = new ACM_Integration_Message_Queue__c();
        im.Custom_Filter__c = String.valueOf(req.Id);
        im.Content__c = String.valueOf(req.Id);
        im.Content_Type__c = 'ARQId';
        im.Module_Name__c = 'SBR';
        im.Source_System__c = 'SBR';
        im.Queue_Type__c = 'Outbound';
        im.Retry_Count__c = 0;
        im.Message_Status__c = 'New';
        imsList.add(im);     

        ACM_Integration_Message_Queue__c im2 = new ACM_Integration_Message_Queue__c();
        im2.Custom_Filter__c = String.valueOf(req2.Id);
        im2.Content__c = String.valueOf(req2.Id);
        im2.Content_Type__c = 'ARQId';
        im2.Module_Name__c = 'SBR';
        im2.Source_System__c = 'SBR';
        im2.Queue_Type__c = 'Outbound';
        im2.Retry_Count__c = 0;
        im2.Message_Status__c = 'New';
        imsList.add(im2);   
        
        ACM_Integration_Message_Queue__c im3 = new ACM_Integration_Message_Queue__c();
        im3.Custom_Filter__c = String.valueOf(req3.Id);
        im3.Content__c = String.valueOf(req3.Id);
        im3.Content_Type__c = 'ARQId';
        im3.Module_Name__c = 'SBR';
        im3.Source_System__c = 'SBR';
        im3.Queue_Type__c = 'Outbound';
        im3.Retry_Count__c = 0;
        im3.Message_Status__c = 'New';
        imsList.add(im3);

        ACM_Integration_Message_Queue__c im4 = new ACM_Integration_Message_Queue__c();
        im4.Custom_Filter__c = String.valueOf(req4.Id);
        im4.Content__c = String.valueOf(req4.Id);
        im4.Content_Type__c = 'ARQId';
        im4.Module_Name__c = 'SBR';
        im4.Source_System__c = 'SBR';
        im4.Queue_Type__c = 'Outbound';
        im4.Retry_Count__c = 0;
        im4.Message_Status__c = 'New';
        imsList.add(im4);

        ACM_Integration_Message_Queue__c im5 = new ACM_Integration_Message_Queue__c();
        im5.Custom_Filter__c = String.valueOf(req5.Id);
        im5.Content__c = String.valueOf(req5.Id);
        im5.Content_Type__c = 'ARQId';
        im5.Module_Name__c = 'SBR';
        im5.Source_System__c = 'SBR';
        im5.Queue_Type__c = 'Outbound';
        im5.Retry_Count__c = 0;
        im5.Message_Status__c = 'New';
        imsList.add(im5);

        ACM_Integration_Message_Queue__c im6 = new ACM_Integration_Message_Queue__c();
        im6.Custom_Filter__c = String.valueOf(req6.Id);
        im6.Content__c = String.valueOf(req6.Id);
        im6.Content_Type__c = 'ARQId';
        im6.Module_Name__c = 'SBR';
        im6.Source_System__c = 'SBR';
        im6.Queue_Type__c = 'Outbound';
        im6.Retry_Count__c = 0;
        im6.Message_Status__c = 'New';
        imsList.add(im6);

        ACM_Integration_Message_Queue__c im7 = new ACM_Integration_Message_Queue__c();
        im7.Custom_Filter__c = String.valueOf(req7.Id);
        im7.Content__c = String.valueOf(req7.Id);
        im7.Content_Type__c = 'ARQId';
        im7.Module_Name__c = 'SBR';
        im7.Source_System__c = 'SBR';
        im7.Queue_Type__c = 'Outbound';
        im7.Retry_Count__c = 0;
        im7.Message_Status__c = 'New';
        imsList.add(im7);
        
        insert imsList;

    }
    public static testMethod void testHierarchyChange(){
        List<Account> accRecordList = [select Id from Account where name ='Test End Customer'];
        Test.startTest();
        UCD_ACM_AccountPlatformEvent_Batch batchRec = new UCD_ACM_AccountPlatformEvent_Batch();
        DataBase.executeBatch(batchRec);
        PRM_AccChange_ResponseParser eventParse = new PRM_AccChange_ResponseParser();

        Test.stopTest();

    }


}