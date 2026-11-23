/**
 * @description Flow action that applies selected workbook-scoped program-name replacements.
 */
public with sharing class Core_MDF_Program_Rename_ApplyAction {
    public class Request {
        @InvocableVariable(label='Selected Metadata Components' required=true)
        public List<Core_MDF_Program_Rename_Item> selectedItems;
        @InvocableVariable(label='Current Program Name' required=true)
        public String oldName;
        @InvocableVariable(label='New Program Name' required=true)
        public String newName;
    }

    public class Response {
        @InvocableVariable(label='Results')
        public List<Core_MDF_Program_Rename_Item> results;
        @InvocableVariable(label='Updated Count')
        public Integer updatedCount;
        @InvocableVariable(label='Failed Count')
        public Integer failedCount;
        @InvocableVariable(label='Error Message')
        public String errorMessage;
    }

    @InvocableMethod(
        label='Core MDF - Apply Program Rename Metadata'
        category='Program Rename'
        callout=true
    )
    public static List<Response> apply(List<Request> requests) {
        List<Response> responses = new List<Response>();
        for (Request request : requests) {
            Response response = new Response();
            response.results = new List<Core_MDF_Program_Rename_Item>();
            response.updatedCount = 0;
            response.failedCount = 0;
            try {
                response.results = Core_MDF_Program_Rename_Service.apply(
                    request.selectedItems,
                    request.oldName,
                    request.newName
                );
            } catch (Exception error) {
                response.errorMessage = error.getMessage();
            }
            for (Core_MDF_Program_Rename_Item item : response.results) {
                if (item.status == 'Updated') {
                    response.updatedCount++;
                } else if (item.status == 'Failed') {
                    response.failedCount++;
                }
            }
            responses.add(response);
        }
        return responses;
    }
}