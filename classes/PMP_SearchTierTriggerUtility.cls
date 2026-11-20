public class PMP_SearchTierTriggerUtility {
  private static boolean run = true;
  private static boolean runWorkCopy = true;  
    public static boolean runOnce(){
        if(run){
             run=false;
             return true;
        }else{
            return run;
        }
    }
    public static boolean runWorkCopyOnce(){
        if(runWorkCopy){
             runWorkCopy=false;
             return true;
        }else{
            return runWorkCopy;
        }
    }

}