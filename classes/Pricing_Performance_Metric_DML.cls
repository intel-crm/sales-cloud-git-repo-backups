public class Pricing_Performance_Metric_DML {
     public static void deletePerformanceMetric(List<Pricing_Performance_Metric__c> pmet)
    {
        /**
        * @description Creating Unit Of Work new instance
        * @author Rakshitha BR | 03-28-2022 
        * @param ; 
        * @return fflib_ISObjectUnitOfWork 
        **/
        fflib_ISObjectUnitOfWork uow = Pricing_IQR_Application.UnitOfWork.newInstance();
        
        Pricing_Performance_Metric_Const pmetct = (Pricing_Performance_Metric_Const) Pricing_IQR_Application.Domain.newInstance( pmet );
        uow.registerDeleted(pmet);
        uow.commitWork();
        System.debug('Number of script statements used so far : ' + Limits.getDmlStatements());
    }
     public static void updatePerformanceMetric(List<Pricing_Performance_Metric__c> pmet)
    {
        /**
        * @description Creating Unit Of Work new instance
        * @author Rakshitha BR | 03-28-2022 
        * @param ; 
        * @return fflib_ISObjectUnitOfWork 
        **/
        fflib_ISObjectUnitOfWork uow = Pricing_IQR_Application.UnitOfWork.newInstance();
        
        Pricing_Performance_Metric_Const pmetct = (Pricing_Performance_Metric_Const) Pricing_IQR_Application.Domain.newInstance( pmet );
        uow.registerDirty(pmet);
        uow.commitWork();
        System.debug('Number of script statements used so far : ' + Limits.getDmlStatements());
    }
    public static void insertPerformanceMetric(List<Pricing_Performance_Metric__c> pmet)
    {
        /**
        * @description Creating Unit Of Work new instance
        * @author Rakshitha BR | 03-28-2022 
        * @param ; 
        * @return fflib_ISObjectUnitOfWork 
        **/
        fflib_ISObjectUnitOfWork uow = Pricing_IQR_Application.UnitOfWork.newInstance();
        
        Pricing_Performance_Metric_Const pmetct = (Pricing_Performance_Metric_Const) Pricing_IQR_Application.Domain.newInstance( pmet );
        uow.registerNew(pmet);
        uow.commitWork();
        System.debug('Number of script statements used so far : ' + Limits.getDmlStatements());
    }
   


}