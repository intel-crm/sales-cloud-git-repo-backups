public class ShowBlades {
	@AuraEnabled(cacheable=true)
    public static void fetchrecords(String Id) {
        System.debug(Id);
        System.debug(System.Label.IPA_MDF_bnft_Description);
    }
}