public class Pricing_Quote_Line_Status_Age_DML {
    
    public static void deleteTPT(List<Pricing_Quote_Line_Status_Age__c> tptLst)
    {
        fflib_ISObjectUnitOfWork uow = Pricing_IQR_Application.UnitOfWork.newInstance();
        
        Pricing_Quote_Line_Status_Age_Const tpts = (Pricing_Quote_Line_Status_Age_Const) Pricing_IQR_Application.Domain.newInstance( tptLst );
        uow.registerDeleted(tptLst);
        uow.commitWork();
    }
    
    public static void updateTPT(List<Pricing_Quote_Line_Status_Age__c> tptLst)
    {
        fflib_ISObjectUnitOfWork uow = Pricing_IQR_Application.UnitOfWork.newInstance();
        
        Pricing_Quote_Line_Status_Age_Const tpts = (Pricing_Quote_Line_Status_Age_Const) Pricing_IQR_Application.Domain.newInstance( tptLst );
        uow.registerDirty(tptLst);
        uow.commitWork();
    }
    
    public static void insertTPT(List<Pricing_Quote_Line_Status_Age__c> tptLst)
    {
        fflib_ISObjectUnitOfWork uow = Pricing_IQR_Application.UnitOfWork.newInstance();
        
        Pricing_Quote_Line_Status_Age_Const tpts = (Pricing_Quote_Line_Status_Age_Const) Pricing_IQR_Application.Domain.newInstance( tptLst );
        uow.registerNew(tptLst);
        uow.commitWork();
    }
    
    public static void upsertTPT(List<Pricing_Quote_Line_Status_Age__c> tptLst)
    {
        fflib_ISObjectUnitOfWork uow = Pricing_IQR_Application.UnitOfWork.newInstance();
        
        Pricing_Quote_Line_Status_Age_Const tpts = (Pricing_Quote_Line_Status_Age_Const) Pricing_IQR_Application.Domain.newInstance( tptLst );
        uow.registerUpsert(tptLst);
        uow.commitWork();
    }
}