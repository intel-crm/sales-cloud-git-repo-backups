public class testtable {
	@auraEnabled(cacheable = true)
    public static List<Account> accountList(){
        return [select id, name from Account limit 10];
    }
}