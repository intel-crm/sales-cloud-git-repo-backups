/*********************************************************************************************************************
Apex Class Name  : UCD_ACM_ReltioModels
Created Date     : 22 May, 2024
Function         : This is a model class for UCD_ACM_ReltioController and UCD_ACM_ReltioService
Modification Log :
* Developer                 Date                    Description
* --------------------------------------------------------------------------------------------------------------------
* Chethan Kunder            22/05/2024              Created
* Rajveer Ranavat           20/06/2024              Updated
*********************************************************************************************************************/
public without sharing class UCD_ACM_ReltioModels {
    public enum Attribute { OPID, COVERAGE }

    public class OPId {
        public String uri='configuration/entityTypes/BusinessOrganization/attributes/OnePartner/attributes/OPID';	
        public String value { set; get;}
        public OPId(String oPId) {
            value = oPId;
        }
    }

    public class OPIdActive {
        public String uri='configuration/entityTypes/BusinessOrganization/attributes/OnePartner/attributes/OPIDActive';	
        public Boolean value { set; get;}
        public OPIdActive(Boolean oPIdActive) {
            value = oPIdActive;
        }
    }

    public class SalesCoverage {
        public String uri='configuration/entityTypes/BusinessOrganization/attributes/CustomerSalesCoverageTypeCd';	
        public String value { set; get;}
        public SalesCoverage(String coverage) {
            value = coverage;
        }
    }

    public class UpdateRequestModel {
        @InvocableVariable(required=true)
        public String bpId;
        @InvocableVariable(required=true)
        public String accountId;
        @InvocableVariable
        public String onePartnerId;
        @InvocableVariable
        public Boolean oPIdActive;
        @InvocableVariable
        public String acctPriCoverage;
        @InvocableVariable
        public String moduleName;
    }

    public class UpdateRequest {
        public final String action = 'upsertAttribute';
        public final String type = 'configuration/sources/Salesforce';
        public final String table = 'Account';
        public String attributeKey { get; set; }
        public String value { set; get; }
        public List<Object> attributes { get; set; }
        
        public UpdateRequest(String accountId, SalesCoverage coverage) {
            // attributeKey='configuration/entityTypes/BusinessOrganization/attributes/CustomerSalesCoverageTypeCd';
            value = accountId;
            List<Object> lstCoverageAttr =  new List<Object>();
            lstCoverageAttr.add(coverage);
            attributes = lstCoverageAttr;
        }
        public UpdateRequest(String accountId, OPId oPId, OPIdActive oPIdActive) {            
            //attributeKey='configuration/entityTypes/BusinessOrganization/attributes/OnePartner/attributes/OPID';
            value = accountId;
            List<Object> lstOPIDAttr =  new List<Object>();
            lstOPIDAttr.add(oPId);
            lstOPIDAttr.add(oPIdActive);
            attributes = lstOPIDAttr;
        }
    }

    public class UpdateResponseModel {
        public String accountId { get; set; } 
        @InvocableVariable
        public String errorDescription;
        @InvocableVariable
        public String status;
    }
 }