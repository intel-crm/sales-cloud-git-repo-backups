/**
 * @description       : 
 * @author            : Sandeep Chamate
 * @group             : 
 * @last modified on  : 11-21-2023
 * @last modified by  : Sandeep Chamate
**/
@isTest
public class Pricing_ConsumptionAttributesWrapperTest {
    static testmethod void testConsumptionAttributes() {
        Pricing_ConsumptionAttributesWrapper.Header header = new Pricing_ConsumptionAttributesWrapper.Header();
        header.xid = null;
        header.target_system = null;
        header.source_system = null;
        header.action = null;
        
		Pricing_ConsumptionAttributesWrapper.ConsumptionData consumptionAtt = new Pricing_ConsumptionAttributesWrapper.ConsumptionData();
        consumptionAtt.cimId = null;
        consumptionAtt.consumptionType = null;
        consumptionAtt.value = null;
        consumptionAtt.mode = null;
        consumptionAtt.isActive = 'false';

        System.assertEquals(consumptionAtt.cimId, null);
    }
}