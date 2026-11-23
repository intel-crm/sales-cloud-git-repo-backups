@IsTest
public without sharing class BLD_Order extends ObjectBuilderBase {
    private static final String DEF_Order_STATUS = 'Draft';
    
    public BLD_Order() {
        this(getNewUnitOfWork());
    }
    
    public BLD_Order(fflib_SObjectUnitOfWork workUnit) {
        super(Order.SObjectType, workUnit);
    }
    
    private BLD_Order(Order sObj, fflib_SObjectUnitOfWork workUnit) {
        super(sObj, workUnit);
    }
    
    protected override void setDefaultData() {
        setField(Order.Status, DEF_Order_STATUS);
    }
    
    public BLD_Order createdById(Id createdById) {
        return(BLD_Order) setField(Order.CreatedById, createdById);
    }
    
    public BLD_Order orderType(String type) {
        return(BLD_Order) setField(Order.Type, type);
    }
    
    public BLD_Order orderCity(String city) {
        return(BLD_Order) setField(Order.Sales_End_Customer_City_Txt__c, city);
    }
}