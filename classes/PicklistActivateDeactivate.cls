global class PicklistActivateDeactivate {
    
    webService static void updatePicklistField(String picklistToUpdate, String picklistLabel, String newPicklistValue)
    {

		MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        MetadataService.CustomField customField = new MetadataService.CustomField();
        customField.fullName = picklistToUpdate; //This is the picklist field. This must in the format Object.Field (append __c for custom object/field)
        customField.label = picklistLabel; //This field is needed in update
        customField.type_x = 'Picklist';
        metadataservice.Picklist pt = new metadataservice.Picklist();
        pt.sorted= false;
        metadataservice.PicklistValue newPlValue = new metadataservice.PicklistValue();
        newPlValue.fullName  = newPicklistValue; //This is the new picklist value
        newPlValue.default_x =false ;
        pt.picklistValues = new list<metadataservice.PicklistValue>{newPlValue};
        customField.picklist = pt ;
        List<MetadataService.SaveResult> results =
            service.updateMetadata(
                new MetadataService.Metadata[] { customField });
        //handleSaveResults(results[0]);
    }

}