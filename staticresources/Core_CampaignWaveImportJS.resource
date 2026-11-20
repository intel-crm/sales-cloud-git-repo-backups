$j = jQuery.noConflict();

var currResults;     // Current result set displayed on the page
var currSAQL;        // Current SAQL query to get the result set
var datasetMap = {};
var colSAQL = [];
var colLength = 0;

// "Loading" status images
var imgLoadingLenses = '<img src="/img/loading32.gif" id="imgLoadingLenses" style="height:18px;position:relative;top:4px"/>';
var imgLoadingResults = '<img src="/img/loading32.gif" id="imgLoadingResults" style="position:relative;left:8px;margin-bottom:12px"/>';

// Set VF remoting timeout to 30 seconds (this is default but gives us a good place to change it as needed)
Visualforce.remoting.timeout = 30000;

// When the page is ready for Javascript to start executing, set its initial state and kick off all of the
// logic to make the initial calls to get lenses/datasets
$j(document).ready(function(){
    getBaseURL();
    getSessionID();
    
    // Get a handle for the iframe so we can populate it to parse compact queries to real SAQL later
    iframeSaved = $j("#queryIFrame").remove();
    iframeSrcBase = iframeSaved[0].src;
    
    // Set all of the UI elements to the proper state for "loading lenses" - these will be reverted back later
    $j("#lensAttributesContainer").hide();
    $j("#resultsContainer").hide();
    $j("#btnShowLensData").hide();
    $j("#btnPreviewData").hide();
    $j("#btnDownloadCSV").hide();
    $j("#lensesLoading").append(imgLoadingLenses);
    
    // Get our lenses & datasets
    getLenses();
    getDatasets();
});

function getBaseURL(){
    Core_CampaignWaveImportController.getBaseURL(function(result, event){
        sessionStorage.baseURL = result;
    },{escape: false});
}

function getSessionID(){
    Core_CampaignWaveImportController.getSessionID(function(result, event){
        sessionStorage.sessionID = result;
    });
}

// Get the initial list of lenses the user has access to
function getLenses(){
    
    // Use VF remoting to invoke the controller method to get the lenses
    return Core_CampaignWaveImportController.getLenses(function(result, event){
        
        // Parse the resulting JSON
        var lensesJson = JSON.parse(result);
        
        // Render the select list based on the JSON
        $j("#lensList").empty();
        $j.each(lensesJson.lenses, function(index, lens) {
            $j("#lensList").append('<option value="' + lens.id + '">' + lens.label + '</option>');
        });
        
        // Revert back from the "loading" state, to allow user interaction
        $j("#imgLoadingLenses").remove();
        $j("#btnShowLensData").show();
        $j("#btnPreviewData").show();
        $j("#btnDownloadCSV").show();
        
    }, {escape:false});
}

// Get our datasets in a similar way as lenses
function getDatasets(){
    Core_CampaignWaveImportController.getDatasets(function(result, event){
        resultJson = JSON.parse(result);
        $j.each(resultJson.datasets, function(index, dataset){
           datasetMap[dataset.name] = dataset.id + '/' + dataset.currentVersionId 
        });
    },{escape:false});
}

// Invoked from all 3 buttons, this is the main function that pulls data for the selected lens
//   - csv: indicates whether or not we're constructing the CSV format (or just the actual lens data)
//   - download: indicates whether or not we should the download after pulling the data
function showData(csv, download){
    $j('#noteError').html('');
    getOneLens($j("#lensList")[0].value, csv, download);
}

// Get the data for the selected lens
function getOneLens(lensId, csv, download){
    colSAQL = [];
    colLength = 0;
    currResults = null;
    currSAQL = null;
    
    // Set the UI elements to a "loading" state - we'll revert them back later
    $j("#resultsContainer").hide();
    $j("#lensAttributes").empty();
    $j("#lensAttributesContainer").hide();
    $j("#resultsLoading").append(imgLoadingResults);
    
    // Use VF remoting to pull the data by invoking the controller method
    return Core_CampaignWaveImportController.getOneLens(lensId, globalSid, function(result, even){
        
        var entireResult = JSON.parse(result);
        var lensJson = JSON.parse(entireResult.lensJson);
        var xmdJson = JSON.parse(entireResult.xmdJson);
        
        xmdJson.versionId = entireResult.datasetVersion;
        
        queryCompact = unescapeHtml(lensJson.state.query.query);
        queryCompact = queryCompact.split("&quot;").join('"');
        queryCompact = queryCompact.split("&amp;quot;").join('"');
        queryJson = JSON.parse(queryCompact);
        
        var tempState = {};
        tempState.query = queryJson;
        var tempDataset = lensJson.dataset;
        
        // Display the lens components (as FYI)
        displayComponents(queryJson, lensJson.visualizationType, lensJson.label);
        
        // Parse the compact query into real SAQL (then display and potentially download it)
        parseStep(tempState, xmdJson, tempDataset, csv, download)
        
     },{escape:false});
}

// Display the components of the lens, for informational purposes
function displayComponents(compJson, vizType, lensName) {
    // measures
    var htmlToAppend = '<h1 id="lensName" style="font-size:1.2em">'+lensName+'</h1>';
    htmlToAppend += '<dl style="margin-top: 15px"><dt>Visualization Type</dt><dd>';
    
    if (vizType == "valuestable"){
        htmlToAppend += vizType + '</dd><dt>Values</dt><dd>';
        $j.each(compJson.values, function(index, item){
            htmlToAppend += item
            if (index != compJson.values.length - 1) htmlToAppend += ", ";
        });
    }
    else{
        htmlToAppend += vizType + '</dd><dt>Measures</dt><dd>';
        if('measures' in compJson){
            $j.each(compJson.measures, function(index, item){
                htmlToAppend += item[0] + " " + item[1];
                if (index != compJson.measures.length - 1) htmlToAppend += ', ';
            });
        }
        else{
            htmlToAppend += '<em>None</em>';
        }
        htmlToAppend += '</dd>';

        // groups
        htmlToAppend += '<dt>Groups</dt><dd>';
        if('groups' in compJson){
            $j.each(compJson.groups, function(index, item){
                if ($j.type(item) == 'string'){
                    htmlToAppend += item;
                }
                else if($j.type(item) == 'array'){
                    htmlToAppend += '(' + item.join(', ') + ')';
                }
                if (index != compJson.groups.length - 1) htmlToAppend += ', ';
            });
        }
        else{
            htmlToAppend += '<em>None</em>';
        }
        htmlToAppend += '</dd>';
    }
    
    // filters
    htmlToAppend += '<dt>Filters</dt><dd>';
    if('filters' in compJson){
        $j.each(compJson.filters, function(index,item){
            if (item[2] != null){
                htmlToAppend += '\'' + item[0] + '\' ' + item[2] + ' ' + '[' + item[1].join(', ') + ']';
            }
            else {
                htmlToAppend += '\'' + item[0] + '\' ' + 'in' + ' ' + '[' + item[1].join(', ') + ']';
            }
            if (index != compJson.filters.length - 1) htmlToAppend += ', ';
        });
    }
    else{
        htmlToAppend += '<em>None</em>';
    }
    htmlToAppend += '</dd>';
    htmlToAppend += '</dl>';

    $j("#lensAttributes").empty();
    //$j("#lensAttributes").append(htmlToAppend);
    $j("#lensAttributes").show();
    $j("#lensAttributesContainer").show();
}

// Parse the compact query into real SAQL (then display and potentially download it)
function parseStep(state, xmd, dataset, csv, download) {
    var def = $j.Deferred();
    var query;
    if(state.query) {
        query = state.query;
    } else if (state.columns) {
        query = state.columns[0].query;
    } else if (state.type == "static") {
        query = { pigql: "Static step\nValues:" + JSON.stringify(state.values,null,2) }; // bit of a hack
    }

    if(!query.pigql || (query.pigql && query.pigql.length == 0)) {
        parseQuery(query, xmd, dataset, def);
    } else {
        var query = query.pigql;
        query = query.replace(/[;]\s*/g,";\n").replace(/[;][\\]n/g,";\n");
        for (var each in datasetMap){
            query = query.replace('load "' + each + '"', 'load "' + datasetMap[each] + '"'); 
        }
        def.resolve(query);
    }
    
    def.then(function(str) {
        currSAQL = str;
        
        // Now get the query results (then display and potentially download)
        var results = getQueryResults(str, csv, download);
        
    }, function(err) {
        showMessage("Could not parse query. Please see console for error details.", err);
    }); 
}

function parseQuery(queryObj, xmdObj, dataset, def) {
    // Call the parser IFRAME. Why? Because edge.Core.js doesn't play nicely with the rest of the page.
    // Write the lens query to sessionStorage (with timestamp ID and pass to the IFRAME for parsing)
    var storageKey = new Date().getTime() + "";
    var value = {
        lens: JSON.stringify(queryObj),
        dataset: dataset._uid || dataset.id,
        xmd: JSON.stringify(xmdObj),
        saql: null,
        error: null
    }
    sessionStorage.setItem(storageKey + "_PARSE", JSON.stringify(value));
    
    $j("#forIframe").html(""); 
    $j("#forIframe").append($j("<IFRAME />").attr("src", iframeSrcBase +"#key=" + storageKey));

    // Start polling saql key to check for a value -- the parser will write to this
    var intId = setInterval(function() {
        storage = JSON.parse(sessionStorage.getItem(storageKey + "_PARSE"));
        if(storage.saql || storage.error) {
            clearInterval(intId);
            if(storage.saql) def.resolve(storage.saql);
            if(storage.error) def.reject({ error: storage.error, lens: storage.lens });
            sessionStorage.removeItem(storageKey + "_PARSE");
            $j("#forIframe").html("");
        }
    }, 500);
    setTimeout(function() { 
        sessionStorage.removeItem(storageKey + "_PARSE");
        clearInterval(intId); 
        $j("#forIframe").html("");
        def.reject({ error: "Query parsing timed out.", lens: storage.lens });
    }, 15000); // timeout after 15 seconds
}

// Get the query results (then display and potentially download)
function getQueryResults(queryString, csv, download){
    Core_CampaignWaveImportController.getQueryResults(queryString, csv, function(result, event){
        $j("#imgLoadingResults").remove();
        if (event.status === true) {
            resultsJson = JSON.parse(JSON.parse(result));
            showResults(resultsJson, csv, download);
        }
        else {
            showMessage(" ", event.message);
        }
    },{escape: false});
}

// Show the results (then potentially download them)
function showResults(jsonResults, csv, download){
    $j("#tableContainer").html("");
    
    if (jsonResults.results.records.length == 0) {
        showMessage("Query generated no results.", " ");
    }
    else {
        var tableHtml = '<table id="resultsTable" class="list" width="100%">' +
            '<thead class="rich-table-thead"><tr class="headerRow">';
        
        // If we're building the CSV format, we need to hardcode the column headers since we're not sending them in the JSON,
        // since we're sending the most compact format possible
        if (csv)
            tableHtml += '<th>Account ID</th><th>Account Name</th><th>Account Owner</th><th>Business ID</th><th>Contact ID</th>' +
                '<th>Contact Name</th><th>Contact Email</th><th>Primary Contact</th><th class="headerRow">Assigned To User ID</th>' +
                '<th class="headerRow">Assigned To User Name</th><th class="headerRow">Assigned To User Email</th>' +
                '<th class="headerRow">Last Touch Marketing Activity</th><th class="headerRow">Campaign ID</th>';
        else
            for (var prop in jsonResults.results.records[0]) {
                tableHtml += '<th class="headerRow">' + prop + '</th>';
            }
        tableHtml += '</tr></thead>';
        
        // Iterate through the result set and build a row for each record
        for (var i=0; i<jsonResults.results.records.length; i++) {
            tableHtml += '<tr class="dataRow odd">'
            for (var prop in jsonResults.results.records[i]) {
                tableHtml += '<td>' + jsonResults.results.records[i][prop] + '</td>';
            }
            // For the CSV format, we need 5 blank fields at the end (these will be for user input in Excel)
            if (csv) tableHtml += '<td></td><td></td><td></td><td></td><td></td>';
            tableHtml += '</tr>';
        }
        tableHtml += '</table>';

        $j("#tableContainer").html(tableHtml);
        $j("#resultsContainer").show();
    }
    currResults = jsonResults.results.records;
    
    // If they clicked the download button, go ahead and download the results
    if (download) downloadResults();
}

// Build the CSV file and download it, by creating it as a link on the page, clicking the link, then removing it
function downloadResults() {
    
    if(currResults && currResults.length > 0) {
        var cols = Object.keys(currResults[0]);
        
        var output = "Account ID,Account Name,Account Owner,Business ID,Contact ID,Contact Name,Contact Email," +
            "Primary Contact,Assigned To User ID,Assigned To User Name,Assigned To User Email," +
            "Last Touch Marketing Activity,Campaign ID\n";
        
        for (var i=0; i<currResults.length; i++) {
            for (var j=0; j<cols.length; j++) {
                if (j>0) output += ",";
                quote = (currResults[i][cols[j]] && ("" + currResults[i][cols[j]]).indexOf(',') > -1) ? '"' : '';
                output += quote + currResults[i][cols[j]] + quote;
                if(j==cols.length-1) output += ",,,,,\n";                    
            }
        }
        // Creating the file as a blob lets us scale much higher in Chrome, in # of rows (22K+ instead of 13K)
        var csvData = new Blob([output], {type:'text/csv'});
        var csvUrl = URL.createObjectURL(csvData);
        var element = document.createElement('a');
        element.href = csvUrl;
        element.setAttribute('download', 'results.csv');
        element.style.display = 'none';
        document.body.appendChild(element);
        element.click();
        document.body.removeChild(element);
    }
    else {
        showMessage("No records to download", " ");
    }
}

function unescapeHtml(safe) {
    return $j('<div />').html(safe).text();
}

function showMessage(msg, err) {
    if (err) {
        $j('#noteError').html('Error: ' + err);
        $j("#resultsContainer").hide();
        $j("#lensAttributes").empty();
        $j("#lensAttributesContainer").hide();
        console.error(msg, err);
    }
    else {
        
    }
}