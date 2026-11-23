public class PCC_LineItemController {

    @AuraEnabled(cacheable=true)
    public static List<Map<String, String>> getLineItems(Id parentId) {
        // [{tyep:name, key:value, key;value},{tyep:name, key:value, key;value}]
        List<Map<String, String>> lineItems = new List<Map<String, String>>();
        //System.debug(Database.query(PCC_ChangeRequest.buildSOQL(getColumns())));
        List<PCC_Change_Request_Field_Mapping__c> columns = getColumns();
        for(PCC_Deal_Change_Request_Line_Item__c lineItem :  Database.query(PCC_ChangeRequest.buildSOQL(columns))){
            lineItems.addAll(FieldMappingService.createObjectWrapper(columns, '', lineItem));
        }
        return lineItems;//Database.query(PCC_ChangeRequest.buildSOQL(getColumns()));//[SELECT Id, Name,PCC_Request_Type__c, PCC_Quantity__c, PCC_Start_Date__c, PCC_Approval_Status__c FROM PCC_Deal_Change_Request_Line_Item__c WHERE PCC_Change_Request__c = :parentId];
    }

     @AuraEnabled
    public static void updateLineItemsStatus(List<Id> lineItemIds, String status, String comments,Id recordId) {
        // Query changeRequestRec along with related Line Items using IN clause for the Line Item Ids.
            PCC_Deal_Change_Request__c changeRequestRec = [SELECT Id, PCC_Approval_Status__c, 
                                                            (SELECT Id, PCC_Approval_Status__c, PCC_PSAM_Comment__c,PCC_Request_Type__c
                                                            FROM Change_Request_Line_Items__r
                                                            WHERE Id IN :lineItemIds)
                                                        FROM PCC_Deal_Change_Request__c 
                                                        WHERE Id =:recordId];
            List<String> statusList = new List<String>{'Approved','Rejected','Approved- RPM Pending'};
            List<PCC_Deal_Change_Request_Line_Item__c> lineItemsToUpdate = new List<PCC_Deal_Change_Request_Line_Item__c>();

            // Loop over the related Line Items to update the status and comments.
            for (PCC_Deal_Change_Request_Line_Item__c lineItem : changeRequestRec.Change_Request_Line_Items__r) {
             if(!(statusList.contains(lineItem.PCC_Approval_Status__c))){
            lineItem.PCC_Approval_Status__c = (status == 'Approved' && lineItem.PCC_Request_Type__c == 'Change') ? 'Approved- RPM Pending':status;
            lineItem.PCC_PSAM_Comment__c = lineItem.PCC_PSAM_Comment__c!=null? lineItem.PCC_PSAM_Comment__c +' '+comments :comments;
             lineItemsToUpdate.add(lineItem);
             }
            }

            // Update the status for Change Request
            
            // Bulk Update records.
            update lineItemsToUpdate;

           /* if (changeRequestRec.PCC_Approval_Status__c != 'Review in Progress'){
            changeRequestRec.PCC_Approval_Status__c = 'Review in Progress';
            update changeRequestRec;
            }*/
            
    }

    @AuraEnabled(cacheable=true)
    public static List<PCC_Change_Request_Field_Mapping__c> getColumns(){
        try {
            
            return [select Id, IsDeleted, Name,Object_Field_Data_Type__c, PCC_Field_API_Name__c, PCC_Active__c, PCC_Object_Name__c, FieldType__c, Label__c, UseFieldName__c, initialWidth__c,  wrapText__c, cellClass__c, EditColumn__c, Enable_for_Partner__c, Enable_for_PSAM__c, Disabled__c, Enable_on_Partner_Screen__c, Enable_for_PSAM_Screen__c, isParent__c, Enable_for_Query__c, WrapperFieldName__c, Partner_Screen_Column_Order__c, PSAM_Screen_Column_Order__c, actions__c, cellAttributes__c, editable__c, fieldName__c, fixedWidth__c, hideDefaultActions__c, iconName__c, sortable__c, typeAttributes__c, DataTableAttributeName__c, DisableDefaultValue__c, EditDefaultValue__c, FieldAPIName__c, Parent_Object_API_Name__c, Child_Object_API_Name__c, Enable_for_Filter__c, Filter_Criteria__c, Filter_Criteria_Sequence__c,ByPassSoqlValueMappping__c from PCC_Change_Request_Field_Mapping__c where Enable_for_PSAM__c = true and FeatureName__c = 'psamapprovalscreen' order by PSAM_Screen_Column_Order__c asc];
            
        } catch (Exception e) {throw new AuraHandledException(e.getMessage());
        }
    }

   
}