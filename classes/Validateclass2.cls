public class Validateclass2 {
 
  public static  Map<string,Object> method2(Attachment a){
    System.debug('heap size validate2 Class before: '+Limits.getHeapSize());
     Attachment a5 = [Select id ,body from attachment where ParentId = 'a3hDU000000KZYnYAO'];
         Attachment a2 = [Select id ,body from attachment where ParentId = 'a3hDU000000KZYnYAO'];
         Attachment a3 = [Select id ,body from attachment where ParentId = 'a3hDU000000KZYnYAO'];
      Map<string,Object> backendJSONMap = new Map<string,Object>();
       for(Integer i=0; i<=50;i++){
     backendJSONMap = (Map<string,Object>) JSON.deserializeUntyped(a.body.toString());
       Map<string,Object> backendJSONMap2 = new Map<string,Object>();
     backendJSONMap2 = (Map<string,Object>) JSON.deserializeUntyped(a.body.toString());
       Map<string,Object> backendJSONMap3 = new Map<string,Object>();
     backendJSONMap3 = (Map<string,Object>) JSON.deserializeUntyped(a.body.toString());
    System.debug('heap size validate2 Class before: '+Limits.getHeapSize());
      }
      validateclass3.method2(a);
      return backendJSONMap;
  }
}