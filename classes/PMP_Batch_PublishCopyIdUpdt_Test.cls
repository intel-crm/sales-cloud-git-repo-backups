@isTest
public  class PMP_Batch_PublishCopyIdUpdt_Test {
    
    @testSetup
    public static void generateData(){
       
        
        List<PMP_Partner_Offering__c> offList = New List<PMP_Partner_Offering__c >();
        PMP_Partner_Offering__c offering = PMP_TestDataUtility.createOffering('Testoffering', 'Public Content','off desc',null,false,'draft','taglineTest' );
        PMP_Partner_Offering__c offering1 = PMP_TestDataUtility.createOffering('Testoffering12', 'Public Content','off desc',null,false,'Published','taglineTest' );
        offering.PMP_Partner_Offering_Nm__c = 'Test1232';
        offering.PMP_Partner_Offering_Start_Dt__c = date.today() -1;
        
        offering.PMP_Partner_Offering_Dsc__c = 'Test';
        offering1.PMP_Partner_Offering_Dsc__c = 'Test';
        offering1.PMP_Partner_Offering_Nm__c = 'Test12';
        offering1.PMP_Partner_Offering_Start_Dt__c = date.today() -1;
        offering1.PMP_Business_Segment_Nm__c = 'IoT';
        
        
        offList.add(offering);
        offList.add(offering1);
        insert offList;
		offering1.PMP_Working_Copy_Id__c = offering.Id;
        update offering1;
        
    }


    public static testMethod void PMP_Batch_PublishCopyIdUpdt(){
        Test.startTest();
            PMP_Batch_PublishCopyIdUpdt obj = new PMP_Batch_PublishCopyIdUpdt(); 
            Database.executeBatch(obj);
        Test.stopTest();    
    }
}