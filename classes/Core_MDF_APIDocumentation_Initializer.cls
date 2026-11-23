/**
 * @description Utility class to initialize Core API Documentation custom settings with sample data
 * This class populates the Core_MDF_API_Documentation__c custom settings with the 4 core APIs
 */
public class Core_MDF_APIDocumentation_Initializer {
    
    /**
     * @description Initializes the Core API Documentation custom settings with default API configurations
     * Safely handles existing records to avoid duplicate creation
     */
    public static void initializeAPIDocumentation() {
        try {
            // Check if already initialized
            Map<String, Core_MDF_API_Documentation__c> existingRecords = Core_MDF_API_Documentation__c.getAll();
            
            if (existingRecords.size() >= 4) {
                System.debug('Core API Documentation already initialized with ' + existingRecords.size() + ' records');
                return;
            }
            
            List<Core_MDF_API_Documentation__c> apiRecords = new List<Core_MDF_API_Documentation__c>();
            
            // API 1: PFR Activity Creation API
            apiRecords.add(new Core_MDF_API_Documentation__c(
                Name = 'PFR_Activity_Create',
                API_Name__c = 'PFR Activity API',
                Category__c = 'Activity Management',
                Operation_Name__c = 'Create Activity',
                API_Method__c = 'POST',
                API_Endpoint__c = '/services/apexrest/v1.0/activity?action=create',
                Version__c = '1.0.0',
                Response_Status_Code__c = '201',
                Sort_Order__c = 1,
                Is_Active__c = true,
                Default__c = true,
                EOL__c = '2026-01-01 - 2026-12-31',
                Description__c = 'Creates a new marketing activity in the MDF system with comprehensive validation',
                Request_Static_Resource_Name__c = 'Core_API_PFR_Activity_Create_Request',
                Response_Static_Resource_Name__c = 'Core_API_PFR_Activity_Create_Response',
                Request_Body_Example__c = '{"activity":{"ActivityName":"Q3 2026 Marketing Push","Campaign":"00013107","Priority":"AI PC - Commercial","Currency":"USD"}}',
                Response_Example__c = '{"isSuccess":true,"code":"201","message":"Success","activityNumber":"00046418","status":"Pending Approval"}'
            ));
            
            // API 2: Campaign Creation API
            apiRecords.add(new Core_MDF_API_Documentation__c(
                Name = 'Campaign_Create',
                API_Name__c = 'Campaign Creation API',
                Category__c = 'Campaign Management',
                Operation_Name__c = 'Create Campaign',
                API_Method__c = 'POST',
                API_Endpoint__c = '/services/apexrest/v1.0/campaign?action=create',
                Version__c = '1.0.0',
                Response_Status_Code__c = '200',
                Sort_Order__c = 2,
                Is_Active__c = true,
                Default__c = true,
                EOL__c = '2026-01-01 - 2026-12-31',
                Description__c = 'Creates a new marketing campaign with outcomes and budgets',
                Request_Static_Resource_Name__c = 'Core_API_Campaign_Create_Request',
                Response_Static_Resource_Name__c = 'Core_API_Campaign_Create_Response',
                Request_Body_Example__c = '{"details":{"Name":"Test CCF External API Validation Campaign","Status":"Planned","Program":"Client","Account":"001D300000qsxfZIAQ"}}',
                Response_Example__c = '{"isSuccess":true,"code":"200","campaignId":"701xx0000000123","status":"Planned"}'
            ));
            
            // API 3: Picklist Values API
            apiRecords.add(new Core_MDF_API_Documentation__c(
                Name = 'Picklist_Values_Get',
                API_Name__c = 'CampaignToActivity Picklist API',
                Category__c = 'Metadata',
                Operation_Name__c = 'Get Picklist Values',
                API_Method__c = 'GET',
                API_Endpoint__c = '/services/apexrest/v1.0/activitymetadata/picklist-values?campaignId=701xx0000000123',
                Version__c = '1.0.0',
                Response_Status_Code__c = '200',
                Sort_Order__c = 3,
                Is_Active__c = true,
                Default__c = true,
                EOL__c = '2026-01-01 - 2026-12-31',
                Description__c = 'Retrieves available picklist values for Activity fields, optionally filtered by campaign',
                Request_Static_Resource_Name__c = 'Core_API_Picklist_Values_Get_Request',
                Response_Static_Resource_Name__c = 'Core_API_Picklist_Values_Get_Response',
                Request_Body_Example__c = '{\n  "campaignId": "701xx0000000123 (Optional - Campaign ID to filter picklist values)"\n}',
                Response_Example__c = '{"isSuccess":true,"code":"200","fields":[{"fieldName":"ActivityCategory","values":["Digital","Event"]}]}'
            ));
            
            // API 4: File Upload API
            apiRecords.add(new Core_MDF_API_Documentation__c(
                Name = 'File_Upload',
                API_Name__c = 'File Upload API',
                Category__c = 'File Management',
                Operation_Name__c = 'Upload File',
                API_Method__c = 'POST',
                API_Endpoint__c = '/services/apexrest/v1.0/activity/uploadfile',
                Version__c = '1.0.0',
                Response_Status_Code__c = '200',
                Sort_Order__c = 4,
                Is_Active__c = true,
                Default__c = true,
                EOL__c = '2026-01-01 - 2026-12-31',
                Description__c = 'Uploads Base64 encoded files to an activity record with metadata',
                Request_Static_Resource_Name__c = 'Core_API_File_Upload_Request',
                Response_Static_Resource_Name__c = 'Core_API_File_Upload_Response',
                Request_Body_Example__c = '{"activity":"0RJdh0000001RRBGA2","FileName":"TestFile.xlsx","file":"base64-content","comment":"Testing upload"}',
                Response_Example__c = '{"isSuccess":true,"code":"200","message":"File uploaded successfully","fileId":"00Pxx0000000001"}'
            ));
            
            // Insert or update records
            upsert apiRecords;
            System.debug('Successfully initialized ' + apiRecords.size() + ' API documentation records');
            
        } catch (Exception e) {
            System.debug('Error initializing API Documentation: ' + e.getMessage());
            throw new AuraHandledException('Failed to initialize API documentation: ' + e.getMessage());
        }
    }
}