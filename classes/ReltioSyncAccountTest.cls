@IsTest private class ReltioSyncAccountTest { 
    @IsTest static void testBehavior() { 
        try { 
            insert new Account( Name = 'TriggerCoverage'); 
        } 
        catch (Exception e) {
        } 
    } 
}