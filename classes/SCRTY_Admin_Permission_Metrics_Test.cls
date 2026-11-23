@isTest(SeeAllData=false)
private class SCRTY_Admin_Permission_Metrics_Test {
    
       static testmethod void testSecurityDashboard(){
        
        Test.startTest();
        
        Id batchId = Database.executeBatch(new SCRTY_Admin_Permission_Metrics_Batch(),200);
         Test.stopTest();
            }
     static testmethod void testTimestampBatchScheduable(){
        Test.startTest();
         String chron = '0 0 12 1 1/3 ? *' ;
        System.schedule('Test Security Dashboard',chron,new SCRTY_Admin_Permission_Metrics_Batch());
       Test.stopTest();
            }
    static testmethod void testexecuteSOQL(){
        String soql='Select id,PermissionsApiEnabled from permissionset';
        list<id>ids=new list<id>{'0PS1J00000034lMWAQ','0PS1J000000352SWAQ'};
        
        String condition=NULL;
        List<sObject> result=SCRTY_Admin_Permission_Metrics.executeSOQL(soql,ids,condition);
    }
}