@isTest
public class PRM_ProfileResponse_Utility_Test {

    @isTest static void testGetProfResFieldNames() {

        Map<String, String> result = PRM_IPAR_ProfileResponse_Utility.getProfResFieldNames();
    }

    @isTest static void testCheckExistingPartnerRoles() {
        List<String> partnerRoles = new List<String>{'PRM_Distributor_Partner_Role', 'PRM_Service_Provider'};

        Boolean result1 = PRM_IPAR_ProfileResponse_Utility.checkExistingPartnerRoles(partnerRoles, 'Not Eligible Role');
        Boolean result2 = PRM_IPAR_ProfileResponse_Utility.checkExistingPartnerRoles(partnerRoles, 'Opt In Role');
        PRM_IPAR_ProfileResponse_Utility.getProfResponsemdt();

        
    }
}