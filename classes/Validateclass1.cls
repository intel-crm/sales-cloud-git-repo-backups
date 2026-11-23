public class Validateclass1{
    
    public static Attachment method(){
        System.debug('heap size Main Class before method call : '+Limits.getHeapSize());
        System.debug('heap size Main Clas actual size : '+Limits.getLimitHeapSize() );
        Attachment a = [Select id ,body from attachment where ParentId = 'a3hDU000000KZYnYAO'];
         Attachment a2 = [Select id ,body from attachment where ParentId = 'a3hDU000000KZYnYAO'];
         Attachment a3 = [Select id ,body from attachment where ParentId = 'a3hDU000000KZYnYAO']; // 9MB
        Map<string,Object> backendJSONMap = Validateclass2.method2(a);
        
         Attachment a5 = [Select id ,body from attachment where ParentId = 'a3hDU000000KZYnYAO'];
         Attachment a2g = [Select id ,body from attachment where ParentId = 'a3hDU000000KZYnYAO'];
         Attachment a37 = [Select id ,body from attachment where ParentId = 'a3hDU000000KZYnYAO'];
      // Attachment a58 =  Validateclass1.method();
        validateClass2.method2(a);
         System.debug('heap size Main Class after clear : '+Limits.getHeapSize());
        return a37;
       
    }
}