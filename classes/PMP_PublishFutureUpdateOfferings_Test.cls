@isTest
//IPA2.0 As part of TWC729-7977 commented the entire class
public class PMP_PublishFutureUpdateOfferings_Test {
    // @testSetup 
    // static void setup(){
        
        
    //    List<PMP_Partner_Offering__c> offObjList = new List<PMP_Partner_Offering__c>();
        
    //     User u1=PMP_TestDataUtility.createUser(true);
                 
    //     PMP_Product_API_Key__c pmp = new PMP_Product_API_Key__c();
    //     pmp.name = 'API_Key';
    //     pmp.PMP_API_KEY__c = 'efm9JpXElhgutg8t8HuHTYWc4tVvcvWk';
    //     insert pmp;
    //     Integer idx;
    //        for(idx=1;idx<7;idx++){
    //             PMP_Partner_Offering__c offObj = new PMP_Partner_Offering__c();
    //             offObj.PMP_Partner_Offering_End_Dt__c = Date.today().addDays(idx);
    //             offObj.PMP_Partner_Offering_Lifecycle_Status_Nm__c = 'Approved';
    //             offObj.PMP_Partner_Offering_Sync_Status_Nm__c = null;
    //             offObj.PMP_Partner_Offering_Start_Dt__c = date.today();
    //             offObj.PMP_Offering_Status_Update_Dt__c = date.today().addDays(-4);
    //             offObj.PMP_Intel_Admin_Id__c = userinfo.getuserid();
    //             offObj.ownerid = u1.id;
    //             offObj.PMP_Partner_Offering_Dsc__c = 'Sample';
    //             offObj.PMP_Review_Comment_Txt__c = 'Sample Text';
    //             offObj.PMP_Partner_Offering_Visibility_Nm__c = 'Public Content';
                
    //             offObj.PMP_Is_Published_Ind__c = true;
                
    //             offObjList.add(offObj);
    //         }  
    //     Document document = PMP_TestDataUtility.createDocument();
        
        
    //     PMP_Partner_Offering__c offObj1 = new PMP_Partner_Offering__c();
    //     offObj1.PMP_Partner_Offering_End_Dt__c = Date.today().addDays(idx);
    //     offObj1.PMP_Partner_Offering_Lifecycle_Status_Nm__c = 'Approved';
    //     offObj1.PMP_Partner_Offering_Sync_Status_Nm__c = null;
    //     offObj1.PMP_Partner_Offering_Start_Dt__c = date.today();
    //     offObj1.PMP_Offering_Status_Update_Dt__c = date.today().addDays(-4);
    //     offObj1.PMP_Intel_Admin_Id__c = userinfo.getuserid();
    //     //offObj1.PMP_Working_Copy_Id__c =offering1.id;
    //     offObj1.ownerid = u1.id;
    //     offObj1.PMP_Partner_Offering_Dsc__c = 'Sample';
    //     offObj1.PMP_Review_Comment_Txt__c = 'Sample Text';
    //     offObj1.PMP_Partner_Offering_Visibility_Nm__c = 'Intel Only Content';
    //     offObj1.PMP_Partner_Offering_Nm__c = 'Test';
    //     offObj1.PMP_Is_Published_Ind__c = false;
                
    //     offObjList.add(offObj1);
        
    //     insert offObjList; 
      
	// 	 Account acc1 = PMP_TestDataUtility.createIntelAccount('TestAccount1', PMP_TestDataUtility.intel_Account_Record_Type, true);
        
    //     Contact con1 = PMP_TestDataUtility.createContact(acc1.id,true);
       
             
    //     PMP_Company__c cmp1 = PMP_TestDataUtility.createCompanyInformation('TestCompany1', acc1.Id, true);
                                
    //     PMP_Partner_Offering__c offering1 = PMP_TestDataUtility.createOffering('TestDuplicateOffering1','Intel Only Content', 
    //                                                                              'TestDuplicate',cmp1.Id, true,'Draft','');
    //     PMP_Partner_Offering_Category__c offCategory = PMP_TestDataUtility.getPMPOfferingCategory(offering1.id);
        
    //     PMP_Partner_Offering_Specification__c offSpecs = PMP_TestDataUtility.getPMPOfferingSpecification(offering1.id);
        
    //     PMP_Partner_Offering_Translation__c offTranslation = PMP_TestDataUtility.createOfferingTranslation(offering1.id,'testTranslation');
    //     if(offTranslation!=null){
    //        insert offTranslation ;
    //     }         
    //     offering1.PMP_Working_Copy_Id__c =  offObjList[0].id;
    //     update offering1;
    //     offering1.Name = 'repulish';
    //     offering1.PMP_Working_Copy_Id__c =  offObjList[0].id;
    //     update offering1;
        
 
    // }
    // static testmethod void test(){
    //     Test.startTest();
    //     try
    //     {
    //         Account a = new Account();
    //         insert a;
    //     }
    //     Catch(exception e)
    //     {
            
    //     }
    //     PMP_PublishFutureUpdateOfferings obj = new PMP_PublishFutureUpdateOfferings();
    //     ID batchprocessid = DataBase.executeBatch(obj);
        
    //     system.assertNotEquals(batchprocessid,Null);
    //     Test.stopTest();
    // }
}