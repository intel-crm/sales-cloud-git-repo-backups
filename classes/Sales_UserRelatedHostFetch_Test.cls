@isTest
public class Sales_UserRelatedHostFetch_Test {
    //@testSetup static void setup()
    static testMethod void testSalesHostList(){
    List<Sales_Host__c> hostinfo = new List<Sales_Host__c>();
    for(Sales_Host__c hosts : hostinfo){
        hosts.Sales_Primary_Admin_Name__c = 'xyz';
        hosts.Sales_Computer_Name_Txt__c = 'abc';
        hosts.Sales_License_Type__c = 'FIXED';
        hosts.Sales_Computer_Type__c = 'NIC ID';
        hosts.Name = '123456789ABC';
        
        
    }
    insert hostinfo;
    
    Test.startTest();
    Sales_UserRelatedHostFetch.getHosts();
    Test.stopTest();
    }
    
    @isTest
        static void createHostLicTest(){
            
            List<Sales_License_Generator__c> licenseGen = new List<Sales_License_Generator__c>();
            Sales_License_Generator__c lGen = new  Sales_License_Generator__c();
            lGen.Name='Gen1';
            lGen.Sales_License_Vendor__c='Mentor Graphics';
            lGen.Sales_License_Generator_txt__c='genlic';
            lGen.Sales_License_Feature_Lyn_Syntx_txt__c='Gen';
            licenseGen.add(lGen);
            insert licenseGen;
    
            Sales_License_Group__c lgp = new Sales_License_Group__c();
            lgp.Name = 'lgp1';
            lgp.Sales_License_Generator__c = licenseGen[0].id ;
            insert lgp;                     
            
            Product2 p = new Product2();
            p.Name = ' Test Corporate Product';
            p.Description='Test Product Entry 1';
            p.productCode = 'ABC';
            p.isActive = true;
            p.Core_Item_Orderable_Ind__c = true;
            p.SBQQ__SubscriptionTerm__c=10;
            p.SBQQ__SubscriptionPricing__c ='Fixed Price';
            p.SBQQ__SubscriptionType__c = 'One-time';
            insert p; 
            system.debug('test class product>>'+p);          
            
            Core_Product_Ext_Attribute__c l1 = new Core_Product_Ext_Attribute__c();
            l1.Core_SW_Lic_Enforcement_Method_Nm__c = 'File';
            l1.Core_Prod_Tool_Type_Nm__c = 'BASE';
            l1.Core_SW_Lic_Type_Nm__c = 'FIXED' ; 
            l1.Core_SW_Prod_Max_Rehost_Cnt__c = 1;
            l1.Core_SW_Prod_Web_Dsc__c='Test';
            l1.Core_SW_Lic_File_Data_Encryption_Std_Cd__c = '1DES' ;
            l1.Core_SW_Prod_Avail_To_TL_ORD_ENBLMT_Ind__c = true;
            l1.Core_SW_Lic_Group_Id__c = lgp.id;
            l1.Core_SW_Lic_Generator_Parameter_Txt__c = 'testing';
            l1.Core_SW_Prod_Expiration_Duration_Nbr__c = 45;
            l1.Core_SW_Prod_Non_Commercial_Purpose_Nm__c='Employee';
            l1.Core_Foundation_Product_Id__c=p.id;
            l1.Core_Product_Id__c=p.id;
            insert l1;
            
            Sales_License__c lic=new Sales_License__c();
            lic.Sales_License_Quantity__c=1;
            lic.Sales_License_Product_Name_Txt__c='Test';
            lic.Sales_License_Maintenance_Exp_Dt__c=system.today();
            lic.Sales_License_Expiration_Date_Dt__c=system.today()+1;
            lic.Sales_License_Start_Date_Dt__c=system.today();
            lic.Sales_License_Status__c='Licensed';
            lic.Sales_License_Avbl_Qty_Nbr__c=1;
            lic.Sales_License_Avbl_Rehost_Nbr__c=1;
            lic.Opt_in_out__c=true;
            lic.Sales_License_Web_Display_Flag__c=false;
            lic.Sales_License_Type__c='Optional';
            lic.Sales_License_Product__c=p.id;
            insert lic;
            system.debug('test class product extnd>>'+l1);     

			Sales_License__c lic2=new Sales_License__c();
            lic2.Sales_License_Quantity__c=1;
            lic2.Sales_License_Product_Name_Txt__c='Test';
            lic2.Sales_License_Maintenance_Exp_Dt__c=system.today();
            lic2.Sales_License_Expiration_Date_Dt__c=system.today()+1;
            lic2.Sales_License_Start_Date_Dt__c=system.today();
            lic2.Sales_License_Status__c='Unlicensed';
            lic2.Sales_License_Avbl_Qty_Nbr__c=1;
            lic2.Sales_License_Avbl_Rehost_Nbr__c=1;
            lic2.Opt_in_out__c=true;
            lic2.Sales_License_Web_Display_Flag__c=false;
            lic2.Sales_License_Type__c='Original';
            lic2.Sales_License_Product__c=p.id;
            insert lic2;
            system.debug('test class product extnd>>'+l1);  
			
            test.startTest();
            List<product2> prodid=[select id from product2 limit 1];
            list<id> idlist=new list<id>();
            for(product2 prd:prodid){
                idlist.add(prd.id);
            }
            //Sales_UserRelatedHostFetch.createLicNew(lic.id,idlist);
			//Sales_UserRelatedHostFetch.createLicNew(lic2.id,idlist);
            test.stopTest();        
        }
}