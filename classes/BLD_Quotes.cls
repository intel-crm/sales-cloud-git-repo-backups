@IsTest
public without sharing class BLD_Quotes extends ObjectBuilderBase {
    private static final String DEF_QUOTE_STATUS = 'Draft';
    
    public BLD_Quotes() {
        this(getNewUnitOfWork());
    }
    
    public BLD_Quotes(fflib_SObjectUnitOfWork workUnit) {
        super(SBQQ__Quote__c.SObjectType, workUnit);
    }
    
    private BLD_Quotes(SBQQ__Quote__c sObj, fflib_SObjectUnitOfWork workUnit) {
        super(sObj, workUnit);
    }
    
    protected override void setDefaultData() {
        setField(SBQQ__Quote__c.SBQQ__Status__c, DEF_QUOTE_STATUS);
    }
    
    public BLD_Quotes quoteStatus(String quoteStatus) {
        return(BLD_Quotes) setField(SBQQ__Quote__c.SBQQ__Status__c, quoteStatus);
    }
    
    public BLD_Quotes ownerId(Id ownerId) {
        return(BLD_Quotes) setField(SBQQ__Quote__c.OwnerId, ownerId);
    }
    
    public BLD_Quotes createdById(Id createdById) {
        return(BLD_Quotes) setField(SBQQ__Quote__c.CreatedById, createdById);
    }
}