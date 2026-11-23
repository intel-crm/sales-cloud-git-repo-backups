@isTest
        public class Core_DDR_Product_Handler_Test
        {
            public static testmethod void DR_Product_test1() {
                List<account> LstAcc = Core_Test_Utility.createAccount(5);
                insert LstAcc;
                
                Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
                update standardPricebook;
                
                Core_Location_To_Approver_Group_Mapping__c locationToApproverGrp = new Core_Location_To_Approver_Group_Mapping__c(name = 'USA-OR', Core_Active_Ind__c = true, Core_Country_Cd__c = 'USA', Core_Approver_Group_Nm__c = 'Core_Design_Approver_USA_Oregon', Core_State_Cd__c = 'OR');
                insert locationToApproverGrp;
                
                List<Product2> products2 = Core_DDR_Utility.CreateProduct(5);
                insert products2;
                
                List<Core_Design_Registration__c> TestDDRlst = Core_DDR_Utility.createDDR(5);
                insert TestDDRlst;
                
                List<Core_Design_Registration_Product__c> TestDDRProd = Core_DDR_Utility.CreateDRProduct(5, TestDDRlst, products2);
                insert TestDDRProd;
                
                List<Core_Design_Registration_Product__c> DRP_Update = new List<Core_Design_Registration_Product__c>();
                
                for(Core_Design_Registration_Product__c pupdate: TestDDRProd){
                    pupdate.Core_Design_Product_Status_Nm__c = 'Approved';
                    DRP_Update.add(pupdate);
                }
                update DRP_Update;
                
                
                List<Core_Design_Registration__c> TestDDRupdate = new List<Core_Design_Registration__c>();
                
                for(Core_Design_Registration__c upDDR: TestDDRlst){
                    //upDDR.Core_Design_Registration_Status_Nm__c = 'Approved';
                    upDDR.Core_Design_Registration_Status_Nm__c = 'Submitted';
                   // upDDR.Core_Product_Segment_Nm__c = 'Client Computing';
                   // upDDR.Core_Product_Application_Nm__c = 'Business Desktop';
                    upDDR.Core_Partner_Account_Id__c = LstAcc[0].id;
                    TestDDRupdate.add(upDDR);
                }
                Test.startTest();
                update TestDDRupdate;
                
                List<Core_Design_Registration_Product__c> TestDDRProd2 = Core_DDR_Utility.CreateDRProduct(5, TestDDRlst, products2);
                insert TestDDRProd2;
                
                for(Core_Design_Registration_Product__c pupdate: TestDDRProd2){
                    pupdate.Core_Design_Product_Status_Nm__c = 'Approved';
                    DRP_Update.add(pupdate);
                }
                //update DRP_Update;
                
                List<Core_Design_Registration__c> TestDDRupdate2 = new List<Core_Design_Registration__c>();
                for(Core_Design_Registration__c upDDR: TestDDRlst){
                    upDDR.Core_Design_Registration_Status_Nm__c = 'Approved';
                    TestDDRupdate2.add(upDDR);
                }
                Assert.isNotNull(TestDDRupdate2);
                update TestDDRupdate2;
                
                Test.stopTest();
            }
            
            public static testmethod void DR_Product_test2() {
                List<account> LstAcc = Core_Test_Utility.createAccount(5);
                insert LstAcc;
                
                Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
                update standardPricebook;
                
                Core_Location_To_Approver_Group_Mapping__c locationToApproverGrp = new Core_Location_To_Approver_Group_Mapping__c(name = 'USA-OR', Core_Active_Ind__c = true, Core_Country_Cd__c = 'USA', Core_Approver_Group_Nm__c = 'Core_Design_Approver_USA_Oregon', Core_State_Cd__c = 'OR');
                insert locationToApproverGrp;
                
                List<Product2> products2 = Core_DDR_Utility.CreateProduct(5);
                insert products2;
                
                List<Core_Design_Registration__c> TestDDRlst = Core_DDR_Utility.createDDR(5);
                insert TestDDRlst;
                
                List<Core_Design_Registration_Product__c> TestDDRProd = Core_DDR_Utility.CreateDRProduct(5, TestDDRlst, products2);
                insert TestDDRProd;
                
                List<Core_Design_Registration_Product__c> DRP_Update = new List<Core_Design_Registration_Product__c>();
                
                for(Core_Design_Registration_Product__c pupdate: TestDDRProd){
                    pupdate.Core_Design_Product_Status_Nm__c = 'Rejected';
                    pupdate.Core_Comment_Txt__c ='Rejected - Test';
                    DRP_Update.add(pupdate);
                }
                update DRP_Update;
                
                List<Core_Design_Registration__c> TestDDRupdate = new List<Core_Design_Registration__c>();
                List<Core_Design_Registration_Product__c> TestDDRProdRej = Core_DDR_Utility.CreateDRProduct(5, TestDDRlst, products2);
                insert TestDDRProdRej;
                List<Core_Design_Registration_Product__c> DRP_UpdateRej = new List<Core_Design_Registration_Product__c>();
                
                for(Core_Design_Registration_Product__c pupdate: TestDDRProdRej){
                    pupdate.Core_Design_Product_Status_Nm__c = 'Approved';
                    DRP_UpdateRej.add(pupdate);
                }
                update DRP_UpdateRej;
                for(Core_Design_Registration__c upDDR: TestDDRlst){
                    upDDR.Core_Design_Registration_Status_Nm__c = 'Rejected';
                    upDDR.Core_Rejection_Comment_Txt__c = 'Embedded';
                    upDDR.Core_Rejection_Reason_Nm__c = 'Duplicate registration';
                    upDDR.Core_Partner_Account_Id__c = LstAcc[0].id;
                    TestDDRupdate.add(upDDR);
                }
                Test.startTest();
                update TestDDRupdate;
                
                List<Core_Design_Registration__c> TestDDRupdate_Rej = new List<Core_Design_Registration__c>();
                
                for(Core_Design_Registration__c upDDR: TestDDRlst){
                    //upDDR.Core_Design_Registration_Status_Nm__c = 'Approved';
                    upDDR.Core_Design_Registration_Status_Nm__c = 'Submitted';
                  //  upDDR.Core_Product_Segment_Nm__c = 'Client Computing';
                   // upDDR.Core_Product_Application_Nm__c = 'Business Desktop';
                    upDDR.Core_Partner_Account_Id__c = LstAcc[0].id;
                    TestDDRupdate_Rej.add(upDDR);
                }
                Assert.isNotNull(TestDDRupdate_Rej);
                update TestDDRupdate_Rej;
                
                Core_Design_Registration_Product__c DRproducts = new Core_Design_Registration_Product__c();
                DRproducts.Core_Design_Registration_Id__c = TestDDRupdate_Rej[0].id;
                DRproducts.Core_Product_Id__c = DRP_UpdateRej[0].Core_Product_Id__c;
                DRproducts.Core_Target_Resale_Amt__c = 20;
                DRproducts.Core_Full_Year_Qty__c = 3;
                DRproducts.Core_Design_Product_Status_Nm__c = 'Pending';
                Assert.isNotNull(DRproducts);
                insert DRproducts;
                
                 List<Core_Design_Registration__c> TestDDRlst28 = Core_DDR_Utility.createDDR(1);
                insert TestDDRlst28;
                 List<Core_Design_Registration__c> TestDDRlst29 = Core_DDR_Utility.createDDR(1);
                insert TestDDRlst29;
                List<Core_Design_Registration_Product__c> TestDDRProd28 = Core_DDR_Utility.CreateDRProduct(1, TestDDRlst28, products2);
                insert TestDDRProd28;
                 List<Core_Design_Registration_Product__c> TestDDRProd29 = Core_DDR_Utility.CreateDRProduct(2, TestDDRlst29, products2);
                insert TestDDRProd29;
                
                 for(Core_Design_Registration_Product__c pupdate: TestDDRProd28){
                    pupdate.Core_Design_Product_Status_Nm__c = 'Expired';
                    pupdate.Core_Comment_Txt__c ='Rejected - Test';
                    DRP_Update.add(pupdate);
                }
                update DRP_Update;
                
                TestDDRProd29[0].Core_Design_Product_Status_Nm__c ='Expired';
                update TestDDRProd29;
                Test.stopTest();
            }
            
            public static testmethod void DR_Product_Exc() {
                List<account> LstAcc = Core_Test_Utility.createAccount(5);
                insert LstAcc;
                
                Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
                update standardPricebook;
                
                Core_Location_To_Approver_Group_Mapping__c locationToApproverGrp = new Core_Location_To_Approver_Group_Mapping__c(name = 'USA-OR', Core_Active_Ind__c = true, Core_Country_Cd__c = 'USA', Core_Approver_Group_Nm__c = 'Core_Design_Approver_USA_Oregon', Core_State_Cd__c = 'OR');
                insert locationToApproverGrp;
                
                List<Product2> products2 = Core_DDR_Utility.CreateProduct(5);
                insert products2;
                
                List<Core_Design_Registration__c> TestDDRlst = Core_DDR_Utility.createDDR(5);
                Assert.isNotNull(TestDDRlst);
                insert TestDDRlst;
                
                List<Core_Design_Registration_Product__c> TestDDRProd = Core_DDR_Utility.CreateDRProduct(5, TestDDRlst, products2);
                for(Core_Design_Registration_Product__c prod: TestDDRProd){
                    prod.Core_Design_Product_Status_Nm__c = 'Cancelled';
                }
                //insert TestDDRProd;
            }
            
            public static testmethod void DR_ProductTest2() {
                List<account> LstAcc = Core_Test_Utility.createAccount(5);
                insert LstAcc;
                
                Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
                update standardPricebook;
                
                List<Product2> products2 = Core_DDR_Utility.CreateProduct(5);
                products2[0].Core_Product_Type__c ='FPGA';
                products2[1].Core_Product_Type__c = 'Processor';
                insert products2;
                
                List<Core_Design_Registration__c> TestDDRlst = Core_DDR_Utility.createDDR(2);
                insert TestDDRlst;
                
                TestDDRlst[1].Core_Design_Registration_Status_Nm__c = 'Approved';
                //TestDDRlst[1].Core_Product_Segment_Nm__c = 'Client Computing';
                //TestDDRlst[1].Core_Product_Application_Nm__c = 'Business Mobility';
                TestDDRlst[1].Core_Partner_Account_Id__c = LstAcc[0].id;
                TestDDRlst[1].Core_Submission_Type__c='M2M';
                Assert.isNotNull(TestDDRlst);
                update TestDDRlst[1];
                
                Core_Design_Registration_Product__c DRproducts = new Core_Design_Registration_Product__c();
                // System.debug('here=='+TestDDRupdate_Rej[0].Core_Design_Registration_Status_Nm__c);
                DRproducts.Core_Design_Registration_Id__c = TestDDRlst[1].id;
                DRproducts.Core_Product_Id__c = products2[0].Id;
                DRproducts.Core_Target_Resale_Amt__c = 20;
                DRproducts.Core_Full_Year_Qty__c = 3;
                DRproducts.Core_Design_Product_Status_Nm__c = 'Pending';
                insert DRproducts;
                
                Core_Design_Registration_Product__c DRproducts1 = new Core_Design_Registration_Product__c();
                //  System.debug('here=='+TestDDRupdate_Rej[0].Core_Design_Registration_Status_Nm__c);
                DRproducts1.Core_Design_Registration_Id__c = TestDDRlst[1].id;
                DRproducts1.Core_Product_Id__c = products2[1].Id;
                DRproducts1.Core_Target_Resale_Amt__c = 20;
                DRproducts1.Core_Full_Year_Qty__c = 3;
                DRproducts1.Core_Design_Product_Status_Nm__c = 'Pending';
                Assert.isNotNull(DRproducts1);
                insert DRproducts1;
                //System.debug('here=='+TestDDRupdate_Rej[0].Core_Design_Registration_Status_Nm__c);*/
                
            }
            
            @isTest
            static void createDRProductTest1(){
                ChannelProgram cp = new ChannelProgram();
                cp.Name = 'Partner Covers Customer (PCC)';
                cp.IsActive  = true;
                insert cp;
                Product2 pr = new Product2();
                pr.Name = 'Test data 1';
                pr.IsActive = true;
                pr.Core_Design_Registration_Eligible_Ind__c = true;
                pr.Core_Avail_for_New_Designs__c = true;
                pr.Core_Sales_Visible_Flag__c = true;
                insert pr;
                Product2 pr1 = new Product2();
                pr1.Name = 'Test data 2';
                pr1.IsActive = true;
                pr1.Core_Design_Registration_Eligible_Ind__c = true;
                pr1.Core_Avail_for_New_Designs__c = true;
                pr1.Core_Sales_Visible_Flag__c = true;
                insert pr1;
                Core_Design_Registration__c ddrRec = new  Core_Design_Registration__c();
                ddrRec.Core_Product_Group_Nm__c = 'Embedded/IOT';
                ddrRec.Core_Military_Aerospace_Gvrnmt_Use_Ind__c = 'Yes';
                ddrRec.Core_Vertical_Market_Nm__c='Education';
                ddrRec.Core_Product_Segment_Nm__c='Client Computing';
                ddrRec.Core_Product_Application_Nm__c='Business Desktop';
                ddrRec.Core_Opportunity_Volume_Cnt__c=100;
                ddrRec.Core_Partner_FAE_Nm__c='Test FAE';
                ddrRec.Core_Partner_FSR_Nm__c='Test FSR';
                ddrRec.Core_End_Customer_Nm__c='Arrow Electronics Account';
                ddrRec.Core_End_Customer_Street_Addr_Line1_Txt__c='12 Street 99';
                ddrRec.Core_End_Customer_Street_Addr_Line2_Txt__c='ffsfjk';
                ddrRec.Core_End_Customer_Country_Nm__c='India';
                ddrRec.Core_End_Customer_City_Nm__c='Bangalore';
                ddrRec.Core_End_Customer_Country_Subdivision_Nm__c='Karnataka';
				ddrRec.PCC_End_Customer_Country__c='India';
                ddrRec.Core_End_Customer_Postal_Cd__c='758854';
                ddrRec.Core_End_Customer_Contact_Title_Txt__c='Mr.';
                ddrRec.Core_End_Customer_Contact_Nm__c='Arrow Electronics Partner User 01';
                ddrRec.Core_End_Customer_Contact_Email_Txt__c='arrowelec.partneruser01@marketstar.com';
                ddrRec.Core_End_Customer_Contact_Phone_Txt__c='7826499722';
                ddrRec.Core_Manufacturing_Region_Cd__c='ASMO';
				
                ddrRec.Core_Opportunity_Decision_Dt__c = system.today().addDays(10);
                ddrRec.Core_First_Customer_Ship_Dt__c = system.today().addDays(11);
                ddrRec.Core_Production_End_Dt__c = system.today().addDays(20);
                ddrRec.Core_Intel_Platform_Nm__c='Arria';
                ddrRec.Core_Design_Registration_Dsc__c='Test Des';
                ddrRec.Core_Design_Registration_Nm__c='Test DR Name Arrow';
				ddrRec.PCC_Industry__c = 'Agriculture';
			ddrRec.PCC_Sub_Industry__c = 'Forestry';
			ddrRec.PCC_Digital_Identifier__c='Website/URL';
			ddrRec.PCC_Digital_Identifier_Value__c='test';
           

                insert ddrRec;
                Product_MM_Attribute_Mapping__c pmam = new Product_MM_Attribute_Mapping__c();
                pmam.Ordering_Code__c = 'WX80660E52630V4';
                pmam.Name = '949344';
                //pmam.MMID__c = '949344';
                pmam.L4_Product__c = pr.Id;
                Assert.isNotNull(pmam);
                insert pmam;
                Product_MM_Attribute_Mapping__c pmam1 = new Product_MM_Attribute_Mapping__c();
                pmam1.Ordering_Code__c = 'WX80550E52630V4';
                pmam1.Name = '949348';
                //pmam1.MMID__c = '949348';
                pmam1.L5_Product__c = pr1.Id;
                Assert.isNotNull(pmam1);
                insert pmam1;
                RestRequest req = new RestRequest();
                RestResponse res = new RestResponse();
            req.requestBody = Blob.valueOf('[{"designRegId":"'+ddrRec.Id+'","mmId":"949348","quantity":"100","externalId":"shs002ABCD"},{"designRegId":"'+ddrRec.Id+'","orderingCd":"WX80660E52630V4","quantity":"100","externalId":"shs002ABCD2"},{"designRegId":"'+ddrRec.Id+'","orderingCd":"CL8067702999011","quantity":"100","externalId":"shs00ABCD3"},{"designRegId":"ABCD","mmId":"924562","quantity":"100","externalId":"shs00ABCD5"},{"designRegId":"'+ddrRec.Id+'","mmId":"","quantity":"100","externalId":"shs002ABCD6"},{"designRegId":"'+ddrRec.Id+'","mmId":"924562","quantity":"","externalId":"shs002ABCD7"},{"designRegId":"'+ddrRec.Id+'","mmId":"924562","quantity":"100"}]');
            RestContext.request = req; RestContext.response = res;
            Test.startTest();
            PCC_CreateDDRProducts_V1.createDDRProductRecords();
            Test.stopTest();
        }
        
        @isTest
        static void createDRProductTest2(){
            ChannelProgram cp = new ChannelProgram();
            cp.Name = 'Partner Covers Customer (PCC)';
            cp.IsActive  = true;
            insert cp;
            Product2 pr = new Product2();
            pr.Name = 'Test data 1';
            pr.IsActive = true;
            pr.Core_Design_Registration_Eligible_Ind__c = true;
            pr.Core_Avail_for_New_Designs__c = true;
            pr.Core_Sales_Visible_Flag__c = true;
            insert pr;
            Product2 pr1 = new Product2();
            pr1.Name = 'Test data 2';
            pr1.IsActive = true;
            pr1.Core_Design_Registration_Eligible_Ind__c = true;
            pr1.Core_Avail_for_New_Designs__c = true;
            pr1.Core_Sales_Visible_Flag__c = true;
            insert pr1;
            Core_Design_Registration__c ddrRec = new  Core_Design_Registration__c();
            ddrRec.Core_Product_Group_Nm__c = 'Embedded/IOT';
            ddrRec.Core_Vertical_Market_Nm__c='Education';
            ddrRec.Core_Military_Aerospace_Gvrnmt_Use_Ind__c = 'Yes';
            ddrRec.Core_Product_Segment_Nm__c='Client Computing';
            ddrRec.Core_Product_Application_Nm__c='Business Desktop';
            ddrRec.Core_Opportunity_Volume_Cnt__c=100;
            ddrRec.Core_Partner_FAE_Nm__c='Test FAE';
            ddrRec.Core_Partner_FSR_Nm__c='Test FSR';
            ddrRec.Core_End_Customer_Nm__c='Arrow Electronics Account';
            ddrRec.Core_End_Customer_Street_Addr_Line1_Txt__c='12 Street 99';
            ddrRec.Core_End_Customer_Street_Addr_Line2_Txt__c='jndjksjd';
            ddrRec.PCC_End_Customer_Country__c='India';
            ddrRec.Core_End_Customer_City_Nm__c='Bangalore';
            ddrRec.Core_End_Customer_Country_Subdivision_Nm__c='Karnataka';
            ddrRec.Core_End_Customer_Postal_Cd__c='758854';
            ddrRec.Core_End_Customer_Contact_Title_Txt__c='Mr.';
            ddrRec.Core_End_Customer_Contact_Nm__c='Arrow Electronics Partner User 01';
            ddrRec.Core_End_Customer_Contact_Email_Txt__c='arrowelec.partneruser01@marketstar.com';
            ddrRec.Core_End_Customer_Contact_Phone_Txt__c='7826499722';
            ddrRec.Core_Manufacturing_Region_Cd__c='ASMO';
            ddrRec.Core_Intel_Platform_Nm__c='Arria';
            ddrRec.Core_Opportunity_Decision_Dt__c = system.today().addDays(10);
            ddrRec.Core_First_Customer_Ship_Dt__c = system.today().addDays(11);
            ddrRec.Core_Production_End_Dt__c = system.today().addDays(20);
            ddrRec.Core_Design_Registration_Nm__c='Test DR Name Arrow';
            ddrRec.Core_Design_Registration_Dsc__c='Test Des';
			ddrRec.PCC_Industry__c = 'Agriculture';
			ddrRec.PCC_Sub_Industry__c = 'Forestry';
			ddrRec.PCC_Digital_Identifier__c='Website/URL';
			ddrRec.PCC_Digital_Identifier_Value__c='test';
            Assert.isNotNull(ddrRec);
            insert ddrRec;
            Core_Design_Registration_Product__c DRproducts = new Core_Design_Registration_Product__c();
            DRproducts.Core_Design_Registration_Id__c = ddrRec.id;
            DRproducts.Core_Product_Id__c = pr1.Id;
            DRproducts.Core_Target_Resale_Amt__c = 20;
            DRproducts.Core_Full_Year_Qty__c = 3;
            DRproducts.Core_Submission_Type__c = 'M2M';
            DRproducts.Core_Design_Product_Status_Nm__c = 'Cancelled';
            insert DRproducts;
            DRproducts.Core_Product_Id__c = pr.Id;
            update DRproducts;
            Product_MM_Attribute_Mapping__c pmam = new Product_MM_Attribute_Mapping__c();
            pmam.Ordering_Code__c = 'WX80660E52630V4';
            pmam.Name = '949344';
            //pmam.MMID__c = '949344';
            pmam.L4_Product__c = pr.Id;
            Assert.isNotNull(pmam);
            insert pmam;
            Product_MM_Attribute_Mapping__c pmam1 = new Product_MM_Attribute_Mapping__c();
            pmam1.Ordering_Code__c = 'WX80550E52630V4';
            pmam1.Name = '949348';//pmam.MMID__c = '949348';
            pmam1.L5_Product__c = pr1.Id;
            insert pmam1;
            PCC_DDR_L5_Product_Mapping__c dlpm = new PCC_DDR_L5_Product_Mapping__c();
            dlpm.PCC_Design_Registration__c = ddrRec.id;
            dlpm.PCC_Design_Registration_Product__c = DRproducts.id;
            dlpm.PCC_Product_MM_Attribute_Mapping__c = pmam1.id;
            dlpm.PCC_MM_ID__c = pmam1.Name;
            dlpm.PCC_Ordering_Cd__c = pmam1.Ordering_Code__c;
            //dlpm.PCC_Old_MM_Id__c = pmam1.MMID__c;
            insert dlpm;
            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('[{"mmId":"949344","recordId":"'+DRproducts.Id+'"}]');
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        PCC_CreateDDRProducts_V1.updateDDRProductRecord();
        Test.stopTest();
    }
    
    @isTest
    static void updateDRProductTest3(){
        ChannelProgram cp = new ChannelProgram();
        cp.Name = 'Partner Covers Customer (PCC)';
        cp.IsActive  = true;
        insert cp;
        Product2 pr = new Product2();
        pr.Name = 'Test data 1';
        pr.IsActive = true;
        pr.Core_Design_Registration_Eligible_Ind__c = true;
        pr.Core_Avail_for_New_Designs__c = true;
        pr.Core_Sales_Visible_Flag__c = true;
        insert pr;
        Product2 pr1 = new Product2();
        pr1.Name = 'Test data 2';
        pr1.IsActive = true;
        pr1.Core_Design_Registration_Eligible_Ind__c = true;
        pr1.Core_Avail_for_New_Designs__c = true;
        pr1.Core_Sales_Visible_Flag__c = true;
        Assert.isNotNull(pr1);
        insert pr1;
        Product_MM_Attribute_Mapping__c pmam = new Product_MM_Attribute_Mapping__c();
        pmam.Ordering_Code__c = 'WX80660E52630V4';
        pmam.Name = '949344';
        pmam.L4_Product__c = pr.Id;
        pmam.Spec_Code__c = 'S';
        insert pmam;
        Product_MM_Attribute_Mapping__c pmam1 = new Product_MM_Attribute_Mapping__c();
        pmam1.Ordering_Code__c = 'WX80550E52630V4';
        pmam1.Name = '949348';
        pmam1.L5_Product__c = pr1.Id;
        pmam1.Spec_Code__c = 'S';
        insert pmam1;
        Core_Design_Registration__c ddrRec = new  Core_Design_Registration__c();
        ddrRec.Core_Product_Group_Nm__c = 'Embedded/IOT';
        ddrRec.Core_Vertical_Market_Nm__c='Education';
        ddrRec.Core_Military_Aerospace_Gvrnmt_Use_Ind__c = 'Yes';
        ddrRec.Core_Opportunity_Volume_Cnt__c=100;
        ddrRec.Core_Product_Segment_Nm__c='Client Computing';
        ddrRec.Core_Product_Application_Nm__c='Business Desktop';
        ddrRec.Core_Partner_FAE_Nm__c='Test FAE';
        ddrRec.Core_Partner_FSR_Nm__c='Test FSR';
        ddrRec.Core_End_Customer_Nm__c='Arrow Electronics Account';
        ddrRec.Core_End_Customer_Street_Addr_Line1_Txt__c='12 Street 99';
        ddrRec.Core_End_Customer_Street_Addr_Line2_Txt__c='jhdjnldk';
        ddrRec.PCC_End_Customer_Country__c='India';
        ddrRec.Core_End_Customer_City_Nm__c='Bangalore';
        ddrRec.Core_End_Customer_Country_Subdivision_Nm__c='Karnataka';
        ddrRec.Core_End_Customer_Postal_Cd__c='758854';
        ddrRec.Core_Manufacturing_Region_Cd__c='ASMO';
        ddrRec.Core_End_Customer_Contact_Title_Txt__c='Mr.';
        ddrRec.Core_End_Customer_Contact_Nm__c='Arrow Electronics Partner User 01';
        ddrRec.Core_End_Customer_Contact_Email_Txt__c='arrowelec.partneruser01@marketstar.com';
        ddrRec.Core_End_Customer_Contact_Phone_Txt__c='7826499722';
        ddrRec.Core_Opportunity_Decision_Dt__c = system.today().addDays(20);
        ddrRec.Core_First_Customer_Ship_Dt__c = system.today().addDays(21);
        ddrRec.Core_Production_End_Dt__c = system.today().addDays(22);
        ddrRec.Core_Intel_Platform_Nm__c='Arria';
        ddrRec.Core_Design_Registration_Nm__c='Test DR Name Arrow';
        ddrRec.Core_Design_Registration_Dsc__c='Test Des';
        ddrRec.Core_End_Customer_URL__c = 'Test';
		ddrRec.PCC_Industry__c = 'Agriculture';
			ddrRec.PCC_Sub_Industry__c = 'Forestry';
			ddrRec.PCC_Digital_Identifier__c='Website/URL';
			ddrRec.PCC_Digital_Identifier_Value__c='test';
           
        Assert.isNotNull(ddrRec);
        insert ddrRec;
        Test.startTest();
        Core_Design_Registration_Product__c DRproducts = new Core_Design_Registration_Product__c();
        // System.debug('here=='+TestDDRupdate_Rej[0].Core_Design_Registration_Status_Nm__c);
        DRproducts.Core_Design_Registration_Id__c = ddrRec.id;
        //DRproducts.MMID_or_Ordering_code__c = pmam.Id;
        DRproducts.Core_Target_Resale_Amt__c = 20;
        DRproducts.Core_Full_Year_Qty__c = 3;
        DRproducts.Core_Design_Product_Status_Nm__c = 'Cancelled';
        insert DRproducts;
        PCC_DDR_L5_Product_Mapping__c dlpm = new PCC_DDR_L5_Product_Mapping__c();
        dlpm.PCC_Design_Registration__c = ddrRec.id;dlpm.PCC_Design_Registration_Product__c = DRproducts.id;
        dlpm.PCC_Product_MM_Attribute_Mapping__c = pmam1.id;
        dlpm.PCC_MM_ID__c = pmam1.Name; dlpm.PCC_Ordering_Cd__c = pmam1.Ordering_Code__c;
        insert dlpm;
        //DRproducts.MMID_or_Ordering_code__c = pmam1.Id;
        Assert.isNotNull(DRproducts);
        update DRproducts;
        Test.stopTest();
        Map<String, String> mapOfDRPIdtoProduct = new Map<String, String>();
        mapOfDRPIdtoProduct.put(DRproducts.Id, DRproducts.Core_Product_Id__c);
        Map<String, Product_MM_Attribute_Mapping__c> mapOfProductToPM = new  Map<String, Product_MM_Attribute_Mapping__c>(); mapOfProductToPM.put(pmam1.L5_Product__c, pmam1);
    }
    
    
}