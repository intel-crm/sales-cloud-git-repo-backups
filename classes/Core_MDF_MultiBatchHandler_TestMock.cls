@isTest
public class Core_MDF_MultiBatchHandler_TestMock {

    @TestVisible
    static List<Core_MDF_MultiObjectBatchHandler.Core_MDF_ObjectQuery> mockQueries;

    @TestVisible
    static void enableMockQueries() {
        mockQueries = Core_MDF_ObjectQuery_Mock_Utility.getMockQueriesFor3Objects();
    }

    public static List<Core_MDF_MultiObjectBatchHandler.Core_MDF_ObjectQuery> prepareQueries() {
        return mockQueries;
    }
}