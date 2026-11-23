@isTest
public class Core_MDF_CommunityRedirect_Mock implements System.StubProvider{

 public static Object handleMethodCall(Object stubbedObject, String stubbedMethodName, 
        Type returnType, List<Type> listOfParamTypes, List<String> listOfParamNames, 
        List<Object> listOfArgs) {
            Map<String, String> authMap =  new Map<String, String>();
            authMap.put('SessionType', 'Visualforce');
            return authMap;
    }
    
}