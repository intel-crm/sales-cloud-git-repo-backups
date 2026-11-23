public class AccountListController {

    public List<Account> getAccounts()
    {
        //ApexPages.StandardSetController controller = new ApexPages.StandardSetController(Database.QueryLocator('select id from Account'));
        ApexPages.StandardSetController controller = new ApexPages.StandardSetController(Database.query('select id from Account'));
        //ApexPages.StandardController controller = new ApexPages.StandardController([select id from Account]);
        return controller.getRecords();
    }
    
}