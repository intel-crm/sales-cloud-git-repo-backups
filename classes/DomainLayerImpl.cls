public class DomainLayerImpl {
    public static void updateAccountAndContact(List<Account> accountls, String Name)
    {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        
        Accounts accounts = (Accounts) Application.Domain.newInstance( accountls );
                
        for(Account acc : accountls) {
         if(acc.Contacts!=null && acc.Contacts.size()>0) {
            for(Contact con : acc.Contacts) {
                con.LastName = con.LastName+' '+Name+' TestCON';
                uow.registerDirty(con);
            }
        }
            acc.Name = acc.Name+' '+Name+' TestACC';
            uow.registerDirty(acc);
    }
        uow.commitWork();
        System.debug('Number of script statements used so far : ' + Limits.getDmlStatements());
    }          
}