public class TestHeapsizeA{

public static void testHeap(){
integer i=100;
 System.debug('heap size batchclass 48 : '+Limits.getHeapSize()+'&&&&ts--'+Limits.getLimitHeapSize());
 System.debug('heap1 1size 1batchclass 49 : '+Limits.getHeapSize()+'&&&&ts--'+Limits.getLimitHeapSize());
 System.debug('heap1 size1 batchclass 46 : '+Limits.getHeapSize()+'&&&&ts--'+Limits.getLimitHeapSize());
 System.debug('heap size1 batchclass 42 : '+Limits.getHeapSize()+'&&&&ts--'+Limits.getLimitHeapSize());
   i+=10;           
    System.debug('heap size batchclass 42 : '+Limits.getHeapSize()+'&&&&ts--'+Limits.getLimitHeapSize());
  //TestHeapsizeB.testHeap1();
    System.debug('heap size batchclass 42 : '+Limits.getHeapSize()+'&&&&ts--'+Limits.getLimitHeapSize());
  TestHeapsizeB b= new TestHeapsizeB();
  b.testHeap();
    System.debug('heap size batchclass 42 : '+Limits.getHeapSize()+'&&&&ts--'+Limits.getLimitHeapSize());
  
  TestHeapsizeB.testHeap1();
     System.debug('heap size batchclass 42 : '+Limits.getHeapSize()+'&&&&ts--'+Limits.getLimitHeapSize());
 
}


}