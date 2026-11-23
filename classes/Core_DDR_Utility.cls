public class Core_DDR_Utility {    
    
    public static List<Product2> CreateProduct(Integer NoProducts){
        List<Product2> NewProducts = new List<Product2>();
        for(Integer i = 0; i < NoProducts; i++){
            Product2 prod = new Product2();
            
            prod.name = 'Intel Atom® CE4275 Media Processor';
            prod.Core_Design_Registration_Eligible_Ind__c  = true;
            prod.Core_Sales_Visible_Flag__c = true;
            prod.isActive = true;
            prod.Core_Partner_Visible_Ind__c = true;
            NewProducts.add(prod);
        }
        return NewProducts;
    }
    public static List<Core_Design_Registration__c> createDDR(Integer NofDDR, List<Account> LstAcc){        
        
        List<Core_Design_Registration__c> LstDDR = new List<Core_Design_Registration__c>();
        
        for (integer i = 0; i <NofDDR; i++) {
            Core_Design_Registration__c ddr = new Core_Design_Registration__c();
            
            ddr.Core_End_Customer_Nm__c = 'DDR Test'+i;
            //ddr.Core_End_Customer_Account_Id__c = LstAcc[i].id;
            ddr.Core_Design_Registration_Nm__c = 'DDR Test'+i;
            ddr.Core_End_Customer_Street_Addr_Line1_Txt__c = 'ABC '+i;
            ddr.Core_End_Customer_Street_Addr_Line1_Txt__c = 'XYZ '+i;
            ddr.Core_End_Customer_Street_Addr_Line2_Txt__c = 'Abc';
            ddr.Core_End_Customer_Country_Nm__c = 'USA';
            ddr.Core_Product_Group_Nm__c = 'FPGA/Power';
            ddr.Core_Design_Registration_Dsc__c = 'ABC';
            ddr.Core_Opportunity_Volume_Cnt__c = 5;
            ddr.Core_Military_Aerospace_Gvrnmt_Use_Ind__c = 'Yes';
            ddr.Core_Opportunity_Decision_Dt__c = system.today()+45;
            ddr.Core_First_Customer_Ship_Dt__c = system.today()+46;
            ddr.Core_Production_End_Dt__c = system.today()+47;
            ddr.Core_Intel_Platform_Nm__c = 'Bakerville';
            ddr.Core_Vertical_Market_Nm__c = 'Education';
            ddr.Core_Manufacturing_Region_Cd__c = 'APJ';
            ddr.Core_Design_Registration_Status_Nm__c = 'Submitted';
            LstDDR.add(ddr);
        }
        return LstDDR;        
    }
    
    public static List<Core_Design_Registration_Product__c> CreateDRProduct(Integer NofDDP, List<Core_Design_Registration__c> LstDRProduct, List<Product2> LstProducts){
        List<Core_Design_Registration_Product__c> LstDRProductlst = new List<Core_Design_Registration_Product__c>();
        
        for(integer i=0; i < NofDDP; i++)
        {
            Core_Design_Registration_Product__c DRproducts = new Core_Design_Registration_Product__c();
            
            DRproducts.Core_Design_Registration_Id__c = LstDRProduct[0].id;// == null ? LstDRProduct[0].id : LstDRProduct[i].id;
            DRproducts.Core_Product_Id__c = LstProducts[0].id;//== null ? LstProducts[0].id : LstProducts[i].id;
            DRproducts.Core_Target_Resale_Amt__c = 20;
            DRproducts.Core_Full_Year_Qty__c = 3;
            DRproducts.Core_Design_Product_Status_Nm__c = 'Pending';
            LstDRProductlst.add(DRproducts);
        }
        return LstDRProductlst;
    }
}