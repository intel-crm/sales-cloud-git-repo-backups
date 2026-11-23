public with sharing class Core_UCD_MasterDataManagementService {
    public static IAccountService getServiceInstance(MDMSource source){
        //String className = String.format('UCD_{0}_Connector', source.name());//
        String className = String.format('UCD_{0}_Connector', new List<Object>{source.name()});
        return (IAccountService)Type.forName(className).newInstance();
    }

    public enum MDMSource {
        CIM
    }
}