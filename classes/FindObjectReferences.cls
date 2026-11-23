public class FindObjectReferences {
    public static void findReferences() {
        String objectName='Core_Account_ERPM_Engagement__c';
        List<ApexClass> apexClasses = [SELECT Id, Name, Body FROM ApexClass];
        for (ApexClass apexClass : apexClasses) {
            if (apexClass.Body != null && apexClass.Body.contains(objectName)) {
                System.debug('Object found in class: ' + apexClass.Name);
            }
        }
    }
}