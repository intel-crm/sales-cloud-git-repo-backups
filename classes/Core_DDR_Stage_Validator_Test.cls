@isTest
public class Core_DDR_Stage_Validator_Test{
    
    static testmethod void testStageValidator1(){
        
        Test.startTest();
        
        List<account> LstAcc = Core_Test_Utility.createAccount(5);
        insert LstAcc;
        
        List<contact> LstCon = Core_Test_Utility.createContacts(5);
        for(contact con: LstCon)
        {
            con.accountid = LstAcc[0].id;
        }
        insert LstCon;
        
        Id p = [select id from profile where name='Partner'].id;  
        
        User userRecord = new User(
        Alias = 'StdUser', 
        Email = 'newuser@disti4.com', 
        EmailEncodingKey ='UTF-8',
        LastName = 'Testing', 
        LanguageLocaleKey = 'en_US',
        LocaleSidKey = 'en_US',
        TimeZoneSidKey = 'America/Los_Angeles', 
        UserName = 'newuser@disti4.com',
        isActive = true, profileid = P, ContactId = LstCon[0].id
        ); 
        
        insert userRecord;      
        
        
        List<Pricebook2> lstPriceBook = new List<Pricebook2>();  
        
        Pricebook2 pb1 = new Pricebook2();
        pb1.name = 'Standard Price Book';
        pb1.isActive = TRUE;
        
        lstPriceBook.add(pb1);
        
        Pricebook2 pb2 = new Pricebook2();
        pb2.name = 'Partner Price Book';
        pb2.isActive = TRUE;
        
        lstPriceBook.add(pb2); 
        
        insert lstPriceBook;  
        
        List<Product2> lstProduct = new List<Product2>();
        
        //Product1 price book entry update scenario
        Product2 product1 = new Product2();
        product1.Name = 'Intel Atom® CE4275 Media Processor';
        product1.IsActive = TRUE;
        product1.Core_Design_Registration_Eligible_Ind__c = TRUE;
        product1.Core_Sales_Visible_Flag__c = TRUE;
        product1.Core_Partner_Visible_Ind__c  = TRUE;
        lstProduct.add(product1);
        
        //Product2 price book entry create scenario
        Product2 product2 = new Product2();
        product2.Name = 'Intel® Core™ i3-4020M Processor (3M Cache, 2.60 GHz)';
        product2.IsActive = TRUE;
        product2.Core_Design_Registration_Eligible_Ind__c = TRUE;
        product2.Core_Sales_Visible_Flag__c = TRUE;
        product2.Core_Partner_Visible_Ind__c  = TRUE;
        lstProduct.add(product2);      
        
        insert lstProduct;
        
        List<PricebookEntry> lstPriceBookEntry = new List<PricebookEntry>();
        
        /*******Partner price book entry update scenario ********/
        PricebookEntry PriceBookEntry1 = new PricebookEntry();
        PriceBookEntry1.Pricebook2Id =  Test.getStandardPricebookId();
        PriceBookEntry1.Product2Id = lstProduct[0].id;
        PriceBookEntry1.IsActive = true;
        PriceBookEntry1.UnitPrice = 100;
        
        lstPriceBookEntry.add(PriceBookEntry1);
        
        PricebookEntry PriceBookEntry2 = new PricebookEntry();
        for(Pricebook2 iPB : lstPriceBook)
        {
            if(iPB.Name == 'Standard Price Book')
            {
                PriceBookEntry2.Pricebook2Id =  iPB.Id;
            }
        }
        PriceBookEntry2.Product2Id = lstProduct[0].id;
        PriceBookEntry2.IsActive = true;
        PriceBookEntry2.UnitPrice = 100;
        PriceBookEntry2.UseStandardPrice = true;    
        
        lstPriceBookEntry.add(PriceBookEntry2);
        
        PricebookEntry PriceBookEntry3 = new PricebookEntry();
        for(Pricebook2 iPB : lstPriceBook)
        {
            if(iPB.Name == 'Partner Price Book')
            {
                PriceBookEntry3.Pricebook2Id =  iPB.ID;
            }
        }
        PriceBookEntry3.Product2Id = lstProduct[0].id;
        PriceBookEntry3.IsActive = true;
        PriceBookEntry3.UnitPrice = 100;
        
        lstPriceBookEntry.add(PriceBookEntry3);      
        
        /*******Partner price book entry update scenario - Close ********/
        
        /*******Partner price book entry create scenario ********/
        
        PricebookEntry PriceBookEntry4 = new PricebookEntry();
        PriceBookEntry4.Pricebook2Id =  Test.getStandardPricebookId();
        PriceBookEntry4.Product2Id = lstProduct[1].id;
        PriceBookEntry4.IsActive = true;
        PriceBookEntry4.UnitPrice = 100;
        
        lstPriceBookEntry.add(PriceBookEntry4);         
        
        PricebookEntry PriceBookEntry5 = new PricebookEntry();
        for(Pricebook2 iPB : lstPriceBook)
        {
            if(iPB.Name == 'Standard Price Book')
            {
                PriceBookEntry5.Pricebook2Id =  iPB.Id;
            }
        }
        PriceBookEntry5.Product2Id = lstProduct[1].id;
        PriceBookEntry5.IsActive = true;
        PriceBookEntry5.UnitPrice = 100;
        PriceBookEntry5.UseStandardPrice = true;    
        
        lstPriceBookEntry.add(PriceBookEntry5);
        
        PricebookEntry PriceBookEntry6 = new PricebookEntry();
        for(Pricebook2 iPB : lstPriceBook)
        {
            if(iPB.Name == 'Partner Price Book')
            {
                PriceBookEntry6.Pricebook2Id =  iPB.Id;
            }
        }
        PriceBookEntry6.Product2Id = lstProduct[1].id;
        PriceBookEntry6.IsActive = true;
        PriceBookEntry6.UnitPrice = 100;
        PriceBookEntry6.UseStandardPrice = true;    
        
        lstPriceBookEntry.add(PriceBookEntry6);
        
        insert lstPriceBookEntry;
        
        List<Core_Design_Registrations_Bulk_Upload__c> DRBulkUploadList = new List<Core_Design_Registrations_Bulk_Upload__c>{
            new Core_Design_Registrations_Bulk_Upload__c(name = 'Cancelled (Y)', Core_Active_Ind__c = true, Core_Design_API_Field_Nm__c = 'Core_Design_Product_Status_Nm__c', Core_CSV_Column_Nm__c= 'Cancelled (Y)', Core_Stage_API_Field_Nm__c= 'Core_Cancelled_Ind__c', Core_Field_Data_Type_Txt__c= 'Boolean', Core_Header_Or_Product_Ind__c= 'Product'),
            new Core_Design_Registrations_Bulk_Upload__c(name = 'Decision Date', Core_Active_Ind__c = true, Core_Design_API_Field_Nm__c = 'Core_Opportunity_Decision_Dt__c', Core_CSV_Column_Nm__c= 'Decision Date', Core_Stage_API_Field_Nm__c= 'Core_Opportunity_Decision_Dt__c', Core_Field_Data_Type_Txt__c= 'Date', Core_Header_Or_Product_Ind__c= 'Header', Core_Design_Required_Ind__c= true),
            new Core_Design_Registrations_Bulk_Upload__c(name = 'Group ID', Core_Active_Ind__c = true, Core_Design_API_Field_Nm__c = 'Core_Group_ID__c', Core_CSV_Column_Nm__c= 'Group ID', Core_Stage_API_Field_Nm__c= 'Core_Group_ID__c', Core_Stage_Required_Ind__c= true),
            new Core_Design_Registrations_Bulk_Upload__c(name = 'Header/ Product', Core_Active_Ind__c = true, Core_Design_API_Field_Nm__c = 'Core_Header_Or_Product_Ind__c', Core_CSV_Column_Nm__c= 'Header/ Product', Core_Stage_API_Field_Nm__c= 'Core_Header_Or_Product_Ind__c', Core_Stage_Required_Ind__c= true),
            new Core_Design_Registrations_Bulk_Upload__c(name = 'Design Registration Line ID', Core_Active_Ind__c = true, Core_Design_API_Field_Nm__c = 'Core_Design_Registration_Line_ID__c', Core_CSV_Column_Nm__c= 'Design Registration Line ID', Core_Stage_API_Field_Nm__c= 'Core_Design_Registration_Line_ID__c', Core_Field_Data_Type_Txt__c= 'Text', Core_Header_Or_Product_Ind__c= 'Product'),
            new Core_Design_Registrations_Bulk_Upload__c(name = 'Partner Tracking Number', Core_Active_Ind__c = true, Core_Design_API_Field_Nm__c = 'Core_Partner_Tracking_Cd__c', Core_CSV_Column_Nm__c= 'Partner Tracking Number', Core_Stage_API_Field_Nm__c= 'Core_Partner_Tracking_Cd__c', Core_Field_Data_Type_Txt__c= 'Text', Core_Header_Or_Product_Ind__c= 'Product'),
            new Core_Design_Registrations_Bulk_Upload__c(name = 'Registration Number', Core_Active_Ind__c = true, Core_Design_API_Field_Nm__c = 'Core_Registration_Number_Id__c', Core_CSV_Column_Nm__c= 'Registration Number', Core_Stage_API_Field_Nm__c= 'Core_Registration_Number_Id__c', Core_Field_Data_Type_Txt__c= 'Text', Core_Header_Or_Product_Ind__c= 'Header'),
            new Core_Design_Registrations_Bulk_Upload__c(name = 'Owner (email)', Core_Active_Ind__c = true, Core_Design_API_Field_Nm__c = 'OwnerId', Core_CSV_Column_Nm__c= 'Owner (email)', Core_Stage_API_Field_Nm__c= 'Core_Owner_Txt__c', Core_Field_Data_Type_Txt__c= 'ID', Core_Header_Or_Product_Ind__c= 'Header'),
            new Core_Design_Registrations_Bulk_Upload__c(name = 'End Customer Address2', Core_Active_Ind__c = true, Core_Design_API_Field_Nm__c = 'Core_End_Customer_Street_Addr_Line2_Txt__c', Core_CSV_Column_Nm__c= 'End Customer Address2', Core_Stage_API_Field_Nm__c= 'Core_End_Customer_Street_Addr_Line2_Txt__c', Core_Field_Data_Type_Txt__c= 'Text', Core_Header_Or_Product_Ind__c= 'Header'),
            new Core_Design_Registrations_Bulk_Upload__c(name = 'Manufacturing Region', Core_Active_Ind__c = true, Core_Design_API_Field_Nm__c = 'Core_Manufacturing_Region_Cd__c', Core_CSV_Column_Nm__c= 'Manufacturing Region', Core_Stage_API_Field_Nm__c= 'Core_Manufacturing_Region_Cd__c', Core_Field_Data_Type_Txt__c= 'Text', Core_Header_Or_Product_Ind__c= 'Header'),
            new Core_Design_Registrations_Bulk_Upload__c(name = 'Design Staging ID', Core_Active_Ind__c = true, Core_Design_API_Field_Nm__c = 'Core_Design_Registration_Stage_Id__c ', Core_Stage_API_Field_Nm__c= 'ID', Core_Field_Data_Type_Txt__c= 'Text', Core_Header_Or_Product_Ind__c= 'Header'),
            new Core_Design_Registrations_Bulk_Upload__c(name = 'Design Solution Network', Core_Active_Ind__c = true, Core_Design_API_Field_Nm__c = 'Core_Design_Solution_Network_Ind__c', Core_CSV_Column_Nm__c= 'Design Solution Network', Core_Stage_API_Field_Nm__c= 'Core_Design_Solution_Network_Ind__c', Core_Field_Data_Type_Txt__c= 'Checkbox', Core_Header_Or_Product_Ind__c= 'Header'),
            new Core_Design_Registrations_Bulk_Upload__c(name = 'Product', Core_CSV_Column_Nm__c= 'Product', Core_Active_Ind__c = true, Core_Design_API_Field_Nm__c = 'Core_Product_Id__c', Core_Stage_API_Field_Nm__c= 'Core_Product_Id__c', Core_Field_Data_Type_Txt__c= 'Lookup', Core_Header_Or_Product_Ind__c= 'Product', Core_Design_Required_Ind__c= true),
            new Core_Design_Registrations_Bulk_Upload__c(name = 'Target Resale Price', Core_CSV_Column_Nm__c= 'Target Resale Price', Core_Active_Ind__c = true, Core_Design_API_Field_Nm__c = 'Core_Target_Resale_Amt__c', Core_Stage_API_Field_Nm__c= 'Core_Target_Resale_Amt__c', Core_Field_Data_Type_Txt__c= 'Number', Core_Header_Or_Product_Ind__c= 'Product', Core_Design_Required_Ind__c= true),
            new Core_Design_Registrations_Bulk_Upload__c(name = 'Quantity (Full Production Year)', Core_CSV_Column_Nm__c= 'Quantity (Full Production Year)', Core_Active_Ind__c = true, Core_Design_API_Field_Nm__c = 'Core_Full_Year_Qty__c', Core_Stage_API_Field_Nm__c= 'Core_Full_Year_Qty__c', Core_Field_Data_Type_Txt__c= 'Number', Core_Header_Or_Product_Ind__c= 'Product', Core_Design_Required_Ind__c= true),
            new Core_Design_Registrations_Bulk_Upload__c(name = 'Military Aerospace Gov\'t End Use?', Core_CSV_Column_Nm__c= 'Military - Aerospace - Gov\'t End Use?', Core_Active_Ind__c = true, Core_Design_API_Field_Nm__c = 'Core_Military_Aerospace_Gvrnmt_Use_Ind__c', Core_Stage_API_Field_Nm__c= 'Core_Military_Aerospace_Gvrnmt_Use_Ind__c', Core_Field_Data_Type_Txt__c= 'Text', Core_Header_Or_Product_Ind__c= 'Header', Core_Design_Required_Ind__c= true),
            new Core_Design_Registrations_Bulk_Upload__c(name = 'Product Application', Core_CSV_Column_Nm__c= 'Product Application', Core_Active_Ind__c = true, Core_Design_API_Field_Nm__c = 'Core_Product_Application_Nm__c', Core_Stage_API_Field_Nm__c= 'Core_Product_Application_Nm__c', Core_Field_Data_Type_Txt__c= 'Text', Core_Header_Or_Product_Ind__c= 'Header', Core_Design_Required_Ind__c= true),
            new Core_Design_Registrations_Bulk_Upload__c(name = 'Product Segment', Core_CSV_Column_Nm__c= 'Product Segment', Core_Active_Ind__c = true, Core_Design_API_Field_Nm__c = 'Core_Product_Segment_Nm__c', Core_Stage_API_Field_Nm__c= 'Core_Product_Segment_Nm__c', Core_Field_Data_Type_Txt__c= 'Text', Core_Header_Or_Product_Ind__c= 'Header', Core_Design_Required_Ind__c= true),
            new Core_Design_Registrations_Bulk_Upload__c(name = 'Intel Platform', Core_CSV_Column_Nm__c= 'Intel Platform', Core_Active_Ind__c = true, Core_Design_API_Field_Nm__c = 'Core_Intel_Platform_Nm__c', Core_Stage_API_Field_Nm__c= 'Core_Intel_Platform_Nm__c', Core_Field_Data_Type_Txt__c= 'Picklist', Core_Header_Or_Product_Ind__c= 'Header', Core_Design_Required_Ind__c= true),
            new Core_Design_Registrations_Bulk_Upload__c(name = 'Vertical Market', Core_CSV_Column_Nm__c= 'Vertical Market', Core_Active_Ind__c = true, Core_Design_API_Field_Nm__c = 'Core_Vertical_Market_Nm__c', Core_Stage_API_Field_Nm__c= 'Core_Vertical_Market_Nm__c', Core_Field_Data_Type_Txt__c= 'Text', Core_Header_Or_Product_Ind__c= 'Header', Core_Design_Required_Ind__c= true),
            new Core_Design_Registrations_Bulk_Upload__c(name = 'Production End Date', Core_CSV_Column_Nm__c= 'Production End Date', Core_Active_Ind__c = true, Core_Design_API_Field_Nm__c = 'Core_Production_End_Dt__c', Core_Stage_API_Field_Nm__c= 'Core_Production_End_Dt__c', Core_Field_Data_Type_Txt__c= 'Date', Core_Header_Or_Product_Ind__c= 'Header', Core_Design_Required_Ind__c= true),
            new Core_Design_Registrations_Bulk_Upload__c(name = 'First Customer Ship Date', Core_CSV_Column_Nm__c= 'First Customer Ship Date', Core_Active_Ind__c = true, Core_Design_API_Field_Nm__c = 'Core_First_Customer_Ship_Dt__c', Core_Stage_API_Field_Nm__c= 'Core_First_Customer_Ship_Dt__c', Core_Field_Data_Type_Txt__c= 'Date', Core_Header_Or_Product_Ind__c= 'Header', Core_Design_Required_Ind__c= true),
            new Core_Design_Registrations_Bulk_Upload__c(name = 'End Customer Country', Core_CSV_Column_Nm__c= 'End Customer Country', Core_Active_Ind__c = true, Core_Design_API_Field_Nm__c = 'Core_End_Customer_Country_Nm__c', Core_Stage_API_Field_Nm__c= 'Core_End_Customer_Country_Nm__c', Core_Field_Data_Type_Txt__c= 'Text', Core_Header_Or_Product_Ind__c= 'Header', Core_Design_Required_Ind__c= true),
            new Core_Design_Registrations_Bulk_Upload__c(name = 'End Customer Zip/ Postal Code', Core_CSV_Column_Nm__c= 'End Customer Zip/ Postal Code', Core_Active_Ind__c = true, Core_Design_API_Field_Nm__c = 'Core_End_Customer_Postal_Cd__c', Core_Stage_API_Field_Nm__c= 'Core_End_Customer_Postal_Cd__c', Core_Field_Data_Type_Txt__c= 'Text', Core_Header_Or_Product_Ind__c= 'Header', Core_Design_Required_Ind__c= true),
            new Core_Design_Registrations_Bulk_Upload__c(name = 'End Customer State', Core_CSV_Column_Nm__c= 'End Customer State', Core_Active_Ind__c = true, Core_Design_API_Field_Nm__c = 'Core_End_Customer_Country_Subdivision_Nm__c', Core_Stage_API_Field_Nm__c= 'Core_End_Customer_Country_Subdivision_Nm__c', Core_Field_Data_Type_Txt__c= 'Text', Core_Header_Or_Product_Ind__c= 'Header', Core_Design_Required_Ind__c= true),
            new Core_Design_Registrations_Bulk_Upload__c(name = 'End Customer City', Core_CSV_Column_Nm__c= 'End Customer City', Core_Active_Ind__c = true, Core_Design_API_Field_Nm__c = 'Core_End_Customer_City_Nm__c', Core_Stage_API_Field_Nm__c= 'Core_End_Customer_City_Nm__c', Core_Field_Data_Type_Txt__c= 'Text', Core_Header_Or_Product_Ind__c= 'Header', Core_Design_Required_Ind__c= true),
            new Core_Design_Registrations_Bulk_Upload__c(name = 'End Customer Address1', Core_CSV_Column_Nm__c= 'End Customer Address1', Core_Active_Ind__c = true, Core_Design_API_Field_Nm__c = 'Core_End_Customer_Street_Addr_Line1_Txt__c', Core_Stage_API_Field_Nm__c= 'Core_End_Customer_Street_Addr_Line1_Txt__c', Core_Field_Data_Type_Txt__c= 'Text', Core_Header_Or_Product_Ind__c= 'Header', Core_Design_Required_Ind__c= true),
            new Core_Design_Registrations_Bulk_Upload__c(name = 'End Customer Name', Core_CSV_Column_Nm__c= 'End Customer Name', Core_Active_Ind__c = true, Core_Design_API_Field_Nm__c = 'Core_End_Customer_Nm__c', Core_Stage_API_Field_Nm__c= 'Core_End_Customer_Nm__c', Core_Field_Data_Type_Txt__c= 'Text', Core_Header_Or_Product_Ind__c= 'Header', Core_Design_Required_Ind__c= true),
            new Core_Design_Registrations_Bulk_Upload__c(name = 'Partner FAE', Core_CSV_Column_Nm__c= 'Partner FAE', Core_Active_Ind__c = true, Core_Design_API_Field_Nm__c = 'Core_Partner_FAE_Nm__c', Core_Stage_API_Field_Nm__c= 'Core_Partner_FAE_Nm__c', Core_Field_Data_Type_Txt__c= 'Text', Core_Header_Or_Product_Ind__c= 'Header', Core_Design_Required_Ind__c= true),
            new Core_Design_Registrations_Bulk_Upload__c(name = 'Opportunity Volume', Core_CSV_Column_Nm__c= 'Opportunity Volume', Core_Active_Ind__c = true, Core_Design_API_Field_Nm__c = 'Core_Opportunity_Volume_Cnt__c', Core_Stage_API_Field_Nm__c= 'Core_Opportunity_Volume_Cnt__c', Core_Field_Data_Type_Txt__c= 'Number', Core_Header_Or_Product_Ind__c= 'Header', Core_Design_Required_Ind__c= true),
            new Core_Design_Registrations_Bulk_Upload__c(name = 'Description', Core_CSV_Column_Nm__c= 'Description', Core_Active_Ind__c = true, Core_Design_API_Field_Nm__c = 'Core_Design_Registration_Dsc__c', Core_Stage_API_Field_Nm__c= 'Core_Design_Registration_Dsc__c', Core_Field_Data_Type_Txt__c= 'Text', Core_Header_Or_Product_Ind__c= 'Header', Core_Design_Required_Ind__c= true),
            new Core_Design_Registrations_Bulk_Upload__c(name = 'Design Registration Name', Core_CSV_Column_Nm__c= 'Design Registration Name', Core_Active_Ind__c = true, Core_Design_API_Field_Nm__c = 'Core_Design_Registration_Nm__c', Core_Stage_API_Field_Nm__c= 'Core_Design_Registration_Nm__c', Core_Field_Data_Type_Txt__c= 'Text', Core_Header_Or_Product_Ind__c= 'Header', Core_Design_Required_Ind__c= true),
            new Core_Design_Registrations_Bulk_Upload__c(name = 'Product Group', Core_CSV_Column_Nm__c= 'Product Group', Core_Active_Ind__c = true, Core_Design_API_Field_Nm__c = 'Core_Product_Group_Nm__c', Core_Stage_API_Field_Nm__c= 'Core_Product_Group_Nm__c', Core_Field_Data_Type_Txt__c= 'Text', Core_Header_Or_Product_Ind__c= 'Header', Core_Design_Required_Ind__c= true),
            new Core_Design_Registrations_Bulk_Upload__c(name = 'xyz')
        };
        insert DRBulkUploadList;
        
        List<Core_LogEntry_Switch__c> LogEntryLst = new List<Core_LogEntry_Switch__c>{new Core_LogEntry_Switch__c(name = 'Core_DDR_LogEntry_Check', Is_Selected__c = true)};
        insert LogEntryLst;
        
        system.runAs(userRecord)
        {
            Core_Design_Registration_Batch__c desRegBatch = new Core_Design_Registration_Batch__c(Core_File_Nm__c = 'BatchFileName', Core_Partner_Account_Id__c = lstAcc[0].Id);
            insert desRegBatch;
            
            
            List<Core_Design_Registration_Stage__c> designRegStage = new List<Core_Design_Registration_Stage__c>{ 
                new Core_Design_Registration_Stage__c(Core_Batch_ID__c = desRegBatch.id, Core_Group_Id__c = '1', Core_Header_Or_Product_Ind__c = 'Header', Core_Registration_Number_Id__c = '', Core_Owner_Txt__c = 'newuser@disti4.com', Core_Product_Group_Nm__c = 'Embedded/IOT', Core_Design_Registration_Nm__c = 'Test Project 1', Core_Design_Registration_Dsc__c = 'For demo Insert Scenario', Core_Opportunity_Volume_Cnt__c = '5', Core_Partner_FAE_Nm__c = 'Test FAE 1', Core_End_Customer_Nm__c = 'Test Customer 1', Core_End_Customer_Street_Addr_Line1_Txt__c = 'Millbare', Core_End_Customer_Street_Addr_Line2_Txt__c = 'Trichy2', Core_End_Customer_City_Nm__c = 'San Francisco', Core_End_Customer_Country_Subdivision_Nm__c = 'California', Core_End_Customer_Postal_Cd__c = '54321', Core_End_Customer_Country_Nm__c = 'USA', Core_Military_Aerospace_Gvrnmt_Use_Ind__c = 'Yes', Core_Opportunity_Decision_Dt__c = system.today().addDays(20).format(), Core_First_Customer_Ship_Dt__c = system.today().addDays(20).format(), Core_Production_End_Dt__c = system.today().addDays(20).format(), Core_Vertical_Market_Nm__c = 'Sports', Core_Intel_Platform_Nm__c = 'Broadwell', Core_Product_Segment_Nm__c = 'Client Computing', Core_Product_Application_Nm__c = 'Desktop', Core_Manufacturing_Region_Cd__c = 'APJ', Core_Design_Solution_Network_Ind__c = 'Yes'),
                new Core_Design_Registration_Stage__c(Core_Batch_ID__c = desRegBatch.id, Core_Group_Id__c = '3', Core_Header_Or_Product_Ind__c = 'Header', Core_Registration_Number_Id__c = '', Core_Owner_Txt__c = 'newuser@disti4.com', Core_Product_Group_Nm__c = 'Embedded/IOT', Core_Design_Registration_Nm__c = 'Test Project 1',  Core_Design_Registration_Dsc__c = 'For demo Insert Scenario',  Core_Opportunity_Volume_Cnt__c = '5', Core_Partner_FAE_Nm__c = 'Test FAE 1', Core_End_Customer_Nm__c = 'Test Customer 1', Core_End_Customer_Street_Addr_Line1_Txt__c = 'Millbare', Core_End_Customer_Street_Addr_Line2_Txt__c = 'Trichy2', Core_End_Customer_City_Nm__c = 'San Francisco', Core_End_Customer_Country_Subdivision_Nm__c = 'California', Core_End_Customer_Postal_Cd__c = '54321', Core_End_Customer_Country_Nm__c = 'USA', Core_Military_Aerospace_Gvrnmt_Use_Ind__c = 'Yes',  Core_Opportunity_Decision_Dt__c = system.today().addDays(20).format(), Core_First_Customer_Ship_Dt__c = system.today().addDays(20).format(), Core_Production_End_Dt__c = system.today().addDays(20).format(), Core_Vertical_Market_Nm__c = 'Sports', Core_Intel_Platform_Nm__c = 'Broadwell', Core_Product_Segment_Nm__c = 'Client Computing', Core_Product_Application_Nm__c = 'Desktop', Core_Manufacturing_Region_Cd__c = 'APJ', Core_Design_Solution_Network_Ind__c = 'Yes'),
                new Core_Design_Registration_Stage__c(Core_Batch_ID__c = desRegBatch.id, Core_Group_Id__c = '4', Core_Header_Or_Product_Ind__c = 'Header', Core_Registration_Number_Id__c = '', Core_Owner_Txt__c = 'newuser@disti4.com', Core_Product_Group_Nm__c = 'Embedded/IOT', Core_Design_Registration_Nm__c = 'Test Project 1',  Core_Design_Registration_Dsc__c = 'For demo Insert Scenario',  Core_Opportunity_Volume_Cnt__c = 'test', Core_Partner_FAE_Nm__c = 'Test FAE 1', Core_End_Customer_Nm__c = 'Test Customer 1', Core_End_Customer_Street_Addr_Line1_Txt__c = 'Millbare', Core_End_Customer_Street_Addr_Line2_Txt__c = 'Trichy2', Core_End_Customer_City_Nm__c = 'San Francisco', Core_End_Customer_Country_Subdivision_Nm__c = 'California', Core_End_Customer_Postal_Cd__c = '54321', Core_End_Customer_Country_Nm__c = 'USA', Core_Military_Aerospace_Gvrnmt_Use_Ind__c = 'Yes',  Core_Opportunity_Decision_Dt__c = '', Core_First_Customer_Ship_Dt__c = system.today().addDays(20).format(), Core_Production_End_Dt__c = system.today().addDays(20).format(), Core_Vertical_Market_Nm__c = 'Sports', Core_Intel_Platform_Nm__c = 'Broadwell', Core_Product_Segment_Nm__c = '', Core_Product_Application_Nm__c = 'Desktop', Core_Manufacturing_Region_Cd__c = 'APJ', Core_Design_Solution_Network_Ind__c = 'Yes'),
                new Core_Design_Registration_Stage__c(Core_Batch_ID__c = desRegBatch.id, Core_Group_Id__c = '6', Core_Header_Or_Product_Ind__c = 'Header', Core_Registration_Number_Id__c = '', Core_Owner_Txt__c = 'newuser@disti4.com', Core_Product_Group_Nm__c = 'Test', Core_Design_Registration_Nm__c = 'Test Project 1',  Core_Design_Registration_Dsc__c = 'For demo Insert Scenario',  Core_Opportunity_Volume_Cnt__c = '5', Core_Partner_FAE_Nm__c = 'Test FAE 1', Core_End_Customer_Nm__c = 'Test Customer 1', Core_End_Customer_Street_Addr_Line1_Txt__c = 'Millbare', Core_End_Customer_Street_Addr_Line2_Txt__c = 'Trichy2', Core_End_Customer_City_Nm__c = 'San Francisco', Core_End_Customer_Country_Subdivision_Nm__c = 'California', Core_End_Customer_Postal_Cd__c = '54321', Core_End_Customer_Country_Nm__c = 'USA', Core_Military_Aerospace_Gvrnmt_Use_Ind__c = 'Yes',  Core_Opportunity_Decision_Dt__c = system.today().addDays(20).format(), Core_First_Customer_Ship_Dt__c = system.today().addDays(20).format(), Core_Production_End_Dt__c = system.today().addDays(20).format(), Core_Vertical_Market_Nm__c = 'Sports', Core_Intel_Platform_Nm__c = 'Broadwell', Core_Product_Segment_Nm__c = 'Client Computing', Core_Product_Application_Nm__c = 'Desktop', Core_Manufacturing_Region_Cd__c = 'APJ', Core_Design_Solution_Network_Ind__c = 'Yes'),
                new Core_Design_Registration_Stage__c(Core_Batch_ID__c = desRegBatch.id, Core_Group_Id__c = '10', Core_Header_Or_Product_Ind__c = 'Header', Core_Registration_Number_Id__c = '', Core_Owner_Txt__c = 'newuser@disti4.com', Core_Product_Group_Nm__c = 'Embedded/IOT', Core_Design_Registration_Nm__c = 'Test Project 1',  Core_Design_Registration_Dsc__c = 'For demo Insert Scenario',  Core_Opportunity_Volume_Cnt__c = '5', Core_Partner_FAE_Nm__c = 'Test FAE 1', Core_End_Customer_Nm__c = 'Test Customer 1', Core_End_Customer_Street_Addr_Line1_Txt__c = 'Millbare', Core_End_Customer_Street_Addr_Line2_Txt__c = 'Trichy2', Core_End_Customer_City_Nm__c = 'San Francisco', Core_End_Customer_Country_Subdivision_Nm__c = 'California', Core_End_Customer_Postal_Cd__c = '54321', Core_End_Customer_Country_Nm__c = 'USA', Core_Military_Aerospace_Gvrnmt_Use_Ind__c = 'Yes',  Core_Opportunity_Decision_Dt__c = system.today().addDays(20).format(), Core_First_Customer_Ship_Dt__c = system.today().addDays(20).format(), Core_Production_End_Dt__c = system.today().addDays(20).format(), Core_Vertical_Market_Nm__c = 'Sports', Core_Intel_Platform_Nm__c = 'Broadwell', Core_Product_Segment_Nm__c = 'Client Computing', Core_Product_Application_Nm__c = 'Desktop', Core_Manufacturing_Region_Cd__c = 'APJ', Core_Design_Solution_Network_Ind__c = 'Yes'),
                new Core_Design_Registration_Stage__c(Core_Batch_ID__c = desRegBatch.id, Core_Group_Id__c = '13', Core_Header_Or_Product_Ind__c = 'Header', Core_Registration_Number_Id__c = '', Core_Owner_Txt__c = 'newuser@disti4.com', Core_Product_Group_Nm__c = 'Embedded/IOT', Core_Design_Registration_Nm__c = 'Test Project 1',  Core_Design_Registration_Dsc__c = 'For demo Insert Scenario',  Core_Opportunity_Volume_Cnt__c = '6', Core_Partner_FAE_Nm__c = 'Test FAE 1', Core_End_Customer_Nm__c = 'Test Customer 1', Core_End_Customer_Street_Addr_Line1_Txt__c = 'Millbare', Core_End_Customer_Street_Addr_Line2_Txt__c = 'Trichy2', Core_End_Customer_City_Nm__c = 'San Francisco', Core_End_Customer_Country_Subdivision_Nm__c = 'California', Core_End_Customer_Postal_Cd__c = '54321', Core_End_Customer_Country_Nm__c = 'USA', Core_Military_Aerospace_Gvrnmt_Use_Ind__c = 'Yes',  Core_Opportunity_Decision_Dt__c = system.today().addDays(20).format(), Core_First_Customer_Ship_Dt__c = system.today().addDays(20).format(), Core_Production_End_Dt__c = system.today().addDays(20).format(), Core_Vertical_Market_Nm__c = 'Sports', Core_Intel_Platform_Nm__c = 'Broadwell', Core_Product_Segment_Nm__c = 'Client Computing', Core_Product_Application_Nm__c = 'Desktop', Core_Manufacturing_Region_Cd__c = 'APJ', Core_Design_Solution_Network_Ind__c = 'Yes'),
                //old data
                new Core_Design_Registration_Stage__c(Core_Batch_ID__c = desRegBatch.id, Core_Group_Id__c = '1', Core_Design_Registration_Line_Id__c = '', Core_Header_Or_Product_Ind__c = 'Product', Core_Target_Resale_Amt__c = '5', Core_Full_Year_Qty__c = '6'),
                new Core_Design_Registration_Stage__c(Core_Batch_ID__c = desRegBatch.id, Core_Group_Id__c = '1', Core_Design_Registration_Line_Id__c = '', Core_Header_Or_Product_Ind__c = 'Product', Core_Target_Resale_Amt__c = 't', Core_Full_Year_Qty__c = 't'),
                new Core_Design_Registration_Stage__c(Core_Batch_ID__c = desRegBatch.id, Core_Group_Id__c = '1', Core_Design_Registration_Line_Id__c = '', Core_Header_Or_Product_Ind__c = 'Header', Core_Owner_Txt__c = 'newuser@disti4.com', Core_Opportunity_Decision_Dt__c = '', Core_First_Customer_Ship_Dt__c = system.today().addDays(20).format(), Core_Production_End_Dt__c = system.today().addDays(20).format()),
                new Core_Design_Registration_Stage__c(Core_Batch_ID__c = desRegBatch.id, Core_Group_Id__c = '2', Core_Design_Registration_Line_Id__c = '', Core_Header_Or_Product_Ind__c = 'Product', Core_Target_Resale_Amt__c = '', Core_Full_Year_Qty__c = ''),
                new Core_Design_Registration_Stage__c(Core_Batch_ID__c = desRegBatch.id, Core_Group_Id__c = '2', Core_Design_Registration_Line_Id__c = '', Core_Header_Or_Product_Ind__c = 'Header', Core_Owner_Txt__c = 'newuser@disti4.com', Core_Registration_Number_Id__c = '', Core_Opportunity_Volume_Cnt__c = '', Core_Opportunity_Decision_Dt__c = system.today().addDays(20).format(), Core_First_Customer_Ship_Dt__c = system.today().addDays(20).format(), Core_Production_End_Dt__c = system.today().addDays(20).format())
            };
            
            
            
            insert designRegStage;
            
            
            Core_DDR_Stage_Validator ProDesRegSta = new Core_DDR_Stage_Validator();
            ProDesRegSta.checkValidations(designRegStage);
            
            List<Core_Design_Registration_Stage__c> designRegStage2 = new List<Core_Design_Registration_Stage__c>{
                new Core_Design_Registration_Stage__c(Core_Batch_ID__c = desRegBatch.id, Core_Group_Id__c = '1', Core_Header_Or_Product_Ind__c = 'Header', Core_Owner_Txt__c = 'newuser@disti4.com', Core_Product_Group_Nm__c = 'Embedded/IOT', Core_Design_Registration_Nm__c = 'Test Project 1', Core_Design_Registration_Dsc__c = 'For demo Insert Scenario', Core_Opportunity_Volume_Cnt__c = '5', Core_Registration_Number_Id__c = '', Core_Partner_FAE_Nm__c = 'Test FAE 1', Core_End_Customer_Nm__c = 'Test Customer 1', Core_End_Customer_Street_Addr_Line1_Txt__c = 'Millbare', Core_End_Customer_Street_Addr_Line2_Txt__c = 'Trichy2', Core_End_Customer_City_Nm__c = 'San Francisco', Core_End_Customer_Country_Subdivision_Nm__c = 'California', Core_End_Customer_Postal_Cd__c = '54321', Core_End_Customer_Country_Nm__c = 'USA', Core_Military_Aerospace_Gvrnmt_Use_Ind__c = 'Yes', Core_Opportunity_Decision_Dt__c = system.today().addDays(20).format(), Core_First_Customer_Ship_Dt__c = system.today().addDays(20).format(), Core_Production_End_Dt__c = system.today().addDays(20).format(), Core_Vertical_Market_Nm__c = 'Sports', Core_Intel_Platform_Nm__c = 'Broadwell', Core_Product_Segment_Nm__c = 'Client Computing', Core_Product_Application_Nm__c = 'Desktop', Core_Manufacturing_Region_Cd__c = 'APJ', Core_Design_Solution_Network_Ind__c = 'Yes'),
                new Core_Design_Registration_Stage__c(Core_Batch_ID__c = desRegBatch.id, Core_Product_Id__c = 'Intel Atom® CE4275 Media Processor', Core_Group_Id__c = '1', Core_Design_Registration_Line_Id__c = '', Core_Header_Or_Product_Ind__c = 'Product', Core_Target_Resale_Amt__c = '5', Core_Full_Year_Qty__c = '6', Core_Owner_Txt__c = 'disti4_user1@disti4.com',  Core_Opportunity_Volume_Cnt__c = ''),
                
                //Record without header
                new Core_Design_Registration_Stage__c(Core_Batch_ID__c = desRegBatch.id, Core_Group_Id__c = '2', Core_Design_Registration_Line_Id__c = '', Core_Header_Or_Product_Ind__c = 'Product', Core_Target_Resale_Amt__c = '5', Core_Full_Year_Qty__c = '6', Core_Owner_Txt__c = '', Core_Registration_Number_Id__c = '', Core_Opportunity_Volume_Cnt__c = ''),
                
                //Invalid picklist value
                new Core_Design_Registration_Stage__c(Core_Batch_ID__c = desRegBatch.id, Core_Group_Id__c = '3', Core_Header_Or_Product_Ind__c = 'Header', Core_Owner_Txt__c = 'newuser@disti4.com', Core_Product_Group_Nm__c = 'Embedded/IOT', Core_Design_Registration_Nm__c = 'Test Project 1', Core_Design_Registration_Dsc__c = 'For demo Insert Scenario', Core_Opportunity_Volume_Cnt__c = '5', Core_Partner_FAE_Nm__c = 'Test FAE 1', Core_End_Customer_Nm__c = 'Test Customer 1', Core_End_Customer_Street_Addr_Line1_Txt__c = 'Millbare', Core_End_Customer_Street_Addr_Line2_Txt__c = 'Trichy2', Core_End_Customer_City_Nm__c = 'San Francisco', Core_End_Customer_Country_Subdivision_Nm__c = 'California', Core_End_Customer_Postal_Cd__c = '54321', Core_End_Customer_Country_Nm__c = 'USA', Core_Military_Aerospace_Gvrnmt_Use_Ind__c = 'Yes', Core_Opportunity_Decision_Dt__c = system.today().addDays(20).format(), Core_First_Customer_Ship_Dt__c = system.today().addDays(20).format(), Core_Production_End_Dt__c = system.today().addDays(20).format(), Core_Vertical_Market_Nm__c = 'Sports', Core_Intel_Platform_Nm__c = 'Broadwell', Core_Product_Segment_Nm__c = 'Client Computing', Core_Product_Application_Nm__c = 'Desktop', Core_Manufacturing_Region_Cd__c = 'Test', Core_Design_Solution_Network_Ind__c = 'Yes'),
                new Core_Design_Registration_Stage__c(Core_Batch_ID__c = desRegBatch.id, Core_Product_Id__c = 'Intel Atom® CE4275 Media Proces', Core_Group_Id__c = '3', Core_Design_Registration_Line_Id__c = '', Core_Header_Or_Product_Ind__c = 'Product', Core_Target_Resale_Amt__c = '5', Core_Full_Year_Qty__c = '6', Core_Owner_Txt__c = 'disti4_user1@disti4.com', Core_Registration_Number_Id__c = '', Core_Opportunity_Volume_Cnt__c = '')
                
            };
            
            for(Core_Design_Registration_Stage__c iMDRStage : designRegStage)
            {
                for(Core_Design_Registration_Stage__c iMDRStageNew : designRegStage2)
                {
                    if(iMDRStage.Core_Header_Or_Product_Ind__c == 'Header' && iMDRStageNew.Core_Header_Or_Product_Ind__c == 'Header')
                    {
                        iMDRStageNew.Core_Registration_Number_Id__c = iMDRStage.Name;
                    }
                    else if(iMDRStage.Core_Header_Or_Product_Ind__c == 'Product' && iMDRStageNew.Core_Header_Or_Product_Ind__c == 'Product')
                    {
                        iMDRStageNew.Core_Design_Registration_Line_Id__c = iMDRStage.Name;
                    }
                } 
            }
            
            insert designRegStage2;
            
            Core_DDR_Stage_Validator ProDesRegSta2 = new Core_DDR_Stage_Validator();
            ProDesRegSta2.checkValidations(designRegStage2);
        }
        
        //system.runAs(userRecord)
        // { 
        
        Core_Design_Registration_Batch__c desRegBatch7430 = new Core_Design_Registration_Batch__c(Core_File_Nm__c = 'BatchFileName', Core_Partner_Account_Id__c = lstAcc[0].Id);
        insert desRegBatch7430;                   
        //Header
        List<Core_Design_Registration_Stage__c> designRegStage7430 = new List<Core_Design_Registration_Stage__c>{
            new Core_Design_Registration_Stage__c(Core_Batch_ID__c = desRegBatch7430.Id, Core_Group_Id__c = '1', 
            Core_Header_Or_Product_Ind__c = 'Header', Core_Design_Registration_Line_Id__c = '', 
            Core_Partner_Tracking_Cd__c = '', Core_Product_Id__c = '', Core_Full_Year_Qty__c = '6',Core_Target_Resale_Amt__c = '', 
            Core_Cancelled_Ind__c = '', Core_Registration_Number_Id__c = '', Core_Owner_Txt__c = 'newuser@disti4.com', 
            Core_Product_Group_Nm__c = 'Embedded/IOT', Core_Design_Registration_Nm__c = 'Test Project 1', 
            Core_Design_Registration_Dsc__c = 'For demo Insert Scenario', Core_Opportunity_Volume_Cnt__c = '5', 
            Core_Partner_FAE_Nm__c = ' Test FAE 1', Core_End_Customer_Nm__c = 'Test Customer 1', 
            Core_End_Customer_Street_Addr_Line1_Txt__c = 'Millbare', 
            Core_End_Customer_Street_Addr_Line2_Txt__c = 'Trichy2', Core_End_Customer_City_Nm__c = 'San Francisco', 
            Core_End_Customer_Country_Subdivision_Nm__c = 'California',
            Core_End_Customer_Postal_Cd__c = '54321', Core_End_Customer_Country_Nm__c = 'USA', 
            Core_Military_Aerospace_Gvrnmt_Use_Ind__c = 'Yes',
            Core_Opportunity_Decision_Dt__c = system.today().addDays(20).format(), Core_First_Customer_Ship_Dt__c = system.today().addDays(20).format(), 
            Core_Production_End_Dt__c = system.today().addDays(20).format(), Core_Vertical_Market_Nm__c = 'Sports',
            Core_Intel_Platform_Nm__c = 'Broadwell', Core_Product_Segment_Nm__c = 'Client Computing', 
            Core_Product_Application_Nm__c = 'Desktop', Core_Manufacturing_Region_Cd__c = 'APJ',
            Core_Design_Solution_Network_Ind__c = 'Yes', Core_End_Customer_Contact_Title_Txt__c = 'Mr', 
            Core_End_Customer_Contact_Nm__c = 'RajaDinakaran', Core_End_Customer_Contact_Email_Txt__c   = 'rd@rd.com', 
            Core_End_Customer_Contact_Phone_Txt__c = '9940837430'),
            
            //Product
            new Core_Design_Registration_Stage__c(Core_Batch_ID__c = desRegBatch7430.Id, Core_Group_Id__c = '1', 
            Core_Header_Or_Product_Ind__c = 'Header', Core_Design_Registration_Line_Id__c = '', 
            Core_Partner_Tracking_Cd__c = '7430', Core_Product_Id__c = 'Intel Atom® CE4270 Media Processor', 
            Core_Full_Year_Qty__c = '6',Core_Target_Resale_Amt__c = '10', 
            Core_Cancelled_Ind__c = '', Core_Registration_Number_Id__c = '', Core_Owner_Txt__c = '', Core_Product_Group_Nm__c = '', 
            Core_Design_Registration_Nm__c = '', Core_Design_Registration_Dsc__c = '', Core_Opportunity_Volume_Cnt__c = '', 
            Core_Partner_FAE_Nm__c = '', Core_End_Customer_Nm__c = '', Core_End_Customer_Street_Addr_Line1_Txt__c = '', 
            Core_End_Customer_Street_Addr_Line2_Txt__c = '', Core_End_Customer_City_Nm__c = '', Core_End_Customer_Country_Subdivision_Nm__c = '',
            Core_End_Customer_Postal_Cd__c = '', Core_End_Customer_Country_Nm__c = '', Core_Military_Aerospace_Gvrnmt_Use_Ind__c = '',
            Core_Opportunity_Decision_Dt__c = '', Core_First_Customer_Ship_Dt__c = '', Core_Production_End_Dt__c = '', Core_Vertical_Market_Nm__c = '',
            Core_Intel_Platform_Nm__c = '', Core_Product_Segment_Nm__c = '', Core_Product_Application_Nm__c = '', Core_Manufacturing_Region_Cd__c = '',
            Core_Design_Solution_Network_Ind__c = '', Core_End_Customer_Contact_Title_Txt__c = '', Core_End_Customer_Contact_Nm__c = '',
        Core_End_Customer_Contact_Email_Txt__c   = '', Core_End_Customer_Contact_Phone_Txt__c = '') };
        
        
        insert designRegStage7430;    
        
        Core_DDR_Stage_Validator checkValidations7430 = new Core_DDR_Stage_Validator();
        checkValidations7430.checkValidations(designRegStage7430);  
        
        //Update record scenario
        Core_Design_Registration_Batch__c desRegBatch7431 = new Core_Design_Registration_Batch__c(Core_File_Nm__c = 'BatchFileName', Core_Partner_Account_Id__c = lstAcc[0].Id);
        insert desRegBatch7431;                   
        //Header
        List<Core_Design_Registration_Stage__c> designRegStage7431 = new List<Core_Design_Registration_Stage__c>{
            new Core_Design_Registration_Stage__c(Core_Batch_ID__c = desRegBatch7431.Id, Core_Group_Id__c = '1', 
            Core_Header_Or_Product_Ind__c = 'Header', Core_Design_Registration_Line_Id__c = '', 
            Core_Partner_Tracking_Cd__c = '', Core_Product_Id__c = '', Core_Full_Year_Qty__c = '6',Core_Target_Resale_Amt__c = '', 
            Core_Cancelled_Ind__c = '', Core_Registration_Number_Id__c = '', Core_Owner_Txt__c = 'Dummy@disti.com', 
            Core_Product_Group_Nm__c = 'Embedded/IOT', Core_Design_Registration_Nm__c = 'Test Project 1', 
            Core_Design_Registration_Dsc__c = 'For demo Insert Scenario', Core_Opportunity_Volume_Cnt__c = '5', 
            Core_Partner_FAE_Nm__c = ' Test FAE 1', Core_End_Customer_Nm__c = 'Test Customer 1', 
            Core_End_Customer_Street_Addr_Line1_Txt__c = 'Millbare', 
            Core_End_Customer_Street_Addr_Line2_Txt__c = 'Trichy2', Core_End_Customer_City_Nm__c = 'San Francisco', 
            Core_End_Customer_Country_Subdivision_Nm__c = 'California',
            Core_End_Customer_Postal_Cd__c = '54321', Core_End_Customer_Country_Nm__c = 'USA', 
            Core_Military_Aerospace_Gvrnmt_Use_Ind__c = 'Yes',
            Core_Opportunity_Decision_Dt__c = system.today().addDays(20).format(), Core_First_Customer_Ship_Dt__c = system.today().addDays(20).format(), 
            Core_Production_End_Dt__c = system.today().addDays(20).format(), Core_Vertical_Market_Nm__c = 'Sports',
            Core_Intel_Platform_Nm__c = 'Broadwell', Core_Product_Segment_Nm__c = 'Client Computing', 
            Core_Product_Application_Nm__c = 'Desktop', Core_Manufacturing_Region_Cd__c = 'APJ',
            Core_Design_Solution_Network_Ind__c = 'No', Core_End_Customer_Contact_Title_Txt__c = 'Mr', 
            Core_End_Customer_Contact_Nm__c = 'RajaDinakaran', Core_End_Customer_Contact_Email_Txt__c   = 'rd@rd.com', 
            Core_End_Customer_Contact_Phone_Txt__c = '9940837430'),
            
            //Product
            new Core_Design_Registration_Stage__c(Core_Batch_ID__c = desRegBatch7431.Id, Core_Group_Id__c = '1', 
            Core_Header_Or_Product_Ind__c = 'Header', Core_Design_Registration_Line_Id__c = '', 
            Core_Partner_Tracking_Cd__c = '7430', Core_Product_Id__c = 'Intel Atom® CE4270 Media Processor', 
            Core_Full_Year_Qty__c = '6',Core_Target_Resale_Amt__c = '10', 
            Core_Cancelled_Ind__c = '', Core_Registration_Number_Id__c = '', Core_Owner_Txt__c = '', Core_Product_Group_Nm__c = '', 
            Core_Design_Registration_Nm__c = '', Core_Design_Registration_Dsc__c = '', Core_Opportunity_Volume_Cnt__c = '', 
            Core_Partner_FAE_Nm__c = '', Core_End_Customer_Nm__c = '', Core_End_Customer_Street_Addr_Line1_Txt__c = '', 
            Core_End_Customer_Street_Addr_Line2_Txt__c = '', Core_End_Customer_City_Nm__c = '', Core_End_Customer_Country_Subdivision_Nm__c = '',
            Core_End_Customer_Postal_Cd__c = '', Core_End_Customer_Country_Nm__c = '', Core_Military_Aerospace_Gvrnmt_Use_Ind__c = '',
            Core_Opportunity_Decision_Dt__c = '', Core_First_Customer_Ship_Dt__c = '', Core_Production_End_Dt__c = '', Core_Vertical_Market_Nm__c = '',
            Core_Intel_Platform_Nm__c = '', Core_Product_Segment_Nm__c = '', Core_Product_Application_Nm__c = '', Core_Manufacturing_Region_Cd__c = '',
            Core_Design_Solution_Network_Ind__c = '', Core_End_Customer_Contact_Title_Txt__c = '', Core_End_Customer_Contact_Nm__c = '',
        Core_End_Customer_Contact_Email_Txt__c   = '', Core_End_Customer_Contact_Phone_Txt__c = '') };
        
        
        for(Core_Design_Registration_Stage__c iDS : designRegStage7430)
        {
            for(Core_Design_Registration_Stage__c iDSNew : designRegStage7431)
            {
                if(iDS.Core_Header_Or_Product_Ind__c == 'Header' && iDSNew.Core_Header_Or_Product_Ind__c == 'Header')
                {
                    iDSNew.Core_Registration_Number_Id__c = iDS.Name;
                }
                else if(iDS.Core_Header_Or_Product_Ind__c == 'Product' && iDSNew.Core_Header_Or_Product_Ind__c == 'Product')
                {
                    iDSNew.Core_Design_Registration_Line_Id__c = iDS.Name;
                }
            }
        }
        
        insert designRegStage7431;   
        
        
        Core_DDR_Stage_Validator checkValidations7431 = new Core_DDR_Stage_Validator();
        checkValidations7431.checkValidations(designRegStage7431); 
        
        designRegStage7431[0].Core_Owner_Txt__c = 'Tewr'; 
        designRegStage7431[1].Core_Owner_Txt__c = 'Tewr'; 
        
        Test.StopTest();
        
        update designRegStage7431;
        
        
        Core_DDR_Stage_Validator checkValidations7432 = new Core_DDR_Stage_Validator();
        checkValidations7432.checkValidations(designRegStage7431);  
        
        designRegStage7431[0].Core_Owner_Txt__c = 'newuser@disti4.com'; 
        designRegStage7431[1].Core_Owner_Txt__c = 'newuser@disti4.com';
        
        update designRegStage7431;
        
        Approval.lock([SELECT id FROM Core_Design_Registration__c WHERE Core_Design_Registration_Stage_Id__c IN:designRegStage7430]);
        Approval.lock([SELECT id FROM Core_Design_Registration_Product__c WHERE Core_Design_Registration_Stage_Id__c  IN:designRegStage7430]);  
        
        checkValidations7432.checkValidations(designRegStage7431);   
        
        //Insert not valid email
        Core_Design_Registration_Batch__c desRegBatch7433 = new Core_Design_Registration_Batch__c(Core_File_Nm__c = 'BatchFileName', Core_Partner_Account_Id__c = lstAcc[0].Id);
        insert desRegBatch7433;                   
        //Header
        List<Core_Design_Registration_Stage__c> designRegStage7433 = new List<Core_Design_Registration_Stage__c>{
            new Core_Design_Registration_Stage__c(Core_Batch_ID__c = desRegBatch7433.Id, Core_Group_Id__c = '1', 
            Core_Header_Or_Product_Ind__c = 'Header', Core_Design_Registration_Line_Id__c = '', 
            Core_Partner_Tracking_Cd__c = '', Core_Product_Id__c = '', Core_Full_Year_Qty__c = '6',Core_Target_Resale_Amt__c = '', 
            Core_Cancelled_Ind__c = '', Core_Registration_Number_Id__c = '', Core_Owner_Txt__c = 'newuser', 
            Core_Product_Group_Nm__c = 'Embedded/IOT', Core_Design_Registration_Nm__c = 'Test Project 1', 
            Core_Design_Registration_Dsc__c = 'For demo Insert Scenario', Core_Opportunity_Volume_Cnt__c = '5', 
            Core_Partner_FAE_Nm__c = ' Test FAE 1', Core_End_Customer_Nm__c = 'Test Customer 1', 
            Core_End_Customer_Street_Addr_Line1_Txt__c = 'Millbare', 
            Core_End_Customer_Street_Addr_Line2_Txt__c = 'Trichy2', Core_End_Customer_City_Nm__c = 'San Francisco', 
            Core_End_Customer_Country_Subdivision_Nm__c = 'California',
            Core_End_Customer_Postal_Cd__c = '54321', Core_End_Customer_Country_Nm__c = 'USA', 
            Core_Military_Aerospace_Gvrnmt_Use_Ind__c = 'Yes',
            Core_Opportunity_Decision_Dt__c = system.today().addDays(20).format(), Core_First_Customer_Ship_Dt__c = system.today().addDays(20).format(), 
            Core_Production_End_Dt__c = system.today().addDays(20).format(), Core_Vertical_Market_Nm__c = 'Sports',
            Core_Intel_Platform_Nm__c = 'Broadwell', Core_Product_Segment_Nm__c = 'Client Computing', 
            Core_Product_Application_Nm__c = 'Desktop', Core_Manufacturing_Region_Cd__c = 'APJ',
            Core_Design_Solution_Network_Ind__c = 'Yes', Core_End_Customer_Contact_Title_Txt__c = 'Mr', 
            Core_End_Customer_Contact_Nm__c = 'RajaDinakaran', Core_End_Customer_Contact_Email_Txt__c   = 'rd@rd.com', 
            Core_End_Customer_Contact_Phone_Txt__c = '9940837430'),
            
            //Product
            new Core_Design_Registration_Stage__c(Core_Batch_ID__c = desRegBatch7430.Id, Core_Group_Id__c = '1', 
            Core_Header_Or_Product_Ind__c = 'Header', Core_Design_Registration_Line_Id__c = '', 
            Core_Partner_Tracking_Cd__c = '7433', Core_Product_Id__c = 'Intel Atom® CE4270 Media Processor', 
            Core_Full_Year_Qty__c = '6',Core_Target_Resale_Amt__c = '10', 
            Core_Cancelled_Ind__c = '', Core_Registration_Number_Id__c = '', Core_Owner_Txt__c = '', Core_Product_Group_Nm__c = '', 
            Core_Design_Registration_Nm__c = '', Core_Design_Registration_Dsc__c = '', Core_Opportunity_Volume_Cnt__c = '', 
            Core_Partner_FAE_Nm__c = '', Core_End_Customer_Nm__c = '', Core_End_Customer_Street_Addr_Line1_Txt__c = '', 
            Core_End_Customer_Street_Addr_Line2_Txt__c = '', Core_End_Customer_City_Nm__c = '', Core_End_Customer_Country_Subdivision_Nm__c = '',
            Core_End_Customer_Postal_Cd__c = '', Core_End_Customer_Country_Nm__c = '', Core_Military_Aerospace_Gvrnmt_Use_Ind__c = '',
            Core_Opportunity_Decision_Dt__c = '', Core_First_Customer_Ship_Dt__c = '', Core_Production_End_Dt__c = '', Core_Vertical_Market_Nm__c = '',
            Core_Intel_Platform_Nm__c = '', Core_Product_Segment_Nm__c = '', Core_Product_Application_Nm__c = '', Core_Manufacturing_Region_Cd__c = '',
            Core_Design_Solution_Network_Ind__c = '', Core_End_Customer_Contact_Title_Txt__c = '', Core_End_Customer_Contact_Nm__c = '',
        Core_End_Customer_Contact_Email_Txt__c   = '', Core_End_Customer_Contact_Phone_Txt__c = '') };
        
        
        insert designRegStage7433; 
           
        Core_DDR_Stage_Validator checkValidations7433 = new Core_DDR_Stage_Validator();
        checkValidations7433.checkValidations(designRegStage7433);   

    }
        
    static testmethod void testStageValidator2()
    {
    
        List<account> LstAcc1 = Core_Test_Utility.createAccount(1);
        lstAcc1[0].Name = 'Distributor 1';
        insert lstAcc1;
        
        List<contact> LstCon1 = Core_Test_Utility.createContacts(1);
        for(contact con: LstCon1)
        {
            con.Firstname = 'disti1user1';
            con.Lastname = 'disti1user1';
             con.email = 'disti1user1@disti1.com';
            con.accountid = lstAcc1[0].id;
        }
        insert LstCon1;
        
        Id p = [select id from profile where name='Partner'].id;  
        
        User userRecord1 = new User(
        Alias = 'StdUser', 
        Email = 'disti1user1@disti1.com', 
        EmailEncodingKey ='UTF-8',
        LastName = 'Testing', 
        LanguageLocaleKey = 'en_US',
        LocaleSidKey = 'en_US',
        TimeZoneSidKey = 'America/Los_Angeles', 
        UserName = 'disti1user1@disti1.com',
        isActive = true, profileid = P, ContactId = LstCon1[0].id
        ); 
        
        insert userRecord1; 
        List<account> LstAcc2 = Core_Test_Utility.createAccount(1);
        lstAcc2[0].Name = 'Distributor 2';
        insert lstAcc2;
        
        List<contact> LstCon2 = Core_Test_Utility.createContacts(1);
        for(contact con: LstCon2)
        {
            con.Firstname = 'disti2user1';
            con.Lastname = 'disti2user1';
             con.email = 'disti2user1@disti2.com';
            con.accountid = lstAcc2[0].id;
        }
        insert LstCon2;
        
        
        User userRecord2 = new User(
        Alias = 'StdUser', 
        Email = 'disti2user1@disti2.com', 
        EmailEncodingKey ='UTF-8',
        LastName = 'Testing', 
        LanguageLocaleKey = 'en_US',
        LocaleSidKey = 'en_US',
        TimeZoneSidKey = 'America/Los_Angeles', 
        UserName = 'disti2user1@disti2.com',
        isActive = true, profileid = P, ContactId = LstCon2[0].id
        ); 
        
        insert userRecord2;   
        
        List<Pricebook2> lstPriceBook = new List<Pricebook2>();  
        
        Pricebook2 pb1 = new Pricebook2();
        pb1.name = 'Standard Price Book';
        pb1.isActive = TRUE;
        
        lstPriceBook.add(pb1);
        
        Pricebook2 pb2 = new Pricebook2();
        pb2.name = 'Partner Price Book';
        pb2.isActive = TRUE;
        
        lstPriceBook.add(pb2); 
        
        insert lstPriceBook;  
        
        List<Product2> lstProduct = new List<Product2>();
        
        //Product1 price book entry update scenario
        Product2 product1 = new Product2();
        product1.Name = 'Intel Atom® CE4275 Media Processor';
        product1.IsActive = TRUE;
        product1.Core_Design_Registration_Eligible_Ind__c = TRUE;
        product1.Core_Sales_Visible_Flag__c = TRUE;
        product1.Core_Partner_Visible_Ind__c  = TRUE;
        lstProduct.add(product1);
        
        //Product2 price book entry create scenario
        Product2 product2 = new Product2();
        product2.Name = 'Intel® Core™ i3-4020M Processor (3M Cache, 2.60 GHz)';
        product2.IsActive = TRUE;
        product2.Core_Design_Registration_Eligible_Ind__c = TRUE;
        product2.Core_Sales_Visible_Flag__c = TRUE;
        product2.Core_Partner_Visible_Ind__c  = TRUE;
        lstProduct.add(product2);      
        
        insert lstProduct;
        
        List<PricebookEntry> lstPriceBookEntry = new List<PricebookEntry>();
        
        /*******Partner price book entry update scenario ********/
        PricebookEntry PriceBookEntry1 = new PricebookEntry();
        PriceBookEntry1.Pricebook2Id =  Test.getStandardPricebookId();
        PriceBookEntry1.Product2Id = lstProduct[0].id;
        PriceBookEntry1.IsActive = true;
        PriceBookEntry1.UnitPrice = 100;
        
        lstPriceBookEntry.add(PriceBookEntry1);
        
        PricebookEntry PriceBookEntry2 = new PricebookEntry();
        for(Pricebook2 iPB : lstPriceBook)
        {
            if(iPB.Name == 'Standard Price Book')
            {
                PriceBookEntry2.Pricebook2Id =  iPB.Id;
            }
        }
        PriceBookEntry2.Product2Id = lstProduct[0].id;
        PriceBookEntry2.IsActive = true;
        PriceBookEntry2.UnitPrice = 100;
        PriceBookEntry2.UseStandardPrice = true;    
        
        lstPriceBookEntry.add(PriceBookEntry2);
        
        PricebookEntry PriceBookEntry3 = new PricebookEntry();
        for(Pricebook2 iPB : lstPriceBook)
        {
            if(iPB.Name == 'Partner Price Book')
            {
                PriceBookEntry3.Pricebook2Id =  iPB.ID;
            }
        }
        PriceBookEntry3.Product2Id = lstProduct[0].id;
        PriceBookEntry3.IsActive = true;
        PriceBookEntry3.UnitPrice = 100;
        
        lstPriceBookEntry.add(PriceBookEntry3);      
        
        /*******Partner price book entry update scenario - Close ********/
        
        /*******Partner price book entry create scenario ********/
        
        PricebookEntry PriceBookEntry4 = new PricebookEntry();
        PriceBookEntry4.Pricebook2Id =  Test.getStandardPricebookId();
        PriceBookEntry4.Product2Id = lstProduct[1].id;
        PriceBookEntry4.IsActive = true;
        PriceBookEntry4.UnitPrice = 100;
        
        lstPriceBookEntry.add(PriceBookEntry4);         
        
        PricebookEntry PriceBookEntry5 = new PricebookEntry();
        for(Pricebook2 iPB : lstPriceBook)
        {
            if(iPB.Name == 'Standard Price Book')
            {
                PriceBookEntry5.Pricebook2Id =  iPB.Id;
            }
        }
        PriceBookEntry5.Product2Id = lstProduct[1].id;
        PriceBookEntry5.IsActive = true;
        PriceBookEntry5.UnitPrice = 100;
        PriceBookEntry5.UseStandardPrice = true;    
        
        lstPriceBookEntry.add(PriceBookEntry5);
        
        PricebookEntry PriceBookEntry6 = new PricebookEntry();
        for(Pricebook2 iPB : lstPriceBook)
        {
            if(iPB.Name == 'Partner Price Book')
            {
                PriceBookEntry6.Pricebook2Id =  iPB.Id;
            }
        }
        PriceBookEntry6.Product2Id = lstProduct[1].id;
        PriceBookEntry6.IsActive = true;
        PriceBookEntry6.UnitPrice = 100;
        PriceBookEntry6.UseStandardPrice = true;    
        
        lstPriceBookEntry.add(PriceBookEntry6);
        
        insert lstPriceBookEntry;
        

        List<Core_Design_Registrations_Bulk_Upload__c> DRBulkUploadList = new List<Core_Design_Registrations_Bulk_Upload__c>{
                new Core_Design_Registrations_Bulk_Upload__c(name = 'Group ID', Core_Active_Ind__c = true, Core_Design_Required_Ind__c = false, Core_CSV_Column_Nm__c= 'Group ID', Core_Stage_API_Field_Nm__c= 'Core_Group_ID__c', Core_Stage_Required_Ind__c= true),
                new Core_Design_Registrations_Bulk_Upload__c(name = 'Header/ Product', Core_Active_Ind__c = true, Core_Design_API_Field_Nm__c = 'Core_Header_Or_Product_Ind__c', Core_CSV_Column_Nm__c= 'Header/ Product', Core_Stage_API_Field_Nm__c= 'Core_Header_Or_Product_Ind__c', Core_Stage_Required_Ind__c= true, Core_Design_Required_Ind__c= false),
                new Core_Design_Registrations_Bulk_Upload__c(name = 'Design Registration Line ID', Core_Active_Ind__c = true, Core_Design_API_Field_Nm__c = 'Core_Design_Registration_Line_ID__c', Core_CSV_Column_Nm__c= 'Design Registration Line ID', Core_Stage_API_Field_Nm__c= 'Core_Design_Registration_Line_ID__c', Core_Field_Data_Type_Txt__c= 'Text', Core_Header_Or_Product_Ind__c= 'Product', Core_Design_Required_Ind__c= false),
                new Core_Design_Registrations_Bulk_Upload__c(name = 'Partner Tracking Number', Core_Active_Ind__c = true, Core_Design_API_Field_Nm__c = 'Core_Partner_Tracking_Cd__c', Core_CSV_Column_Nm__c= 'Partner Tracking Number', Core_Stage_API_Field_Nm__c= 'Core_Partner_Tracking_Cd__c', Core_Field_Data_Type_Txt__c= 'Text', Core_Header_Or_Product_Ind__c= 'Product', Core_Design_Required_Ind__c= false),
                new Core_Design_Registrations_Bulk_Upload__c(name = 'Product', Core_CSV_Column_Nm__c= 'Product', Core_Active_Ind__c = true, Core_Design_API_Field_Nm__c = 'Core_Product_Id__c', Core_Stage_API_Field_Nm__c= 'Core_Product_Id__c', Core_Field_Data_Type_Txt__c= 'Lookup', Core_Header_Or_Product_Ind__c= 'Product', Core_Design_Required_Ind__c= true),
                new Core_Design_Registrations_Bulk_Upload__c(name = 'Quantity (Full Production Year)', Core_CSV_Column_Nm__c= 'Quantity (Full Production Year)', Core_Active_Ind__c = true, Core_Design_API_Field_Nm__c = 'Core_Full_Year_Qty__c', Core_Stage_API_Field_Nm__c= 'Core_Full_Year_Qty__c', Core_Field_Data_Type_Txt__c= 'Number', Core_Header_Or_Product_Ind__c= 'Product', Core_Design_Required_Ind__c= true),
                new Core_Design_Registrations_Bulk_Upload__c(name = 'Target Resale Price', Core_CSV_Column_Nm__c= 'Target Resale Price', Core_Active_Ind__c = true, Core_Design_API_Field_Nm__c = 'Core_Target_Resale_Amt__c', Core_Stage_API_Field_Nm__c= 'Core_Target_Resale_Amt__c', Core_Field_Data_Type_Txt__c= 'Number', Core_Header_Or_Product_Ind__c= 'Product', Core_Design_Required_Ind__c= true),
                new Core_Design_Registrations_Bulk_Upload__c(name = 'Cancelled (Y)', Core_Active_Ind__c = true, Core_Design_API_Field_Nm__c = 'Core_Design_Product_Status_Nm__c', Core_CSV_Column_Nm__c= 'Cancelled (Y)', Core_Stage_API_Field_Nm__c= 'Core_Cancelled_Ind__c', Core_Field_Data_Type_Txt__c= 'Boolean', Core_Header_Or_Product_Ind__c= 'Product', Core_Design_Required_Ind__c= false),
                new Core_Design_Registrations_Bulk_Upload__c(name = 'Registration Number', Core_Active_Ind__c = true, Core_Design_API_Field_Nm__c = 'Core_Registration_Number_Id__c', Core_CSV_Column_Nm__c= 'Registration Number', Core_Stage_API_Field_Nm__c= 'Core_Registration_Number_Id__c', Core_Field_Data_Type_Txt__c= 'Text', Core_Header_Or_Product_Ind__c= 'Header', Core_Design_Required_Ind__c= false),
                new Core_Design_Registrations_Bulk_Upload__c(name = 'Owner (email)', Core_Active_Ind__c = true, Core_Design_API_Field_Nm__c = 'OwnerId', Core_CSV_Column_Nm__c= 'Owner (email)', Core_Stage_API_Field_Nm__c= 'Core_Owner_Txt__c', Core_Field_Data_Type_Txt__c= 'ID', Core_Header_Or_Product_Ind__c= 'Header', Core_Design_Required_Ind__c= false),
                new Core_Design_Registrations_Bulk_Upload__c(name = 'Product Group', Core_CSV_Column_Nm__c= 'Product Group', Core_Active_Ind__c = true, Core_Design_API_Field_Nm__c = 'Core_Product_Group_Nm__c', Core_Stage_API_Field_Nm__c= 'Core_Product_Group_Nm__c', Core_Field_Data_Type_Txt__c= 'Text', Core_Header_Or_Product_Ind__c= 'Header', Core_Design_Required_Ind__c= true),
                new Core_Design_Registrations_Bulk_Upload__c(name = 'Design Registration Name', Core_CSV_Column_Nm__c= 'Design Registration Name', Core_Active_Ind__c = true, Core_Design_API_Field_Nm__c = 'Core_Design_Registration_Nm__c', Core_Stage_API_Field_Nm__c= 'Core_Design_Registration_Nm__c', Core_Field_Data_Type_Txt__c= 'Text', Core_Header_Or_Product_Ind__c= 'Header', Core_Design_Required_Ind__c= true),
                new Core_Design_Registrations_Bulk_Upload__c(name = 'Description', Core_CSV_Column_Nm__c= 'Description', Core_Active_Ind__c = true, Core_Design_API_Field_Nm__c = 'Core_Design_Registration_Dsc__c', Core_Stage_API_Field_Nm__c= 'Core_Design_Registration_Dsc__c', Core_Field_Data_Type_Txt__c= 'Text', Core_Header_Or_Product_Ind__c= 'Header', Core_Design_Required_Ind__c= true),
                new Core_Design_Registrations_Bulk_Upload__c(name = 'Opportunity Volume', Core_CSV_Column_Nm__c= 'Opportunity Volume', Core_Active_Ind__c = true, Core_Design_API_Field_Nm__c = 'Core_Opportunity_Volume_Cnt__c', Core_Stage_API_Field_Nm__c= 'Core_Opportunity_Volume_Cnt__c', Core_Field_Data_Type_Txt__c= 'Number', Core_Header_Or_Product_Ind__c= 'Header', Core_Design_Required_Ind__c= true),
                new Core_Design_Registrations_Bulk_Upload__c(name = 'Partner FAE', Core_CSV_Column_Nm__c= 'Partner FAE', Core_Active_Ind__c = true, Core_Design_API_Field_Nm__c = 'Core_Partner_FAE_Nm__c', Core_Stage_API_Field_Nm__c= 'Core_Partner_FAE_Nm__c', Core_Field_Data_Type_Txt__c= 'Text', Core_Header_Or_Product_Ind__c= 'Header', Core_Design_Required_Ind__c= true),
                new Core_Design_Registrations_Bulk_Upload__c(name = 'End Customer Name', Core_CSV_Column_Nm__c= 'End Customer Name', Core_Active_Ind__c = true, Core_Design_API_Field_Nm__c = 'Core_End_Customer_Nm__c', Core_Stage_API_Field_Nm__c= 'Core_End_Customer_Nm__c', Core_Field_Data_Type_Txt__c= 'Text', Core_Header_Or_Product_Ind__c= 'Header', Core_Design_Required_Ind__c= true),
                new Core_Design_Registrations_Bulk_Upload__c(name = 'End Customer Address1', Core_CSV_Column_Nm__c= 'End Customer Address1', Core_Active_Ind__c = true, Core_Design_API_Field_Nm__c = 'Core_End_Customer_Street_Addr_Line1_Txt__c', Core_Stage_API_Field_Nm__c= 'Core_End_Customer_Street_Addr_Line1_Txt__c', Core_Field_Data_Type_Txt__c= 'Text', Core_Header_Or_Product_Ind__c= 'Header', Core_Design_Required_Ind__c= true),
                new Core_Design_Registrations_Bulk_Upload__c(name = 'End Customer Address2', Core_Active_Ind__c = true, Core_Design_API_Field_Nm__c = 'Core_End_Customer_Street_Addr_Line2_Txt__c', Core_CSV_Column_Nm__c= 'End Customer Address2', Core_Stage_API_Field_Nm__c= 'Core_End_Customer_Street_Addr_Line2_Txt__c', Core_Field_Data_Type_Txt__c= 'Text', Core_Header_Or_Product_Ind__c= 'Header', Core_Design_Required_Ind__c= false),
                new Core_Design_Registrations_Bulk_Upload__c(name = 'End Customer City', Core_CSV_Column_Nm__c= 'End Customer City', Core_Active_Ind__c = true, Core_Design_API_Field_Nm__c = 'Core_End_Customer_City_Nm__c', Core_Stage_API_Field_Nm__c= 'Core_End_Customer_City_Nm__c', Core_Field_Data_Type_Txt__c= 'Text', Core_Header_Or_Product_Ind__c= 'Header', Core_Design_Required_Ind__c= true),
                new Core_Design_Registrations_Bulk_Upload__c(name = 'End Customer State', Core_CSV_Column_Nm__c= 'End Customer State', Core_Active_Ind__c = true, Core_Design_API_Field_Nm__c = 'Core_End_Customer_Country_Subdivision_Nm__c', Core_Stage_API_Field_Nm__c= 'Core_End_Customer_Country_Subdivision_Nm__c', Core_Field_Data_Type_Txt__c= 'Text', Core_Header_Or_Product_Ind__c= 'Header', Core_Design_Required_Ind__c= true),
                new Core_Design_Registrations_Bulk_Upload__c(name = 'End Customer Zip/ Postal Code', Core_CSV_Column_Nm__c= 'End Customer Zip/ Postal Code', Core_Active_Ind__c = true, Core_Design_API_Field_Nm__c = 'Core_End_Customer_Postal_Cd__c', Core_Stage_API_Field_Nm__c= 'Core_End_Customer_Postal_Cd__c', Core_Field_Data_Type_Txt__c= 'Text', Core_Header_Or_Product_Ind__c= 'Header', Core_Design_Required_Ind__c= true),
                new Core_Design_Registrations_Bulk_Upload__c(name = 'End Customer Country', Core_CSV_Column_Nm__c= 'End Customer Country', Core_Active_Ind__c = true, Core_Design_API_Field_Nm__c = 'Core_End_Customer_Country_Nm__c', Core_Stage_API_Field_Nm__c= 'Core_End_Customer_Country_Nm__c', Core_Field_Data_Type_Txt__c= 'Text', Core_Header_Or_Product_Ind__c= 'Header', Core_Design_Required_Ind__c= true),
                new Core_Design_Registrations_Bulk_Upload__c(name = 'End Customer Contact Title', Core_CSV_Column_Nm__c= 'End Customer Contact Title', Core_Active_Ind__c = true, Core_Design_API_Field_Nm__c = 'Core_End_Customer_Contact_Title_Txt__c', Core_Stage_API_Field_Nm__c= 'Core_End_Customer_Contact_Title_Txt__c', Core_Field_Data_Type_Txt__c= 'Text', Core_Header_Or_Product_Ind__c= 'Header', Core_Design_Required_Ind__c= false),
                new Core_Design_Registrations_Bulk_Upload__c(name = 'End Customer Contact Name', Core_CSV_Column_Nm__c= 'End Customer Contact Name', Core_Active_Ind__c = true, Core_Design_API_Field_Nm__c = 'Core_End_Customer_Contact_Nm__c', Core_Stage_API_Field_Nm__c= 'Core_End_Customer_Contact_Nm__c', Core_Field_Data_Type_Txt__c= 'Text', Core_Header_Or_Product_Ind__c= 'Header', Core_Design_Required_Ind__c= false),
                new Core_Design_Registrations_Bulk_Upload__c(name = 'End Customer Contact Email', Core_CSV_Column_Nm__c= 'End Customer Contact Email', Core_Active_Ind__c = true, Core_Design_API_Field_Nm__c = 'Core_End_Customer_Contact_Email_Txt__c', Core_Stage_API_Field_Nm__c= 'Core_End_Customer_Contact_Email_Txt__c', Core_Field_Data_Type_Txt__c= 'Text', Core_Header_Or_Product_Ind__c= 'Header', Core_Design_Required_Ind__c= false),
                new Core_Design_Registrations_Bulk_Upload__c(name = 'End Customer Contact Phone', Core_CSV_Column_Nm__c= 'End Customer Contact Phone', Core_Active_Ind__c = true, Core_Design_API_Field_Nm__c = 'Core_End_Customer_Contact_Phone_Txt__c', Core_Stage_API_Field_Nm__c= 'Core_End_Customer_Contact_Phone_Txt__c', Core_Field_Data_Type_Txt__c= 'Text', Core_Header_Or_Product_Ind__c= 'Header', Core_Design_Required_Ind__c= false),
                new Core_Design_Registrations_Bulk_Upload__c(name = 'Military Aerospace Gov\'t End Use?', Core_CSV_Column_Nm__c= 'Military - Aerospace - Gov\'t End Use?', Core_Active_Ind__c = true, Core_Design_API_Field_Nm__c = 'Core_Military_Aerospace_Gvrnmt_Use_Ind__c', Core_Stage_API_Field_Nm__c= 'Core_Military_Aerospace_Gvrnmt_Use_Ind__c', Core_Field_Data_Type_Txt__c= 'Text', Core_Header_Or_Product_Ind__c= 'Header', Core_Design_Required_Ind__c= true),
                new Core_Design_Registrations_Bulk_Upload__c(name = 'Decision Date', Core_Active_Ind__c = true, Core_Design_API_Field_Nm__c = 'Core_Opportunity_Decision_Dt__c', Core_CSV_Column_Nm__c= 'Decision Date', Core_Stage_API_Field_Nm__c= 'Core_Opportunity_Decision_Dt__c', Core_Field_Data_Type_Txt__c= 'Date', Core_Header_Or_Product_Ind__c= 'Header', Core_Design_Required_Ind__c= true),
                new Core_Design_Registrations_Bulk_Upload__c(name = 'First Customer Ship Date', Core_CSV_Column_Nm__c= 'First Customer Ship Date', Core_Active_Ind__c = true, Core_Design_API_Field_Nm__c = 'Core_First_Customer_Ship_Dt__c', Core_Stage_API_Field_Nm__c= 'Core_First_Customer_Ship_Dt__c', Core_Field_Data_Type_Txt__c= 'Date', Core_Header_Or_Product_Ind__c= 'Header', Core_Design_Required_Ind__c= true),
                new Core_Design_Registrations_Bulk_Upload__c(name = 'Production End Date', Core_CSV_Column_Nm__c= 'Production End Date', Core_Active_Ind__c = true, Core_Design_API_Field_Nm__c = 'Core_Production_End_Dt__c', Core_Stage_API_Field_Nm__c= 'Core_Production_End_Dt__c', Core_Field_Data_Type_Txt__c= 'Date', Core_Header_Or_Product_Ind__c= 'Header', Core_Design_Required_Ind__c= true),
                new Core_Design_Registrations_Bulk_Upload__c(name = 'Vertical Market', Core_CSV_Column_Nm__c= 'Vertical Market', Core_Active_Ind__c = true, Core_Design_API_Field_Nm__c = 'Core_Vertical_Market_Nm__c', Core_Stage_API_Field_Nm__c= 'Core_Vertical_Market_Nm__c', Core_Field_Data_Type_Txt__c= 'Text', Core_Header_Or_Product_Ind__c= 'Header', Core_Design_Required_Ind__c= true),
                new Core_Design_Registrations_Bulk_Upload__c(name = 'Intel Platform', Core_CSV_Column_Nm__c= 'Intel Platform', Core_Active_Ind__c = true, Core_Design_API_Field_Nm__c = 'Core_Intel_Platform_Nm__c', Core_Stage_API_Field_Nm__c= 'Core_Intel_Platform_Nm__c', Core_Field_Data_Type_Txt__c= 'Picklist', Core_Header_Or_Product_Ind__c= 'Header', Core_Design_Required_Ind__c= true),
                new Core_Design_Registrations_Bulk_Upload__c(name = 'Product Segment', Core_CSV_Column_Nm__c= 'Product Segment', Core_Active_Ind__c = true, Core_Design_API_Field_Nm__c = 'Core_Product_Segment_Nm__c', Core_Stage_API_Field_Nm__c= 'Core_Product_Segment_Nm__c', Core_Field_Data_Type_Txt__c= 'Text', Core_Header_Or_Product_Ind__c= 'Header', Core_Design_Required_Ind__c= true),
                new Core_Design_Registrations_Bulk_Upload__c(name = 'Product Application', Core_CSV_Column_Nm__c= 'Product Application', Core_Active_Ind__c = true, Core_Design_API_Field_Nm__c = 'Core_Product_Application_Nm__c', Core_Stage_API_Field_Nm__c= 'Core_Product_Application_Nm__c', Core_Field_Data_Type_Txt__c= 'Text', Core_Header_Or_Product_Ind__c= 'Header', Core_Design_Required_Ind__c= true),
                new Core_Design_Registrations_Bulk_Upload__c(name = 'Manufacturing Region', Core_Active_Ind__c = true, Core_Design_API_Field_Nm__c = 'Core_Manufacturing_Region_Cd__c', Core_CSV_Column_Nm__c= 'Manufacturing Region', Core_Stage_API_Field_Nm__c= 'Core_Manufacturing_Region_Cd__c', Core_Field_Data_Type_Txt__c= 'Text', Core_Header_Or_Product_Ind__c= 'Header', Core_Design_Required_Ind__c= false),
                new Core_Design_Registrations_Bulk_Upload__c(name = 'Design Solution Network', Core_Active_Ind__c = true, Core_Design_API_Field_Nm__c = 'Core_Design_Solution_Network_Ind__c', Core_CSV_Column_Nm__c= 'Design Solution Network', Core_Stage_API_Field_Nm__c= 'Core_Design_Solution_Network_Ind__c', Core_Field_Data_Type_Txt__c= 'Checkbox', Core_Header_Or_Product_Ind__c= 'Header', Core_Design_Required_Ind__c= false),
            
                new Core_Design_Registrations_Bulk_Upload__c(name = 'Design Staging ID', Core_Active_Ind__c = true, Core_Design_API_Field_Nm__c = 'Core_Design_Registration_Stage_Id__c ', Core_Stage_API_Field_Nm__c= 'ID', Core_Field_Data_Type_Txt__c= 'Text', Core_Header_Or_Product_Ind__c= 'Header')
                    
        
        };
        insert DRBulkUploadList;
        
        List<Core_LogEntry_Switch__c> LogEntryLst = new List<Core_LogEntry_Switch__c>{new Core_LogEntry_Switch__c(name = 'Core_DDR_LogEntry_Check', Is_Selected__c = true)};
        insert LogEntryLst;
        
        Core_Design_Registration_Batch__c desRegBatch7430 = new Core_Design_Registration_Batch__c(Core_File_Nm__c = 'BatchFileName', Core_Partner_Account_Id__c = lstAcc1[0].Id);
        insert desRegBatch7430;                   
        //Header
        List<Core_Design_Registration_Stage__c> designRegStage7430 = new List<Core_Design_Registration_Stage__c>{
            new Core_Design_Registration_Stage__c(Core_Batch_ID__c = desRegBatch7430.Id, Core_Group_Id__c = '1', 
            Core_Header_Or_Product_Ind__c = 'Header', Core_Design_Registration_Line_Id__c = '', 
            Core_Partner_Tracking_Cd__c = '', Core_Product_Id__c = '', Core_Full_Year_Qty__c = '',Core_Target_Resale_Amt__c = '', 
            Core_Cancelled_Ind__c = '', Core_Registration_Number_Id__c = '', Core_Owner_Txt__c = 'disti1user1@disti1.com', 
            Core_Product_Group_Nm__c = 'Embedded/IOT', Core_Design_Registration_Nm__c = 'Test Project 1', 
            Core_Design_Registration_Dsc__c = 'For demo Insert Scenario', Core_Opportunity_Volume_Cnt__c = '5', 
            Core_Partner_FAE_Nm__c = ' Test FAE 1', Core_End_Customer_Nm__c = 'Test Customer 1', 
            Core_End_Customer_Street_Addr_Line1_Txt__c = 'Millbare', 
            Core_End_Customer_Street_Addr_Line2_Txt__c = 'Trichy2', Core_End_Customer_City_Nm__c = 'San Francisco', 
            Core_End_Customer_Country_Subdivision_Nm__c = 'California',
            Core_End_Customer_Postal_Cd__c = '54321', Core_End_Customer_Country_Nm__c = 'USA', 
            Core_Military_Aerospace_Gvrnmt_Use_Ind__c = 'Yes',
            Core_Opportunity_Decision_Dt__c = '11/13/2050', 
            Core_First_Customer_Ship_Dt__c = '11/13/2050',
            Core_Production_End_Dt__c = '11/13/2050', Core_Vertical_Market_Nm__c = 'Sports',
            Core_Intel_Platform_Nm__c = 'Broadwell', Core_Product_Segment_Nm__c = 'Client Computing', 
            Core_Product_Application_Nm__c = 'Business Desktop', Core_Manufacturing_Region_Cd__c = 'APJ',
            Core_Design_Solution_Network_Ind__c = 'Yes', Core_End_Customer_Contact_Title_Txt__c = 'Mr', 
            Core_End_Customer_Contact_Nm__c = 'RajaDinakaran', Core_End_Customer_Contact_Email_Txt__c   = 'rd@rd.com', 
            Core_End_Customer_Contact_Phone_Txt__c = '9940837430'),
            
            //Product
            new Core_Design_Registration_Stage__c(Core_Batch_ID__c = desRegBatch7430.Id, Core_Group_Id__c = '1', 
            Core_Header_Or_Product_Ind__c = 'Product', Core_Design_Registration_Line_Id__c = '', 
            Core_Partner_Tracking_Cd__c = '7430', Core_Product_Id__c = 'Intel Atom® CE4275 Media Processor', 
            Core_Full_Year_Qty__c = '6',Core_Target_Resale_Amt__c = '10', 
            Core_Cancelled_Ind__c = '', Core_Registration_Number_Id__c = '', Core_Owner_Txt__c = '', Core_Product_Group_Nm__c = '', 
            Core_Design_Registration_Nm__c = '', Core_Design_Registration_Dsc__c = '', Core_Opportunity_Volume_Cnt__c = '', 
            Core_Partner_FAE_Nm__c = '', Core_End_Customer_Nm__c = '', Core_End_Customer_Street_Addr_Line1_Txt__c = '', 
            Core_End_Customer_Street_Addr_Line2_Txt__c = '', Core_End_Customer_City_Nm__c = '', Core_End_Customer_Country_Subdivision_Nm__c = '',
            Core_End_Customer_Postal_Cd__c = '', Core_End_Customer_Country_Nm__c = '', Core_Military_Aerospace_Gvrnmt_Use_Ind__c = '',
            Core_Opportunity_Decision_Dt__c = '', Core_First_Customer_Ship_Dt__c = '', Core_Production_End_Dt__c = '', Core_Vertical_Market_Nm__c = '',
            Core_Intel_Platform_Nm__c = '', Core_Product_Segment_Nm__c = '', Core_Product_Application_Nm__c = '', Core_Manufacturing_Region_Cd__c = '',
            Core_Design_Solution_Network_Ind__c = '', Core_End_Customer_Contact_Title_Txt__c = '', Core_End_Customer_Contact_Nm__c = '',
            Core_End_Customer_Contact_Email_Txt__c   = '', Core_End_Customer_Contact_Phone_Txt__c = '') };
        
        
        insert designRegStage7430;    
        
        Core_DDR_Stage_Validator checkValidations7430 = new Core_DDR_Stage_Validator();
        checkValidations7430.checkValidations(designRegStage7430);  
        
        Core_Design_Registration__c insertedDesign = new Core_Design_Registration__c();
        Core_Design_Registration_Product__c insertDesignProduct = new Core_Design_Registration_Product__c();
        
        insertedDesign = [SELECT id, Name FROM Core_Design_Registration__c WHERE Core_Design_Registration_Stage_Id__c =: designRegStage7430[0].id];
        insertDesignProduct = [SELECT id, Name FROM Core_Design_Registration_Product__c WHERE Core_Design_Registration_Stage_Id__c =: designRegStage7430[1].id];
        
        //Update scenario
        Core_Design_Registration_Batch__c desRegBatch7431 = new Core_Design_Registration_Batch__c(Core_File_Nm__c = 'BatchFileName', Core_Partner_Account_Id__c = lstAcc1[0].Id);
        insert desRegBatch7431;                   
        //Header
        List<Core_Design_Registration_Stage__c> designRegStage7431 = new List<Core_Design_Registration_Stage__c>{
            new Core_Design_Registration_Stage__c(Core_Batch_ID__c = desRegBatch7431.Id, Core_Group_Id__c = '1', 
            Core_Header_Or_Product_Ind__c = 'Header', Core_Design_Registration_Line_Id__c = '', 
            Core_Partner_Tracking_Cd__c = '', Core_Product_Id__c = '', Core_Full_Year_Qty__c = '',Core_Target_Resale_Amt__c = '', 
            Core_Cancelled_Ind__c = '', Core_Registration_Number_Id__c = insertedDesign.Name, Core_Owner_Txt__c = 'disti1user1@disti1.com', 
            Core_Product_Group_Nm__c = 'Embedded/IOT', Core_Design_Registration_Nm__c = 'Test Project 1', 
            Core_Design_Registration_Dsc__c = 'For demo Insert Scenario', Core_Opportunity_Volume_Cnt__c = '5', 
            Core_Partner_FAE_Nm__c = ' Test FAE 1', Core_End_Customer_Nm__c = 'Test Customer 1', 
            Core_End_Customer_Street_Addr_Line1_Txt__c = 'Millbare', 
            Core_End_Customer_Street_Addr_Line2_Txt__c = 'Trichy2', Core_End_Customer_City_Nm__c = 'San Francisco', 
            Core_End_Customer_Country_Subdivision_Nm__c = 'California',
            Core_End_Customer_Postal_Cd__c = '54321', Core_End_Customer_Country_Nm__c = 'USA', 
            Core_Military_Aerospace_Gvrnmt_Use_Ind__c = 'Yes',
            Core_Opportunity_Decision_Dt__c = '11/13/2050', 
            Core_First_Customer_Ship_Dt__c = '11/13/2050',
            Core_Production_End_Dt__c = '11/13/2050', Core_Vertical_Market_Nm__c = 'Sports',
            Core_Intel_Platform_Nm__c = 'Broadwell', Core_Product_Segment_Nm__c = 'Wireless & Connectivity', 
            Core_Product_Application_Nm__c = 'Automotive', Core_Manufacturing_Region_Cd__c = 'APJ',
            Core_Design_Solution_Network_Ind__c = 'Yes', Core_End_Customer_Contact_Title_Txt__c = 'Mr', 
            Core_End_Customer_Contact_Nm__c = 'RajaDinakaran', Core_End_Customer_Contact_Email_Txt__c   = 'rd2@rd.com', 
            Core_End_Customer_Contact_Phone_Txt__c = '9940837430'),
            
            //Product
            new Core_Design_Registration_Stage__c(Core_Batch_ID__c = desRegBatch7431.Id, Core_Group_Id__c = '1', 
            Core_Header_Or_Product_Ind__c = 'Product', Core_Design_Registration_Line_Id__c = insertDesignProduct.Name, 
            Core_Partner_Tracking_Cd__c = '7430', Core_Product_Id__c = 'Intel Atom® CE4275 Media Processor', 
            Core_Full_Year_Qty__c = '6',Core_Target_Resale_Amt__c = '11', 
            Core_Cancelled_Ind__c = 'Yes', Core_Registration_Number_Id__c = '', Core_Owner_Txt__c = '', Core_Product_Group_Nm__c = '', 
            Core_Design_Registration_Nm__c = '', Core_Design_Registration_Dsc__c = '', Core_Opportunity_Volume_Cnt__c = '', 
            Core_Partner_FAE_Nm__c = '', Core_End_Customer_Nm__c = '', Core_End_Customer_Street_Addr_Line1_Txt__c = '', 
            Core_End_Customer_Street_Addr_Line2_Txt__c = '', Core_End_Customer_City_Nm__c = '', Core_End_Customer_Country_Subdivision_Nm__c = '',
            Core_End_Customer_Postal_Cd__c = '', Core_End_Customer_Country_Nm__c = '', Core_Military_Aerospace_Gvrnmt_Use_Ind__c = '',
            Core_Opportunity_Decision_Dt__c = '', Core_First_Customer_Ship_Dt__c = '', Core_Production_End_Dt__c = '', Core_Vertical_Market_Nm__c = '',
            Core_Intel_Platform_Nm__c = '', Core_Product_Segment_Nm__c = '', Core_Product_Application_Nm__c = '', Core_Manufacturing_Region_Cd__c = '',
            Core_Design_Solution_Network_Ind__c = '', Core_End_Customer_Contact_Title_Txt__c = '', Core_End_Customer_Contact_Nm__c = '',
            Core_End_Customer_Contact_Email_Txt__c   = '', Core_End_Customer_Contact_Phone_Txt__c = '') };
        
        
        insert designRegStage7431;
        
        Core_DDR_Stage_Validator checkValidations7431 = new Core_DDR_Stage_Validator();
        checkValidations7430.checkValidations(designRegStage7431);  
    
    Test.StartTest();
    
     //Update other disti record - no permission
        
        Core_Design_Registration_Batch__c desRegBatch7432 = new Core_Design_Registration_Batch__c(Core_File_Nm__c = 'BatchFileName', Core_Partner_Account_Id__c = lstAcc2[0].Id);
        insert desRegBatch7432;                   
        //Header
        List<Core_Design_Registration_Stage__c> designRegStage7432 = new List<Core_Design_Registration_Stage__c>{
            new Core_Design_Registration_Stage__c(Core_Batch_ID__c = desRegBatch7432.Id, Core_Group_Id__c = '1', 
            Core_Header_Or_Product_Ind__c = 'Header', Core_Design_Registration_Line_Id__c = '', 
            Core_Partner_Tracking_Cd__c = '', Core_Product_Id__c = '', Core_Full_Year_Qty__c = '',Core_Target_Resale_Amt__c = '', 
            Core_Cancelled_Ind__c = '', Core_Registration_Number_Id__c = insertedDesign.Name,
            Core_Owner_Txt__c = 'disti2user1@disti2.com', 
            Core_Product_Group_Nm__c = 'Embedded/IOT', Core_Design_Registration_Nm__c = 'Test Project 1', 
            Core_Design_Registration_Dsc__c = 'For demo Insert Scenario', Core_Opportunity_Volume_Cnt__c = '5', 
            Core_Partner_FAE_Nm__c = ' Test FAE 1', Core_End_Customer_Nm__c = 'Test Customer 1', 
            Core_End_Customer_Street_Addr_Line1_Txt__c = 'Millbare', 
            Core_End_Customer_Street_Addr_Line2_Txt__c = 'Trichy2', Core_End_Customer_City_Nm__c = 'San Francisco', 
            Core_End_Customer_Country_Subdivision_Nm__c = 'California',
            Core_End_Customer_Postal_Cd__c = '54321', Core_End_Customer_Country_Nm__c = 'USA', 
            Core_Military_Aerospace_Gvrnmt_Use_Ind__c = 'Yes',
            Core_Opportunity_Decision_Dt__c = '11/13/2050', 
            Core_First_Customer_Ship_Dt__c = '11/13/2050',
            Core_Production_End_Dt__c = '11/13/2050', Core_Vertical_Market_Nm__c = 'Sports',
            Core_Intel_Platform_Nm__c = 'Broadwell', Core_Product_Segment_Nm__c = 'Client Computing', 
            Core_Product_Application_Nm__c = 'Desktop', Core_Manufacturing_Region_Cd__c = 'APJ',
            Core_Design_Solution_Network_Ind__c = 'Yes', Core_End_Customer_Contact_Title_Txt__c = 'Mr', 
            Core_End_Customer_Contact_Nm__c = 'RajaDinakaran', Core_End_Customer_Contact_Email_Txt__c   = 'rd2@rd.com', 
            Core_End_Customer_Contact_Phone_Txt__c = '9940837430'),
            
            //Product
            new Core_Design_Registration_Stage__c(Core_Batch_ID__c = desRegBatch7432.Id, Core_Group_Id__c = '1', 
            Core_Header_Or_Product_Ind__c = 'Product', 
            Core_Design_Registration_Line_Id__c = insertDesignProduct.Name, 
            Core_Partner_Tracking_Cd__c = '7430', Core_Product_Id__c = 'Intel Atom® CE4275 Media Processor', 
            Core_Full_Year_Qty__c = '6',Core_Target_Resale_Amt__c = '11', 
            Core_Cancelled_Ind__c = '', Core_Registration_Number_Id__c = '', Core_Owner_Txt__c = '', Core_Product_Group_Nm__c = '', 
            Core_Design_Registration_Nm__c = '', Core_Design_Registration_Dsc__c = '', Core_Opportunity_Volume_Cnt__c = '', 
            Core_Partner_FAE_Nm__c = '', Core_End_Customer_Nm__c = '', Core_End_Customer_Street_Addr_Line1_Txt__c = '', 
            Core_End_Customer_Street_Addr_Line2_Txt__c = '', Core_End_Customer_City_Nm__c = '', Core_End_Customer_Country_Subdivision_Nm__c = '',
            Core_End_Customer_Postal_Cd__c = '', Core_End_Customer_Country_Nm__c = '', Core_Military_Aerospace_Gvrnmt_Use_Ind__c = '',
            Core_Opportunity_Decision_Dt__c = '', Core_First_Customer_Ship_Dt__c = '', Core_Production_End_Dt__c = '', Core_Vertical_Market_Nm__c = '',
            Core_Intel_Platform_Nm__c = '', Core_Product_Segment_Nm__c = '', Core_Product_Application_Nm__c = '', Core_Manufacturing_Region_Cd__c = '',
            Core_Design_Solution_Network_Ind__c = '', Core_End_Customer_Contact_Title_Txt__c = '', Core_End_Customer_Contact_Nm__c = '',
            Core_End_Customer_Contact_Email_Txt__c   = '', Core_End_Customer_Contact_Phone_Txt__c = '') };
        
        
            insert designRegStage7432;  
            
        
            Core_DDR_Stage_Validator checkValidations7432 = new Core_DDR_Stage_Validator();
            checkValidations7432.checkValidations(designRegStage7432);  
        
        //For invalid date fields    
        //Header
        List<Core_Design_Registration_Stage__c> designRegStage7433 = new List<Core_Design_Registration_Stage__c>{
            new Core_Design_Registration_Stage__c(Core_Batch_ID__c = desRegBatch7430.Id, Core_Group_Id__c = '1', 
            Core_Header_Or_Product_Ind__c = 'Header', Core_Design_Registration_Line_Id__c = '', 
            Core_Partner_Tracking_Cd__c = '', Core_Product_Id__c = '', Core_Full_Year_Qty__c = '',Core_Target_Resale_Amt__c = '', 
            Core_Cancelled_Ind__c = '', Core_Registration_Number_Id__c = '', Core_Owner_Txt__c = 'disti1user1@disti1.com', 
            Core_Product_Group_Nm__c = 'Embedded/IOT', Core_Design_Registration_Nm__c = 'Test Project 1', 
            Core_Design_Registration_Dsc__c = 'For demo Insert Scenario', Core_Opportunity_Volume_Cnt__c = '5', 
            Core_Partner_FAE_Nm__c = ' Test FAE 1', Core_End_Customer_Nm__c = 'Test Customer 1', 
            Core_End_Customer_Street_Addr_Line1_Txt__c = 'Millbare', 
            Core_End_Customer_Street_Addr_Line2_Txt__c = 'Trichy2', Core_End_Customer_City_Nm__c = 'San Francisco', 
            Core_End_Customer_Country_Subdivision_Nm__c = 'California',
            Core_End_Customer_Postal_Cd__c = '54321', Core_End_Customer_Country_Nm__c = 'USA', 
            Core_Military_Aerospace_Gvrnmt_Use_Ind__c = 'Yes',
            Core_Opportunity_Decision_Dt__c = 'test', 
            Core_First_Customer_Ship_Dt__c = '11/13/2050',
            Core_Production_End_Dt__c = '11/13/2050', Core_Vertical_Market_Nm__c = 'Sports',
            Core_Intel_Platform_Nm__c = 'Broadwell', Core_Product_Segment_Nm__c = 'Client Computing', 
            Core_Product_Application_Nm__c = 'Desktop', Core_Manufacturing_Region_Cd__c = 'APJ',
            Core_Design_Solution_Network_Ind__c = 'Yes', Core_End_Customer_Contact_Title_Txt__c = 'Mr', 
            Core_End_Customer_Contact_Nm__c = 'RajaDinakaran', Core_End_Customer_Contact_Email_Txt__c   = 'rd@rd.com', 
            Core_End_Customer_Contact_Phone_Txt__c = '9940837430'),
            
            //Product
            new Core_Design_Registration_Stage__c(Core_Batch_ID__c = desRegBatch7430.Id, Core_Group_Id__c = '1', 
            Core_Header_Or_Product_Ind__c = 'Product', Core_Design_Registration_Line_Id__c = '', 
            Core_Partner_Tracking_Cd__c = '7430', Core_Product_Id__c = 'Intel Atom® CE4275 Media Processor', 
            Core_Full_Year_Qty__c = '6',Core_Target_Resale_Amt__c = '10', 
            Core_Cancelled_Ind__c = '', Core_Registration_Number_Id__c = '', Core_Owner_Txt__c = '', Core_Product_Group_Nm__c = '', 
            Core_Design_Registration_Nm__c = '', Core_Design_Registration_Dsc__c = '', Core_Opportunity_Volume_Cnt__c = '', 
            Core_Partner_FAE_Nm__c = '', Core_End_Customer_Nm__c = '', Core_End_Customer_Street_Addr_Line1_Txt__c = '', 
            Core_End_Customer_Street_Addr_Line2_Txt__c = '', Core_End_Customer_City_Nm__c = '', Core_End_Customer_Country_Subdivision_Nm__c = '',
            Core_End_Customer_Postal_Cd__c = '', Core_End_Customer_Country_Nm__c = '', Core_Military_Aerospace_Gvrnmt_Use_Ind__c = '',
            Core_Opportunity_Decision_Dt__c = '', Core_First_Customer_Ship_Dt__c = '', Core_Production_End_Dt__c = '', Core_Vertical_Market_Nm__c = '',
            Core_Intel_Platform_Nm__c = '', Core_Product_Segment_Nm__c = '', Core_Product_Application_Nm__c = '', Core_Manufacturing_Region_Cd__c = '',
            Core_Design_Solution_Network_Ind__c = '', Core_End_Customer_Contact_Title_Txt__c = '', Core_End_Customer_Contact_Nm__c = '',
            Core_End_Customer_Contact_Email_Txt__c   = '', Core_End_Customer_Contact_Phone_Txt__c = '') };
        
        
            insert designRegStage7433;    
            
            Core_DDR_Stage_Validator checkValidations7433 = new Core_DDR_Stage_Validator();
            checkValidations7433.checkValidations(designRegStage7433);  
            
        }
}