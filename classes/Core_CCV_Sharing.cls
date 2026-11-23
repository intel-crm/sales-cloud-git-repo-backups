public class Core_CCV_Sharing {
   
    public Id ccvId  { get; set; }
    public Id userId { get; set; }

    public String accessLevel { get; set; }
    public String rowCause    { get; set; }


    public void Core_CCV_Sharing()
    {
        // RowCause defaulted to manual.
        rowCause = Schema.Core_CCV__Share.RowCause.Manual;        
    }

   
    public static boolean manualShareList(List<Core_CCV_Sharing> ccvShareObjs){
                        
        List<Core_CCV__Share> ccvShareList = new List<Core_CCV__Share>();
        Core_CCV__Share ccvShare;

        for (Core_CCV_Sharing ccvShareObj : ccvShareObjs)
        {  
            // Create new sharing object for the custom object Job.
            ccvShare = new Core_CCV__Share();
            
            // Set the ID of record being shared.
            ccvShare.ParentId = ccvShareObj.ccvId;
           
            // Set the ID of user or group being granted access.
            ccvShare.UserOrGroupId = ccvShareObj.userId;
            
            // Set the access level.
            ccvShare.AccessLevel = 'Edit';
            
            // Set rowCause to 'manual' for manual sharing.
            // This line can be omitted as 'manual' is the default value for sharing objects.
            ccvShare.RowCause = Schema.Core_CCV__Share.RowCause.Manual;
              
            ccvShareList.add(ccvShare);
        }
        
        // Insert the sharing record and capture the save result. 
        // The false parameter allows for partial processing if multiple records passed 
        // into the operation.
        List<Database.SaveResult> srList = Database.insert(ccvShareList, false);

        for (Database.SaveResult sr : srList)        
        {
            // Process the save results.
            if (!sr.isSuccess()) {
                // Get first save result error.
                Database.Error err = sr.getErrors()[0];
                
                // Check if the error is related to trival access level.
                // Access levels equal or more permissive than the object's default 
                // access level are not allowed. 
                // These sharing records are not required and thus an insert exception is acceptable. 
                if (err.getStatusCode() == StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION  &&  
                    err.getMessage().contains('AccessLevel')) {
                    // Indicates success.
                    continue;
                }
                else                     
                    return false;  // Indicates failure.
            }
        }

        return true;
    }          
}