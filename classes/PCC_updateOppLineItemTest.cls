@isTest
public with sharing class PCC_updateOppLineItemTest {
    public PCC_updateOppLineItemTest() {

    }
    @isTest
    public static void updateOppLineItem(){
        List<Core_Design_Registration__c> DDRLst = Core_DDR_Utility.createDDR(2);
        DDRLst[0].Core_Product_Group_Nm__c = 'Embedded/IOT';
        insert DDRLst;

        test.startTest();
        System.enqueueJob(new PCC_UpdateOppLineItem(DDRLst[0].id));
        test.stopTest();
    }

}