public class ACM_CNDA_RecordID_POC {

    @AuraEnabled(cacheable=true)
    public static void getData()
    {
        System.debug('Fetch Data');
    }
}