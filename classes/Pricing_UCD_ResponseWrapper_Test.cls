/**
 * @description       :
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             :
 * @last modified on  : 09-27-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 **/
@isTest
public class Pricing_UCD_ResponseWrapper_Test{
    static testmethod void testUCDResponseWrapper(){
        
        Pricing_UCD_ResponseWrapper.ResponseData ucdResponseObject1 = new Pricing_UCD_ResponseWrapper.ResponseData();
        ucdResponseObject1.AccountId = '';
        ucdResponseObject1.AccountName = 'Test End Customer';
        ucdResponseObject1.MasteredSimplifiedAccountName = 'Test End Customer';
        ucdResponseObject1.BusinessPartyIdentifier = '56789';
        ucdResponseObject1.RecordType = 'Intel Account';
        
        Pricing_UCD_ResponseWrapper.AccountAddress  primaryAddress1 = new Pricing_UCD_ResponseWrapper.AccountAddress();
        primaryAddress1.TypeCode ='';
        primaryAddress1.CountryCode ='AFG';
        primaryAddress1.CountryName = 'Afghanistan';
        ucdResponseObject1.PrimaryAddress = primaryAddress1;
        
        Pricing_UCD_ResponseWrapper.MasteredBusinessPhysicalAddress  physicalAddress1 = new Pricing_UCD_ResponseWrapper.MasteredBusinessPhysicalAddress('AFG','Afghanistan');
        ucdResponseObject1.MasteredBusinessPhysicalAddress = physicalAddress1;
        
        ucdResponseObject1.SecondaryAddress = primaryAddress1;
        
        Pricing_UCD_ResponseWrapper.ResponseData parentAcount1 = new Pricing_UCD_ResponseWrapper.ResponseData();
        parentAcount1.AccountId = '5464';
        parentAcount1.AccountName = 'Test End Customer';
        parentAcount1.BusinessPartyIdentifier = '12345';
        ucdResponseObject1.parentAccount = parentAcount1;
        
        List<Pricing_UCD_ResponseWrapper.ComplianceWatchList> cwlList = new List<Pricing_UCD_ResponseWrapper.ComplianceWatchList>();
        Pricing_UCD_ResponseWrapper.ComplianceWatchList cwl = new Pricing_UCD_ResponseWrapper.ComplianceWatchList('EC', 'Embargoed Country');
        Pricing_UCD_ResponseWrapper.ComplianceWatchList cwl1 = new Pricing_UCD_ResponseWrapper.ComplianceWatchList('NOPAYOUT', 'Block Payment from Intel');
        
        cwlList.add(cwl);
        cwlList.add(cwl1);
        ucdResponseObject1.complianceWatchList = cwlList;
        
        Pricing_UCD_ResponseWrapper.CustomerAggregationType custAgg = new Pricing_UCD_ResponseWrapper.CustomerAggregationType('UNFD_CTRY_CUST','');
        ucdResponseObject1.CustomerAggregationType = custAgg;
        Pricing_UCD_ResponseWrapper.CustomerProcessEngagement custPro = new Pricing_UCD_ResponseWrapper.CustomerProcessEngagement('DIR_PRC_EXCPT','');
        ucdResponseObject1.CustomerProcessEngagement = new List<Pricing_UCD_ResponseWrapper.CustomerProcessEngagement>{custPro};
        System.assert(custAgg != null);
        
    }
    
}