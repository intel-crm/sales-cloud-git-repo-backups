@isTest
public class Core_MDF_Calendar_Utility_Test {

    @TestSetup
    static void createTestData(){

        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1];
        // Creating User with utility class 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        UserRole ur = [Select Id, Name From UserRole WHERE Name = 'Admin' LIMIT 1];
        usr.UserRoleId =ur.Id ;
        usr.LastName = 'SysAdmin';
        usr.profileId = sysAdminProfile.Id;
        Database.insert(usr);
    }

    @isTest
    static void testGetFiscalQuarterWeekPeriods() {

        User usr = [Select Id, lastName from User where lastName = 'SysAdmin' limit 1];
        System.runAs(usr)   {
            Test.startTest();
        
            Date inputDate = Date.today();
            List<Period> result = Core_MDF_Calendar_Utility.getFiscalQuarterWeekPeriods(inputDate);
            Assert.areNotEqual(0, result.size());
            Assert.areEqual(13, result.size());

            Test.stopTest();
        }
    }
    
    @isTest
    static void testMapMonthAndWeekPeriods() {

        User usr = [Select Id, lastName from User where lastName = 'SysAdmin' limit 1];
        System.runAs(usr) {
            Test.startTest();

            List<Period> testWeeks = [SELECT Id, Type, Number, StartDate, EndDate FROM Period WHERE Type = 'Week' LIMIT 13];
            Map<String, Period> mappedWeeks = Core_MDF_Calendar_Utility.mapMonthAndWeekPeriods(testWeeks);
            Assert.areEqual(13, mappedWeeks.size());

            Test.stopTest();
        }
    }

    @isTest
    static void testGetWeekNumberOfQuarter() {
        Assert.areEqual(1, Core_MDF_Calendar_Utility.getWeekNumberOfQuarter(1));
        Assert.areEqual(13, Core_MDF_Calendar_Utility.getWeekNumberOfQuarter(13));
        Assert.areEqual(1, Core_MDF_Calendar_Utility.getWeekNumberOfQuarter(14));
        Assert.areEqual(5, Core_MDF_Calendar_Utility.getWeekNumberOfQuarter(18));
    }

    @isTest
    static void testGetStandardQuarterEndDate() {
        User usr = [Select Id, lastName from User where lastName = 'SysAdmin' limit 1];
        System.runAs(usr) {
            Test.startTest();

            Date q1Date = Date.newInstance(2024, 2, 15);
            Date q1End = Core_MDF_Calendar_Utility.getStandardQuarterEndDate(q1Date);
            Assert.areEqual(Date.newInstance(2024, 3, 31), q1End);
        }
    }
}