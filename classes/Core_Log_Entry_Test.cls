@isTest
private class Core_Log_Entry_Test {

    private class dummyException extends Exception {}

    static String getFirstTrackedScope() {
        String strScopes = Label.Core_App_Logging_Tracked_Scopes;
        String[] lstScopes = strScopes.split(';');
        if(lstScopes != null && !String.isBlank(lstScopes[0])) {
            return lstScopes[0];
        } else {
            return 'Scope';
        }
    }
    
    static testMethod void testLogEntryWithException() {
        if(getFirstTrackedScope() != '0') { 
            String strLogEntryID = Core_Log_Entry.logEntryWithException('SFDC', 'Test', getFirstTrackedScope(), 'error', 'Message', 'Details', null, null, null, new dummyException());
            system.assert(!String.isBlank(strLogEntryID), 'Log Entry Record Not Created');
        }
    }
    
    static testMethod void testlogEntryWithDetails() {
        if(getFirstTrackedScope() != '0') {
            String strLogEntryID = Core_Log_Entry.logEntryWithDetails('SFDC', 'Test', getFirstTrackedScope(), 'info', 'Message', 'Details', null, null, null);
            system.assert(!String.isBlank(strLogEntryID), 'Log Entry Record Not Created');
        }
    }
	/*
    static testMethod void testlogEntryWithLimits() {
        //this test expects the log method to be on the case trigger
        if(getFirstTrackedScope() != '0') { 
            Case cs = new Case(Origin = 'Phone');
            insert cs;

            List<Core_Log_Entry__c> lstCLE = [Select Id from Core_Log_Entry__c Where Name = 'LogLimits'];
            system.assert(lstCLE != null, 'Log Limits Entry Record Not Created');
        }
    }
	*/
    static testMethod void testlogEntryWithGovernorMaxStmts() {
        if(getFirstTrackedScope() == '0') return;
        //get current limits
        integer intDMLStmtBuffer = Label.Core_App_Logging_DML_Statements_Buffer.isNumeric() ?
                                   Integer.valueOf(Label.Core_App_Logging_DML_Statements_Buffer) : 0;
        
        integer intDMLStmtsRemaining = Limits.getLimitDMLStatements() - Limits.getDMLStatements();

        integer intDMLRowsBuffer = Label.Core_App_Logging_DML_Rows_Buffer.isNumeric() ?
                                   Integer.valueOf(Label.Core_App_Logging_DML_Rows_Buffer) : 0;
        integer intDMLRowsRemaining = Limits.getLimitDMLRows() - Limits.getDMLRows();
        
        String strDMLStats = '**** Test Class: DML Stmt Buffer: ' + intDMLStmtBuffer + ', ' +
            'DML Stmts Remaining: ' + intDMLStmtsRemaining;
        system.debug(strDMLStats);
        
        //How many records to create that overruns the limits
        integer intStmtAvailable = intDMLStmtsRemaining - intDMLStmtBuffer;
        integer intStmtInsert = intStmtAvailable + 10;
        
        strDMLStats = '**** Test Class: intStmtAvailable: ' + intStmtAvailable + ', ' +
                      'intStmtInsert: ' + intStmtInsert;
        system.debug(strDMLStats);

        system.assert(intDMLRowsRemaining > intStmtInsert + intDMLRowsBuffer + 1, 'Not enough DML Rows limit remaining to run this test class. '+ 
                                            'Adjust Core_App_Logging_DML_Statements_Buffer and Core_App_Logging_DML_Rows_Buffer ' +
                                            'custom labels.');

        for(integer i = 0; i < intStmtInsert; i++) {
            Core_Log_Entry.logEntryWithDetails('SFDC', 'Test', getFirstTrackedScope(), 'info', 'Message', 'Details', null, null, null);
        }
        
        //Check number of records created.  The assertion test for one extra record because of logging the limit being hit.
        List<Core_Log_Entry__c> lstCLE = [Select Id from Core_Log_Entry__c];

        system.assert(lstCLE != null, 'Log Entry Records Not Created');
        
        intDMLStmtsRemaining = Limits.getLimitDMLStatements() - Limits.getDMLStatements();
        
        system.assert(intDMLStmtsRemaining == intDMLStmtBuffer, 'Incorrect Number of Log Entries Created: ' + intDMLStmtsRemaining);
    }
}