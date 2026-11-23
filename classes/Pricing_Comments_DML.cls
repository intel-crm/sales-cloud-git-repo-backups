/**
 * @description       : Creating Domain layer class 
 * @author            : Rakshitha BR
 * @group             : Gravity
 * @last modified on  : 03-28-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class Pricing_Comments_DML {
    public static void updateComments(List<Pricing_Comments__c> cmntLst){
        fflib_ISObjectUnitOfWork uow = Pricing_IQR_Application.UnitOfWork.newInstance();
        
        Pricing_Comments_Const cmnts = (Pricing_Comments_Const) Pricing_IQR_Application.Domain.newInstance( cmntLst );
        uow.registerDirty(cmntLst);
        uow.commitWork();
        System.debug('Number of script statements used so far : ' + Limits.getDmlStatements());
    }
    
     /**
     * @description For Insert DML
     * @author Rakshitha BR | 03-28-2022 
     * @param cmntLst 
     **/
    public static void insertComments(List<Pricing_Comments__c> cmntLst){
        fflib_ISObjectUnitOfWork uow = Pricing_IQR_Application.UnitOfWork.newInstance();        
        Pricing_Comments_Const cmnts = (Pricing_Comments_Const) Pricing_IQR_Application.Domain.newInstance( cmntLst );
        uow.registerNew(cmntLst);
        uow.commitWork();
        System.debug('Number of script statements used so far : ' + Limits.getDmlStatements());
    }
    
    public static void deleteComments(List<Pricing_Comments__c> cmntLst){
        fflib_ISObjectUnitOfWork uow = Pricing_IQR_Application.UnitOfWork.newInstance();        
        Pricing_Comments_Const cmnts = (Pricing_Comments_Const) Pricing_IQR_Application.Domain.newInstance( cmntLst );
        uow.registerDeleted(cmntLst);
        uow.commitWork();
        System.debug('Number of script statements used so far : ' + Limits.getDmlStatements());
    }
}