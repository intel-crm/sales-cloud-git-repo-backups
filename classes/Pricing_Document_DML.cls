public class Pricing_Document_DML {
    public static void updateDocuments(List<Pricing_Document__c> docLst)
    {
        fflib_ISObjectUnitOfWork uow = Pricing_IQR_Application.UnitOfWork.newInstance();
        
        Pricing_Document_Const docs = (Pricing_Document_Const) Pricing_IQR_Application.Domain.newInstance( docLst );
        uow.registerDirty(docLst);
        uow.commitWork();
        System.debug('Number of script statements used so far : ' + Limits.getDmlStatements());
    }

     public static void insertDocuments(List<Pricing_Document__c> docLst)
    {
        fflib_ISObjectUnitOfWork uow = Pricing_IQR_Application.UnitOfWork.newInstance();
        
        Pricing_Document_Const docs = (Pricing_Document_Const) Pricing_IQR_Application.Domain.newInstance( docLst );
        uow.registerNew(docLst);
        uow.commitWork();
        System.debug('Number of script statements used so far : ' + Limits.getDmlStatements());
    }
    
    public static void deleteDocuments(List<Pricing_Document__c> docLst)
    {
        fflib_ISObjectUnitOfWork uow = Pricing_IQR_Application.UnitOfWork.newInstance();
        
        Pricing_Document_Const docs = (Pricing_Document_Const) Pricing_IQR_Application.Domain.newInstance( docLst );
        uow.registerDeleted(docLst);
        uow.commitWork();
        System.debug('Number of script statements used so far : ' + Limits.getDmlStatements());
    }
}