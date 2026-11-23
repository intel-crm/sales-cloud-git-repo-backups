public with sharing class ApexGovernorLimitUtil {
    public static Integer getRemainingSOQLQueries() {
        return Limits.getLimitQueries() - Limits.getQueries();
    }
    public static Integer getRemainingDMLStatements() {
        return Limits.getLimitDMLStatements() - Limits.getDMLStatements();
    }
    public static Integer getRemainingCPUTime() {
        return Limits.getLimitCpuTime() - Limits.getCpuTime();
    }
    public static Integer getRemainingHeapSize() {
        return Limits.getLimitHeapSize() - Limits.getHeapSize();
    }
    public static Integer getRemainingCallouts() {
        return Limits.getLimitCallouts() - Limits.getCallouts();
    }
    
    
}