public interface IAccountService {
    List<Account> getAccountsForDeactivation(Datetime toDate, Datetime fromDate);

    Boolean deactivateAccount(Set<Id> accountIds, String deactivationReason);
}