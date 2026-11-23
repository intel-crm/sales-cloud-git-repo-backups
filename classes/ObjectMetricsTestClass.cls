@isTest
public class ObjectMetricsTestClass {
    
    public static testMethod void userLicenseTest(){
    Test.startTest();
    ObjectMetrics.getObjectNames();
    ObjectMetrics.getUserLicence();   
    Test.stopTest();
        System.assert(ObjectMetrics.getUserLicence().size()>0);
        
    }
    public static testMethod void objectDashboardTest(){
     Test.startTest();
    Map<String,List<User>> allowedUsers=ObjectMetrics.allowedUsers('Opportunity');
   
    Test.stopTest();
        System.assert(allowedUsers.size()>0);        
    }
    public static testMethod void securtiyTypeDashboardTest(){
     Test.startTest();
    Map<String,List<User>> permissionTypeUserMap=ObjectMetrics.getUsers(true);
   
    Test.stopTest();
        System.assert(permissionTypeUserMap.size()>0);        
    }
}