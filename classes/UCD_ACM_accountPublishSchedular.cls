public class UCD_ACM_accountPublishSchedular implements Schedulable{
    private static UCD_ACM_ServiceContracts.IAccountService accountServiceInstance = UCD_ACM_AccountService.getInstance();

    public void execute(SchedulableContext SC) {
        //accountServiceInstance.publishAccount();
   }
}