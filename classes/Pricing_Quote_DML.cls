public class Pricing_Quote_DML {
    public static void updateQuotes(List<SBQQ__Quote__c> quoteLst)
    {
        fflib_ISObjectUnitOfWork uow = Pricing_IQR_Application.UnitOfWork.newInstance();
        
        Pricing_Quote_Const quotes = (Pricing_Quote_Const) Pricing_IQR_Application.Domain.newInstance( quoteLst );
        uow.registerDirty(quoteLst);
        uow.commitWork();
        System.debug('Number of script statements used so far : ' + Limits.getDmlStatements());
    }

     public static void insertQuotes(List<SBQQ__Quote__c> quoteLst)
    {
        fflib_ISObjectUnitOfWork uow = Pricing_IQR_Application.UnitOfWork.newInstance();
        
        Pricing_Quote_Const quotes = (Pricing_Quote_Const) Pricing_IQR_Application.Domain.newInstance( quoteLst );
        uow.registerNew(quoteLst);
        uow.commitWork();
        System.debug('Number of script statements used so far : ' + Limits.getDmlStatements());
    }
    
    public static void deleteQuotes(List<SBQQ__Quote__c> quoteLst)
    {
        fflib_ISObjectUnitOfWork uow = Pricing_IQR_Application.UnitOfWork.newInstance();
        
        Pricing_Quote_Const quotes = (Pricing_Quote_Const) Pricing_IQR_Application.Domain.newInstance( quoteLst );
        uow.registerDeleted(quoteLst);
        uow.commitWork();
        System.debug('Number of script statements used so far : ' + Limits.getDmlStatements());
    }
}