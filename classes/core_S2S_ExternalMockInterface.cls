public virtual without sharing class core_S2S_ExternalMockInterface {
    
    protected virtual List<SObject> passThrough(List<SObject> records){
        return records;
    } 
 
    static core_S2S_ExternalMockInterface mockInstance;
    
    public static List<sObject> records(List<sObject> records){
        return mockInstance.passThrough(records);   
    }
    
    @TestVisible 
    static void setMock(core_S2S_ExternalMockInterface mock){
        mockInstance = mock;
    }
    
}