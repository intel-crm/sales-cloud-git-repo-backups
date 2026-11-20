/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 04-28-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class Pricing_ClaimsDataWrapper_Test {
    static testmethod void testClaimsData(){
        Pricing_ClaimsDataWrapper.Header header = new Pricing_ClaimsDataWrapper.Header();
        header.xid=null;
        header.target_system=null;
        header.source_system=null;
        header.action=null;
        
		Pricing_ClaimsDataWrapper.ClaimsData claimsData = new Pricing_ClaimsDataWrapper.ClaimsData();
        claimsData.creditVolume=null;
        claimsData.creditDollars=null;
        claimsData.debitVolume=null;
        claimsData.debitDollars=null;
        claimsData.lastCreditOrDebitDate=null;
        claimsData.dealId=null;
        claimsData.quoteLineNumber=null;
        System.assert(claimsData != null);
    }
}