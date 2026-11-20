/******************************************************************************************************************************************
Class Name  : SWS_DynamicMethodCaller
Version     : 1.0 
Function    : Dynamic Service call for Custom_URL_Embed LWC in Account 360 Tab
Modification Log :
* Developer         Date          Description
* ----------------------------------------------------------------------------                 
* Shijas KM        04/15/2025   Original version
*****************************************************************************************************************************************/

public class SWS_DynamicMethodCaller {
  	@AuraEnabled(cacheable=true) 
    public static Object callMethod(String className, List<Object> methodParams) {   
        try{
        Type myClassType = Type.forName(className);      
        SWS_DynamicMethodInterface serviceInstance = (SWS_DynamicMethodInterface)myClassType.newInstance();
        return serviceInstance.execute(methodParams);
        }            
       catch(Exception ex){        
           return null;
        }
    
    }
}