@istest
public class Core_IPS_AdminUtilityTest {
    static testmethod void AdminUtilitytestMethod1() {
        Profile ps = [select id, name from Profile where name = 'System Administrator'
            limit 1
        ];
        ID recordTypeId = schema.sobjecttype.Account.getrecordtypeinfosbyname().get('Intel Account').getRecordTypeId();
        UserRole role=new UserRole();
        role.name='CEO';
        
        insert role;
        
        User sysAdimUser = TestUtilities.getUser();
        sysAdimUser.ProfileId = ps.id;
        sysAdimUser.userroleid=role.id;
        
        insert sysAdimUser;
        
        System.runAs(sysAdimUser) {
            List < Account > ListOfAccounts = TestUtilities.getAccountsList(1);
            ListOfAccounts.get(0).OwnerId = sysAdimUser.id;
            //Ashutosh _ US103890
            ListOfAccounts.get(0).Core_IPS_Active__c = true;
            ListOfAccounts.get(0).Core_B2B_Entitlement__c = true;
            ListOfAccounts.get(0).Core_CNDA_Number__c = '12523';
            insert ListOfAccounts;
            System.assert(ListOfAccounts[0].Id != null, 'Record not created');
            List < Contact > ListOfContacts = TestUtilities.getListOfContact(1);
            for (Contact ContactRec: ListOfContacts) {
                ContactRec.Accountid = ListOfAccounts.get(0).Id;
                ContactRec.Core_IPS_Active__c = true;
                
            } 
            insert ListOfContacts;
            System.assert(ListOfContacts[0].id != null, 'Record not created');
            // Create Product
            List < Product2 > ListOfProducts = TestUtilities.getListOfProduct(1);
            for (Product2 Product: ListOfProducts) {
                Product.Core_Hierarchy_ID__c = '43';
                Product.Core_Hierarchy_Name__c = 'ProdHierarchyName';
                Product.Core_Unique_ID__c = 'Product12345';
                Product.Core_Code_Name__c = 'ProductCoreCodeName';

            }
            insert ListOfProducts;
            System.assert(ListOfProducts[0].id != null, 'Record not created');
            // Create Support Org
            List < Core_IPS_Product_Organization__c > ListOfSupportOrg = TestUtilities.getListOfSupportOrg(2);
            insert ListOfSupportOrg;
            System.assert(ListOfSupportOrg != null, 'Record not created');
            // Create Supported product
            List < Core_IPS_Supported_Product__c > ListOfSupportedProduct = TestUtilities.getListOfSupportedProduct(1);
            for (Core_IPS_Supported_Product__c SupportedProduct: ListOfSupportedProduct) {
                SupportedProduct.Core_Product__c = ListOfProducts.get(0).id;
                SupportedProduct.Core_Product_Organization__c = ListOfSupportOrg.get(0).id;

            }
            insert ListOfSupportedProduct;
            System.assert(ListOfSupportedProduct[0].id != null, 'Record not created');

            //Added by Sunil 
            //Product2 prod =  TestUtilities.getProduct();
            //insert Prod;

            Asset asst = TestUtilities.getAsset();
            asst.Core_Supported_Product__c = ListOfSupportedProduct[0].Id;
            Asst.product2Id = ListOfProducts.get(0).id;
            Asst.Core_product_organization__c = ListOfSupportOrg.get(0).id;
            insert Asst;
            System.assert(Asst.Id != null, 'Record not created');
            //End By sunil                
            // Create Case
            List <
                case >ListOfCases = TestUtilities.getListOfCases(10);
            for (Case CaseRec: ListOfCases) {
                CaseRec.ContactId = ListOfContacts.get(0).id;
                CaseRec.accountId = ListOfAccounts.get(0).Id;
                CaseRec.AssetId = Asst.id;
                CaseRec.Core_IPS_Supported_Product__c = ListOfSupportedProduct.get(0).id;
                CaseRec.Core_IPS_Product_Org1__c = ListOfSupportOrg.get(0).id;
            }
            Core_IPS_Master_Issue_Category__c MasterCaseCategory = TestUtilities.getMasterCaseCategories();
            MasterCaseCategory.Core_type__c = 'Case Category';
            insert MasterCaseCategory;
            System.assert(MasterCaseCategory.Id != null, 'Record not created');

            Core_IPS_Master_Issue_Category__c MasterCategory = TestUtilities.getMasterCaseCategories();
            MasterCategory.Core_Master_Issue_Category__c = MasterCaseCategory.id;
            insert MasterCategory;
            System.assert(MasterCategory.Id != null, 'Record not created');
            Core_IPS_Product_Issue_Category__c caseCat = TestUtilities.getCaseCategories();
            caseCat.Core_Issue_Category_Name__c = MasterCategory.id;
            caseCat.Core_Type__c = 'Case Category';
            insert caseCat;
            System.assert(caseCat.Id != null, 'Record not created');

            Core_IPS_Product_Issue_Category__c subCategory = TestUtilities.getCaseCategories();
            subCategory.Core_Issue_Sub_Category_Name__c = MasterCategory.id;
            subCategory.Core_Type__c = 'Case Subcategory';
            insert subCategory;
            System.assert(subCategory.Id != null, 'Record not created');
            ListOfCases.get(0).Core_Case_Issue_Category__c = caseCat.id;
            ListOfCases.get(0).Core_case_issue_sub_category__c = subCategory.id;
            insert ListOfCases;
            System.assert(ListOfCases[0].Id != null, 'Record not created');
            List < Core_IPS_Error_Code__c > errorCodes = TestUtilities.getListOfIpsErrorCodes();
            insert errorCodes;
            System.assert(errorCodes[0].Id != null, 'Record not created');
            List < Core_IPS_Environment_Variables__c > ListOfenvVars = new List < Core_IPS_Environment_Variables__c > ();
            for (integer i = 0; i < 7; i++) {
                Core_IPS_Environment_Variables__c envVar = TestUtilities.getEnvironmentalDetailMaster();
                envVar.Core_Product_Organization__c = ListOfSupportOrg.get(0).id;
                ListOfenvVars.add(envVar);
            } 
            ListOfenvVars[0].Core_Datatype__c = 'picklist';
            ListOfenvVars[1].Core_Datatype__c = 'text';
            ListOfenvVars[2].Core_Datatype__c = 'textarea';
            ListOfenvVars[3].Core_Datatype__c = 'Multi Select';
            ListOfenvVars[4].Core_Datatype__c = 'text (255)';
            ListOfenvVars[5].Core_Datatype__c = 'textarea (5000)';
            ListOfenvVars[6].Core_Datatype__c = 'boolean';
            insert ListOfenvVars;

            List < Core_IPS_Environment_Details__c > lstenvDetal = new List < Core_IPS_Environment_Details__c > ();
            Core_IPS_Environment_Details__c envDetal = new Core_IPS_Environment_Details__c();
            envDetal.Name = 'Issue Resolution List';
            envDetal.Core_Question__c = 'intel';
            envDetal.Core_Answer__c = 'TestAnswer1;TestAns2;Testans3';
            envDetal.Core_Case__c = ListOfCases[0].id;
            lstenvDetal.add(envDetal);
            Core_IPS_AdminUtility.insertEnvDetailsToCreate(lstenvDetal);
			
			/*Added By Yogesh Sharma Start*/
				List<Core_IPS_Response__c> responseList = TestUtilities.getCoreResponseRecords(2);
				for(Core_IPS_Response__c cr : responseList){
					cr.Core_IPS_Case__c = ListOfCases.get(0).Id;
				}
				Core_IPS_AdminUtility.insertEnvDetailsToCreate(responseList);
			
				//insert responseList;
				Core_IPS_AdminUtility.DeleteEnvDetails(responseList);
			    
			    //List < Account > ListOfAccounts1 = TestUtilities.getAccountsList(1);
	            //insert ListOfAccounts1;
	      		Case cs=TestUtilities.getCase();
            	insert cs;
            
            	List<Core_IPS_Environment_Details__c> envResponses=TestUtilities.getEnvironmentDetailResponses(10);
            	for(Core_IPS_Environment_Details__c envResp:envResponses){
                	envResp.Core_Case__c = cs.id;
            	}
            	insert envResponses;
	      		
	      		Core_IPS_AdminUtility.DeleteEnvDetails(envResponses);
	     		
	     		Map<string,ID> MapRecordtype = new Map<string,ID>();
        		for(Recordtype Rt:[Select ID,Name from Recordtype where sobjectType = 'Core_IPS_MAP_PAR__c'])
        		{  
              		MapRecordtype.put(Rt.Name,Rt.ID);
        		}        
        		//Create PAR
        		Core_IPS_MAP_PAR__c par = TestUtilities.getMapPar();
        		par.RecordTypeId = MapRecordtype.get('PAR');
            	insert par;
        		           
		        //Create Core_IPS_MAP_Account__c
		        Core_IPS_MAP_Account__c ipsmapAcc = TestUtilities.getIPSMAPAccount();
		        
	            ipsmapAcc.Core_MAP_PAR__c = par.Id;
	            ipsmapAcc.Core_Account__c = ListOfAccounts[0].Id;
	            //insert ipsmapAcc;
	        	
	        	Core_IPS_AdminUtility.insertProdAccessAccJOs(new List<Core_IPS_MAP_Account__c>{ipsmapAcc});
	        	
	        	List<Core_IPS_Supported_Product__c> SuppProductList = new List<Core_IPS_Supported_Product__c> ();
	        	List<Product2> ProductList = new List<Product2>();
	        	Core_IPS_Product_Organization__c prodOrg = new Core_IPS_Product_Organization__c();
	        	
	        	// inserting products
		        ProductList = TestUtilities.getListOfProduct(3);
		        insert ProductList;
		        System.assert(ProductList <> null, 'Record not created');
		        // inserting product org
		        prodOrg = TestUtilities.getSupportOrg();
		        insert prodOrg;
		        System.assert(prodOrg <> null, 'Record not created');
		        
	        	// inserting Supported Product 
        		SuppProductList = TestUtilities.getListOfSupportedProduct(3);
		        Integer i = 0; 
		        for(Core_IPS_Supported_Product__c SupportedProductRecord: SuppProductList){                
		                SupportedProductRecord.Core_Product__c = ProductList.get(i).id;
		                SupportedProductRecord.Core_Product_Organization__c = prodOrg.id;
		                 i++;                     
		        } 
		        insert SuppProductList;
			    
			    // inserting Product Access Header 
			    Core_IPS_MAP_PAR__c mapRec = TestUtilities.getMapPar();
			    mapRec.Core_Product_Organization__c = prodOrg.id;
			    mapRec.RecordTypeId  = schema.sobjecttype.Core_IPS_MAP_PAR__c.getrecordtypeinfosbyname().get('MAP').getRecordTypeId(); //'012210000004IHY';
			    insert mapRec;
			    System.assert(mapRec <> null, 'Record not created');
			    
			    // inserting Prodcut Access Product
        		List<Core_IPS_MAP_Product__c> prodJuncList= new List<Core_IPS_MAP_Product__c>();
        		for(Integer j=0;j<1;j++){
            		Core_IPS_MAP_Product__c mapProd = new Core_IPS_MAP_Product__c();
            		mapProd.Core_MAP_PAR__c = mapRec.id;
            		mapProd.Core_MAP_Supported_Product__c = SuppProductList[j].id;
            		prodJuncList.add(mapProd);
       			}
       			//insert prodJuncList; 
       			Core_IPS_AdminUtility.insertProdAccessProdJOs(prodJuncList);
            	//Ashutosh - US103890
                List<Core_IPS_Case_Interested_Party__c> ListOfInterestedParty = TestUtilities.getInternalInterestedParties(2);//Ashutosh-us103988 - change to 2 parties
                ListOfInterestedParty.get(0).Case__c = ListOfCases.get(0).Id;
                ListOfInterestedParty.get(0).User__c = sysAdimUser.Id;
                //ListOfInterestedParty.get(0).Contact__c = ListOfContacts.get(0).Id;
                ListOfInterestedParty.get(0).Type__c = 'Internal';
                
                ListOfInterestedParty.get(1).Case__c = ListOfCases.get(0).Id;
                //ListOfInterestedParty.get(1).User__c = ListOfExternalUsers.get(1).Id;
                ListOfInterestedParty.get(1).Contact__c = ListOfContacts.get(0).Id;
                ListOfInterestedParty.get(1).Type__c = 'External';
                
            	
        		Core_IPS_AdminUtility.insertInterestedParties(ListOfInterestedParty);
            	System.assertEquals(true,ListOfInterestedParty.get(0) != null);
	        }
        
			/*Added By Yogesh Sharma Stop*/ 
        
    }
    static testmethod void AdminUtilitytestMethod2() {
        List <case >ListOfCases = TestUtilities.getListOfCases(1);

        insert ListOfCases;
        list < Core_IPS_GEC_Details__c > GECList = new list < Core_IPS_GEC_Details__c > ();


        Core_IPS_GEC_Details__c GEC1 = new Core_IPS_GEC_Details__c();
        GEC1.Core_IPS_GEC_Question1__c = 'THIS IS TEST CLASS';
        GEC1.Core_IPS_GEC_Question2__c = 'THIS IS TEST CLASS';
        GEC1.Core_IPS_Case__c = ListOfCases[0].Id;
        GECList.add(GEC1);

        Core_IPS_AdminUtility.insertGECList(GECList);
    }
     /*static testmethod void AdminUtilitytestMethod3() {
        Profile ps = [select id, name from Profile where name = 'System Administrator'
            limit 1
        ];
        User sysAdimUser = TestUtilities.getUser();
        sysAdimUser.ProfileId = ps.id;
        insert sysAdimUser;
        System.runAs(sysAdimUser) {
            List < Account > ListOfAccounts = TestUtilities.getAccountsList(1);
            insert ListOfAccounts;
      
        Core_IPS_MAP_PAR__c  map1 = new Core_IPS_MAP_PAR__c();
        //map1.Core_Product_Organization__c = prodOrg.Id;
        // map1.core_name__c = reqField.Core_Name__c;
        map1.core_name__c = 'hghhhh';
        map1.RecordTypeId = System.Label.MAP_Header_Record_Type_ID;
        map1.Core_Submitter_Comments__c='sssssssssssss';
        insert map1;
        List<Core_IPS_Map_Par_Line_Item__c> mapLineItems = new List<Core_IPS_Map_Par_Line_Item__c>();
        Core_IPS_Map_Par_Line_Item__c lineItem = new Core_IPS_Map_Par_Line_Item__c();
            
            lineItem.Core_Account__c = ListOfAccounts[0].id;
            //lineItem.Core_Supported_Product__c=mapProdToSupProd.get(wl.prod.id).id;                
            lineItem.Core_MAP_PAR__c = map1.id;
            lineItem.RecordTypeId = System.Label.MAP_LineItem_Record_Type_ID;
                mapLineItems.add(lineItem);

        Core_IPS_AdminUtility.insertLineItems(mapLineItems);
        }
    }
    */
    
}