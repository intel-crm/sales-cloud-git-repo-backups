public class UCD_ACM_AccountTestData {
    
    public static UCD_ACM_Models.AccountModel getAccountModel(String accountName, String customerAggregationCode, String CustomerProcessCode,String requesterName, String requesterEmail, String countryName,String countryCode){
        UCD_ACM_Models.AccountModel accountModel = new UCD_ACM_Models.AccountModel();
        accountModel.Name = accountName;
        accountModel.CustomerAggregationTypeCode = customerAggregationCode;
        accountModel.CustomerProcessEngagmentCode = CustomerProcessCode;
        accountModel.RequesterName = requesterName;
        accountModel.RequesterEmail = requesterEmail;
        accountModel.Addresses = getAccountAddress(countryName,countryCode,'Billing');
        accountModel.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Requested Account').getRecordTypeId();


        return accountModel;
    }
    
    public static List<UCD_ACM_Models.AccountAddress> getAccountAddress(String countryName,string countryCode,String typeCode){
        List<UCD_ACM_Models.AccountAddress> lstofnewModeladdr =  new List<UCD_ACM_Models.AccountAddress>(); 
        UCD_ACM_Models.AccountAddress newModelAddressRef = new UCD_ACM_Models.AccountAddress();
        newModelAddressRef.TypeCode  =  typeCode != null ? typeCode :null;
        newModelAddressRef.CountryCode = countryCode != null ? countryCode :null;
        newModelAddressRef.CountryName = countryName != null ? countryName :null;
        lstofnewModeladdr.add(newModelAddressRef);
        return lstofnewModeladdr;
    }
    
     public static Map<String, String>  getAccountRequestReference(String Name,String Value){
        Map<String, String> mapAccReqRef = new Map<String,String>(); 
        mapAccReqRef.put(Name,Value);
        return mapAccReqRef;
    }
    
    
    public static UCD_ACM_BusinessOrganizationModel getBusinessOrganizationModel(List<String> accountIds){
        UCD_ACM_BusinessOrganizationModel requestModel = new UCD_ACM_BusinessOrganizationModel();
        UCD_ACM_BusinessOrganizationModel.BusinessOrganizationData businessData = new UCD_ACM_BusinessOrganizationModel.BusinessOrganizationData();
        List<UCD_ACM_BusinessOrganizationModel.AttributesData> lstattribute= new List<UCD_ACM_BusinessOrganizationModel.AttributesData>();
        requestModel.TransactionId = 'tx011';
        businessData.AccountId = accountIds;
        businessData.BusinessPartyId = null;
        requestModel.BusinessOrganization = businessData;
        
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
    
}