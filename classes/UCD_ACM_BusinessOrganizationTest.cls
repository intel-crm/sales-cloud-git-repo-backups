@isTest
public class UCD_ACM_BusinessOrganizationTest {
    private static RestRequest request = new RestRequest();
    
    
    //@TestSetup
    private static void setCommonData(){
        Profile pf= [Select Id from profile where Name='Integration' LIMIT 1]; 
        
        user uu = UCD_ACM_Cntrlr_TestDataInitialization.createUser(pf.Id); 
        insert uu;
        system.runAs(uu){
        // Create Parent Account
        Account parentAccount = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('TestParentAccount','Intel Account','UNFD_GLBL_CUST');
        insert parentAccount;
        
        // Create End Customer Deal Account
        Account acc = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('TestReadAPI','End Customer Deal Account','UNFD_GLBL_CUST');
        acc.parentId = parentAccount.Id;
        insert acc;
        
        // Create Requested Account
        Account requestedAcc = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('RequetedAccount','Requested Account','UNFD_GLBL_CUST');
        insert requestedAcc;
        
        // Create Business Type
        Business_Types__c businessType = UCD_ACM_Cntrlr_TestDataInitialization.createBusinessType('Direct Price Exception','DIR_PRC_EXCPT');
        insert businessType;

        // Create Account Business Type
        Account_Business_Types__c accountBusinessType = UCD_ACM_Cntrlr_TestDataInitialization.createAccountBusinessType(acc.Id,businessType.Id);
        insert accountBusinessType;
        
        }
        
        
    }

    private static UCD_ACM_BusinessOrganizationModel createBusinessOrganizationModel(){
        UCD_ACM_BusinessOrganizationModel requestModel = new UCD_ACM_BusinessOrganizationModel();
        Account acc = [Select Id from Account where Name = 'TestReadAPI'];
        requestModel.TransactionId = 'tx011';
        UCD_ACM_BusinessOrganizationModel.BusinessOrganizationData businessData = new UCD_ACM_BusinessOrganizationModel.BusinessOrganizationData(); 
        List< String > accId = new List<String>();
        accId.add(acc.Id);
        businessData.AccountId = accId;
        businessData.BusinessPartyId = null;
        requestModel.BusinessOrganization = businessData;
        List<UCD_ACM_BusinessOrganizationModel.AttributesData> lstattribute= new List<UCD_ACM_BusinessOrganizationModel.AttributesData>();
        For(Integer i=0;i<=5;i++){
            UCD_ACM_BusinessOrganizationModel.AttributesData attribute = new UCD_ACM_BusinessOrganizationModel.AttributesData();
            if(i==0)
            attribute.AttributeName = 'AccountInformation';
            if(i==1)
            attribute.AttributeName = 'AccountAddressInformation';
            if(i==2)
            attribute.AttributeName = 'ParentAccountInfomation';
            if(i==3)
            attribute.AttributeName = 'AccountMasteredDetails';
            if(i==4)
            attribute.AttributeName = 'AccountComplianceDetails';
            lstattribute.add(attribute);
        }
        requestModel.Attributes = lstattribute;

        return requestModel;
    }
   
    @isTest
    private static void whenRequestFromIQR(){
        setCommonData();
        UCD_ACM_BusinessOrganizationModel requestModel = createBusinessOrganizationModel();
        Test.startTest();
        UCD_ACM_BusinessOrganizationModel.BusinessOrganizationResponse resData = UCD_ACM_BusinessOrganization.businessOrganization(requestModel);
        //system.assertEquals(resData.Data[0].AccountInformation.AccountName, 'TestReadAPI');
        Test.stopTest();
    }
    
    @isTest
    private static void whenRequestFromMyDeal(){
        setCommonData();
        UCD_ACM_BusinessOrganizationModel requestModel = createBusinessOrganizationModel();
        
        String jsonReq = JSON.serialize(requestModel); 
        request.requestURI = '/services/apexrest/BusinessOrganization/';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(jsonReq);
        RestContext.request = request;
        Test.startTest();
        UCD_ACM_BusinessOrganizationModel.BusinessOrganizationResponse resData = UCD_ACM_BusinessOrganization.selectBusinessOrganization();
        //system.assertEquals(resData.Data[0].AccountInformation.AccountName, 'TestReadAPI');
    	Test.stopTest();
    }
    
    /*@isTest
    private static void whenThrowException(){
        setCommonData();
        UCD_ACM_BusinessOrganizationModel requestModel = createBusinessOrganizationModel();
        Test.startTest();
        UCD_ACM_AccountService.isTestException = true;
        UCD_ACM_BusinessOrganizationModel.BusinessOrganizationResponse resData = UCD_ACM_BusinessOrganization.businessOrganization(requestModel);
        system.assertEquals(resData, null);
        Test.stopTest();
       
    }*/
}