({
    searchFilesWithTitle : function(component){
        //data showing in table
        var dataLibraryList = component.get("v.libraryList");
        
        // all data featched from apex when component loaded
        var allDataLibraryList = component.get("v.unfilteredLibraryList");

        //Search tems  
        var searchKey = component.get("v.searchString");
        // check is data is not undefined and its lenght is greater than 0
        if(dataLibraryList !=undefined || dataLibraryList.length>0){  
            // filter method create a new array tha pass the test (provided as function)
            var filteredLibraryList = [];
            for(var libraryRecord in allDataLibraryList){
                let allDataLibraryListValues = [];
                allDataLibraryListValues = allDataLibraryList[libraryRecord].value;
                var innerFilteredLibraryList = [];
                for(var key in allDataLibraryListValues){
                    var filterRecord1 = allDataLibraryListValues[key].value.filter(word => (!searchKey) || word.contentTitle.toLowerCase().indexOf(searchKey.toLowerCase()) > -1);
                    innerFilteredLibraryList.push({key : allDataLibraryListValues[key].key, value : filterRecord1});
                }
                filteredLibraryList.push({key : allDataLibraryList[libraryRecord].key, value : innerFilteredLibraryList});
            }
        }
        // set new filtered array value to data showing in the table.  
        component.set("v.libraryList", filteredLibraryList);
        
        // check if searchKey is blank  
        if(searchKey==''){  
            // set unfiltered data to data in the table.  
            component.set("v.libraryList",component.get("v.unfilteredLibraryList")); 
        }  
    }
})