public class AsyncApexJobUsageAndLimit {

    @AuraEnabled(cacheable=true)
    public static Integer getOrgLimits(){
        List<sobject> usage = [Select Id from AsyncApexJob Where Status != 'Completed' And Status != 'Failed'];
        Integer size = usage.size();
        return size;
    }
}