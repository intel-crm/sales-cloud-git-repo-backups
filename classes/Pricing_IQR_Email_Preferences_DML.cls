public class Pricing_IQR_Email_Preferences_DML {
    public static void savePreferences(List<Pricing_IQR_Email_Preferences__c> iep)
    {
        
        fflib_ISObjectUnitOfWork uow = Pricing_IQR_Application.UnitOfWork.newInstance();
        
        Pricing_IQR_Email_Preferences_Const iqriep = (Pricing_IQR_Email_Preferences_Const) Pricing_IQR_Application.Domain.newInstance( iep );
        uow.registerUpsert(iep);
        uow.commitWork();
        System.debug('Number of script statements used so far : ' + Limits.getDmlStatements());
    }

}