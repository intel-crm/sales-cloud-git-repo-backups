public without sharing virtual class PRM_External_Objects_Mockdata{
    @TestVisible protected List<SObject> mockedData = new List<SObject>();
    
    public void addTestRecord(SObject record) {
        mockedData.add(record);
    }

    public void addTestRecords(List<SObject> records) {
        mockedData.addAll(records);
    }
    
}