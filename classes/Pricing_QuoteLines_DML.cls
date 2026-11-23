public class Pricing_QuoteLines_DML {
    
    public static void deleteQLI(List<SBQQ__QuoteLine__c> qlitLst)
    {
        fflib_ISObjectUnitOfWork uow = Pricing_IQR_Application.UnitOfWork.newInstance();
        
        Pricing_QuoteLines_Const qlis = (Pricing_QuoteLines_Const) Pricing_IQR_Application.Domain.newInstance( qlitLst );
        uow.registerDeleted(qlitLst);
        uow.commitWork();
    }
    
     public static void updateQLI(List<SBQQ__QuoteLine__c> qlitLst)
    {
        fflib_ISObjectUnitOfWork uow = Pricing_IQR_Application.UnitOfWork.newInstance();
        
        Pricing_QuoteLines_Const qlis = (Pricing_QuoteLines_Const) Pricing_IQR_Application.Domain.newInstance( qlitLst );
        uow.registerDirty(qlitLst);
        uow.commitWork();
    }
}