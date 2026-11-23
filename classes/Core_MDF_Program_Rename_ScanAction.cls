/**
 * @description Flow action that previews workbook-scoped matches for one supported metadata type.
 */
public with sharing class Core_MDF_Program_Rename_ScanAction {
  public class Request {
    @InvocableVariable(label='Metadata Type' required=true)
    public String metadataType;
    @InvocableVariable(label='Current Program Name' required=true)
    public String oldName;
    @InvocableVariable(label='New Program Name' required=true)
    public String newName;
  }

  public class Response {
    @InvocableVariable(label='Matches')
    public List<Core_MDF_Program_Rename_Item> items;
    @InvocableVariable(label='Occurrence Details')
    public List<Core_MDF_Program_Rename_Occurrence> occurrences;
    @InvocableVariable(label='Match Count')
    public Integer itemCount;
    @InvocableVariable(label='Error Message')
    public String errorMessage;
  }

  @InvocableMethod(
    label='Core MDF - Scan Program Rename Metadata'
    category='Program Rename'
    callout=true
  )
  public static List<Response> scan(List<Request> requests) {
    List<Response> responses = new List<Response>();
    for (Request request : requests) {
      Response response = new Response();
      response.items = new List<Core_MDF_Program_Rename_Item>();
      response.occurrences = new List<Core_MDF_Program_Rename_Occurrence>();
      try {
        response.errorMessage = Core_MDF_Program_Rename_Service.validateInput(
          request.metadataType,
          request.oldName,
          request.newName
        );
        if (response.errorMessage == null) {
          Core_MDF_Program_Rename_Service.ScanResult scanResult = Core_MDF_Program_Rename_Service.scanDetailed(
            request.metadataType.trim(),
            request.oldName.trim(),
            request.newName.trim()
          );
          response.items = scanResult.items;
          response.occurrences = scanResult.occurrences;
        }
      } catch (Exception error) {
        response.errorMessage = error.getMessage();
      }
      response.itemCount = response.items.size();
      responses.add(response);
    }
    return responses;
  }
}