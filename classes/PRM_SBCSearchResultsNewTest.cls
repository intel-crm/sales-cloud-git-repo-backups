@isTest
public class PRM_SBCSearchResultsNewTest {

    @isTest
    public static void PRM_SBCSearchResults(){
       
        PRM_SBCSearchResults.partnerRolesInfo pr=new PRM_SBCSearchResults.partnerRolesInfo();
        pr.PartnerRole='Manufacturer';
        pr.status='Approved';
        pr.statusChangeDt=string.valueof(system.now());
        pr.Tier='Member';
        
        PRM_SBCSearchResults.AccountAddress padr=new PRM_SBCSearchResults.AccountAddress();
        padr.StateCode2='KA';
        padr.City='Bangalore';
        padr.CountryCode2='IN';
        padr.AddressLine1='233';
        padr.PostalCode='232';
        
        Address adobj=new Address('21',null,'banglore','IN','KA','32323');
        list<POC_CIMAccountSearch.AccountLegalAgreement> leh=new list<POC_CIMAccountSearch.AccountLegalAgreement>();
        POC_CIMAccountSearch.AccountLegalAgreement ap=new POC_CIMAccountSearch.AccountLegalAgreement(system.now());
        leh.add(ap);
        
        list<PartnerRoleInfo> prrole=new list<PartnerRoleInfo>();
        PartnerRoleInfo prr=new PartnerRoleInfo('Manufacturer', 'Member', 'Approved', system.now());
        prrole.add(prr);

        CIMAccountSearchInfo cim=new CIMAccountSearchInfo('herman',adobj,leh,prrole,'000123456700', '98776', 'Member');
        
        
        
    }
}