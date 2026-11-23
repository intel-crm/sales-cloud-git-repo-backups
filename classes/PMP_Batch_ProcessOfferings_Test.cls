@isTest
public class PMP_Batch_ProcessOfferings_Test {
 @isTest 
    static void executeTest(){
        SchedulableContext  sc = null;
        PMP_Batch_ProcessOfferings obj = new PMP_Batch_ProcessOfferings();
        obj.execute(sc);
    } 
}