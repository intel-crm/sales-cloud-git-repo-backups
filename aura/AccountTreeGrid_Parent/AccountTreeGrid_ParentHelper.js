({
	doInIt : function(component) {
        // Fetching Salesforce Base URL
        this.getsfdcBaseUrl(component);
        // Apex Call to Fetch All Ultimate Accounts which are comarketing Active
		var action = component.get("c.fetchUltimateAccounts");
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.accountsToDisplay",response.getReturnValue());
                component.set("v.listOfAllUltimateAccounts",response.getReturnValue());
                // On Page load ,set totalDisplayedAccounts to number of ultimate accounts fetched from server
                component.set("v.totalDisplayedAccounts", component.get("v.listOfAllUltimateAccounts").length);
                // Once accounts fetched; hide spinner
                component.set('v.showSpinner',false);
             }
            else{
                //Handling Server Exception
            }
        });
        $A.enqueueAction(action);
	},
    
    /* Calling Apex method to get Salesforce Base Url */
    getsfdcBaseUrl : function(component){        
        var action = component.get("c.fetchSalesforceBaseURL");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.salesforceBaseURL",response.getReturnValue());
             }
            else{
                //Handling Server Exception
            }
        });
        $A.enqueueAction(action);
    },
    
    /* Getting Searched Account records and displaying in component and calling Paginator's function */
    fetchSearchedRecords: function (component){
        
        var searchTextAcctName = '';
        searchTextAcctName = component.get("v.accountNameSearchText");
        // Getting List of all Ultimate Accounts
        var listOfAllUltimateAccounts = component.get("v.listOfAllUltimateAccounts");
        // If Search text is empty or undefined then Display all the accounts
        if(searchTextAcctName === '' || searchTextAcctName === undefined){
            component.set("v.accountsToDisplay",listOfAllUltimateAccounts);
        }
        else{
			// Filtering the account list on searched text and returning it          
            var filteredAccounts = listOfAllUltimateAccounts.filter(function (account){ 
            	return account.Name.toLowerCase().includes(searchTextAcctName.toLowerCase());                                                     
            });
            // If the filtered accounts is not empty then display those accounts
            if(filteredAccounts != null && filteredAccounts.length>0 && filteredAccounts != 'undefined'){
                component.set("v.accountsToDisplay",filteredAccounts);
            }
            else{
                component.set("v.accountsToDisplay",[]);
            }
        }
        var accountsToDisplay = component.get("v.accountsToDisplay");
        component.set("v.totalDisplayedAccounts", accountsToDisplay.length);

        var paginationComponent = component.find('paginatorComponent');
        // Calling Paginator function to handle Pagination when a search is made
        paginationComponent.handlePaginationOnSearch(accountsToDisplay, accountsToDisplay.length);
    },
    
    /*Displaying Records on the Page depending upon Page size*/
    handleRecordsOnPageChange : function(component, event){
        
        console.log('InsidehandleRecordsOnPageChange',JSON.stringify(event));
        var eventRecords = event.Xo;
        var accountsToDisplay = [];
        for(var key in eventRecords){
        	var value = eventRecords[key];
            accountsToDisplay.push(value);
        }
        // Setting accountsToDisplay attribute
        component.set("v.accountsToDisplay",accountsToDisplay);
    }
})