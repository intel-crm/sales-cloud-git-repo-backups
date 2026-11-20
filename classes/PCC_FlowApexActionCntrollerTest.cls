@isTest
public with sharing class PCC_FlowApexActionCntrollerTest {
    
    @isTest
    public static void approvedDDR1(){
        Test.startTest();
        
        List<account> LstAcc = Core_Test_Utility.createAccount(1);
        LstAcc[0].Core_Sales_Groups__c = 'Americas Brazil Sales Group';
        
        Id accountRecordTypeIntel = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId(); 
        Assert.isNotNull(accountRecordTypeIntel);
        LstAcc[0].OwnerId=UserInfo.getUserId();
        LstAcc[0].recordtypeID = accountRecordTypeIntel;
        insert LstAcc;
        
        List<Product2> ProdLst = Core_DDR_Utility.CreateProduct(1);
        
        ProdLst[0].name = 'Intel® Server System S7000FC4UR';
        ProdLst[0].Core_Design_Registration_Eligible_Ind__c  = true;
        ProdLst[0].Core_Sales_Visible_Flag__c = true;
        ProdLst[0].isActive = false;
        ProdLst[0].Core_Partner_Visible_Ind__c = true;
        ProdLst[0].Core_Avail_for_New_Designs__c = true;
        ProdLst[0].Core_Product_Org__c = 'sales';
        ProdLst[0].Core_Sales_Visible_Flag__c = true;
        ProdLst[0].IsActive = true;
        ProdLst[0].Core_Hierarchy_ID__c = '43';
        insert ProdLst;
        
        
        
        List<PriceBook2> PriceBookLst = Core_DDR_Utility.CreatePriceBook2();
        insert PriceBookLst;
        System.debug('PriceBookLst -->'+JSON.serialize(PriceBookLst));
        
        // List<PriceBook2> standardPB = new List<PriceBook2>{new PriceBook2(name = 'Standard Price Book', IsActive = true)};
        
        List<PriceBookEntry> PBELst = Core_DDR_Utility.CreatePriceBookEntry(1, ProdLst, PriceBookLst);
        System.debug('PBELst -->'+JSON.serialize(PBELst));
        // List<PriceBookEntry> PBELst1 = Core_DDR_Utility.CreatePriceBookEntry(1, ProdLst, standardPB);
        Assert.isNotNull(PBELst);
        List<Core_Design_Registration__c> oldList = new  List<Core_Design_Registration__c>();
        List<Core_Design_Registration__c> newList=new List<Core_Design_Registration__c>();
        Map<Id,Core_Design_Registration__c> oldMap=new Map<Id,Core_Design_Registration__c>();
        Map<Id,Core_Design_Registration__c> newMap= new Map<Id,Core_Design_Registration__c>();
        
        List<Id> listDDRId = new List<Id>();
        String dealRecordTypeId = Schema.sObjectType.Core_Design_Registration__c.getRecordTypeInfosByDeveloperName().get('PCC_Deal_Registration_Partner').getRecordTypeId(); 
        Core_Design_Registration__c DDRLst = new Core_Design_Registration__c( Core_Product_Group_Nm__c = 'FPGA/Power', Core_Design_Registration_Nm__c = 'DDR Test',
                                                                             Core_Design_Registration_Dsc__c = 'ABC', Core_Opportunity_Volume_Cnt__c = 5, Core_Partner_FAE_Nm__c = '6', Core_End_Customer_Nm__c = 'DDR Test', Core_End_Customer_Street_Addr_Line1_Txt__c = 'ABC', 
                                                                             Core_End_Customer_Street_Addr_Line2_Txt__c = 'Abc', Core_End_Customer_City_Nm__c = 'BAN', Core_End_Customer_Country_Subdivision_Nm__c = 'KA', PCC_End_Customer_Country__c = 'United States', Core_End_Customer_Postal_Cd__c = '560037',
                                                                             Core_Military_Aerospace_Gvrnmt_Use_Ind__c = 'Yes', Core_Opportunity_Decision_Dt__c = system.today()+45, Core_First_Customer_Ship_Dt__c = system.today()+46, Core_Production_End_Dt__c = system.today()+47, Core_Vertical_Market_Nm__c = 'Education', 
                                                                             Core_Intel_Platform_Nm__c = 'Board', Core_Product_Application_Nm__c = 'Business Desktop', Core_Product_Segment_Nm__c = 'Client Computing', Core_Manufacturing_Region_Cd__c = 'APJ', Core_Design_Registration_Status_Nm__c = 'Approved', Core_Partner_Account_Id__c= LstAcc[0].id, 
                                                                             PCC_Consumption_Countries__c='INDIA, UK, US',PCC_Current_EndCustomer_Product_Provider__c='56789sjdjsd');
        DDRLst.recordTypeId = dealRecordTypeId;
        Assert.isNotNull(DDRLst);
        insert DDRLst;
        
        
        // Core_Deal_Opportunity
        String dealOpptyRecordTypeId = Schema.sObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Core_Deal_Opportunity').getRecordTypeId(); 
        List<Id> oppLstId = new List<Id>();
        Opportunity opp = new Opportunity();
        opp.Core_Design_Registration_Id__c = DDRLst.id;
        opp.AccountId =  LstAcc[0].Id;
        opp.StageName = 'Qualify';
        opp.recordTypeId = dealOpptyRecordTypeId;
        opp.CloseDate = system.today()+10;
        opp.PriceBook2Id = PriceBookLst[0].Id;
        //opp.Core_Opportunity_Type__c = 'Deal: Sell-through';
        opp.name = 'Test Opty';
        insert opp;
        System.debug(' Insert OP : '+JSON.serialize(opp));
        oppLstId.add(opp.Id);
        
        DDRLst.Core_Design_Registration_Status_Nm__c = 'Approved';
        DDRLst.Core_End_Customer_Account_Id__c = LstAcc[0].id;
        DDRLst.Core_Partner_Account_Id__c = LstAcc[0].id;
        DDRLst.Core_Opportunity_Id__c = opp.Id;
        oldList.add(DDRLst);
        oldMap.put(DDRLst.Id, DDRLst);
        Assert.isNotNull(DDRLst);
        update DDRLst;
        
        //Update DDR as approved
        DDRLst.Core_Design_Registration_Status_Nm__c = 'Approved';
        DDRLst.Core_Opportunity_Id__c = NULL;
        newList.add( DDRLst);
        newMap.put( DDRLst.Id,  DDRLst);
        
        update DDRLst;
        List<Core_Design_Registration__c> DDRList = new List<Core_Design_Registration__c>();
        DDRList.add(DDRLst);
        listDDRId.add(DDRLst.Id);
        
        // create additional_attributes
        
        Id DealProductRecordTypeid = Schema.SObjectType.Core_Design_Registration_Product__c.getRecordTypeInfosByDeveloperName().get('PCC_Deal_Registration_Product_Partner').getRecordTypeId();
        Product_Additional_Attribute__c newProdAA = new Product_Additional_Attribute__c();
        newProdAA.Name = 'Intel® Server System S7000FC4UR';
        newProdAA.Programs_Eligible__c='PDI;';
        newProdAA.Product__c =ProdLst[0].id;
        newProdAA.Eligible_for_Deal_Reg__c = true;
        insert newProdAA;
        
        
        
        String dealdrpRecordTypeId = Schema.sObjectType.Core_Design_Registration_Product__c.getRecordTypeInfosByDeveloperName().get('PCC_Deal_Registration_Product_Locked').getRecordTypeId(); 
        List<Core_Design_Registration_Product__c> DRPLst = Core_DDR_Utility.CreateDRProduct(1, DDRList, ProdLst);
        DRPLst[0].Core_Design_Registration_Id__c = DDRLst.Id;
        DRPLst[0].Core_Design_Product_Status_Nm__c = 'Approved';
        DRPLst[0].recordTypeId = dealdrpRecordTypeId;
        DRPLst[0].Core_Product_Id__c = ProdLst[0].Id;
        DRPLst[0].Core_Full_Year_Qty__c = 10;
        DRPLst[0].Core_Target_Resale_Amt__c = 199;
        DRPLst[0].PCC_Product_Additional_Attribute__c = newProdAA.Id;
        DRPLst[0].Core_Locked_Ind__c = true;
        DRPLst[0].Core_Product_List_Price_Amt__c =456;
        DRPLst[0].PCC_Competitor_Name__c ='AMD';
        DRPLst[0].PCC_Competitor_OEM_Name__c='Apple';
        DRPLst[0].PCC_Competitor_System_Model__c='PROC';
        DRPLst[0].PCC_Form_Factor__c='Desktop Workstation';
        DRPLst[0].PCC_OEM_Name__c='Apple';
        DRPLst[0].PCC_System_Model__c='Apple';
        DRPLst[0].PCC_Quote_Line_Pricing_End_Date__c=System.today()+10;
        DRPLst[0].PCC_Quote_Line_Pricing_Start_Date__c=System.today();
        
        insert DRPLst;
        
        PCC_FlowApexActionCntroller.processDealLines(new List<Core_Design_Registration__c>{DDRLst});
        Test.stopTest(); 
        System.assertNotEquals(null,listDDRId);
        
    }
}