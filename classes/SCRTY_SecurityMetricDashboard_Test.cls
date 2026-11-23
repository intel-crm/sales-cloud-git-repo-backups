@isTest(SeeAllData=false)
private class SCRTY_SecurityMetricDashboard_Test {
    static testmethod void testExecuteSoql(){
        String soql = 'Select Id from Profile where PermissionsViewAllData = true limit 1';
        String condition;
        List<Id> ids = new List<Id>();
        List<Sobject> sObjList = SCRTY_SecurityMetricDashboardController.executeSOQL(soql,ids,condition);
        
        condition = ' Where isActive = true and ProfileId=:';
        ids.add(sObjList[0].Id);
        sObjList = SCRTY_SecurityMetricDashboardController.executeSOQL('Select Id from User',ids,condition);

    }
}