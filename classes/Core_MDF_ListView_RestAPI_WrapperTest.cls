/**
 * Tests request parsing in Core_MDF_ListView_RestAPI_Wrapper.
 */
@isTest
private class Core_MDF_ListView_RestAPI_WrapperTest {

    @isTest
    static void parsesFieldKeyedFilters() {
        Core_MDF_ListView_RestAPI_Wrapper.ListViewRequest request =
            Core_MDF_ListView_RestAPI_Wrapper.parse(
                '{"objectName":"Campaign","filters":{"StartDate":{"operator":"GREATER tHAN","value":"2026-01"}}}'
            );

        System.assertEquals('Campaign', request.objectName);
        System.assertEquals(1, request.getFilters().size());
        System.assertEquals('StartDate', request.getFilters()[0].field);
        System.assertEquals('GREATER tHAN', request.getFilters()[0].operator);
        System.assertEquals('2026-01', request.getFilters()[0].value);
    }

    @isTest
    static void parsesOrderedFiltersAndFilterLogic() {
        Core_MDF_ListView_RestAPI_Wrapper.ListViewRequest request =
            Core_MDF_ListView_RestAPI_Wrapper.parse(
                '{"objectName":"Campaign","filters":[' +
                '{"field":"Status","operator":"=","value":"In Progress"},' +
                '{"field":"StartDate","operator":">","value":"2026-01-01"}' +
                '],"filterLogic":"1 OR 2"}'
            );

        System.assertEquals('Campaign', request.objectName);
        System.assertEquals('1 OR 2', request.filterLogic);
        System.assertEquals(2, request.getFilters().size());

        System.assertEquals('Status', request.getFilters()[0].field);
        System.assertEquals('=', request.getFilters()[0].operator);
        System.assertEquals('In Progress', request.getFilters()[0].value);

        System.assertEquals('StartDate', request.getFilters()[1].field);
        System.assertEquals('>', request.getFilters()[1].operator);
        System.assertEquals('2026-01-01', request.getFilters()[1].value);
    }

    @isTest
    static void parsesBasicRequestProperties() {
        Core_MDF_ListView_RestAPI_Wrapper.ListViewRequest request =
            Core_MDF_ListView_RestAPI_Wrapper.parse(
                '{"objectName":"Campaign",' +
                '"programName":"Test Program",' +
                '"sortBy":"StartDate",' +
                '"sortOrder":"ASC"}'
            );

        System.assertEquals('Campaign', request.objectName);
        System.assertEquals('Test Program', request.programName);
        System.assertEquals('StartDate', request.sortBy);
        System.assertEquals('ASC', request.sortOrder);
        System.assertEquals(0, request.getFilters().size());
    }

    @isTest
    static void handlesBlankRequest() {
        Core_MDF_ListView_RestAPI_Wrapper.ListViewRequest request =
            Core_MDF_ListView_RestAPI_Wrapper.parse('');

        System.assertNotEquals(null, request);
        System.assertEquals(0, request.getFilters().size());
    }

    @isTest
    static void parsesWrappedRequest() {
        Core_MDF_ListView_RestAPI_Wrapper.ListViewRequest request =
            Core_MDF_ListView_RestAPI_Wrapper.parse(
                '{"request":{"objectName":"Campaign",' +
                '"filters":[{"field":"Status","operator":"=","value":"Active"}]}}'
            );

        System.assertEquals('Campaign', request.objectName);
        System.assertEquals(1, request.getFilters().size());
        System.assertEquals('Status', request.getFilters()[0].field);
        System.assertEquals('Active', request.getFilters()[0].value);
    }
}