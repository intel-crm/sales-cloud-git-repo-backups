public class Pricing_Quote_Team_DML {
    public static void updateQTMS(List<Pricing_Quote_Team__c> qtmLst)
    {
        fflib_ISObjectUnitOfWork uow = Pricing_IQR_Application.UnitOfWork.newInstance();
        
        Pricing_Quote_Team_Const qtms = (Pricing_Quote_Team_Const) Pricing_IQR_Application.Domain.newInstance( qtmLst );
        uow.registerDirty(qtmLst);
        uow.commitWork();
        System.debug('Number of script statements used so far : ' + Limits.getDmlStatements());
    }

     public static void insertQTMS(List<Pricing_Quote_Team__c> qtmLst)
    {
        fflib_ISObjectUnitOfWork uow = Pricing_IQR_Application.UnitOfWork.newInstance();
        
        Pricing_Quote_Team_Const qtms = (Pricing_Quote_Team_Const) Pricing_IQR_Application.Domain.newInstance( qtmLst );
        uow.registerNew(qtmLst);
        uow.commitWork();
        System.debug('Number of script statements used so far : ' + Limits.getDmlStatements());
    }
    
    public static void deleteQTMS(List<Pricing_Quote_Team__c> qtmLst)
    {
        fflib_ISObjectUnitOfWork uow = Pricing_IQR_Application.UnitOfWork.newInstance();
        
        Pricing_Quote_Team_Const qtms = (Pricing_Quote_Team_Const) Pricing_IQR_Application.Domain.newInstance( qtmLst );
        uow.registerDeleted(qtmLst);
        uow.commitWork();
        System.debug('Number of script statements used so far : ' + Limits.getDmlStatements());
    }
}