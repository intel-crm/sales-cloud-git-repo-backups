public with sharing class Core_DDR_Utility {    
    
    //Products
    public static List<Product2> CreateProduct(Integer NoProducts) {
        List<Product2> NewProducts = new List<Product2>();
        for(Integer i = 0; i < NoProducts; i++) {
            Product2 prod = new Product2();
            
            prod.name = 'Intel Atom® CE4275 Media Processor'+i;
            prod.Core_Design_Registration_Eligible_Ind__c  = true;
            prod.Core_Sales_Visible_Flag__c = true;
            prod.isActive = true;
            prod.Core_Partner_Visible_Ind__c = true;
            prod.Core_Avail_for_New_Designs__c = true;
            NewProducts.add(prod);
        }
        return NewProducts;
    }
    
    /*PriceBook*/
    public static List<PriceBook2> CreatePriceBook2() {
        
        List<PriceBook2> PBCreate = new List<PriceBook2>{new PriceBook2(name = 'Partner Price Book', IsActive = true)};
        return PBCreate;
    }
    
    /*PriceBookEntry*/
    public static List<PriceBookEntry> CreatePriceBookEntry(Integer NoPriceBookEntry, List<Product2> LstPro, List<PriceBook2> LstPB2) {
        List<PriceBookEntry> NewPBE = new List<PriceBookEntry>();
        
        for(integer i = 0; i < NoPriceBookEntry; i++) {
            PriceBookEntry PBE = new PriceBookEntry();
            PBE.Product2ID = LstPro[i].id == null ? LstPro[0].id : LstPro[i].id;         
            PBE.PriceBook2ID = Test.getStandardPricebookId();
            PBE.isActive = true;
            PBE.UnitPrice = 10;
            PBE.UseStandardPrice = false;
            NewPBE.add(PBE);
        }
         Database.insert(NewPBE,false,AccessLevel.User_mode);            
                                    
       // insert NewPBE;
        
        List<PriceBookEntry> NewPBE2 = new List<PriceBookEntry>();
        for(integer i = 0; i < NoPriceBookEntry; i++) {
            PriceBookEntry PBE2 = new PriceBookEntry();
            PBE2.Product2ID = LstPro[i].id == null ? LstPro[0].id : LstPro[i].id;         
            PBE2.PriceBook2ID = LstPB2[0].id;
            PBE2.IsActive = true;
            PBE2.UnitPrice = 78;
            PBE2.UseStandardPrice = false;
            NewPBE2.add(PBE2);
        }        
       // insert NewPBE2;
       Database.insert(NewPBE2,false,AccessLevel.User_mode);            
        return NewPBE2;
    }   
    
    /*Designs*/
    public static List<Core_Design_Registration__c> createDDR(Integer NofDDR) {        
        
        List<Core_Design_Registration__c> LstDDR = new List<Core_Design_Registration__c>();
        
        for (integer i = 0; i <NofDDR; i++) {
            Core_Design_Registration__c ddr = new Core_Design_Registration__c();
            
            ddr.Core_Product_Group_Nm__c = 'FPGA/Power';
            ddr.Core_Design_Registration_Nm__c = 'DDR Test'+i;
            ddr.Core_Design_Registration_Dsc__c = 'ABC';
            ddr.Core_Opportunity_Volume_Cnt__c = 5;
            ddr.Core_Partner_FAE_Nm__c = '6';   
            ddr.Core_End_Customer_URL__c='www.testddr.com'; // added by dinesh
            ddr.Core_End_Customer_Nm__c = 'DDR Test'+i;            
            ddr.Core_End_Customer_Street_Addr_Line1_Txt__c = 'ABC '+i;
            ddr.Core_End_Customer_Street_Addr_Line2_Txt__c = 'Abc';
            ddr.Core_End_Customer_City_Nm__c = 'BAN';
            ddr.Core_End_Customer_Country_Subdivision_Nm__c = 'KA';
            ddr.PCC_End_Customer_Country__c = 'United States';
            ddr.Core_End_Customer_Postal_Cd__c = '560037';
            ddr.Core_Military_Aerospace_Gvrnmt_Use_Ind__c = 'Yes';
            ddr.Core_First_Customer_Ship_Dt__c = system.today()+46;
            ddr.Core_Production_End_Dt__c = system.today()+47;
            ddr.Core_Vertical_Market_Nm__c = 'Education';
            ddr.Core_Intel_Platform_Nm__c = 'Board';
            ddr.Core_Product_Application_Nm__c = 'Embedded Board';
            ddr.Core_Product_Segment_Nm__c = 'Embedded / IOT';
            ddr.Core_Manufacturing_Region_Cd__c = 'APJ';
            ddr.Core_Design_Registration_Status_Nm__c = 'Submitted';
            ddr.PCC_Industry__c = 'Agriculture';
            ddr.PCC_Sub_Industry__c = 'Forestry';
            ddr.PCC_Digital_Identifier__c='Website/URL';
            ddr.PCC_Digital_Identifier_Value__c='test';

            LstDDR.add(ddr);
        }
        return LstDDR;        
    }
    
    /*Design Products*/
    public static List<Core_Design_Registration_Product__c> CreateDRProduct(Integer NofDDP, List<Core_Design_Registration__c> LstDRProduct, List<Product2> LstProducts) {
        List<Core_Design_Registration_Product__c> LstDRProductlst = new List<Core_Design_Registration_Product__c>();
        
        for(integer i=0; i < NofDDP; i++) {
            Core_Design_Registration_Product__c DRproducts = new Core_Design_Registration_Product__c();
            
            DRproducts.Core_Design_Registration_Id__c = LstDRProduct[0].id;
            DRproducts.Core_Product_Id__c = LstProducts[0].id;
            DRproducts.Core_Target_Resale_Amt__c = 20;
            DRproducts.Core_Full_Year_Qty__c = 3;
            DRproducts.Core_Design_Product_Status_Nm__c = 'Pending';
            DRproducts.Core_Comment_Txt__c='Test';
            DRproducts.Core_Product_Id__c = LstProducts[0].id;
            LstDRProductlst.add(DRproducts);
        }
        return LstDRProductlst;
    }
    
    /*Location To Approver Group Mapping*/
    public static List<Core_Location_To_Approver_Group_Mapping__c> CreateLocationToApproverGroup() {
        List<Core_Location_To_Approver_Group_Mapping__c> NewLocToAppGroMap = new List<Core_Location_To_Approver_Group_Mapping__c> {
            new Core_Location_To_Approver_Group_Mapping__c(name = 'RSG Catch All', Core_Active_Ind__c = true, Core_Approver_Group_Nm__c = 'Core_DDR_Approver_RSG_Catch_All', Core_Country_Cd__c = '', Core_Product_Group_Nm__c = 'Embedded/IOT', Core_State_Cd__c = ''),
            new Core_Location_To_Approver_Group_Mapping__c(name = 'RSG CHN', Core_Active_Ind__c = true, Core_Approver_Group_Nm__c = 'Core_DDR_Approver_RSG_PRC', Core_Country_Cd__c = 'CHN', Core_Product_Group_Nm__c = 'Embedded/IOT', Core_State_Cd__c = ''),
            new Core_Location_To_Approver_Group_Mapping__c(name = 'RSG TWN', Core_Active_Ind__c = true, Core_Approver_Group_Nm__c = 'Core_DDR_Approver_RSG_Taiwan', Core_Country_Cd__c = 'TWN', Core_Product_Group_Nm__c = 'Embedded/IOT', Core_State_Cd__c = ''),
            new Core_Location_To_Approver_Group_Mapping__c(name = 'PSG Catch All', Core_Approver_Group_Nm__c = 'Core_DDR_Approver_PSG_Catch_All', Core_Country_Cd__c = '', Core_State_Cd__c = '', Core_Product_Group_Nm__c = 'FPGA/Power', Core_Active_Ind__c = true),
            new Core_Location_To_Approver_Group_Mapping__c(name = 'PSG USA-MD', Core_Approver_Group_Nm__c = 'Core_DDR_Approver_PSG_USA_MD_VA_NC_FL', Core_Country_Cd__c = 'USA', Core_State_Cd__c = 'MD', Core_Product_Group_Nm__c = 'FPGA/Power', Core_Active_Ind__c = true),
            new Core_Location_To_Approver_Group_Mapping__c(name = 'PSG USA-VA', Core_Approver_Group_Nm__c = 'Core_DDR_Approver_PSG_USA_MD_VA_NC_FL', Core_Country_Cd__c = 'USA', Core_State_Cd__c = '', Core_Product_Group_Nm__c = 'FPGA/Power', Core_Active_Ind__c = true),
            new Core_Location_To_Approver_Group_Mapping__c(name = 'PSG USA-NC', Core_Approver_Group_Nm__c = 'Core_DDR_Approver_PSG_USA_MD_VA_NC_FL', Core_Country_Cd__c = 'USA', Core_State_Cd__c = 'NC', Core_Product_Group_Nm__c = 'FPGA/Power', Core_Active_Ind__c = true),
            new Core_Location_To_Approver_Group_Mapping__c(name = 'PSG USA-FL', Core_Approver_Group_Nm__c = 'Core_DDR_Approver_PSG_USA_MD_VA_NC_FL', Core_Country_Cd__c = 'USA', Core_State_Cd__c = 'FL', Core_Product_Group_Nm__c = 'FPGA/Power', Core_Active_Ind__c = true),
            new Core_Location_To_Approver_Group_Mapping__c(name = 'PSG USA-CO', Core_Approver_Group_Nm__c = 'Core_DDR_Approver_PSG_USA_CO_UT', Core_Country_Cd__c = 'USA',Core_State_Cd__c = 'CO', Core_Product_Group_Nm__c = 'FPGA/Power', Core_Active_Ind__c = true),
            new Core_Location_To_Approver_Group_Mapping__c(name = 'PSG USA-UT', Core_Approver_Group_Nm__c = 'Core_DDR_Approver_PSG_USA_CO_UT', Core_Country_Cd__c = 'USA', Core_State_Cd__c = 'UT', Core_Product_Group_Nm__c = 'FPGA/Power', Core_Active_Ind__c = true),
            new Core_Location_To_Approver_Group_Mapping__c(name = 'PSG DEU', Core_Approver_Group_Nm__c = 'Core_DDR_Approver_PSG_Central_Europe', Core_Country_Cd__c = 'DEU', Core_State_Cd__c = '', Core_Product_Group_Nm__c = 'FPGA/Power', Core_Active_Ind__c = true),
            new Core_Location_To_Approver_Group_Mapping__c(name = 'PSG CHE', Core_Approver_Group_Nm__c = 'Core_DDR_Approver_PSG_Central_Europe', Core_Country_Cd__c = 'CHE', Core_State_Cd__c = '', Core_Product_Group_Nm__c = 'FPGA/Power', Core_Active_Ind__c = true),
            new Core_Location_To_Approver_Group_Mapping__c(name = 'PSG VNM', Core_Approver_Group_Nm__c = 'Core_DDR_Approver_PSG_South_AP', Core_Country_Cd__c = 'VNM', Core_State_Cd__c = '', Core_Product_Group_Nm__c = 'FPGA/Power', Core_Active_Ind__c = true),
            new Core_Location_To_Approver_Group_Mapping__c(name = 'PSG AUT', Core_Approver_Group_Nm__c = 'Core_DDR_Approver_PSG_Central_Europe', Core_Country_Cd__c = 'AUT', Core_State_Cd__c = '', Core_Product_Group_Nm__c = 'FPGA/Power', Core_Active_Ind__c = true),
            new Core_Location_To_Approver_Group_Mapping__c(name = 'PSG LIE', Core_Approver_Group_Nm__c = 'Core_DDR_Approver_PSG_Central_Europe', Core_Country_Cd__c = 'LIE', Core_State_Cd__c = '', Core_Product_Group_Nm__c = 'FPGA/Power', Core_Active_Ind__c = true),
            new Core_Location_To_Approver_Group_Mapping__c(name = 'PSG CHN', Core_Approver_Group_Nm__c = 'Core_DDR_Approver_PSG_China', Core_Country_Cd__c = 'CHN', Core_State_Cd__c = '', Core_Product_Group_Nm__c = 'FPGA/Power', Core_Active_Ind__c = true),
            new Core_Location_To_Approver_Group_Mapping__c(name = ' PSG AUS', Core_Approver_Group_Nm__c = 'Core_DDR_Approver_PSG_South_AP', Core_Country_Cd__c = 'AUS', Core_State_Cd__c = '', Core_Product_Group_Nm__c = 'FPGA/Power', Core_Active_Ind__c = true),
            new Core_Location_To_Approver_Group_Mapping__c(name = 'PSG NZL', Core_Approver_Group_Nm__c = 'Core_DDR_Approver_PSG_South_AP', Core_Country_Cd__c = 'NZL', Core_State_Cd__c = '', Core_Product_Group_Nm__c = 'FPGA/Power', Core_Active_Ind__c = true),
            new Core_Location_To_Approver_Group_Mapping__c(name = 'PSG SGP', Core_Approver_Group_Nm__c = 'Core_DDR_Approver_PSG_South_AP', Core_Country_Cd__c = 'SGP', Core_State_Cd__c = '', Core_Product_Group_Nm__c = 'FPGA/Power', Core_Active_Ind__c = true),
            new Core_Location_To_Approver_Group_Mapping__c(name = 'PSG PHL', Core_Approver_Group_Nm__c = 'Core_DDR_Approver_PSG_South_AP', Core_Country_Cd__c = 'PHL', Core_State_Cd__c = '', Core_Product_Group_Nm__c = 'FPGA/Power', Core_Active_Ind__c = true),
            new Core_Location_To_Approver_Group_Mapping__c(name = 'PSG THA', Core_Approver_Group_Nm__c = 'Core_DDR_Approver_PSG_South_AP', Core_Country_Cd__c = 'THA', Core_State_Cd__c = '', Core_Product_Group_Nm__c = 'FPGA/Power', Core_Active_Ind__c = true),
            new Core_Location_To_Approver_Group_Mapping__c(name = 'PSG MYS', Core_Approver_Group_Nm__c = 'Core_DDR_Approver_PSG_South_AP', Core_Country_Cd__c = 'MYS', Core_State_Cd__c = '', Core_Product_Group_Nm__c = 'FPGA/Power', Core_Active_Ind__c = true),
            new Core_Location_To_Approver_Group_Mapping__c(name = 'PSG JPN', Core_Approver_Group_Nm__c = 'Core_DDR_Approver_PSG_Japan', Core_Country_Cd__c = 'JPN', Core_State_Cd__c = '', Core_Product_Group_Nm__c = 'FPGA/Power', Core_Active_Ind__c = true),
            new Core_Location_To_Approver_Group_Mapping__c(name = 'PSG USA-OR', Core_Approver_Group_Nm__c = 'Core_DDR_Approver_PSG_USA_Oregon', Core_Country_Cd__c = 'USA', Core_State_Cd__c = 'OR', Core_Product_Group_Nm__c = 'FPGA/Power', Core_Active_Ind__c = true)
        };
        insert NewLocToAppGroMap;
        //Database.insert(NewLocToAppGroMap,false,AccessLevel.User_mode);            
       
        return NewLocToAppGroMap;
    }
    
    /*DDR LogEntry Check*/
    public static List<Core_LogEntry_Switch__c> CreateLogEntry() {
        
        List<Core_LogEntry_Switch__c> LogEntryLst = new List<Core_LogEntry_Switch__c> {
            new Core_LogEntry_Switch__c(name = 'Core_DDR_LogEntry_Check', Is_Selected__c = true)
        };
        insert LogEntryLst;
        //Database.insert(LogEntryLst,false,AccessLevel.User_mode);            
        return LogEntryLst;
    }
  
}