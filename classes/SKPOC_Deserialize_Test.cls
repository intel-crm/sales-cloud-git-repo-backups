public class SKPOC_Deserialize_Test {
    
    
    public static void QT(){
        

        string t2 = '[{"Subject":"test","Status":"New","LastModifiedDate":null,"CaseURL":null,"CaseNumber":"00198251", "CaseNumber2":"00198251"},{"Subject":"test case mag","Status":"New","LastModifiedDate":null,"CaseURL":null,"CaseNumber":"00198274"}]';
        
        List<SObjectWrapper> objList = (List<SObjectWrapper>)JSON.deserialize(t2, List<SObjectWrapper>.class);
        System.debug(' >>>>>>>>>>> objList '+objList);
        
    }
}